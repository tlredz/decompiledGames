local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._dash_cooldown = 0
	self:_Init()
	return self
end

function object:CanEasyQuickAttack()
	local canQuickAttack = self:CanQuickAttack()

	if canQuickAttack then
		if tick() > self._dash_cooldown then
			canQuickAttack = not self:IsEquipping()
		else
			canQuickAttack = false
		end
	end

	return canQuickAttack
end

function object:StartAiming(p)
	if not p and (tick() < self._dash_cooldown or self:IsEquipping()) then
		return false
	end

	self._dash_cooldown = tick() + self.Info.DashCooldown
	self:CooldownEffect("rbxassetid://16828140099", self.Info.DashCooldown, "Dash")
	self.ViewModel:StopAnimation("Inspect")

	if self.ViewModel:GetAnimationTrack("Dash") then
		if self._last_attack_animation_name then
			self.ViewModel:StopAnimation(self._last_attack_animation_name)
		end

		self.ViewModel:PlayAnimation("Dash")
	end

	if not p then
		local v = self.ClientFighter:GetMoveVector(true, false, workspace.CurrentCamera.CFrame.LookVector) * self.Info.DashSpeed
		self.ClientFighter.Entity:HardDash(v, self.Info.DashDuration)
	end

	self:CreateSound("rbxassetid://16492958314", 1, 1 + 0.1 * math.random(), true)

	if self.ItemInterface then
		self.ItemInterface:PlaySpeedLines(self.Info.DashDuration)
	end

	return true, "StartAiming"
end

function object.FinishAiming(_, _)
	return false
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("Dash", 0)
	end
end

function object:_Init()
	self:_Setup()
end

return object