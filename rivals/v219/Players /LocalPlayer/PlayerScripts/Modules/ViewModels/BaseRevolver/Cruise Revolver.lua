local Players = game:GetService("Players")
local BaseRevolver = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRevolver)
local colorSequence = ColorSequence.new(Color3.fromRGB(53, 194, 255))
local object = setmetatable({}, BaseRevolver)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRevolver.new(...), object)
	self._is_empty = false
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_UpdateDefaultAnimationsFromAmmo()
	local ammo = self.ClientItem:Get("Ammo")
	self.ClientItem:Get("AmmoReserve")
	local is_empty = ammo <= 0

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
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateDefaultAnimationsFromAmmo()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateDefaultAnimationsFromAmmo()
	end)
	self:_UpdateDefaultAnimationsFromAmmo()
end

return object