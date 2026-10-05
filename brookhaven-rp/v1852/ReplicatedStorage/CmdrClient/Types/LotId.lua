local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LotConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.LotConfig)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local packages = ReplicatedStorage:WaitForChild("Packages")
local TableUtil = require(packages.TableUtil)

local function fn(registry)
	return {
		DisplayName = "Lot ID",
		Transform = function(p)
			if LotConfig.isLoaded then
				return p, registry.Cmdr.Util.MakeFuzzyFinder(TableUtil.Keys(LotConfig.cache))(p)
			end

			return p, {}
		end,
		ValidateOnce = function(p)
			if LotConfig.isLoaded then
				return LotConfig.cache[p] ~= nil, "No lot with that name could be found."
			end

			return true
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return LotUtil.CleanLotName(p)
		end,
		Default = function(_)
			if LotConfig.isLoaded then
				return TableUtil.Keys(LotConfig.cache)[1]
			end

			return ""
		end,
		ArgumentOperatorAliases = {
			all = "*"
		}
	}
end

return function(registry)
	local v = fn(registry)
	registry:RegisterType("lotId", v)
	registry:RegisterType("lotIds", registry.Cmdr.Util.MakeListableType(v, {
		Prefixes = "% lots"
	}))
end