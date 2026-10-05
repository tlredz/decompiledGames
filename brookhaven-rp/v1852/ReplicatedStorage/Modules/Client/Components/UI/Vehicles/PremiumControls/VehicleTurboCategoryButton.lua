local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleTurboCategoryButton"
})
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)

local function isTurboUnlocked()
	return UnlockableController.IsFeatureUnlocked(AdFeatures.VEHICLE_SPEED_MAX.id, Gamepasses.VEHICLE_SPEED_UNLOCKED)
end

function v:UpdateChecked()
	if self.menu == nil or not self.menu.Visible then
		self.Instance:RemoveTag("Checked")
	else
		self.Instance:AddTag("Checked")
	end
end

function v:UpdateGamepassIcon()
	self.Instance.GamepassIcon.Visible = not UnlockableController.IsFeatureUnlocked(
		AdFeatures.VEHICLE_SPEED_MAX.id,
		Gamepasses.VEHICLE_SPEED_UNLOCKED
	)
end

function v:HideSiblingMenus()
	local parent = self.menu.Parent

	if not parent then
		return
	end

	for _, guiObject in parent:GetChildren() do
		if not guiObject:IsA("GuiObject") or guiObject == self.menu or guiObject == self.Instance or self.Instance:IsDescendantOf(guiObject) then
			continue
		end

		guiObject.Visible = false
	end
end

function v:PromptTurboGamepass()
	local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

	if not currentDrivingVehicleModel then
		return
	end

	local vehicleName = currentDrivingVehicleModel:GetAttribute("vehicleName")
	GamepassController.Show(
		Gamepasses.VEHICLE_SPEED_UNLOCKED,
		nil,
		"turbo",
		nil,
		AdFeatures.VEHICLE_SPEED_MAX,
		nil,
		"Vehicle Controls",
		vehicleName,
		function()
			self:HideSiblingMenus()
			self.menu.Visible = true
		end
	)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.menu = self.Instance.Panel.Value

	if not self.menu then
		return
	end

	self:UpdateChecked()
	self._Janitor:Add(self.menu:GetPropertyChangedSignal("Visible"):Connect(function()
		self:UpdateChecked()
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function(p)
		local currentDrivingVehicleModel = VehicleController.GetCurrentDrivingVehicleModel()

		if not (currentDrivingVehicleModel and VehicleController.GetVehicleUuidFromInstance(currentDrivingVehicleModel) == p) then
			return
		end

		self.menu.Visible = false
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if not self.menu then
			return
		end

		if not UnlockableController.IsFeatureUnlocked(
			AdFeatures.VEHICLE_SPEED_MAX.id,
			Gamepasses.VEHICLE_SPEED_UNLOCKED
		) then
			self:PromptTurboGamepass()
			return
		end

		if self.menu.Visible then
			self.menu.Visible = false
			return
		end

		self:HideSiblingMenus()
		self.menu.Visible = true
	end))
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
		if p == AdFeatures.VEHICLE_SPEED_MAX.id then
			self:UpdateGamepassIcon()
		end
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(p)
		if Gamepasses.GetById(p) == Gamepasses.VEHICLE_SPEED_UNLOCKED then
			self:UpdateGamepassIcon()
		end
	end))
	GamepassController.WaitForGamepasses()

	if not Janitor.Is(self._Janitor) then
		return
	end

	self:UpdateGamepassIcon()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v