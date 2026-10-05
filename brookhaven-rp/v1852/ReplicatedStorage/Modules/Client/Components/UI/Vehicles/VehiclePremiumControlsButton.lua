local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehiclePremiumControlsButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

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

		self.premiumControlsPanel = self.Instance.Panel.Value

		if not self.premiumControlsPanel then
			return
		end

		local bikeFrameWheels = self.premiumControlsPanel:FindFirstChild("BikeFrameWheels", true)

		if bikeFrameWheels ~= nil and bikeFrameWheels:IsA("GuiObject") then
			local isBike = currentDrivingVehicleModel:GetAttribute("IsBike") == true
			bikeFrameWheels.Visible = isBike
			local frameWheels = self.premiumControlsPanel:FindFirstChild("FrameWheels", true)

			if frameWheels ~= nil and frameWheels:IsA("GuiObject") then
				frameWheels.Visible = isBike ~= true
			end
		end

		self.premiumControlsPanel:AddTag("Panel")
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		if not self.premiumControlsPanel then
			return
		end

		self.premiumControlsPanel:RemoveTag("Panel")
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.vehiclePanel:SetCurrentOpenPanel(self.premiumControlsPanel)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v