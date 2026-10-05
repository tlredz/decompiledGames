local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "VehicleTurboLabel"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTurbo(p: number)
	if p == 0 then
		return "Off"
	end

	return (tostring(p))
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("TextLabel") then
		warn("VehicleTurboLabel must be a TextLabel")
		return
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
		if p2 ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		instance.Text = formatTurbo(VehicleController.GetCurrentTurboLevel())
	end))
	self._Janitor:Add(VehicleController.OnTurboChanged:Connect(function(p2: string, value: number)
		if not (p2 == VehicleController.GetCurrentDrivingVehicleUuid() and typeof(value) == "number") then
			return
		end

		instance.Text = formatTurbo(value)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v