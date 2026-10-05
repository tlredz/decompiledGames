local module = require("../../SimpleFetchQuests/lib")
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
local _ = {
	DeepCity = "Deep City",
	OuterDeep = "Outer Deep",
	LowerDeep = "Lower Deep",
	GloomyCrevice = "Gloomy Crevice",
	ThermalVents = "Thermal Vents"
}
local _ = {
	"Deep City",
	"Outer Deep",
	"Lower Deep",
	"Gloomy Crevice",
	"Thermal Vents"
}

local function series(questSeries: string, seriesIndex: number, acceptIndicatorTag: string, zone: string)
	return {
		QuestSeries = questSeries,
		SeriesIndex = seriesIndex,
		AcceptIndicatorTag = acceptIndicatorTag,
		NavigationTargets = {
			{
				Zone = zone,
				Tags = { acceptIndicatorTag },
				AllComplete = true
			}
		}
	}
end

local function merge(p, items)
	for k, item in items do
		p[k] = item
	end

	return p
end

local color = Color3.fromRGB(180, 60, 60)
local deepDan = {
	DisplayName = "The Deep: Precision in the Dark",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	QuestType = "Major",
	Description = "Prove your aim to Hunter Dan.",
	CompletedDescription = "Return to Hunter Dan at the Sector 1P-1 Outpost.",
	List = {
		{
			"CatchFishAny",
			3,
			{ "Snipefish" },
			nil,
			{
				Perfect = true
			}
		},
		module.ObtainItem({
			Item = "Prism Scale",
			RequiredAmount = 5,
			ForNpc = "Hunter Dan"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 6000 },
		{ "Xp", 1200 },
		{ "Title", "Trench Marksman" }
	}
}
local v2 = series("DeepDan", 1, "DeepHunterDan", "Outer Deep")
local TheDeepSideQuests = {}
local v3 = {
	"Radiant Prism Scale",
	"Abyssal Bio-Fluid",
	"Hardened Chitin",
	"Refined Scrap",
	"Ancient Bone"
}
local v5 = {
	DeepDan = "Deep3_Core1",
	DeepCarto = "Deep3_Core2",
	DeepVane = "Deep3_Core3",
	DeepSledge = "Deep3_Core4"
}

for k, v6 in v2 do
	deepDan[k] = v6
end

TheDeepSideQuests.DeepDan1 = deepDan
local deepDan2 = {
	DisplayName = "The Deep: Apex Encounter",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	QuestType = "Major",
	Description = "Track down an apex of the trench for Hunter Dan.",
	CompletedDescription = "Return to Hunter Dan at the Sector 1P-1 Outpost.",
	List = {
		{ "Custom", 1, "Catch a Big or larger Atlantic Dragonfish" },
		module.ObtainItem({
			Item = "Bone Shard",
			RequiredAmount = 15,
			ForNpc = "Hunter Dan"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 15000 },
		{ "Xp", 2500 },
		{ "AccessoryUpgrade", "SurveyDevice_AccuracyChip" }
	}
}
local v7 = series("DeepDan", 2, "DeepHunterDan", "Outer Deep")

for k, v8 in v7 do
	deepDan2[k] = v8
end

TheDeepSideQuests.DeepDan2 = deepDan2
local v8 = series("DeepDan", 3, "DeepHunterDan", "Outer Deep")
local deepDan3 = {
	DisplayName = "The Deep: Big Game Harpooner",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	QuestType = "Major",
	Description = "Hunt big game the way Dan does: with a harpoon.",
	CompletedDescription = "Return to Hunter Dan at the Sector 1P-1 Outpost.",
	List = {
		{ "Custom", 3, "Harpoon 3 sharks in The Deep" },
		{ "Custom", 5, "Land 5 Perfect Catches in a row" }
	},
	Rewards = {
		{ "Currency", "Coins", 20000 },
		{ "Xp", 4000 },
		{
			"ItemOrFish",
			"Heat-Proof Metal",
			nil,
			1
		}
	}
}

for k, v10 in v8 do
	deepDan3[k] = v10
end

TheDeepSideQuests.DeepDan3 = deepDan3
local deepDan4 = {
	DisplayName = "The Deep: Master of the Outer Deep",
	Icon = "rbxassetid://79523391252060",
	IconColor = color,
	QuestType = "Major",
	Description = "Take the trophy that even Dan never landed.",
	CompletedDescription = "Return to Hunter Dan at the Sector 1P-1 Outpost.",
	List = { module.CatchFishAny({
			Fish = "Greenland Shark",
			RequiredAmount = 1,
			RequiredAttributes = {
				WeightClass = "Giant"
			}
		}), module.ObtainItem({
			Item = "Ancient Bone",
			RequiredAmount = 7,
			ForNpc = "Hunter Dan"
		}) },
	Rewards = {
		{ "Currency", "Coins", 50000 },
		{ "Xp", 7500 },
		{ "Title", "Deep Hunter" }
	}
}
local v11 = series("DeepDan", 4, "DeepHunterDan", "Outer Deep")

for k, v12 in v11 do
	deepDan4[k] = v12
end

TheDeepSideQuests.DeepDan4 = deepDan4
local color2 = Color3.fromRGB(90, 170, 220)
local deepCarto = {
	DisplayName = "The Deep: Charting the Shallows",
	Icon = "rbxassetid://79523391252060",
	IconColor = color2,
	QuestType = "Major",
	Description = "Help the Cartographer chart the upper trench.",
	CompletedDescription = "Return to the Cartographer at the Sector 1P-2 Survey Post.",
	List = { module.CatchFishAny({
			Fish = "Sacabambaspis",
			RequiredAmount = 3
		}), module.CatchFishAny({
			Fish = "Tripod Fish",
			RequiredAmount = 2
		}) },
	Rewards = {
		{ "Currency", "Coins", 2000 },
		{ "Xp", 1000 },
		{ "AccessoryUpgrade", "SurveyDevice_TrenchRunning" }
	}
}
local v13 = series("DeepCarto", 1, "DeepCartographer", "Outer Deep")

for k, v14 in v13 do
	deepCarto[k] = v14
end

TheDeepSideQuests.DeepCarto1 = deepCarto
local v14 = series("DeepCarto", 2, "DeepCartographer", "Outer Deep")
local deepCarto2 = {
	DisplayName = "The Deep: Surveying Current Lanes",
	Icon = "rbxassetid://79523391252060",
	IconColor = color2,
	QuestType = "Major",
	Description = "Survey the current lanes for the Cartographer.",
	CompletedDescription = "Return to the Cartographer at the Sector 1P-2 Survey Post.",
	List = {
		{
			"CatchFishAny",
			1,
			{ "West Australian Lanternshark" },
			nil,
			{
				ShinyOrSparkling = true
			}
		},
		{ "Custom", 100, "Scan 100 fish with a Fish Radar or Survey Device" }
	},
	Rewards = {
		{ "Currency", "Coins", 5000 },
		{ "Xp", 2000 },
		{ "AccessoryUpgrade", "SurveyDevice_RangeChip" }
	}
}

for k, v16 in v14 do
	deepCarto2[k] = v16
end

TheDeepSideQuests.DeepCarto2 = deepCarto2
local v16 = series("DeepCarto", 3, "DeepCartographer", "Outer Deep")
local deepCarto3 = {
	DisplayName = "The Deep: Complete Soundings",
	Icon = "rbxassetid://79523391252060",
	IconColor = color2,
	QuestType = "Major",
	Description = "The chart is half empty. Fill it.",
	CompletedDescription = "Return to the Cartographer at the Sector 1P-2 Survey Post.",
	List = {
		{ "Custom", true, "Reach 50% Bestiary completion in the Outer Deep" },
		{
			"CatchFishAny",
			1,
			{ "Faceless Cusk" },
			nil,
			{
				Perfect = true
			}
		}
	},
	Rewards = {
		{ "Currency", "Coins", 15000 },
		{ "Xp", 4500 },
		{ "Title", "Trench Cartographer" }
	}
}

for k, v18 in v16 do
	deepCarto3[k] = v18
end

TheDeepSideQuests.DeepCarto3 = deepCarto3
local deepCarto4 = {
	DisplayName = "The Deep: Depth Surveyor",
	Icon = "rbxassetid://79523391252060",
	IconColor = color2,
	QuestType = "Major",
	Description = "Finish the chart of the Outer Deep, down to the last sounding.",
	CompletedDescription = "Return to the Cartographer at the Sector 1P-2 Survey Post.",
	List = {
		{ "Custom", true, "Reach 100% Bestiary completion in the Outer Deep" },
		module.ObtainItem({
			Item = "Radiant Prism Scale",
			RequiredAmount = 6,
			ForNpc = "the Cartographer"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 60000 },
		{ "Xp", 6500 },
		{
			"ItemOrFish",
			"Line of the Deep",
			nil,
			1
		}
	}
}
local v19 = series("DeepCarto", 4, "DeepCartographer", "Outer Deep")

for k, v20 in v19 do
	deepCarto4[k] = v20
end

TheDeepSideQuests.DeepCarto4 = deepCarto4
local color3 = Color3.fromRGB(120, 220, 140)
local deepVane = {
	DisplayName = "The Deep: Bioluminescent Samples",
	Icon = "rbxassetid://79523391252060",
	IconColor = color3,
	QuestType = "Major",
	Description = "Dr. Vane needs living light for the Bio-Lab.",
	CompletedDescription = "Return to Dr. Vane at the Sector 1P-3 Bio-Lab.",
	List = {
		{ "Custom", 3, "Catch 3 Bioluminescent or Entrenched fish" },
		module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 15,
			ForNpc = "Dr. Vane"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 8000 },
		{ "Xp", 1100 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			10
		}
	}
}
local v21 = series("DeepVane", 1, "DeepDrVane", "Outer Deep")

for k, v22 in v21 do
	deepVane[k] = v22
end

TheDeepSideQuests.DeepVane1 = deepVane
local deepVane2 = {
	DisplayName = "The Deep: Chemical Synthesis",
	Icon = "rbxassetid://79523391252060",
	IconColor = color3,
	QuestType = "Major",
	Description = "Vane's next formula calls for something twisted by the trench.",
	CompletedDescription = "Return to Dr. Vane at the Sector 1P-3 Bio-Lab.",
	List = {
		{ "Custom", 1, "Catch an Atlantean Pacific Footballfish" },
		module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 25,
			ForNpc = "Dr. Vane"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 10000 },
		{ "Xp", 3000 },
		{ "AccessoryUpgrade", "SurveyDevice_ResilienceChip" }
	}
}
local v23 = series("DeepVane", 2, "DeepDrVane", "Outer Deep")

for k, v24 in v23 do
	deepVane2[k] = v24
end

TheDeepSideQuests.DeepVane2 = deepVane2
local deepVane3 = {
	DisplayName = "The Deep: Abyssal Luminescence",
	Icon = "rbxassetid://79523391252060",
	IconColor = color3,
	QuestType = "Major",
	Description = "Vane wants proof of light where light should not survive.",
	CompletedDescription = "Return to Dr. Vane at the Sector 1P-3 Bio-Lab.",
	List = {
		{ "Custom", 1, "Catch a Big or larger Deep-sea Anglerfish with any mutation" },
		module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 35,
			ForNpc = "Dr. Vane"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 25000 },
		{ "Xp", 5500 },
		{ "Rod", "Luminous Rod" }
	}
}
local v25 = series("DeepVane", 3, "DeepDrVane", "Outer Deep")

