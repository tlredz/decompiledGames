local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RngUtil = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils"):WaitForChild("RngUtil"))
local apply_op = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils"):WaitForChild("GeneralUtils"):WaitForChild("apply_op"))
require("./sharedTypes")
local Rods = {
	["Chasm-Stalker"] = {
		Icon = "rbxassetid://97255683335131",
		Price = 5000000,
		Description = "Whispers of the forgotten trenches cling to its spine, binding the line to the suffocating depths below. With every steady haul, the waters churn into a desperate vortex, trapping anything foolish enough to bite...",
		Luck = 278,
		LureSpeed = -35,
		Strength = 1e999,
		LineDistance = 300,
		Resilience = 80,
		Control = 0.3,
		Durability = 200,
		MutationPool = {
			Myriapodic = 35,
			Obsidian = 25
		},
		FishingPassives = {
			ChasmStalker = {
				PerfectGain = 1,
				LevelCoefficient = 0.003752,
				LevelExponent = 1.4286,
				IconOrder = 5,
				FailLossPercent = 15,
				SoftCapStreak = 1000,
				SoftCapExponent = 0.35,
				MutationChancePerCatch = 8,
				WeightBoostPerCatch = 6,
				MaxStacks = 5
			}
		},
		ReelGuiName = "chasmstalker_reel",
		ClientFishingPassives = {
			ChasmStalkerClient = {
				AttemptInterval = 4,
				TriggerChance = 50,
				Duration = 2,
				Width = 0.15,
				PullInTime = 1.25,
				ForcedProgressSpeed = 15,
				ForcedProgressSpeedPerLevel = 2.5,
				ResidualShare = 0.1,
				RampTime = 0.35,
				SwirlRadius = 0.6,
				SwirlSpeed = 4,
				MaxControlLoss = 0.1,
				ControlRefund = 0.25
			}
		},
		BestiaryRequirement = {
			{
				Island = "Obsidian Trench",
				Requirement = 100
			}
		},
		Color = Color3.fromRGB(163, 33, 23),
		BobberTop = Color3.fromRGB(163, 33, 23),
		BobberBottom = Color3.fromRGB(117, 0, 0)
	},
	["Meteoric Rod"] = {
		Icon = "rbxassetid://97871637104665",
		Price = 1e999,
		Description = "Harness the true strength of the meteors...",
		Luck = 175,
		LureSpeed = 25,
		Strength = 550000,
		LineDistance = 75,
		Resilience = 25,
		Control = 0.05,
		MutationPool = {
			Cragged = 20
		},
		ReelGuiName = "meteoricrod",
		FishingPassives = {
			MeteoricRod = {
				WeightBoostPerDodge = 0.05,
				MaxDodges = 5,
				MinDodges = 0
			}
		},
		ClientFishingPassives = {
			MeteoricRod = {
				METEOR_COUNT = 5,
				SPAWN_INTERVAL_MIN = 4,
				SPAWN_INTERVAL_MAX = 6.5,
				FLIGHT_TIME = 1.7,
				METEOR_WIDTH = 0.13,
				HIT_PROGRESS_LOSS = -15,
				DODGE_PROGRESS_GAIN = 10
			}
		},
		Color = Color3.fromRGB(0, 0, 0),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		Unpurchasable = true
	},
	["Scavenger Rod"] = {
		Icon = "rbxassetid://82118096744060",
		Price = 1e999,
		Description = "Let's go on a Scavenger Hunt!",
		Luck = 100,
		LureSpeed = 25,
		Strength = 75000,
		LineDistance = 50,
		Resilience = 20,
		Control = 0.1,
		Scavenging = 200,
		MutationPool = {
			Scavenged = 40
		},
		FishingPassives = {
			Generic_BoostNonFishChances = {
				Multiplier = 3
			}
		},
		Color = Color3.fromRGB(222, 204, 167),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		Unpurchasable = true
	},
	["Rod of the Singularity"] = {
		Icon = "rbxassetid://80659833469905",
		Price = 1e999,
		Description = "Worlds Collide.",
		Luck = 287,
		LureSpeed = -518,
		Strength = 1e999,
		LineDistance = 618,
		Resilience = 28,
		Control = 0.08,
		MutationPool = {
			Nova = 25.92,
			Umbra = 20,
			Singularity = 18.54
		},
		ReelGuiName = "singularity",
		FishingPassives = {
			RodOfTheSingularity = {
				MUTATION_WEIGHT_BOOST = {
					Mutations = { "Umbra", "Singularity" },
					WeightBoost = 1.286
				},
				SINGULARITY_BUFF = {
					DuplicateChance = 10,
					TripleChanceAfterDuplicateChance = 25
				},
				SuccessSound = ReplicatedStorage.resources.sounds.sfx.singularity.Explode,
				FailSound = ReplicatedStorage.resources.sounds.sfx.singularity.Fail
			}
		},
		ClientFishingPassives = {
			RodOfTheSingularityClient = {
				ProgressGain = 1,
				ProgressDecay_Max = 2,
				ProgressDecay_Ramp = 0.25
			}
		},
		Color = Color3.fromRGB(255, 186, 80),
		BobberTop = Color3.fromRGB(255, 186, 80),
		BobberBottom = Color3.fromRGB(255, 101, 93),
		EnhancementPatches = {
			Mastery1 = {
				WeightBoost = 40
			},
			Mastery2 = {
				ClientFishingPassives = {
					RodOfTheSingularityClient = {
						ProgressGain = 2
					}
				}
			},
			Mastery3 = {
				Durability = 200,
				Disturbance = 4
			}
		},
		Unpurchasable = true
	},
	["Stellarwave Melody"] = {
		Icon = "rbxassetid://75412252491909",
		Price = 1e999,
		Description = [[
Stars, Constellations & Zodiacs going round & round - in circles
Concept/Model: Illusion
VFX: Error
Animations: Elude
Random Kid: Tawou]],
		Luck = 244,
		LureSpeed = 12,
		Strength = 1e999,
		LineDistance = 188,
		Resilience = 30,
		Control = 0.1,
		Color = Color3.fromRGB(180, 181, 255),
		BobberTop = Color3.fromRGB(236, 180, 255),
		BobberBottom = Color3.fromRGB(146, 205, 241),
		ProgressEfficiency = 0.24,
		SparklingChance = 5,
		MutationPool = {
			Aurora = 25,
			Melody = 18.8,
			Synth = 8.8
		},
		ReelGuiName = "stellarwave",
		FishingPassives = {
			Generic_FinalWeightMultiplier = {
				Multiplier = 0.8
			},
			StellarwaveMelody_ZodiacWheel = {
				WheelLifetime = 7,
				HardClickLimit = 12,
				IconCount = 12,
				ExtraCatchPassiveBlockLevel = 0,
				ExtraCatchMutationPool = {
					Aurora = 0,
					Melody = 0,
					Synth = 0
				},
				ExtraCatchWeightBoost = 0,
				ExtraCatchShinyChance = 0,
				ExtraCatchSparklingChance = 10,
				Thresholds = {
					{
						Threshold = 4,
						WeightBoost = 20,
						ExtraCatch = 1
					},
					{
						Threshold = 8,
						WeightBoost = 30,
						ExtraCatch = 1
					},
					{
						Threshold = 12,
						WeightBoost = 40,
						ExtraCatch = 1,
						BuffId = "Stellar",
						BuffDuration = 120,
						BuffData = {
							GiveFishEvery = 2,
							CosmicRelicChance = 2
						}
					}
				}
			},
			Generic_WeatherBoosts = {
				Starfall = {
					Boosts = {
						SparklingChance = 3
					}
				},
				["Aurora Borealis"] = {
					Boosts = {
						SparklingChance = 3
					}
				}
			}
		},
		ClientFishingPassives = {
			StellarwaveMelody_ZodiacWheel = {
				AlwaysUseWheel = false,
				WheelLifetime = 7,
				HardClickLimit = 12,
				ShouldRotateIcons = false,
				ProgressPerSign = 3,
				ForcedProgressRatio = 0.1,
				TemporaryControlBuff = 0.3,
				BuffRetainAmountPerClick = 0.06,
				Thresholds = {
					{
						Threshold = 4,
						Progress = 10,
						Resilience = 10,
						ProgressSpeed = 15
					},
					{
						Threshold = 8,
						Progress = 20,
						Resilience = 20,
						ProgressSpeed = 25
					},
					{
						Threshold = 12,
						Progress = 30,
						Resilience = 40,
						ProgressSpeed = 100
					}
				},
				Signs = {
					{
						hint = "rbxassetid://125302445958483",
						base = "rbxassetid://87713177367461",
						glow = "rbxassetid://113241679006265"
					},
					{
						hint = "rbxassetid://117513835761256",
						base = "rbxassetid://79785331277449",
						glow = "rbxassetid://139876409598017"
					},
					{
						hint = "rbxassetid://118230882140700",
						base = "rbxassetid://131660825899150",
						glow = "rbxassetid://136966459699557"
					},
					{
						hint = "rbxassetid://115079204174105",
						base = "rbxassetid://112848958832289",
						glow = "rbxassetid://113321480934426"
					},
					{
						hint = "rbxassetid://125344705992662",
						base = "rbxassetid://101622591206402",
						glow = "rbxassetid://129072950219218"
					},
					{
						hint = "rbxassetid://136666079531813",
						base = "rbxassetid://134568966081333",
						glow = "rbxassetid://88060410759370"
					},
					{
						hint = "rbxassetid://78728966038999",
						base = "rbxassetid://78633129282959",
						glow = "rbxassetid://92031092823033"
					},
					{
						hint = "rbxassetid://108794287269065",
						base = "rbxassetid://85750329590074",
						glow = "rbxassetid://89738590852503"
					},
					{
						hint = "rbxassetid://72337254711587",
						base = "rbxassetid://135640910512677",
						glow = "rbxassetid://104158216634955"
					},
					{
						hint = "rbxassetid://81139403523874",
						base = "rbxassetid://118096235948723",
						glow = "rbxassetid://81034559612359"
					},
					{
						hint = "rbxassetid://104541677855659",
						base = "rbxassetid://82332081547151",
						glow = "rbxassetid://136036324989147"
					},
					{
						hint = "rbxassetid://86735374079048",
						base = "rbxassetid://131990023531922",
						glow = "rbxassetid://125767396757241"
					}
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				Durability = 100,
				Disturbance = 1,
				PreferredDisturbance = {
					Event = "GoliathSiphonophoreHunt",
					Risk = 9
				},
				FishingPassives = {
					StellarwaveMelody_ZodiacWheel = {
						WheelLifetime = 7.5
					}
				},
				ClientFishingPassives = {
					StellarwaveMelody_ZodiacWheel = {
						WheelLifetime = 7.5
					}
				}
			},
			Mastery2 = {
				SparklingChance = 8,
				FishingPassives = {
					Generic_WeatherBoosts = {
						Starfall = {
							Boosts = {
								SparklingChance = 4
							}
						},
						["Aurora Borealis"] = {
							Boosts = {
								SparklingChance = 4
							}
						}
					}
				},
				MutationPool = {
					Aurora = 30,
					Melody = 22.4,
					Synth = 12.4
				}
			}
		},
		Unpurchasable = true
	},
	["Halibut Harpoon"] = {
		Icon = "rbxassetid://122558740234863",
		Price = 1e999,
		Description = [[
RIP TotalBiscuit
Music @DM Dokuro
Animations @3lud_e
Textures @EmeraldTrooper
Programming @Layla
Model @Migura
VFX @RRmarr
UI @Luneth]],
		Luck = 288,
		LureSpeed = -32,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 56,
		Control = 0.1,
		Durability = 200,
		Color = Color3.fromRGB(255, 0, 255),
		BobberTop = Color3.fromRGB(97, 139, 255),
		BobberBottom = Color3.fromRGB(28, 32, 74),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		BaitPreserveChance = 10,
		WeightBoost = 20,
		MutationPool = {
			Bathyal = 20,
			Thalassic = 20,
			Hadal = 20
		},
		ReelGuiName = "halibutharpoon",
		ShakeButtonName = "halibutharpoon",
		FishingPassives = {
			HalibutHarpoon = {
				HarpoonBonusThreshold = 15,
				HarpoonBonusWeightBoost = 1.7,
				ForcedHarpoonPatches = {
					HarpoonCritChance = 0,
					HarpoonCountMin = 15,
					HarpoonDamage = 1,
					HarpoonInterval = 5,
					ExtraAbilities = {}
				},
				ForcedProgressSpeedMultipliers = {
					HarpoonCritChance = 1,
					HarpoonCritDamageBonus = 1,
					HarpoonCountMin = 1,
					HarpoonCountMax = 1,
					HarpoonDamage = 0.5,
					HarpoonInterval = 1
				},
				BaseClientConfig = {
					HarpoonCritChance = 5,
					HarpoonCritDamageBonus = 1,
					HarpoonCountMin = 15,
					HarpoonCountMax = 35,
					HarpoonDamage = 1,
					HarpoonInterval = 5
				},
				ClientConfigClamps = {
					HarpoonCritChance = { 1, 10 },
					HarpoonCountMin = { 15, 25 },
					HarpoonCountMax = { 35, 35 },
					HarpoonDamage = { 1, 5 },
					HarpoonInterval = { 1, 5 }
				},
				BaitStatMap = {
					Luck = "HarpoonCritChance",
					PreferredLuck = "HarpoonCountMin",
					Resilience = "HarpoonDamage",
					Lure = "HarpoonInterval"
				},
				ExtraAbilityConfigs = {
					UselessConfetti = {},
					FinalWeightBoost = {
						WeightBoost = 1.25
					},
					PullFish = {
						PullCooldown = 0,
						PullStrength = 2,
						HarpoonButtonSpeedMultiplier = 0.25
					},
					ShinySparkling = {
						ShinyChance = 5,
						SparklingChance = 5
					},
					AlwaysMaxHarpoonCount = {},
					ExtraMutation = {
						MutationPool = {
							Royal = 10
						}
					},
					StartingProgressBoost = {
						BoostValue = 10
					},
					HarpoonDamageEnhance = {
						DamageIncrease = 1
					}
				},
				RarityConfigs = {
					Trash = {
						StatIncrements = {
							Luck = 1,
							PreferredLuck = 0.05,
							Resilience = 0.02,
							Lure = -0.1
						},
						ExtraAbility = "UselessConfetti"
					},
					Common = {
						StatIncrements = {
							Luck = 0.15,
							PreferredLuck = 0.08,
							Resilience = 0.02,
							Lure = -0.06
						},
						ExtraAbility = "UselessConfetti"
					},
					Uncommon = {
						StatIncrements = {
							Luck = 0.145,
							PreferredLuck = 0,
							Resilience = 0.2,
							Lure = -0.1
						},
						ExtraAbility = "AlwaysMaxHarpoonCount"
					},
					Unusual = {
						StatIncrements = {
							Luck = 0.03,
							PreferredLuck = 0.06,
							Resilience = 0.02,
							Lure = -0.1
						},
						ExtraAbility = "ShinySparkling"
					},
					Rare = {
						StatIncrements = {
							Luck = 0.04,
							PreferredLuck = 0.08,
							Resilience = 0.008,
							Lure = -0.057
						},
						ExtraAbility = "FinalWeightBoost"
					},
					Legendary = {
						StatIncrements = {
							Luck = 0.03,
							PreferredLuck = 0.05,
							Resilience = 0.016,
							Lure = -0.06
						},
						ExtraAbility = "ExtraMutation"
					},
					Mythical = {
						StatIncrements = {
							Luck = 0.04,
							PreferredLuck = 0.06,
							Resilience = 0.01,
							Lure = -0.08
						},
						ExtraAbility = "StartingProgressBoost"
					},
					Exotic = {
						StatIncrements = {
							Luck = 0.03,
							PreferredLuck = 0.05,
							Resilience = 0.01,
							Lure = -0.06
						},
						ExtraAbility = "HarpoonDamageEnhance"
					},
					Secret = {
						StatIncrements = {
							Luck = 0.03,
							PreferredLuck = 0.05,
							Resilience = 0.01,
							Lure = -0.06
						},
						ExtraAbility = "HarpoonDamageEnhance"
					},
					Snare = {
						StatIncrements = {
							Luck = 0.03,
							PreferredLuck = 0.05,
							Resilience = 0.01,
							Lure = 0
						},
						ExtraAbility = "HarpoonDamageEnhance"
					}
				}
			},
			HarpoonGunConversion = {
				LinkedHarpoon = "Halibut Harpoon Gun",
				LinkedRod = "Halibut Harpoon"
			},
			Generic_PerfectBoost = {
				MutationPool = {
					Hadal = 10
				}
			},
			Generic_HardStatLimit = {
				Control = 0.15,
				BaitsBypass = true
			}
		},
		ClientFishingPassives = {
			HalibutHarpoonClient = {
				WarningTime = 1,
				FlightTime = 0.1,
				HarpoonDistance = 16,
				WarningMovementFactor = 3.5,
				MaxSpawnDistanceRatio = 0.9,
				DistanceSkewRatio = 0,
				HarpoonHitboxSize = 0.11,
				SucksNowChance = 1,
				MaximumDelayOnTheFirstWaveOfHarpoonsAgainstAForcedProgressSpeedFish = 2
			},
			HarpoonGunConversion = {
				LinkedHarpoon = "Halibut Harpoon Gun",
				LinkedRod = "Halibut Harpoon"
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "The Deep",
		Hint = "???"
	},
	["Luminous Rod"] = {
		Icon = "rbxassetid://87132597073854",
		Price = 1e999,
		Description = "Dr. Vane's favorite rod, it casts an otherworldly glow into the abyss, luring nocturnal horrors from the darkest trenches.",
		Luck = 95,
		LureSpeed = 30,
		Strength = 60000,
		LineDistance = 40,
		Resilience = 25,
		Control = 0.1,
		ProgressEfficiency = 0.1,
		Color = Color3.fromRGB(96, 214, 255),
		BobberTop = Color3.fromRGB(96, 214, 255),
		BobberBottom = Color3.fromRGB(28, 32, 74),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		MutationPool = {
			Luminous = 30,
			Bioluminescent = 10
		},
		FishingPassives = {
			LuminousRod = {
				NightProgressSpeed = 30
			}
		},
		Unpurchasable = true,
		From = "The Deep",
		Hint = "A late reward from Dr. Vane."
	},
	["Titanium Rod"] = {
		Icon = "rbxassetid://111601652440248",
		Price = 1e999,
		Description = "A polished work of beauty; it boasts simple yet extreme strength.",
		Luck = 180,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 120,
		Resilience = 75,
		Control = 0.3,
		ProgressEfficiency = 0.3,
		Durability = 200,
		Color = Color3.fromRGB(96, 104, 118),
		BobberTop = Color3.fromRGB(198, 214, 232),
		BobberBottom = Color3.fromRGB(52, 57, 66),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		MutationPool = {
			Silver = 75,
			Titanium = 25
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 35,
				SlashDamage = 5,
				SlashInterval = 0.5,
				StunTime = 0.15,
				RawStun = false,
				AnimTime = 0.3,
				OnlyOnBar = true,
				SourceType = "rod",
				SourceName = "Titanium Rod",
				RequiredConditions = {}
			}
		},
		Unpurchasable = true,
		From = "The Deep",
		Hint = "Crafted from various Titanium parts at Ancient Archives."
	},
	["Cusk Purger"] = {
		Icon = "rbxassetid://137793282848341",
		Price = 1e999,
		Description = "Bound with the razor-sharp teeth of the Monstrous Cusk, it creates a terrifying vacuum effect that drags predatory deep-sea monsters straight to your line.",
		Luck = 225,
		LureSpeed = 12,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 25,
		Control = -0.05,
		ProgressEfficiency = 0.35,
		ForcedProgressEfficiency = 0.05,
		Durability = 250,
		Disturbance = 7,
		Color = Color3.fromRGB(44, 40, 50),
		BobberTop = Color3.fromRGB(126, 196, 148),
		BobberBottom = Color3.fromRGB(28, 25, 32),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		WeightBoost = 15,
		MutationPool = {
			Monstrous = 50
		},
		FishingPassives = {
			MonsterHunter = {
				ExcludeRarities = { "Special" },
				MutationPool = {
					Monstrous = 100
				},
				FinalWeightBoost = 1.35
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 35,
				SlashDamage = 5,
				SlashInterval = 0.45,
				StunTime = 0,
				RawStun = false,
				AnimTime = 0.28,
				OnlyOnBar = true,
				SourceType = "rod",
				SourceName = "Cusk Purger"
			},
			CuskPurger = {
				MinInterval = 6,
				MaxInterval = 12,
				HoldTime = 0.9,
				PullStrength = 1.5
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "The Deep",
		Hint = "Crafted from materials dropped by the Monstrous Cusk, in addition to other materials."
	},
	["Scalding Hook"] = {
		Icon = "rbxassetid://77525614718620",
		Price = 1e999,
		Description = "Bestowed by the Vesper of the Deep, its core boils with intense thermal energy, searing catches in a flurry of superheated water.",
		Luck = 180,
		LureSpeed = 18,
		Strength = 400000,
		LineDistance = 100,
		Resilience = 30,
		Control = 0.12,
		ProgressEfficiency = 0.2,
		Durability = 200,
		Color = Color3.fromRGB(255, 106, 40),
		BobberTop = Color3.fromRGB(255, 156, 46),
		BobberBottom = Color3.fromRGB(74, 158, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 6000
			}
		},
		ClientFishingPassives = {
			ScaldingHook = {
				HeatUpTime = 6,
				CoolDownTime = 4,
				MaxForcedProgressSpeed = 35
			}
		},
		FishingPassives = {
			ScaldingHook = {
				CatchCountMin = 1,
				CatchCountMax = 2,
				MinInterval = 15,
				MaxInterval = 30,
				IntervalReducePerCatch = 5,
				MutationPool = {
					["Ashen Fortune"] = 100
				},
				HeatMutation = "Scalded",
				ChancePerForcedSpeed = 1.7,
				HeatUpTime = 6,
				MaxForcedProgressSpeed = 35,
				MaxSparklingChance = 17.5,
				PassiveBlockLevel = 0
			}
		},
		Unpurchasable = true,
		From = "The Deep",
		Hint = "A final reward from the Vesper of the Deep."
	},
	Terrotrapper = {
		Icon = "rbxassetid://129568714340223",
		Price = 1e999,
		Description = "Forged from the remains of the Drylands' apex predator, it calls upon the desert itself to aid in every catch.",
		Luck = 210,
		LureSpeed = 18,
		Strength = 1e999,
		LineDistance = 40,
		Resilience = 47,
		Control = 0.05,
		ProgressSpeed = 20,
		Color = Color3.fromRGB(213, 62, 90),
		BobberTop = Color3.fromRGB(213, 62, 90),
		BobberBottom = Color3.fromRGB(23, 15, 16),
		PreferredDisturbance = {
			Event = "DustStorm",
			Risk = 8
		},
		MutationPool = {
			Terro = 40,
			Photical = 15
		},
		FishingPassives = {
			Terrotrapper = {
				PerfectCatchWeightBoost = 1.5
			}
		},
		ClientFishingPassives = {
			Terrotrapper = {
				MinInterval = 10,
				MaxInterval = 20,
				FastIntervalScale = 0.4,
				BaseProgress = 10,
				MaxProgressBonus = 15,
				CommonRarityThreshold = "Common",
				RarityFalloff = 4,
				SmallWeightThreshold = 100
			}
		},
		Unpurchasable = true,
		From = "Drylands",
		Hint = "Crafted at Ancient Isle using ingredients from the Drylands."
	},
	["Marrow Rod"] = {
		Icon = "rbxassetid://133088704783226",
		Price = 1e999,
		Description = "Excels within the shifting dunes, where ancient remains still lie hidden.",
		Luck = 80,
		LureSpeed = 70,
		Strength = 100000,
		LineDistance = 50,
		Resilience = 11,
		Control = 0.1,
		Color = Color3.fromRGB(198, 154, 99),
		BobberTop = Color3.fromRGB(129, 100, 66),
		BobberBottom = Color3.fromRGB(44, 34, 27),
		PreferredDisturbance = {
			Event = "DustStorm",
			Risk = 4
		},
		MutationPool = {
			Marrow = 35
		},
		FishingPassives = {
			Generic_MultiplyStatsInZone = {
				ZoneMultipliers = {
					Drylands = 2.5,
					Dunehaven = 2.5,
					["The Sunken Reservoir"] = 2.5,
					["The Claypans"] = 2.5
				},
				SkipStats = {
					"BaitEffectiveness",
					"TimeEffectiveness",
					"WeatherEffectiveness",
					"SeasonEffectiveness",
					"StartingProgress",
					"ShakeSize",
					"ShakePower"
				}
			},
			Generic_HardStatLimit = {
				Control = 0.4
			}
		},
		Unpurchasable = true,
		From = "Drylands",
		Hint = "Crafted at Ancient Isle using ingredients from the Drylands."
	},
	["Milk Rod"] = {
		ReelGuiName = "milkrod",
		Icon = "rbxassetid://119265524827463",
		Price = 1e999,
		Description = "Obliterate fish with a huge milk carton on a stick.",
		Luck = 125,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.25,
		Color = Color3.fromRGB(137, 198, 255),
		BobberTop = Color3.fromRGB(151, 184, 255),
		BobberBottom = Color3.fromRGB(229, 229, 229),
		FishingPassives = {
			Generic_FallingWeapon = {
				ModelScale = 4,
				TriggerChance = 100,
				ProgressGain = 30,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 0, -30),
				EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				PivotOffset = CFrame.new(0, -2.5, 0),
				FallAnimTime = 2,
				HitSoundName = "doombringerhammer"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Lemonade Serenade"] = {
		Icon = "rbxassetid://139727182595047",
		Price = 1e999,
		Description = "🍋💫",
		Luck = 230,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 125,
		Resilience = 20,
		Control = 0.2,
		Disturbance = 1,
		Color = Color3.fromRGB(255, 209, 70),
		BobberTop = Color3.fromRGB(255, 209, 92),
		BobberBottom = Color3.fromRGB(61, 47, 15),
		ProgressEfficiency = 0.4,
		FishingPassives = {
			Lemonade = {
				LemonFallChance = 5,
				LemonModelName = "Lemon",
				MutationChancePerDrop = 0,
				DropMutation = "Sour",
				DropsPerSecond = 3
			},
			ButterflyEntity = {
				FISH_GRANT_INTERVAL = 30,
				STANDARD_CATCH_REDUCTION = 15,
				MODEL_NAME = "Dragonfly",
				ALLOW_UNEQUIPPED = true,
				PERSISTENT_ZONE = true,
				BUTTERFLY_OFFSET = CFrame.fromOrientation(0, 1.5707963267948966, 0),
				PASSIVE_BLOCK_LEVEL = 0
			},
			LemonadeSerenadeSkinMutations = {
				SkinMap = {
					Default = "Lemon",
					["Limeade Serenade"] = "Lime",
					["Berrynade Serenade"] = "Strawberry",
					["Bananade Serenade"] = "Banana",
					["Blueberry Serenade"] = "Blueberry",
					["Lavender Serenade"] = "Lavender"
				},
				FallbackMutation = "Lemon",
				TargetRod = "Lemonade Serenade",
				BaseMutationChance = 33.333333333333336,
				ButterflyEntityChance = 100
			}
		},
		ClientFishingPassives = {
			LemonadeSerenade = {
				DropsPerSecond = 2,
				MaxDrops = 5,
				MaxControlLoss = 0.3,
				ChargingAccel = 0,
				PreservePartialCharge = true,
				DropAnimTime = 1,
				DropsProgressOnBar = 5,
				DropsProgressOffBar = 1
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				ClientFishingPassives = {
					LemonadeSerenade = {
						DropsPerSecond = 3,
						MaxDrops = 10
					}
				},
				FishingPassives = {
					Lemonade = {
						DropsPerSecond = 3,
						MutationChancePerDrop = 3
					}
				}
			}
		},
		ReelGuiName = "lemonreel",
		From = "Fischfest 2",
		Hint = "Obtainable during Fischfest 2.",
		Unregistered = true,
		Tags = { "Instrument" }
	},
	["Pool Noodle Rod"] = {
		Icon = "rbxassetid://76574054309462",
		Price = 1000,
		LocalCurrency = "Sunshells",
		Description = [[
Only obtainable during Fischfest 2; 
A floppy foam companion with a 15% chance to leave your fish Splashed, and a big boost to progress speed at the Fischfest 2 location and during Summer!]],
		Luck = 60,
		LureSpeed = 40,
		Strength = 1200,
		LineDistance = 30,
		Resilience = 10,
		Control = 0.05,
		Color = Color3.fromRGB(116, 201, 255),
		BobberTop = Color3.fromRGB(116, 201, 255),
		BobberBottom = Color3.fromRGB(255, 138, 196),
		ReelGuiName = "poolnoodlerod",
		MutationPool = {
			Splashed = 15
		},
		FishingPassives = {
			Generic_SeasonBoosts = {
				Summer = {
					Boosts = {
						ProgressSpeed = 30
					},
					ZoneBoosts = {
						["Fischfest 2"] = {
							ProgressSpeed = 30
						}
					}
				},
				Default = {
					ZoneBoosts = {
						["Fischfest 2"] = {
							ProgressSpeed = 30
						}
					}
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (1,000 Sunshells)",
		From = "Fischfest 2"
	},
	["Tiki Rod"] = {
		Icon = "rbxassetid://74906592544540",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest 2; 
A carved island totem with a 30% chance to bless fish with Tiki style and a hefty fish size boost. A tiki mask watches the center of the catch -- pass over it for bonus progress!]],
		Luck = 90,
		LureSpeed = 35,
		Strength = 4000,
		LineDistance = 30,
		Resilience = 15,
		Control = 0.05,
		Color = Color3.fromRGB(196, 119, 56),
		BobberTop = Color3.fromRGB(232, 156, 64),
		BobberBottom = Color3.fromRGB(120, 72, 40),
		WeightBoost = 30,
		MutationPool = {
			Tiki = 30
		},
		ReelGuiName = "tikirod",
		ClientFishingPassives = {
			TikiMask = {
				ZoneSize = 0.18,
				ProgressBoost = 15,
				FlashColor = Color3.fromRGB(255, 140, 0)
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (Beach Bonfire, Day 7)",
		From = "Fischfest 2"
	},
	["Creamsicle Rod"] = {
		Icon = "rbxassetid://83800504772122",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest 2; 
A frosty treat with a 25% chance to grant the Creamsicle mutation. The bar turns slippery, and fish slowly freeze while held -- freeze one fully for a guaranteed Creamsicle!]],
		Luck = 120,
		LureSpeed = 25,
		Strength = 3000,
		LineDistance = 30,
		Resilience = 10,
		Control = 0.05,
		Color = Color3.fromRGB(255, 170, 92),
		BobberTop = Color3.fromRGB(255, 206, 148),
		BobberBottom = Color3.fromRGB(255, 244, 224),
		MutationPool = {
			Creamsicle = 25
		},
		ReelGuiName = "creamsiclerod",
		FishingPassives = {
			CreamsicleFreeze = {
				Mutation = "Creamsicle"
			}
		},
		ClientFishingPassives = {
			CreamsicleFreeze = {
				Slipperiness = 0.35,
				FreezeTime = 8,
				FullFreezeMutation = "Creamsicle"
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (Sunshell Merchant, 6,500 Sunshells)",
		From = "Fischfest 2"
	},
	["Floatie Rod"] = {
		Icon = "rbxassetid://135863368911362",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest 2; 
An inflatable buoy with a 10% chance for the Floatie mutation. The minigame slowly floats upward with progress -- and every form of progress speed rises the higher it goes!]],
		Luck = 140,
		LureSpeed = 20,
		Strength = 5000,
		LineDistance = 35,
		Resilience = 20,
		Control = 0.05,
		Color = Color3.fromRGB(255, 138, 196),
		BobberTop = Color3.fromRGB(255, 196, 224),
		BobberBottom = Color3.fromRGB(249, 249, 249),
		MutationPool = {
			Floatie = 10
		},
		ReelGuiName = "floatierod",
		ClientFishingPassives = {
			FloatieRise = {
				MaxTrueProgressSpeedBonus = 10,
				MaxForcedProgressSpeedBonus = 10,
				MaxProgressSpeedBonus = 30,
				FloatOffset = 0.25
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (Beach Minigames reward)",
		From = "Fischfest 2"
	},
	["Beach Ball Rod"] = {
		Icon = "rbxassetid://86905944554180",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest 2; 
A bouncy beach ball rod with a 10% chance for the Beach Ball mutation. Serves with +30 starting progress, and a ball bounces around the catch boosting progress speed every time it strikes the bar!]],
		Luck = 110,
		LureSpeed = 25,
		Strength = 4000,
		LineDistance = 30,
		Resilience = 15,
		Control = 0.05,
		Color = Color3.fromRGB(255, 89, 94),
		BobberTop = Color3.fromRGB(255, 202, 58),
		BobberBottom = Color3.fromRGB(106, 197, 255),
		MutationPool = {
			["Beach Ball"] = 10
		},
		ReelGuiName = "beachballrod",
		ClientFishingPassives = {
			BeachBallBounce = {
				InitialProgress = 30,
				HitProgressSpeed = 5
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (25+ Beach Volleyball score)",
		From = "Fischfest 2"
	},
	["Starshell Rod"] = {
		Icon = "rbxassetid://88241556612218",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest 2; 
Captain Conch's prized rod, with a 20% chance for Starshell and a 10% chance for any natural Fischfest 2 mutation. Shells and starfish drop mid-catch for bonus progress, and every catch may pour you a Tiki Hut drink!]],
		Luck = 180,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 40,
		Resilience = 25,
		Control = 0.1,
		Color = Color3.fromRGB(255, 224, 130),
		BobberTop = Color3.fromRGB(255, 245, 200),
		BobberBottom = Color3.fromRGB(255, 200, 80),
		Durability = 100,
		MutationPool = {
			Starshell = 20,
			Beached = 4,
			Paradise = 3,
			Tropical = 3
		},
		ReelGuiName = "starshellrod",
		FishingPassives = {
			Generic_DrinkOnCatch = {
				Chance = 5,
				DirectCatchOnly = true,
				Buffs = {
					"CoconutCooler",
					"PineapplePunch",
					"SunsetSmoothie",
					"LagoonLemonade",
					"SunburstSoda"
				}
			}
		},
		ClientFishingPassives = {
			StarshellDrops = {
				DropInterval = 4,
				DropProgress = 6,
				WaveSpeed = 0.4,
				WaveWidth = 0.1,
				StunDuration = 2.5,
				ShoreMaxAccel = 10
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (Captain Conch quest reward)",
		From = "Fischfest 2"
	},
	["Sand Castle Caster"] = {
		Icon = "rbxassetid://105362270256011",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest; 
A crafted beachcomber's rod with a 20% chance for the Sandy mutation. Hold to charge a meter mid-catch -- fill it to bury the fish in a sand castle, freezing it in place for a guaranteed Sand Castled mutation!]],
		Luck = 100,
		LureSpeed = 30,
		Strength = 6000,
		LineDistance = 30,
		Resilience = 20,
		Control = 0.05,
		Color = Color3.fromRGB(232, 201, 152),
		BobberTop = Color3.fromRGB(212, 180, 130),
		BobberBottom = Color3.fromRGB(196, 166, 120),
		MutationPool = {
			Sandy = 20
		},
		FishingPassives = {
			SandCastleCharge = {
				Mutation = "Sand Castled"
			}
		},
		ReelGuiName = "sandcastlecaster",
		ClientFishingPassives = {
			SandCastleCharge = {
				ChargeTime = 10,
				CastleY = 0.2,
				FullChargeMutation = "Sand Castled"
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest 2. (Crafted)",
		From = "Fischfest 2"
	},
	["Crew Rod"] = {
		Icon = "rbxassetid://132353116390758",
		Price = 70000,
		CrewRatingRequirement = 5000,
		Description = "The journey is the crew we made along the way.",
		Luck = 250,
		LureSpeed = 20,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 55,
		Control = -0.1,
		Color = Color3.fromRGB(239, 184, 56),
		BobberTop = Color3.fromRGB(239, 184, 56),
		BobberBottom = Color3.fromRGB(42, 42, 42),
		LevelRequirement = 500,
		ProgressEfficiency = 0.2,
		ForcedProgressEfficiency = 0.1,
		TrueProgressSpeed = 5,
		FishingPassives = {
			Generic_RarityBoost = {
				Secret = 2
			},
			Generic_BoostStatsForRarity = {
				Secret = {
					ProgressSpeed = 20,
					ForcedProgressSpeed = 10,
					Control = 0.1
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Generic_RarityBoost = {
						["Divine Secret"] = 3
					},
					Generic_BoostStatsForRarity = {
						["Divine Secret"] = {
							ProgressSpeed = 20,
							ForcedProgressSpeed = 10,
							Control = 0.1
						}
					}
				}
			}
		},
		From = "The Crew House",
		Hint = "Obtained by purchasing it at The Crew House.",
		Unregistered = true,
		NotLimited = true
	},
	Noiseform = {
		Icon = "rbxassetid://130907032792662",
		Price = 1e999,
		Description = "It's so loud in here..\nMusic By DM Dokuro",
		Luck = 290,
		LureSpeed = -25,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 65,
		Control = 0,
		Color = Color3.fromRGB(0, 255, 60),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 255, 21),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 4,
		ProgressEfficiency = 0.15,
		ForcedProgressEfficiency = 0.07,
		WeightBoost = 22,
		ReelGuiName = "noiseform",
		MutationPool = {
			Soultorn = 35,
			Flowed = 25
		},
		FishingPassives = {
			ShadowEntity = {
				GiveFishChance = 35,
				ModelName = "Noiseform",
				MatchPlayerEmotes = true,
				CatchEmotesEnabled = false,
				UseOwnerAvatar = false,
				DialogSetName = "Default",
				PassiveBlockLevel = 0,
				SpiritMutationPool = {
					Soultorn = 100
				},
				SpiritWeightMult = 1.85,
				AllowedRarities = {
					"Legendary",
					"Mythical",
					"Exotic",
					"Secret",
					"Apex",
					"Relic"
				}
			},
			Noiseform_PerfectBoost = {
				RhythmicChance = 33
			}
		},
		ClientFishingPassives = {
			Noiseform = {
				LaserTime = 2.5,
				BeamLife = 0.15,
				BeamCooldown = 3.5,
				BeamProgress = 20,
				LaserChance = 2,
				LaserSize = 20,
				WarningCount = 3,
				ZoneWidth = 0.12,
				ProgressLossReduction = -0.33,
				ControlReduction = 0.28,
				MinControl = -0.1,
				StarBeamDuration = 2.25,
				MinStarBeamInterval = 0,
				MaxStarBeamInterval = 10,
				BaseStarBeamSpeed = 0.5,
				MinStarBeamSpeed = 0.1,
				StarBeamSpeedFactor = 13.5,
				ProgressPerStar = 2
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Flowed = 35
				},
				ClientFishingPassives = {
					Noiseform = {
						ControlReduction = 0.2,
						MaxStarBeamInterval = 5
					}
				}
			},
			Mastery2 = {
				MutationPool = {
					Soultorn = 45
				}
			},
			Mastery3 = {
				ShinyChance = 2,
				SparklingChance = 2
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "Shady Bazaar",
		Hint = "Obtained from N/A.",
		Cool = true,
		Tags = { "Instrument" }
	},
	["Moonlit Rod"] = {
		Icon = "rbxassetid://117739514325170",
		Price = 1e999,
		Description = "A rod infused with pale moonlight that grows stronger as darkness settles in. Its blessing awakens at night and shines endlessly during Moonlit Mirages.",
		Luck = 160,
		LureSpeed = 22,
		Strength = 250,
		LineDistance = 30,
		Resilience = 30,
		Control = 0.05,
		Color = Color3.fromRGB(198, 214, 255),
		BobberTop = Color3.fromRGB(235, 240, 255),
		BobberBottom = Color3.fromRGB(6, 2, 112),
		Durability = 250,
		FishingPassives = {
			MoonlitRod = {
				PassiveDuration = 120,
				PassiveCatchRequirement = 10,
				BuffId = "MoonlitBlessing",
				BuffData = {
					PassiveBoosts = {
						Luck = 75,
						ProgressSpeed = 25
					},
					MutationPool = {
						Lunar = 100
					}
				},
				MirageBuffData = {
					PassiveBoosts = {
						Luck = 150,
						ProgressSpeed = 50,
						WeightBoost = 25
					},
					MutationPool = {
						Lunar = 100
					}
				}
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "Shady Bazaar",
		Hint = "Purchased from the Rod Dealer."
	},
	["Shady Rod"] = {
		Icon = "rbxassetid://108961088517473",
		Price = 1e999,
		Description = "A suspiciously well-crafted rod wrapped in worn fabric and hidden intentions. Thrives in darker places, occasionally making catches appear from questionable sources.",
		Luck = 350,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 35,
		Resilience = 40,
		Control = 0.08,
		Color = Color3.fromRGB(60, 58, 70),
		BobberTop = Color3.fromRGB(90, 86, 105),
		BobberBottom = Color3.fromRGB(30, 28, 38),
		ProgressEfficiency = 0.2,
		Durability = 300,
		MutationPool = {
			Shady = 35
		},
		FishingPassives = {
			ShadyRod = {
				NearbyRadius = 30,
				DuplicateChance = 0,
				PerfectCatchScrip = 0
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "Shady Bazaar",
		Hint = "Purchased from the Rod Dealer."
	},
	Acidgrinder = {
		Icon = "rbxassetid://105648215546039",
		Price = 1e999,
		Description = "🧪",
		Luck = 185,
		LureSpeed = 17,
		Strength = 1e999,
		LineDistance = 30,
		Resilience = 30,
		Control = -0.02,
		Color = Color3.fromRGB(108, 196, 64),
		BobberTop = Color3.fromRGB(108, 196, 64),
		BobberBottom = Color3.fromRGB(45, 45, 45),
		Disturbance = 3,
		PreferredDisturbance = {
			Event = "BrineStorm",
			Risk = 15
		},
		Durability = 200,
		MutationPool = {
			Acidic = 40
		},
		FishingPassives = {
			Acidgrinder = {
				RodName = "Acidgrinder"
			}
		},
		ClientFishingPassives = {
			Acidgrinder = {
				MaxSpeedMult = 1.5,
				RampUpTime = 2,
				RampDownTime = 2
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Underground Music Venue",
		Hint = "Obtained from Axel."
	},
	["Steampunk Rod"] = {
		Icon = "rbxassetid://99374737190874",
		Price = 1e999,
		Description = "Brass, gears, and pressure valves humming with kinetic potential. Every catch winds the springs tighter — release the burst to crank progress and resilience past the redline.",
		Luck = 90,
		LureSpeed = 25,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 30,
		Control = 0.1,
		Disturbance = 1,
		ProgressEfficiency = 0.1,
		Color = Color3.fromRGB(150, 100, 60),
		BobberTop = Color3.fromRGB(180, 130, 80),
		BobberBottom = Color3.fromRGB(60, 40, 30),
		Durability = 100,
		MutationPool = {
			Clockwork = 25
		},
		FishingPassives = {
			Steampunk = {
				EnergyPerCatch = 0.05,
				EnergyPerPerfectCatch = 0.05,
				EnergyPerPerfectCast = 0.025,
				EnergyPerReelSnap = -0.1,
				MaxBurstDuration = 60,
				BurstBuffs = {
					ProgressSpeed = 35,
					ForcedProgressSpeed = 15,
					Luck = 100,
					Resilience = 30
				},
				BurstMutationPool = {
					Clockwork = 75
				}
			}
		},
		ClientFishingPassives = {
			Steampunk_Indicator = {
				GearSlashIntervalMin = 5,
				GearSlashIntervalMax = 5,
				GearSlashProgress = 5,
				ForcedProgressEfficiency = 0.15,
				ProgressEfficiency = 0.35,
				Resilience = 30,
				MaxDuration = 60
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		Cool = true,
		From = "Underground Music Venue",
		Hint = "Obtained from Rivet."
	},
	Wingkeeper = {
		Icon = "rbxassetid://120865031667127",
		Price = 1e999,
		Description = "🪽",
		Luck = 222,
		LureSpeed = -11,
		Strength = 1e999,
		LineDistance = 333,
		Resilience = 33,
		Control = 0.11,
		Disturbance = 2,
		ProgressEfficiency = 0.66,
		Color = Color3.fromRGB(236, 232, 214),
		BobberTop = Color3.fromRGB(255, 255, 255),
		BobberBottom = Color3.fromRGB(198, 185, 151),
		Durability = 100,
		LevelRequirement = 1500,
		FishingPassives = {
			Wingkeeper = {
				DAY_PROGRESS_SPEED_BONUS = 75,
				DAY_CONTROL_PENALTY = -0.1,
				DAY_MUTATION = "Sanctified",
				DAY_MUTATION_CHANCE = 35,
				NIGHT_PROGRESS_SPEED_PENALTY = -20,
				NIGHT_MUTATION = "Veilfallen",
				NIGHT_MUTATION_CHANCE = 50
			}
		},
		ClientFishingPassives = {
			Wingkeeper_BarTracking = {
				TrackingSpeed = 0.2
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		From = "Underground Music Venue",
		Hint = "Obtained from Seraphel.",
		Tags = { "Instrument" }
	},
	Castbound = {
		Icon = "rbxassetid://85723718246956",
		Price = 1e999,
		Description = "The culmination of a journey forged into the ultimate sword. [Model & VFX by: @emeraldtrooper444 & @esmulambido]",
		Luck = 390,
		LureSpeed = -1e999,
		Strength = 1e999,
		LineDistance = 130,
		Resilience = 32,
		Control = 0.14,
		ReelGuiName = "castbound",
		FishingPassives = {
			ShadowEntity = {
				GiveFishChance = 50,
				ModelName = "Stardust",
				MatchPlayerEmotes = false,
				CatchEmotesEnabled = false,
				UseOwnerAvatar = false,
				DialogSetName = "Stardust",
				PassiveBlockLevel = 1,
				DontOverrideTransparency = true,
				AttachmentCFrameOverride = CFrame.new(-2, 2.5, 3),
				SpiritMutationPool = {
					Fury = 25,
					Energy = 25,
					Nebula = 25,
					Cosmos = 25
				}
			}
		},
		ClientFishingPassives = {
			Castbound = {
				MinimumBarSize = 0.15,
				LockInModeAmount = 0.3
			},
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 100,
				SlashInterval = 0.8,
				SlashDamage = 5,
				IntervalRamp = 0.1,
				AnimTime = 0.25,
				ChaoticSlashes = true,
				OnlyOnBar = true,
				SourceType = "rod",
				SourceName = "Castbound",
				SoundName = "stabbystab",
				IconName = "Castbound",
				GradientColor = Color3.fromRGB(255, 255, 255)
			}
		},
		XpMultiply = 0.15,
		EnhancementPatches = {
			Mastery1 = {
				Durability = 200,
				FishingPassives = {
					CastboundMastery = {
						PerfectCastProgressAdd = 5
					}
				},
				ClientFishingPassives = {
					Castbound = {
						TheConfigBooleanThatTogglesTheMasteryBuff = true
					},
					Generic_Slashes = {
						IntervalRamp = 0.15
					}
				}
			}
		},
		Color = Color3.fromRGB(255, 40, 100),
		BobberTop = Color3.fromRGB(72, 72, 72),
		BobberBottom = Color3.fromRGB(25, 25, 25),
		Unregistered = true,
		Unpurchasable = true,
		From = "Underground Music Venue",
		Hint = "Obtained from The Guide."
	},
	Remembrance = {
		Icon = "rbxassetid://104976411839413",
		Price = 1e999,
		Description = "A Violin entwined with both the sorrow of those who live and the paradise of those who have left. Butterflies seem particularly attracted to the music that plays. Face the Fear, Fish the Seas.",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 120,
		Resilience = 20,
		Control = -0.1,
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(255, 255, 255),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		ReelGuiName = "remembrance_living",
		FishingPassives = {
			Generic_WeldAccessory = {
				Models = {
					{
						ModelName = "RemembranceBow",
						WeldToLimb = "Left Arm",
						BypassSetting = true
					}
				}
			}
		},
		ClientFishingPassives = {
			Remembrance = {
				DarkFishProgressRatio = -1,
				DarkFishSpeedMultiplier = 1,
				RespectProgressSpeedRatio = 1,
				PerfectionForcedProgressSpeedBoost = 0,
				PerfectionProgressSpeedBoost = 0.1,
				RespectFreeze = true,
				DarkFishFollowBar = false,
				DarkFishMaxSpeed = 1e999,
				DarkFishMinDistance = 0.1
			},
			QuickModeSwap = {
				LinkedRod = "Remembrance"
			}
		},
		DefaultMode = "Living",
		Modes = {
			Living = {
				DisplayName = "Living",
				Icon = "rbxassetid://125535736732170",
				Order = 1,
				Color = Color3.fromRGB(255, 255, 255),
				Patches = {
					Icon = "rbxassetid://104976411839413",
					ShinyChance = 7,
					SparklingChance = 7,
					MutationPool = {
						Fluttering = 50
					},
					ReelGuiName = "remembrance_living"
				}
			},
			Departed = {
				DisplayName = "Departed",
				Icon = "rbxassetid://102878317629151",
				Order = 2,
				Color = Color3.fromRGB(0, 0, 0),
				OverrideModelName = "Departed",
				Patches = {
					Icon = "rbxassetid://111469363158607",
					ProgressEfficiency = 0.15,
					TrueProgressSpeed = 15,
					MutationPool = {
						Departed = 50
					},
					ClientFishingPassives = {
						Remembrance = {
							DarkFishProgressRatio = -1.25,
							DarkFishSpeedMultiplier = 2,
							PerfectionForcedProgressSpeedBoost = 0.02,
							PerfectionProgressSpeedBoost = 0.1,
							DarkFishFollowBar = true
						},
						Generic_AntiSlashes = {
							StunDurationMult = 0.25
						},
						RemembranceButterfly = {
							AttemptInterval = 1.5,
							Chance = 60,
							Cooldown = 8,
							MovementFactor = 6.8,
							Duration = 3,
							AccelMultiply = 0.65
						}
					},
					ReelGuiName = "remembrance_departed"
				}
			}
		},
		From = "Underground Music Venue",
		Hint = "Obtained from Luneth.",
		EnhancementPatches = {
			Mastery1 = {
				Modes = {
					Departed = {
						Patches = {
							MutationPool = {
								Departed = 75
							},
							FishingPassives = {
								ButterflyEntity = {
									INTERVAL_MODE = "catches",
									GRANT_MODE = "duplicate",
									FISH_GRANT_INTERVAL_MIN = 2,
									FISH_GRANT_INTERVAL_MAX = 3,
									STANDARD_CATCH_REDUCTION = 0.5,
									PERFECT_CATCH_REDUCTION = 1,
									BUTTERFLY_MUTATION_POOL = {
										Departed = 100
									},
									MODEL_NAME = "DepartedButterfly",
									PASSIVE_BLOCK_LEVEL = 3
								}
							}
						}
					}
				}
			},
			Mastery2 = {
				Modes = {
					Living = {
						Patches = {
							MutationPool = {
								Fluttering = 75
							},
							FishingPassives = {
								ButterflyEntity = {
									FISH_GRANT_INTERVAL = 100,
									BUTTERFLY_CATCH_MIN = 2,
									BUTTERFLY_COUNT = 4,
									PERFECT_CATCH_REDUCTION = 25,
									SPARKLING_CHANCE = 3,
									SHINY_CHANCE = 3,
									BUTTERFLY_MUTATION_POOL = {
										Fluttering = 100
									},
									MODEL_NAME = "LivingButterfly",
									PERSISTENT_ZONE = true,
									PASSIVE_BLOCK_LEVEL = 0,
									RARITY_POOL = {
										Trash = 10,
										Common = 28,
										Uncommon = 27,
										Unusual = 13,
										Rare = 43,
										Legendary = 3,
										Mythical = 2,
										Exotic = 1,
										Secret = 0.5,
										Apex = 1
									}
								}
							}
						}
					}
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Tags = { "Instrument" }
	},
	Lullaby = {
		Icon = "rbxassetid://99471771785939",
		Price = 1e999,
		Description = "A fool found a companion in Hawaii..",
		Luck = 225,
		LureSpeed = 10,
		Strength = 1e999,
		LineDistance = 225,
		Resilience = 25,
		Control = 0.25,
		Disturbance = 2,
		Durability = 200,
		Color = Color3.fromRGB(137, 143, 255),
		BobberTop = Color3.fromRGB(168, 123, 208),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		ShinyChance = 2,
		SparklingChance = 2,
		MutationPool = {
			Prismatic = 24,
			Rainbow = 18,
			Mythical = 12
		},
		FishingPassives = {
			MetronomeBuff = {
				HitDuration = 2.5,
				MissDuration = -1,
				HitDurationMultiply = 1,
				OwnerBuffMultiplier = 1,
				BuffRange = 64,
				PlayerLevelRequirement = 15,
				PerfectCatchDuration = 5,
				MusicName = "Lullaby",
				MusicFactor = 2.5833333333333335,
				MaxDuration = 28800
			},
			Generic_TimeBoosts = {
				Night = {
					MutationPool = {
						Prismatic = 6
					}
				}
			}
		},
		ClientFishingPassives = {
			MetronomeBuff = {
				ControlPerHit = 0.01,
				ControlDuration = 2,
				BuffExpirationPenalty = 0.03,
				MusicName = "Lullaby",
				MusicVolume = 0.5,
				BeatsPerMeasure = 4,
				BPM = {
					{ 0, 157 },
					{ 2, 150 },
					{ 56, 166 },
					{ 100, 164 },
					{ 134, 150 }
				},
				MusicFactor = 2.5833333333333335,
				FixedMusicOffset = 0.2,
				ProgressPerHit = 1,
				ProgressPerMiss = -5,
				ProgressSpeedPerHit = 1,
				ProgressSpeedPerHitMultiply = 0,
				BuffRange = 64
			},
			MoonlightRay = {
				FlingTime = 0.5,
				UseMetronomeTiming = true,
				TryEveryMetronomeHits = 4,
				MinInterval = 2,
				MaxInterval = 4,
				BeamWidth = 0.15,
				ProgressGain = 5
			},
			QuickModeSwap = {
				LinkedRod = "Lullaby"
			}
		},
		DefaultMode = "Resistant",
		Modes = {
			Quickening = {
				DisplayName = "Quickening Symphony",
				Icon = "rbxassetid://125195401804674",
				Order = 2,
				Color = Color3.fromRGB(97, 226, 255),
				Description = "Buffs Lure and Progress Speed",
				Hint = "Unlocked by progressing Simon's quests.",
				RequiresUnlock = true,
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://105090079290956",
									Start = 0,
									End = 90
								}
							},
							SectionCount = 1,
							Speed = 1,
							MusicFactor = 2.5833333333333335,
							BuffIcon = "rbxassetid://125195401804674",
							BuffColor = ColorSequence.new(Color3.fromRGB(213, 255, 248), Color3.fromRGB(112, 236, 255))
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabyQuickening",
							BuffStats = {
								Lure = 20,
								ProgressSpeed = 20
							},
							MusicFactor = 2.5833333333333335,
							SectionCount = 1
						}
					}
				}
			},
			Strengthening = {
				DisplayName = "Strengthening Melody",
				Icon = "rbxassetid://137881438860164",
				Order = 3,
				Color = Color3.fromRGB(255, 143, 87),
				Description = "Buffs Strength, Line Distance, XP, and Disturbance",
				Hint = "Unlocked by progressing Simon's quests.",
				RequiresUnlock = true,
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://95661750144510",
									Start = 70,
									End = 110
								}
							},
							Speed = 0.5,
							SectionCount = 2,
							BPM = {
								{ 0, 153 }
							},
							MusicFactor = 1.275,
							FixedMusicOffset = 0,
							MusicName = "LullabyStrengthening",
							BuffIcon = "rbxassetid://137881438860164",
							BuffColor = ColorSequence.new(Color3.fromRGB(248, 135, 6), Color3.fromRGB(165, 37, 37))
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabyStrengthening",
							BuffStats = {
								Strength = 75000,
								LineDistance = 75,
								XpMultiply = 0.5,
								Disturbance = 4
							},
							MusicName = "LullabyStrengthening",
							MusicFactor = 1.275,
							SectionCount = 2
						}
					}
				}
			},
			Fortuitous = {
				DisplayName = "Fortuitous Harmony",
				Icon = "rbxassetid://75735607800057",
				Order = 4,
				Color = Color3.fromRGB(174, 233, 104),
				Description = "Buffs Luck and Fish Weight",
				Hint = "Unlocked by progressing Simon's quests.",
				RequiresUnlock = true,
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://138390172276836",
									Start = 90,
									End = 180
								}
							},
							SectionCount = 1,
							Speed = 1,
							MusicFactor = 2.533333333333333,
							BPM = {
								{ 0, 152 }
							},
							FixedMusicOffset = 0,
							MusicName = "LullabyFortuitous",
							BuffIcon = "rbxassetid://75735607800057",
							BuffColor = ColorSequence.new(Color3.fromRGB(229, 254, 122), Color3.fromRGB(120, 255, 134))
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabyFortuitous",
							BuffStats = {
								Luck = 40,
								WeightBoost = 10
							},
							MusicName = "LullabyFortuitous",
							MusicFactor = 2.533333333333333,
							SectionCount = 1
						}
					}
				}
			},
			Resistant = {
				DisplayName = "Resistant Composition",
				Icon = "rbxassetid://106206049362009",
				Order = 1,
				Color = Color3.fromRGB(255, 253, 34),
				Description = "Buffs Resilience and Control",
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://102840309188358",
									Start = 0,
									End = 40
								},
								{
									Asset = "rbxassetid://100636274763625",
									Start = 70,
									End = 110
								},
								{
									Asset = "rbxassetid://101844998523000",
									Start = 140,
									End = 180
								}
							},
							SectionCount = 4,
							Speed = 0.5,
							MusicFactor = 1.3333333333333333,
							BPM = {
								{ 0, 160 }
							},
							FixedMusicOffset = 0.1,
							MusicName = "LullabyStranded",
							BuffIcon = "rbxassetid://106206049362009",
							BuffColor = ColorSequence.new(Color3.fromRGB(255, 242, 23), Color3.fromRGB(177, 152, 48))
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabyResistant",
							BuffStats = {
								Resilience = 20,
								Control = 0.05
							},
							MusicName = "LullabyStranded",
							MusicFactor = 1.3333333333333333,
							SectionCount = 4
						}
					}
				}
			},
			Prismatic = {
				DisplayName = "Prismatic Sinfonia",
				Icon = "rbxassetid://103371808334979",
				Order = 5,
				Color = Color3.fromRGB(254, 136, 187),
				Description = "Provides all previous buffs at half effectiveness, and grants the Prismatic and Mythical mutations",
				Hint = "Unlocked by progressing Simon's quests.",
				RequiresUnlock = true,
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://102840309188358",
									Start = 0,
									End = 40
								},
								{
									Asset = "rbxassetid://101844998523000",
									Start = 140,
									End = 180
								}
							},
							SectionCount = 2,
							Speed = 1,
							MusicFactor = 2.4,
							MusicName = "LullabyPrismatic",
							FixedMusicOffset = 0,
							MusicVolume = 0.5,
							BPM = {
								{ 0, 144 }
							},
							BuffIcon = "rbxassetid://103371808334979",
							BuffColor = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(202, 248, 255)),
								ColorSequenceKeypoint.new(0.5, Color3.fromRGB(237, 239, 193)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(237, 194, 186))
							})
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabyPrismatic",
							BuffStats = {
								Lure = 10,
								ProgressSpeed = 10,
								Strength = 25000,
								LineDistance = 25,
								XpMultiply = 0.25,
								Luck = 20,
								WeightBoost = 5,
								Resilience = 10,
								Control = 0.025,
								ShinyChance = 3,
								SparklingChance = 3,
								Disturbance = 2
							},
							BuffMutationPool = {
								Prismatic = 12,
								Mythical = 3
							},
							MusicName = "LullabyPrismatic",
							MusicFactor = 2.4,
							SectionCount = 2
						}
					}
				}
			},
			Serenity = {
				DisplayName = "Serene Hymn",
				Icon = "rbxassetid://110456768627220",
				Order = 6,
				Color = Color3.fromRGB(247, 153, 255),
				Description = "Massively buffs Resilience and grants the Serene mutation",
				Hint = "Unlocked via Rod Mastery",
				RequiresUnlock = true,
				Patches = {
					ClientFishingPassives = {
						MetronomeBuff = {
							Sections = {
								{
									Asset = "rbxassetid://102840309188358",
									Start = 0,
									End = 40
								},
								{
									Asset = "rbxassetid://101844998523000",
									Start = 140,
									End = 180
								}
							},
							SectionCount = 2,
							Speed = 1,
							MusicFactor = 2.5166666666666666,
							MusicName = "LullabySerenity",
							FixedMusicOffset = 0,
							MusicVolume = 0.5,
							BPM = {
								{ 0, 177.64705882352942 }
							},
							BuffIcon = "rbxassetid://110456768627220",
							BuffColor = ColorSequence.new(Color3.fromRGB(250, 183, 255), Color3.fromRGB(198, 115, 204))
						}
					},
					FishingPassives = {
						MetronomeBuff = {
							BuffId = "LullabySerenity",
							BuffStats = {
								Resilience = 45
							},
							BuffMutationPool = {
								Serene = 10
							},
							MusicName = "LullabySerenity",
							MusicFactor = 2.5166666666666666,
							SectionCount = 2
						}
					}
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					MetronomeBuff = {
						HitDurationMultiply = 2
					}
				}
			},
			Mastery2 = {
				ClientFishingPassives = {
					MetronomeBuff = {
						ProgressSpeedPerHitMultiply = 1
					}
				}
			}
		},
		From = "Underground Music Venue",
		Hint = "A Labyrinth.",
		Unregistered = true,
		Unpurchasable = true,
		ReelGuiName = "lullaby",
		Tags = { "Instrument" }
	},
	["Zeus's Thundermaul"] = {
		Icon = "rbxassetid://96673976117071",
		Price = 18750000,
		MinDistanceToPurchase = 30,
		Description = "A divine hammer forged from pure lightning. Every 2 minutes it fully charges, allowing a perfect cast to electrocute the surrounding waters. Passive lightning bolts throughout each minigame grant progress, doubled during rain.",
		Luck = 200,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 75,
		Resilience = 35,
		Control = 0.08,
		Color = Color3.fromRGB(255, 255, 100),
		BobberTop = Color3.fromRGB(255, 255, 100),
		BobberBottom = Color3.fromRGB(40, 30, 10),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		PreferredDisturbance = {
			Event = "KeraunoWyrmHunt",
			Risk = 12
		},
		LevelRequirement = 600,
		Disturbance = 5,
		MutationPool = {
			["Zeus's Storm"] = 10
		},
		FishingPassives = {
			Thundermaul = {
				CHARGE_TIME = 120,
				ELECTRIFIED_DURATION = 30,
				ELECTRIFIED_MUTATION_CHANCE = 100
			},
			Generic_WeatherBoosts = {
				Rain = {
					MutationPool = {
						["Zeus's Storm"] = 20
					},
					Boosts = {
						ProgressSpeed = 10
					}
				},
				Stormy = {
					MutationPool = {
						["Zeus's Storm"] = 20
					},
					Boosts = {
						ProgressSpeed = 10
					}
				}
			}
		},
		ClientFishingPassives = {
			ThundermaulPassive = {
				StrikeInterval = 3,
				ProgressPerStrike = 2,
				RainyMultiplier = 2,
				StrikeWidth = 0.08,
				InitialProgressBonus = 15,
				InitialProgressBonus_PerfectCast = 50,
				ForcedProgressSpeedMaxBonus = 30
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.DivineSealsBroken.Poseidon",
					ExpectedValue = true,
					FailMessage = "You have not yet broken Poseidon's seal."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Zeus's Thunder of Chaos",
				Requirement = 100
			}
		},
		From = "Zeus's Thunder of Chaos",
		Hint = "Obtained by completing the Zeus layer of the Wrath of Olympus."
	},
	["Apollo's Sunshot"] = {
		Icon = "rbxassetid://111604883317296",
		Price = 17500000,
		Description = "A bow of radiant light that rewards precision; each cast channels the sun's power, building into blazing shots that accelerate the hunt and burn through resistance.",
		Luck = 150,
		LureSpeed = 20,
		Strength = 2000000,
		LineDistance = 180,
		Resilience = 40,
		Control = 0.1,
		Color = Color3.fromRGB(255, 210, 121),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		PreferredDisturbance = {
			Event = "SolarChorus",
			Risk = 7
		},
		LevelRequirement = 350,
		FishingPassives = {
			["Apollo's Sunshot"] = {
				MAX_PROGRESS_SPEED_BOOST = 100,
				MUTATION = "Sunlit"
			}
		},
		ReelGuiName = "apollo",
		ClientFishingPassives = {
			ApollosSunshotClient = {
				CHARGE_RATE = 0.5,
				DAYTIME_CHARGE_RATE = 1.5,
				ARROW_PROGRESS = 9,
				BURN_CHANCE = 40,
				BURN_DURATION = 3,
				BURN_MOVE_SPEED = 0.5
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.Apollo.InstrumentPuzzleCompleted",
					ExpectedValue = true,
					FailMessage = "You have not yet completed the instrument puzzle."
				},
				{
					Path = "WrathOfOlympus.DivineSealsBroken.Bellona",
					ExpectedValue = true,
					FailMessage = "You have not yet broken Bellona's seal."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Apollo's Song of Light",
				Requirement = 100
			}
		},
		From = "Apollo's Song of Light",
		Hint = "Obtained by solving Apollo's instrument puzzle and completing a Solar Eclipse trial.",
		Tags = { "Bow" }
	},
	["Olympian Godbreaker"] = {
		Icon = "rbxassetid://138915349383813",
		Price = 50000000,
		MinDistanceToPurchase = 30,
		Description = "A forbidden construct forged from shattered divinity; collapsing gravity, summoning violent cosmic forces, and dragging lesser prey toward inevitable capture under its overwhelming pull.",
		Luck = 265,
		LureSpeed = 1.9000000000000057,
		Strength = 1e999,
		LineDistance = 98.1,
		Resilience = 19.81,
		Control = 0.18,
		Color = Color3.fromRGB(255, 47, 137),
		BobberTop = Color3.fromRGB(255, 47, 137),
		BobberBottom = Color3.fromRGB(145, 46, 202),
		Disturbance = 3,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 10000
			}
		},
		ProgressEfficiency = 0.35,
		Durability = 981,
		LevelRequirement = 981,
		MutationPool = {
			Cragged = 30,
			Gravitas = 30
		},
		FishingPassives = {
			StarcallerCry = {
				TriggerChance = 30,
				ActiveStats = {
					Control = -0.15
				},
				PassiveMutationPool = {
					Cragged = 100
				},
				AfterSuccessStats = {
					Disturbance = 5
				},
				AfterSuccessCatchCount = 3,
				BuffMutations = { "Gravitas" },
				BuffWeight = 1.981,
				FishCountMin = 2,
				FishCountMax = 5,
				RequirePerfect = true,
				PassiveBlockLevel = 0,
				BlockHigherRarity = true,
				BlockSameRarity = false,
				BlockLowerRarity = false,
				VfxModelName = "GravityVfx"
			},
			MeteorShower = {
				ChancePerCatch = 5,
				ProgressPerHit = 6,
				MeteorCount = 12,
				CountPassiveCatches = true,
				CountDuplicateCatches = false,
				BlockOnForcedProgressFish = true,
				MeteorModelName = "OlympianGodbreakerMeteor",
				FallAnimTime = 0.5,
				MeteorInterval = 0.1,
				StartSoundName = "meteorFall",
				EndSoundName = "meteorExplode"
			}
		},
		ClientFishingPassives = {
			Generic_FixedProgressSpeed = {
				FixedProgressEfficiency = 0.25,
				ForcedProgressFishOnly = true
			},
			Generic_AntiSlashes = {
				DamageReduction = 0.5,
				DisableStun = true,
				ForcedProgressFishOnly = true
			},
			CollapsingStars = {
				Chance = 50,
				ChanceInterval = 1.25,
				Cooldown = 1.25,
				PullTime = 1,
				PullPower = 1,
				ProgressGain = 9,
				ProgressGainOffBar = 3,
				ProgressGain_NonFPF = 3,
				ProgressGainOffBar_NonFPF = 0,
				ForcedProgressFishOnly = nil
			},
			StarcallerCryClient = {}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Olympian = apply_op.ADD(2)
				},
				ClientFishingPassives = {
					CollapsingStars = {
						ProgressGain = 12,
						ProgressGainOffBar = 6,
						ProgressGain_NonFPF = 6,
						ProgressGainOffBar_NonFPF = 3,
						ForcedProgressFishOnly = nil
					}
				}
			},
			Mastery2 = {
				MutationPool = {
					Olympian = apply_op.ADD(2)
				},
				FishingPassives = {
					StarcallerCry = {
						ActiveStats = {
							Control = -0.0981
						}
					}
				}
			},
			Mastery3 = {
				MutationPool = {
					Olympian = apply_op.ADD(2)
				},
				FishingPassives = {
					StarcallerCry = {
						AfterSuccessCatchCount = 5
					}
				}
			},
			Mastery4 = {
				MutationPool = {
					Olympian = apply_op.ADD(2)
				},
				FishingPassives = {
					StarcallerCry = {
						FishCountMin = 3,
						FishCountMax = 6
					}
				}
			},
			Mastery5 = {
				MutationPool = {
					Olympian = apply_op.ADD(2)
				},
				ClientFishingPassives = {
					Generic_FixedProgressSpeed = {
						FixedProgressEfficiency = 0.4
					}
				}
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.DivineSealsBroken.Hades",
					ExpectedValue = true,
					FailMessage = "You have not yet unlocked the Olympian Fissure."
				}
			},
			PlayerAttributes = {
				{
					Name = "CanBuyGodbreaker",
					ExpectedValue = true,
					FailMessage = "You must prove your worth to the gods before purchasing this."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Bellona's Frenzy of War",
				Requirement = 100
			},
			{
				Island = "Apollo's Song of Light",
				Requirement = 100
			},
			{
				Island = "Poseidon's Storm of Floods",
				Requirement = 100
			},
			{
				Island = "Zeus's Thunder of Chaos",
				Requirement = 100
			},
			{
				Island = "Hades' Underworld of Indefinite",
				Requirement = 100
			},
			{
				Island = "Olympian Fissure",
				Requirement = 100
			}
		},
		From = "Olympian Fissure",
		Hint = "???"
	},
	["Hades' Soul-Scythe"] = {
		Icon = "rbxassetid://140210858328833",
		Price = 25000000,
		MinDistanceToPurchase = 30,
		Description = "A cursed scythe that feeds on every catch, gathering soul energy until it unleashes devastating effects; wisps swarm, and the next victim is claimed with unnatural force.",
		Luck = 250,
		LureSpeed = -100,
		Strength = 1e999,
		LineDistance = 120,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(83, 255, 126),
		BobberTop = Color3.fromRGB(83, 255, 126),
		BobberBottom = Color3.fromRGB(66, 168, 61),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		Disturbance = 5,
		LevelRequirement = 750,
		WeightBoost = 25,
		MutationPool = {
			Soultouched = 40
		},
		FishingPassives = {
			Generic_FallingWeapon = {
				ModelScale = 3,
				TriggerChance = 10,
				ProgressGain = 100,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 0, -30),
				EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				PivotOffset = CFrame.new(0, -2.5, 0),
				EasingIntensity = 2,
				FallAnimTime = 2,
				FallHitTime = 2,
				HitSoundName = "soulScytheImpact",
				DisabledOnFish = { "Styx Angler" }
			},
			HadesCurse = {
				PassiveChargeTime = 600,
				CatchCharge = 5,
				PerfectCatchCharge = 10,
				PerfectCastCharge = 6,
				ReelSnapCharge = -10,
				CurseBoosts = {
					WeightBoost = 50,
					Resilience = -50
				},
				CurseMutationPool = {
					["Hades' Curse"] = 100
				}
			}
		},
		ClientFishingPassives = {
			HadesCurse = {
				SpecialThreshold = 0
			},
			Wisps = {
				WispCountMin = 4,
				WispCountMax = 10,
				WispIntervalMin = 2,
				WispIntervalMax = 4,
				ResilienceFactor = 0.5,
				WispDamage = 4,
				WispDamageNight = 6,
				WispAnimTime = 1.5
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.Hades.DarkGate.WispsOffered",
					ExpectedValue = 100,
					FailMessage = "You have not opened the gate."
				},
				{
					Path = "WrathOfOlympus.Hades.DarkGate.DarkWispsOffered",
					ExpectedValue = 25,
					FailMessage = "You have not opened the gate."
				},
				{
					Path = "WrathOfOlympus.DivineSealsBroken.Zeus",
					ExpectedValue = true,
					FailMessage = "You have not yet broken Zeus's seal."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Hades' Underworld of Indefinite",
				Requirement = 100
			}
		},
		From = "Hades' Underworld of Indefinite",
		Hint = "Obtained by offering Wisps and navigating the Underworld's hidden path."
	},
	["Poseidon's Lance"] = {
		Icon = "rbxassetid://130549527827482",
		Price = 13000000,
		MinDistanceToPurchase = 30,
		Description = "A tide-commanding lance that calls crashing waves and crushing force upon its prey, pinning even the strongest fish in place beneath overwhelming pressure.",
		Luck = 175,
		LureSpeed = 15,
		Strength = 250000,
		LineDistance = 150,
		Resilience = 40,
		Control = 0,
		Color = Color3.fromRGB(97, 181, 255),
		BobberTop = Color3.fromRGB(97, 181, 255),
		BobberBottom = Color3.fromRGB(67, 69, 185),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		PreferredDisturbance = {
			Event = "TidecrasherArchonHunt",
			Risk = 9
		},
		LevelRequirement = 500,
		MutationPool = {
			["Tidal Surge"] = 25
		},
		FishingPassives = {
			PoseidonsLance = {
				MinInterval = 3,
				MaxInterval = 10,
				WeatherFactors = {
					Rain = 1.5,
					Stormy = 3,
					Tornado = 3
				},
				WaveDamage = 22,
				WaveDamageSpear = 44,
				WaveAnimTime = 2,
				StartSoundName = "waveIdle",
				HitSoundName = "waveImpact",
				EndSoundName = nil,
				LinkedSpears = { "Poseidon's Spear" }
			},
			SpearConversion = {
				LinkedSpear = "Poseidon's Spear"
			},
			Generic_WeatherBoosts = {
				Rain = {
					MutationPool = {
						["Tidal Surge"] = 5
					},
					Boosts = {
						WeightBoost = 10
					}
				},
				Stormy = {
					MutationPool = {
						["Tidal Surge"] = 15
					},
					Boosts = {
						WeightBoost = 10
					}
				},
				FishingTypes = { "rod", "spear" }
			}
		},
		ClientFishingPassives = {
			Impaling = {
				StabChance = 35,
				RollInterval = 1,
				MiddleThreshold = 0.35,
				StabDamage = 2,
				StunTime = 3,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Poseidon's Lance",
				VfxColor = Color3.fromRGB(105, 240, 255),
				SoundName = "lancestab"
			},
			SpearConversion = {
				LinkedSpear = "Poseidon's Spear",
				LinkedRod = "Poseidon's Lance"
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.DivineSealsBroken.Apollo",
					ExpectedValue = true,
					FailMessage = "You have not yet broken Apollo's seal."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Poseidon's Storm of Floods",
				Requirement = 100
			}
		},
		From = "Poseidon's Storm of Floods",
		Hint = "Obtained through offerings during a Storm Flood."
	},
	["Bellona's Waraxe"] = {
		Icon = "rbxassetid://77953497223025",
		Price = 5000000,
		MinDistanceToPurchase = 30,
		Description = "A relentless weapon of war that splits the very flow of the hunt, striking with constant force and turning a single catch into a chaotic clash of blades and opportunity.",
		Luck = 150,
		LureSpeed = 35,
		Strength = 1000000,
		LineDistance = 30,
		Resilience = 40,
		Control = 0.2,
		Color = Color3.fromRGB(255, 161, 124),
		BobberTop = Color3.fromRGB(255, 161, 124),
		BobberBottom = Color3.fromRGB(184, 67, 67),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		PreferredDisturbance = {
			Event = "LegionnaireLampreyHunt",
			Risk = 8
		},
		LevelRequirement = 200,
		MutationPool = {
			["Bellona's Fury"] = 20
		},
		FishingPassives = {
			BellonasWaraxe = {
				PassiveBlockLevel = 4
			}
		},
		ClientFishingPassives = {
			BellonasWaraxe = {},
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 30,
				SlashDamage = 10,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Bellona's Waraxe",
				SoundName = "stabbystab",
				IconName = "Default",
				IconColor = Color3.fromRGB(217, 88, 24),
				GradientColor = Color3.fromRGB(217, 88, 24)
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "WrathOfOlympus.Bellona.RoyalGuards.Guard1",
					ExpectedValue = true,
					FailMessage = "You can't buy this yet."
				},
				{
					Path = "WrathOfOlympus.Bellona.RoyalGuards.Guard2",
					ExpectedValue = true,
					FailMessage = "You can't buy this yet."
				},
				{
					Path = "WrathOfOlympus.Bellona.RoyalGuards.Guard3",
					ExpectedValue = true,
					FailMessage = "You can't buy this yet."
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Bellona's Frenzy of War",
				Requirement = 100
			}
		},
		From = "Bellona's Frenzy of War",
		Hint = "Obtained from Bellona's Royal Guards."
	},
	["Bunnybloom Caster"] = {
		Icon = "rbxassetid://70446451152530",
		Price = 1e999,
		Description = "bnuy",
		Luck = 150,
		LureSpeed = 10,
		Strength = 30000,
		LineDistance = 50,
		Resilience = 30,
		Control = -0.1,
		Color = Color3.fromRGB(238, 199, 255),
		BobberTop = Color3.fromRGB(238, 199, 255),
		BobberBottom = Color3.fromRGB(138, 138, 255),
		FishingPassives = {
			Generic_SeasonBoosts = {
				Spring = {
					Boosts = {
						ProgressSpeed = 75
					},
					MutationPool = {
						Bunny = 50
					}
				},
				Default = {
					Boosts = {
						ProgressSpeed = 50
					},
					MutationPool = {
						Bunny = 25
					}
				}
			}
		},
		From = "Egg Hunt 2026",
		Hint = "Obtained from the Bunny NPC after collecting all eggs.",
		Unpurchasable = true,
		Unregistered = true
	},
	["Splitbranch Twig"] = {
		Icon = "rbxassetid://75823970837273",
		Price = 25000,
		Description = "A brittle branch that beckons two catches at once, though something in the dark insists on taking more.",
		Luck = 100,
		LureSpeed = 15,
		Strength = 10000,
		LineDistance = 20,
		Resilience = 45,
		Control = -0.1,
		Color = Color3.fromRGB(66, 51, 46),
		BobberTop = Color3.fromRGB(66, 51, 46),
		BobberBottom = Color3.fromRGB(66, 51, 46),
		FishingPassives = {
			SelectiveFish = {
				AmountToChoose = 2,
				PassiveBlockLevel = 4,
				UseSplitbranchGimmick = true,
				GimmickRespectsPassiveBlock = true,
				GimmickPassiveBlockLevel = 1
			}
		},
		ClientFishingPassives = {
			SelectiveFishClient = {
				SelectTime = 3.5
			}
		},
		MutationPool = {
			Rotting = 35
		},
		From = "Everturn Forest",
		Hint = "Purchasable below a tree after perfectly catching 5 fish at Night.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		}
	},
	["Spirit of the Forest"] = {
		Icon = "rbxassetid://97699568146915",
		Price = 1e999,
		Unpurchasable = true,
		Description = "A living rod, bound to the forest’s breath, its power massively grows as the seasons remember you...",
		Luck = 70,
		LureSpeed = 60,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = -0.02,
		Color = Color3.fromRGB(79, 199, 70),
		BobberTop = Color3.fromRGB(79, 199, 70),
		BobberBottom = Color3.fromRGB(84, 65, 48),
		MutationPool = {
			["Forest Spirit"] = 5
		},
		FishingPassives = {
			Spirits = {
				SpawnChance = 20,
				Spirits = {
					Winter = {
						StatBoost = { "Resilience", 2 },
						WorldPrerequisite = { "season", "Winter", 1 },
						Max = 30
					},
					Spring = {
						StatBoost = { "Lure", 4 },
						WorldPrerequisite = { "season", "Spring", 1 },
						Max = 60
					},
					Summer = {
						StatBoost = { "Luck", 5 },
						WorldPrerequisite = { "season", "Summer", 1 },
						Max = 150
					},
					Autumn = {
						StatBoost = { "Control", 0.005 },
						WorldPrerequisite = { "season", "Autumn", 1 },
						Max = 0.15
					},
					Nightly = {
						StatBoost = { "ProgressSpeed", 5 },
						RollChance = 2,
						WorldPrerequisite = { "cycle", "Night", 2 },
						Max = 50
					}
				}
			}
		},
		From = "Everturn Forest",
		Hint = "Obtainable from Thalor Virewood.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		}
	},
	["Leprechaun Line"] = {
		Icon = "rbxassetid://94343930755276",
		Price = 1e999,
		Description = [=[
Only obtainable during Shamrock Seas;
A rod made of solid gold and pure luck, straight from the Leprechaun's and St. Patrick's spirit! [May increase server luck and grant the Lucky Gold mutation]]=],
		Luck = 350,
		LureSpeed = 45,
		Strength = 14000,
		LineDistance = 30,
		Resilience = 14,
		Control = 0,
		Color = Color3.fromRGB(48, 235, 76),
		BobberTop = Color3.fromRGB(48, 235, 54),
		BobberBottom = Color3.fromRGB(255, 202, 43),
		BaitEffectiveness = -0.9,
		BaitPreserveChance = -200,
		MutationPool = {
			["Lucky Gold"] = 10
		},
		FishingPassives = {
			ServerLuckOnMutation = {
				ServerLuckIncrease = 1,
				Duration = 45,
				MaxStack = 8,
				MaxDuration = 3600,
				BoostKey = "LeprechaunLine",
				TargetMutations = { "Lucky Gold" },
				DirectCatchOnly = true,
				NonPersistent = true
			},
			Generic_ExtraItemOnCatch = {
				PossibleItems = {
					["Four Leaf Clover"] = 1
				},
				DirectCatchOnly = true
			}
		},
		From = "Shamrock Seas",
		Hint = "Obtained from Clover Captain.",
		Unpurchasable = true,
		Unregistered = true
	},
	["Decayed Rod"] = {
		Icon = "rbxassetid://97582643677804",
		Price = 2000,
		MinDistanceToPurchase = 30,
		Description = "Pieced together with rotting remains of the Toxic Grove, where time itself seems to wither. Has a 50% chance to decay caught fish.",
		Luck = 40,
		LureSpeed = 25,
		Strength = 1000,
		LineDistance = 10,
		Resilience = -5,
		Control = -0.05,
		ProgressEfficiency = -0.05,
		Durability = 150,
		WeightBoost = 40,
		Color = Color3.fromRGB(50, 38, 66),
		BobberTop = Color3.fromRGB(50, 38, 66),
		BobberBottom = Color3.fromRGB(19, 14, 25),
		From = "Toxic Grove",
		Hint = "Purchasable at the Toxic Grove.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Decayed = 50,
			Withered = 10
		}
	},
	["Gardenkeeper Rod"] = {
		Icon = "rbxassetid://121831295530172",
		Price = 1e999,
		Description = "A relic said to have grown within the hidden heart of the Living Garden. Its vine-woven frame hums with quiet life, petals shifting as though stirred by unseen winds. Those who wield have a 25% chance to entangle fish the Floral mutation.",
		Luck = 120,
		LureSpeed = 5,
		Strength = 120000,
		LineDistance = 30,
		Resilience = 45,
		Control = 0.25,
		Color = Color3.fromRGB(66, 53, 52),
		BobberTop = Color3.fromRGB(66, 53, 52),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Living Garden",
		Hint = "Craftable at Level 300 at the Ancient Archives using flowers obtained from the Living Garden.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1500
			}
		},
		MutationPool = {
			Floral = 25
		},
		ClientFishingPassives = {
			RoseRod = {},
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 15,
				SlashDamage = 0,
				StunTime = 2.5,
				RawStun = false,
				SlashInterval = 0.8,
				SourceType = "rod",
				SourceName = "Rose Rod",
				SoundName = "stabbystab",
				IconName = "Rose",
				GradientColor = Color3.fromRGB(197, 36, 38)
			}
		}
	},
	["Toxinburst Rod"] = {
		Icon = "rbxassetid://83301897550767",
		Price = 400000,
		MinDistanceToPurchase = 30,
		Description = "Shaped from swollen toxic fungi of the corrupted grove, this rod seeps with unstable spores. Each cast stirs the water with a sickly bloom, as if the rot itself is waiting to burst.",
		Luck = 85,
		LureSpeed = 17,
		Strength = 125000,
		LineDistance = 30,
		Resilience = 30,
		Control = -0.02,
		PreferredDisturbance = {
			Event = "RotbloomHunt",
			Risk = 2
		},
		ProgressEfficiency = 0.3,
		Color = Color3.fromRGB(184, 84, 255),
		BobberTop = Color3.fromRGB(170, 73, 255),
		BobberBottom = Color3.fromRGB(45, 41, 30),
		From = "Toxic Grove",
		Hint = "Craftable at Level 150 at the Ancient Archives using parts obtained from the Toxic Grove.",
		LevelRequirement = 325,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		Durability = 150,
		MutationPool = {
			Noxious = 35,
			Toxic = 15
		},
		FishingPassives = {
			Toxinburst = {
				BuffId = "Propagation",
				RateIncreasePerStack = 0.25,
				ProgressRateIncreasePerStack = 0.025,
				MaxStack = 50,
				MinDuration = 60,
				ExtraDurationPerStack = 20,
				SpawnIntervalMin = 20,
				SpawnIntervalMax = 40,
				FungusLifetime = 3,
				ExplodeChance = 20,
				FishCountMin = 2,
				FishCountMax = 3,
				MutationPool = {
					Noxious = 100
				},
				RarityPool = {
					Trash = 10,
					Common = 28,
					Uncommon = 27,
					Unusual = 13,
					Rare = 43,
					Legendary = 3,
					Mythical = 2,
					Exotic = 1,
					Secret = 0.5,
					Apex = 1
				},
				PassiveBlockLevel = 0
			}
		},
		ClientFishingPassives = {
			["Poisonous Fungus"] = {
				BuffId = "Propagation",
				RateIncreasePerStack = 0.025,
				SpawnIntervalMin = 1,
				SpawnIntervalMax = 2,
				ProgressPerExplosion = 4,
				Color = Color3.fromRGB(159, 62, 255)
			}
		}
	},
	["Sweet-Stinger"] = {
		Icon = "rbxassetid://107086268117404",
		Price = 150000,
		MinDistanceToPurchase = 30,
		Description = "The Sweet-Stinger may only be wielded by those proficient in the art of apiculture. Bees befriend the holder!",
		Luck = 172,
		LureSpeed = -80,
		Strength = 1e999,
		LineDistance = 20,
		Resilience = -10,
		Control = 0.14,
		Disturbance = 3,
		PreferredDisturbance = {
			Event = "NectarBloom",
			Risk = 20
		},
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		FishingPassives = {
			Bees = {
				GiveRewards = true,
				WaitInterval = {
					Min = 45,
					Max = 90
				}
			},
			Generic_SeasonBoosts = {
				Default = {
					ZoneBoosts = {
						["Nectar Den"] = {
							ProgressSpeed = 15
						}
					}
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 2,
				StunTime = 0.05,
				RawStun = false,
				SlashInterval = 2,
				SlashComboMin = 3,
				SlashComboMax = 3,
				SlashComboInterval = 0.15,
				SourceType = "rod",
				SourceName = "Sweet-Stinger",
				AnimTime = 0.25,
				SoundName = "beeybee",
				IconName = "Default",
				IconColor = Color3.fromRGB(255, 212, 57),
				GradientColor = Color3.fromRGB(255, 165, 55)
			}
		},
		MutationPool = {
			Honey = 30
		},
		Color = Color3.fromRGB(255, 192, 3),
		BobberTop = Color3.fromRGB(255, 192, 3),
		BobberBottom = Color3.fromRGB(43, 35, 8),
		From = "Nectar Den",
		Hint = "Purchasable at the Nectar Den after completing the bestiary.",
		BestiaryRequirement = {
			{
				Island = "Nectar Den",
				Requirement = 100
			}
		}
	},
	Plaguereaver = {
		Icon = "rbxassetid://77297659910536",
		Price = 1e999,
		Description = "...",
		Luck = 175,
		LureSpeed = 85,
		Strength = 1e999,
		LineDistance = 500,
		Resilience = 0,
		Control = 0.4,
		Disturbance = 5,
		PreferredDisturbance = {
			Event = "RotbloomHunt",
			Risk = 5
		},
		ProgressEfficiency = 0.75,
		Color = Color3.fromRGB(26, 19, 34),
		BobberTop = Color3.fromRGB(26, 19, 34),
		BobberBottom = Color3.fromRGB(18, 15, 21),
		From = "Toxic Grove",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Durability = 150,
		DisturbanceContributionQuest = "Plaguereaver/Plaguereaver3-MASTERY",
		FishingPassives = {
			Generic_HardStatLimit = {
				Control = 0.6
			},
			Generic_FallingWeapon = {
				ModelScale = 2,
				TriggerChance = 100,
				ProgressGain = 40,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 35, 0),
				EndingOffset = CFrame.new(0, -47, 0),
				PivotOffset = CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0),
				FallAnimTime = 1,
				EasingStyle = Enum.EasingStyle.Quart,
				ShockwaveSize = 12,
				ShockwaveSizeEnd = 60,
				HitSoundName = "plaguereaver"
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 2,
				SlashDamage = 20,
				StunTime = 5,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Plaguereaver",
				SoundName = "stabbystab",
				IconName = "Default",
				GradientColor = Color3.fromRGB(25, 20, 34)
			}
		},
		MutationPool = {
			Plagued = 15
		},
		EnhancementPatches = {
			Mastery1 = {
				Lure = 25,
				Disturbance = 7,
				Durability = 200
			}
		},
		LevelRequirement = 850,
		Hint = "Obtained from the Plagued Reaper."
	},
	["Verdant Oath"] = {
		Icon = "rbxassetid://97167761500904",
		Price = 12500000,
		MinDistanceToPurchase = 30,
		Description = "Forged where ancient roots coil through sacred soil, this blade breathes with the quiet will of the wild; a living power bound by the forest’s timeless oath...",
		Luck = 300,
		LureSpeed = 5,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 75,
		Control = 0.1,
		Color = Color3.fromRGB(0, 255, 0),
		BobberTop = Color3.fromRGB(0, 245, 0),
		BobberBottom = Color3.fromRGB(52, 83, 46),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 3000
			}
		},
		Durability = 150,
		FixedStats = {
			Control = 0.1
		},
		ProgressEfficiency = 0.35,
		ForcedProgressEfficiency = 0.15,
		ReelGuiName = "verdantoath",
		FishingPassives = {
			Generic_PerfectBoost = {
				MutationPool = {
					Verdant = 100
				}
			}
		},
		ClientFishingPassives = {
			VerdantOath = {
				InitialSize = 0.2,
				ZoneGrowRate = 0.025,
				ExitZonePenalty = 20,
				BrokenBarLossRate = 10,
				ZoneShrinkRate = 0.1,
				MinSplitBarSize = 0.1,
				MaxGreenZoneSize = 0.6,
				MaxResilienceLoss = 0.1,
				MaxFishSpeed = 0.1,
				StopMovementAfter = 70
			}
		},
		MutationPool = {
			Blossomed = 40
		},
		BestiaryRequirement = {
			{
				Island = "Living Garden",
				Requirement = 100
			},
			{
				Island = "Toxic Grove",
				Requirement = 100
			},
			{
				Island = "Nectar Den",
				Requirement = 100
			}
		},
		LevelRequirement = 1000,
		From = "Living Garden",
		Hint = "Purchasable at a hidden location after completing every bestiary below the Lost Jungle and reaching Level 1000."
	},
	Bloomspire = {
		Icon = "rbxassetid://115167790947787",
		Price = 1250000,
		MinDistanceToPurchase = 30,
		Description = "Grown from living vines and crowned with a single, slumbering blossom, this rod changes with the flowers bound to it. Its true nature is never fixed; each bloom awakens a different power within the spire.",
		Luck = 0,
		LureSpeed = 85,
		Strength = 1000,
		LineDistance = 150,
		Resilience = 10,
		Control = 0,
		Color = Color3.fromRGB(168, 136, 114),
		BobberTop = Color3.fromRGB(216, 216, 216),
		BobberBottom = Color3.fromRGB(83, 83, 83),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		VariantGroup = "Bloomspire",
		VariantIcon = "rbxassetid://116582083970494",
		VariantOrder = 4,
		From = "Living Garden",
		Hint = "Reap from a seed blessed by a Flower Guardian."
	},
	["Herald of Justice"] = {
		Icon = "rbxassetid://111825152430209",
		Price = 1e999,
		Description = "Throughout Heaven and Earth, I alone am the honored one. (not finished)",
		Luck = 444,
		LureSpeed = -455,
		Strength = 1e999,
		LineDistance = 1500,
		Resilience = 222,
		Control = 0.05,
		Color = Color3.fromRGB(255, 225, 0),
		BobberTop = Color3.fromRGB(216, 216, 216),
		BobberBottom = Color3.fromRGB(255, 217, 0),
		MutationPool = {
			["King’s Blessing"] = 3,
			Greedy = 5,
			Midas = 10
		},
		ReelGuiName = "heraldofjustice",
		FishingPassives = {
			HeraldOfJustice = {}
		},
		ClientFishingPassives = {
			HeraldOfJusticeClient = {
				PERFECT_STUN_CHANCE = 0.5,
				PERFECT_STUN_DURATION = 5,
				SLASH_INTERVAL = 1.5,
				SLASH_COOLDOWN = 0.5,
				SLASH_ZONE_WIDTH = 0.1,
				SLASH_PROGRESS_BONUS = 12.5,
				SLASH_STUN_DURATION = 2,
				MAX_INITIAL_PROGRESS = 5
			}
		},
		Cool = true,
		DEV = true,
		Unregistered = true,
		Unpurchasable = true
	},
	["Bloomspire: Blooming Splendor"] = {
		Icon = "rbxassetid://105470571384180",
		Price = 1e999,
		Description = "Imbued with the power of the Living Lotus, only the healthist of fish are attracted. Each slash sows another.",
		Luck = 200,
		LureSpeed = 5,
		Strength = 1000000,
		Resilience = 20,
		LineDistance = 150,
		Control = 0.2,
		Color = Color3.fromRGB(172, 255, 171),
		BobberTop = Color3.fromRGB(172, 255, 171),
		BobberBottom = Color3.fromRGB(88, 130, 87),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		PreferredDisturbance = {
			Event = "FlowerGuardianHunt",
			Risk = 15
		},
		VariantGroup = "Bloomspire",
		VariantIcon = "rbxassetid://127103963758900",
		VariantOrder = 1,
		WeightBoost = 25,
		MutationPool = {
			Vitalic = 50
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 10,
				SlashDamage = 1.5,
				SlashInterval = 2,
				SlashRamp = 1.5,
				SlashComboMin = 1,
				SlashComboMax = 1,
				SlashComboRamp = 1,
				SlashComboInterval = 0.15,
				SourceType = "rod",
				SourceName = "Bloomspire",
				SoundName = "bloomspireLivingSlash",
				SoundPitch = 0.75,
				SlashComboPitch = 0.1,
				AnimTime = 0.25,
				IconName = "Default",
				IconColor = Color3.fromRGB(171, 255, 62),
				GradientColor = Color3.fromRGB(171, 255, 62)
			}
		},
		From = "Living Garden",
		Hint = "Obtained by harnessing the power of a Living Lotus.",
		Unpurchasable = true
	},
	["Bloomspire: Twisted Toxins"] = {
		Icon = "rbxassetid://79676351909109",
		Price = 1e999,
		Description = "Imbued with the power of the Toxic Lotus, each slash hastens the fish's demise.",
		Luck = 125,
		LureSpeed = 20,
		Strength = 250000,
		Resilience = -200,
		Control = -0.04,
		LineDistance = 150,
		Color = Color3.fromRGB(176, 79, 255),
		BobberTop = Color3.fromRGB(176, 79, 255),
		BobberBottom = Color3.fromRGB(83, 37, 121),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		PreferredDisturbance = {
			Event = "FlowerGuardianHunt",
			Risk = 10
		},
		Durability = 200,
		VariantGroup = "Bloomspire",
		VariantIcon = "rbxassetid://73118572472188",
		VariantOrder = 2,
		WeightBoost = -20,
		MutationPool = {
			Tainted = 40,
			Poisoned = 10
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 10,
				StunTime = 1,
				RawStun = false,
				OnlyOnBar = true,
				SourceType = "rod",
				SourceName = "Bloomspire",
				AnimTime = 0.7,
				SoundName = "bloomspireToxicSlash",
				IconName = "Default",
				IconColor = Color3.fromRGB(152, 40, 217),
				GradientColor = Color3.fromRGB(152, 40, 217),
				IconSizeFull = UDim2.fromScale(20.376, 9)
			},
			BloomspireToxic = {
				DamageRelative = true,
				ProgressSpeed = 0.9,
				ForcedProgressSpeed = 0.1,
				ProgressSpeedDecay = 10,
				ForcedProgressSpeedDecay = 2
			}
		},
		From = "Living Garden",
		Hint = "Obtained by harnessing the power of a Toxic Lotus.",
		Unpurchasable = true
	},
	["Bloomspire: Slumbering Elegance"] = {
		Icon = "rbxassetid://111138406977786",
		Price = 1e999,
		Description = "Imbued with the power of the Dream Orchid, periodic slashes stop the fish in its tracks.",
		Luck = 175,
		LureSpeed = 30,
		Strength = 25000,
		Resilience = 30,
		Control = 0.1,
		ProgressEfficiency = 0.25,
		LineDistance = 150,
		Color = Color3.fromRGB(255, 201, 239),
		BobberTop = Color3.fromRGB(255, 201, 239),
		BobberBottom = Color3.fromRGB(133, 127, 167),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		PreferredDisturbance = {
			Event = "FlowerGuardianHunt",
			Risk = 20
		},
		VariantGroup = "Bloomspire",
		VariantIcon = "rbxassetid://117422267214679",
		VariantOrder = 3,
		MutationPool = {
			Dreaming = 85,
			Bliss = 15
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 100,
				SlashDamage = 10,
				StunTime = 2,
				RawStun = false,
				SlashInterval = 4,
				SourceType = "rod",
				SourceName = "Bloomspire",
				SoundName = "bloomspireDreamSlash",
				IconName = "Default",
				IconColor = Color3.fromRGB(255, 201, 239),
				GradientColor = Color3.fromRGB(255, 201, 239)
			}
		},
		From = "Living Garden",
		Hint = "Obtained by harnessing the power of a Dream Orchid.",
		Unregistered = true,
		Unpurchasable = true
	},
	["Daybreaker Rod"] = {
		Icon = "rbxassetid://112148270617779",
		Price = 750000,
		Description = "An instrument of rising suns, the Daybreaker grows radiant in places of intense heat, reshaping fate as daylight strengthens its will.",
		Luck = 125,
		LureSpeed = 30,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 25,
		Control = -0.05,
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "SkeletalLeviathanHunt",
			Risk = 1
		},
		ProgressEfficiency = 0.15,
		Color = Color3.fromRGB(255, 228, 120),
		BobberTop = Color3.fromRGB(255, 228, 120),
		BobberBottom = Color3.fromRGB(45, 41, 30),
		From = "Scoria Reach",
		BestiaryRequirement = {
			{
				Island = "Scoria Reach",
				Requirement = 50
			}
		},
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		Durability = 100,
		FishingPassives = {
			Daybreaker = {
				SOLAR_BASE_CHANCE = 25,
				HOT_ZONE_STAT_MULT = 2,
				SKIP_STATS = {
					"BaitEffectiveness",
					"TimeEffectiveness",
					"WeatherEffectiveness",
					"SeasonEffectiveness",
					"StartingProgress"
				}
			}
		},
		LevelRequirement = 50,
		Hint = "Purchasable at the town located near the center of Scoria Reach."
	},
	["Microphone Rod"] = {
		Icon = "rbxassetid://126015973851188",
		Price = 1e999,
		Description = "am i mutted?",
		Luck = 80,
		LureSpeed = 0,
		Strength = 200,
		LineDistance = 30,
		Resilience = 30,
		Control = 0,
		MutationPool = {
			Amped = 10
		},
		Color = Color3.fromRGB(197, 197, 197),
		BobberTop = Color3.fromRGB(72, 72, 72),
		BobberBottom = Color3.fromRGB(25, 25, 25),
		Unpurchasable = true,
		Unregistered = true,
		From = "Streamer Hideout",
		Hint = "Obtainable during Twitch RB Battles event.",
		Tags = { "Instrument" }
	},
	["Igneous Rupturer"] = {
		Icon = "rbxassetid://87880062657159",
		Price = 5000000,
		MinDistanceToPurchase = 30,
		Description = [[
A blade forged in the heart of a living volcano, the Igneous Rupturer thrums with tectonic fury;
Its strikes split the waters with molten spires, sometimes branding fish with the Igneous mutation.]],
		Luck = 100,
		LureSpeed = 40,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 85,
		Control = 0.3,
		Disturbance = 11,
		PreferredDisturbance = {
			Event = "SkeletalLeviathanHunt",
			Risk = 2
		},
		ProgressEfficiency = 0.2,
		Color = Color3.fromRGB(255, 102, 0),
		BobberTop = Color3.fromRGB(255, 102, 0),
		BobberBottom = Color3.fromRGB(255, 221, 53),
		From = "Scoria Reach",
		BestiaryRequirement = {
			{
				Island = "Scoria Reach",
				Requirement = 100
			}
		},
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 20000
			}
		},
		Durability = 200,
		FishingPassives = {
			IgneousRupturer = {
				HitInterval = 2.8,
				DecayTime = 5
			}
		},
		ClientFishingPassives = {
			IgneousRupturer = {}
		},
		MutationPool = {
			Igneous = 50
		},
		LevelRequirement = 500,
		Hint = "Purchasable within the Volcanic Depths after completing the bestiary and reaching Level 500."
	},
	["Rose Rod"] = {
		Icon = "rbxassetid://138170572823538",
		Price = 2140,
		LocalCurrency = "Chocolates",
		Description = [[
Only obtainable during Valentides;
A thorned promise of beauty and pain, blooming wherever its line is casted.]],
		Luck = 65,
		LureSpeed = 30,
		Strength = 15000,
		LineDistance = 20,
		Resilience = 2,
		Control = 0.14,
		Color = Color3.fromRGB(165, 39, 39),
		BobberTop = Color3.fromRGB(165, 39, 39),
		BobberBottom = Color3.fromRGB(38, 81, 45),
		MutationPool = {
			Rose = 30
		},
		ClientFishingPassives = {
			RoseRod = {},
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 80,
				SlashDamage = 1,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Rose Rod",
				SoundName = "stabbystab",
				IconName = "Rose",
				GradientColor = Color3.fromRGB(197, 36, 38)
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Valentides 2.",
		From = "Valentides 2"
	},
	["Cupid's Bow"] = {
		Icon = "rbxassetid://93717720159219",
		Price = 25000,
		LocalCurrency = "Chocolates",
		Description = [[
Only obtainable during Valentides;
A divine arrow strung with love, striking twice when destiny allows.]],
		Luck = 125,
		LureSpeed = -20,
		Strength = 1e999,
		LineDistance = 500,
		Resilience = -5,
		Control = -0.02,
		ProgressEfficiency = 0.3,
		Color = Color3.fromRGB(255, 242, 169),
		BobberTop = Color3.fromRGB(255, 242, 169),
		BobberBottom = Color3.fromRGB(255, 162, 250),
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Valentides 2.",
		From = "Valentides 2",
		MutationPool = {
			Lovestruck = 60,
			Heartburst = 10
		},
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 20,
				PassiveBlockLevel = 3
			}
		},
		ReelGuiName = "cupidsbow",
		ClientFishingPassives = {
			["Cupid's Bow"] = {},
			Generic_KillSimplified = {}
		},
		Requirements = {
			PlayerAttributes = {
				{
					Name = "ReachedCupidsIsland",
					ExpectedValue = true,
					FailMessage = "💔"
				}
			}
		},
		Tags = { "Bow" }
	},
	["Cupid's Embrace"] = {
		Icon = "rbxassetid://134546072504759",
		Price = 1e999,
		Description = [[
Only obtainable during Valentides;
A staff bound by fate, growing stronger when hearts and hooks align.]],
		Luck = 214,
		LureSpeed = 30,
		Strength = 225000,
		LineDistance = 30,
		Resilience = 14,
		Control = 0.1,
		Color = Color3.fromRGB(255, 153, 211),
		BobberTop = Color3.fromRGB(255, 153, 211),
		BobberBottom = Color3.fromRGB(255, 232, 193),
		MutationPool = {
			Embraced = 25
		},
		FishingPassives = {
			CupidsEmbrace = {
				ProximityRange = 25,
				BuffData = {
					PassiveBoosts = {
						ProgressSpeed = 25
					},
					MutationPool = {
						Embraced = 15
					}
				}
			}
		},
		ClientFishingPassives = {
			CupidsEmbrace = {
				ResilienceGainRate = 1.4,
				ProgressSpeedDecayRate = 0.02,
				HeartInterval = 1,
				ProximityRange = 25
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Valentides 2.",
		From = "Valentides 2"
	},
	["Brine-Infused Rod"] = {
		Icon = "rbxassetid://138793509414691",
		Price = 75000,
		MinDistanceToPurchase = 30,
		Description = "The Brine-Infused Rod was designed by a researcher who studied the Brine Pool for a living; it was kept as a secret until he mysteriously went missing... The rod has a 50% chance to grant the Brined mutation.",
		Luck = 50,
		LureSpeed = 60,
		Strength = 650000,
		LineDistance = 40,
		Resilience = 350,
		Control = 0,
		Color = Color3.fromRGB(53, 255, 178),
		BobberTop = Color3.fromRGB(71, 255, 178),
		BobberBottom = Color3.fromRGB(63, 63, 63),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		Durability = 200,
		Disturbance = 1,
		PreferredDisturbance = {
			Event = "BrineStorm",
			Risk = 5
		},
		MutationPool = {
			Brined = 50
		},
		Cool = true,
		From = "Brine Pool",
		Hint = "Purchasable near the heights of the Brine Pool; a very difficult reach."
	},
	["Masterline Rod"] = {
		Icon = "rbxassetid://95926377052917",
		Price = 1e999,
		Description = [[
Only granted to truly dedicated Fischers;
A true masterpiece, no catch is too strong for the Masterline...]],
		Luck = 350,
		LureSpeed = -900,
		Strength = 1e999,
		LineDistance = 250,
		Resilience = 50,
		Control = 0.2,
		ProgressEfficiency = 0.5,
		Disturbance = 3,
		ForcedProgressEfficiency = 0.25,
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(255, 255, 255),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		Durability = 200,
		MutationPool = {
			Ascended = 30,
			Blessed = 25
		},
		FishingPassives = {
			Generic_FinalWeightMultiplier = {
				Multiplier = 1,
				MaxMultiplier = 2.25
			}
		},
		ClientFishingPassives = {
			Generic_DimScreen = {
				OverlayTransprency = 0.75,
				FadeInTime = 1,
				FadeOutTime = 1
			},
			MoonlightRay = {
				FlingTime = 1,
				MinInterval = 1,
				MaxInterval = 3,
				BeamWidth = 0.15,
				ProgressGain = 7.5,
				DisableCenterFling = true
			}
		},
		ShinyChance = 8,
		SparklingChance = 8,
		ReelGuiName = "masterline",
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					RandomPassives = {
						IntervalMin = 300,
						IntervalMax = 300,
						CountMin = apply_op.ADD(1),
						CountMax = apply_op.ADD(1),
						BlacklistRods = {
							"Dave Rod",
							"Tryhard Rod",
							"Masterline Rod",
							"Cinder Block Rod",
							"Silly Fun Happy Rod",
							"Wingripper",
							"Requiem",
							"Leprechaun Line",
							"Tranquility Rod",
							"Cupid's Bow",
							"Maelstrom",
							"Verdant Oath",
							"Spirit of the Forest",
							"Apollo's Sunshot",
							"Lullaby",
							"Upside-Down Rod",
							"Clover Rod",
							"Part",
							"Magnet Rod",
							"Bellona's Waraxe"
						},
						SingletonPassives = {
							"Pinion's Aria",
							"Merlin's Staff",
							"Cornucopia",
							"Cryolash",
							"Dreambreaker",
							"Generic_DimScreen",
							"Jack-o-Blazer",
							"Jinglestar Rod",
							"GlorpBlade",
							"Fabulous Rod",
							"Generic_FallingWeapon",
							"Generic_Laser",
							"Tidemourner",
							"SelectiveFish",
							"SelectiveFishClient",
							"HadesCurse",
							"StarcallerCry",
							"StarcallerCryClient",
							"MeteorShower",
							"LemonadeSerenade",
							"MysteryBox",
							"WisdomPassive",
							"Toxinburst",
							"Generic_TieredBoosts"
						},
						BlacklistPassives = {
							"RandomPassives",
							"RandomPassivesClient",
							"Generic_ForcedReplacePool",
							"Generic_HardStatLimit",
							"Generic_ReelRecolor",
							"Generic_ServerGift",
							"ControlToProgress",
							"SpearConversion",
							"HarpoonGunConversion",
							"Generic_FixedProgressSpeed",
							"Remembrance",
							"Generic_WeldAccessory",
							"MultiFish"
						},
						IncludeStats = {
							"ShinyChance",
							"SparklingChance",
							"WeightBoost",
							"Disturbance",
							"BaitPreserveChance",
							"BaitEffectiveness",
							"TimeEffectiveness",
							"SeasonEffectiveness",
							"WeatherEffectiveness",
							"XpMultiply",
							"Scavenging"
						},
						IncludeMutationPools = true,
						IncludeOwnedLimiteds = true,
						RequirePassiveOrMutation = true,
						NeverDev = true
					}
				},
				ClientFishingPassives = {
					RandomPassivesClient = {}
				}
			},
			Mastery2 = {
				FishingPassives = {
					RandomPassives = {
						CountMin = apply_op.ADD(1),
						CountMax = apply_op.ADD(1)
					}
				}
			},
			Mastery3 = {
				FishingPassives = {
					RandomPassives = {
						CountMin = apply_op.ADD(1),
						CountMax = apply_op.ADD(1),
						LockEnabled = true
					}
				},
				ClientFishingPassives = {
					RandomPassivesClient = {
						LockEnabled = true
					}
				}
			}
		},
		Cool = true,
		Unregistered = true,
		NotLimited = true,
		Unpurchasable = true,
		LevelRequirement = 1000,
		From = "Full Bestiary & Journal Completion",
		Hint = "Obtained by completing the entire Fisch Bestiary and Rod Journal",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100000
			}
		}
	},
	["Thalassar's Ruin"] = {
		Icon = "rbxassetid://118254108935404",
		Price = 14500000,
		Description = "A trident of ancient collapse, lashing the ocean in brutal bursts and dragging forgotten prey from the abyssal fog...",
		Luck = 250,
		LureSpeed = -100,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = -75,
		Control = -0.2,
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "Goldwraith",
			Risk = 4
		},
		ProgressEfficiency = -0.25,
		Color = Color3.fromRGB(159, 24, 24),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		From = "Tidefall",
		ReelGuiName = "thalassar'sruin",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 25000
			}
		},
		MutationPool = {
			["Ocean's Ruin"] = 30
		},
		MutationPoolCatchOnly = true,
		FishingPassives = {
			Thalassar = {
				CATCH_INTERVAL = 25,
				PASSIVE_MUTATION_POOL = {
					Forgotten = 90,
					["Ocean's Ruin"] = 10
				},
				MAX_CATCHES = 10,
				PASSIVE_BLOCK_LEVEL = 0
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 80,
				SlashDamage = 1,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Thalassar's Ruin",
				SoundName = "stabbystab",
				IconName = "Thalassar's Ruin",
				GradientColor = Color3.fromRGB(139, 19, 19)
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "Tidefall.ThalassarRuin.DoorOpened",
					ExpectedValue = true,
					FailMessage = "You have not yet unlocked this area."
				}
			}
		},
		Hint = "Purchasable somewhere near the underwater cave of Tidefall; a part of Thalassar's Secret."
	},
	["Anchor n' Chain"] = {
		Icon = "rbxassetid://92558219139622",
		Price = 1e999,
		Description = "A heavy anchor covered with rust and wrapped in chains; Always hauls in several catches, but the weight slows your reeling progress.",
		Luck = 50,
		LureSpeed = 200,
		Strength = 5000000,
		LineDistance = 50,
		Resilience = 100,
		Control = 0.5,
		ProgressEfficiency = -0.1,
		Color = Color3.fromRGB(143, 69, 34),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 3,
		PreferredDisturbance = {
			Event = "Plesiosaur",
			Risk = 2
		},
		MutationPool = {
			Rusty = 10
		},
		FishingPassives = {
			Anchor_N_Chain = {
				UNIQUE_CATCHES_AMOUNT = 3,
				PASSIVE_BLOCK_LEVEL = 0
			}
		},
		From = "Tidefall",
		Hint = "Craftable at Level 25 at the Ancient Archives using an anchor and some scraps."
	},
	Requiem = {
		Icon = "rbxassetid://94059757390277",
		Price = 1e999,
		Description = "A solemn staff that sings with arcane finality; measured strikes bring reward, but reckless hands invite erasure...",
		Luck = 277,
		LureSpeed = -20,
		Strength = 1500000,
		LineDistance = 100,
		Resilience = 63,
		Control = 0.1,
		Color = Color3.fromRGB(0, 255, 140),
		BobberTop = Color3.fromRGB(0, 12, 7),
		BobberBottom = Color3.fromRGB(0, 255, 140),
		ReelGuiName = "requiem",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 20000
			}
		},
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "Omnithal",
			Risk = 3
		},
		MutationPool = {
			Husk = 20
		},
		FishingPassives = {
			RequiemStaff = {
				TargetMutations = { "Husk" },
				DefaultWeightMult = 0.4,
				DuplicateWeightMult = 1.6,
				DuplicateMutationPool = {
					Requies = 100
				}
			}
		},
		ClientFishingPassives = {
			Requiem = {
				ProgressPerClick = 5,
				ClickThreshold = 0.3,
				FailThreshold = 0.15,
				ForcedProgressSpeedThreshold = -50,
				ForcedProgressSpeedConfig = {
					ProgressPerClick = 2,
					ClickThreshold = 0.4,
					FailThreshold = 0.15
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Husk = 25
				}
			},
			Mastery2 = {
				ClientFishingPassives = {
					Requiem = {
						ForcedProgressSpeedConfig = {
							ProgressPerClick = 2.5
						}
					}
				}
			}
		},
		Unpurchasable = true,
		From = "Sunken Reliquary",
		Hint = "Craftable at Level 1000 at the Ancient Archives using essences and a core earned from the Magical Diver."
	},
	["Fallen Rod"] = {
		Icon = "rbxassetid://104842347068863",
		Price = 175000,
		MinDistanceToPurchase = 30,
		Description = "A bone-ridden rod steeped in depth-bound sorrow, growing stronger the further it descends into the ocean's shadow.",
		Luck = 95,
		LureSpeed = 30,
		Strength = 80000,
		LineDistance = 20,
		Resilience = 30,
		Control = 0.12,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		FishingPassives = {
			FallenRod = {
				Y_LEVEL_THRESHOLD = -400,
				SIZE_BOOST = 0.5,
				DEFAULT_SIZE_PENALTY = 0.25,
				MutationPool = {
					Fallen = 50
				}
			}
		},
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(253, 251, 255),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		From = "Tidefall",
		Hint = "Purchasable at Tidefall."
	},
	["Coral Rod"] = {
		Icon = "rbxassetid://86145530693470",
		Price = 30000,
		MinDistanceToPurchase = 30,
		Description = "Grown rather than crafted, this living coral rod hums with reefbound life; Has a 50% chance to grant the Coral mutation.",
		Luck = 74,
		LureSpeed = 28,
		Strength = 10000,
		LineDistance = 20,
		Resilience = 40,
		Control = 0.02,
		ProgressEfficiency = 0.1,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 800
			}
		},
		MutationPool = {
			Coral = 50
		},
		Color = Color3.fromRGB(255, 157, 226),
		BobberTop = Color3.fromRGB(255, 157, 226),
		BobberBottom = Color3.fromRGB(98, 255, 103),
		From = "Coral Bastion",
		BestiaryRequirement = {
			{
				Island = "Coral Bastion",
				Requirement = 50
			}
		},
		Hint = "Purchasable at the Coral Bastion after completing 50% of the bestiary.",
		Disturbance = 1,
		PreferredDisturbance = {
			Event = "ReefTitan",
			Risk = 2
		}
	},
	Tidemourner = {
		Icon = "rbxassetid://133986741248643",
		Price = 1e999,
		Description = "A tide-forged hammer that answers strength with violence; every perfect strike echoes like a funeral bell beneath the waves.",
		Luck = 250,
		LureSpeed = 50,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 0,
		Control = 0.4,
		Color = Color3.fromRGB(33, 122, 255),
		BobberTop = Color3.fromRGB(17, 144, 255),
		BobberBottom = Color3.fromRGB(32, 37, 47),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		MutationPool = {
			Mourned = 35
		},
		FishingPassives = {
			TidemournerRod = {}
		},
		ClientFishingPassives = {
			Tidemourner = {
				PERFECT_STUN_CHANCE = 0.5,
				PERFECT_STUN_DURATION = 5,
				TIME_ON_BAR_FOR_HAMMER = 5,
				HAMMER_STUN_DURATION = 2,
				HAMMER_PROGRESS_BONUS = 8,
				HAMMER_COOLDOWN = 3,
				MAX_INITIAL_PROGRESS = 25
			}
		},
		Unpurchasable = true,
		From = "Tidefall",
		Hint = "Craftable using a key part found in Tidefall at the Ancient Archives at Level 200.",
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "Pliosaur",
			Risk = 2
		}
	},
	["Boreal Rod"] = {
		Icon = "rbxassetid://80907973781207",
		Price = 42000,
		MinDistanceToPurchase = 30,
		Description = "A frostbitten rod carved from northern pines, imbuing catches with quiet, creeping cold.",
		Luck = 50,
		LureSpeed = 40,
		Strength = 14000,
		LineDistance = 30,
		Resilience = 25,
		Control = 0.05,
		Color = Color3.fromRGB(66, 53, 52),
		BobberTop = Color3.fromRGB(66, 53, 52),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Boreal Pines",
		Hint = "Purchasable at Boreal Pines.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		PreferredDisturbance = {
			Event = "FrostwyrmHunt",
			Risk = 4
		},
		MutationPool = {
			Boreal = 40
		}
	},
	Cryolash = {
		Icon = "rbxassetid://122666397342667",
		Price = 3500000,
		MinDistanceToPurchase = 30,
		Description = "A brutal cryogenic rod that hurls icicle spears at hooked prey, trading stability for explosive frozen progress.",
		Luck = 200,
		LureSpeed = 40,
		Strength = 500000,
		LineDistance = 30,
		Resilience = 75,
		Control = -0.05,
		Color = Color3.fromRGB(116, 243, 255),
		BobberTop = Color3.fromRGB(116, 243, 255),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Boreal Pines",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		FishingPassives = {
			Cryolash = {
				InitialDelay = 2,
				MinSpawnInterval = 4,
				MaxSpawnInterval = 5
			}
		},
		ClientFishingPassives = {
			Cryolash = {}
		},
		LevelRequirement = 650,
		BestiaryRequirement = {
			{
				Island = "Boreal Pines",
				Requirement = 100
			}
		},
		MutationPool = {
			Frozen = 50,
			Glacial = 25
		},
		Hint = "Purchasable at the Boreal Pines after completing the bestiary and reaching Level 650.",
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "FrostwyrmHunt",
			Risk = 8
		}
	},
	["North Pole"] = {
		Icon = "rbxassetid://100962714811886",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A mercilessly precise rod forged for mastery, rewarding unyielding freezing strength...]],
		Luck = 177,
		LureSpeed = 10,
		Strength = 1e999,
		LineDistance = 80,
		Resilience = 25,
		Control = 0,
		Color = Color3.fromRGB(21, 169, 177),
		BobberTop = Color3.fromRGB(21, 169, 177),
		BobberBottom = Color3.fromRGB(39, 46, 48),
		Unregistered = true,
		Unpurchasable = true,
		MutationPool = {
			Permafrost = 25
		},
		SlashDamage = 12,
		SlashChance = 24,
		LevelRequirement = 500,
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 24,
				SlashDamage = 12,
				StunTime = 0.25,
				RawStun = false,
				SourceType = "rod",
				SourceName = "North Pole",
				SoundName = "stabbystab",
				IconName = "Default",
				IconColor = Color3.fromRGB(21, 169, 177),
				GradientColor = Color3.fromRGB(21, 169, 177)
			},
			["North Pole"] = {}
		},
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Peppermint Rod"] = {
		Icon = "rbxassetid://96712713222760",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A candy cane radiating icy cheer. All fish have a 25% chance to be Peppermint.]],
		Luck = 50,
		LureSpeed = -250,
		Strength = 10000,
		LineDistance = 20,
		Resilience = 12,
		Control = 0.12,
		Color = Color3.fromRGB(255, 157, 157),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		MutationPool = {
			Peppermint = 25
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Gingerbread Rod"] = {
		Icon = "rbxassetid://135064454685691",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A delicious and festive gingerbread cookie built rod! All fish have a 25% chance to be Gingerbread.]],
		Luck = 65,
		LureSpeed = 50,
		Strength = 2000,
		LineDistance = 20,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(113, 61, 31),
		BobberTop = Color3.fromRGB(113, 61, 31),
		BobberBottom = Color3.fromRGB(171, 36, 36),
		MutationPool = {
			Gingerbread = 25
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Santa's Miracle Rod"] = {
		Icon = "rbxassetid://111066699561888",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A festive rod blessed by Santa himself. Fish have a 20% chance to gain the Santa mutation, a 10% chance to gain any natural Fischmas mutation, and magically spawned presents. Each catch also has a 10% chance to be magically gifted your Fischmas pals!]],
		Luck = 125,
		LureSpeed = -25,
		Strength = 1e999,
		LineDistance = 25,
		Resilience = 25,
		Control = 0.25,
		Color = Color3.fromRGB(212, 0, 0),
		BobberTop = Color3.fromRGB(194, 0, 0),
		BobberBottom = Color3.fromRGB(245, 212, 80),
		MutationPool = {
			Santa = 20,
			Peppermint = 3.3333333333333335,
			Gingerbread = 3.3333333333333335,
			Merry = 3.3333333333333335
		},
		FishingPassives = {
			Generic_ServerGift = {
				GiftChance = 10,
				BlockedRarities = { "Divine Secret" },
				GiftMessage = "%s has gifted everyone with Santa's Miracle Rod!"
			}
		},
		ClientFishingPassives = {
			["Santa's Miracle Rod"] = {},
			Generic_KillSimplified = {}
		},
		Unregistered = true,
		Unpurchasable = true,
		LevelRequirement = 100,
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Jinglestar Rod"] = {
		Icon = "rbxassetid://123108775462382",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A legendary rod of starlight and bells, its full strength will return when real Christmas magic awakens...]],
		Luck = 122.5,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 5,
		Control = 0.4,
		ProgressEfficiency = 0.25,
		Color = Color3.fromRGB(230, 209, 92),
		BobberTop = Color3.fromRGB(230, 209, 92),
		BobberBottom = Color3.fromRGB(230, 215, 161),
		MutationPool = {
			["Jingle Bell"] = 25
		},
		ClientFishingPassives = {
			["Jinglestar Rod"] = {}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Christmas Tree Rod"] = {
		Icon = "rbxassetid://80035892379740",
		Price = 1e999,
		Description = [[
Only obtainable during Fischmas;
A festively lit tree repurposed as a rod! All fish have a 25% chance to be Merry.]],
		Luck = 75,
		LureSpeed = 50,
		Strength = 1e999,
		LineDistance = 20,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(3, 126, 59),
		BobberTop = Color3.fromRGB(3, 126, 59),
		BobberBottom = Color3.fromRGB(94, 66, 42),
		MutationPool = {
			Merry = 25
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2"
	},
	["Merlin's Staff"] = {
		Icon = "rbxassetid://109429886727687",
		Price = 1e999,
		Description = "Channels Merlin's rift-woven magic to trap unsuspecting fish between realms...",
		Luck = 254,
		LureSpeed = 20,
		Strength = 1e999,
		LineDistance = 20,
		Resilience = 50,
		Control = 0.1,
		Color = Color3.fromRGB(193, 70, 255),
		BobberTop = Color3.fromRGB(193, 70, 255),
		BobberBottom = Color3.fromRGB(145, 99, 42),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 6500
			}
		},
		MutationPool = {
			Magical = 35
		},
		ClientFishingPassives = {
			["Merlin's Staff"] = {},
			Generic_KillSimplified = {}
		},
		Unpurchasable = true,
		From = "Sunstone",
		Hint = "Obtained from Merlin himself."
	},
	Dreambreaker = {
		Icon = "rbxassetid://94411844017115",
		Price = 1e999,
		Description = "A rod born of torment and twilight, empowering night fishing with violent surges and larger prey; but twisting the mind with slower progress and unpredictable control.",
		Luck = 215,
		LureSpeed = -20,
		Strength = 1e999,
		LineDistance = 30,
		Resilience = 66,
		Control = 0.23,
		Color = Color3.fromRGB(36, 36, 36),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		ProgressEfficiency = 0.15,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 8500
			}
		},
		Disturbance = 4,
		PreferredDisturbance = {
			Event = "The Sanctum Hunt",
			Risk = 15
		},
		FishingPassives = {
			Generic_TimeBoosts = {
				Night = {
					MutationPool = {
						Distraught = 35
					},
					Boosts = {
						WeightBoost = 50,
						ForcedProgressSpeed = -15
					}
				},
				Day = {
					MutationPool = {
						Distraught = 25
					},
					Boosts = {
						WeightBoost = -50
					}
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 33,
				SlashDamage = 5,
				StunTime = 0.05,
				RawStun = false,
				SlashInterval = 0.25,
				RequiredConditions = {
					cycle = "Night"
				},
				SourceType = "rod",
				SourceName = "Dreambreaker",
				SoundName = "dreambreakerSlash",
				IconName = "Dreambreaker",
				GradientColor = Color3.fromRGB(0, 0, 0)
			},
			Dreambreaker = {},
			Generic_KillSimplified = {}
		},
		EnhancementPatches = {
			Mastery1 = {
				ProgressSpeed = 10
			}
		},
		Unpurchasable = true,
		LevelRequirement = 500,
		From = "Cultist Lair",
		Hint = "Obtained from The Restless One."
	},
	["Lucid Rod"] = {
		Icon = "rbxassetid://106306084065245",
		Price = 1e999,
		Description = "A radiant rod that channels the power of dreams, granting the Lucid mutation and rarely cloning catches; particularly under clear skies.",
		Luck = 100,
		LureSpeed = 20,
		Strength = 500000,
		LineDistance = 30,
		Resilience = 45,
		Control = -0.05,
		Color = Color3.fromRGB(188, 111, 255),
		BobberTop = Color3.fromRGB(226, 108, 255),
		BobberBottom = Color3.fromRGB(123, 96, 255),
		ProgressEfficiency = 0.1,
		LevelRequirement = 50,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 4500
			}
		},
		FishingPassives = {
			Generic_WeatherBoosts = {
				Clear = {
					MutationPool = {
						Lucid = 30
					}
				},
				Default = {
					MutationPool = {
						Lucid = 20
					}
				}
			},
			["Lucid Rod"] = {
				TargetWeathers = { "Clear" },
				CloneRequiredMutations = { "Lucid" },
				DefaultCloneCount = 1,
				TargetWeatherCloneCount = 2
			}
		},
		Unpurchasable = true,
		From = "Cultist Lair",
		Hint = "Craftable at Level 50 after fulfilling Tessael's request."
	},
	["Eidolon Rod"] = {
		Icon = "rbxassetid://108306128914739",
		Price = 2000000,
		MinDistanceToPurchase = 30,
		Description = "A spectral rod infused with phantom energy, hastening progress and drawing forth the Phantom mutation; even completing your catch as reality begins to fade...",
		Luck = 50,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 30,
		Resilience = 0,
		Control = 0.25,
		Color = Color3.fromRGB(57, 57, 57),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		ProgressEfficiency = 0.4,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5500
			}
		},
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "The Sanctum Hunt",
			Risk = 25
		},
		MutationPool = {
			Phantom = 35
		},
		ClientFishingPassives = {
			["Eidolon Rod"] = {
				ProgressThreshold = 70,
				ProgressBoost = 100,
				BarSize = 1
			}
		},
		Requirements = {
			DataValues = {
				{
					Path = "TerrapinExpansion.UnlockedSanctum",
					ExpectedValue = true,
					FailMessage = "You must unlock The Sanctum before purchasing this rod."
				}
			}
		},
		LevelRequirement = 350,
		From = "Cultist Lair",
		Hint = "Purchasable at The Sanctum after reaching Level 350.",
		Cool = true
	},
	["Dusekkar Rod"] = {
		Icon = "rbxassetid://98629791425762",
		Price = 1e999,
		Description = [[
Only obtainable during FischFright;
Haunted by the fireless spirit of Matt Dusek; this rod is haunted with a spectral blaze...]],
		Luck = 166,
		LureSpeed = 20,
		Strength = 700000,
		LineDistance = 30,
		Resilience = 80,
		Control = 0.05,
		Color = Color3.fromRGB(46, 60, 255),
		BobberTop = Color3.fromRGB(46, 60, 255),
		BobberBottom = Color3.fromRGB(255, 203, 17),
		ProgressEfficiency = 0.25,
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 20,
				SlashDamage = 12,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Dusekkar Rod",
				SoundName = "stabbystabdusekkar",
				IconName = "Dusekkar Rod",
				GradientColor = "Dusekkar Rod"
			}
		},
		MutationPool = {
			Nightmare = 20
		},
		Unpurchasable = true,
		Unregistered = true,
		LevelRequirement = 100,
		Hint = "Obtainable during FischFright 2.",
		From = "FischFright 2"
	},
	["Spooky Rod"] = {
		Icon = "rbxassetid://91633899156296",
		Price = 1e999,
		Description = [[
Only obtainable during FischFright;
The rod is cursed with the constant energy of FischFright, allowing it to catch FischFright mutations all year round.]],
		Luck = 66,
		LureSpeed = 25,
		Strength = 150000,
		LineDistance = 20,
		Resilience = -10,
		Control = 0.2,
		Color = Color3.fromRGB(68, 61, 91),
		BobberTop = Color3.fromRGB(255, 161, 53),
		BobberBottom = Color3.fromRGB(68, 61, 91),
		ProgressEfficiency = 0.05,
		MutationPool = {
			Spooky = 10,
			Frightful = 10,
			Eerie = 10
		},
		ClientFishingPassives = {
			["Spooky Rod"] = {}
		},
		Unpurchasable = true,
		Unregistered = true,
		Hint = "Obtainable during FischFright 2.",
		From = "FischFright 2"
	},
	["Bat Whisperer Rod"] = {
		Icon = "rbxassetid://87198849891806",
		Price = 1e999,
		Description = [[
Only obtainable during FischFright;
A cursed rod that summons swarms of bats to snatch fish from the water; their numbers multiplying under unknown conditions...]],
		Luck = 96,
		LureSpeed = 14,
		Strength = 200000,
		LineDistance = 45,
		Resilience = 30,
		Control = 0.15,
		Color = Color3.fromRGB(181, 58, 58),
		BobberTop = Color3.fromRGB(181, 58, 58),
		BobberBottom = Color3.fromRGB(54, 42, 40),
		ProgressEfficiency = 0.1,
		FishingPassives = {
			["Bat Whisperer"] = {
				RARITY_WEIGHTS = {
					Trash = 10,
					Common = 18,
					Uncommon = 17,
					Unusual = 13,
					Rare = 13,
					Legendary = 11,
					Mythical = 8,
					Exotic = 5,
					Secret = 2,
					Limited = 1,
					Apex = 1
				},
				POOL_BLACKLIST = {},
				CATCH_COOLDOWN = 30,
				PASSIVE_BLOCK_LEVEL = 0,
				BAT_MUTATION_POOL = {
					Batty = 100
				},
				RETRY_DELAY = 1,
				BAT_SEARCH_RADIUS = 50,
				FISHING_DURATION = 15,
				VISIBILITY_UPDATE_INTERVAL = 1
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		LevelRequirement = 100,
		Hint = "Obtainable during FischFright 2.",
		From = "FischFright 2"
	},
	["Necrotic Rod"] = {
		Icon = "rbxassetid://73470162208118",
		Price = 1e999,
		Description = [[
Only obtainable during FischFright;
A rod infused with necrotic energy that saps the life from its prey, reeling in fish as their vitality withers away.]],
		Luck = 143,
		LureSpeed = 18,
		Strength = 400000,
		LineDistance = 50,
		Resilience = 66,
		Control = 0.05,
		Color = Color3.fromRGB(67, 45, 45),
		BobberTop = Color3.fromRGB(93, 0, 0),
		BobberBottom = Color3.fromRGB(33, 26, 26),
		ProgressEfficiency = 0.13,
		MutationPool = {
			Necrotic = 30
		},
		ClientFishingPassives = {
			["Necrotic Rod"] = {}
		},
		Cool = true,
		Unpurchasable = true,
		Unregistered = true,
		LevelRequirement = 100,
		Hint = "Obtainable during FischFright 2.",
		From = "FischFright 2"
	},
	["Jack-o-Blazer"] = {
		Icon = "rbxassetid://94483525287284",
		Price = 1e999,
		Description = [[
Only obtainable during FischFright;
A flame-engulfed rod wreathed in halloween-spirit, launching blazing jack-o-lanterns that explode on impact; incinerating the waters and anything daring to swim within!]],
		Luck = 166.6,
		LureSpeed = 4,
		Strength = 1e999,
		LineDistance = 80,
		Resilience = 66,
		Control = 0.16,
		Color = Color3.fromRGB(255, 201, 66),
		BobberTop = Color3.fromRGB(255, 201, 66),
		BobberBottom = Color3.fromRGB(0, 120, 12),
		ProgressEfficiency = 0.15,
		MutationPool = {
			Wicked = 20,
			["Jack's Curse"] = 2
		},
		FishingPassives = {
			PumpkinRain = {
				InitialDelay = 2,
				PumpkinInterval = 1,
				PumpkinMinTime = 0.9,
				PumpkinMaxTime = 1.1,
				PumpkinProgress = 8
			}
		},
		ClientFishingPassives = {
			["Jack-o-Blazer"] = {}
		},
		Unpurchasable = true,
		Unregistered = true,
		LevelRequirement = 100,
		Hint = "Obtainable during FischFright 2.",
		From = "FischFright 2"
	},
	["Cinder Block Rod"] = {
		Icon = "rbxassetid://70848292796768",
		Price = 50000,
		MinDistanceToPurchase = 30,
		Description = "seems a little heavy...",
		Luck = 350,
		LureSpeed = 150,
		Strength = 100000000000,
		LineDistance = 15,
		Resilience = 1000,
		Control = 0.7,
		Color = Color3.fromRGB(138, 138, 138),
		BobberTop = Color3.fromRGB(171, 171, 171),
		BobberBottom = Color3.fromRGB(66, 66, 66),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		ForcedProgressEfficiency = -0.85,
		FixedStats = {
			ProgressSpeed = -85
		},
		MutationPool = {
			Cement = 70
		},
		ClientFishingPassives = {
			Generic_FixedProgressSpeed = {
				FixedProgressEfficiency = 0.15,
				DisplayFormat = "So heavy..."
			}
		},
		From = "Ocean",
		Hint = "Purchasable at the Oil Rig.",
		Disturbance = 3
	},
	["Random Rod"] = {
		Icon = "rbxassetid://127719699084418",
		Price = RngUtil.ServerSharedRandom("RandomRodPrice"):NextInteger(1, 9999999),
		MinDistanceToPurchase = 30,
		Description = "?",
		Luck = 350,
		LureSpeed = 20,
		Strength = 1e999,
		LineDistance = 25,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(138, 138, 138),
		BobberTop = Color3.fromRGB(171, 171, 171),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		LevelRequirement = 100,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 10000
			}
		},
		MutationPool = {
			Jackpot = 50,
			Unlucky = 50
		},
		ReelGuiName = "randomrod",
		FishingPassives = {
			RandomRod = {
				LOW_WEIGHT_MULTIPLIER = 0.5,
				HIGH_WEIGHT_MULTIPLIER = 2,
				WEIGHT_CHANCE = 50,
				MIN_BOOSTS = {
					Resilience = -80,
					Control = -0.3,
					ProgressSpeed = -77
				},
				MAX_BOOSTS = {
					Resilience = 80,
					Control = 0.3,
					ProgressSpeed = 100
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					RandomRod = {
						LOW_WEIGHT_MULTIPLIER = 0.5,
						HIGH_WEIGHT_MULTIPLIER = 2,
						WEIGHT_CHANCE = 50,
						MIN_BOOSTS = {
							Resilience = -40,
							Control = -0.1,
							ProgressSpeed = -33
						},
						MAX_BOOSTS = {
							Resilience = 80,
							Control = 0.4,
							ProgressSpeed = 100
						}
					}
				}
			},
			Mastery2 = {
				FishingPassives = {
					MysteryBox = {
						Effects = {
							progress_up1 = {
								DisplayName = "+10% Progress!",
								Icon = "rbxassetid://87645220868691",
								Color = Color3.fromRGB(119, 196, 255),
								Type = "progress",
								Value = 10,
								ChanceWeight = 10,
								MaxCount = nil
							},
							progress_up2 = {
								DisplayName = "+25% Progress!!",
								Icon = "rbxassetid://87645220868691",
								Color = Color3.fromRGB(98, 255, 169),
								Type = "progress",
								Value = 25,
								ChanceWeight = 5,
								MaxCount = nil
							},
							progress_up3 = {
								DisplayName = "+50% Progress!!!",
								Icon = "rbxassetid://87645220868691",
								Color = Color3.fromRGB(96, 255, 71),
								Type = "progress",
								Value = 50,
								ChanceWeight = 1,
								MaxCount = nil
							},
							progress_down1 = {
								DisplayName = "-10% Progress...",
								Icon = "rbxassetid://124708149818755",
								Color = Color3.fromRGB(255, 208, 67),
								Type = "progress",
								Value = -10,
								ChanceWeight = 10,
								MaxCount = nil
							},
							progress_down2 = {
								DisplayName = "-25% Progress...",
								Icon = "rbxassetid://124708149818755",
								Color = Color3.fromRGB(255, 169, 64),
								Type = "progress",
								Value = -25,
								ChanceWeight = 5,
								MaxCount = 3
							},
							progress_down3 = {
								DisplayName = "-50% Progress...",
								Icon = "rbxassetid://124708149818755",
								Color = Color3.fromRGB(255, 81, 58),
								Type = "progress",
								Value = -50,
								ChanceWeight = 1,
								MaxCount = 1
							},
							freeze_fish = {
								DisplayName = "Freeze Fish!",
								Icon = "rbxassetid://70776930982385",
								Color = Color3.fromRGB(162, 230, 255),
								Type = "freeze_fish",
								Value = 5,
								ChanceWeight = 2,
								MaxCount = nil
							},
							freeze_player = {
								DisplayName = "Freeze YOU!",
								Icon = "rbxassetid://71832084988430",
								Color = Color3.fromRGB(255, 37, 88),
								Type = "freeze_player",
								Value = 5,
								ChanceWeight = 1,
								MaxCount = 1
							},
							weight_up1 = {
								DisplayName = "+10% Fish Weight!",
								Icon = "rbxassetid://119131287642594",
								Color = Color3.fromRGB(67, 148, 255),
								Type = "weight",
								Value = 1.1,
								ChanceWeight = 10,
								MaxCount = 5
							},
							weight_up2 = {
								DisplayName = "+25% Fish Weight!!",
								Icon = "rbxassetid://119131287642594",
								Color = Color3.fromRGB(224, 110, 255),
								Type = "weight",
								Value = 1.25,
								ChanceWeight = 2,
								MaxCount = 2
							},
							weight_up3 = {
								DisplayName = "+50% Fish Weight!!!",
								Icon = "rbxassetid://75031005553960",
								Color = Color3.fromRGB(255, 205, 106),
								Type = "weight",
								Value = 1.5,
								ChanceWeight = 1,
								MaxCount = 1
							},
							weight_down1 = {
								DisplayName = "-10% Fish Weight...",
								Icon = "rbxassetid://122405578684033",
								Color = Color3.fromRGB(255, 225, 75),
								Type = "weight",
								Value = 0.9,
								ChanceWeight = 10,
								MaxCount = 5
							},
							weight_down2 = {
								DisplayName = "-25% Fish Weight...",
								Icon = "rbxassetid://86064639913098",
								Color = Color3.fromRGB(255, 131, 43),
								Type = "weight",
								Value = 0.75,
								ChanceWeight = 2,
								MaxCount = 2
							},
							weight_down3 = {
								DisplayName = "-50% Fish Weight...",
								Icon = "rbxassetid://76096030826986",
								Color = Color3.fromRGB(255, 41, 62),
								Type = "weight",
								Value = 0.5,
								ChanceWeight = 1,
								MaxCount = 1
							},
							control_up = {
								DisplayName = "+0.1 Control!",
								Icon = "rbxassetid://92054477930182",
								Color = Color3.fromRGB(88, 255, 79),
								Type = "control",
								Value = 0.1,
								ChanceWeight = 10,
								MaxCount = nil
							},
							control_down = {
								DisplayName = "-0.1 Control...",
								Icon = "rbxassetid://129158012646654",
								Color = Color3.fromRGB(255, 166, 76),
								Type = "control",
								Value = -0.1,
								ChanceWeight = 10,
								MaxCount = nil
							},
							player_speed_up = {
								DisplayName = "+50% Bar Speed!",
								Icon = "rbxassetid://88692655785368",
								Color = Color3.fromRGB(85, 255, 76),
								Type = "player_speed",
								Value = 1.5,
								ChanceWeight = 5,
								MaxCount = nil
							},
							player_speed_down = {
								DisplayName = "-50% Bar Speed...",
								Icon = "rbxassetid://88692655785368",
								Color = Color3.fromRGB(255, 127, 76),
								Type = "player_speed",
								Value = 0.5,
								ChanceWeight = 5,
								MaxCount = nil
							},
							fish_speed_up = {
								DisplayName = "+50% Fish Speed...",
								Icon = "rbxassetid://88692655785368",
								Color = Color3.fromRGB(255, 166, 76),
								Type = "fish_speed",
								Value = 0.75,
								ChanceWeight = 5,
								MaxCount = nil
							},
							fish_speed_down = {
								DisplayName = "-50% Fish Speed!",
								Icon = "rbxassetid://88692655785368",
								Color = Color3.fromRGB(83, 255, 74),
								Type = "fish_speed",
								Value = 1.5,
								ChanceWeight = 5,
								MaxCount = nil
							},
							bird = {
								DisplayName = "What! It's nothing but a useless bird!",
								Icon = "rbxassetid://103669792037664",
								Color = Color3.fromRGB(255, 214, 65),
								Type = "bird",
								Value = nil,
								ChanceWeight = 3,
								MaxCount = nil
							},
							luck_buff = {
								DisplayName = "+100 Luck!",
								Icon = "rbxassetid://18198637843",
								Color = Color3.fromRGB(0, 255, 106),
								Type = "buff",
								Value = {
									BuffId = "Luck",
									BuffDuration = 300,
									BuffData = {
										Stack = 20,
										BoostValue = 100
									}
								},
								ChanceWeight = 4,
								MaxCount = 1
							},
							luck_debuff = {
								DisplayName = "-100 Luck...",
								Icon = "rbxassetid://139695287607406",
								Color = Color3.fromRGB(126, 96, 46),
								Type = "buff",
								Value = {
									BuffId = "Unlucky",
									BuffDuration = 300,
									BuffData = {
										Stack = 20,
										BoostValue = -100
									}
								},
								ChanceWeight = 4,
								MaxCount = 1
							},
							fire = {
								DisplayName = "AAAAAAAAAAAAA",
								Icon = "rbxassetid://18197272991",
								Color = Color3.fromRGB(255, 156, 34),
								Type = "buff",
								Value = {
									BuffId = "Fire",
									BuffDuration = 5,
									BuffData = {
										Stack = 3,
										Damage = 12
									}
								},
								ChanceWeight = 1,
								MaxCount = nil
							},
							progspeed_up = {
								DisplayName = "+25% Progress Speed!",
								Icon = "rbxassetid://81833802199325",
								Color = Color3.fromRGB(85, 255, 76),
								Type = "progspeed",
								Value = 0.25,
								ChanceWeight = 10,
								MaxCount = nil
							},
							progspeed_down = {
								DisplayName = "-25% Progress Speed...",
								Icon = "rbxassetid://137361806231060",
								Color = Color3.fromRGB(255, 157, 58),
								Type = "progspeed",
								Value = -0.25,
								ChanceWeight = 10,
								MaxCount = nil
							}
						},
						MinInterval = 3,
						MaxInterval = 7,
						BaseOpenTime = 1,
						DecayTime = 2
					}
				},
				ClientFishingPassives = {
					MysteryBox = {}
				}
			}
		},
		From = "Anywhere or Daily Shopkeeper",
		Hint = "Purchasable from the Daily Shopkeeper or randomly around the sea."
	},
	["Elder Mossripper"] = {
		Icon = "rbxassetid://114701867275895",
		Price = 1e999,
		Description = "Ancient fangs lash at the hooked, forcing weight to rise drastically. With a chance for the Shrouded and Mossy mutations; the lurking Mossjaw waits to strike...",
		Luck = 215,
		LureSpeed = 10,
		Strength = 1e999,
		LineDistance = 125,
		Resilience = 50,
		Control = 0.2,
		Disturbance = 3,
		PreferredDisturbance = {
			Event = "MossjawHunt",
			Risk = 8
		},
		Color = Color3.fromRGB(115, 206, 90),
		BobberTop = Color3.fromRGB(239, 255, 237),
		BobberBottom = Color3.fromRGB(73, 124, 84),
		ProgressEfficiency = 0.3,
		WeightBoost = 45,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 9500
			}
		},
		MutationPool = {
			Mossy = 15,
			Shrouded = 20
		},
		FishingPassives = {
			ElderMossripper = {
				Cooldown = 120,
				PassiveMutationPool = {
					Mossy = 100
				},
				RarityWeights = {
					Legendary = 27,
					Mythical = 23,
					Exotic = 20,
					Secret = 15,
					Apex = 10
				},
				PassiveBlockLevel = 2
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					ElderMossripper = {
						Cooldown = 60
					}
				}
			}
		},
		Unpurchasable = true,
		LevelRequirement = 350,
		From = "Lost Jungle",
		Hint = "Craftable at Level 350 after catching the beasts of the temple."
	},
	["Toxic Spire Rod"] = {
		Icon = "rbxassetid://105529359815955",
		Price = 1e999,
		Description = "Tainted power seeps into the catch, slowing it with each struggle. When catching a fish with the Toxic mutation, the fish will be paralyzed completely, granting 70% faster progress.",
		Luck = 248,
		LureSpeed = 13,
		Strength = 100000,
		LineDistance = 75,
		Resilience = -20,
		Control = 0.3,
		Color = Color3.fromRGB(124, 97, 206),
		BobberTop = Color3.fromRGB(194, 174, 255),
		BobberBottom = Color3.fromRGB(182, 180, 119),
		Durability = 150,
		ProgressEfficiency = 0.2,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Toxic = 25
		},
		ClientFishingPassives = {
			["Toxic Spire Rod"] = {}
		},
		Cool = true,
		Unpurchasable = true,
		Disturbance = 2,
		From = "Lost Jungle",
		Hint = "Craftable at Level 90 after completing the rising toxic water puzzle in the forgotten temple."
	},
	["Vineweaver Rod"] = {
		Icon = "rbxassetid://130375644975614",
		Price = 1e999,
		Description = "Vines twist across the line, halting prey in its tracks. In the last 30%, the fish is bound, with a 30% chance of gaining a Vined form. [+10% Forced Progress Speed]",
		Luck = 117,
		LureSpeed = 20,
		Strength = 50000,
		LineDistance = 15,
		Resilience = 40,
		Control = 0.1,
		Color = Color3.fromRGB(92, 165, 72),
		BobberTop = Color3.fromRGB(38, 139, 58),
		BobberBottom = Color3.fromRGB(84, 62, 31),
		ForcedProgressEfficiency = 0.1,
		ProgressEfficiency = 0.1,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Vined = 30,
			Shrouded = 15
		},
		ClientFishingPassives = {
			["Vineweaver Rod"] = {}
		},
		Unpurchasable = true,
		From = "Lost Jungle",
		Hint = "Craftable at Level 70 after completing the vine puzzle in the forgotten temple."
	},
	["Vinefang Rod"] = {
		Icon = "rbxassetid://123396519009292",
		Price = 1e999,
		Description = [[
Only obtainable during Jungle's Echo Bone Hunt; 
A fragile rod of bone and vine, hiding absurd, untamed power that awakens only in the Jungle.]],
		ProgressEfficiency = 0.5,
		Luck = 117,
		LureSpeed = 20,
		Strength = 25000,
		LineDistance = 20,
		Resilience = -16,
		Control = -0.11,
		Color = Color3.fromRGB(115, 206, 90),
		BobberTop = Color3.fromRGB(239, 255, 237),
		BobberBottom = Color3.fromRGB(73, 124, 84),
		FishingPassives = {
			Shark = {
				CatchRequirement = 2,
				RequirePerfect = true,
				ModelName = "Vinefang",
				BlockedRarities = { "Limited", "Gemstone", "Seed" },
				PassiveBlockLevel = 0,
				SharkMutationPool = {},
				MinWeightBoost = 1,
				MaxWeightBoost = 1
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 15,
				SlashDamage = 1,
				StunTime = 1,
				RawStun = false,
				SlashInterval = 1,
				SlashComboMin = 3,
				SlashComboMax = 5,
				SlashComboInterval = 0.3,
				SourceType = "rod",
				SourceName = "Vinefang Rod",
				AnimTime = 0.4,
				SoundName = "vinefangSlash",
				IconName = "Vinefang Rod",
				IconColor = Color3.fromRGB(2, 127, 0),
				GradientColor = Color3.fromRGB(13, 127, 0)
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Jungle's Echo Bone Hunt.",
		From = "Jungle's Echo"
	},
	["The Boom Ball"] = {
		Icon = "rbxassetid://100107717413221",
		Price = 50000,
		MinDistanceToPurchase = 30,
		Description = "how could this possibly be a good idea?",
		Luck = 0,
		LureSpeed = 100,
		Strength = 500000000,
		LineDistance = 50,
		Resilience = -500,
		Control = 0.5,
		Color = Color3.fromRGB(55, 58, 74),
		BobberTop = Color3.fromRGB(55, 58, 74),
		BobberBottom = Color3.fromRGB(161, 161, 161),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1500
			}
		},
		Disturbance = 5,
		MutationPool = {
			Exploded = 50
		},
		FishingPassives = {
			Generic_BoostStatsForMutation = {
				Exploded = {
					ProgressSpeed = 100
				}
			},
			TheBoomBallVFX = {
				TargetMutations = { "Exploded" },
				ExplosionVolume = 1
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Exploded = 100
				},
				FishingPassives = {
					TheBoomBallVFX = {
						ExplosionVolume = 2
					}
				}
			}
		},
		Cool = true,
		From = "Desolate Deep",
		Hint = "Purchasable after an absurd amount of explosion related deaths."
	},
	["Experimental Rod"] = {
		Icon = "rbxassetid://113112697751756",
		Description = "Something seems off...",
		Luck = 123.4567,
		LureSpeed = 87.7654,
		Strength = 123.4567,
		LineDistance = 123.4567,
		Resilience = 12.3456,
		Control = 0.1234,
		Color = Color3.fromRGB(154, 170, 190),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		ReelGuiName = "experimentalrod",
		Unregistered = true,
		Unpurchasable = true,
		From = "The Takeover",
		Hint = "Obtained from the Takeover Challenger."
	},
	["Rod of the Cosmos"] = {
		Icon = "rbxassetid://81458874828170",
		Price = 1e999,
		Description = [[
Only obtainable during Continental Drift; 
Has a 15% chance for the Nova mutation, and +50% Progress Speed during Starfall; with a chance to catch Cosmic Relics.]],
		Luck = 135,
		LureSpeed = 50,
		Strength = 10000,
		LineDistance = 200,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(93, 193, 255),
		BobberTop = Color3.fromRGB(90, 184, 255),
		BobberBottom = Color3.fromRGB(255, 195, 98),
		MutationPool = {
			Nova = 15
		},
		FishingPassives = {
			Generic_WeatherBoosts = {
				Starfall = {
					FishPool = {
						["Cosmic Relic"] = 2
					},
					Boosts = {
						ProgressSpeed = 50
					}
				},
				Default = {
					FishPool = {
						["Cosmic Relic"] = 0.1
					}
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Continental Drift.",
		From = "Continental Drift"
	},
	["Tidal Wave Rod"] = {
		Icon = "rbxassetid://105552468878440",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest; 
A crashing surge of power with a 20% chance to wash your fish in Beachy style, and a small chance to infuse it with the glow of Summer!]],
		Luck = 65,
		LureSpeed = 50,
		Strength = 8500,
		LineDistance = 30,
		Resilience = 20,
		Control = 0.1,
		Color = Color3.fromRGB(88, 169, 255),
		BobberTop = Color3.fromRGB(89, 155, 255),
		BobberBottom = Color3.fromRGB(254, 255, 192),
		MutationPool = {
			Beachy = 20,
			Summer = 5
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest.",
		From = "Fischfest"
	},
	["Paper Fan Rod"] = {
		Icon = "rbxassetid://133475644061237",
		Price = 70000,
		Description = [[
Only obtainable during Fischfest; 
A lightweight paper fan rod that slices through the water, striking fish with swift, cutting blows.]],
		Luck = 75,
		LureSpeed = 30,
		Strength = 1500,
		LineDistance = 30,
		Resilience = 10,
		Control = -0.05,
		Color = Color3.fromRGB(255, 255, 134),
		BobberTop = Color3.fromRGB(255, 160, 206),
		BobberBottom = Color3.fromRGB(255, 255, 134),
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 70,
				SlashDamage = 1.5,
				StunTime = 0.1,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Paper Fan Rod",
				SoundName = "stabbystabpaperfan",
				IconName = "Paper Fan Rod",
				GradientColor = "Paper Fan Rod"
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest.",
		From = "Fischfest"
	},
	["Popsicle Rod"] = {
		Icon = "rbxassetid://79202008064865",
		Price = 1e999,
		Description = [[
Only obtainable during Fischfest; 
A frozen delight with a 15% chance to feed a fish a popsicle, and greatly increased progress speed during Summer!]],
		Luck = 150,
		LureSpeed = 0,
		Strength = 100,
		LineDistance = 30,
		Resilience = 0,
		Control = 0,
		Color = Color3.fromRGB(0, 221, 255),
		BobberTop = Color3.fromRGB(0, 221, 255),
		BobberBottom = Color3.fromRGB(255, 0, 4),
		MutationPool = {
			Popsicle = 15
		},
		FishingPassives = {
			Generic_SeasonBoosts = {
				Summer = {
					Boosts = {
						ProgressSpeed = 50
					}
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Fischfest.",
		From = "Fischfest"
	},
	["Superstar Rod"] = {
		Icon = "rbxassetid://83352494018645",
		Price = 1e999,
		Description = "It glows with unmatched shopping energy!",
		Luck = 70,
		LureSpeed = 50,
		Strength = 10000,
		LineDistance = 200,
		Resilience = 15,
		Control = 0.1,
		Color = Color3.fromRGB(47, 98, 207),
		BobberTop = Color3.fromRGB(255, 235, 21),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		Unregistered = true,
		From = "Walmart Event",
		Hint = "Walmart Event purchase exclusive."
	},
	["Great Rod of Oscar"] = {
		Icon = "rbxassetid://134829568024925",
		ProgressEfficiency = 0.3,
		Price = 2500000,
		MinDistanceToPurchase = 30,
		Description = "A relic of the Dead Mans Tale, with a moderate boost to experience... Has a chance to apply the spirits of Oscar.",
		Luck = 280,
		LureSpeed = 5,
		Strength = 100000,
		LineDistance = 150,
		Resilience = 20,
		Control = 0.1,
		Color = Color3.fromRGB(225, 182, 11),
		BobberTop = Color3.fromRGB(158, 29, 29),
		BobberBottom = Color3.fromRGB(74, 38, 12),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 9000
			}
		},
		MutationPool = {
			Oscar = 20
		},
		XpMultiply = 0.35,
		From = "Ocean",
		Hint = "A secret of the Dead Mans Tale.",
		LevelRequirement = 250,
		Requirements = {
			DataInstanceRequiriment = {
				"QuestFinished.DeadMansTale",
				true,
				"An ancient curse prevents you from purchasing this now."
			}
		}
	},
	["Lobster Rod"] = {
		Icon = "rbxassetid://96060253091803",
		Price = 1e999,
		Description = "As tough as a lobster's shell, built to withstand immense force. Has a 30% chance to apply the Lobster mutation.",
		Luck = 110,
		LureSpeed = 40,
		Strength = 50000,
		LineDistance = 20,
		Resilience = 10,
		Control = 0.3,
		Color = Color3.fromRGB(171, 0, 0),
		BobberTop = Color3.fromRGB(195, 67, 67),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Waveborne",
		MutationPool = {
			Lobster = 30
		},
		FishingPassives = {
			LobsterVFX = {
				TriggerOnMutations = { "Lobster" }
			}
		},
		Unregistered = true
	},
	["Carrot Rod"] = {
		Icon = "rbxassetid://93433983978773",
		Price = 45000,
		MinDistanceToPurchase = 30,
		Description = "Rich in nutrients!",
		Luck = 125,
		LureSpeed = 15,
		Strength = 10000,
		LineDistance = 35,
		Resilience = 25,
		Control = 0.15,
		ProgressEfficiency = 0.15,
		Color = Color3.fromRGB(255, 175, 38),
		BobberTop = Color3.fromRGB(55, 191, 34),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Carrot Garden",
		Hint = "Purchasable at the Carrot Garden.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 900
			}
		},
		BestiaryRequirement = {
			{
				Island = "Carrot Garden",
				Requirement = 100
			}
		},
		MutationPool = {
			Carrot = 25
		},
		FishingPassives = {
			CarrotRod = {
				PoolSpawnChance = 10,
				PoolMutation = "Carrot",
				PoolMutationChance = 15,
				Duration = 60
			}
		}
	},
	["Brother's Rod"] = {
		Icon = "rbxassetid://108982992846517",
		Price = 1e999,
		Description = "Built from a brother's bond, grants a 20% chance to duplicate and mutate fish.",
		Luck = 70,
		LureSpeed = 30,
		Strength = 3000,
		LineDistance = 25,
		Resilience = 10,
		Control = 0.1,
		Color = Color3.fromRGB(75, 207, 196),
		BobberTop = Color3.fromRGB(60, 195, 186),
		BobberBottom = Color3.fromRGB(176, 255, 246),
		From = "Isle of New Beginnings",
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 20,
				DuplicateMutation = "Brother",
				PassiveBlockLevel = 3
			}
		},
		Hint = "Obtained from Luka.",
		Unregistered = true
	},
	["Adventurer's Rod"] = {
		Icon = "rbxassetid://118199056040351",
		Price = 0,
		Description = "It has a feeble, yet strangely familiar feel... Has a 5% chance to equally grant any natural mutation.",
		Luck = 50,
		LureSpeed = 40,
		Strength = 104,
		LineDistance = 19,
		Resilience = 15,
		Control = 0,
		Color = Color3.fromRGB(154, 170, 190),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Waveborne",
		Unregistered = true,
		Hint = "Freely given upon entering the Second Sea.",
		NaturalMutationChance = 5
	},
	["Firefly Rod"] = {
		Icon = "rbxassetid://140500389806941",
		Price = 9500,
		MinDistanceToPurchase = 30,
		ProgressEfficiency = 0.1,
		Description = "Humming with energy, and a line glowing like a trail of fireflies in the night. +15% Progress Speed at Night.",
		Luck = 55,
		LureSpeed = 15,
		Strength = 175,
		LineDistance = 20,
		Resilience = 25,
		Control = -0.01,
		Color = Color3.fromRGB(255, 255, 73),
		BobberTop = Color3.fromRGB(88, 66, 35),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Castaway Cliffs",
		Hint = "Purchasable at Castaway Cliffs after completing 40% of the bestiary.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		BestiaryRequirement = {
			{
				Island = "Castaway Cliffs",
				Requirement = 40
			}
		},
		FishingPassives = {
			Generic_TimeBoosts = {
				Night = {
					Boosts = {
						ProgressSpeed = 15
					},
					MutationPool = {
						Bioluminescent = 10
					}
				}
			}
		}
	},
	["Wildflower Rod"] = {
		Icon = "rbxassetid://103371431508772",
		Price = 40000,
		MinDistanceToPurchase = 30,
		Description = "Entwined with blooming vines and the essence of the wild. Fish have a high chance to be drawn to nature.",
		Luck = 75,
		LureSpeed = 30,
		Strength = 700,
		LineDistance = 15,
		Resilience = 17,
		Control = 0.17,
		Color = Color3.fromRGB(103, 255, 159),
		BobberTop = Color3.fromRGB(54, 35, 9),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Terrapin",
		Hint = "Purchasable at Terrapin Island.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			["Mother Nature"] = 50
		}
	},
	["Frog Rod"] = {
		Icon = "rbxassetid://87494298589702",
		Price = 12000,
		MinDistanceToPurchase = 30,
		Description = "A peculiar rod infused with amphibian magic. Frogs appear applying a stacking luck boost for every perfect catch.",
		Luck = 100,
		LureSpeed = 40,
		Strength = 650,
		LineDistance = 15,
		Resilience = 15,
		Control = 0.15,
		Color = Color3.fromRGB(188, 255, 190),
		BobberTop = Color3.fromRGB(80, 134, 80),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Mushgrove",
		Hint = "Purchasable at Mushgrove Swamp after completing 50% of the bestiary.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		BestiaryRequirement = {
			{
				Island = "Mushgrove",
				Requirement = 50
			}
		},
		FishingPassives = {
			Frog = {
				BOOSTS_PER_FROG = {
					LuckMultiply = 0.5
				},
				MAX_FROGS = 3,
				FROG_SPAWN_CHANCE = 50,
				FROG_DESPAWN_TIME = 120
			}
		}
	},
	["Azure Of Lagoon"] = {
		Icon = "rbxassetid://74803712156841",
		Price = 80000,
		MinDistanceToPurchase = 30,
		Description = "Its delicate form belies a sharp, cutting force with an almost eerie precision. All caught fish become Glossy or Luminescent, and has a chance to slash fish.",
		Luck = 145,
		LureSpeed = 25,
		Strength = 200000,
		LineDistance = 30,
		Resilience = 55,
		Control = -0.01,
		Color = Color3.fromRGB(61, 71, 255),
		BobberTop = Color3.fromRGB(61, 236, 255),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		From = "Lost Jungle",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		BestiaryRequirement = {
			{
				Island = "Lost Jungle",
				Requirement = 85
			}
		},
		MutationPool = {
			Glossy = 85,
			Luminescent = 15
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Azure Of Lagoon",
				SoundName = "stabbystab",
				IconName = "Azure Of Lagoon",
				GradientColor = Color3.fromRGB(0, 255, 255)
			}
		},
		Hint = "Purchasable at the Lost Jungle after completing 85% of the bestiary."
	},
	["Tranquility Rod"] = {
		Icon = "rbxassetid://98333011934763",
		Price = 1e999,
		Description = "A serene flute-shaped rod that summons a cascade of musical notes with every catch, granting a 15% chance to bestow the Spirit mutation.",
		Luck = 100,
		LureSpeed = 35,
		Strength = 8000,
		LineDistance = 50,
		Resilience = 30,
		Control = 0.15,
		Color = Color3.fromRGB(173, 216, 230),
		BobberTop = Color3.fromRGB(173, 216, 230),
		BobberBottom = Color3.fromRGB(218, 165, 32),
		MutationPool = {
			Spirit = 15
		},
		ClientFishingPassives = {
			["Tranquility Rod"] = {
				SpecialChartChance = 1,
				SpecialChartSpeed = 1,
				MobileLaneScale = 1.5,
				DefaultAttackCooldown = 8,
				DefaultAttackChance = 15,
				AttackChanceEscalation = 15,
				EnchantNoteCooldownScale = 1
			}
		},
		Unpurchasable = true,
		Tags = { "Instrument" }
	},
	["Blazebringer Rod"] = {
		Icon = "rbxassetid://76779510183446",
		Price = 70000,
		MinDistanceToPurchase = 30,
		Description = "A flaming rod with power that builds with every perfect catch, yielding a variety of unique mutations & a luck boost.",
		Luck = 90,
		LureSpeed = 20,
		Strength = 12000,
		LineDistance = 25,
		Resilience = 15,
		Control = 0.15,
		Color = Color3.fromRGB(255, 136, 0),
		BobberTop = Color3.fromRGB(23, 17, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		Durability = 100,
		ProgressEfficiency = 0.1,
		FishingPassives = {
			Generic_TieredBoosts = {
				DefaultLevel = 1,
				RequirePerfect = true,
				AllowRefresh = true,
				BuffId = "Blazebringer",
				Levels = {
					{
						Boosts = {},
						MutationPool = {}
					},
					{
						Duration = 120,
						CatchRequirement = 3,
						Boosts = {
							Luck = 10
						},
						MutationPool = {
							Ember = 20,
							Cracked = 5,
							Emberflame = 0
						}
					},
					{
						Duration = 180,
						CatchRequirement = 5,
						Boosts = {
							Luck = 25
						},
						MutationPool = {
							Ember = 35,
							Cracked = 10,
							Emberflame = 5
						}
					}
				}
			}
		},
		BestiaryRequirement = {
			{
				Island = "Roslit Volcano",
				Requirement = 80
			}
		},
		From = "Roslit Volcano",
		Hint = "Purchasable at Roslit Volcano after completing 80% of the bestiary."
	},
	["Free Spirit Rod"] = {
		Icon = "rbxassetid://127063268905050",
		Price = 200000,
		MinDistanceToPurchase = 30,
		Description = "A rod infused with untamed blooming spirits. Occasional slashes, & all caught fish have a 30% chance to be mutated with Bloom.",
		Luck = 150,
		LureSpeed = 45,
		Strength = 30000,
		LineDistance = 60,
		Resilience = 10,
		Control = 0.15,
		Color = Color3.fromRGB(52, 235, 143),
		BobberTop = Color3.fromRGB(52, 235, 143),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		MutationPool = {
			Bloom = 30
		},
		FishingPassives = {
			FreeSpiritRod = {
				ShowGemMutations = { "Bloom" },
				GemModelName = "FreeSpiritRod",
				ProgressGain = {
					TriggerChance = 100,
					ProgressGain = 25,
					ShakeIntensity = 0.1,
					ShakeTime = 0.2,
					ShakeRotates = false,
					ProgressGainSplit = 5,
					ProgressGainSplitInterval = 0.5
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Free Spirit Rod",
				SoundName = "stabbystab",
				IconName = "Default",
				GradientColor = Color3.fromRGB(0, 255, 255)
			}
		},
		BestiaryRequirement = {
			{
				Island = "Mineshaft",
				Requirement = 100
			}
		},
		From = "Mineshaft",
		Hint = "Purchasable at the Mineshaft after completing the bestiary."
	},
	["Verdant Shear Rod"] = {
		Icon = "rbxassetid://124211923278861",
		Price = 50000,
		MinDistanceToPurchase = 30,
		Description = "A rod entwined with nature's will. Has a 20% chance to sprout a tree, blessing each catch with triple its worth.",
		Luck = 75,
		LureSpeed = 30,
		Strength = 2000,
		LineDistance = 15,
		Resilience = 20,
		Control = 0.1,
		Color = Color3.fromRGB(52, 235, 143),
		BobberTop = Color3.fromRGB(52, 235, 143),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		FishingPassives = {
			VerdantShearRod = {
				SPAWN_TREE_CHANCE = 20,
				CALCULATED_SYNC = 0.55,
				DESPAWN_TREE_TIME = 60,
				TREE_MUTATION_POOL = {
					["Mother Nature"] = 33.333333333333336,
					["Green Leaf"] = 33.333333333333336,
					["Brown Wood"] = 33.333333333333336
				},
				TREE_MODEL_NAME = "VerdantShear"
			}
		},
		From = "Lost Jungle",
		Hint = "Purchasable at Lost Jungle after completing 75% of the bestiary.",
		BestiaryRequirement = {
			{
				Island = "Lost Jungle",
				Requirement = 75
			}
		}
	},
	["Great Dreamer Rod"] = {
		Icon = "rbxassetid://82471714348423",
		Price = 275000,
		MinDistanceToPurchase = 30,
		Description = "Pulsing with energy and madness, some say the Dreamer himself occasionally awakens to seize a fish, with a 50% chance of Cursed Touch.",
		Luck = 147,
		LureSpeed = 25,
		Strength = 100000,
		LineDistance = 60,
		Resilience = 17,
		Control = 0.17,
		Color = Color3.fromRGB(18, 92, 89),
		BobberTop = Color3.fromRGB(209, 174, 31),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		BestiaryRequirement = {
			{
				Island = "Cursed Isle",
				Requirement = 50
			}
		},
		Disturbance = 2,
		FishingPassives = {
			GreatDreamerRod = {
				MinTargetCatch = 1,
				MaxTargetCatch = 3,
				PassiveBlockLevel = 0,
				PassiveMutationPool = {
					["Cursed Touch"] = 50
				},
				PassiveWeightBoost = 1.1928,
				ModelName = "Cathulu"
			}
		},
		From = "Cursed Isle",
		Hint = "Purchasable at Cursed Isle after completing 50% of the bestiary."
	},
	["Egg Rod"] = {
		Icon = "rbxassetid://74749469803380",
		Price = 1e999,
		Description = "Cast your bobber for a bite sweeter than chocolate!",
		Luck = 75,
		LureSpeed = 25,
		Strength = 20000,
		LineDistance = 25,
		Resilience = 15,
		Control = 0.15,
		Color = Color3.fromRGB(239, 175, 255),
		BobberTop = Color3.fromRGB(120, 255, 131),
		BobberBottom = Color3.fromRGB(183, 249, 255),
		From = "Egg Hunt",
		Hint = "Obtained by getting 10 of 23 eggs during the Egg Hunt.",
		MutationPool = {
			Easter = 10
		},
		Unregistered = true
	},
	["Shamrock Rod"] = {
		Icon = "rbxassetid://130006650981630",
		Price = 1e999,
		Description = "Surely the pot of gold at the end of the rainbow is real... Right?",
		Luck = 150,
		LureSpeed = 75,
		Strength = 5000,
		LineDistance = 60,
		Resilience = 10,
		Control = 0.15,
		Color = Color3.fromRGB(52, 235, 143),
		BobberTop = Color3.fromRGB(52, 235, 143),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		MutationPool = {
			Clover = 10
		},
		From = "Lucky Event",
		Hint = "Obtained from Clover McRich.",
		Unpurchasable = true,
		Unregistered = true
	},
	["Volcanic Rod"] = {
		Icon = "rbxassetid://125536554173274",
		MinDistanceToPurchase = 30,
		Price = 150000,
		Description = "A rod forged in the heart of molten fury, granting a 30% chance for the Ashen Fortune mutation.",
		Luck = 130,
		LureSpeed = 30,
		Strength = 100000,
		LineDistance = 70,
		Resilience = 15,
		Control = 0.1,
		Durability = 100,
		Color = Color3.fromRGB(255, 170, 0),
		BobberTop = Color3.fromRGB(255, 170, 0),
		BobberBottom = Color3.fromRGB(49, 49, 49),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2000
			}
		},
		Disturbance = 1,
		MutationPool = {
			["Ashen Fortune"] = 30
		},
		From = "Volcanic Vents",
		Hint = "Purchasable at Volcanic Vents."
	},
	["Challenger's Rod"] = {
		Icon = "rbxassetid://136719591192487",
		ProgressEfficiency = 0.25,
		MinDistanceToPurchase = 30,
		Price = 400000,
		Description = "An ice-imbued rod for the most dedicated fishers.",
		Luck = 190,
		LureSpeed = 5,
		Strength = 200000,
		LineDistance = 70,
		Resilience = 35,
		Control = 0.2,
		MutationPool = {
			Chilled = 35
		},
		Color = Color3.fromRGB(4, 175, 236),
		BobberTop = Color3.fromRGB(4, 175, 236),
		BobberBottom = Color3.fromRGB(128, 187, 219),
		LevelRequirement = 110,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 3000
			}
		},
		From = "Challenger's Deep",
		Hint = "Purchasable at Challenger's Deep after reaching Level 110."
	},
	["Rod Of The Zenith"] = {
		Icon = "rbxassetid://98068621248855",
		MinDistanceToPurchase = 30,
		Price = 700000,
		Description = "A legendary rod that defies limits, allowing a challenge for those seeking the ultimate reward. Has a 70% chance to apply the Wrath mutation to fish.",
		Luck = 145,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 70,
		Resilience = 12,
		Control = -0.1,
		Color = Color3.fromRGB(101, 148, 173),
		BobberTop = Color3.fromRGB(101, 148, 173),
		BobberBottom = Color3.fromRGB(53, 91, 127),
		LevelRequirement = 150,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 3,
		ProgressEfficiency = 0.2,
		MutationPool = {
			Wrath = 70
		},
		WeightBoost = 20,
		EnhancementPatches = {
			Mastery1 = {
				ProgressSpeed = 20,
				ClientFishingPassives = {
					Generic_Slashes = {
						TriggerMode = "FishMove",
						SlashChance = 30,
						SlashDamage = 3,
						StunTime = 0.15,
						RawStun = false,
						SourceType = "rod",
						SourceName = "Rod Of The Zenith",
						SoundName = "stabbystab",
						IconName = "Default",
						IconColor = Color3.fromRGB(101, 148, 173),
						GradientColor = Color3.fromRGB(101, 148, 173)
					}
				}
			}
		},
		From = "Abyssal Zenith",
		Hint = "Purchasable at Abyssal Zenith after reaching Level 150.",
		Cool = true
	},
	["Ethereal Prism Rod"] = {
		Icon = "rbxassetid://115941878738443",
		MinDistanceToPurchase = 30,
		Price = 3500000,
		Description = "A rod infused with spectral essence and alluring gems, granting chances for the Prismized and Prism mutations.",
		Luck = 195,
		LureSpeed = 5,
		Strength = 250000,
		LineDistance = 70,
		Resilience = 40,
		Control = 0.25,
		Color = Color3.fromRGB(255, 170, 255),
		BobberTop = Color3.fromRGB(121, 80, 191),
		BobberBottom = Color3.fromRGB(148, 126, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7500
			}
		},
		ProgressEfficiency = 0.35,
		MutationPool = {
			Prismize = 50,
			Prism = 10
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Prismize = 60
				},
				Lure = 5,
				ProgressSpeed = 10
			}
		},
		BestiaryRequirement = {
			{
				Island = "Veil of the Forsaken",
				Requirement = 100
			}
		},
		LevelRequirement = 250,
		From = "Calm Zone",
		Hint = "Purchasable at Calm Zone after completing the Veil of the Forsaken bestiary and reaching Level 250.",
		Cool = true
	},
	["Leviathan's Fang Rod"] = {
		Icon = "rbxassetid://106357016712874",
		MinDistanceToPurchase = 30,
		Price = 350000,
		Description = "A weaponized rod forged to withstand the wrath of Scylla, carving through its relentless assaults with unyielding force.",
		Luck = 220,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 70,
		Resilience = 10,
		Control = 0.1,
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "ScyllaHunt",
			Risk = 4
		},
		Color = Color3.fromRGB(104, 164, 190),
		BobberTop = Color3.fromRGB(104, 164, 190),
		BobberBottom = Color3.fromRGB(51, 88, 130),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Leviathan's Fang Rod",
				SoundName = "stabbystab",
				IconName = "Leviathan's Fang Rod",
				GradientColor = Color3.fromRGB(255, 0, 0)
			}
		},
		From = "Veil of the Forsaken",
		Hint = "Purchasable at Veil of the Forsaken.",
		Cool = true
	},
	["Zeus Rod"] = {
		Icon = "rbxassetid://89898180854550",
		Price = 500000,
		MinDistanceToPurchase = 30,
		Description = "Forged in the heart of Mount Olympus, this divine rod crackles with Zeus's lightning. Its power grants the ability to command storms, with a 90% chance to inflict the Electric Shock mutation on fish; all others are Charred.",
		Luck = 110,
		LureSpeed = 15,
		Strength = 250000,
		LineDistance = 70,
		Resilience = 20,
		Control = 0.13,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(20, 20, 20),
		LevelRequirement = 250,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 4000
			}
		},
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "KeraunoWyrmHunt",
			Risk = 6
		},
		ProgressEfficiency = 0.15,
		FishingPassives = {
			ZeusRod = {
				THUNDERSTORM_MUTATION_POOL = {
					["Electric Shock"] = 90,
					Charred = 10
				},
				THUNDERSTORM_BOOSTS = {
					Luck = 175
				},
				SPAWN_THUNDERSTORM_CHANCE = 20,
				THUNDERSTORM_DURATION = 120,
				FADE_DURATION = 2,
				SATURATION_CYCLE_DURATION = 3
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				ClientFishingPassives = {
					Generic_Slashes = {
						TriggerMode = "Interval",
						SlashChance = 35,
						SlashDamage = 3.5,
						StunTime = 0,
						RawStun = false,
						SlashInterval = 0.35,
						SourceType = "rod",
						SourceName = "Zeus Rod",
						SoundName = "stabbystab",
						IconName = "Trident Rod",
						GradientColor = Color3.fromRGB(255, 218, 107)
					}
				}
			}
		},
		From = "Atlantis",
		Hint = "Purchasable at Zeus's Sanctuary after reaching Level 150."
	},
	["Poseidon Rod"] = {
		Icon = "rbxassetid://136614385578483",
		Price = 450000,
		MinDistanceToPurchase = 30,
		Description = "Blessed by the God of the Seas himself, this trident-inspired rod commands the ocean's bounty. 25% chance of receiving 75% of your fish value as a bonus. 10% chance of spawning Poseidon's ghost, giving your fish the King's Blessing mutation which boosts weight by 75-150%.",
		Luck = 165,
		LureSpeed = 25,
		Strength = 1e999,
		LineDistance = 125,
		Resilience = 40,
		Control = 0.2,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(255, 170, 0),
		BobberBottom = Color3.fromRGB(34, 191, 134),
		LevelRequirement = 200,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 7000
			}
		},
		PreferredDisturbance = {
			Event = "StormFlood",
			Risk = 6
		},
		MutationPool = {
			["King’s Blessing"] = 10
		},
		FishingPassives = {
			Poseidon = {
				MULTIPLIER = 0.75,
				MULTIPLIER_POSITIVE_CHANCE = 25,
				MULTIPLIER_NEGATIVE_CHANCE = 0,
				SPAWN_GHOST_MUTATIONS = { "King’s Blessing" },
				GHOST_WEIGHT_MIN = 1.75,
				GHOST_WEIGHT_MAX = 2.5,
				GHOST_MODEL_NAME = "PoseidonRod"
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					["King’s Blessing"] = 20
				}
			},
			Mastery2 = {
				ClientFishingPassives = {
					Generic_Slashes = {
						TriggerMode = "FishMove",
						SlashChance = 25,
						SlashDamage = 6,
						StunTime = 0.35,
						RawStun = false,
						SourceType = "rod",
						SourceName = "Poseidon Rod",
						SoundName = "stabbystab",
						IconName = "Trident Rod",
						GradientColor = Color3.fromRGB(255, 207, 84)
					}
				}
			}
		},
		From = "Atlantis",
		Hint = "Purchasable at the Poseidon Temple after reaching Level 100."
	},
	["Kraken Rod"] = {
		Icon = "rbxassetid://78311848325999",
		Price = 950000,
		MinDistanceToPurchase = 30,
		Description = "Crafted from the tentacle of an ancient Kraken, this mysterious rod pulses with dark energy. Gives you a random Legendary/Mythical/Exotic fish every 5 catches. 20% chance of giving you 2x the amount of fish.  10% chance of giving you the Tentacle Surge mutation.",
		Luck = 185,
		LureSpeed = 40,
		Strength = 115000,
		LineDistance = 60,
		Resilience = 15,
		Control = 0.2,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(170, 0, 0),
		BobberBottom = Color3.fromRGB(85, 0, 0),
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "KrakenHunt",
			Risk = 4
		},
		LevelRequirement = 180,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		MutationPool = {
			["Tentacle Surge"] = 10
		},
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 20,
				PassiveBlockLevel = 3
			},
			KrakenRod = {
				BestiaryUnit = 5,
				MinTotalBestiary = 20,
				AllowedRarities = { "Legendary", "Mythical", "Exotic" },
				PassiveBlockLevel = 0
			}
		},
		From = "Atlantis",
		Hint = "Purchasable at the Kraken Lair after reaching Level 180."
	},
	["Tempest Rod"] = {
		Icon = "rbxassetid://85559595470049",
		Price = 100000,
		MinDistanceToPurchase = 30,
		Description = "Born from the essence of a perpetual storm, this rod moves faster than the eye can follow.",
		Luck = 120,
		LureSpeed = 10,
		Strength = 120000,
		LineDistance = 20,
		Resilience = 40,
		Control = 0.15,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(220, 220, 220),
		BobberBottom = Color3.fromRGB(85, 255, 255),
		ProgressEfficiency = 0.3,
		LevelRequirement = 120,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 4000
			}
		},
		MutationPool = {
			Electric = 10
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Generic_WeatherBoosts = {
						Rain = {
							MutationPool = {
								Electric = 50
							}
						},
						Default = {
							MutationPool = {
								Electric = 25
							}
						}
					}
				}
			}
		},
		From = "Atlantis",
		Hint = "Purchasable at the Sunken Depths after reaching Level 80."
	},
	["Abyssal Specter Rod"] = {
		Icon = "rbxassetid://135758457869213",
		Price = 300000,
		MinDistanceToPurchase = 30,
		Description = "Forged in the darkest depths of the ocean's trenches, this spectral rod radiates an otherworldly strength. Its phantom line reaches impossible depths, while its ghostly power grants the ability to haul in catches that would snap lesser rods. All fish are 20% larger, & have a 25% chance to be Abyssal.",
		Luck = 125,
		LureSpeed = 40,
		Strength = 1e999,
		LineDistance = 80,
		Resilience = 70,
		Control = 0.3,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(47, 245, 172),
		BobberBottom = Color3.fromRGB(26, 26, 26),
		LevelRequirement = 170,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		Disturbance = 1,
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Abyssal = 35
				},
				WeightBoost = 50,
				ForcedProgressEfficiency = 0.05
			}
		},
		MutationPool = {
			Abyssal = 25
		},
		WeightBoost = 25,
		From = "Atlantis",
		Hint = "Purchasable at the Ethereal Abyss after reaching Level 170.",
		Cool = true
	},
	["Champions Rod"] = {
		Icon = "rbxassetid://72090307482760",
		Price = 90000,
		MinDistanceToPurchase = 30,
		Description = "Wielded by legendary tournament winners, this balanced rod embodies competitive excellence.",
		Luck = 130,
		LureSpeed = 20,
		Strength = 100000,
		LineDistance = 20,
		Resilience = 20,
		Control = 0.25,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(255, 170, 0),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		PreferredDisturbance = {
			Event = "WarSurge",
			Risk = 8
		},
		MutationPool = {
			Greedy = 10
		},
		From = "Atlantis",
		Hint = "Purchasable at central Atlantis."
	},
	["Depthseeker Rod"] = {
		Icon = "rbxassetid://75606506873083",
		Price = 40000,
		MinDistanceToPurchase = 30,
		Description = "Engineered with deep-sea technology, this resilient rod thrives in challenging conditions.",
		Luck = 70,
		LureSpeed = 45,
		Strength = 70000,
		LineDistance = 50,
		Resilience = 25,
		Control = 0.17,
		Color = Color3.fromRGB(40, 132, 245),
		BobberTop = Color3.fromRGB(66, 255, 239),
		BobberBottom = Color3.fromRGB(27, 27, 27),
		ProgressEfficiency = 0.05,
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Darkened = 25
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					FallenRod = {
						Y_LEVEL_THRESHOLD = 0,
						MutationPool = {
							Darkened = 100
						}
					}
				}
			}
		},
		From = "Atlantis",
		Hint = "Purchasable at central Atlantis."
	},
	["Flimsy Rod"] = {
		Icon = "rbxassetid://72440218528420",
		Price = 0,
		Description = "Quite the weak and unreliable rod. But, it can get the job done!",
		Luck = 0,
		LureSpeed = 100,
		Strength = 10.4,
		LineDistance = 19,
		Resilience = 0,
		Control = 0,
		Color = Color3.fromRGB(154, 170, 190),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Every Fischer's starting point."
	},
	["Precision Rod"] = {
		Icon = "rbxassetid://86883917221507",
		Price = 1e999,
		Description = "Counterpart to the Rapid Rod, with much better resilience!",
		Luck = 150,
		LureSpeed = 35,
		Strength = 12000,
		LineDistance = 100,
		Resilience = 25,
		Control = 0.05,
		Color = Color3.fromRGB(154, 170, 190),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		FishingPassives = {
			Generic_PerfectBoost = {
				MutationPool = {
					Silver = 100
				}
			}
		},
		ClientFishingPassives = {
			Precision = {
				OffBarAccel = 1.4,
				OnBarAccel = 0.6
			}
		},
		Unpurchasable = true,
		From = "Ancient Archives",
		Hint = "Craftable at the Ancient Archives at Level 5."
	},
	["Plastic Rod"] = {
		Icon = "rbxassetid://119049415149213",
		Price = 750,
		MinDistanceToPurchase = 30,
		Description = "Made of ABS plastic; You can trust this rod will last you.",
		Luck = 15,
		LureSpeed = 80,
		Strength = 100,
		LineDistance = 15,
		Resilience = 10,
		Control = 0,
		Color = Color3.fromRGB(73, 240, 255),
		BobberTop = Color3.fromRGB(163, 60, 60),
		BobberBottom = Color3.fromRGB(255, 242, 93),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Carbon Rod"] = {
		Icon = "rbxassetid://80486052744950",
		Price = 2000,
		MinDistanceToPurchase = 30,
		Description = "Stiff, strong, and easier to handle than other rods out there, however it is slightly shorter.",
		Luck = 25,
		LureSpeed = 85,
		Strength = 600,
		LineDistance = 15,
		Resilience = 10,
		Control = 0.05,
		Color = Color3.fromRGB(155, 190, 255),
		BobberTop = Color3.fromRGB(69, 109, 117),
		BobberBottom = Color3.fromRGB(192, 233, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Long Rod"] = {
		Icon = "rbxassetid://90128080901987",
		Price = 3000,
		MinDistanceToPurchase = 30,
		Description = "Not the strongest, but it's sure the longest! Is this really needed?",
		Luck = 80,
		LureSpeed = 80,
		Strength = 250,
		LineDistance = 1000,
		Resilience = 20,
		Control = -0.1,
		Color = Color3.fromRGB(220, 204, 167),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Executive Rod"] = {
		Icon = "rbxassetid://130075736892070",
		Price = 1e999,
		Description = "Game development is truly difficult..",
		Luck = 0,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 0,
		Control = 0.4,
		Durability = 1e999,
		Color = Color3.fromRGB(255, 42, 42),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(39, 39, 39),
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Ultra Flimsy Rod"] = {
		Icon = "rbxassetid://72440218528420",
		Price = 1e999,
		Description = "The humble Flimsy Rod, pushed far beyond what any rod was ever meant to be.",
		Luck = 1000,
		LureSpeed = -900,
		Strength = 1e999,
		LineDistance = 1e999,
		Resilience = 100,
		Control = 1,
		ProgressEfficiency = 1,
		Durability = 1e999,
		InstantCatch = true,
		StartingProgress = 100,
		ShinyChance = 100,
		SparklingChance = 100,
		WeightBoost = 1000,
		Color = Color3.fromRGB(154, 170, 190),
		BobberTop = Color3.fromRGB(134, 38, 38),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		FixedStats = {
			NaturalMutationChance = 0
		},
		MutationPool = {
			Aether = 100
		},
		FishingPassives = {
			Generic_GroupWhitelist = {
				GROUP_ID = 7381705,
				MINIMUM_RANK = 252,
				UNAUTH_KICK = true,
				UNAUTH_KICK_MSG = "You are not authorized to use this rod.",
				UNAUTH_STATS = {}
			},
			Generic_DuplicateFish = {
				DuplicateChance = 100,
				DuplicateCount = 9,
				PassiveBlockLevel = 99
			},
			Generic_PerfectBoost = {
				XpBoost = 10
			},
			Generic_RarityBoost = {
				Legendary = 10,
				Mythical = 10,
				Exotic = 10
			},
			Generic_FinalWeightMultiplier = {
				Multiplier = 10
			},
			Generic_MakeUntradeable = {
				TradeCooldown = -1
			}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Flimsy Rod",
		Unpurchasable = true
	},
	["No-Life Rod"] = {
		Icon = "rbxassetid://90940593179243",
		Price = 1e999,
		Description = "Fisching 24/7/365. Are you okay?",
		Luck = 105,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.28,
		Color = Color3.fromRGB(255, 42, 42),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(39, 39, 39),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 2,
		ProgressEfficiency = 0.25,
		XpMultiply = 0.25,
		MutationPool = {
			Hexed = 50
		},
		EnhancementPatches = {
			Mastery1 = {
				ProgressSpeed = 25,
				Control = 0.28,
				Lure = 10,
				MutationPool = {
					Crimson = 25,
					Sanguine = 25
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "No-Life Rod",
				SoundName = "stabbystab",
				IconName = "No-Life Rod",
				GradientColor = Color3.fromRGB(225, 0, 0)
			}
		},
		Unpurchasable = true,
		LevelRequirement = 500,
		From = "Leveling Up",
		Hint = "Obtainable from reaching Level 500."
	},
	["Original No-Life Rod"] = {
		Icon = "rbxassetid://88926926947920",
		Price = 1,
		MinDistanceToPurchase = 30,
		Description = "Fisching 24/7/365. Are you okay?",
		Luck = 100,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.2,
		Color = Color3.fromRGB(255, 42, 42),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(39, 39, 39),
		MutationPool = {
			Hexed = 20
		},
		Unregistered = true,
		From = "Moosewood",
		Hint = "Obtainable during Original No-Life Rod admin event."
	},
	["Astralhook Rod"] = {
		Icon = "rbxassetid://92263578041170",
		ProgressEfficiency = 0.15,
		Price = 1e999,
		Description = "Tempered from the silence within descending stars, it draws from the power of the Milky Way to assemble powers beyond conceivability.",
		Luck = 200,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 20,
		Control = 0.2,
		Color = Color3.fromRGB(168, 112, 0),
		BobberTop = Color3.fromRGB(117, 62, 255),
		BobberBottom = Color3.fromRGB(75, 38, 167),
		LevelRequirement = 1000,
		FishingPassives = {
			Astralhook = {
				EnableAfterFishCatch = 12,
				PoolMutation = "Astral",
				PoolMutationChance = 63,
				Duration = 44,
				RandomFishChance = 10,
				RandomFishMutation = "Stardust",
				PassiveBlockLevel = 2,
				BlockedRarities = {
					"Limited",
					"Special",
					"Apex",
					"Cataclysmic",
					"Extinct",
					"Divine Secret"
				},
				BlockedFish = {
					"Doubloon",
					"Eyefestation",
					"Moon Idol Sea 1",
					"Moon Idol Sea 2",
					"Experimental Salmon",
					"Him",
					"🐟",
					"🦑",
					"🦈",
					"🐋",
					"🐡",
					"Imprinted Relic"
				}
			}
		},
		ClientFishingPassives = {
			Astralhook = {
				ProgressBoost = 15,
				MinInterval = 2,
				MaxInterval = 4
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Leveling Up",
		Hint = "Obtained from reaching Level 2500."
	},
	["Seraphic Rod"] = {
		Icon = "rbxassetid://99896956393962",
		Price = 1e999,
		Description = "TOUCH SOME GRASS BUDDY",
		Luck = 225,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 160,
		Resilience = 20,
		Control = 0.25,
		Color = Color3.fromRGB(255, 170, 0),
		BobberTop = Color3.fromRGB(255, 204, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 15000
			}
		},
		Disturbance = 3,
		ForcedProgressEfficiency = 0.08,
		MutationPool = {
			Blessed = 35,
			Heavenly = 10
		},
		FishingPassives = {
			Generic_Laser = {
				LaserPropName = "SeraphicProp",
				TriggerChance = 100,
				ProgressGain = 40,
				LaserTime = 3,
				LaserChargeTime = 0.5,
				ShakeIntensity = 0.8,
				ShakeRotates = true,
				ShakeIntensityDecay = 0.97,
				StartSoundName = "voyagerlaser1",
				FireSoundName = "voyagerlaser2",
				EndSoundName = "voyagerlaser3",
				ProgressIcon = "rbxassetid://84339284727476",
				ProgressIconColor = Color3.fromRGB(255, 228, 174)
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				Control = 0.3,
				ShinyChance = 8,
				SparklingChance = 8,
				ProgressSpeed = 8,
				StartingProgress = 8,
				MutationPool = {
					Blessed = 50
				}
			}
		},
		Unpurchasable = true,
		LevelRequirement = 1000,
		From = "Leveling Up",
		Hint = "Obtainable from reaching Level 1000."
	},
	["Fang of the Eclipse"] = {
		Icon = "rbxassetid://89139902442823",
		Price = 1e999,
		Description = "A quiet antique under normal conditions... Under the presence of an Eclipse, it becomes a power beyond comprehension—an intricate yet worthy challenge.",
		Luck = 80,
		LureSpeed = 20,
		Strength = 25000,
		LineDistance = 100,
		Resilience = 20,
		Control = 0.15,
		Color = Color3.fromRGB(168, 112, 0),
		BobberTop = Color3.fromRGB(117, 62, 255),
		BobberBottom = Color3.fromRGB(75, 38, 167),
		MutationPool = {
			Solarblaze = 10
		},
		FishingPassives = {
			Generic_TimedConditionalBoosts = {
				BoostDuration = 900,
				TargetWeathers = { "Eclipse" },
				OneDuplicateChance = 20,
				TwoDuplicateChance = 5,
				BuffId = "EclipseBoost",
				BuffData = {
					MutationPool = {
						Solarblaze = 80,
						Umbra = 10
					},
					PassiveBoosts = {
						Lure = 99,
						Luck = 150,
						Strength = 1e999,
						Resilience = -50,
						Control = -0.35,
						ProgressSpeed = 50,
						WeightBoost = 20
					}
				}
			}
		},
		Cool = true,
		Unregistered = true,
		Unpurchasable = true,
		From = "Leveling Up",
		Hint = "Obtained from reaching Level 2000."
	},
	["Rod Of The Depths"] = {
		Icon = "rbxassetid://93648294146825",
		Price = 750000,
		MinDistanceToPurchase = 30,
		Description = "This Rod was crafted by the Legendary King of The Depths... Legends say, every once in a while the Spirit of the King visits you to hand you a gift from the deep waters!",
		Luck = 130,
		LureSpeed = 25,
		Strength = 30000,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		ProgressEfficiency = 0.1,
		Color = Color3.fromRGB(255, 66, 52),
		BobberTop = Color3.fromRGB(255, 79, 66),
		BobberBottom = Color3.fromRGB(106, 26, 20),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 8000
			}
		},
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "DepthsAbsoluteDarkness",
			Risk = 20
		},
		MutationPool = {
			Abyssal = 30,
			Hexed = 15
		},
		FishingPassives = {
			ShadowEntity = {
				GiveFishEvery = 3,
				ModelName = "Shadow",
				MatchPlayerEmotes = true,
				CatchEmotesEnabled = true,
				UseOwnerAvatar = true,
				DialogSetName = "Default",
				PassiveBlockLevel = 0,
				SpiritMutationPool = {
					Abyssal = 55
				},
				SpiritMutationWeightBoostMap = {
					Abyssal = 1.35,
					Hexed = 0.8
				},
				SpiritCatchPool = {
					["Enchant Relic"] = 10
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					ShadowEntity = {
						GiveFishEvery = 2
					}
				}
			}
		},
		Cool = true,
		From = "The Depths",
		Hint = "Obtainable from a maze hidden within The Depths."
	},
	["Evil Pitchfork of Doom Rod"] = {
		Icon = "rbxassetid://103690823637430",
		Price = 1e999,
		Description = "lol im evil",
		Luck = 120,
		LureSpeed = 50,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = -10,
		Control = 0.1,
		Color = Color3.fromRGB(189, 0, 0),
		BobberTop = Color3.fromRGB(167, 0, 0),
		BobberBottom = Color3.fromRGB(47, 0, 0),
		LocalPassive = "Evil Pitchfork Of Doom",
		ProgressEfficiency = 0.25,
		FishingPassives = {
			Poseidon = {
				MULTIPLIER = 2,
				MULTIPLIER_POSITIVE_CHANCE = 20,
				MULTIPLIER_NEGATIVE_CHANCE = 30,
				SPAWN_GHOST_MUTATIONS = { "Siren's Spite" },
				GHOST_WEIGHT_MIN = 2,
				GHOST_WEIGHT_MAX = 3,
				GHOST_MODEL_NAME = "EvilPitchfork"
			}
		},
		ClientFishingPassives = {
			Generic_ReelRecolor = {
				BackgroundColor3 = Color3.fromRGB(76, 0, 0),
				progress = {
					BackgroundColor3 = Color3.fromRGB(91, 13, 13),
					bar = {
						BackgroundColor3 = Color3.fromRGB(138, 21, 21)
					}
				},
				fish = {
					BackgroundColor3 = Color3.fromRGB(103, 21, 21),
					icon = {
						ImageColor3 = Color3.fromRGB(111, 17, 17)
					}
				}
			},
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 8,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Evil Pitchfork of Doom Rod",
				SoundName = "stabbystab",
				IconName = "Evil Pitchfork",
				GradientColor = "Evil Pitchfork"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Demon-Slayer"] = {
		Icon = "rbxassetid://137922590697896",
		Price = 1e999,
		Description = "Designed for cutting magic with its precise edges, although ineffective as a typical sword...",
		Luck = -50,
		LureSpeed = 0,
		ProgressEfficiency = 0.5,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 70,
		Control = 0,
		Color = Color3.fromRGB(60, 60, 60),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(16, 15, 13),
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable from a code."
	},
	["Clover Rod"] = {
		Icon = "rbxassetid://136914725101820",
		Price = 1e999,
		Description = "A giant four leaf clover picked during St. Patrick's day! Seems ineffective as a normal rod, but surely it can bring some luck...",
		Luck = 300,
		LureSpeed = 20,
		ProgressEfficiency = 0.1,
		Strength = 10000,
		LineDistance = 100,
		Resilience = 3,
		Control = -0.14,
		Color = Color3.fromRGB(29, 108, 36),
		BobberTop = Color3.fromRGB(29, 108, 36),
		BobberBottom = Color3.fromRGB(25, 121, 23),
		MutationPool = {
			Clover = 1
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable from a code."
	},
	["Abyssal Spinecaster"] = {
		Icon = "rbxassetid://107955219388641",
		Price = 1e999,
		Description = "Transformed from the spine of an ancient, unnatural being. Brimming with an enigmatic aura, its glowing spikes attract the most elusive fishes. [For @nekoanims]",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 1e999,
		ProgressEfficiency = 0.5,
		Resilience = 40,
		Control = 0.15,
		Durability = 200,
		Color = Color3.fromRGB(88, 50, 170),
		BobberTop = Color3.fromRGB(22, 13, 40),
		BobberBottom = Color3.fromRGB(19, 11, 47),
		MutationPool = {
			Abyssal = 30
		},
		FishingPassives = {
			ShadowEntity_Raven = {}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Abyssal Spinecaster",
				SoundName = { "stabbystabspinecaster", "stabbystabspinecaster2" },
				IconName = "Abyssal Spinecaster",
				GradientColor = Color3.fromRGB(109, 85, 189)
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true,
		Cool = true
	},
	["Tetra Rod"] = {
		Icon = "rbxassetid://80368147456690",
		Price = 1e999,
		Description = "A rod that belongs to the hands of the Tetrapede. [For @voaj77]",
		Luck = 150,
		LureSpeed = 35,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		Durability = 200,
		Color = Color3.fromRGB(170, 31, 26),
		BobberTop = Color3.fromRGB(255, 205, 26),
		BobberBottom = Color3.fromRGB(86, 0, 0),
		MutationPool = {
			Aurora = 10
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 3,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Tetra Rod",
				SoundName = "stabbystabtetra",
				IconName = "Tetra Rod",
				GradientColor = Color3.fromRGB(255, 0, 0)
			}
		},
		Cool = true,
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Pen Rod"] = {
		Icon = "rbxassetid://98981470895206",
		Price = 1e999,
		Description = [=[
Given to editors of the Official Fisch Wiki for their continued contributions!
[Originally for @ZooWeeMamaMoment]]=],
		Luck = 150,
		LureSpeed = 35,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		Durability = 200,
		Color = Color3.fromRGB(85, 85, 85),
		BobberTop = Color3.fromRGB(98, 98, 98),
		BobberBottom = Color3.fromRGB(17, 17, 17),
		MutationPool = {
			Glyphed = 52
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 52,
				SlashDamage = 5.2,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Pen Rod",
				SoundName = "stabbystabpen",
				IconName = "Pen Rod",
				GradientColor = "Pen Rod"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Courage Bat"] = {
		Icon = "rbxassetid://119058362888195",
		Price = 1e999,
		Description = "-1,300,000,000,000 C$",
		Luck = 250,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		ProgressEfficiency = 1,
		ShinyChance = 10,
		SparklingChance = 10,
		Color = Color3.fromRGB(247, 222, 182),
		BobberTop = Color3.fromRGB(255, 224, 189),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Electric Guitar"] = {
		Icon = "rbxassetid://140255299216735",
		Price = 1e999,
		Description = "WOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!",
		Luck = 244,
		LureSpeed = -344,
		Strength = 444444444,
		LineDistance = 444,
		Resilience = 44,
		Control = 0.14,
		Durability = 200,
		Color = Color3.fromRGB(106, 27, 27),
		BobberTop = Color3.fromRGB(124, 117, 114),
		BobberBottom = Color3.fromRGB(62, 24, 20),
		FishingPassives = {
			FallingNotes = {
				SoundName = "Boom",
				ModelFolderName = "Models",
				TriggerChance = 16.7,
				ProgressGain = 75,
				FinalMult = 2,
				DropDelay = 0
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		LevelRequirement = 444,
		From = "Black Market",
		Hint = "Obtained from the Black Market.",
		Tags = { "Instrument" }
	},
	["Miku's Melody"] = {
		Icon = "rbxassetid://73839395719311",
		Price = 1e999,
		Description = "Blue hair, blue tie, hiding in your wifi! [For @.const]",
		Luck = 39,
		LureSpeed = -3839,
		Strength = 393939393,
		LineDistance = 3939,
		Resilience = 3939,
		Control = 0.39,
		Color = Color3.fromRGB(86, 172, 226),
		BobberTop = Color3.fromRGB(124, 117, 114),
		BobberBottom = Color3.fromRGB(119, 160, 213),
		FishingPassives = {
			Generic_Laser = {
				LaserPropName = "MikuProp",
				TriggerChance = 100,
				ProgressGain = 40,
				LaserTime = 5,
				LaserChargeTime = 4.6,
				ShakeIntensity = 3,
				ShakeRotates = true,
				ShakeIntensityDecay = 0.97,
				StartSoundName = "mikulaser1",
				FireSoundName = "mikulaser2",
				EndSoundName = "voyagerlaser3",
				ProgressIcon = "rbxassetid://98623629387972"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true,
		Cool = true,
		Tags = { "Instrument" }
	},
	["R0b's Blade"] = {
		Icon = "rbxassetid://107951361723512",
		Price = 1e999,
		Description = "The King of Dodos greatest treasure... [Admin Rod, for @R0bustic]",
		Luck = 150,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 8623,
		Resilience = 40,
		Control = 0.35,
		Color = Color3.fromRGB(77, 124, 226),
		BobberTop = Color3.fromRGB(124, 117, 114),
		BobberBottom = Color3.fromRGB(119, 160, 213),
		ShinyChance = 30,
		SparklingChance = 30,
		MutationPool = {
			Aether = 50
		},
		FishingPassives = {
			Generic_Laser = {
				LaserPropName = "MikuProp",
				TriggerChance = 100,
				ProgressGain = 99,
				LaserTime = 6,
				LaserChargeTime = 1,
				ShakeIntensity = 1,
				ShakeRotates = true,
				ShakeIntensityDecay = 0.97,
				StartSoundName = "voyagerlaser1",
				FireSoundName = "R0blaser2",
				EndSoundName = "voyagerlaser3"
			},
			Generic_MakeUntradeable = {
				TradeCooldown = -1
			},
			R0bWhitelist = {}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Seraphic Rod",
		Unpurchasable = true
	},
	["Clickbait Caster"] = {
		Icon = "rbxassetid://123438721747548",
		Price = 1e999,
		Description = "Lights, camera, action—now bite already! [CC Only]",
		Luck = 225,
		LureSpeed = 50,
		Strength = 1e999,
		LineDistance = 70,
		Resilience = 30,
		Control = 0.25,
		Color = Color3.fromRGB(255, 0, 0),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		FishingPassives = {
			ShadowEntity = {
				GiveFishEvery = 3,
				ModelName = "Shadow",
				MatchPlayerEmotes = true,
				CatchEmotesEnabled = true,
				UseOwnerAvatar = true,
				DialogSetName = "ContentCreator",
				PassiveBlockLevel = 0
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Polaris Serenade"] = {
		Icon = "rbxassetid://128134700783992",
		Price = 1e999,
		Description = "💫",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 250,
		Resilience = 40,
		Control = 0.4,
		ProgressEfficiency = 0.3,
		Color = Color3.fromRGB(115, 115, 255),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(143, 160, 255),
		Disturbance = 1,
		MutationPool = {
			Serene = 18
		},
		MutationPoolCatchOnly = true,
		FishingPassives = {
			ButterflyEntity = {
				FISH_GRANT_INTERVAL = 72,
				PERFECT_CATCH_REDUCTION = 24,
				SPARKLING_CHANCE = 3,
				SHINY_CHANCE = 3,
				BUTTERFLY_MUTATION_POOL = {
					Quiet = 100
				},
				MODEL_NAME = "Butterfly",
				XP_MULTIPLIER = 1,
				PASSIVE_BLOCK_LEVEL = 0
			},
			PolarisTrees = {
				ModelName = "Default"
			},
			Generic_HardStatLimit = {
				Control = 0.6
			},
			FallingNotes = {
				UsePlanet = true,
				TriggerChance = 4,
				ProgressGain = 75,
				FinalMult = 2,
				DropDelay = 0
			}
		},
		ClientFishingPassives = {
			Generic_ReelRecolor = {
				BackgroundColor3 = Color3.fromRGB(41, 202, 245),
				progress = {
					BackgroundColor3 = Color3.fromRGB(41, 202, 245),
					bar = {
						BackgroundColor3 = Color3.fromRGB(41, 202, 245)
					}
				},
				fish = {
					BackgroundColor3 = Color3.fromRGB(41, 202, 245),
					icon = {
						ImageColor3 = Color3.fromRGB(41, 202, 245),
						Image = "rbxassetid://101070066880954",
						ImageRectSize = Vector2.zero,
						ImageRectOffset = Vector2.zero,
						ImageTransparency = 0
					}
				}
			}
		},
		LevelRequirement = 1000,
		Unregistered = true,
		Unpurchasable = true,
		From = "Underground Music Venue",
		Hint = "Obtained from Nick.",
		Tags = { "Instrument" }
	},
	["Astraeus Serenade"] = {
		Icon = "rbxassetid://76677925964888",
		Price = 1e999,
		Description = "🌌",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 250,
		Resilience = 20,
		Control = 0.3,
		ProgressEfficiency = 0.5,
		Color = Color3.fromRGB(255, 140, 0),
		BobberTop = Color3.fromRGB(255, 128, 0),
		BobberBottom = Color3.fromRGB(102, 0, 255),
		Disturbance = 1,
		MutationPool = {
			Astraeus = 18,
			Serene = 13,
			Celestial = 11,
			Breezed = 11,
			Nova = 11
		},
		ReelGuiName = "astraeusserenade",
		ClientFishingPassives = {
			AstraeusSerenade = {
				InstantCompletionChance = 10,
				StarBeamDuration = 2.25,
				MinStarBeamInterval = 0,
				MaxStarBeamInterval = 10,
				BaseStarBeamSpeed = 0.5,
				MinStarBeamSpeed = 0.1,
				StarBeamSpeedFactor_Default = 13.5,
				StarBeamSpeedFactor_Starfall = 8,
				ProgressPerStar = 3
			},
			Generic_DimScreen = {
				OverlayTransprency = 0.25,
				FadeInTime = 1.5,
				FadeOutTime = 1
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					ButterflyEntity = {
						FISH_GRANT_INTERVAL = 180,
						PERFECT_CATCH_REDUCTION = 60,
						SPARKLING_CHANCE = 3,
						SHINY_CHANCE = 3,
						BUTTERFLY_MUTATION_POOL = {
							Quiet = 100
						},
						MODEL_NAME = "Firefly",
						XP_MULTIPLIER = 1,
						PASSIVE_BLOCK_LEVEL = 0
					}
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtained from Astraeus.",
		Tags = { "Instrument" }
	},
	SOULREAPER = {
		Icon = "rbxassetid://88364499421863",
		Price = 1e999,
		Description = "Vampires will never hurt you. [For @049492]",
		Luck = 288.88,
		LureSpeed = -899.999,
		Strength = 1e999,
		LineDistance = 999,
		Resilience = 16.66,
		Control = 0.177,
		Color = Color3.fromRGB(33, 33, 33),
		BobberTop = Color3.fromRGB(26, 26, 26),
		BobberBottom = Color3.fromRGB(126, 119, 119),
		Durability = 500,
		WeightBoost = 25,
		ShinyChance = 3,
		SparklingChance = 3,
		StartingProgress = 6,
		ProgressEfficiency = 0.3333,
		MutationPool = {
			Paranormal = 50
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 35,
				SlashDamage = 3,
				StunTime = 0.1,
				RawStun = false,
				SlashInterval = 0.5,
				SourceType = "rod",
				SourceName = "SOULREAPER",
				SoundName = "stabbystab",
				IconName = "SOULREAPER",
				GradientColor = Color3.fromRGB(59, 46, 43)
			}
		},
		FishingPassives = {
			StarcallerCry = {
				TriggerChance = 50,
				ActiveStats = {
					Control = 0
				},
				PassiveMutationPool = {
					Paranormal = 100
				},
				AfterSuccessStats = {},
				AfterSuccessCatchCount = 3,
				BuffMutations = { "Paranormal" },
				BuffWeight = 1.5,
				FishCountMin = 1,
				FishCountMax = 2,
				RequirePerfect = false,
				PassiveBlockLevel = 0,
				BlockHigherRarity = false,
				BlockSameRarity = false,
				BlockLowerRarity = false,
				VfxModelName = "SoulreaperTombstone",
				ModelScale = 2
			},
			Generic_DuplicateFish = {
				DuplicateChance = 100,
				DuplicateMinInterval = 3,
				DuplicateMaxInterval = 6,
				DuplicateMutation = "Spirit",
				RequireDirectCatch = true,
				PassiveBlockLevel = 3
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Underground Music Venue",
		Hint = "Obtained from The Reaper."
	},
	["???"] = {
		Icon = "rbxassetid://127476566659937",
		Price = 1e999,
		Description = "a hot, presumably super-sharp blade of 67 [Admin Rod, for @yvlyf]",
		Luck = 150,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 8623,
		Resilience = 40,
		Control = 0.35,
		Color = Color3.fromRGB(106, 27, 27),
		BobberTop = Color3.fromRGB(124, 117, 114),
		BobberBottom = Color3.fromRGB(62, 14, 14),
		Durability = 999,
		InstantCatch = true,
		StartingProgress = 80,
		MutationPool = {
			Chaotic = 25
		},
		WeightBoost = 50,
		ReelGuiName = "???",
		FishingPassives = {
			Crucible = {}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		Unpurchasable = true
	},
	["Dead Man's Rod"] = {
		Icon = "rbxassetid://91508953750012",
		Price = 1e999,
		Description = "A rod possessed by the soul of Davy Jones [Developer Rod, for @Johnny_D3pp]",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 20,
		Control = 0.1,
		Color = Color3.fromRGB(18, 72, 21),
		BobberTop = Color3.fromRGB(124, 117, 114),
		BobberBottom = Color3.fromRGB(18, 72, 21),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 4,
		Scavenging = 150,
		MutationPool = {
			["Tentacle Surge"] = 20,
			Wrath = 20,
			Sunken = 20,
			Atlantean = 20,
			Greedy = 20
		},
		FishingPassives = {
			["Dead Man's Rod"] = {
				ActiveAttribute = "DeadMansPassiveActive",
				MutationBuffs = {
					Sunken = {
						TreasureMapChance = 20,
						AutoFixTreasureMaps = true
					},
					Wrath = {
						PoseidonChargeAmount = 25
					},
					Greedy = {
						WeightBoost = 1.4,
						FishingStats = {
							Control = -0.1,
							Resilience = 0
						}
					}
				}
			},
			KrakenRod = {
				BestiaryUnit = 1,
				MinTotalBestiary = 20,
				AllowedRarities = {
					"Legendary",
					"Mythical",
					"Exotic",
					"Secret"
				},
				PassiveBlockLevel = 1,
				OnlyOnMutation = "Tentacle Surge",
				NoVisual = true
			}
		},
		ClientFishingPassives = {
			["Dead Man's Rod"] = {
				PROGRESS_THRESHOLD = 50,
				SPAWN_INTERVAL = 10,
				TENTACLE_HIT_PROGRESS_GAIN = 40
			},
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 0,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				MutationOverrides = {
					Atlantean = {
						SlashChance = 25
					}
				},
				SourceType = "rod",
				SourceName = "Dead Man's Rod",
				SoundName = "stabbystab",
				IconName = "Trident Rod",
				GradientColor = Color3.fromRGB(255, 207, 84)
			}
		},
		Unpurchasable = true,
		From = "Ocean",
		Hint = "Craftable at the Ancient Archives at Level 1000 using parts mostly found in chests."
	},
	ReRod = {
		Icon = "rbxassetid://83709832927652",
		Price = 1e999,
		Description = "my mom keeps calling me ReRod :d [For @RoReddo]",
		Luck = 2525.252525,
		LureSpeed = -2425.252525,
		Strength = 2525252525,
		LineDistance = 2525,
		Resilience = 25.25252525,
		Control = 0.25,
		Durability = 252,
		Color = Color3.fromRGB(238, 0, 4),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(39, 39, 39),
		WeightBoost = 99,
		ShinyChance = 25.25,
		SparklingChance = 25.25,
		MutationPool = {
			Tryhard = 45
		},
		ReelGuiName = "rerod",
		FishingPassives = {
			RoyalEscort = {
				ChancePerCatch = 5,
				CatchPerPerfectCatch = 10,
				Duration = 180,
				EscortBoosts = {
					Luck = 75,
					ProgressSpeed = 25
				},
				EscortMutationPool = {
					Royal = 10
				},
				VfxFolderName = "ReRod"
			},
			RoyalEscort_HighRarity = {
				TriggerChance = 100,
				PassiveBlockLevel = 1
			},
			ReRod = {
				PropName = "ReRodBat",
				VfxName = "ReRodVFX",
				SoundName = "rerod",
				ProgressGain1 = 15,
				ProgressGain2 = 15,
				ProgressGain3 = 30
			},
			Generic_MakeUntradeable = {
				TradeCooldown = -1
			}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Crowbar",
		Unpurchasable = true
	},
	["Tryhard Rod"] = {
		Icon = "rbxassetid://89151583332572",
		Price = 1e999,
		Description = "Every cast is a challenge. Every catch, a victory. -RoReddo [Controlled/Herculean Enchant REQUIRED]",
		Luck = 399,
		LureSpeed = 20,
		Strength = 999999999999999,
		LineDistance = 150,
		Resilience = -500,
		Control = -0.37,
		Durability = 200,
		Color = Color3.fromRGB(238, 0, 4),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(39, 39, 39),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		MutationPool = {
			Tryhard = 100
		},
		MutationPoolCatchOnly = true,
		ForcedProgressEfficiency = 1.35,
		ProgressEfficiency = 1.65,
		ReelGuiName = "tryhardrod",
		FishingPassives = {
			Generic_HardStatLimit = {
				Control = -0.13
			}
		},
		ClientFishingPassives = {
			Generic_KillSimplified = {},
			Generic_AntiSlashes = {
				DamageReduction = 0.25,
				DisableStun = true
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				Lure = 20,
				ForcedProgressSpeed = 15,
				ProgressSpeed = 10
			}
		},
		Cool = true,
		LevelRequirement = 999,
		Unpurchasable = true,
		From = "Roslit Volcano",
		Hint = "Obtainable from RoRed."
	},
	["Patience Rod"] = {
		Icon = "rbxassetid://126136158757095",
		Price = 1e999,
		Description = "Endure the wait or catch nothing. -RoReddo",
		Luck = 25,
		LureSpeed = 2525,
		Strength = 252525252525,
		LineDistance = 150,
		Resilience = 252525,
		Control = 0.95,
		Color = Color3.fromRGB(0, 89, 255),
		BobberTop = Color3.fromRGB(0, 89, 255),
		BobberBottom = Color3.fromRGB(0, 28, 80),
		FixedProgressEfficiency = 0.05,
		MutationPool = {
			Chaotic = 100
		},
		WeightBoost = 50,
		DEV = true,
		Unregistered = true,
		Unpurchasable = true
	},
	["Sovereign Doombringer"] = {
		Icon = "rbxassetid://110232945576999",
		Price = 1e999,
		Description = "Obliterate fish with a huge hammer. [Developer-Exclusive]",
		Luck = 150,
		LureSpeed = 35,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		Color = Color3.fromRGB(137, 198, 255),
		BobberTop = Color3.fromRGB(151, 184, 255),
		BobberBottom = Color3.fromRGB(32, 37, 47),
		FishingPassives = {
			Generic_FallingWeapon = {
				ModelScale = 4,
				TriggerChance = 100,
				ProgressGain = 30,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 0, -30),
				EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				PivotOffset = CFrame.new(0, -2.5, 0),
				FallAnimTime = 2,
				HitSoundName = "doombringerhammer"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Oblivion Doombreaker"] = {
		Icon = "rbxassetid://136984096344794",
		Price = 1e999,
		Description = "Obliterate fish with a huge flame-engulfed hammer. [Developer-Exclusive]",
		Luck = 150,
		LureSpeed = 500,
		Strength = 1e999,
		LineDistance = 1000,
		Resilience = 100,
		Control = 0.05,
		Color = Color3.fromRGB(255, 87, 57),
		BobberTop = Color3.fromRGB(180, 39, 34),
		BobberBottom = Color3.fromRGB(47, 0, 0),
		FishingPassives = {
			Generic_FallingWeapon = {
				OverrideModelName = "OblivionProp",
				ModelScale = 1,
				TriggerChance = 100,
				ProgressGain = 99,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 70, 0),
				EndingOffset = CFrame.new(0, -95, 0),
				PivotOffset = CFrame.new(0, 0, 0),
				FallAnimTime = 1.1,
				ShockwaveSizeEnd = 60,
				HitSoundName = "oblivionmeteor"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Dave Rod"] = {
		Icon = "rbxassetid://72532329518741",
		Price = 1e999,
		ForcedProgressEfficiency = -0.51,
		Description = "PLSS DAVE RODDDD!",
		Luck = -1e21,
		LureSpeed = -1e21,
		Strength = 1e21,
		LineDistance = 1500,
		Resilience = -1e21,
		Control = 0.7,
		Color = Color3.fromRGB(59, 59, 59),
		BobberTop = Color3.fromRGB(189, 189, 189),
		BobberBottom = Color3.fromRGB(144, 144, 144),
		FishingPassives = {
			Generic_ForcedReplacePool = {
				ReplacementPool = {
					Rock = 100
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Dave",
		Hint = "BOULDER BOULDER BOULDER."
	},
	Crowbar = {
		Icon = "rbxassetid://86734775868208",
		Price = 1e999,
		Description = "insert metal pipe noise here",
		Luck = 245,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 35,
		Control = 0.15,
		Color = Color3.fromRGB(59, 59, 59),
		BobberTop = Color3.fromRGB(125, 7, 7),
		BobberBottom = Color3.fromRGB(62, 62, 62),
		ProgressEfficiency = 0.4,
		Disturbance = 3,
		MutationPool = {
			Contraband = 50,
			Counterfeit = 10
		},
		ReelGuiName = "crowbar",
		FishingPassives = {
			StealFish = {
				ActivateEvery = 3,
				ActivateDuration = 10,
				MaxPerActivate = 1,
				ForceMutationPool = true,
				PassiveBlockLevel = 2,
				MutationPool = {
					Counterfeit = 100
				}
			},
			ReRod = {
				PropName = "CrowbarSwing",
				VfxName = "CrowbarVFX",
				SoundName = "rerod",
				ProgressGain1 = 5,
				ProgressGain2 = 5,
				ProgressGain3 = 15,
				ProgressGain1_PerfectCast = 10,
				ProgressGain2_PerfectCast = 10,
				ProgressGain3_PerfectCast = 20
			}
		},
		From = "Roslit",
		Hint = "Obtained at The Laboratory.",
		Unpurchasable = true,
		Unregistered = true
	},
	["Venomfang Rod"] = {
		Icon = "rbxassetid://113297611358849",
		Price = 1e999,
		Description = "From the bowels of an ancient temple. [For @kylecat11]",
		Luck = 250,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.65,
		Color = Color3.fromRGB(96, 36, 131),
		BobberTop = Color3.fromRGB(107, 41, 148),
		BobberBottom = Color3.fromRGB(40, 15, 56),
		ReelGuiName = "venomfangrod",
		ClientFishingPassives = {
			["Venomfang Rod"] = {}
		},
		FishingPassives = {
			VenomfangRod = {}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Vinefang Rod",
		Unpurchasable = true
	},
	["The Brick Rod"] = {
		Icon = "rbxassetid://85235574632292",
		Price = 1e999,
		Description = "It's real. [For @LiamGame09]",
		Luck = 250,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.65,
		Color = Color3.fromRGB(128, 64, 255),
		BobberTop = Color3.fromRGB(255, 183, 38),
		BobberBottom = Color3.fromRGB(144, 11, 28),
		ReelGuiName = "thebrickrod",
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 100,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "The Brick Rod",
				SoundName = "stabbystabthebrickrod",
				IconName = "The Brick Rod",
				GradientColor = "The Brick Rod"
			},
			["The Brick Rod"] = {}
		},
		FishingPassives = {
			TheBrickRod = {}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	CocoRod = {
		Icon = "rbxassetid://94333883442853",
		Price = 1e999,
		Description = "The Coco-nut-nut is a giant nut. [For @Goober_ish]",
		Luck = 250,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.65,
		Color = Color3.fromRGB(72, 52, 42),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 255),
		FishingPassives = {
			Generic_FallingWeapon = {
				OverrideModelName = "CoconutProp",
				TriggerChance = 100,
				ProgressGain = 100,
				ProgressGainSplit = 10,
				ProgressGainSplitInterval = 0.1,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 50, 0),
				EndingOffset = CFrame.new(0, -50, 0),
				PivotOffset = nil,
				FallAnimTime = 1,
				EasingStyle = Enum.EasingStyle.Quart,
				ShockwaveSizeEnd = 60,
				HitSoundName = "coconut"
			}
		},
		ReelGuiName = "cocorod",
		ClientFishingPassives = {
			CocoRod = {}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Prismatic Rod"] = {
		Icon = "rbxassetid://133233794877921",
		Price = 1e999,
		Description = "Feel my unstoppable daggers! [For @naivepassion]",
		Luck = 250,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.65,
		Color = Color3.fromRGB(101, 104, 148),
		BobberTop = Color3.fromRGB(134, 125, 195),
		BobberBottom = Color3.fromRGB(34, 31, 47),
		ReelGuiName = "prismaticrod",
		ClientFishingPassives = {
			["Prismatic Rod"] = {}
		},
		FishingPassives = {
			FallingDaggers = {
				MaximumHits = 2,
				ProjectileName = "PrismaticProjectile",
				SoundName = "prismaticdagger",
				ProgressGain = 55
			}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		Unpurchasable = true
	},
	Maelstrom = {
		Icon = "rbxassetid://132589475075099",
		Price = 3250000,
		Description = [[
Only obtainable during Fischmas;
A glacial bow of overwhelming power, capable of locking the sea in its grasp...]],
		Luck = 85,
		LureSpeed = 20,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 35,
		Control = 0.15,
		ProgressEfficiency = -0.1,
		Color = Color3.fromRGB(101, 104, 148),
		BobberTop = Color3.fromRGB(134, 125, 195),
		BobberBottom = Color3.fromRGB(34, 31, 47),
		MutationPool = {
			Frostbitten = 30
		},
		ReelGuiName = "maelstrom",
		ClientFishingPassives = {
			Maelstrom = {},
			Generic_KillSimplified = {}
		},
		LevelRequirement = 100,
		Unregistered = true,
		Unpurchasable = true,
		Requirements = {
			DataValues = {
				{
					Path = "LifetimeCatches.Cryoshock Serpent",
					ExpectedValue = 1,
					FailMessage = "The serpent watches."
				}
			},
			WorldState = {
				{
					Name = "meteorological",
					ExpectedValue = "Frost Moon",
					FailMessage = "Return once more under the dim light of a frozen moon."
				}
			}
		},
		Hint = "Obtainable during Fischmas 2.",
		From = "Fischmas 2",
		Tags = { "Bow" }
	},
	["Yin Yang Rod"] = {
		Icon = "rbxassetid://122751777851520",
		Price = 1e999,
		Description = "i ate a piece of bark, and got poisoned - yvlyf",
		Luck = 375,
		LureSpeed = -50,
		Strength = 1e999,
		LineDistance = 125,
		Resilience = 75,
		Control = 0.7,
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(255, 255, 255),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		FishingPassives = {
			VerdantShearRod = {
				SPAWN_TREE_CHANCE = 100,
				CALCULATED_SYNC = 0.55,
				DESPAWN_TREE_TIME = 60,
				TREE_MUTATION_POOL = {
					["Mother Nature"] = 33.333333333333336,
					["Green Leaf"] = 33.333333333333336,
					["Brown Wood"] = 33.333333333333336
				},
				TREE_MODEL_NAME = "YinYang"
			},
			FallingDaggers = {
				MaximumHits = 4,
				ProjectileName = "YangProjectile",
				SoundName = "coconut",
				ProgressGain = 55
			}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Verdant Shear Rod",
		Unpurchasable = true
	},
	["Fabulous Rod"] = {
		Icon = "rbxassetid://104123308695417",
		Price = 1e999,
		Description = "As fabulous as possible! Actually, even more than that. [For @GreenResolve]",
		Luck = 300,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 50,
		Control = 0,
		Color = Color3.fromRGB(218, 167, 235),
		BobberTop = Color3.fromRGB(218, 167, 235),
		BobberBottom = Color3.fromRGB(166, 236, 232),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 3,
		PreferredDisturbance = {
			Event = "ColossalEtherealDragon",
			Risk = 2
		},
		ReelGuiName = "fabulousrod",
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "Interval",
				SlashChance = 25,
				SlashDamage = 3,
				StunTime = 0,
				RawStun = false,
				SlashInterval = 0.4,
				SourceType = "rod",
				SourceName = "Fabulous Rod",
				SoundName = "fabulousSlash",
				IconName = "Fabulous Rod",
				GradientColor = "Fabulous Rod"
			},
			["Fabulous Rod"] = {
				RevengeDuration = 3,
				AllowedSlashSources = { "Fabulous Rod" },
				RequiredSlashCombo = 3
			}
		},
		MutationPool = {
			Fabulous = 49
		},
		WeightBoost = 25,
		EnhancementPatches = {
			Mastery1 = {
				WeightBoost = 40,
				ClientFishingPassives = {
					Generic_Slashes = {
						MutationOverrides = {
							Fabulous = {
								SlashChance = 40
							}
						}
					}
				}
			},
			Mastery2 = {
				ShinyChance = 5,
				SparklingChance = 5
			}
		},
		Unpurchasable = true,
		LevelRequirement = 1000,
		From = "Calm Zone",
		Hint = "Obtained from Fabulous Deity."
	},
	["Blade Of Glorp"] = {
		Icon = "rbxassetid://113934986272654",
		Price = 1e999,
		Description = "A sharp Blade & friendly UFO crafted by Glorp harnesses the power of Lasers. Be careful, it is hot and will melt your hands if touched. [For @uhvanni]",
		Luck = 288,
		LureSpeed = 0,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 45,
		Control = 0.05,
		Color = Color3.fromRGB(189, 255, 83),
		BobberTop = Color3.fromRGB(241, 255, 85),
		BobberBottom = Color3.fromRGB(161, 255, 89),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 2,
		SlashChance = 88,
		MutationPool = {
			Gleebous = 23
		},
		ReelGuiName = "bladeofglorp",
		FishingPassives = {
			GlorpBlade = {
				SECOND_UFO_ENABLED = false,
				UFO_DISTANCE = 2
			}
		},
		ClientFishingPassives = {
			["Blade Of Glorp"] = {
				LaserTime = 2.5,
				BeamLife = 0.15,
				LaserChance = 5,
				LaserSize = 30,
				WarningCount = 2
			},
			Generic_KillSimplified = {}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Gleebous = 33
				},
				FishingPassives = {
					GlorpBlade = {
						SECOND_UFO_ENABLED = true,
						UFO_DISTANCE = 1.3
					}
				},
				ClientFishingPassives = {
					["Blade Of Glorp"] = {
						LaserChance = 3,
						LaserSize = 50,
						WarningCount = 4
					}
				}
			}
		},
		Unpurchasable = true,
		LevelRequirement = 888,
		From = "Roslit",
		Hint = "Obtained from Glorp."
	},
	["Katana Rod"] = {
		Icon = "rbxassetid://138361927178338",
		Price = 1e999,
		Description = "Good at cutting fruit. \n[Black Market Exclusive]",
		Luck = 150,
		LureSpeed = 5,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.15,
		Color = Color3.fromRGB(177, 177, 177),
		BobberTop = Color3.fromRGB(197, 197, 197),
		BobberBottom = Color3.fromRGB(48, 48, 48),
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Katana Rod",
				SoundName = "stabbystab",
				IconName = "Default",
				GradientColor = Color3.fromRGB(88, 88, 88)
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Black Market",
		Hint = "Obtained from the Black Market."
	},
	["Sword of Darkness"] = {
		Icon = "rbxassetid://130526509714895",
		Price = 1e999,
		Description = [=[
Dare to reach out your hand into the darkness, to pull another hand into the dark from the light. 
[Black Market Exclusive]]=],
		Luck = 250,
		LureSpeed = -150,
		Strength = 1000000,
		LineDistance = 100,
		Resilience = -50,
		Control = -0.17,
		Color = Color3.fromRGB(60, 60, 60),
		BobberTop = Color3.fromRGB(255, 239, 119),
		BobberBottom = Color3.fromRGB(48, 48, 48),
		SlashDamage = 3,
		ReelGuiName = "swordofdarkness",
		FishingPassives = {
			Generic_TieredBoosts = {
				DefaultLevel = 1,
				RequirePerfect = false,
				AllowRefresh = false,
				FullReset = true,
				BuffId = "Darkness",
				Levels = {
					{
						Boosts = {},
						MutationPool = {}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ProgressSpeed = 10
						},
						MutationPool = {
							Darkness = 5
						}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ProgressSpeed = 20
						},
						MutationPool = {
							Darkness = 10
						}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ProgressSpeed = 150
						},
						MutationPool = {
							Darkness = 100
						}
					}
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 3,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Sword of Darkness",
				SoundName = "stabbystab",
				IconName = "Sword of Darkness",
				GradientColor = "Sword of Darkness"
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		LevelRequirement = 100,
		From = "Black Market",
		Hint = "Obtained from the Black Market."
	},
	["Rex Umbrarum"] = {
		Icon = "rbxassetid://136335246003651",
		Price = 1e999,
		Description = "Beeg Heavy Sord [For @Plutoly]",
		Luck = 150,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 10,
		Control = 0.35,
		Color = Color3.fromRGB(100, 9, 18),
		BobberTop = Color3.fromRGB(159, 160, 162),
		BobberBottom = Color3.fromRGB(32, 32, 34),
		FishingPassives = {
			Generic_FallingWeapon = {
				ModelScale = 2,
				TriggerChance = 100,
				ProgressGain = 99,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 40, 0),
				EndingOffset = CFrame.new(0, -50, 0),
				PivotOffset = CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0),
				FallAnimTime = 1,
				EasingStyle = Enum.EasingStyle.Quart,
				ShockwaveSizeEnd = 60,
				HitSoundName = "rexsword"
			}
		},
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Plaguereaver",
		Unpurchasable = true
	},
	["Wind Elemental"] = {
		Icon = "rbxassetid://131474362599126",
		Price = 1e999,
		Description = "May you slash with all the colors of the wind.",
		Luck = 255,
		LureSpeed = -455,
		Strength = 1e999,
		LineDistance = 555,
		Resilience = 55,
		Control = 0.055,
		ProgressSpeed = 25,
		Color = Color3.fromRGB(221, 206, 92),
		BobberTop = Color3.fromRGB(194, 181, 0),
		BobberBottom = Color3.fromRGB(255, 252, 166),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		FishingPassives = {
			Generic_FallingWeapon = {
				ModelScale = 3,
				TriggerChance = 100,
				ProgressGain = 30,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 20, 0),
				EndingOffset = CFrame.new(0, -50, 0),
				PivotOffset = CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0),
				FallAnimTime = 1,
				EasingStyle = Enum.EasingStyle.Quart,
				ShockwaveSizeEnd = 60,
				HitSoundName = "rexsword"
			}
		},
		ClientFishingPassives = {
			QuickModeSwap = {
				LinkedRod = "Wind Elemental"
			}
		},
		DefaultMode = "Wind",
		Modes = {
			Wind = {
				DisplayName = "Wind",
				Icon = "rbxassetid://131474362599126",
				Order = 1,
				Color = Color3.fromRGB(247, 255, 164),
				Description = [[
Buffed during <b>Windy</b> weather, granting Breezed mutation
Increased base Luck]],
				Patches = {
					Luck = apply_op.ADD(45),
					MutationPool = {
						Breezed = 30
					},
					FishingPassives = {
						Generic_WeatherBoosts = {
							Windy = {
								Boosts = {
									ProgressSpeed = 50
								},
								MutationPool = {
									Breezed = 20
								}
							}
						}
					}
				}
			},
			Earth = {
				DisplayName = "Earth Elemental",
				Icon = "rbxassetid://108009780916105",
				Order = 2,
				Color = Color3.fromRGB(163, 129, 74),
				Description = [[
Buffed during <b>Clear</b> weather, granting Terra mutation
Increased base Control and Durability]],
				Hint = "Unlocked via Rod Mastery",
				RequiresUnlock = true,
				OverrideModelName = "Earth Elemental",
				Patches = {
					Control = 0.15,
					Durability = 50,
					MutationPool = {
						Terra = 30
					},
					FishingPassives = {
						Generic_WeatherBoosts = {
							Clear = {
								Boosts = {
									ProgressSpeed = 50
								},
								MutationPool = {
									Terra = 20
								}
							}
						},
						Generic_FallingWeapon = {
							OverrideModelName = "EarthElementalProp"
						}
					}
				}
			},
			Fire = {
				DisplayName = "Fire Elemental",
				Icon = "rbxassetid://114006230603980",
				Order = 3,
				Color = Color3.fromRGB(255, 115, 39),
				Description = [[
Buffed during <b>Foggy</b> weather, granting Ignited mutation
Increased base Durability and passively grants minigame progress]],
				Hint = "Unlocked via Rod Mastery",
				RequiresUnlock = true,
				OverrideModelName = "Fire Elemental",
				Patches = {
					Durability = 100,
					MutationPool = {
						Ignited = 30
					},
					FishingPassives = {
						Generic_WeatherBoosts = {
							Foggy = {
								Boosts = {
									ProgressSpeed = 50
								},
								MutationPool = {
									Ignited = 20
								}
							}
						},
						Generic_FallingWeapon = {
							OverrideModelName = "FireElementalProp"
						}
					},
					ClientFishingPassives = {
						Generic_ProgressPerSecond = {
							ProgressPerSecond = 2
						}
					}
				}
			},
			Water = {
				DisplayName = "Water Elemental",
				Icon = "rbxassetid://77932361133136",
				Order = 4,
				Color = Color3.fromRGB(94, 148, 255),
				Description = [[
Buffed during <b>Rainy</b> weather, granting Stormy mutation
Increased base Durability]],
				Hint = "Unlocked via Rod Mastery",
				RequiresUnlock = true,
				OverrideModelName = "Water Elemental",
				Patches = {
					Durability = 150,
					MutationPool = {
						Stormy = 30
					},
					FishingPassives = {
						Generic_WeatherBoosts = {
							Rain = {
								Boosts = {
									ProgressSpeed = 50
								},
								MutationPool = {
									Stormy = 20
								}
							}
						},
						Generic_FallingWeapon = {
							ProgressGain = 40,
							OverrideModelName = "WaterElementalProp"
						}
					}
				}
			},
			Omni = {
				DisplayName = "Omni Elemental",
				Icon = "rbxassetid://131474362599126",
				Order = 5,
				Color = Color3.fromRGB(255, 255, 255),
				Description = [[
Buffed during all weathers, granting all previous mutations
Increased base Durability, Control and Luck]],
				Hint = "Unlocked via Rod Mastery",
				RequiresUnlock = true,
				OverrideModelName = "Omni Elemental",
				Patches = {
					ProgressSpeed = 55,
					Luck = apply_op.ADD(25),
					Control = 0.1,
					Durability = 200,
					MutationPool = {
						Breezed = 20,
						Terra = 20,
						Ignited = 20,
						Stormy = 20
					},
					FishingPassives = {
						Generic_FallingWeapon = {
							ProgressGain = 35,
							OverrideModelName = "OmniElementalProp"
						}
					},
					ClientFishingPassives = {
						Generic_ProgressPerSecond = {
							ProgressPerSecond = 1
						}
					}
				}
			}
		},
		Unpurchasable = true,
		LevelRequirement = 800,
		From = "Glacial Grotto",
		Hint = "Obtainable from the Wind Master."
	},
	Onirifalx = {
		Icon = "rbxassetid://72800181932258",
		ProgressEfficiency = 0.7,
		Price = 1e999,
		Description = [=[
Tempered in dreams and sharpened by peril, the Onirifalx reaps catches with unrivaled speed for those who can hold their ground.
[For @animepunk]]=],
		Luck = 277,
		LureSpeed = -677,
		Strength = 1e999,
		LineDistance = 777,
		Resilience = -1e999,
		Control = 0.17,
		Durability = 200,
		Color = Color3.fromRGB(157, 208, 255),
		BobberTop = Color3.fromRGB(210, 236, 255),
		BobberBottom = Color3.fromRGB(17, 19, 21),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 5000
			}
		},
		Disturbance = 4,
		PreferredDisturbance = {
			Event = "DepthsAbsoluteDarkness",
			Risk = 2
		},
		MutationPool = {
			Puritas = 3,
			Sacratus = 7,
			Levitas = 50
		},
		ReelGuiName = "onirifalx",
		FishingPassives = {
			Onirifalx = {
				BoostsPerPerfectCatch = {
					ProgressSpeed = 5,
					Control = -0.01
				},
				MinBoosts = {
					ProgressSpeed = 0,
					Control = -0.1
				},
				MaxBoosts = {
					ProgressSpeed = 50,
					Control = 0
				}
			},
			Generic_FallingWeapon = {
				ModelScale = 3,
				TriggerChance = 30,
				ProgressGain = 30,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 0, -30),
				EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				PivotOffset = CFrame.new(0, -2.5, 0),
				FallAnimTime = 1,
				HitSoundName = "onirifalximpact"
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Puritas = 7,
					Sacratus = 13,
					Levitas = 60
				},
				FishingPassives = {
					Onirifalx = {
						BoostsPerPerfectCatch = {
							ProgressSpeed = 8
						},
						MaxBoosts = {
							ProgressSpeed = 80
						}
					}
				}
			}
		},
		LevelRequirement = 1000,
		Unpurchasable = true,
		From = "The Depths",
		Hint = "Obtained from Nick."
	},
	Illumina = {
		Icon = "rbxassetid://117278379103930",
		ProgressEfficiency = 10,
		Price = 1e999,
		Description = "Telamon's favorite weapon from Sword Fight on the Heights. It is light, agile, and deadly.",
		Luck = 1000,
		LureSpeed = -900,
		Strength = 1e999,
		LineDistance = 1000,
		Resilience = 1000,
		Control = 1,
		Durability = 200,
		Color = Color3.fromRGB(193, 226, 255),
		BobberTop = Color3.fromRGB(193, 226, 255),
		BobberBottom = Color3.fromRGB(239, 16, 255),
		Disturbance = 25,
		ClientFishingPassives = {
			Generic_ReelRecolor = {
				BackgroundColor3 = Color3.fromRGB(89, 105, 118),
				progress = {
					BackgroundColor3 = Color3.fromRGB(151, 176, 199),
					bar = {
						BackgroundColor3 = Color3.fromRGB(193, 226, 255)
					}
				},
				fish = {
					BackgroundColor3 = Color3.fromRGB(193, 226, 255),
					icon = {
						ImageColor3 = Color3.fromRGB(217, 0, 255)
					}
				}
			}
		},
		FishingPassives = {
			Generic_MakeUntradeable = {
				TradeCooldown = -1
			}
		},
		InstantCatch = true,
		StartingProgress = 80,
		ShinyChance = 100,
		SparklingChance = 100,
		Unregistered = true,
		DEV = true,
		OP = true,
		Unpurchasable = true
	},
	Darkheart = {
		Icon = "rbxassetid://93784975681164",
		Price = 1e999,
		Description = "It's darker than RGB(0,0,0) and it steals life from your enemies. What more is there to say.",
		Luck = 200,
		LureSpeed = -900,
		Strength = 1e999,
		LineDistance = 1000,
		Resilience = -10,
		Control = -0.1,
		Durability = 500,
		Color = Color3.fromRGB(35, 35, 35),
		BobberTop = Color3.fromRGB(0, 0, 0),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		Disturbance = 10,
		LevelRequirement = 500,
		AlwaysEnforceLevelRequirement = true,
		MutationPool = {
			Darkheart = 15
		},
		ReelGuiName = "darkheart",
		FishingPassives = {
			Darkheart = {
				MaxStacks = 3
			}
		},
		ClientFishingPassives = {
			Darkheart = {
				DARKNESS_PER_SLASH = 25,
				DARKNESS_PROGRESS_MAX_STACKS = 40,
				DARKNESS_PROGRESS_MAX_STACKS_FPS = 40,
				DARKNESS_DRAIN = 5,
				DRAIN_TIME = 2.5,
				MAX_STACKS = 3
			},
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 50,
				SlashDamage = 7,
				StunTime = 0.3,
				RawStun = false,
				OnlyOnBar = true,
				SourceType = "rod",
				SourceName = "Darkheart",
				SoundName = "darkheart",
				IconName = "Darkheart",
				GradientColor = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 7, 7)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 7))
				})
			}
		},
		StartingProgress = 0.01,
		ShinyChance = -100,
		SparklingChance = -100,
		Unregistered = true,
		Unpurchasable = true
	},
	["Sword of Light"] = {
		Icon = "rbxassetid://140550782584897",
		Price = 1e999,
		Description = [=[
Who is more foolish, the child afraid of the dark or the man afraid of the light? 
[Black Market Exclusive]]=],
		Luck = 250,
		LureSpeed = -100,
		Strength = 1000000,
		LineDistance = 100,
		Resilience = 50,
		Control = 0.17,
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(255, 255, 255),
		BobberBottom = Color3.fromRGB(255, 246, 196),
		SlashDamage = 3,
		ReelGuiName = "swordoflight",
		FishingPassives = {
			Generic_TieredBoosts = {
				DefaultLevel = 1,
				RequirePerfect = true,
				AllowRefresh = true,
				FullReset = true,
				BuffId = "Light",
				Levels = {
					{
						Boosts = {},
						MutationPool = {}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ForcedProgressSpeed = 5
						},
						MutationPool = {
							Light = 5
						}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ForcedProgressSpeed = 10
						},
						MutationPool = {
							Light = 10
						}
					},
					{
						Duration = 30,
						CatchRequirement = 1,
						Boosts = {
							ForcedProgressSpeed = 20
						},
						MutationPool = {
							Light = 100
						}
					}
				}
			}
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 70,
				SlashDamage = 3,
				StunTime = 0.1,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Sword of Light",
				SoundName = "stabbystab",
				IconName = "Sword of Light",
				GradientColor = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 244, 201)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 244, 201))
				})
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		LevelRequirement = 100,
		From = "Black Market",
		Hint = "Obtained from the Black Market."
	},
	["Training Rod"] = {
		Icon = "rbxassetid://97227051346282",
		Price = 300,
		MinDistanceToPurchase = 30,
		Description = "Handy fishing rod for honing your fishing skills. Remember, stay calm.",
		Luck = -70,
		LureSpeed = 90,
		Strength = 9,
		LineDistance = 20,
		Resilience = 20,
		Control = 0.2,
		Color = Color3.fromRGB(100, 198, 207),
		BobberTop = Color3.fromRGB(115, 199, 255),
		BobberBottom = Color3.fromRGB(50, 50, 50),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Fast Rod"] = {
		Icon = "rbxassetid://89552461717134",
		Price = 4000,
		MinDistanceToPurchase = 30,
		Description = "Quick rod that seems to catch fish in a fly! You can tell it's fast from the racing stripes.",
		Luck = 10,
		LureSpeed = 30,
		Strength = 175,
		LineDistance = 20,
		Resilience = -5,
		Control = 0.05,
		Color = Color3.fromRGB(255, 101, 101),
		BobberTop = Color3.fromRGB(255, 103, 103),
		BobberBottom = Color3.fromRGB(255, 105, 105),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Lucky Rod"] = {
		Icon = "rbxassetid://91243968652771",
		Price = 4500,
		MinDistanceToPurchase = 30,
		Description = "Seems to attract a handful of rare fish. Not sure why?.. Maybe I should buy a lottery ticket?",
		Luck = 177,
		LureSpeed = 80,
		Strength = 175,
		LineDistance = 20,
		Resilience = 7,
		Control = 0.07,
		Color = Color3.fromRGB(188, 255, 190),
		BobberTop = Color3.fromRGB(80, 134, 80),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		From = "Moosewood",
		Hint = "Purchasable at Moosewood."
	},
	["Steady Rod"] = {
		Icon = "rbxassetid://133367355747623",
		Price = 7000,
		MinDistanceToPurchase = 30,
		Description = "Insanely stiff and strong. Can withstand immense pressure and tension. [Increases shake UI size and power]",
		Luck = 35,
		LureSpeed = 160,
		Strength = 250000,
		LineDistance = 25,
		Resilience = 45,
		Control = 0.1,
		Color = Color3.fromRGB(255, 190, 160),
		BobberTop = Color3.fromRGB(85, 85, 85),
		BobberBottom = Color3.fromRGB(95, 95, 95),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		ShakeSize = 100,
		ShakePower = 100,
		EnhancementPatches = {
			Mastery1 = {
				Lure = 30,
				ProgressSpeed = 10
			}
		},
		From = "Roslit",
		Hint = "Purchasable at Roslit Bay."
	},
	["Fortune Rod"] = {
		Icon = "rbxassetid://100096407996269",
		Price = 11000,
		MinDistanceToPurchase = 30,
		Description = "Extremely lucky rod with an odd tendency to attract significantly rarer fish than usual.",
		Luck = 200,
		LureSpeed = 70,
		Strength = 3000,
		LineDistance = 20,
		Resilience = 10,
		Control = 0.05,
		Color = Color3.fromRGB(109, 77, 212),
		BobberTop = Color3.fromRGB(83, 56, 120),
		BobberBottom = Color3.fromRGB(255, 233, 111),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		From = "Roslit",
		Hint = "Purchasable at Roslit Bay."
	},
	["Magma Rod"] = {
		Icon = "rbxassetid://87767141972860",
		Price = 1e999,
		Description = "Hot to the touch. Engulfed with a constant burning passion to fish. [Capable of fishing in lava, 35% chance for fish to become mutated with Ember]",
		Luck = 55,
		LureSpeed = 55,
		Strength = 1200,
		LineDistance = 32,
		Resilience = 0,
		Control = 0.15,
		Durability = 100,
		Color = Color3.fromRGB(255, 122, 55),
		BobberTop = Color3.fromRGB(74, 41, 41),
		BobberBottom = Color3.fromRGB(33, 33, 33),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Ember = 35
		},
		Unpurchasable = true,
		From = "Roslit Volcano",
		Hint = "Obtained from the Orc."
	},
	["Reinforced Rod"] = {
		Icon = "rbxassetid://117938768391908",
		Price = 20000,
		MinDistanceToPurchase = 30,
		Description = "Crafted by a metal stronger than diamond, making it capable of fishing in any harmful liquid.",
		Luck = 65,
		LureSpeed = 60,
		Strength = 1e999,
		LineDistance = 32,
		Resilience = 15,
		Control = 0.1,
		Durability = 200,
		Color = Color3.fromRGB(255, 178, 89),
		BobberTop = Color3.fromRGB(244, 152, 86),
		BobberBottom = Color3.fromRGB(39, 31, 25),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		From = "Desolate Deep",
		Hint = "Purchasable at a small pocket nearby the Desolate Deep.",
		Cool = true
	},
	["Stone Rod"] = {
		Icon = "rbxassetid://106449091871722",
		Price = 2000,
		Description = "A rock-hard rod made purely from stone, which also makes it quite heavy.",
		Luck = 40,
		LureSpeed = 105,
		Strength = 50000,
		LineDistance = 24,
		Resilience = 50,
		Control = 0.2,
		Color = Color3.fromRGB(110, 110, 120),
		BobberTop = Color3.fromRGB(85, 85, 93),
		BobberBottom = Color3.fromRGB(32, 32, 35),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 100
			}
		},
		MutationPool = {
			Stone = 100
		},
		ClientFishingPassives = {
			Generic_AddModifiers = {
				Modifiers = {
					multiply = {
						barMoveSpeed = 0.7
					}
				}
			}
		},
		From = "Ancient Isle",
		Hint = "Purchasable at Ancient Isle."
	},
	["Phoenix Rod"] = {
		Icon = "rbxassetid://129257555514795",
		Price = 50000,
		MinDistanceToPurchase = 30,
		Description = "Embued with the spirit of the graceful Phoenix. All fish have a 40% chance to be set ablaze, with 10% possessing the power of the Eclipse.",
		Luck = 80,
		LureSpeed = 45,
		Strength = 8000,
		LineDistance = 20,
		Resilience = 15,
		Control = 0.02,
		Color = Color3.fromRGB(255, 98, 87),
		BobberTop = Color3.fromRGB(234, 78, 255),
		BobberBottom = Color3.fromRGB(255, 116, 51),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Scorched = 40,
			Solarblaze = 10
		},
		From = "Ancient Isle",
		Hint = "Purchasable at Ancient Isle.",
		Cool = true
	},
	["Midas Rod"] = {
		Icon = "rbxassetid://104225938852074",
		Price = 55000,
		Description = "Blessed with the power of Midas. All caught fish will be golden.",
		Luck = 79,
		LureSpeed = 30,
		Strength = 4000,
		LineDistance = 15,
		Resilience = -30,
		Control = 0.2,
		Color = Color3.fromRGB(255, 226, 83),
		BobberTop = Color3.fromRGB(255, 184, 62),
		BobberBottom = Color3.fromRGB(255, 171, 53),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Midas = 100
		},
		EnhancementPatches = {
			Mastery1 = {
				Resilience = 0,
				ProgressSpeed = 10
			}
		},
		From = "Ocean",
		Hint = "Purchasable from the Travelling Merchant.",
		Cool = true
	},
	["Trident Rod"] = {
		Icon = "rbxassetid://73297042214602",
		Price = 150000,
		MinDistanceToPurchase = 30,
		Description = "Was originally the King of the Sea's way of defending his kingdom. All fish have a 30% chance to be Atlantean. [Has a chance to stab a fish while catching it, briefly stunning it and increasing progress]",
		Luck = 150,
		LureSpeed = 65,
		Strength = 6000,
		LineDistance = 100,
		Resilience = 0,
		Control = 0.05,
		Color = Color3.fromRGB(255, 191, 80),
		BobberTop = Color3.fromRGB(255, 178, 53),
		BobberBottom = Color3.fromRGB(255, 152, 48),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		Disturbance = 3,
		MutationPool = {
			Atlantean = 30
		},
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Trident Rod",
				SoundName = "stabbystab",
				IconName = "Trident Rod",
				GradientColor = Color3.fromRGB(255, 207, 84)
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				Lure = 35
			}
		},
		From = "Desolate Deep",
		Hint = "Purchasable somewhere near a hidden cave of the Desolate Deep; hidden behind a mysterious locked door.",
		Cool = true
	},
	["Mythical Rod"] = {
		Icon = "rbxassetid://94583240347875",
		Price = 90000,
		Description = "Blessed with the power of The Keepers. All fish have a 30% chance to be rainbow.",
		Luck = 60,
		LureSpeed = 60,
		Strength = 2500,
		LineDistance = 20,
		Resilience = 15,
		Control = 0.05,
		Color = Color3.fromRGB(255, 49, 159),
		BobberTop = Color3.fromRGB(255, 103, 156),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Mythical = 30
		},
		EnhancementPatches = {
			Mastery1 = {
				Lure = 35,
				MutationPool = {
					Mythical = 35
				}
			}
		},
		From = "Ocean",
		Hint = "Purchasable from the Travelling Merchant.",
		Cool = true
	},
	["Rapid Rod"] = {
		Icon = "rbxassetid://81722647940867",
		Price = 12000,
		MinDistanceToPurchase = 30,
		Description = "Extremely fast rod that catches fish at record speeds! -It even has racing wings!",
		Luck = 49,
		LureSpeed = 11,
		Strength = 800,
		LineDistance = 21,
		Resilience = 9,
		Control = 0,
		Color = Color3.fromRGB(255, 163, 87),
		BobberTop = Color3.fromRGB(255, 161, 94),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		From = "Roslit",
		Hint = "Purchasable at Roslit Bay."
	},
	["Brick Rod"] = {
		Icon = "rbxassetid://107006503164769",
		Price = 13337,
		Description = "Wait.. it's real?",
		Luck = 75,
		LureSpeed = 100,
		Strength = 1e999,
		LineDistance = 200,
		Resilience = 35,
		Control = 0.35,
		Color = Color3.fromRGB(245, 90, 90),
		BobberTop = Color3.fromRGB(245, 103, 103),
		BobberBottom = Color3.fromRGB(61, 35, 35),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		MutationPool = {
			Studded = 100
		},
		Hint = "A series of bricks...",
		Unregistered = true,
		NotLimited = true
	},
	["Magnet Rod"] = {
		Icon = "rbxassetid://121694522761024",
		Price = 15000,
		MinDistanceToPurchase = 30,
		Description = "This rod has an advanced magnetic field, allowing it to quickly attract crates and loot.",
		Luck = 0,
		LureSpeed = 110,
		Strength = 10000,
		LineDistance = 21,
		Resilience = 0,
		Control = 0.05,
		Color = Color3.fromRGB(0, 34, 255),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(0, 17, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		FishingPassives = {
			MagnetRod = {
				NonCrateReduction = 0.0001
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				Lure = 70
			}
		},
		From = "Terrapin",
		Hint = "Purchasable at Terrapin Island.",
		Cool = true
	},
	["Nocturnal Rod"] = {
		Icon = "rbxassetid://114497121121959",
		Price = 15000,
		MinDistanceToPurchase = 30,
		Description = "Seems to wake up fish just by throwing the bobber in!-- Can catch nocturnal and diurnal fish at any time!",
		Luck = 90,
		LureSpeed = 50,
		Strength = 10000,
		LineDistance = 15,
		Resilience = 15,
		Control = 0.1,
		ProgressEfficiency = 0.1,
		Color = Color3.fromRGB(72, 59, 143),
		BobberTop = Color3.fromRGB(43, 41, 75),
		BobberBottom = Color3.fromRGB(255, 255, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 250
			}
		},
		FishingPassives = {
			Generic_TimeBoosts = {
				Night = {
					MutationPool = {
						Luminescent = 8
					},
					Boosts = {
						ProgressSpeed = 10
					}
				}
			}
		},
		TimeEffectiveness = -1,
		From = "Vertigo",
		Hint = "Purchasable at Vertigo.",
		Cool = true
	},
	["Fungal Rod"] = {
		Icon = "rbxassetid://75287952676988",
		Price = 1e999,
		Description = "Has a 30% chance for fish to be Fungal, & a 70% chance for the rod to sprout suspicious spores, giving you Luck X for 45 seconds! Prettyy funky!",
		Luck = 45,
		LureSpeed = 60,
		Strength = 200,
		LineDistance = 15,
		Resilience = 20,
		Control = 0,
		Color = Color3.fromRGB(78, 255, 78),
		BobberTop = Color3.fromRGB(51, 74, 45),
		BobberBottom = Color3.fromRGB(87, 109, 79),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Fungal = 30
		},
		FishingPassives = {
			FungalRod = {
				BuffChance = 70,
				BuffDuration = 45,
				BuffData = {
					Stack = 10,
					BoostValue = 50
				},
				BuffName = "Luck",
				FishingType = "rod"
			}
		},
		From = "Mushgrove",
		Hint = "Obtained from Agaric.",
		Cool = true
	},
	["Destiny Rod"] = {
		Icon = "rbxassetid://71166223194192",
		Price = 1e999,
		Description = "The Destiny Rod pulses continuously with the pure essence of luck. (10% Higher chance of Shiny & Sparkling fish)",
		Luck = 250,
		LureSpeed = 55,
		Strength = 177777,
		LineDistance = 25,
		Resilience = 10,
		Control = 0.2,
		Color = Color3.fromRGB(255, 254, 220),
		BobberTop = Color3.fromRGB(248, 248, 248),
		BobberBottom = Color3.fromRGB(0, 0, 0),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		ShinyChance = 10,
		SparklingChance = 10,
		MutationPool = {
			Blessed = 5
		},
		EnhancementPatches = {
			Mastery1 = {
				ProgressSpeed = 15,
				ShinyChance = 15,
				SparklingChance = 15,
				MutationPool = {
					Blessed = 10
				}
			}
		},
		Unpurchasable = true,
		From = "Ocean",
		Hint = "Obtained from Caleia under The Arch.",
		Cool = true
	},
	["Haunted Rod"] = {
		Icon = "rbxassetid://122443800789396",
		Price = 1e999,
		Description = "Only obtainable during FischFright; The rod is cursed with the constant energy of FischFright, allowing it to catch FischFright mutations all year round.",
		Luck = 50,
		LureSpeed = 50,
		Strength = 1000,
		LineDistance = 30,
		Resilience = 0,
		Control = 0.05,
		Color = Color3.fromRGB(94, 255, 105),
		BobberTop = Color3.fromRGB(94, 255, 105),
		BobberBottom = Color3.fromRGB(18, 18, 18),
		MutationPool = {
			Ghastly = 10,
			Sinister = 10
		},
		FishingPassives = {
			HauntedRodVFX = {
				TargetMutations = { "Ghastly", "Sinister" }
			}
		},
		Unpurchasable = true,
		Unregistered = true,
		Hint = "Obtainable during FischFright.",
		From = "FischFright",
		Cool = true
	},
	["Kings Rod"] = {
		Icon = "rbxassetid://80387888571251",
		Price = 100000,
		MinDistanceToPurchase = 30,
		Description = "All fish caught are 30% bigger.",
		Luck = 85,
		LureSpeed = 70,
		Strength = 1e999,
		LineDistance = 13,
		Resilience = 35,
		Control = 0.15,
		Color = Color3.fromRGB(52, 96, 255),
		BobberTop = Color3.fromRGB(33, 111, 255),
		BobberBottom = Color3.fromRGB(35, 35, 35),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		Disturbance = 2,
		WeightBoost = 30,
		MutationPool = {
			["King’s Blessing"] = 5
		},
		EnhancementPatches = {
			Mastery1 = {
				WeightBoost = 40,
				ProgressSpeed = 20
			}
		},
		From = "Keepers Altar",
		Hint = "Purchasable at the Keepers Altar.",
		Cool = true
	},
	["Aurora Rod"] = {
		Icon = "rbxassetid://129748325010098",
		Price = 70000,
		MinDistanceToPurchase = 30,
		Description = [[
Enhanced by the Aurora Borealis' energy. All fish have a 15% chance to have the Aurora mutation.
Chances increase to 30% during the Aurora Borealis.]],
		Luck = 60,
		LureSpeed = 55,
		Strength = 6000,
		LineDistance = 20,
		Resilience = 16,
		Control = 0.06,
		Color = Color3.fromRGB(46, 255, 185),
		BobberTop = Color3.fromRGB(49, 255, 179),
		BobberBottom = Color3.fromRGB(107, 127, 255),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		FishingPassives = {
			Generic_WeatherBoosts = {
				Default = {
					MutationPool = {
						Aurora = 15
					}
				},
				["Aurora Borealis"] = {
					MutationPool = {
						Aurora = 30
					}
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Generic_WeatherBoosts = {
						Default = {
							MutationPool = {
								Aurora = 25
							}
						},
						["Aurora Borealis"] = {
							MutationPool = {
								Aurora = 40
							}
						}
					}
				},
				Lure = 30
			}
		},
		From = "Vertigo",
		Hint = "Purchasable at Vertigo during an Aurora Borealis.",
		Requirements = {
			WorldState = {
				{
					Name = "meteorological",
					ExpectedValue = "Aurora Borealis",
					FailMessage = "This rod can only be purchased during an Aurora Borealis."
				}
			}
		},
		Cool = true
	},
	["Rainbow Cluster Rod"] = {
		Icon = "rbxassetid://133550040037110",
		Price = 250000,
		MinDistanceToPurchase = 30,
		Description = "Enhanced by the Rainbow's energy!",
		Luck = 180,
		LureSpeed = 35,
		Strength = 50000,
		LineDistance = 50,
		Resilience = 25,
		Control = 0,
		Color = Color3.fromRGB(235, 83, 144),
		BobberTop = Color3.fromRGB(235, 83, 144),
		BobberBottom = Color3.fromRGB(108, 255, 97),
		From = "Castaway Cliffs",
		Hint = "Purchasable at a hidden mineshaft during Rainbow weather.",
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 1000
			}
		},
		ReelGuiName = "rainbowclusterrod",
		FishingPassives = {
			Generic_WeatherBoosts = {
				Rainbow = {
					Boosts = {
						ProgressSpeed = 50
					},
					MutationPool = {
						RainbowCluster = 35,
						Rainbow = 15
					}
				},
				Default = {
					MutationPool = {
						RainbowCluster = 20,
						Rainbow = 10
					}
				}
			},
			RainbowClusterRodVFX = {}
		},
		Requirements = {
			WorldState = {
				{
					Name = "meteorological",
					ExpectedValue = "Rainbow",
					FailMessage = "This rod can only be purchased during a Rainbow."
				}
			}
		}
	},
	["Sunken Rod"] = {
		Icon = "rbxassetid://134989344625022",
		Price = 1e999,
		Description = "An ancient, coral-encrusted rod found in shipwreck depths, radiating faint power to lure rare fish. Every 10 catches, gain a 25% higher chance to pull up a Treasure Map! All fish have a 8% chance to be Sunken.",
		Luck = 150,
		LureSpeed = 50,
		Strength = 25000,
		LineDistance = 60,
		Resilience = 15,
		Control = 0.15,
		Color = Color3.fromRGB(145, 255, 115),
		BobberTop = Color3.fromRGB(162, 255, 134),
		BobberBottom = Color3.fromRGB(34, 53, 66),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Sunken = 8
		},
		FishingPassives = {
			SunkenRod = {
				MapChance = 25,
				ChanceEvery = 10,
				GuaranteeEvery = 230
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				MutationPool = {
					Sunken = 13
				},
				Lure = 35
			}
		},
		From = "Ocean",
		Hint = "Rarely obtained from Treasure Chests.",
		Unpurchasable = true
	},
	["Rod Of The Exalted One"] = {
		Icon = "rbxassetid://129915706991944",
		Price = 1e999,
		Description = "Originally created for the most magnificent royals, was lost in time and sealed away. Exalted Relics now have a 10× higher chance to be caught.",
		Luck = 170,
		LureSpeed = 45,
		Strength = 57000,
		LineDistance = 70,
		Resilience = 20,
		Control = 0.15,
		Color = Color3.fromRGB(255, 128, 249),
		BobberTop = Color3.fromRGB(148, 250, 255),
		BobberBottom = Color3.fromRGB(255, 124, 238),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		LevelRequirement = 150,
		FishingPassives = {
			Generic_BoostFishChances = {
				Multiply = {
					["Exalted Relic"] = 10
				}
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Generic_BoostFishChances = {
						Multiply = {
							["Sovereign Relic"] = 2
						}
					}
				}
			},
			Mastery2 = {
				FishingPassives = {
					ShadowEntity = {
						GiveFishEvery = 8,
						ModelName = "Exalted",
						MatchPlayerEmotes = true,
						CatchEmotesEnabled = true,
						UseOwnerAvatar = true,
						DialogSetName = "Default",
						PassiveBlockLevel = 0,
						SpiritCatchPool = {
							["Enchant Relic"] = 85,
							["Exalted Relic"] = 12,
							["Song of the Deep"] = 1,
							["Invincible Relic"] = 1,
							["Dune Relic"] = 1
						}
					}
				}
			}
		},
		Cool = true,
		Unpurchasable = true,
		From = "Mushgrove Swamp",
		Hint = "Obtainable by collecting a series of relics and returning them to a hidden area under Mushgrove Swamp."
	},
	["Buddy Bond Rod"] = {
		Icon = "rbxassetid://106336662267795",
		Price = 1e999,
		Description = "A friendly rod!\nWhile playing with a friend, all stats are increased by 30%!",
		Luck = 5,
		LureSpeed = 100,
		Strength = 300,
		LineDistance = 20,
		Resilience = 0,
		Control = 0,
		Color = Color3.fromRGB(145, 255, 115),
		BobberTop = Color3.fromRGB(162, 255, 134),
		BobberBottom = Color3.fromRGB(34, 53, 66),
		FishingPassives = {
			BuddyBond = {
				StatMultiplier = 1.3,
				SkipStats = {
					"BaitEffectiveness",
					"TimeEffectiveness",
					"WeatherEffectiveness",
					"SeasonEffectiveness",
					"StartingProgress"
				}
			}
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Moosewood",
		Hint = "Obtained from Bob."
	},
	["Friendly Rod"] = {
		Icon = "rbxassetid://75465336952071",
		Price = 1e999,
		Description = [[
Made for friends and good times!
While playing with a friend, provides a 10% chance to catch a Friend Fish.]],
		Luck = 105,
		LureSpeed = 15,
		Strength = 1e999,
		LineDistance = 50,
		Resilience = 40,
		Control = 0.05,
		Color = Color3.fromRGB(255, 198, 243),
		BobberTop = Color3.fromRGB(255, 198, 243),
		BobberBottom = Color3.fromRGB(162, 255, 134),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		FishingPassives = {
			FriendlyPassive = {
				FriendFishChance = 10
			}
		},
		Unpurchasable = true,
		From = "Moosewood",
		Hint = "Obtainable from Marlon Friend."
	},
	["Ultratech Rod"] = {
		Icon = "rbxassetid://80380540572349",
		Price = 1e999,
		Description = "A rod of Unknown origin, feels pretty heavy. The rod has a pressed-in text on it's bottom which says \"Ultratech v.3.\" A scratched out name next to it which reads as: ZIK [For @Zik_isi].",
		Luck = 150,
		LureSpeed = 80,
		Strength = 10000,
		LineDistance = 100,
		Resilience = 10,
		Control = 0,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(170, 0, 170),
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Ultratech Rod",
				SoundName = { "stabbystabspinecaster", "stabbystabspinecaster2" },
				IconName = "Ultratech Rod",
				GradientColor = "Ultratech Rod"
			}
		},
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["Fischer's Rod"] = {
		Icon = "rbxassetid://104991259094527",
		Price = 1e999,
		Description = "A fischer's starter rod to get started with Fisching! What else would you do with it?..",
		Luck = 10,
		LureSpeed = 90,
		Strength = 100,
		LineDistance = 20,
		Resilience = 5,
		Control = 0.05,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(170, 0, 170),
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtained from Starter Pack."
	},
	["Scurvy Rod"] = {
		Icon = "rbxassetid://117578296630862",
		Price = 40000,
		MinDistanceToPurchase = 30,
		Description = "This rod has been on every pirate ship imaginable. Decent at everything, bad at nothing. Just like a pirate should! Has a 16% chance for fish to become Greedy.",
		Luck = 50,
		LureSpeed = 75,
		Strength = 2000,
		LineDistance = 20,
		Resilience = 15,
		Control = 0,
		Color = Color3.fromRGB(245, 205, 48),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(170, 0, 170),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 500
			}
		},
		MutationPool = {
			Greedy = 15
		},
		FishingPassives = {
			ScurvyRod = {
				TargetCompanions = { "Plunderbeak" },
				TargetPlayerZones = { "Forsaken Shores" },
				WeightBoost = 7.5,
				ProgressSpeed = 7.5
			}
		},
		From = "Forsaken Shores",
		Hint = "Purchasable at Forsaken Shores."
	},
	["Relic Rod"] = {
		Icon = "rbxassetid://106453693323122",
		Price = 1e999,
		Requirements = {
			GatesOpened = { "RelicRodGate" }
		},
		Description = "A really old rod, found from the tombs of ancient isles, crafted out of ancient bone, but does it hold a mysterious power within it?",
		Luck = 125,
		LureSpeed = 20,
		Strength = 250000,
		LineDistance = 20,
		Resilience = 35,
		Control = -0.1,
		Color = Color3.fromRGB(186, 178, 175),
		BobberTop = Color3.fromRGB(245, 213, 195),
		BobberBottom = Color3.fromRGB(133, 170, 158),
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "MegHunt",
			Risk = 6
		},
		Cool = true,
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable during Archaeological Hunt.",
		From = "Archaeological Hunt"
	},
	["Auric Rod"] = {
		Icon = "rbxassetid://91055017480900",
		Price = 1e999,
		Requirements = {
			GatesOpened = { "RelicRodGate" }
		},
		Description = "A rod forged with many valuable gemstones. Fish caught with this rod have a random sell value between 2-4x.",
		Luck = 45,
		LureSpeed = 55,
		Strength = 25000,
		LineDistance = 20,
		Resilience = 20,
		Control = 0.05,
		Color = Color3.fromRGB(148, 19, 43),
		BobberTop = Color3.fromRGB(204, 52, 14),
		BobberBottom = Color3.fromRGB(81, 23, 13),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Aurous = 20,
			Aurelian = 20,
			Aureate = 20,
			Aurulent = 20,
			Aureolin = 20
		},
		ProgressEfficiency = 0.1,
		Cool = true,
		Unpurchasable = true,
		From = "Ocean",
		Hint = "Rarely obtained from Sunken Chests."
	},
	["Rod Of Time"] = {
		Icon = "rbxassetid://71358863463163",
		Price = 1e999,
		Description = "A time rod!",
		Luck = 25,
		LureSpeed = 80,
		Strength = 2500,
		LineDistance = 20,
		Resilience = 20,
		Control = 0.05,
		Color = Color3.fromRGB(148, 19, 43),
		BobberTop = Color3.fromRGB(204, 52, 14),
		BobberBottom = Color3.fromRGB(81, 23, 13),
		XpMultiply = 0.25,
		Unregistered = true,
		Unpurchasable = true,
		Hint = "Obtainable from AFK Mine rewards."
	},
	["Developers Rod"] = {
		Icon = "rbxassetid://119152793214765",
		Price = 1e999,
		Description = "A rod made for developers not to have to suffer in fishing.",
		Luck = 150,
		LureSpeed = 99,
		Strength = 1e999,
		LineDistance = 150,
		Resilience = 99,
		Control = 1,
		Durability = 1e999,
		Color = Color3.fromRGB(255, 0, 0),
		BobberTop = Color3.fromRGB(245, 205, 48),
		BobberBottom = Color3.fromRGB(255, 0, 0),
		InstantCatch = true,
		StartingProgress = 80,
		Cool = true,
		Unregistered = true,
		DEV = true,
		OP = true,
		Unpurchasable = true
	},
	["Mystic Staff"] = {
		Icon = "rbxassetid://80181546313720",
		Price = 1e999,
		Description = "A powerful staff once held by a mysterious witch who disappeared without a trace... Strangely, its magic seems to attract fish.",
		Luck = 100,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 30,
		Control = 0.4,
		Color = Color3.fromRGB(90, 255, 145),
		BobberTop = Color3.fromRGB(91, 36, 36),
		BobberBottom = Color3.fromRGB(188, 151, 100),
		Unregistered = true,
		DEV = true,
		Unpurchasable = true
	},
	["The Twig"] = {
		Icon = "rbxassetid://130212420370396",
		Price = 1e999,
		Description = "I think it genuinely may break in two. [WoozyNate Only]",
		Luck = 300,
		LureSpeed = 1,
		Strength = 1e999,
		LineDistance = 100,
		Resilience = 50,
		Control = 0,
		Durability = 1e999,
		Color = Color3.fromRGB(255, 255, 255),
		BobberTop = Color3.fromRGB(172, 172, 172),
		BobberBottom = Color3.fromRGB(59, 59, 59),
		FishingPassives = {
			Generic_FallingWeapon = {
				OverrideModelName = "TheTwigprop",
				TriggerChance = 100,
				ProgressGain = 30,
				SpawnDelay = 0,
				ShakeRotates = true,
				InitialOffset = CFrame.new(0, 0, -30),
				EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
				PivotOffset = CFrame.new(0, 0, 0),
				FallAnimTime = 2,
				HitSoundName = "thetwig"
			}
		},
		Cool = true,
		Unregistered = true,
		DEV = true,
		OP = true,
		OP_Fallback = "Plaguereaver",
		Unpurchasable = true
	},
	["Nates Blade"] = {
		Icon = "rbxassetid://109812151664285",
		Price = 1e999,
		Description = "A sword wielded by the oneand only Nate The human. Created by Nates father, out of Kee-Oths Blood. [For @Woozynate]",
		Luck = 244,
		LureSpeed = -19,
		Strength = 1e999,
		LineDistance = 444,
		Resilience = 44,
		Control = 0,
		Color = Color3.fromRGB(255, 11, 11),
		BobberTop = Color3.fromRGB(255, 0, 0),
		BobberBottom = Color3.fromRGB(150, 15, 15),
		ProgressEfficiency = 0.5,
		MutationPool = {
			Bubblegum = 33.333333333333336,
			Rockstar = 33.333333333333336,
			Lumpy = 33.333333333333336
		},
		WeightBoost = 100,
		ReelGuiName = "natesblade",
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 25,
				SlashDamage = 6,
				StunTime = 0.35,
				RawStun = false,
				SourceType = "rod",
				SourceName = "Nates Blade",
				SoundName = "scream",
				IconName = "Nates Blade",
				GradientColor = "Nates Blade"
			},
			["Nates Blade"] = {}
		},
		Cool = true,
		Unregistered = true,
		Unpurchasable = true,
		LevelRequirement = 1000,
		From = "Black Market",
		Hint = "Obtained from the Black Market."
	},
	["Test Rod"] = {
		Icon = "rbxassetid://133088177128189",
		Price = 1e999,
		Description = "Test Rod Description",
		Luck = 150,
		LureSpeed = -50,
		Strength = 150000,
		LineDistance = 150,
		Resilience = 15,
		Control = 0.15,
		Color = Color3.fromRGB(73, 240, 255),
		BobberTop = Color3.fromRGB(163, 60, 60),
		BobberBottom = Color3.fromRGB(255, 242, 93),
		MutationPool = {
			Lightning = 5
		},
		Unregistered = true,
		Unpurchasable = true,
		From = "Underground Music Venue",
		Hint = "Obtained from the Underground Music Venue."
	},
	["Voyager Rod"] = {
		Icon = "rbxassetid://112874590464474",
		Price = 1e999,
		Description = "A rod forged by an ancient civilization, capable of mass destruction. All fish have a 40% chance to be fossilized. [Lasers fish with an orbital cannon].",
		Luck = 160,
		LureSpeed = 30,
		Strength = 300000,
		LineDistance = 60,
		Resilience = 20,
		Control = 0.08,
		Disturbance = 3,
		Color = Color3.fromRGB(204, 181, 255),
		BobberTop = Color3.fromRGB(255, 178, 53),
		BobberBottom = Color3.fromRGB(228, 202, 235),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		MutationPool = {
			Fossilized = 40
		},
		FishingPassives = {
			Generic_Laser = {
				LaserPropName = "VoyagerProp",
				TriggerChance = 100,
				ProgressGain = 25,
				LaserTime = 3,
				LaserChargeTime = 0.5,
				ShakeIntensity = 0.8,
				ShakeRotates = true,
				ShakeIntensityDecay = 0.97,
				StartSoundName = "voyagerlaser1",
				FireSoundName = "voyagerlaser2",
				EndSoundName = "voyagerlaser3"
			}
		},
		Cool = true,
		Unpurchasable = true,
		From = "Ancient Archives",
		Hint = "Craftable at the Ancient Archives at Level 80."
	},
	["Rod Of The Forgotten Fang"] = {
		Icon = "rbxassetid://84655930411987",
		Price = 1e999,
		Description = [[
All caught fish have a chance for the Tidal mutation
After 3 perfect catches, triggers a special mode where a Meg jumps out of the Deeps with a higher-tier fish. Boasting a 25-50% size buff and the Tidal mutation.]],
		Luck = 175,
		LureSpeed = 20,
		Strength = 300000,
		LineDistance = 100,
		Resilience = 25,
		Control = 0.22,
		Color = Color3.fromRGB(49, 155, 255),
		BobberTop = Color3.fromRGB(228, 244, 255),
		BobberBottom = Color3.fromRGB(39, 59, 124),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		Disturbance = 4,
		PreferredDisturbance = {
			Event = "MegHunt",
			Risk = 3
		},
		MutationPool = {
			Tidal = 35
		},
		FishingPassives = {
			Shark = {
				CatchRequirement = 3,
				RequirePerfect = true,
				ModelName = "ForgottenFang",
				BlockedRarities = { "Limited", "Gemstone", "Seed" },
				PassiveBlockLevel = 0,
				SharkMutationPool = {
					Tidal = 100
				},
				MinWeightBoost = 1.25,
				MaxWeightBoost = 1.5
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Shark = {
						CatchRequirement = 2
					}
				}
			}
		},
		Cool = true,
		Unpurchasable = true,
		From = "Ancient Archives",
		Hint = "Craftable at the Ancient Archives at Level 700."
	},
	Spiritbinder = {
		Icon = "rbxassetid://100808766660328",
		Price = 1e999,
		Description = [[
Spirits occasionally leave fish behind...
Their presence subtly draws high-rarity fish closer...]],
		Luck = 125,
		LureSpeed = 10,
		Strength = 150000,
		LineDistance = 100,
		Resilience = 5,
		Control = 0.03,
		Color = Color3.fromRGB(78, 81, 118),
		BobberTop = Color3.fromRGB(78, 81, 118),
		BobberBottom = Color3.fromRGB(196, 195, 212),
		DiscoveryRewards = {
			{
				Type = "XP",
				Value = 2500
			}
		},
		Disturbance = 5,
		MutationPool = {
			Translucent = 90,
			Spirit = 10
		},
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 30,
				DuplicateMutation = "Spirit",
				PassiveBlockLevel = 3
			},
			Spiritbinder = {
				PassiveCooldown = 60,
				HighRarityChance = 5,
				HighRarityOrder = {
					"Secret",
					"Apex",
					"Exotic",
					"Mythical",
					"Legendary"
				},
				HighRarityWeightBoost = 1.25,
				PassiveMutationPool = {
					Spirit = 100
				},
				PassiveBlockLevel = 0,
				HighRarityMutationPool = {
					Spirit = 100
				},
				HighRarityPassiveBlockLevel = 1
			}
		},
		EnhancementPatches = {
			Mastery1 = {
				FishingPassives = {
					Spiritbinder = {
						PassiveCooldown = 45
					}
				}
			}
		},
		Cool = true,
		Unpurchasable = true,
		From = "Ancient Archives",
		Hint = "Craftable at the Ancient Archives at Level 500."
	},
	["Rose Rend"] = {
		Icon = "rbxassetid://110386801816885",
		Price = 1e999,
		Description = "A thorn-kissed weapon that strikes with the elegance & cruelty of a wilting rose. [TOY-EXCLUSIVE]",
		Luck = 115,
		LureSpeed = 15,
		Strength = 100000,
		LineDistance = 100,
		Resilience = 15,
		Control = 0.15,
		ProgressEfficiency = 0.15,
		Color = Color3.fromRGB(255, 80, 156),
		BobberTop = Color3.fromRGB(255, 80, 156),
		BobberBottom = Color3.fromRGB(212, 187, 187),
		Unregistered = true,
		Unpurchasable = true,
		From = "Fisch Toy Codes",
		Hint = "Obtained from Fisch Toy Codes."
	},
	["Scarlet Ravager"] = {
		Icon = "rbxassetid://129801504642033",
		Price = 1e999,
		Description = "Forged in fury, this rod tears through the depths like a blade soaked in blood. [TOY-EXCLUSIVE]",
		Luck = 125,
		LureSpeed = 10,
		Strength = 125000,
		LineDistance = 100,
		Resilience = 20,
		Control = 0.2,
		ProgressEfficiency = 0.2,
		Color = Color3.fromRGB(153, 21, 30),
		BobberTop = Color3.fromRGB(150, 0, 2),
		BobberBottom = Color3.fromRGB(75, 65, 65),
		Unregistered = true,
		Unpurchasable = true,
		From = "Fisch Toy Codes",
		Hint = "Obtained from Fisch Toy Codes."
	}
}
local rodOfTheEternalKing = {
	Icon = "rbxassetid://122671343136101",
	Price = 1e999,
	Description = "Every 30 seconds, a 5% chance summons a 'Royal Escort', boosting luck by 150% for 45 seconds. If you miss a catch, there's a 15% chance of immediately catching a higher rarity fish. All fish have a 60% chance to be Greedy.",
	Luck = 160,
	LureSpeed = 50,
	Strength = 75000,
	LineDistance = 80,
	Resilience = 15,
	Control = 0.175,
	Color = Color3.fromRGB(255, 221, 25),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	SplashSound = 0,
	DiscoveryRewards = 0,
	Disturbance = 3,
	MutationPool = 0,
	FishingPassives = 0,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 400."
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
rodOfTheEternalKing.SplashSound = ReplicatedStorage2.resources.sounds.sfx.fishing.customSplashes["Eternal King Splash"]
rodOfTheEternalKing.DiscoveryRewards = {
	{
		Type = "XP",
		Value = 2500
	}
}
rodOfTheEternalKing.MutationPool = {
	Greedy = 60,
	Royal = 10
}
rodOfTheEternalKing.FishingPassives = {
	RoyalEscort = {
		ChancePerCatch = 5,
		CatchPerPerfectCatch = 10,
		Duration = 180,
		EscortBoosts = {
			Luck = 75,
			ProgressSpeed = 25
		},
		EscortMutationPool = {
			Royal = 10
		},
		VfxFolderName = "EternalKing"
	},
	RoyalEscort_HighRarity = {
		TriggerChance = 15,
		PassiveBlockLevel = 0
	}
}
Rods["Rod Of The Eternal King"] = rodOfTheEternalKing
Rods["Resourceful Rod"] = {
	Icon = "rbxassetid://94518948138890",
	Price = 1e999,
	Description = "Doubles the effects of all bait, and has a 60% chance to not consume bait, increasing the efficiency of every catch.",
	Luck = 60,
	LureSpeed = 70,
	Strength = 1000,
	LineDistance = 50,
	Resilience = 10,
	Control = -0.01,
	Color = Color3.fromRGB(255, 75, 15),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	BaitEffectiveness = 1,
	BaitPreserveChance = 60,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 50."
}
Rods["Seasons Rod"] = {
	Icon = "rbxassetid://136028611604583",
	Price = 1e999,
	Description = "Massively boosts fish luck for the current season. It also has a 100% chance to grant a \"Seasonal\" mutation that changes the fish's colors and provides unique buffs based on the season it was caught.",
	Luck = 100,
	LureSpeed = 50,
	Strength = 8000,
	LineDistance = 50,
	Resilience = 20,
	Control = 0.03,
	Color = Color3.fromRGB(255, 185, 115),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	MutationPool = {
		Seasonal = 100
	},
	SeasonEffectiveness = 0.4,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 40."
}
Rods["Wisdom Rod"] = {
	Icon = "rbxassetid://139792686966380",
	Price = 1e999,
	Description = "A mystical rod that rewards skilled fishers, granting a stackable 5% XP bonus for every perfect catch in a row up to 80%.",
	Luck = 130,
	LureSpeed = 45,
	Strength = 2000,
	LineDistance = 50,
	Resilience = 40,
	Control = -0.02,
	Color = Color3.fromRGB(54, 47, 5),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	FishingPassives = {
		WisdomPassive = {
			MultiplyBoostsPerStack = {
				XpMultiply = 0.05
			},
			AddBoostsPerStack = {
				ProgressSpeed = 1.5,
				Resilience = 2
			},
			MaxStacks = 16,
			StackPerPerfectCatch = 1,
			StackPerImperfectCatch = -2,
			StackPerReelSnap = -2
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			FishingPassives = {
				WisdomPassive = {
					MultiplyBoostsPerStack = {
						XpMultiply = 0.1
					}
				}
			}
		}
	},
	Cool = true,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 80."
}
Rods["Celestial Rod"] = {
	Icon = "rbxassetid://86742008647025",
	Price = 1e999,
	Description = "After catching 15 fish, summon Celestial powers for 2 minutes, granting +100% Luck & +60% Lure Speed. Caught fish also get the Celestial mutation & +50% XP on them!",
	Luck = 60,
	LureSpeed = 50,
	Strength = 350000,
	LineDistance = 70,
	Resilience = 25,
	Control = 0.21,
	Color = Color3.fromRGB(19, 145, 255),
	BobberTop = Color3.fromRGB(58, 134, 255),
	BobberBottom = Color3.fromRGB(43, 208, 189),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	FishingPassives = {
		CelestialPower = {
			PassiveDuration = 120,
			PassiveCatchRequirement = 15,
			BuffId = "CelestialPower",
			BuffData = {
				PassiveBoosts = {
					Luck = 100,
					Lure = 60,
					XpMultiply = 0.5,
					StartingProgress = 0
				},
				MutationPool = {
					Celestial = 100
				}
			}
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			FishingPassives = {
				CelestialPower = {
					PassiveDuration = 240
				}
			}
		},
		Mastery2 = {
			StartingProgress = 10,
			FishingPassives = {
				CelestialPower = {
					BuffData = {
						PassiveBoosts = {
							StartingProgress = 10
						}
					}
				}
			}
		},
		Mastery3 = {
			ClientFishingPassives = {
				AstraeusSerenade = {
					InstantCompletionChance = 0,
					StarBeamDuration = 2.5,
					AlwaysImmediate = true,
					MinStarBeamInterval = 7,
					MaxStarBeamInterval = 15,
					BaseStarBeamSpeed = 0.51,
					MinStarBeamSpeed = 0.51,
					StarBeamSpeedFactor_Default = 1,
					StarBeamSpeedFactor_Starfall = 1,
					ProgressPerStar = 3
				}
			}
		}
	},
	Cool = true,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 350."
}
Rods["The Lost Rod"] = {
	Icon = "rbxassetid://105882349077376",
	Price = 1e999,
	Description = "After a Perfect Catch, your current and next catches have a 36% chance for the Lost mutation.",
	Luck = 140,
	LureSpeed = 35,
	Strength = 55000,
	LineDistance = 70,
	Resilience = 20,
	Control = 0.08,
	Color = Color3.fromRGB(64, 255, 102),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	FishingPassives = {
		TheLostRod = {
			MUTATION_NAME = "Lost",
			MUTATION_CHANCE = 36
		},
		Generic_PerfectBoost = {
			MutationPool = {
				Lost = 36
			}
		}
	},
	Cool = true,
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 100."
}
Rods["Riptide Rod"] = {
	Icon = "rbxassetid://78541901122895",
	Price = 1e999,
	Description = "The Riptide Rod fills its Tide Meter by 1/3 with each Perfect Catch. At max, it enters `High Tide` for 5 casts. This will boost Lure Speed and Luck, provide a chance for the Tidal mutation, and a chance to catch a high-rarity fish.",
	Luck = 100,
	LureSpeed = 40,
	Strength = 3500,
	LineDistance = 50,
	Resilience = 20,
	Control = 0.05,
	Color = Color3.fromRGB(66, 94, 255),
	BobberTop = Color3.fromRGB(255, 211, 33),
	BobberBottom = Color3.fromRGB(124, 72, 8),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	Disturbance = 2,
	FishingPassives = {
		HighTide = {
			AmountOfHighTide = 5,
			AmountOfPerfectCatch = 3,
			HighTideBoosts = {
				Lure = 25,
				Luck = 25
			},
			HighTideMutationPool = {
				Tidal = 10
			},
			HighTideRarityBoostChance = 30,
			PassiveBlockLevel = 2
		}
	},
	Unpurchasable = true,
	From = "Ancient Archives",
	Hint = "Craftable at the Ancient Archives at Level 30."
}
Rods["Astral Rod"] = {
	Icon = "rbxassetid://121418713557252",
	Price = 1e999,
	Description = "An intergalactic rod, powered by the harmonious essence of all the stars in the night sky. All fish have a 5% chance to be Lunar.",
	Luck = 30,
	LureSpeed = 90,
	Strength = 1000,
	LineDistance = 20,
	Resilience = 5,
	Control = 0.05,
	Color = Color3.fromRGB(105, 26, 241),
	BobberTop = Color3.fromRGB(98, 25, 255),
	BobberBottom = Color3.fromRGB(255, 155, 83),
	MutationPool = {
		Lunar = 5
	},
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable from a code."
}
Rods["Event Horizon Rod"] = {
	Icon = "rbxassetid://89522045456818",
	Price = 1e999,
	Description = "The powerful black hole within this rod decimates everything in its path. All fish have a 5% chance to be Lunar.",
	Luck = 30,
	LureSpeed = 90,
	Strength = 1000,
	LineDistance = 20,
	Resilience = 5,
	Control = 0.05,
	Color = Color3.fromRGB(255, 184, 5),
	BobberTop = Color3.fromRGB(255, 138, 5),
	BobberBottom = Color3.fromRGB(23, 23, 31),
	MutationPool = {
		Lunar = 5
	},
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable from a code."
}
Rods["Antler Rod"] = {
	Icon = "rbxassetid://126885545063597",
	Price = 1e999,
	Description = "A rod bearing the magnificent antlers of a reindeer. All fish have a 25% chance to be Jolly.",
	Luck = 45,
	LureSpeed = 75,
	Strength = 200,
	LineDistance = 24,
	Resilience = -4,
	Control = 0.02,
	Color = Color3.fromRGB(140, 98, 86),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(122, 46, 46),
	MutationPool = {
		Jolly = 25
	},
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable during Fischmas.",
	From = "Fischmas"
}
Rods["North-Star Rod"] = {
	Icon = "rbxassetid://81713353218223",
	Price = 1e999,
	Description = "Powered by the intensely bright shine of the Northern Star.",
	Luck = 30,
	LureSpeed = 95,
	Strength = 875,
	LineDistance = 19,
	Resilience = 12,
	Control = 0.04,
	Color = Color3.fromRGB(255, 237, 170),
	BobberTop = Color3.fromRGB(195, 179, 117),
	BobberBottom = Color3.fromRGB(255, 209, 102),
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable during Fischmas.",
	From = "Fischmas"
}
Rods["Candy Cane Rod"] = {
	Icon = "rbxassetid://140479025360511",
	Price = 1e999,
	Description = "A sweet and minty rod with a festive pattern. All fish have a 10% chance to be Festive.",
	Luck = 25,
	LureSpeed = 90,
	Strength = 150,
	LineDistance = 14,
	Resilience = -2,
	Control = 0.01,
	Color = Color3.fromRGB(185, 37, 37),
	BobberTop = Color3.fromRGB(230, 23, 23),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	MutationPool = {
		Festive = 10
	},
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable during Fischmas.",
	From = "Fischmas"
}
Rods["Krampus's Rod"] = {
	Icon = "rbxassetid://119989352332484",
	Price = 1e999,
	Description = "Haunted with the evil spirit of Krampus himself. Every 10 catches, gain a temporary buff.",
	Luck = 15,
	LureSpeed = 50,
	Strength = 50000,
	LineDistance = 40,
	Resilience = 8,
	Control = 0.15,
	Color = Color3.fromRGB(255, 66, 91),
	BobberTop = Color3.fromRGB(241, 80, 96),
	BobberBottom = Color3.fromRGB(29, 30, 35),
	FishingPassives = {
		Krampus = {
			CatchRequirement = 10,
			BuffDuration = 600,
			PossibleBuffs = {
				{
					Type = "Luck",
					Data = {
						Stack = 10,
						BoostValue = 50
					}
				},
				{
					Type = "Lure",
					Data = {
						Stack = 10,
						BoostValue = 50
					}
				}
			}
		}
	},
	Unpurchasable = true,
	Unregistered = true,
	Hint = "Obtainable during Fischmas.",
	From = "Fischmas"
}
Rods["Frostbane Rod"] = {
	Icon = "rbxassetid://94897600635895",
	Price = 1500000,
	MinDistanceToPurchase = 30,
	Description = "An unwieldy blade laced with frost magic, its true power dormant; until the darkest cold deepens, unlocking a surge of strength few can withstand.",
	Luck = 85,
	LureSpeed = 20,
	Strength = 1500,
	LineDistance = 40,
	Resilience = 35,
	Control = 0.05,
	Color = Color3.fromRGB(144, 240, 255),
	BobberTop = Color3.fromRGB(155, 242, 255),
	BobberBottom = Color3.fromRGB(48, 51, 62),
	FishingPassives = {
		Generic_SeasonBoosts = {
			Winter = {
				MutationPool = {
					Glacial = 3,
					Chilled = 30
				}
			},
			Default = {
				MutationPool = {
					Glacial = 1,
					Chilled = 10
				}
			}
		},
		FrostbaneRod = {
			DefaultBoosts = {},
			WinterBoosts = {
				ProgressSpeed = 20
			},
			NightBoosts = {
				ProgressSpeed = 20
			},
			WinterNightBoosts = {
				ProgressSpeed = 50
			}
		}
	},
	ClientFishingPassives = {
		Generic_ReelRecolor = {
			progress = {
				BackgroundColor3 = Color3.fromRGB(137, 191, 199),
				bar = {
					BackgroundColor3 = Color3.fromRGB(172, 247, 255)
				}
			},
			fish = {
				BackgroundColor3 = Color3.fromRGB(183, 245, 255),
				icon = {
					ImageColor3 = Color3.fromRGB(135, 243, 255)
				}
			}
		}
	},
	Hint = "Purchasable during the Snowstorm admin event.",
	Unregistered = true
}
Rods["Frost Warden Rod"] = {
	Icon = "rbxassetid://113823883871130",
	Price = 1e999,
	Description = "A frigid rod wielded by fierce anglers. Built to fish in the coldest of waters.",
	Luck = 45,
	LureSpeed = 90,
	Strength = 2200,
	LineDistance = 22,
	Resilience = 15,
	Control = 0.05,
	Color = Color3.fromRGB(144, 240, 255),
	BobberTop = Color3.fromRGB(155, 242, 255),
	BobberBottom = Color3.fromRGB(48, 51, 62),
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable from Winter Bundle."
}
Rods["Crystalized Rod"] = {
	Icon = "rbxassetid://135599022251951",
	Price = 35000,
	Description = "A luminous rod with a bright yellow glow and crystal-like effects. Has a 30% chance to Crystalize fish.",
	Luck = 90,
	LureSpeed = 65,
	Strength = 25000,
	LineDistance = 100,
	Resilience = 15,
	Control = 0.15,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 500
		}
	},
	Requirements = {
		DataInstanceRequiriment = {
			"Cache.IcePuzzlePass",
			true,
			"You must complete the puzzle before purchasing this."
		}
	},
	MutationPool = {
		Crystalized = 30
	},
	Cool = true,
	From = "Overgrowth Caves",
	Hint = "Purchasable after completing the Ice Puzzle."
}
Rods["Ice Warpers Rod"] = {
	Icon = "rbxassetid://133015770772958",
	Price = 65000,
	Description = "A frost-themed rod with glowing blue accents and icy particle effects. Has a 25% chance to mutate fish with Blighted.",
	Luck = 60,
	LureSpeed = 50,
	Strength = 75000,
	LineDistance = 70,
	Resilience = 20,
	Control = 0.15,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 500
		}
	},
	MutationPool = {
		Blighted = 25
	},
	Requirements = {
		DataInstanceRequiriment = {
			"Cache.FrozenLeverPuzzle",
			true,
			"You must complete the puzzle before purchasing this."
		}
	},
	From = "Frigid Cavern",
	Hint = "Purchasable after flipping all frozen levers."
}
Rods["Heaven's Rod"] = {
	Icon = "rbxassetid://74013259116743",
	Requirements = {
		GatesOpened = { "NorthFinalPuzzleDoor" }
	},
	Price = 800000,
	MinDistanceToPurchase = 30,
	Description = "A heavenly rod with glowing floating parts and a divine halo, emitting mythical particles and celestial animations. Has a chance for fish to become Heavenly.",
	Luck = 250,
	LureSpeed = 35,
	Strength = 1e999,
	LineDistance = 70,
	Resilience = 30,
	Control = 0.2,
	Color = Color3.fromRGB(190, 140, 24),
	BobberTop = Color3.fromRGB(234, 90, 23),
	BobberBottom = Color3.fromRGB(255, 159, 24),
	LevelRequirement = 220,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2000
		}
	},
	ProgressEfficiency = 0.2,
	MutationPool = {
		Heavenly = 35
	},
	FishingPassives = {
		FallenRod = {
			Y_LEVEL_THRESHOLD = 150,
			INVERSE = true,
			SKIP_UNDERGROUND = true,
			MutationPool = {
				Heavenly = 10
			}
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			ProgressSpeed = 10,
			MutationPool = {
				Heavenly = 40
			}
		},
		Mastery2 = {
			FishingPassives = {
				Generic_Laser = {
					LaserPropName = "SeraphicProp",
					TriggerChance = 100,
					ProgressGain = 20,
					LaserTime = 3,
					LaserChargeTime = 0.5,
					ShakeIntensity = 0.8,
					ShakeRotates = false,
					ShakeIntensityDecay = 0.97,
					StartSoundName = "voyagerlaser1",
					FireSoundName = "voyagerlaser2",
					EndSoundName = "voyagerlaser3"
				}
			}
		}
	},
	Cool = true,
	From = "Glacial Grotto",
	Hint = "Purchasable after returning all crystals to the peak."
}
Rods["Arctic Rod"] = {
	Icon = "rbxassetid://123369379556130",
	Price = 25000,
	MinDistanceToPurchase = 30,
	Description = "A white rod with frost effects and a cool blue glow, all fish become Frozen.",
	Luck = 45,
	LureSpeed = 75,
	Strength = 7500,
	LineDistance = 70,
	Resilience = 15,
	Control = 0.06,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 500
		}
	},
	MutationPool = {
		Frozen = 100
	},
	From = "Overgrowth Caves",
	Hint = "Purchasable at the bottom of the Northern Expedition."
}
Rods["Avalanche Rod"] = {
	Icon = "rbxassetid://98267901630995",
	Price = 35000,
	MinDistanceToPurchase = 30,
	Description = "A sleek rod with an icy blue spiral design and glowing blue accents, has a 25% chance for fish to be covered in Sleet.",
	Luck = 68,
	LureSpeed = 60,
	Strength = 65000,
	LineDistance = 70,
	Resilience = 10,
	Control = 0.15,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 500
		}
	},
	MutationPool = {
		Sleet = 25
	},
	From = "Frigid Cavern",
	Hint = "Purchasable at the Frigid Cavern."
}
Rods["Summit Rod"] = {
	Icon = "rbxassetid://78153641688331",
	ProgressEfficiency = 0.1,
	Price = 500000,
	MinDistanceToPurchase = 30,
	Description = "A refined rod with snow-white highlights and shimmering blue effects. Has a 40% chance for fish to be Frozen, 20% chance for Sleet, & a 15% chance for Blighted.",
	Luck = 75,
	LureSpeed = 55,
	Strength = 200000,
	LineDistance = 70,
	Resilience = 15,
	Control = 0.25,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 1000
		}
	},
	MutationPool = {
		Frozen = 40,
		Sleet = 20,
		Blighted = 15
	},
	EnhancementPatches = {
		Mastery1 = {
			MutationPool = {
				Frozen = 45,
				Sleet = 25,
				Blighted = 20
			},
			Lure = 25
		}
	},
	Cool = true,
	From = "Cryogenic Canal",
	Hint = "Purchasable at the Cryogenic Canal."
}
Rods["Fischmas Rod"] = {
	Icon = "rbxassetid://116915995678745",
	Price = 1e999,
	Description = "A festive fishing rod wrapped in holiday cheer, perfect for reeling in seasonal treasures.",
	Luck = 45,
	LureSpeed = 90,
	Strength = 2200,
	LineDistance = 22,
	Resilience = 15,
	Control = 0.05,
	Color = Color3.fromRGB(144, 240, 255),
	BobberTop = Color3.fromRGB(155, 242, 255),
	BobberBottom = Color3.fromRGB(48, 51, 62),
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtained from XMAS Pack."
}
Rods["Frostfire Rod"] = {
	Icon = "rbxassetid://107853837867107",
	Price = 1e999,
	Description = "A sleek fishing rod wreathed in flames and frost, designed to tackle the toughest catches with elemental flair.",
	Luck = 35,
	LureSpeed = 80,
	Strength = 2200,
	LineDistance = 22,
	Resilience = 12,
	Control = 0.08,
	Color = Color3.fromRGB(144, 240, 255),
	BobberTop = Color3.fromRGB(155, 242, 255),
	BobberBottom = Color3.fromRGB(48, 51, 62),
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtained from XMAS Pack (II)."
}
Rods["Firework Rod"] = {
	Icon = "rbxassetid://83213453938095",
	MinDistanceToPurchase = 30,
	Description = "A rod imbued with festive magic. 15% chance for Firework Mutation (4.0x sell price). Reduces whale progress speed by 20% and gives a +0.2% whale encounter rate.",
	Luck = 45,
	LureSpeed = 65,
	Strength = 25000,
	LineDistance = 100,
	Resilience = 15,
	Control = 0.15,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	MutationPool = {
		Firework = 15
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Golden Tide",
	Hint = "Obtainable during Golden Tide."
}
Rods["New Years Rod"] = {
	Icon = "rbxassetid://81474907198968",
	Price = 20260,
	ProgressEfficiency = 0.26,
	Description = "A New Years specialty; imbued with the magic of 2026! Has a 15% chance to apply the New Years mutation.",
	Luck = 126,
	LureSpeed = 74,
	Strength = 26000,
	LineDistance = 26,
	Resilience = 26,
	Control = 0.26,
	Color = Color3.fromRGB(255, 227, 144),
	BobberTop = Color3.fromRGB(255, 227, 144),
	BobberBottom = Color3.fromRGB(31, 27, 18),
	MutationPool = {
		["New Years"] = 15
	},
	FishingPassives = {
		Generic_BoostStatsForMutation = {
			["New Years"] = {
				ProgressSpeed = 100
			}
		},
		FireworksOnMutation = {
			TargetMutations = { "New Years" },
			FireworkColors = {
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(253, 255, 158),
				Color3.fromRGB(52, 52, 42)
			},
			SparkColors = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(246, 255, 167)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 229, 178)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 250, 196)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 237, 138))
			}),
			FireworkAscentHeight = 60,
			FireworkAscentDuration = 2
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtainable during New Years.",
	From = "New Years"
}
Rods["View Smasher"] = {
	Icon = "rbxassetid://96835545397522",
	Price = 1e999,
	Description = "HIT THAT FOLLOW BUTTON!! [CC Only]",
	Luck = 230,
	LureSpeed = 40,
	Strength = 1e999,
	LineDistance = 100,
	Resilience = 25,
	Control = 0.25,
	Color = Color3.fromRGB(255, 144, 144),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	FishingPassives = {
		Generic_FallingWeapon = {
			ModelScale = 4,
			TriggerChance = 100,
			ProgressGain = 30,
			SpawnDelay = 0,
			ShakeRotates = true,
			InitialOffset = CFrame.new(0, 0, -30),
			EndingOffset = CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0),
			PivotOffset = CFrame.new(0, -2.5, 0),
			FallAnimTime = 2,
			HitSoundName = "doombringerhammer"
		}
	},
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods["Fish Photographer"] = {
	Icon = "rbxassetid://91420661762791",
	Price = 1e999,
	Description = "If I catch you fishy.. if I catch you [CC Only]",
	Luck = 250,
	LureSpeed = 30,
	Strength = 1e999,
	LineDistance = 125,
	Resilience = 40,
	Control = 0.3,
	Color = Color3.fromRGB(255, 241, 206),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	FishingPassives = {
		ShadowEntity = {
			GiveFishEvery = 3,
			ModelName = "Shadow",
			MatchPlayerEmotes = true,
			CatchEmotesEnabled = true,
			UseOwnerAvatar = true,
			DialogSetName = "ContentCreator",
			PassiveBlockLevel = 0
		}
	},
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods["Treasure Rod"] = {
	Icon = "rbxassetid://85629423257826",
	ProgressEfficiency = 0.15,
	Price = 50000,
	MinDistanceToPurchase = 30,
	Description = "A radiant rod with shimmmering gems. Has a chance for the Gemstone mutation, triggering a Coinfall.",
	Luck = 130,
	LureSpeed = 30,
	Strength = 10000,
	LineDistance = 20,
	Resilience = 5,
	Control = 0.12,
	Color = Color3.fromRGB(0, 158, 225),
	BobberTop = Color3.fromRGB(255, 30, 30),
	BobberBottom = Color3.fromRGB(230, 196, 5),
	From = "Treasure Island",
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 500
		}
	},
	MutationPool = {
		Gemstone = 30
	},
	Cool = true,
	Hint = "Purchasable at Treasure Island."
}
Rods["Merchant Rod"] = {
	Icon = "rbxassetid://73263401977534",
	Price = 20000,
	MinDistanceToPurchase = 30,
	Description = "A rod designed for Merchants! Has a 50% chance to create a whirlpool, allowing for random bait to be caught.",
	Luck = 60,
	LureSpeed = 25,
	Strength = 5000,
	LineDistance = 25,
	Resilience = 18,
	Control = 0.05,
	Color = Color3.fromRGB(154, 0, 0),
	BobberTop = Color3.fromRGB(65, 65, 65),
	BobberBottom = Color3.fromRGB(186, 185, 166),
	From = "Limited",
	Hint = "Purchasable inside the Whale Interior.",
	FishingPassives = {
		WhirlpoolBait = {
			TriggerChance = 50,
			GiveCount = 3
		}
	},
	Unregistered = true,
	Unpurchasable = true
}
Rods["Brick Built Rod"] = {
	Icon = "rbxassetid://110214290692910",
	Price = 1e999,
	Description = "Stacked with color, packed with fun! Fish have a 10% chance to become Awesome.",
	Luck = 80,
	LureSpeed = 85,
	Strength = 200,
	LineDistance = 15,
	Resilience = 10,
	Control = 0.1,
	Color = Color3.fromRGB(255, 0, 0),
	BobberTop = Color3.fromRGB(255, 0, 0),
	BobberBottom = Color3.fromRGB(255, 225, 0),
	MutationPool = {
		LEGO = 10
	},
	Unpurchasable = true,
	Unregistered = true,
	From = "LEGO",
	Hint = "Obtainable during LEGO event."
}
Rods["Smurf Rod"] = {
	Icon = "rbxassetid://78930660389689",
	Price = 1e999,
	Description = "Smurf-themed rod with a smiling head and mushroom details. Cute and magical!",
	Luck = 80,
	LureSpeed = 85,
	Strength = 200,
	LineDistance = 15,
	Resilience = 10,
	Control = 0.1,
	MutationPool = {
		Smurf = 10
	},
	FishingPassives = {
		SmurfVFX = {
			TriggerOnMutations = { "Smurf" }
		}
	},
	Color = Color3.fromRGB(44, 171, 255),
	BobberTop = Color3.fromRGB(0, 166, 255),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	Unpurchasable = true,
	Unregistered = true,
	From = "Smurfs",
	Hint = "Obtainable during Smurfs event."
}
Rods["Patriot Rod"] = {
	Icon = "rbxassetid://117935665119184",
	Price = 1e999,
	Description = "Happy 4th of July!",
	Luck = 100,
	LureSpeed = 30,
	Strength = 742025,
	LineDistance = 74,
	Resilience = 7,
	Control = 0.04,
	MutationPool = {
		Patriotic = 20
	},
	FishingPassives = {
		Generic_BoostStatsForMutation = {
			Patriotic = {
				ProgressSpeed = 100
			}
		},
		FireworksOnMutation = {
			TargetMutations = { "Patriotic" },
			FireworkColors = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 0, 255) },
			SparkColors = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 167, 168)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(172, 183, 255))
			}),
			FireworkAscentHeight = 60,
			FireworkAscentDuration = 2
		}
	},
	Color = Color3.fromRGB(255, 0, 0),
	BobberTop = Color3.fromRGB(0, 0, 255),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	Unpurchasable = true,
	Unregistered = true,
	From = "4th of July",
	Hint = "Obtainable during 4th of July."
}
Rods["Liberty-Line"] = {
	Icon = "rbxassetid://98337612854409",
	Price = 1e999,
	Description = "Liberty Larry's finest. Sparks a Liberty mutation on a quarter of all catches, and kicks off every reel with a firework barrage.",
	Luck = 150,
	LureSpeed = 25,
	Strength = 1e999,
	LineDistance = 80,
	Resilience = 15,
	Control = 0.1,
	MutationPool = {
		Liberty = 25
	},
	ClientFishingPassives = {
		["Liberty-Line"] = {
			InitialProgress = 30,
			RepeatProgress = 5
		}
	},
	Color = Color3.fromRGB(0, 0, 255),
	BobberTop = Color3.fromRGB(255, 0, 0),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	Unpurchasable = true,
	Unregistered = true,
	ReelGuiName = "libertyline",
	From = "4th of July",
	Hint = "Obtained from Liberty Larry during 4th of July."
}
Rods["Cheeto Rod"] = {
	Icon = "rbxassetid://139341980998681",
	Price = 1e999,
	Description = "A cheese puff that spent too long at the bottom of a chip bag. The dust never washes off, the grip is greasy, and snacks occasionally fall from the sky. Carbon swears it's a collector's item.",
	Luck = 15,
	LureSpeed = 60,
	Strength = 500,
	LineDistance = 15,
	Resilience = 5,
	Control = -0.1,
	FishingPassives = {
		Generic_FallingWeapon = {
			OverrideModelName = "CheetoProp",
			ModelScale = 2.25,
			TriggerChance = 25,
			ProgressGain = 18,
			ProgressGainSplit = 3,
			ProgressGainSplitInterval = 0.1,
			SpawnDelay = 0,
			ShakeRotates = true,
			InitialOffset = CFrame.new(0, 50, 0),
			EndingOffset = CFrame.new(0, -50, 0),
			FallAnimTime = 0.9,
			EasingStyle = Enum.EasingStyle.Quart,
			ShockwaveSizeEnd = 45,
			HitSoundName = "coconut"
		}
	},
	Color = Color3.fromRGB(255, 138, 32),
	BobberTop = Color3.fromRGB(255, 138, 32),
	BobberBottom = Color3.fromRGB(255, 202, 96),
	Unpurchasable = true,
	Unregistered = true,
	ReelGuiName = "cheetorod",
	From = "Carbon",
	Hint = "Somewhere, a very hungry content creator is blocking a door."
}
Rods.Paintbrush = {
	Icon = "rbxassetid://112791122218457",
	ProgressEfficiency = 3.14,
	Price = 1e999,
	Description = "Awarded to only the best artists of Fisch! This rod shows that you have excelled and rose above everyone else.",
	Luck = 333,
	LureSpeed = -1518,
	Strength = 123456789,
	LineDistance = 150,
	Resilience = 45,
	Control = 0.123,
	Color = Color3.fromRGB(204, 0, 0),
	BobberTop = Color3.fromRGB(204, 0, 0),
	BobberBottom = Color3.fromRGB(72, 0, 255),
	MutationPool = {
		Mythical = 50
	},
	ShinyChance = 10,
	SparklingChance = 10,
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods.Cerebra = {
	Icon = "rbxassetid://101466087041681",
	ProgressEfficiency = 0.22,
	Price = 1e999,
	Description = "❤️",
	Luck = 95,
	LureSpeed = -100,
	Strength = 50000,
	LineDistance = 50,
	Resilience = 50,
	Control = 0.2,
	Color = Color3.fromRGB(255, 20, 145),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(255, 33, 166),
	MutationPool = {
		Heartburst = 10
	},
	WeightBoost = 22,
	FishingPassives = {
		Generic_FallingWeapon = {
			ModelScale = 2,
			TriggerChance = 100,
			ProgressGain = 20,
			SpawnDelay = 0,
			ShakeRotates = true,
			InitialOffset = CFrame.new(0, 10, 0),
			EndingOffset = CFrame.new(0, -5, 0),
			PivotOffset = CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0),
			FallAnimTime = 1,
			FallHitTime = 0.25,
			EasingStyle = Enum.EasingStyle.Elastic,
			EasingDirection = Enum.EasingDirection.Out,
			ShockwaveTime = 0.5,
			ShockwaveSizeEnd = 60,
			HitSoundName = "amygstab"
		}
	},
	ReelGuiName = "cerebra",
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 30,
			SlashDamage = 6,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Cerebra",
			SoundName = "stabbystab",
			IconName = "Default",
			GradientColor = Color3.fromRGB(255, 0, 132)
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Valentides 2",
	Hint = "Obtainable during Valentides 2."
}
Rods["Sanguine Spire"] = {
	Icon = "rbxassetid://102286476761772",
	ProgressEfficiency = 0.3,
	Price = 10000000,
	MinDistanceToPurchase = 30,
	Description = "i am emo rod!",
	Luck = 100,
	LureSpeed = 0,
	Strength = 1e999,
	LineDistance = 100,
	Resilience = 25,
	Control = 0.125,
	Color = Color3.fromRGB(190, 25, 34),
	BobberTop = Color3.fromRGB(190, 25, 34),
	BobberBottom = Color3.fromRGB(190, 25, 34),
	Disturbance = 4,
	MutationPool = {
		Sanguine = 30
	},
	ReelGuiName = "sanguinespire",
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 25,
			SlashDamage = 2,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Sanguine Spire",
			SoundName = "stabbystab",
			IconName = "Sanguine Spire",
			GradientColor = "Sanguine Spire"
		}
	},
	Unregistered = true,
	LevelRequirement = 100,
	From = "Underground Music Venue",
	Hint = "Obtainable during Corruption admin event."
}
Rods["Starline Caster"] = {
	Icon = "rbxassetid://72531079519984",
	ProgressEfficiency = 0,
	Price = 1e999,
	Description = "☆ this guy called rick is a nerd and made the stats some stupid cipher [For @s1mplyrick]",
	Luck = 333,
	LureSpeed = -566,
	Strength = 407,
	LineDistance = -69,
	Resilience = 111,
	Control = 0.7,
	Color = Color3.fromRGB(197, 228, 255),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	ReelGuiName = "starlinecaster",
	FishingPassives = {
		Generic_TimeBoosts = {
			Day = {
				MutationPool = {
					Aurora = 20
				}
			},
			Night = {
				MutationPool = {
					Chaotic = 20
				}
			}
		},
		StarlineCaster = {},
		Generic_MakeUntradeable = {
			TradeCooldown = -1
		}
	},
	ClientFishingPassives = {
		["Starline Caster"] = {
			ProgressPerVertex = 2.5,
			ConstellationInterval = 0.75,
			ConstellationDuration = 5,
			VertexHitRadius = 0.1,
			ConstellationSize = 0.7,
			BaseConstellationsNeeded = 4,
			ResilienceFactor = 40
		},
		["Starline Caster PerfectDance"] = {
			TimeOnBarThreshold = 2,
			BarShrinkFactor = 0.45,
			ForcedProgressSpeedBonus = 35
		},
		Generic_DimScreen = {
			OverlayTransprency = 0.3,
			FadeInTime = 1.5,
			FadeOutTime = 1
		}
	},
	WeightBoost = 200,
	ShinyChance = 20,
	SparklingChance = 20,
	Cool = true,
	Unregistered = true,
	DEV = true,
	OP = true,
	Unpurchasable = true
}
Rods.nilCaster = {
	Icon = "rbxassetid://103409083726676",
	ProgressEfficiency = 1.01010101,
	Price = 1e999,
	Description = "oops my data corrupt",
	Luck = 101,
	LureSpeed = -1,
	Strength = 1010101,
	LineDistance = 1e999,
	Resilience = 10.1,
	Control = 0.101,
	Color = Color3.fromRGB(55, 255, 0),
	BobberTop = Color3.fromRGB(26, 255, 0),
	BobberBottom = Color3.fromRGB(255, 0, 0),
	MutationPool = {
		Nuclear = 50
	},
	ReelGuiName = "nilcaster",
	FishingPassives = {
		RandomRod = {
			LOW_WEIGHT_MULTIPLIER = 0.01,
			HIGH_WEIGHT_MULTIPLIER = 3,
			WEIGHT_CHANCE = 50,
			MIN_BOOSTS = {
				Resilience = -80,
				Control = -0.35,
				ProgressSpeed = -100
			},
			MAX_BOOSTS = {
				Resilience = 80,
				Control = 0.4,
				ProgressSpeed = 100
			}
		}
	},
	Cool = true,
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods["ROBLOX Explorer"] = {
	Icon = "rbxassetid://114071705795370",
	Price = 1e999,
	Description = "Once a Guitar Hero controller, it has been adorned with stickers from it's previous owner. It is now re-modelled into a multi-purpose instrument of precision and power.",
	Luck = 125,
	LureSpeed = 20,
	Strength = 1e999,
	LineDistance = 150,
	Resilience = 60,
	Control = 0,
	Color = Color3.fromRGB(255, 255, 255),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	Unregistered = true,
	DEV = true,
	Unpurchasable = true,
	Tags = { "Instrument" }
}
Rods.Cinderstring = {
	Icon = "rbxassetid://79281785079831",
	ProgressEfficiency = 0.3,
	Price = 1e999,
	Description = "We feel the pain of a lifetime lost in a thousand days...",
	Luck = 175,
	LureSpeed = 0,
	Strength = 1e999,
	LineDistance = 200,
	Resilience = 80,
	Control = 0.05,
	Color = Color3.fromRGB(255, 170, 0),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(255, 157, 0),
	FishingPassives = {
		Generic_TieredBoosts = {
			DefaultLevel = 1,
			RequirePerfect = true,
			AllowRefresh = true,
			BuffId = "InfernalMelody",
			Levels = {
				{
					Boosts = {},
					MutationPool = {}
				},
				{
					Duration = 60,
					CatchRequirement = 2,
					Boosts = {
						Luck = 35,
						Resilience = -20,
						Control = -0.05,
						ProgressSpeed = 30
					},
					MutationPool = {
						Scorched = 60,
						Emberflame = 15,
						Infernal = 5
					}
				},
				{
					Duration = 60,
					CatchRequirement = 2,
					Boosts = {
						Luck = 50,
						Resilience = -40,
						Control = -0.15,
						ProgressSpeed = 100
					},
					MutationPool = {
						Scorched = 60,
						Emberflame = 20,
						Infernal = 20
					}
				}
			}
		}
	},
	LevelRequirement = 125,
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from the Underground Music Venue.",
	Tags = { "Instrument" }
}
Rods.Duskwire = {
	Icon = "rbxassetid://106809785021167",
	ProgressEfficiency = 0.25,
	Price = 1e999,
	Description = "Intertwined with souls of the masses; a reminder that we are all human after all.",
	Luck = 175,
	LureSpeed = 0,
	Strength = -757575,
	LineDistance = 75,
	Resilience = 175,
	Control = -0.2,
	Color = Color3.fromRGB(60, 60, 60),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 5000
		}
	},
	Disturbance = 4,
	ReelGuiName = "duskwire",
	FishingPassives = {
		Duskwire = {
			NormalMutationPool = {
				Chaotic = 30,
				Darkened = 68,
				Serene = 2
			},
			PerfectMutationPool = {
				Chaotic = 97,
				Serene = 3
			}
		},
		FallingNotes = {
			SoundName = "Duskwire",
			ModelFolderName = "DuskwireNotes",
			TriggerChance = 5,
			ProgressGain = 75,
			FinalMult = 2,
			DropDelay = 0
		}
	},
	ClientFishingPassives = {
		ControlToProgress = {
			MaxBarSize = 0.15,
			ConversionRatio = 1.5
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			FishingPassives = {
				Duskwire = {
					NormalMutationPool = {
						Chaotic = 50,
						Darkened = 45,
						Serene = 5
					},
					PerfectMutationPool = {
						Chaotic = 90,
						Serene = 10
					}
				}
			}
		}
	},
	LevelRequirement = 275,
	Unpurchasable = true,
	From = "Crystal Cove",
	Hint = "Obtained from Hollow.",
	Tags = { "Instrument" }
}
Rods.Wingripper = {
	Icon = "rbxassetid://73660191822388",
	ProgressEfficiency = 0.22,
	Price = 1e999,
	Description = "name a few dimensions we can flow between with no obstructions, another timeline.",
	Luck = 222,
	LureSpeed = -122,
	Strength = 1e999,
	LineDistance = 222,
	Resilience = 22,
	Control = 0.22,
	Color = Color3.fromRGB(60, 60, 60),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	ReelGuiName = "wingripper",
	FishingPassives = {
		Generic_TimeBoosts = {
			Night = {
				MutationPool = {
					Nocturnal_Night = 7
				},
				Boosts = {
					ProgressSpeed = 200,
					Control = -0.5
				}
			},
			Day = {
				MutationPool = {
					Nocturnal_Day = 27
				}
			}
		}
	},
	LevelRequirement = 1000,
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from the Underground Music Venue.",
	Tags = { "Instrument" }
}
Rods.Fangsplitter = {
	Icon = "rbxassetid://124580761794275",
	Price = 1e999,
	Description = "🦇",
	Luck = 222,
	LureSpeed = -122,
	Strength = 1e999,
	LineDistance = 222,
	Resilience = 222,
	Control = 0.22,
	Color = Color3.fromRGB(80, 67, 61),
	BobberTop = Color3.fromRGB(80, 67, 61),
	BobberBottom = Color3.fromRGB(121, 100, 84),
	LevelRequirement = 1111,
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods.SMILE = {
	Icon = "rbxassetid://71489491029769",
	Price = 1e999,
	Description = "more.... fisch...es.... (for 049492)",
	Luck = 50,
	LureSpeed = 75,
	Strength = 1e999,
	LineDistance = 1000,
	Resilience = 10,
	Control = 0.01,
	Durability = 777,
	ReelGuiName = "SMILE",
	Color = Color3.fromRGB(0, 0, 0),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	FishingPassives = {
		Generic_TieredBoosts = {
			DefaultLevel = 1,
			RequirePerfect = true,
			AllowRefresh = true,
			BuffId = "SMILE",
			Levels = {
				{
					Boosts = {},
					MutationPool = {}
				},
				{
					Duration = 1e999,
					CatchRequirement = 10,
					Boosts = {
						Luck = 50,
						LureSpeed = 15,
						Resilience = 15,
						Control = 0.15,
						ProgressSpeed = 25
					},
					MutationPool = {
						Darkened = 10
					}
				},
				{
					Duration = 1e999,
					CatchRequirement = 15,
					Boosts = {
						Luck = 150,
						LureSpeed = 40,
						Resilience = 40,
						Control = 0.2,
						ProgressSpeed = 75,
						SparklingChance = 10,
						ShinyChance = 10,
						WeightBoost = 25
					},
					MutationPool = {
						Darkened = 25
					}
				},
				{
					Duration = 1e999,
					CatchRequirement = 20,
					Boosts = {
						Luck = 450,
						LureSpeed = 75,
						Resilience = 90,
						Control = 0.5,
						ProgressSpeed = 250,
						SparklingChance = 25,
						ShinyChance = 25,
						WeightBoost = 100
					},
					MutationPool = {
						Darkened = 50
					}
				}
			}
		}
	},
	Unregistered = true,
	DEV = true,
	OP = true,
	OP_Fallback = "Sword of Darkness",
	Unpurchasable = true
}
Rods.Chrysalis = {
	Icon = "rbxassetid://84173544425344",
	ProgressEfficiency = 0.1,
	Price = 1e999,
	Description = "🍡",
	Luck = 150,
	LureSpeed = 0,
	Strength = 1e999,
	LineDistance = 100,
	Resilience = 100,
	Control = 0,
	Color = Color3.fromRGB(255, 142, 249),
	BobberTop = Color3.fromRGB(250, 125, 233),
	BobberBottom = Color3.fromRGB(248, 222, 255),
	MutationPool = {
		Bloom = 92,
		Flora = 8
	},
	ReelGuiName = "chrysalis",
	FishingPassives = {
		Chrysalis = {
			EyeSpawnChance = 12,
			EyeMutationPool = {
				Flora = 100
			},
			EyeShinyChance = 20,
			EyeSparklingChance = 20,
			PassiveBlockLevel = 1
		}
	},
	LevelRequirement = 1000,
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from the Underground Music Venue."
}
Rods.Eardrum = {
	Icon = "rbxassetid://132473338191220",
	Price = 1e999,
	Description = "Is there no standard anymore?",
	Luck = 125,
	LureSpeed = 10,
	Strength = 100000,
	LineDistance = 100,
	Resilience = 15,
	Control = 0.3,
	Color = Color3.fromRGB(74, 52, 38),
	BobberTop = Color3.fromRGB(74, 52, 38),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	ReelGuiName = "eardrum",
	FishingPassives = {
		ShadowEntity = {
			GiveFishEvery = 2,
			ModelName = "Eardrum",
			MatchPlayerEmotes = false,
			CatchEmotesEnabled = false,
			UseOwnerAvatar = false,
			DialogSetName = "Eardrum",
			PassiveBlockLevel = 0,
			SpiritMutationPool = {
				Oak = 100
			},
			SpiritCatchPool = {
				Log = 10
			}
		}
	},
	LevelRequirement = 120,
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from the Underground Music Venue.",
	Tags = { "Instrument" }
}
Rods["Nico's Yarncaster"] = {
	Icon = "rbxassetid://77262326604379",
	Price = 1e999,
	Description = [=[
a kitty who trots by your side and sneakily snags extra fish when you're not looking!
[extra power with clownfish cat toy!]]=],
	Luck = 75,
	LureSpeed = 35,
	Strength = 10000,
	LineDistance = 100,
	Resilience = 35,
	Control = 0.1,
	Color = Color3.fromRGB(153, 141, 121),
	BobberTop = Color3.fromRGB(227, 156, 255),
	BobberBottom = Color3.fromRGB(122, 110, 92),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 5000
		}
	},
	MutationPool = {
		Skrunkly = 30
	},
	ReelGuiName = "nicosyarncaster",
	FishingPassives = {
		Generic_BobberBoosts = {
			["Clownfish Cat Toy"] = {
				MutationPool = {
					["Nico's Nyantics"] = 30
				}
			}
		},
		["Nico's Yarncaster"] = {
			BobberMutationPool = {},
			NicoMutationPool = {
				["Nico's Nyantics"] = 100
			},
			TargetBobber = "Clownfish Cat Toy",
			FollowTime = 0.2,
			SleepInterval = 15,
			SleepToggleChance = 40,
			IdleTimeBeforeDive = 30,
			DiveChance = 33,
			TugInterval = 7200,
			TugChance = 2,
			TugDuration = 5,
			TugStrength = 30,
			PassiveBlockLevel = 0
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			CompanionFishingPassives = {
				Nico_RandomFish = {
					DiveChance = 60
				}
			}
		},
		Mastery2 = {
			FishingPassives = {
				["Nico's Yarncaster//2"] = {
					BobberMutationPool = {},
					NicoMutationPool = {
						["Nico's Nyantics"] = 100
					},
					TargetBobber = "Clownfish Cat Toy",
					FollowTime = 0.2,
					SleepInterval = 15,
					SleepToggleChance = 40,
					IdleTimeBeforeDive = 30,
					DiveChance = 33,
					TugInterval = 7200,
					TugChance = 2,
					TugDuration = 5,
					TugStrength = 30,
					PassiveBlockLevel = 0
				}
			}
		}
	},
	Cool = true,
	Unpurchasable = true,
	From = "Crystal Cove",
	Hint = "Obtainable from the Underground Music Venue."
}
Rods["Fallen Snowblade"] = {
	Icon = "rbxassetid://116839759525452",
	ProgressEfficiency = 0.5,
	Price = 1e999,
	Description = "Wielded by a lost soul, this divine blade now conjures snow and silence—a cursed echo of his eternal search for home. It's true strength may vary relative to the current Season... [For @rDevSno]",
	Luck = 219,
	LureSpeed = 25,
	Strength = 21512406,
	LineDistance = 50,
	Resilience = 15,
	Control = 0.39,
	Color = Color3.fromRGB(255, 255, 255),
	BobberTop = Color3.fromRGB(0, 0, 0),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	FishingPassives = {
		Generic_SeasonBoosts = {
			Winter = {
				Boosts = {
					ProgressSpeed = 25
				},
				MutationPool = {
					Snowy = 45,
					Frozen = 65
				}
			},
			Summer = {
				Boosts = {
					ProgressSpeed = -25
				},
				MutationPool = {
					Snowy = 5,
					Frozen = 95
				}
			},
			Default = {
				Boosts = {},
				MutationPool = {
					Snowy = 25,
					Frozen = 75
				}
			}
		},
		FallingNotes = {
			SoundName = "Snowflake",
			ModelFolderName = "Snowflakes",
			TriggerChance = 15,
			ProgressGain = 75,
			FinalMult = 2,
			DropDelay = 0
		}
	},
	LevelRequirement = 1000,
	Unregistered = true,
	Unpurchasable = true,
	Hint = "Obtained from Sno."
}
Rods["Pinion's Aria"] = {
	Icon = "rbxassetid://96489369728202",
	Price = 1e999,
	Description = "All together, resonate once more.",
	Luck = 242,
	LureSpeed = -42,
	Strength = 1e999,
	LineDistance = 342,
	Resilience = 4.2,
	Control = 0,
	Durability = 200,
	Color = Color3.fromRGB(201, 184, 255),
	BobberTop = Color3.fromRGB(232, 192, 255),
	BobberBottom = Color3.fromRGB(163, 207, 241),
	StartingProgress = 10,
	PreferredDisturbance = {
		Event = "WyvernHunt",
		Risk = 15
	},
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2000
		}
	},
	MutationPool = {
		Harmonized = 42
	},
	ShinyChance = 14.2,
	ReelGuiName = "pinionsaria",
	FishingPassives = {
		Generic_PerfectBoost = {
			XpBoost = 1.6133333333333333
		}
	},
	ClientFishingPassives = {
		["Pinion's Aria"] = {
			DROP_HEIGHT = 30,
			DROP_RANGE = 0.3,
			DROP_TIME = 2,
			DROP_TIME_REDUCE = 0.975,
			MIN_DROP_TIME = 0.5,
			DROP_INTERVAL = 2,
			DROP_INTERVAL_REDUCE = 0.925,
			MIN_DROP_INTERVAL = 1,
			SUCCESS_CONTROL_INCREASE = 0.025,
			SUCCESS_PROGRESS_BOOST = 3,
			SUCCESS_PROGRESS_SPEED_INCREASE = 0.05,
			SUCCESS_PROGRESS_LOSS_REDUCTION = -0.025,
			SUCCESS_FISH_SLOW_FACTOR = 0.1,
			FAIL_CONTROL_REDUCE = 0.15,
			FAIL_PROGRESS_LOSS = -0.1,
			FAIL_PROGRESS_SPEED_REDUCE = -0.1,
			FAIL_PROGRESS_LOSS_INCREASE = 0.1,
			FAIL_FISH_SLOW_FACTOR = -0.5,
			ACCEL_INCREASE = 0.15,
			MAX_ACCEL_BOOST = 2,
			RESONANCE_REQUIREMENT = 7,
			RESONANCE_FOLLOW_SPEED = 25,
			RESONANCE_CONTROL_REDUCE_RATE = 0.075,
			RESONANCE_PROGRESS_SPEED_INCREASE = 0.01,
			EXTERNAL_CONTROL_DEBUFF = 0.5
		},
		Generic_DimScreen = {
			OverlayTransprency = 0.5,
			FadeInTime = 2,
			FadeOutTime = 2
		},
		Generic_KillSimplified = {}
	},
	Unpurchasable = true,
	From = "Crystal Cove",
	Hint = "Obtainable from the Underground Music Venue.",
	EnhancementPatches = {
		Mastery1 = {
			ClientFishingPassives = {
				["Pinion's Aria"] = {
					SUCCESS_CONTROL_INCREASE = 0.035,
					SUCCESS_PROGRESS_BOOST = 4,
					SUCCESS_PROGRESS_SPEED_INCREASE = 0.075,
					SUCCESS_PROGRESS_LOSS_REDUCTION = -0.05,
					SUCCESS_FISH_SLOW_FACTOR = 0.15,
					FAIL_CONTROL_REDUCE = 0.075,
					FAIL_PROGRESS_LOSS = -0.05,
					FAIL_PROGRESS_SPEED_REDUCE = -0.075,
					FAIL_PROGRESS_LOSS_INCREASE = 0.05,
					FAIL_FISH_SLOW_FACTOR = -0.5,
					RESONANCE_CONTROL_REDUCE_RATE = 0.08,
					RESONANCE_PROGRESS_SPEED_INCREASE = 0.015
				}
			}
		},
		Mastery2 = {
			MutationPool = {
				Harmonized = 62
			},
			ShinyChance = 22
		}
	},
	Tags = { "Instrument" }
}
Rods["Rod of the Hubert"] = {
	Icon = "",
	Price = 1e999,
	Description = "TBD",
	Luck = 135,
	LureSpeed = 20,
	Strength = 1e999,
	LineDistance = 300,
	Resilience = 35,
	Control = 0,
	Color = Color3.fromRGB(236, 127, 169),
	BobberTop = Color3.fromRGB(236, 127, 169),
	BobberBottom = Color3.fromRGB(171, 136, 109),
	FishingPassives = {
		Hubert = {}
	},
	ClientFishingPassives = {
		HubertClient = {}
	},
	Unregistered = true,
	DEV = true,
	Unpurchasable = true
}
Rods.MiguRod = {
	Icon = "rbxassetid://77014167518233",
	Price = 1e999,
	Description = "A joke, that fulfilled its dream!",
	Luck = 237,
	LureSpeed = -327,
	Strength = 1e999,
	LineDistance = 401,
	Resilience = -185,
	Control = 0.101,
	Durability = 401,
	Color = Color3.fromRGB(255, 57, 57),
	BobberTop = Color3.fromRGB(255, 110, 110),
	BobberBottom = Color3.fromRGB(241, 241, 241),
	Disturbance = 4,
	Scavenging = 41,
	MutationPool = {
		Supersonic = 40.1
	},
	ReelGuiName = "migurod",
	FishingPassives = {
		Generic_FallingWeapon = {
			OverrideModelName = "MiguRodBaguette",
			ModelScale = 3,
			TriggerChance = 100,
			ProgressGain = 31,
			SpawnDelay = 0,
			ShakeRotates = true,
			InitialOffset = CFrame.new(0, 35, 0),
			EndingOffset = CFrame.new(0, -25, 0),
			PivotOffset = CFrame.fromOrientation(0, 3.141592653589793, 0),
			FallAnimTime = 1,
			EasingStyle = Enum.EasingStyle.Quart,
			ShockwaveSize = 12,
			ShockwaveSizeEnd = 30,
			HitSoundName = "vineboom",
			DisabledOnFish = { "Redlip Batfish" }
		},
		Generic_BonusCatch = {
			GiveFishEvery = 3,
			FishCount = 2,
			PassiveMutationPool = {
				Mesmerized = 100
			},
			PassiveShinyChance = 14,
			RarityWeights = {
				Trash = 10,
				Common = 16,
				Uncommon = 16,
				Unusual = 13,
				Rare = 13,
				Legendary = 12,
				Mythical = 8,
				Exotic = 5,
				Secret = 2,
				Limited = 1,
				Apex = 1,
				Gemstone = 1,
				Fragment = 1,
				Relic = 1
			},
			AddedFixedChanceFish = {
				["Enchant Relic"] = 9,
				["Exalted Relic"] = 1
			},
			PassiveBlockLevel = 2
		}
	},
	ClientFishingPassives = {
		MiguRodClient = {
			SlashCount = 3,
			AttackChance = 41,
			ProgressPerDodge = 4,
			WarningTime = 1.75,
			SlashTime = 0.25,
			Cooldown = 1,
			MinSlashDistance = 0.1,
			TriggerOnFishSlashed = true
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			Scavenging = 0,
			ProgressSpeed = 41,
			WeightBoost = -4.1,
			ClientFishingPassives = {
				MiguRodClient = {
					SlashCount = 4,
					AttackChance = 81,
					ProgressPerDodge = 1,
					WarningTime = 0.75,
					CounterAttack = {
						TriggerChance = 100,
						MinDamage = 0,
						MaxDamage = 20,
						OffBarPenalty = 0.5,
						BarMoveTime = 1
					},
					DisableMesmerizerVisuals = true
				},
				Generic_AddModifiers = {
					Modifiers = {
						multiply = {
							accel = 1.5
						}
					}
				}
			},
			FishingPassives = {
				Generic_BonusCatch = apply_op.DELETE,
				Generic_DuplicateFish = {
					DuplicateChance = 100,
					DuplicateCount = 1,
					DuplicateRequireMutation = { "Supersonic" },
					DuplicateMutation = "Bouka",
					PassiveBlockLevel = 3,
					RequireDirectCatch = true
				},
				["Generic_DuplicateFish//2"] = {
					DuplicateChance = 100,
					DuplicateCount = 1,
					DuplicateRequireMutation = { "Supersonic" },
					DuplicateMutation = "Idol",
					PassiveBlockLevel = 3,
					RequireDirectCatch = true
				}
			}
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	Cool = true,
	From = "Underground Music Venue",
	Hint = "Obtained from a peculiar trio at the Underground Music Venue.",
	Tags = { "Instrument" }
}
Rods["Mission Specialist's Rod"] = {
	Icon = "rbxassetid://101460877335509",
	Price = 1e999,
	Description = "You chose the Mission Specialist's Rod in your Jurassic missions!",
	Luck = 60,
	LureSpeed = 40,
	Strength = 5000,
	LineDistance = 30,
	Resilience = 40,
	Control = 0.1,
	Color = Color3.fromRGB(255, 170, 0),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(255, 85, 0),
	Unpurchasable = true,
	MutationPool = {
		Zora = 10
	},
	Unregistered = true,
	From = "Jurassic Event",
	Hint = "Obtainable during Jurassic Event."
}
Rods["Fixer's Rod"] = {
	Icon = "rbxassetid://102560229491775",
	Price = 1e999,
	Description = "You chose Fixer's Rod in your Jurassic missions!",
	Luck = 60,
	LureSpeed = 40,
	Strength = 5000,
	LineDistance = 30,
	Resilience = 10,
	Control = 0.3,
	Color = Color3.fromRGB(0, 170, 255),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(0, 170, 255),
	Unpurchasable = true,
	MutationPool = {
		Duncan = 10
	},
	Unregistered = true,
	From = "Jurassic Event",
	Hint = "Obtainable during Jurassic Event."
}
Rods["Paleontologist's Rod"] = {
	Icon = "rbxassetid://74519534929307",
	Price = 1e999,
	Description = "You chose Paleontologist's Rod in your Jurassic missions!",
	Luck = 150,
	LureSpeed = 40,
	Strength = 5000,
	LineDistance = 30,
	Resilience = 10,
	Control = 0.1,
	Color = Color3.fromRGB(170, 0, 0),
	BobberTop = Color3.fromRGB(255, 255, 255),
	BobberBottom = Color3.fromRGB(170, 0, 0),
	Unpurchasable = true,
	MutationPool = {
		Henry = 10
	},
	Unregistered = true,
	From = "Jurassic Event",
	Hint = "Obtainable during Jurassic Event."
}
Rods["Silly Fun Happy Rod"] = {
	Icon = "rbxassetid://55735329",
	Price = 1e999,
	Description = ":P\n[@newandreformedlyth]",
	Luck = 200,
	LureSpeed = -1e999,
	Strength = 1e999,
	LineDistance = 1e999,
	Resilience = 1e999,
	Control = -0.01,
	Color = Color3.fromRGB(221, 210, 0),
	BobberTop = Color3.fromRGB(221, 210, 0),
	BobberBottom = Color3.fromRGB(118, 19, 22),
	ProgressEfficiency = 0.5,
	ForcedProgressEfficiency = 0.5,
	MutationPool = {
		Honked = 50
	},
	FishingPassives = {
		Generic_HardStatLimit = {
			Control = 0.19
		}
	},
	ClientFishingPassives = {
		["Silly Fun Happy Rod"] = {}
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from Silly Clown.",
	Tags = { "Instrument" }
}
Rods["Stone Hammer"] = {
	Icon = "rbxassetid://118617961319261",
	Price = 1e999,
	Description = "i think nick dropped this... [things are happening soon 😈]",
	Luck = 100,
	LureSpeed = 0,
	Strength = 1e999,
	LineDistance = 1e999,
	Resilience = 0,
	Control = 0.5,
	Color = Color3.fromRGB(157, 157, 157),
	BobberTop = Color3.fromRGB(104, 104, 104),
	BobberBottom = Color3.fromRGB(61, 45, 37),
	Disturbance = 5,
	Cool = true,
	Unregistered = true,
	Unpurchasable = true
}
Rods["Luminescent Oath"] = {
	Icon = "rbxassetid://91638236496957",
	Price = 1000000,
	MinDistanceToPurchase = 30,
	Description = "Forged from the radiant crystals of the Luminescent Cavern, this blade hums with sealed brilliance; its true power is seemingly forbidden from awakening...",
	Luck = 200,
	LureSpeed = 15,
	Strength = 250000,
	LineDistance = 150,
	Resilience = 12,
	Control = 0.1,
	Color = Color3.fromRGB(69, 236, 255),
	BobberTop = Color3.fromRGB(86, 208, 245),
	BobberBottom = Color3.fromRGB(48, 48, 83),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2000
		}
	},
	MutationPool = {
		Luminescent = 15
	},
	FishingPassives = {
		Generic_PerfectBoost = {
			MutationPool = {
				Luminescent = 100
			}
		}
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "Interval",
			SlashChance = 5,
			SlashDamage = 1,
			StunTime = 0,
			RawStun = false,
			SlashInterval = 0.25,
			SlashRamp = 10,
			SourceType = "rod",
			SourceName = "Luminescent Oath",
			AnimTime = 0.4,
			SoundName = "oath",
			IconName = "Oath",
			IconColor = Color3.fromRGB(0, 0, 127),
			GradientColor = Color3.fromRGB(0, 0, 127)
		},
		["Luminescent Oath"] = {}
	},
	Disturbance = 2,
	PreferredDisturbance = {
		Event = "ColossalBlueDragon",
		Risk = 3
	},
	LevelRequirement = 500,
	BestiaryRequirement = {
		{
			Island = "Luminescent Cavern",
			Requirement = 100
		}
	},
	From = "Luminescent Cavern",
	Hint = "Purchasable at the Luminescent Cavern after completing the bestiary and reaching Level 500."
}
Rods["Ruinous Oath"] = {
	Icon = "rbxassetid://106093081661329",
	Price = 5000000,
	MinDistanceToPurchase = 30,
	Description = "Born from radiant crystals scorched by crimson fury, this blade blazes with unbound strength; its power no longer knows restraint...",
	Luck = 300,
	LureSpeed = 5,
	Strength = 1e999,
	LineDistance = 150,
	Resilience = 25,
	Control = 0.08,
	Color = Color3.fromRGB(255, 0, 0),
	BobberTop = Color3.fromRGB(245, 0, 0),
	BobberBottom = Color3.fromRGB(48, 48, 83),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2000
		}
	},
	MutationPool = {
		Mastered = 25
	},
	FishingPassives = {
		Generic_PerfectBoost = {
			MutationPool = {
				Mastered = 100
			}
		}
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "Interval",
			SlashChance = 5,
			SlashDamage = 2,
			StunTime = 0,
			RawStun = false,
			SlashInterval = 0.25,
			SlashRamp = 8,
			SourceType = "rod",
			SourceName = "Ruinous Oath",
			AnimTime = 0.4,
			SoundName = "oath",
			IconName = "Oath",
			IconColor = Color3.fromRGB(127, 0, 0),
			GradientColor = Color3.fromRGB(127, 0, 0)
		},
		["Ruinous Oath"] = {}
	},
	Disturbance = 4,
	PreferredDisturbance = {
		Event = "ColossalAncientDragon",
		Risk = 3
	},
	EnhancementPatches = {
		Mastery1 = {
			WeightBoost = 15
		}
	},
	BestiaryRequirement = {
		{
			Island = "Crimson Cavern",
			Requirement = 100,
			RequirementType = "both"
		}
	},
	LevelRequirement = 750,
	From = "Crimson Cavern",
	Hint = "Purchasable at the Crimson Cavern after completing the shiny sparkling bestiary and reaching Level 750."
}
Rods["Evil Pitchfork"] = {
	Icon = "rbxassetid://127858359745950",
	Price = 1e999,
	Description = "Cursed by the Deep Below, this twisted trident tempts fate with unnatural fortune. 50% chance to gain 5× your fish's base value, occasionally twisting the gain. 25% chance to summon Poseidon's shade, inflicting the Siren's Spite mutation to greatly increase weight.",
	Luck = 120,
	LureSpeed = -50,
	Strength = 1e999,
	LineDistance = 100,
	Resilience = -10,
	Control = -0.1,
	Color = Color3.fromRGB(189, 0, 0),
	BobberTop = Color3.fromRGB(167, 0, 0),
	BobberBottom = Color3.fromRGB(47, 0, 0),
	Disturbance = 4,
	ProgressEfficiency = 0.35,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2500
		}
	},
	MutationPool = {
		Evil = 20,
		["Siren's Spite"] = 25
	},
	FishingPassives = {
		Poseidon = {
			MULTIPLIER = 5,
			MULTIPLIER_POSITIVE_CHANCE = 50,
			MULTIPLIER_NEGATIVE_CHANCE = 30,
			SPAWN_GHOST_MUTATIONS = { "Siren's Spite" },
			GHOST_WEIGHT_MIN = 2,
			GHOST_WEIGHT_MAX = 3,
			GHOST_MODEL_NAME = "EvilPitchfork"
		}
	},
	ClientFishingPassives = {
		Generic_ReelRecolor = {
			BackgroundColor3 = Color3.fromRGB(76, 0, 0),
			progress = {
				BackgroundColor3 = Color3.fromRGB(91, 13, 13),
				bar = {
					BackgroundColor3 = Color3.fromRGB(138, 21, 21)
				}
			},
			fish = {
				BackgroundColor3 = Color3.fromRGB(103, 21, 21),
				icon = {
					ImageColor3 = Color3.fromRGB(111, 17, 17)
				}
			}
		},
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 25,
			SlashDamage = 8,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Evil Pitchfork",
			SoundName = "stabbystab",
			IconName = "Evil Pitchfork",
			GradientColor = "Evil Pitchfork"
		}
	},
	EnhancementPatches = {
		Mastery1 = {
			FishingPassives = {
				Poseidon = {
					MULTIPLIER = 10
				}
			}
		}
	},
	Cool = true,
	Unpurchasable = true,
	LevelRequirement = 500,
	From = "Crimson Cavern",
	Hint = "Craftable at Level 500 after receiving a reward from the Crimson King."
}
Rods["Cerulean Fang Rod"] = {
	Icon = "rbxassetid://132107415023879",
	ProgressEfficiency = 0.15,
	Price = 800000,
	MinDistanceToPurchase = 30,
	Description = [[
Swift as the spirits, this rod carves through the sea with rapid, cutting precision; its fangs strike fast and unrelenting.
Has a 15% chance for the Nova mutation.]],
	Luck = 190,
	LureSpeed = 25,
	Strength = 1e999,
	LineDistance = 175,
	Resilience = 35,
	Control = 0.25,
	Color = Color3.fromRGB(4, 175, 236),
	BobberTop = Color3.fromRGB(4, 175, 236),
	BobberBottom = Color3.fromRGB(128, 187, 219),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 1000
		}
	},
	Disturbance = 2,
	MutationPool = {
		Nova = 15
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 40,
			SlashDamage = 8,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Cerulean Fang Rod",
			SoundName = "stabbystab",
			IconName = "Default",
			GradientColor = Color3.fromRGB(0, 255, 255)
		}
	},
	Cool = true,
	LevelRequirement = 400,
	Requirements = {
		WorldState = {
			{
				Name = "meteorological",
				ExpectedValue = "Starfall",
				FailMessage = "This rod can only be purchased during Starfall."
			}
		}
	},
	From = "Luminescent Cavern",
	Hint = "Purchasable at Level 400 within the Luminescent Cavern during Starfall weather."
}
Rods["Wicked Fang Rod"] = {
	Icon = "rbxassetid://72248252695511",
	ProgressEfficiency = 0.2,
	Price = 400000,
	MinDistanceToPurchase = 30,
	Description = [[
Forged in malice, its fangs bite slow but devastatingly deep; every strike leaves ruin in its wake.
Has a 30% chance for the Solarblaze mutation.]],
	Luck = 140,
	LureSpeed = 5,
	Strength = 1e999,
	LineDistance = 75,
	Resilience = 15,
	Control = 0,
	Color = Color3.fromRGB(223, 0, 0),
	BobberTop = Color3.fromRGB(167, 0, 0),
	BobberBottom = Color3.fromRGB(47, 0, 0),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 1000
		}
	},
	Disturbance = 2,
	MutationPool = {
		Solarblaze = 30
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 25,
			SlashDamage = 10,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Wicked Fang Rod",
			SoundName = "stabbystab",
			IconName = "Wicked Fang Rod",
			GradientColor = "Wicked Fang Rod"
		}
	},
	SlashDamage = 10,
	LevelRequirement = 300,
	Requirements = {
		WorldState = {
			{
				Name = "meteorological",
				ExpectedValue = "Eclipse",
				FailMessage = "This rod can only be purchased during an Eclipse."
			}
		}
	},
	From = "Crimson Cavern",
	Hint = "Purchasable at Level 300 within the Crimson Cavern during Eclipse weather.",
	Cool = true
}
Rods["Scarlet Spincaster Rod"] = {
	Icon = "rbxassetid://103144430550800",
	Price = 180000,
	MinDistanceToPurchase = 30,
	Description = "A rod steeped in sanguine essence, pulsing with forbidden vigor and granting a 30% chance for the Crimson mutation.",
	Luck = 170,
	LureSpeed = 50,
	Strength = 250000,
	LineDistance = 30,
	Resilience = 150,
	Control = -0.2,
	Color = Color3.fromRGB(189, 0, 0),
	BobberTop = Color3.fromRGB(167, 0, 0),
	BobberBottom = Color3.fromRGB(47, 0, 0),
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 1000
		}
	},
	MutationPool = {
		Crimson = 30
	},
	From = "Crimson Cavern",
	Hint = "Purchasable at the Crimson Cavern.",
	Cool = true,
	Unpurchasable = true
}
Rods["Artisan Rod"] = {
	Icon = "rbxassetid://126515638655050",
	Price = 40000,
	MinDistanceToPurchase = 30,
	Description = "Shaped by a craftsman's patience, it worries at a fish with a steady rhythm of light cuts.",
	Luck = 145,
	LureSpeed = 35,
	Strength = 150000,
	LineDistance = 60,
	Resilience = 40,
	Control = 0.15,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 1000
		}
	},
	MutationPool = {
		["Kaito's Blessing"] = 25
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "Interval",
			SlashChance = 50,
			SlashDamage = 2,
			StunTime = 0,
			RawStun = false,
			SlashInterval = 0.8,
			SourceType = "rod",
			SourceName = "Artisan Rod",
			AnimTime = 0.2,
			SoundName = "stabbystab",
			IconName = "Default",
			GradientColor = Color3.fromRGB(214, 89, 66)
		}
	},
	Color = Color3.fromRGB(214, 89, 66),
	BobberTop = Color3.fromRGB(214, 89, 66),
	BobberBottom = Color3.fromRGB(58, 40, 33),
	From = "Skycrest",
	Hint = "Purchasable from Kaito at Skycrest."
}
Rods["Ancient Idol Rod"] = {
	Icon = "rbxassetid://73074685949959",
	Price = 1e999,
	Description = "Carved from a toppled idol. The stone still judges what you hook, and gilds or curses it accordingly.",
	Luck = 165,
	LureSpeed = 20,
	Strength = 1e999,
	LineDistance = 80,
	Resilience = 60,
	Control = 0.3,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 3000
		}
	},
	FishingPassives = {
		AncientIdolRod = {
			PetrifiedMutation = "Petrified",
			SpiritMutation = "Idol's Spirit",
			MaxSpiritChance = 60
		}
	},
	ClientFishingPassives = {
		AncientIdolRod = {
			GlowIntervalMin = 2,
			GlowIntervalMax = 4,
			GlowChance = 50,
			GlowDuration = 3.25,
			GoldenProgressMultiplier = 12,
			GoldenFishSlowdown = 1.8,
			GoldenBarShrink = 0.65,
			PurpleProgressPerSecond = 6,
			PurpleProgressLoss = 20,
			PurpleFishSpeedup = 0.55,
			PurpleBarShrink = 0.5,
			FillPerGoldenProgress = 0.03,
			DrainPerPurpleLoss = 0.01,
			PetrifiedBarSize = 1,
			PetrifiedProgressPerSecond = 10,
			GoldenColor = Color3.fromRGB(255, 214, 102),
			PurpleColor = Color3.fromRGB(168, 94, 255)
		}
	},
	Color = Color3.fromRGB(154, 148, 133),
	BobberTop = Color3.fromRGB(255, 214, 102),
	BobberBottom = Color3.fromRGB(87, 82, 72),
	From = "Skycrest",
	Hint = "Forged by Forgemaster Torin at Skycrest.",
	Unpurchasable = true
}
Rods["Breeze Caster"] = {
	Icon = "rbxassetid://99247562322165",
	Price = 1e999,
	Description = "The wind does half the work, dragging the catch back toward you and rattling the line the whole way.",
	Luck = 155,
	LureSpeed = 60,
	Strength = 200000,
	LineDistance = 100,
	Resilience = 30,
	Control = 0.35,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 2000
		}
	},
	FishingPassives = {
		Generic_WeatherBoosts = {
			Windy = {
				MutationPool = {
					Gusty = 70
				}
			},
			Default = {
				MutationPool = {
					Gusty = 25
				}
			}
		}
	},
	ClientFishingPassives = {
		BreezeCaster = {
			BarSpeedMultiplier = 1.8,
			FishPullStrength = 0.3,
			ShakeIntensity = 0.012,
			ShakeStep = 0.05
		},
		Gusts = {
			SlashDamage = 1.5,
			StunChance = 10,
			StunTime = 0.4,
			RawStun = false,
			IntervalMin = 14,
			IntervalMax = 22,
			WindyIntervalMin = 1.2,
			WindyIntervalMax = 2.2,
			SourceType = "rod",
			SourceName = "Breeze Caster",
			AnimTime = 0.35,
			SoundName = "stabbystabpaperfan",
			IconName = "Breeze",
			GradientColor = Color3.fromRGB(198, 233, 255)
		}
	},
	Color = Color3.fromRGB(198, 233, 255),
	BobberTop = Color3.fromRGB(198, 233, 255),
	BobberBottom = Color3.fromRGB(96, 132, 158),
	From = "Skycrest",
	Hint = "Obtained from Aero at Skycrest.",
	Unpurchasable = true
}
Rods["Abaia's Spite"] = {
	Icon = "rbxassetid://82238087635451",
	Price = 1e999,
	Description = "Abaia hunts alongside you now, chewing on whatever you hook and hoarding the rest for later.",
	Luck = 180,
	LureSpeed = -10,
	Strength = 1e999,
	LineDistance = 150,
	Resilience = 80,
	Control = 0.35,
	Durability = 200,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 8000
		}
	},
	MutationPool = {
		Squalled = 100,
		["Abaia's Spite"] = 25
	},
	FishingPassives = {
		AbaiasSpite = {
			CollectIntervalMin = 10,
			CollectIntervalMax = 30,
			MaxBanked = 5,
			BankedMutationPool = {
				["Abaia's Spite"] = 100
			},
			PassiveBlockLevel = 1
		},
		Generic_PerfectBoost = {
			MutationPool = {
				["Abaia's Spite"] = 25
			}
		}
	},
	ClientFishingPassives = {
		AbaiasSpite = {
			ChompIntervalMin = 5,
			ChompIntervalMax = 8,
			ChompProgress = 10,
			ChompProgressByWeather = {
				["Tropical Squall"] = 15,
				["Raging Squall"] = 25
			},
			SquallChance = 30,
			SquallProgress = 60,
			SquallRampTime = 1.5,
			AnimTime = 0.4
		}
	},
	Color = Color3.fromRGB(58, 92, 110),
	BobberTop = Color3.fromRGB(120, 200, 190),
	BobberBottom = Color3.fromRGB(28, 44, 54),
	From = "Skycrest",
	Hint = "Crafted from what Abaia leaves behind.",
	Unpurchasable = true
}
Rods.Fruitline = {
	Icon = "rbxassetid://87544947850979",
	Price = 1e999,
	Description = "Every fish it hooks leaves a wake of fruit. Catch it and everyone nearby tastes the luck.",
	Luck = 200,
	LureSpeed = 0,
	Strength = 1e999,
	LineDistance = 90,
	Resilience = 0,
	Control = 0,
	ProgressSpeed = 25,
	DiscoveryRewards = {
		{
			Type = "XP",
			Value = 3000
		}
	},
	MutationPool = {
		["Fruit-Crowned"] = 25
	},
	FishingPassives = {
		Fruitline = {
			BuffId = "FruityBlessing",
			BuffDuration = 6,
			BuffRange = 10,
			StatMultiplier = 1.1,
			CompanionLevels = 2,
			CollectDebounce = 0.15
		}
	},
	ClientFishingPassives = {
		Fruitline = {
			DropInterval = 0.45,
			TrailSpacing = 0.06,
			BarSizeMultiplier = 0.8,
			FruitLifetime = 5,
			ProgressPerFruit = 1.2,
			CollectSize = 0.06,
			FruitY = 0.5,
			StreakWindow = 1.5,
			StreakBonus = 0.03,
			StreakCap = 10,
			StreakMilestone = 5,
			BlessingGlow = 2,
			GlowColor = Color3.fromRGB(255, 214, 92)
		}
	},
	Color = Color3.fromRGB(255, 214, 92),
	BobberTop = Color3.fromRGB(255, 108, 128),
	BobberBottom = Color3.fromRGB(126, 217, 87),
	From = "Skycrest",
	Hint = "Rewarded by Fruit Lover Frank at Skycrest.",
	Unpurchasable = true,
	Unregistered = true
}
Rods.Part = {
	Icon = "rbxassetid://72444096547318",
	Price = 1e999,
	Description = "Instance.new(\"Part\",workspace)",
	Luck = 0,
	LureSpeed = 100,
	Strength = 1e999,
	LineDistance = 10,
	Resilience = 0,
	Control = 0,
	Color = Color3.fromRGB(221, 221, 221),
	BobberTop = Color3.fromRGB(194, 194, 194),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	ReelGuiName = "part",
	MutationPool = {
		Part = 100
	},
	EnhancementPatches = {
		Mastery1 = {
			MutationPool = {
				Part = 95,
				["Golden Part"] = 5
			},
			Lure = 100,
			Control = 0.7,
			Luck = 100,
			ClientFishingPassives = {
				Generic_ReelRecolor = {
					BackgroundColor3 = Color3.fromRGB(255, 179, 49),
					progress = {
						BackgroundColor3 = Color3.fromRGB(194, 146, 33),
						bar = {
							BackgroundColor3 = Color3.fromRGB(255, 176, 48),
							UIGradient = {
								Enabled = false
							}
						}
					},
					playerbar = {
						BackgroundColor3 = Color3.fromRGB(197, 141, 45)
					},
					fish = {
						BackgroundColor3 = Color3.fromRGB(255, 176, 48),
						icon = {
							ImageColor3 = Color3.fromRGB(194, 146, 33)
						}
					},
					progressspeed = {
						TextColor3 = Color3.fromRGB(255, 188, 32)
					}
				}
			}
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Underground Music Venue",
	Hint = "Obtained from BasePart."
}
Rods["Upside-Down Rod"] = {
	Icon = "rbxassetid://95381045084994",
	Price = 0,
	Description = "what happened!",
	Luck = 0,
	LureSpeed = 100,
	Strength = 10.4,
	LineDistance = 19,
	Resilience = 0,
	Control = 0,
	Color = Color3.fromRGB(154, 170, 190),
	BobberTop = Color3.fromRGB(134, 38, 38),
	BobberBottom = Color3.fromRGB(255, 255, 255),
	MutationPool = {
		["Upside-Down"] = 100
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Black Market",
	Hint = "Obtained from the Black Market."
}
Rods["Bone Blade"] = {
	Icon = "rbxassetid://128118654004308",
	Price = 0,
	Description = "🦴",
	Luck = 0,
	LureSpeed = 0,
	Strength = 1000000,
	LineDistance = 999,
	Resilience = 100,
	Control = -0.2,
	Durability = 200,
	Color = Color3.fromRGB(190, 185, 143),
	BobberTop = Color3.fromRGB(190, 185, 143),
	BobberBottom = Color3.fromRGB(35, 34, 31),
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 30,
			SlashDamage = 4,
			StunTime = 0.35,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Bone Blade",
			SoundName = "stabbystab",
			IconName = "Default",
			GradientColor = Color3.fromRGB(225, 191, 126)
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	LevelRequirement = 100,
	From = "Black Market",
	Hint = "Obtained from the Black Market."
}
Rods.Crimsonwrath = {
	Icon = "rbxassetid://125678171796826",
	Price = 1e999,
	Description = "👺",
	Luck = 100,
	LureSpeed = -1e999,
	Strength = 1e999,
	LineDistance = 999,
	Resilience = -10,
	Control = -0.1,
	Durability = 100,
	Color = Color3.fromRGB(193, 16, 0),
	BobberTop = Color3.fromRGB(193, 16, 0),
	BobberBottom = Color3.fromRGB(89, 72, 72),
	MutationPool = {
		Crimson = 10,
		Wrath = 10,
		Crimsonwrath = 30
	},
	ClientFishingPassives = {
		Generic_Slashes = {
			TriggerMode = "FishMove",
			SlashChance = 70,
			SlashDamage = 1,
			StunTime = 0.5,
			RawStun = false,
			SourceType = "rod",
			SourceName = "Crimsonwrath",
			SoundName = "stabbystab",
			IconName = "Default",
			GradientColor = Color3.fromRGB(217, 21, 21)
		}
	},
	Unregistered = true,
	Unpurchasable = true,
	LevelRequirement = 100,
	From = "Black Market",
	Hint = "Obtained from the Black Market."
}
Rods.Noctone = {
	Icon = "rbxassetid://120781933981993",
	Price = 1e999,
	Description = "Wherever we end up;\nKnow that you've made your mark...",
	Luck = 155,
	LureSpeed = 15,
	Strength = 200000,
	LineDistance = 100,
	Resilience = 65,
	Control = 0.25,
	Color = Color3.fromRGB(230, 166, 54),
	BobberTop = Color3.fromRGB(180, 142, 54),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	ReelGuiName = "noctone",
	MutationPool = {
		Glowy = 40,
		Greedy = 20
	},
	ShinyChance = 7,
	SparklingChance = 7,
	Unregistered = true,
	Unpurchasable = true,
	LevelRequirement = 1000,
	From = "Underground Music Venue",
	Hint = "Obtainable from the Underground Music Venue.",
	Tags = { "Instrument" }
}
Rods["Cornucopia Rod"] = {
	Icon = "rbxassetid://74215654089011",
	Price = 1e999,
	Description = [[
Only obtainable during Fischgiving;
A bountiful horn-of-plenty rod that spills Fischgiving treats onto fish, making them easy pickings!]],
	Luck = 112.7,
	LureSpeed = 10,
	Strength = 250000,
	LineDistance = 100,
	Resilience = 75,
	Control = 0.05,
	Color = Color3.fromRGB(230, 166, 54),
	BobberTop = Color3.fromRGB(180, 142, 54),
	BobberBottom = Color3.fromRGB(0, 0, 0),
	MutationPool = {
		Gravy = 10
	},
	FishingPassives = {
		Cornucopia = {
			InitialDelay = 2,
			MinSpawnInterval = 2,
			MaxSpawnInterval = 3
		}
	},
	ClientFishingPassives = {
		Cornucopia = {}
	},
	Unregistered = true,
	Unpurchasable = true,
	From = "Fischgiving 2",
	Hint = "Obtainable during Fischgiving 2."
}

local function count()
	local count2 = 0

	for _, v2 in Rods do
		if typeof(v2) ~= "table" or v2.Unregistered then
			continue
		end

		count2 += 1
	end

	return count2
end

local count2 = 0

for _, v2 in Rods do
	if typeof(v2) ~= "table" or v2.Unregistered then
		continue
	end

	count2 += 1
end

Rods.RegisteredNumberOfRods = count2
return Rods