local module = require("../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUniversalTime(2026, 2, 7, 17)
local AstraeusQuest = {
	Astraeus1_Emberpile = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Astraeus",
		SeriesIndex = 1,
		IsSecret = true
	},
	Astraeus2_MoonWood = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Astraeus",
		SeriesIndex = 2,
		Prerequisites = {
			QuestComplete = { "Astraeus1_Emberpile" }
		},
		IsSecret = true
	},
	Astraeus3_Serenade = {
		DisplayName = "???",
		QuestType = "Major",
		ExpiresAt = dateTime,
		QuestSeries = "Astraeus",
		SeriesIndex = 3,
		Prerequisites = {
			QuestComplete = { "Astraeus2_MoonWood" }
		},
		IsSecret = true
	},
	Astraeus4_Offering = {
		DisplayName = "Astraeus: Astraeus' Wish",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 140, 0),
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "WishEcho" }
			}
		},
		ExpiresAt = dateTime,
		QuestSeries = "Astraeus",
		SeriesIndex = 4,
		Prerequisites = {
			QuestComplete = { "Astraeus3_Serenade" }
		},
		List = {
			module.ObtainItem({
				Item = "Dusky Thread",
				RequiredAmount = 1,
				ForNpc = "Astraeus"
			}),
			module.ObtainItem({
				Item = "Twilight Pegs",
				RequiredAmount = 1,
				ForNpc = "Astraeus"
			}),
			module.ObtainItem({
				Item = "Astronomical Fretboard",
				RequiredAmount = 1,
				ForNpc = "Astraeus"
			}),
			module.ObtainItem({
				Item = "Scrap Metal",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Lunar"
				},
				ForNpc = "Astraeus"
			}),
			module.ObtainItem({
				Item = "Resin",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Nova"
				},
				ForNpc = "Astraeus"
			}),
			module.CatchFishAny({
				Fish = "Bloop Fish",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Breezed"
				}
			}),
			module.CatchFishAny({
				Fish = "Colossal Ethereal Dragon",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Celestial"
				}
			}),
			module.CatchFishAny({
				Fish = "String",
				RequiredAmount = 2,
				RequiredAttributes = {
					Mutation = "Serene"
				}
			}),
			{ "Custom", true, "Pay Astraeus 50,000,000C$" }
		},
		Rewards = {
			{ "Rod", "Astraeus Serenade" },
			{ "Xp", 15000 }
		}
	}
}

for _, v in AstraeusQuest do
	v.WishLocked = "AstraeusSerenade"
	v.AcceptIndicatorTag = "WishEcho"
end

AstraeusQuest.Astraeus = {
	DisplayName = "Astraeus",
	Icon = "rbxassetid://18162767851",
	IconColor = Color3.fromRGB(0, 0, 0),
	QuestType = "Major",
	ExpiresAt = dateTime,
	List = {
		{ "Custom", true, "???" }
	},
	Rewards = {}
}
return AstraeusQuest