for k, v26 in v25 do
	deepVane3[k] = v26
end

TheDeepSideQuests.DeepVane3 = deepVane3
local deepVane4 = {
	DisplayName = "The Deep: Master Biochemist",
	Icon = "rbxassetid://79523391252060",
	IconColor = color3,
	QuestType = "Major",
	Description = "One final sample stands between Vane and a breakthrough.",
	CompletedDescription = "Return to Dr. Vane at the Sector 1P-3 Bio-Lab.",
	List = { module.CatchFishAny({
			Fish = "Humpback Anglerfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Bioluminescent"
			}
		}), module.ObtainItem({
			Item = "Abyssal Bio-Fluid",
			RequiredAmount = 8,
			ForNpc = "Dr. Vane"
		}) },
	Rewards = {
		{ "Currency", "Coins", 40000 },
		{ "Xp", 8000 },
		{ "Title", "Master Biochemist" }
	}
}
local v27 = series("DeepVane", 4, "DeepDrVane", "Outer Deep")

for k, v28 in v27 do
	deepVane4[k] = v28
end

TheDeepSideQuests.DeepVane4 = deepVane4
local color4 = Color3.fromRGB(200, 140, 60)
local deepSledge = {
	DisplayName = "The Deep: Scrap Extraction",
	Icon = "rbxassetid://79523391252060",
	IconColor = color4,
	QuestType = "Major",
	Description = "One angler's trash is Sledge's treasure.",
	CompletedDescription = "Return to Sledge at the Scrapper's Forge.",
	List = { module.CatchFishAny({
			Fish = "Broken Flashlight",
			RequiredAmount = 1
		}), module.CatchFishAny({
			Fish = "Bent Harpoon",
			RequiredAmount = 1
		}) },
	Rewards = {
		{ "Currency", "Coins", 4000 },
		{ "Xp", 950 },
		{ "Title", "Benthic Scrapper" }
	}
}
local v29 = series("DeepSledge", 1, "DeepSledge", "Outer Deep")

