local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(255, 255, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local count = 0

local function index()
	count += 1
	return count
end

local fortuneIdol_Base = {
	DisplayName = "Ebisu Idol: Legendary Fortune",
	Description = "Fetch a notably rare fish...",
	List = { lib.ObtainItem({
			Fish = {
				"Hawaiian Ventralis Anthias",
				"Vibranium Fairy Wrasse",
				"Aphrodite Anthias",
				"Rose-Veiled Fairy Wrasse"
			},
			RequiredAmount = 1,
			ForNpc = "Ebisu Idol"
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Base.SeriesIndex = count
fortuneIdol_Base.Rewards = {
	{ "IdolFavor", 10 }
}
local fortuneIdol_Base2 = {
	DisplayName = "Ebisu Idol: Glistening Fortune",
	Description = "Fetch an exceptionally rare glistening fish...",
	List = { lib.ObtainItem({
			Item = { "Aphrodite Anthias", "Rose-Veiled Fairy Wrasse" },
			RequiredAttributes = {
				Sparkling = true
			},
			RequiredAmount = 1,
			ForNpc = "Ebisu Idol"
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Base2.SeriesIndex = count
fortuneIdol_Base2.Rewards = {
	{ "IdolFavor", 80 }
}
count += 1
local FortuneIdol = {
	FortuneIdol_Base1 = fortuneIdol_Base,
	FortuneIdol_Base2 = fortuneIdol_Base2,
	FortuneIdol_Base3 = {
		DisplayName = "Ebisu Idol: Fortunate Bargain",
		Description = "Appraise a fish, and receive a mutation of astonishing rarity or value...",
		List = {
			{ "Custom", 1, "Receive 1 rare mutation via appraisal" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 180 }
		}
	}
}
count += 1
FortuneIdol.FortuneIdol_Base4 = {
	DisplayName = "Ebisu Idol: Fortunate Find",
	Description = "Speak to the treasures...",
	List = {
		{ "Custom", 1, "Open 1 Treasure Chest" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 250 }
	}
}
count += 1
FortuneIdol.FortuneIdol_Base5 = {
	DisplayName = "Ebisu Idol: True Fortune",
	Description = "Reel in a catch worth a fortune...",
	List = {
		{ "Custom", 1, "Catch 1 fish worth more than 100,000 C$" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Fortune Charm", 5 },
		{ "IdolFavor", 1500 }
	}
}
local fortuneIdol_Tropical = {
	DisplayName = "Ebisu Idol: Legendary Fortune - Tropical Ascension",
	Description = "Fetch 25 notably rare fish...",
	List = { lib.CatchFishAny({
			Raritites = { "Legendary", "Mythical" },
			PlayerZones = { "Skycrest" },
			RequiredAmount = 25,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Tropical.SeriesIndex = count
fortuneIdol_Tropical.Rewards = {
	{ "IdolFavor", 20 }
}
FortuneIdol.FortuneIdol_Tropical1 = fortuneIdol_Tropical
local fortuneIdol_Tropical2 = {
	DisplayName = "Ebisu Idol: Glistening Fortune - Tropical Ascension",
	Description = "Fetch 10 exceptionally rare glistening fish...",
	List = { lib.CatchFishAny({
			Raritites = { "Mythical" },
			RequiredAttributes = {
				ShinyOrSparkling = true
			},
			RequiredAmount = 10,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Tropical2.SeriesIndex = count
fortuneIdol_Tropical2.Rewards = {
	{ "IdolFavor", 160 }
}
FortuneIdol.FortuneIdol_Tropical2 = fortuneIdol_Tropical2
count += 1
FortuneIdol.FortuneIdol_Tropical3 = {
	DisplayName = "Ebisu Idol: Fortunate Bargain - Tropical Ascension",
	Description = "Appraise a fish, and receive a mutation of astonishing rarity or value 10 times...",
	List = {
		{ "Custom", 10, "Receive 10 rare mutations via appraisal during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 360 }
	}
}
count += 1
FortuneIdol.FortuneIdol_Tropical4 = {
	DisplayName = "Ebisu Idol: Fortunate Find - Tropical Ascension",
	Description = "Speak to the treasures...",
	List = {
		{ "Custom", 10, "Open 10 Treasure Chests during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 500 }
	}
}
count += 1
FortuneIdol.FortuneIdol_Tropical5 = {
	DisplayName = "Ebisu Idol: True Fortune - Tropical Ascension",
	Description = "Reel in a haul worth a fortune...",
	List = {
		{ "Custom", 10, "Catch 10 fish worth more than 100,000 C$ during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Fortune Charm", 10 },
		{ "IdolFavor", 3000 }
	}
}
local fortuneIdol_Raging = {
	DisplayName = "Ebisu Idol: Legendary Fortune - Raging Ascension",
	Description = "Fetch 5 notably rare fish...",
	List = { lib.CatchFishAny({
			Raritites = { "Legendary", "Mythical" },
			PlayerZones = { "Skycrest" },
			RequiredAmount = 5,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Raging.SeriesIndex = count
fortuneIdol_Raging.Rewards = {
	{ "IdolFavor", 30 }
}
FortuneIdol.FortuneIdol_Raging1 = fortuneIdol_Raging
local fortuneIdol_Raging2 = {
	DisplayName = "Ebisu Idol: Glistening Fortune - Raging Ascension",
	Description = "Fetch 3 exceptionally rare glistening fish...",
	List = { lib.CatchFishAny({
			Raritites = { "Mythical" },
			RequiredAttributes = {
				ShinyOrSparkling = true
			},
			RequiredAmount = 3,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
fortuneIdol_Raging2.SeriesIndex = count
fortuneIdol_Raging2.Rewards = {
	{ "IdolFavor", 240 }
}
FortuneIdol.FortuneIdol_Raging2 = fortuneIdol_Raging2
count += 1
FortuneIdol.FortuneIdol_Raging3 = {
	DisplayName = "Ebisu Idol: Fortunate Bargain - Raging Ascension",
	Description = "Appraise a fish, and receive a mutation of astonishing rarity or value 2 times...",
	List = {
		{ "Custom", 2, "Receive 2 rare mutations via appraisal during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 540 }
	}
}
count += 1
FortuneIdol.FortuneIdol_Raging4 = {
	DisplayName = "Ebisu Idol: Fortunate Find - Raging Ascension",
	Description = "Speak to the treasures...",
	List = {
		{ "Custom", 5, "Open 5 Treasure Chests during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 750 }
	}
}
count += 1
FortuneIdol.FortuneIdol_Raging5 = {
	DisplayName = "Ebisu Idol: True Fortune - Raging Ascension",
	Description = "Reel in a haul worth a fortune...",
	List = {
		{ "Custom", 3, "Catch 3 fish worth more than 100,000 C$ during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "Charm", "Fortune Charm", 15 },
		{ "IdolFavor", 4500 }
	}
}
local v16 = {}

for k, v17 in FortuneIdol do
	v17.QuestSeries = "FortuneIdol"
	v17.AcceptIndicatorTag = "FortuneIdol"
	v17.Icon = "rbxassetid://127616480328932"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "FortuneIdol" },
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
	FortuneIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return FortuneIdol