local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Stats = require(ReplicatedStorage.Modules.Stats)
local Network = require(ReplicatedStorage.Modules.Network)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local PlayerData = require(ReplicatedStorage.Modules.Neighbors.PlayerData)
require(ReplicatedStorage.Modules.Types)
local localPlayer = Players.LocalPlayer

local function applyCustomization(object)
	local owner = object:GetOwner()

	if owner then
		local playerData = PlayerData:GetPlayerData(owner)
		local prefabModel = object:GetPrefabModel()

		if playerData.CustomizationData then
			prefabModel.Customization:Apply(playerData.CustomizationData)
		end
	end
end

local function updateHouse(object)
	local owner = object:GetOwner()

	if owner then
		local playerData = PlayerData:GetPlayerData(owner)
		local prefabModel = object:GetPrefabModel()
		object:GetActiveSkin()

		if playerData.CustomizationData then
			prefabModel.Customization:Apply(playerData.CustomizationData)
		end
	end
end

House.EnteredHouse:Connect(updateHouse)
House.ActiveSkinChanged:Connect(function()
	local currentHouse = House:GetCurrentHouse()
	local owner = currentHouse and currentHouse:GetOwner()

	if owner then
		local playerData = PlayerData:GetPlayerData(owner)
		local prefabModel = currentHouse:GetPrefabModel()
		currentHouse:GetActiveSkin()

		if playerData.CustomizationData then
			prefabModel.Customization:Apply(playerData.CustomizationData)
		end
	end
end)
House.LeftHouse:Connect(function(object)
	object:GetPrefabModel().Customization:ResetToDefault()
end)
PlayerData.CustomizationChanged:Connect(function(p, p2)
	local houseFromPlayer = House:GetHouseFromPlayer(p)

	if houseFromPlayer and houseFromPlayer == House:GetCurrentHouse() and p ~= localPlayer then
		houseFromPlayer:GetPrefabModel().Customization:ApplyChanges(p2)
	end
end)
PlayerData.ActiveHouseSaveChanged:Connect(function(p)
	local houseFromPlayer = House:GetHouseFromPlayer(p)

	if houseFromPlayer and houseFromPlayer == House:GetCurrentHouse() and houseFromPlayer:GetOwner() == p then
		local playerData = PlayerData:GetPlayerData(p)
		local prefabModel = houseFromPlayer:GetPrefabModel()

		if playerData and playerData.CustomizationData and playerData.CustomizationData.Type == houseFromPlayer:GetActiveSkin() then
			prefabModel.Customization:Apply(playerData.CustomizationData)
		end
	end
end)
Network:listen("HouseCustomization/UpdateSave", function(p: string, p2)
	if not Stats.HouseCustomizationSaves[p] then
		Stats.HouseCustomizationSaves[p] = {}
	end

	Stats.HouseCustomizationSaves[p][p2.Id] = p2
end)
Network:listen("HouseCustomization/DeleteSave", function(p: string, p2: string)
	if Stats.HouseCustomizationSaves[p] then
		Stats.HouseCustomizationSaves[p][p2] = nil
	end
end)
Network:listen("HouseCustomization/InitializeSaves", function(items)
	for k, item in next, items, nil do
		if not Stats.HouseCustomizationSaves[k] then
			Stats.HouseCustomizationSaves[k] = {}
		end

		for _, v in next, item, nil do
			Stats.HouseCustomizationSaves[k][v.Id] = v
		end
	end
end)