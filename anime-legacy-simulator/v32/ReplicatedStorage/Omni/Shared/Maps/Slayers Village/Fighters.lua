local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
require(ReplicatedStorage.Omni.Shared.SoftPity)
local Stars = require(ReplicatedStorage.Omni.Shared.Stars)
local Fighters = require(ReplicatedStorage.Omni.Shared.Fighters)
local name = script.Parent.Name
local v = {
	Nezko = {
		Rarity = "Common",
		SPA = 1,
		UltHits = 5,
		Ultimate = {
			[0.25] = 0.16666666666666666,
			[0.75] = 0.16666666666666666,
			[1.2] = 0.16666666666666666,
			[1.82] = 0.5,
			[2.17] = 0.5
		},
		Perks = {}
	},
	Inosuko = {
		CombatSound = "Sword",
		Rarity = "Uncommon",
		SPA = 0.9,
		UltHits = 7,
		Ultimate = {
			[1.83] = 0.25,
			[2.15] = 0.25,
			[2.57] = 0.5,
			[2.63] = 0
		},
		Perks = {}
	},
	Zenytso = {
		CombatSound = "Sword",
		Rarity = "Rare",
		SPA = 0.8,
		UltHits = 8,
		Ultimate = {
			[2.32] = 1,
			[3.77] = 0
		},
		Perks = {}
	},
	Tanjero = {
		CombatSound = "Sword",
		Rarity = "Epic",
		SPA = 0.9,
		UltHits = 6,
		Ultimate = {
			[0.85] = 1,
			[1.35] = 0
		},
		Perks = {}
	},
	Shinobo = {
		CombatSound = "Sword",
		Rarity = "Legendary",
		SPA = 0.8,
		UltHits = 7,
		Ultimate = {
			[1.85] = 1,
			[3.6] = 0
		},
		Perks = {}
	},
	Rengoke = {
		CombatSound = "Sword",
		Rarity = "Mythical",
		SPA = 0.85,
		UltHits = 6,
		Ultimate = {},
		Perks = {}
	},
	Muzon = {
		Rarity = "Secret",
		SPA = 0.8,
		UltHits = 5,
		Ultimate = {
			[2.3] = 0
		},
		Perks = {}
	}
}
local rengoke = v.Rengoke
rengoke.Ultimate[1.58] = 0.1
rengoke.Ultimate[1.6877777777777778] = 0.1
rengoke.Ultimate[1.7955555555555556] = 0.1
rengoke.Ultimate[1.9033333333333333] = 0.1
rengoke.Ultimate[2.011111111111111] = 0.1
rengoke.Ultimate[2.118888888888889] = 0.1
rengoke.Ultimate[2.2266666666666666] = 0.1
rengoke.Ultimate[2.3344444444444443] = 0.1
rengoke.Ultimate[2.442222222222222] = 0.1
rengoke.Ultimate[2.55] = 0.1
local muzon = v.Muzon
muzon.Ultimate[0.6] = 0.1
muzon.Ultimate[0.7555555555555555] = 0.1
muzon.Ultimate[0.911111111111111] = 0.1
muzon.Ultimate[1.0666666666666667] = 0.1
muzon.Ultimate[1.222222222222222] = 0.1
muzon.Ultimate[1.3777777777777778] = 0.1
muzon.Ultimate[1.5333333333333332] = 0.1
muzon.Ultimate[1.6888888888888887] = 0.1
muzon.Ultimate[1.844444444444444] = 0.1
muzon.Ultimate[2] = 0.1
local unformat = Number:Unformat("400")
local unformat2 = Number:Unformat("1")
local unformat3 = Number:Unformat("1")
local v2 = {
	Common = {
		Price = 1,
		Damage = 15,
		Ultimate = 11.5
	},
	Uncommon = {
		Price = 2,
		Damage = 23,
		Ultimate = 21.5
	},
	Rare = {
		Price = 3,
		Damage = 33,
		Ultimate = 27
	},
	Epic = {
		Price = 4,
		Damage = 45,
		Ultimate = 19
	},
	Legendary = {
		Price = 6,
		Damage = 59,
		Ultimate = 31.5
	},
	Mythical = {
		Price = 8,
		Damage = 89,
		Ultimate = 28.5
	},
	Secret = {
		Price = 10,
		Damage = 180,
		Ultimate = 45
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
		Amount = "2K"
	},
	SoftPity = {
		{
			Name = "Secret",
			Amount = 150000,
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
			Name = "Nezko",
			Chance = 38.0208333333
		},
		Uncommon = {
			Name = "Inosuko",
			Chance = 30.009
		},
		Rare = {
			Name = "Zenytso",
			Chance = 22.7
		},
		Epic = {
			Name = "Tanjero",
			Chance = 8.25
		},
		Legendary = {
			Name = "Shinobo",
			Chance = 1
		},
		Mythical = {
			Name = "Rengoke",
			Chance = 0.02
		},
		Secret = {
			Name = "Muzon",
			Chance = 0.0001666667,
			Hide = true
		}
	}
})
Fighters.Register(script.Parent.Name, v)
return true