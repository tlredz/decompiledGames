local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(198, 233, 255)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local aero1_SwiftWinds = {
	DisplayName = "Aero: Swift Winds",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "You unlocked the Swiftness Charm! Go show Aero.",
	AutoNavigate = true,
	AcceptIndicatorTag = "Aero",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "SwiftnessIdol" },
			Objectives = { 1 }
		},
		{
			Zone = "Skycrest",
			Tags = { "Aero" },
			AllComplete = true
		}
	},
	QuestSeries = "Aero",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Unlock the Swiftness Charm at the Hayate Idol" }
	},
	Rewards = {
		{
			"ItemOrFish",
			"Cloud Glider",
			nil,
			1
		},
		{ "IdolFavor", 500 }
	}
}
count += 1
local AeroQuest = {
	Aero1_SwiftWinds = aero1_SwiftWinds,
	Aero2_StrongGusts = {
		DisplayName = "Aero: Strong Gusts",
		QuestType = "Major",
		Icon = "",
		IconColor = color,
		CompletedDescription = "Return to Aero to choose your gale-weapon.",
		AutoNavigate = true,
		AcceptIndicatorTag = "Aero",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "Aero" },
				AllComplete = true
			}
		},
		QuestSeries = "Aero",
		SeriesIndex = count,
		List = {
			{ "Custom", 10, (`Reach Level {10} on the Swiftness Charm`) },
			{ "Custom", 1000, (`Travel {1000} studs with the Cloud Glider`) }
		},
		Rewards = {
			{ "IdolFavor", 1500 }
		}
	}
}
count += 1
AeroQuest.Aero3_HarnessTheWinds = {
	DisplayName = "Aero: Harness the Winds",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "You tamed the gale! Bring your catches back to Aero.",
	AutoNavigate = true,
	AcceptIndicatorTag = "Aero",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "Aero" },
			AllComplete = true
		}
	},
	QuestSeries = "Aero",
	SeriesIndex = count,
	List = { module.CatchFishAny({
			RequiredAmount = 20,
			Raritites = {
				"Legendary",
				"Mythical",
				"Exotic",
				"Secret",
				"Relic"
			},
			RequiredAttributes = {
				Mutation = "Gusty"
			},
			PlayerZones = "Skycrest",
			AndReturn = true
		}), module.CatchFishAny({
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Gusty",
				ShinyOrSparkling = true
			},
			PlayerZones = "Skycrest",
			AndReturn = true
		}) },
	Rewards = {
		{ "IdolFavor", 1500 }
	}
}
local v4 = {}

for k, v5 in AeroQuest do
	v4[v5.SeriesIndex] = k
end

for k, v5 in v4 do
	local v6 = v4[k - 1]

	if not v6 then
		continue
	end

	local v7 = AeroQuest[v5]

	if not v7.Prerequisites then
		v7.Prerequisites = {
			QuestComplete = { v6 }
		}
	end
end

return AeroQuest