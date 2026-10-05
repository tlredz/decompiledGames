local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "VehicleTurboIncrementButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._level = 0
end

function v:Start()
	local instance = self.Instance

	if not (instance:IsA("TextButton") or instance:IsA("ImageButton")) then
		warn("VehicleTurboIncrementButton must be a TextButton or ImageButton")
		return
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		if p ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		self._level = VehicleController.GetCurrentTurboLevel()
	end))
	self._Janitor:Add(VehicleController.OnTurboChanged:Connect(function(p: string, level: number)
		if p ~= VehicleController.GetCurrentDrivingVehicleUuid() then
			return
		end

		if typeof(level) == "number" then
			self._level = level
		end
	end))
	self._Janitor:Add(instance.Activated:Connect(function()
		local incrementValue = self.Instance:GetAttribute("IncrementValue")

		if typeof(incrementValue) ~= "number" then
			return
		end

		local level = math.clamp(self._level + incrementValue, 0, 3)

		if level == self._level then
			return
		end

		if VehicleController.SetTurbo(level) == true then
			self._level = level

			if level >= 1 then
				VehicleUiInteractionTelemetryController.Fire("Speed", "Turbo - " .. tostring(level))
			end
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v