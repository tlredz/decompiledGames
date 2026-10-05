return {
	Marvin1 = {
		DisplayName = "A Snowy Favor",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Marvin",
		NavigationTargets = {
			{
				Zone = "Boreal Pines",
				Tags = { "Marvin" }
			}
		},
		Description = "Give 2 items to Marvin for him to craft something special",
		CompletedDescription = "",
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.ReturnMeg'sSpine",
				true,
				"???"
			},
			{
				"DataInstanceValue",
				"Cache.ReturnMeg'sFang",
				true,
				"???"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Winter Boots",
				nil,
				1
			},
			{ "Xp", 2500 }
		}
	}
}