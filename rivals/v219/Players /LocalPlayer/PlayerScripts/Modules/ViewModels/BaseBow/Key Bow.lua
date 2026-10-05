local Players = game:GetService("Players")
local BaseBow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseBow)
local v = {
	Color3.fromRGB(191, 191, 191),
	Color3.fromRGB(250, 228, 116),
	Color3.fromRGB(248, 214, 44),
	Color3.fromRGB(229, 192, 6)
}
local object = setmetatable({}, BaseBow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseBow.new(...), object)
	self:_Init()
	return self
end

function object.GetChargeColor(_, p)
	return v[p]
end

function object.PlayChargeSound(object2, p)
	BaseBow.PlayChargeSound(object2, p)
	object2:CreateSound("rbxassetid://90757583550672", 0.5, 1.25 + 0.25 * p, true, 5)
	object2:CreateSound("rbxassetid://90757583550672", 0.125, 1, true, 5)
end

function object:_UpdateAmmoContext()
	local is_empty = self.ClientItem:Get("Ammo") <= 0

	if is_empty == self._is_empty then
		return
	end

	self._is_empty = is_empty
	self:ChangeInspectAnimation(self._is_empty and "InspectEmpty" or "Inspect")
	self.Animator:ChangeRareInspectAnimation(self._is_empty and "nil" or "RareInspect")
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateAmmoContext()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoContext()
	end)
	self:_UpdateAmmoContext()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick"))
end

return object