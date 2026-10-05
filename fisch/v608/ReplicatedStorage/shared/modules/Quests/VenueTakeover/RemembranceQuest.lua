require("../../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUnixTimestamp(1784563200)
local RemembranceQuest = {
	Remembrance1 = {
		DisplayName = "Remembrance: Broken Cocoon",
		Icon = "rbxassetid://102878317629151",
		IconColor = Color3.fromRGB(255, 255, 255),
		QuestType = "Major",
		AcceptIndicatorTag = "Luneth",
		NavigationTargets = {
			{
				Zone = "Snowburrow",
				Objectives = { 2 }
			},
			{
				Zone = "Underground Music Venue",
				Tags = { "Luneth" },
				AllComplete = true
			}
		},
		QuestSeries = "Remembrance",
		SeriesIndex = 1,
		Description = "Abnormality Research: Hue of Solemn",
		ExpiresAt = dateTime,
		Prerequisites = {
			Level = 680
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Rod", "Remembrance", "Restricted" },
			{ "Bait", "Nectar", 68 }
		}
	},
	Remembrance2 = {
		DisplayName = "Remembrance: Departure of Self",
		Icon = "rbxassetid://102878317629151",
		IconColor = Color3.fromRGB(255, 255, 255),
		QuestType = "Major",
		AcceptIndicatorTag = "Luneth",
		NavigationTargets = {
			{
				Zone = "Living Garden",
				Objectives = {
					1,
					2,
					3,
					4,
					5,
					6,
					7,
					8,
					9,
					10,
					11
				}
			},
			{
				Zone = "Underground Music Venue",
				Tags = { "Luneth" },
				AllComplete = true
			}
		},
		QuestSeries = "Remembrance",
		SeriesIndex = 2,
		Description = "Luneth needs you to return \"Lost Souls\" to her.... And a ton of them.",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Remembrance1" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "Rod", "Remembrance", "none" },
			{ "Lantern", "Butterfly" }
		}
	}
}

for _, v in RemembranceQuest do
	v.WishLocked = "Remembrance"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return RemembranceQuest