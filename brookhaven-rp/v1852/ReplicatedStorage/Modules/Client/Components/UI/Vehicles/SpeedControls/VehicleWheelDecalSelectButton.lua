local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleWheelDecalSelectButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local VehicleWheelDecalUtil = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleWheelDecalUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local GamepassIcon = require(ReplicatedStorage.Modules.Client.Item.GamepassIcon)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local VehicleUiInteractionTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.VehicleUiInteractionTelemetryController)

local function isCustomizationUnlocked()
	if GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
		return true
	end

	return UnlockableController.IsFeatureUnlocked(AdFeatures.CAR_EFFECTS.id, Gamepasses.VEHICLE_CUSTOMIZATION)
end

function v:UpdateChecked(p2: string?)
	if p2 == self.decalId then
		self.Instance:AddTag("Checked")
	else
		self.Instance:RemoveTag("Checked")
	end
end

function v:UpdateCornerIcon()
	local cornerIcon = self.Instance.CornerIcon

	if self.entry.Gamepass == nil then
		cornerIcon.Visible = false
		return
	end

	local smallIcon = GamepassIcon.GetSmallIcon(self.entry.Gamepass)

	if smallIcon == nil then
		cornerIcon.Visible = false
		return
	end

	cornerIcon.Image = smallIcon
	cornerIcon.Visible = true
end

function v:AttemptSelect()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
		NotificationController.Notify("This vehicle doesn't have wheels!")
		return
	end

	if VehicleController.SetWheelDecal(self.decalId) ~= true then
		return
	end

	VehicleUiInteractionTelemetryController.Fire("Speed", "Tire Decal - " .. self.decalId)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.decalId = self.Instance.WheelImage.Image
	self.entry = VehicleWheelDecalUtil.GetEntry(self.decalId)

	if self.entry == nil then
		return
	end

	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("IsBoat") == true then
			NotificationController.Notify("This vehicle doesn't have wheels!")
			return
		end

		if currentDrivingVehicleModel and currentDrivingVehicleModel:GetAttribute("WheelDecal") == self.decalId then
			self:AttemptSelect()
			return
		end

		if self.entry.Gamepass == nil or GamepassController.IsOwned(Gamepasses.VEHICLE_CUSTOMIZATION) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) or UnlockableController.IsFeatureUnlocked(
			AdFeatures.CAR_EFFECTS.id,
			Gamepasses.VEHICLE_CUSTOMIZATION
		) then
			self:AttemptSelect()
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
				if VehicleController.GetCurrentDrivingVehicleModel() == currentDrivingVehicleModel then
					self:AttemptSelect()
				end
			end
		)
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self:UpdateChecked(currentDrivingVehicleModel:GetAttribute("WheelDecal"))
		self:UpdateCornerIcon()
		self._Janitor:Add(currentDrivingVehicleModel:GetAttributeChangedSignal("WheelDecal"):Connect(function()
			self:UpdateChecked(currentDrivingVehicleModel:GetAttribute("WheelDecal"))
		end), "Disconnect", "WheelDecal")
	end))
	self:UpdateCornerIcon()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v