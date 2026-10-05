local createVector = vector.create
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local GameSettings = {
	studioNpcSpawnTime = 3,
	NpcAnimDistanceGating = 1,
	DisableNpcSpawns = false,
	NpcStunRecovery = 0.5,
	NpcResetRegenDelay = 30,
	NpcKillLedgerShare = 0.9,
	NpcKillCreditShare = 0.1,
	MovementSnapBack = "All",
	AutoBan = true,
	AutoBanBar = {
		YoungDays = 30,
		OldDays = 365,
		Young = 2,
		Middle = 3,
		Old = 4,
		OldSignals = 2
	},
	IsRunning = RunService:IsRunning(),
	IsStudio = isStudio,
	IsTestPlace = game.PlaceId == 17047024836 or game.PlaceId == 130395143593224,
	rigHitEffectOffset = -4,
	IsMinigame = workspace:GetAttribute("IsMinigame") == true,
	IsMenu = workspace:GetAttribute("IsMenu") == true,
	HUDQueuTimeout = 600,
	HUDQueuTeleportDelay = 7,
	HUDQueuVersion = "Queu_v2_",
	HUDQueuTicketVersion = "Tickets_v3_",
	HUDQueuPlaceId = 75556147183481,
	DataStoreKey = "ps2_data_keyv_0001",
	TrainerCompliments = {
		"Good. Again tomorrow, and the day after.",
		"That is how it is done. Keep that form.",
		"Better than most manage on their first try.",
		"Your breathing steadied there. I noticed.",
		"Strong. Now do not let it go to your head.",
		"That one counts. On to the next.",
		"You are starting to move like a Slayer.",
		"Clean. Very clean. Do it again sometime."
	},
	TrainingMarkerPositions = {
		[17047024836] = {
			["Aim Training"] = {
				Image = "rbxassetid://79695808909686",
				Position = createVector(-535.3511, 5.87667, 137.02505)
			},
			["Boulder Push"] = {
				Image = "rbxassetid://77634363833516",
				Position = createVector(-635.5268, 5.87667, 117.52721)
			},
			["Boulder Split"] = {
				Image = "rbxassetid://77990827503588",
				Position = createVector(-636.1665, 5.87667, 40.729168)
			},
			["Cup Game"] = {
				Image = "rbxassetid://140667428374750",
				Position = createVector(-451.52664, 5.876671, 141.03596)
			},
			Meditation = {
				Image = "rbxassetid://112418953189035",
				Position = createVector(-472.64548, 5.8075, 164.25818)
			},
			Pushups = {
				Image = "rbxassetid://120413357264540",
				Position = createVector(-441.6455, 5.8075, 164.25818)
			},
			["Squat Rack"] = {
				Image = "rbxassetid://84951512988617",
				Position = createVector(-409.796, 5.8616204, 166.74527)
			}
		},
		[136406881576517] = {
			Meditation = {
				Image = "rbxassetid://112418953189035",
				Position = createVector(-1890.526, 318.302, 34.055)
			},
			Pushups = {
				Image = "rbxassetid://120413357264540",
				Position = createVector(-1680.239, 318.802, -200.03)
			},
			["Cup Game"] = {
				Image = "rbxassetid://140667428374750",
				Position = createVector(-1893.244, 318.688, -3.579)
			},
			["Target Shooting"] = {
				Image = "rbxassetid://79695808909686",
				Position = createVector(-1495.314, 317.951, -134.056)
			},
			Squat = {
				Image = "rbxassetid://84951512988617",
				Position = createVector(-1827.863, 317.098, 76.18)
			},
			["Boulder Split"] = {
				Image = "rbxassetid://77990827503588",
				Position = createVector(-1046.802, 1133.481, -616.822)
			},
			["Boulder Push"] = {
				Image = "rbxassetid://77634363833516",
				Position = createVector(-311.575, 1074.607, -569.579)
			},
			["Parkour Dungeon"] = {
				Image = "rbxassetid://135018602259567",
				Position = createVector(130.262, 1074.051, -1301.78)
			},
			["Underwater Rocks"] = {
				Image = "rbxassetid://77990827503588",
				Position = createVector(598.608, 1016.106, -419.76)
			}
		},
		Default = {}
	},
	UnderwaterRockSpots = {
		[136406881576517] = {
			createVector(487.379, 974.072, -501.33),
			createVector(700.08, 983.638, -462.772),
			createVector(807.996, 978.238, -345.793),
			createVector(553.939, 982.505, -331.953),
			createVector(538.606, 975.048, -112.438)
		}
	},
	Day = {
		Inversed = false,
		DisableInStudio = true,
		DayTime = {
			Studio = 120,
			Game = 720
		},
		NighTime = {
			Studio = 240,
			Game = 1440
		}
	},
	placesWithinGame = {
		136406881576517,
		130395143593224,
		17047024836,
		16205713724
	},
	analyticsDisabledPlaces = { 17047024836, 130395143593224 },
	maxPartyMembers = 5,
	partyPvpCooldown = 60,
	maxFactionMembers = 50,
	minFactionNameLength = 5,
	maxFactionNameLength = 20,
	indicatorAdditionalDistance = 7,
	RespawnEffectDelay = 0.25,
	defaultSkillTreeItemPointIncrement = 6,
	defaultSkillStatIncrementFactor = 0.25,
	masteryFromMaxHealthFactor = 0.18,
	expPerLevel = 60,
	levelCostCurve = {
		{
			Level = 1,
			Divisor = 3
		},
		{
			Level = 45,
			Divisor = 3
		},
		{
			Level = 55,
			Divisor = 2.2
		},
		{
			Level = 125,
			Divisor = 2.2
		},
		{
			Level = 150,
			Divisor = 1.25
		},
		{
			Level = 175,
			Divisor = 0.75
		},
		{
			Level = 200,
			Divisor = 0.45
		},
		{
			Level = 225,
			Divisor = 0.25
		}
	},
	wenPerExp = 0.45,
	expPerMasteryDefault = 30,
	maxMastery = 400,
	skillPointsPerLevel = 3,
	maxLevel = 225,
	manuallyUnlockedSkills = {
		Blocking = true,
		Dash = true,
		["Breathing Boost"] = true
	},
	BaseStats = {
		Speed = 16,
		BlockPoints = 5,
		M1Damage = 3,
		M1BlockDamage = 0.5,
		StaminaRegen = 6.25,
		HealthRegen = 0.01,
		Health = 75,
		Stamina = 125
	},
	NpcCombatSlowMult = 1.2,
	NpcCombatHitboxShrink = 1.2,
	HitBoxTransparency = 0.9,
	hitboxVisualiserEnabled = RunService:IsStudio(),
	loadingScreenEnabled = true,
	defaultSkillCooldown = 1,
	CooldownGroupShare = 0.5,
	SkillCooldownRules = {
		CarryAcrossDeath = {
			Enabled = true,
			DisabledPlaces = {},
			PvPModes = {
				Default = true
			}
		}
	},
	defaultMaxZoom = 100,
	BlockRegenerateCoolDown = 10,
	BlockRegenInterval = 1.7,
	BlockRegenWhileStunned = true,
	BlockCancelNoCooldownWindow = 0.5,
	StunChainBoost = {
		Enabled = true,
		Stat = "Block Regen",
		Stun = 1.05,
		StrictStun = 1.1,
		CombatStun = 1.025,
		Cap = 3,
		Duration = 5,
		Npcs = false,
		SkipsRegenCooldown = true,
		DisplayPvPOnly = false
	},
	BlockBreakRestorePercent = 0.25,
	BlockBreakRegenDelay = 2,
	GuardCrusherBlockBreak = 5,
	BlockingSpeedMult = 0.625,
	skillStandStillForce = 15000,
	skillDashForcePerSpeed = 142.85714285714286,
	npcPlantForce = 10000,
	movementFactorSoftCap = 0.25,
	movementFactorExcessRate = 0.4,
	movementFactorHardCap = 0.4,
	movementFactorFloor = -0.9,
	lowHealthThreshold = 25,
	lowHealthSpeedFactor = -0.5,
	modeBarMax = 300,
	ModeBarLevelDivisionFactor = 30,
	ModeBarPvpPoolCharge = 240,
	modeDuration = 45,
	MasteryDamageDivisionFactor = 150,
	ClanSkillLevelDamageDivisionFactor = 150,
	MasteryBlockRemovalDivisionFactor = 150,
	NpcPercentDamageFactor = 0.5,
	default_touched_cooldown = 0.35,
	TreeDestructionRespawnTime = 6,
	lvlColor = Color3.fromRGB(255, 195, 75),
	lvlColorRich = "rgb(255, 195, 75)",
	staminaColor = Color3.new(0.811765, 0.435294, 1),
	wenColor = Color3.new(0.831373, 1, 0.0823529),
	robuxColor = Color3.fromRGB(125, 255, 150),
	masteryColor = Color3.fromRGB(255, 255, 255),
	noSaveOverlayTransparency = 0,
	noSaveOverlayShadowColor = Color3.new(),
	noSaveOverlayShadowTransparency = 0.5,
	noSaveOverlayShadowBlur = UDim.new(1, 0),
	reputationColor = Color3.fromRGB(190, 120, 255),
	raceColors = {
		Human = Color3.new(1, 1, 1),
		Slayer = Color3.fromRGB(90, 161, 255),
		Demon = Color3.fromRGB(255, 48, 48),
		Hybrid = Color3.new(1, 0.215686, 0.894118)
	},
	preferedFont = Font.new(
		"rbxasset://fonts/families/JosefinSans.json",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	),
	Tips = {
		"You can block while being stunned as long as there is no stars above your head.",
		"You can dash while blocking but the dash won't travel as far.",
		"There are different shops around the map that sell unique items, some of them only appear at night.",
		"Unless you're confident, you should do final selection with atleast 3 people.",
		"The party system is cross server, you can also join your friends from the party UI by long pressing/clicking their name tag."
	},
	RichTextPopularConfigs = {
		SoroundColor = "Color=rgb(255,176,0)",
		SoroundColorRBX = "color=\"rgb(255,176,0)\""
	},
	KeybindTextSize = UDim2.fromOffset(200, 12),
	KeybindTextOffset = 12,
	KeybindTextTransparency = 1,
	BottomHudLift = 13,
	BottomHudLiftPad = 15,
	PadHintRaise = 2,
	AimAssist = {
		Enabled = true,
		DisabledForTools = {
			Horse = true
		},
		Range = 90,
		CaptureRadius = 0.18,
		HoldRadius = 0.26,
		SwitchRatio = 0.7,
		MinFacingDot = 0.2,
		Refresh = 0.4,
		MaxStrength = 0.5,
		PlatformStrength = {
			Mobile = 1.7,
			Console = 1.3
		},
		PlatformRadius = {
			Mobile = 1.6,
			Console = 1
		},
		CameraStrength = 0.04,
		HoldingStrength = 0.25,
		HoldingMaxYawPerFrame = 0.10471975511965978,
		HoldingMaxPitchPerFrame = 0.06981317007977318,
		SteeringFactor = 0.35,
		FightBreak = 1.5707963267948966,
		FightRecover = 0.5,
		FightRelock = 1,
		MaxYawPerFrame = 0.026179938779914945,
		MaxPitchPerFrame = 0.017453292519943295,
		AngleDeadZone = 0.006981317007977318,
		CursorStrength = 0.075,
		MaxCursorPerFrame = 12,
		CursorDeadZone = 4,
		SkipRagdolled = false,
		ComboMemory = 3.5,
		SkillHitMemory = 2,
		AttackedMemory = 2
	},
	MarkerSize = 45,
	MarkerDistanceTextScale = UDim2.fromScale(1.3, 0.338),
	CompassWidth = 400,
	DialogueTextSettings = {
		XAlignment = Enum.TextXAlignment.Center,
		YAlignment = Enum.TextYAlignment.Center,
		Scaled = true,
		Scale = 0.26,
		MobileScale = 0.17,
		Font = Enum.Font.SourceSansSemibold,
		Style = "Wiggle",
		Amplitude = 1.1,
		Speed = 3,
		Chunks = 2,
		StepFactor = 1.35,
		UseCanvas = true
	},
	sellReturnFactor = 0.44,
	CurrencyToWen = {
		Robux = {
			From = 1,
			To = 25
		}
	},
	SellRobuxPayout = {
		Item = "Ore",
		RobuxEach = 15
	},
	RewardedAds = {
		ShardsPerOre = 5,
		DailyCap = 25,
		PlacementId = 194965006670655
	},
	Tags = {
		Chest = "Chest",
		LootDrop = "LootDrop"
	},
	PartyMaxSize = 5,
	horseRidingPlayerOffset = CFrame.new(0.0824890137, -0.48254776, -2.17668915, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	horseEquipCooldown = 5,
	crowEquipCooldown = 5,
	lifeLostFadeTime = 0.4,
	NewPlayerPlayTime = 900,
	NewPlayerWorld = "Ouwland",
	OnboardedLevel = 10
}
GameSettings.TrainingMarkerPositions[130395143593224] = GameSettings.TrainingMarkerPositions[136406881576517]
GameSettings.UnderwaterRockSpots[130395143593224] = GameSettings.UnderwaterRockSpots[136406881576517]
return GameSettings