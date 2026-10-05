local Players = game:GetService("Players")
local Wildcat = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Wildcat)
local colorSequence = ColorSequence.new(Color3.fromRGB(149, 43, 255))
local object = setmetatable({}, Wildcat)
object.__index = object

function object.new(...)
	local self = setmetatable(Wildcat.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object