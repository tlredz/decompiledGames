local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(97, 200, 255)
local v = {
	Zone = "Moosewood",
	Tags = { "WeeklyChallenger" },
	AllComplete = true
}
local rewards = {
	{ "CrewRating", 500 },
	{ "DisplayOnly", "Random Reward Spin ×1" }
}
return {
	WeeklyChallenge_CatchFish = {
		DisplayName = "Weekly Challenge: Catch Fish",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 250,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_ShinyFish = {
		DisplayName = "Weekly Challenge: Shiny Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 50,
				RequiredAttributes = {
					Shiny = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_SparklingFish = {
		DisplayName = "Weekly Challenge: Sparkling Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 50,
				RequiredAttributes = {
					Sparkling = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_ShinySparklingFish = {
		DisplayName = "Weekly Challenge: Pristine Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 10,
				RequiredAttributes = {
					Shiny = true,
					Sparkling = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_SpecificLocation = {
		HasCustomData = true,
		DisplayName = `Weekly Challenge: {module.var("TargetLocation")} Fishing`,
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 150,
				PlayerZones = module.var("TargetLocation"),
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_CageFish = {
		DisplayName = "Weekly Challenge: Crab Cage Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishCage({
				RequiredAmount = 150
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_SpearFish = {
		DisplayName = "Weekly Challenge: Spear Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishSpear({
				RequiredAmount = 25
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_TreasureChest = {
		DisplayName = "Weekly Challenge: Treasure Hunting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 25, "Open 25 Treasure Chests" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_AnglerQuest = {
		DisplayName = "Weekly Challenge: Angler Quests",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 15, "Complete 15 Angler Quests" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_ShadyAnglerQuest = {
		DisplayName = "Weekly Challenge: Shady Angler Quests",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = {
			{
				Zone = "The Shady Bazaar",
				Tags = { "ShadyAngler" },
				Objectives = { 1 }
			},
			v
		},
		List = {
			{ "Custom", 3, "Complete 3 Shady Angler Quests" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_SellFish = {
		DisplayName = "Weekly Challenge: Sell Fish",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 1000000, "Sell 1,000,000 C$ worth of fish" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_GainXp = {
		DisplayName = "Weekly Challenge: Experienced Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 250000, "Catch 250,000 XP worth of fish" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_PerfectCatch = {
		DisplayName = "Weekly Challenge: Perfect Catches",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 150,
				PerfectCatch = true,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_EnchantRod = {
		DisplayName = "Weekly Challenge: Enchanting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 25, "Enchant any Fishing Rod 25 times" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_SharkHunt = {
		DisplayName = "Weekly Challenge: Shark Hunting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Fish = { "Great Hammerhead Shark", "Great White Shark", "Whale Shark" },
				RequiredAmount = 20
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_ExoticCatch = {
		DisplayName = "Weekly Challenge: Exotic Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Raritites = { "Exotic" },
				RequiredAmount = 100
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_SecretCatch = {
		DisplayName = "Weekly Challenge: Secret Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Raritites = { "Secret" },
				RequiredAmount = 50
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_ApexCatch = {
		DisplayName = "Weekly Challenge: Apex Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Raritites = { "Apex" },
				RequiredAmount = 10
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_UseBait = {
		DisplayName = "Weekly Challenge: Use Bait",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 250, "Catch 250 fish using any bait" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_CatchFishWithRod = {
		HasCustomData = true,
		DisplayName = `Weekly Challenge: {module.var("TargetRod")} Fishing`,
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFish({
				Rods = module.var("TargetRod"),
				RequiredAmount = 150,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_CatchSpecificFish = {
		HasCustomData = true,
		DisplayName = `Weekly Challenge: Catch {module.var("TargetFish")}`,
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Fish = module.var("TargetFish"),
				RequiredAmount = module.var("TargetCount")
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_CatchSpecificMutation = {
		HasCustomData = true,
		DisplayName = "Weekly Challenge: Mutated Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAttributes = {
					Mutation = module.var("TargetMutation")
				},
				RequiredAmount = module.var("TargetCount"),
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	WeeklyChallenge_Gardening = {
		DisplayName = "Weekly Challenge: Gardening",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = {
			{
				Zone = "Living Garden",
				Tags = { "PlantableArea" },
				Objectives = { 1 }
			},
			v
		},
		List = {
			{ "Custom", 15, "Harvest 15 Lotuses at the Living Garden" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_Wisps = {
		DisplayName = "Weekly Challenge: Soul Harvesting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = {
			{
				Zone = "Hades' Underworld of Indefinite",
				Objectives = { 1 }
			},
			v
		},
		List = {
			{ "Custom", 50, "Obtain 50 Wisps or Dark Wisps" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_ShadyScrip = {
		DisplayName = "Weekly Challenge: Shady Dealings",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = {
			{
				Zone = "The Shady Bazaar",
				Objectives = { 1 }
			},
			v
		},
		List = {
			{ "Custom", 1000, "Earn 1,000 S$ at the Shady Bazaar" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_CatchStreak = {
		DisplayName = "Weekly Challenge: Catch Streak",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 100, "Catch 100 fish in a row without snapping a reel" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_MellaInfusion = {
		DisplayName = "Weekly Challenge: Please Mella I Need This",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = {
			{
				Zone = "Sunken Reliquary",
				Tags = { "Mella" },
				Objectives = { 1 }
			},
			v
		},
		List = {
			{ "Custom", 1, "Infuse any Fishing Rod with Mella" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_StarfallLoot = {
		DisplayName = "Weekly Challenge: Cosmic Treasure",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 20, "Loot 20 Fallen Stars during Starfall" }
		},
		Rewards = rewards
	},
	WeeklyChallenge_MeteorLoot = {
		DisplayName = "Weekly Challenge: Meteor Looting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 15, "Loot 15 Meteors" }
		},
		Rewards = rewards
	}
}