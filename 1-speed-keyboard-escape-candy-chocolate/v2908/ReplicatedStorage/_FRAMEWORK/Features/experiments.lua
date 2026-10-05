local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local PlayerExperimentCard = require(script.PlayerExperimentCard)
require(script.Types)
local OngoingExperiments = require(script.OngoingExperiments)
local isServer = RunService:IsServer()
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local Experiments = {
	remotes = remo.createRemotes({
		experiments = remo.namespace({
			requestEnrollment = remo.remote(t.string).middleware(remo.throttleMiddleware(0.5)),
			variantAssigned = remo.remote()
		})
	}).experiments,
	ongoing = OngoingExperiments
}
local ongoingExperimentsByConfigKey = {}
local v = {}

local function checkExperimentSession(data)
	if ongoingExperimentsByConfigKey[data.configKey] then
		return false, string.format("experiments: %s is already registered", data.configKey)
	end

	if table.find(data.variantGroups, data.controlGroup) then
		return true, nil
	end

	return
		false,
		string.format(
			"experiments: control group %q of %s is not one of its variant groups",
			data.controlGroup,
			data.configKey
		)
end

local function checkEnrollmentRequest(p, p2: string)
	if ongoingExperimentsByConfigKey[p2] then
		return true, nil
	end

	return false, string.format("%s requested enrollment in unknown experiment %q", p.Name, p2)
end

local function registerOngoing()
	for _, ongoingExperiment in OngoingExperiments do
		local v2, flag

		if ongoingExperimentsByConfigKey[ongoingExperiment.configKey] then
			v2 = string.format("experiments: %s is already registered", ongoingExperiment.configKey)
			flag = false
		elseif table.find(ongoingExperiment.variantGroups, ongoingExperiment.controlGroup) then
			flag = true
		else
			v2 = string.format(
				"experiments: control group %q of %s is not one of its variant groups",
				ongoingExperiment.controlGroup,
				ongoingExperiment.configKey
			)
			flag = false
		end

		if flag then
			ongoingExperimentsByConfigKey[ongoingExperiment.configKey] = ongoingExperiment
		else
			error(v2)
		end
	end
end

local function cardFor(p)
	if not v[p] then
		v[p] = PlayerExperimentCard.new(p, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	return v[p]
end

local function serverInit()
	Players.PlayerAdded:Connect(cardFor)

	for _, v2 in ipairs(Players:GetPlayers()) do
		if not v[v2] then
			v[v2] = PlayerExperimentCard.new(v2, Experiments.remotes, ongoingExperimentsByConfigKey)
		end

		local _ = v[v2]
	end

	Players.PlayerRemoving:Connect(function(player)
		v[player]:Destroy()
		v[player] = nil
	end)
	Experiments.remotes.requestEnrollment:connect(function(p, p2)
		local flag, v2

		if ongoingExperimentsByConfigKey[p2] then
			flag = true
		else
			v2 = string.format("%s requested enrollment in unknown experiment %q", p.Name, p2)
			flag = false
		end

		if flag then
			v[p]:enroll(p2)
		else
			logger:warn(v2)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clientInit()
	local localPlayer = Players.LocalPlayer

	if not v[localPlayer] then
		v[localPlayer] = PlayerExperimentCard.new(localPlayer, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	local _ = v[localPlayer]
	Experiments.remotes.variantAssigned:connect(function(p: string, p2: string)
		v[Players.LocalPlayer]:receiveAssignment(p, p2)
	end)
end

function Experiments.getExperimentSession(p: string)
	return ongoingExperimentsByConfigKey[p]
end

function Experiments:getPlayerVariantGroup(p2: string)
	if isServer then
		assert(self, "experiments: player required on the server")
		return v[self]:getPlayerVariantGroup(p2)
	end

	local localPlayer = Players.LocalPlayer

	if not v[localPlayer] then
		v[localPlayer] = PlayerExperimentCard.new(localPlayer, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	return v[localPlayer]:getPlayerVariantGroup(p2)
end

function Experiments:isPlayerEnrolled(p2: string)
	if isServer then
		assert(self, "experiments: player required on the server")
		return v[self]:isPlayerEnrolled(p2)
	end

	local localPlayer = Players.LocalPlayer

	if not v[localPlayer] then
		v[localPlayer] = PlayerExperimentCard.new(localPlayer, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	return v[localPlayer]:isPlayerEnrolled(p2)
end

function Experiments:enroll(p2: string)
	assert(isServer, "experiments: server-only call")
	v[self]:enroll(p2)
end

function Experiments:requestEnrollment()
	assert(not isServer, "experiments: client-only call")
	local localPlayer = Players.LocalPlayer

	if not v[localPlayer] then
		v[localPlayer] = PlayerExperimentCard.new(localPlayer, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	v[localPlayer]:requestEnrollment(self)
end

function Experiments:onVariantAssigned(callback)
	assert(not isServer, "experiments: client-only call")
	local localPlayer = Players.LocalPlayer

	if not v[localPlayer] then
		v[localPlayer] = PlayerExperimentCard.new(localPlayer, Experiments.remotes, ongoingExperimentsByConfigKey)
	end

	return v[localPlayer]:onVariantAssigned(self, callback)
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		registerOngoing()

		if isServer then
			serverInit()
			return
		end

		clientInit() -- equivalent call inferred; original call site unknown
	end
})
return Experiments