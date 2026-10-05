return {
	WindElemental1 = {
		DisplayName = "Wind Elemental",
		Icon = "rbxassetid://83658575432597",
		IconColor = Color3.fromRGB(255, 216, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "WindMaster",
		NavigationTargets = {
			{
				Zone = "Glacial Grotto",
				Tags = { "WindMaster" }
			}
		},
		Description = "Find what the Wind Master seeks",
		CompletedDescription = "Return to the Wind Master!",
		Prerequisites = {
			Level = 800
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.WindElementalQuest",
				true,
				"???"
			}
		},
		Rewards = {}
	},
	WindElemental2 = {
		DisplayName = "Wind Elemental",
		Icon = "rbxassetid://83658575432597",
		IconColor = Color3.fromRGB(255, 216, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "WindMaster",
		NavigationTargets = {
			{
				Zone = "Glacial Grotto",
				Tags = { "WindMaster" }
			}
		},
		Description = "Find what the Wind Master seeks",
		CompletedDescription = "Return to the Wind Master!",
		Prerequisites = {
			QuestComplete = { "WindElemental1" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.WindElementalQuest",
				true,
				"???"
			}
		},
		Rewards = {}
	},
	WindElemental3 = {
		DisplayName = "Wind Elemental",
		Icon = "rbxassetid://83658575432597",
		IconColor = Color3.fromRGB(255, 216, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "WindMaster",
		NavigationTargets = {
			{
				Zone = "Glacial Grotto",
				Tags = { "WindMaster" }
			}
		},
		Description = "Find what the Wind Master seeks",
		CompletedDescription = "Return to the Wind Master!",
		Prerequisites = {
			QuestComplete = { "WindElemental2" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.WindElementalQuest",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Rod", "Wind Elemental" }
		}
	}
}