local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
local ABTestExperiments = require(ReplicatedStorage.Shared.ABTestExperiments)
require(ReplicatedStorage.Shared.ABTestExperiments.ABTestTypes)
local localPlayer = Players.LocalPlayer
local ABTestController = {}
ABTestController._loaded = false
ABTestController._loadedSignal = Signal.new()
ABTestController._remoteConfigs = {}

function ABTestController._runExperiments(p)
	if not p._remoteConfigs then
		return
	end

	for _, aBTestExperiment in ABTestExperiments do
		if aBTestExperiment.Disabled then
			continue
		end

		local v = p._remoteConfigs[aBTestExperiment.RemoteConfig] or aBTestExperiment.DefaultState
		local state = aBTestExperiment.States[v]

		if state and state.Client then
			task.defer(state.Client, localPlayer, v)
		end
	end
end

function ABTestController:IsLoaded()
	return self._loaded
end

function ABTestController.OnLoad(p, on_loadedSignal)
	return p._loadedSignal:Connect(on_loadedSignal)
end

function ABTestController:GetRemoteConfig(p)
	return self._remoteConfigs[p], self:IsLoaded()
end

function ABTestController.Start(_) end

return ABTestController