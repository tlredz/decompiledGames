local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.TitleTypes)
return {
	slayer = {
		displayName = "Slayer",
		category = "Race",
		rarity = "Common",
		description = "Survive the Final Selection.",
		requirements = {
			{
				counter = "final_selections",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Max Stamina",
				amount = 10
			},
			{
				stat = "Stamina Regen Speed",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 5
			}
		},
		disabled = false
	},
	demon = {
		displayName = "Demon",
		category = "Race",
		rarity = "Common",
		description = "Drink Muzan's blood and become a demon.",
		requirements = {
			{
				counter = "demon_conversions",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			},
			{
				stat = "Evil Art Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	blooded = {
		displayName = "Blooded",
		category = "Combat",
		rarity = "Common",
		description = "Slay 500 enemies.",
		requirements = {
			{
				counter = "kills",
				threshold = 500
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.009,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	reaper = {
		displayName = "Reaper",
		category = "Combat",
		rarity = "Legendary",
		description = "Slay 15,000 enemies.",
		requirements = {
			{
				counter = "kills",
				threshold = 15000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			},
			{
				stat = "Max Health",
				amount = 12
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 11
			}
		},
		disabled = false
	},
	challenger = {
		displayName = "Challenger",
		category = "Combat",
		rarity = "Common",
		description = "Defeat 10 bosses.",
		requirements = {
			{
				counter = "boss_kills",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	monster_hunter = {
		displayName = "Monster Hunter",
		category = "Combat",
		rarity = "Epic",
		description = "Defeat 100 bosses.",
		requirements = {
			{
				counter = "boss_kills",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 8
			}
		},
		disabled = false
	},
	nemesis = {
		displayName = "Nemesis",
		category = "Combat",
		rarity = "Legendary",
		description = "Defeat 500 bosses.",
		requirements = {
			{
				counter = "boss_kills",
				threshold = 500
			}
		},
		buffs = {
			{
				stat = "Attack Speed Factor",
				amount = 0.03,
				isRatio = true
			},
			{
				stat = "Max Health",
				amount = 12
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 11
			}
		},
		disabled = false
	},
	bruised = {
		displayName = "Bruised",
		category = "Combat",
		rarity = "Common",
		description = "Die 50 times.",
		requirements = {
			{
				counter = "deaths",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	scarred = {
		displayName = "Scarred",
		category = "Combat",
		rarity = "Rare",
		description = "Die 250 times.",
		requirements = {
			{
				counter = "deaths",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Damage Reduction",
				amount = 0.5
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 6
			}
		},
		disabled = false
	},
	relentless = {
		displayName = "Relentless",
		category = "Combat",
		rarity = "Legendary",
		description = "Die 1,000 times.",
		requirements = {
			{
				counter = "deaths",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Damage Reduction Factor",
				amount = 0.025,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 11
			}
		},
		disabled = false
	},
	hard_hitter = {
		displayName = "Hard Hitter",
		category = "Combat",
		rarity = "Common",
		description = "Deal 50,000 total damage.",
		requirements = {
			{
				counter = "damage_dealt",
				threshold = 50000
			}
		},
		buffs = {
			{
				stat = "Additional Damage",
				amount = 0.75
			}
		},
		collection = {
			{
				stat = "Additional Damage",
				amount = 0.1
			}
		},
		disabled = false
	},
	bonebreaker = {
		displayName = "Bonebreaker",
		category = "Combat",
		rarity = "Rare",
		description = "Deal 500,000 total damage.",
		requirements = {
			{
				counter = "damage_dealt",
				threshold = 500000
			}
		},
		buffs = {
			{
				stat = "Additional Damage",
				amount = 1
			}
		},
		collection = {
			{
				stat = "Additional Damage",
				amount = 0.15
			}
		},
		disabled = false
	},
	devastator = {
		displayName = "Devastator",
		category = "Combat",
		rarity = "Epic",
		description = "Deal 2,500,000 total damage.",
		requirements = {
			{
				counter = "damage_dealt",
				threshold = 2500000
			}
		},
		buffs = {
			{
				stat = "Additional Damage",
				amount = 1.5
			}
		},
		collection = {
			{
				stat = "Additional Damage",
				amount = 0.2
			}
		},
		disabled = false
	},
	annihilator = {
		displayName = "Annihilator",
		category = "Combat",
		rarity = "Legendary",
		description = "Deal 10,000,000 total damage.",
		requirements = {
			{
				counter = "damage_dealt",
				threshold = 10000000
			}
		},
		buffs = {
			{
				stat = "Additional Damage",
				amount = 2
			}
		},
		collection = {
			{
				stat = "Additional Damage",
				amount = 0.25
			}
		},
		disabled = false
	},
	night_stalker = {
		displayName = "Night Stalker",
		category = "Combat",
		rarity = "Rare",
		description = "Slay 1,000 enemies after dark.",
		requirements = {
			{
				counter = "night_kills",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	hashiras_bane = {
		displayName = "Hashira's Bane",
		category = "Combat",
		rarity = "Legendary",
		description = "Defeat 100 Hashira.",
		requirements = {
			{
				counter = "hashira_kills",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	defender = {
		displayName = "Defender",
		category = "Combat",
		rarity = "Common",
		description = "Block 100 attacks.",
		requirements = {
			{
				counter = "blocks",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Block Regen",
				amount = 0.06,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	bulwark = {
		displayName = "Bulwark",
		category = "Combat",
		rarity = "Rare",
		description = "Block 1,000 attacks.",
		requirements = {
			{
				counter = "blocks",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Block Regen",
				amount = 0.1,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	living_fortress = {
		displayName = "Living Fortress",
		category = "Combat",
		rarity = "Legendary",
		description = "Block 10,000 attacks.",
		requirements = {
			{
				counter = "blocks",
				threshold = 10000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	unpredictable = {
		displayName = "Unpredictable",
		category = "Combat",
		rarity = "Common",
		description = "Perfect block 10 times.",
		requirements = {
			{
				counter = "perfect_blocks",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Block Regen",
				amount = 0.06,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	untouchable = {
		displayName = "Untouchable",
		category = "Combat",
		rarity = "Epic",
		description = "Perfect block 100 times.",
		requirements = {
			{
				counter = "perfect_blocks",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	unbreakable = {
		displayName = "Unbreakable",
		category = "Combat",
		rarity = "Legendary",
		description = "Perfect block 1,000 times.",
		requirements = {
			{
				counter = "perfect_blocks",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Damage Reduction Factor",
				amount = 0.025,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	one_man_party = {
		displayName = "One Man Party",
		category = "Combat",
		rarity = "Rare",
		description = "Defeat 10 bosses alone.",
		requirements = {
			{
				counter = "solo_boss_kills",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	lone_blade = {
		displayName = "Lone Blade",
		category = "Combat",
		rarity = "Epic",
		description = "Defeat 100 bosses alone.",
		requirements = {
			{
				counter = "solo_boss_kills",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	one_man_army = {
		displayName = "One Man Army",
		category = "Combat",
		rarity = "Legendary",
		description = "Defeat 500 bosses alone.",
		requirements = {
			{
				counter = "solo_boss_kills",
				threshold = 500
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	odd_jobber = {
		displayName = "Odd-Jobber",
		category = "Progression",
		rarity = "Common",
		description = "Complete 25 quests.",
		requirements = {
			{
				counter = "quests",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Quest Exp Factor",
				amount = 0.03,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 5
			}
		},
		disabled = false
	},
	village_pillar = {
		displayName = "Village Pillar",
		category = "Progression",
		rarity = "Rare",
		description = "Complete 150 quests.",
		requirements = {
			{
				counter = "quests",
				threshold = 150
			}
		},
		buffs = {
			{
				stat = "Quest Exp Factor",
				amount = 0.04,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 7
			}
		},
		disabled = false
	},
	oathkeeper = {
		displayName = "Oathkeeper",
		category = "Progression",
		rarity = "Legendary",
		description = "Complete 500 quests.",
		requirements = {
			{
				counter = "quests",
				threshold = 500
			}
		},
		buffs = {
			{
				stat = "Quest Exp Factor",
				amount = 0.08,
				isRatio = true
			},
			{
				stat = "Max Stamina",
				amount = 12
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 13
			}
		},
		disabled = false
	},
	escort_captain = {
		displayName = "Escort Captain",
		category = "Progression",
		rarity = "Rare",
		description = "See 50 escorts safely home.",
		requirements = {
			{
				counter = "escorts",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 15
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	living_legend = {
		displayName = "Living Legend",
		category = "Progression",
		rarity = "Mythic",
		description = "Reach the level cap.",
		requirements = {
			{
				counter = "level",
				threshold = 225
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	devoted_follower = {
		displayName = "Devoted Follower",
		category = "Progression",
		rarity = "Rare",
		description = "Complete 50 crow or Muzan quests.",
		requirements = {
			{
				counter = "crow_quests",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Quest Exp Factor",
				amount = 0.04,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	unwavering_loyalty = {
		displayName = "Unwavering Loyalty",
		category = "Progression",
		rarity = "Legendary",
		description = "Complete 250 crow or Muzan quests.",
		requirements = {
			{
				counter = "crow_quests",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Quest Exp Factor",
				amount = 0.08,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	kind_soul = {
		displayName = "Kind Soul",
		category = "Reputation",
		rarity = "Common",
		description = "Reach 1,000 reputation.",
		requirements = {
			{
				counter = "reputation",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	trusted_ally = {
		displayName = "Trusted Ally",
		category = "Reputation",
		rarity = "Epic",
		description = "Reach 10,000 reputation.",
		requirements = {
			{
				counter = "reputation",
				threshold = 10000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	humanitys_savior = {
		displayName = "Humanity's Savior",
		category = "Reputation",
		rarity = "Legendary",
		description = "Reach 100,000 reputation.",
		requirements = {
			{
				counter = "reputation",
				threshold = 100000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	evil_soul = {
		displayName = "Evil Soul",
		category = "Reputation",
		rarity = "Common",
		description = "Sink to -1,000 reputation.",
		requirements = {
			{
				counter = "infamy",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.009,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	public_enemy = {
		displayName = "Public Enemy",
		category = "Reputation",
		rarity = "Epic",
		description = "Sink to -10,000 reputation.",
		requirements = {
			{
				counter = "infamy",
				threshold = 10000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	global_threat = {
		displayName = "Global Threat",
		category = "Reputation",
		rarity = "Legendary",
		description = "Sink to -100,000 reputation.",
		requirements = {
			{
				counter = "infamy",
				threshold = 100000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	gladiator = {
		displayName = "Gladiator",
		category = "Ranked",
		rarity = "Common",
		description = "Win 10 ranked fights.",
		requirements = {
			{
				counter = "arena_wins",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	conqueror = {
		displayName = "Conqueror",
		category = "Ranked",
		rarity = "Epic",
		description = "Win 50 ranked fights.",
		requirements = {
			{
				counter = "arena_wins",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	unrivaled = {
		displayName = "Unrivaled",
		category = "Ranked",
		rarity = "Legendary",
		description = "Win 250 ranked fights.",
		requirements = {
			{
				counter = "arena_wins",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	unstoppable = {
		displayName = "Unstoppable",
		category = "Ranked",
		rarity = "Mythic",
		description = "Win 25 ranked fights in a row.",
		requirements = {
			{
				counter = "arena_streak",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	prospector = {
		displayName = "Prospector",
		category = "Exploration",
		rarity = "Common",
		description = "Open 25 chests.",
		requirements = {
			{
				counter = "chests",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Movement Speed Factor",
				amount = 0.018,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Run Speed Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		disabled = false
	},
	vaultbreaker = {
		displayName = "Vaultbreaker",
		category = "Exploration",
		rarity = "Legendary",
		description = "Open 500 chests.",
		requirements = {
			{
				counter = "chests",
				threshold = 500
			}
		},
		buffs = {
			{
				stat = "Movement Speed Factor",
				amount = 0.032,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Movement Speed Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		disabled = false
	},
	seal_breaker = {
		displayName = "Seal Breaker",
		category = "Exploration",
		rarity = "Common",
		description = "Clear 10 sealed chests.",
		requirements = {
			{
				counter = "events",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Block Regen",
				amount = 0.06,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	warden = {
		displayName = "Warden",
		category = "Exploration",
		rarity = "Rare",
		description = "Clear 50 sealed chests.",
		requirements = {
			{
				counter = "events",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Block Regen",
				amount = 0.1,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 6
			}
		},
		disabled = false
	},
	calamitys_end = {
		displayName = "Calamity's End",
		category = "Exploration",
		rarity = "Legendary",
		description = "Clear 200 sealed chests.",
		requirements = {
			{
				counter = "events",
				threshold = 200
			}
		},
		buffs = {
			{
				stat = "Damage Reduction Factor",
				amount = 0.025,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 11
			}
		},
		disabled = false
	},
	bounty_hunter = {
		displayName = "Bounty Hunter",
		category = "Exploration",
		rarity = "Common",
		description = "Complete 25 boss hunts.",
		requirements = {
			{
				counter = "boss_hunts",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	hunt_master = {
		displayName = "Hunt Master",
		category = "Exploration",
		rarity = "Epic",
		description = "Complete 250 boss hunts.",
		requirements = {
			{
				counter = "boss_hunts",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	wanderer = {
		displayName = "Wanderer",
		category = "Exploration",
		rarity = "Common",
		description = "Set foot in every region.",
		requirements = {
			{
				counter = "visited_Bamboo Grove",
				threshold = 1
			},
			{
				counter = "visited_Butterfly Estate",
				threshold = 1
			},
			{
				counter = "visited_Final Selection Plains",
				threshold = 1
			},
			{
				counter = "visited_Hidden Mist Village",
				threshold = 1
			},
			{
				counter = "visited_Iceveil Valley",
				threshold = 1
			},
			{
				counter = "visited_Mistfall Harbor",
				threshold = 1
			},
			{
				counter = "visited_Windy Peak",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	refiner = {
		displayName = "Refiner",
		category = "Crafting",
		rarity = "Rare",
		description = "Refine an item to +10.",
		requirements = {
			{
				counter = "refine_level",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	forgemaster = {
		displayName = "Forgemaster",
		category = "Crafting",
		rarity = "Epic",
		description = "Craft 5 Series pieces.",
		requirements = {
			{
				counter = "series_crafted",
				threshold = 5
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	master_smith = {
		displayName = "Master Smith",
		category = "Crafting",
		rarity = "Legendary",
		description = "Take a Series piece to Tier 3.",
		requirements = {
			{
				counter = "series_tier",
				threshold = 3
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	tower_runner = {
		displayName = "Tower Runner",
		category = "Ouwigahara",
		rarity = "Common",
		description = "Finish 10 tower runs past floor 10.",
		requirements = {
			{
				counter = "tower_runs",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 4
			}
		},
		disabled = false
	},
	spire_regular = {
		displayName = "Spire Regular",
		category = "Ouwigahara",
		rarity = "Rare",
		description = "Finish 50 tower runs past floor 10.",
		requirements = {
			{
				counter = "tower_runs",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Max Stamina",
				amount = 15
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 7
			}
		},
		disabled = false
	},
	endless = {
		displayName = "Endless",
		category = "Ouwigahara",
		rarity = "Legendary",
		description = "Finish 200 tower runs past floor 10.",
		requirements = {
			{
				counter = "tower_runs",
				threshold = 200
			}
		},
		buffs = {
			{
				stat = "Max Stamina",
				amount = 24
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 13
			}
		},
		disabled = false
	},
	climber = {
		displayName = "Climber",
		category = "Ouwigahara",
		rarity = "Common",
		description = "Reach floor 25 of the tower.",
		requirements = {
			{
				counter = "tower_floor",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Max Stamina",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 5
			}
		},
		disabled = false
	},
	highclimber = {
		displayName = "Highclimber",
		category = "Ouwigahara",
		rarity = "Epic",
		description = "Reach floor 50 of the tower.",
		requirements = {
			{
				counter = "tower_floor",
				threshold = 50
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 8
			}
		},
		disabled = false
	},
	roof_of_the_world = {
		displayName = "Heaven's Doorstep",
		category = "Ouwigahara",
		rarity = "Mythic",
		description = "Stand at the top of Ouwigahara.",
		requirements = {
			{
				counter = "tower_summits",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 13
			}
		},
		disabled = false
	},
	stairwalker = {
		displayName = "Stairwalker",
		category = "Ouwigahara",
		rarity = "Legendary",
		description = "Wear it in the tower: from the floor that earned it, the draft starts dealing a way around.",
		requirements = {
			{
				counter = "tower_floor",
				threshold = 90
			}
		},
		vanityOnly = true,
		hidden = true,
		disabled = false
	},
	spire_banker = {
		displayName = "Spire Banker",
		category = "Ouwigahara",
		rarity = "Rare",
		description = "Bank 1,000,000 tower points.",
		requirements = {
			{
				counter = "tower_points",
				threshold = 1000000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 15
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	cache_cracker = {
		displayName = "Cache Cracker",
		category = "Ouwigahara",
		rarity = "Epic",
		description = "Open 250 tower caches.",
		requirements = {
			{
				counter = "tower_caches",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	skybound = {
		displayName = "Skybound",
		category = "Ouwigahara",
		rarity = "Legendary",
		description = "Reach floor 75 of the tower.",
		requirements = {
			{
				counter = "tower_floor",
				threshold = 75
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	spire_magnate = {
		displayName = "Spire Magnate",
		category = "Ouwigahara",
		rarity = "Legendary",
		description = "Bank 25,000,000 tower points.",
		requirements = {
			{
				counter = "tower_points",
				threshold = 25000000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	sky_warden = {
		displayName = "Sky Warden",
		category = "Ouwigahara",
		rarity = "Mythic",
		description = "Stand at the top of Ouwigahara 10 times.",
		requirements = {
			{
				counter = "tower_summits",
				threshold = 10
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	spire_eternal = {
		displayName = "Spire Eternal",
		category = "Ouwigahara",
		rarity = "Mythic",
		description = "Finish 1,000 tower runs past floor 10.",
		requirements = {
			{
				counter = "tower_runs",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.03,
				isRatio = true
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	wildcard = {
		displayName = "Wildcard",
		category = "Roguelike",
		rarity = "Common",
		description = "Reach floor 20 in a Roguelike. Worn into one: a build hand each run rerolls for free.",
		requirements = {
			{
				counter = "roguelike_floor",
				threshold = 20
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	run_regular = {
		displayName = "Regular",
		category = "Roguelike",
		rarity = "Common",
		description = "Finish 25 Roguelike runs past floor 20. Worn into one: you start holding a Heal card.",
		requirements = {
			{
				counter = "roguelike_runs",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.009,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 3
			}
		},
		disabled = false
	},
	deep_draft = {
		displayName = "Deep Draft",
		category = "Roguelike",
		rarity = "Rare",
		description = "Reach floor 40 in a Roguelike. Worn into one: every build hand deals one more card.",
		requirements = {
			{
				counter = "roguelike_floor",
				threshold = 40
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	token_hoarder = {
		displayName = "Token Hoarder",
		category = "Roguelike",
		rarity = "Rare",
		description = "Earn 300 Ouwigahara Tokens. Worn into a Roguelike: you start holding a Potion card.",
		requirements = {
			{
				counter = "tokens_earned",
				threshold = 300
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 15
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	boss_breaker = {
		displayName = "Boss Breaker",
		category = "Roguelike",
		rarity = "Rare",
		description = "Defeat 100 bosses in Roguelikes. Worn into one: you deal 10% more damage to its bosses.",
		requirements = {
			{
				counter = "roguelike_bosses",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.01,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	party_anchor = {
		displayName = "Party Anchor",
		category = "Roguelike",
		rarity = "Rare",
		description = "Finish 25 party Roguelikes past floor 20. Worn into one: a teammate you revive comes back with every heart they started with.",
		requirements = {
			{
				counter = "roguelike_party_runs",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 15
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 5
			}
		},
		disabled = false
	},
	fates_gambler = {
		displayName = "Fate's Gambler",
		category = "Roguelike",
		rarity = "Epic",
		description = "Reach floor 60 in a Roguelike. Worn into one: 15% more damage dealt, 15% less max health.",
		requirements = {
			{
				counter = "roguelike_floor",
				threshold = 60
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	veteran = {
		displayName = "Veteran",
		category = "Roguelike",
		rarity = "Epic",
		description = "Finish 100 Roguelike runs past floor 20. Worn into one: your first build hand is all Rare or better.",
		requirements = {
			{
				counter = "roguelike_runs",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	collector = {
		displayName = "Collector",
		category = "Roguelike",
		rarity = "Epic",
		description = "Earn 1,000 Ouwigahara Tokens. Worn into a Roguelike: Forge cards come twice as often.",
		requirements = {
			{
				counter = "tokens_earned",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	gravedigger = {
		displayName = "Gravedigger",
		category = "Roguelike",
		rarity = "Epic",
		description = "Defeat 5,000 enemies in Roguelikes. Worn into one: every 150th kill you hold one more Heal card.",
		requirements = {
			{
				counter = "roguelike_kills",
				threshold = 5000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.012,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	flawless = {
		displayName = "Flawless",
		category = "Roguelike",
		rarity = "Epic",
		description = "Reach floor 30 of a Roguelike without losing a heart. Worn into one: the first hit you take each floor is halved.",
		requirements = {
			{
				counter = "roguelike_flawless_floor",
				threshold = 30
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 20
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 7
			}
		},
		disabled = false
	},
	unwritten = {
		displayName = "Unwritten",
		category = "Roguelike",
		rarity = "Legendary",
		description = "Reach floor 80 in a Roguelike. Worn into one: your first fall each run costs no heart.",
		requirements = {
			{
				counter = "roguelike_floor",
				threshold = 80
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	undying = {
		displayName = "Undying",
		category = "Roguelike",
		rarity = "Legendary",
		description = "Finish 300 Roguelike runs past floor 20. Worn into one: one more heart every run.",
		requirements = {
			{
				counter = "roguelike_runs",
				threshold = 300
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	tokenlord = {
		displayName = "Tokenlord",
		category = "Roguelike",
		rarity = "Legendary",
		description = "Earn 3,000 Ouwigahara Tokens. Worn into a Roguelike: milestone hands deal a rarity higher.",
		requirements = {
			{
				counter = "tokens_earned",
				threshold = 3000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	draft_master = {
		displayName = "Draft Master",
		category = "Roguelike",
		rarity = "Legendary",
		description = "Pick 1,000 build cards in Roguelikes. Worn into one: Reroll cards are dealt twice as often.",
		requirements = {
			{
				counter = "roguelike_cards",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.022,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	bossbane = {
		displayName = "Bossbane",
		category = "Roguelike",
		rarity = "Legendary",
		description = "Defeat 1,000 bosses in Roguelikes. Worn into one: every boss you kill deals you a Potion card.",
		requirements = {
			{
				counter = "roguelike_bosses",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 30
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 9
			}
		},
		disabled = false
	},
	skywritten = {
		displayName = "Skywritten",
		category = "Roguelike",
		rarity = "Mythic",
		description = "Reach floor 100 in a Roguelike. Worn into one: you start with a Legendary build card.",
		requirements = {
			{
				counter = "roguelike_floor",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	eternal = {
		displayName = "Eternal",
		category = "Roguelike",
		rarity = "Mythic",
		description = "Finish 1,000 Roguelike runs past floor 20. Worn into one: one more heart and a free reroll every run.",
		requirements = {
			{
				counter = "roguelike_runs",
				threshold = 1000
			}
		},
		buffs = {
			{
				stat = "Max Health",
				amount = 40
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	token_baron = {
		displayName = "Token Baron",
		category = "Roguelike",
		rarity = "Mythic",
		description = "Earn 10,000 Ouwigahara Tokens. Worn into a Roguelike: every milestone hand holds a Forge card.",
		requirements = {
			{
				counter = "tokens_earned",
				threshold = 10000
			}
		},
		buffs = {
			{
				stat = "Additional Damage Factor",
				amount = 0.03,
				isRatio = true
			},
			{
				stat = "Damage Reduction Factor",
				amount = 0.035,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 10
			}
		},
		disabled = false
	},
	angler = {
		displayName = "Angler",
		category = "Fishing",
		rarity = "Common",
		description = "Catch 100 common fish.",
		requirements = {
			{
				counter = "fish_common",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Bite Speed Factor",
				amount = 0.03,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Stamina",
				amount = 5
			}
		},
		disabled = false
	},
	deep_water_angler = {
		displayName = "Deep Water Angler",
		category = "Fishing",
		rarity = "Rare",
		description = "Catch 250 rare fish.",
		requirements = {
			{
				counter = "fish_rare",
				threshold = 250
			}
		},
		buffs = {
			{
				stat = "Bite Speed Factor",
				amount = 0.05,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breath Duration Factor",
				amount = 0.05,
				isRatio = true
			}
		},
		disabled = false
	},
	leviathan_hunter = {
		displayName = "Leviathan Hunter",
		category = "Fishing",
		rarity = "Epic",
		description = "Catch 100 legendary fish.",
		requirements = {
			{
				counter = "fish_legendary",
				threshold = 100
			}
		},
		buffs = {
			{
				stat = "Fishing Luck Factor",
				amount = 0.05,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Max Health",
				amount = 8
			}
		},
		disabled = false
	},
	salvager = {
		displayName = "Salvager",
		category = "Fishing",
		rarity = "Legendary",
		description = "Pull 25 lost items out of the water.",
		requirements = {
			{
				counter = "fish_items",
				threshold = 25
			}
		},
		buffs = {
			{
				stat = "Fishing Luck Factor",
				amount = 0.08,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breath Duration Factor",
				amount = 0.1,
				isRatio = true
			}
		},
		disabled = false
	},
	legendary_fisherman = {
		displayName = "Legendary Fisherman",
		category = "Fishing",
		rarity = "Legendary",
		description = "Inherit the drowned fisherman's line.",
		requirements = {
			{
				counter = "legendary_rods",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Fishing Luck Factor",
				amount = 0.07,
				isRatio = true
			},
			{
				stat = "Bite Speed Factor",
				amount = 0.05,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breath Duration Factor",
				amount = 0.06,
				isRatio = true
			}
		},
		hidden = true,
		disabled = false
	},
	mastered_flame = {
		displayName = "Flame Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Flame Breathing.",
		requirements = {
			{
				counter = "mastered_Flame",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 45, 30)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(230, 45, 30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 45)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 250, 235)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 250, 235))
		}),
		disabled = false
	},
	mastered_insect = {
		displayName = "Insect Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Insect Breathing.",
		requirements = {
			{
				counter = "mastered_Insect",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 85, 210)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(150, 85, 210)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(215, 130, 225)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(250, 232, 250)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 232, 250))
		}),
		disabled = false
	},
	mastered_serpent = {
		displayName = "Serpent Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Serpent Breathing.",
		requirements = {
			{
				counter = "mastered_Serpent",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 45, 165)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(95, 45, 165)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(165, 110, 235)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(240, 228, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 228, 255))
		}),
		disabled = false
	},
	mastered_sound = {
		displayName = "Sound Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Sound Breathing.",
		requirements = {
			{
				counter = "mastered_Sound",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 120, 35)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(240, 120, 35)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 185, 80)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 240, 215)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 215))
		}),
		disabled = false
	},
	mastered_stone = {
		displayName = "Stone Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Stone Breathing.",
		requirements = {
			{
				counter = "mastered_Stone",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 120, 80)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(150, 120, 80)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 180, 145)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(242, 238, 228)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 238, 228))
		}),
		disabled = false
	},
	mastered_thunder = {
		displayName = "Thunder Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Thunder Breathing.",
		requirements = {
			{
				counter = "mastered_Thunder",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 205, 35)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(250, 205, 35)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(249, 243, 129)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		disabled = false
	},
	mastered_water = {
		displayName = "Water Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Water Breathing.",
		requirements = {
			{
				counter = "mastered_Water",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 95, 190)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(14, 95, 190)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(85, 195, 240)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(236, 250, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(236, 250, 255))
		}),
		disabled = false
	},
	mastered_wind = {
		displayName = "Wind Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Wind Breathing.",
		requirements = {
			{
				counter = "mastered_Wind",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Breathing Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 180, 165)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(120, 180, 165)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(195, 230, 220)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(248, 255, 253)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 255, 253))
		}),
		disabled = false
	},
	mastered_arrow = {
		displayName = "Arrow Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Arrow.",
		requirements = {
			{
				counter = "mastered_Arrow",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(243, 79, 147)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 39, 69))
		}),
		disabled = false
	},
	mastered_blood_manipulation = {
		displayName = "Blood Manipulation Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Blood Manipulation.",
		requirements = {
			{
				counter = "mastered_Blood Manipulation",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(125, 15, 32)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(125, 15, 32)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(205, 35, 52)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(250, 200, 202)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 200, 202))
		}),
		disabled = false
	},
	mastered_cryokinesis = {
		displayName = "Cryokinesis Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Cryokinesis.",
		requirements = {
			{
				counter = "mastered_Cryokinesis",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 150, 205)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(60, 150, 205)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 225, 248)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(246, 253, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(246, 253, 255))
		}),
		disabled = false
	},
	mastered_dream = {
		displayName = "Dream Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Dream.",
		requirements = {
			{
				counter = "mastered_Dream",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(165, 40, 130)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(165, 40, 130)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 115, 180)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(226, 240, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(226, 240, 255))
		}),
		disabled = false
	},
	mastered_obi_manipulation = {
		displayName = "Obi Manipulation Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Obi Manipulation.",
		requirements = {
			{
				counter = "mastered_Obi Manipulation",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 85, 150)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(235, 85, 150)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 160, 205)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 235, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 245))
		}),
		disabled = false
	},
	mastered_pyrokenesis = {
		displayName = "Pyrokenesis Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Pyrokenesis.",
		requirements = {
			{
				counter = "mastered_Pyrokenesis",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 23, 120)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(142, 44, 155)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 61, 230)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(231, 146, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(231, 184, 255))
		}),
		disabled = false
	},
	mastered_reaper = {
		displayName = "Reaper Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Reaper.",
		requirements = {
			{
				counter = "mastered_Reaper",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 101, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(159, 176, 255))
		}),
		disabled = false
	},
	mastered_shockwave = {
		displayName = "Shockwave Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Shockwave.",
		requirements = {
			{
				counter = "mastered_Shockwave",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 120, 255)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(40, 120, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 210, 255)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(240, 250, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 250, 255))
		}),
		disabled = false
	},
	mastered_tamari = {
		displayName = "Tamari Perfected",
		category = "Powers",
		rarity = "Epic",
		description = "Reach max mastery with Tamari.",
		requirements = {
			{
				counter = "mastered_Tamari",
				threshold = 1
			}
		},
		buffs = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.02,
				isRatio = true
			}
		},
		collection = {
			{
				stat = "Evil Art Damage Factor",
				amount = 0.005,
				isRatio = true
			}
		},
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(205, 80, 170)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(205, 80, 170)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 150, 210)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 235, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 245))
		}),
		disabled = false
	},
	son_of_ilio = {
		displayName = "Son of Ilio",
		category = "Legacy",
		rarity = "Mythic",
		description = "For the ones who waited on a sun that never rose.",
		requirements = {},
		vanityOnly = true,
		hidden = true,
		disabled = false
	},
	developer = {
		displayName = "Developer",
		category = "Staff",
		rarity = "Impossible",
		description = "Given to the game's developers.",
		requirements = {},
		vanityOnly = true,
		hidden = true,
		disabled = false
	}
}