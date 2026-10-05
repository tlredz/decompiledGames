local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehiclePropSavesConstants = require(ReplicatedStorage.Modules.Client.Vehicles.VehiclePropSavesConstants)
local allSlotNames = VehiclePropSavesConstants.GetAllSlotNames()

local function fn(registry)
	return {
		DisplayName = "Vehicle save slot",
		Transform = function(p)
			return p, registry.Cmdr.Util.MakeFuzzyFinder(allSlotNames)(p)
		end,
		ValidateOnce = function(p)
			return VehiclePropSavesConstants.IsValidSlotName(p), "Unknown vehicle save slot"
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
	registry:RegisterType("vehicleSaveSlot", (fn(registry)))
end