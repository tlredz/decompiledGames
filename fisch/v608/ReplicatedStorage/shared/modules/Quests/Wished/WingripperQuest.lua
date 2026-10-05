local WingripperQuest = {
	Wingripper1 = {
		DisplayName = "Wingripper",
		Icon = "rbxassetid://131957160459539",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Find the Sardine Goth asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring a Shiny Sparkling Darkened \"Sardine\" to Goth"
			}
		},
		Rewards = {
			{
				"Bait",
				"Garbage",
				nil,
				1000
			},
			{
				"Bait",
				"Golden Tentacle",
				nil,
				150
			}
		}
	},
	Wingripper2 = {
		DisplayName = "Wingripper",
		Icon = "rbxassetid://131957160459539",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Find the Exalted Relic Goth asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring a Blessed \"Exalted Relic\" to Goth"
			}
		},
		Rewards = {
			{ "Title", "🌙" }
		}
	},
	Wingripper3 = {
		DisplayName = "Wingripper",
		Icon = "rbxassetid://131957160459539",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Find the 🐟 Goth asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.OnirifalxQuest",
				true,
				"Bring a \"🐟\" to Goth"
			}
		},
		Rewards = {
			{ "Rod", "Wingripper" }
		}
	}
}

for _, v in WingripperQuest do
	v.WishLocked = "Wingripper"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return WingripperQuest