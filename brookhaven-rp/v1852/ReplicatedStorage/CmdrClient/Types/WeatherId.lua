local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local packages = ReplicatedStorage:WaitForChild("Packages")
local TableUtil = require(packages.TableUtil)
return function(registry)
	local function stringsGetter()
		return TableUtil.Keys(GameConstants.WeatherTypes)
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("weatherType")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end