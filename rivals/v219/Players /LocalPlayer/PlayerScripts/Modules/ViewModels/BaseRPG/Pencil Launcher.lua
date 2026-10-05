local Players = game:GetService("Players")
local BaseRPG = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRPG)
local object = setmetatable({}, BaseRPG)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRPG.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Lead"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Wood"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Yellow"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Neck"))
end

return object