local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self.AnimationReachedHealTimestamp = Signal.new()
	self._is_using = false
	self._use_cooldown = 0
	self._use_hash = 0
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	local v = not self._is_using

	if v then
		if tick() > self._use_cooldown then
			return not self:IsEquipping() and self.ClientFighter:GetHealth() < self.ClientFighter:GetMaxHealth()
		else
			return false
		end
	end

	return v
end

function object:StartShooting(p)
	if p or not (self._is_using or tick() < self._use_cooldown or self:IsEquipping() or self.ClientFighter:GetHealth() >= self.ClientFighter:GetMaxHealth()) then
		self:_Use("Long")
		return true, "StartShooting"
	else
		return false
	end
end

function object:StartAiming(p)
	if p or not (self._is_using or tick() < self._use_cooldown or self:IsEquipping() or self.ClientFighter:GetHealth() >= self.ClientFighter:GetMaxHealth()) then
		self:_Use("Quick")
		return true, "StartAiming"
	else
		return false
	end
end

function object:Unequip(...)
	self:_CancelUse()
	Custom.Unequip(self, ...)
end

function object:ReplicateFromServer(p, ...)
	if p == "CancelUse" then
		if not self:IsRendered() then
			return
		end

		self:_CancelUse()
	else
		if p ~= "SetCooldown" then
			Custom.ReplicateFromServer(self, p, ...)
			return
		end

		if not self:IsRendered() then
			return
		end

		self:_SetCooldown()
	end
end

function object.Destroy(p)
	p.AnimationReachedHealTimestamp:Destroy()
	Custom.Destroy(p)
end

function object:_SetCooldown()
	self._use_cooldown = tick() + self.Info.Cooldown
	self._is_using = false
	self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Heal")
end

function object:_CancelUse()
	self._is_using = false
	self._use_hash += 1
	self:StopCooldownEffect("Healing")
	self.ViewModel:StopAnimation("Use")
	self.ViewModel:StopAnimation("UseQuick")
end

function object:_Use(p)
	self._is_using = true
	local _use_hash = self._use_hash
	local v = self.Info[p .. "ActionTimestamp"]
	local v2 = p == "Long" and "Use" or p == "Quick" and "UseQuick" or nil
	local v3 = AnimationLibrary.Info[self.ViewModel.Info.Animations[v2]]
	self.ViewModel:StopAnimation(self.ViewModel.Animator:GetEquipAnimationKey())
	self.ViewModel:PlayAnimation(v2, v3.Length)
	self:CooldownEffect("rbxassetid://17140223250", v, "Healing", true)
	task.spawn(function()
		wait(v)

		if _use_hash ~= self._use_hash then
			return
		end

		self.AnimationReachedHealTimestamp:Fire()
		self._use_cooldown = tick() + 1
		self._is_using = false
	end)
	task.spawn(function()
		wait(v3.Length)

		if _use_hash ~= self._use_hash then
			return
		end

		if self.ViewModel.PlayEquipAnimationOnHeal then
			self.ViewModel:PlayAnimation(self.ViewModel.Animator:GetEquipAnimationKey())
		end
	end)
end

function object:_Init() end

return object