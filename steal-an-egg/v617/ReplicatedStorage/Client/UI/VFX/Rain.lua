local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)
local ParticleStage = require(script.Parent.ParticleStage)
local Spread = require(ReplicatedStorage.Shared.Utils.Spread)

local function fade()
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(0.8, 0, 0),
		NumberSequenceKeypoint.new(1, 1, 0)
	})
end

local v = {
	Drag = -3.5,
	EmissionDirection = Enum.NormalId.Top,
	Enabled = false,
	Lifetime = NumberRange.new(1, 2),
	LightInfluence = 1,
	LockedToPart = true,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	Rate = 70,
	RotSpeed = NumberRange.new(-360, 360),
	Rotation = NumberRange.new(-45, 45),
	ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
	Size = NumberSequence.new(0.25),
	Speed = NumberRange.new(-7, -3),
	SpreadAngle = Vector2.new(0, 15),
	Squash = NumberSequence.new(0),
	Transparency = fade(),
	ZOffset = 1
}
local max = v.Lifetime.Max
local random = Random.new()

local function orDefault(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local function resolveTuning(data)
	local scale = data.Scale or {}
	local rate = v.Rate
	local rate2 = scale.Rate
	local v3 = rate * (rate2 == nil and 1 or rate2) * ParticleStage.QualityBudget()
	local seconds = data.Seconds
	local v4 = {
		seconds = seconds == nil and 2.5 or seconds,
		dropsPerSheet = v3 / #data.Sheets,
		speed = 0,
		size = 0,
		loudness = 0
	}
	local speed = scale.Speed
	v4.speed = speed == nil and 1 or speed
	local size = scale.Size
	v4.size = size == nil and 1 or size
	local volume = scale.Volume
	v4.loudness = volume == nil and 1 or volume
	return v4
end

local function sheetOverrides(data, p)
	local speed = v.Speed
	local v3 = {
		Rate = p.dropsPerSheet,
		Speed = NumberRange.new(speed.Min * p.speed, speed.Max * p.speed),
		Texture = data.Texture,
		ZOffset = v.ZOffset + random:NextNumber(-0.06, 0.06)
	}

	if data.Glow ~= nil then
		v3.LightEmission = data.Glow
	end

	if data.SizeMultiplier ~= nil then
		v3.Size = ParticleStage.ScaleSequence(v.Size, data.SizeMultiplier)
	end

	return v3
end

local function buildSheet(p, p2)
	local emitter = ParticleStage.Emitter(v, (sheetOverrides(p, p2)))

	if p2.size ~= 1 then
		ParticleStage.Scale(emitter, p2.size)
	end

	return emitter
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAmbience(ambience, loudness: number)
	Audio.Play(ambience.Sounds, script, {
		PlaybackSpeed = ambience.PlaybackSpeed,
		Volume = Spread.Scale(ambience.Volume, loudness)
	})
end

return table.freeze({
	Fall = function(p)
		local v3

		if type(p) == "table" then
			v3 = type(p.Sheets) == "table"
		else
			v3 = false
		end

		assert(v3, "a rain recipe needs a Sheets list")
		assert(#p.Sheets > 0, "a rain recipe needs at least one sheet")
		local tuning = resolveTuning(p)
		local v4 = ParticleStage.new(9, 1.5)
		local emitters = table.create(#p.Sheets)

		for k, sheet in p.Sheets do
			local emitter = ParticleStage.Emitter(v, (sheetOverrides(sheet, tuning)))

			if tuning.size ~= 1 then
				ParticleStage.Scale(emitter, tuning.size)
			end

			v4:Adopt(emitter)
			emitters[k] = emitter
		end

		local ambience = p.Ambience

		if ambience ~= nil and tuning.loudness > 0 then
			playAmbience(ambience, tuning.loudness) -- equivalent call inferred; original call site unknown
		end

		ParticleStage.SetEnabled(emitters, true)
		task.delay(tuning.seconds, ParticleStage.SetEnabled, emitters, false)
		task.delay(tuning.seconds + max, function()
			v4:Dispose()
		end)
	end
})