for k, v30 in v29 do
	deepSledge[k] = v30
end

TheDeepSideQuests.DeepSledge1 = deepSledge
local deepSledge2 = {
	DisplayName = "The Deep: Armored Shells",
	Icon = "rbxassetid://79523391252060",
	IconColor = color4,
	QuestType = "Major",
	Description = "Sledge needs shells hard enough to forge with.",
	CompletedDescription = "Return to Sledge at the Scrapper's Forge.",
	List = {
		{ "Custom", 3, "Catch 3 Big or larger Devil Scorpionfish" },
		module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 15,
			ForNpc = "Sledge"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 7000 },
		{ "Xp", 2200 },
		{ "AccessoryUpgrade", "SurveyDevice_PowerChip" }
	}
}
local v31 = series("DeepSledge", 2, "DeepSledge", "Outer Deep")

for k, v32 in v31 do
	deepSledge2[k] = v32
end

TheDeepSideQuests.DeepSledge2 = deepSledge2
local deepSledge3 = {
	DisplayName = "The Deep: Heavy Metallurgy",
	Icon = "rbxassetid://79523391252060",
	IconColor = color4,
	QuestType = "Major",
	Description = "Heavy metal for heavy work.",
	CompletedDescription = "Return to Sledge at the Scrapper's Forge.",
	List = { module.CatchFishAny({
			Fish = "Crushed Diving Helmet",
			RequiredAmount = 1
		}), module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 30,
			ForNpc = "Sledge"
		}) },
	Rewards = {
		{ "Currency", "Coins", 15000 },
		{ "Xp", 4200 },
		{ "HarpoonGun", "Scrap-Cannon" }
	}
}
local v33 = series("DeepSledge", 3, "DeepSledge", "Outer Deep")

for k, v34 in v33 do
	deepSledge3[k] = v34
end

TheDeepSideQuests.DeepSledge3 = deepSledge3
local deepSledge4 = {
	DisplayName = "The Deep: Master Smith's Honor",
	Icon = "rbxassetid://79523391252060",
	IconColor = color4,
	QuestType = "Major",
	Description = "Bring Sledge materials worthy of a master's forge.",
	CompletedDescription = "Return to Sledge at the Scrapper's Forge.",
	List = { module.ObtainItem({
			Item = "Hardened Chitin",
			RequiredAmount = 5,
			ForNpc = "Sledge"
		}), module.ObtainItem({
			Item = "Refined Scrap",
			RequiredAmount = 5,
			ForNpc = "Sledge"
		}) },
	Rewards = {
		{ "Currency", "Coins", 35000 },
		{ "Xp", 7000 },
		{
			"ItemOrFish",
			"Titanium Shaft",
			nil,
			1
		}
	}
}
local v35 = series("DeepSledge", 4, "DeepSledge", "Outer Deep")

