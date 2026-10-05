local module = require("../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 232, 139)
local color2 = Color3.fromRGB(255, 232, 139)
local rewards = {
	{ "DisplayOnly", "Crew Rating" }
}
return {
	CrewGoal_CrewHaul = {
		DisplayName = "Crew Goal: Crew Haul",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 30,
		List = { module.CatchFishAny({
				RequiredAmount = 50,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_BigHaul = {
		DisplayName = "Crew Goal: Big Haul",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 35,
		List = { module.CatchFishAny({
				RequiredAmount = 100,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_BaitBlitz = {
		DisplayName = "Crew Goal: Bait Blitz",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 35,
		List = {
			{ "BaitUse", 50 }
		},
		Rewards = rewards
	},
	CrewGoal_CageCrew = {
		DisplayName = "Crew Goal: Cage Crew",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 40,
		List = { module.CatchFishCage({
				RequiredAmount = 50
			}) },
		Rewards = rewards
	},
	CrewGoal_SpearSquad = {
		DisplayName = "Crew Goal: Spear Squad",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 40,
		List = { module.CatchFishSpear({
				RequiredAmount = 10
			}) },
		Rewards = rewards
	},
	CrewGoal_PerfectForm = {
		DisplayName = "Crew Goal: Perfect Form",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		List = { module.CatchFishAny({
				RequiredAmount = 25,
				PerfectCatch = true,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_CatchStreak = {
		DisplayName = "Crew Goal: Catch Streak",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 40,
		StreakCatch = {
			Objective = 1
		},
		List = {
			{ "Custom", 50, "Catch 50 fish in a row without snapping a reel" }
		},
		Rewards = rewards
	},
	CrewGoal_ShinyHunt = {
		DisplayName = "Crew Goal: Shiny Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		List = { module.CatchFishAny({
				RequiredAmount = 5,
				RequiredAttributes = {
					Shiny = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_SparklingHunt = {
		DisplayName = "Crew Goal: Sparkling Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		List = { module.CatchFishAny({
				RequiredAmount = 5,
				RequiredAttributes = {
					Sparkling = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_PristineHunt = {
		DisplayName = "Crew Goal: Pristine Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.3,
			Min = 2
		},
		Rating = 50,
		List = { module.CatchFishAny({
				RequiredAmount = 3,
				RequiredAttributes = {
					Shiny = true,
					Sparkling = true
				},
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_ExoticHunt = {
		DisplayName = "Crew Goal: Exotic Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 45,
		List = { module.CatchFishAny({
				Raritites = { "Exotic" },
				RequiredAmount = 10,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_SecretHunt = {
		DisplayName = "Crew Goal: Secret Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.3,
			Min = 2
		},
		Rating = 60,
		List = { module.CatchFishAny({
				Raritites = { "Secret" },
				RequiredAmount = 3,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_ApexHunt = {
		DisplayName = "Crew Goal: Apex Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.25,
			Min = 2
		},
		Rating = 70,
		List = { module.CatchFishAny({
				Raritites = { "Apex" },
				RequiredAmount = 1,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_SharkHunt = {
		DisplayName = "Crew Goal: Shark Hunt",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		List = { module.CatchFishAny({
				Fish = { "Great Hammerhead Shark", "Great White Shark", "Whale Shark" },
				RequiredAmount = 3
			}) },
		Rewards = rewards
	},
	CrewGoal_AnglerRounds = {
		DisplayName = "Crew Goal: Angler Rounds",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 45,
		AnglerDistinct = {
			Objective = 1
		},
		List = {
			{ "Custom", 10, "Catch a fish for 10 different Anglers" }
		},
		Rewards = rewards
	},
	CrewGoal_AnglerJobs = {
		DisplayName = "Crew Goal: Angler Jobs",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		AnglerCount = {
			Objective = 1
		},
		List = {
			{ "Custom", 3, "Complete 3 Angler Quests" }
		},
		Rewards = rewards
	},
	CrewGoal_MarketDay = {
		DisplayName = "Crew Goal: Market Day",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 35,
		SellValue = {
			Objective = 1
		},
		List = {
			{ "Custom", 250000, "Sell 250,000 C$ worth of fish" }
		},
		Rewards = rewards
	},
	CrewGoal_ExperiencedFishing = {
		DisplayName = "Crew Goal: Experienced Fishing",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		XpCatch = {
			Objective = 1
		},
		List = {
			{ "Custom", 50000, "Catch 50,000 XP worth of fish" }
		},
		Rewards = rewards
	},
	CrewGoal_TreasureHunt = {
		DisplayName = "Crew Goal: Treasure Hunting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		TreasureOpen = {
			Objective = 1
		},
		List = {
			{ "Custom", 3, "Open 3 Treasure Chests" }
		},
		Rewards = rewards
	},
	CrewGoal_Enchanting = {
		DisplayName = "Crew Goal: Enchanting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		EnchantRod = {
			Objective = 1
		},
		List = {
			{ "Custom", 3, "Enchant any Fishing Rod 3 times" }
		},
		Rewards = rewards
	},
	CrewGoal_MutationMedley = {
		DisplayName = "Crew Goal: Mutation Medley",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		DistinctCatch = {
			Objective = 1,
			Kind = "Mutation"
		},
		List = {
			{ "Custom", 5, "Catch fish with 5 different Mutations" }
		},
		Rewards = rewards
	},
	CrewGoal_ExoticFrenzy = {
		DisplayName = "Crew Goal: Exotic Frenzy",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 55,
		List = { module.CatchFishAny({
				Raritites = { "Exotic" },
				RequiredAmount = 25,
				IgnoreSourceTypes = { "system" }
			}) },
		Rewards = rewards
	},
	CrewGoal_DailyChallenges = {
		DisplayName = "Crew Goal: Daily Challenges",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 45,
		DailyDone = {
			Objective = 1
		},
		List = {
			{ "Custom", 2, "Complete 2 Daily Challenges" }
		},
		Rewards = rewards
	},
	CrewGoal_ShadyJob = {
		DisplayName = "Crew Goal: Shady Job",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.3,
			Min = 2
		},
		Rating = 55,
		ShadyDone = {
			Objective = 1
		},
		List = {
			{ "Custom", 1, "Complete 1 Shady Angler Quest" }
		},
		Rewards = rewards
	},
	CrewGoal_TreasureTrove = {
		DisplayName = "Crew Goal: Treasure Trove",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 55,
		TreasureOpen = {
			Objective = 1
		},
		List = {
			{ "Custom", 5, "Open 5 Treasure Chests" }
		},
		Rewards = rewards
	},
	CrewGoal_MeteorLooting = {
		DisplayName = "Crew Goal: Meteor Looting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.3,
			Min = 2
		},
		Rating = 60,
		MeteorLoot = {
			Objective = 1
		},
		List = {
			{ "Custom", 3, "Loot 3 Meteors" }
		},
		Rewards = rewards
	},
	CrewGoal_CosmicTreasure = {
		DisplayName = "Crew Goal: Cosmic Treasure",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 55,
		StarLoot = {
			Objective = 1
		},
		List = {
			{ "Custom", 10, "Loot 10 Fallen Stars during Starfall" }
		},
		Rewards = rewards
	},
	CrewGoal_Gardening = {
		DisplayName = "Crew Goal: Gardening",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		SeedHarvest = {
			Objective = 1
		},
		List = {
			{ "Custom", 10, "Harvest 10 Lotuses at the Living Garden" }
		},
		Rewards = rewards
	},
	CrewGoal_SoulHarvesting = {
		DisplayName = "Crew Goal: Soul Harvesting",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		WispGain = {
			Objective = 1
		},
		List = {
			{ "Custom", 20, "Obtain 20 Wisps or Dark Wisps" }
		},
		Rewards = rewards
	},
	CrewGoal_ShadyDealings = {
		DisplayName = "Crew Goal: Shady Dealings",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 50,
		ScripGain = {
			Objective = 1
		},
		List = {
			{ "Custom", 250, "Earn 250 S$ at the Shady Bazaar" }
		},
		Rewards = rewards
	},
	CrewGoal_AppraisalSpree = {
		DisplayName = "Crew Goal: Appraisal Spree",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 35,
		List = {
			{ "AppraiseFish", 10 }
		},
		Rewards = rewards
	},
	CrewGoal_TotemPower = {
		DisplayName = "Crew Goal: Totem Power",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 45,
		List = {
			{ "TotemUse", 3 }
		},
		Rewards = rewards
	},
	CrewGoal_WorldTour = {
		DisplayName = "Crew Goal: World Tour",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		DistinctCatch = {
			Objective = 1,
			Kind = "Zone"
		},
		List = {
			{ "Custom", 5, "Catch fish at 5 different locations" }
		},
		Rewards = rewards
	},
	CrewGoal_RodRotation = {
		DisplayName = "Crew Goal: Rod Rotation",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.4,
			Min = 2
		},
		Rating = 45,
		DistinctCatch = {
			Objective = 1,
			Kind = "Rod"
		},
		List = {
			{ "Custom", 5, "Catch fish using 5 different Fishing Rods" }
		},
		Rewards = rewards
	},
	CrewGoal_RarityRun = {
		DisplayName = "Crew Goal: Rarity Run",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		DisplayColor = color2,
		QuestType = "Crew",
		NoAutoTrack = true,
		AutoComplete = true,
		IsRepeatable = true,
		Participation = {
			Fraction = 0.5,
			Min = 2
		},
		Rating = 40,
		DistinctCatch = {
			Objective = 1,
			Kind = "Rarity"
		},
		List = {
			{ "Custom", 5, "Catch fish of 5 different Rarities" }
		},
		Rewards = rewards
	}
}