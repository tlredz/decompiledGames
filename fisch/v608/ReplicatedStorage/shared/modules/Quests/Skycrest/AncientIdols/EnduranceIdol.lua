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
local enduranceIdol_Base = {
	DisplayName = "Fudo Idol: Consistent Endurance",
	Description = "Perfectly catch a few fish with no error between...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 5, "Perfect Catch 5 fish in a row" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 25 }
	}
}
count += 1
local EnduranceIdol = {
	EnduranceIdol_Base1 = enduranceIdol_Base,
	EnduranceIdol_Base2 = {
		DisplayName = "Fudo Idol: Persistent Endurance",
		Description = "Prove your willingness to endure and strictly withstand...",
		List = {
			{ "Custom", 1, "Maintain a catch minigame against a Common fish for 60+ seconds" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 60 }
		}
	}
}
count += 1
EnduranceIdol.EnduranceIdol_Base3 = {
	DisplayName = "Fudo Idol: Precise Endurance",
	Description = "Display adequate casting and catching skills...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 10, "Perfect Cast and Perfect Catch 10 fish in a row" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 150 }
	}
}
local enduranceIdol_Base2 = {
	DisplayName = "Fudo Idol: Weighty Endurance",
	Description = "Show your ability to withstand larger catches...",
	List = { lib.CatchFishAny({
			PlayerZones = { "Skycrest" },
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 10,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Base2.SeriesIndex = count
enduranceIdol_Base2.Rewards = {
	{ "IdolFavor", 450 }
}
EnduranceIdol.EnduranceIdol_Base4 = enduranceIdol_Base2
local enduranceIdol_Base3 = {
	DisplayName = "Fudo Idol: True Endurance",
	Description = "Perfectly catch a fish of true power with the Artisan Rod, to test your versatility...",
	DisplayList = {
		{ "Custom", 1, "<b>Perfect</b> Catch any Hunt Fish with Artisan Rod" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			Rods = "Artisan Rod",
			RequiredAmount = 1,
			PerfectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Base3.SeriesIndex = count
enduranceIdol_Base3.Rewards = {
	{ "Charm", "Endurance Charm", 5 },
	{ "IdolFavor", 1500 }
}
EnduranceIdol.EnduranceIdol_Base5 = enduranceIdol_Base3
count += 1
EnduranceIdol.EnduranceIdol_Tropical1 = {
	DisplayName = "Fudo Idol: Consistent Endurance - Tropical Ascension",
	Description = "Perfectly catch several fish with no error between...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 25, "Perfect Catch 25 fish in a row during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 50 }
	}
}
count += 1
EnduranceIdol.EnduranceIdol_Tropical2 = {
	DisplayName = "Fudo Idol: Persistent Endurance - Tropical Ascension",
	Description = "Prove your willingness to endure and strictly withstand...",
	List = {
		{ "Custom", 3, "Maintain a catch minigame against 3 Common fish for 60+ seconds during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 120 }
	}
}
count += 1
EnduranceIdol.EnduranceIdol_Tropical3 = {
	DisplayName = "Fudo Idol: Precise Endurance - Tropical Ascension",
	Description = "Display superior casting and catching skills...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 25, "Perfect Cast and Perfect Catch 25 fish in a row during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 300 }
	}
}
local enduranceIdol_Tropical = {
	DisplayName = "Fudo Idol: Weighty Endurance - Tropical Ascension",
	Description = "Show your ability to withstand larger catches...",
	List = { lib.CatchFishAny({
			PlayerZones = { "Skycrest" },
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 25,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Tropical.SeriesIndex = count
enduranceIdol_Tropical.Rewards = {
	{ "IdolFavor", 900 }
}
EnduranceIdol.EnduranceIdol_Tropical4 = enduranceIdol_Tropical
local enduranceIdol_Tropical2 = {
	DisplayName = "Fudo Idol: True Endurance - Tropical Ascension",
	Description = "Perfectly catch a fish of true power with the Artisan Rod, to test your versatility...",
	DisplayList = {
		{ "Custom", 3, "<b>Perfect</b> Catch 3 of any Hunt Fish with Artisan Rod during a Tropical Squall" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			Rods = "Artisan Rod",
			RequiredAmount = 3,
			PerfectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Tropical2.SeriesIndex = count
enduranceIdol_Tropical2.Rewards = {
	{ "Charm", "Endurance Charm", 10 },
	{ "IdolFavor", 3000 }
}
EnduranceIdol.EnduranceIdol_Tropical5 = enduranceIdol_Tropical2
count += 1
EnduranceIdol.EnduranceIdol_Raging1 = {
	DisplayName = "Fudo Idol: Consistent Endurance - Raging Ascension",
	Description = "Perfectly catch several fish with no error between...",
	List = {
		{ "Custom", 15, "Perfect Catch 15 fish in a row during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 75 }
	}
}
count += 1
EnduranceIdol.EnduranceIdol_Raging2 = {
	DisplayName = "Fudo Idol: Persistent Endurance - Raging Ascension",
	Description = "Prove your willingness to endure and strictly withstand...",
	List = {
		{ "Custom", 2, "Maintain a catch minigame against 2 Common fish for 60+ seconds during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 180 }
	}
}
count += 1
EnduranceIdol.EnduranceIdol_Raging3 = {
	DisplayName = "Fudo Idol: Precise Endurance - Raging Ascension",
	Description = "Display masterful casting and catching skills...",
	List = {
		{ "Custom", 10, "Perfect Cast and Perfect Catch 10 fish in a row during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 450 }
	}
}
local enduranceIdol_Raging = {
	DisplayName = "Fudo Idol: Weighty Endurance - Raging Ascension",
	Description = "Show your ability to withstand larger catches...",
	List = { lib.CatchFishAny({
			PlayerZones = { "Skycrest" },
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			RequiredAmount = 15,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Raging.SeriesIndex = count
enduranceIdol_Raging.Rewards = {
	{ "IdolFavor", 1350 }
}
EnduranceIdol.EnduranceIdol_Raging4 = enduranceIdol_Raging
local enduranceIdol_Raging2 = {
	DisplayName = "Fudo Idol: True Endurance - Raging Ascension",
	Description = "Perfectly catch a fish of true power with the Artisan Rod, to test your versatility...",
	DisplayList = {
		{ "Custom", 1, "<b>Perfect</b> Catch any Hunt Fish with Artisan Rod during a Raging Squall" }
	},
	List = { lib.CatchFish({
			Fish = lib.AllHuntFish(),
			Rods = "Artisan Rod",
			RequiredAmount = 1,
			PerfectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
enduranceIdol_Raging2.SeriesIndex = count
enduranceIdol_Raging2.Rewards = {
	{ "Charm", "Endurance Charm", 15 },
	{ "IdolFavor", 4500 }
}
EnduranceIdol.EnduranceIdol_Raging5 = enduranceIdol_Raging2
local v16 = {}

for k, v17 in EnduranceIdol do
	v17.QuestSeries = "EnduranceIdol"
	v17.AcceptIndicatorTag = "EnduranceIdol"
	v17.Icon = "rbxassetid://89016904991149"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "EnduranceIdol" },
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
	EnduranceIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return EnduranceIdol