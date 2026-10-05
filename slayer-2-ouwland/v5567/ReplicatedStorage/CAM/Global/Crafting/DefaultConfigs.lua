local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.Types.CraftingTypes)
local v = {
	Points = 90000,
	Materials = {
		{
			name = "Mythic Refinement Ore",
			amount = 10
		},
		{
			name = "Metal Scraps",
			amount = 500
		},
		{
			name = "Silk Thread",
			amount = 300
		}
	},
	RefineKept = 1
}
local DefaultConfigs = {}

for k, v2 in {
	volcanic_katana = { "Flame Katana", "Volcanic Katana" },
	tornadic_katana = { "Wind Katana", "Tornadic Katana" },
	tidal_katana = { "Water Katana", "Tidal Katana" },
	thundercloud_katana = { "Thunder Katana", "Thundercloud Katana" },
	serpentine_katana = { "Serpent Katana", "Serpentine Katana" },
	butterfly_katana = { "Insect Katana", "Butterfly Katana" },
	reverb_cleavers = { "Sound Katanas", "Reverb Cleavers" },
	seismic_axe_and_mace = { "Axe and Mace", "Seismic Axe and Mace" },
	damascus_bladed_wagasa = { "Bladed Wagasa", "Damascus Bladed Wagasa" },
	damascus_claws = { "Claws", "Damascus Claws" },
	damascus_gauntlet = { "Gauntlet", "Damascus Gauntlet" },
	damascus_scythe = { "Scythe", "Damascus Scythe" },
	damascus_shotgun = { "Shotgun", "Damascus Shotgun" },
	damascus_sickles = { "Sickles", "Damascus Sickles" },
	damascus_sickles_blood = { "Blood Sickles", "Damascus Sickles" },
	damascus_spear = { "Spear", "Damascus Spear" },
	damascus_tanto = { "Tanto", "Damascus Tanto" },
	damascus_war_fans = { "War Fans", "Damascus War Fans" }
} do
	local additionalMaterials = {}

	for _, material in v.Materials do
		table.insert(additionalMaterials, {
			name = material.name,
			amount = material.amount
		})
	end

	DefaultConfigs[k] = {
		station = "Ouwigahara",
		result = v2[2],
		amount = 1,
		price = {
			RunPoints = v.Points
		},
		required = {
			{
				name = v2[1],
				amount = 1
			}
		},
		additionalMaterials = additionalMaterials,
		refineKept = v.RefineKept
	}
end

