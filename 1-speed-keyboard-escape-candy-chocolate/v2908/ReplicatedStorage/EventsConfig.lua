return {
	Events = {
		{
			Name = "Easter2026",
			Label = "Easter 2026",
			Gamepass = 1744432451,
			Start = os.time({
				year = 2026,
				month = 3,
				day = 27,
				hour = 15,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 4,
				day = 19,
				hour = 23,
				min = 0,
				sec = 0
			}),
			FrameTag = "EasterTrailFrame",
			ExtraFrameTags = { "EasterGoldenTrailFrame" },
			TimerTag = "Easter2026Timer"
		},
		{
			Name = "Easter2027",
			Label = "Easter 2027",
			Gamepass = 1744432451,
			Start = os.time({
				year = 2027,
				month = 3,
				day = 27,
				hour = 15,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2027,
				month = 4,
				day = 10,
				hour = 15,
				min = 0,
				sec = 0
			}),
			FrameTag = "EasterTrailFrame",
			ExtraFrameTags = { "EasterGoldenTrailFrame" },
			TimerTag = "Easter2027Timer"
		},
		{
			Name = "Summer2026",
			Label = "Summer 2026",
			Gamepass = 0,
			Start = os.time({
				year = 2025,
				month = 7,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 8,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			ShowEventShop = false
		},
		{
			Name = "Halloween2026",
			Label = "Halloween 2026",
			Gamepass = 0,
			Start = os.time({
				year = 2026,
				month = 10,
				day = 1,
				hour = 18,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 11,
				day = 30,
				hour = 19,
				min = 0,
				sec = 0
			}),
			ShowEventShop = false,
			CurrencyInfo = {
				Title = "Candy Corn",
				Description = [[
Candy Corn is used to buy items in the <b>Halloween shop</b>, which is only available during <b>Admin Abuse</b>.

Collect as much as you can before the end of the Halloween event!]]
			}
		}
	},
	Currencies = {
		{
			Key = "Eggs",
			Label = "Egg",
			Rarity = 0,
			Respawn = 30,
			Default = 0,
			Icon = 129680199327342,
			Events = { "Easter2026", "Easter2027" }
		},
		{
			Key = "GoldenEggs",
			Label = "Golden Egg",
			Rarity = 1,
			Respawn = 60,
			Default = 0,
			Icon = 87713380580209,
			Events = { "Easter2026", "Easter2027" }
		},
		{
			Key = "SummerCoins",
			Label = "Summer Coin",
			Rarity = 0,
			Default = 10,
			Icon = 117582891502895,
			Events = { "Summer2026" },
			SkipAutoSpawn = true
		},
		{
			Key = "CandyCorn",
			Label = "Candy Corn",
			Rarity = 0,
			Default = 10,
			Icon = 93199614742461,
			Events = { "Halloween2026" },
			SkipAutoSpawn = true
		}
	},
	Trails = {
		{
			Key = "EasterTrail",
			Label = "Easter Trail",
			Multiplier = 20,
			Events = { "Easter2026", "Easter2027" },
			Gamepass = 1744432451,
			CurrencyPrice = nil,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 185)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(220, 165, 75)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(175, 100, 35)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 60, 15))
			}),
			Icon = "rbxassetid://116271569672141",
			Texture = "rbxassetid://102982173039667",
			TextureLength = 3,
			Lifetime = 0.6
		},
		{
			Key = "EasterGoldenTrail",
			Label = "Golden Easter Trail",
			Multiplier = 4,
			Events = { "Easter2026", "Easter2027" },
			Gamepass = 0,
			CurrencyPrice = {
				Key = "GoldenEggs",
				Amount = 200
			},
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 252, 203)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 230, 0)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(200, 160, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 105, 0))
			}),
			Icon = "rbxassetid://94374620397754",
			Texture = "rbxassetid://71019043397814",
			TextureLength = 2,
			Lifetime = 0.9,
			WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.5),
				NumberSequenceKeypoint.new(0.3, 1.1),
				NumberSequenceKeypoint.new(0.7, 0.5),
				NumberSequenceKeypoint.new(1, 0)
			})
		}
	},
	CurrencyGamepasses = {
		X2Rarity0 = 1770945281,
		X2Rarity1 = 1766724426
	},
	CurrenciesRadar = {
		{
			Event = "Easter2026",
			Gamepass = 1768457960
		},
		{
			Event = "Easter2027",
			Gamepass = 1768457960
		}
	},
	GamepassButtons = {
		{
			Tag = "BuyGoldenEggRadar",
			Gamepass = 1768457960
		},
		{
			Tag = "BuyEasterEggsx2",
			Gamepass = 1770945281
		},
		{
			Tag = "BuyGoldenEggsx2",
			Gamepass = 1766724426
		}
	},
	ShopRewards = {
		{
			Tag = "BuyEvent150wins",
			Currency = {
				Key = "Eggs",
				Amount = 200
			},
			Reward = {
				Type = "Wins",
				Amount = 150
			}
		},
		{
			Tag = "BuyEvent1500wins",
			Currency = {
				Key = "GoldenEggs",
				Amount = 20
			},
			Reward = {
				Type = "Wins",
				Amount = 1500
			}
		},
		{
			Tag = "BuyEvent150kxp",
			Currency = {
				Key = "Eggs",
				Amount = 150
			},
			Reward = {
				Type = "XP",
				Amount = 150000
			}
		},
		{
			Tag = "BuyEvent1mxp",
			Currency = {
				Key = "GoldenEggs",
				Amount = 15
			},
			Reward = {
				Type = "XP",
				Amount = 1000000
			}
		}
	},
	OrbEvent = {
		DisplayName = "Orb Event",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 600,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SyncChannelName = "OrbEventSync",
		OrbTemplateName = "CollectibleOrb",
		OrbFolderName = "OrbEventOrbsLocal",
		SpawnIntervalSec = 1,
		OrbsPerSpawner = 4,
		MaxActiveOrbs = 75,
		OrbLifetimeSec = 4,
		SpawnRadiusMin = 50,
		SpawnRadiusMax = 800,
		HoverHeightStuds = 1.5,
		CollectCooldownSec = 0.25,
		WinsTierDivisor = 25,
		WinsMultiplier = 0.35,
		OrbLight = {
			Brightness = 2,
			Range = 20,
			Color = { 255, 200, 0 }
		},
		OrbHighlight = {
			FillColor = { 255, 230, 50 },
			OutlineColor = { 255, 200, 0 },
			FillTransparency = 0.7,
			OutlineTransparency = 0
		},
		ClientColorCorrection = {
			Brightness = 0.02,
			Contrast = 0.05,
			Saturation = 0.08,
			TintColor = { 255, 252, 245 }
		},
		Sounds = {
			"rbxassetid://140074993424765",
			"rbxassetid://5410080857",
			"rbxassetid://127447678350704",
			"rbxassetid://7024280102",
			"rbxassetid://7024245182"
		}
	},
	Lightning = {
		LightningFolder = "Ligtning",
		LightningHeight = 35,
		LightningSegments = { 7, 11 },
		LightningColor = { 255, 230, 50 },
		LightningBrightness = 5,
		LightningBoltLife = 1.5,
		LightningCloudLife = 3,
		LightningSoundVolume = 0.5
	},
	GoldenRain = {
		DisplayName = "Mass Golden Keycaps",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 600,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SpawnWaveInterval = 10,
		SpawnPerPlayerMin = 1,
		SpawnPerPlayerMax = 3,
		MinBurstKeycaps = 10,
		SpawnRadiusMin = 50,
		SpawnRadiusMax = 800,
		SpawnStaggerSec = 0.25,
		BurstNotificationDurationSec = 1,
		WinsMultiplier = 0.35,
		Sounds = { "rbxassetid://140074993424765", "rbxassetid://5410080857", "rbxassetid://127447678350704" }
	},
	CoinBattle = {
		DisplayName = "Coin Battle",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 300,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SyncChannelName = "CoinBattleSync",
		CoinModelName = "CoinModel",
		SpawnWaveInterval = 10,
		SpawnPerPlayerMin = 1,
		SpawnPerPlayerMax = 6,
		MinBurstCoins = 10,
		SpawnRadiusMin = 150,
		SpawnRadiusMax = 1200,
		SpawnStaggerSec = 0.25,
		ContinuousSpawnStaggerSec = 1,
		CoinLifetimeSec = 20,
		HoverHeightStuds = 5.5,
		HoverBobAmplitude = 1.25,
		HoverBobSpeed = 2.2,
		RotateSpeedRad = 1.4,
		CollectDistanceStuds = 22,
		CollectCooldownSec = 0.12,
		MaxActiveCoins = 80,
		PickupDestroyDelaySec = 3,
		ResultsSeconds = 6,
		RewardTrophyItemKey = "ChocolateTrophy",
		RewardMedalItemKey = "ChocolateMedal",
		RewardCoinItemKey = "ChocolateCoin",
		RewardMedalMaxRank = 4,
		SpawnSoundId = "rbxassetid://330274138",
		SpawnSoundVolume = 1.5,
		SpawnSoundRollOffMin = 40,
		SpawnSoundRollOffMax = 900,
		PickupSoundId = "rbxassetid://127645268874265",
		PickupSoundVolume = 0.85,
		PickupSoundRollOffMin = 12,
		PickupSoundRollOffMax = 220,
		Sounds = {
			"rbxassetid://81789245198334",
			"rbxassetid://104695245037953",
			"rbxassetid://94627193867884",
			"rbxassetid://120007441962737",
			"rbxassetid://93970609264491",
			"rbxassetid://98090122284200",
			"rbxassetid://81888427712271",
			"rbxassetid://127176623684925",
			"rbxassetid://71016572563090",
			"rbxassetid://100910937626709"
		}
	},
	MilkBattle = {
		DisplayName = "Milk Battle",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 300,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SyncChannelName = "MilkBattleSync",
		CoinModelName = "MilkModel",
		ToolModelName = "MilkTool",
		ToolName = "Milk",
		BoostDurationSeconds = 60,
		SpawnWaveInterval = 10,
		SpawnPerPlayerMin = 1,
		SpawnPerPlayerMax = 6,
		MinBurstCoins = 10,
		SpawnRadiusMin = 150,
		SpawnRadiusMax = 1200,
		SpawnStaggerSec = 0.25,
		ContinuousSpawnStaggerSec = 1,
		CoinLifetimeSec = 20,
		HoverHeightStuds = 5.5,
		HoverBobAmplitude = 1.25,
		HoverBobSpeed = 2.2,
		RotateSpeedRad = 1.4,
		CollectDistanceStuds = 22,
		CollectHitboxSizeStuds = 12,
		CollectCooldownSec = 0.12,
		MaxActiveCoins = 80,
		PickupDestroyDelaySec = 3,
		ResultsSeconds = 6,
		RewardItemKey = "Milk",
		RewardFirstPlaceItemKey = "GoldenMilk",
		RewardMaxRank = 3,
		SpawnSoundId = "rbxassetid://17208204604",
		SpawnSoundVolume = 1.5,
		SpawnSoundRollOffMin = 40,
		SpawnSoundRollOffMax = 900,
		PickupSoundId = "rbxassetid://133347729618467",
		PickupSoundVolume = 1.3,
		PickupSoundRollOffMin = 12,
		PickupSoundRollOffMax = 220,
		Sounds = {
			"rbxassetid://81789245198334",
			"rbxassetid://104695245037953",
			"rbxassetid://94627193867884",
			"rbxassetid://120007441962737",
			"rbxassetid://93970609264491",
			"rbxassetid://98090122284200",
			"rbxassetid://81888427712271",
			"rbxassetid://127176623684925",
			"rbxassetid://71016572563090",
			"rbxassetid://100910937626709"
		}
	},
	CheeseBattle = {
		DisplayName = "Cheese Battle",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 300,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SyncChannelName = "CheeseBattleSync",
		CoinModelName = "CheeseModel",
		ToolModelName = "CheeseTool",
		ToolName = "Cheese",
		BoostDurationSeconds = 60,
		SpawnWaveInterval = 10,
		SpawnPerPlayerMin = 1,
		SpawnPerPlayerMax = 6,
		MinBurstCoins = 10,
		SpawnRadiusMin = 150,
		SpawnRadiusMax = 1200,
		SpawnStaggerSec = 0.25,
		ContinuousSpawnStaggerSec = 1,
		CoinLifetimeSec = 20,
		HoverHeightStuds = 5.5,
		HoverBobAmplitude = 1.25,
		HoverBobSpeed = 2.2,
		RotateSpeedRad = 1.4,
		CollectDistanceStuds = 22,
		CollectHitboxSizeStuds = 12,
		CollectCooldownSec = 0.12,
		MaxActiveCoins = 80,
		PickupDestroyDelaySec = 3,
		ResultsSeconds = 6,
		RewardItemKey = "Cheese",
		RewardFirstPlaceItemKey = "GoldenCheese",
		RewardMaxRank = 3,
		SpawnSoundId = "rbxassetid://3043029786",
		SpawnSoundVolume = 0.7,
		SpawnSoundRollOffMin = 40,
		SpawnSoundRollOffMax = 900,
		PickupSoundId = "rbxassetid://103637182693391",
		PickupSoundVolume = 0.85,
		PickupSoundRollOffMin = 12,
		PickupSoundRollOffMax = 220,
		Sounds = {
			"rbxassetid://81789245198334",
			"rbxassetid://104695245037953",
			"rbxassetid://94627193867884",
			"rbxassetid://120007441962737",
			"rbxassetid://93970609264491",
			"rbxassetid://98090122284200",
			"rbxassetid://81888427712271",
			"rbxassetid://127176623684925",
			"rbxassetid://71016572563090",
			"rbxassetid://100910937626709"
		}
	},
	SlapBattle = {
		DisplayName = "Glove Battle",
		ScoreLabel = "HITS",
		MaxDurationSeconds = 1200,
		DefaultDurationSeconds = 300,
		NeedsDuration = true,
		SkipDoorTransition = true,
		IsAdminAbuse = false,
		SyncChannelName = "SlapBattleSync",
		HitRemoteName = "SlapBattleHit",
		ToolModelName = "Glove",
		ToolName = "Battle Glove",
		SlapCooldownSeconds = 1,
		SwingDistanceStuds = 20,
		SlapHitRadiusStuds = 28,
		SwingScale = 4,
		SwingOutSeconds = 0.1,
		SwingReturnSeconds = 0.16,
		FlingHorizontalSpeed = 120,
		FlingVerticalSpeed = 70,
		FlingAngularSpeed = 18,
		TripDurationSeconds = 2,
		SmackSoundId = "rbxassetid://173818824",
		SmackSoundVolume = 1,
		WinRewardPercent = 0.01,
		PayoutWinRewardPercent = 0.05,
		MinimumWinReward = 2,
		MaximumWinReward = 5000,
		RewardFirstPlaceItemKey = "ChampionshipBelt",
		RewardSecondPlaceItemKey = "PunchingBag",
		RewardThirdPlaceItemKey = "RoundTimer",
		RewardMaxRank = 3,
		SwingSoundId = "rbxassetid://140025518477459",
		SwingSoundVolume = 1,
		ResultsSeconds = 6,
		Sounds = {
			"rbxassetid://81789245198334",
			"rbxassetid://104695245037953",
			"rbxassetid://94627193867884",
			"rbxassetid://120007441962737",
			"rbxassetid://93970609264491",
			"rbxassetid://98090122284200",
			"rbxassetid://81888427712271",
			"rbxassetid://127176623684925",
			"rbxassetid://71016572563090",
			"rbxassetid://100910937626709"
		}
	},
	MiguelParty = {
		SyncChannelName = "MiguelPartySync",
		SpawnCount = 250,
		HoverHeightStuds = 2
	},
	PizzaParty = {
		SyncChannelName = "PizzaPartySync",
		SpawnCount = 250,
		HoverHeightStuds = 2
	},
	YoutuberSpecialSteakEvent = {
		SyncChannelName = "YoutuberSpecialSteakEventSync",
		SpawnCount = 250,
		HoverHeightStuds = 2
	},
	ChickenParty = {
		SyncChannelName = "ChickenPartySync",
		SpawnCount = 250,
		HoverHeightStuds = 2
	},
	OGParty = {
		SyncChannelName = "OGPartySync",
		SpawnCount = 250,
		HoverHeightStuds = 5.4,
		GiantScale = 1.75,
		NoobLoadRadiusStuds = 350,
		NoobUnloadRadiusStuds = 425,
		MaxActiveNoobs = 70,
		MaxNoobSpawnsPerUpdate = 4,
		NoobStreamUpdateSeconds = 0.15,
		HappyHomeCount = 16,
		HappyHomeMaxCount = 24,
		HappyHomeMinSeparationStuds = 75,
		HappyHomeHoverHeightStuds = 0.15,
		HappyHomeSpawnStaggerSeconds = 0.05
	},
	EventCoins = {
		HoverHeightStuds = 3,
		TickIntervalSec = 120,
		MaxActiveCoins = 100,
		CoinLifetimeSec = 600,
		CollectCooldownSec = 0.25,
		AmountPerCoin = 1,
		SpawnSoundId = "rbxassetid://330274138",
		SpawnSoundVolume = 1.5,
		SpawnSoundRollOffMin = 40,
		SpawnSoundRollOffMax = 450,
		CollectSoundId = "rbxassetid://113863002540263",
		CollectSoundVolume = 0.85,
		FallbackTemplate = {
			Name = "SummerCoinModel",
			Rotation = { 90, 0, 0 }
		},
		Events = {
			Summer2026 = {
				CurrencyKey = "SummerCoins",
				CoinTemplateName = "SummerCoinModel",
				CoinRotation = { 90, 0, 0 },
				CoinLight = {
					Brightness = 2,
					Range = 16,
					Color = { 255, 210, 60 }
				},
				CoinHighlight = {
					FillColor = { 255, 225, 120 },
					OutlineColor = { 255, 190, 40 },
					FillTransparency = 0.6,
					OutlineTransparency = 0
				},
				FirstCollectSeenId = "SummerCoinFound",
				InfoModal = {
					FirstCollect = {
						Title = "Summer coin found!",
						Description = [[
✨ Woohoo! You picked up a <b>Summer coin</b>! ✨

These coins are used in the awesome item shop during our weekly admin abuse events!

You have until end of August to collect as many as you can and grab new summer items to boost your progression in Keyboard Escape!]]
					},
					EventCurrency = {
						Title = "Summer coins",
						Description = [[
Summer coins are used to buy items in the <b>Summer shop</b>, which is only available during <b>Admin Abuse</b>.

Find them throughout the stages as you play, and watch for coin storms!]]
					}
				},
				Storm = {
					AnnounceText = "A Summer Coin Storm is starting...",
					AnnounceColor = { 255, 200, 60 },
					EndAnnounceText = "The Summer Coin Storm has ended.",
					EndAnnounceColor = { 200, 200, 200 }
				}
			},
			Halloween2026 = {
				CurrencyKey = "CandyCorn",
				CoinTemplateName = "CandyCornModel",
				CoinRotation = { 0, 0, 0 },
				CoinLight = {
					Brightness = 2,
					Range = 16,
					Color = { 255, 140, 40 }
				},
				CoinHighlight = {
					FillColor = { 255, 170, 60 },
					OutlineColor = { 255, 110, 0 },
					FillTransparency = 0.6,
					OutlineTransparency = 0
				},
				FirstCollectSeenId = "CandyCornFound",
				InfoModal = {
					FirstCollect = {
						Title = "Candy Corn found!",
						Description = [[
🎃 Spooky! You picked up some <b>Candy Corn</b>! 🎃

Candy Corn is used in the Halloween item shop during our admin abuse events!

Collect as much as you can before the end of the Halloween event, and watch for Candy Corn storms!]]
					}
				},
				Storm = {
					AnnounceText = "A Candy Corn Storm is starting...",
					AnnounceColor = { 255, 140, 40 },
					EndAnnounceText = "The Candy Corn Storm has ended.",
					EndAnnounceColor = { 200, 200, 200 }
				}
			}
		}
	},
	EventCoinStorm = {
		IntervalSec = 3600,
		DurationSec = 300,
		TickIntervalSec = 15,
		BurstMin = 10,
		BurstMax = 25,
		SpawnRadiusMin = 100,
		SpawnRadiusMax = 10000,
		PollIntervalSec = 5
	},
	CurrencyDevProducts = {
		{
			Tag = "EasterMegaPack",
			Id = 3564438479,
			Grants = {
				{
					Key = "Eggs",
					Amount = 2000
				},
				{
					Key = "GoldenEggs",
					Amount = 200
				}
			}
		},
		{
			Tag = "BuyEasterGoldenEggs1",
			Id = 3564437196,
			Grants = {
				{
					Key = "GoldenEggs",
					Amount = 5
				}
			}
		},
		{
			Tag = "BuyEasterGoldenEggs2",
			Id = 3564437320,
			Grants = {
				{
					Key = "GoldenEggs",
					Amount = 10
				}
			}
		},
		{
			Tag = "BuyEasterGoldenEggs3",
			Id = 3564437428,
			Grants = {
				{
					Key = "GoldenEggs",
					Amount = 50
				}
			}
		},
		{
			Tag = "BuyEasterEggs1",
			Id = 3564437599,
			Grants = {
				{
					Key = "Eggs",
					Amount = 100
				}
			}
		},
		{
			Tag = "BuyEasterEggs2",
			Id = 3564437717,
			Grants = {
				{
					Key = "Eggs",
					Amount = 250
				}
			}
		},
		{
			Tag = "BuyEasterEggs3",
			Id = 3564437841,
			Grants = {
				{
					Key = "Eggs",
					Amount = 500
				}
			}
		}
	}
}