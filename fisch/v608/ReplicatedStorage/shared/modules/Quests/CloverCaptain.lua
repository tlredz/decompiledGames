require("../SimpleFetchQuests/lib")
local module = require("../EventConfig/StPatricks26")
return {
	CloverCaptain_GoldCoin = {
		DisplayName = "Clover Captain: A Bit of Luck",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(120, 255, 120),
		QuestType = "Major",
		AcceptIndicatorTag = "CloverCaptain",
		ExpiresAt = module.ExpiresAt,
		QuestSeries = "Clover Captain",
		SeriesIndex = 1,
		Description = "The Clover Captain wants proof you've found a Pot o' Gold.",
		CompletedDescription = "",
		Prerequisites = {},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Luck Potion",
				{
					Tier = 3
				},
				1
			}
		}
	},
	CloverCaptain_LimitedFish = {
		DisplayName = "Clover Captain: Lucky Waters",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(120, 255, 120),
		QuestType = "Major",
		AcceptIndicatorTag = "Clover Captain",
		ExpiresAt = module.ExpiresAt,
		QuestSeries = "Clover Captain",
		SeriesIndex = 2,
		Description = "Bring the Clover Captain three St. Patrick's limited fish.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "CloverCaptain_GoldCoin" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Bait", "Clover Cluster", 25 }
		}
	},
	CloverCaptain_Clover = {
		DisplayName = "Clover Captain: True Fortune",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(120, 255, 120),
		QuestType = "Major",
		AcceptIndicatorTag = "Clover Captain",
		ExpiresAt = module.ExpiresAt,
		QuestSeries = "Clover Captain",
		SeriesIndex = 3,
		Description = "Find a mythical Four Leaf Clover.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "CloverCaptain_LimitedFish" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Halo", "Clover Halo" }
		}
	},
	CloverCaptain_Leviathan = {
		DisplayName = "Clover Captain: End of the Rainbow",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(120, 255, 120),
		QuestType = "Major",
		AcceptIndicatorTag = "Clover Captain",
		ExpiresAt = module.ExpiresAt,
		QuestSeries = "Clover Captain",
		SeriesIndex = 4,
		Description = "Catch the legendary Rainbow Leviathan.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "CloverCaptain_Clover" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Boat", "Rainbow Boat" }
		}
	},
	CloverCaptain_AllLeprechauns = {
		DisplayName = "Clover Captain: Master of Luck",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(120, 255, 120),
		QuestType = "Major",
		AcceptIndicatorTag = "Clover Captain",
		ExpiresAt = module.ExpiresAt,
		QuestSeries = "Clover Captain",
		SeriesIndex = 5,
		Description = "Complete every other Leprechaun quest.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "CloverCaptain_Leviathan" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Rod", "Leprechaun Line" }
		}
	}
}