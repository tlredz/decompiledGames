local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local Spring = require(ReplicatedStorage.Modules.Spring)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Crosshair = require(Players.LocalPlayer.PlayerScripts.Modules.Crosshair)
local MouseCrosshair = {}
MouseCrosshair.__index = MouseCrosshair

function MouseCrosshair.new(mouse)
	local self = setmetatable({}, MouseCrosshair)
	self.Mouse = mouse
	self.Crosshair = Crosshair.new()
	self._crouch_spring = Spring.new(0, 0.875, 20)
	self._speed_spring = Spring.new(0, 0.875, 20)
	self._jump_spring = Spring.new(0, 0.875, 20)
	self._hitmarker_spring = Spring.new(1, 1, 20)
	self._hitmarker_rotation = 0
	self._last_damage_dealt_time = 0
	self:_Init()
	return self
end

function MouseCrosshair:Refresh()
	if self.Mouse.ItemInterface.ClientItem.ClientFighter.IsLocalPlayer then
		self.Crosshair:SetAppearance(SettingsLibrary:GenerateCrosshairAppearance(PlayerDataController))
		self.Mouse:Refresh()
	else
		local compressedCrosshairAppearance = self.Mouse.ItemInterface.ClientItem.ClientFighter:Get("CompressedCrosshairAppearance")

		if compressedCrosshairAppearance then
			self.Crosshair:SetAppearance(SettingsLibrary:DecodeCrosshairAppearance(compressedCrosshairAppearance))
			self.Mouse:Refresh()
		end
	end
end

function MouseCrosshair:DamageEffect(p, p2)
	if p[utf8.char(0)] == 0 then
		return
	end

	self._hitmarker_rotation = math.sign(math.random() - 0.5) * 15
	self._hitmarker_spring.Value = 0
	self._last_damage_dealt_time = tick()
	self.Crosshair:SetHitmarkerColor(p[utf8.char(1)])
	self.Mouse.ItemInterface.ClientItem.ViewModel:PlayHitmarkerSound(p[utf8.char(1)], p2)
end

function MouseCrosshair:Update(_, data2, _)
	if self.Crosshair.Info.DotEnabled or self.Crosshair.Info.BarsEnabled then
		local currentAimValue = self.Mouse.ItemInterface.ClientItem.ViewModel.CurrentAimValue
		local currentRecoilValue = self.Mouse.ItemInterface.ClientItem.ViewModel.CurrentRecoilValue
		local currentInspectValue = self.Mouse.ItemInterface.ClientItem.ViewModel.CurrentInspectValue
		local shootAccuracy = self.Mouse.ItemInterface.ClientItem.Info.ShootAccuracy or 1
		local isAimingAnimationEnabled = self.Mouse.ItemInterface.ClientItem.ViewModel:IsAimingAnimationEnabled()
		self._speed_spring.Target = not (data2.MoveSpeed > 4) and 0 or data2.MoveSpeed or 0
		self._jump_spring.Target = data2.IsGrounded and 0 or 1
		self._crouch_spring.Target = data2.IsCrouching and 0.25 or 1

		for _, v in pairs({ self._speed_spring, self._jump_spring, self._crouch_spring }) do
			v.Value = v.Target > v.Value and v.Target or v.Value
		end

		local value = self._crouch_spring.Value
		local v = self._speed_spring.Value * 0.75
		local value2 = self._jump_spring.Value
		local v2 = not self.Mouse.Scope:IsActive() and self.Crosshair:ShowWhileAiming() and 1 or 1 - currentAimValue
		local v3 = (self.Crosshair:GetAppearanceSpacing() + 8 * (v / CONSTANTS.BASE_WALKSPEED) ^ 2 + 32 * value2 + 100 * currentRecoilValue.Magnitude / shootAccuracy) * value / shootAccuracy
		local v4 = (not data2.IsFirstPerson or self.Mouse.ItemInterface.ClientItem.Name == "Minigun" or not isAimingAnimationEnabled) and 0 or 1 - v2 or 0
		local v5 = v4 + (1 - v4) * (self.Crosshair:ShowWhileInspecting() and 0 or currentInspectValue)
		self.Crosshair:SetSpacing(v3, v2)
		self.Crosshair:SetTransparency(v5)
	end

	local value = self._hitmarker_spring.Value
	local v = 32 + -26 * value
	local v2 = 16 + -8 * value
	local uDim = UDim2.new(0, v2, 0, v2)
	local v3 = math.min(1, (tick() - self._last_damage_dealt_time) / 2) ^ 10
	local v4 = (1 - value) * self._hitmarker_rotation
	self.Crosshair:SetHitmarkerVisuals(v, uDim, v3, v4)
end

function MouseCrosshair:Destroy()
	self.Crosshair:Destroy()
end

function MouseCrosshair:_Setup()
	self.Crosshair:SetType(self.Mouse.ItemInterface.ClientItem.Info.CrosshairType)
	self.Crosshair:SetParent(self.Mouse.Frame)
end

function MouseCrosshair:_Init()
	self:_Setup()
end

return MouseCrosshair