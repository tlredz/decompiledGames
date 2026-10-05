local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local packages = ReplicatedStorage:WaitForChild("Packages")
local TableUtil = require(packages.TableUtil)
return function(registry)
	local function stringsGetter()
		local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
		return TableUtil.Keys(FeatureFlagsConfig.GetConfig())
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("featureFlagId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end