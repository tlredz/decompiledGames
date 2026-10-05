local HauntedGalaConfig = {
	FORCE_VALUE_NAME = "ForceHauntedGala",
	CARD_MODIFIER_NAME = "HauntedGala",
	ACTIVE_ATTRIBUTE = "HauntedGalaActive",
	MODE_ATTRIBUTE = "HauntedGalaMode",
	SCRIPT_NAME = "HauntedGala",
	DEFAULT_MODE = "HauntedGlow",
	MAX_CHANCE = 30,
	MAX_CHANCE_REDUCED = 25,
	REDUCTION_CARD_NAME = "PartyCrashers"
}

function HauntedGalaConfig.GetMaxChance()
	local info = workspace:FindFirstChild("Info")
	local cardModifiers = info and info:FindFirstChild("CardModifiers")

	if cardModifiers and cardModifiers:FindFirstChild(HauntedGalaConfig.REDUCTION_CARD_NAME) then
		return HauntedGalaConfig.MAX_CHANCE_REDUCED
	end

	return HauntedGalaConfig.MAX_CHANCE
end

HauntedGalaConfig.INTRO_MUSIC = {
	SoundId = "rbxassetid://120456598834473",
	Seconds = 3.6,
	Volume = 0.7,
	SnapTail = 0.4,
	MaxCeremonySeconds = 6,
	LENGTH_ATTRIBUTE = "HauntedGalaIntroSeconds"
}

function HauntedGalaConfig.MaskCeremonySeconds()
	local INTRO_MUSIC = HauntedGalaConfig.INTRO_MUSIC
	local info = workspace:FindFirstChild("Info")
	local attribute = info and tonumber(info:GetAttribute(INTRO_MUSIC.LENGTH_ATTRIBUTE))

	if not (attribute and attribute > 0 and attribute) then
		attribute = tonumber(INTRO_MUSIC.Seconds) or 0
	end

	return (math.clamp(
		attribute - (tonumber(INTRO_MUSIC.SnapTail) or 0),
		1.5,
		tonumber(INTRO_MUSIC.MaxCeremonySeconds) or 6
	))
end

HauntedGalaConfig.MODES = {
	{
		id = "HauntedGlow",
		label = "Haunted Glow"
	},
	{
		id = "MoonlightFog",
		label = "Moonlight Fog"
	}
}
HauntedGalaConfig.VISUALS = {
	HauntedGlow = {
		transitionTime = 2,
		fogRollInTime = 6,
		ambient = Color3.fromRGB(75, 28, 25),
		outdoorAmbient = Color3.fromRGB(100, 63, 20),
		brightness = 0.6,
		fogColor = Color3.fromRGB(100, 51, 12),
		fogEnd = 120,
		atmosphereDensity = 0.6,
		atmosphereColor = Color3.fromRGB(255, 212, 175),
		atmosphereHaze = 2.5,
		colorTint = Color3.fromRGB(255, 178, 89),
		colorSaturation = -0.35,
		colorContrast = 0.05,
		colorBrightness = -0.03,
		bloomIntensity = 0.25,
		bloomSize = 40,
		bloomThreshold = 1.8,
		lightColor = Color3.fromRGB(255, 205, 160),
		lightBrightnessScale = 0.55,
		cameraOffset = CFrame.new(0, 0, -12),
		groundFogHeight = 0,
		cameraParticlesEnabled = false
	},
	MoonlightFog = {
		transitionTime = 2,
		fogRollInTime = 6,
		ambient = Color3.fromRGB(35, 45, 75),
		outdoorAmbient = Color3.fromRGB(50, 65, 100),
		brightness = 0.6,
		fogColor = Color3.fromRGB(110, 135, 185),
		fogEnd = 120,
		atmosphereDensity = 0.6,
		atmosphereColor = Color3.fromRGB(150, 175, 225),
		atmosphereHaze = 2.5,
		colorTint = Color3.fromRGB(187, 246, 255),
		colorSaturation = -0.35,
		colorContrast = 0.05,
		colorBrightness = -0.03,
		bloomIntensity = 0.25,
		bloomSize = 40,
		bloomThreshold = 1.8,
		lightColor = Color3.fromRGB(150, 180, 255),
		lightBrightnessScale = 0.55,
		cameraOffset = CFrame.new(0, 0, -14),
		groundFogHeight = 0,
		clouds = {
			enabled = false,
			cloudCount = 3,
			offsetBelowCeiling = 5,
			sweepDistance = 300,
			minSweepFraction = 0.6,
			sweepSpeed = 1,
			spacing = 10,
			placementAttempts = 30,
			retryDelay = 2
		},
		cloudParts = {
			enabled = false,
			offsetBelowCeiling = 5,
			heightJitter = 5,
			spawnInterval = 0.4,
			maxActive = 40,
			fadeInTime = 3,
			holdTime = 4,
			fadeOutTime = 3,
			driftSpeed = 2,
			flipUpsideDown = true,
			sizeStartScale = 0.9,
			sizeEndScale = 1.1
		},
		cameraParticles = {
			texture = "rbxasset://textures/particles/smoke_main.dds",
			color = ColorSequence.new(Color3.fromRGB(190, 210, 255)),
			rate = 3,
			lifetime = NumberRange.new(4, 6),
			size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 8) }),
			transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 0.85),
				NumberSequenceKeypoint.new(1, 1)
			}),
			speed = NumberRange.new(0.2, 0.5),
			lightEmission = 0,
			boxSize = vector.create(30, 16, 1)
		}
	}
}

function HauntedGalaConfig.IsValidMode(value)
	return type(value) == "string" and HauntedGalaConfig.VISUALS[value] ~= nil
end

function HauntedGalaConfig.ResolveMode(p)
	if HauntedGalaConfig.IsValidMode(p) then
		return p
	end

	return HauntedGalaConfig.DEFAULT_MODE
end

function HauntedGalaConfig.GetModeLabel(p)
	for _, v in ipairs(HauntedGalaConfig.MODES) do
		if v.id == p then
			return v.label
		end
	end

	return (tostring(p))
end

return HauntedGalaConfig