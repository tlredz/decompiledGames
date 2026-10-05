local Players = game:GetService("Players")
local AssaultRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Assault Rifle"])
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 215, 246))
local object = setmetatable({}, AssaultRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(AssaultRifle.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object