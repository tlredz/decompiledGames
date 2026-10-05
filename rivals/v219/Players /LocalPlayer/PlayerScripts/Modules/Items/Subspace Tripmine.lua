local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.GameplayUtility)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self._use_cooldown = 0
	self._preview_connection = nil
	self._preview_model = nil
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	return tick() > self._use_cooldown and (self:Get("Ammo") or 1e999) > 0 and not self:IsEquipping()
end

function object:StartShooting(p)
	if not p and (tick() < self._use_cooldown or (self:Get("Ammo") or 1e999) <= 0 or self:IsEquipping()) then
		return false
	end

	self._use_cooldown = tick() + self.Info.Cooldown
	self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Use")
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:PlayAnimation("Use", 0.5)
	return true, "StartShooting", self:_GetPlacementPosition()
end

function object:Equip(...)
	Custom.Equip(self, ...)
	self:_StartPlacementPreview()
end

function object:Unequip(...)
	self:_StopPlacementPreview()
	Custom.Unequip(self, ...)
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "MineExplosion" then
		Custom.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	object2.ViewModel:ExplosionEffect(...)
end

function object:Destroy()
	self:_StopPlacementPreview()
	Custom.Destroy(self)
end

function object:_GetPlacementPosition()
	local _, v = self.ClientFighter:GetCameraData()
	return v.Position
end

function object:_StopPlacementPreview()
	if self._preview_connection then
		self._preview_connection:Disconnect()
		self._preview_connection = nil
	end

	if self._preview_model then
		self._preview_model:Destroy()
		self._preview_model = nil
	end
end

function object:_StartPlacementPreview()
	self:_StopPlacementPreview()

	if self.ClientFighter.IsLocalPlayer then
	end
end

function object:_Init() end

return object