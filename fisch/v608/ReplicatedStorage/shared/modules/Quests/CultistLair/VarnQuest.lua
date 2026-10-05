return {
	Varn = {
		DisplayName = "Cultist Lair: Varn",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Varn",
		NavigationTargets = {
			{
				Zone = "Passage of Oaths",
				Tags = { "Varn" },
				AllComplete = true
			}
		},
		Description = "Find the Notes around the Lair",
		CompletedDescription = "Talk to Varn to receive your reward!",
		List = {
			{
				"DataInstanceValue",
				"Cache.VarnNotesCount",
				9,
				string.format("Find %d notes around the Lair", 9)
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Varn's Amulet Fragment</b>" }
		}
	}
}