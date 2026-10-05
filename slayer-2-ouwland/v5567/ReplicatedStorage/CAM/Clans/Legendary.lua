local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Shared = require(script.Parent.Shared)
return {
	Kocho = {
		name = "Kocho",
		rarity = 5,
		archetype = "Phantom",
		stats = {
			["Max Health"] = 113,
			["Max Stamina"] = 26,
			["Additional Damage Factor"] = 0.12,
			["Movement Speed Factor"] = 0.05
		},
		skills = {
			{
				name = "Poison Draw Mode",
				mode = true,
				cooldown = 90,
				modeCost = 225,
				aura = "Green or brown by draw",
				description = "Mode. Grants +20% Insect Damage Factor, +10% Movement Speed Factor, +15% Dash Speed Factor, +10% Poison Damage Factor and +5% Cooldown Reduction Factor for the duration. Skills also gain one of two poison debuffs, rolled each time a skill lands: Neurotoxin Slow (-35% Movement Speed Factor and -10% Attack Speed Factor for 3 seconds) or Viral Decay (2% Max Health per second, growing 1% per tick up to 5%, over 4 seconds, does not stack)."
			}
		},
		passives = {
			{
				name = "Insect Affinity",
				description = "Insect Breathing skills poison their targets. +15% Poison Damage Factor.",
				effects = {
					{
						stats = {
							["Poison Damage Factor"] = 0.15
						}
					}
				}
			},
			{
				name = "Status Immunity",
				description = "Immune to Poison.",
				immunities = { "Poison" }
			},
			{
				name = "Toxic Essence",
				description = "If the user is killed by an opponent, that opponent takes 5% Max Health poison damage per second for 4 seconds."
			},
			{
				name = "Aerial Mastery",
				description = "Airborne Sword attacks deal 25% more damage."
			},
			{
				name = "Butterfly's Grace",
				description = "Below 30% health, gain +5% Movement Speed Factor and +30% Jump Power Factor.",
				effects = {
					{
						when = {
							stat = "Health",
							below = 0.3
						},
						stats = {
							["Movement Speed Factor"] = 0.05,
							["Jump Power Factor"] = 0.3
						}
					}
				}
			}
		}
	},
	Shabana = {
		name = "Shabana",
		rarity = 5,
		archetype = "Titan",
		stats = {
			["Max Health"] = 108,
			["Max Stamina"] = 25,
			["Additional Damage Factor"] = 0.13,
			["Movement Speed Factor"] = 0.05
		},
		skills = {
			{
				name = "Core Detachment",
				cooldown = 90,
				description = "Throws the user's Core at the targeted location, creating a Blood Demon Zone for 12 seconds. The user and any party member standing inside gain +25% Additional Damage Factor, +15% Max Health Factor and +6% Damage Reduction Factor, which linger 3 seconds after they leave it."
			},
			{
				name = "Poison Generation",
				cooldown = 35,
				aura = "Poison, on the hand and weapon",
				description = "For 7 seconds, M1s inflict Blood Poison, dealing 2% of the target's Max Health per second for 3 seconds. Stacks with multiple applications."
			}
		},
		passives = {
			Shared.PainResistance,
			{
				name = "Status Immunity",
				description = "Takes 75% less Poison damage.",
				resistances = {
					Poison = 0.75
				}
			},
			{
				name = "Tainted Blood",
				description = "If the user is killed by an opponent, that opponent takes -20% Movement Speed Factor for 5 seconds and 3 tick damage per second for 7 seconds."
			},
			{
				name = "Siblings Bond",
				description = "Within 15 meters of a party member, gain +5% Damage Reduction Factor, +4% Stamina Regen Speed and +5% Health Regen Speed, and grant allies in range +5% Additional Damage Factor."
			}
		}
	},
	Tomioka = {
		name = "Tomioka",
		rarity = 5,
		archetype = "Technician",
		stats = {
			["Max Health"] = 117,
			["Max Stamina"] = 24,
			["Additional Damage Factor"] = 0.15
		},
		skills = {
			{
				name = "Flowing Motion",
				cooldown = 75,
				description = "Resets the cooldowns of 2 random skills."
			}
		},
		passives = {
			Shared.PainResistance,
			{
				name = "Flowing Counter",
				description = "After blocking an attack, the next Water Breathing skill within 5 seconds deals 15% more damage."
			},
			{
				name = "Serenity Discount",
				description = "30% off the Wen price of shop purchases, refinement and crafting. Series set bills stay full price."
			},
			{
				name = "Water's Clarity",
				description = "Every 15 seconds in combat, gain +5% Water Damage Factor and -3% Water Stamina Cost Factor. Stacks up to 3 times, so +15% and -9% at 45 seconds."
			},
			{
				name = "Tidal Blood",
				description = "Water Breathing skills splash the opponent they hit with tidal blood, applying -20% Movement Speed Factor for 5 seconds."
			}
		}
	},
	Ubuyashiki = {
		name = "Ubuyashiki",
		rarity = 5,
		archetype = "Titan",
		stats = {
			["Max Health"] = 128,
			["Max Stamina"] = -10,
			["Additional Damage Factor"] = -0.06
		},
		skills = {
			{
				name = "Self-Destruct",
				cooldown = 60,
				description = "The user detonates themselves, dealing heavy damage to every nearby enemy, knocking them down and setting them alight for 5 seconds. The blast throws the user clear, and they take 10% of the damage dealt to each enemy caught."
			},
			{
				name = "Soothing Voice",
				cooldown = 75,
				description = "A calming command that renders an opponent's block completely ineffective for 5 seconds, letting attacks break through their guard."
			},
			{
				name = "Demon Slayer Summon",
				cooldown = 40,
				maxHold = 5,
				description = "Aim at an enemy and call in a Demon Slayer ally, who drops in beside the user and fights that target for 15 seconds, in either PvP or PvE. They arrive with one breathing skill, rolled fresh each summon."
			}
		},
		passives = {
			{
				name = "Enhanced Growth",
				description = "+10% Exp Factor.",
				effects = {
					{
						stats = {
							["Exp Factor"] = 0.1
						}
					}
				}
			},
			{
				name = "Enhanced Drop Luck",
				description = "+2% Drop Luck Factor.",
				effects = {
					{
						stats = {
							["Drop Luck Factor"] = 0.02
						}
					}
				}
			},
			{
				name = "Status Resistance",
				description = "Takes 50% less Poison, Flame and Frost damage.",
				resistances = {
					Poison = 0.5,
					Flame = 0.5,
					Frost = 0.5
				}
			}
		}
	}
}