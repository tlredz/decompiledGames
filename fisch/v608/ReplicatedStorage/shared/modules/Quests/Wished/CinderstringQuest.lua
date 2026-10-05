local CinderstringQuest = {
	Cinderstring1 = {
		DisplayName = "Cinderstring",
		Icon = "rbxassetid://92198090110083",
		IconColor = Color3.fromRGB(188, 110, 0),
		QuestType = "Major",
		Description = "Find the Sea Mine Rick asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring a Scorched \"Sea Mine\" to Rick"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Fillionaire",
				nil,
				50
			}
		}
	},
	Cinderstring2 = {
		DisplayName = "Cinderstring",
		Icon = "rbxassetid://92198090110083",
		IconColor = Color3.fromRGB(255, 106, 0),
		QuestType = "Major",
		Description = "Find the Hogchoker Rick asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring an Emberflame \"Hogchoker\" to Rick"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Exalted Relic",
				{
					Mutation = "Female",
					Weight = 21
				},
				3
			}
		}
	},
	Cinderstring3 = {
		DisplayName = "Cinderstring",
		Icon = "rbxassetid://92198090110083",
		IconColor = Color3.fromRGB(255, 85, 0),
		QuestType = "Major",
		Description = "Find the Bait Crate Rick asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring a Shiny Subspace \"Bait Crate\" to Rick"
			}
		},
		Rewards = {
			{ "Rod", "Cinderstring" }
		}
	}
}

for _, v in CinderstringQuest do
	v.WishLocked = "Cinderstring"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return CinderstringQuest