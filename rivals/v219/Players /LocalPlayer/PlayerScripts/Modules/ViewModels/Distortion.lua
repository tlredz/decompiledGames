local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local distortionExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("DistortionExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(0, 255, 149))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(_, position, p, p2)
	task.delay(math.random() * 0.2, function()
		local clone = (p2 or distortionExplosionParticles):Clone()
		clone.CFrame = CFrame.new(position)
		clone.Parent = workspace
		BetterDebris:AddItem(clone, 5)
		Utility:CreateSound("rbxassetid://97822830667649", 0.375, 0.75 + 1.25 * math.random(), clone, true, 10)

		for _, emitter in pairs(clone.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				Utility:ScaleParticleEmitter(emitter, p / 4)
			end
		end

		Utility:PlayParticles(clone.Attachment)
	end)
end

function object:_Init() end

return object