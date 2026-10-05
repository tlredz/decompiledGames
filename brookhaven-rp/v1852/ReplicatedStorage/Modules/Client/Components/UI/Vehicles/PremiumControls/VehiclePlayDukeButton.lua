local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehiclePlayDukeButton"
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
			self:AttemptSelect()
			return
		end

		if GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
			self:AttemptSelect()
			return
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_EFFECTS.id, Gamepasses.VEHICLE_CUSTOMIZATION) then
			self:AttemptSelect()
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
					self:AttemptSelect()
				end
			end
		)
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleUIImprovementABTest.IsEnabled()) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("EquippedHorn") == self.Instance.Name then
			self.Instance:AddTag("Checked")
		else
			self.Instance:RemoveTag("Checked")
		end
	end))
end

function v:AttemptSelect()
	local v2, v3 = VehicleController.PlayDukeSound(self.Instance.Name)

	if v2 ~= true then
		return
	end

	local v4 = ({
		Duke1 = "Clown horn",
		Duke2 = "Emergency horn"
	})[self.Instance.Name]

	if v4 ~= nil then
		VehicleUiInteractionTelemetryController.Fire("Customization", v4)
	end

	if not VehicleUIImprovementABTest.IsEnabled() then
		return
	end

	for _, child in self.Instance.Parent:GetChildren() do
		if not child:HasTag("VehiclePlayDukeButton") then
			continue
		end

		if v3 == child.Name then
			child:AddTag("Checked")
		else
			child:RemoveTag("Checked")
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v