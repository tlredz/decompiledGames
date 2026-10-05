local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleColorPicker"
})
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local playersCar = nil
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

local function canUseVehicleColor()
	if UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_COLOUR.id) or GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
		return true
	end

	return GamepassController.IsOwnedLegacy(Gamepasses.VEHICLE_UPGRADE) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM)
end

function v:Construct()
	self._Janitor = Janitor.new()
	local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
	local module = require(game8Settings)
	playersCar = module.PlayersCar
end

function v:Start()
	local component = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	self._Janitor:Add(component.OnColorConfirmed:Connect(function(p2)
		if not PlayerFlag.IsEnabled("small-vehicle-customization-upsell") or UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_COLOUR.id) or GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.VEHICLE_UPGRADE) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
			playersCar:FireServer("NoMotorColor", p2)
			return
		end

		local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()

		if currentNonMotorVehicle == nil then
			return
		end

		local vehicleName = currentNonMotorVehicle:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			"5122248968",
			"car colour",
			nil,
			AdFeatures.CAR_COLOUR,
			nil,
			"NonMotored Vehicle Control",
			vehicleName,
			function()
				if VehicleController.GetCurrentNonMotorVehicle() == currentNonMotorVehicle then
					playersCar:FireServer("NoMotorColor", p2)
				end
			end
		)
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()
		local defaultColor = currentNonMotorVehicle and currentNonMotorVehicle:GetAttribute("DefaultColor")

		if defaultColor then
			component.Instance:SetAttribute("DefaultColor", defaultColor)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v