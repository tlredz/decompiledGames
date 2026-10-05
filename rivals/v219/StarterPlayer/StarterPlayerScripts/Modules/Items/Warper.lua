local Players = game:GetService("Players")
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self._portal_cooldown = 0
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:StartShooting(...)
	return self:_OpenPortal("StartShooting", ...)
end

function object:StartAiming(...)
	return self:_OpenPortal("StartAiming", ...)
end

function object:_OpenPortal(p, p2)
	if not p2 and (tick() < self._portal_cooldown or self:IsEquipping()) then
		return
	end

	self._portal_cooldown = tick() + self.Info.ShootCooldown
	local cameraData = self.ClientFighter:GetCameraData()
	self:_Recoil(1)
	self.ViewModel:MuzzleFlash()
	self.ViewModel:StopAnimation("Equip", 0)
	self.ViewModel:PlayAnimation("Shoot1", self.Info.ShootCooldown, 0)
	return true, p, cameraData
end

function object:_Init() end

return object