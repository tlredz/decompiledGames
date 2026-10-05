return {
	HookedOnPride = {
		DisplayName = "Hooked On Pride",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		AcceptIndicatorTag = "Harris",
		NavigationTargets = {
			{
				Zone = "Grand Reef",
				Tags = { "Harris" }
			}
		},
		Description = "Find the fish Harris asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.BringFishToHarris",
				true,
				"Bring a Shiny \"Grand Reef Guardian\" to Harris"
			}
		},
		Rewards = {
			{ "Xp", 350000 }
		}
	}
}