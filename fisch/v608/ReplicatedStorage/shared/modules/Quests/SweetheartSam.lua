local module = require("../EventConfig/Valentides26")
return {
	["Duo-SweetSam-1"] = {
		DisplayName = "Sweetheart Sam: Quest 1",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "Limited Fish",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				3,
				nil,
				{ "Limited" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 100 },
			{ "Lantern", "Heart" }
		}
	},
	["Alone-SweetSam-1"] = {
		DisplayName = "Sweetheart Sam: Quest 1",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "More Limited Fish",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				10,
				nil,
				{ "Limited" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 100 },
			{ "Lantern", "Heart" }
		}
	},
	["Duo-SweetSam-2"] = {
		DisplayName = "Sweetheart Sam: Quest 2",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "Catching at Night",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Dove" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 250 },
			{ "Bobber", "Love Letter" }
		}
	},
	["Alone-SweetSam-2"] = {
		DisplayName = "Sweetheart Sam: Quest 2",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "Catching at Night... Alone.",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Dove" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 250 },
			{ "Bobber", "Love Letter" }
		}
	},
	["Duo-SweetSam-3"] = {
		DisplayName = "Sweetheart Sam: Quest 3",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "Lovestorm",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				10,
				{ "Lovestorm Turtle" },
				{ "Limited" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 750 },
			{ "Boat", "Heart" }
		}
	},
	["Alone-SweetSam-3"] = {
		DisplayName = "Sweetheart Sam: Quest 3",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = module.ExpiresAt,
		AcceptIndicatorTag = "Sweetheart Sam",
		NavigationTargets = {},
		Description = "Lonely Lovestorm",
		CompletedDescription = "",
		Prerequisites = {},
		List = {
			{
				"CatchFishAny",
				10,
				{ "Lovestorm Turtle" },
				{ "Limited" }
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 750 },
			{ "Boat", "Heart" }
		}
	}
}