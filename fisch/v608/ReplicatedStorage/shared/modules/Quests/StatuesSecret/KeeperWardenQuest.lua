local module = require("../../SimpleFetchQuests/lib")
return {
	Keeper_CheckOnMiners = {
		DisplayName = "Keepers Guidance: All Hands",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = { "Evelyn" },
				Objectives = { 1 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "Harper" },
				Objectives = { 2 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "Asher" },
				Objectives = { 3 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "Caleb" },
				Objectives = { 4 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "Colton" },
				Objectives = { 5 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "KeeperWarden" },
				AllComplete = true
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 1,
		Description = "The Keeper Warden wants you to make sure everyone affected by the breach is okay. Check on each of the miners.",
		CompletedDescription = "Everyone is safe. Return to the Keeper Warden.",
		List = {
			{
				"DataInstanceValue",
				"Cache.MinerWake_Evelyn",
				true,
				"Check on Evelyn"
			},
			{
				"DataInstanceValue",
				"Cache.MinerWake_Harper",
				true,
				"Check on Harper"
			},
			{
				"DataInstanceValue",
				"Cache.MinerWake_Asher",
				true,
				"Check on Asher"
			},
			{
				"DataInstanceValue",
				"Cache.MinerWake_Caleb",
				true,
				"Check on Caleb"
			},
			{
				"DataInstanceValue",
				"Cache.MinerWake_Colton",
				true,
				"Check on Colton"
			}
		},
		Rewards = {
			{ "KeeperXp", 50 }
		}
	},
	Keeper_CrevicePower = {
		DisplayName = "Keepers Guidance: Power Burst",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = {},
				Objectives = { 1 }
			},
			{
				Zone = "Enchanted Crevice",
				Tags = { "Keeper Warden" },
				AllComplete = true
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 2,
		Description = "Catch 5 fish from the Enchanted Crevice. Each catch may build power towards the Keepers Altar.",
		CompletedDescription = "Return to the Keeper Warden.",
		Prerequisites = {
			QuestComplete = { "Keeper_CheckOnMiners" }
		},
		List = { module.CatchFishAny({
				RequiredAmount = 5,
				FishingZones = "Enchanted Crevice",
				ForNpc = "Keeper Warden"
			}) },
		Rewards = {
			{ "KeeperXp", 100 },
			{
				"ItemOrFish",
				"Sovereign Relic",
				{
					Weight = 75,
					Mutation = "Unsellable"
				},
				1
			}
		}
	},
	Keeper_FirstRitual = {
		DisplayName = "Keepers Guidance: First Ritual",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = { "Keeper Warden" },
				AllComplete = true
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 3,
		Description = "Complete a Keeper's Ritual at the Keepers Altar.",
		CompletedDescription = "Return to the Keeper Warden.",
		Prerequisites = {
			QuestComplete = { "Keeper_CrevicePower" },
			KeeperLevel = 1
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Keeper_FirstRitual",
				true,
				"Complete a Keeper's Ritual"
			}
		},
		Rewards = {
			{ "KeeperXp", 150 }
		}
	},
	Keeper_MultiPillar = {
		DisplayName = "Keepers Guidance: Greater Ritual",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = { "Keeper Warden" },
				AllComplete = true
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 4,
		Description = "Witness a Keeper's Weather, and enchant a rod using more than one pillar.",
		CompletedDescription = "Return to the Keeper Warden.",
		Prerequisites = {
			QuestComplete = { "Keeper_FirstRitual" },
			KeeperLevel = 2
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Keeper_WitnessWeather",
				true,
				"Witness any Keeper's Weather"
			},
			{
				"DataInstanceValue",
				"Cache.Keeper_MultiPillar",
				true,
				"Enchant a rod using more than 1 pillar"
			}
		},
		Rewards = {
			{ "KeeperXp", 150 }
		}
	},
	Keeper_Repower = {
		DisplayName = "Keepers Guidance: Restoration",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = { "Keeper Warden" },
				AllComplete = true
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 5,
		Description = "Restore power to a Keeperbound rod using any Relic at the Keepers Altar.",
		CompletedDescription = "Return to the Keeper Warden.",
		Prerequisites = {
			QuestComplete = { "Keeper_MultiPillar" },
			KeeperLevel = 3
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Keeper_Repower",
				true,
				"Repower a rod using any Relic"
			}
		},
		Rewards = {
			{ "KeeperXp", 150 }
		}
	},
	Keeper_SovereignSupply = {
		DisplayName = "Keepers Guidance: Sovereign Supply",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(94, 184, 255),
		QuestType = "Challenge",
		AutoNavigate = true,
		AcceptIndicatorTag = "KeeperWarden",
		NavigationTargets = {
			{
				Zone = "Enchanted Crevice",
				Tags = { "KeeperWarden" }
			}
		},
		QuestSeries = "Keepers Guidance",
		SeriesIndex = 6,
		Description = "Bring the Keeper Warden any Sovereign-mutated fish caught from a Sovereign Beam.",
		CompletedDescription = "Return to the Keeper Warden.",
		Prerequisites = {
			QuestComplete = { "Keeper_Repower" },
			KeeperLevel = 4
		},
		List = { module.CatchFishAny({
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Sovereign"
				}
			}) },
		Rewards = {
			{ "KeeperXp", 50 }
		}
	}
}