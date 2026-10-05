local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self._use_cooldown = 0
	self._use_hash = 0
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	return tick() > self._use_cooldown and not self:IsEquipping()
end

function object:StartShooting(p)
	if not p and (tick() < self._use_cooldown or self:IsEquipping()) then
		return false
	end

	self._use_cooldown = tick() + self.Info.Cooldown
	self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Use")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation("Use", AnimationLibrary.Info[self.ViewModel.Info.Animations.Use].Length)
	self.ViewModel:PlayHornEffect()
	return true, "StartShooting"
end

function object:Unequip(...)
	self._use_hash += 1
	Custom.Unequip(self, ...)
end

function object:_CancelUse()
	self._is_using = false
	self._use_hash += 1
	self:StopCooldownEffect("Use")
	self.ViewModel:StopAnimation("Use")
	self.ViewModel:StopAnimation("UseQuick")
end

function object:_Init() end

return object