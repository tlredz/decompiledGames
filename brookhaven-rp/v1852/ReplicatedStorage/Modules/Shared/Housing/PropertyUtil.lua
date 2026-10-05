local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PropertyConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.PropertyConfig)
local LotConfig = require(ReplicatedStorage.Modules.Shared.DB.Housing.LotConfig)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local PropertyUtil = {}

function PropertyUtil.GetConfig(p: string)
	local config = PropertyConfig.GetConfig()

	if GameUtil.isHouseTestingPlace() then
		return {
			Type = "House"
		}
	end

	if config == nil or config[p] == nil then
		return nil
	end

	return config[p]
end

function PropertyUtil.IsCompatibleWithLot(p: string, p2: number)
	if PropertyConfig.isLoaded ~= true or LotConfig.isLoaded ~= true then
		return false
	end

	local v = PropertyConfig.cache[p]

	if v == nil then
		return false
	end

	local v2 = LotConfig.cache["Lot_" .. p2]

	if v2 == nil or v2.PlaceableType ~= v.Type then
		return false
	end

	return v.LotIdRestrictions == nil or table.find(v.LotIdRestrictions, p2) ~= nil
end

function PropertyUtil.GetCompatibleIdsForLot(p: number)
	if PropertyConfig.isLoaded ~= true or LotConfig.isLoaded ~= true then
		return {}
	end

	local v = LotConfig.cache["Lot_" .. p]

	if v == nil then
		return {}
	end

	local result = {}

	for k, v2 in PropertyConfig.cache do
		if not (v2.Type == v.PlaceableType and (v2.LotIdRestrictions == nil or table.find(v2.LotIdRestrictions, p) ~= nil)) then
			continue
		end

		table.insert(result, k)
	end

	table.sort(result)
	return result
end

return PropertyUtil