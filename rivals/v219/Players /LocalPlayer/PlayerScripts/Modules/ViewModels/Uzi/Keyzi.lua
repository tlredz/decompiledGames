local Players = game:GetService("Players")
local Uzi = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Uzi)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 218, 155))
local object = setmetatable({}, Uzi)
object.__index = object

function object.new(...)
	local self = setmetatable(Uzi.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.PlayAimSound(object2, p)
	object2:CreateSound("rbxassetid://96253147006478", 0.375, 2 + (p and 0.1 or 0), true, 5)
end

function object:_Init() end

return object