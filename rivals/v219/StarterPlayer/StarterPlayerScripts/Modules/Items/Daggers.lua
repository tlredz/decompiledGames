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

function object:_UpdateViewModelAnimations()
	local dontUseAmmoReserveToChangeCoreAnimations

	if self:Get("Ammo") <= 0 then
		dontUseAmmoReserveToChangeCoreAnimations = self.ViewModel.DontUseAmmoReserveToChangeCoreAnimations or self:Get("AmmoReserve") <= 0
	else
		dontUseAmmoReserveToChangeCoreAnimations = false
	end

	self.ViewModel:ChangeEquipAnimation(dontUseAmmoReserveToChangeCoreAnimations and self.ViewModel.Info.Animations.EmptyEquip and "EmptyEquip" or "Equip")
	self.ViewModel:ChangeInspectAnimation(dontUseAmmoReserveToChangeCoreAnimations and self.ViewModel.Info.Animations.EmptyInspect and "EmptyInspect" or "Inspect")
	self.ViewModel:ChangeIdleAnimation(dontUseAmmoReserveToChangeCoreAnimations and self.ViewModel.Info.Animations.EmptyIdle and "EmptyIdle" or "Idle")
	local viewModel = self.ViewModel
	local v

	if dontUseAmmoReserveToChangeCoreAnimations and self.ViewModel.Info.Animations.EmptyIdle then
		v = CFrame.identity
	end

	viewModel:OverrideRootPartOffset(v)
end

function object:_Init()
	self:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateViewModelAnimations()
	end)
	self:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateViewModelAnimations()
	end)
	task.defer(self._UpdateViewModelAnimations, self)
end

return object