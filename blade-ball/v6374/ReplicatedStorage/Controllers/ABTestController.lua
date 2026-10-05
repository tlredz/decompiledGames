local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Packages.GameAnalytics)
local v3 = require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments)
require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments.ABTestTypes)
local localPlayer = Players.LocalPlayer
local ABTestController = {}
ABTestController._loaded = false
ABTestController._loadedSignal = v.new()
ABTestController._remoteConfigs = {}

function ABTestController:_runExperiments()
	if not self._remoteConfigs then
		return
	end

	for _, v4 in v3 do
		if v4.Disabled then
			continue
		end

		local v5 = self._remoteConfigs[v4.RemoteConfig] or v4.DefaultState
		local state = v4.States[v5]

		if state and state.Client then
			task.defer(state.Client, localPlayer, v5)
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
	v2:initClient()
	ReplicatedStorage2:WaitForChild("GameAnalyticsRemoteConfigs").OnClientEvent:Connect(function(items)
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