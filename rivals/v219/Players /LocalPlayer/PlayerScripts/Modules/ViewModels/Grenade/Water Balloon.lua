local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Grenade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grenade)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc.WaterBalloonEffect.Attachment
local object = setmetatable({}, Grenade)
object.__index = object

function object.new(...)
	local self = setmetatable(Grenade.new(...), object)
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
	Utility:CreateSound("rbxassetid://17812496122", 1, 1.5 + 0.25 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 8)
		end
	end

	clone.PointLight.Range = p * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object