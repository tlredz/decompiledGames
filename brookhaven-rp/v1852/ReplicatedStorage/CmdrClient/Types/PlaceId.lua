local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local packages = ReplicatedStorage:WaitForChild("Packages")
local TableUtil = require(packages.TableUtil)
return function(registry)
	local function stringsGetter()
		return TableUtil.Keys(GameConstants.PlaceIds)
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("placeType")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))

	for k, placeId in pairs(GameConstants.PlaceIds) do
		local v2 = placeId

		local function stringsGetter2()
			return TableUtil.Keys(v2)
		end

		local function stringToObject2(p: string)
			return p
		end

		local v3 = CmdrUtil.cleanTypeName(("placeId%s"):format(k))
		registry:RegisterType(v3, (CmdrUtil.createTypeDefinition(v3, stringsGetter2, stringToObject2)))
	end
end