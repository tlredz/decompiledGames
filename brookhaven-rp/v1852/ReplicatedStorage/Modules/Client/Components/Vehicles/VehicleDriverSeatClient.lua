local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleDriverSeatClient"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p2: string, p3: number)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		local maxSpeed = self.Instance:FindFirstChild("MaxSpeed")

		if maxSpeed then
			maxSpeed.Value = p3
		else
			warn("MaxSpeed instance not found")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v