local openingCutsceneAnimations = {
	camera = 133879446839552,
	player = 124004665691533,
	luckymat = 133142578626176,
	lokii = 86451435049338,
	theMask = 122516845138896,
	chichine = 135472609146097,
	cage = 101629496743305
}
local animations = {}
local endingCutsceneAnimations = {
	camera = 137122657359678,
	player = 85013057224073,
	luckymat = 90746323957012,
	lokii = 78248859271463,
	theMask = 103943383215109,
	chichine = 97007270292460,
	cage = 105690248807208
}

for _, v4 in openingCutsceneAnimations do
	table.insert(animations, v4)
end

for _, v4 in endingCutsceneAnimations do
	table.insert(animations, v4)
end

table.insert(animations, "rbxassetid://74004467521549")
table.insert(animations, "rbxassetid://138045145352450")
return {
	sequenceOffset = 20,
	phase1DurationSeconds = 240,
	phase2DurationSeconds = 180,
	phase3DurationSeconds = 120,
	phase4DurationSeconds = 180,
	endingCutsceneLeadSeconds = 30,
	endingAttackCooldownSeconds = 10,
	endingCutsceneClientStartLeadSeconds = 1.5,
	endingTeardownGraceSeconds = 1.5,
	cutsceneFieldOfView = 35,
	cutsceneVerticalOffsetY = -4,
	openingCutsceneAnimations = openingCutsceneAnimations,
	endingCutsceneAnimations = endingCutsceneAnimations,
	idleBossAnimation = "rbxassetid://74004467521549",
	cloneWalkAnimation = "rbxassetid://138045145352450",
	endingCameraOffsetX = -15,
	endingCameraFreezeLeadSeconds = 1,
	cutsceneStartFadeSeconds = 0.5,
	cutsceneFadeInSeconds = 0.5,
	cutsceneEndFadeSeconds = 0.6,
	credits = {
		{
			username = "EternityReality",
			role = "Animator",
			image = "rbxassetid://135427321913527",
			aspectRatio = 1
		},
		{
			username = "FoeCakes",
			role = "Lead Dev",
			image = "rbxassetid://115052533712186",
			aspectRatio = 1
		},
		{
			username = "X3ll3n",
			role = "Music Composer",
			image = "rbxassetid://111211209789698",
			aspectRatio = 1
		}
	},
	creditsTitle = "Galaxy 1 - End of Chapter",
	creditsFadeSeconds = 0.4,
	creditsHoldSeconds = 6,
	openingDialogue = {
		{
			text = "Finally, it's time..",
			duration = 4
		},
		{
			text = "Chichine's goals are cute, but I want more.",
			duration = 4
		},
		{
			text = "Not a world, a GALAXY.",
			duration = 4
		},
		{
			text = "But I need you, Player.",
			duration = 4
		},
		{
			text = "BREAK THE SPEED OF SOUND",
			duration = 4
		}
	},
	endingDialogue = {
		{
			text = "STOP THIS NOW-",
			duration = 4
		},
		{
			text = "CATCH ME IF U CAN LOLOLOLOL",
			duration = 4
		}
	},
	bossMusic = 81159218250076,
	ambiance = 81159218250076,
	AAFw_AutoPreloadEnabled = false,
	AAFw_AutoPreloadIDs = {
		music = { 81159218250076, 81159218250076 },
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
		}
	},
	winRingMovementSeed = 552017,
	winRingFillSeconds = 1,
	winRingDepleteSeconds = 999,
	winRingAwardDivisor = 100,
	attackDelaySecondsByPhase = {
		2,
		1,
		0.75,
		0.6
	},
	attackConfigIndex = 1,
	stoneTsunamiSizeXRange = { 50, 120 },
	stoneTsunamiSelectionWeight = 0.4,
	lavaFloodSelectionWeight = 0.5,
	meteorRainAttackConfigs = {
		{
			dropCount = 26,
			dropIntervalSeconds = 0.14,
			fallHeight = 500,
			fallDurationSeconds = 2,
			impactRadius = 25,
			recoverySeconds = 1,
			damage = 55
		},
		{
			dropCount = 34,
			dropIntervalSeconds = 0.11,
			fallHeight = 500,
			fallDurationSeconds = 1.8,
			impactRadius = 28,
			recoverySeconds = 0.8,
			damage = 60
		},
		{
			dropCount = 40,
			dropIntervalSeconds = 0.09,
			fallHeight = 500,
			fallDurationSeconds = 1.5,
			impactRadius = 30,
			recoverySeconds = 0.5,
			damage = 65
		},
		{
			dropCount = 46,
			dropIntervalSeconds = 0.08,
			fallHeight = 500,
			fallDurationSeconds = 1.4,
			impactRadius = 32,
			recoverySeconds = 0.4,
			damage = 70
		}
	},
	stoneTsunamiAttackConfigs = {
		{
			waveCount = 2,
			waveIntervalSeconds = 0.75,
			growDurationSeconds = 0.6,
			travelDurationSeconds = 3.5,
			shrinkDurationSeconds = 0.6,
			recoverySeconds = 1,
			damage = 40
		},
		{
			waveCount = 3,
			waveIntervalSeconds = 0.65,
			growDurationSeconds = 0.5,
			travelDurationSeconds = 3.2,
			shrinkDurationSeconds = 0.5,
			recoverySeconds = 0.8,
			damage = 45
		},
		{
			waveCount = 3,
			waveIntervalSeconds = 0.55,
			growDurationSeconds = 0.45,
			travelDurationSeconds = 2.9,
			shrinkDurationSeconds = 0.45,
			recoverySeconds = 0.5,
			damage = 50
		},
		{
			waveCount = 4,
			waveIntervalSeconds = 0.5,
			growDurationSeconds = 0.4,
			travelDurationSeconds = 2.7,
			shrinkDurationSeconds = 0.4,
			recoverySeconds = 0.4,
			damage = 55
		}
	},
	lavaFloodAttackConfigs = {
		{
			warningDurationSeconds = 3,
			telegraphFlashSeconds = 0.9,
			islandRiseDurationSeconds = 1,
			lavaRiseDurationSeconds = 0.75,
			lavaActiveDurationSeconds = 3,
			damageTickSeconds = 0.25,
			lavaLowerDurationSeconds = 1,
			islandLowerDurationSeconds = 2,
			recoverySeconds = 1,
			damage = 12
		},
		{
			warningDurationSeconds = 2.5,
			telegraphFlashSeconds = 0.8,
			islandRiseDurationSeconds = 0.9,
			lavaRiseDurationSeconds = 0.65,
			lavaActiveDurationSeconds = 3,
			damageTickSeconds = 0.22,
			lavaLowerDurationSeconds = 0.9,
			islandLowerDurationSeconds = 1.7,
			recoverySeconds = 0.8,
			damage = 12
		},
		{
			warningDurationSeconds = 2,
			telegraphFlashSeconds = 0.7,
			islandRiseDurationSeconds = 0.75,
			lavaRiseDurationSeconds = 0.55,
			lavaActiveDurationSeconds = 3,
			damageTickSeconds = 0.2,
			lavaLowerDurationSeconds = 0.75,
			islandLowerDurationSeconds = 1.5,
			recoverySeconds = 0.5,
			damage = 12
		},
		{
			warningDurationSeconds = 1.75,
			telegraphFlashSeconds = 0.65,
			islandRiseDurationSeconds = 0.65,
			lavaRiseDurationSeconds = 0.5,
			lavaActiveDurationSeconds = 3,
			damageTickSeconds = 0.18,
			lavaLowerDurationSeconds = 0.65,
			islandLowerDurationSeconds = 1.3,
			recoverySeconds = 0.4,
			damage = 12
		}
	},
	maskCloneCount = 6,
	maskCloneHitPoints = 3,
	maskCloneSwordDamage = 1,
	maskCloneWinMultiplier = 1.5,
	maskCloneChaseWalkSpeed = 26,
	maskCloneTouchDamage = 15,
	maskCloneRespawnIntervalSeconds = 5
}