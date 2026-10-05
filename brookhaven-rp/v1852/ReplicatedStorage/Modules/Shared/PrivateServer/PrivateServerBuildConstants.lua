local PrivateServerBuildConstants = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
PrivateServerBuildConstants.FREE_SLOTS = 3
local PLUS_ONE_PS_PROPS_SLOT = CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT

function PrivateServerBuildConstants.GetMaxPurchasableSlots()
	return CountableDevProducts.GetMax(PLUS_ONE_PS_PROPS_SLOT)
end

function PrivateServerBuildConstants.GetMaxSlotIndex()
	return PrivateServerBuildConstants.FREE_SLOTS + PrivateServerBuildConstants.GetMaxPurchasableSlots()
end

function PrivateServerBuildConstants.GetAdminOverrideMaxSlotIndex()
	return PrivateServerBuildConstants.FREE_SLOTS + CountableDevProducts.GetAdminOverrideMax(PLUS_ONE_PS_PROPS_SLOT)
end

function PrivateServerBuildConstants.GetSlotName(p: number)
	return "b" .. tostring(p)
end

function PrivateServerBuildConstants.GetSlotIndex(value: string)
	if string.sub(value, 1, 1) ~= "b" then
		return nil
	end

	local v = string.sub(value, 2)

	if v == "" or string.match(v, "^%d+$") == nil then
		return nil
	end

	local v2 = tonumber(v)

	if v2 == nil or v2 < 1 or PrivateServerBuildConstants.GetAdminOverrideMaxSlotIndex() < v2 then
		return nil
	end

	if PrivateServerBuildConstants.GetSlotName(v2) == value then
		return v2
	end

	return nil
end

function PrivateServerBuildConstants.IsValidSlotName(p: string)
	return PrivateServerBuildConstants.GetSlotIndex(p) ~= nil
end

function PrivateServerBuildConstants.GetUnlockedSlotCount(p: number)
	return PrivateServerBuildConstants.FREE_SLOTS + math.max(0, (math.floor(p)))
end

function PrivateServerBuildConstants.IsSlotUnlocked(p: string, p2: number)
	local slotIndex = PrivateServerBuildConstants.GetSlotIndex(p)
	return slotIndex ~= nil and slotIndex <= PrivateServerBuildConstants.GetUnlockedSlotCount(p2)
end

function PrivateServerBuildConstants.GetAllSlotNames()
	local result = {}

	for i = 1, PrivateServerBuildConstants.GetMaxSlotIndex() do
		table.insert(result, PrivateServerBuildConstants.GetSlotName(i))
	end

	return result
end

function PrivateServerBuildConstants.GetUnlockedSlotNames(p: number)
	local result = {}

	for i = 1, PrivateServerBuildConstants.GetUnlockedSlotCount(p) do
		table.insert(result, PrivateServerBuildConstants.GetSlotName(i))
	end

	return result
end

return PrivateServerBuildConstants