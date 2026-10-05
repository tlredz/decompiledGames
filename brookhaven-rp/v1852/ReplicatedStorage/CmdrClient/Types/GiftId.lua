local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local TableUtil = require(packages.TableUtil)
local v = {}

for _, v2 in Gamepasses.All do
	v[Gamepasses.GetName(v2)] = Gamepasses.GetGiftId(v2)
end

for _, v2 in DevProducts.All do
	v[DevProducts.GetName(v2)] = DevProducts.GetGiftId(v2)
end

local function fn(registry)
	return {
		DisplayName = "Gamepass name or developer product ID (prefixed with #)",
		Prefixes = "# nonNegativeInteger",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(TableUtil.Keys(v))(p)
		end,
		ValidateOnce = function(p)
			return v[p] ~= nil, "No gift with that name could be found."
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return v[p]
		end,
		Default = function(_)
			return TableUtil.Keys(v)[1]
		end
	}
end

return function(registry)
	registry:RegisterType("giftId", (fn(registry)))
end