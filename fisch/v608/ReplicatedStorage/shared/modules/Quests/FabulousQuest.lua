return {
	Fabulous1 = {
		DisplayName = "Fabulous Beginnings",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FabulousDeity",
		NavigationTargets = {
			{
				Zone = "Calm Zone",
				Tags = { "FabulousDeity" },
				AllComplete = true
			}
		},
		Description = "",
		CompletedDescription = "",
		Prerequisites = {
			Level = 1000
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				nil,
				nil
			}
		},
		Rewards = {}
	},
	Fabulous2 = {
		DisplayName = "Fabulous Findings",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FabulousDeity",
		NavigationTargets = {
			{
				Zone = "Calm Zone",
				Tags = { "FabulousDeity" },
				AllComplete = true
			}
		},
		Description = "",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Fabulous1" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				nil,
				nil
			}
		},
		Rewards = {}
	},
	Fabulous3 = {
		DisplayName = "Fabulous Torment",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FabulousDeity",
		NavigationTargets = {
			{
				Zone = "Calm Zone",
				Tags = { "FabulousDeity" },
				AllComplete = true
			}
		},
		Description = "",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Fabulous2" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				nil,
				nil
			}
		},
		Rewards = {}
	},
	Fabulous4 = {
		DisplayName = "Fabulous Finale",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FabulousDeity",
		NavigationTargets = {
			{
				Zone = "Calm Zone",
				Tags = { "FabulousDeity" },
				Objectives = { 3 }
			},
			{
				Zone = "Calm Zone",
				Tags = { "FabulousDeity" },
				AllComplete = true
			}
		},
		Description = "",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Fabulous3" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Title", "Fabulous" },
			{ "DisplayOnly", "Fabulous Rod" }
		}
	}
}