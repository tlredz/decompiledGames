local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local GravityManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GravityManager"))
local ParticleZone = require(ReplicatedStorage.Utilities.Events.ParticleZone)
local LightingSnapshot = require(ReplicatedStorage.Utilities.Events.LightingSnapshot)
local v = PartyEvent.new({
	Sounds = { "rbxassetid://92493694084741" }
})

function v.OnStart(_, p, _, parent, p2)
	local janitor = p.janitor
	GravityManager.set("Galaxy", 20, 10)
	LightingSnapshot.acquireShared()
	LightingSnapshot.capture({
		"ClockTime",
		"Brightness",
		"Ambient",
		"OutdoorAmbient"
	}):apply({
		ClockTime = 0,
		Brightness = 10,
		Ambient = Color3.new(1, 1, 1),
		OutdoorAmbient = Color3.new(1, 1, 1)
	})
	local v2 = janitor:Add(Instance.new("ColorCorrectionEffect"))
	v2.Name = "GalaxyColorCorrection"
	v2.Brightness = -0.3
	v2.Contrast = 0.12
	v2.Saturation = 0.18
	v2.TintColor = Color3.fromRGB(180, 150, 255)
	v2.Parent = Lighting
	local galaxyZone = ParticleZone.new({
		diameter = 50
	})
	galaxyZone:setup(janitor, CFrame.new(p2.CFrame.Position))
	p.galaxyZone = galaxyZone
	local parent2 = janitor:Add(Instance.new("Attachment"))
	parent2.Name = "GalaxyStars"
	parent2.Parent = parent
	local v5 = janitor:Add(Instance.new("PointLight"))
	v5.Color = Color3.fromRGB(180, 140, 255)
	v5.Brightness = 3
	v5.Range = 54
	v5.Parent = parent2
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://91897496727346"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(210, 190, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 90, 255))
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(0.5, 1.6),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Speed = NumberRange.new(0.5, 3)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Lifetime = NumberRange.new(2.5, 5)
	particleEmitter.Rate = 40
	particleEmitter.LockedToPart = true
	particleEmitter.RotSpeed = NumberRange.new(-90, 90)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.Parent = galaxyZone.part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxassetid://243660364"
	particleEmitter2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 255))
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.4),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	particleEmitter2.LightEmission = 1
	particleEmitter2.LightInfluence = 0
	particleEmitter2.Speed = NumberRange.new(0.3, 2)
	particleEmitter2.SpreadAngle = Vector2.new(180, 180)
	particleEmitter2.Lifetime = NumberRange.new(2, 4)
	particleEmitter2.Rate = 28
	particleEmitter2.LockedToPart = true
	particleEmitter2.RotSpeed = NumberRange.new(-60, 60)
	particleEmitter2.Rotation = NumberRange.new(0, 360)
	particleEmitter2.Parent = galaxyZone.part
end

function v.OnRender(_, p, _, _, _, p2)
	if p.galaxyZone then
		p.galaxyZone:update(p2.CFrame.Position)
	end
end

function v.OnStop(_, _)
	GravityManager.release("Galaxy")
	LightingSnapshot.releaseShared()
end

return v