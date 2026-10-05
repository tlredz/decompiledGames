local Players = game:GetService("Players")
local BaseDaggers = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseDaggers)
local object = setmetatable({}, BaseDaggers)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseDaggers.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart"), 2)
end

return object