local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HousePropSavesConstants = require(ReplicatedStorage.Modules.Client.Houses.HousePropSavesConstants)
local allSlotNames = HousePropSavesConstants.GetAllSlotNames()

local function fn(registry)
	return {
		DisplayName = "House save slot",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(allSlotNames)(p)
		end,
		ValidateOnce = function(p)
			return HousePropSavesConstants.IsValidSlotName(p), "Unknown house save slot"
		end,
		Autocomplete = function(_, p)
			return p
		end,
		Parse = function(p)
			return p
		end,
		Default = function()
			return allSlotNames[1]
		end
	}
end

return function(registry)
	registry:RegisterType("houseSaveSlot", (fn(registry)))
end