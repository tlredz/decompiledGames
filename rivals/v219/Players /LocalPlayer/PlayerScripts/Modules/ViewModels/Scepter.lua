local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ScepterExplosionParticles"):WaitForChild("Attachment")
local attachment2 = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ScepterTransformParticles"):WaitForChild("Attachment")
local attachment3 = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ScepterCastParticles"):WaitForChild("Attachment")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self._cast_attachment = self.ItemModel:FindFirstChild("_scepter_cast", true)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.CanTouch = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://104637136404553", 1, 2 + 0.5 * math.random(), part, true, 10)
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

function object:PlayCastParticles(position, p2)
	local parent = self._cast_attachment

	if position then
		parent = Instance.new("Part")
		parent.CanCollide = false
		parent.CanQuery = false
		parent.CanTouch = false
		parent.Anchored = true
		parent.Transparency = 1
		parent.CFrame = CFrame.new(position)
		parent.Parent = workspace
		BetterDebris:AddItem(parent, 5)
	end

	local clone = attachment3:Clone()
	clone.Parent = parent
	BetterDebris:AddItem(clone, 5)

	if p2 then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				Utility:ScaleParticleEmitter(emitter, p2)
			end
		end
	end

	Utility:PlayParticles(clone)
end

function object.TransformProjectile(_, p, p2)
	if not (p and p2) then
		return
	end

	Utility:CreateSound("rbxassetid://81429998577064", 1, 1.5 + 0.5 * math.random(), p, true, 10)
	p2.Part.Normal:Destroy()

	for _, effect in pairs(p2.Part.Transformed:GetDescendants()) do
		if effect:IsA("Trail") or effect:IsA("ParticleEmitter") then
			effect.Enabled = true
		end
	end

	local clone = attachment2:Clone()
	clone.Parent = p2.Part
	Utility:PlayParticles(clone)
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileShot:Connect(function()
			self:PlayCastParticles()
		end)
	end)
end

return object