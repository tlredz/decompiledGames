local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
require(ReplicatedStorage.Omni.Shared.SoftPity)
local Stars = require(ReplicatedStorage.Omni.Shared.Stars)
local Fighters = require(ReplicatedStorage.Omni.Shared.Fighters)
local name = script.Parent.Name
local v = {
	Nobera = {
		Rarity = "Common",
		SPA = 0.95,
		UltHits = 5,
		Ultimate = {
			[0.85] = 1,
			[1.37] = 0
		},
		Perks = {}
	},
	Naname = {
		Rarity = "Uncommon",
		SPA = 0.9,
		UltHits = 6,
		Ultimate = {
			[3.5] = 1,
			[3.95] = 0
		},
		Perks = {}
	},
	Tudo = {
		Rarity = "Rare",
		SPA = 0.85,
		UltHits = 7,
		Ultimate = {
			[0.4] = 0.5,
			[1.73] = 0.5,
			[2.23] = 0
		},
		Perks = {}
	},
	Memugi = {
		Rarity = "Epic",
		SPA = 0.8,
		UltHits = 6,
		Ultimate = {
			[2.98] = 1,
			[3.98] = 0
		},
		Perks = {}
	},
	Itadore = {
		Rarity = "Legendary",
		SPA = 0.8,
		UltHits = 6,
		Ultimate = {
			[0.37] = 1,
			[1.7] = 0
		},
		Perks = {}
	},
	Yuto = {
		CombatSound = "Sword",
		Rarity = "Mythical",
		SPA = 0.75,
		UltHits = 7,
		Ultimate = {
			[1.683333] = 0.125,
			[1.883333] = 0.125,
			[2.083333] = 0.125,
			[2.283333] = 0.125,
			[2.483333] = 0.125,
			[2.683333] = 0.125,
			[2.883333] = 0.125,
			[3.083333] = 0.125,
			[3.933333] = 0
		},
		Perks = {}
	},
	Goujo = {
		Rarity = "Secret",
		UltimateSpeed = 0.5,
		SPA = 0.8,
		UltHits = 5,
		Ultimate = {
			[2] = 1,
			[2.65] = 0
		},
		Perks = {}
	}
}
local unformat = Number:Unformat("15000")
local unformat2 = Number:Unformat("1")
local unformat3 = Number:Unformat("1")
local v2 = {
	Common = {
		Price = 1,
		Damage = 21,
		Ultimate = 22
	},
	Uncommon = {
		Price = 1.5,
		Damage = 31,
		Ultimate = 34
	},
	Rare = {
		Price = 2,
		Damage = 43,
		Ultimate = 29.5
	},
	Epic = {
		Price = 2.5,
		Damage = 57,
		Ultimate = 35.3
	},
	Legendary = {
		Price = 3,
		Damage = 73,
		Ultimate = 28
	},
	Mythical = {
		Price = 3.5,
		Damage = 105,
		Ultimate = 48.5
	},
	Secret = {
		Price = 4,
		Damage = 210,
		Ultimate = 76.12
	}
}

for _, v3 in v do
	local v4 = v2[v3.Rarity] or v2.Common

	if not v4 then
		continue
	end

	if not v3.Price then
		v3.Price = {
			Type = "Currency",
			Name = "Yen",
			Amount = unformat * v4.Price
		}
	end

	if not v3.Damage then
		v3.Damage = unformat2 * v4.Damage
	end

	if not v3.UltMultiplier then
		v3.UltMultiplier = unformat3 * v4.Ultimate
	end
end

Stars.Register(name, {
	MapName = name,
	Price = {
		Type = "Currency",
		Name = "Yen",
		Amount = "75K"
	},
	SoftPity = {
		{
			Name = "Secret",
			Amount = 200000,
			Multiplier = 1.25
		}
	},
	Pity = {
		{
			Name = "Legendary",
			Amount = 350
		},
		{
			Name = "Mythical",
			Amount = 7500
		}
	},
	List = {
		Common = {
			Name = "Nobera",
			Chance = 38.020875
		},
		Uncommon = {
			Name = "Naname",
			Chance = 30.009
		},
		Rare = {
			Name = "Tudo",
			Chance = 22.7
		},
		Epic = {
			Name = "Memugi",
			Chance = 8.25
		},
		Legendary = {
			Name = "Itadore",
			Chance = 1
		},
		Mythical = {
			Name = "Yuto",
			Chance = 0.02
		},
		Secret = {
			Name = "Goujo",
			Chance = 0.000125,
			Hide = true
		}
	}
})
Fighters.Register(name, v)
return true