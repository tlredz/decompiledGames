local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local BaseRPG = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRPG)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("CupcakeExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, BaseRPG)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRPG.new(...), object)
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
	Utility:CreateSound("rbxassetid://13455969017", 0.5, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://121017531909847", 1.25, 0.9 + 0.2 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 16)
		end
	end

	clone.PointLight.Range = p * 2
	clone.Parent = part
	Utility:PlayParticles(clone)
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart1"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart2"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart3"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart4"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart5"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart6"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("MeshPart7"))
end

return object