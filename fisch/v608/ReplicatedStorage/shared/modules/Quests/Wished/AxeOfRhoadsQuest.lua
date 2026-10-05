local AxeOfRhoadsQuest = {
	AxeOfRhoads1 = {
		DisplayName = "Noctone",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(35, 35, 35),
		QuestType = "Major",
		Description = "Find the Great Hammerhead Shark Nico asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.AxeOfRhoadsQuest",
				true,
				"Bring a Shiny Mythical \"Great Hammerhead Shark\" to Nico"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Rock",
				{
					Shiny = true,
					Sparkling = true,
					Mutation = "Nuclear",
					Weight = 8
				},
				10
			},
			{ "Xp", 50000 }
		}
	},
	AxeOfRhoads2 = {
		DisplayName = "Noctone",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(117, 117, 117),
		QuestType = "Major",
		Description = "Find the Maelstorm Shark Nico asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.AxeOfRhoadsQuest",
				true,
				"Bring a Sparkling Electric Shock \"Maelstorm Shark\" to Nico"
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Nuke",
				nil,
				1
			},
			{ "Xp", 75000 }
		}
	},
	AxeOfRhoads3 = {
		DisplayName = "Noctone",
		Icon = "rbxassetid://86080334936308",
		IconColor = Color3.fromRGB(255, 255, 255),
		QuestType = "Major",
		Description = "Find the Ancient Megalodon Nico asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.AxeOfRhoadsQuest",
				true,
				"Bring a Wrath \"Ancient Megalodon\" to Nico"
			}
		},
		Rewards = {
			{ "Rod", "Noctone" }
		}
	}
}

for _, v in AxeOfRhoadsQuest do
	v.WishLocked = "AxeOfRhoads"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return AxeOfRhoadsQuest