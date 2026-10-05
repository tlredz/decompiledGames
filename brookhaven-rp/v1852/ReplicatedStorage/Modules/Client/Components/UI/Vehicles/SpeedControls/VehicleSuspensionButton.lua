local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSuspensionButton"
})
require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.VehiclePanel)
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not (instance:IsA("TextButton") or instance:IsA("ImageButton")) then
		warn("VehicleSpeedIncreaseButton must be a TextButton or ImageButton")
		return
	end

	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p2) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("HideSuspensionButton") == true or currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			instance.Visible = false
		else
			instance.Visible = true
		end
	end))
	self._Janitor:Add(instance.Activated:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			NotificationController.Notify("This vehicle doesn't have wheels!")
			return
		end

		local defaultSuspensionLevel = VehicleController.GetDefaultSuspensionLevel()

		if VehicleController.SetNextSuspensionHeight() ~= true then
			return
		end

		local suspensionLevelCount = VehicleController.GetSuspensionLevelCount()
		local v2 = defaultSuspensionLevel + 1
		local v3 = suspensionLevelCount < v2 and 1 or v2
		VehicleUiInteractionTelemetryController.Fire("Speed", "Suspension - " .. tostring(v3))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v