DefaultConfigs.enryu_katana = {
	station = "Hidden Mist",
	result = "Enryu Katana",
	amount = 1,
	price = {},
	required = {
		{
			name = "Crude Iron Ingot",
			amount = 1
		}
	},
	additionalMaterials = {}
}
DefaultConfigs.shinkage_katana = {
	station = "Hidden Mist",
	result = "Shinkage Katana",
	amount = 1,
	price = {},
	required = {
		{
			name = "Crude Iron Ingot",
			amount = 1
		}
	},
	additionalMaterials = {}
}
DefaultConfigs.tengoku_katana = {
	station = "Hidden Mist",
	result = "Tengoku Katana",
	amount = 1,
	price = {},
	required = {
		{
			name = "Crude Iron Ingot",
			amount = 1
		}
	},
	additionalMaterials = {}
}
DefaultConfigs.shotgun = {
	station = "Ouwland",
	result = "Shotgun",
	amount = 1,
	price = {
		Wen = 25000
	},
	required = {
		{
			name = "Shotgun Schematic",
			amount = 1
		}
	},
	additionalMaterials = {
		{
			name = "Silk Thread",
			amount = 200
		},
		{
			name = "Metal Scraps",
			amount = 100
		}
	}
}
local v2 = {
	Craft = {
		Weapon = {
			Wen = 500000,
			Generic = {
				["Metal Scraps"] = 500,
				["Silk Thread"] = 500
			}
		},
		Armor = {
			Wen = 400000,
			Generic = {
				["Metal Scraps"] = 400,
				["Silk Thread"] = 400
			},
			MaterialEach = 3
		},
		Accessory = {
			Wen = 200000,
			Generic = {
				["Metal Scraps"] = 200,
				["Silk Thread"] = 200
			},
			MaterialEach = 2
		}
	},
	Weapons = {
		["Firstlight Katana"] = {
			"Volcanic Katana",
			"Tornadic Katana",
			"Tidal Katana",
			"Thundercloud Katana"
		},
		["Firstlight Insect Katana"] = { "Butterfly Katana" },
		["Firstlight Sound Cleavers"] = { "Reverb Cleavers" },
		["Firstlight Bladed Wagasa"] = { "Damascus Bladed Wagasa" },
		["Firstlight Spear"] = { "Damascus Spear" },
		["Firstlight Tanto"] = { "Damascus Tanto" },
		["Firstlight War Fans"] = { "Damascus War Fans" },
		["Nightfall Katana"] = {
			"Volcanic Katana",
			"Tornadic Katana",
			"Tidal Katana",
			"Thundercloud Katana"
		},
		["Nightfall Serpent Katana"] = { "Serpentine Katana" },
		["Nightfall Axe and Mace"] = { "Seismic Axe and Mace" },
		["Nightfall Claws"] = { "Damascus Claws" },
		["Nightfall Gauntlet"] = { "Damascus Gauntlet" },
		["Nightfall Scythe"] = { "Damascus Scythe" },
		["Nightfall Sickles"] = { "Damascus Sickles" }
	},
	Kinds = { "Metal", "Cloth", "Third" },
	Wearables = {
		Firstlight = {
			Materials = {
				Metal = "Firstlight Forged Ingot",
				Cloth = "Firstlight Weaver's Silk",
				Third = "Firstlight Star Ore"
			},
			Pieces = {
				["Firstlight Haori"] = "Armor",
				["Firstlight Mask"] = "Accessory",
				["Firstlight Lantern"] = "Accessory"
			}
		},
		Nightfall = {
			Materials = {
				Metal = "Nightfall Forged Ingot",
				Cloth = "Nightfall Weaver's Cloth",
				Third = "Nightfall Reinforced Plating"
			},
			Pieces = {
				["Nightfall Cape"] = "Accessory",
				["Nightfall Mask"] = "Accessory",
				["Nightfall Top"] = "Armor",
				["Nightfall Bottom"] = "Armor"
			}
		}
	},
	Tower = {
		Pieces = { "Firstlight Top", "Firstlight Bottom" },
		Price = {
			RunPoints = 500000,
			Wen = 200000
		},
		Generic = {
			["Metal Scraps"] = 400,
			["Silk Thread"] = 400
		}
	},
	TierUps = {
		[2] = {
			Wen = {
				Weapon = 750000,
				Armor = 750000,
				Accessory = 450000
			},
			Generic = {
				["Metal Scraps"] = 750,
				["Silk Thread"] = 750
			},
			Materials = {
				Weapon = {
					Metal = 6,
					Third = 6
				},
				Armor = {
					Metal = 6,
					Cloth = 6
				},
				Accessory = {
					Third = 4,
					Cloth = 3
				}
			}
		},
		[3] = {
			Wen = {
				Weapon = 1500000,
				Armor = 1500000,
				Accessory = 750000
			},
			Generic = {},
			Materials = {
				Weapon = {
					Metal = 12,
					Third = 12
				},
				Armor = {
					Metal = 12,
					Cloth = 12
				},
				Accessory = {
					Third = 6,
					Cloth = 6
				}
			}
		}
	},
	Fished = {
		["Lost Shotgun"] = {
			[2] = 2,
			[3] = 6
		}
	}
}

local function seriesId(value: string)
	return string.lower((string.gsub(value, "%W", "_")))
end

local function seriesGeneric(generic)
	local result = {}

	for k, item in generic do
		table.insert(result, {
			name = k,
			amount = item
		})
	end

	return result
end

