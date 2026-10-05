local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local TableUtil = require(packages.TableUtil)

local function fn(registry)
	return {
		DisplayName = "Gamepass name or gamepass ID (prefixed with #)",
		Prefixes = "# nonNegativeInteger",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(TableUtil.Keys(Gamepasses.All))(p)
		end,
		ValidateOnce = function(p)
			return Gamepasses.All[p] ~= nil, "No gamepass with that name could be found."
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return Gamepasses.GetId(Gamepasses.All[p])
		end,
		Default = function(_)
			return TableUtil.Keys(Gamepasses.All)[1]
		end
	}
end

return function(registry)
	registry:RegisterType("gamepassId", (fn(registry)))
end