return {
	EligibleReputation = -40,
	GrantDistance = 20,
	LairAttribute = "IsInMuzanLayor",
	LairReturnAttribute = "MuzanLairReturn",
	LairEntryReputation = -20,
	LairEntryCost = 5,
	LairBlockedQuest = "Muzan Quest",
	LairRingLength = 1.2666666666666666,
	LairFallLead = 0.2,
	LairFallDelay = 0.25,
	LairFallLength = 1.0833333333333333,
	LairTeleportAtFall = 0.4166666666666667,
	LairRiseLength = 0.9833333333333333,
	LairArrival = CFrame.new(2466.4750977, 1069.3210449, 2351.8779297),
	LairMaxZoom = 50,
	LairSituation = {
		Name = "Sunless",
		SecondaryName = "Muzan's Lair",
		Center = Vector2.new(2467.068, 2337.539),
		Size = Vector2.new(70, 76),
		YRange = { 1040, 1105 }
	},
	TransformSipAt = 1.9,
	TransformDrinkLead = 2.4,
	TransformCutsceneAt = 3,
	TransformLength = 9.533333333333333,
	TransformConvertAt = 4.416666666666667,
	LairActionBypasses = {
		BiwaBell = true,
		MuzansBlood = true
	},
	HigoshimaSpawn = CFrame.new(1451.5, 1245.5, -220, -1, 0, 0, 0, 1, 0, 0, 0, -1),
	HigoshimaSafeZone = CFrame.new(
		-1159.5692,
		1195.0554,
		-1008.9142,
		-0.906299055,
		-0.00755609758,
		-0.422569394,
		0.00546554942,
		0.999547064,
		-0.0295953639,
		0.42260164,
		-0.0291318279,
		-0.905847192
	),
	HigoshimaSafeRadius = 10,
	MizunotoCount = 3,
	MizunotoSpawnRing = {
		Min = 25,
		Max = 35
	},
	MizunotoSpawnArc = 60,
	MizunotoSpawnMaxDrop = 20,
	MizunotoRespawnDelay = 45,
	MizunotoLeash = 150,
	MizunotoRunSpeed = 33,
	WhisperDuration = 6,
	JoinReminderDelay = 15,
	muzanPositions = {
		IsDemon = CFrame.new(2466.3007812, 1079.3299561, 2333.5146484, -1, 0, 0, 0, 1, 0, 0, 0, -1),
		IsNotDemon = CFrame.new(2466.3007812, 1079.3299561, 2334.5146484, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	},
	Whispers = {
		{
			Threshold = -10,
			Pool = { "The scent of blood clings to you… You reek of weakness." }
		},
		{
			Threshold = -20,
			Pool = { "Your cruelty has not gone unnoticed.", "You have earned my attention." }
		},
		{
			Threshold = -30,
			Pool = { "Come. Prove your worth.", "You may now stand before me." }
		},
		{
			Threshold = -40,
			Pool = { "Find me at nightfall." }
		}
	},
	GrantShoutText = "The bell knows the way. Come to me when the moon rises.",
	GrantShoutDuration = 5,
	OrbShoutText = "I have given you a fraction of my power, use it before it's too late.",
	OrbHasArtText = "My power already runs in you. Tear it out first."
}