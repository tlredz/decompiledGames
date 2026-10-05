local TestRodQuest = {
	LightningFish = {
		DisplayName = "Lightning Fish",
		Icon = "rbxassetid://115679557871754",
		IconColor = Color3.fromRGB(251, 255, 0),
		QuestType = "Major",
		Description = "Find the Largemouth Bass Buildaroo asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.TestRodQuest",
				true,
				"Bring a Lightning \"Largemouth Bass\" to Buildaroo"
			}
		},
		Rewards = {
			{ "Rod", "Test Rod" },
			{
				"ItemOrFish",
				"Largemouth Bass",
				{
					Mutation = "Sandy",
					Weight = 3
				},
				1
			}
		}
	}
}

for _, v in TestRodQuest do
	v.WishLocked = "TestRod"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return TestRodQuest