local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleWheelDecalButton"
})
local VehiclePanel = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.VehiclePanel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleWheelDecalUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleWheelDecalUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)

local function isCustomizationUnlocked()
	if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
		return true
	end

	return UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_EFFECTS.id, Gamepasses.VEHICLE_CUSTOMIZATION)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)

	if not ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "VehiclePanel", VehiclePanel) then
		warn("VehicleWheelDecalButton must be a descendant of VehiclePanel")
		return
	end

	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p2)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p2) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("HideWheelDecalButton") == true or currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			self.Instance.Visible = false
		else
			self.Instance.Visible = true
		end
	end))
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			NotificationController.Notify("This vehicle doesn't have wheels!")
			return
		end

		local v2 = currentDrivingVehicleModel == nil and "" or currentDrivingVehicleModel:GetAttribute("WheelDecal") or ""
		local nextDecal = VehicleWheelDecalUtil.GetNextDecal(v2, isCustomizationUnlocked())

		if VehicleController.SetWheelDecal(nextDecal) ~= true then
			return
		end

		VehicleUiInteractionTelemetryController.Fire("Speed", "Tire Decal - " .. nextDecal)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v