local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Exogun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Exogun)
local repulsorExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("RepulsorExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(55, 218, 255))
local object = setmetatable({}, Exogun)
object.__index = object

function object.new(...)
	local self = setmetatable(Exogun.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(_, position, p)
	local clone = repulsorExplosionParticles:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://17245106793", 0.125, 1 + 0.5 * math.random(), clone, true, 10)
	Utility:CreateSound("rbxassetid://103974521039631", 0.375, 1 + 0.25 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 6)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object.PlayReloadParticles(_) end

function object:_Init()
	self.AnimationPlayed:Connect(function(p2)
		if p2 == "Reload" then
			Utility:PlayParticles(self._reload_attachment.Parent)
		end
	end)
end

return object