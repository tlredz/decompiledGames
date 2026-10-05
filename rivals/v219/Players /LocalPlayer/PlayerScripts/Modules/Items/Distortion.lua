local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self._vortex_cooldown = 0
	self:_Init()
	return self
end

function object:StartAiming(p)
	if not p and (tick() < self._vortex_cooldown or self:IsEquipping()) then
		return
	end

	self._vortex_cooldown = tick() + self.Info.VortexCooldown
	local cameraData = self.ClientFighter:GetCameraData()
	self:_Recoil(1)
	self:CooldownEffect("rbxassetid://76793585944473", self.Info.VortexCooldown, "Vortex")
	self.ViewModel:MuzzleFlash()
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:StopAnimation("Equip", 0)
	self.ViewModel:PlayAnimation("Shoot1")
	return true, "StartAiming", cameraData
end

function object.FinishAiming(_, _)
	return false
end

function object.StartSprinting(_, _)
	return false
end

function object:_Init() end

return object