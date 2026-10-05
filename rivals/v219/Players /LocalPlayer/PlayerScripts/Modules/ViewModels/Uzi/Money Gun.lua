local Players = game:GetService("Players")
local Uzi = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Uzi)
local colorSequence = ColorSequence.new(Color3.fromRGB(0, 255, 0))
local object = setmetatable({}, Uzi)
object.__index = object

function object.new(...)
	local self = setmetatable(Uzi.new(...), object)
	self._body_money = self.ItemModel:WaitForChild("Body"):WaitForChild("Money")
	self._body_money_decal1 = self._body_money:WaitForChild("Decal1")
	self._body_money_decal2 = self._body_money:WaitForChild("Decal2")
	self._magazine_money = self.ItemModel:WaitForChild("Magazine"):WaitForChild("Money")
	self._magazine_money_decal1 = self._magazine_money:WaitForChild("Decal1")
	self._magazine_money_decal2 = self._magazine_money:WaitForChild("Decal2")
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	local ammo = self.ClientItem:Get("Ammo")
	local v = ammo > 0 and 0 or 1
	local v2 = (ammo > 1 or self:IsAnimationPlaying("Reload")) and 0 or 1
	self:_LocalTransparencyModifier(self._body_money, "AmmoVisual", v)
	self:_LocalTransparencyModifier(self._body_money_decal1, "AmmoVisual", v)
	self:_LocalTransparencyModifier(self._body_money_decal2, "AmmoVisual", v)
	self:_LocalTransparencyModifier(self._magazine_money, "AmmoVisual", v2)
	self:_LocalTransparencyModifier(self._magazine_money_decal1, "AmmoVisual", v2)
	self:_LocalTransparencyModifier(self._magazine_money_decal2, "AmmoVisual", v2)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.AnimationPlayed:Connect(function()
		self:_UpdateAmmoVisual()
	end)
	self.AnimationStopped:Connect(function()
		self:_UpdateAmmoVisual()
	end)
	task.defer(self._UpdateAmmoVisual, self)
end

return object