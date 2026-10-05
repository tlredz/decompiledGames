local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(97, 197, 255)
local v = {
	"Prism Scale",
	"Bone Shard",
	"Bio-Fluid",
	"Chitin Plate",
	"Salvage Scrap"
}
local v2 = {
	"Radiant Prism Scale",
	"Abyssal Bio-Fluid",
	"Hardened Chitin",
	"Refined Scrap",
	"Ancient Bone"
}

local function relayMaterialList()
	local result = {}

	for _, v3 in v do
		table.insert(result, module.ObtainItem({
			Item = v3,
			RequiredAmount = 15,
			ForNpc = "Nereus",
			AndReturn = true
		}))
	end

	for _, v3 in v2 do
		table.insert(result, module.ObtainItem({
			Item = v3,
			RequiredAmount = 3,
			ForNpc = "Nereus",
			AndReturn = true
		}))
	end

	return result
end

local _ = {
	PrismScale = "Prism Scale",
	BoneShard = "Bone Shard",
	BioFluid = "Bio-Fluid",
	ChitinPlate = "Chitin Plate",
	SalvageScrap = "Salvage Scrap",
	AncientBone = "Ancient Bone",
	RadiantPrismScale = "Radiant Prism Scale",
	AbyssalBioFluid = "Abyssal Bio-Fluid",
	HardenedChitin = "Hardened Chitin",
	RefinedScrap = "Refined Scrap"
}

