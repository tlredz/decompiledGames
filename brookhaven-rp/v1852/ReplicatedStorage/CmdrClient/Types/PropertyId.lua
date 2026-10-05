local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PropertyConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.PropertyConfig)
local packages = ReplicatedStorage:WaitForChild("Packages")
local TableUtil = require(packages.TableUtil)

local function fn(registry)
	return {
		DisplayName = "Property ID",
		Transform = function(p)
			if PropertyConfig.isLoaded then
				return p, registry.Cmdr.Util.MakeFuzzyFinder(TableUtil.Keys(PropertyConfig.cache))(p)
			end

			return p, {}
		end,
		ValidateOnce = function(p)
			if PropertyConfig.isLoaded then
				return PropertyConfig.cache[p] ~= nil, "No property with that name could be found."
			end

			return true
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return p
		end,
		Default = function(_)
			return not PropertyConfig.isLoaded or TableUtil.Keys(PropertyConfig.cache)[1]
		end
	}
end

return function(registry)
	registry:RegisterType("propertyId", (fn(registry)))
end