local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleSpeedIncreaseUpsellButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()
		local vehicleName = currentNonMotorVehicle:GetAttribute("vehicleName")

		local function fn()
			PanelController.ToggleGroup("NoMotorVehicleControls", false)
		end

		local function reopen()
			if VehicleController.GetCurrentNonMotorVehicle() == currentNonMotorVehicle then
				VehicleController.IncrementNoMotorVehicleSpeed(self.Instance:GetAttribute("IncrementValue"))
				local component = ComponentUtil.FindComponentByAncestor(self.Instance, "Panel", Panel)

				if not component:IsOpen() then
					component:Open()
				end
			end
		end

		if PlayerFlag.IsEnabled("vehicle-upgrade-removed") then
			GamepassController.Show(
				Gamepasses.VEHICLE_SPEED_UNLOCKED,
				nil,
				"no motor speed",
				fn,
				AdFeatures.VEHICLE_SPEED_MAX,
				nil,
				"NonMotored Vehicle Control",
				vehicleName,
				reopen
			)
		else
			GamepassController.Show(
				Gamepasses.VEHICLE_UPGRADE,
				"rbxassetid://5112217484",
				"no motor speed",
				fn,
				AdFeatures.VEHICLE_SPEED_UPGRADE,
				nil,
				"NonMotored Vehicle Control",
				vehicleName,
				reopen
			)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v