local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 243, 243)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local count = 0

local function index()
	count += 1
	return count
end

count += 1
local pesterIdol_Base = {
	DisplayName = "Amanojaku Idol: Pestering Danger",
	Description = "Find your familiarity with danger...",
	List = {
		{ "Custom", 10, "Catch 10 fish at any active hunt" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 20 }
	}
}
count += 1
local PesterIdol = {
	PesterIdol_Base1 = pesterIdol_Base,
	PesterIdol_Base2 = {
		DisplayName = "Amanojaku Idol: Pestering Slash",
		Description = "Practice your slashing...",
		List = {
			{ "Custom", 100, "Slash a fish 100 times" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 100 }
		}
	}
}
count += 1
PesterIdol.PesterIdol_Base3 = {
	DisplayName = "Amanojaku Idol: Awakening Pester",
	Description = "Be the reason danger awakens...",
	List = {
		{ "Custom", 1, "Summon 1 hunt via Disturbance" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 150 }
	}
}
local pesterIdol_Base2 = {
	DisplayName = "Amanojaku Idol: Disturbing Pester",
	Description = "To pester... To disturb...",
	List = { lib.CatchFishAny({
			RequiredAmount = 15,
			BiteStats = {
				Disturbance = { 10 }
			},
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
pesterIdol_Base2.SeriesIndex = count
pesterIdol_Base2.Rewards = {
	{ "IdolFavor", 250 }
}
PesterIdol.PesterIdol_Base4 = pesterIdol_Base2
count += 1
PesterIdol.PesterIdol_Base5 = {
	DisplayName = "Amanojaku Idol: True Pester",
	Description = "Catch multiple fish of danger in ample time...",
	List = {
		{ "Custom", 5, "Catch 5 hunt fish in 10 minutes" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Pester Charm", 5 },
		{ "IdolFavor", 1500 }
	}
}
count += 1
PesterIdol.PesterIdol_Tropical1 = {
	DisplayName = "Amanojaku Idol: Pestering Danger - Tropical Ascension",
	Description = "Find your familiarity with danger...",
	List = {
		{ "Custom", 25, "Catch 25 fish at any active hunt during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 40 }
	}
}
count += 1
PesterIdol.PesterIdol_Tropical2 = {
	DisplayName = "Amanojaku Idol: Pestering Slash - Tropical Ascension",
	Description = "Practice your slashing...",
	List = {
		{ "Custom", 250, "Slash a fish 250 times during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 200 }
	}
}
count += 1
PesterIdol.PesterIdol_Tropical3 = {
	DisplayName = "Amanojaku Idol: Awakening Pester - Tropical Ascension",
	Description = "Be the reason danger awakens...",
	List = {
		{ "Custom", 5, "Summon 5 hunts via Disturbance during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 300 }
	}
}
local pesterIdol_Tropical = {
	DisplayName = "Amanojaku Idol: Disturbing Pester - Tropical Ascension",
	Description = "To pester... To disturb...",
	List = { lib.CatchFishAny({
			RequiredAmount = 50,
			BiteStats = {
				Disturbance = { 15 }
			},
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
pesterIdol_Tropical.SeriesIndex = count
pesterIdol_Tropical.Rewards = {
	{ "IdolFavor", 500 }
}
PesterIdol.PesterIdol_Tropical4 = pesterIdol_Tropical
count += 1
PesterIdol.PesterIdol_Tropical5 = {
	DisplayName = "Amanojaku Idol: True Pester - Tropical Ascension",
	Description = "Catch multiple fish of danger in ample time...",
	List = {
		{ "Custom", 3, "<b>Directly</b> catch 3 hunt fish in 10 minutes during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Pester Charm", 10 },
		{ "IdolFavor", 3000 }
	}
}
count += 1
PesterIdol.PesterIdol_Raging1 = {
	DisplayName = "Amanojaku Idol: Pestering Danger - Raging Ascension",
	Description = "Find your familiarity with danger...",
	List = {
		{ "Custom", 15, "<b>Perfect</b> Catch 15 fish at any active hunt during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 60 }
	}
}
count += 1
PesterIdol.PesterIdol_Raging2 = {
	DisplayName = "Amanojaku Idol: Pestering Slash - Raging Ascension",
	Description = "Practice your slashing...",
	List = {
		{ "Custom", 200, "Slash a fish 200 times during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 300 }
	}
}
count += 1
PesterIdol.PesterIdol_Raging3 = {
	DisplayName = "Amanojaku Idol: Awakening Pester - Raging Ascension",
	Description = "Be the reason danger awakens...",
	List = {
		{ "Custom", 2, "Summon 2 hunts via Disturbance during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 450 }
	}
}
local pesterIdol_Raging = {
	DisplayName = "Amanojaku Idol: Disturbing Pester - Raging Ascension",
	Description = "To pester... To disturb...",
	List = { lib.CatchFishAny({
			RequiredAmount = 5,
			BiteStats = {
				Disturbance = { 25 }
			},
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
pesterIdol_Raging.SeriesIndex = count
pesterIdol_Raging.Rewards = {
	{ "IdolFavor", 750 }
}
PesterIdol.PesterIdol_Raging4 = pesterIdol_Raging
count += 1
PesterIdol.PesterIdol_Raging5 = {
	DisplayName = "Amanojaku Idol: True Pester - Raging Ascension",
	Description = "Catch multiple fish of danger in ample time...",
	List = {
		{ "Custom", 3, "<b>Directly</b> catch 3 hunt fish in 10 minutes during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Pester Charm", 15 },
		{ "IdolFavor", 4500 }
	}
}
local v16 = {}

for k, v17 in PesterIdol do
	v17.QuestSeries = "PesterIdol"
	v17.AcceptIndicatorTag = "PesterIdol"
	v17.Icon = "rbxassetid://128250028410271"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "PesterIdol" },
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
	PesterIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return PesterIdol