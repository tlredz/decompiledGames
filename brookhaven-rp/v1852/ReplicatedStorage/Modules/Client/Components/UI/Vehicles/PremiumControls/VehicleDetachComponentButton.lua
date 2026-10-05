local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)
local v = Component.new({
	Tag = "VehicleDetachComponentButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)

function v:DetachComponent()
	if not VehicleUIImprovementABTest.IsEnabled() and self.hasBeenDetached == true then
		return
	end

	local v2, v3 = VehicleController.DetachComponent(self.Instance.Name)

	if v2 ~= true then
		return
	end

	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()
	local v4

	if currentDrivingVehicleModel == nil then
		v4 = false
	else
		v4 = currentDrivingVehicleModel:GetAttribute("IsBike") == true
	end

	local v5 = ({
		WheelFR = v4 and "Front" or "Front Right",
		WheelFL = v4 and "Front" or "Front Left",
		WheelBR = v4 and "Back" or "Back Right",
		WheelBL = v4 and "Back" or "Back Left"
	})[self.Instance.Name]

	if v5 ~= nil then
		local v6 = v3 == true and "Remove Tire - " or "Reattach Tire - "
		VehicleUiInteractionTelemetryController.Fire("Customization", v6 .. v5)
	end

	if not VehicleUIImprovementABTest.IsEnabled() then
		self.hasBeenDetached = true
	elseif v3 == true then
		self.Instance:AddTag("Crossed")
	else
		self.Instance:RemoveTag("Crossed")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
	local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
	self.hasBeenDetached = false
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		if currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			self.Instance.Visible = false
			return
		end

		self.Instance.Visible = true

		if not VehicleUIImprovementABTest.IsEnabled() then
			return
		end

		if ("," .. (currentDrivingVehicleModel:GetAttribute("DetachedWheels") or "") .. ","):find(
			"," .. self.Instance.Name .. ",",
			1,
			true
		) then
			self.Instance:AddTag("Crossed")
		else
			self.Instance:RemoveTag("Crossed")
		end
	end))
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			NotificationController.Notify("This vehicle doesn't have wheels!")
			return
		end

		if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) then
			self:DetachComponent()
			return
		end

		if GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
			self:DetachComponent()
			return
		end

		if UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_EFFECTS.id, Gamepasses.VEHICLE_CUSTOMIZATION) then
			self:DetachComponent()
			return
		end

		local currentDrivingVehicleModel2 = VehicleController.GetCurrentDrivingVehicleModel()

		if not currentDrivingVehicleModel2 then
			return
		end

		local vehicleName = currentDrivingVehicleModel2:GetAttribute("vehicleName")
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
				if VehicleController.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel2 then
					self:DetachComponent()
				end
			end
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v