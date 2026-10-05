local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self._is_charging = false
	self._charge_hash = 0
	self:_Init()
	return self
end

function object:StartAiming(p)
	if not p then
		if self._is_charging or tick() < self._shoot_cooldown or tick() < self._reload_cooldown or tick() < self._shoot_cooldown_no_ammo or self:IsEquipping() then
			return false
		end

		if self:Get("Ammo") <= 0 then
			local v = { self:StartReloading() }

			if v[1] then
				return table.unpack(v)
			end

			self._shoot_cooldown_no_ammo = tick() + self.Info.ShootCooldown
			self:CreateSound("rbxassetid://13087319223", 1, 1, true, 5)
			return false
		end
	end

	local chargeLevelTimestamps = self.Info.ChargeLevelTimestamps
	self._is_charging = true
	self._shoot_cooldown = 1e999
	self._reload_cooldown = 1e999
	self:_StartAimAssist()
	self._on_shoot_callback()
	self.ViewModel:StopAnimation("Equip", 0)
	self.ViewModel:PlayAnimation("Charge", 1e999, 0.1)

	if self.ItemInterface then
		self.ItemInterface.Charge:Set(1)
		self.ItemInterface.Charge:Start(chargeLevelTimestamps)
	end

	self._charge_hash += 1
	local _charge_hash = self._charge_hash
	task.spawn(function()
		for k, chargeLevelTimestamp in pairs(chargeLevelTimestamps) do
			if chargeLevelTimestamp <= 0 then
				continue
			end

			wait(chargeLevelTimestamp - (chargeLevelTimestamps[k - 1] or 0))

			if _charge_hash ~= self._charge_hash then
				break
			end

			self:SetReplicate("FOVOffset", 5 * (k - 1))
			self.ViewModel:PlayChargeEffect(k)

			if not self.ItemInterface then
				continue
			end

			self.ItemInterface.Charge:Set(k)
			self.ItemInterface.Charge:Play()
		end
	end)
	task.spawn(function()
		wait(AnimationLibrary.Info[self.ViewModel.Info.Animations.Charge].Length)

		if _charge_hash ~= self._charge_hash then
			return
		end

		self.ViewModel:PlayAnimation("ChargeLoop", 1e999, 0)
	end)
	return true, "StartAiming"
end

function object:FinishAiming(p)
	if p or self._is_charging then
		self:_StopCharging()
		return true, "FinishAiming", (self.ClientFighter:GetCameraData())
	else
		return false
	end
end

function object.StartSprinting(_, _)
	return false
end

function object:Unequip(...)
	task.spawn(self.Input, self, "FinishAiming")
	task.defer(self._StopCharging, self, true)
	Gun.Unequip(self, ...)
end

function object:_StopCharging(p)
	local chargeReleaseCooldown = self.Info.ChargeReleaseCooldown
	self._is_charging = false
	self._charge_hash += 1
	self._shoot_cooldown = tick() + chargeReleaseCooldown
	self._reload_cooldown = tick() + chargeReleaseCooldown
	self:_FinishAimAssist()
	self:SetReplicate("FOVOffset", 0)

	if not p then
		self.ViewModel:PlayAnimation("ChargeRelease", chargeReleaseCooldown, 0)
	end

	self.ViewModel:StopAnimation("ChargeLoop", 0.1)
	self.ViewModel:StopAnimation("Charge", 0.1)

	if self.ItemInterface then
		self.ItemInterface.Charge:Stop(p)
	end
end

function object:_Setup()
	function self._on_shoot_callback()
		self.ViewModel:StopAnimation("ChargeLoop", 0)
		self.ViewModel:StopAnimation("ChargeRelease", 0)
	end
end

function object:_Init()
	table.insert(self._connections, self.ClientFighter.Interrupted:Connect(function()
		self:_StopCharging(true)
	end))
	self:_Setup()
end

return object