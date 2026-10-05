local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FreezeRay = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Freeze Ray"])
local gumRayExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("GumRayExplosionEffect")
local object = setmetatable({}, FreezeRay)
object.__index = object

function object.new(...)
	local self = setmetatable(FreezeRay.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local clone = gumRayExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)

	for _ = 1, 4 do
		task.delay(
			0.2 * math.random(),
			Utility.CreateSound,
			Utility,
			"rbxassetid://94915446476512",
			0.5 + 0.25 * math.random(),
			1 + 0.2 * math.random(),
			clone,
			true,
			10
		)
	end

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 6)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:_Init() end

return object