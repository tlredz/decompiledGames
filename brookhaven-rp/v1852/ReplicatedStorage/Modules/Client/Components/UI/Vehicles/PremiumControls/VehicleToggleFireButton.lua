local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleToggleFireButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			self:AttemptToggleFire()
			return
		end

		if GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
			self:AttemptToggleFire()
			return
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_EFFECTS.id, Gamepasses.VEHICLE_CUSTOMIZATION) then
			self:AttemptToggleFire()
			return
		end

		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel then
			return
		end

		local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
		GamepassController.Show(
			Gamepasses.VEHICLE_CUSTOMIZATION,
			nil,
			"car effects",
			nil,
			AdFeatures.CAR_EFFECTS,
			nil,
			"Vehicle Controls",
			vehicleName,
			function()
				if VehicleController.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel then
					self:AttemptToggleFire()
				end
			end
		)
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleUIImprovementABTest.IsEnabled()) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("OnFire") == true then
			self.Instance:AddTag("Checked")
		else
			self.Instance:RemoveTag("Checked")
		end
	end))
end

function v:AttemptToggleFire()
	if VehicleController.ToggleOnFire() ~= true then
		return
	end

	VehicleUiInteractionTelemetryController.Fire("Customization", "Fire")

	if VehicleUIImprovementABTest.IsEnabled() then
		if self.Instance:HasTag("Checked") then
			self.Instance:RemoveTag("Checked")
		else
			self.Instance:AddTag("Checked")
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v