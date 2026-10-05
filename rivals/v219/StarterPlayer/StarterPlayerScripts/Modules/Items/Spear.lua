local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local spearThrowParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc.SpearThrowParticles
local spearThrowTrail = Players.LocalPlayer.PlayerScripts.Assets.Misc.SpearThrowTrail
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._throw_cooldown = 0
	self:_Init()
	return self
end

function object:CanEasyQuickAttack()
	local canQuickAttack = self:CanQuickAttack()

	if canQuickAttack then
		if tick() > self._throw_cooldown then
			canQuickAttack = not self:IsEquipping()
		else
			canQuickAttack = false
		end
	end

	return canQuickAttack
end

function object:StartAiming(p, p2)
	if not p and (self:IsEquipping() or tick() < self._throw_cooldown or self:Get("Ammo") <= 0) then
		return false
	end

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	local v = p2 and self:FromEnum(p2) or self:Get("Ammo") <= 1 and "ThrowFinal" or "Throw"
	self._throw_cooldown = tick() + self.Info.ThrowCooldown
	self._attack_cooldown = tick() + self.Info.ThrowCooldown
	self:CooldownEffect("rbxassetid://86982712098586", self.Info.ThrowCooldown, v)
	self.ViewModel:StopAnimation("Inspect", 0)
	self.ViewModel:StopAnimation("Throw", 0)
	self.ViewModel:StopAnimation("ThrowFinal", 0)
	self.ViewModel:PlayAnimation(v, AnimationLibrary.Info[self.ViewModel.Info.Animations[v]].Length)
	self:_Shake("SpearThrow")
	task.spawn(self._PlayThrowParticles, self)
	return true, "StartAiming", self.ClientFighter:GetCameraData(), self:ToEnum(v)
end

function object._PlayThrowParticles(p)
	local position = nil
	local mousePositionFromCameraData = nil

	if p.ClientFighter.IsLocalPlayer then
		local cameraData = p.ClientFighter:GetCameraData(nil, nil, true)
		position = (cameraData[utf8.char(0)] * CFrame.new(0.5, -0.5, -0.5)).Position
		mousePositionFromCameraData = GameplayUtility:GetMousePositionFromCameraData(
			p.ClientFighter:Get("EnvironmentID"),
			p.ClientFighter:GetEntityLookupParams(),
			cameraData[utf8.char(0)],
			cameraData[utf8.char(1)],
			cameraData[utf8.char(2)],
			cameraData[utf8.char(3)]
		)
	else
		local head = p.ClientFighter.Entity and (p.ClientFighter.Entity.Head or p.ClientFighter.Entity.RootPart)

		if head then
			local v = CFrame.new(head.Position) * p.ClientFighter:GetRotationCFrame()
			position = v.Position
			mousePositionFromCameraData = GameplayUtility:GetMousePositionFromCameraData(
				p.ClientFighter:Get("EnvironmentID"),
				p.ClientFighter:GetEntityLookupParams(),
				v,
				v
			)
		end
	end

	if not position or not mousePositionFromCameraData or position:FuzzyEq(mousePositionFromCameraData) then
		return
	end

	local clone = spearThrowParticles:Clone()
	clone.CFrame = CFrame.new(position, mousePositionFromCameraData) * CFrame.new(
		0,
		0,
		-math.min(10, (position - mousePositionFromCameraData).Magnitude - 1)
	)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:PlayParticles(clone)
	local clone2 = spearThrowTrail:Clone()
	clone2.Parent = workspace
	clone2.Attachment0.WorldCFrame = CFrame.new(position, mousePositionFromCameraData)
	clone2.Attachment1.WorldCFrame = CFrame.new(mousePositionFromCameraData) * clone2.Attachment0.WorldCFrame.Rotation
	BetterDebris:AddItem(clone2, 5)
	local beam1 = clone2.Beam1
	local beam2 = clone2.Beam2
	local width0 = beam1.Width0
	local width1 = beam1.Width1
	local width02 = beam2.Width0
	local width12 = beam2.Width1
	Utility:RenderstepForLoop(0, 100, 10, function(p2)
		local v = (p2 / 100) ^ 3
		beam1.Width0 = width0 + (0 - width0) * v
		beam1.Width1 = width1 + (0 - width1) * v
		beam2.Width0 = width02 + (0 - width02) * v
		beam2.Width1 = width12 + (0 - width12) * v
	end)
	clone2:Destroy()
end

function object:_UpdateViewModelAnimations()
	local v = self:Get("Ammo") <= 0
	self.ViewModel:ChangeEquipAnimation(v and "EmptyEquip" or "Equip")
	self.ViewModel:ChangeIdleAnimation(v and "EmptyIdle" or "Idle")
	self.ViewModel:ChangeInspectAnimation(v and "EmptyInspect" or "Inspect")
	self.ViewModel:ChangeSprintAnimation(v and "EmptySprint" or "Sprint")
	local viewModel = self.ViewModel
	local v2

	if v then
		v2 = CFrame.identity
	end

	viewModel:OverrideRootPartOffset(v2)
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("Throw", 0)
		self.ViewModel:StopAnimation("ThrowFinal", 0)
	end
end

function object:_Init()
	self:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateViewModelAnimations()
	end)
	self:_Setup()
	task.defer(self._UpdateViewModelAnimations, self)
end

return object