local dateTime = DateTime.fromUniversalTime(2026, 9, 12, 16)
return {
	SandyFinn2Quest1 = {
		DisplayName = "Fischfest 2026: Find the Crabs",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "SandyFinn",
		NavigationTargets = {
			{
				Zone = "Fischfest",
				Tags = { "SandyFinn" },
				AllComplete = true
			}
		},
		Description = "Interact with the 10 crabs around the islands.",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.SandyFinn2Quest1",
				10,
				"Interact with the 10 crabs around the islands."
			}
		},
		Rewards = {
			{ "LocalCurrency", "Sunshells", 500 },
			{
				"ItemOrFish",
				"Coastal Crate",
				{
					Weight = 8
				},
				5
			},
			{ "Xp", 3000 }
		}
	},
	SandyFinn2Quest2 = {
		DisplayName = "Fischfest 2026: A Tanned Crabby Coconut",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		ExpiresAt = dateTime,
		NavigationTargets = {
			{
				Zone = "Fischfest",
				Tags = { "SandyFinn" }
			}
		},
		Description = "Return a single Tanned Crabby Coconut.",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.SandyFinn2Quest2",
				true,
				"Return a single Tanned Crabby Coconut."
			}
		},
		Rewards = {
			{ "LocalCurrency", "Sunshells", 500 },
			{ "Title", "The Crab Master" },
			{
				"ItemOrFish",
				"Coastal Crate",
				{
					Weight = 8
				},
				5
			},
			{
				"ItemOrFish",
				"Sandy Handle",
				nil,
				1
			},
			{ "Xp", 7000 }
		}
	}
}