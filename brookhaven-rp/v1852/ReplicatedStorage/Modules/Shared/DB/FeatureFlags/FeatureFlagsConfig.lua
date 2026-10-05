local FeatureFlagsConfig = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local ReplicatedDataController

if isServer then
	ReplicatedDataController = nil
else
	ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
end

local ReplicatedDataService

if isServer then
	local ServerScriptService = game:GetService("ServerScriptService")
	ReplicatedDataService = require(ServerScriptService.Modules.PlayerData.ReplicatedDataService)
else
	ReplicatedDataService = nil
end

local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)
FeatureFlagsConfig.remoteConfigDirectory = "FeatureFlags/Config"
FeatureFlagsConfig.isPublic = true
FeatureFlagsConfig.isLoaded = false
FeatureFlagsConfig.cache = nil
FeatureFlagsConfig.featureFlagsOverrides = {}
FeatureFlagsConfig.OverrideChanged = Signal.new()
local v = {}
FeatureFlagsConfig.middlewares = {
	buildOverrideCache = function(items)
		if isServer then
			return items
		end

		local v2, v3 = ReplicatedDataController.GetClientReplicaPromise():await()

		if v2 then
			FeatureFlagsConfig.featureFlagsOverrides = v3.Data.featureFlagsOverrides

			for k, _ in items do
				if FeatureFlagsConfig.featureFlagsOverrides[k] ~= nil then
					warn((`Feature flag [{k}] is being overridden  to [{FeatureFlagsConfig.featureFlagsOverrides[k]}]`))
				end

				if v[k] then
					continue
				end

				v[k] = true
				local v4 = k
				v3:OnSet({ "featureFlagsOverrides", k }, function(p)
					FeatureFlagsConfig.featureFlagsOverrides[v4] = p
					FeatureFlagsConfig.OverrideChanged:Fire(v4)
				end)
			end

			return items
		else
			warn("Failed to get client replica for feature flags")
		end

		return items
	end
}

function FeatureFlagsConfig.GetConfig()
	while not FeatureFlagsConfig.isLoaded do
		task.wait()
	end

	return FeatureFlagsConfig.cache
end

function FeatureFlagsConfig.HasFeatureFlag(p: string)
	return FeatureFlagsConfig.GetConfig()[p] ~= nil
end

function FeatureFlagsConfig.GetFeatureFlagValue(p: string)
	local config = FeatureFlagsConfig.GetConfig()

	if not (config[p] and t.number(config[p])) then
		return 0
	end

	if config[p] == config[p] then
		return config[p]
	end

	return 0
end

function FeatureFlagsConfig.GetFeatureFlagOverride(p, p2: string)
	if not isServer then
		return FeatureFlagsConfig.featureFlagsOverrides[p2]
	end

	local replicatedData = ReplicatedDataService.GetReplicatedData(p)

	if replicatedData == nil then
		return nil
	end

	return replicatedData.featureFlagsOverrides[p2]
end

function FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(p, p2: string)
	local featureFlagOverride = FeatureFlagsConfig.GetFeatureFlagOverride(p, p2)

	if featureFlagOverride ~= nil then
		return featureFlagOverride
	end

	local config = FeatureFlagsConfig.GetConfig()

	if config[p2] then
		return p.UserId % 100 < config[p2]
	end

	return false
end

return FeatureFlagsConfig