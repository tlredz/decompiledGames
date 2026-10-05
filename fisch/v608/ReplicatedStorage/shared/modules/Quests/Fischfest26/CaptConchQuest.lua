local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 197, 97)
local dateTime = DateTime.fromUniversalTime(2026, 9, 12, 16)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local captConch1_Intro = {
	DisplayName = "Captain Conch: Marina's Troubles",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "FischfestMarina" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Talk to Marina" }
	},
	DisplayRewardsFrom = "CaptConch1_ReturnTrio",
	Rewards = {}
}
count += 1
local CaptConchQuest = {
	CaptConch1_Intro = captConch1_Intro,
	CaptConch1_TeamMeeting = {
		DisplayName = "Captain Conch: Marina's Troubles",
		QuestType = "Major",
		Icon = "rbxassetid://79523391252060",
		IconColor = color,
		ExpiresAt = dateTime,
		AutoNavigate = true,
		AcceptIndicatorTag = "FischfestMarina",
		NavigationTargets = {
			{
				Zone = "Coconut Town",
				Tags = { "FischfestTim" },
				Objectives = { 1 }
			},
			{
				Zone = "Coconut Town",
				Tags = { "FischfestJim" },
				Objectives = { 2 }
			},
			{
				Zone = "Coconut Town",
				Tags = { "FischfestKim" },
				Objectives = { 3 }
			}
		},
		QuestSeries = "Captain Conch",
		SeriesIndex = count,
		List = {
			{ "Custom", true, "Find Tim" },
			{ "Custom", true, "Find Jim" },
			{ "Custom", true, "Find Kim" }
		},
		DisplayRewardsFrom = "CaptConch1_ReturnTrio",
		Rewards = {}
	}
}
count += 1
CaptConchQuest.CaptConch1_ReturnTrio = {
	DisplayName = "Captain Conch: Marina's Troubles",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "FischfestMarina",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "FischfestMarina" },
			AllComplete = true
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Bring the trio back to Marina" }
	},
	Rewards = {
		{
			"ItemOrFish",
			"Coastal Crate",
			{
				Weight = 8
			},
			3
		},
		{ "LocalCurrency", "Sunshells", 250 },
		{ "Xp", 2000 }
	}
}
count += 1
CaptConchQuest.CaptConch2_GetSupplies = {
	DisplayName = "Captain Conch: Marina's Supplies",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	CompletedDescription = "You got all the supplies! Go report back to Marina.",
	AutoNavigate = true,
	AcceptIndicatorTag = "FischfestMarina",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "FischfestMarina" },
			AllComplete = true
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		module.ObtainItem({
			Item = "Firework",
			RequiredAmount = 50,
			ForNpc = "Marina"
		}),
		module.CatchFishAny({
			RequiredAmount = 25,
			PlayerZones = { "Fischfest" }
		}),
		module.CatchFishAny({
			Fish = "Slushy",
			RequiredAmount = 1,
			RequiredAttributes = {
				Shiny = true
			},
			AndReturn = true
		}),
		module.ObtainItem({
			Item = "Beach Radio",
			RequiredAmount = 1,
			RequiredAttributes = {
				Shiny = true
			},
			AndReturn = true
		}),
		module.CatchFishAny({
			Fish = "Water Balloon",
			RequiredAmount = 5,
			AndReturn = true
		}),
		module.CatchFishAny({
			Fish = "Designer Shades",
			RequiredAmount = 1,
			AndReturn = true
		})
	},
	Rewards = {
		{
			"ItemOrFish",
			"Coastal Crate",
			{
				Weight = 8
			},
			10
		},
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 5000 }
	}
}
count += 1
CaptConchQuest.CaptConch3_Transition = {
	DisplayName = "Captain Conch: Gathering of Festivities",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "FischfestMarina",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "CaptainConch" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Report back to Captain Conch" }
	},
	DisplayRewardsFrom = "CaptConch3_ReportBack",
	Rewards = {}
}
count += 1
CaptConchQuest.CaptConch3_GatherCrowd = {
	DisplayName = "Captain Conch: Gathering of Festivities",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "FischfestDrinkServer" },
			Objectives = { 1 }
		},
		{
			Zone = "Fischfest",
			Tags = { "SandyFinn" },
			Objectives = { 2 }
		},
		{
			Zone = "Fischfest",
			Tags = { "BonfireBlake" },
			Objectives = { 3 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{
			"Custom",
			2,
			{ "Talk to the Drink Server", "Buy any drink from the Drink Server" }
		},
		{
			"Custom",
			2,
			{ "Talk to Sandy Finn", "Spot a Crab" }
		},
		{
			"Custom",
			2,
			{ "Talk to Bonfire Blake", "Throw a Driftwood into the bonfire" }
		},
		{ "Custom", 5, "Complete 5 other Fischfest Quests" }
	},
	DisplayRewardsFrom = "CaptConch3_ReportBack",
	Rewards = {}
}
count += 1
CaptConchQuest.CaptConch3_ReportBack = {
	DisplayName = "Captain Conch: Gathering of Festivities",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "CaptainConch" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Report back to Captain Conch" }
	},
	Rewards = {
		{
			"ItemOrFish",
			"Beached Relic",
			{
				Weight = 20
			},
			1
		},
		{ "LocalCurrency", "Sunshells", 2500 },
		{ "Xp", 10000 }
	}
}
count += 1
CaptConchQuest.CaptConch4_Challenge = {
	DisplayName = "Captain Conch: Captain's Challenge",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "JetskiReferee" },
			Objectives = { 1 }
		},
		{
			Zone = "Fischfest",
			Tags = { "BeachVolleyballReferee" },
			Objectives = { 2 }
		},
		{
			Zone = "Fischfest",
			Tags = { "SandcastleReferee" },
			Objectives = { 3 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{
			"Custom",
			2,
			{ "Talk to the Jetski Referee", "Complete any Jetski Race" }
		},
		{
			"Custom",
			2,
			{ "Talk to the Beach Volleyball Referee", "Reach 5+ score in a game of Beach Volleyball" }
		},
		{
			"Custom",
			2,
			{ "Talk to the Sand Castle Referee", "Build a Sand Castle" }
		}
	},
	DisplayRewardsFrom = "CaptConch4_ReportBack",
	Rewards = {}
}
count += 1
CaptConchQuest.CaptConch4_ReportBack = {
	DisplayName = "Captain Conch: Captain's Challenge",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "CaptainConch" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Report back to Captain Conch" }
	},
	Rewards = {
		{
			"ItemOrFish",
			"Tropical Relic",
			{
				Weight = 20
			},
			1
		},
		{ "LocalCurrency", "Sunshells", 3500 },
		{ "Xp", 15000 }
	}
}
count += 1
CaptConchQuest.CaptConch5_Sunslashers = {
	DisplayName = "Captain Conch: Sunlit Savages",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	CompletedDescription = "You caught the Sunslashers! Go report back to Captain Conch.",
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "CaptainConch" },
			AllComplete = true
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = { module.CatchFishAny({
			Fish = "Sunslasher",
			RequiredAmount = 3
		}) },
	Rewards = {
		{ "Rod", "Starshell Rod", "Restricted" },
		{ "LocalCurrency", "Sunshells", 4000 },
		{
			"ItemOrFish",
			"Pink Conch",
			nil,
			1
		},
		{ "Xp", 20000 }
	}
}
count += 1
CaptConchQuest.CaptConch6_OpenGate = {
	DisplayName = "Captain Conch: Flamewrought Finale",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "SandCastleGate" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Open the Great Sand Castle's hatch" }
	},
	DisplayRewardsFrom = "CaptConch6_Flameslasher",
	Rewards = {}
}
count += 1
CaptConchQuest.CaptConch6_Flameslasher = {
	DisplayName = "Captain Conch: Flamewrought Finale",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	ExpiresAt = dateTime,
	CompletedDescription = "You caught the Flameslasher! Go tell Captain Conch the good news!",
	AutoNavigate = true,
	AcceptIndicatorTag = "CaptainConch",
	NavigationTargets = {
		{
			Zone = "Heart of the Island",
			Tags = { "FlameslasherPool" },
			Objectives = { 1 }
		},
		{
			Zone = "Fischfest",
			Tags = { "CaptainConch" },
			AllComplete = true
		}
	},
	QuestSeries = "Captain Conch",
	SeriesIndex = count,
	List = { module.CatchFish({
			Fish = "Flameslasher",
			RequiredAmount = 1,
			Rods = { "Starshell Rod" }
		}) },
	Rewards = {
		{ "Rod", "Starshell Rod", "none" },
		{ "Companion", "Sunhat Starfish" },
		{
			"ItemOrFish",
			"Paradise Relic",
			{
				Weight = 20
			},
			1
		},
		{ "LocalCurrency", "Sunshells", 5000 },
		{ "Xp", 25000 }
	}
}
local v13 = {}

for k, v14 in CaptConchQuest do
	v13[v14.SeriesIndex] = k
end

for k, v14 in v13 do
	local v15 = v13[k - 1]

	if not v15 then
		continue
	end

	local v16 = CaptConchQuest[v14]

	if not v16.Prerequisites then
		v16.Prerequisites = {
			QuestComplete = { v15 }
		}
	end
end

return CaptConchQuest