local HouseUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)
local v = {
	Landmark = {
		numbers = { 38 }
	},
	Mansion = {
		numbers = { 33, 34, 37 }
	},
	House = {
		min = 11,
		max = 32
	},
	Motel = {
		max = 5
	},
	Apartment = {
		numbers = { 6, 7 }
	}
}

function HouseUtil.GetHouseType(p: number)
	if table.find(v.Landmark.numbers, p) then
		return "Landmark"
	end

	if table.find(v.Mansion.numbers, p) then
		return "Mansion"
	end

	if table.find(v.Apartment.numbers, p) then
		return "Apartment"
	end

	if p <= v.Motel.max then
		return "Motel"
	end

	if v.House.min <= p then
		return "House"
	end

	return nil
end

function HouseUtil.GetHouseControlPanel(_: string)
	return "HouseControlPanel"
end

function HouseUtil.GetHouseMenu(p: string)
	return ({
		Mansion = "MainHouseMenu",
		House = "MainHouseMenu",
		Motel = "MainHouseMenu",
		Apartment = "MainHouseMenu",
		Landmark = "MainHouseMenu"
	})[p]
end

return HouseUtil