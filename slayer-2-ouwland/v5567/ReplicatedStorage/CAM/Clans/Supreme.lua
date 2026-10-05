local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Shared = require(script.Parent.Shared)
return {
	Kamado = {
		name = "Kamado",
		rarity = 7,
		archetype = "Ascendant",
		stats = {
			["Max Health"] = 263,
			["Max Stamina"] = 130,
			["Additional Damage Factor"] = 0.23,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.06,
			["Sun Immunity"] = true
		},
		skills = {
			Shared.IndomitableWill,
			{
				name = "Regen Adrenal",
				cooldown = 45,
				aura = "Green and gold, arrows rising",
				requirements = {
					Race = { "Demon", "Hybrid" }
				},
				description = "Demon only. Grants +14% Health Regen Speed for 7 seconds, and health keeps regenerating in combat for that window."
			},
			{
				name = "Combat Intuition",
				cooldown = 60,
				aura = "Golden, then red on the release",
				description = "Stores the damage the user takes for 10 seconds. " .. Shared.STORED_DAMAGE .. " In ranked, Stored Damage converts at x 0.07."
			},
			{
				name = "Headbutt",
				cooldown = 25,
				description = "The user pulls their head back then snaps forward, shattering a held guard outright and knocking the opponent straight down instead of backward."
			}
		},
		passives = {
			Shared.EnhancedSpeed,
			Shared.PainResistance,
			{
				name = "Adaptive Breathing",
				description = "Below 35% health, gain +5% Health Regen Speed. Below 30% stamina, gain +5% Stamina Regen Speed. Also grants Sun Immunity.",
				effects = {
					{
						when = {
							stat = "Health",
							below = 0.35
						},
						stats = {
							["Health Regen Speed"] = 0.05
						}
					},
					{
						when = {
							stat = "Stamina",
							below = 0.3
						},
						stats = {
							["Stamina Regen Speed"] = 0.05
						}
					}
				}
			},
			{
				name = "Damage Reduction Factor",
				description = "Below 25% health, gain +10% Damage Reduction Factor.",
				effects = {
					{
						when = {
							stat = "Health",
							below = 0.25
						},
						stats = {
							["Damage Reduction Factor"] = 0.1
						}
					}
				}
			}
		}
	},
	Rengoku = {
		name = "Rengoku",
		rarity = 7,
		archetype = "Ascendant",
		stats = {
			["Max Health"] = 278,
			["Max Stamina"] = 125,
			["Additional Damage Factor"] = 0.26,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.06
		},
		skills = {
			Shared.IndomitableWill,
			{
				name = "Heart Ablaze Mode",
				mode = true,
				cooldown = 90,
				modeCost = 375,
				aura = "Flame",
				description = "Mode. A flame aura burns anyone who hits the user for 2% of their own Max Health per second over 3 seconds, and the user gains +18% Additional Damage Factor, +5% Movement Speed Factor, +5% Stamina Regen Speed and +20% Burn Damage Factor."
			}
		},
		passives = {
			Shared.PainResistance,
			Shared.MasterSwordsman,
			{
				name = "Ignition Hit",
				description = "The first M1 of a new combo string ignites the enemy with tick damage for 3 seconds. Also burns Purgatory, Flame Undulation, Flame Tiger, and Blazing Universe. Burn does not stack.",
				burns = {
					"Purgatory",
					"Flame Undulation",
					"Flame Tiger",
					"Blazing Universe"
				}
			},
			{
				name = "Status Immunity",
				description = "Takes 50% less Flame damage, and is immune to Indomitable Will.",
				immunities = { "Indomitable Will" },
				resistances = {
					Flame = 0.5
				}
			}
		}
	},
	Soyama = {
		name = "Soyama",
		rarity = 7,
		archetype = "Ascendant",
		stats = {
			["Max Health"] = 255,
			["Max Stamina"] = 128,
			["Additional Damage Factor"] = 0.22,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.06
		},
		skills = {
			Shared.IndomitableWill,
			{
				name = "Combat Intuition",
				cooldown = 60,
				aura = "Golden, then red on the release",
				description = "Applies +8% Damage Reduction Factor for 12 seconds and stores a share of the damage the user deals in that window: 75% of what lands on players, 50% of what lands on NPCs. " .. Shared.STORED_DAMAGE
			},
			{
				name = "Bell Splitter",
				cooldown = 75,
				cooldownGroup = "Counter",
				maxHold = 4,
				skillStats = {
					counter = Menum.CounterType.All
				},
				description = "Tapping the key enters a stance. Getting hit during the stance triggers a counter that parries the blow and leaves the opponent stunned, with -30% Movement Speed Factor for 3 seconds and -35% Additional Damage Factor with fists for 10 seconds. A stance that catches nothing leaves the user unable to attack for 2 seconds: no skills and no swings, though they can still block and dash."
			}
		},
		passives = { Shared.EnhancedSpeed, Shared.PainResistance }
	},
	Uzui = {
		name = "Uzui",
		rarity = 7,
		archetype = "Ascendant",
		stats = {
			["Max Health"] = 248,
			["Max Stamina"] = 135,
			["Additional Damage Factor"] = 0.21,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.06
		},
		skills = {
			{
				name = "Enhanced Hearing",
				cooldown = 40,
				description = "The user stomps the ground, releasing a circular shockwave and marking everyone caught with a golden aura. For 10 seconds the marked enemy takes 25% more damage from the user."
			},
			{
				name = "Vital Draw",
				cooldown = 45,
				description = "Tapping this skill randomly draws one of 3 passives, each pulsing its own aura once from the user. Heart: a warm green aura pulse, restoring 150 health instantly. Muscle: a white aura pulse, dodging the next 5 M1 hits and granting +15% Additional Damage Factor with fists for 11 seconds. Lungs: a red aura pulse, granting +150 Max Stamina for 15 seconds and instantly restoring 150 stamina."
			},
			{
				name = "Musical Score",
				cooldown = 42.1875,
				description = "Listens for 6 seconds. The first skill that lands is recorded, without blocking or reducing its damage, and stored as an imprint for 30 seconds. Several can be stored at once. The next time a stored skill is used on the user, the user dodges it, along with the rest of that attack's hits for 2 seconds, and the imprint is spent."
			}
		},
		passives = {
			Shared.EnhancedSpeed,
			Shared.IndomitableWillImmunity,
			Shared.TacticalIntellect,
			Shared.PainResistance,
			{
				name = "Poison Immunity",
				description = "Immune to Poison.",
				immunities = { "Poison" }
			}
		}
	}
}