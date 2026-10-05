local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleSpeedIncreaseButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local instance = self.Instance

	if not (instance:IsA("TextButton") or instance:IsA("ImageButton")) then
		warn("VehicleSpeedIncreaseButton must be a TextButton or ImageButton")
		return
	end

	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	self._Janitor:Add(instance.Activated:Connect(function()
		local incrementValue = self.Instance:GetAttribute("IncrementValue")

		if not incrementValue then
			warn("IncrementValue attribute not found")
		elseif instance:GetAttribute("ShouldShowUpsell") then
			local currentNonMotorVehicle = VehicleController.GetCurrentNonMotorVehicle()
			local vehicleName = currentNonMotorVehicle:GetAttribute("vehicleName")
			GamepassController.Show(Gamepasses.VEHICLE_SPEED_UNLOCKED, nil, "no motor speed", function()
				PanelController.ToggleGroup("NoMotorVehicleControls", false)
			end, AdFeatures.VEHICLE_SPEED_MAX, nil, "NonMotored Vehicle Inventory", vehicleName, function()
				if VehicleController.GetCurrentNonMotorVehicle() == currentNonMotorVehicle then
					VehicleController.IncrementNoMotorVehicleSpeed(incrementValue)
					local component = ComponentUtil.FindComponentByAncestor(self.Instance, "Panel", Panel)

					if not component:IsOpen() then
						component:Open()
					end
				end
			end)
		else
			if VehicleController.IncrementNoMotorVehicleSpeed(incrementValue) then
				return
			end

			warn("Failed to increment no motor vehicle speed")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v