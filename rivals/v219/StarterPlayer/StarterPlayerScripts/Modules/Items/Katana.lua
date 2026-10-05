game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._deflect_cooldown = 0
	self._deflect_hash = 0
	self._deflect_num = 0
	self:_Init()
	return self
end

function object:CanEasyQuickAttack()
	local canQuickAttack = self:CanQuickAttack()

	if canQuickAttack then
		if tick() > self._deflect_cooldown then
			canQuickAttack = not self:IsEquipping()
		else
			canQuickAttack = false
		end
	end

	return canQuickAttack
end

function object:StartAiming(p)
	if not p and (tick() < self._deflect_cooldown or self:IsEquipping()) then
		return
	end

	self._deflect_cooldown = tick() + self.Info.DeflectDuration + self.Info.DeflectCooldown
	self._attack_cooldown = tick() + self.Info.DeflectDuration
	self:_StartDeflecting()
	self:CooldownEffect("rbxassetid://16828414433", self.Info.DeflectDuration, "Deflect", true)
	task.delay(self.Info.DeflectDuration, function()
		self:CooldownEffect("rbxassetid://16828414433", self.Info.DeflectCooldown, "Deflect")
	end)
	return true, "StartAiming"
end

function object:ReplicateFromServer(p, ...)
	if p ~= "DeflectHit" then
		Melee.ReplicateFromServer(self, p, ...)
		return
	end

	if not self:IsRendered() then
		return
	end

	self.ViewModel:StopAnimation("DeflectIdle", 0)
	self.ViewModel:StopAnimation("Deflect" .. self._deflect_num)
	self._deflect_num = self._deflect_num == #self.ViewModel:GetAnimationKeys("Deflect") and 1 or self._deflect_num + 1
	self.ViewModel:PlayAnimation("Deflect" .. self._deflect_num, 1, 0)
	self.ViewModel:PlayDeflectHitParticles()
	self.ViewModel:PlayDeflectHitSounds()
end

function object:_StopDeflectionAnimations()
	for i = 1, #self.ViewModel:GetAnimationKeys("Deflect") do
		self.ViewModel:StopAnimation("Deflect" .. i)
	end
end

function object:_StartDeflecting()
	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	self._deflect_hash += 1
	local _deflect_hash = self._deflect_hash
	self:SetReplicate("FOVOffset", 5)
	self.ViewModel:StopAnimation("Equip", 0)
	self.ViewModel:PlayAnimation("DeflectIdle", self.Info.DeflectDuration)

	if self:Get("QuickAttackQueued") then
		task.delay(0.1, function()
			self.ViewModel:PlayDeflectActiveParticles()
		end)
	else
		self.ViewModel:PlayDeflectActiveParticles()
	end

	task.spawn(function()
		wait(self.Info.DeflectDuration)

		if self._deflect_hash ~= _deflect_hash then
			return
		end

		self:_StopDeflecting()
		wait(self.Info.DeflectCooldown)

		if self._deflect_hash ~= _deflect_hash then
			return
		end

		self:StopCooldownEffect("Deflect")
	end)
end

function object:_StopDeflecting()
	self._deflect_hash += 1
	self:SetReplicate("FOVOffset", 0)
	self.ViewModel:ClearDeflectActiveParticles()
	self:_StopDeflectionAnimations()
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("DeflectIdle", 0)
		self:_StopDeflectionAnimations()
	end
end

function object:_Init()
	self:_Setup()
end

return object