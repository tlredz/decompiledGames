local module = require("../../EventConfig/Fischmas25")
return {
	Fischmas25_Santa_ElfComplete = {
		DisplayName = "Fischmas 2025: Factory Assistant",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FakeSanta",
		NavigationTargets = {
			{
				Zone = "Toy Factory",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "FakeSanta" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Help all the elves at the Toy Factory!",
		CompletedDescription = "Return to \"Santa\" at the Toy Factory to report your progress!",
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_ElfQuests",
				4,
				"Help all the elves at the Toy Factory!"
			}
		},
		Rewards = {}
	},
	Fischmas25_Santa_Rescue1 = {
		DisplayName = "Fischmas 2025: Where's Santa?",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "FakeSanta",
		NavigationTargets = {
			{
				Zone = "Northern Expedition",
				Tags = { "SantaNorthern" },
				Objectives = { 1 }
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 2,
		ExpiresAt = module.ExpiresAt,
		Description = "Santa has gone missing...",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_ElfComplete" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_FoundSanta",
				true,
				"Find Santa!"
			}
		},
		Rewards = {}
	},
	Fischmas25_Santa_Rescue2 = {
		DisplayName = "Fischmas 2025: Santa's Escort",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "SantaNorthern",
		NavigationTargets = {
			{
				Zone = "Northern Expedition",
				Tags = { "SantaNorthern" },
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 3,
		ExpiresAt = module.ExpiresAt,
		Description = "Santa got lost... Let's bring him back home.",
		CompletedDescription = "You've rescued Santa! Better go check up on him at the Toy Factory...",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_Rescue1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_RescueSanta",
				true,
				"Use the Magical Snow Globe to return to the Toy Factory"
			}
		},
		Rewards = {
			{ "Title", "On The Nice List" }
		}
	},
	Fischmas25_Santa_SnackBreak = {
		DisplayName = "Fischmas 2025: Snack Break",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Santa25",
		NavigationTargets = {
			{
				Zone = "Northstar Village",
				Objectives = { 1, 2 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 4,
		ExpiresAt = module.ExpiresAt,
		Description = "Santa is starving after being stranded for so long. Get him something to eat, and make sure it's fresh!",
		CompletedDescription = "Return the snacks to Santa!",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_Rescue2" }
		},
		List = {
			{
				"CatchFishAny",
				5,
				{ "Gingerbread Man" },
				nil,
				{
					Return = true
				}
			},
			{
				"CatchFishAny",
				2,
				{ "Glass of Eggnog" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Bobber", "Santa's Hat" }
		}
	},
	Fischmas25_Santa_MissingPresents = {
		DisplayName = "Fischmas 2025: Missing Presents",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Santa25",
		NavigationTargets = {
			{
				Zone = "Northstar Village",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 5,
		ExpiresAt = module.ExpiresAt,
		Description = "Some of Santa's presents fell into the water around the Northstar Village!",
		CompletedDescription = "Return the presents to Santa!",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_SnackBreak" }
		},
		List = {
			{
				"CatchFishAny",
				3,
				{ "Santa's Present" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Lantern", "Santa Lantern" }
		}
	},
	Fischmas25_Santa_HotCocoa = {
		DisplayName = "Fischmas 2025: Warming Up",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Santa25",
		NavigationTargets = {
			{
				Zone = "Northstar Village",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 6,
		ExpiresAt = module.ExpiresAt,
		Description = "Santa is almost ready to go! He just needs one fresh glass of Hot Cocoa... for each of his elves. And Carbon.",
		CompletedDescription = "Return the Hot Cocoa to Santa!",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_MissingPresents" }
		},
		List = {
			{
				"CatchFishAny",
				6,
				{ "Hot Cocoa" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "Boat", "Turbo Sleigh" }
		}
	},
	Fischmas25_Santa_PresentDelivery = {
		DisplayName = "Fischmas 2025: Present Delivery",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Santa25",
		NavigationTargets = {
			{
				Zone = "Glacial Ridge",
				Tags = { "Snowman25" },
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 7,
		ExpiresAt = module.ExpiresAt,
		Description = "Santa is still running behind schedule and needs your help delivring some of the presents.",
		CompletedDescription = "You've delivered all the presents! Report back to Santa and tell him the good news.",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_HotCocoa" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.Fischmas25_PresentDelivery",
				10,
				"Deliver presents to snowmen at the Glacial Ridge"
			},
			{
				"DataInstanceValue",
				"Cache.Fischmas25_PresentTrading",
				game.GameId == 5750914919 and 10 or 3,
				"Trade presents with other players"
			}
		},
		Rewards = {
			{ "Rod", "Santa's Miracle Rod" }
		}
	},
	Fischmas25_Santa_StrangeWhale = {
		DisplayName = "Fischmas 2025: \"Strange Whale\"",
		Icon = "rbxassetid://78476264790401",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Santa25",
		NavigationTargets = {
			{
				Zone = "Northstar Village",
				Objectives = { 1 }
			},
			{
				Zone = "Toy Factory",
				Tags = { "Santa25" },
				AllComplete = true
			}
		},
		QuestSeries = "Fischmas 2025",
		SeriesIndex = 8,
		ExpiresAt = module.ExpiresAt,
		Description = "A \"strange whale\" is terrorizing the residents of the Winter Village! Carbon seems particularly nervous...",
		CompletedDescription = "You caught the Northstar Whale! Go tell Santa the good news.",
		Prerequisites = {
			QuestComplete = { "Fischmas25_Santa_PresentDelivery" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Northstar Whale" },
				nil,
				nil
			}
		},
		Rewards = {
			{ "Skin", "Krampus's Miracle" },
			{
				"ItemOrFish",
				"Everfrost Key",
				{},
				1
			}
		}
	}
}