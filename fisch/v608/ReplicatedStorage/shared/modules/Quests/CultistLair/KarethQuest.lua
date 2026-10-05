return {
	Kareth = {
		DisplayName = "Cultist Lair: Kareth",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Kareth",
		NavigationTargets = {
			{
				Zone = "Hall of Whispers",
				Tags = { "Kareth" },
				AllComplete = true
			}
		},
		Description = "Inspect the lair’s shelves and cleanse the Corrupt books.",
		CompletedDescription = "Talk to Kareth to receive your reward!",
		List = {
			{
				"DataInstanceValue",
				"Cache.KarethBooksCount",
				8,
				"Cleanse the Corrupt books"
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Kareth's Amulet Fragment</b>" }
		}
	}
}