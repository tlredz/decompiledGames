local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._build_cooldown = 0
	self:_Init()
	return self
end

function object:CanEasyQuickAttack()
	local canQuickAttack = self:CanQuickAttack()

	if canQuickAttack then
		if tick() > self._build_cooldown then
			canQuickAttack = not self:IsEquipping()
		else
			canQuickAttack = false
		end
	end

	return canQuickAttack
end

function object:StartAiming(p)
	if not p and (tick() < self._build_cooldown or self:IsEquipping()) then
		return false
	end

	local _, v = self.ClientFighter:GetCameraData()
	self._build_cooldown = tick() + self.Info.BuildCooldown
	self:CooldownEffect("rbxassetid://17132668997", self.Info.BuildCooldown, "Build")
	self.ViewModel:PlayAnimation("Build", AnimationLibrary.Info[self.ViewModel.Info.Animations.Build].Length)
	return true, "StartAiming", v.Position
end

function object.FinishAiming(_, _)
	return false
end

function object.ReplicateFromServer(object2, p, ...)
	if p == "HardenEffect" then
		if not object2:IsRendered() then
			return
		end

		local v = ...
		Utility:CreateSound("rbxassetid://17138809559", 1.25, 1 + 0.2 * math.random(), v, true, 5)
	else
		if p ~= "ThrowEffect" then
			Melee.ReplicateFromServer(object2, p, ...)
			return
		end

		if not object2:IsRendered() then
			return
		end

		local v = ...
		Utility:CreateSound("rbxassetid://14522189766", 1.25, 2 + 0.25 * math.random(), v, true, 5)
	end
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("Build")
	end
end

function object:_Init()
	self:_Setup()
end

return object