for k, v36 in v35 do
	deepSledge4[k] = v36
end

TheDeepSideQuests.DeepSledge4 = deepSledge4
local color5 = Color3.fromRGB(110, 130, 200)
local deepKael = {
	DisplayName = "The Deep: Patrol Fleet Material",
	Icon = "rbxassetid://79523391252060",
	IconColor = color5,
	QuestType = "Major",
	Description = "The city's patrol fleet is short on hulls.",
	CompletedDescription = "Return to Shipwright Kael at the Deep City Docks.",
	List = { module.ObtainItem({
			Item = "Bone Shard",
			RequiredAmount = 30,
			ForNpc = "Shipwright Kael"
		}), module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 25,
			ForNpc = "Shipwright Kael"
		}) },
	Rewards = {
		{ "Currency", "Coins", 45000 },
		{ "Xp", 3000 },
		{ "Boat", "Hydro-Skiff" }
	}
}
local v37 = series("DeepKael", 1, "DeepShipwrightKael", "Deep City")

for k, v38 in v37 do
	deepKael[k] = v38
end

TheDeepSideQuests.DeepKael1 = deepKael
local deepKael2 = {
	DisplayName = "The Deep: Deep Submersible Project",
	Icon = "rbxassetid://79523391252060",
	IconColor = color5,
	QuestType = "Major",
	Description = "Kael's masterwork needs materials no dock has ever stocked.",
	CompletedDescription = "Return to Shipwright Kael at the Deep City Docks.",
	List = {
		module.CatchFishAny({
			RequiredAmount = 15,
			RequiredAttributes = {
				Mutation = "Atlantean"
			}
		}),
		module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 50,
			ForNpc = "Shipwright Kael"
		}),
		module.ObtainItem({
			Item = "Abyssal Bio-Fluid",
			RequiredAmount = 3,
			ForNpc = "Shipwright Kael"
		}),
		module.ObtainItem({
			Item = "Radiant Prism Scale",
			RequiredAmount = 3,
			ForNpc = "Shipwright Kael"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 120000 },
		{ "Xp", 8500 },
		{ "Boat", "Deep City Submarine" }
	}
}
local v39 = series("DeepKael", 2, "DeepShipwrightKael", "Deep City")

for k, v40 in v39 do
	deepKael2[k] = v40
end

TheDeepSideQuests.DeepKael2 = deepKael2
local color6 = Color3.fromRGB(230, 190, 90)
local deepNix = {
	DisplayName = "The Deep: Glowing Attraction",
	Icon = "rbxassetid://79523391252060",
	IconColor = color6,
	QuestType = "Side",
	Description = "Nix wants to bottle the glow of the trench.",
	CompletedDescription = "Return to Artisan Nix in the Trade District.",
	List = {
		module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 15,
			ForNpc = "Artisan Nix"
		}),
		{ "Custom", 1, "Catch a Big or larger Luminous Hake" }
	},
	Rewards = {
		{ "Currency", "Coins", 2000 },
		{ "Xp", 1500 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			5
		},
		{ "Bobber", "Angler Lure" }
	}
}
local v41 = series("DeepNix", 1, "DeepArtisanNix", "Deep City")

for k, v42 in v41 do
	deepNix[k] = v42
end

TheDeepSideQuests.DeepNix1 = deepNix
local deepNix2 = {
	DisplayName = "The Deep: Scrap Calibration",
	Icon = "rbxassetid://79523391252060",
	IconColor = color6,
	QuestType = "Side",
	Description = "Precision instruments, built from garbage.",
	CompletedDescription = "Return to Artisan Nix in the Trade District.",
	List = { module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 20,
			ForNpc = "Artisan Nix"
		}), module.ObtainItem({
			Item = "Crushed Diving Helmet",
			RequiredAmount = 1,
			ForNpc = "Artisan Nix"
		}) },
	Rewards = {
		{ "Currency", "Coins", 2500 },
		{ "Xp", 1800 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			5
		},
		{ "Bobber", "Scrap-Gauge" }
	}
}
local v43 = series("DeepNix", 2, "DeepArtisanNix", "Deep City")

for k, v44 in v43 do
	deepNix2[k] = v44
end

TheDeepSideQuests.DeepNix2 = deepNix2
local deepNix3 = {
	DisplayName = "The Deep: Prismatic Optics",
	Icon = "rbxassetid://79523391252060",
	IconColor = color6,
	QuestType = "Side",
	Description = "Nix is grinding lenses from prism scales.",
	CompletedDescription = "Return to Artisan Nix in the Trade District.",
	List = { module.ObtainItem({
			Item = "Prism Scale",
			RequiredAmount = 25,
			ForNpc = "Artisan Nix"
		}), module.ObtainItem({
			Item = "Faceless Cusk",
			RequiredAmount = 1,
			ForNpc = "Artisan Nix"
		}) },
	Rewards = {
		{ "Currency", "Coins", 3500 },
		{ "Xp", 2800 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			10
		},
		{ "Bobber", "Crystal Prism" }
	}
}
local v45 = series("DeepNix", 3, "DeepArtisanNix", "Deep City")

