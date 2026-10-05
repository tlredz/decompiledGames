local BaitData = {}
require(game.ReplicatedStorage.BuildInfo)
local types = {}
BaitData.Types = types
local _ = script.Parent.FishData
types["Frozen Bait"] = {
	RarityBoost = 1,
	TaggedBoost = 2,
	RequiredBoost = 1,
	BaitRarity = 2,
	TaggedTypes = { "Ice", "Frozen" },
	Recipe = {
		["Yeti Fur"] = 1,
		Beli = {
			Amount = 36000
		}
	},
	Desc = "It's so cold you think you'll get frostbite just from touching it!",
	AnglerTrust = 20,
	Vendor = {
		SeaId = "Sea2",
		NPC = "Angler"
	},
	SortId = 7
}
types.None = {
	RarityBoost = 1,
	BaitRarity = 1,
	Recipe = {}
}
types["Basic Bait"] = {
	RarityBoost = 1,
	BaitRarity = 0,
	Recipe = {
		Beli = {
			Amount = 1000
		}
	},
	Fisherman = true,
	Desc = "The most basic fish bait you could scrap together.",
	SortId = 1
}
types["Kelp Bait"] = {
	RarityBoost = nil,
	BaitRarity = 1,
	TaggedTypes = { "Kelp" },
	TaggedBoost = 2,
	Recipe = {
		Beli = {
			Amount = 12000
		}
	},
	Vendor = {
		SeaId = "Sea1",
		NPC = "Angler"
	},
	AnglerTrust = 3,
	Desc = "Attracts fish that live in lush, green kelp forests.",
	SortId = 2
}
types["Good Bait"] = {
	RarityBoost = 2,
	BaitRarity = 1,
	Recipe = {
		Beli = {
			Amount = 8000
		}
	},
	Vendor = {
		SeaId = "Sea1",
		NPC = "Angler"
	},
	AnglerTrust = 10,
	Desc = "Attracts a wide array of fish.",
	SortId = 3
}
types["Epic Bait"] = {
	RarityBoost = 1,
	BaitRarity = 3,
	Recipe = {
		["Terror Eyes"] = 1,
		Beli = {
			Amount = 50000
		}
	},
	Vendor = {
		SeaId = "Sea3",
		NPC = "Angler"
	},
	AnglerTrust = 10,
	Desc = "Used for attracting the most elusive sea creatures. Don't waste it!",
	SortId = 4
}
types["Carnivore Bait"] = {
	RarityBoost = 2,
	BaitRarity = 2,
	TaggedTypes = { "Carnivore" },
	TaggedBoost = 2,
	Recipe = {
		["Dragon Scale"] = 1,
		Beli = {
			Amount = 60000
		}
	},
	Vendor = {
		SeaId = "Sea3",
		NPC = "Angler"
	},
	AnglerTrust = 15,
	Desc = "Attracts aggressive, carnivorous fish. Smells awful.",
	SortId = 5
}
types["Abyssal Bait"] = {
	RarityBoost = 1,
	BaitRarity = 3,
	TaggedTypes = { "Abyssal" },
	TaggedBoost = 2,
	Recipe = {
		["Demonic Wisp"] = 1,
		Beli = {
			Amount = 25000
		}
	},
	Vendor = {
		SeaId = "Sea2",
		NPC = "Angler"
	},
	AnglerTrust = 5,
	Desc = "The scent from this bait will reach the bottom of the ocean.",
	SortId = 6
}

function commaInteger(p: number)
	local v2

	if p < 10 then
		v2 = math.round(p * 100) / 100
	elseif p < 100 then
		v2 = math.round(p * 10) / 10
	else
		v2 = math.round(p)
	end

	local v3 = tostring(v2)

	repeat
		local v4
		v3, v4 = string.gsub(v3, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v4 == 0

	return v3
end

function BaitData.FormatRecipe(p)
	local v2 = types[p]

	if not v2 then
		return false
	end

	local recipe = v2.Recipe

	if not recipe then
		return false
	end

	local v3 = {}
	local beli = recipe.Beli

	if beli then
		table.insert(v3, (`${commaInteger(beli)}`))
	end

	for k, v4 in recipe.EtcItems or {} do
		table.insert(v3, (`{v4} {k}`))
	end

	return table.concat(v3, "+")
end

function BaitData.GetRecipeTable()
	local result = {}

	for k, _ in types do
		result[k] = BaitData.FormatRecipe(k)
	end

	return result
end

function BaitData.GetBonusesForBait(p: string)
	local v2 = types[p]
	assert(v2, (`BaitType not found for {p}`))
	return v2
end

for k, type in BaitData.Types do
	type.Name = k
end

return BaitData