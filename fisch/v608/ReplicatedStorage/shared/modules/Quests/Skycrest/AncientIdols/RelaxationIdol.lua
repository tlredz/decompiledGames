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
local relaxationIdol_Base = {
	DisplayName = "Nagomi Idol: A Relaxing Moment",
	Description = "To relax is to be patient...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 60, "Stand still for 60 seconds straight" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 5 }
	}
}
count += 1
local RelaxationIdol = {
	RelaxationIdol_Base1 = relaxationIdol_Base,
	RelaxationIdol_Base2 = {
		DisplayName = "Nagomi Idol: Relaxing Companionship",
		Description = "Relax with a trusted companion...",
		List = {
			{ "Custom", 10, "Interact with a Companion 10 times" }
		},
		SeriesIndex = count,
		Rewards = {
			{ "IdolFavor", 60 }
		}
	}
}
local relaxationIdol_Base2 = {
	DisplayName = "Nagomi Idol: A Relaxing Catch",
	Description = "Back to simplicity...",
	List = { lib.CatchFishAny({
			Raritites = {
				"Common",
				"Uncommon",
				"Unusual",
				"Rare"
			},
			RequiredAmount = 20,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Base2.SeriesIndex = count
relaxationIdol_Base2.Rewards = {
	{ "IdolFavor", 250 }
}
RelaxationIdol.RelaxationIdol_Base3 = relaxationIdol_Base2
local relaxationIdol_Base3 = {
	DisplayName = "Nagomi Idol: More Relaxing Catches",
	Description = "What's more relaxing than fishing?",
	List = { lib.CatchFishCage({
			RequiredAmount = 100,
			DirectCatch = true
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Base3.SeriesIndex = count
relaxationIdol_Base3.Rewards = {
	{ "IdolFavor", 300 }
}
RelaxationIdol.RelaxationIdol_Base4 = relaxationIdol_Base3
local relaxationIdol_Base4 = {
	DisplayName = "Nagomi Idol: True Relaxation",
	Description = "Catch a particularly laid-back fish...",
	List = { lib.CatchFishCage({
			Fish = "Grandpa Horseshoe Crab",
			RequiredAmount = 1
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Base4.SeriesIndex = count
relaxationIdol_Base4.Rewards = {
	{ "Charm", "Relaxation Charm", 5 },
	{ "IdolFavor", 1500 }
}
RelaxationIdol.RelaxationIdol_Base5 = relaxationIdol_Base4
count += 1
RelaxationIdol.RelaxationIdol_Tropical1 = {
	DisplayName = "Nagomi Idol: A Relaxing Moment - Tropical Ascension",
	Description = "To relax is to be patient...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 120, "Stand still for 120 seconds straight during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 10 }
	}
}
count += 1
RelaxationIdol.RelaxationIdol_Tropical2 = {
	DisplayName = "Nagomi Idol: Relaxing Companionship - Tropical Ascension",
	Description = "Relax with a trusted companion...",
	List = {
		{ "Custom", 25, "Interact with a Companion 25 times during a Tropical Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 120 }
	}
}
local relaxationIdol_Tropical = {
	DisplayName = "Nagomi Idol: A Relaxing Catch - Tropical Ascension",
	Description = "Back to simplicity...",
	List = { lib.CatchFishAny({
			Raritites = { "Common", "Uncommon", "Unusual" },
			RequiredAmount = 50,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Tropical.SeriesIndex = count
relaxationIdol_Tropical.Rewards = {
	{ "IdolFavor", 500 }
}
RelaxationIdol.RelaxationIdol_Tropical3 = relaxationIdol_Tropical
local relaxationIdol_Tropical2 = {
	DisplayName = "Nagomi Idol: More Relaxing Catches - Tropical Ascension",
	Description = "What's more relaxing than fishing?",
	List = { lib.CatchFishCage({
			RequiredAmount = 250,
			DirectCatch = true,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Tropical2.SeriesIndex = count
relaxationIdol_Tropical2.Rewards = {
	{ "IdolFavor", 600 }
}
RelaxationIdol.RelaxationIdol_Tropical4 = relaxationIdol_Tropical2
local relaxationIdol_Tropical3 = {
	DisplayName = "Nagomi Idol: True Relaxation - Tropical Ascension",
	Description = "Catch some particularly laid-back fish...",
	List = { lib.CatchFishCage({
			Fish = "Grandpa Horseshoe Crab",
			RequiredAmount = 5,
			EventFlags = { "Tropical Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Tropical3.SeriesIndex = count
relaxationIdol_Tropical3.Rewards = {
	{ "Charm", "Relaxation Charm", 10 },
	{ "IdolFavor", 3000 }
}
RelaxationIdol.RelaxationIdol_Tropical5 = relaxationIdol_Tropical3
count += 1
RelaxationIdol.RelaxationIdol_Raging1 = {
	DisplayName = "Nagomi Idol: A Relaxing Moment - Raging Ascension",
	Description = "To relax is to be patient...",
	ResetOnRejoin = "incomplete",
	List = {
		{ "Custom", 90, "Stand still for 90 seconds straight during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 15 }
	}
}
count += 1
RelaxationIdol.RelaxationIdol_Raging2 = {
	DisplayName = "Nagomi Idol: Relaxing Companionship - Raging Ascension",
	Description = "Relax with a trusted companion...",
	List = {
		{ "Custom", 15, "Interact with a Companion 15 times during a Raging Squall" }
	},
	SeriesIndex = count,
	Rewards = {
		{ "IdolFavor", 180 }
	}
}
local relaxationIdol_Raging = {
	DisplayName = "Nagomi Idol: A Relaxing Catch - Raging Ascension",
	Description = "Back to simplicity...",
	List = { lib.CatchFishAny({
			Raritites = { "Common", "Uncommon" },
			RequiredAmount = 30,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Raging.SeriesIndex = count
relaxationIdol_Raging.Rewards = {
	{ "IdolFavor", 750 }
}
RelaxationIdol.RelaxationIdol_Raging3 = relaxationIdol_Raging
local relaxationIdol_Raging2 = {
	DisplayName = "Nagomi Idol: More Relaxing Catches - Raging Ascension",
	Description = "What's more relaxing than fishing?",
	List = { lib.CatchFishCage({
			RequiredAmount = 150,
			DirectCatch = true,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Raging2.SeriesIndex = count
relaxationIdol_Raging2.Rewards = {
	{ "IdolFavor", 900 }
}
RelaxationIdol.RelaxationIdol_Raging4 = relaxationIdol_Raging2
local relaxationIdol_Raging3 = {
	DisplayName = "Nagomi Idol: True Relaxation - Raging Ascension",
	Description = "Catch some particularly laid-back fish...",
	List = { lib.CatchFishCage({
			Fish = "Grandpa Horseshoe Crab",
			RequiredAmount = 3,
			EventFlags = { "Raging Squall" }
		}) },
	SeriesIndex = 0,
	Rewards = 0
}
count += 1
relaxationIdol_Raging3.SeriesIndex = count
relaxationIdol_Raging3.Rewards = {
	{ "Charm", "Relaxation Charm", 15 },
	{ "IdolFavor", 4500 }
}
RelaxationIdol.RelaxationIdol_Raging5 = relaxationIdol_Raging3
local v16 = {}

for k, v17 in RelaxationIdol do
	v17.QuestSeries = "RelaxationIdol"
	v17.AcceptIndicatorTag = "RelaxationIdol"
	v17.Icon = "rbxassetid://128629011009345"
	v17.IconColor = color
	v17.QuestType = "Reputation"
	v16[v17.SeriesIndex] = k

	if not v17.NavigationTargets then
		v17.NavigationTargets = {}
	end

	table.insert(v17.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "RelaxationIdol" },
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
	RelaxationIdol[v18].Prerequisites = {
		QuestComplete = v17 and { v17 } or nil,
		WorldState = i > 10 and {
			squall = "Raging Squall"
		} or i > 5 and {
			squall = "Tropical Squall"
		} or nil
	}
	v17 = v18
end

return RelaxationIdol