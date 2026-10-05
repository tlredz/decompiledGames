return {
	TryhardRod1 = {
		DisplayName = "The True Tryhard [Part 1]",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(111, 69, 69),
		QuestType = "Major",
		AcceptIndicatorTag = "RoRed",
		NavigationTargets = {
			{
				Zone = "Roslit Volcano",
				Tags = { "RoRed" },
				AllComplete = true
			}
		},
		Description = "Achieve 10 Perfect Catches in a row with the Flimsy Rod",
		CompletedDescription = "You nailed 10 perfect catches in a row with the Flimsy Rod!",
		Prerequisites = {
			Level = 999
		},
		IsSecret = true,
		List = {
			{
				"CatchFish",
				10,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Xp", 50000 }
		}
	},
	TryhardRod2 = {
		DisplayName = "The True Tryhard [Part 2]",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(159, 55, 55),
		QuestType = "Major",
		AcceptIndicatorTag = "RoRed",
		NavigationTargets = {
			{
				Zone = "Roslit Volcano",
				Tags = { "RoRed" },
				AllComplete = true
			}
		},
		Description = "Achieve 25 Perfect Casts + Catches in a row with the Flimsy Rod",
		CompletedDescription = "You mastered 25 perfect casts and catches in a row with the Flimsy Rod!",
		Prerequisites = {
			QuestComplete = { "TryhardRod1" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFish",
				25,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Bait", "Tryhard Worm", 100 }
		}
	},
	TryhardRod3 = {
		DisplayName = "The True Tryhard [Part 3]",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 25, 25),
		QuestType = "Major",
		AcceptIndicatorTag = "RoRed",
		NavigationTargets = {
			{
				Zone = "Roslit Volcano",
				Tags = { "RoRed" },
				AllComplete = true
			}
		},
		Description = "Catch something big with special gear",
		CompletedDescription = "You caught a Megalodon with a Hasty Tryhard Flimsy Rod!",
		Prerequisites = {
			QuestComplete = { "TryhardRod2" }
		},
		IsSecret = true,
		List = {
			{
				"CatchFish",
				1,
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Rod", "Tryhard Rod" },
			{ "Boat", "Elite Chair" },
			{ "Title", "Tryhard" },
			{ "Skin", "Tryhard Chroma" }
		}
	}
}