local PolarisSerenadeQuest = {
	PolarisSerenade1 = {
		DisplayName = "???",
		Icon = "rbxassetid://85076538937599",
		IconColor = Color3.fromRGB(20, 87, 111),
		QuestType = "Major",
		Description = "Find the String Nick asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.PolarisSerenadeQuest",
				true,
				"Bring a Serene \"String\" to Nick"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Aurora Totem",
				nil,
				5
			}
		}
	},
	PolarisSerenade2 = {
		DisplayName = "???",
		Icon = "rbxassetid://85076538937599",
		IconColor = Color3.fromRGB(29, 130, 163),
		QuestType = "Major",
		Description = "Catch a Serene \"Spectral Serpent\" and return it to Nick",
		CompletedDescription = "Return to Nick with the Serene \"Spectral Serpent\"",
		List = {
			{
				"CatchFish",
				1,
				{ "Spectral Serpent" },
				nil,
				{
					Mutation = "Serene"
				},
				nil
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Shiny Totem",
				nil,
				3
			},
			{
				"ItemOrFish",
				"Sparkling Totem",
				nil,
				3
			}
		}
	},
	PolarisSerenade3 = {
		DisplayName = "???",
		Icon = "rbxassetid://85076538937599",
		IconColor = Color3.fromRGB(45, 206, 255),
		QuestType = "Major",
		Description = "Get the Coins Nick asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.PolarisSerenadeQuest",
				true,
				"Bring an unknown amount of Coins to Nick"
			}
		},
		Rewards = {
			{ "Rod", "Polaris Serenade" }
		}
	}
}

for _, v in PolarisSerenadeQuest do
	v.WishLocked = "PolarisSerenade"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return PolarisSerenadeQuest