local Players = game:GetService("Players")
local Shorty = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Shorty)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 0, 0))
local object = setmetatable({}, Shorty)
object.__index = object

function object.new(...)
	local self = setmetatable(Shorty.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object