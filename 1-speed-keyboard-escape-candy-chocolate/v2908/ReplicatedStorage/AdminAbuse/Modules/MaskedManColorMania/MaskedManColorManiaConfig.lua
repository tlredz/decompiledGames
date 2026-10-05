return {
	bossName = "Masked Man",
	sseChannelName = "MaskedManColorMania",
	mapModelName = "MaskedManColorMania",
	bossIcon = "rbxassetid://74389556285578",
	BossUseTheatreHp = true,
	BossTheatreDurationSec = 720,
	BossTheatreDisplayMaxHp = 10000000000,
	PHASE_THRESHOLDS = { 0.35, 0.7, 0.95 },
	useDeferredMapLoad = true,
	deferredLoadTimeBudgetSec = 0.006,
	deferredUnloadTimeBudgetSec = 0.0025,
	KeycapTag = "MaskedManKeycap",
	KeycapColoredTag = "MaskedManKeycapColored",
	KeycapColors = {
		NonColored = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0) },
		Colored = {
			Color3.fromRGB(255, 152, 220),
			Color3.fromRGB(235, 119, 200),
			Color3.fromRGB(180, 128, 255),
			Color3.fromRGB(255, 102, 204),
			Color3.fromRGB(77, 39, 0),
			Color3.fromRGB(156, 104, 78),
			Color3.fromRGB(136, 92, 62),
			Color3.fromRGB(93, 48, 11)
		}
	},
	CHECK_INTERVAL_SEC = 0.01,
	CHECK_RADIUS_STUDS = 5,
	BossNoobUncolorTickSec = 0.05,
	BossUncolorRadiusStuds = 3,
	WinsPerKeycapDivisor = 75,
	WinPadCollectCooldownSec = 1,
	WinPadLabelTag = "MaskedManWinPadToCollect",
	WorldWinsMultiplier = { 1, 1, 3 },
	DefaultSenderId = 1,
	TRUSTED_COMMAND_USER_IDS = {
		[7614363348] = true,
		[18298071] = true,
		[3845375404] = true,
		[175193570] = true,
		[10580349267] = true,
		[586487285] = true,
		[162206312] = true,
		[435763596] = true
	},
	MessageSenderName = "The Mask",
	MessageCommandRemoteName = "MaskedManMessageCommand",
	MessageBroadcastTopic = "Secretverse_MaskedMan_Message_v1",
	MessageCommandCooldownSec = 3,
	MessageMaxLen = 200,
	MobWins = {
		WinOrb = 1
	},
	GiantOrbWinMultiplier = 15,
	Orbs = {
		orbCollectCooldownSec = 0.4,
		despawnSec = 60
	},
	TimelineCues = {
		{
			Time = 20,
			Message = "It's simple: paint the keys, win the prize... or don't! Either way is fun.",
			SpawnOrbs = 6
		},
		{
			Time = 35,
			Message = "...Who exactly are you?",
			SenderId = 18298071,
			SpawnOrbs = 6
		},
		{
			Time = 45,
			Message = "Let's play a little game. Color is such a wonderful thing.",
			SpawnOrbs = 6
		},
		{
			Time = 60,
			Message = "Oops... my color now. You're making this far too easy.",
			SpawnOrbs = 8
		},
		{
			Time = 85,
			Message = "OKAY... THIS IS WEIRD. YOU'RE SERIOUSLY DOING THIS FOR FUN?",
			SenderId = 175193570,
			SpawnOrbs = 8
		},
		{
			Time = 105,
			Message = "Games are much more fun when nobody knows the rules, don't you think?",
			SpawnOrbs = 8
		},
		{
			Time = 125,
			Message = "Paint keycaps quick! No let him steal colors!",
			SenderId = 3845375404,
			SpawnOrbs = 8
		},
		{
			Time = 150,
			Message = "I wonder who will win... maybe I'll change the score.",
			SpawnOrbs = 8
		},
		{
			Time = 180,
			Message = "Come on, entertain me. Let's make the board a little busier!",
			SpawnOrbs = 10,
			SpawnGiantOrbs = 2
		},
		{
			Time = 210,
			Message = "This makes absolutely no sense.",
			SenderId = 18298071,
			SpawnOrbs = 10
		},
		{
			Time = 235,
			Message = "Why does everything need to make sense? That sounds terribly boring.",
			SpawnOrbs = 10
		},
		{
			Time = 265,
			Message = "I HATE TO ADMIT IT... THIS IS ACTUALLY KIND OF FUN.",
			SenderId = 175193570,
			SpawnOrbs = 10
		},
		{
			Time = 295,
			Message = "Stay together! We winning, keep go!",
			SenderId = 3845375404,
			SpawnOrbs = 10,
			SpawnGiantOrbs = 1
		},
		{
			Time = 320,
			Message = "Oh, you're getting better. That was almost impressive.",
			SpawnOrbs = 10
		},
		{
			Time = 360,
			Message = "Paint it again! Let's see how much color we can splash around!",
			SpawnOrbs = 12,
			SpawnGiantOrbs = 3
		},
		{
			Time = 400,
			Message = "You're doing all this... just for fun?",
			SenderId = 18298071,
			SpawnOrbs = 12
		},
		{
			Time = 430,
			Message = "What else is there? Live a little! Don't stop now.",
			SpawnOrbs = 12,
			SpawnGiantOrbs = 1
		},
		{
			Time = 465,
			Message = "No let him paint all! We can win this!",
			SenderId = 3845375404,
			SpawnOrbs = 12
		},
		{
			Time = 500,
			Message = "I DON'T EVEN KNOW WHAT'S HAPPENING ANYMORE.",
			SenderId = 175193570,
			SpawnOrbs = 12,
			SpawnGiantOrbs = 2
		},
		{
			Time = 540,
			Message = "I must say, I'm having a wonderful time. Shall we finish the game?",
			SpawnOrbs = 15,
			SpawnGiantOrbs = 5
		},
		{
			Time = 570,
			Message = "Let's see what colors are left when the music stops.",
			SpawnOrbs = 15,
			SpawnGiantOrbs = 2
		},
		{
			Time = 600,
			Message = "He's still going? Are we even close to finishing this?!",
			SenderId = 18298071,
			SpawnOrbs = 15,
			SpawnGiantOrbs = 2
		},
		{
			Time = 630,
			Message = "Keep paint keycaps! We almost there!",
			SenderId = 3845375404,
			SpawnOrbs = 15,
			SpawnGiantOrbs = 2
		},
		{
			Time = 660,
			Message = "MY LEGS ARE TIRED! BUT WE CANNOT LOSE NOW!",
			SenderId = 175193570,
			SpawnOrbs = 15,
			SpawnGiantOrbs = 3
		},
		{
			Time = 690,
			Message = "Oh, are we reaching the final crescendo? Let's add more colors!",
			SpawnOrbs = 18,
			SpawnGiantOrbs = 4
		},
		{
			Time = 710,
			Message = "What a beautiful game it has been. Just a few seconds left...",
			SpawnOrbs = 20,
			SpawnGiantOrbs = 5
		},
		{
			Time = 720,
			Message = "Time's up! Let's see who won...",
			SpawnOrbs = 20,
			SpawnGiantOrbs = 6
		}
	},
	Cutscenes = {
		RigsFolderName = "CutsceneRigs",
		CameraRigName = "HumanoidCameraRig",
		BossRigName = "TragedyRig",
		OpeningDurationFallbackSec = 10,
		EndingDurationFallbackSec = 8,
		TeardownExtraDelaySec = 2
	},
	BossWalkSpeed = 100,
	IdleTaunts = {
		intervalMinSec = 20,
		intervalMaxSec = 50,
		roarChance = 0.5,
		roarWaitSec = 4.5,
		roarStopSec = 0.6,
		laughWaitCapSec = 15,
		laughStopSec = 0.5
	},
	TauntSFX = {
		Laugh = "rbxassetid://4810729995",
		Roar = "rbxassetid://140076040328382"
	},
	Soundtracks = {
		{
			ID = "rbxassetid://94897123439142",
			DisplayName = "[+1 Keyboard Escape OST] X3ll3n - The Masked Guy [OGG Loop]"
		}
	},
	AttackPerPhase = {
		{ "ColorBeam", "PaintBalloonRain" },
		{ "ColorBeam", "PaintBalloonRain" },
		{
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"ColorTimeshift",
			"PaintBalloonRain"
		},
		{
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"ColorBeam",
			"PaintBalloonRain"
		}
	},
	ColorBeam = {
		halfExtents = vector.create(14, 45, 14),
		warnTimeSec = 1.4,
		zoneCount = 8,
		spawnDelaySec = 0.15
	},
	ColorTimeshift = {
		cooldownSec = 90,
		durationSec = 2,
		resetDelaySec = 0.3,
		fadeIn = 0.6,
		fadeOut = 0.5,
		fakeMessage = "COLORLESS OVERCAST!",
		senderName = "The Mask"
	},
	InkRain = {
		dropCount = 14,
		spawnDelaySec = 0.12,
		fallHeight = 45,
		fallTimeSec = 0.6,
		splashRadius = 6
	},
	NoobUncoloners = {
		templateName = "ColorNoob",
		countByPhase = {
			[2] = 10,
			[3] = 20
		},
		maxNpcs = 20,
		walkSpeed = 16,
		scale = 1,
		maxHealth = 1000000,
		uncolorRadiusStuds = 8,
		retargetMinSec = 3,
		retargetMaxSec = 6,
		spawnStaggerSec = 0.15,
		wanderTickSec = 0.1
	},
	PaintBalloonRain = {
		countByPhase = {
			{
				min = 3,
				max = 4
			},
			{
				min = 4,
				max = 6
			},
			{
				min = 8,
				max = 15
			},
			{
				min = 10,
				max = 15
			}
		},
		spawnDelaySec = 0.15,
		rayLengthStuds = 1000,
		fallSpeedStudsPerSec = 80,
		fallTimeMinSec = 0.8,
		fallTimeMaxSec = 3,
		splashRadius = 15,
		uncolorRadius = 27.5,
		tumbleSpinsMin = 1,
		tumbleSpinsMax = 3,
		cameraFollowSmoothTime = 0.35,
		cameraFollowHeightOffset = 10,
		cameraFollowStopBufferSec = 0.4
	},
	PaintSprayer = {
		PickupsPerPlayer = 1,
		MaxLivePickups = 12,
		PickupMaintenanceTickSec = 2,
		PickupRespawnDelayMinSec = 5,
		PickupRespawnDelayMaxSec = 20,
		ClaimRadiusStuds = 15,
		ClaimCheckIntervalSec = 0.05,
		PickupAssetName = "SprayPaintBombVisualModel",
		ToolAssetName = "PaintSprayerTool",
		BubbleAssetName = "PaintSprayerBubbleModel",
		SprayBudgetSec = 5,
		SprayTickSec = 0.1,
		SprayConeHalfAngleDeg = 20,
		SprayRangeMinStuds = 40,
		SprayRangeStuds = 200,
		SprayColorRadiusStuds = 12,
		BubbleScale = 10,
		BubbleSpeedStudsPerSec = 40,
		BubbleTravelTimeMinSec = 0.3,
		BubbleTravelTimeMaxSec = 1.2
	}
}