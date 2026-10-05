local Players = game:GetService("Players")
local Distortion = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Distortion)
local sleighstortionExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("SleighstortionExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 208, 39))
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
	Distortion.ExplosionEffect(p, p2, p3, sleighstortionExplosionParticles)
end

function object:_Init() end

return object