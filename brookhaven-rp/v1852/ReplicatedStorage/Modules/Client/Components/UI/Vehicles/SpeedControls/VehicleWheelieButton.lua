local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleWheelieButton"
})
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)

function v:UpdateChecked(flag: boolean)
	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

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
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local instance = self.Instance
	instance.Visible = false
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("IsBike") then
			local chassis = currentDrivingVehicleModel:FindFirstChild("Chassis")

			if not chassis then
				warn("VehicleWheelieButton: vehicle has no chassis")
				return
			end

			local wheelie = chassis:FindFirstChild("Wheelie")

			if not wheelie then
				warn("VehicleWheelieButton: vehicle chassis has no Wheelie value")
				return
			end

			self.wheelieValue = wheelie
			instance.Visible = true
			self:UpdateChecked(wheelie.Value == true)
			self._Janitor:Add(wheelie.Changed:Connect(function(p2)
				self:UpdateChecked(p2 == true)
			end), "Disconnect", "Wheelie")
		else
			instance.Visible = false
			self.wheelieValue = nil
			self:UpdateChecked(false)
		end
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		instance.Visible = false
		self.wheelieValue = nil
		self:UpdateChecked(false)
	end))
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if self.wheelieValue == nil then
			return
		end

		self.wheelieValue.Value = not self.wheelieValue.Value
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v