for k, v46 in v45 do
	deepNix3[k] = v46
end

TheDeepSideQuests.DeepNix3 = deepNix3
local deepNix4 = {
	DisplayName = "The Deep: High-Beam Illuminator",
	Icon = "rbxassetid://79523391252060",
	IconColor = color6,
	QuestType = "Side",
	Description = "A lantern bright enough to cut the trench dark.",
	CompletedDescription = "Return to Artisan Nix in the Trade District.",
	List = { module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 35,
			ForNpc = "Artisan Nix"
		}), module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 15,
			ForNpc = "Artisan Nix"
		}) },
	Rewards = {
		{ "Currency", "Coins", 4200 },
		{ "Xp", 3200 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			10
		},
		{ "Lantern", "Trench Spotlight" }
	}
}
local v47 = series("DeepNix", 4, "DeepArtisanNix", "Deep City")

for k, v48 in v47 do
	deepNix4[k] = v48
end

TheDeepSideQuests.DeepNix4 = deepNix4
local deepNix5 = {
	DisplayName = "The Deep: Organic Phosphor Lantern",
	Icon = "rbxassetid://79523391252060",
	IconColor = color6,
	QuestType = "Side",
	Description = "Nix's final design burns on living light.",
	CompletedDescription = "Return to Artisan Nix in the Trade District.",
	List = { module.ObtainItem({
			Item = "Bio-Fluid",
			RequiredAmount = 45,
			ForNpc = "Artisan Nix"
		}), module.ObtainItem({
			Item = "Humpback Anglerfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				WeightClass = "Giant"
			},
			ForNpc = "Artisan Nix"
		}) },
	Rewards = {
		{ "Currency", "Coins", 5000 },
		{ "Xp", 4000 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			15
		},
		{ "Lantern", "Bio-Lumen" }
	}
}
local v49 = series("DeepNix", 5, "DeepArtisanNix", "Deep City")

for k, v50 in v49 do
	deepNix5[k] = v50
end

TheDeepSideQuests.DeepNix5 = deepNix5
local color7 = Color3.fromRGB(160, 160, 170)
local deepMarcus = {
	DisplayName = "The Deep: Bearing Reinforcement",
	Icon = "rbxassetid://79523391252060",
	IconColor = color7,
	QuestType = "Side",
	Description = "Marcus is machining a reel that will not seize at depth.",
	CompletedDescription = "Return to Forge Hand Marcus in the Scrapper District.",
	List = { module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 30,
			ForNpc = "Forge Hand Marcus"
		}), module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 12,
			ForNpc = "Forge Hand Marcus"
		}) },
	Rewards = {
		{ "Currency", "Coins", 3000 },
		{ "Xp", 2400 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			5
		},
		{
			"ItemOrFish",
			"Titanium Reel",
			nil,
			1
		}
	}
}
local v51 = series("DeepMarcus", 1, "DeepForgeHandMarcus", "Deep City")

for k, v52 in v51 do
	deepMarcus[k] = v52
end

TheDeepSideQuests.DeepMarcus1 = deepMarcus
local deepMarcus2 = {
	DisplayName = "The Deep: Scrappy Aesthetic",
	Icon = "rbxassetid://79523391252060",
	IconColor = color7,
	QuestType = "Side",
	Description = "Marcus insists scrap can look good. Prove him right.",
	CompletedDescription = "Return to Forge Hand Marcus in the Scrapper District.",
	List = { module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 40,
			ForNpc = "Forge Hand Marcus"
		}), module.ObtainItem({
			Item = "Broken Flashlight",
			RequiredAmount = 2,
			ForNpc = "Forge Hand Marcus"
		}) },
	Rewards = {
		{ "Currency", "Coins", 3700 },
		{ "Xp", 3100 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			10
		},
		{ "HarpoonGunSkin", "Refined Scrap-Cannon" }
	}
}
local v53 = series("DeepMarcus", 2, "DeepForgeHandMarcus", "Deep City")

for k, v54 in v53 do
	deepMarcus2[k] = v54
end

TheDeepSideQuests.DeepMarcus2 = deepMarcus2
local color8 = Color3.fromRGB(220, 120, 220)
local deepCorin = {
	DisplayName = "The Deep: Neon Filament",
	Icon = "rbxassetid://79523391252060",
	IconColor = color8,
	QuestType = "Side",
	Description = "Corin's next line glows in the dark.",
	CompletedDescription = "Return to Stylist Corin on the Central Promenade.",
	List = {
		{ "Custom", 2, "Catch 2 Radiant or Bioluminescent fish" },
		module.ObtainItem({
			Item = "Prism Scale",
			RequiredAmount = 25,
			ForNpc = "Stylist Corin"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 2800 },
		{ "Xp", 2100 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			5
		},
		{ "HarpoonGunSkin", "Oracle Blaster" }
	}
}
local v55 = series("DeepCorin", 1, "DeepStylistCorin", "Deep City")

for k, v56 in v55 do
	deepCorin[k] = v56
end

TheDeepSideQuests.DeepCorin1 = deepCorin
local deepCorin2 = {
	DisplayName = "The Deep: Brass Restoration",
	Icon = "rbxassetid://79523391252060",
	IconColor = color8,
	QuestType = "Side",
	Description = "Old brass, new shine.",
	CompletedDescription = "Return to Stylist Corin on the Central Promenade.",
	List = { module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 35,
			ForNpc = "Stylist Corin"
		}), module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 20,
			ForNpc = "Stylist Corin"
		}) },
	Rewards = {
		{ "Currency", "Coins", 4500 },
		{ "Xp", 3500 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			10
		},
		{ "Skin", "Faceless Purger" }
	}
}
local v57 = series("DeepCorin", 2, "DeepStylistCorin", "Deep City")

