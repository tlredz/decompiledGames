local Players = game:GetService("Players")
local Gunblade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Gunblade)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255))
local object = setmetatable({}, Gunblade)
object.__index = object

function object.new(...)
	local self = setmetatable(Gunblade.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object