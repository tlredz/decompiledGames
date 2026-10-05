local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSpeedCheckMark"
})
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if VehicleUIImprovementABTest.IsEnabled() then
		self.Instance.Visible = false
		return
	end

	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	self._Janitor:Add(VehicleController.OnMaxSpeedChanged:Connect(function(p2: string)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		self.Instance.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v