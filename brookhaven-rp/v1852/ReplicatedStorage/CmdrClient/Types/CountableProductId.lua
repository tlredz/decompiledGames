local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local TableUtil = require(packages.TableUtil)
local v = {}

for k, v2 in CountableDevProducts.All do
	v[k] = CountableDevProducts.GetId(v2)
end

local function fn(registry)
	return {
		DisplayName = "Countable dev product name",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(TableUtil.Keys(v))(p)
		end,
		ValidateOnce = function(p)
			return v[p] ~= nil, "No countable dev product with that name could be found."
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return v[p]
		end,
		Default = function()
			return TableUtil.Keys(v)[1]
		end
	}
end

return function(registry)
	registry:RegisterType("countableProductId", (fn(registry)))
end