local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 223, 167)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local drylands1_MagCore = {
	DisplayName = "Drylands: Shopping Errand",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	AcceptIndicatorTag = "PaleontologistPetri",
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "MagnetiteCorePurchase" },
			Objectives = { 1 }
		},
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			AllComplete = true
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	Prerequisites = {
		Level = 200
	},
	List = { module.ObtainItem({
			Item = "Unrefined Magnetite Core",
			RequiredAmount = 1,
			ForNpc = "Paleontologist Petri"
		}) },
	Rewards = {
		{ "Bobber", "Sand Sifter" },
		{
			"ItemOrFish",
			"Mysterious Spine",
			{},
			1
		}
	}
}
count += 1
local DrylandsQuests = {
	Drylands1_MagCore = drylands1_MagCore,
	Drylands2_GatherIngredients = {
		DisplayName = "Drylands: Mysterious Marrow",
		QuestType = "Major",
		Icon = "",
		IconColor = color,
		AutoNavigate = true,
		AcceptIndicatorTag = "PaleontologistPetri",
		NavigationTargets = {
			{
				Zone = "Dunehaven",
				Tags = { "MysteriousSkullPurchase" },
				Objectives = { 1 }
			},
			{
				Zone = "Ancient Isle",
				Tags = { "AnalystArchaeologist" },
				Objectives = { 3 }
			}
		},
		QuestSeries = "Drylands",
		SeriesIndex = count,
		AutoComplete = true,
		AutoAdvance = true,
		List = { module.ObtainItem({
				Item = "Mysterious Skull",
				RequiredAmount = 1
			}), module.ObtainItem({
				Item = "Mysterious Spine",
				RequiredAmount = 1
			}), module.ObtainItem({
				Item = "Mysterious Fang",
				RequiredAmount = 1
			}) },
		DisplayRewardsFrom = "Drylands2_ReportBack",
		Rewards = {}
	}
}
count += 1
DrylandsQuests.Drylands2_CraftRod = {
	DisplayName = "Drylands: Mysterious Marrow",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Ancient Archives",
			Tags = { "RodCrafting" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoComplete = true,
	AutoAdvance = true,
	List = {
		{ "Custom", true, "Craft the Marrow Rod at Ancient Archives" }
	},
	DisplayRewardsFrom = "Drylands2_ReportBack",
	Rewards = {}
}
count += 1
DrylandsQuests.Drylands2_ReportBack = {
	DisplayName = "Drylands: Mysterious Marrow",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	List = {
		{ "Custom", true, "Report back to Paleontologist Petri" }
	},
	Rewards = {}
}
count += 1
DrylandsQuests.Drylands3_FossilRetrieval = {
	DisplayName = "Drylands: Fossil Retrieval",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Drylands",
			Tags = { "ExampleSandZone" },
			Objectives = { 1 }
		},
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			AllComplete = true
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	DisplayList = {
		{ "Custom", 15, "Catch and return 15 unique fossil fish from the Drylands" }
	},
	List = { module.CatchFishAny({
			Fish = {
				"Calcified Trilobite",
				"Petrified Ammonite",
				"Bone-Plate Dace",
				"Silt-Crusted Carp",
				"Shard-Tooth Salmon",
				"Marrow Pike",
				"Duneseat Crustacean",
				"Strata-Bound Bass",
				"Dune-Stalker Eel",
				"Ancient Coelacanth",
				"Sunder-Whelp Jaw",
				"Terrosunder Skull"
			},
			RequiredAmount = 15,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Dune Goggles",
			{},
			1
		}
	}
}
count += 1
DrylandsQuests.Drylands4_CactusThing = {
	DisplayName = "Drylands: Botanical Synthesis",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Drylands",
			Tags = { "Cactus" },
			Objectives = { 1 }
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	AutoComplete = true,
	List = {
		{ "Custom", 20, "Harvest 20 Cacti Pulps" }
	},
	DisplayRewardsFrom = "Drylands4_ReportBack",
	Rewards = {}
}
count += 1
DrylandsQuests.Drylands4_ReportBack = {
	DisplayName = "Drylands: Botanical Synthesis",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" }
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	List = {
		{ "Custom", true, "Report back to Paleontologist Petri" }
	},
	Rewards = {
		{
			"ItemOrFish",
			"Dune Boots",
			{},
			1
		}
	}
}
count += 1
DrylandsQuests.Drylands5_AwakenSerum = {
	DisplayName = "Drylands: The Awakening Serum",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			AllComplete = true
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	AutoAdvance = true,
	DisplayList = {
		{ "Custom", 1, "Catch and return 1 Terrosunder during a Dust Storm" },
		{ "Custom", 5, "Catch and return 5 unique fish from the Claypans during Torrential Rain" },
		{ "Custom", 5, "Catch and return 5 unique fish from the Sunken Reservoir" }
	},
	List = { module.CatchFishAny({
			Fish = "Terrosunder",
			RequiredAmount = 1,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = {
				"Dryskin Minnow",
				"Cactus-Feeder Barb",
				"Torrential Catfish",
				"Claypan Guppy",
				"Sun-Blistered Perch"
			},
			RequiredAmount = 5,
			AndReturn = true
		}), module.CatchFishAny({
			Fish = {
				"Sandbar Loach",
				"Mirage Fin",
				"Dustveil Ray",
				"Prickly Gurnard",
				"Reservoir Squalus"
			},
			RequiredAmount = 5,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Awakening Serum",
			{},
			1
		}
	}
}
count += 1
DrylandsQuests.Drylands6_AwakenedTerrosunder = {
	DisplayName = "Drylands: The Awakened Terrosunder",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	AutoNavigate = true,
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			AllComplete = true
		}
	},
	QuestSeries = "Drylands",
	SeriesIndex = count,
	List = { module.CatchFishAny({
			Fish = "Photic Terrosunder",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Dune Relic",
			{
				Weight = 21
			},
			1
		},
		{ "DisplayOnly", "???" }
	}
}
DrylandsQuests.Drylands7_DuneRelicChallenge = {
	DisplayName = "Dune Relic",
	QuestType = "Challenge",
	Icon = "",
	IconColor = color,
	AcceptIndicatorTag = "PaleontologistPetri",
	NavigationTargets = {
		{
			Zone = "Dunehaven",
			Tags = { "PaleontologistPetri" },
			AllComplete = true
		}
	},
	IsRepeatable = true,
	Prerequisites = {
		QuestComplete = { "Drylands6_AwakenedTerrosunder" }
	},
	List = { module.CatchFishAny({
			Fish = "Photic Terrosunder",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{
			"ItemOrFish",
			"Dune Relic",
			{
				Weight = 21
			},
			1
		}
	}
}
local v10 = {}

for k, v11 in DrylandsQuests do
	if v11.SeriesIndex then
		v10[v11.SeriesIndex] = k
	end
end

for k, v11 in v10 do
	local v12 = v10[k - 1]

	if not v12 then
		continue
	end

	local v13 = DrylandsQuests[v11]

	if not v13.Prerequisites then
		v13.Prerequisites = {
			QuestComplete = { v12 }
		}
	end
end

return DrylandsQuests