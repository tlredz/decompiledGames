local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("../SharedEnchants")
local module2 = require("../../SharedDataHelper")
local module3 = require("../../../utils/GeneralUtils")
local apply_op = require(ReplicatedStorage.shared.utils.GeneralUtils.apply_op)
local Enchants = {
	Enchants = {
		Cupid = {
			Description = "10% chance for the Sweet mutation, increases Lure Speed by <$Lure$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(253, 255, 221),
			StrokeColor = Color3.fromRGB(226, 175, 231),
			ForceStroke = true,
			Display = "Cupid",
			Lure = 25,
			ProgressSpeed = 30,
			Mutations = {
				{
					Name = "Sweet",
					Chance = 10
				}
			},
			RelicGroup = "Cupid",
			CanSelectFromAdmin = false
		},
		["Valentine's"] = {
			Description = "45% chance for a random Valentine's mutation, increases Resilience by <$Resilience$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(234, 151, 202),
			StrokeColor = Color3.fromRGB(200, 70, 105),
			Display = "Valentine's",
			Resilience = 10,
			ProgressSpeed = 30,
			Mutations = {
				{
					Name = "Sweet",
					Chance = 15
				},
				{
					Name = "Lovely",
					Chance = 15
				},
				{
					Name = "Candy",
					Chance = 15
				}
			},
			RelicGroup = "Valentine",
			CanSelectFromAdmin = false
		},
		Hunter = {
			Description = "Increases Disturbance by +<$Disturbance$>",
			Color = Color3.fromRGB(86, 30, 229),
			StrokeColor = Color3.fromRGB(23, 16, 45),
			Display = "Hunter",
			Disturbance = 2,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Ferocious = {
			Description = "Increases Disturbance by +<$Disturbance$>",
			Color = Color3.fromRGB(144, 21, 24),
			StrokeColor = Color3.fromRGB(85, 12, 15),
			Display = "Ferocious",
			Disturbance = 4,
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Santa = {
			Description = "30% chance for a Fischmas mutation, increases fish size by <$WeightBoost$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(234, 57, 57),
			StrokeColor = Color3.fromRGB(231, 231, 231),
			ForceStroke = true,
			Display = "Santa",
			WeightBoost = 30,
			ProgressSpeed = 30,
			Mutations = {
				{
					Name = "Santa",
					Chance = 6
				},
				{
					Name = "Jingle Bell",
					Chance = 6
				},
				{
					Name = "Merry",
					Chance = 6
				},
				{
					Name = "Peppermint",
					Chance = 6
				},
				{
					Name = "Gingerbread",
					Chance = 6
				}
			},
			RelicGroup = "Santa",
			CanSelectFromAdmin = false
		},
		Merry = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases Lure Speed by <$Lure$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(22, 131, 26),
			StrokeColor = Color3.fromRGB(3, 44, 0),
			Display = "Merry",
			Lure = 35,
			ProgressSpeed = 35,
			Mutations = {
				{
					Name = "Merry",
					Chance = 10
				}
			},
			RelicGroup = "Festive",
			CanSelectFromAdmin = false
		},
		Peppermint = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, rod has a high chance to lightly stab fish while reeling, & increases Luck by <$Luck$>%",
			Color = Color3.fromRGB(255, 0, 0),
			StrokeColor = Color3.fromRGB(255, 255, 255),
			ForceStroke = true,
			Display = "Peppermint",
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 40,
					SlashDamage = 1,
					StunTime = 0.1,
					SourceType = "secondaryEnchant",
					SourceName = "Peppermint",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(255, 0, 0),
					GradientColor = Color3.fromRGB(255, 0, 0)
				}
			},
			Luck = 25,
			Mutations = {
				{
					Name = "Peppermint",
					Chance = 10
				}
			},
			Secondary = true,
			RelicGroup = "Festive",
			CanSelectFromAdmin = false
		},
		Gingerbread = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases fish size by <$WeightBoost$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(140, 70, 43),
			StrokeColor = Color3.fromRGB(35, 0, 0),
			Display = "Gingerbread",
			WeightBoost = 40,
			ProgressSpeed = 10,
			Mutations = {
				{
					Name = "Gingerbread",
					Chance = 10
				}
			},
			RelicGroup = "Festive",
			CanSelectFromAdmin = false
		},
		Rage = {
			Description = "Slashes fish with unmatched force, Decreases Luck by <$Luck$>%, & Decreases Resilience by <$Resilience$>%",
			Color = Color3.fromRGB(209, 17, 17),
			StrokeColor = Color3.fromRGB(36, 17, 17),
			Display = "Rage",
			Luck = -50,
			Resilience = -20,
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 25,
					SlashDamage = 8,
					StunTime = 0.25,
					SourceType = "enchant",
					SourceName = "Rage",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(209, 17, 17),
					GradientColor = Color3.fromRGB(209, 17, 17)
				}
			},
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		Greed = {
			Description = "Makes fish <$WeightBoost$>% bigger, Decreases Lure Speed by <$Lure$>%, & Decreases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(255, 191, 0),
			StrokeColor = Color3.fromRGB(90, 57, 17),
			Display = "Greed",
			ProgressSpeed = -5,
			Lure = -30,
			WeightBoost = 50,
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		Fractured = {
			Description = "Increases Progress Speed by <$ProgressSpeed$>%, & Decreases Control by <$Control$>",
			Color = Color3.fromRGB(213, 207, 185),
			StrokeColor = Color3.fromRGB(102, 99, 88),
			Display = "Fractured",
			ProgressSpeed = 50,
			Control = -0.1,
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		["Blessed Song"] = {
			Description = "Increases Progress Speed by <$ProgressSpeed$>% and True Progress Speed by <$TrueProgressSpeed$>%",
			Color = Color3.fromRGB(0, 170, 255),
			StrokeColor = Color3.fromRGB(0, 60, 90),
			Display = "Blessed Song",
			ProgressSpeed = 20,
			TrueProgressSpeed = 20,
			RelicGroup = "SongOfTheDeep",
			CanSelectFromAdmin = true
		},
		Dune = {
			Description = "Grants infinite Strength, allows fishing in Drylands sand, and <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to duplicate fish with <$FishingPassives.Generic_DuplicateFish.DuplicateMutation$> Mutation",
			Color = Color3.fromRGB(255, 227, 170),
			StrokeColor = Color3.fromRGB(35, 30, 25),
			Display = "Dune",
			Strength = 1e999,
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 5,
					DuplicateMutation = "Dune",
					PassiveBlockLevel = 3
				}
			},
			Secondary = true,
			RelicGroup = "Dune",
			CanSelectFromAdmin = true,
			AdminRelicQuestRequirement = "Drylands6_AwakenedTerrosunder"
		},
		Frightful = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases Progress Speed by <$ProgressSpeed$>%, & decreases Resilience by <$Resilience$>%",
			Color = Color3.fromRGB(123, 104, 165),
			StrokeColor = Color3.fromRGB(44, 37, 50),
			Display = "Frightful",
			Resilience = -20,
			ProgressSpeed = 50,
			Mutations = {
				{
					Name = "Frightful",
					Chance = 10
				}
			},
			RelicGroup = "Frightful",
			CanSelectFromAdmin = false
		},
		Spooky = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases Control by <$Control$>, & rapid Slashes",
			Color = Color3.fromRGB(220, 151, 81),
			StrokeColor = Color3.fromRGB(50, 39, 28),
			Display = "Spooky",
			Control = 0.1,
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 30,
					SlashDamage = 3,
					StunTime = 0.25,
					SourceType = "enchant",
					SourceName = "Spooky",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(220, 151, 81),
					GradientColor = Color3.fromRGB(220, 151, 81)
				}
			},
			Mutations = {
				{
					Name = "Spooky",
					Chance = 10
				}
			},
			RelicGroup = "Spooky",
			CanSelectFromAdmin = false
		},
		Eerie = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases fish size by <$WeightBoost$>%, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(84, 211, 114),
			StrokeColor = Color3.fromRGB(67, 84, 72),
			Display = "Eerie",
			WeightBoost = 10,
			ProgressSpeed = 10,
			Mutations = {
				{
					Name = "Eerie",
					Chance = 10
				}
			},
			Secondary = true,
			RelicGroup = "Eerie",
			CanSelectFromAdmin = false
		},
		["Sea King"] = {
			Description = "Makes fish <$WeightBoost$>% bigger",
			Color = Color3.fromRGB(53, 77, 211),
			StrokeColor = Color3.fromRGB(9, 13, 35),
			Display = "Sea King",
			WeightBoost = 30,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Swift = {
			Description = "Increases Lure Speed by <$Lure$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(181, 227, 229),
			StrokeColor = Color3.fromRGB(40, 50, 50),
			Display = "Swift",
			ProgressSpeed = 10,
			Lure = 30,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Long = {
			Description = "Increases Line Distance by <$LineDistance$> studs, Resilience by <$Resilience$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(223, 165, 64),
			StrokeColor = Color3.fromRGB(33, 25, 14),
			Display = "Long",
			LineDistance = 150,
			ProgressSpeed = 15,
			Resilience = 35,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Ghastly = {
			Description = "All caught fish become <$Mutations.1.Name$>, with a <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to double caught fish",
			Color = Color3.fromRGB(129, 223, 173),
			StrokeColor = Color3.fromRGB(46, 79, 61),
			Display = "Ghastly",
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 10,
					DuplicateMutation = "Translucent",
					PassiveBlockLevel = 3
				}
			},
			Mutations = {
				{
					Name = "Translucent",
					Chance = 100
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Lucky = {
			Description = "Increases Luck by <$Luck$>%, Lure Speed by <$Lure$>%, & natural Mutation chances by <$NaturalMutationChance$>%",
			Color = Color3.fromRGB(126, 229, 164),
			StrokeColor = Color3.fromRGB(25, 45, 32),
			Display = "Lucky",
			Luck = 25,
			Lure = 15,
			NaturalMutationChance = 50,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Divine = {
			Description = "Increases luck by <$Luck$>%, Resilience by <$Resilience$>%, & Lure Speed by <$Lure$>%",
			Color = Color3.fromRGB(198, 229, 220),
			StrokeColor = Color3.fromRGB(118, 135, 132),
			Display = "Divine",
			Luck = 50,
			Lure = 25,
			Resilience = 20,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Mutated = {
			Description = "Increases natural Mutation chances by <$NaturalMutationChance$>%",
			Color = Color3.fromRGB(147, 229, 112),
			StrokeColor = Color3.fromRGB(45, 58, 39),
			Display = "Mutated",
			NaturalMutationChance = 90,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Unbreakable = {
			Description = "Increases Strength by <$Strength$>kg, Control by <$Control$>, and Durability by <$Durability$>",
			Color = Color3.fromRGB(225, 179, 229),
			StrokeColor = Color3.fromRGB(16, 13, 16),
			Display = "Unbreakable",
			Strength = 10000,
			Control = 0.1,
			Durability = 50,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Steady = {
			Description = "Increases Progress Speed by <$ProgressSpeed$>%, & Control by <$Control$>",
			Color = Color3.fromRGB(229, 207, 191),
			StrokeColor = Color3.fromRGB(21, 19, 18),
			Display = "Steady",
			ProgressSpeed = 20,
			Control = 0.05,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Blessed = {
			Description = "Increases Shiny & Sparkling chances by <$ShinyChance$>%, Lure Speed by <$Lure$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(255, 79, 164),
			StrokeColor = Color3.fromRGB(42, 20, 34),
			Display = "Blessed",
			Lure = 5,
			ShinyChance = 5,
			SparklingChance = 5,
			ProgressSpeed = 5,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Wormhole = {
			Description = "<$FishingPassives.WormholeEnchant.ActivateChance$>% chance to catch a fish and mutation from a random place",
			Color = Color3.fromRGB(145, 90, 255),
			StrokeColor = Color3.fromRGB(13, 8, 22),
			Display = "Wormhole",
			FishingPassives = {
				WormholeEnchant = {
					ActivateChance = 80
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Resilient = {
			Description = "Increases Resilience by <$Resilience$>%, & Fish Size by <$WeightBoost$>%",
			Color = Color3.fromRGB(106, 255, 198),
			StrokeColor = Color3.fromRGB(17, 29, 25),
			Display = "Resilient",
			WeightBoost = 10,
			Resilience = 35,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Controlled = {
			Description = "Increases Control by <$Control$>",
			Color = Color3.fromRGB(175, 155, 255),
			StrokeColor = Color3.fromRGB(32, 28, 39),
			Display = "Controlled",
			Control = 0.15,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Storming = {
			Description = "Increases Luck by <$Luck$>%, Lure Speed by <$Lure$>%, & <$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation [Doubled during Rain, Tripled during Storms]",
			Color = Color3.fromRGB(255, 236, 131),
			StrokeColor = Color3.fromRGB(36, 36, 24),
			Display = "Storming",
			Luck = 50,
			Lure = 25,
			Mutations = {
				{
					Name = "Electric",
					Chance = 25
				}
			},
			ConditionalBoosts = function(data, _)
				local v = ReplicatedStorage.world.weather.Value == "Rain" and 2 or ReplicatedStorage.world.weather.Value == "Stormy" and 3 or nil

				if v then
					return {
						Luck = data.Luck * v,
						Lure = data.Lure * v,
						Mutations = {
							{
								Name = data.Mutations[1].Name,
								Chance = data.Mutations[1].Chance * v
							}
						}
					}
				end
			end,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Scrapper = {
			Description = "<$BaitPreserveChance$>% chance to not consume Bait, +<$Percent::BaitEffectiveness$>% Bait Effectiveness",
			Color = Color3.fromRGB(255, 155, 83),
			StrokeColor = Color3.fromRGB(36, 23, 13),
			Display = "Scrapper",
			BaitPreserveChance = 60,
			BaitEffectiveness = 0.25,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Breezed = {
			Description = "Increases Luck by <$Luck$>%, Lure Speed by <$Lure$>%, & Progress Speed by <$ProgressSpeed$>% [Doubled during Windy weather]",
			Color = Color3.fromRGB(188, 208, 255),
			StrokeColor = Color3.fromRGB(28, 30, 36),
			Display = "Breezed",
			Luck = 50,
			Lure = 20,
			ProgressSpeed = 10,
			ConditionalBoosts = function(data, _)
				if ReplicatedStorage.world.weather.Value == "Windy" then
					return {
						Luck = data.Luck * 2,
						Lure = data.Lure * 2,
						ProgressSpeed = data.ProgressSpeed * 2
					}
				end
			end,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Insight = {
			Description = "<$XpMultiply$>× XP after catching a fish, Lure Speed increased by <$Lure$>%, & grants a <$Mutations.1.Chance$>% chance to Purify caught fish",
			Color = Color3.fromRGB(128, 255, 114),
			StrokeColor = Color3.fromRGB(29, 36, 27),
			Display = "Insight",
			XpMultiply = 1.5,
			Lure = 30,
			Mutations = {
				{
					Name = "Purified",
					Chance = 30
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Clever = {
			Description = "<$XpMultiply$>× XP after catching a fish",
			Color = Color3.fromRGB(255, 110, 166),
			StrokeColor = Color3.fromRGB(36, 18, 24),
			Display = "Clever",
			XpMultiply = 2.25,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Noir = {
			Description = "Caught fish will be Albino or Darkened, with a <$WeightBoost$>% size boost",
			Color = Color3.fromRGB(255, 255, 255),
			StrokeColor = Color3.fromRGB(0, 0, 0),
			Display = "Noir",
			WeightBoost = 20,
			Mutations = {
				{
					Name = "Albino",
					Chance = 50
				},
				{
					Name = "Darkened",
					Chance = 50
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Hasty = {
			Description = "Increases Lure Speed by <$Lure$>%",
			Color = Color3.fromRGB(229, 209, 92),
			StrokeColor = Color3.fromRGB(50, 42, 12),
			Display = "Hasty",
			Lure = 55,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Quality = {
			Description = "Increases Luck by <$Luck$>%, Resilience by <$Resilience$>%, Lure Speed by <$Lure$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(158, 255, 55),
			StrokeColor = Color3.fromRGB(56, 90, 19),
			Display = "Quality",
			Luck = 20,
			Lure = 20,
			ProgressSpeed = 5,
			Resilience = 10,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Abyssal = {
			Description = "Caught fish have a <$Mutations.1.Chance$>% chance to be <$Mutations.1.Name$>, & a chance to be larger, or a low chance to be notably smaller",
			Color = Color3.fromRGB(39, 57, 173),
			StrokeColor = Color3.fromRGB(83, 41, 173),
			Display = "Abyssal",
			WeightBoost = 30,
			Mutations = {
				{
					Name = "Abyssal",
					Chance = 20
				}
			},
			ConditionalBoosts = function(_, _)
				if math.random() <= 0.2 then
					return {
						WeightBoost = -40
					}
				end
			end,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Herculean = {
			Description = "Increases Strength by <$Strength$>kg, Control by <$Control$>, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(255, 234, 0),
			StrokeColor = Color3.fromRGB(48, 43, 0),
			Display = "Herculean",
			Strength = 25000,
			ProgressSpeed = 10,
			Control = 0.2,
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Mystical = {
			Description = "Increases Luck by <$Luck$>%, Resilience by <$Resilience$>%, Lure Speed by <$Lure$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(194, 223, 255),
			StrokeColor = Color3.fromRGB(43, 50, 57),
			Display = "Mystical",
			Luck = 25,
			Lure = 15,
			ProgressSpeed = 10,
			Resilience = 45,
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Quantum = {
			Description = "Caught fish have a <$Mutations.1.Chance$>% chance to be <$Mutations.1.Name$>, & increased Resilience by <$Resilience$>%; Increases with Perfect Cast",
			Color = Color3.fromRGB(255, 0, 179),
			StrokeColor = Color3.fromRGB(49, 0, 36),
			Display = "Quantum",
			Resilience = 15,
			Mutations = {
				{
					Name = "Subspace",
					Chance = 25
				}
			},
			FishingPassives = {
				Quantum = {
					MUTATION = "Subspace",
					PERFECT_CAST_PROGRESS_BONUS = 10,
					PERFECT_CAST_MUTATION_CHANCE_BONUS = 10
				}
			},
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Invincible = {
			Description = "Grants infinite Strength and +<$Durability$> Durability",
			Color = Color3.fromRGB(255, 98, 25),
			StrokeColor = Color3.fromRGB(35, 13, 3),
			Display = "Invincible",
			Strength = 1e999,
			Durability = 200,
			Secondary = true,
			RelicGroup = "Invincible",
			CanSelectFromAdmin = true
		},
		Piercing = {
			Description = "Rod has a chance to stab fish while reeling, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(13, 167, 141),
			StrokeColor = Color3.fromRGB(3, 40, 33),
			Display = "Piercing",
			ProgressSpeed = 15,
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 30,
					SlashDamage = 6,
					StunTime = 0.35,
					SourceType = "enchant",
					SourceName = "Piercing",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(13, 167, 141),
					GradientColor = Color3.fromRGB(13, 167, 141)
				}
			},
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Anomalous = {
			Description = "Caught fish have a <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to be duplicated & <$FishingPassives.Generic_DuplicateFish.DuplicateMutation$>",
			Color = Color3.fromRGB(255, 29, 29),
			StrokeColor = Color3.fromRGB(35, 4, 4),
			Display = "Anomalous",
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 20,
					DuplicateMutation = "Anomalous",
					PassiveBlockLevel = 3
				}
			},
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		["Sea Overlord"] = {
			Description = "Makes fish <$WeightBoost$>% bigger",
			Color = Color3.fromRGB(51, 168, 211),
			StrokeColor = Color3.fromRGB(9, 29, 35),
			Display = "Sea Overlord",
			WeightBoost = 40,
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Immortal = {
			Description = "Increases Luck by <$Luck$>%, & Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(232, 217, 255),
			StrokeColor = Color3.fromRGB(69, 65, 76),
			Display = "Immortal",
			Luck = 75,
			ProgressSpeed = 30,
			RelicGroup = "Exalted",
			CanSelectFromAdmin = true
		},
		Flashline = {
			Description = "A small chance of majorly boosted Progress Speed",
			Color = Color3.fromRGB(255, 255, 255),
			StrokeColor = Color3.fromRGB(49, 49, 49),
			Display = "Flashline",
			ProgressSpeed = 15,
			ConditionalBoosts = function(_, _)
				if math.random(1, 4) == 1 then
					return {
						ProgressSpeed = 100
					}
				end
			end,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Scavenger = {
			Description = "Raised chances for utility catches",
			Color = Color3.fromRGB(255, 191, 102),
			StrokeColor = Color3.fromRGB(56, 39, 13),
			Display = "Scavenger",
			FishingPassives = {
				Generic_BoostFishChances = {
					Multiply = {
						["Exalted Relic"] = 1.75,
						["Enchant Relic"] = 3
					}
				}
			},
			Scavenging = 200,
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Chaotic = {
			Description = "Unleash pure chaos with every cast. Slashes fish with an <$Mutations.1.Chance$>% chance to awaken the <$Mutations.1.Name$> mutation",
			Color = Color3.fromRGB(20, 19, 22),
			StrokeColor = Color3.fromRGB(255, 255, 255),
			ForceStroke = true,
			Display = "Chaotic",
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 15,
					SlashDamage = 6,
					StunTime = 0.35,
					SourceType = "enchant",
					SourceName = "Chaotic",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(255, 255, 255),
					GradientColor = Color3.fromRGB(20, 19, 22)
				}
			},
			Mutations = {
				{
					Name = "Chaotic",
					Chance = 12
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Sacrificial = {
			Description = "Sacrifice health for a health-dependent chance to apply the Sanguine mutation",
			Color = Color3.fromRGB(74, 8, 8),
			StrokeColor = Color3.fromRGB(163, 17, 17),
			ForceStroke = true,
			Display = "Sacrificial",
			FishingPassives = {
				Sacrificial = {
					HealthCost = 20,
					HealthChanceRatio = 1,
					MutationName = "Sanguine"
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Chronos = {
			Description = "Occasionally freeze fish in place",
			Color = Color3.fromRGB(29, 84, 211),
			StrokeColor = Color3.fromRGB(11, 13, 35),
			Display = "Chronos",
			ClientFishingPassives = {
				Chronos = {
					FreezeChance = 50,
					FreezeCooldown = 2.5,
					FreezeDuration = 3
				}
			},
			RelicGroup = "Default",
			CanSelectFromAdmin = true
		},
		Momentum = {
			Description = "Perfect Catches increase Lure, Resilience & Progress Speed incrementally",
			Color = Color3.fromRGB(211, 179, 128),
			StrokeColor = Color3.fromRGB(35, 27, 18),
			Display = "Momentum",
			ProgressSpeed = 0,
			RelicGroup = "Default",
			CanSelectFromAdmin = true,
			FishingPassives = {
				MomentumEnchant = {
					AttributeName = "CurrentMomentumBoost",
					BoostPerStack = 2,
					ReducePerImperfect = 4,
					MaxBoost = 40
				}
			},
			ConditionalBoosts = function(_, instance)
				return {
					ProgressSpeed = instance:GetAttribute("CurrentMomentumBoost") or 0,
					Lure = instance:GetAttribute("CurrentMomentumBoost") or 0,
					Resilience = instance:GetAttribute("CurrentMomentumBoost") or 0
				}
			end
		},
		Vicious = {
			Description = "Increases Disturbance by +<$Disturbance$>, & increases Progress Speed by <$ProgressSpeed$>%",
			Color = Color3.fromRGB(255, 103, 76),
			StrokeColor = Color3.fromRGB(71, 29, 21),
			Display = "Vicious",
			Disturbance = 1,
			ProgressSpeed = 10,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Overclocked = {
			Description = "Increases Progress Speed by <$ForcedProgressSpeed$>% for any fish",
			Color = Color3.fromRGB(0, 255, 204),
			StrokeColor = Color3.fromRGB(11, 35, 28),
			Display = "Overclocked",
			ForcedProgressSpeed = 5,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Tenacity = {
			Description = "Increases Progress Speed by 20% for every reel snapped in a row",
			Color = Color3.fromRGB(255, 248, 171),
			StrokeColor = Color3.fromRGB(71, 70, 54),
			Display = "Tenacity",
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true,
			FishingPassives = {
				TenacityEnchant = {
					AttributeName = "TenacityBoost",
					BoostPerStack = 20,
					MaxBoost = 1e999
				}
			},
			ConditionalBoosts = function(_, instance)
				return {
					ProgressSpeed = instance:GetAttribute("TenacityBoost")
				}
			end
		},
		Tryhard = {
			Description = "Increases Progress Speed by <$ProgressSpeed$>%, Increases Strength by <$Strength$>kg, & decreases Control by <$Control$>",
			Color = Color3.fromRGB(255, 0, 0),
			StrokeColor = Color3.fromRGB(49, 35, 35),
			Display = "Tryhard",
			Control = -0.1,
			ProgressSpeed = 30,
			Strength = 50000,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Wise = {
			Description = "<$XpMultiply$>× XP after catching a fish",
			Color = Color3.fromRGB(200, 105, 255),
			StrokeColor = Color3.fromRGB(42, 36, 49),
			Display = "Wise",
			XpMultiply = 1.2,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Cryogenic = {
			Description = "<$ClientFishingPassives.Cryogenic.FreezeChance$>% chance to fully freeze a lured fish",
			Color = Color3.fromRGB(148, 235, 255),
			StrokeColor = Color3.fromRGB(21, 43, 49),
			Display = "Cryogenic",
			ClientFishingPassives = {
				Cryogenic = {
					AttemptDelay = 1,
					FreezeChance = 20,
					FreezeDuration = 1e999
				}
			},
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		["Sea Prince"] = {
			Description = "Makes fish <$WeightBoost$>% bigger",
			Color = Color3.fromRGB(84, 118, 211),
			StrokeColor = Color3.fromRGB(18, 23, 35),
			Display = "Sea Prince",
			WeightBoost = 15,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Glittered = {
			Description = "Increases Shiny & Sparkling chances by <$ShinyChance$>%",
			Color = Color3.fromRGB(255, 241, 160),
			StrokeColor = Color3.fromRGB(42, 42, 29),
			Display = "Glittered",
			ShinyChance = 3,
			SparklingChance = 3,
			Secondary = true,
			RelicGroup = "Cosmic",
			CanSelectFromAdmin = true
		},
		Weak = {
			Description = "Decreased Strength by <$StrengthPercent$>%",
			Color = Color3.fromRGB(134, 134, 134),
			StrokeColor = Color3.fromRGB(9, 9, 9),
			Display = "Weak",
			StrengthPercent = -10,
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		Putrid = {
			Description = "Decreased Luck by <$Luck$>%",
			Color = Color3.fromRGB(67, 88, 49),
			StrokeColor = Color3.fromRGB(9, 12, 7),
			Display = "Putrid",
			Luck = -10,
			Mutations = {
				{
					Name = "Putrid",
					Chance = 2
				}
			},
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		["Pharaohs Curse"] = {
			Description = "Caught fish have a <$Mutations.1.Chance$>% chance to be <$Mutations.1.Name$>",
			Color = Color3.fromRGB(156, 139, 105),
			StrokeColor = Color3.fromRGB(40, 36, 27),
			Display = "Pharaohs Curse",
			Mutations = {
				{
					Name = "Sandy",
					Chance = 25
				}
			},
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		Wobbly = {
			Description = "Decreases Control by <$Control$>",
			Color = Color3.fromRGB(86, 91, 112),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Wobbly",
			Control = -0.05,
			RelicGroup = "Twisted",
			CanSelectFromAdmin = true
		},
		Restricted = {
			Description = "Can only be used under specific conditions until relevant quest(s) are completed",
			Color = Color3.fromRGB(255, 28, 62),
			StrokeColor = Color3.fromRGB(53, 9, 18),
			Display = "Restricted",
			FishingPassives = {
				Restricted = {
					["Pinion's Aria"] = {
						AllowedZones = {
							"Crystal Cove",
							"Forsaken Veil - Scylla",
							"Megalodon Default",
							"Megalodon Ancient",
							"The Sanctum Hunt",
							"The Sanctum Profane Hunt",
							"Skeletal Leviathan Hunt",
							"Colossal Ethereal Dragon",
							"Colossal Blue Dragon",
							"Colossal Ancient Dragon"
						},
						BlockMessage = "Your Pinion's Aria can only fish at Crystal Cove and certain Hunts. Complete the Songstress' quests to unlock it fully!"
					},
					Remembrance = {
						AllowedZones = { "Living Garden" },
						BlockMessage = "Your Remembrance can only catch fish at the Living Garden while Restricted. Complete Luneth's quests to unlock it fully!",
						AllowMutations = true
					},
					Castbound = {
						AllowedZones = { "Shimmer" },
						BlockMessage = "Your Castbound can only fish in Shimmer while Restricted. Complete the Guide's quests to unlock it fully!",
						AllowMutations = false
					},
					Lullaby = {
						AllowHunts = true,
						BlockMessage = "Your Lullaby can only catch fish in Hunts while Restricted. Complete the \"Encore\" quest to unlock it fully!"
					},
					Acidgrinder = {
						AllowedZones = { "Brine Storm", "Brine Pool Water" },
						BlockMessage = "Your Acidgrinder can only fish in the Brine Pool while Restricted. Complete Axel's quests to unlock it fully!",
						AllowMutations = true
					},
					Noiseform = {
						AllowedZones = { "Glitched Pool" },
						BlockMessage = "This rod is Restricted, and can only be used under the colorless rainbow.",
						AllowMutations = true
					},
					["Starshell Rod"] = {
						AllowedZones = { "Heart of the Island" },
						BlockMessage = "This rod is Restricted, and can only be used in the Heart of the Island.",
						AllowMutations = true,
						AllowShiny = true,
						AllowSparkling = true
					},
					["Halibut Harpoon"] = {
						AllowedZones = { "Roslit Bay" },
						AllowMutations = true,
						RemoveMutations = { "Bathyal", "Thalassic", "Hadal" },
						BlockMessage = "This rod is Restricted, and can only be used in the Pufferfish abundance at Roslit Bay.",
						QuestPatches = {
							HalibutHarpoon5 = {
								RemoveMutations = apply_op.DELETE
							}
						}
					},
					["Stellarwave Melody"] = {
						AllowedZones = { "Isonade" },
						BlockMessage = "Your Stellarwave Melody can only fish in Strange Whirlpools until The Final Convergence has been completed.",
						AllowMutations = true,
						AllowSparkling = true
					}
				}
			},
			RelicGroup = "None",
			CanSelectFromAdmin = false
		},
		Beached = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases Progress Speed by <$ProgressSpeed$>%, & caught fish have a <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to be duplicated & <$FishingPassives.Generic_DuplicateFish.DuplicateMutation$>",
			Color = Color3.fromRGB(255, 213, 130),
			StrokeColor = Color3.fromRGB(90, 68, 52),
			Display = "Beached",
			ProgressSpeed = 10,
			Mutations = {
				{
					Name = "Beached",
					Chance = 10
				}
			},
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 10,
					DuplicateMutation = "Sandy",
					PassiveBlockLevel = 3
				}
			},
			Secondary = true,
			RelicGroup = "Beached",
			CanSelectFromAdmin = false
		},
		Tropical = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, rod has a high chance to lightly stab fish while reeling, & increases Forced Progress Speed by <$ForcedProgressSpeed$>%",
			Color = Color3.fromRGB(90, 220, 60),
			StrokeColor = Color3.fromRGB(43, 103, 28),
			ForceStroke = true,
			Display = "Tropical",
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 35,
					SlashDamage = 7,
					StunTime = 0.4,
					SourceType = "Enchant",
					SourceName = "Tropical",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(90, 220, 60),
					GradientColor = Color3.fromRGB(90, 220, 60)
				}
			},
			ForcedProgressSpeed = 10,
			Mutations = {
				{
					Name = "Tropical",
					Chance = 10
				}
			},
			RelicGroup = "Tropical",
			CanSelectFromAdmin = false
		},
		Paradise = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, increases fish size by <$WeightBoost$>%, & increases Luck by <$Luck$>%",
			Color = Color3.fromRGB(255, 133, 176),
			StrokeColor = Color3.fromRGB(159, 88, 75),
			Display = "Paradise",
			WeightBoost = 40,
			Luck = 60,
			Mutations = {
				{
					Name = "Paradise",
					Chance = 10
				}
			},
			RelicGroup = "Paradise",
			CanSelectFromAdmin = false
		},
		["Steady Crown"] = {
			Description = "Increases Resilience by +<$Resilience$>%, Control by +<$Control$>, and Progress Speed by +<$ProgressSpeed$>%",
			Color = Color3.fromRGB(229, 207, 191),
			ColorGradient = ColorSequence.new(Color3.fromRGB(229, 195, 184), Color3.fromRGB(255, 249, 210)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Steady Crown",
			Resilience = 25,
			Control = 0.1,
			ProgressSpeed = 25,
			Keeperbound = true,
			RelicGroup = "KeeperEnchant",
			CanSelectFromAdmin = false
		},
		["Stonewake Crown"] = {
			Description = "Increases Resilience by +<$Resilience$>%, Fish Weight by +<$WeightBoost$>%, and stops fish movement frequently",
			Color = Color3.fromRGB(170, 170, 170),
			ColorGradient = ColorSequence.new(Color3.fromRGB(153, 153, 153), Color3.fromRGB(211, 206, 174)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Stonewake Crown",
			Resilience = 35,
			WeightBoost = 20,
			Keeperbound = true,
			RelicGroup = "KeeperEnchant",
			CanSelectFromAdmin = false,
			ClientFishingPassives = {
				Chronos = {
					FreezeChance = 100,
					FreezeCooldown = 4,
					FreezeDuration = 1
				}
			}
		},
		["Glimmering Crown"] = {
			Description = "Increases Shiny & Sparkling chance by +<$ShinyChance$>%, and all Mutation chances by <$MutationChanceBoost$>%",
			Color = Color3.fromRGB(255, 241, 160),
			ColorGradient = ColorSequence.new(Color3.fromRGB(255, 202, 225), Color3.fromRGB(255, 241, 160)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Glimmering Crown",
			ShinyChance = 10,
			SparklingChance = 10,
			MutationChanceBoost = 20,
			Keeperbound = true,
			RelicGroup = "KeeperEnchant",
			CanSelectFromAdmin = false
		},
		["Immortal Might"] = {
			Description = "Increases Luck by +<$Luck$>%, Lure Speed by +<$Lure$>%, and Progress Speed by +<$ProgressSpeed$>%",
			Color = Color3.fromRGB(255, 180, 181),
			ColorGradient = ColorSequence.new(Color3.fromRGB(229, 195, 184), Color3.fromRGB(255, 180, 181)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Immortal Might",
			Luck = 90,
			Lure = 30,
			ProgressSpeed = 35,
			Keeperbound = true,
			RelicGroup = "KeeperExalted",
			CanSelectFromAdmin = false
		},
		["Magnitude Might"] = {
			Description = "Increases Fish Weight by +<$WeightBoost$>%, Control by +<$Control$>, and Resilience by +<$Resilience$>%",
			Color = Color3.fromRGB(255, 168, 125),
			ColorGradient = ColorSequence.new(Color3.fromRGB(255, 168, 125), Color3.fromRGB(203, 143, 255)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Magnitude Might",
			WeightBoost = 25,
			Control = 0.25,
			Resilience = 35,
			Keeperbound = true,
			RelicGroup = "KeeperExalted",
			CanSelectFromAdmin = false
		},
		["Swift Might"] = {
			Description = "Increases Lure Speed by +<$Lure$>%, Progress Speed by +<$ProgressSpeed$>%, and Forced Progress Speed by +<$ForcedProgressSpeed$>%",
			Color = Color3.fromRGB(170, 188, 255),
			ColorGradient = ColorSequence.new(Color3.fromRGB(170, 188, 255), Color3.fromRGB(203, 143, 255)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Swift Might",
			Lure = 55,
			ProgressSpeed = 50,
			ForcedProgressSpeed = 10,
			Keeperbound = true,
			RelicGroup = "KeeperExalted",
			CanSelectFromAdmin = false
		},
		["Menacing Spirit"] = {
			Description = "Increases Disturbance by +<$Disturbance$>, Progress Speed by +<$ProgressSpeed$>%, and frequently Slashes",
			Color = Color3.fromRGB(255, 116, 118),
			ColorGradient = ColorSequence.new(Color3.fromRGB(255, 171, 75), Color3.fromRGB(255, 116, 118)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Menacing Spirit",
			Disturbance = 7,
			ProgressSpeed = 20,
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "FishMove",
					SlashChance = 30,
					SlashDamage = 6,
					StunTime = 0.35,
					SourceType = "enchant",
					SourceName = "Menacing Might",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(255, 116, 118),
					GradientColor = Color3.fromRGB(255, 116, 118)
				}
			},
			ConditionalBoosts = function(p, _, value: number?)
				p.ClientFishingPassives.Generic_Slashes.SlashChance = 30 * (value or 1)
				p.ClientFishingPassives.Generic_Slashes.SlashDamage = 6 * (value or 1)
			end,
			Keeperbound = true,
			RelicGroup = "KeeperCosmic",
			CanSelectFromAdmin = false
		},
		["Starforged Spirit"] = {
			Description = "Increases Resilience by +<$Resilience$>%, Forced Progress Speed by +<$ForcedProgressSpeed$>%, and Fish Weight by +<$WeightBoost$>%",
			Color = Color3.fromRGB(194, 170, 229),
			ColorGradient = ColorSequence.new(Color3.fromRGB(194, 170, 229), Color3.fromRGB(255, 180, 181)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Starforged Spirit",
			Resilience = 15,
			ForcedProgressSpeed = 5,
			WeightBoost = 65,
			Keeperbound = true,
			RelicGroup = "KeeperCosmic",
			CanSelectFromAdmin = false
		},
		["Propensity Spirit"] = {
			Description = "<$ClientFishingPassives.Cryogenic.FreezeChance$>% to freeze a lured fish, <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to duplicate caught fish with the <$FishingPassives.Generic_DuplicateFish.DuplicateMutation$> mutation, and periodic slashes",
			Color = Color3.fromRGB(255, 147, 181),
			ColorGradient = ColorSequence.new(Color3.fromRGB(255, 147, 181), Color3.fromRGB(203, 143, 255)),
			StrokeColor = Color3.fromRGB(20, 21, 24),
			Display = "Propensity Spirit",
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 15,
					DuplicateMutation = "Sovereign",
					PassiveBlockLevel = 3
				}
			},
			ClientFishingPassives = {
				Cryogenic = {
					AttemptDelay = 1,
					FreezeChance = 15,
					FreezeDuration = 1e999
				},
				Generic_Slashes = {
					TriggerMode = "Interval",
					SlashChance = 35,
					SlashDamage = 5,
					SlashInterval = 0.8,
					StunTime = 0.2,
					SourceType = "enchant",
					SourceName = "Propensity Spirit",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(255, 147, 181),
					GradientColor = Color3.fromRGB(255, 147, 181)
				}
			},
			ConditionalBoosts = function(p, _, value: number?)
				p.ClientFishingPassives.Cryogenic.FreezeChance = 15 * (value or 1)
				p.ClientFishingPassives.Generic_Slashes.SlashChance = 35 * (value or 1)
				p.ClientFishingPassives.Generic_Slashes.SlashDamage = 5 * (value or 1)
				p.FishingPassives.Generic_DuplicateFish.DuplicateChance = 15 * (value or 1)
			end,
			Keeperbound = true,
			RelicGroup = "KeeperCosmic",
			CanSelectFromAdmin = false
		},
		Sanctified = {
			Description = "Increases Progress Speed by <$ProgressSpeed$>% and True Progress Speed by <$TrueProgressSpeed$>%",
			Color = Color3.fromRGB(0, 37, 83),
			StrokeColor = Color3.fromRGB(114, 201, 255),
			ForceStroke = true,
			Display = "Sanctified",
			ProgressSpeed = 10,
			TrueProgressSpeed = 10,
			KeeperboundAffix = true,
			RelicGroup = "SongOfTheDeep",
			CanSelectFromAdmin = false
		},
		Unshakeable = {
			Description = "Grants infinite Strength and +<$Durability$> Durability",
			Color = Color3.fromRGB(35, 13, 3),
			StrokeColor = Color3.fromRGB(255, 98, 25),
			ForceStroke = true,
			Display = "Unshakeable",
			Strength = 1e999,
			Durability = 200,
			KeeperboundAffix = true,
			RelicGroup = "Invincible",
			CanSelectFromAdmin = false
		},
		Sifting = {
			Description = "Grants infinite Strength and allows fishing in Drylands sand",
			Color = Color3.fromRGB(35, 30, 25),
			StrokeColor = Color3.fromRGB(255, 227, 170),
			ForceStroke = true,
			Display = "Sifting",
			Strength = 1e999,
			KeeperboundAffix = true,
			RelicGroup = "Dune",
			CanSelectFromAdmin = false
		},
		Twisted = {
			Description = "Increases Progress Speed by +<$ProgressSpeed$>%, but reduces Control by <$Control$>",
			Color = Color3.fromRGB(30, 0, 76),
			StrokeColor = Color3.fromRGB(151, 119, 255),
			ForceStroke = true,
			Display = "Twisted",
			Control = -0.1,
			ProgressSpeed = 30,
			KeeperboundAffix = true,
			RelicGroup = "Twisted",
			CanSelectFromAdmin = false
		},
		["Bygone Spooky"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$Control$> Control",
			Color = Color3.fromRGB(48, 33, 18),
			StrokeColor = Color3.fromRGB(255, 177, 98),
			ForceStroke = true,
			Display = "Spooky",
			Control = 0.05,
			Mutations = {
				{
					Name = "Spooky",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Spooky",
			CanSelectFromAdmin = false
		},
		["Bygone Frightful"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$ProgressSpeed$>% Progress Speed, and <$Resilience$> Resilience",
			Color = Color3.fromRGB(44, 37, 50),
			StrokeColor = Color3.fromRGB(163, 139, 220),
			ForceStroke = true,
			Display = "Frightful",
			ProgressSpeed = 20,
			Resilience = -10,
			Mutations = {
				{
					Name = "Frightful",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Frightful",
			CanSelectFromAdmin = false
		},
		["Bygone Eerie"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$ProgressSpeed$>% Progress Speed, +<$WeightBoost$>% Fish Weight",
			Color = Color3.fromRGB(19, 59, 29),
			StrokeColor = Color3.fromRGB(102, 255, 138),
			ForceStroke = true,
			Display = "Eerie",
			ProgressSpeed = 5,
			WeightBoost = 5,
			Mutations = {
				{
					Name = "Eerie",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Eerie",
			CanSelectFromAdmin = false
		},
		["Bygone Festive"] = {
			Description = "10% chance for <$Mutations.1.Name$>, <$Mutations.2.Name$>, or <$Mutations.3.Name$> mutation; +<$Lure$>% Lure Speed, +<$Luck$>% Luck, and +<$WeightBoost$>% Fish Weight",
			Color = Color3.fromRGB(42, 10, 10),
			StrokeColor = Color3.fromRGB(255, 147, 147),
			ForceStroke = true,
			Display = "Festive",
			Lure = 10,
			Luck = 10,
			WeightBoost = 5,
			Mutations = {
				{
					Name = "Merry",
					Chance = 3.3333333333333335
				},
				{
					Name = "Peppermint",
					Chance = 3.3333333333333335
				},
				{
					Name = "Gingerbread",
					Chance = 3.3333333333333335
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Festive",
			CanSelectFromAdmin = false
		},
		["Bygone Santa"] = {
			Description = "10% chance for <$Mutations.1.Name$>, <$Mutations.2.Name$>, <$Mutations.3.Name$>, <$Mutations.4.Name$>, or <$Mutations.5.Name$> mutation; +<$WeightBoost$>% Fish Weight, and +<$ProgressSpeed$>% Progress Speed",
			Color = Color3.fromRGB(42, 10, 10),
			StrokeColor = Color3.fromRGB(231, 0, 0),
			ForceStroke = true,
			Display = "Santa",
			WeightBoost = 10,
			ProgressSpeed = 15,
			Mutations = {
				{
					Name = "Santa",
					Chance = 2
				},
				{
					Name = "Jingle Bell",
					Chance = 2
				},
				{
					Name = "Merry",
					Chance = 2
				},
				{
					Name = "Peppermint",
					Chance = 2
				},
				{
					Name = "Gingerbread",
					Chance = 2
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Santa",
			CanSelectFromAdmin = false
		},
		["Bygone Cupid"] = {
			Description = "10% chance for <$Mutations.1.Name$> mutation, +<$Lure$>% Lure Speed, and +<$ProgressSpeed$>% Progress Speed",
			Color = Color3.fromRGB(45, 5, 43),
			StrokeColor = Color3.fromRGB(226, 175, 231),
			ForceStroke = true,
			Display = "Cupid",
			Lure = 5,
			ProgressSpeed = 5,
			Mutations = {
				{
					Name = "Sweet",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Cupid",
			CanSelectFromAdmin = false
		},
		["Bygone Valentine's"] = {
			Description = "10% chance for <$Mutations.1.Name$>, <$Mutations.2.Name$>, or <$Mutations.3.Name$> mutation; +<$ProgressSpeed$>% Progress Speed, +<$Resilience$>% Resilience",
			Color = Color3.fromRGB(45, 23, 36),
			StrokeColor = Color3.fromRGB(255, 193, 226),
			ForceStroke = true,
			Display = "Valentine's",
			ProgressSpeed = 15,
			Resilience = 5,
			Mutations = {
				{
					Name = "Sweet",
					Chance = 3.3333333333333335
				},
				{
					Name = "Lovely",
					Chance = 3.3333333333333335
				},
				{
					Name = "Candy",
					Chance = 3.3333333333333335
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Valentine",
			CanSelectFromAdmin = false
		},
		["Bygone Beached"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$ProgressSpeed$>% Progress Speed",
			Color = Color3.fromRGB(59, 44, 34),
			StrokeColor = Color3.fromRGB(255, 213, 130),
			ForceStroke = true,
			Display = "Beached",
			ProgressSpeed = 10,
			Mutations = {
				{
					Name = "Beached",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Beached",
			CanSelectFromAdmin = false
		},
		["Bygone Tropical"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$ForcedProgressSpeed$>% Forced Progress Speed",
			Color = Color3.fromRGB(22, 52, 14),
			StrokeColor = Color3.fromRGB(90, 220, 60),
			ForceStroke = true,
			Display = "Tropical",
			ForcedProgressSpeed = 5,
			Mutations = {
				{
					Name = "Tropical",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Tropical",
			CanSelectFromAdmin = false
		},
		["Bygone Paradise"] = {
			Description = "<$Mutations.1.Chance$>% chance for <$Mutations.1.Name$> mutation, +<$Luck$>% Luck, and +<$WeightBoost$>% Fish Weight",
			Color = Color3.fromRGB(70, 39, 33),
			StrokeColor = Color3.fromRGB(255, 133, 176),
			ForceStroke = true,
			Display = "Paradise",
			Luck = 15,
			WeightBoost = 5,
			Mutations = {
				{
					Name = "Paradise",
					Chance = 10
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Paradise",
			CanSelectFromAdmin = false
		},
		["Crested Affix"] = {
			Description = "Fish are now slightly slowed",
			Color = Color3.fromRGB(49, 30, 57),
			StrokeColor = Color3.fromRGB(255, 188, 112),
			ForceStroke = true,
			Display = "Crested",
			ClientFishingPassives = {
				Crested = {
					FishSpeedMultiplier = 0.85
				}
			},
			KeeperboundAffix = true,
			RelicGroup = "Crested",
			CanSelectFromAdmin = false
		},
		Empyrean = {
			Description = "+10% Forced, +10% True, +30% Normal Progress Speed, <$FishingPassives.Generic_DuplicateFish.DuplicateChance$>% chance to dupe with <$FishingPassives.Generic_DuplicateFish.DuplicateMutation$> mutation, and Slashes with progressing power",
			Color = Color3.fromRGB(156, 220, 255),
			StrokeColor = Color3.fromRGB(112, 131, 153),
			Display = "Empyrean",
			FishingPassives = {
				Generic_DuplicateFish = {
					DuplicateChance = 15,
					DuplicateMutation = "Empyrean",
					PassiveBlockLevel = 3
				}
			},
			ClientFishingPassives = {
				Generic_Slashes = {
					TriggerMode = "Interval",
					SlashChance = 30,
					SlashInterval = 0.45,
					SlashDamage = 3,
					ProgressScaling = {
						Reference = 12,
						Power = 1.5,
						Min = 0.25,
						Max = 3,
						Smoothing = 0.4
					},
					SourceType = "enchant",
					SourceName = "Peppermint",
					SoundName = "stabbystab",
					IconName = "Default",
					IconColor = Color3.fromRGB(255, 0, 0),
					GradientColor = Color3.fromRGB(255, 0, 0)
				}
			},
			ProgressSpeed = 30,
			ForcedProgressSpeed = 10,
			TrueProgressSpeed = 10,
			RelicGroup = "Empyrean",
			CanSelectFromAdmin = false
		},
		Crested = {
			Description = "Fish are now slowed",
			Color = Color3.fromRGB(255, 188, 112),
			StrokeColor = Color3.fromRGB(114, 72, 132),
			Display = "Crested",
			ClientFishingPassives = {
				Crested = {
					FishSpeedMultiplier = 0.7,
					AntiStunFishSpeedMultiplier = 0.85
				}
			},
			Secondary = true,
			RelicGroup = "Crested",
			CanSelectFromAdmin = true
		}
	}
}

function Enchants.GetStatBoostsForPlayer(_, p, p2: string?)
	local newFormat = module2.fetchNewFormat(p)

	if not newFormat then
		return {}
	end

	local v = p2 or module2.readLegacyPathValue(p, { "Stats", "rod" })
	local rod = newFormat.Rods[v]

	if not rod then
		return {}
	end

	if rod.keeperboundActive and rod.keeperboundEnchant then
		local module4 = require("../../SharedKeeperEnchant")
		local powerLevelMultiplier = module4.GetPowerLevelMultiplier(p, v)
		local copy = module3.copy(Enchants:GetCurrentBoosts(rod.keeperboundEnchant, p, powerLevelMultiplier), true)

		if not rod.keeperboundAffixes then
			return copy
		end

		for _, keeperboundAffix in rod.keeperboundAffixes do
			for k, v2 in Enchants:GetCurrentBoosts(keeperboundAffix, p, powerLevelMultiplier) do
				if typeof(v2) == "number" then
					copy[k] = (copy[k] or 0) + v2
				end
			end
		end

		return copy
	else
		local copy = module3.copy(Enchants:GetCurrentBoosts(rod.enchant, p), true)

		if rod.secondaryEnchant then
			for k, v2 in Enchants:GetCurrentBoosts(rod.secondaryEnchant, p) do
				if typeof(v2) == "number" then
					copy[k] = (copy[k] or 0) + v2
				end
			end
		end

		return copy
	end
end

module.extend(Enchants, {
	Enchants = Enchants.Enchants
})
return Enchants