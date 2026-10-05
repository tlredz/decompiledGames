local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local v = Component.new({
	Tag = "VehicleDriftIncreaseButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if instance:IsA("TextButton") or instance:IsA("ImageButton") then
		local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
		self._Janitor:Add(instance.Activated:Connect(function()
			local incrementValue = self.Instance:GetAttribute("IncrementValue")

			if not incrementValue then
				return
			end

			local v2, _ = VehicleController.AddDriftStrength(incrementValue)

			if not v2 then
				return
			end

			local v3 = incrementValue > 0 and "Increase Drift" or "Decrease Drift"
			VehicleUiInteractionTelemetryController.Fire("Speed", v3)
		end))
	else
		warn("VehicleDriftIncreaseButton must be a TextButton or ImageButton")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v