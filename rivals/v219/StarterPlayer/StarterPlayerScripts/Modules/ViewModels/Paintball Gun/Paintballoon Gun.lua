local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PaintballGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("BalloonExplosionEffect"):WaitForChild("Attachment")
local v = {
	ColorSequence.new(Color3.fromRGB(61, 90, 255)),
	ColorSequence.new(Color3.fromRGB(88, 255, 62)),
	ColorSequence.new(Color3.fromRGB(255, 232, 57))
}
local object = setmetatable({}, PaintballGun)
object.__index = object

function object.new(...)
	local self = setmetatable(PaintballGun.new(...), object)
	self:_Init()
	return self
end

function object.CustomImpactMarker(_, parent)
	local color = v[math.random(#v)]
	local clone = attachment:Clone()
	clone.flash.Color = color
	clone.impact1.Color = color
	clone.impact2.Color = color
	clone.specs2Balloon.Color = color
	clone.specs2Balloon2.Color = color
	clone.Parent = parent

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, 0.16666666666666666)
		end
	end

	Utility:PlayParticles(clone)
end

function object:_Init() end

return object