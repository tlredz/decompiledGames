local Players = game:GetService("Players")
local Distortion = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Distortion)
local bubbleDistortionExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("BubbleDistortionExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(155, 217, 255))
local object = setmetatable({}, Distortion)
object.__index = object

function object.new(...)
	local self = setmetatable(Distortion.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(p, p2, p3)
	Distortion.ExplosionEffect(p, p2, p3, bubbleDistortionExplosionParticles)
end

function object:_Init() end

return object