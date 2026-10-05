local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
require(ReplicatedStorage.Modules.BetterDebris)
require(ReplicatedStorage.Modules.Utility)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._is_slamming = false
	self._slam_hash = 0
	self._slam_cooldown = 0
	self._leap_cooldown = 0
	self:_Init()
	return self
end

function object:StartAiming(p, p2)
	local v

	if p then
		v = p2
	else
		v = self.ClientFighter.Entity and (self.ClientFighter.Entity:IsAirborne() or not self.ClientFighter.Entity:IsGrounded())
	end

	local v2 = v and true or false

	if not p then
		p2 = v2 and not self.ClientFighter.Entity:GetFloor(self.Info.SlamFloorDistance)
	end

	local v3 = p2 and true or false

	if not p then
		if self:IsEquipping() or v3 and tick() < self._slam_cooldown or v2 and not v3 then
			return false
		end

		if self.ClientFighter.Entity.Humanoid:GetState() == Enum.HumanoidStateType.Climbing or not v2 and not v3 and tick() < self._leap_cooldown then
			return false
		end
	end

	self.ClientFighter.Entity:AirborneCancel()

	if v3 then
		self._slam_hash += 1
		local _slam_hash = self._slam_hash
		self._is_slamming = true
		self._slam_cooldown = tick() + self.Info.SlamCooldown
		self._attack_cooldown = 1e999
		self.ClientFighter.Entity.RootPart.Velocity = createVector(0, -128, 0)
		self:CooldownEffect("rbxassetid://127897416506738", self.Info.SlamCooldown, "Slam")
		task.spawn(function()
			self.ViewModel:PlayAnimation("SlamIntro", 1e999, 0)
			wait(AnimationLibrary.Info[self.ViewModel.Info.Animations.SlamIntro].Length)

			if _slam_hash ~= self._slam_hash then
				return
			end

			self.ViewModel:PlayAnimation("SlamLoop", 1e999, 0)
		end)
	else
		self._leap_cooldown = tick() + self.Info.LeapCooldown
		local v4 = self.ClientFighter:GetCameraData(nil, nil, true)[utf8.char(1)].LookVector * 32 * createVector(
			1,
			0,
			1
		) + createVector(0, 24, 0)
		self.ClientFighter.Entity:AirborneTrigger(v4, 2, true)
		self:CreateSound("rbxassetid://98587858115094", 1 + 0.25 * math.random(), 0.9 + 0.2 * math.random(), true, 10)
	end

	return true, "StartAiming", v3
end

function object:Unequip()
	self:_CancelSlam()
	Melee.Unequip(self)
end

function object:ReplicateFromServer(p, ...)
	if p == "SlamAttack" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...
		self:_CancelSlam()
		self._attack_cooldown = tick() + self.Info.SlamEndLag
		self.ViewModel:PlayAnimation("SlamOutro", 0, 0)
		self.ViewModel:SlamEffect(v, v2)
		self.ViewModel:SlamSoundEffect(v, v2)

		if self.ClientFighter:Get("IsSpectating") then
			CameraController:ShakeOnce(50, 10, 0.1, 0.4, createVector(0.25, 0.25, 0), createVector(0, 0, 0))
		end
	elseif p == "CancelSlam" then
		if not self:IsRendered() then
			return
		end

		self:_CancelSlam()
	else
		Melee.ReplicateFromServer(self, p, ...)
	end
end

function object:_CancelSlam()
	self._slam_hash += 1

	if not self._is_slamming then
		return
	end

	self._is_slamming = false
	self._attack_cooldown = 0
	self.ViewModel:StopAnimation("SlamIntro")
	self.ViewModel:StopAnimation("SlamLoop")
	self.ViewModel.Animator:SetInspectCooldown(0)
end

function object:_Init() end

return object