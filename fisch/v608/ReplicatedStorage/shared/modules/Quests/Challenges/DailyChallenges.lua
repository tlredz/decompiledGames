local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 103, 123)
local v = {
	Zone = "Moosewood",
	Tags = { "DailyChallenger" },
	AllComplete = true
}
local rewards = {
	{ "CrewRating", 150 },
	{ "DisplayOnly", "Random Reward Spin ×1" }
}
return {
	DailyChallenge_CatchFish = {
		DisplayName = "Daily Challenge: Catch Fish",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 25,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_ShinyFish = {
		DisplayName = "Daily Challenge: Shiny Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 5,
				RequiredAttributes = {
					Shiny = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_SparklingFish = {
		DisplayName = "Daily Challenge: Sparkling Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 5,
				RequiredAttributes = {
					Sparkling = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_SpecificLocation = {
		HasCustomData = true,
		DisplayName = `Daily Challenge: {module.var("TargetLocation")} Fishing`,
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 15,
				PlayerZones = module.var("TargetLocation"),
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_CageFish = {
		DisplayName = "Daily Challenge: Crab Cage Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishCage({
				RequiredAmount = 15
			}) },
		Rewards = rewards
	},
	DailyChallenge_SpearFish = {
		DisplayName = "Daily Challenge: Spear Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishSpear({
				RequiredAmount = 10
			}) },
		Rewards = rewards
	},
	DailyChallenge_TreasureChest = {
		DisplayName = "Daily Challenge: Treasure Hunting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 1, "Open 1 Treasure Chest" }
		},
		Rewards = rewards
	},
	DailyChallenge_AnglerQuest = {
		DisplayName = "Daily Challenge: Angler Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 1, "Complete 1 Angler Quest" }
		},
		Rewards = rewards
	},
	DailyChallenge_SellFish = {
		DisplayName = "Daily Challenge: Sell Fish",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 100000, "Sell 100,000 C$ worth of fish" }
		},
		Rewards = rewards
	},
	DailyChallenge_GainXp = {
		DisplayName = "Daily Challenge: Experienced Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 10000, "Catch 10,000 XP worth of fish" }
		},
		Rewards = rewards
	},
	DailyChallenge_PerfectCatch = {
		DisplayName = "Daily Challenge: Perfect Catches",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				RequiredAmount = 15,
				PerfectCatch = true,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_EnchantRod = {
		DisplayName = "Daily Challenge: Enchanting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 3, "Enchant any Fishing Rod 3 times" }
		},
		Rewards = rewards
	},
	DailyChallenge_SharkHunt = {
		DisplayName = "Daily Challenge: Shark Hunting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Fish = { "Great Hammerhead Shark", "Great White Shark", "Whale Shark" },
				RequiredAmount = 1
			}) },
		Rewards = rewards
	},
	DailyChallenge_ExoticCatch = {
		DisplayName = "Daily Challenge: Exotic Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFishAny({
				Raritites = { "Exotic" },
				RequiredAmount = 3
			}) },
		Rewards = rewards
	},
	DailyChallenge_UseBait = {
		DisplayName = "Daily Challenge: Use Bait",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 25, "Catch 25 fish using any bait" }
		},
		Rewards = rewards
	},
	DailyChallenge_CatchFishWithRod = {
		HasCustomData = true,
		DisplayName = `Daily Challenge: {module.var("TargetRod")} Fishing`,
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = { module.CatchFish({
				Rods = module.var("TargetRod"),
				RequiredAmount = 15,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	DailyChallenge_CatchSpecificMutation = {
		HasCustomData = true,
		DisplayName = "Daily Challenge: Mutated Catch",
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
	DailyChallenge_MeteorLoot = {
		DisplayName = "Daily Challenge: Meteor Looting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Challenge",
		NavigationTargets = { v },
		List = {
			{ "Custom", 1, "Loot 1 Meteor" }
		},
		Rewards = rewards
	}
}