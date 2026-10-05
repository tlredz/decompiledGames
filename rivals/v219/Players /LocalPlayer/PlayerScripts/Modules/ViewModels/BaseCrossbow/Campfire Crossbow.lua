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
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart1"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart2"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart3"))
end

return object