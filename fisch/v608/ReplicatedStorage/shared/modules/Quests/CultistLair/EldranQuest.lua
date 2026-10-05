return {
	Eldran = {
		DisplayName = "Cultist Lair: Eldran",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Eldran",
		NavigationTargets = {
			{
				Zone = "Cultist Lair",
				Tags = { "Eldran" },
				AllComplete = true
			}
		},
		Description = "Discover the Cult Markings around Terrapin.",
		CompletedDescription = "Talk to Eldran to receive your reward!",
		List = {
			{
				"DataInstanceValue",
				"Cache.EldranMarkingsCount",
				3,
				string.format("Find %d cult markings", 3)
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Eldran's Amulet Fragment</b>" }
		}
	}
}