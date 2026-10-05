local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSirensPanelOpenButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)

function v:UpdateChecked()
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	if self.sirensLightsPanel == nil or not self.sirensLightsPanel.Visible then
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

		self.sirensLightsPanel = self.Instance.Panel.Value

		if not self.sirensLightsPanel then
			return
		end

		self.sirensLightsPanel:AddTag("Panel")
		self:UpdateChecked()
		self._Janitor:Add(self.sirensLightsPanel:GetPropertyChangedSignal("Visible"):Connect(function()
			self:UpdateChecked()
		end), "Disconnect", "SirensLightsVisible")
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		if VehicleUIImprovementABTest.IsEnabled() then
			self.Instance:RemoveTag("Checked")
		end

		if not self.sirensLightsPanel then
			return
		end

		self.sirensLightsPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if self.vehiclePanel and self.sirensLightsPanel then
			self.vehiclePanel:SetCurrentOpenPanel(self.sirensLightsPanel)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v