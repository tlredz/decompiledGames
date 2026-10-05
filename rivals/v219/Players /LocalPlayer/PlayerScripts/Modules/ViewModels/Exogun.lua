local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local exogunExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ExogunExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(131, 255, 117))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._reload_attachment = self.Model:FindFirstChild("_exogun_reload", true)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(_, position, p, p2, _)
	local clone = (p2 or exogunExplosionParticles):Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://17245106793", 0.375, 1 + 0.5 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 8)
		end
	end

	Utility:PlayParticles(clone.Attachment)
end

function object:PlayReloadParticles()
	for _, child in pairs(self._reload_attachment:GetChildren()) do
		child:Emit(20)
	end
end

function object:_Init() end

return object