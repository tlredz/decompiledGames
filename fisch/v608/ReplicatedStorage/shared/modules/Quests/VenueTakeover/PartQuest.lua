require("../../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUnixTimestamp(1784563200)
local PartQuest = {
	BasePart1 = {
		DisplayName = "BasePart: Part Shenanigans",
		Icon = "rbxassetid://72444096547318",
		IconColor = Color3.fromRGB(172, 172, 172),
		QuestType = "Major",
		AcceptIndicatorTag = "BasePart",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "BasePart" }
			}
		},
		QuestSeries = "BasePart",
		SeriesIndex = 1,
		Description = "???",
		CompletedDescription = "!!!",
		ExpiresAt = dateTime,
		Prerequisites = {
			Level = 1
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.BasePartQuest",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Bait", "Part", 500 }
		}
	},
	BasePart2 = {
		DisplayName = "BasePart: Part Super Shenanigans",
		Icon = "rbxassetid://72444096547318",
		IconColor = Color3.fromRGB(185, 185, 185),
		QuestType = "Major",
		AcceptIndicatorTag = "BasePart",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "BasePart" }
			}
		},
		QuestSeries = "BasePart",
		SeriesIndex = 2,
		Description = "???",
		CompletedDescription = "!!!",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "BasePart1" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.BasePartQuest",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Bait", "Part", 50000 }
		}
	},
	BasePart3 = {
		DisplayName = "BasePart: Part Super Ultra Shenanigans",
		Icon = "rbxassetid://72444096547318",
		IconColor = Color3.fromRGB(195, 195, 195),
		QuestType = "Major",
		AcceptIndicatorTag = "BasePart",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "BasePart" }
			}
		},
		QuestSeries = "BasePart",
		SeriesIndex = 3,
		Description = "???",
		CompletedDescription = "!!!",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "BasePart2" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.BasePartQuest",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Rod", "Part" }
		}
	}
}

for _, v in PartQuest do
	v.WishLocked = "Part"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return PartQuest