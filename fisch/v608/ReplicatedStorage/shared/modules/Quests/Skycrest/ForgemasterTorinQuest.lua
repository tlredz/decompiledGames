local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../../SimpleFetchQuests/lib")
local charms = require(ReplicatedStorage.shared.modules.library.charms)
local color = Color3.fromRGB(224, 149, 59)
local count = 0

for _, charm in charms do
	if charm.IdolTag then
		count += 1
	end
end

local count2 = 0

local function seriesIndex()
	count2 += 1
	return count2
end

count2 += 1
local torin1_AncientIdolRod = {
	DisplayName = "Forgemaster Torin: The Ancient Idol Rod",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "You proved your strength. Return to Torin's anvil.",
	AutoNavigate = true,
	AcceptIndicatorTag = "ForgemasterTorin",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "ForgemasterTorin" },
			AllComplete = true
		}
	},
	QuestSeries = "Forgemaster Torin",
	SeriesIndex = count2,
	List = {
		module.CatchFishAny({
			RequiredAmount = 5,
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			FishingZones = "Skycrest"
		}),
		{ "Custom", count, "Unlock every Ancient Idol's Charm" }
	},
	Rewards = {
		{ "Rod", "Ancient Idol Rod" },
		{ "IdolFavor", 3000 }
	}
}
count2 += 1
local ForgemasterTorinQuest = {
	Torin1_AncientIdolRod = torin1_AncientIdolRod,
	Torin2_EmpyreanIdol = {
		DisplayName = "Forgemaster Torin: The Empyrean Idol",
		QuestType = "Major",
		Icon = "",
		IconColor = color,
		CompletedDescription = "You have the standing and the catalyst. Take them to Torin.",
		AutoNavigate = true,
		AcceptIndicatorTag = "ForgemasterTorin",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "ForgemasterTorin" },
				AllComplete = true
			}
		},
		QuestSeries = "Forgemaster Torin",
		SeriesIndex = count2,
		List = {
			{ "Custom", 50, (`Reach Idol Favor Level {50}`) },
			module.ObtainItem({
				Item = "Empyrean Relic",
				RequiredAmount = 1,
				ForNpc = "Torin"
			})
		},
		Rewards = {
			{ "Skin", "Empyrean Idol" },
			{ "IdolFavor", 5000 }
		}
	}
}
local v3 = {}

for k, v4 in ForgemasterTorinQuest do
	v3[v4.SeriesIndex] = k
end

for k, v4 in v3 do
	local v5 = v3[k - 1]

	if not v5 then
		continue
	end

	local v6 = ForgemasterTorinQuest[v4]

	if not v6.Prerequisites then
		v6.Prerequisites = {
			QuestComplete = { v5 }
		}
	end
end

return ForgemasterTorinQuest