local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowPropertyLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local property = self.Instance:GetAttribute("Property")
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			warn("Vehicle not found")
			return
		end

		local underglowHolder

		if currentDrivingVehicleModel:GetAttribute("NoMotorVehicle") then
			underglowHolder = currentDrivingVehicleModel:WaitForChild("UnderglowHolder")
		else
			local body = currentDrivingVehicleModel:FindFirstChild("Body")

			if not body then
				warn("Body not found")
				return
			end

			underglowHolder = body:FindFirstChild("VehicleCollide")

			if not underglowHolder then
				warn("Vehicle collide not found")
				return
			end
		end

		if not underglowHolder then
			warn("Vehicle collide not found")
			return
		end

		local child = underglowHolder:WaitForChild(property, 10)

		if not child then
			warn("Property not found")
			return
		end

		self.Instance.Text = child.Value
		self._Janitor:Add(child.Changed:Connect(function()
			self.Instance.Text = child.Value
		end))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v