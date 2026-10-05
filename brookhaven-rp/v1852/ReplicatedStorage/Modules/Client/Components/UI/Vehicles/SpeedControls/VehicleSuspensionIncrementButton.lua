local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local v = Component.new({
	Tag = "VehicleSuspensionIncrementButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if instance:IsA("TextButton") or instance:IsA("ImageButton") then
		self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
			local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

			if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p2) then
				return
			end

			if currentDrivingVehicleModel:GetAttribute("HideSuspensionButton") then
				instance.Visible = false
			else
				instance.Visible = true
			end
		end))
		self._Janitor:Add(instance.Activated:Connect(function()
			local incrementValue = self.Instance:GetAttribute("IncrementValue")

			if typeof(incrementValue) ~= "number" then
				return
			end

			local defaultSuspensionLevel = VehicleController.GetDefaultSuspensionLevel()

			if VehicleController.AddSuspensionLevel(incrementValue) ~= true then
				return
			end

			VehicleUiInteractionTelemetryController.Fire(
				"Speed",
				"Suspension - " .. tostring(defaultSuspensionLevel + incrementValue)
			)
		end))
	else
		warn("VehicleSuspensionIncrementButton must be a TextButton or ImageButton")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v