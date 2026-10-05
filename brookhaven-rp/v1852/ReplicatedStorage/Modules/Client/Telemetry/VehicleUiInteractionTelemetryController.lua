local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

-- equivalent calls inferred from this helper; original call sites unknown
local function getVehicleType(instance)
	if instance:GetAttribute("IsBike") == true then
		return "bike"
	end

	if instance:GetAttribute("IsBoat") == true then
		return "boat"
	end

	return "motor"
end

return {
	Fire = function(menu: string, action: string)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel == nil then
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")

		if typeof(vehicleName) ~= "string" or vehicleName == "" then
			return
		end

		TelemetryController.SendClientInteraction("vehicleUIInteraction", {
			menu = menu,
			vehicleName = vehicleName,
			vehicleType = getVehicleType(currentDrivingVehicleModel),
			action = action
		})
	end
}