require("./sharedTypes")
return {
	["Flimsy Harpoon Gun"] = {
		Price = 300,
		Description = "...",
		Power = 10,
		Range = 10,
		Reload = 10,
		Velocity = 10,
		Resilience = 10,
		Accuracy = 10,
		Strength = 1000000,
		Icon = "rbxassetid://119159450394678",
		Color = Color3.fromRGB(109, 82, 69),
		WireColor = Color3.fromRGB(77, 77, 77),
		From = "Moosewood",
		Hint = "Purchasable at Moosewood.",
		Unregistered = true
	},
	["Plastic Harpoon Gun"] = {
		Price = 1200,
		Description = "...",
		Power = 4,
		Range = 12,
		Reload = 2,
		Velocity = 20,
		Resilience = 5,
		Accuracy = -10,
		Strength = 400,
		Icon = "rbxassetid://123158810914212",
		Color = Color3.fromRGB(129, 207, 255),
		From = "Moosewood",
		Hint = "Purchasable at Moosewood.",
		Unregistered = true
	},
	["Steady Harpoon Gun"] = {
		Price = 9000,
		Description = "...",
		Power = 15,
		Range = 64,
		Reload = 6,
		Velocity = 50,
		Resilience = 20,
		Accuracy = 50,
		Strength = 10000,
		Icon = "rbxassetid://124376865327719",
		Color = Color3.fromRGB(84, 74, 62),
		From = "Roslit Bay",
		Hint = "Purchasable at Roslit Bay."
	},
	["Trident Striker"] = {
		Price = 175000,
		MinDistanceToPurchase = 40,
		Description = "Some say this was once carried by the King of the Sea for his offense, but it's often debated to this day. All fish have a 30% chance to be Atlantean. [Has a chance to pierce fish with an additional prong, completing a pull]",
		Requirements = {
			PlayerAttributes = {
				{
					Name = "CanPurchaseTridentStriker",
					ExpectedValue = true,
					FailMessage = "You must complete the ritual before purchasing this."
				}
			}
		},
		Power = 25,
		Range = 100,
		Reload = 2.5,
		Velocity = 60,
		Resilience = -5,
		Accuracy = 20,
		Strength = 50000,
		MutationPool = {
			Atlantean = 30
		},
		ClientFishingPassives = {
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 12.5,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "TridentStriker",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(255, 186, 47),
				GradientColor = Color3.fromRGB(255, 218, 107)
			}
		},
		Icon = "rbxassetid://128461907965665",
		Color = Color3.fromRGB(255, 188, 53),
		From = "Desolate Deep",
		Hint = "Purchasable somewhere near a hidden cave of the Desolate Deep; hidden behind a mysterious locked door"
	},
	["Relic Piercer"] = {
		Price = 175000,
		Description = "Forged from ancient materials. Requires rapid effort to pull, but turns quick reflexes into incredible progress.",
		Power = 25,
		Range = 90,
		Reload = 2.5,
		Velocity = 70,
		Resilience = -5,
		Accuracy = 20,
		Strength = 50000,
		MutationPool = {
			Relic = 35
		},
		Icon = "rbxassetid://83583459547191",
		Color = Color3.fromRGB(255, 188, 53),
		ClientFishingPassives = {
			Generic_HarpoonMultiClick = {
				ClicksMin = 2,
				ClicksMax = 4
			}
		},
		From = "Ancient Isle",
		Hint = "Crafted at Ancient Isle.",
		Recipe = {
			LevelRequired = 0,
			Materials = {
				{
					"Moonstone",
					3,
					nil,
					"rbxassetid://77828409661314"
				},
				{
					"Meg's Spine",
					1,
					"Marrow",
					"rbxassetid://117923629140102"
				},
				{
					"Scrap Metal",
					2,
					nil,
					"rbxassetid://75586584726923"
				}
			}
		},
		Unpurchasable = true
	},
	["Frost Biter"] = {
		Price = 270000,
		Description = "Chilled to the core; flings icy harpoons that momentarily freeze target responses in place.",
		Power = 18,
		Range = 80,
		Reload = 3.5,
		Velocity = 100,
		Resilience = 20,
		Accuracy = 15,
		Strength = 10000,
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "FrostwyrmHunt",
			Risk = 12
		},
		MutationPool = {
			Frostbite = 40
		},
		ClientFishingPassives = {
			FrostBiter = {
				FreezeTimeFactor = 0.02,
				MinFreezeTime = 0.2
			}
		},
		Icon = "rbxassetid://77948591356695",
		Color = Color3.fromRGB(152, 214, 255),
		WireColor = Color3.fromRGB(178, 228, 255),
		From = "Snowburrow",
		Hint = "Purchased at Snowburrow.",
		BestiaryRequirement = {
			{
				Island = "Boreal Pines",
				Requirement = 100
			}
		}
	},
	["Great Dream Waker"] = {
		Price = 1500000,
		Description = "Pulsing with Eldritch energy... Beckons Cthulhu to clutch and curse nearby sea life.",
		Power = 22,
		Range = 128,
		Reload = 2.5,
		Velocity = 35,
		Resilience = -20,
		Accuracy = 30,
		Strength = 35000,
		Disturbance = 9,
		PreferredDisturbance = {
			Event = "The Sanctum Hunt",
			Risk = 30
		},
		MutationPool = {
			["Cursed Touch"] = 20
		},
		ClientFishingPassives = {
			GreatDreamWaker = {}
		},
		FishingPassives = {
			GreatDreamWaker = {
				TriggerProgressMin = 40,
				TriggerProgressMax = 80,
				ButtonCountMin = 1,
				ButtonCountMax = 3,
				MaxCharge = 5,
				PassiveMutationPool = {
					["Cursed Touch"] = 100
				},
				ModelName = "Cthulhu",
				PassiveBlockLevel = 0
			}
		},
		Icon = "rbxassetid://101109667151518",
		Color = Color3.fromRGB(60, 255, 180),
		WireColor = Color3.fromRGB(67, 255, 227),
		From = "Cursed Isle",
		Hint = "Purchased at the Cursed Isle.",
		BestiaryRequirement = {
			{
				Island = "Cursed Isle",
				Requirement = 75
			}
		}
	},
	["Crystal Crasher"] = {
		Price = 2400000,
		Description = "Encased in rigid, yet beautiful resonance. Breaking through its crystalline exterior unlocks immense pulling force; stronger than diamonds.",
		Power = 20,
		Range = 110,
		Reload = 2.5,
		Velocity = 35,
		Resilience = -20,
		Accuracy = 30,
		Strength = 35000,
		MutationPool = {
			Crystalline = 25
		},
		MinigameGuiName = "crystalcrasher",
		ClientFishingPassives = {
			CrystalCrasher = {
				BaseRequiredClicks = 2,
				CrystalChargeMax = 5,
				EnhancedProgressMultiplier = 2
			}
		},
		Icon = "rbxassetid://108109496166073",
		Color = Color3.fromRGB(21, 21, 21),
		From = "Crystal Cove",
		Hint = "Purchased at Crystal Cove.",
		BestiaryRequirement = {
			{
				Island = "Crystal Cove",
				Requirement = 100
			}
		}
	},
	["Fungal Harpoon Gun"] = {
		Price = 155000,
		Description = "Coated in sporing flora, landing hits occasionally releases spores to grant temporary boosts.",
		Power = 10,
		Range = 64,
		Reload = 5,
		Velocity = 15,
		Resilience = 10,
		Accuracy = 12,
		Strength = 5000,
		MutationPool = {
			Fungal = 30
		},
		FishingPassives = {
			FungalRod = {
				BuffChance = 50,
				BuffDuration = 60,
				BuffData = {
					Stack = 10,
					BoostValue = 50
				},
				BuffName = "Luck",
				FishingType = "harpoon"
			}
		},
		Icon = "rbxassetid://135637437018064",
		Color = Color3.fromRGB(81, 141, 24),
		WireColor = Color3.fromRGB(67, 231, 22),
		From = "Mushgrove",
		Hint = "Purchasable at Mushgrove Swamp."
	},
	["Scrap-Cannon"] = {
		Price = 1e999,
		Description = "Assembled from discarded junk, this crude launcher fires heavy metal chunks that instantly shatter a target's stamina.",
		Power = 17,
		Range = 64,
		Reload = 5,
		Velocity = 10,
		Resilience = 30,
		Accuracy = 20,
		Strength = 25000,
		Scavenging = 200,
		ProgressSpeed = -10,
		MutationPool = {
			Rusty = 30
		},
		FishingPassives = {
			ScrapCannon = {
				AnimTime = 0.75,
				TriggerChance = 100,
				ProgressGain = 30,
				ProjectileModelName = "MetalChunk2"
			}
		},
		Icon = "rbxassetid://85601618403292",
		Color = Color3.fromRGB(162, 90, 65),
		WireColor = Color3.fromRGB(120, 92, 66),
		From = "The Deep",
		Hint = "Obtained from Sledge's quest.",
		Unpurchasable = true
	},
	["Titanic Scalder"] = {
		Price = 1e999,
		Description = "Forged using heat-proof metal and parts from the Thermal Vents, it unleashes a barrage of blistering rapid pulls that superheat your catch.",
		Power = 9,
		Range = 128,
		Reload = 2,
		Velocity = 32,
		Resilience = 40,
		Accuracy = 20,
		Strength = 100000,
		FishingPassives = {
			TitanicScalder = {
				MutationName = "Scalded",
				MutationChancePerHeat = 1
			}
		},
		ClientFishingPassives = {
			TitanicScalder = {
				HeatPerClick = 5,
				HeatPerMiss = -5,
				MaxHeat = 100,
				MaxExtraPullSpawnRate = 0.25,
				MaxLossPenaltyReduction = 0.1
			}
		},
		Icon = "rbxassetid://74320290758166",
		Color = Color3.fromRGB(255, 165, 62),
		WireColor = Color3.fromRGB(255, 99, 47),
		From = "The Deep",
		Hint = "Forged with the blazing heat of the Thermal Vents.",
		Recipe = {
			LevelRequired = 200,
			Materials = {
				{
					"Heat-Proof Metal",
					1,
					nil,
					"rbxassetid://98416497385331"
				},
				{
					"Thermal Harpoon",
					1,
					nil,
					"rbxassetid://130573658684063"
				},
				{
					"Salvage Scrap",
					25,
					nil,
					"rbxassetid://113227935598851"
				}
			}
		},
		Unpurchasable = true
	},
	["Sightless Oracle"] = {
		Price = 1e999,
		Description = "A sacred relic granted by the Shrine's hermit, its lineless shots automatically lock onto nearby prey, growing exponentially stronger with every accurate strike.",
		Power = 12,
		Range = 100,
		Reload = 3,
		Velocity = 32,
		Resilience = 15,
		Accuracy = 25,
		Strength = 75000,
		MutationPool = {
			Refracted = 50
		},
		MinigameGuiName = "sightlessoracle",
		ClientFishingPassives = {
			SightlessOracle_StreakBoost = {
				PowerMultPerPull = 1.05
			},
			SightlessOracle_WeirdButtonGimmick = {
				MaxSize = 2.5,
				MaxTransparency = 1
			}
		},
		Icon = "rbxassetid://93196185321373",
		Color = Color3.fromRGB(177, 174, 255),
		WireColor = Color3.fromRGB(255, 181, 214),
		From = "The Deep",
		Hint = "The final reward of The Blind Oracle.",
		Unpurchasable = true
	},
	["Cusk-Shot"] = {
		Price = 1e999,
		Description = "Crafted from the remains of the Gloomy Crevice's terror, it rends targets with visceral slashes and shadowy traps that drain a target's will to fight.",
		Power = 30,
		Range = 150,
		Reload = 1,
		Velocity = 38,
		Resilience = 35,
		Accuracy = 50,
		Strength = 250000,
		MutationPool = {
			Monstrous = 50
		},
		ClientFishingPassives = {
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 25,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "CuskShot",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(115, 85, 180),
				GradientColor = Color3.fromRGB(115, 85, 180)
			},
			CuskShot = {
				DarkPullSpawnChance = 10,
				DarkPullLifetime = 2,
				DarkPullSizeRatio = 0.5
			}
		},
		Icon = "rbxassetid://128391298634880",
		Color = Color3.fromRGB(76, 56, 111),
		WireColor = Color3.fromRGB(71, 57, 141),
		From = "The Deep",
		Hint = "Crafted from materials dropped by the Monstrous Cusk, in addition to other materials.",
		Unpurchasable = true,
		Recipe = {
			LevelRequired = 200,
			Materials = {
				{
					"Monstrous Cusk Tooth",
					1,
					nil,
					"rbxassetid://129828741726096"
				},
				{
					"Faceless Cusk",
					1,
					"Entrenched",
					"rbxassetid://128749169562382"
				},
				{
					"Refined Scrap",
					3,
					nil,
					"rbxassetid://134439726881413"
				},
				{
					"Hardened Chitin",
					3,
					nil,
					"rbxassetid://132653260130962"
				},
				{
					"Abyssal Bio-Fluid",
					3,
					nil,
					"rbxassetid://87225133657385"
				},
				{
					"Radiant Prism Scale",
					3,
					nil,
					"rbxassetid://73350099672942"
				},
				{
					"Ancient Bone",
					3,
					nil,
					"rbxassetid://78247410376423"
				}
			}
		}
	},
	["Halibut Harpoon Gun"] = {
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
		LinkedRod = "Halibut Harpoon",
		Power = 25,
		Range = 100,
		Reload = 1,
		Velocity = 120,
		Resilience = 30,
		Accuracy = 15,
		Strength = 1e999,
		BaitPreserveChance = 10,
		WeightBoost = 20,
		MutationPool = {
			Bathyal = 20,
			Thalassic = 20,
			Hadal = 20
		},
		MinigameGuiName = "halibutharpoon",
		FishingPassives = {
			SchoolObliterator = {
				MutationPool = {
					Bathyal = 20,
					Thalassic = 20,
					Hadal = 20
				},
				PassiveBlockLevel = 0
			},
			OxygenReplenishOnCatch = {
				ReplenishValue = 5
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
			}
		},
		Icon = "rbxassetid://122558740234863",
		Color = Color3.fromRGB(255, 0, 255),
		WireColor = Color3.fromRGB(55, 101, 141),
		From = "The Deep",
		Hint = "???",
		Unpurchasable = true,
		Unregistered = true
	},
	["Clickbait Chaser"] = {
		Price = 1e999,
		Description = "SUBSCRIBE & FOLLOW [CC Only]",
		Power = 30,
		Range = 200,
		Reload = 0.1,
		Velocity = 80,
		Resilience = 0,
		Accuracy = 100,
		Strength = 1e999,
		MutationPool = {
			Putrid = 0.1
		},
		MinigameGuiName = "clickbaitchaser",
		ClientFishingPassives = {
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 25,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "ClickbaitChaser",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(255, 47, 47),
				GradientColor = Color3.fromRGB(255, 105, 105)
			}
		},
		Icon = "rbxassetid://129861296926377",
		Color = Color3.fromRGB(206, 45, 45),
		From = "None",
		Hint = "???",
		DEV = true,
		Unregistered = true,
		Unpurchasable = true
	},
	["Breeze Guster"] = {
		Price = 1e999,
		Description = "A crosswind runs through the sights, herding every pull back toward the middle.",
		Power = 26,
		Range = 120,
		Reload = 1.2,
		Velocity = 65,
		Resilience = 40,
		Accuracy = 70,
		Strength = 300000,
		FishingPassives = {
			Generic_WeatherBoosts = {
				FishingTypes = "harpoon",
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
			BreezeGuster = {
				DriftPerSecond = 0.4
			},
			Gusts = {
				SlashDamage = 1.5,
				StunChance = 10,
				StunTime = 0.4,
				IntervalMin = 14,
				IntervalMax = 22,
				WindyIntervalMin = 1.2,
				WindyIntervalMax = 2.2,
				SourceType = "rod",
				SourceName = "Breeze Guster",
				AnimTime = 0.35,
				SoundName = "stabbystabpaperfan",
				IconName = "Breeze",
				GradientColor = Color3.fromRGB(198, 233, 255)
			}
		},
		Icon = "rbxassetid://134100097425321",
		Color = Color3.fromRGB(198, 233, 255),
		WireColor = Color3.fromRGB(96, 132, 158),
		From = "Skycrest",
		Hint = "Obtained from Aero at Skycrest.",
		Unpurchasable = true
	}
}