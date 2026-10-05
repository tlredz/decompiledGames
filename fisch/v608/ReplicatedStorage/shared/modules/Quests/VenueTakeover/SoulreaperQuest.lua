local module = require("../../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUnixTimestamp(1785168000)
local SoulreaperQuest = {
	Soulreaper1 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 1,
		Description = "Bring the Reaper a Shiny Sparkling Darkened Rubber Ducky",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		List = { module.ObtainItem({
				Item = "Rubber Ducky",
				RequiredAmount = 1,
				RequiredAttributes = {
					Shiny = true,
					Sparkling = true,
					Mutation = "Darkened"
				},
				ForNpc = "Reaper"
			}) },
		Rewards = {
			{ "Currency", "Coins", 5000 }
		}
	},
	Soulreaper2 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 2,
		Description = "Catch a Shiny or Sparkling Spirit Ancient Depth Serpent and bring it to the Reaper",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Soulreaper1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Ancient Depth Serpent" },
				nil,
				{
					ShinyOrSparkling = true,
					Mutation = "Spirit",
					Return = true
				}
			}
		},
		Rewards = {
			{ "Skin", "OG 🥺" }
		}
	},
	Soulreaper3 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 3,
		Description = "Catch a Shiny or Sparkling Soultouched Log and bring it to the Reaper",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Soulreaper2" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Log" },
				nil,
				{
					ShinyOrSparkling = true,
					Mutation = "Soultouched",
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Soulreaper Handle",
				nil,
				1
			}
		}
	},
	Soulreaper4 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 4,
		Description = "Catch a Shiny or Sparkling Distraught Scrap Metal and bring it to the Reaper",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Soulreaper3" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Scrap Metal" },
				nil,
				{
					ShinyOrSparkling = true,
					Mutation = "Distraught",
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Soulreaper Blade",
				nil,
				1
			}
		}
	},
	Soulreaper5 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 5,
		Description = "Catch a Shiny or Sparkling Phantom String and bring it to the Reaper",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Soulreaper4" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "String" },
				nil,
				{
					ShinyOrSparkling = true,
					Mutation = "Phantom",
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Soulreaper Bonds",
				nil,
				1
			}
		}
	},
	Soulreaper6 = {
		DisplayName = "Soulreaper",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(120, 80, 180),
		QuestType = "Major",
		AcceptIndicatorTag = "Reaper",
		QuestSeries = "Soulreaper",
		SeriesIndex = 6,
		Description = "Find the three ghost buddies scattered across the world and deliver a Soulreaper part to each. Then return to the Reaper.",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Soulreaper5" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.SoulreaperGhost1",
				true,
				"Deliver the Soulreaper Handle to the first ghost buddy"
			},
			{
				"DataInstanceValue",
				"Cache.SoulreaperGhost2",
				true,
				"Deliver the Soulreaper Blade to the second ghost buddy"
			},
			{
				"DataInstanceValue",
				"Cache.SoulreaperGhost3",
				true,
				"Deliver the Soulreaper Bonds to the third ghost buddy"
			}
		},
		Rewards = {
			{ "Rod", "SOULREAPER" },
			{ "Title", "Soul Snatcher" }
		}
	}
}

for _, v in SoulreaperQuest do
	v.WishLocked = "Soulreaper"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return SoulreaperQuest