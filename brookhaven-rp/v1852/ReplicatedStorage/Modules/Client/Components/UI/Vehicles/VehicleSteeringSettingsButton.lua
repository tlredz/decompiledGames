local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSteeringSettingsButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)

function v:UpdateChecked()
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	if self.steeringSettingsPanel == nil or not self.steeringSettingsPanel.Visible then
		self.Instance:RemoveTag("Checked")
	else
		self.Instance:AddTag("Checked")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.vehiclePanel = VehicleController.GetVehiclePanel()

		if not self.vehiclePanel then
			return
		end

		self.steeringSettingsPanel = self.Instance.Panel.Value

		if not self.steeringSettingsPanel then
			return
		end

		self.steeringSettingsPanel:AddTag("Panel")
		self:UpdateChecked()
		self._Janitor:Add(self.steeringSettingsPanel:GetPropertyChangedSignal("Visible"):Connect(function()
			self:UpdateChecked()
		end), "Disconnect", "SteeringSettingsVisible")
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		self.Instance:RemoveTag("Checked")

		if not self.steeringSettingsPanel then
			return
		end

		self.steeringSettingsPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.vehiclePanel:SetCurrentOpenPanel(self.steeringSettingsPanel)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v