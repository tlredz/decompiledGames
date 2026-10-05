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
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart1"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart2"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart3"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart4"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("LeftBody"):WaitForChild("MeshPart5"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart1"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart2"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart3"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart4"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("RightBody"):WaitForChild("MeshPart5"), 2)
end

return object