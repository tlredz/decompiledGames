local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Shared = require(script.Parent.Shared)
return {
	Makomo = {
		name = "Makomo",
		rarity = 3,
		archetype = "Sentinel",
		stats = {
			["Max Health"] = 72,
			["Block Points"] = 4,
			["Block Regen"] = 0.1
		},
		skills = { Shared.GhostAttendanceMode },
		passives = { Shared.WaterFamilyBond }
	},
	Sabito = {
		name = "Sabito",
		rarity = 3,
		archetype = "Duelist",
		stats = {
			["Max Health"] = 75,
			["Additional Damage Factor"] = 0.1
		},
		skills = { Shared.GhostAttendanceMode },
		passives = {
			Shared.WaterFamilyBond,
			{
				name = "Expert Swordsman",
				description = "+20% Katana mastery."
			}
		}
	},
	Susumaru = {
		name = "Susumaru",
		rarity = 3,
		archetype = "Technician",
		stats = {
			["Max Health"] = 60,
			["Additional Damage Factor"] = 0.09,
			["Additional Damage"] = 0.5
		},
		skills = {},
		passives = {
			Shared.PartyBuff,
			{
				name = "Tamari Regen",
				description = "Landing a Tamari skill restores 5% of Max Stamina and grants +2% Additional Damage Factor for 5 seconds."
			}
		}
	},
	Urokodaki = {
		name = "Urokodaki",
		rarity = 3,
		archetype = "Technician",
		stats = {
			["Max Health"] = 69,
			["Movement Speed Factor"] = 0.04,
			["Additional Damage Factor"] = 0.09
		},
		skills = {},
		passives = {
			{
				name = "Water Breathing Affinity",
				description = "+15% Water Damage Factor and -10% Water Stamina Cost Factor.",
				effects = {
					{
						stats = {
							["Water Damage Factor"] = 0.15,
							["Water Stamina Cost Factor"] = -0.1
						}
					}
				}
			},
			{
				name = "Breathing Discipline",
				description = "+25% Water Breathing mastery and +5% Exp Factor.",
				effects = {
					{
						stats = {
							["Exp Factor"] = 0.05
						}
					}
				}
			},
			{
				name = "Instructor's Intuition",
				description = "Party members within 15 meters gain +6 Max Stamina and +5% Stamina Regen Speed."
			},
			{
				name = "Maskful Sight",
				description = "While wearing any mask, night vision reaches 50% further, and stacks with Lanterns."
			},
			{
				name = "Mask of the Master",
				description = "Wearing any mask grants +15% Damage Reduction Factor."
			}
		}
	},
	Yahaba = {
		name = "Yahaba",
		rarity = 3,
		archetype = "Technician",
		stats = {
			["Max Health"] = 65,
			["Additional Damage Factor"] = 0.1
		},
		skills = {
			{
				name = "Disruption Pulse",
				cooldown = 18,
				description = "A blast around the user that knocks nearby enemies back a short distance and applies -10% Additional Damage Factor and -10% Movement Speed Factor for 3 seconds. Comboable."
			}
		},
		passives = {
			Shared.PartyBuff,
			{
				name = "Arrow Regen",
				description = "Landing an Arrow Evil Art skill grants +5% Stamina Regen Speed for 5 seconds."
			}
		}
	}
}