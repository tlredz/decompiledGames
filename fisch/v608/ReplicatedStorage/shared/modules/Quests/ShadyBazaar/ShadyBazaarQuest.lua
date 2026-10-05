require("../../SimpleFetchQuests/lib")
return {
	Bazaar_FindFigures = {
		DisplayName = "Whispers Below: The Three",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(180, 140, 90),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "Todd",
		NavigationTargets = {
			{
				Zone = "Moosewood",
				Tags = { "ShadyFigure" }
			}
		},
		QuestSeries = "Whispers Below",
		SeriesIndex = 1,
		Description = "Three strange figures have been seen around Moosewood at night. Find each of them.",
		CompletedDescription = "You've met all three.",
		Prerequisites = {},
		List = {
			{
				"DataInstanceValue",
				"Cache.Bazaar_FoundLantern",
				true,
				"Find the Lantern Figure"
			},
			{
				"DataInstanceValue",
				"Cache.Bazaar_FoundDiver",
				true,
				"Find the Diver"
			},
			{
				"DataInstanceValue",
				"Cache.Bazaar_FoundWatchman",
				true,
				"Find the Watchman"
			}
		},
		Rewards = {}
	},
	Bazaar_LighthouseEntry = {
		DisplayName = "Whispers Below: Coded Words",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(180, 140, 90),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "ShadyLighthouseFigure",
		NavigationTargets = {
			{
				Zone = "Moosewood",
				Tags = { "ShadyLighthouseFigure" }
			}
		},
		QuestSeries = "Whispers Below",
		SeriesIndex = 2,
		Description = "Equip all three items and return to the figure at the lighthouse at night.",
		CompletedDescription = "The hatch is open.",
		Prerequisites = {
			QuestComplete = { "Bazaar_FindFigures" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Bazaar_LighthousePassed",
				true,
				"Convince the figure at the lighthouse"
			}
		},
		Rewards = {}
	}
}