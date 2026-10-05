local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 255, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local count = 0

local function index()
	count += 1
	return count
end

local brawnIdol_Base = {
	DisplayName = "Goriki Idol: Resilient Brawn",
	Description = "Catch 10 fish of fair difficulty...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 150 }
			},
			RequiredAmount = 10,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Base.SeriesIndex = count
brawnIdol_Base.Rewards = {
	{ "IdolFavor", 15 }
}
local brawnIdol_Base2 = {
	DisplayName = "Goriki Idol: Enduring Brawn",
	Description = "Catch numerous fish that fight back...",
	List = { lib.CatchFish({
			BiteStats = {
				ProgressSpeed = { nil, -40 }
			},
			RequiredAmount = 15,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Base2.SeriesIndex = count
brawnIdol_Base2.Rewards = {
	{ "IdolFavor", 90 }
}
local brawnIdol_Base3 = {
	DisplayName = "Goriki Idol: Refined Brawn",
	Description = "Refine the art of the hunt...",
	DisplayList = {
		{ "Custom", 5, "<b>Directly</b> Catch 5 Hunt Fish" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			RequiredAmount = 5,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Base3.SeriesIndex = count
brawnIdol_Base3.Rewards = {
	{ "IdolFavor", 120 }
}
local brawnIdol_Base4 = {
	DisplayName = "Goriki Idol: Controlled Brawn",
	Description = "Display your maximum control potential...",
	List = { lib.CatchFish({
			BiteStats = {
				Control = { 0.7, nil }
			},
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Base4.SeriesIndex = count
brawnIdol_Base4.Rewards = {
	{ "IdolFavor", 200 }
}
local brawnIdol_Base5 = {
	DisplayName = "Goriki Idol: True Brawn",
	Description = "Perfectly catch a fish with no typical training wheels...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 100 },
				Control = { nil, 0 }
			},
			PerfectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Base5.SeriesIndex = count
brawnIdol_Base5.Rewards = {
	{ "Charm", "Brawn Charm", 5 },
	{ "IdolFavor", 1500 }
}
local brawnIdol_Tropical = {
	DisplayName = "Goriki Idol: Resilient Brawn - Tropical Ascension",
	Description = "Catch 25 fish of moderate difficulty...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 100 }
			},
			RequiredAmount = 25,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Tropical.SeriesIndex = count
brawnIdol_Tropical.Rewards = {
	{ "IdolFavor", 30 }
}
local brawnIdol_Tropical2 = {
	DisplayName = "Goriki Idol: Enduring Brawn - Tropical Ascension",
	Description = "Catch numerous fish that fight back...",
	List = { lib.CatchFish({
			BiteStats = {
				ProgressSpeed = { nil, -60 }
			},
			RequiredAmount = 25,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Tropical2.SeriesIndex = count
brawnIdol_Tropical2.Rewards = {
	{ "IdolFavor", 180 }
}
local brawnIdol_Tropical3 = {
	DisplayName = "Goriki Idol: Refined Brawn - Tropical Ascension",
	Description = "Refine the art of the hunt...",
	DisplayList = {
		{ "Custom", 10, "<b>Directly</b> Catch 10 Hunt Fish during a Tropical Squall" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			RequiredAmount = 10,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Tropical3.SeriesIndex = count
brawnIdol_Tropical3.Rewards = {
	{ "IdolFavor", 240 }
}
local brawnIdol_Tropical4 = {
	DisplayName = "Goriki Idol: Controlled Brawn - Tropical Ascension",
	Description = "Display your maximum control potential...",
	List = { lib.CatchFish({
			BiteStats = {
				Control = { 0.7, nil }
			},
			RequiredAmount = 25,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Tropical4.SeriesIndex = count
brawnIdol_Tropical4.Rewards = {
	{ "IdolFavor", 400 }
}
local brawnIdol_Tropical5 = {
	DisplayName = "Goriki Idol: True Brawn - Tropical Ascension",
	Description = "Perfectly catch 25 fish with no typical training wheels...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 100 },
				Control = { nil, 0 }
			},
			RequiredAmount = 25,
			PerfectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Tropical5.SeriesIndex = count
brawnIdol_Tropical5.Rewards = {
	{ "Charm", "Brawn Charm", 10 },
	{ "IdolFavor", 3000 }
}
local brawnIdol_Raging = {
	DisplayName = "Goriki Idol: Resilient Brawn - Raging Ascension",
	Description = "Catch 25 fish of moderate difficulty...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 100 }
			},
			RequiredAmount = 25,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Raging.SeriesIndex = count
brawnIdol_Raging.Rewards = {
	{ "IdolFavor", 45 }
}
local brawnIdol_Raging2 = {
	DisplayName = "Goriki Idol: Enduring Brawn - Raging Ascension",
	Description = "Catch numerous fish that fight back...",
	List = { lib.CatchFish({
			BiteStats = {
				ProgressSpeed = { nil, -60 }
			},
			RequiredAmount = 10,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Raging2.SeriesIndex = count
brawnIdol_Raging2.Rewards = {
	{ "IdolFavor", 270 }
}
local brawnIdol_Raging3 = {
	DisplayName = "Goriki Idol: Refined Brawn - Raging Ascension",
	Description = "Refine the art of the hunt...",
	DisplayList = {
		{ "Custom", 3, "<b>Directly</b> Catch 3 Hunt Fish during a Raging Squall" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			RequiredAmount = 3,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Raging3.SeriesIndex = count
brawnIdol_Raging3.Rewards = {
	{ "IdolFavor", 360 }
}
local brawnIdol_Raging4 = {
	DisplayName = "Goriki Idol: Controlled Brawn - Raging Ascension",
	Description = "Display your maximum control potential...",
	List = { lib.CatchFish({
			BiteStats = {
				Control = { 0.7, nil }
			},
			RequiredAmount = 15,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Raging4.SeriesIndex = count
brawnIdol_Raging4.Rewards = {
	{ "IdolFavor", 600 }
}
local brawnIdol_Raging5 = {
	DisplayName = "Goriki Idol: True Brawn - Raging Ascension",
	Description = "Perfectly catch 25 fish with no typical training wheels...",
	List = { lib.CatchFish({
			BiteStats = {
				Resilience = { nil, 100 },
				Control = { nil, 0 }
			},
			RequiredAmount = 25,
			PerfectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
brawnIdol_Raging5.SeriesIndex = count
brawnIdol_Raging5.Rewards = {
	{ "Charm", "Brawn Charm", 15 },
	{ "IdolFavor", 4500 }
}
local BrawnIdol = {
	BrawnIdol_Base1 = brawnIdol_Base,
	BrawnIdol_Base2 = brawnIdol_Base2,
	BrawnIdol_Base3 = brawnIdol_Base3,
	BrawnIdol_Base4 = brawnIdol_Base4,
	BrawnIdol_Base5 = brawnIdol_Base5,
	BrawnIdol_Tropical1 = brawnIdol_Tropical,
	BrawnIdol_Tropical2 = brawnIdol_Tropical2,
	BrawnIdol_Tropical3 = brawnIdol_Tropical3,
	BrawnIdol_Tropical4 = brawnIdol_Tropical4,
	BrawnIdol_Tropical5 = brawnIdol_Tropical5,
	BrawnIdol_Raging1 = brawnIdol_Raging,
	BrawnIdol_Raging2 = brawnIdol_Raging2,
	BrawnIdol_Raging3 = brawnIdol_Raging3,
	BrawnIdol_Raging4 = brawnIdol_Raging4,
	BrawnIdol_Raging5 = brawnIdol_Raging5
}
local v16 = {}

for k, v17 in BrawnIdol do
	v17.QuestSeries = "BrawnIdol"
	v17.AcceptIndicatorTag = "BrawnIdol"
	v17.Icon = "rbxassetid://133117035816705"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "BrawnIdol" },
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
	BrawnIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return BrawnIdol