local function seriesTierUps(name: string, p: string)
	local v3 = v2.Fished[name]

	for k, tierUp in v2.TierUps do
		local additionalMaterials = seriesGeneric(tierUp.Generic)

		if v3 == nil then
			local wearable = v2.Wearables[string.match(name, "^(%a+) ")]
			local material = tierUp.Materials[p]

			for _, kind in v2.Kinds do
				if material[kind] ~= nil then
					table.insert(additionalMaterials, {
						name = wearable.Materials[kind],
						amount = material[kind]
					})
				end
			end
		else
			for _, wearable in v2.Wearables do
				for _, kind in v2.Kinds do
					table.insert(additionalMaterials, {
						name = wearable.Materials[kind],
						amount = v3[k]
					})
				end
			end
		end

		DefaultConfigs[`{string.lower((string.gsub(name, "%W", "_")))}_t{k}`] = {
			station = "Ouwland",
			result = name,
			amount = 1,
			price = {
				Wen = tierUp.Wen[p]
			},
			required = {
				{
					name = name,
					amount = 1
				}
			},
			additionalMaterials = additionalMaterials,
			refineKept = 1,
			keep = v3 == nil and { name .. " Schematic" } or nil,
			requiredTier = k - 1,
			tier = k,
			listedWhenHeld = v3 ~= nil,
			fullPrice = true
		}
	end
end

for k, weapon in v2.Weapons do
	for _, name in weapon do
		DefaultConfigs[`{string.lower((string.gsub(k, "%W", "_")))}__{string.lower((string.gsub(name, "%W", "_")))}`] = {
			station = "Ouwland",
			result = k,
			amount = 1,
			price = {
				Wen = v2.Craft.Weapon.Wen
			},
			required = {
				{
					name = name,
					amount = 1
				}
			},
			additionalMaterials = seriesGeneric(v2.Craft.Weapon.Generic),
			refineKept = 1,
			keep = { k .. " Schematic" },
			tier = 1,
			fullPrice = true
		}
	end

	seriesTierUps(k, "Weapon")
end

for k in v2.Fished do
	seriesTierUps(k, "Weapon")
end

for _, wearable in v2.Wearables do
	for k, piece in wearable.Pieces do
		local v3 = v2.Craft[piece]
		local required = {}

		for _, kind in v2.Kinds do
			table.insert(required, {
				name = wearable.Materials[kind],
				amount = v3.MaterialEach
			})
		end

		DefaultConfigs[string.lower((string.gsub(k, "%W", "_")))] = {
			station = "Ouwland",
			result = k,
			amount = 1,
			price = {
				Wen = v3.Wen
			},
			required = required,
			additionalMaterials = seriesGeneric(v3.Generic),
			keep = { k .. " Schematic" },
			tier = 1,
			fullPrice = true
		}
		seriesTierUps(k, piece)
	end
end

for _, piece in v2.Tower.Pieces do
	local required = {}

	for k, amount in v2.Tower.Generic do
		table.insert(required, {
			name = k,
			amount = amount
		})
	end

	DefaultConfigs[string.lower((string.gsub(piece, "%W", "_")))] = {
		station = "Ouwigahara",
		result = piece,
		amount = 1,
		price = table.clone(v2.Tower.Price),
		required = required,
		additionalMaterials = {},
		keep = { piece .. " Schematic" },
		tier = 1,
		fullPrice = true
	}
	seriesTierUps(piece, "Armor")
end

if not RunService:IsStudio() then
	return DefaultConfigs
end

