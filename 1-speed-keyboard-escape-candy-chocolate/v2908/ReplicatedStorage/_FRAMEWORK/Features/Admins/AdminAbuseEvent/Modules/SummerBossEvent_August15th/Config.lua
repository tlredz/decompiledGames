local openingCutsceneAnimations = {
	camera = 75836495254270,
	characterOne = 77224157609429
}
local animations = {}
local endingCutsceneAnimations = {
	camera = 107923381143742,
	characterOne = 124380960876999,
	characterTwo = 108434687208414
}

for _, v4 in openingCutsceneAnimations do
	table.insert(animations, v4)
end

for _, v4 in endingCutsceneAnimations do
	table.insert(animations, v4)
end

table.insert(animations, "rbxassetid://74004467521549")
return {
	sequenceOffset = 20,
	endingCutsceneLeadSeconds = 30,
	endingAttackCooldownSeconds = 10,
	cutsceneFieldOfView = 35,
	cutsceneVerticalOffsetY = -8,
	skipOpeningCutscene = true,
	openingCutsceneAnimations = openingCutsceneAnimations,
	endingCutsceneAnimations = endingCutsceneAnimations,
	idleBossAnimation = "rbxassetid://74004467521549",
	endingCameraOffsetX = -15,
	endingCameraFreezeLeadSeconds = 1,
	bossMusic = 139783453578137,
	beachAmbiance = 4948924204,
	AAFw_AutoPreloadEnabled = false,
	AAFw_AutoPreloadIDs = {
		music = { 4948924204, 139783453578137 },
		animations = animations
	},
	endingMusicCrossfadeSeconds = 10,
	winRingConfigs = {
		{
			radius = 25,
			winMultiplier = 1,
			movementSpeed = 0.5
		},
		{
			radius = 15,
			winMultiplier = 2,
			movementSpeed = 1
		},
		{
			radius = 10,
			winMultiplier = 5,
			movementSpeed = 2
		}
	},
	winRingMovementSeed = 731947,
	winRingFillSeconds = 1,
	winRingDepleteSeconds = 999,
	winRingAwardDivisor = 100,
	attackDelaySecondsByPhase = { 2, 1, 0 },
	attackConfigIndex = 1,
	crabTsunamiSizeXRange = { 50, 120 },
	sharkRainAttackConfigs = {
		{
			dropCount = 30,
			dropIntervalSeconds = 0.125,
			fallHeight = 500,
			fallDurationSeconds = 2,
			impactRadius = 25,
			recoverySeconds = 1,
			damage = 55
		},
		{
			dropCount = 36,
			dropIntervalSeconds = 0.11,
			fallHeight = 500,
			fallDurationSeconds = 1.8,
			impactRadius = 28,
			recoverySeconds = 0.8,
			damage = 60
		},
		{
			dropCount = 44,
			dropIntervalSeconds = 0.09,
			fallHeight = 500,
			fallDurationSeconds = 1.5,
			impactRadius = 30,
			recoverySeconds = 0.5,
			damage = 65
		}
	},
	crabTsunamiAttackConfigs = {
		{
			waveCount = 4,
			waveIntervalSeconds = 0.75,
			growDurationSeconds = 0.6,
			travelDurationSeconds = 3.5,
			shrinkDurationSeconds = 0.6,
			recoverySeconds = 1,
			damage = 40
		},
		{
			waveCount = 5,
			waveIntervalSeconds = 0.65,
			growDurationSeconds = 0.5,
			travelDurationSeconds = 3.2,
			shrinkDurationSeconds = 0.5,
			recoverySeconds = 0.8,
			damage = 45
		},
		{
			waveCount = 6,
			waveIntervalSeconds = 0.55,
			growDurationSeconds = 0.45,
			travelDurationSeconds = 2.9,
			shrinkDurationSeconds = 0.45,
			recoverySeconds = 0.5,
			damage = 50
		}
	},
	sandCastleAttackConfigs = {
		{
			warningDurationSeconds = 3,
			telegraphFlashSeconds = 0.9,
			castleRiseDurationSeconds = 1,
			waterRiseDurationSeconds = 0.75,
			waterActiveDurationSeconds = 3,
			damageTickSeconds = 0.25,
			waterLowerDurationSeconds = 1,
			castleLowerDurationSeconds = 2,
			recoverySeconds = 1,
			damage = 10
		},
		{
			warningDurationSeconds = 2.5,
			telegraphFlashSeconds = 0.8,
			castleRiseDurationSeconds = 0.9,
			waterRiseDurationSeconds = 0.65,
			waterActiveDurationSeconds = 3,
			damageTickSeconds = 0.22,
			waterLowerDurationSeconds = 0.9,
			castleLowerDurationSeconds = 1.7,
			recoverySeconds = 0.8,
			damage = 10
		},
		{
			warningDurationSeconds = 2,
			telegraphFlashSeconds = 0.7,
			castleRiseDurationSeconds = 0.75,
			waterRiseDurationSeconds = 0.55,
			waterActiveDurationSeconds = 3,
			damageTickSeconds = 0.2,
			waterLowerDurationSeconds = 0.75,
			castleLowerDurationSeconds = 1.5,
			recoverySeconds = 0.5,
			damage = 10
		}
	}
}