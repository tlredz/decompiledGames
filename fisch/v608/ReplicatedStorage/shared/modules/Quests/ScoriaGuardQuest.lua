return {
	["ScoriaGuard-1"] = {
		DisplayName = "Fragments & Pearls",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Scoria Guard",
		NavigationTargets = {},
		Description = "Mining the Fragments",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"ObtainItem",
				1,
				{ "Sulfur Fragment" }
			},
			{
				"ObtainItem",
				1,
				{ "Obsidian Fragment" }
			},
			{
				"ObtainItem",
				1,
				{ "Infernal Fragment" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 75000 },
			{ "Xp", 25000 }
		}
	}
}