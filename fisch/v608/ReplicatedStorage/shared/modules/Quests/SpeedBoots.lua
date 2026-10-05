return {
	DrCrookspineQuest = {
		DisplayName = "Dr. Crookspine Invention",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Crookspine",
		NavigationTargets = {
			{
				Tags = { "Crookspine" }
			}
		},
		Description = "Give Dr. Crookspine a hand with his new invention!",
		CompletedDescription = "...",
		List = {
			{
				"DataInstanceValue",
				"DrCrookspineQuest.QuestFinished",
				true,
				"Catch Boots, Rocket Fuel and a Speed Core."
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"GlimmerSuit Boots",
				nil,
				1
			}
		}
	}
}