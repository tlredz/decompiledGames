return {
	MadChemist = {
		DisplayName = "Experimental Catalyst",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		AcceptIndicatorTag = "MadChemist",
		NavigationTargets = {
			{
				Zone = "Toxic Grove",
				Tags = { "MadChemist" },
				AllComplete = true
			}
		},
		Description = "You met a Mad Chemist in the Toxic Grove who seems to be on the verge of making a strange concoction...",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"ObtainItem",
				3,
				{ "Toxic Jellymass" }
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Prototype Noxious Catalyst",
				{},
				1
			}
		}
	}
}