local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ElixirExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
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
	Utility:CreateSound("rbxassetid://95384128224111", 1, 1 + 0.25 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://104637136404553", 0.75, 1.5 + 0.5 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://139202431534769", 0.75, 1 + 0.25 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 4)
		end
	end

	clone.PointLight.Range = p * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object