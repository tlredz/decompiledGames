local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local BaseSatchel = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSatchel)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("MoneyExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, BaseSatchel)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSatchel.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 0.75, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://84305904579250", 0.75, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://136485588193503", 0.75, 1 + 0.1 * math.random(), part, true, 5)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 5)
		end
	end

	clone.PointLight.Range = p * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object