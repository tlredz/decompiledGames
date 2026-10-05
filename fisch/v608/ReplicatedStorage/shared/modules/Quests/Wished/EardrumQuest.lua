local EardrumQuest = {
	Eardrum1 = {
		DisplayName = "Eardrum",
		Icon = "rbxassetid://90514644330726",
		IconColor = Color3.fromRGB(213, 170, 142),
		QuestType = "Major",
		Description = "Find the Goblin Shark Holladay asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.EardrumQuest",
				true,
				"Bring an Atlantean \"Goblin Shark\" to Holladay"
			}
		},
		Rewards = {
			{ "Bait", "Snare", 100 },
			{ "Xp", 20000 }
		}
	},
	Eardrum2 = {
		DisplayName = "Eardrum",
		Icon = "rbxassetid://90514644330726",
		IconColor = Color3.fromRGB(177, 141, 112),
		QuestType = "Major",
		Description = "Find the Tartaruga Holladay asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.EardrumQuest",
				true,
				"Bring a Carrot \"Tartaruga\" to Holladay"
			}
		},
		Rewards = {
			{ "Lantern", "Lil' Guy" },
			{ "Xp", 80000 }
		}
	},
	Eardrum3 = {
		DisplayName = "Eardrum",
		Icon = "rbxassetid://90514644330726",
		IconColor = Color3.fromRGB(152, 115, 90),
		QuestType = "Major",
		Description = "Find the Crowned Anglerfish Holladay asked for",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.EardrumQuest",
				true,
				"Bring a Charred \"Crowned Anglerfish\" to Holladay"
			}
		},
		Rewards = {
			{ "Rod", "Eardrum" }
		}
	}
}

for _, v in EardrumQuest do
	v.WishLocked = "Eardrum"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return EardrumQuest