local Players = game:GetService("Players")
local BaseBow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseBow)
local object = setmetatable({}, BaseBow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseBow.new(...), object)
	self:_Init()
	return self
end

function object.PlayChargeSound(object2, p)
	BaseBow.PlayChargeSound(object2, p)
	object2:CreateSound("rbxassetid://117872201487330", 0.5, 0.5 + 0.1 * p, true, 10)
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Feather"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Tip"))
end

return object