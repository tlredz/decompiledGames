local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "VehicleSuspensionLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("TextLabel") then
		warn("VehicleSuspensionLabel must be a TextLabel")
		return
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p2) then
			return
		end

		instance.Text = tostring(VehicleController.GetDefaultSuspensionLevel(currentDrivingVehicleModel))
	end))
	self._Janitor:Add(VehicleController.OnSuspensionHeightChanged:Connect(function(p2: string, value: number)
		if not (p2 == VehicleController.GetCurrentDrivingVehicleUuid() and typeof(value) == "number") then
			return
		end

		instance.Text = tostring(value)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v