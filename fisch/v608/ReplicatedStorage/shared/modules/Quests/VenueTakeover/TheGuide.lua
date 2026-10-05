local module = require("../../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUnixTimestamp(1784563200)
local TheGuide = {
	TheGuide_GettingStarted = {
		DisplayName = "The Guide: Getting Started",
		Icon = "rbxassetid://101267106505092",
		IconColor = Color3.fromRGB(207, 255, 94),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "The Guide",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "The Guide" }
			}
		},
		QuestSeries = "The Guide",
		SeriesIndex = 1,
		Prerequisites = {},
		Description = "",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		List = { module.CatchFishAny({
				Fish = "Flying Fish",
				RequiredAmount = 10,
				RequiredAttributes = {
					Perfect = true,
					Shiny = true
				},
				ForNpc = "The Guide"
			}) },
		Rewards = {
			{
				"Rod",
				"Castbound",
				"Restricted",
				-50
			}
		}
	},
	TheGuide_Shimmer = {
		DisplayName = "The Guide: Shimmer",
		Icon = "rbxassetid://101267106505092",
		IconColor = Color3.fromRGB(207, 255, 94),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "The Guide",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "The Guide" }
			}
		},
		QuestSeries = "The Guide",
		SeriesIndex = 2,
		Prerequisites = {
			QuestComplete = { "TheGuide_GettingStarted" }
		},
		Description = "",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		List = { module.CatchFish({
				RequiredAmount = 150,
				FishingZones = "Shimmer",
				Rods = { "Castbound" },
				RequiredAttributes = {
					Perfect = true
				},
				ForNpc = "The Guide"
			}) },
		Rewards = {
			{
				"Rod",
				"Castbound",
				"Restricted",
				-25
			},
			{ "Xp", 5000 }
		}
	},
	TheGuide_Final = {
		DisplayName = "The Guide: Final Stretch",
		Icon = "rbxassetid://101267106505092",
		IconColor = Color3.fromRGB(207, 255, 94),
		QuestType = "Major",
		AutoNavigate = true,
		AcceptIndicatorTag = "The Guide",
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "The Guide" }
			}
		},
		QuestSeries = "The Guide",
		SeriesIndex = 3,
		Prerequisites = {
			QuestComplete = { "TheGuide_Shimmer" }
		},
		Description = "",
		CompletedDescription = "",
		ExpiresAt = dateTime,
		List = { module.HaveRod({
				Rod = {
					"Flimsy Rod",
					"Carbon Rod",
					"Steady Rod",
					"Arctic Rod",
					"Mythical Rod",
					"Trident Rod",
					"Rod Of The Depths",
					"Rod Of The Forgotten Fang",
					"Heaven's Rod",
					"Tempest Rod",
					"Zeus Rod",
					"Ethereal Prism Rod",
					"Free Spirit Rod",
					"Great Rod of Oscar",
					"Ruinous Oath"
				},
				ForNpc = "The Guide"
			}) },
		Rewards = {
			{
				"Rod",
				"Castbound",
				"none",
				0
			},
			{ "Title", "Bound" }
		}
	}
}

for _, v in TheGuide do
	v.WishLocked = "Castbound"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return TheGuide