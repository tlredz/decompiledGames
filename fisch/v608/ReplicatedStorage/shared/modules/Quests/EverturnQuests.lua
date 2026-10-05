return {
	Everturn_CatchUnique = {
		DisplayName = "Everturn Forest: Hidden Waters",
		Icon = "rbxassetid://",
		IconColor = Color3.fromRGB(60, 140, 80),
		QuestType = "Major",
		AcceptIndicatorTag = "Thalor",
		NavigationTargets = {
			{
				Zone = "Everturn Forest",
				Objectives = { 1 }
			},
			{
				Zone = "Everturn Forest",
				Tags = { "Thalor" },
				AllComplete = true
			}
		},
		QuestSeries = "Everturn Forest",
		SeriesIndex = 1,
		Description = "Catch 5 unique fish from the Everturn Forest bestiary.",
		CompletedDescription = "Return to Thalor Virewood in the Everturn Forest.",
		List = {
			{
				"DataInstanceValue",
				"Cache.Everturn_UniqueCatches",
				5,
				"Catch 5 unique Everturn fish"
			}
		},
		Rewards = {
			{ "Currency", "Coins", 4000 },
			{ "Xp", 8000 }
		}
	},
	Everturn_NightPerfect = {
		DisplayName = "Everturn Forest: Night Fisher",
		Icon = "rbxassetid://",
		IconColor = Color3.fromRGB(60, 140, 80),
		QuestType = "Major",
		AcceptIndicatorTag = "Thalor",
		NavigationTargets = {
			{
				Zone = "Everturn Forest",
				Objectives = { 1 }
			},
			{
				Zone = "Everturn Forest",
				Tags = { "Thalor" },
				AllComplete = true
			}
		},
		QuestSeries = "Everturn Forest",
		SeriesIndex = 2,
		Description = "Perfect Catch 5 fish at night in the Everturn Forest.",
		CompletedDescription = "Return to Thalor Virewood in the Everturn Forest.",
		Prerequisites = {
			QuestComplete = { "Everturn_CatchUnique" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Everturn_NightPerfectCatches",
				5,
				"Perfect Catch 5 fish at night in Everturn Forest"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Everturn Cloak",
				{},
				1
			}
		}
	},
	Everturn_RottingSturgeon = {
		DisplayName = "Everturn Forest: Spirit Seeker",
		Icon = "rbxassetid://",
		IconColor = Color3.fromRGB(60, 140, 80),
		QuestType = "Major",
		AcceptIndicatorTag = "Thalor",
		NavigationTargets = {
			{
				Zone = "Everturn Forest",
				Tags = { "Thalor" },
				AllComplete = true
			}
		},
		QuestSeries = "Everturn Forest",
		SeriesIndex = 3,
		Description = "Return a Rotting Sturgeon of any kind to Thalor Virewood.",
		CompletedDescription = "Return to Thalor Virewood in the Everturn Forest.",
		Prerequisites = {
			QuestComplete = { "Everturn_NightPerfect" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{
					"Glaciaseer Sturgeon",
					"Floraseer Sturgeon",
					"Solarseer Sturgeon",
					"Umbraleaf Sturgeon"
				},
				nil,
				{
					Mutation = "Rotting",
					Return = true
				}
			}
		},
		Rewards = {
			{ "Rod", "Spirit of the Forest" }
		}
	},
	Everturn_Oakling = {
		DisplayName = "Everturn Forest: The Lost Oakling",
		Icon = "rbxassetid://",
		IconColor = Color3.fromRGB(100, 80, 50),
		QuestType = "Side",
		AcceptIndicatorTag = "Brindle",
		NavigationTargets = {
			{
				Zone = "Everturn Forest",
				Objectives = { 1 }
			},
			{
				Zone = "Everturn Forest",
				Tags = { "Brindle" },
				AllComplete = true
			}
		},
		Description = "Catch an Oakling and return it to Brindle Oakshade.",
		CompletedDescription = "Return the Oakling to Brindle Oakshade in the Everturn Forest.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Oakling" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Lantern", "Oakling Pal" }
		}
	}
}