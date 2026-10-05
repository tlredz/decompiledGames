local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._is_holding = false
	self._hold_cooldown = 0
	self._hold_hash = 0
	self._hold_sounds = nil
	self._hold_sounds_progress = 0
	self._hold_particles = {}
	self:_Init()
	return self
end

function object:StartAiming(p)
	if not p and (self._is_holding or tick() < self._hold_cooldown or tick() < self._attack_cooldown or self:Get("Ammo") <= 0 or self:IsEquipping()) then
		return false
	end

	self._is_holding = true
	self._hold_cooldown = tick() + self.Info.InternalHoldCooldown
	self._attack_cooldown = 1e999

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	self.ViewModel:StopAnimation(self.ViewModel.Animator:GetEquipAnimationKey(), 0)
	self.ViewModel:PlayAnimation("HoldStart", 1e999, 0.1)
	self.ViewModel:StopAnimation("HoldFinish", 0.1)
	self._hold_hash += 1
	local _hold_hash = self._hold_hash
	task.spawn(function()
		local lastTime = tick()
		local ammo = nil
		local lastTime2 = nil

		while self._is_holding and _hold_hash == self._hold_hash do
			local v = self.Info.HoldSpeedBoostMin + (self.Info.HoldSpeedBoostMax - self.Info.HoldSpeedBoostMin) * math.clamp(
				(tick() - lastTime) / self.Info.HoldSpeedBoostRampTime,
				0,
				1
			)
			self.ClientFighter.Entity:SetBoost("Speed", "ChainsawHold", 0.3, v)
			self:_Shake("ChainsawHold")

			if ammo and ammo == self:Get("Ammo") then
				if tick() - lastTime2 > 0.25 then
					self:SimulateInputFromGameplayMechanic("FinishAiming", true)
					break
				end
			else
				ammo = self:Get("Ammo")
				lastTime2 = tick()
			end

			wait(0.1)
		end
	end)
	task.spawn(function()
		wait(AnimationLibrary.Info[self.ViewModel.Info.Animations.HoldStart].Length)

		if _hold_hash ~= self._hold_hash then
			return
		end

		self.ViewModel:PlayAnimation("HoldLoop", 1e999, 0)
		self.ViewModel:EnableParticles(true)
	end)

	if not self._hold_sounds then
		self._hold_sounds = {}

		for _, v in pairs(self.ViewModel:CreateHoldSounds()) do
			self._hold_sounds[v] = v.Volume
			v.Looped = true
		end

		self.ViewModel:PlayStartingHoldSounds()
	end

	task.spawn(Utility.RenderstepForLoop, Utility, self._hold_sounds_progress, 100, 25, function(hold_sounds_progress)
		if _hold_hash ~= self._hold_hash then
			return true
		end

		self._hold_sounds_progress = hold_sounds_progress

		for k, _hold_sound in pairs(self._hold_sounds) do
			k.Volume = _hold_sound * hold_sounds_progress / 100
		end
	end)
	return true, "StartAiming"
end

function object:FinishAiming(p)
	if p or self._is_holding then
		self:_StopHolding(true)
		return true, "FinishAiming"
	end
end

function object:Equip()
	Melee.Equip(self)
	self:_StopHolding()
end

function object:Unequip()
	self:_StopHolding(true)
	Melee.Unequip(self)
end

function object:ReplicateFromServer(p, ...)
	if p == "StopHolding" then
		self:_StopHolding(true)
	else
		Melee.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	self:_StopHolding()
	Melee.Destroy(self)
end

function object:_StopHolding(p)
	local _is_holding = self._is_holding
	self._hold_hash += 1
	self._is_holding = false
	self._attack_cooldown = p and 0 or self._attack_cooldown

	if self.ClientFighter.Entity then
		self.ClientFighter.Entity:RemoveBoost("ChainsawHold")
	end

	if _is_holding then
		self.ViewModel:PlayAnimation(
			"HoldFinish",
			AnimationLibrary.Info[self.ViewModel.Info.Animations.HoldFinish].Length,
			0.1
		)
	end

	self.ViewModel:StopAnimation("HoldStart", 0.1)
	self.ViewModel:StopAnimation("HoldLoop", 0.1)

	if self._hold_sounds then
		local _hold_hash = self._hold_hash
		task.spawn(function()
			Utility:RenderstepForLoop(self._hold_sounds_progress, 0, -10, function(hold_sounds_progress)
				if _hold_hash ~= self._hold_hash then
					return true
				end

				self._hold_sounds_progress = hold_sounds_progress

				for k, _hold_sound in pairs(self._hold_sounds) do
					k.Volume = _hold_sound * (hold_sounds_progress / 100) ^ 2
				end
			end)

			if _hold_hash ~= self._hold_hash then
				return
			end

			for k in pairs(self._hold_sounds) do
				k:Destroy()
			end

			self._hold_sounds = nil
		end)
	end

	self.ViewModel:EnableParticles(false)
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("HoldFinish")
	end
end

function object:_Init()
	table.insert(self._connections, self.ClientFighter.Interrupted:Connect(function()
		if self._is_holding then
			self:_StopHolding(true)
		end
	end))
	self:_Setup()
end

return object