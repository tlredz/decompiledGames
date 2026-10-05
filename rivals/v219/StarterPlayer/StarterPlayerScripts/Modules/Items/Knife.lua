local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
local Melee = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Melee)
local object = setmetatable({}, Melee)
object.__index = object

function object.new(...)
	local self = setmetatable(Melee.new(...), object)
	self._heavy_attack_num = 0
	self._backstab_hash = 0
	self._fov_offset_speed = 1
	self:_Init()
	return self
end

function object:GetAimSpeed()
	return self._fov_offset_speed
end

function object:StartAiming(p, p2)
	if not p and (tick() < self._attack_cooldown or self:IsEquipping()) then
		return false
	end

	self._attack_cooldown = tick() + self.Info.HeavyAttackCooldown
	self:CooldownEffect("rbxassetid://133090003053503", self.Info.HeavyAttackCooldown, "HeavyAttack")

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	self._heavy_attack_num = self._heavy_attack_num % #self.ViewModel:GetAnimationKeys("HeavyAttack") + 1
	local last_attack_animation_name = p2 and self:FromEnum(p2) or "HeavyAttack" .. self._heavy_attack_num
	self._last_attack_animation_name = last_attack_animation_name
	self.ViewModel:StopAnimation("HeavyAttackAnimationHit")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation(last_attack_animation_name, self.Info.HeavyAttackCooldown)
	task.delay(0.1, function()
		self:_Shake("Bump")
	end)
	local cameraData, v2 = self.ClientFighter:GetCameraData()

	if self.ClientFighter.IsLocalPlayer then
		self:_ImpactMarkerSlash(self.Info.HeavyAttackReach, cameraData, v2)
	end

	if not self:Get("DashOnAim") then
		return true, "StartAiming", cameraData, self:ToEnum(last_attack_animation_name)
	end

	if not p then
		local v3 = self.ClientFighter:GetMoveVector(true, false, workspace.CurrentCamera.CFrame.LookVector) * 100
		self.ClientFighter.Entity:HardDash(v3, 0.25)
	end

	self:CreateSound("rbxassetid://16492958314", 1, 1 + 0.1 * math.random(), true)
	return true, "StartAiming", cameraData, self:ToEnum(last_attack_animation_name)
end

function object:ReplicateFromServer(p, ...)
	if p ~= "BackstabEffect" then
		Melee.ReplicateFromServer(self, p, ...)
		return
	end

	if not self:IsRendered() then
		return
	end

	self._backstab_hash += 1
	local _backstab_hash = self._backstab_hash
	self._fov_offset_speed = 5
	self:SetReplicate("FOVOffset", -10)
	wait(0.25)

	if self._backstab_hash ~= _backstab_hash then
		return
	end

	self._fov_offset_speed = 1
	self:SetReplicate("FOVOffset", 0)
end

function object:_Setup()
	function self._on_attack_callback()
		self.ViewModel:StopAnimation("HeavyAttackAnimationHit")
	end
end

function object:_Init()
	self:_Setup()
end

return object