local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local HousePropSavesConstants = {
	FREE_SLOTS = 3,
	DEFAULT_NAME = "My House",
	SLOT_PREFIX = "h"
}

function HousePropSavesConstants.GetMaxSlots()
	return HousePropSavesConstants.FREE_SLOTS + #DevProducts.HOUSE_SAVE_SLOTS
end

function HousePropSavesConstants.GetSlotName(p: number)
	return HousePropSavesConstants.SLOT_PREFIX .. tostring(p)
end

function HousePropSavesConstants.GetAllSlotNames()
	local result = {}

	for i = 1, HousePropSavesConstants.GetMaxSlots() do
		table.insert(result, HousePropSavesConstants.GetSlotName(i))
	end

	return result
end

function HousePropSavesConstants.IsValidSlotName(p: string)
	for i = 1, HousePropSavesConstants.GetMaxSlots() do
		if p == HousePropSavesConstants.GetSlotName(i) then
			return true
		end
	end

	return false
end

return HousePropSavesConstants