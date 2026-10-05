local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
local ClientItem = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
local object = setmetatable({}, ClientItem)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientItem.new(...), object)
	self._last_attack = 0
	self._burst_count = 0
	self._attack_cooldown = 0
	self._attack_num = 0
	self._attack_hash = 0
	self._last_attack_animation_name = nil
	self._on_attack_callback = nil
	self:_Init()
	return self
end

function object.GetAutoShootReach(p)
	return p.Info.AttackReach
end

function object:CanQuickAttack()
	local v = not self:IsEquipping()

	if v then
		if tick() > self._attack_cooldown then
			return not self.Info.NeedsAmmoToAttack or self:Get("Ammo") > 0
		else
			return false
		end
	end

	return v
end

function object:StartShooting(p, p2)
	if not p and (self:IsEquipping() or tick() < self._attack_cooldown or self.Info.NeedsAmmoToAttack and self:Get("Ammo") <= 0) then
		return false
	end

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name, self.Info.BurstCount > 1 and 0 or nil)
	end

	self._burst_count = tick() - self._last_attack >= self.Info.AttackCooldown and 0 or self._burst_count
	self._burst_count = self._burst_count % self.Info.BurstCount + 1
	self._last_attack = tick()
	local burstCooldown = self._burst_count < self.Info.BurstCount and self.Info.BurstCooldown or self.Info.AttackCooldown
	self._attack_cooldown = tick() + burstCooldown
	self._attack_hash += 1
	local _attack_hash = self._attack_hash
	self._attack_num = self._attack_num % #self.ViewModel:GetAnimationKeys("Attack") + 1
	local last_attack_animation_name = p2 and self:FromEnum(p2) or "Attack" .. self._attack_num
	self._last_attack_animation_name = last_attack_animation_name
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation(last_attack_animation_name, burstCooldown)

	if self._on_attack_callback then
		self._on_attack_callback()
	end

	task.delay(self.Info.AttackDelay, function()
		if _attack_hash ~= self._attack_hash then
			return
		end

		if self.ClientFighter.IsLocalPlayer then
			local cameraData, v2 = self.ClientFighter:GetCameraData()
			self:_ImpactMarkerSlash(self.Info.AttackReach, cameraData, v2)
		end

		self:_Shake("Bump")
	end)
	return true, "StartShooting", self.ClientFighter:GetCameraData(), self:ToEnum(last_attack_animation_name)
end

function object:Equip(...)
	ClientItem.Equip(self, ...)
	self._attack_hash += 1
end

function object:Unequip(...)
	self._attack_hash += 1
	ClientItem.Unequip(self, ...)
end

function object:_Init() end

return object