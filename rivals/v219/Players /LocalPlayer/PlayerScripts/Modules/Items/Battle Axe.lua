local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.AnimationLibrary)
require(ReplicatedStorage.Modules.BetterDebris)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._spin_cooldown = 0
	self:_Init()
	return self
end

function object:CanQuickAttack()
	return tick() > self._spin_cooldown and not self:IsEquipping()
end

function object:StartAiming(p)
	if not p and (tick() < self._spin_cooldown or tick() < self._attack_cooldown or self:IsEquipping()) then
		return
	end

	self._spin_cooldown = tick() + self.Info.SpinCooldown
	self._attack_cooldown = tick() + self.Info.SpinDuration + 0.5

	if not p then
		local v = workspace.CurrentCamera.CFrame.LookVector:FuzzyEq(createVector(0, 1, 0)) and createVector(0, 0, 0) or (workspace.CurrentCamera.CFrame.LookVector * createVector(
			1,
			0,
			1
		)).Unit
		local v2 = self.ClientFighter:GetMoveVector(true, true, v) * self.Info.SpinSpeed
		self.ClientFighter.Entity:HardDash(v2, self.Info.SpinDuration, true, createVector(0, 0.625, 0))
	end

	if self.ItemInterface then
		self.ItemInterface:PlaySpeedLines(self.Info.SpinDuration)
	end

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	self:CooldownEffect("rbxassetid://16828140099", self.Info.SpinCooldown, "Spin")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation("SpinAttack", 1)
	self.ViewModel:PlaySpinParticles()
	self:_Shake("BattleAxeSpin")
	return true, "StartAiming", (self.ClientFighter:GetCameraData())
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("SpinAttack")
	end
end

function object:_Init()
	self:_Setup()
end

return object