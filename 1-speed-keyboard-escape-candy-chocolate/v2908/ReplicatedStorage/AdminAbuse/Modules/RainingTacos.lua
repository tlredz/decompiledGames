local createVector = vector.create
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local Spotlight = require(ReplicatedStorage.Utilities.Events.Spotlight)
local ParticleZone = require(ReplicatedStorage.Utilities.Events.ParticleZone)
local v = Spotlight.new({
	colorSpeed = 0.18,
	cameraOffset = CFrame.new(0, 20, -50),
	range = 30,
	speed = 1.5,
	ccSpeed = 0.072
})
local v2 = PartyEvent.new({
	Sounds = { "rbxassetid://142376088" }
})

function v2.OnStart(_, p, _, _, p2)
	local janitor = p.janitor
	local cc = janitor:Add(Instance.new("ColorCorrectionEffect"))
	cc.Name = "RainingTacosCC"
	cc.Brightness = 0.04
	cc.Contrast = 0.12
	cc.Saturation = 0.35
	cc.TintColor = Color3.fromRGB(255, 255, 255)
	cc.Parent = Lighting
	p._cc = cc
	local v4 = janitor:Add(Instance.new("BloomEffect"))
	v4.Name = "RainingTacosBloom"
	v4.Intensity = 0.55
	v4.Size = 20
	v4.Threshold = 0.88
	v4.Parent = Lighting
	v:setup(p, p2, janitor)
	local tacoZone = ParticleZone.new({
		diameter = 50
	})
	tacoZone:setup(janitor, CFrame.new(p2.CFrame.Position))
	p._tacoZone = tacoZone
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://99411353334255"
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.85, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(
			1,
			1.8
		) })
	particleEmitter.LightEmission = 0.1
	particleEmitter.LightInfluence = 0.9
	particleEmitter.Speed = NumberRange.new(8, 16)
	particleEmitter.SpreadAngle = Vector2.new(30, 30)
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.Acceleration = createVector(0, -20, 0)
	particleEmitter.Lifetime = NumberRange.new(2, 3.5)
	particleEmitter.Rate = 25
	particleEmitter.LockedToPart = true
	particleEmitter.RotSpeed = NumberRange.new(-200, 200)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Parent = tacoZone.part
end

function v2.OnRender(_, p, p2, _, _, p3)
	v:update(p, p2, p3)

	if p._tacoZone then
		p._tacoZone:update(p3.CFrame.Position)
	end
end

function v2.OnStop(_, _) end

return v2