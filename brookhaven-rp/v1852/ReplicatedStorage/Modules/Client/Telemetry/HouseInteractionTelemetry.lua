local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local HouseInteractionTelemetry = require(ReplicatedStorage.Modules.Shared.Housing.HouseInteractionTelemetry)
return {
	Fire = function(p, p2)
		local payload = HouseInteractionTelemetry.BuildPayload(p, p2)

		if payload == nil then
			return
		end

		TelemetryController.SendClientInteraction("houseInteraction", payload)
	end
}