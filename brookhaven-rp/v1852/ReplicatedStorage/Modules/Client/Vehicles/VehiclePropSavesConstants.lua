local VehiclePropSavesConstants = {
	FREE_SLOTS = 3,
	MAX_SLOTS = 10,
	DEFAULT_NAME = "My Car",
	SLOT_PREFIX = "v",
	RENAME_MAX_LENGTH = 20,
	TOO_MANY_PROPS = "TooManyProps",
	EXCEEDS_SERVER_LIMIT = "ExceedsServerLimit"
}

function VehiclePropSavesConstants.GetUnlockedSlotCount(p: number)
	return (math.clamp(
		VehiclePropSavesConstants.FREE_SLOTS + p,
		VehiclePropSavesConstants.FREE_SLOTS,
		VehiclePropSavesConstants.MAX_SLOTS
	))
end

function VehiclePropSavesConstants.GetSlotName(p: number)
	return VehiclePropSavesConstants.SLOT_PREFIX .. tostring(p)
end

function VehiclePropSavesConstants.GetAllSlotNames()
	local result = {}

	for i = 1, VehiclePropSavesConstants.MAX_SLOTS do
		table.insert(result, VehiclePropSavesConstants.GetSlotName(i))
	end

	return result
end

function VehiclePropSavesConstants.IsValidSlotName(p: string)
	for i = 1, VehiclePropSavesConstants.MAX_SLOTS do
		if p == VehiclePropSavesConstants.GetSlotName(i) then
			return true
		end
	end

	return false
end

function VehiclePropSavesConstants.IsSlotUnlocked(p: string, p2: number)
	for i = 1, VehiclePropSavesConstants.GetUnlockedSlotCount(p2) do
		if p == VehiclePropSavesConstants.GetSlotName(i) then
			return true
		end
	end

	return false
end

function VehiclePropSavesConstants.NextDefaultName(items)
	local v = {}

	for _, item in items do
		v[item] = true
	end

	if v[VehiclePropSavesConstants.DEFAULT_NAME] ~= true then
		return VehiclePropSavesConstants.DEFAULT_NAME
	end

	local v2 = 2

	while v[VehiclePropSavesConstants.DEFAULT_NAME .. " " .. tostring(v2)] == true do
		v2 += 1
	end

	return VehiclePropSavesConstants.DEFAULT_NAME .. " " .. tostring(v2)
end

return VehiclePropSavesConstants