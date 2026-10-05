local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local Config = require(script.Config)
local Director = require(script.Director)
local SupportBarView = require(script.SupportBarView)
require(script.Types)
local isServer = RunService:IsServer()
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local strictInterface = t.strictInterface({
	active = t.boolean,
	totalVotes = t.numberConstrained(0, 1000000000000),
	totalNoise = t.numberConstrained(0, 1),
	totalGrowthPerMinute = t.numberConstrained(-1000000000, 1000000000),
	cruzShare = t.numberConstrained(0, 1),
	shareNoise = t.numberConstrained(0, 1),
	driftPerSecond = t.numberConstrained(0, 1),
	autoMode = t.boolean,
	autoMinShare = t.numberConstrained(0, 1),
	autoMaxShare = t.numberConstrained(0, 1),
	autoIntervalSeconds = t.numberConstrained(1, 3600)
})
local SupportBar = {
	remotes = remo.createRemotes({
		supportBar = remo.namespace({
			snapshot = remo.remote(),
			requestSnapshot = remo.remote().middleware(remo.throttleMiddleware(5))
		})
	}).supportBar
}
local now = 0
local now2 = 0
local snapshot = nil
local v2 = nil
local v3 = nil
local v4 = nil

function checkApplyReady(p)
	local v5, v6 = strictInterface(p)

	if not v5 then
		return false, nil, string.format("Invalid support bar settings: %s", (tostring(v6)))
	end

	if p.autoMinShare > p.autoMaxShare then
		return false, nil, "Auto mode needs its minimum share below its maximum."
	end

	if GlobalStateManager.isReadyToMutate("SupportBar_State") then
		return true, p, ""
	end

	return false, nil, "Support bar state is still loading"
end

function applySnapshot(p)
	snapshot = p
	SupportBar.remotes.snapshot:fireAll(p)
end

function observeMutation(p: string, object)
	object:catch(function(p2)
		logger:warn(string.format("failed to %s: %s", p, (tostring(p2))))
	end)
end

function persistConfig(p)
	local v5, v6 = GlobalStateManager.setState("SupportBar_State", p)
	observeMutation("broadcast support bar state", v5)
	observeMutation("persist support bar state", v6)
end

function applyStoredState(p)
	if strictInterface(p) then
		Director.setConfig(p)
		now = os.clock()
		applySnapshot(Director.buildSnapshot())
	end
end

function handleApply(_, p)
	local v5, v6, message = checkApplyReady(p)

	if not v5 then
		return {
			success = false,
			message = message
		}
	end

	persistConfig(v6)
	return {
		success = true,
		message = "Support bar updated."
	}
end

function handleFetch()
	return {
		config = Director.getConfig(),
		snapshot = snapshot
	}
end

function registerAdminEvents()
	local registerClientEvent = AdminRemote.RegisterClientEvent
	local v8

	if isServer then
		v8 = handleApply
	end

	v3 = registerClientEvent("SupportBar_Apply", "cui.liveops.manage", true, v8)
	local registerClientEvent2 = AdminRemote.RegisterClientEvent
	local v12

	if isServer then
		v12 = handleFetch
	end

	v4 = registerClientEvent2("SupportBar_Fetch", "cui.liveops.supportBar", false, v12)
end

function serverInit()
	GlobalStateManager.subscribeToState("SupportBar_State", applyStoredState)
	SupportBar.remotes.requestSnapshot:connect(function(p)
		local v5 = snapshot

		if v5 then
			SupportBar.remotes.snapshot:fire(p, v5)
		end
	end)
	now2 = os.clock()
end

function serverUpdate()
	local now3 = os.clock()
	local v5 = now3 - now2
	now2 = now3

	if Director.getConfig().active then
		Director.step(v5)

		if now3 - now >= Config.broadcastIntervalSeconds then
			now = now3
			applySnapshot(Director.buildSnapshot())
		end
	end
end

function clientInit()
	SupportBar.remotes.snapshot:connect(function(p)
		snapshot = p
		local v5 = v2

		if v5 then
			v5.update(p)
		end
	end)
end

function clientUIInit()
	local v5 = SupportBarView.mount(Players.LocalPlayer:WaitForChild("PlayerGui"))
	v2 = v5
	local v6 = snapshot

	if v6 then
		v5.update(v6)
	end

	SupportBar.remotes.requestSnapshot:fire()
end

function SupportBar.getDefaults()
	return table.clone(Config.defaults)
end

function SupportBar.adminApply(p)
	assert(not isServer, "supportBar.adminApply is client-only")
	return v3:Fire(p)
end

function SupportBar.adminFetch()
	assert(not isServer, "supportBar.adminFetch is client-only")
	return v4:Fire({})
end

local registerFeature = FeatureManager.RegisterFeature
local name = script.Name
local v5 = {
	OnInit = function()
		registerAdminEvents()

		if isServer then
			serverInit()
		else
			clientInit()
		end
	end,
	OnUIInit = clientUIInit,
	OnUpdate = 0
}
local onUpdate

if isServer then
	onUpdate = serverUpdate
end

v5.OnUpdate = onUpdate
registerFeature(name, v5)
return SupportBar