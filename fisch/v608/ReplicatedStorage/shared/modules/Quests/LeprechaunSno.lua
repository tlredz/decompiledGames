local module = require("../EventConfig/StPatricks26")
return {
	LeprechaunSno_1 = {
		DisplayName = "Leprechaun Sno: Rainbow Leviathan",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(23, 40, 13),
		QuestType = "Major",
		AcceptIndicatorTag = "LeprechaunSno",
		NavigationTargets = {
			{
				Zone = "Shamrock Seas",
				Objectives = { 1 }
			},
			{
				Zone = "Shamrock Seas",
				Tags = { "LeprechaunSno" },
				AllComplete = true
			}
		},
		QuestSeries = "Leprechaun Sno",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Leprechaun Sno wants you to catch a Rainbow Leviathan.",
		CompletedDescription = "Return to Leprechaun Sno with your catch!",
		Prerequisites = {
			QuestComplete = { "LeprechaunSno_1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Rainbow Leviathan" },
				nil,
				nil
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Glitched Potion",
				{
					Tier = 1
				},
				3
			},
			{ "Bait", "Clover Cluster", 5 }
		}
	},
	LeprechaunSno_2 = {
		DisplayName = "Leprechaun Sno: Golden Rainbow",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(23, 40, 13),
		QuestType = "Major",
		AcceptIndicatorTag = "LeprechaunSno",
		NavigationTargets = {
			{
				Zone = "Shamrock Seas",
				Objectives = { 1 }
			},
			{
				Zone = "Shamrock Seas",
				Tags = { "LeprechaunSno" },
				AllComplete = true
			}
		},
		QuestSeries = "Leprechaun Sno",
		SeriesIndex = 2,
		ExpiresAt = module.ExpiresAt,
		Description = "Leprechaun Sno wants you to catch a Golden Rainbow Leviathan.",
		CompletedDescription = "Return to Leprechaun Sno with your catch!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Golden Rainbow Leviathan" },
				nil,
				nil
			}
		},
		Rewards = {
			{ "Boat", "Shamrock Leviathan" },
			{ "Bait", "Clover Cluster", 10 }
		}
	},
	LeprechaunSno_3 = {
		DisplayName = "Leprechaun Sno: Shamrock Leviathan",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(23, 40, 13),
		QuestType = "Major",
		AcceptIndicatorTag = "LeprechaunSno",
		NavigationTargets = {
			{
				Zone = "Shamrock Seas",
				Objectives = { 1 }
			},
			{
				Zone = "Shamrock Seas",
				Tags = { "LeprechaunSno" },
				AllComplete = true
			}
		},
		QuestSeries = "Leprechaun Sno",
		SeriesIndex = 3,
		ExpiresAt = module.ExpiresAt,
		Description = "Leprechaun Sno wants you to catch a Shamrock Leviathan.",
		CompletedDescription = "Return to Leprechaun Sno with your catch!",
		Prerequisites = {
			QuestComplete = { "LeprechaunSno_2" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Shamrock Leviathan" },
				nil,
				nil
			}
		},
		Rewards = {
			{ "Skin", "Lucky Cloverblade" },
			{ "Bait", "Clover Cluster", 15 }
		}
	},
	LeprechaunSno_Winter = {
		DisplayName = "Leprechaun Sno: Frozen Fortune",
		Icon = "rbxassetid://82328659300693",
		IconColor = Color3.fromRGB(23, 40, 13),
		QuestType = "Major",
		AcceptIndicatorTag = "LeprechaunSno",
		NavigationTargets = {
			{
				Zone = "Shamrock Seas",
				Objectives = { 1 }
			},
			{
				Zone = "Shamrock Seas",
				Tags = { "LeprechaunSno" },
				AllComplete = true
			}
		},
		QuestSeries = "Leprechaun Sno",
		SeriesIndex = 4,
		ExpiresAt = module.ExpiresAt,
		Description = "Leprechaun Sno wants you to catch a Lucky Gold mutated Frostwyrm.",
		CompletedDescription = "Return to Leprechaun Sno with your catch!",
		Prerequisites = {
			QuestComplete = { "LeprechaunSno_3" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Frostwyrm" },
				nil,
				{
					Mutation = "Lucky Gold"
				}
			}
		},
		Rewards = {
			{ "Rod", "Fallen Snowblade" },
			{ "Bait", "Clover Cluster", 20 }
		}
	}
}