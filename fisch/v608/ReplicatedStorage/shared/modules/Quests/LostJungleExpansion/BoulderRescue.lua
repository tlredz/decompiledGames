local dateTime = DateTime.fromUniversalTime(2026, 3, 7, 17)
return {
	LostJungle_GatherWorkers = {
		DisplayName = "Boulder Rescue: The Demolition Crew",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Major",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Oliver",
		NavigationTargets = {},
		QuestSeries = "Lost Jungle: Boulder Rescue",
		SeriesIndex = 1,
		Description = "Oliver's partner is trapped behind a boulder. Find the 5 workers at the Oil Rig and convince them to help.",
		CompletedDescription = "All workers have been gathered! Return to Oliver at the boulder site.",
		List = {
			{
				"DataInstanceValue",
				"Cache.LostJungle_WorkersGathered",
				5,
				"Gather all 5 workers from the Oil Rig"
			}
		},
		Rewards = {}
	},
	LostJungle_Samuel = {
		DisplayName = "Boulder Rescue: Samuel's Request",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Side",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Samuel",
		NavigationTargets = {},
		Description = "Samuel wants a Rubber Ducky to liven up his boring workdays.",
		CompletedDescription = "Bring the Rubber Ducky back to Samuel at the Oil Rig.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Rubber Ducky" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Title", "Boulder Basher" }
		}
	},
	LostJungle_Theo = {
		DisplayName = "Boulder Rescue: Theo's Request",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Side",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Theo",
		NavigationTargets = {},
		Description = "Theo misses playing music. Bring him a Pufferflute to rekindle his passion.",
		CompletedDescription = "Bring the Pufferflute back to Theo at the Oil Rig.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Pufferflute" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Bait", "Thorn Cluster", 50 }
		}
	},
	LostJungle_Elias = {
		DisplayName = "Boulder Rescue: Elias's Request",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Side",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Elias",
		NavigationTargets = {},
		Description = "Elias is fascinated by explosive design. Bring him a Sea Mine to study.",
		CompletedDescription = "Bring the Sea Mine back to Elias at the Oil Rig.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Sea Mine" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Flower Glider",
				{},
				1
			}
		}
	},
	LostJungle_Paul = {
		DisplayName = "Boulder Rescue: Paul's Request",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Side",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Paul",
		NavigationTargets = {},
		Description = "Paul misses his fishing days at Forsaken Shores. Bring him an Atlantean Captain's Goldfish.",
		CompletedDescription = "Bring the Atlantean Captain's Goldfish back to Paul at the Oil Rig.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Captain's Goldfish" },
				nil,
				{
					Mutation = "Atlantean",
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Dream Orchid",
				{},
				1
			}
		}
	},
	LostJungle_Hayden = {
		DisplayName = "Boulder Rescue: Hayden's Request",
		Icon = "rbxassetid://000000",
		IconColor = Color3.fromRGB(34, 139, 34),
		QuestType = "Side",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "LostJungle_Hayden",
		NavigationTargets = {},
		Description = "Hayden is starving from all the hard work. Bring him a Banana.",
		CompletedDescription = "Bring the Banana back to Hayden at the Oil Rig.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Banana" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Mysterious Seed",
				{},
				1
			}
		}
	}
}