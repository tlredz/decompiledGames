local IceSkatingConfig = {
	ENABLED = false,
	STANDALONE_EVENT = false,
	DefaultPhysics = {
		density = 1.5,
		friction = 0.3,
		elasticity = 0.3,
		frictionWeight = 1,
		elasticityWeight = 1
	},
	Presets = {
		Playground = {
			name = "Playground",
			description = "Maximum fun: All cool effects, arm flailing, perfect for casual play!",
			friction = 0.01,
			frictionWeight = 100,
			density = 0.25,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.35,
			icePuddleNudgeForce = 1400,
			icePuddleNudgeDuration = 0.12,
			icePuddleNudgeMultiplierOnIce = 0.5,
			useMomentum = false,
			useVectorForce = false,
			useBodyVelocity = false,
			useNaturalSlide = true,
			useGradualSpeedRamp = true,
			speedRampDuration = 1,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useBlur = false,
			useTilt = true,
			useAnimationSpeedUp = false,
			animationSpeedMultiplier = 1.5,
			useSkatingParticles = true,
			usePanicEffects = true,
			useArmBalancing = false,
			useCrashDetection = false,
			useCircleSkating = true,
			circleSpinForce = 3,
			circleMinSpeed = 5,
			disableSprint = true,
			useBloom = true,
			useSunRays = false,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 82,
			maxTiltDegrees = 20,
			maxCameraBankDegrees = 4,
			abilityBoostSpeed = 55
		},
		Crazy = {
			name = "Crazy Ice",
			description = "High acceleration, long slides, momentum system",
			friction = 0,
			icePuddleNudgeForce = 2000,
			icePuddleNudgeDuration = 0.15,
			icePuddleNudgeMultiplierOnIce = 0.4,
			frictionWeight = 100,
			density = 0.5,
			elasticity = 0.02,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.8,
			useMomentum = true,
			useNaturalSlide = false,
			accelerationRate = 0.8,
			decelerationRate = 0.6,
			maxSpeedMultiplier = 3.5,
			useTrails = false,
			useSounds = false,
			useFOV = false,
			useTilt = false,
			useAnimationSpeedUp = false,
			usePanicAnimation = false,
			usePanicEffects = false,
			useGradualSpeed = false,
			useCrashDetection = false,
			disableSprint = true,
			useBloom = false,
			useSunRays = false,
			useDepthOfField = true,
			useCameraBanking = false,
			useCameraShake = true,
			useCameraBobbing = false,
			maxCameraBankDegrees = 6,
			cameraShakeIntensity = 0.12,
			cameraBobbingIntensity = 0.06,
			cameraBobbingSpeed = 15
		},
		Enhanced = {
			name = "Enhanced Ice (Research Recommended)",
			description = "Momentum + trails + FOV + tilt + sounds",
			friction = 0.02,
			icePuddleNudgeForce = 1800,
			icePuddleNudgeDuration = 0.12,
			icePuddleNudgeMultiplierOnIce = 0.45,
			frictionWeight = 100,
			density = 1.5,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.5,
			useMomentum = true,
			useNaturalSlide = false,
			accelerationRate = 0.7,
			decelerationRate = 0.7,
			maxSpeedMultiplier = 2.5,
			useTrails = true,
			useSounds = true,
			useFOV = true,
			useTilt = true,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.6,
			useSkatingParticles = true,
			usePanicAnimation = false,
			useGradualSpeed = false,
			useCrashDetection = true,
			useArmBalancing = false,
			disableSprint = true,
			useScreenSnow = false,
			useBlueTint = false,
			useBloom = true,
			useSunRays = false,
			useDepthOfField = false,
			trailLifetime = 0.5,
			trailColor = Color3.fromRGB(180, 230, 255),
			baseFOV = 70,
			maxFOV = 85,
			fovTransitionSpeed = 5,
			maxTiltDegrees = 25,
			tiltSpeed = 0.15,
			speedRampDuration = 1,
			speedRampEasing = Enum.EasingStyle.Quad,
			panicDecelerationThreshold = 5,
			panicSpeedThreshold = 8,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			maxCameraBankDegrees = 4,
			cameraShakeIntensity = 0.08,
			cameraBobbingIntensity = 0.04,
			cameraBobbingSpeed = 12,
			abilityBoostSpeed = 60
		},
		Polished = {
			name = "Polished Ice",
			description = "Frictionless slide + sparkly trails + FOV/tilt",
			friction = 0,
			icePuddleNudgeForce = 1500,
			icePuddleNudgeDuration = 0.1,
			icePuddleNudgeMultiplierOnIce = 0.5,
			frictionWeight = 100,
			density = 0.15,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.25,
			useMomentum = false,
			useNaturalSlide = true,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useTilt = true,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.4,
			useSkatingParticles = true,
			usePanicAnimation = false,
			usePanicEffects = true,
			useGradualSpeedRamp = true,
			useCrashDetection = false,
			useArmBalancing = false,
			disableSprint = true,
			useBloom = true,
			useSunRays = true,
			useDepthOfField = false,
			speedRampDuration = 1,
			speedRampEasing = Enum.EasingStyle.Quad,
			trailLifetime = 0.6,
			trailColor = Color3.fromRGB(200, 240, 255),
			baseFOV = 70,
			maxFOV = 80,
			fovTransitionSpeed = 4,
			maxTiltDegrees = 20,
			tiltSpeed = 0.2,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			maxCameraBankDegrees = 3,
			cameraBobbingIntensity = 0.03,
			cameraBobbingSpeed = 10
		},
		VectorForce = {
			name = "VectorForce Driven",
			description = "Physics-based skating using VectorForce (mutually exclusive with Momentum)",
			friction = 0.02,
			icePuddleNudgeForce = 1900,
			icePuddleNudgeDuration = 0.14,
			icePuddleNudgeMultiplierOnIce = 0.4,
			frictionWeight = 100,
			density = 0.7,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.5,
			useVectorForce = true,
			useMomentum = false,
			useNaturalSlide = false,
			accelerationRate = 0,
			decelerationRate = 0,
			maxSpeedMultiplier = 1.5,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useTilt = true,
			useAnimationSpeedUp = false,
			usePanicAnimation = false,
			useGradualSpeedRamp = false,
			useCrashDetection = false,
			disableSprint = true,
			useBloom = false,
			useSunRays = false,
			useDepthOfField = true,
			trailLifetime = 0.6,
			trailColor = Color3.fromRGB(180, 230, 255),
			baseFOV = 70,
			maxFOV = 85,
			fovTransitionSpeed = 5,
			maxTiltDegrees = 20,
			tiltSpeed = 0.15,
			useCameraBanking = false,
			useCameraShake = true,
			useCameraBobbing = false,
			maxCameraBankDegrees = 10,
			cameraShakeIntensity = 0.12,
			cameraBobbingIntensity = 0.07,
			cameraBobbingSpeed = 11
		},
		BodyVelocity = {
			name = "BodyVelocity Driven",
			description = "Community standard BodyVelocity approach with lerp-based acceleration",
			friction = 0.02,
			icePuddleNudgeForce = 1700,
			icePuddleNudgeDuration = 0.12,
			icePuddleNudgeMultiplierOnIce = 0.45,
			frictionWeight = 100,
			density = 0.7,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1,
			useBodyVelocity = true,
			useMomentum = false,
			useVectorForce = false,
			useNaturalSlide = false,
			maxSpeed = 14,
			accelerationFactor = 0.5,
			frictionFactor = 0.8,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useTilt = true,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.5,
			useSkatingParticles = true,
			usePanicAnimation = false,
			usePanicEffects = true,
			useGradualSpeedRamp = false,
			useCrashDetection = false,
			useArmBalancing = false,
			disableSprint = true,
			useBloom = true,
			useSunRays = false,
			useDepthOfField = false,
			trailLifetime = 0.6,
			trailColor = Color3.fromRGB(180, 230, 255),
			baseFOV = 70,
			maxFOV = 85,
			fovTransitionSpeed = 5,
			maxTiltDegrees = 25,
			tiltSpeed = 0.15,
			useCameraBanking = false,
			useCameraShake = true,
			useCameraBobbing = false,
			maxCameraBankDegrees = 9,
			cameraShakeIntensity = 0.15,
			cameraBobbingIntensity = 0.08,
			cameraBobbingSpeed = 12
		},
		CharlieBrown = {
			name = "Charlie Brown",
			description = "Chill and somber: Peaceful skating with nostalgic Christmas melancholy",
			friction = 0.005,
			icePuddleNudgeForce = 1500,
			icePuddleNudgeDuration = 0.1,
			frictionWeight = 100,
			density = 0.3,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.15,
			useMomentum = false,
			useVectorForce = false,
			useBodyVelocity = false,
			useNaturalSlide = true,
			useMomentumTurnResistance = true,
			useGradualSpeedRamp = true,
			speedRampDuration = 1.8,
			baseSkatingSpeed = 26,
			slideDecay = 0.993,
			velocityThreshold = 0.35,
			slideBoost = 1.5,
			accelerationRate = 0.4,
			maxSpeedMultiplier = 1.5,
			turnSmoothing = 0.08,
			driftStrength = 0.025,
			useTrails = true,
			useVelocityBasedTrails = false,
			velocityTrailThreshold = 3,
			useSounds = true,
			useFOV = false,
			useBlur = true,
			maxBlurSize = 4,
			useTilt = false,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.1,
			maxEffectiveSpeed = 40,
			usePanicEffects = false,
			useArmBalancing = false,
			useCrashDetection = false,
			useCircleSkating = false,
			disableSprint = false,
			useScreenSnow = true,
			useBlueTint = true,
			maxExternalBuffFactor = 2,
			useSprintBoost = true,
			sprintSpeedBoost = 8,
			sprintSlideBoostIncrease = 0.5,
			sprintBoostTweenInTime = 0.2,
			sprintBoostTweenOutTime = 0.8,
			sprintDecayBoost = 0.0005,
			sprintVelocityImpulse = 7.5,
			useSprintBlur = false,
			sprintBlurSize = 0,
			useSprintTilt = false,
			sprintTiltDegrees = 0,
			useSprintFOV = true,
			sprintFOVBoost = 8,
			useBloom = false,
			useSunRays = false,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 70,
			maxTiltDegrees = 0,
			maxCameraBankDegrees = 0,
			abilityBoostSpeed = 50,
			twisted = {}
		},
		CharlieBrownTriggerZone = {
			name = "Charlie Brown (Zone Trigger)",
			description = "CharlieBrown skating for zone triggers - no screen overlays",
			friction = 0.005,
			icePuddleNudgeForce = 1500,
			icePuddleNudgeDuration = 0.1,
			frictionWeight = 100,
			density = 0.3,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.15,
			useMomentum = false,
			useVectorForce = false,
			useBodyVelocity = false,
			useNaturalSlide = true,
			useMomentumTurnResistance = false,
			useGradualSpeedRamp = true,
			speedRampDuration = 1.8,
			baseSkatingSpeed = 26,
			slideDecay = 0.993,
			velocityThreshold = 0.35,
			slideBoost = 1.5,
			accelerationRate = 0.4,
			maxSpeedMultiplier = 1.5,
			turnSmoothing = 0.08,
			driftStrength = 0.025,
			useTrails = true,
			useVelocityBasedTrails = false,
			velocityTrailThreshold = 3,
			useSounds = true,
			useFOV = false,
			useBlur = true,
			maxBlurSize = 4,
			useTilt = false,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.1,
			maxEffectiveSpeed = 40,
			usePanicEffects = false,
			useArmBalancing = false,
			useCrashDetection = false,
			useCircleSkating = false,
			disableSprint = false,
			useScreenSnow = false,
			useBlueTint = false,
			maxExternalBuffFactor = 2,
			useSprintBoost = true,
			sprintSpeedBoost = 8,
			sprintSlideBoostIncrease = 0.5,
			sprintBoostTweenInTime = 0.2,
			sprintBoostTweenOutTime = 0.8,
			sprintDecayBoost = 0.0005,
			sprintVelocityImpulse = 7.5,
			useSprintBlur = false,
			sprintBlurSize = 0,
			useSprintTilt = false,
			sprintTiltDegrees = 0,
			useSprintFOV = true,
			sprintFOVBoost = 8,
			useBloom = false,
			useSunRays = false,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 70,
			maxTiltDegrees = 0,
			maxCameraBankDegrees = 0,
			abilityBoostSpeed = 50
		},
		ChillMomentum = {
			name = "Chill Momentum",
			description = "Relaxed momentum-based skating: Smooth, controllable, lower speed",
			friction = 0.03,
			icePuddleNudgeForce = 1300,
			icePuddleNudgeDuration = 0.1,
			icePuddleNudgeMultiplierOnIce = 0.5,
			frictionWeight = 100,
			density = 0.8,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.2,
			useMomentum = true,
			useNaturalSlide = false,
			accelerationRate = 0.4,
			decelerationRate = 0.8,
			maxSpeedMultiplier = 1.8,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useTilt = false,
			useAnimationSpeedUp = false,
			usePanicEffects = false,
			useCrashDetection = false,
			useCircleSkating = true,
			circleSpinForce = 2,
			circleMinSpeed = 5,
			disableSprint = true,
			useBloom = true,
			useSunRays = false,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 78,
			maxTiltDegrees = 0,
			maxCameraBankDegrees = 2
		},
		Custom = {
			name = "Custom Mix",
			description = "User-configurable preset: Modify via admin commands or code",
			friction = 0.01,
			frictionWeight = 100,
			density = 0.25,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.35,
			icePuddleNudgeForce = 1400,
			icePuddleNudgeDuration = 0.12,
			icePuddleNudgeMultiplierOnIce = 0.5,
			useMomentum = false,
			useVectorForce = false,
			useBodyVelocity = false,
			useNaturalSlide = true,
			useGradualSpeedRamp = true,
			speedRampDuration = 1,
			useTrails = true,
			useSounds = false,
			useFOV = true,
			useBlur = false,
			useTilt = true,
			useAnimationSpeedUp = true,
			animationSpeedMultiplier = 1.5,
			useSkatingParticles = true,
			usePanicEffects = true,
			useArmBalancing = true,
			useCrashDetection = false,
			useCircleSkating = true,
			circleSpinForce = 3,
			circleMinSpeed = 5,
			disableSprint = true,
			useBloom = true,
			useSunRays = false,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 82,
			maxTiltDegrees = 20,
			maxCameraBankDegrees = 4,
			abilityBoostSpeed = 55
		},
		SmoothGlide = {
			name = "Smooth Glide",
			description = "Effortless gliding: Low speed, high control, butter-smooth",
			friction = 0.01,
			icePuddleNudgeForce = 1200,
			icePuddleNudgeDuration = 0.1,
			icePuddleNudgeMultiplierOnIce = 0.5,
			frictionWeight = 100,
			density = 0.2,
			elasticity = 0,
			elasticityWeight = 1,
			walkSpeedMultiplier = 1.15,
			useMomentum = false,
			useNaturalSlide = true,
			useGradualSpeedRamp = true,
			speedRampDuration = 1.5,
			useTrails = true,
			useSounds = false,
			useFOV = false,
			useTilt = false,
			useAnimationSpeedUp = false,
			usePanicEffects = false,
			useCrashDetection = false,
			useCircleSkating = true,
			circleSpinForce = 1.5,
			circleMinSpeed = 4,
			disableSprint = true,
			useBloom = true,
			useSunRays = true,
			useDepthOfField = false,
			useCameraBanking = false,
			useCameraShake = false,
			useCameraBobbing = false,
			baseFOV = 70,
			maxFOV = 70,
			maxTiltDegrees = 0,
			maxCameraBankDegrees = 0
		}
	},
	DefaultAntiCheat = {
		ignoreSpeedCheat = true,
		ignorePlayerSpeedCheat = true,
		ignoreTeleportCheat = false,
		ignorePlayerTeleportCheat = false,
		ignoreFlyCheat = false
	},
	AntiCheatOverrides = {
		Playground = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true
		},
		Crazy = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = true
		},
		Enhanced = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = true
		},
		Polished = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true
		},
		VectorForce = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = true
		},
		BodyVelocity = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = true
		},
		CharlieBrown = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = false
		},
		CharlieBrownTriggerZone = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true,
			ignoreFlyCheat = false
		},
		ChillMomentum = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true
		},
		SmoothGlide = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = false,
			ignorePlayerTeleportCheat = false,
			ignoreFlyCheat = false
		},
		Custom = {
			ignoreSpeedCheat = true,
			ignorePlayerSpeedCheat = true,
			ignoreTeleportCheat = true,
			ignorePlayerTeleportCheat = true
		}
	},
	ActivePreset = "Playground"
}

