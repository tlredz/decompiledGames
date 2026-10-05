local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 255, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local count = 0

local function index()
	count += 1
	return count
end

local swiftnessIdol_Base = {
	DisplayName = "Hayate Idol: Swift Swimmer",
	Description = "Fetch one of the fastest swimmers in all of Skycrest...",
	List = { lib.ObtainItem({
			Item = { "Rose-Veiled Fairy Wrasse", "Vibranium Fairy Wrasse" },
			RequiredAmount = 1,
			ForNpc = "Hayate Idol"
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Base.SeriesIndex = count
swiftnessIdol_Base.Rewards = {
	{ "IdolFavor", 15 }
}
local swiftnessIdol_Base2 = {
	DisplayName = "Hayate Idol: Swift Sailing",
	Description = "Perfectly catch the second quickest fish of the sea while winds are strong...",
	List = { lib.CatchFishAny({
			Fish = "Sailfish",
			RequiredAmount = 1,
			PerfectCatch = true,
			EventFlags = { "Windy" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Base2.SeriesIndex = count
swiftnessIdol_Base2.Rewards = {
	{ "IdolFavor", 50 }
}
local swiftnessIdol_Base3 = {
	DisplayName = "Hayate Idol: Swift Winds",
	Description = "Fetch one of the most rapid fish in all of Skycrest with a windy mutation...",
	List = { lib.ObtainItem({
			Item = { "African Butterflyfish" },
			RequiredAttributes = {
				Mutation = { "Gusty", "Breezed" }
			},
			RequiredAmount = 1,
			ForNpc = "Hayate Idol"
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Base3.SeriesIndex = count
swiftnessIdol_Base3.Rewards = {
	{ "IdolFavor", 150 }
}
count += 1
local SwiftnessIdol = {
	SwiftnessIdol_Base1 = swiftnessIdol_Base,
	SwiftnessIdol_Base2 = swiftnessIdol_Base2,
	SwiftnessIdol_Base3 = swiftnessIdol_Base3,
	SwiftnessIdol_Base4 = {
		DisplayName = "Hayate Idol: Swift Gliding",
		Description = "Head to the top of the Northern Summit and maintain peak velocity...",
		List = {
			{ "Custom", 10, "Maintain the maximum velocity of any Hang Glider for 10 seconds" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 250 }
		}
	}
}
count += 1
SwiftnessIdol.SwiftnessIdol_Base5 = {
	DisplayName = "Hayate Idol: True Swiftness",
	Description = "Catch a being of remarkable speed, with exceptional speed...",
	List = {
		{ "Custom", 1, "<b>Directly</b> Catch a Wyvern in under 20 seconds" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Swiftness Charm", 5 },
		{ "IdolFavor", 1500 }
	}
}
local swiftnessIdol_Tropical = {
	DisplayName = "Hayate Idol: Swift Swimmer - Tropical Ascension",
	Description = "Fetch 10 of the fastest swimmers in all of Skycrest...",
	List = { lib.CatchFishAny({
			Fish = { "Rose-Veiled Fairy Wrasse", "Vibranium Fairy Wrasse" },
			RequiredAmount = 10,
			AndReturn = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Tropical.SeriesIndex = count
swiftnessIdol_Tropical.Rewards = {
	{ "IdolFavor", 30 }
}
SwiftnessIdol.SwiftnessIdol_Tropical1 = swiftnessIdol_Tropical
local swiftnessIdol_Tropical2 = {
	DisplayName = "Hayate Idol: Swift Sailing - Tropical Ascension",
	Description = "Perfectly catch 10 of the second quickest fish of the sea while winds are strong...",
	List = { lib.CatchFishAny({
			Fish = "Sailfish",
			RequiredAmount = 10,
			PerfectCatch = true,
			EventFlags = { "Windy", "Tropical Squall" },
			EventFlagsRequireAll = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Tropical2.SeriesIndex = count
swiftnessIdol_Tropical2.Rewards = {
	{ "IdolFavor", 100 }
}
SwiftnessIdol.SwiftnessIdol_Tropical2 = swiftnessIdol_Tropical2
local swiftnessIdol_Tropical3 = {
	DisplayName = "Hayate Idol: Swift Winds - Tropical Ascension",
	Description = "Fetch 10 of the most rapid fish in all of Skycrest with a windy mutation...",
	List = { lib.CatchFishAny({
			Fish = { "African Butterflyfish" },
			RequiredAttributes = {
				Mutation = { "Gusty", "Breezed" }
			},
			EventFlags = { "Tropical Squall" },
			RequiredAmount = 10,
			AndReturn = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Tropical3.SeriesIndex = count
swiftnessIdol_Tropical3.Rewards = {
	{ "IdolFavor", 300 }
}
SwiftnessIdol.SwiftnessIdol_Tropical3 = swiftnessIdol_Tropical3
count += 1
SwiftnessIdol.SwiftnessIdol_Tropical4 = {
	DisplayName = "Hayate Idol: Swift Gliding - Tropical Ascension",
	Description = "Head to the top of the Northern Summit and maintain peak velocity...",
	List = {
		{ "Custom", 30, "Maintain the maximum velocity of any Hang Glider for 30 seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 500 }
	}
}
count += 1
SwiftnessIdol.SwiftnessIdol_Tropical5 = {
	DisplayName = "Hayate Idol: True Swiftness - Tropical Ascension",
	Description = "Perfectly Catch a being of remarkable speed, with exceptional speed...",
	List = {
		{ "Custom", 1, "Perfect Catch a Wyvern in under 20 seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Swiftness Charm", 10 },
		{ "IdolFavor", 3000 }
	}
}
local swiftnessIdol_Raging = {
	DisplayName = "Hayate Idol: Swift Swimmer - Raging Ascension",
	Description = "Fetch 5 of the fastest swimmers in all of Skycrest...",
	List = { lib.CatchFishAny({
			Fish = { "Rose-Veiled Fairy Wrasse", "Vibranium Fairy Wrasse" },
			RequiredAmount = 5,
			AndReturn = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Raging.SeriesIndex = count
swiftnessIdol_Raging.Rewards = {
	{ "IdolFavor", 45 }
}
SwiftnessIdol.SwiftnessIdol_Raging1 = swiftnessIdol_Raging
local swiftnessIdol_Raging2 = {
	DisplayName = "Hayate Idol: Swift Sailing - Raging Ascension",
	Description = "Perfectly catch 5 of the second quickest fish of the sea while winds are strong...",
	List = { lib.CatchFishAny({
			Fish = "Sailfish",
			RequiredAmount = 5,
			PerfectCatch = true,
			EventFlags = { "Windy", "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Raging2.SeriesIndex = count
swiftnessIdol_Raging2.Rewards = {
	{ "IdolFavor", 150 }
}
SwiftnessIdol.SwiftnessIdol_Raging2 = swiftnessIdol_Raging2
local swiftnessIdol_Raging3 = {
	DisplayName = "Hayate Idol: Swift Winds - Raging Ascension",
	Description = "Fetch 3 of the most rapid fish in all of Skycrest with a windy mutation...",
	List = { lib.CatchFishAny({
			Fish = { "African Butterflyfish" },
			RequiredAttributes = {
				Mutation = { "Gusty", "Breezed" }
			},
			EventFlags = { "Raging Squall" },
			RequiredAmount = 3,
			AndReturn = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
swiftnessIdol_Raging3.SeriesIndex = count
swiftnessIdol_Raging3.Rewards = {
	{ "IdolFavor", 450 }
}
SwiftnessIdol.SwiftnessIdol_Raging3 = swiftnessIdol_Raging3
count += 1
SwiftnessIdol.SwiftnessIdol_Raging4 = {
	DisplayName = "Hayate Idol: Swift Gliding - Raging Ascension",
	Description = "Head to the top of the Northern Summit and maintain peak velocity...",
	List = {
		{ "Custom", 30, "Maintain the maximum velocity of any Hang Glider for 30 seconds during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 750 }
	}
}
count += 1
SwiftnessIdol.SwiftnessIdol_Raging5 = {
	DisplayName = "Hayate Idol: True Swiftness - Raging Ascension",
	Description = "Perfectly Catch a being of remarkable speed, with exceptional speed...",
	List = {
		{ "Custom", 1, "Perfect Catch a Wyvern in under 30 seconds during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Swiftness Charm", 15 },
		{ "IdolFavor", 4500 }
	}
}
local v16 = {}

for k, v17 in SwiftnessIdol do
	v17.QuestSeries = "SwiftnessIdol"
	v17.AcceptIndicatorTag = "SwiftnessIdol"
	v17.Icon = "rbxassetid://136594788108497"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "SwiftnessIdol" },
		AllComplete = true
	})

	if not (v17.SeriesIndex > 10) then
		continue
	end

	v17.ResetOnRejoin = "incomplete"
	v17.Description ..= [[

<b><font color="#ff2747">Quest progress will be reset when the current Raging Squall ends.</font></b>]]
end

local v17 = nil

for i, v18 in ipairs(v16) do
	SwiftnessIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return SwiftnessIdol