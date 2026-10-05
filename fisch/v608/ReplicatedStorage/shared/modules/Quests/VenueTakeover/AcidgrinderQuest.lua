local dateTime = DateTime.fromUnixTimestamp(1784563200)
local AcidgrinderQuest = {
	Axel1 = {
		DisplayName = "Acidgrinder",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(140, 255, 50),
		QuestType = "Major",
		AcceptIndicatorTag = "Axel",
		QuestSeries = "Acidgrinder",
		SeriesIndex = 1,
		Description = "Catch a Tainted Brine Phantom and bring it to Axel",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		List = {
			{
				"CatchFishAny",
				1,
				{ "Brine Phantom" },
				nil,
				{
					Mutation = "Tainted",
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Brine Storm Totem",
				nil,
				1
			}
		}
	},
	Axel2 = {
		DisplayName = "Acidgrinder",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(140, 255, 50),
		QuestType = "Major",
		AcceptIndicatorTag = "Axel",
		QuestSeries = "Acidgrinder",
		SeriesIndex = 2,
		Description = "Catch a Brined Brine Sovereign and bring it to Axel",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Axel1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Brine Sovereign" },
				nil,
				{
					Mutation = "Brined",
					Return = true
				}
			}
		},
		Rewards = {
			{ "Rod", "Acidgrinder", "Restricted" },
			{ "Bait", "Acidic Larva", 250 },
			{
				"ItemOrFish",
				"Brine Storm Totem",
				nil,
				2
			}
		}
	},
	Axel3 = {
		DisplayName = "Acidgrinder",
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(140, 255, 50),
		QuestType = "Major",
		AcceptIndicatorTag = "Axel",
		QuestSeries = "Acidgrinder",
		SeriesIndex = 3,
		Description = "Catch an Acidic Caustic Starwyrm and bring it to Axel",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Axel2" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Caustic Starwyrm" },
				nil,
				{
					Mutation = "Acidic",
					Return = true
				},
				{ "Acidgrinder" }
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Acidgrinder</b> Restriction lifted" }
		}
	}
}

for _, v in AcidgrinderQuest do
	v.WishLocked = "Acidgrinder"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return AcidgrinderQuest