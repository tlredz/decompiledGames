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
	object2:CreateSound("rbxassetid://98081733365737", 0.5, 1 + 0.1 * p, true, 10)

	if p >= 4 then
		object2:CreateSound("rbxassetid://106485622539697", 0.375, 1.25 + 0.25 * math.random(), true, 5)
	end
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick2"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Tip"))
end

return object