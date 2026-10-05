local module = require("../../EventConfig/Valentides26")
local module2 = require("../../SimpleFetchQuests/lib")
return {
	ValentidesReunite1 = {
		DisplayName = "Tidebound Reunion: A Letter For Him (Part 1)",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		AcceptIndicatorTag = "Penny",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Objectives = { 1 }
			},
			{
				Zone = "Sweetheart Shores",
				Tags = { "Penny" },
				AllComplete = true
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Penny wants to write a letter to her husband.",
		CompletedDescription = "You found a Rose Love Letter Long Pike! Go bring it to Penny.",
		Prerequisites = {},
		List = { module2.ObtainItem({
				RequiredAmount = 1,
				Item = "Love Letter Long Pike",
				RequiredAttributes = {
					Mutation = "Rose"
				},
				ForNpc = "Penny"
			}) },
		Rewards = {
			{ "LocalCurrency", "Chocolates", 500 },
			{ "Xp", 35000 }
		}
	},
	ValentidesReunite2 = {
		DisplayName = "Tidebound Reunion: Interlude",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		AcceptIndicatorTag = "Oddie",
		NavigationTargets = {
			{
				Zone = "Sunstone Island",
				Tags = { "Oddie" }
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 2,
		ExpiresAt = module.ExpiresAt,
		Description = "Penny wants you go ahead and check up on Oddie while she writes the letter.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "ValentidesReunite1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.ValentideReunite_VisitOddie",
				true,
				"Pay a visit to Oddie while Penny writes her letter"
			}
		},
		Rewards = {}
	},
	ValentidesReunite3 = {
		DisplayName = "Tidebound Reunion: A Gift For Her (Part 1)",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		AcceptIndicatorTag = "Oddie",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Objectives = { 1 }
			},
			{
				Zone = "Sunstone Island",
				Tags = { "Oddie" },
				AllComplete = true
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 3,
		ExpiresAt = module.ExpiresAt,
		Description = "Oddie wants a Lovely Rose Bouquet for his wife.",
		CompletedDescription = "You found a Lovely Rose Bouquet! Go bring it to Oddie.",
		Prerequisites = {
			QuestComplete = { "ValentidesReunite2" }
		},
		List = { module2.ObtainItem({
				RequiredAmount = 1,
				Item = "Rose Bouquet",
				RequiredAttributes = {
					Mutation = "Lovely"
				},
				ForNpc = "Oddie"
			}) },
		Rewards = {
			{ "LocalCurrency", "Chocolates", 250 },
			{ "Xp", 25000 }
		}
	},
	ValentidesReunite4 = {
		DisplayName = "Tidebound Reunion: A Letter for Him (Part 2)",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Tags = { "Penny" }
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 4,
		ExpiresAt = module.ExpiresAt,
		Description = "Penny should have finished writing her letter by now. Go pay her another visit.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "ValentidesReunite3" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.ValentideReunite_VisitPenny",
				true,
				"Retrieve the finished letter from Penny"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Penny's Love Letter",
				{},
				1
			}
		}
	},
	ValentidesReunite5 = {
		DisplayName = "Tidebound Reunion: A Letter for Him (Part 2)",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		AcceptIndicatorTag = "Oddie",
		NavigationTargets = {
			{
				Zone = "Sunstone Island",
				Tags = { "Oddie" }
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 5,
		ExpiresAt = module.ExpiresAt,
		Description = "Penny finished writing her letter, and needs it delivered to Oddie at Sunstone Island.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "ValentidesReunite4" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.ValentideReunite_LetterDelivered",
				true,
				"Deliver the letter to Oddie"
			}
		},
		Rewards = {
			{ "LocalCurrency", "Chocolates", 100 },
			{ "Xp", 5000 }
		}
	},
	ValentidesReunite6 = {
		DisplayName = "Tidebound Reunion: A Gift For Her (Part 2)",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Side",
		AcceptIndicatorTag = "Penny",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Objectives = { 1 }
			},
			{
				Zone = "Sunstone Island",
				Tags = { "Oddie" },
				AllComplete = true
			}
		},
		QuestSeries = "Tidebound Reunion",
		SeriesIndex = 6,
		ExpiresAt = module.ExpiresAt,
		Description = "Oddie needs help getting another gift for Penny.",
		CompletedDescription = "You found a Shiny Sparkling Stuffed Bear! Go bring it to Oddie.",
		Prerequisites = {
			QuestComplete = { "ValentidesReunite5" }
		},
		List = { module2.ObtainItem({
				RequiredAmount = 1,
				Item = "Stuffed Bear",
				RequiredAttributes = {
					Shiny = true,
					Sparkling = true
				},
				ForNpc = "Oddie"
			}) },
		Rewards = {
			{
				"ItemOrFish",
				"Cupid Relic",
				{
					Weight = 15
				},
				1
			},
			{ "LocalCurrency", "Chocolates", 1000 },
			{ "Xp", 50000 }
		}
	}
}