for k, v58 in v57 do
	deepCorin2[k] = v58
end

TheDeepSideQuests.DeepCorin2 = deepCorin2
local deepCorin3 = {
	DisplayName = "The Deep: Relic Engraving",
	Icon = "rbxassetid://79523391252060",
	IconColor = color8,
	QuestType = "Side",
	Description = "Corin's masterpiece needs a subject worth engraving.",
	CompletedDescription = "Return to Stylist Corin on the Central Promenade.",
	List = {
		module.ObtainItem({
			Item = "Radiant Prism Scale",
			RequiredAmount = 3,
			ForNpc = "Stylist Corin"
		}),
		{ "Custom", 1, "Catch a Big or larger Shiny or Sparkling fish in The Deep" }
	},
	Rewards = {
		{ "Currency", "Coins", 5200 },
		{ "Xp", 4100 },
		{
			"ItemOrFish",
			"Deep Tackle Box",
			nil,
			15
		},
		{ "HarpoonGunSkin", "Faceless Cusk-Shot" }
	}
}
local v59 = series("DeepCorin", 3, "DeepStylistCorin", "Deep City")

for k, v60 in v59 do
	deepCorin3[k] = v60
end

TheDeepSideQuests.DeepCorin3 = deepCorin3
local color9 = Color3.fromRGB(200, 200, 255)
local v60 = series("DeepOracle", 1, "DeepBlindOracle", "Lower Deep")
local deepOracle = {
	DisplayName = "The Deep: Unseen Guidance",
	Icon = "rbxassetid://79523391252060",
	IconColor = color9,
	QuestType = "Major",
	Description = "The Oracle asks you to fish as she sees: without sight, without error.",
	CompletedDescription = "Return to the Blind Oracle at the Lower Deep Shrine.",
	List = {
		{ "Custom", 15, "Land 15 Perfect Catches in a row in the Gloomy Crevice" }
	},
	Rewards = {
		{ "Currency", "Coins", 40000 },
		{ "Xp", 3000 },
		{ "Title", "Sightless Scholar" }
	}
}

for k, v62 in v60 do
	deepOracle[k] = v62
end

