local module = require("../EventConfig/Fischgiving25")
local color = Color3.fromRGB(208, 147, 91)
local FishFetchThanksgiving = {}

for _, v in ipairs({
	{
		questId = "Fischgiving1_1",
		npcName = "Captain Harvestbeard",
		location = "Maple Meadow",
		objectiveName = "Captain's Goldfish"
	},
	{
		questId = "Fischgiving1_2",
		npcName = "Captain Harvestbeard",
		location = "Maple Meadow",
		objectiveName = "Pirate Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			},
			{ "Title", "🍁" }
		}
	},
	{
		questId = "Fischgiving2_1",
		npcName = "Sunberry Mae",
		location = "Maple Meadow",
		objectiveName = "Tartaruga"
	},
	{
		questId = "Fischgiving2_2",
		npcName = "Sunberry Mae",
		location = "Maple Meadow",
		objectiveName = "Sunny Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				30
			},
			{ "Title", "🥧" }
		}
	},
	{
		questId = "Fischgiving3_1",
		npcName = "Mariner Mike",
		location = "Maple Meadow",
		objectiveName = "Grand Reef Guardian"
	},
	{
		questId = "Fischgiving3_2",
		npcName = "Mariner Mike",
		location = "Maple Meadow",
		objectiveName = "Poseidon Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			}
		}
	},
	{
		questId = "Fischgiving4_1",
		npcName = "Reef-Scout Ryan",
		location = "Maple Meadow",
		objectiveName = "Manta Ray"
	},
	{
		questId = "Fischgiving4_2",
		npcName = "Reef-Scout Ryan",
		location = "Maple Meadow",
		objectiveName = "Coral Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			}
		}
	},
	{
		questId = "Fischgiving5_1",
		npcName = "Cinderfeast Cooper",
		location = "Maple Meadow",
		objectiveName = "Molten Banshee"
	},
	{
		questId = "Fischgiving5_2",
		npcName = "Cinderfeast Cooper",
		location = "Maple Meadow",
		objectiveName = "Magma Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				30
			}
		}
	},
	{
		questId = "Fischgiving6_1",
		npcName = "Forager Frank",
		location = "Maple Meadow",
		objectiveName = "Mossjaw"
	},
	{
		questId = "Fischgiving6_2",
		npcName = "Forager Frank",
		location = "Maple Meadow",
		objectiveName = "Lost Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				30
			},
			{ "Title", "🍂" }
		}
	},
	{
		questId = "Fischgiving7_1",
		npcName = "Carver Caleb",
		location = "Maple Meadow",
		objectiveName = "Umbral Shark"
	},
	{
		questId = "Fischgiving7_2",
		npcName = "Carver Caleb",
		location = "Maple Meadow",
		objectiveName = "Slate Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				20
			}
		}
	},
	{
		questId = "Fischgiving8_1",
		npcName = "Spirit Gatherer Sam",
		location = "Maple Meadow",
		objectiveName = "Scalloped Hammerhead"
	},
	{
		questId = "Fischgiving8_2",
		npcName = "Spirit Gatherer Sam",
		location = "Maple Meadow",
		objectiveName = "Ghost Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			}
		}
	},
	{
		questId = "Fischgiving9_1",
		npcName = "Marsh-Feast Mason",
		location = "Maple Meadow",
		objectiveName = "Sea Turtle"
	},
	{
		questId = "Fischgiving9_2",
		npcName = "Marsh-Feast Mason",
		location = "Maple Meadow",
		objectiveName = "Mossy Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			}
		}
	},
	{
		questId = "Fischgiving10_1",
		npcName = "Chilly Hearth Hailey",
		location = "Maple Meadow",
		objectiveName = "Baby Pond Emperor"
	},
	{
		questId = "Fischgiving10_2",
		npcName = "Chilly Hearth Hailey",
		location = "Maple Meadow",
		objectiveName = "Frosty Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				30
			}
		}
	},
	{
		questId = "Fischgiving11_1",
		npcName = "Reed-Roast Rachel",
		location = "Maple Meadow",
		objectiveName = "Handfish"
	},
	{
		questId = "Fischgiving11_2",
		npcName = "Reed-Roast Rachel",
		location = "Maple Meadow",
		objectiveName = "Murky Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				25
			}
		}
	},
	{
		questId = "Fischgiving12_1",
		npcName = "Harvestman Hank",
		location = "Maple Meadow",
		objectiveName = "Treble Bass"
	},
	{
		questId = "Fischgiving12_2",
		npcName = "Harvestman Hank",
		location = "Maple Meadow",
		objectiveName = "Pioneer Turkey",
		rewards = {
			{
				"ItemOrFish",
				"Tasty Turkey Leg",
				nil,
				1
			},
			{
				"ItemOrFish",
				"Bountiful Bait Crate",
				nil,
				30
			},
			{ "Title", "🦃" }
		}
	}
}) do
	local v2 = not v.location and "" or ` in {v.location}` or ""
	local formatted = `Return a "{v.objectiveName}" to {v.npcName}{v2}.`
	local v3 = {
		DisplayName = `Fischgiving - {v.npcName}`,
		Icon = "rbxassetid://13693223669",
		IconColor = color,
		QuestType = "Side",
		ExpiresAt = module.ExpiresAt,
		Description = `Return a {v.objectiveName} to {v.npcName}{v2}.`,
		CompletedDescription = `You returned a {v.objectiveName} to {v.npcName}{v2}.`,
		List = {
			{
				"DataInstanceValue",
				`Cache.{v.questId}`,
				true,
				formatted
			}
		},
		Rewards = not v.rewards and {} or table.clone(v.rewards) or {}
	}
	FishFetchThanksgiving[v.questId] = v3
end

return FishFetchThanksgiving