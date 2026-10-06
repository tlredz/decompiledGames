local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
require(ReplicatedStorage.Omni.Shared.SoftPity)
local Stars = require(ReplicatedStorage.Omni.Shared.Stars)
local Fighters = require(ReplicatedStorage.Omni.Shared.Fighters)
local name = script.Parent.Name
local v = {
	Ussopa = {
		Rarity = "Common",
		SPA = 1.1,
		UltHits = 5,
		Ultimate = {
			[1.62] = 1
		},
		Perks = {}
	},
	Namy = {
		Rarity = "Uncommon",
		SPA = 1.05,
		UltHits = 5,
		Ultimate = {
			[2.22] = 1,
			[4.12] = 0
		},
		Perks = {}
	},
	Roben = {
		Rarity = "Rare",
		SPA = 0.95,
		UltHits = 6,
		Ultimate = {
			[3] = 1,
			[3.78] = 0
		},
		Perks = {}
	},
	Sanje = {
		Rarity = "Epic",
		SPA = 0.8,
		UltHits = 7,
		Ultimate = {
			[1.62] = 0.5,
			[2.85] = 0
		},
		Perks = {}
	},
	Zore = {
		CombatSound = "Sword",
		Rarity = "Legendary",
		SPA = 0.85,
		UltHits = 6,
		Ultimate = {
			[3.27] = 0.5,
			[3.58] = 0
		},
		Perks = {}
	},
	Lufe = {
		Rarity = "Mythical",
		SPA = 0.8,
		UltHits = 7,
		Ultimate = {},
		Perks = {}
	},
	Shanko = {
		CombatSound = "Sword",
		Rarity = "Secret",
		SPA = 0.8,
		UltHits = 5,
		Ultimate = {
			[2.17] = 1,
			[2.77] = 0
		},
		Perks = {}
	}
}
local sanje = v.Sanje
sanje.Ultimate[1.13] = 0.1
sanje.Ultimate[1.2025] = 0.1
sanje.Ultimate[1.275] = 0.1
sanje.Ultimate[1.3475] = 0.1
sanje.Ultimate[1.42] = 0.1
local zore = v.Zore
zore.Ultimate[0.73] = 0.05
zore.Ultimate[0.9677777777777777] = 0.05
zore.Ultimate[1.2055555555555555] = 0.05
zore.Ultimate[1.4433333333333334] = 0.05
zore.Ultimate[1.681111111111111] = 0.05
zore.Ultimate[1.918888888888889] = 0.05
zore.Ultimate[2.1566666666666667] = 0.05
zore.Ultimate[2.394444444444445] = 0.05
zore.Ultimate[2.6322222222222225] = 0.05
zore.Ultimate[2.87] = 0.05
local lufe = v.Lufe
lufe.Ultimate[0.35] = 0.1
lufe.Ultimate[0.5422222222222222] = 0.1
lufe.Ultimate[0.7344444444444445] = 0.1
lufe.Ultimate[0.9266666666666666] = 0.1
lufe.Ultimate[1.1188888888888888] = 0.1
lufe.Ultimate[1.3111111111111111] = 0.1
lufe.Ultimate[1.5033333333333334] = 0.1
lufe.Ultimate[1.6955555555555555] = 0.1
lufe.Ultimate[1.8877777777777776] = 0.1
lufe.Ultimate[2.08] = 0.1
local unformat = Number:Unformat("10")
local unformat2 = Number:Unformat("10")
local unformat3 = Number:Unformat("1")
local v2 = {
	Common = {
		Price = 1,
		Damage = 1,
		Ultimate = 10
	},
	Uncommon = {
		Price = 2,
		Damage = 1.8,
		Ultimate = 14
	},
	Rare = {
		Price = 3,
		Damage = 2.8,
		Ultimate = 14.5
	},
	Epic = {
		Price = 4,
		Damage = 4,
		Ultimate = 12.5
	},
	Legendary = {
		Price = 6,
		Damage = 5.4,
		Ultimate = 17
	},
	Mythical = {
		Price = 8,
		Damage = 8.2,
		Ultimate = 18
	},
	Secret = {
		Price = 10,
		Damage = 16.5,
		Ultimate = 42.5
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
		Amount = "50"
	},
	SoftPity = {
		{
			Name = "Secret",
			Amount = 25000,
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
			Name = "Ussopa",
			Chance = 38.0206666667
		},
		Uncommon = {
			Name = "Namy",
			Chance = 30.009
		},
		Rare = {
			Name = "Roben",
			Chance = 22.7
		},
		Epic = {
			Name = "Sanje",
			Chance = 8.25
		},
		Legendary = {
			Name = "Zore",
			Chance = 1
		},
		Mythical = {
			Name = "Lufe",
			Chance = 0.02
		},
		Secret = {
			Name = "Shanko",
			Chance = 0.0003333333,
			Hide = true
		}
	}
})
Fighters.Register(script.Parent.Name, v)
return true