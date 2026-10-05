return {
	SellFish = {
		DisplayName = "Sell Fish",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Testing description",
		CompletedDescription = "Talk to Ringo to receive your reward!",
		List = {
			{ "SellFish", 15, nil },
			{
				"SellFish",
				5,
				{ "Megalodon" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	CatchFish = {
		DisplayName = "Fish Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{
				"CatchFish",
				5,
				nil,
				nil,
				nil
			},
			{
				"CatchFish",
				5,
				nil,
				{ "Legendary" },
				nil
			},
			{
				"CatchFish",
				5,
				nil,
				{ "Legendary" },
				nil,
				{ "Developers Rod" }
			},
			{
				"CatchFish",
				5,
				nil,
				nil,
				{
					Mutation = "Nuclear"
				},
				nil
			},
			{
				"CatchFish",
				5,
				nil,
				nil,
				nil,
				nil,
				{ "BaitName" }
			},
			{
				"CatchFish",
				5,
				nil,
				nil,
				nil,
				nil,
				{ "BaitName" },
				{ "Glossy", "Hexed" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	CatchFishWithSpear = {
		DisplayName = "Fish Catch With Spear",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		Description = "Testing description",
		CompletedDescription = "talk to Layla to receive your reward!",
		List = {
			{
				"CatchFishWithSpear",
				5,
				nil,
				nil,
				nil
			},
			{
				"CatchFishWithSpear",
				5,
				nil,
				{ "Legendary" },
				nil
			},
			{
				"CatchFishWithSpear",
				5,
				nil,
				{ "Legendary" },
				nil,
				{ "Barbed Spear" }
			},
			{
				"CatchFishWithSpear",
				5,
				nil,
				nil,
				{
					Mutation = "Royal"
				}
			},
			{
				"CatchFishWithSpear",
				5,
				{ "Carp" },
				nil,
				nil,
				nil
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	BaitQuest = {
		DisplayName = "Fish Catch",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Challenge",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{
				"CatchFish",
				5,
				nil,
				nil,
				nil,
				nil,
				{ "BaitName" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	ConceptionConch = {
		DisplayName = "Conception Conch",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Reputation",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{ "ConceptionConch", 3 }
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	TotemUse = {
		DisplayName = "Totem Use",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Mastery",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{ "TotemUse", 3, nil },
			{
				"TotemUse",
				3,
				{ "Tempest Totem" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	Drive = {
		DisplayName = "Drive",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{ "Drive", 2000 }
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	Travel = {
		DisplayName = "Travel",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{ "Travel", 500 }
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	DataInstanceValue = {
		DisplayName = "Data Instance Value",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Challenge",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
		List = {
			{
				"DataInstanceValue",
				"Cache.FishNotesCompleted",
				true,
				"Complete Fish Notes puzzle"
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 }
		}
	},
	AllRewards = {
		DisplayName = "All Rewards",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		Description = "Testing description",
		CompletedDescription = "talk to Ringo to receive your reward!",
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
			{ "Currency", "Coins", 1500 },
			{ "Badge", 34342342 },
			{
				"ItemOrFish",
				"Drill",
				nil,
				1
			},
			{ "Rod", "Developers Rod" },
			{ "Skin", "Seraphic Rainbow" },
			{ "Xp", 10000 },
			{ "Bobber", "Abyssal Skull" },
			{ "Title", "Ocean's Champion" },
			{ "Boat", "Camera Boat" },
			{ "Lantern", "Aurora Lantern" },
			{ "Bait", "Maggot", 100 },
			{ "Reputation", "Red Marlins", 40 },
			{ "LocalCurrency", "Doubloons", 45 },
			{ "Passive", "Developers Rod", "2xBaits" }
		}
	}
}