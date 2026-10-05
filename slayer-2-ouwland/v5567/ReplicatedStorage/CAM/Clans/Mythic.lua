local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Shared = require(script.Parent.Shared)
return {
	Agatsuma = {
		name = "Agatsuma",
		rarity = 6,
		archetype = "Phantom",
		stats = {
			["Max Health"] = 158,
			["Max Stamina"] = 90,
			["Additional Damage Factor"] = 0.19,
			["Movement Speed Factor"] = 0.05,
			["Stamina Regen Speed"] = 0.04
		},
		skills = {
			{
				name = "Enhanced Hearing",
				cooldown = 40,
				description = "The user stomps the ground, releasing a circular shockwave and marking everyone caught with a golden aura. For 10 seconds the marked enemy takes 20% more damage from the user."
			},
			{
				name = "Sleepless Knight Mode",
				mode = true,
				cooldown = 90,
				modeCost = 330,
				aura = "Thunder",
				description = "Mode. Dealing damage charges the bar; once full the key press activates a thunder aura granting +20% Thunder Damage Factor, +3% Additional Damage Factor, +5% Movement Speed Factor, +35% Dash Speed Factor and +12% Cooldown Reduction Factor."
			}
		},
		passives = {
			Shared.MasterSwordsman,
			Shared.TacticalIntellect,
			{
				name = "Unconscious Combat",
				description = "Timid State, above 90% health: -5% Attack Speed Factor. Struggle Mode, below 60% health: +12% Additional Damage Factor, +4 Additional Damage and +5% Stamina Regen Speed.",
				effects = {
					{
						when = {
							stat = "Health",
							above = 0.9
						},
						stats = {
							["Attack Speed Factor"] = -0.05
						}
					},
					{
						when = {
							stat = "Health",
							below = 0.6
						},
						stats = {
							["Additional Damage Factor"] = 0.12,
							["Additional Damage"] = 4,
							["Stamina Regen Speed"] = 0.05
						}
					}
				}
			},
			{
				name = "Enhanced Speed",
				description = "+5% Movement Speed Factor, and Flaming Thunder God burns what it hits.",
				effects = {
					{
						stats = {
							["Movement Speed Factor"] = 0.05
						}
					}
				},
				burns = { "Flaming Thunder God" }
			}
		}
	},
	Douma = {
		name = "Douma",
		rarity = 6,
		archetype = "Tank",
		stats = {
			["Max Health"] = 180,
			["Max Stamina"] = 95,
			["Additional Damage Factor"] = 0.18,
			["Stamina Regen Speed"] = 0.05,
			["Damage Reduction"] = 1,
			["Damage Reduction Factor"] = 0.05,
			["Cold Immunity"] = true
		},
		skills = {
			{
				name = "Extrasensory Perception",
				cooldown = 40,
				description = "The user dodges the next 3 incoming attacks, skill or M1."
			},
			{
				name = "Speed & Reflex",
				cooldown = 40,
				skillStats = {
					stun_bypass_skill = true
				},
				description = "Leaves a clone standing where the user is. Pressing the key again within 12 seconds pulls them back to it from any distance, shaking off any stun or knockdown as they arrive. Castable while stunned."
			}
		},
		passives = {
			Shared.PainResistance,
			{
				name = "Reactive Adaptation",
				description = "Takes 50% less Poison and Flame damage. Immune to the freezing cold of snowy regions.",
				resistances = {
					Poison = 0.5,
					Flame = 0.5
				}
			},
			{
				name = "Keen Intellect",
				description = "+25% Evil Art and Weapon mastery."
			}
		}
	},
	Himejima = {
		name = "Himejima",
		rarity = 6,
		archetype = "Sentinel",
		stats = {
			["Max Health"] = 195,
			["Max Stamina"] = 90,
			["Additional Damage Factor"] = 0.17,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.05,
			["Block Points"] = 3,
			["Block Regen"] = 0.1
		},
		skills = {
			{
				name = "Stone Skin Mode",
				mode = true,
				cooldown = 90,
				modeCost = 255,
				aura = "Stone armor",
				description = "Mode. Enemies who M1 the user take 15% of the damage they dealt back, and the user gains +10% Damage Reduction Factor, +5% Movement Speed Factor, +4% Stamina Regen Speed and +5% Health Regen Speed."
			},
			{
				name = "Enhanced Hearing",
				cooldown = 40,
				description = "The user stomps the ground, releasing a circular shockwave and marking everyone caught with a golden aura. For 14 seconds the marked enemy takes 20% more damage from the user."
			}
		},
		passives = {
			Shared.PainResistance,
			Shared.TacticalIntellect,
			{
				name = "Repetitive Action",
				description = "Skill damage banks into a temporary M1 bonus: 100 skill damage grants +3 M1 damage. Stacks, and fades after 8 to 10 seconds."
			}
		}
	},
	Iguro = {
		name = "Iguro",
		rarity = 6,
		archetype = "Duelist",
		flavour = "All Iguro users have a serpent around their neck.",
		stats = {
			["Max Health"] = 165,
			["Max Stamina"] = 85,
			["Additional Damage Factor"] = 0.2,
			["Movement Speed Factor"] = 0.05,
			["Damage Reduction"] = 1,
			["Damage Reduction Factor"] = 0.02
		},
		skills = {
			{
				name = "Kaburamaru",
				cooldown = 35,
				description = "Hold to aim, release to send the serpent. At long range it homes in on the target and bites it repeatedly for 6 seconds, each bite dealing 1.5% Max Health tick damage and applying Poison, 0.75% Max Health per second for 4 seconds, which does not stack. Up close it latches straight onto the target instead, and a second key press binds them for 1.3 seconds. The snake lasts 4 seconds on the opponent."
			},
			{
				name = "Flash Step",
				cooldown = 6,
				maxHold = 1.5,
				skillStats = {
					iframe = true,
					stun_bypass_skill = true,
					cancel_bypass = true
				},
				requiresAura = "Serpent's Wrath Mode",
				description = "Hold to vanish for up to 1.5 seconds and fly wherever the user steers, camera up and down included. Release to reappear."
			},
			{
				name = "Serpent's Wrath Mode",
				mode = true,
				cooldown = 90,
				modeCost = 300,
				aura = "Serpent",
				description = "Mode. Grants Flash Step, a white aura dash that vanishes for a second before reappearing, plus +15% Serpent Damage Factor, +3% Additional Damage Factor, +5% Movement Speed Factor and +4% Stamina Regen Speed."
			}
		},
		passives = {
			Shared.PainResistance,
			Shared.MasterSwordsman,
			{
				name = "Venomous Precision",
				description = "If the user is killed by an opponent, that opponent takes 25% Max Health damage."
			},
			{
				name = "Serpent's Venom",
				description = "+15% Poison Damage Factor, and takes 50% less Poison damage.",
				effects = {
					{
						stats = {
							["Poison Damage Factor"] = 0.15
						}
					}
				},
				resistances = {
					Poison = 0.5
				}
			}
		}
	},
	Shinazugawa = {
		name = "Shinazugawa",
		rarity = 6,
		archetype = "Tank",
		stats = {
			["Max Health"] = 203,
			["Health Regen Speed"] = 0.05,
			["Max Stamina"] = 90,
			["Additional Damage Factor"] = 0.18,
			["Movement Speed Factor"] = 0.05,
			["Damage Reduction"] = 2,
			["Damage Reduction Factor"] = 0.03
		},
		skills = {
			{
				name = "Marechi's Blade",
				cooldown = 30,
				aura = "Bloody, on the arms",
				description = "For 10 seconds, the user sacrifices 10% of their Max Health to wrap the blade in a purple aura, and every M1 applies 3 Poison tick damage."
			},
			{
				name = "Windstorm Vigor Mode",
				mode = true,
				cooldown = 90,
				modeCost = 300,
				aura = "Windstorm",
				description = "Mode. Grants +20% Wind Damage Factor, +10% Additional Damage Factor, -10% Stamina Cost Factor and +5% Movement Speed Factor."
			}
		},
		passives = {
			Shared.PainResistance,
			Shared.TacticalIntellect,
			{
				name = "Marechi's Blood",
				description = "Any M1 dealt to the user has a 10% chance to poison the attacker for 2% Max Health per second over 5 seconds and apply -15% Movement Speed Factor for 3 seconds. If the user is killed by an opponent, that opponent takes 10% Max Health damage and -10% Movement Speed Factor for 10 seconds."
			},
			{
				name = "Unyielding Spirit",
				description = "Below 30% health, gain +15% Damage Reduction Factor and +5% Additional Damage Factor.",
				effects = {
					{
						when = {
							stat = "Health",
							below = 0.3
						},
						stats = {
							["Damage Reduction Factor"] = 0.15,
							["Additional Damage Factor"] = 0.05
						}
					}
				}
			},
			{
				name = "Weapon Versatility",
				description = "+25% Katana and Weapon mastery."
			}
		}
	},
	Tamayo = {
		name = "Tamayo",
		rarity = 6,
		archetype = "Titan",
		stats = {
			["Max Health"] = 175,
			["Max Stamina"] = 75,
			["Additional Damage Factor"] = 0.17,
			["Health Regen Speed"] = 0.04,
			["Damage Reduction"] = 1
		},
		skills = {
			{
				name = "Pharmaceutical Skills",
				cooldown = 120,
				description = "Places down a healing ring that restores 20% Max Health and resets all cooldowns, once per person."
			},
			{
				name = "Demon Coagulant",
				cooldown = 30,
				description = "A swift jab that catches everyone in front of the user and holds them while a dose goes in, then throws them down. The dose deals 3 seconds of tick damage and applies -20% Additional Damage Factor for 5 seconds. Missing costs the user nothing."
			},
			{
				name = "Blood Bewitchment",
				cooldown = 30,
				aura = "Purple perfume",
				description = "Releases a purple perfume aura around the user for 10 seconds. Any opponent that lands a hit on the user while inside the aura is inflicted with Bewitched for 4 seconds: -6% Movement Speed Factor, +6% Stamina Drain Rate, and -3% Block Regen. Does not stack, re-hitting the user refreshes the debuff duration instead of applying it again."
			}
		},
		passives = {}
	}
}