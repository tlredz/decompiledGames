local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FreezeRay = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Freeze Ray"])
local wrappedFreezeRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("WrappedFreezeRayExplosionEffect")
local object = setmetatable({}, FreezeRay)
object.__index = object

function object.new(...)
	local self = setmetatable(FreezeRay.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local clone = wrappedFreezeRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://18429092842", 0.4, 1 + 0.2 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 4)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_Init() end

return object