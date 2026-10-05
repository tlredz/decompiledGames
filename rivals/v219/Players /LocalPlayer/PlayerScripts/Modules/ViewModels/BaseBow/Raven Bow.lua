local Players = game:GetService("Players")
local BaseBow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseBow)
local object = setmetatable({}, BaseBow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseBow.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Feather1"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Feather2"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Tip"))
end

return object