TheDeepSideQuests.DeepOracle1 = deepOracle
local deepOracle2 = {
	DisplayName = "The Deep: Eyeless Truth",
	Icon = "rbxassetid://79523391252060",
	IconColor = color9,
	QuestType = "Major",
	Description = "See what the Oracle sees. Catch what cannot be seen.",
	CompletedDescription = "Return to the Blind Oracle at the Lower Deep Shrine.",
	List = {
		{
			"CatchFishAny",
			1,
			{ "Monstrous Cusk" },
			nil,
			{
				Perfect = true
			}
		},
		module.ObtainItem({
			Item = v3[1],
			RequiredAmount = 5,
			ForNpc = "the Blind Oracle"
		}),
		module.ObtainItem({
			Item = v3[2],
			RequiredAmount = 5,
			ForNpc = "the Blind Oracle"
		}),
		module.ObtainItem({
			Item = v3[3],
			RequiredAmount = 5,
			ForNpc = "the Blind Oracle"
		}),
		module.ObtainItem({
			Item = v3[4],
			RequiredAmount = 5,
			ForNpc = "the Blind Oracle"
		}),
		module.ObtainItem({
			Item = v3[5],
			RequiredAmount = 5,
			ForNpc = "the Blind Oracle"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 85000 },
		{ "Xp", 16000 },
		{ "HarpoonGun", "Sightless Oracle" }
	}
}
local v63 = series("DeepOracle", 2, "DeepBlindOracle", "Lower Deep")

for k, v64 in v63 do
	deepOracle2[k] = v64
end

TheDeepSideQuests.DeepOracle2 = deepOracle2
local color10 = Color3.fromRGB(255, 120, 70)
local deepVesper = {
	DisplayName = "The Deep: Thermal Adaptations",
	Icon = "rbxassetid://79523391252060",
	IconColor = color10,
	QuestType = "Major",
	Description = "Fish where the water boils.",
	CompletedDescription = "Return to Vesper at the Thermal Vents.",
	List = { module.CatchFishAny({
			RequiredAmount = 15,
			PlayerZones = "Lower Deep"
		}) },
	Rewards = {
		{ "Currency", "Coins", 35000 },
		{ "Xp", 2800 },
		{
			"ItemOrFish",
			"Thermal Harpoon",
			nil,
			1
		}
	}
}
local v65 = series("DeepVesper", 1, "DeepVesper", "Thermal Vents")

for k, v66 in v65 do
	deepVesper[k] = v66
end

TheDeepSideQuests.DeepVesper1 = deepVesper
local deepVesper2 = {
	DisplayName = "The Deep: Scalded Abyss",
	Icon = "rbxassetid://79523391252060",
	IconColor = color10,
	QuestType = "Major",
	Description = "Turn the Titanic Scalder on the abyss itself.",
	CompletedDescription = "Return to Vesper at the Thermal Vents.",
	List = {
		{
			"CatchFishWithHarpoonGun",
			15,
			nil,
			{ "Mythical", "Exotic", "Secret" },
			nil,
			{ "Titanic Scalder" }
		},
		module.ObtainItem({
			Item = "Abyssal Bio-Fluid",
			RequiredAmount = 8,
			ForNpc = "Vesper"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 90000 },
		{ "Xp", 6500 },
		{ "Rod", "Scalding Hook" }
	}
}
local v67 = series("DeepVesper", 2, "DeepVesper", "Thermal Vents")

for k, v68 in v67 do
	deepVesper2[k] = v68
end

TheDeepSideQuests.DeepVesper2 = deepVesper2
local color11 = Color3.fromRGB(150, 220, 230)
local v68 = series("DeepLyra", 1, "DeepCuratorLyra", "Deep City")
local deepLyra = {
	DisplayName = "The Deep: Fragment Collector",
	Icon = "rbxassetid://79523391252060",
	IconColor = color11,
	QuestType = "Side",
	Description = "The Archives are missing their oldest records.",
	CompletedDescription = "Return to Curator Lyra at the Deep City Archives.",
	List = {
		{ "Custom", true, "Scan the 1st Data Capsule in the Outer Deep" },
		{ "Custom", true, "Scan the 2nd Data Capsule in the Outer Deep" },
		{ "Custom", true, "Scan the 3rd Data Capsule in the Outer Deep" },
		{ "Custom", true, "Scan the 4th Data Capsule in the Outer Deep" }
	},
	Rewards = {
		{ "Currency", "Coins", 3000 },
		{ "Xp", 2200 },
		{ "Lantern", "Abyssal Crystal" }
	}
}

for k, v70 in v68 do
	deepLyra[k] = v70
end

TheDeepSideQuests.DeepLyra1 = deepLyra
local v70 = series("DeepLyra", 2, "DeepCuratorLyra", "Deep City")
local deepLyra2 = {
	DisplayName = "The Deep: Uncovering the Past",
	Icon = "rbxassetid://79523391252060",
	IconColor = color11,
	QuestType = "Side",
	Description = "The record trail leads into the Lower Deep.",
	CompletedDescription = "Return to Curator Lyra at the Deep City Archives.",
	List = {
		{ "Custom", true, "Scan the 1st Data Capsule in the Lower Deep" },
		{ "Custom", true, "Scan the 2nd Data Capsule in the Lower Deep" },
		{ "Custom", true, "Scan the 3rd Data Capsule in the Lower Deep" },
		{ "Custom", true, "Scan the 4th Data Capsule in the Lower Deep" }
	},
	Rewards = {
		{ "Currency", "Coins", 6000 },
		{ "Xp", 4500 },
		{ "Title", "Archive Keeper" }
	}
}

for k, v72 in v70 do
	deepLyra2[k] = v72
end

TheDeepSideQuests.DeepLyra2 = deepLyra2
local v72 = series("DeepLyra", 3, "DeepCuratorLyra", "Deep City")
local deepLyra3 = {
	DisplayName = "The Deep: History Restored",
	Icon = "rbxassetid://79523391252060",
	IconColor = color11,
	QuestType = "Side",
	Description = "Four capsules remain, hidden in the dark of the Gloomy Crevice.",
	CompletedDescription = "Return to Curator Lyra at the Deep City Archives.",
	List = {
		{ "Custom", true, "Scan the 1st Data Capsule in the Gloomy Crevice" },
		{ "Custom", true, "Scan the 2nd Data Capsule in the Gloomy Crevice" },
		{ "Custom", true, "Scan the 3rd Data Capsule in the Gloomy Crevice" },
		{ "Custom", true, "Scan the 4th Data Capsule in the Gloomy Crevice" }
	},
	Rewards = {
		{ "Currency", "Coins", 12000 },
		{ "Xp", 9000 },
		{ "Bobber", "Ancient Relic" }
	}
}

for k, v74 in v72 do
	deepLyra3[k] = v74
end

TheDeepSideQuests.DeepLyra3 = deepLyra3
local color12 = Color3.fromRGB(120, 160, 120)
local deepVal = {
	DisplayName = "The Deep: Supplying the Garrison",
	Icon = "rbxassetid://79523391252060",
	IconColor = color12,
	QuestType = "Side",
	Description = "The city reserves run on donations. Mostly yours.",
	CompletedDescription = "Return to Quartermaster Val at the City Commissary.",
	List = { module.ObtainItem({
			Item = "Bone Shard",
			RequiredAmount = 20,
			ForNpc = "Quartermaster Val"
		}), module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 20,
			ForNpc = "Quartermaster Val"
		}) },
	Rewards = {
		{ "Currency", "Coins", 22000 },
		{ "Xp", 1600 },
		{ "Title", "City Benefactor" }
	}
}
local v75 = series("DeepVal", 1, "DeepQuartermasterVal", "Deep City")

for k, v76 in v75 do
	deepVal[k] = v76
end

