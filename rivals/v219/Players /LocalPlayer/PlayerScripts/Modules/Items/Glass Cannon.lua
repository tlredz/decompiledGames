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

function object.StartAiming(_, _)
	return false
end

function object.FinishAiming(_, _)
	return false
end

function object.StartSprinting(_, _)
	return false
end

function object:_UpdateViewModelAnimations()
	local v

	if self:Get("Ammo") <= 0 then
		v = self:Get("AmmoReserve") <= 0
	else
		v = false
	end

	self.ViewModel:ChangeEquipAnimation(v and "EmptyEquip" or "Equip")
	self.ViewModel:ChangeIdleAnimation(v and "EmptyIdle" or "Idle")
	self.ViewModel:ChangeInspectAnimation(v and "EmptyInspect" or "Inspect")
	self.ViewModel:ChangeSprintAnimation(v and "EmptySprint" or "Sprint")
end

function object:_Init()
	self:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateViewModelAnimations()
	end)
	task.defer(self._UpdateViewModelAnimations, self)
end

return object