local createVector = vector.create
local companions = {
	Nico = {
		Icon = "rbxassetid://99837676797929",
		Description = "A curious little wanderer that never strays too far, sometimes bringing you gifts you didn't ask for.",
		Color = Color3.fromRGB(145, 139, 138),
		Model = "Nico",
		FishingPassives = {
			Nico_RandomFish = {
				CompanionScaling = {
					Companion = "Nico",
					MaxLevelConfig = {
						IntervalSeconds = 15,
						DiveChance = 60
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalSeconds = 30,
				DiveChance = 30,
				MutationPool = {
					["Nico's Nyantics"] = 100
				},
				PassiveBlockLevel = 0
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Pet", "Headbutt" },
		InteractPlayerAnimation = "petCompanionLarge",
		MoodHandler = "Nico",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.1, 0),
		SwimOffset = 0.1
	},
	Plunderbeak = {
		Icon = "rbxassetid://108301147153447",
		Description = "A loud-mouthed treasure hunter with a nose for riches, and a habit of making every catch feel legendary.",
		Color = Color3.fromRGB(26, 116, 20),
		Model = "Plunderbeak",
		FishingPassives = {
			Plunderbeak_PureGold = {
				CompanionScaling = {
					Companion = "Plunderbeak",
					MaxLevelConfig = {
						GoldChance = 20
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				GoldChance = 10,
				GoldMutation = "Golden",
				SkipRarities = {
					Trash = true
				}
			},
			Plunderbeak_MusicDance = {
				MusicRods = {
					"Cinderstring",
					"Electric Guitar",
					"Wingripper",
					"MiguRod",
					"Silly Fun Happy Rod",
					"Duskwire",
					"Astraeus Serenade",
					"Polaris Serenade",
					"Noctone",
					"Tranquility Rod",
					"Eardrum",
					"Pinion's Aria",
					"Apollo's Sunshot",
					"Microphone Rod",
					"Remembrance",
					"Wingkeeper",
					"Lullaby",
					"Noiseform"
				}
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = {},
		MoodHandler = "Plunderbeak",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.1, 0)
	},
	["Flopping Salmon"] = {
		Icon = "rbxassetid://110832626149715",
		Description = "An eager companion that refuses to sit still, always jumping in when things get slippery.",
		Color = Color3.fromRGB(190, 183, 183),
		Model = "Flopping Salmon",
		FishingPassives = {
			FloppingSalmon_CatchAssist = {
				CompanionScaling = {
					Companion = "Flopping Salmon",
					MaxLevelConfig = {
						AttemptInterval = 1.5,
						TriggerChance = 50
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				AttemptInterval = 3,
				TriggerChance = 25
			}
		},
		ClientFishingPassives = {
			FloppingSalmon_CatchAssist = {
				CompanionScaling = {
					Companion = "Flopping Salmon",
					MaxLevelConfig = {
						ProgressSpeedBoost = 30,
						ResilienceBoost = 30
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				ProgressSpeedBoost = 10,
				ResilienceBoost = 10
			}
		},
		InteractionAnimations = {},
		MoodHandler = "FloppingSalmon",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.2, 0),
		ModelRotation = 3.141592653589793,
		RareWalkChance = 5
	},
	["Little Meg"] = {
		Icon = "rbxassetid://102852401819596",
		Description = "A tiny terror that stirs the waters, scaring off the weak and turning every catch into a gamble.",
		Color = Color3.fromRGB(47, 111, 143),
		Model = "Little Meg",
		FishingPassives = {
			LittleMeg_FearTactics = {
				CompanionScaling = {
					Companion = "Little Meg",
					MaxLevelConfig = {
						SmallWeightThreshold = 200,
						EnhanceChance = 10,
						RamChance = 10
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				SmallWeightThreshold = 100,
				CommonRarityThreshold = "Common",
				IgnoreTrash = true,
				IgnoreCrates = true,
				IgnoreNonFish = true,
				LowRarityMultiplier = 0.1,
				EnhancedRarityThreshold = "Rare",
				EnhanceAttemptInterval = 60,
				EnhanceChance = 3,
				EnhanceDuration = 40,
				RamAttemptInterval = 50,
				RamChance = 4,
				RamWaterSearch = {
					MinRadius = 10,
					MaxRadius = 60,
					RadiusStep = 10,
					AngleStep = 36,
					ExtraStartHeight = 25,
					RayLength = 75,
					ShowRays = false
				}
			}
		},
		ClientFishingPassives = {
			JawConstriction = {
				CompanionScaling = {
					Companion = "Little Meg",
					MaxLevelConfig = {
						TriggerChance = 15,
						Duration = 7.5,
						BarAccel = 0.6,
						MoveFrequency = 1.25,
						ProgressSpeedMin = 60,
						ProgressSpeedMax = 60
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				AttemptInterval = 5,
				AttemptImmediate = false,
				TriggerChance = 10,
				Cooldown = 5,
				Duration = 5,
				ProgressSpeedMin = 30,
				ProgressSpeedMax = 30,
				BarAccel = 0.45,
				MoveFrequency = 1.45,
				EnhanceStatus = "AncientLittleMeg",
				EnhanceMultiplier = 2,
				Assets = {
					BottomTeeth = "rbxassetid://120616021774180",
					TopTeeth = "rbxassetid://104775577519556",
					LurkLeft = "rbxassetid://102939337421480",
					LurkRight = "rbxassetid://126140798124813"
				},
				EnhancedAssets = {
					BottomTeeth = "rbxassetid://87839464050005",
					TopTeeth = "rbxassetid://94035186952579",
					LurkLeft = "rbxassetid://86322673035735",
					LurkRight = "rbxassetid://112594324753592"
				}
			}
		},
		InteractionAnimations = { "Pet", "Headbutt" },
		InteractPlayerAnimation = "petCompanionLarge",
		MoodHandler = "LittleMeg",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.25, 0),
		GroundOffset = 1.1
	},
	["Mutated Sharky"] = {
		Icon = "rbxassetid://91915309046037",
		Description = "Something unstable lurks beneath it, quiet until the water twists in its favor.",
		Color = Color3.fromRGB(85, 255, 66),
		Model = "Mutated Sharky",
		FishingPassives = {
			MutatedSharky_SpawnWhirlpool = {
				CompanionScaling = {
					Companion = "Mutated Sharky",
					MaxLevelConfig = {
						SpawnChance = 100,
						SpawnAttemptInterval = 90,
						WhirlpoolDuration = 40,
						WhirlpoolMutationPool = {
							Abyssal = 20
						}
					},
					ScalingStyle = Enum.EasingStyle.Linear
				},
				Search = {
					MinRadius = 10,
					MaxRadius = 60,
					RadiusStep = 10,
					AngleStep = 36,
					ExtraStartHeight = 25,
					RayLength = 256,
					ShowRays = false
				},
				SpawnAttemptInterval = 150,
				SpawnChance = 50,
				WhirlpoolDuration = 30,
				WhirlpoolSize = createVector(25, 5, 25),
				WhirlpoolMutationPool = {
					Abyssal = 15
				}
			},
			Generic_StatBoost = {
				CompanionScaling = {
					Companion = "Mutated Sharky",
					MaxLevelConfig = {
						Stats = {
							NaturalMutationChance = 30,
							MutationChanceBoost = 10
						}
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				Stats = {
					NaturalMutationChance = 15,
					MutationChanceBoost = 5
				},
				FishingTypes = "all"
			}
		},
		ClientFishingPassives = {
			JawConstriction = {
				CompanionScaling = {
					Companion = "Mutated Sharky",
					MaxLevelConfig = {
						AttemptInterval = 5,
						BarAccel = 1.75,
						TriggerChance = 20
					},
					ScalingStyle = Enum.EasingStyle.Linear
				},
				AttemptInterval = 10,
				AttemptImmediate = false,
				TriggerChance = 10,
				Cooldown = 5,
				Duration = 5,
				ProgressSpeedMin = 0,
				ProgressSpeedMax = 0,
				BarAccel = 1.25,
				Assets = {
					TopTeeth = "rbxassetid://98713774200404"
				}
			}
		},
		InteractionAnimations = { "Pet", "Headbutt" },
		MoodHandler = "MutatedSharky",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, 0, 0),
		GroundOffset = 0.8,
		SwimOffset = -2.5
	},
	["Beak Bill"] = {
		Icon = "rbxassetid://96379439743558",
		Description = "A watchful fisher with perfect timing, swooping in when you (usually) least expect it.",
		Color = Color3.fromRGB(255, 175, 78),
		Model = "Beak Bill",
		FishingPassives = {
			BeakBill_SwoopCatch = {
				CompanionScaling = {
					Companion = "Beak Bill",
					MaxLevelConfig = {
						IntervalSeconds = 20,
						SwoopChance = 65,
						CatchGrantDelay = 12,
						BaitReturnChance = 50
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalSeconds = 45,
				SwoopChance = 35,
				CatchGrantDelay = 25,
				BaitReturnChance = 25,
				RainyIntervalMult = 0.5,
				RainyChanceMult = 2,
				PassiveBlockLevel = 0,
				WaterSearch = {
					MinRadius = 30,
					MaxRadius = 60,
					RadiusStep = 10,
					AngleStep = 36,
					ExtraStartHeight = 25,
					RayLength = 75,
					ShowRays = false
				}
			}
		},
		InteractionAnimations = {},
		MoodHandler = "BeakBill",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.2, 0),
		ModelRotation = 3.141592653589793,
		GroundOffset = 3.3
	},
	["Penguin Pal"] = {
		Icon = "rbxassetid://105873767380842",
		Description = "A cheerful little penguin that waddles at your side and slides across ice. Hops into the water to circle and freeze your catch.",
		Color = Color3.fromRGB(120, 190, 255),
		Model = "Penguin Pal",
		Skins = { "Default" },
		FishingPassives = {},
		ClientFishingPassives = {
			PenguinPal_Freezing = {
				AttemptInterval = 4,
				AttemptImmediate = false,
				TriggerChance = 15,
				Duration = 4,
				Cooldown = 6,
				CompanionScaling = {
					Companion = "Penguin Pal",
					MaxLevelConfig = {
						TriggerChance = 20,
						Duration = 6
					}
				}
			}
		},
		InteractionAnimations = { "Happy" },
		MoodHandler = "PenguinPal",
		FollowOffset = createVector(-5, 0, 0),
		FollowSmoothing = 0.18,
		ModelOffset = createVector(0, -0.7, 0),
		SwimOffset = 1.5,
		StateAnimations = {
			Walking = "Walk"
		}
	},
	["Silly Seal"] = {
		Icon = "rbxassetid://78844646469744",
		Description = "Lazy and chaotic; feed 'em well and it might just decide to help... or eat your problem.",
		Color = Color3.fromRGB(230, 242, 255),
		Model = "Silly Seal",
		FishingPassives = {
			SillySeal_Hunger = {
				CompanionScaling = {
					Companion = "Silly Seal",
					MaxLevelConfig = {
						DrainSeconds = 1500,
						FeedMultiplier = 2
					},
					ScalingStyle = Enum.EasingStyle.Linear
				},
				DrainSeconds = 420,
				FeedMultiplier = 1,
				MaxHunger = 120,
				ActiveThreshold = 0.5,
				LazyThreshold = 0.2,
				SleepThreshold = 0.05,
				FeedCutoff = 0.92,
				FeedBlacklist = {
					Rarity = { "Divine Secret" },
					Name = {}
				},
				RarityHungerPercent = {
					Trash = 2,
					Common = 4,
					Uncommon = 7,
					Unusual = 9,
					Rare = 12,
					Legendary = 18,
					Mythical = 24,
					Exotic = 30,
					Secret = 60,
					["Divine Secret"] = 100,
					Default = 8
				}
			},
			SillySeal_FishBite = {}
		},
		ClientFishingPassives = {
			SillySeal_ClientFishBite = {
				BiteIntervalMin = 1.5,
				BiteIntervalMax = 3,
				BiteProgress = 8,
				EatChance = 10,
				BiteBlacklist = {
					Name = { "Redlip Batfish" },
					Rarity = { "Divine Secret" }
				},
				RaritiesToEat = {
					"Trash",
					"Common",
					"Uncommon",
					"Unusual",
					"Rare",
					"Legendary"
				}
			}
		},
		MoodHandler = "SillySeal",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.3,
		ModelOffset = createVector(0, 0.01, 0),
		SwimOffset = -0.4
	},
	["Gary 'Gator"] = {
		Icon = "rbxassetid://130043595482591",
		Description = "A laid-back alligator that lurks nearby and snaps at hooked fish to help reel them in.",
		Color = Color3.fromRGB(75, 120, 60),
		Model = "Gary 'Gator",
		Skins = { "Default" },
		FishingPassives = {},
		ClientFishingPassives = {
			GaryGator_Bites = {
				AttemptImmediate = false,
				MiniBiteInterval = 5,
				MiniBiteChance = 33,
				MiniBiteProgress = 5,
				MiniBiteColor = Color3.fromRGB(120, 220, 100),
				InstantBiteInterval = 10,
				InstantBiteChance = 2,
				InstantBiteCooldown = 30,
				InstantBiteProgress = 50,
				InstantBiteColor = Color3.fromRGB(60, 255, 70),
				CompanionScaling = {
					Companion = "Gary 'Gator",
					MaxLevelConfig = {
						MiniBiteChance = 40,
						InstantBiteChance = 4,
						InstantBiteProgress = 60
					}
				}
			}
		},
		InteractionAnimations = { "Happy" },
		MoodHandler = "GaryGator",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.1, 0),
		SwimOffset = -0.5,
		StateAnimations = {
			Walking = "Walk",
			Jumping = "Jump"
		}
	},
	["Tropical Toucan"] = {
		Icon = "rbxassetid://115103331721188",
		Description = "An observant bird that perches on your shoulder, scouts out bait nearby, and flies over water to spot the biggest catches.",
		Color = Color3.fromRGB(255, 170, 50),
		Model = "Tropical Toucan",
		Skins = { "Default" },
		FishingPassives = {
			TropicalToucan_BaitScout = {
				AttemptInterval = 2,
				TriggerChance = 60,
				Cooldown = 5,
				BaitAmountMin = 1,
				BaitAmountMax = 3,
				BaitPools = {
					Default = {
						"Shrimp",
						"Seaweed",
						"Bagel",
						"Squid",
						"Magnet",
						"Worm",
						"Minnow",
						"Flakes",
						"Insect",
						"Fish Head",
						"Rapid Catcher",
						"Instant Catcher",
						"Super Flakes",
						"Maggot"
					},
					LostJungle = {
						"Ant",
						"Earthworm",
						"Beetle Grub",
						"Cricket",
						"Snail",
						"Centipede",
						"Stag Beetle",
						"Dragonfly",
						"Glowworm"
					},
					NectarDen = {
						"Ant",
						"Beetle Grub",
						"Nectar",
						"Centipede",
						"Stag Beetle",
						"Dragonfly",
						"Glowworm"
					}
				},
				ZonePoolMap = {
					["Lost Jungle"] = "LostJungle",
					["Living Garden"] = "LostJungle",
					["Toxic Grove"] = "LostJungle",
					["Verdant Pocket"] = "LostJungle",
					["Nectar Den"] = "NectarDen"
				},
				CompanionScaling = {
					Companion = "Tropical Toucan",
					MaxLevelConfig = {
						BaitAmountMax = 6
					}
				}
			},
			TropicalToucan_FishScout = {
				AttemptInterval = 30,
				TriggerChance = 35,
				Cooldown = 5,
				Duration = 20,
				LuckBoost = 25,
				WeightBoost = 10,
				CompanionScaling = {
					Companion = "Tropical Toucan",
					MaxLevelConfig = {
						Duration = 30,
						LuckBoost = 50,
						WeightBoost = 25
					}
				}
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Happy" },
		MoodHandler = "TropicalToucan",
		FollowOffset = createVector(-1.6, 2.2, 0),
		FollowSmoothing = 0.1,
		ModelOffset = createVector(0, 0, 0),
		Flight = true,
		StateAnimations = {
			Walking = "Fly",
			Idle = "Perch"
		}
	},
	Smudge = {
		Icon = "rbxassetid://125911995122257",
		Description = "hi im smudge",
		Color = Color3.fromRGB(126, 77, 195),
		Model = "Smudge",
		FishingPassives = {
			Smudge_TrashCollecting = {
				CompanionScaling = {
					Companion = "Smudge",
					MaxLevelConfig = {
						IntervalMin = 45,
						IntervalMax = 90
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalMin = 60,
				IntervalMax = 120,
				AllowedRarities = { "Trash" },
				MutationPool = {
					Sludged = 100
				},
				FoggyStandardMutationPool = {
					Sludged = 10
				},
				WeatherMultipliers = {
					Foggy = 1.25
				},
				PassiveBlockLevel = 0
			},
			Smudge_SuperSticky = {
				CompanionScaling = {
					Companion = "Smudge",
					MaxLevelConfig = {
						MovementMin = 2500,
						MovementMax = 5000
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				MovementMin = 5000,
				MovementMax = 10000,
				CurrencyName = "Shady Scrip",
				CurrencyAmount = 5,
				ValidZones = { "The Shady Bazaar" },
				WeatherMultipliers = {
					Foggy = 1.5
				}
			}
		},
		ClientFishingPassives = {
			Smudge_Stickiness = {
				FishSpeedRatio = 1.2
			}
		},
		InteractionAnimations = { "Happy" },
		InteractPlayerAnimation = "petCompanionLarge",
		MoodHandler = "Smudge",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.5,
		ModelOffset = createVector(0, 0, 0),
		SwimOffset = 0.1,
		GroundOffset = 1,
		Unregistered = true
	},
	["Relic Construct"] = {
		Icon = "rbxassetid://109213974684680",
		Description = "An ancient golem powered by unstable relic energy. It enhances relic discovery, strengthens Keeperbound Rods, and can consume relics to awaken unique enchantments as its glowing core shifts with newfound power.",
		Color = Color3.fromRGB(73, 200, 255),
		Model = "Relic Construct",
		FishingPassives = {
			Generic_BoostFishChances = {
				Multiply = {
					["Exalted Relic"] = 2,
					["Enchant Relic"] = 2,
					["Sovereign Relic"] = 2
				}
			},
			Generic_StatBoost = {
				Stats = {
					PowerEfficiency = 100
				}
			},
			RelicConstruct_Buffs = {
				BuffData = {
					Enchant = {
						Relic = "Enchant Relic",
						GlowColor = Color3.fromRGB(85, 255, 193),
						LevelRequirement = 0,
						BuffId = "ConstructEnchant",
						BuffData = {
							StatBoosts = {
								XpMultiply = 0.2
							}
						}
					},
					Exalted = {
						Relic = "Exalted Relic",
						GlowColor = Color3.fromRGB(229, 167, 255),
						LevelRequirement = 3,
						BuffId = "ConstructExalted",
						BuffData = {
							StatBoosts = {
								WeightBoost = 10,
								Luck = 10,
								Resilience = 10
							}
						}
					},
					Cosmic = {
						Relic = "Cosmic Relic",
						GlowColor = Color3.fromRGB(255, 99, 169),
						LevelRequirement = 5,
						BuffId = "ConstructCosmic",
						BuffData = {
							StatBoosts = {
								ShinyChance = 3,
								SparklingChance = 3,
								ForcedProgressSpeed = 3
							}
						}
					},
					Twisted = {
						Relic = "Twisted Relic",
						GlowColor = Color3.fromRGB(99, 70, 166),
						LevelRequirement = 8,
						BuffId = "ConstructTwisted",
						BuffData = {
							TwistedAttackConfig = {
								Interval = 2,
								TriggerChance = 50,
								ProgressBoost = 3
							}
						}
					},
					Sovereign = {
						Relic = "Sovereign Relic",
						GlowColor = Color3.fromRGB(167, 179, 255),
						LevelRequirement = 10,
						BuffId = "ConstructSovereign",
						BuffData = {
							MutationPool = {
								Sovereign = 10
							},
							StatBoosts = {
								XpMultiply = 0.1,
								WeightBoost = 5,
								Luck = 5,
								Resilience = 5,
								ShinyChance = 1,
								SparklingChance = 1,
								ForcedProgressSpeed = 1
							},
							TwistedAttackConfig = {
								Interval = 3,
								TriggerChance = 25,
								ProgressBoost = 3
							}
						}
					},
					Blessed = {
						Relic = "Song of the Deep",
						Secondary = true,
						GlowColor = Color3.fromRGB(128, 168, 255),
						LevelRequirement = 9,
						BuffId = "ConstructBlessed",
						BuffData = {
							StatBoosts = {
								TrueProgressSpeed = 5
							}
						}
					},
					Invincible = {
						Relic = "Invincible Relic",
						Secondary = true,
						GlowColor = Color3.fromRGB(255, 114, 43),
						LevelRequirement = 6,
						BuffId = "ConstructInvincible",
						BuffData = {
							StatBoosts = {
								Durability = 100
							}
						}
					}
				}
			}
		},
		MoodHandler = "RelicConstruct",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, 0, 0),
		SwimOffset = 0,
		GroundOffset = 0.5
	},
	Mosswaddler = {
		Icon = "rbxassetid://125309526200659",
		Description = "A mossy little ocean waddler known for its playful energy. It distracts hooked fish with frantic hopping and splashing, then proudly celebrates successful catches with excited bounces of its own.",
		Color = Color3.fromRGB(109, 209, 92),
		Model = "Mosswaddler",
		Skins = { "Default" },
		FishingPassives = {},
		ClientFishingPassives = {
			Mosswaddler_Distraction = {
				AttemptInterval = 5,
				AttemptImmediate = false,
				TriggerChance = 20,
				Cooldown = 6,
				Duration = 3,
				CompanionScaling = {
					Companion = "Mosswaddler",
					MaxLevelConfig = {
						TriggerChance = 40,
						Duration = 7
					}
				}
			}
		},
		InteractionAnimations = { "Happy" },
		MoodHandler = "Mosswaddler",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.4, 0),
		ModelRotation = 3.141592653589793,
		SwimOffset = 0.1
	},
	["Sunhat Starfish"] = {
		Icon = "rbxassetid://75170439362707",
		Description = "A cheerful, sun-loving beachcomber bursting with island energy. Each catch charges its arms with a radiant glow that stacks your fortune, while its tropical aura coaxes vibrant sun-kissed mutations from the depths.",
		Color = Color3.fromRGB(232, 110, 196),
		Model = "Sunhat Starfish",
		Skins = { "Default" },
		FishingPassives = {
			SunhatStarfish_FiveArmedFortune = {
				CompanionScaling = {
					Companion = "Sunhat Starfish",
					MaxLevelConfig = {
						LuckPerArm = 30
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				LuckPerArm = 20,
				MaxArms = 5,
				ResetRarityOrder = 6
			},
			SunhatStarfish_TropicalMutations = {
				CompanionScaling = {
					Companion = "Sunhat Starfish",
					MaxLevelConfig = {
						TriggerChance = 35
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				TriggerChance = 20
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Happy" },
		MoodHandler = "SunhatStarfish",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.53, 0),
		ModelRotation = 3.141592653589793,
		SwimOffset = 0.4,
		NoWalkBob = true,
		Unregistered = true
	},
	Terroscuttler = {
		Icon = "rbxassetid://86631911221250",
		Description = "A loyal desert friend with remarkably sharp instincts. It can sniff out valuable resources, sense movement before it happens, and never hesitates to lend a claw when fishing through the shifting sands!",
		Color = Color3.fromRGB(217, 166, 122),
		Model = "Terroscuttler",
		FishingPassives = {
			Terroscuttler_CactiFanatic = {
				CompanionScaling = {
					Companion = "Terroscuttler",
					MaxLevelConfig = {
						WalkInterval = 5,
						MaxBetweenCatches = 15
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				WalkInterval = 10,
				BaitName = "Cacti Pulp",
				BaitPerTick = 1,
				MaxBetweenCatches = 10
			}
		},
		ClientFishingPassives = {
			Terroscuttler_GlintEye = {},
			Terroscuttler_SandProficiency = {
				CompanionScaling = {
					Companion = "Terroscuttler",
					MaxLevelConfig = {
						IntervalMin = 1.5,
						IntervalMax = 3,
						ProgressPerTick = 3
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalMin = 2,
				IntervalMax = 4,
				ProgressPerTick = 2,
				SandMaterials = { "Sand" }
			}
		},
		InteractionAnimations = { "Happy" },
		InteractPlayerAnimation = "petCompanionLarge",
		MoodHandler = "Terroscuttler",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.2, 0),
		ModelRotation = 3.141592653589793,
		SwimOffset = 0.1,
		NoWalkBob = true
	},
	["Ollie Otter"] = {
		Icon = "rbxassetid://102824569357290",
		Description = "A curious little otter with a knack for uncovering hidden treasures, always eager to lend a paw... in his own mischievous way.",
		Color = Color3.fromRGB(139, 105, 76),
		Model = "Ollie Otter",
		Skins = { "Default" },
		FishingPassives = {
			OllieOtter_Evil = {
				CompanionScaling = {
					Companion = "Ollie Otter",
					MaxLevelConfig = {
						AttackChance = 8
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				AttemptInterval = 60,
				AttackChance = 5,
				AttackDamage = 5,
				AttackRange = 20,
				VictimCooldown = 120
			},
			OllieOtter_Gatherer = {
				CompanionScaling = {
					Companion = "Ollie Otter",
					MaxLevelConfig = {
						TriggerChance = 40,
						RareChance = 15
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				TriggerChance = 30,
				RareChance = 5,
				PassiveBlockLevel = 5
			},
			Generic_StatBoost = {
				CompanionScaling = {
					Companion = "Ollie Otter",
					MaxLevelConfig = {
						Stats = {
							Scavenging = 200
						}
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				Stats = {
					Scavenging = 100
				},
				FishingTypes = "all"
			}
		},
		ClientFishingPassives = {
			OllieOtter_Attack = {
				CompanionScaling = {
					Companion = "Ollie Otter",
					MaxLevelConfig = {
						TriggerChance = 55,
						AttackProgress = 6
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalMin = 2,
				IntervalMax = 9,
				TriggerChance = 35,
				AttackProgress = 4,
				SmallWeightReference = 100,
				SmallFishChanceMult = 2,
				FlashColor = Color3.fromRGB(150, 111, 74)
			},
			OllieOtter_Treasure = {
				CompanionScaling = {
					Companion = "Ollie Otter",
					MaxLevelConfig = {
						FillTime = 2.5
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				FillTime = 5,
				DecayMult = 0.4,
				ZoneSize = 0.05,
				AppearDelayMin = 1,
				AppearDelayMax = 2
			}
		},
		InteractionAnimations = { "Happy" },
		MoodHandler = "OllieOtter",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, 0.5, 0),
		ModelRotation = 3.141592653589793,
		SwimOffset = -0.7,
		NoWalkBob = true
	},
	["Scrap-Bot"] = {
		Icon = "rbxassetid://108105661789945",
		Description = "A diligent little robot that scours the depths for useful materials, occasionally putting its machinery to work on nearby fish.",
		Color = Color3.fromRGB(66, 66, 66),
		Model = "Scrap-Bot",
		Skins = { "Default" },
		FishingPassives = {
			ScrapBot_ScrapCollector = {
				CompanionScaling = {
					Companion = "Scrap-Bot",
					MaxLevelConfig = {
						IntervalMin = 40,
						IntervalMax = 60
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalMin = 60,
				IntervalMax = 90,
				WaterSearchRadius = 60,
				AmountMin = 1,
				AmountMax = 1
			},
			ScrapBot_FishCollector = {
				CompanionScaling = {
					Companion = "Scrap-Bot",
					MaxLevelConfig = {
						IntervalMin = 15,
						IntervalMax = 30
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalMin = 30,
				IntervalMax = 90,
				RoamerSearchRadius = 128,
				GrabDurationMin = 3,
				GrabDurationMax = 8,
				WeightReference = 500,
				PassiveBlockLevel = 0
			},
			ScrapBot_FishRefiner = {
				CompanionScaling = {
					Companion = "Scrap-Bot",
					MaxLevelConfig = {
						MaxTargets = 5,
						RefineRadius = 60
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				Interval = 15,
				RefineRadius = 40,
				MutationName = "Refined",
				MaxTargets = 3,
				PlayDive = true
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Wiggle" },
		MoodHandler = "ScrapBot",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.12,
		ModelOffset = createVector(0, 0, 0),
		Flight = true,
		NoWalkBob = true,
		StateAnimations = {
			Walking = "Hover",
			Idle = "Hover"
		}
	},
	Comet = {
		Icon = "rbxassetid://128948044462727",
		Description = "A luminous celestial spirit that hovers overhead, calling down shooting stars to steady your line and pulling rare cosmic treasures from the sky.",
		Color = Color3.fromRGB(255, 248, 157),
		Model = "Comet",
		Skins = { "Default" },
		FishingPassives = {
			Comet_ShootingStars = {},
			Comet_AstralLuck = {
				CompanionScaling = {
					Companion = "Comet",
					MaxLevelConfig = {
						MeteorChance = 5,
						MeteorStackPerExtra = 1,
						MeteorRarityFlatten = 0.65,
						FallenStarChance = 30,
						FallenStarStackPerExtra = 4,
						FallenStarRarityFlatten = 0.65
					}
				},
				MeteorTargetItem = "Moonstone",
				MeteorChance = 2,
				MeteorStackPerExtra = 0,
				MeteorCap = 10,
				FallenStarTargetItem = "Cosmic Relic",
				FallenStarChance = 22,
				FallenStarStackPerExtra = 0,
				FallenStarCap = 50
			}
		},
		ClientFishingPassives = {
			Comet_ShootingStars = {
				CompanionScaling = {
					Companion = "Comet",
					MaxLevelConfig = {
						TriggerChance = 60,
						Duration = 4.5
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				AttemptInterval = 3,
				AttemptImmediate = false,
				TriggerChance = 40,
				Cooldown = 5,
				Duration = 3,
				ProgressSpeedBoost = 10,
				ResilienceBoost = 5,
				ControlPenalty = 0.12
			}
		},
		InteractionAnimations = {},
		MoodHandler = "Comet",
		FollowOffset = createVector(-4, 3, 0),
		FollowSmoothing = 0.25,
		ModelOffset = createVector(0, 0, 0),
		ModelRotation = 3.141592653589793,
		Flight = true,
		NoWalkBob = true,
		StateAnimations = {
			Walking = "Fly",
			Idle = "Hover"
		}
	},
	["Idol Taiga"] = {
		Icon = "rbxassetid://139658660624566",
		Description = "A stone-carved guardian of the Ancient Idols that favors those who feed the flame.",
		Color = Color3.fromRGB(148, 148, 138),
		Model = "Idol Taiga",
		Skins = { "Default" },
		MoodHandler = "IdolTaiga",
		PassiveToggle = {
			Label = "Burn",
			DataPath = { "Skycrest", "SacrificialEnabled" },
			Remote = "Companion/IdolTaiga/ToggleSacrificial"
		},
		FishingPassives = {
			IdolTaiga_CharmFanatic = {
				CharmBoostPercent = 20
			},
			IdolTaiga_IdolFavoring = {
				CompanionScaling = {
					Companion = "Idol Taiga",
					MaxLevelConfig = {
						FavorBoostPercent = 25
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				FavorBoostPercent = 5
			},
			IdolTaiga_Sacrificial = {
				BurnChance = 20,
				FavorPerBurnXPRatio = 0.1
			},
			IdolTaiga_TaigaSpearing = {
				CompanionScaling = {
					Companion = "Idol Taiga",
					MaxLevelConfig = {
						SpearChance = 50
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalSeconds = 60,
				RetryCooldown = 20,
				SpearChance = 30,
				SearchRadius = 80,
				PassiveBlockLevel = 0
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Interact" },
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.1, 0)
	},
	Him = {
		Icon = "rbxassetid://120861788678376",
		Description = "wat da heck",
		Color = Color3.fromRGB(167, 167, 167),
		Model = "Him",
		FishingPassives = {
			Nico_RandomFish = {
				CompanionScaling = {
					Companion = "Him",
					MaxLevelConfig = {
						IntervalSeconds = 1800,
						DiveChance = 1
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				IntervalSeconds = 3600,
				DiveChance = 1,
				MutationPool = {
					Putrid = 50,
					Aether = 50
				},
				PassiveBlockLevel = 0,
				MakeUntradeable = true
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = { "Wave", "Cheer" },
		InteractPlayerAnimation = "petCompanionLarge",
		MoodHandler = "Nico",
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, -0.1, 0),
		SwimOffset = 0.1,
		SwimPitch = -1.5707963267948966,
		GroundOffset = 1.5,
		NoWalkBob = true,
		Unregistered = true
	},
	Budling = {
		Icon = "rbxassetid://99526163187569",
		Description = "A sleepy sprout with a nose for nectar, happiest when the garden's in bloom and the night is kind.",
		Color = Color3.fromRGB(85, 170, 0),
		Model = "Budling",
		MoodHandler = "Budling",
		FishingPassives = {
			Budling_NectarAroma = {
				CompanionScaling = {
					Companion = "Budling",
					MaxLevelConfig = {
						TrashReduction = 80
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				ChargePerPerfect = 1,
				MaxCharge = 5,
				DecayPerCatch = 1,
				TrashReduction = 60
			},
			Budling_MidnightBloom = {
				CompanionScaling = {
					Companion = "Budling",
					MaxLevelConfig = {
						Reduction = 0.7
					},
					ScalingStyle = Enum.EasingStyle.Quad
				},
				Reduction = 0.4,
				OnlyAtNight = true
			},
			Budling_FlowerResonance = {
				Divisor = 2
			}
		},
		ClientFishingPassives = {},
		InteractionAnimations = {},
		FollowOffset = createVector(-6, 0, 0),
		FollowSmoothing = 0.15,
		ModelOffset = createVector(0, 0, 0),
		SwimOffset = 0,
		GroundOffset = 1,
		NoWalkBob = true,
		Unregistered = true
	}
}
local skins = require(script.skins)

for k, v2 in pairs(companions) do
	local skins2 = { "Default" }

	for k2, skin in pairs(skins.Skins) do
		if skin.TargetCompanion == k then
			table.insert(skins2, k2)
		end
	end

	v2.Skins = skins2
end

local count = 0

for _, v2 in pairs(companions) do
	if not v2.Unregistered then
		count += 1
	end
end

return table.freeze({
	Companions = companions,
	RegisteredCount = count
})