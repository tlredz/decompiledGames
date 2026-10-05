return {
	Maelira = {
		DisplayName = "Cultist Lair: Maelira",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Maelira",
		NavigationTargets = {
			{
				Zone = "Cultist Lair",
				Tags = { "Maelira" },
				AllComplete = true
			}
		},
		Description = "Catch each native fish from the Cultist Lair.",
		CompletedDescription = "Talk to Maelira to receive your reward!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Mexican Tetra" }
			},
			{
				"CatchFishAny",
				1,
				{ "Abyssal Slickhead" }
			},
			{
				"CatchFishAny",
				1,
				{ "Cave Loach" }
			},
			{
				"CatchFishAny",
				1,
				{ "Scaly Dragonfish" }
			},
			{
				"CatchFishAny",
				1,
				{ "Sinocyclocheilus" }
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Maelira's Amulet Fragment</b>" }
		}
	}
}