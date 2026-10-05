local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeatureFlags = require(ReplicatedStorage.Modules.FeatureFlags)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local Queue = require(ReplicatedStorage.Modules.Queue)
Queue.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentGroup()
	local currentHouse = House:GetCurrentHouse()

	if currentHouse then
		return currentHouse.GroupNumber
	end

	return 1
end

local function updateHouse(object)
	if not FeatureFlags:IsEnabled("FFlagGroupHousesIntoChunks") then
		object:SetVisible(true)
		return
	end

	object:SetVisible(object.GroupNumber == getCurrentGroup())
end

local function registerHouse(object)
	if not FeatureFlags:IsEnabled("FFlagGroupHousesIntoChunks") then
		object:SetVisible(true)
		return
	end

	object:SetVisible(object.GroupNumber == getCurrentGroup())
end

local function updateNeighboringHouses()
	if FeatureFlags:IsEnabled("FFlagGroupHousesIntoChunks") then
		local currentGroup = getCurrentGroup() -- equivalent call inferred; original call site unknown

		for _, hous in next, House.Houses, nil do
			if hous.GroupNumber ~= currentGroup then
				hous:SetVisible(false)
			end
		end

		for _, hous in next, House.Houses, nil do
			if hous.GroupNumber == currentGroup then
				hous:SetVisible(true)
			end
		end
	else
		for _, hous in next, House.Houses, nil do
			if FeatureFlags:IsEnabled("FFlagGroupHousesIntoChunks") then
				hous:SetVisible(hous.GroupNumber == getCurrentGroup())
			else
				hous:SetVisible(true)
			end
		end
	end
end

House.ActiveHouseChanged:Connect(updateNeighboringHouses)
House.HouseAdded:Connect(registerHouse)
updateNeighboringHouses()