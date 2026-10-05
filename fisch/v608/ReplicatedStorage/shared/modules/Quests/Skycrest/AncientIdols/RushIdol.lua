local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 255, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local count = 0

local function index()
	count += 1
	return count
end

count += 1
local rushIdol_Base = {
	DisplayName = "Shunsoku Idol: Rushed Catch",
	Description = "Catch a fish in ample time...",
	List = {
		{ "Custom", 1, "<b>Directly</b> Catch a fish in under 8 seconds" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 10 }
	}
}
local rushIdol_Base2 = {
	DisplayName = "Shunsoku Idol: Rushing Potential",
	Description = "Show some simple rushing potential...",
	List = { lib.CatchFishAny({
			BiteStats = {
				ProgressSpeed = { 50 }
			},
			RequiredAmount = 20,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Base2.SeriesIndex = count
rushIdol_Base2.Rewards = {
	{ "IdolFavor", 75 }
}
local rushIdol_Base3 = {
	DisplayName = "Shunsoku Idol: Electric Rush",
	Description = "Catch the fish known for the quickest acceleration of the sea, electrified...",
	List = { lib.CatchFishAny({
			Fish = "Northern Pike",
			RequiredAttributes = {
				Mutation = { "Electric", "Electrified" }
			},
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Base3.SeriesIndex = count
rushIdol_Base3.Rewards = {
	{ "IdolFavor", 100 }
}
count += 1
local RushIdol = {
	RushIdol_Base1 = rushIdol_Base,
	RushIdol_Base2 = rushIdol_Base2,
	RushIdol_Base3 = rushIdol_Base3,
	RushIdol_Base4 = {
		DisplayName = "Shunsoku Idol: Rushed Selection",
		Description = "Those in a rush don't overvalue their catch...",
		ResetOnRejoin = "incomplete",
		List = {
			{ "Custom", 2, "<b>Directly</b> Hook 2 fish in 15 seconds" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 350 }
		}
	}
}
count += 1
RushIdol.RushIdol_Base5 = {
	DisplayName = "Shunsoku Idol: True Rush",
	Description = "Catch numerous fish in extraordinarily rapid succession...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 5, "Catch 5 fish in 15 seconds" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Rush Charm", 5 },
		{ "IdolFavor", 1500 }
	}
}
count += 1
RushIdol.RushIdol_Tropical1 = {
	DisplayName = "Shunsoku Idol: Rushed Catch - Tropical Ascension",
	Description = "Catch a fish in ample time...",
	List = {
		{ "Custom", 1, "<b>Directly</b> Catch a fish in under 5 seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 20 }
	}
}
local rushIdol_Tropical = {
	DisplayName = "Shunsoku Idol: Rushing Potential - Tropical Ascension",
	Description = "Show some simple rushing potential...",
	List = { lib.CatchFish({
			BiteStats = {
				ProgressSpeed = { 100 }
			},
			RequiredAmount = 50,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Tropical.SeriesIndex = count
rushIdol_Tropical.Rewards = {
	{ "IdolFavor", 150 }
}
RushIdol.RushIdol_Tropical2 = rushIdol_Tropical
local rushIdol_Tropical2 = {
	DisplayName = "Shunsoku Idol: Electric Rush - Tropical Ascension",
	Description = "Catch the fish known for the quickest acceleration of the sea, electrified...",
	List = { lib.CatchFishAny({
			Fish = "Northern Pike",
			RequiredAttributes = {
				Mutation = { "Electric", "Electrified" }
			},
			RequiredAmount = 5,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Tropical2.SeriesIndex = count
rushIdol_Tropical2.Rewards = {
	{ "IdolFavor", 200 }
}
RushIdol.RushIdol_Tropical3 = rushIdol_Tropical2
count += 1
RushIdol.RushIdol_Tropical4 = {
	DisplayName = "Shunsoku Idol: Rushed Selection - Tropical Ascension",
	Description = "Those in a rush don't overvalue their catch...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 2, "<b>Directly</b> Hook 2 fish in 12 seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 700 }
	}
}
count += 1
RushIdol.RushIdol_Tropical5 = {
	DisplayName = "Shunsoku Idol: True Rush - Tropical Ascension",
	Description = "Catch numerous fish in extraordinarily rapid succession...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 5, "Catch 5 fish in 5 seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Rush Charm", 10 },
		{ "IdolFavor", 3000 }
	}
}
count += 1
RushIdol.RushIdol_Raging1 = {
	DisplayName = "Shunsoku Idol: Rushed Catch - Raging Ascension",
	Description = "Catch a fish in ample time...",
	List = {
		{ "Custom", 1, "<b>Directly</b> Catch a fish in under 3 seconds during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 30 }
	}
}
local rushIdol_Raging = {
	DisplayName = "Shunsoku Idol: Rushing Potential - Raging Ascension",
	Description = "Show some simple rushing potential...",
	List = { lib.CatchFish({
			BiteStats = {
				ProgressSpeed = { 200 }
			},
			RequiredAmount = 10,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Raging.SeriesIndex = count
rushIdol_Raging.Rewards = {
	{ "IdolFavor", 225 }
}
RushIdol.RushIdol_Raging2 = rushIdol_Raging
local rushIdol_Raging2 = {
	DisplayName = "Shunsoku Idol: Electric Rush - Raging Ascension",
	Description = "Catch the fish known for the quickest acceleration of the sea, electrified and glistening...",
	List = { lib.CatchFishAny({
			Fish = "Northern Pike",
			RequiredAttributes = {
				Mutation = { "Electric", "Electrified" },
				ShinyOrSparkling = true
			},
			RequiredAmount = 1,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
rushIdol_Raging2.SeriesIndex = count
rushIdol_Raging2.Rewards = {
	{ "IdolFavor", 300 }
}
RushIdol.RushIdol_Raging3 = rushIdol_Raging2
count += 1
RushIdol.RushIdol_Raging4 = {
	DisplayName = "Shunsoku Idol: Rushed Selection - Raging Ascension",
	Description = "Those in a rush don't overvalue their catch...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 2, "<b>Directly</b> Hook 2 fish in 7 seconds during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 1050 }
	}
}
count += 1
RushIdol.RushIdol_Raging5 = {
	DisplayName = "Shunsoku Idol: True Rush - Raging Ascension",
	Description = "Catch numerous fish in extraordinarily rapid succession...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 5, "Catch 5 fish in 1 second during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Rush Charm", 15 },
		{ "IdolFavor", 4500 }
	}
}
local v16 = {}

for k, v17 in RushIdol do
	v17.QuestSeries = "RushIdol"
	v17.AcceptIndicatorTag = "RushIdol"
	v17.Icon = "rbxassetid://111467438627174"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "RushIdol" },
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
	RushIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return RushIdol