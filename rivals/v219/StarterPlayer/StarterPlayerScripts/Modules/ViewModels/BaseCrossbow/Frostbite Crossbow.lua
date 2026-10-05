local Players = game:GetService("Players")
local BaseCrossbow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseCrossbow)
local object = setmetatable({}, BaseCrossbow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseCrossbow.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Stick"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("Tip"))
end

return object