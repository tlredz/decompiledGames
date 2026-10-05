local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.packages.Signal)
local GameAnalytics = require(ReplicatedStorage.packages.GameAnalytics)
local ABTestExperiments = require(ReplicatedStorage.shared.modules.ABTestExperiments)
require(ReplicatedStorage.shared.modules.ABTestExperiments.ABTestTypes)
local localPlayer = Players.LocalPlayer
local ABTestController = {}
ABTestController._loaded = false
ABTestController._loadedSignal = Signal.new()
ABTestController._remoteConfigs = {}

function ABTestController:_runExperiments()
	if not self._remoteConfigs then
		return
	end

	for _, aBTestExperiment in ABTestExperiments do
		if aBTestExperiment.Disabled then
			continue
		end

		local v = self._remoteConfigs[aBTestExperiment.RemoteConfig] or aBTestExperiment.DefaultState
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

function ABTestController:Start()
	GameAnalytics:initClient()
	ReplicatedStorage:WaitForChild("GameAnalyticsRemoteConfigs").OnClientEvent:Connect(function(items)
		if typeof(items) ~= "table" then
			return
		end

		local remoteConfigs = {}

		for k, item in items do
			local success, result = pcall(HttpService.JSONDecode, HttpService, item)

			if success then
				if result == nil then
					result = item
				end
			else
				result = item
			end

			remoteConfigs[k] = result
		end

		self._remoteConfigs = remoteConfigs

		if not self._loaded then
			self._loaded = true
			self._loadedSignal:Fire(remoteConfigs)
			self:_runExperiments()
		end
	end)
end

return ABTestController