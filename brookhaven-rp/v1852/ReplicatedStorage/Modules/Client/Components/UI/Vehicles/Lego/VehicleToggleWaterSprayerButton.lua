local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FireTruckAirportLego = require(ReplicatedStorage.Modules.Client.Components.Vehicles.SpecificVehicles.FireTruckAirportLego)
local Lego_FireBoat = require(ReplicatedStorage.Modules.Client.Components.Vehicles.SpecificVehicles.Lego_FireBoat)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "VehicleToggleWaterSprayerButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			return
		end

		local v2 = FireTruckAirportLego:FromInstance(currentDrivingVehicleModel) or Lego_FireBoat:FromInstance(currentDrivingVehicleModel)

		if v2 then
			v2:ToggleWaterSprayer()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v