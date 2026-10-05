local Players = game:GetService("Players")
local Handgun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Handgun)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 243, 116))
local object = setmetatable({}, Handgun)
object.__index = object

function object.new(...)
	local self = setmetatable(Handgun.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:_Init() end

return object