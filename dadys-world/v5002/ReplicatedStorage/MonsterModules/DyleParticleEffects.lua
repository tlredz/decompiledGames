local createVector = vector.create
local DyleParticleEffects = {}
DyleParticleEffects.__index = DyleParticleEffects

function DyleParticleEffects.new(character, config)
	local self = setmetatable({}, DyleParticleEffects)
	self.character = character
	self.config = config
	self.particles = {}
	local DyleMonster = require(game.ReplicatedStorage.MonsterData.DyleMonster)

	if not DyleMonster.ParticleEffectsEnabled then
		return nil
	end

	self.dripRate = DyleMonster.ParticleDripRate or 20
	self.trailDensity = DyleMonster.ParticleTrailDensity or 30
	self.gooIntensity = DyleMonster.ParticleGooIntensity or 1
	self.enableDrips = DyleMonster.EnableDripParticles ~= false
	self.enableTrail = DyleMonster.EnableTrailParticles ~= false
	self.enableAmbient = DyleMonster.EnableAmbientParticles ~= false
	self:createParticleEffects()
	self:startDynamicEffects()
	return self
end

function DyleParticleEffects:createParticleEffects()
	local humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
	local v = {
		{
			name = "HeadAttachment",
			parent = self.character:WaitForChild("Head"),
			position = createVector(0, 0.5, 0)
		},
		{
			name = "BodyAttachment",
			parent = humanoidRootPart,
			position = createVector(0, 0, 0)
		},
		{
			name = "TrailAttachment1",
			parent = humanoidRootPart,
			position = createVector(0, -2, 0)
		},
		{
			name = "TrailAttachment2",
			parent = humanoidRootPart,
			position = createVector(0, -2, -1)
		}
	}

	for _, v2 in pairs(v) do
		local attachment = Instance.new("Attachment")
		attachment.Name = v2.name
		attachment.Position = v2.position
		attachment.Parent = v2.parent
		self[v2.name] = attachment
	end

	if self.enableDrips then
		self:createDripParticles()
	end

	if self.enableTrail then
		self:createTrailEffect()
	end

	if self.enableAmbient then
		self:createAmbientParticles()
	end
end

function DyleParticleEffects:createDripParticles()
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "GooDrops"
	particleEmitter.Parent = self.BodyAttachment
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 10)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
	particleEmitter.Rate = self.dripRate * self.gooIntensity
	particleEmitter.Lifetime = NumberRange.new(1, 2)
	particleEmitter.Speed = NumberRange.new(2, 5)
	particleEmitter.VelocityInheritance = 0.2
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.SpreadAngle = Vector2.new(10, 10)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0.1)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.7, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Acceleration = createVector(0, -10, 0)
	particleEmitter.Drag = 0.5
	table.insert(self.particles, particleEmitter)
end

function DyleParticleEffects:createTrailEffect()
	local trail = Instance.new("Trail")
	trail.Name = "GooTrail"
	trail.Parent = self.character
	trail.Attachment0 = self.TrailAttachment1
	trail.Attachment1 = self.TrailAttachment2
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 1.5
	trail.MinLength = 0.1
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	trail.FaceCamera = true
	trail.Texture = "rbxasset://textures/ui/LuaChat/icons/ic-gift.png"
	trail.TextureMode = Enum.TextureMode.Stretch
	trail.TextureLength = 2
	self.trail = trail
end

function DyleParticleEffects:createAmbientParticles()
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "AmbientGoo"
	particleEmitter.Parent = self.HeadAttachment
	particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	particleEmitter.Rate = 5 * self.gooIntensity
	particleEmitter.Lifetime = NumberRange.new(2, 3)
	particleEmitter.Speed = NumberRange.new(0.5, 1)
	particleEmitter.VelocityInheritance = 0.5
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1.5),
		NumberSequenceKeypoint.new(1, 2)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.7),
		NumberSequenceKeypoint.new(0.8, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-60, 60)
	table.insert(self.particles, particleEmitter)
end

function DyleParticleEffects:startDynamicEffects()
	local RunService = game:GetService("RunService")
	self.connection = RunService.Heartbeat:Connect(function()
		if not self.character.Parent then
			return
		end

		local dyleSpeedPercent = self.character:GetAttribute("DyleSpeedPercent") or 0
		self:updateEffectsForSpeed(dyleSpeedPercent)
	end)
end

function DyleParticleEffects:updateEffectsForSpeed(p)
	local DyleMonster = require(game.ReplicatedStorage.MonsterData.DyleMonster)
	local v = 1 + p * ((DyleMonster.ParticleSpeedMultiplier or 2) - 1)

	for _, particle in pairs(self.particles) do
		if particle.Name == "GooDrops" then
			particle.Rate = self.dripRate * self.gooIntensity * v
			particle.Speed = NumberRange.new(2 * v, 5 * v)
		elseif particle.Name == "AmbientGoo" then
			particle.Rate = 5 * self.gooIntensity * v
			particle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5 * v),
				NumberSequenceKeypoint.new(0.5, 1.5 * v),
				NumberSequenceKeypoint.new(1, 2 * v)
			})
		end
	end

	if self.trail then
		self.trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5 * v),
			NumberSequenceKeypoint.new(0.5, 1 * v),
			NumberSequenceKeypoint.new(1, 0.2)
		})
		local v2 = p * 0.2
		self.trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, (math.max(0, 0.3 - v2))),
			NumberSequenceKeypoint.new(0.5, 0.5 - v2 / 2),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end

function DyleParticleEffects:destroy()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	for _, particle in pairs(self.particles) do
		particle:Destroy()
	end

	if self.trail then
		self.trail:Destroy()
	end

	for _, v in pairs({
		"HeadAttachment",
		"BodyAttachment",
		"TrailAttachment1",
		"TrailAttachment2"
	}) do
		if self[v] then
			self[v]:Destroy()
		end
	end
end

return DyleParticleEffects