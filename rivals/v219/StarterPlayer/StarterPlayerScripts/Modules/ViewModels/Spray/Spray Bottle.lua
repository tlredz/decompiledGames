local Players = game:GetService("Players")
local Spray = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Spray)
local colorSequence = ColorSequence.new(Color3.fromRGB(75, 192, 255))
local object = setmetatable({}, Spray)
object.__index = object

function object.new(...)
	local self = setmetatable(Spray.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object