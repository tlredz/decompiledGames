return {
	ENABLED = false,
	POLLINATED_DURATION = 10,
	FLOWER_COOLDOWN = 3,
	FLOWER_TAG = "PollenFlower",
	TWISTED_TRAILS_ENABLED = true,
	SELF_TRAIL_ALLOWED = true,
	SELF_TRAIL_COOLDOWN = 5,
	SELF_COMBO_MIN_AGE = 2,
	TRAIL_WIDTH = 4,
	TRAIL_HEIGHT = 6,
	MERGE_ANGLE_THRESHOLD = 8,
	MAX_MERGE_LENGTH = 18,
	MIN_MOVE_DISTANCE = 0.8,
	TRAIL_SEGMENT_LIFETIME = 10,
	MAX_SEGMENTS_PER_PLAYER = 40,
	EFFECT_COOLDOWN = 3.5,
	COMBO_EFFECT_SOURCE = "PollenCombo",
	TRAIL_SPEED_MULTIPLIER = 1.08,
	TRAIL_BOOST_DURATION = 6,
	TRAIL_STAMINA_REGEN_MULTIPLIER = 1.15,
	BASE_COMBO_MULTIPLIER = 1.1,
	BASE_COMBO_DURATION = 12,
	COMBO_COOLDOWN = 3,
	SELF_COMBO_COOLDOWN = 0.5,
	COMBO_MULTIPLIER_PER_EXTRA = 0.05,
	COMBO_DURATION_PER_EXTRA = 5,
	MAX_COMBO_MULTIPLIER = 1.25,
	MAX_COMBO_DURATION = 25,
	CUBE_SIZE_PER_EXTRA = 0.15,
	CUBE_MAX_SIZE_SCALE = 2,
	CUBE_GLOW_PER_EXTRA = 1.5,
	CUBE_CHARGE_DURATION = 1.5,
	CUBE_CHARGE_SIZE_START = 0.3,
	TRAIL_PAIR_CUBE_COOLDOWN = 8,
	NOTIFY_CONTRIBUTORS = true,
	TRAIL_OWNER_SPEED_MULTIPLIER = 1.05,
	TRAIL_OWNER_SOURCE = "PollenTrailOwner",
	CUBE_CREATE_MULTIPLIER = 1.08,
	CUBE_CREATE_DURATION = 4,
	CUBE_CREATE_SOURCE = "PollenCubeCreate",
	SPEED_FX_FOV_MIN = 2,
	SPEED_FX_FOV_MAX = 10,
	SPEED_FX_BLUR_MIN = 1,
	SPEED_FX_BLUR_MAX = 4,
	SPEED_FX_SATURATION_BOOST = 0.15,
	TWISTED_CORRUPT_MULTIPLIER = 1.15,
	TWISTED_CORRUPT_DURATION = 10,
	TWISTED_TRAIL_SLOW = 0.85,
	TWISTED_TRAIL_DEBUFF_DURATION = 5,
	TWISTED_TRAIL_DEBUFF_SOURCE = "PollenTwistedTrailSlow",
	DEBUFF_FX_FOV_DECREASE = 1.5,
	DEBUFF_FX_SATURATION = -0.1,
	DEBUFF_FX_BRIGHTNESS = -0.02,
	TRAIL_SEGMENT_TAG = "PollenTrailSegment",
	DEFAULT_PRESET = "SpringBreeze",
	OVERLAP_SCAN_INTERVAL = 0.15,
	COMBO_REACTIONS = {
		Bloom = {
			displayName = "Bloom!",
			reactColor = Color3.fromRGB(160, 255, 120),
			stats = {
				{
					stat = "SpeedModifier",
					multiplier = 1.06
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.06
				},
				{
					stat = "BoundarySize",
					multiplier = 1.2
				},
				{
					stat = "StaminaRegenModifier",
					multiplier = 1.5
				}
			},
			heal = 15,
			extendTrail = 0,
			durationBonus = 0
		},
		Haste = {
			displayName = "Haste!",
			reactColor = Color3.fromRGB(255, 200, 80),
			stats = {
				{
					stat = "SpeedModifier",
					multiplier = 1.18
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.18
				},
				{
					stat = "StaminaModifier",
					multiplier = 1.25
				}
			},
			heal = 0,
			extendTrail = 0,
			durationBonus = 0
		},
		Endure = {
			displayName = "Endure!",
			reactColor = Color3.fromRGB(180, 140, 255),
			stats = {
				{
					stat = "BoundarySize",
					multiplier = 1.3
				},
				{
					stat = "StealthModifier",
					multiplier = 0.8
				},
				{
					stat = "DecodeSpeedModifier",
					multiplier = 1.2
				},
				{
					stat = "SpeedModifier",
					multiplier = 1.04
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.04
				}
			},
			heal = 0,
			extendTrail = 0,
			durationBonus = 6
		},
		Harmony = {
			displayName = "Harmony!",
			reactColor = Color3.fromRGB(255, 255, 180),
			stats = {
				{
					stat = "SpeedModifier",
					multiplier = 1.1
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.1
				},
				{
					stat = "BoundarySize",
					multiplier = 1.1
				},
				{
					stat = "StaminaRegenModifier",
					multiplier = 1.2
				}
			},
			heal = 0,
			extendTrail = 6,
			durationBonus = 0
		},
		FairyLoop = {
			displayName = "Fairy Loop!",
			reactColor = Color3.fromRGB(255, 240, 200),
			stats = {
				{
					stat = "SpeedModifier",
					multiplier = 1.06
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.06
				},
				{
					stat = "StaminaRegenModifier",
					multiplier = 1.15
				}
			},
			heal = 0,
			extendTrail = 4,
			durationBonus = 0
		},
		MysteryMix = {
			displayName = "Mystery Mix!",
			reactColor = Color3.fromRGB(220, 220, 220),
			stats = {
				{
					stat = "SpeedModifier",
					multiplier = 1.08
				},
				{
					stat = "RunSpeedModifier",
					multiplier = 1.08
				},
				{
					stat = "DecodeSpeedModifier",
					multiplier = 1.1
				}
			},
			heal = 0,
			extendTrail = 0,
			durationBonus = 0
		}
	},
	JUICE = {
		ScreenShake = true,
		ScreenShakeIntensity = 0.4,
		ScreenShakeDuration = 0.25,
		DepthOfFieldPulse = true,
		DoFInDistance = 5,
		DoFFarDistance = 50,
		DoFDuration = 0.5,
		SunRaysFlash = true,
		SunRaysIntensity = 0.35,
		SunRaysDuration = 0.6,
		SquashStretch = true,
		SquashAmount = 0.85,
		StretchAmount = 1.15,
		SquashStretchSpeed = 0.15,
		FootstepSparkles = true,
		FootstepRate = 6,
		HighlightFlash = true,
		HighlightFlashDuration = 0.15,
		TrailBreathing = true,
		TrailBreathSpeed = 2.5,
		TrailBreathAmount = 0.12,
		ComboProximityShift = true,
		ProximityShiftAmount = 0.4,
		GroundGlow = false,
		GroundGlowRadius = 5,
		GroundGlowPulse = true,
		AtmosphereTint = true,
		AtmoTintColor = Color3.fromRGB(255, 240, 200),
		AtmoTintDuration = 0.8,
		CubeIdleBob = true,
		CubeBobHeight = 0.6,
		CubeBobSpeed = 1.8,
		CubeRotateSpeed = 25,
		SpringTimerBar = true,
		SpringDamping = 0.6,
		SpringFrequency = 8,
		NumberPop = true,
		NumberPopDuration = 1.5,
		NumberPopRise = 40
	}
}