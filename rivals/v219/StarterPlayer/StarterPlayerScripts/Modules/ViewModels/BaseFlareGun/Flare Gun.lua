local Players = game:GetService("Players")
local BaseFlareGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseFlareGun)
local object = setmetatable({}, BaseFlareGun)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseFlareGun.new(...), object)
	self._is_empty = nil
	self:_Init()
	return self
end

function object:_UpdateAmmoContext()
	local is_empty = self.ClientItem:Get("Ammo") <= 0

	if is_empty == self._is_empty then
		return
	end

	self._is_empty = is_empty
	local v2 = self._is_empty and "Empty" or ""
	self:ChangeEquipAnimation("Equip" .. v2)
	self:ChangeIdleAnimation("Idle" .. v2)
	self:ChangeSprintAnimation("Sprint" .. v2)
	self:ChangeInspectAnimation("Inspect" .. v2)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoContext()
	end)
	self:_UpdateAmmoContext()
	self:_RegisterDefaultAmmoVisuals()
end

return object