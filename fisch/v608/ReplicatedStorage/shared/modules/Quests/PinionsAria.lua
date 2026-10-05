require("../SimpleFetchQuests/lib")
return {
	Aria_MusicalFish1 = {
		DisplayName = "Pinion's Aria: Musical Attenuation",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 1,
		Description = "The Mysterious Songstress wants you to demonstrate your musical ability.",
		CompletedDescription = "",
		Prerequisites = {
			Level = 424
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
		Rewards = {}
	},
	Aria_MusicalFish2 = {
		DisplayName = "Pinion's Aria: Musical Attenuation",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "MysteriousSongstress" }
			}
		},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 2,
		Description = "The Mysterious Songstress wants you to demonstrate your musical ability.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Aria_MusicalFish1" }
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
			{
				"ItemOrFish",
				"Hang Glider",
				{},
				1
			}
		}
	},
	Aria_ReachIsland = {
		DisplayName = "Pinion's Aria: Spread Your Wings",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {
			{
				Zone = "Castaway Cliffs",
				Tags = { "HiddenIslandStart" },
				Objectives = { 1 }
			},
			{
				Zone = "Above the Clouds",
				Tags = { "HiddenIslandLand" },
				AllComplete = true
			}
		},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 3,
		Description = "The Mysterious Songstress needs something to prepare a microphone for you... but it's not gonna be easy to get.",
		CompletedDescription = "Reach the island above the clouds!",
		Prerequisites = {
			QuestComplete = { "Aria_MusicalFish2" }
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
		Rewards = {}
	},
	Aria_CatchDove = {
		DisplayName = "Pinion's Aria: Spread Your Wings",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "MysteriousSongstress" },
				AllComplete = true
			}
		},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 4,
		Description = "The Mysterious Songstress needs something to prepare a microphone for you... but it's not gonna be easy to get.",
		CompletedDescription = "You got it! Go return to the Mysterious Songstress.",
		Prerequisites = {
			QuestComplete = { "Aria_ReachIsland" }
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
			{ "DisplayOnly", "<b>Pinion's Aria</b> (Restricted)" }
		}
	},
	Aria_Tutorial = {
		DisplayName = "Pinion's Aria",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {
			{
				Zone = "Harmonic Realm",
				Tags = { "MysteriousSongstress" }
			}
		},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 5,
		Description = "To get used to your new rod, the Mysterious Songstress wants you to catch 42 fish at Crystal Cove.",
		CompletedDescription = "You did it! Go return to the Mysterious Songstress.",
		Prerequisites = {
			QuestComplete = { "Aria_CatchDove" }
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
			{
				"ItemOrFish",
				"Megalodon Hunt Totem",
				{},
				2
			}
		}
	},
	Aria_FinalChallenge = {
		DisplayName = "Pinion's Aria: Finale",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "MysteriousSongstress",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "MysteriousSongstress" },
				AllComplete = true
			}
		},
		QuestSeries = "Pinion's Aria",
		SeriesIndex = 6,
		Description = "The Mysterious Songstress needs something to prepare a microphone for you... but it's not gonna be easy to get.",
		CompletedDescription = "You got it! Go return to the Mysterious Songstress.",
		Prerequisites = {
			QuestComplete = { "Aria_Tutorial" }
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
			{ "DisplayOnly", "<b>Pinion's Aria</b> Restriction lifted" },
			{ "Lantern", "Celestial Dreamsphere" }
		}
	}
}