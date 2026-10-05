local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "NoMotorVehicleToggleVisible"
})
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)

function v:SetupVisibility()
	local textLabel = self.Instance.TextLabel
	local decreaseSpeed = self.Instance.DecreaseSpeed
	local increaseSpeed = self.Instance.IncreaseSpeed
	local increaseSpeedInitial = self.Instance.IncreaseSpeedInitial
	local speedTextBox = self.Instance.SpeedTextBox

	if UnlockableController.IsFeatureUnlocked(AdFeatures.VEHICLE_SPEED_MAX.id, Gamepasses.VEHICLE_SPEED_UNLOCKED) then
		textLabel.Text = "Max Speed 50"
		decreaseSpeed.Visible = true
		increaseSpeed.Visible = true
		speedTextBox.Visible = true
		increaseSpeedInitial.Visible = false
	elseif UnlockableController.IsFeatureUnlocked(AdFeatures.VEHICLE_SPEED_UPGRADE.id, Gamepasses.VEHICLE_UPGRADE) or GamepassController.IsOwnedLegacy(Gamepasses.PREMIUM) then
		textLabel.Text = "Max Speed 40"
		decreaseSpeed.Visible = true
		increaseSpeed.Visible = true
		speedTextBox.Visible = true
		increaseSpeedInitial.Visible = false
	else
		textLabel.Text = "Max Speed 25"
		decreaseSpeed.Visible = false
		increaseSpeed.Visible = false
		speedTextBox.Visible = false
		increaseSpeedInitial.Visible = true
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(_)
		self:SetupVisibility()
	end))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(function(_)
		self:SetupVisibility()
	end))
	self:SetupVisibility()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v