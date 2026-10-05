local Players = game:GetService("Players")
local BurstRifle = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Burst Rifle"])
local colorSequence = ColorSequence.new(Color3.fromRGB(56, 255, 112))
local object = setmetatable({}, BurstRifle)
object.__index = object

function object.new(...)
	local self = setmetatable(BurstRifle.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object