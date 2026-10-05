return {
	DeadMansTale = {
		DisplayName = "Dead Mans Tale",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(85, 255, 127),
		QuestType = "Major",
		AcceptIndicatorTag = "DeadManJoe",
		NavigationTargets = {
			{
				Zone = "Grand Reef",
				Tags = { "Amulet" },
				Objectives = { 1 }
			},
			{
				Zone = "Forsaken Shores",
				Tags = { "DeadManJoe" },
				Objectives = { 2 }
			},
			{
				Zone = "Forsaken Shores",
				Tags = { "DeadManJoe" },
				AllComplete = true
			}
		},
		Description = "Find and explore the mysterious \"Oscar’s Locker\"",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.DeadMansTale1",
				true,
				"Find the amulet in Grand Reef"
			},
			{
				"DataInstanceValue",
				"Cache.DeadMansTale2",
				true,
				"Bring the amulet to the \"Dead Man Joe\" to get more information"
			}
		},
		Rewards = {
			{ "Xp", 10000 }
		}
	}
}