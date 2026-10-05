local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Permafrost = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Permafrost)
local temporalRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("TemporalRayExplosionEffect")
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 119, 0))
local object = setmetatable({}, Permafrost)
object.__index = object

function object.new(...)
	local self = setmetatable(Permafrost.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(_, position, p)
	local clone = temporalRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://18431054727", 0.75, 1 + 0.2 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 4)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_Init() end

return object