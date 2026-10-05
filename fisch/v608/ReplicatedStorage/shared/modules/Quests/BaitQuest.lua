return {
	BaitQuest = {
		DisplayName = "Bait Quest",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		Description = "Catch 3 fish using shrimp bait",
		CompletedDescription = "Talk to the tackle shop owner to receive your reward!",
		List = {
			{
				"CatchFish",
				3,
				nil,
				nil,
				nil,
				nil,
				{ "Shrimp" }
			}
		},
		Rewards = {
			{ "Xp", 10000 }
		}
	}
}