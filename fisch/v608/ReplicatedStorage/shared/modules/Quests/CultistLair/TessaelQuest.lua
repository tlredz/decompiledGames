return {
	Tessael = {
		DisplayName = "Cultist Lair: Tessael",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(209, 139, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "Tessael",
		NavigationTargets = {
			{
				Zone = "The Sanctum",
				Tags = { "Tessael" }
			}
		},
		Description = "Bring Tessael something special",
		CompletedDescription = "",
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.CursedTouchFish",
				true,
				"???"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Lucid Reel",
				{},
				1
			}
		}
	}
}