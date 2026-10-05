local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local GlobalStateManager = require(ReplicatedStorage._FRAMEWORK.Features.GlobalStateManager)
require(ReplicatedStorage.Utilities.Promise)
local v = nil
local model = nil
local v2 = nil
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getTreadmillFolder()
	return Workspace:FindFirstChild("Treadmill")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isTreadmillActiveHere(p)
	return p ~= nil and p.active and p.expiresAt > os.time()
end

local function getServerState()
	local readyToMutate = GlobalStateManager.isReadyToMutate("AdminAbuseTreadmill_State")
	local v4 = v
	local active

	if v4 == nil then
		active = false
	else
		active = v4.active and v4.expiresAt > os.time()
	end

	local v6 = {
		available = v2 ~= nil and Workspace:FindFirstChild("Treadmill") ~= nil,
		ready = readyToMutate,
		active = active,
		expiresAt = 0
	}
	local expiresAt

	if active then
		expiresAt = v.expiresAt
	end

	v6.expiresAt = expiresAt
	return v6
end

local function setTreadmillInstanceEnabled(flag: boolean)
	if flag then
		if not v2 then
			return
		end

		local treadmillFolder = getTreadmillFolder() -- equivalent call inferred; original call site unknown

		if not treadmillFolder then
			warn("[AdminAbuseTreadmill] Workspace folder 'Treadmill' is missing")
			return
		end

		if not model then
			local clone = v2:Clone()
			clone:RemoveTag("AdminAbuseTreadmillModel")
			model = clone
		end

		model.Parent = treadmillFolder

		if model and model:IsA("Model") and v3 then
			local boundingBox, v4 = model:GetBoundingBox()
			local collidedTreadmillPlayers = v3.GetCollidedTreadmillPlayers(v3, boundingBox, v4)
			v3.DespawnPlayers(v3, collidedTreadmillPlayers)
		end
	elseif model then
		model:Destroy()
		model = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTreadmillInstance(p)
	setTreadmillInstanceEnabled(isTreadmillActiveHere(p or v))
end

local function applyStoredState(p)
	local v4 = nil

	if type(p) == "table" and type(p.active) == "boolean" and type(p.expiresAt) == "number" then
		v4 = p
	end

	v = v4
	updateTreadmillInstance() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function observeMutation(p: string, object)
	object:catch(function(p2)
		warn((`[AdminAbuseTreadmill] Failed to {p}: {tostring(p2)}`))
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTemplate(p)
	if p.Parent ~= ServerStorage then
		p.Parent = ServerStorage
	end

	if not v2 then
		v2 = p
		setTreadmillInstanceEnabled(isTreadmillActiveHere(v))
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsServer() then
			local PersonalTreadmillManager = require(ServerScriptService.PersonalTreadmillManager)
			v3 = PersonalTreadmillManager

			for _, v4 in CollectionService:GetTagged("AdminAbuseTreadmillModel") do
				setTemplate(v4) -- equivalent call inferred; original call site unknown
			end

			CollectionService:GetInstanceAddedSignal("AdminAbuseTreadmillModel"):Connect(setTemplate)
			GlobalStateManager.subscribeToState("AdminAbuseTreadmill_State", applyStoredState)
			task.spawn(function()
				Workspace:WaitForChild("Treadmill")
				updateTreadmillInstance() -- equivalent call inferred; original call site unknown
			end)
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() then
			return
		end

		if model then
			local v4 = v
			local v5

			if v4 == nil then
				v5 = false
			else
				v5 = v4.active and v4.expiresAt > os.time()
			end

			if not v5 and model then
				model:Destroy()
				model = nil
			end
		end
	end
})
local AdminAbuseTreadmill = {}

function AdminAbuseTreadmill.getState()
	assert(RunService:IsServer(), "AdminAbuseTreadmill.getState can only be called on the server")
	return (getServerState())
end

function AdminAbuseTreadmill.start(value: number?)
	assert(RunService:IsServer(), "AdminAbuseTreadmill.start can only be called on the server")
	local serverState = getServerState()

	if not serverState.ready then
		return false, "Admin Abuse treadmill state is still loading"
	end

	if not serverState.available then
		return false, "Admin Abuse treadmill model or workspace folder is missing"
	end

	if serverState.active then
		return false, "Admin Abuse treadmill is already active"
	end

	local v4 = value or 1800

	if v4 ~= v4 or v4 == 1e999 or v4 == -1e999 then
		return false, "Admin Abuse treadmill duration must be finite"
	end

	local v5 = math.clamp(v4, 1, 1800)
	local now = os.time()
	local v6, v7 = GlobalStateManager.setState("AdminAbuseTreadmill_State", {
		active = true,
		expiresAt = now + v5
	})
	observeMutation("broadcast activation", v6) -- equivalent call inferred; original call site unknown
	observeMutation("persist activation", v7) -- equivalent call inferred; original call site unknown
	return true, "Admin Abuse treadmill started globally"
end

function AdminAbuseTreadmill.stop()
	assert(RunService:IsServer(), "AdminAbuseTreadmill.stop can only be called on the server")

	if not GlobalStateManager.isReadyToMutate("AdminAbuseTreadmill_State") then
		return false, "Admin Abuse treadmill state is still loading"
	end

	local v4, v5 = GlobalStateManager.setState("AdminAbuseTreadmill_State", {
		active = false,
		expiresAt = 0
	})
	observeMutation("broadcast stop", v4) -- equivalent call inferred; original call site unknown
	observeMutation("persist stop", v5) -- equivalent call inferred; original call site unknown
	return true, "Admin Abuse treadmill stopped globally"
end

return AdminAbuseTreadmill