local function beaconQuest(p: string, p2: string, acceptIndicatorTag: string, items, rewards)
	local list = {}

	for _, item in items do
		table.insert(list, module.ObtainItem({
			Item = item[1],
			RequiredAmount = item[2],
			ForNpc = item[3],
			AndReturn = true
		}))
	end

	table.insert(list, { "Custom", true, (`Install the {p2} in Sector {p}`) })
	return {
		DisplayName = `The Deep Main Quest: Restoring {p}`,
		QuestType = "Major",
		Icon = "rbxassetid://79523391252060",
		IconColor = color,
		Description = `Sector {p} is dark. Gather what the specialist needs to synthesize the {p2}, then bring it to the sector tower.`,
		CompletedDescription = `Sector {p} is lit. Report back if anything else needs restoring.`,
		AutoNavigate = true,
		AcceptIndicatorTag = acceptIndicatorTag,
		NavigationTargets = {
			{
				Zone = "Outer Deep",
				Tags = { acceptIndicatorTag },
				Objectives = { 1 }
			},
			{
				Zone = "Outer Deep",
				Tags = { (`DeepBeaconTower_{p}`) },
				Objectives = { #list }
			}
		},
		Prerequisites = {
			QuestComplete = { "Deep2_Descent" }
		},
		List = list,
		Rewards = rewards
	}
end

local count = 0

local function seriesIndex()
	count += 1
	return count
end

local TheDeepMainQuests = {
	Deep0_Equipping = {
		DisplayName = "The Deep Main Quest: Equipping the Abyss",
		QuestType = "Major",
		Icon = "rbxassetid://79523391252060",
		IconColor = color,
		CompletedDescription = "You're geared up. Head back to Cadet Shimmerfin.",
		AutoNavigate = true,
		AcceptIndicatorTag = "CadetShimmerfin",
		NavigationTargets = {
			{
				Zone = "Ocean",
				Tags = { "CadetShimmerfin" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", true, "Equip any Diving Gear" },
			{ "Custom", true, "Equip any Flippers" }
		},
		Rewards = {}
	}
}
local deep1_Signal = {
	DisplayName = "The Deep Main Quest: A Signal Below",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	CompletedDescription = "You found the city. Someone down here must know what happened.",
	AutoNavigate = true,
	AcceptIndicatorTag = "CadetShimmerfin",
	NavigationTargets = {
		{
			Zone = "Deep City",
			Tags = { "ChiefEngineerNereus" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "The Deep Main Quest",
	SeriesIndex = 0,
	List = 0,
	DisplayRewardsFrom = "Deep2_Descent",
	Rewards = 0
}
count += 1
deep1_Signal.SeriesIndex = count
deep1_Signal.List = {
	{ "Custom", true, "Dive into the trench and find what lies below" }
}
deep1_Signal.Rewards = {
	{ "Xp", 3000 }
}
TheDeepMainQuests.Deep1_Signal = deep1_Signal
local deep2_Descent = {
	DisplayName = "The Deep Main Quest: The Fading Grid",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	AutoNavigate = true,
	AcceptIndicatorTag = "ChiefEngineerNereus",
	NavigationTargets = {
		{
			Zone = "Deep City",
			Tags = { "ChiefEngineerNereus" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "The Deep Main Quest",
	SeriesIndex = 0,
	List = 0,
	Rewards = 0
}
count += 1
deep2_Descent.SeriesIndex = count
deep2_Descent.List = {
	{ "Custom", true, "Let Chief Engineer Nereus restore the Survey Device" }
}
deep2_Descent.Rewards = {
	{
		"ItemOrFish",
		"Deep Survey Device MK I",
		nil,
		1
	},
	{ "Xp", 8000 }
}
TheDeepMainQuests.Deep2_Descent = deep2_Descent
TheDeepMainQuests.Deep3_Core1 = beaconQuest("1P-1", "Hydro-Core", "DeepHunterDan", {
	{ "Bone Shard", 10, "Hunter Dan" },
	{ "Prism Scale", 5, "Hunter Dan" },
	{ "Abyssal Bio-Fluid", 1, "Hunter Dan" }
}, {
	{ "Currency", "Coins", 12000 },
	{ "Xp", 6000 }
})
TheDeepMainQuests.Deep3_Core2 = beaconQuest("1P-2", "Abyssal Lens", "DeepCartographer", {
	{ "Prism Scale", 15, "The Cartographer" },
	{ "Bio-Fluid", 10, "The Cartographer" },
	{ "Ancient Bone", 1, "The Cartographer" }
}, {
	{ "Currency", "Coins", 14000 },
	{ "Xp", 6500 }
})
TheDeepMainQuests.Deep3_Core3 = beaconQuest("1P-3", "Bioluminescent Battery", "DeepDrVane", {
	{ "Bone Shard", 20, "Dr. Vane" },
	{ "Salvage Scrap", 15, "Dr. Vane" },
	{ "Radiant Prism Scale", 1, "Dr. Vane" }
}, {
	{ "Currency", "Coins", 16000 },
	{ "Xp", 7000 }
})
TheDeepMainQuests.Deep3_Core4 = beaconQuest("1P-4", "Reinforced Housing", "DeepSledge", {
	{ "Chitin Plate", 25, "Sledge" },
	{ "Salvage Scrap", 20, "Sledge" },
	{ "Refined Scrap", 1, "Sledge" },
	{ "Hardened Chitin", 1, "Sledge" }
}, {
	{ "Currency", "Coins", 18000 },
	{ "Xp", 7500 }
})
local deep4_Materials = {
	DisplayName = "The Deep Main Quest: The Master Relay",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	Description = "Beacon 1P-5 bridges the city to everything below it. Nereus needs a full spread of materials to bring it up.",
	CompletedDescription = "Nereus has everything he needs. Head back to him.",
	AutoNavigate = true,
	AcceptIndicatorTag = "ChiefEngineerNereus",
	NavigationTargets = {
		{
			Zone = "Deep City",
			Tags = { "ChiefEngineerNereus" },
			AllComplete = true
		}
	},
	QuestSeries = "The Deep Main Quest",
	SeriesIndex = 0,
	Prerequisites = 0,
	List = 0,
	DisplayRewardsFrom = "Deep4_MasterRelay",
	Rewards = 0
}
count += 1
deep4_Materials.SeriesIndex = count
deep4_Materials.Prerequisites = {
	QuestComplete = {
		"Deep3_Core1",
		"Deep3_Core2",
		"Deep3_Core3",
		"Deep3_Core4"
	}
}
deep4_Materials.List = relayMaterialList()
deep4_Materials.Rewards = {
	{ "Xp", 10000 }
}
TheDeepMainQuests.Deep4_Materials = deep4_Materials
local deep4_MasterRelay = {
	DisplayName = "The Deep Main Quest: The Master Relay",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	Description = "The relay core is assembled. Bring it up at the Master Relay Tower on the edge of the drop-off.",
	AutoNavigate = true,
	AcceptIndicatorTag = "ChiefEngineerNereus",
	NavigationTargets = {
		{
			Zone = "Outer Deep",
			Tags = { "DeepBeaconTower_1P-5" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "The Deep Main Quest",
	SeriesIndex = 0,
	List = 0,
	Rewards = 0
}
count += 1
deep4_MasterRelay.SeriesIndex = count
deep4_MasterRelay.List = {
	{ "Custom", true, "Bring up the Master Relay Tower" }
}
deep4_MasterRelay.Rewards = {
	{
		"ItemOrFish",
		"Deep Survey Device MK II",
		nil,
		1
	},
	{ "Currency", "Coins", 40000 },
	{ "Xp", 20000 }
}
TheDeepMainQuests.Deep4_MasterRelay = deep4_MasterRelay
local deep5_Crevice = {
	DisplayName = "The Deep Main Quest: Into the Gloomy Crevice",
	QuestType = "Major",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	Description = "Power telemetry points at heavy damage down in the Gloomy Crevice. Light the place up and survey the pillars that came down.",
	CompletedDescription = "You surveyed all four pillars. Nereus will want to hear about this.",
	AutoNavigate = true,
	AcceptIndicatorTag = "ChiefEngineerNereus",
	NavigationTargets = {
		{
			Zone = "Gloomy Crevice",
			Tags = { "DeepInvestigationSite" },
			Objectives = { 1 }
		},
		{
			Zone = "Deep City",
			Tags = { "ChiefEngineerNereus" },
			AllComplete = true
		}
	},
	QuestSeries = "The Deep Main Quest",
	SeriesIndex = 0,
	List = 0,
	Rewards = 0
}
count += 1
deep5_Crevice.SeriesIndex = count
deep5_Crevice.List = {
	{ "Custom", 4, "Survey the collapsed pillars in the Gloomy Crevice" }
}
deep5_Crevice.Rewards = {
	{ "Currency", "Coins", 25000 },
	{ "Xp", 12000 }
}
TheDeepMainQuests.Deep5_Crevice = deep5_Crevice
local v8 = {}

for k, v9 in TheDeepMainQuests do
	if v9.SeriesIndex then
		v8[v9.SeriesIndex] = k
	end
end

for k, v9 in v8 do
	local v10 = v8[k - 1]

	if not v10 then
		continue
	end

	local v11 = TheDeepMainQuests[v9]

	if not v11.Prerequisites then
		v11.Prerequisites = {
			QuestComplete = { v10 }
		}
	end
end

return TheDeepMainQuests