function IceSkatingConfig.GetActive()
	return IceSkatingConfig.Presets[IceSkatingConfig.ActivePreset]
end

function IceSkatingConfig.SetPreset(activePreset)
	if not IceSkatingConfig.Presets[activePreset] then
		warn("[IceSkatingConfig] Preset not found:", activePreset)
		return false
	end

	IceSkatingConfig.ActivePreset = activePreset
	print("[IceSkatingConfig] Switched to preset:", activePreset)
	return true
end

function IceSkatingConfig.GetPresetNames()
	local result = {}

	for k, _ in pairs(IceSkatingConfig.Presets) do
		table.insert(result, k)
	end

	return result
end

IceSkatingConfig.TwistedDefaults = {
	enabled = true,
	friction = 0.005,
	density = 0.3,
	elasticity = 0,
	frictionWeight = 100,
	elasticityWeight = 1,
	speedMultiplier = 1.15,
	slideDecay = 0.993,
	velocityThreshold = 0.35,
	driftAngleThreshold = 45,
	driftMin = 0.005,
	driftMax = 0.02,
	enableFlocking = true,
	flockProfile = "IceSkate",
	particles = true,
	tilt = true,
	maxTiltDegrees = 12
}

function IceSkatingConfig.GetTwisted(p)
	local result = {}

	for k, twistedDefault in pairs(IceSkatingConfig.TwistedDefaults) do
		result[k] = twistedDefault
	end

	local v = p and IceSkatingConfig.Presets[p]
	local twisted = v and v.twisted

	if type(twisted) == "table" then
		for k, v2 in pairs(twisted) do
			result[k] = v2
		end
	end

	return result
