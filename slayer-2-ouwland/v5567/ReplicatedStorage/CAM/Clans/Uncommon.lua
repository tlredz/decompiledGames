local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Shared = require(script.Parent.Shared)
return {
	Aori = {
		name = "Aori",
		rarity = 2,
		archetype = "Titan",
		stats = {
			["Max Health"] = 39,
			["Additional Damage Factor"] = 0.05,
			["Movement Speed Factor"] = 0.03
		},
		skills = {},
		passives = { Shared.FamilyBond }
	},
	Aoshima = {
		name = "Aoshima",
		rarity = 2,
		archetype = "Titan",
		stats = {
			["Max Health"] = 36,
			["Additional Damage Factor"] = 0.05,
			["Movement Speed Factor"] = 0.04
		},
		skills = {},
		passives = { Shared.FamilyBond }
	},
	Kaneki = {
		name = "Kaneki",
		rarity = 2,
		archetype = "Titan",
		stats = {
			["Max Health"] = 41,
			["Movement Speed Factor"] = 0.05,
			["Additional Damage Factor"] = 0.05
		},
		skills = {},
		passives = { Shared.FamilyBond }
	},
	Kurotsume = {
		name = "Kurotsume",
		rarity = 2,
		archetype = "Titan",
		stats = {
			["Max Health"] = 35,
			["Movement Speed Factor"] = 0.05,
			["Additional Damage Factor"] = 0.05
		},
		skills = {},
		passives = { Shared.FamilyBond }
	},
	Yamagiri = {
		name = "Yamagiri",
		rarity = 2,
		archetype = "Titan",
		stats = {
			["Max Health"] = 42,
			["Max Stamina"] = 22,
			["Stamina Regen Speed"] = 0.05
		},
		skills = {},
		passives = { Shared.FamilyBond }
	}
}