TheDeepSideQuests.DeepVal1 = deepVal
local v76 = series("DeepVal", 2, "DeepQuartermasterVal", "Deep City")
local deepVal2 = {
	DisplayName = "The Deep: Abyssal Trade Network",
	Icon = "rbxassetid://79523391252060",
	IconColor = color12,
	QuestType = "Side",
	Description = "Keep the trade network moving.",
	CompletedDescription = "Return to Quartermaster Val at the City Commissary.",
	List = {
		{ "Custom", 5, "Complete 5 daily bounties from the Citizen Bounty Board" }
	},
	Rewards = {
		{ "Currency", "Coins", 48000 },
		{ "Xp", 3500 },
		{
			"ItemOrFish",
			"The Deep Commissary Badge",
			nil,
			1
		}
	}
}

for k, v78 in v76 do
	deepVal2[k] = v78
end

TheDeepSideQuests.DeepVal2 = deepVal2
local color13 = Color3.fromRGB(255, 210, 120)
local deepOrik = {
	DisplayName = "The Deep: The Grand Frame Assembly",
	Icon = "rbxassetid://79523391252060",
	IconColor = color13,
	QuestType = "Major",
	Description = "Orik has finally decided you are worth his time. Bring the frame.",
	CompletedDescription = "Return to Tinkerer Orik at the Lower Scaffolding.",
	List = {
		module.ObtainItem({
			Item = "Salvage Scrap",
			RequiredAmount = 50,
			ForNpc = "Tinkerer Orik"
		}),
		module.ObtainItem({
			Item = "Chitin Plate",
			RequiredAmount = 40,
			ForNpc = "Tinkerer Orik"
		}),
		module.ObtainItem({
			Item = "Refined Scrap",
			RequiredAmount = 5,
			ForNpc = "Tinkerer Orik"
		}),
		module.ObtainItem({
			Item = "Hardened Chitin",
			RequiredAmount = 3,
			ForNpc = "Tinkerer Orik"
		}),
		module.ObtainItem({
			Item = "Crushed Diving Helmet",
			RequiredAmount = 1,
			ForNpc = "Tinkerer Orik"
		})
	},
	Rewards = {
		{ "Currency", "Coins", 10000 },
		{ "Xp", 4000 }
	}
}
local v79 = series("DeepOrik", 1, "DeepTinkererOrik", "Lower Deep")

for k, v80 in v79 do
	deepOrik[k] = v80
end

TheDeepSideQuests.DeepOrik1 = deepOrik
local deepOrik2 = {
	DisplayName = "The Deep: Biological Wiring",
	Icon = "rbxassetid://79523391252060",
	IconColor = color13,
	QuestType = "Major",
	Description = "The frame needs nerves. Living ones.",
	CompletedDescription = "Return to Tinkerer Orik at the Lower Scaffolding.",
	List = { module.ObtainItem({
			Item = "Pacific Footballfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Luminous"
			},
			ForNpc = "Tinkerer Orik"
		}), module.ObtainItem({
			Item = "Luminous Hake",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Scalded"
			},
			ForNpc = "Tinkerer Orik"
		}), module.ObtainItem({
			Item = "Dark Snailfish",
			RequiredAmount = 1,
			RequiredAttributes = {
				Mutation = "Monstrous"
			},
			ForNpc = "Tinkerer Orik"
		}) },
	Rewards = {
		{ "Currency", "Coins", 20000 },
		{ "Xp", 6500 }
	}
}
local v81 = series("DeepOrik", 2, "DeepTinkererOrik", "Lower Deep")

for k, v82 in v81 do
	deepOrik2[k] = v82
end

TheDeepSideQuests.DeepOrik2 = deepOrik2
local v82 = series("DeepOrik", 3, "DeepTinkererOrik", "Lower Deep")
local deepOrik3 = {
	DisplayName = "The Deep: Core Activation & Testing",
	Icon = "rbxassetid://79523391252060",
	IconColor = color13,
	QuestType = "Major",
	Description = "The Ancient Energy Core was lost in the Monstrous Cusk hunt. Find it at the edge of the Outer Deep.",
	CompletedDescription = "Return to Tinkerer Orik at the Lower Scaffolding.",
	List = {
		{ "Custom", true, "Retrieve the Ancient Energy Core from the edge of the Outer Deep" }
	},
	Rewards = {
		{ "Currency", "Coins", 50000 },
		{ "Xp", 22000 },
		{ "Title", "Deep Engineer" },
		{ "Companion", "Scrap-Bot" }
	}
}

for k, v84 in v82 do
	deepOrik3[k] = v84
end

TheDeepSideQuests.DeepOrik3 = deepOrik3
local v84 = {}

for k, v85 in TheDeepSideQuests do
	local v86 = v84[v85.QuestSeries] or {}
	v86[v85.SeriesIndex] = k
	v84[v85.QuestSeries] = v86
end

for k, v85 in v84 do
	for k2, v86 in v85 do
		local v87 = TheDeepSideQuests[v86]

		if v87.Prerequisites then
			continue
		end

		local questComplete = {}

		if k2 > 1 then
			table.insert(questComplete, v85[k2 - 1])
		elseif v5[k] then
			table.insert(questComplete, v5[k])
		end

		if #questComplete > 0 then
			v87.Prerequisites = {
				QuestComplete = questComplete
			}
		end
	end
end

return TheDeepSideQuests