end

function IceSkatingConfig.CreateCustomPreset(p, p2)
	IceSkatingConfig.Presets[p] = p2
	print("[IceSkatingConfig] Created custom preset:", p)
end

function IceSkatingConfig.GetAntiCheatSettings(p)
	local result = {}

	for k, v in pairs(IceSkatingConfig.DefaultAntiCheat) do
		result[k] = v
	end

	local antiCheatOverride = IceSkatingConfig.AntiCheatOverrides[p]

	if antiCheatOverride then
		for k, v in pairs(antiCheatOverride) do
			result[k] = v
		end
	end

	return result
end

function IceSkatingConfig.ApplyAntiCheatExceptions(instance, p)
	local antiCheatSettings = IceSkatingConfig.GetAntiCheatSettings(p)

	if antiCheatSettings.ignoreSpeedCheat then
		instance:SetAttribute("KM_SPEED_TEMPORARY_EXCEPTION", true)
	end

	if antiCheatSettings.ignorePlayerSpeedCheat then
		instance:SetAttribute("KM_IGNORE_PLAYER_SPEED_CHEAT", true)
	end

	if antiCheatSettings.ignoreTeleportCheat then
		instance:SetAttribute("KM_TELEPORT_TEMPORARY_EXCEPTION", true)
	end

	if antiCheatSettings.ignorePlayerTeleportCheat then
		instance:SetAttribute("KM_IGNORE_PLAYER_TELEPORT_CHEAT", true)
	end

	if antiCheatSettings.ignoreFlyCheat then
		instance:SetAttribute("KM_IGNORE_PLAYER_FLY_CHEAT", true)
	end
end

function IceSkatingConfig.ClearAntiCheatExceptions(instance)
	instance:SetAttribute("KM_SPEED_TEMPORARY_EXCEPTION", nil)
	instance:SetAttribute("KM_IGNORE_PLAYER_SPEED_CHEAT", nil)
	instance:SetAttribute("KM_TELEPORT_TEMPORARY_EXCEPTION", nil)
	instance:SetAttribute("KM_IGNORE_PLAYER_TELEPORT_CHEAT", nil)
	instance:SetAttribute("KM_IGNORE_PLAYER_FLY_CHEAT", nil)
end

return IceSkatingConfig