local Players = game:GetService("Players")
local Uzi = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Uzi)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 0, 0))
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

function object:_Init() end

return object