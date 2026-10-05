local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FreezeRay = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Freeze Ray"])
local spiderRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("SpiderRayExplosionEffect")
local object = setmetatable({}, FreezeRay)
object.__index = object

function object.new(...)
	local self = setmetatable(FreezeRay.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local clone = spiderRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://97679859406914", 0.75, 1 + 0.2 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 8)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_Init() end

return object