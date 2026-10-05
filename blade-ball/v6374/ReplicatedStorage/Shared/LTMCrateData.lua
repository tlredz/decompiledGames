local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.LTM)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.ServerInfo)
return {
	SpinTable = function(items, p: number)
		local total = 0

		for _, item in items do
			total += item.Probability
		end

		local v3 = Random.new(p):NextNumber() * total
		local total2 = 0

		for k, item in items do
			total2 += item.Probability

			if v3 <= total2 then
				return k, item
			end
		end

		return nil
	end,
	Profiles = {
		RobloxClassic = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Redcliff Claymore"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Gothic Squire's Sword"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Wind's Breath"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Firebrand's Fury"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Block Breaker"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Glitch Bomb"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Emote1189"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Emote1190"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Periastron's Glory"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createExplosionReward("Periastron's Ending"),
						ItemType = "Explosion"
					}
				}
			}
		},
		Dragon = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Traitor's Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Scale Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Abyssal Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Ember's Rage"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Molten Eruption"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Infernal Blast"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Emote359"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Emote360"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Bane of Ferocity"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createExplosionReward("Ferocitus' Awakening"),
						ItemType = "Explosion"
					}
				}
			}
		},
		Rebirth = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Hope's Dagger"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Edge of Resurgence"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Reclaimer's Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Eternal Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Life Pulse"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Reclaimer's Demise"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Unlikely Foe"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("The Cake"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Ashblade"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createExplosionReward("Phoenix's Wake"),
						ItemType = "Explosion"
					}
				}
			}
		},
		FloodSurvival = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 3,
					Tickets = 2
				},
				{
					Streak = 5,
					Tickets = 3
				},
				{
					Streak = 7,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Kelp Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Tidal Cutlass"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Aqua Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Maelstrom Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Whirlpool"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Abyssal Maelstrom"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Ice Cream Fail"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Backflip Baller"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Kraken's Wraith"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createExplosionReward("Beach Party"),
						ItemType = "Explosion"
					}
				}
			}
		},
		Shark = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Reef Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Hammerhead Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Tiger Shark"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Great White Fury"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Chum Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Coral Cataclysm"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Emote440"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Emote445"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Megatooth Relic"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createExplosionReward("Feeding Frenzy"),
						ItemType = "Explosion"
					}
				}
			}
		},
		Dodgeball = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Crimson Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Toxic Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Obsidian Wrath"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Lunaris Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Twilight Slasher"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Sunflare Katana"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createSwordReward("Astral Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createSwordReward("Aetherwing Blade"),
					ItemType = "Sword"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Golden Champion"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		HotPotato = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Rubber Chicken"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Noodle Nuisance"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Stop Sign"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Meme Destroyer"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Facepalm Blast"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("LOLplosion"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Emote561"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Coffin Dance"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Potato"),
					ItemType = "Sword",
					LimitedStock = true,
					Replacement = {
						Reward = v.createSwordReward("Long-nosed Scythe"),
						ItemType = "Sword"
					}
				}
			}
		},
		HalloweenEvent = {
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Nightstalker"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Soul Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Gravebane"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Phantom Reaver"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Coffin Eruption"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Banshee's Cry"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Eerie Chant"),
					ItemType = "Emote"
				},
				{
					Probability = 2.75,
					Reward = v.createEmoteReward("Spectral Waltz"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.25,
					Reward = v.createSwordReward("Eternal Nightmare"),
					ItemType = "Sword",
					LimitedStock = true,
					Replacement = {
						Reward = v.createSwordReward("Dreadspire Blade"),
						ItemType = "Sword"
					}
				}
			}
		},
		MysteryBall = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Voidpulse"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Holy Aetherwing"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Cinderfall"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Stellacore"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Verdant Judgment"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Abysspike"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createSwordReward("Blood Omen"),
					ItemType = "Sword"
				},
				{
					Probability = 2.75,
					Reward = v.createSwordReward("Tidebound Relic"),
					ItemType = "Sword"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.25,
					Reward = v.createSwordReward("Holy Blade"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		WinterRoyale = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Candy Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Frostbite Slash"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Polar Cleaver"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Blizzard Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Snowflake Nova"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Festive Blaze"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Reindeer Leap"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Ice Sculptors"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Frostbound Regal Edge"),
					ItemType = "Sword",
					LimitedStock = true,
					Replacement = {
						Reward = v.createSwordReward("Frost Monarch Saber"),
						ItemType = "Sword"
					}
				}
			}
		},
		SantasVsElves = {
			RewardPool = {}
		},
		Overdrive = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Neon Shard"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Synth Saber"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Mechslayer Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Hyperion Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Circuit Splash"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Overclock Blast"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Pulse Wave"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Mech Overdrive"),
					ItemType = "Emote"
				},
				{
					Probability = 0.1,
					Reward = v.createSwordReward("Overclocked"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		Fates = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Twilight Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Glyphfang"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Mystic Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Rune Carver"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Runewind Pulse"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Ethereal Glyphstorm"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Mark of the Fates"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Eclipse Ritual"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Solblade Sentinel"),
					ItemType = "Sword",
					LimitedStock = true,
					Replacement = {
						Reward = v.createSwordReward("Ancient Iceblade"),
						ItemType = "Sword"
					}
				}
			}
		},
		AbilityGame = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Ironfang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Runeblade"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Shadowpiercer"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Oblivion Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Infernal Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Celestial Detonation"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Victory Pose"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("We're Doomed"),
					ItemType = "Emote"
				},
				{
					Probability = 0.1,
					Reward = v.createSwordReward("Twisted Rosemary Blade"),
					ItemType = "Sword",
					LimitedStock = true,
					Replacement = {
						Reward = v.createSwordReward("Skull King"),
						ItemType = "Sword"
					}
				}
			}
		},
		Flying = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30,
					Reward = v.createSwordReward("Cosmic Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Zero Saber"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Asteroid Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Voidwalker Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Moonwalk Shuffle"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Zero-G Spin"),
					ItemType = "Emote"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Anti-Gravity Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Cosmic Implosion"),
					ItemType = "Explosion"
				},
				{
					Probability = 0.1,
					Reward = v.createSwordReward("Solar Iceblade"),
					ItemType = "Sword",
					Replacement = {
						Reward = v.createSwordReward("Nebula Warrior"),
						ItemType = "Sword"
					}
				}
			}
		},
		SquadRoyale = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Survivor's Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Stormpiercer Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Gale Sabre"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createEmoteReward("Walk This Earth"),
					ItemType = "Emote"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Flashpoint Detonation"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Stormbreaker Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Not My Lover"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Boom Shaka Laka"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Supercharged Amethyst Bow"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		LavaFloor = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Cinder Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Ashen Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Magma Splitter"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Sleek Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Lava Pop"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Volcanic Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Super Slide"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Elegeance"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Oblivion Scythe"),
					ItemType = "Sword"
				}
			}
		},
		CrownClash = {
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Thornblade"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Crescent Saber"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Loyal Oathblade"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Shatterthorn"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Knightfall Shock"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Thronebreaker"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Glitchstep"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Riftwalk"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Blooming Katana"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		LuckyBlocks = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Golden Snapper"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Fortune Carver"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Lucky Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Fortune Splitter"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Sparkburst"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Fortunate Sword"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createSwordReward("Lucky Dagger"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createExplosionReward("Jackpot Detonation"),
					ItemType = "Explosion"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Block Buster"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		Brainrot = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Lirilì Larilà Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Shark Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Capuchino Assassino Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Fish"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("BRR BRR PATAPIMPLOSION"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Porcospino Stivale"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Job Application"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Ballerina Capuchina Dance"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("TUNG TUNG TUNG SAHUR"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		OneAbility = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Vortex Striker"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Rosequartz Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Tinsel Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Vampire Sword"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Elven Touch"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Cursed Ashes"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createExplosionReward("Smoke Screen"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createSwordReward("Witchfire Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Draconic Greatsword"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		RedLightGreenLight = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Crimson Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Void Reaver"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Glimmeredge"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Stormpiercer"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Darkflare"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Starfall"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Laughing"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Popcorn"),
					ItemType = "Sword"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Viral Piercer"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		Tag = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Rotblade"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Gravepiercer"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Infected Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Ghoul Cleaver"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Toxic Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Necro Detonation"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Absolute Cinema"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Assumptions"),
					ItemType = "Sword"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Amethyst Fireblade"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		Hovergoal = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Violet Crusher"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Verdraith"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Rose Pinksaber"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Solaris Lance"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Bloodreaver"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Shadowcleaver"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createSwordReward("Stormreign"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createSwordReward("Celestara"),
					ItemType = "Sword"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Venomsanct"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		AbilityBlock = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Embroided Slasher"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Vanguard Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Goldfire Hammer"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createExplosionReward("Nova Impact"),
					ItemType = "Explosion"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Tempest Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Iron Reaver"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createExplosionReward("Shockwave Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 2.9,
					Reward = v.createSwordReward("Phantom Saber"),
					ItemType = "Sword"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Runic Dragonslayer"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		SnowballFight = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Embroided Slasher"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Vanguard Edge"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Goldfire Hammer"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createExplosionReward("Nova Impact"),
					ItemType = "Explosion"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Tempest Cutter"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Iron Reaver"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createExplosionReward("Shockwave Burst"),
					ItemType = "Explosion"
				},
				{
					Probability = 2.9,
					Reward = v.createSwordReward("Phantom Saber"),
					ItemType = "Sword"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createSwordReward("Runic Dragonslayer"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		},
		SheriffsVsOutlaws = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Tundraglass Greatblade"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Sea Warden"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Zombie Sword"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createEmoteReward("Shadow Boxing"),
					ItemType = "Emote"
				},
				{
					Probability = 25,
					Reward = v.createSwordReward("Phoenix Fang"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Twilight Slicer"),
					ItemType = "Sword"
				},
				{
					Probability = 6,
					Reward = v.createSwordReward("Pulse Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Astral Shift"),
					ItemType = "Emote"
				},
				{
					Probability = v2.isTestGame() and 30 or 0.05,
					Reward = v.createExplosionReward("Nebula Implosion"),
					ItemType = "Explosion",
					LimitedStock = true
				}
			}
		},
		Rebound = {
			DailyLoginStreaks = {
				{
					Streak = 1,
					Tickets = 1
				},
				{
					Streak = 2,
					Tickets = 2
				},
				{
					Streak = 3,
					Tickets = 3
				},
				{
					Streak = 4,
					Tickets = 4
				}
			},
			RewardPool = {
				{
					Probability = 30.05,
					Reward = v.createSwordReward("Redcliff Claymore"),
					ItemType = "Sword"
				},
				{
					Probability = 15,
					Reward = v.createSwordReward("Scale Blade"),
					ItemType = "Sword"
				},
				{
					Probability = 5,
					Reward = v.createSwordReward("Hope's Dagger"),
					ItemType = "Sword"
				},
				{
					Probability = 1,
					Reward = v.createSwordReward("Tidal Cutlass"),
					ItemType = "Sword"
				},
				{
					Probability = 25,
					Reward = v.createExplosionReward("Necro Detonation"),
					ItemType = "Explosion"
				},
				{
					Probability = 15,
					Reward = v.createExplosionReward("Whirlpool"),
					ItemType = "Explosion"
				},
				{
					Probability = 6,
					Reward = v.createEmoteReward("Backflip Baller"),
					ItemType = "Emote"
				},
				{
					Probability = 2.9,
					Reward = v.createEmoteReward("Super Slide"),
					ItemType = "Emote"
				},
				{
					Probability = 0.05,
					Reward = v.createSwordReward("Abyssal Sovereign"),
					ItemType = "Sword",
					LimitedStock = true
				}
			}
		}
	}
}