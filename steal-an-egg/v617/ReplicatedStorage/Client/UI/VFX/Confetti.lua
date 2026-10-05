local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)
local ParticleStage = require(script.Parent.ParticleStage)
local numberRange = NumberRange.new(0.92, 1.08)
local numberRange2 = NumberRange.new(1.8, 2.2)

local function fade()
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0, 0),
		NumberSequenceKeypoint.new(0.8, 0, 0),
		NumberSequenceKeypoint.new(1, 1, 0)
	})
end

local v = {
	Drag = -0.5,
	EmissionDirection = Enum.NormalId.Top,
	Enabled = false,
	Lifetime = NumberRange.new(3, 5),
	LightInfluence = 1,
	LockedToPart = true,
	Orientation = Enum.ParticleOrientation.VelocityParallel,
	Rate = 15,
	RotSpeed = NumberRange.new(-60, 60),
	Rotation = NumberRange.new(-180, 180),
	ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1, 0.03), NumberSequenceKeypoint.new(1, 0.1, 0.03) }),
	Speed = NumberRange.new(-3, -1.5),
	SpreadAngle = Vector2.new(0, 15),
	Squash = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0, 1), NumberSequenceKeypoint.new(1, 0, 1) }),
	Texture = "rbxassetid://104352847228921",
	Transparency = fade(),
	ZOffset = 2
}
local v2 = {
	Drag = 2.4,
	Speed = NumberRange.new(19, 28)
}
local max = v.Lifetime.Max
local random = Random.new()

local function paintSwatches()
	local colors = table.create(5)

	for i = 1, 5 do
		colors[i] = Color3.fromHSV(((i - 1) * 0.618033988749895 + 0.74) % 1, 0.66, 1)
	end

	return colors
end

local v3 = paintSwatches()

local function orDefault(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local function resolveTuning(data)
	local opening = data.Opening or {}
	local scale = data.Scale or {}
	local seconds = data.Seconds
	local v4 = {
		streamSeconds = seconds == nil and 4.5 or seconds,
		swatches = 0,
		texture = 0,
		pops = 0,
		audible = 0,
		rate = 0,
		size = 0,
		speed = 0,
		loudness = 0
	}
	local palette = data.Palette
	local swatches = v3

	if palette ~= nil then
		swatches = palette
	end

	v4.swatches = swatches
	local texture

	if not (data.Texture == nil or data.Texture == "") then
		texture = data.Texture
	end

	v4.texture = texture
	local pop = opening.Pop
	v4.pops = pop == nil or pop
	local sound = opening.Sound
	v4.audible = sound == nil or sound
	local rate = scale.Rate
	v4.rate = rate == nil and 1 or rate
	local size = scale.Size
	v4.size = size == nil and 1 or size
	local speed = scale.Speed
	v4.speed = speed == nil and 1 or speed
	local volume = scale.Volume
	v4.loudness = volume == nil and 1 or volume
	return v4
end

local function layerOverrides(color: Color3, data, p: number)
	local v4 = data.speed * (1 + random:NextNumber(-0.08, 0.08))
	local speed = v.Speed
	local v5 = {
		Color = ColorSequence.new(color),
		Rate = v.Rate * data.rate * p,
		Speed = NumberRange.new(speed.Min * v4, speed.Max * v4),
		ZOffset = v.ZOffset + random:NextNumber(-0.07, 0.07)
	}

	if data.texture ~= nil then
		v5.Texture = data.texture
	end

	return v5
end

local function buildStreamer(color: Color3, p, p2: number)
	local emitter = ParticleStage.Emitter(v, (layerOverrides(color, p, p2)))

	if p.size ~= 1 then
		ParticleStage.Scale(emitter, p.size)
	end

	return emitter
end

local function throwPop(object, swatch: Color3, tuning, qualityBudget: number)
	local v4 = math.round(tuning.rate * 100 * qualityBudget)

	if v4 < 1 then
		return
	end

	local v5 = layerOverrides(swatch, tuning, qualityBudget)

	for k, v6 in v2 do
		v5[k] = v6
	end

	local emitter = ParticleStage.Emitter(v, v5)

	if tuning.size ~= 1 then
		ParticleStage.Scale(emitter, tuning.size)
	end

	object:Adopt(emitter)
	emitter:Emit(v4)
end

local function ringPop(loudness: number)
	Audio.Play("rbxassetid://135524199765808", script, {
		PlaybackSpeed = random:NextNumber(numberRange.Min, numberRange.Max),
		Volume = random:NextNumber(numberRange2.Min, numberRange2.Max) * loudness
	})
end

return table.freeze({
	Burst = function(options)
		assert(options == nil or type(options) == "table", "a confetti recipe must be a table when given")
		local tuning = resolveTuning(options or {})
		local qualityBudget = ParticleStage.QualityBudget()
		local v4 = ParticleStage.new(5.5, 1.25)
		local emitters = table.create(#tuning.swatches)

		for k, swatch in tuning.swatches do
			local emitter = ParticleStage.Emitter(v, (layerOverrides(swatch, tuning, qualityBudget)))

			if tuning.size ~= 1 then
				ParticleStage.Scale(emitter, tuning.size)
			end

			v4:Adopt(emitter)
			emitters[k] = emitter
		end

		local v5

		if tuning.pops then
			v5 = 0.6

			for _, swatch in tuning.swatches do
				throwPop(v4, swatch, tuning, qualityBudget)
			end

			if tuning.audible and tuning.loudness > 0 then
				ringPop(tuning.loudness)
			end
		else
			v5 = 0
		end

		local v6 = v5 + tuning.streamSeconds
		task.delay(v5, ParticleStage.SetEnabled, emitters, true)
		task.delay(v6, ParticleStage.SetEnabled, emitters, false)
		task.delay(v6 + max, function()
			v4:Dispose()
		end)
	end
})