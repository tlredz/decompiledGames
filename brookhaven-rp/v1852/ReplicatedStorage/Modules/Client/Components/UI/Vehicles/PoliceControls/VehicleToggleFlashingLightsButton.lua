local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleToggleFlashingLightsButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)

function v:UpdateVisual(flag: boolean)
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	self.Instance.Icon.Image = flag and "rbxassetid://75945523022168" or "rbxassetid://75613838242345"

	if flag == true then
		self.Instance:AddTag("Checked")
	else
		self.Instance:RemoveTag("Checked")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p and VehicleUIImprovementABTest.IsEnabled()) then
			return
		end

		self:UpdateVisual(currentDrivingVehicleModel:GetAttribute("EmergencyLights") == true)
		self._Janitor:Add(currentDrivingVehicleModel:GetAttributeChangedSignal("EmergencyLights"):Connect(function()
			self:UpdateVisual(currentDrivingVehicleModel:GetAttribute("EmergencyLights") == true)
		end), "Disconnect", "EmergencyLights")
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		if VehicleUIImprovementABTest.IsEnabled() then
			self.Instance:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if VehicleController.ToggleEmergencyLights() == true then
			VehicleUiInteractionTelemetryController.Fire("Siren", "Flashing Lights")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v