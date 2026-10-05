return {
	Sythra = {
		DisplayName = "Cultist Lair: Sythra",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Sythra",
		NavigationTargets = {
			{
				Zone = "Passage of Oaths",
				Tags = { "Sythra" },
				AllComplete = true
			}
		},
		Description = "Re-ignite lanterns around the Lair.",
		CompletedDescription = "Talk to Sythra to receive your reward!",
		List = {
			{
				"DataInstanceValue",
				"Cache.SythraLanternsCount",
				10,
				string.format("Relight %d lanterns", 10)
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Sythra's Amulet Fragment</b>" }
		}
	}
}