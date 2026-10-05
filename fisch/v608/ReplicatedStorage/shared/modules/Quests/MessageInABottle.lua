return {
	MessageInABottle = {
		DisplayName = "Message In a Bottle",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		NavigationTargets = {
			{
				Zone = "Roslit Bay",
				Tags = { "WhiteCrate" }
			}
		},
		Description = "There's a water-damaged note inside… coordinates and a scribbled phrase.",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.MessageInABottleCrate",
				true,
				"Travel to Roslit and pick up a crate"
			}
		},
		Rewards = {
			{ "Xp", 30000 },
			{ "Bait", "Kraken Tentacle", 15 }
		}
	}
}