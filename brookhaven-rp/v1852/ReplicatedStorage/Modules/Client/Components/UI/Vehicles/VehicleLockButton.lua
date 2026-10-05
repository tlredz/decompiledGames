local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleLockButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		VehicleController.ToggleLockState(self.vehicleUuid)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v