for k, v3 in {
	firstlight_katana = {
		result = "Firstlight Katana",
		amount = 1,
		price = {
			Product = 3709745729
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 3
			},
			{
				name = "Firstlight Star Ore",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 5
			},
			{
				name = "Silk Thread",
				amount = 3
			}
		}
	},
	firstlight_haori = {
		result = "Firstlight Haori",
		amount = 1,
		price = {
			["Silk Thread"] = 12
		},
		required = {
			{
				name = "Firstlight Weaver's Silk",
				amount = 4
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 6
			}
		}
	},
	firstlight_mask = {
		result = "Firstlight Mask",
		amount = 1,
		price = {
			["Golden Fish"] = 2
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 1
			},
			{
				name = "Firstlight Weaver's Silk",
				amount = 1
			},
			{
				name = "Firstlight Star Ore",
				amount = 1
			}
		},
		additionalMaterials = {}
	},
	firstlight_spear = {
		result = "Firstlight Spear",
		amount = 1,
		price = {
			Wen = 450,
			["Metal Scraps"] = 10
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Refinement Ore",
				amount = 2
			},
			{
				name = "Coral",
				amount = 1
			},
			{
				name = "Worm",
				amount = 4
			}
		}
	},
	nightfall_katana = {
		result = "Nightfall Katana",
		amount = 1,
		price = {
			["Mythic Refinement Ore"] = 3
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 3
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 8
			}
		}
	},
	nightfall_scythe = {
		result = "Nightfall Scythe",
		amount = 1,
		price = {
			["Refinement Ore"] = 5
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 2
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 2
			},
			{
				name = "Nightfall Weaver's Cloth",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 4
			},
			{
				name = "Silk Thread",
				amount = 2
			},
			{
				name = "Fish Head",
				amount = 1
			},
			{
				name = "Mythic Refinement Ore",
				amount = 1
			}
		}
	},
	nightfall_serpent_katana = {
		result = "Nightfall Serpent Katana",
		amount = 1,
		price = {
			Wen = 900,
			["Demon Horns"] = 4
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 3
			},
			{
				name = "Krathulon",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 6
			},
			{
				name = "Sea Horse",
				amount = 2
			}
		}
	},
	firstlight_insect_katana = {
		result = "Firstlight Insect Katana",
		amount = 1,
		price = {
			Product = 3709745340
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 3
			},
			{
				name = "Firstlight Star Ore",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 2
			},
			{
				name = "Metal Scraps",
				amount = 6
			},
			{
				name = "Refinement Ore",
				amount = 2
			},
			{
				name = "Mythic Refinement Ore",
				amount = 1
			},
			{
				name = "Coral",
				amount = 3
			},
			{
				name = "Worm",
				amount = 5
			},
			{
				name = "Fish Head",
				amount = 2
			},
			{
				name = "Sea Horse",
				amount = 1
			},
			{
				name = "Zebra Fish",
				amount = 2
			},
			{
				name = "Golden Tentacle",
				amount = 1
			}
		}
	},
	firstlight_sound_cleavers = {
		result = "Firstlight Sound Cleavers",
		amount = 1,
		price = {
			Wen = 650,
			["Metal Scraps"] = 5
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 4
			}
		},
		additionalMaterials = {}
	},
	firstlight_bladed_wagasa = {
		result = "Firstlight Bladed Wagasa",
		amount = 1,
		price = {
			["Golden Fish"] = 5,
			["Refinement Ore"] = 2
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 2
			},
			{
				name = "Firstlight Weaver's Silk",
				amount = 3
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 4
			},
			{
				name = "Coral",
				amount = 2
			}
		}
	},
	nightfall_axe_and_mace = {
		result = "Nightfall Axe and Mace",
		amount = 1,
		price = {
			["Demon Horns"] = 10
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 3
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 10
			}
		}
	},
	firstlight_top = {
		result = "Firstlight Top",
		amount = 1,
		price = {
			["Silk Thread"] = 8
		},
		required = {
			{
				name = "Firstlight Weaver's Silk",
				amount = 3
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 5
			}
		}
	},
	firstlight_bottom = {
		result = "Firstlight Bottom",
		amount = 1,
		price = {
			Wen = 300
		},
		required = {
			{
				name = "Firstlight Weaver's Silk",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 4
			}
		}
	},
	nightfall_top = {
		result = "Nightfall Top",
		amount = 1,
		price = {
			Product = 3709745395
		},
		required = {
			{
				name = "Nightfall Weaver's Cloth",
				amount = 3
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 5
			}
		}
	},
	nightfall_bottom = {
		result = "Nightfall Bottom",
		amount = 1,
		price = {
			["Metal Scraps"] = 15
		},
		required = {
			{
				name = "Nightfall Weaver's Cloth",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 4
			}
		}
	},
	nightfall_cape = {
		result = "Nightfall Cape",
		amount = 1,
		price = {
			Wen = 500,
			["Golden Fish"] = 1
		},
		required = {
			{
				name = "Nightfall Weaver's Cloth",
				amount = 4
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 1
			}
		},
		additionalMaterials = {}
	},
	nightfall_mask = {
		result = "Nightfall Mask",
		amount = 1,
		price = {
			["Demon Horns"] = 2
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Zebra Fish",
				amount = 1
			}
		}
	},
	firstlight_lantern = {
		result = "Firstlight Lantern",
		amount = 2,
		price = {
			Wen = 150
		},
		required = {
			{
				name = "Firstlight Star Ore",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Golden Tentacle",
				amount = 1
			}
		}
	},
	nightfall_gauntlet = {
		result = "Nightfall Gauntlet",
		amount = 1,
		price = {
			["Refinement Ore"] = 3
		},
		required = {
			{
				name = "Nightfall Reinforced Plating",
				amount = 3
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 6
			}
		}
	},
	nightfall_claws = {
		result = "Nightfall Claws",
		amount = 1,
		price = {
			["Mythic Refinement Ore"] = 1,
			["Metal Scraps"] = 6
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 2
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Fish Head",
				amount = 3
			}
		}
	},
	firstlight_war_fans = {
		result = "Firstlight War Fans",
		amount = 1,
		price = {
			Product = 3709745729
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 1
			},
			{
				name = "Firstlight Weaver's Silk",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 3
			}
		}
	},
	firstlight_tanto = {
		result = "Firstlight Tanto",
		amount = 3,
		price = {
			Wen = 400
		},
		required = {
			{
				name = "Firstlight Forged Ingot",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 3
			}
		}
	},
	nightfall_sickles = {
		result = "Nightfall Sickles",
		amount = 1,
		price = {
			["Refinement Ore"] = 6
		},
		required = {
			{
				name = "Nightfall Forged Ingot",
				amount = 2
			},
			{
				name = "Nightfall Reinforced Plating",
				amount = 1
			},
			{
				name = "Nightfall Weaver's Cloth",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Metal Scraps",
				amount = 4
			}
		}
	},
	rarity_common = {
		result = "Black Bandana",
		amount = 1,
		price = {
			Wen = 100
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 1
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 1
			}
		}
	},
	rarity_uncommon = {
		result = "Fancy Katana",
		amount = 1,
		price = {
			["Golden Fish"] = 3
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 2
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 2
			}
		}
	},
	rarity_rare = {
		result = "Azure Cloak",
		amount = 1,
		price = {
			Product = 3709745340
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 3
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 3
			}
		}
	},
	rarity_epic = {
		result = "Autumn Haori",
		amount = 1,
		price = {
			["Refinement Ore"] = 4
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 4
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 4
			}
		}
	},
	rarity_legendary = {
		result = "Blood Sickles",
		amount = 1,
		price = {
			Wen = 500,
			["Mythic Refinement Ore"] = 2
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 5
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 5
			}
		}
	},
	rarity_mythic = {
		result = "Akatsuki Straw Hat",
		amount = 1,
		price = {
			Product = 3709745395
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 6
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 6
			}
		}
	},
	rarity_impossible = {
		result = "Dev Cape",
		amount = 1,
		price = {
			["Demon Horns"] = 7,
			["Metal Scraps"] = 20
		},
		required = {
			{
				name = "Metal Scraps",
				amount = 7
			}
		},
		additionalMaterials = {
			{
				name = "Silk Thread",
				amount = 7
			}
		}
	}
} do
	DefaultConfigs[k] = v3
end

return DefaultConfigs