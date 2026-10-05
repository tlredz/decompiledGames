local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self:_Init()
	return self
end

function object:StartAiming(p)
	if not p and (tick() < self._shoot_cooldown or tick() < self._reload_cooldown or self:Get("Ammo") <= 0 or self:IsEquipping()) then
		return
	end

	self._reload_cooldown = tick() + 1.5
	task.delay(1.5, self._CheckReload, self)
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:PlayAnimation("Throw", 1)
	return true, "StartAiming", (self.ClientFighter:GetCameraData())
end

function object.FinishAiming(_, _)
	return false
end

function object.StartSprinting(_, _)
	return false
end

function object:_Init() end

return object