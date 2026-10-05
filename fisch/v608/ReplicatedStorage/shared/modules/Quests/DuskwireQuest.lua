return {
	Duskwire1 = {
		DisplayName = "Duskwire",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(216, 216, 216),
		QuestType = "Major",
		AcceptIndicatorTag = "Hollow",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "Hollow" }
			}
		},
		Description = "Find the Catfish Hollow asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.DuskwireQuest",
				true,
				"Bring a \"Catfish\" to Hollow"
			}
		},
		Rewards = {
			{ "Xp", 10 }
		}
	},
	Duskwire2 = {
		DisplayName = "Duskwire",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Hollow",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "Hollow" }
			}
		},
		Description = "Get the Coins Hollow asked for",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Duskwire1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.DuskwireQuest",
				true,
				"Bring 1,750,001 C$ to Hollow"
			}
		},
		Rewards = {
			{ "Rod", "Duskwire" }
		}
	}
}