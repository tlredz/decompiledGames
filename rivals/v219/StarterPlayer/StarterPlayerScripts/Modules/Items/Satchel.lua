local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Throwable = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Throwable)
local object = setmetatable({}, Throwable)
object.__index = object

function object.new(...)
	local self = setmetatable(Throwable.new(...), object)
	self._detonate_cooldown = 0
	self._detonate_animation_cooldown = 0
	self:_Init()
	return self
end

function object.CanQuickAttack(object2)
	return Throwable.CanQuickAttack(object2) or object2:Get("NumSatchels") > 0
end

function object:StartShooting(p)
	if p or not ((self:Get("Ammo") or 1e999) <= 0 and self:Get("NumSatchels") > 0) then
		return Throwable.StartShooting(self, p)
	end

	return self:StartAiming(p)
end

function object:StartAiming(p)
	if not p and self:IsEquipping() then
		return false
	end

	if p or tick() > self._detonate_animation_cooldown then
		self._detonate_animation_cooldown = tick() + 0.25
		self.ViewModel:PlayAnimation("Detonate")
	end

	if not p and (self:Get("NumSatchels") <= 0 or tick() < self._detonate_cooldown) then
		return false
	end

	self._detonate_cooldown = tick() + 0.25
	return true, "StartAiming"
end

function object.FinishAiming(_, _)
	return false
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "SatchelAttached" then
		Throwable.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	Utility:CreateSound("rbxassetid://128061013194700", 0.1, 1, ..., true, 5)
end

function object:_Init() end

return object