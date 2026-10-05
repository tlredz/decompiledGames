local Players = game:GetService("Players")
local BaseCrossbow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseCrossbow)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255))
local object = setmetatable({}, BaseCrossbow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseCrossbow.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart"))
end

return object