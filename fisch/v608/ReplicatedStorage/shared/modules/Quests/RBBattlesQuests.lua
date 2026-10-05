local dateTime = DateTime.fromUniversalTime(2026, 2, 28, 17)
return {
	RBBattles_CatchFish = {
		DisplayName = "Gone Fishing... Live! The Catch",
		Icon = "rbxassetid://75635323960971",
		IconColor = Color3.fromRGB(145, 70, 255),
		QuestType = "Major",
		AcceptIndicatorTag = "TwitchViewer",
		NavigationTargets = {
			{
				Zone = "Ocean",
				Objectives = { 1 }
			},
			{
				Zone = "Mushgrove Swamp",
				Objectives = { 2 }
			},
			{
				Zone = "Vertigo",
				Objectives = { 3 }
			},
			{
				Zone = "Moosewood",
				Tags = { "TwitchViewer" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Gone Fishing... Live!",
		SeriesIndex = 1,
		Description = "Catch a Pufferfish from the Ocean, Mushgrove Crab from Mushgrove Swamp, and a Rubber Ducky from Vertigo for the Twitch Viewer.",
		CompletedDescription = "Return to the Twitch Viewer at Moosewood.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Pufferfish" },
				nil,
				{
					Return = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Mushgrove Crab" },
				nil,
				{
					Return = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Rubber Ducky" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {}
	},
	RBBattles_OpenPassage = {
		DisplayName = "Gone Fishing... Live! The Hideout",
		Icon = "rbxassetid://75635323960971",
		IconColor = Color3.fromRGB(145, 70, 255),
		QuestType = "Major",
		NavigationTargets = {
			{
				Zone = "Earmark Island",
				Objectives = { 1 }
			},
			{
				Zone = "Earmark Island",
				Tags = { "HatchTeleport" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Gone Fishing... Live!",
		SeriesIndex = 2,
		Description = "Place the fish at the hidden passageway on Earmark Island.",
		CompletedDescription = "The passageway is open! Head inside.",
		Prerequisites = {
			QuestComplete = { "RBBattles_CatchFish" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.RBBattles_PassageOpened",
				true,
				"Place the fish at the hidden passageway"
			}
		},
		Rewards = {}
	},
	RBBattles_CloutCarp = {
		DisplayName = "Gone Fishing... Live! Clout Carp",
		Icon = "rbxassetid://75635323960971",
		IconColor = Color3.fromRGB(145, 70, 255),
		QuestType = "Major",
		NavigationTargets = {
			{
				Zone = "Streamer Hideout",
				Objectives = { 1 }
			},
			{
				Zone = "Streamer Hideout",
				Tags = { "StreamerDoor" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Gone Fishing... Live!",
		SeriesIndex = 3,
		Description = "Catch the Clout Carp in the Streamer Hideout.",
		CompletedDescription = "Bring the Clout Carp to the streamer's locked door.",
		Prerequisites = {
			QuestComplete = { "RBBattles_OpenPassage" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Clout Carp" },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {}
	},
	RBBattles_FindStreamer = {
		DisplayName = "Gone Fishing... Live! Meet the Streamer",
		Icon = "rbxassetid://75635323960971",
		IconColor = Color3.fromRGB(145, 70, 255),
		QuestType = "Major",
		NavigationTargets = {
			{
				Zone = "Streamer Hideout",
				Tags = { "StreamerDoor" },
				Objectives = { 1 }
			},
			{
				Zone = "Streamer Hideout",
				Tags = { "Streamer" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Gone Fishing... Live!",
		SeriesIndex = 4,
		Description = "Use the Clout Carp for the streamer to unlock the door.",
		CompletedDescription = "Talk to the Streamer.",
		Prerequisites = {
			QuestComplete = { "RBBattles_CloutCarp" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.RBBattles_DoorUnlocked",
				true,
				"Use the Clout Carp for the streamer to unlock the door."
			}
		},
		Rewards = {}
	},
	RBBattles_FixBugs = {
		DisplayName = "Gone Fishing... Live! Bug Fixes",
		Icon = "rbxassetid://75635323960971",
		IconColor = Color3.fromRGB(145, 70, 255),
		QuestType = "Major",
		AcceptIndicatorTag = "Streamer",
		NavigationTargets = {
			{
				Zone = "Streamer Hideout",
				Objectives = { 1 }
			},
			{
				Zone = "Streamer Hideout",
				Tags = { "Streamer" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Gone Fishing... Live!",
		SeriesIndex = 5,
		Description = "Fix the cables and dials, then restart the router.",
		CompletedDescription = "Talk to the Streamer.",
		Prerequisites = {
			QuestComplete = { "RBBattles_FindStreamer" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.RBBattles_EquipmentFixed",
				13,
				"Fix the streamer's equipment"
			}
		},
		Rewards = {
			{ "Rod", "Microphone Rod" },
			{ "Badge", 3502827194384292 }
		}
	}
}