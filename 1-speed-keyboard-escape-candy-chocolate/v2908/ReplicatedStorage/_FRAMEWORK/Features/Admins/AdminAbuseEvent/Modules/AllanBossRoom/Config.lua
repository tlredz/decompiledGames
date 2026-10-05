local soundtracksByPhase = { "rbxassetid://93416826267213" }
local music = {}
local openingCutsceneAnimations = {
	camera = "rbxassetid://128848992382740",
	lokii = "rbxassetid://95848733146890",
	allan = "rbxassetid://135008002812444",
	bridge = "rbxassetid://138512286475560"
}
local endingCutsceneAnimations = {
	camera = "rbxassetid://88254526588514",
	lokii = "rbxassetid://114179591227433",
	allan = "rbxassetid://124902289944666"
}

for _, v5 in soundtracksByPhase do
	table.insert(music, v5)
end

local animations = {}

for _, v6 in openingCutsceneAnimations do
	table.insert(animations, v6)
end

for _, v6 in endingCutsceneAnimations do
	table.insert(animations, v6)
end

return {
	mapTemplateName = "AllanBossRoom",
	topBanner = {
		icon = "rbxassetid://105997309315946"
	},
	rigNametags = {
		lokii = {
			text = "Secret_Lokii",
			color = Color3.fromRGB(255, 199, 0)
		},
		allan = {
			text = "Pinpin",
			color = Color3.fromRGB(64, 156, 255)
		}
	},
	platformZonesPath = "Scriptables/PlatformZones",
	lokiiBossRigPath = "Scriptables/LokiiBossRig",
	allanBossRigPath = "Scriptables/AllanBossRig",
	keycapsFolderName = "Keycaps",
	bridgesGroupPath = "Scriptables/Bridges",
	builtBridgeName = "BuiltBridge",
	brokenBridgeName = "BrokenBridge",
	maxBrokenBridges = 5,
	cutsceneRigsFolderName = "CutsceneRigs",
	cutsceneIntroFolderName = "Intro",
	cutsceneOutroFolderName = "Outro",
	cutsceneCameraRigName = "HumanoidCameraRig",
	cutsceneLokiiRigName = "Secret_Lokii",
	cutsceneAllanRigName = "Allan",
	cutsceneBridgeRigName = "ChocolateBridge",
	keycapTag = "AllanBossRoomKeycap",
	keycapHiddenTag = "AllanBossRoomKeycapHidden",
	restoreCheckIntervalSeconds = 0.03,
	restoreRadiusStuds = 6,
	hideTickSeconds = 0.05,
	hideRadiusStuds = 7,
	repairRadiusStuds = 7,
	attackDelaySecondsByPhase = { 2, 1.4, 1 },
	meteorRainKeycapHideRadiusStuds = 10,
	meteorRainBridgeBreakRadiusStuds = 14,
	meteorRainAttackConfigs = {
		{
			dropCount = 22,
			dropIntervalSeconds = 0.15,
			fallHeight = 500,
			fallDurationSeconds = 2,
			impactRadius = 22,
			recoverySeconds = 1,
			damage = 50,
			bridgeHitChance = 0.025
		},
		{
			dropCount = 28,
			dropIntervalSeconds = 0.12,
			fallHeight = 500,
			fallDurationSeconds = 1.8,
			impactRadius = 25,
			recoverySeconds = 0.8,
			damage = 55,
			bridgeHitChance = 0.03
		},
		{
			dropCount = 34,
			dropIntervalSeconds = 0.1,
			fallHeight = 500,
			fallDurationSeconds = 1.5,
			impactRadius = 28,
			recoverySeconds = 0.5,
			damage = 60,
			bridgeHitChance = 0.035
		}
	},
	floatingOrbWins = {
		spawnIntervalMinSeconds = 0.7,
		spawnIntervalMaxSeconds = 1.6,
		orbsPerWave = 2,
		maxActivePerPlayer = 14,
		orbLifetimeSeconds = 16,
		hoverHeightStuds = 10,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	floatingOrbWinsAward = {
		source = "AllanBossRoom:WinOrb"
	},
	bridgeRepair = {
		endOffsetStuds = 10,
		ringLiftStuds = 0,
		ringRadiusStuds = 10,
		fullRepairSecondsOnePlayer = 16,
		extraPlayerRateFactor = 0.6,
		winAwardIntervalSeconds = 2,
		graceSeconds = 30,
		partRevealTweenSeconds = 0.4,
		partRevealRiseStuds = 6,
		progressReplicationIntervalSeconds = 0.15
	},
	bridgeRepairAward = {
		source = "AllanBossRoom:BridgeRepair"
	},
	keycapRepairAward = {
		source = "AllanBossRoom:KeycapRepair"
	},
	keycapRepairWins = {
		winFlushIntervalSeconds = 1,
		keycapsPerWholeAward = 50
	},
	npcFloorHazardTag = "AllanBossRoomNpcHazard",
	npcWalkSpeed = 90,
	npcMoveTimeoutSeconds = 6,
	npcWanderPointPauseSeconds = 0.25,
	npcZoneDwellMinSeconds = 6,
	npcZoneDwellMaxSeconds = 14,
	npcJumpAirtimeSeconds = 1.8,
	npcJumpPeakHeightStuds = 55,
	npcJumpLandProbeHeightStuds = 24,
	npcJumpLandProbeDepthStuds = 64,
	walkAnimationMinSpeed = 3,
	walkAnimation = "rbxassetid://85182433317814",
	idleAnimation = "rbxassetid://130683825654737",
	allanWalkAnimation = "rbxassetid://85182433317814",
	allanIdleAnimation = "rbxassetid://130683825654737",
	landingDebris = {
		slabCount = 11,
		ringRadiusMinStuds = 2,
		ringRadiusMaxStuds = 6,
		sizeMinStuds = 3,
		sizeMaxStuds = 7,
		thicknessMinStuds = 1.5,
		thicknessMaxStuds = 4,
		outwardSpeedMin = 20,
		outwardSpeedMax = 42,
		upSpeedMin = 26,
		upSpeedMax = 44,
		spinSpeed = 16,
		lifetimeSeconds = 2.8,
		fadeSeconds = 0.8,
		shadeJitter = 0.08,
		surfaceProbeDepthStuds = 16,
		fallbackColor = Color3.fromRGB(150, 150, 150)
	},
	taunts = {
		intervalMinSeconds = 20,
		intervalMaxSeconds = 50,
		roarChanceFromPhase = 3,
		roarChance = 0.5,
		laughAnimation = "rbxassetid://139095659336169",
		roarAnimation = "rbxassetid://97037698102407",
		laughSound = "rbxassetid://4810729995",
		roarSound = "rbxassetid://140076040328382",
		laughHoldSeconds = 6,
		roarHoldSeconds = 4.5
	},
	allanTaunts = {
		intervalMinSeconds = 20,
		intervalMaxSeconds = 50,
		roarChanceFromPhase = 3,
		roarChance = 0.5,
		laughAnimation = "rbxassetid://139095659336169",
		roarAnimation = "rbxassetid://97037698102407",
		laughSound = "rbxassetid://4810729995",
		roarSound = "rbxassetid://140076040328382",
		laughHoldSeconds = 6,
		roarHoldSeconds = 4.5
	},
	soundtracksByPhase = soundtracksByPhase,
	AAFw_AutoPreloadEnabled = false,
	AAFw_AutoPreloadIDs = {
		music = music,
		animations = animations
	},
	sequenceOffsetSeconds = 20,
	introLeadSeconds = 20,
	phaseDurationsSeconds = { 240, 240, 240 },
	endingLeadSeconds = 3,
	endingCutsceneFallbackSeconds = 12,
	endingTeardownGraceSeconds = 3,
	cutsceneFieldOfView = 40,
	cutsceneStartFadeSeconds = 0.5,
	cutsceneFadeInSeconds = 0.5,
	cutsceneEndFadeSeconds = 0.6,
	openingCutsceneAnimations = openingCutsceneAnimations,
	endingCutsceneAnimations = endingCutsceneAnimations,
	dialogueSpeakers = {
		lokii = {
			name = "Lokii",
			icon = "rbxthumb://type=AvatarHeadShot&id=3845375404&w=150&h=150"
		},
		pinpin = {
			name = "Pinpin",
			icon = "rbxthumb://type=AvatarHeadShot&id=10580349267&w=150&h=150"
		}
	},
	openingDialogue = {
		{
			text = "Lokii?! What are you doing?!",
			speaker = "pinpin",
			duration = 4,
			atSeconds = 9.5
		},
		{
			text = "Testers, I need you guys to give me a hand!",
			speaker = "pinpin",
			duration = 3.5,
			atSeconds = 22
		}
	},
	endingDialogue = {
		{
			text = "I'll get revenge!",
			speaker = "lokii",
			duration = 3.5,
			atSeconds = 1
		},
		{
			text = "Sure you will.",
			speaker = "pinpin",
			duration = 4,
			atSeconds = 3.5
		},
		{
			text = "Testers, thank you for your help!",
			speaker = "pinpin",
			duration = 4,
			atSeconds = 5.5
		}
	},
	npcCollisionGroup = "AllanBossRoomNpc",
	npcBarrierCollisionGroup = "AllanBossRoomBarrier",
	npcBarriersPath = "Scriptables/InvisibleNPCBarriers",
	voidTriggerPath = "Scriptables/VoidTrigger",
	voidCatchSafeMarginStuds = 30,
	voidCatchStandingHistorySeconds = 1,
	voidCatchMessageDurationSeconds = 4,
	voidCatchMessages = { "Got you.", "Watch where you walk.", "Are you really a tester of mine?" },
	creditsTitle = "AllanBossRoom",
	creditsFadeSeconds = 1,
	creditsHoldSeconds = 6,
	credits = {
		{
			username = "X3LL3N",
			role = "Music Composer",
			image = "rbxassetid://111211209789698",
			aspectRatio = 1
		},
		{
			username = "FoeCakes",
			role = "Lead Dev",
			image = "rbxassetid://115052533712186",
			aspectRatio = 1
		},
		{
			username = "DarkBegin",
			role = "Animator",
			image = "",
			aspectRatio = 1
		}
	}
}