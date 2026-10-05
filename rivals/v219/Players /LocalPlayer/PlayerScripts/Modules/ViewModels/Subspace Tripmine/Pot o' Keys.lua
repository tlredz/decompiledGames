local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("PotoKeysExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, position)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 1, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://127191726448786", 1, 0.9 + 0.2 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p.ClientItem.Info.ExplosionRadius / 6)
		end
	end

	clone.PointLight.Range = p.ClientItem.Info.ExplosionRadius * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object