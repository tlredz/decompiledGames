local dateTime = DateTime.fromUniversalTime(2025, 9, 18, 4)
return {
	EasyChallenge = {
		DisplayName = "Noob Challenge",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 255, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Catch 15 fish using the Flimsy Rod",
		CompletedDescription = "Talk to the Challenger to claim your reward!",
		List = {
			{
				"CatchFish",
				15,
				nil,
				nil,
				nil,
				{ "Flimsy Rod" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 2500 },
			{ "Xp", 1200 },
			{ "Rod", "Experimental Rod" }
		}
	},
	MediumChallenge = {
		DisplayName = "Pro Challenge",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 255, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Catch 40 fish using the Experimental Rod",
		CompletedDescription = "Talk to the Challenger to claim your reward!",
		List = {
			{
				"CatchFish",
				40,
				nil,
				nil,
				nil,
				{ "Experimental Rod" }
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Lure Speed Potion",
				{
					Tier = 1
				},
				1
			},
			{ "Currency", "Coins", 7500 },
			{ "Xp", 3500 }
		}
	},
	HardChallenge = {
		DisplayName = "Master Challenge",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Achieve 50 Perfect Catches using the Experimental Rod",
		CompletedDescription = "Talk to the Challenger to claim your reward!",
		List = {
			{
				"CatchFish",
				50,
				nil,
				nil,
				{
					Perfect = true
				},
				{ "Experimental Rod" }
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Glitched Potion",
				{
					Tier = 1
				},
				1
			},
			{ "Currency", "Coins", 15000 },
			{ "Xp", 7500 }
		}
	},
	ExperimentalChallenge = {
		DisplayName = "Extreme Challenge!",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(128, 0, 128),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Use 60 Normal Bait",
		CompletedDescription = "Talk to the Challenger to claim your reward!",
		List = {
			{
				"BaitUse",
				60,
				{
					"Garbage",
					"Shrimp",
					"Seaweed",
					"Bagel",
					"Squid",
					"Magnet",
					"Minnow",
					"Flakes",
					"Insect",
					"Fish Head",
					"Rapid Catcher",
					"Instant Catcher",
					"Super Flakes",
					"Maggot",
					"Worm"
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Experimental Salmon",
				nil,
				1
			},
			{ "Currency", "Coins", 20000 },
			{ "Xp", 10000 }
		}
	}
}