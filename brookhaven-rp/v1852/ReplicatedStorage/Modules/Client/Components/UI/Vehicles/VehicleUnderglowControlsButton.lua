local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowControlsButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

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

		self.underglowControlsPanel = self.Instance.Panel.Value

		if not self.underglowControlsPanel then
			return
		end

		self.underglowControlsPanel:AddTag("Panel")
		local folder = VehicleController.GetCurrentDrivingVehicleModel()

		if not folder then
			return
		end

		local flag = false

		for _, descendant in folder:GetDescendants() do
			if not descendant:HasTag("VehicleBoost") then
				continue
			end

			flag = true
			break
		end

		if flag then
			self.Instance.Visible = true
		else
			self.Instance.Visible = false
		end
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		if not self.underglowControlsPanel then
			return
		end

		self.underglowControlsPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.vehiclePanel:SetCurrentOpenPanel(self.underglowControlsPanel)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v