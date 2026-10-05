return {
	Glorp1 = {
		DisplayName = "Confusing Creature",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Glorp",
		NavigationTargets = {
			{
				Tags = { "Crookspine" }
			}
		},
		Description = "Retrieving the Translator",
		CompletedDescription = "",
		Prerequisites = {
			Level = 888
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.TalktoGlimmerfinAboutGlorp",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Xp", 1000 }
		}
	},
	Glorp2 = {
		DisplayName = "How Gleebous!",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Crookspine",
		NavigationTargets = {
			{
				Tags = { "Crookspine" },
				Objectives = { 2 }
			}
		},
		Description = "Fish around the crash site",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Glorp1" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				1,
				nil,
				nil,
				nil
			},
			{
				"DataInstanceValue",
				"Cache.ReturnAGleebousFish",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Xp", 2000 }
		}
	},
	Glorp3 = {
		DisplayName = "Understanding Glorp",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Crookspine",
		NavigationTargets = {
			{
				Tags = { "Crookspine" }
			}
		},
		Description = "Give items to Dr. Crookspine to craft a Translator",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Glorp2" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.ReturnDeviceDisplay",
				true,
				"???"
			},
			{
				"DataInstanceValue",
				"Cache.ReturnTranslatorCore",
				true,
				"???"
			},
			{
				"DataInstanceValue",
				"Cache.ReturnCommunicationCircuit",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Xp", 3500 },
			{
				"ItemOrFish",
				"Translator",
				nil,
				1
			},
			{ "Title", "Gleebin" }
		}
	},
	Glorp4 = {
		DisplayName = "Glorp Bonding",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Glorp",
		NavigationTargets = {
			{
				Zone = "Roslit Bay",
				Tags = { "Glorp" },
				AllComplete = true
			}
		},
		Description = "Gleeb gloop GOB!!!!",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "Glorp3" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFishAny",
				15,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Xp", 8500 },
			{ "Rod", "Blade Of Glorp" },
			{ "Boat", "Glorp's Saucer" }
		}
	}
}