local Bait = {
	["Carrot Sticks"] = {
		Icon = "rbxassetid://122733918047368",
		Lure = 0,
		PreferredLuck = 500,
		Luck = 0,
		Resilience = 0,
		Rarity = "Unusual",
		FixedChanceFish = {
			Pufferfish = 90
		}
	},
	["Crustacean Mix"] = {
		Icon = "rbxassetid://80405914681436",
		Lure = 15,
		PreferredLuck = 90,
		Luck = 65,
		Resilience = 5,
		Rarity = "Rare"
	},
	["Luminous Flakes"] = {
		Icon = "rbxassetid://98468471425116",
		Lure = 40,
		Power = 10,
		PreferredLuck = 135,
		Luck = 60,
		Resilience = -3,
		Rarity = "Mythical",
		ProgressSpeed = 5
	},
	["Bio-Infused Coral"] = {
		Icon = "rbxassetid://127029581351589",
		Lure = 50,
		PreferredLuck = 70,
		Power = 10,
		Luck = -15,
		Resilience = 10,
		Rarity = "Legendary",
		Mutation = "Bioluminescent",
		MutationChance = { 1, 100, 10 },
		ProgressSpeed = 10
	},
	["Phosphor Jelly"] = {
		Icon = "rbxassetid://132649742159182",
		Lure = -10,
		Power = 5,
		PreferredLuck = 295,
		Luck = 210,
		Resilience = -20,
		Rarity = "Exotic",
		ProgressSpeed = -10
	},
	["Trench Grubs"] = {
		Icon = "rbxassetid://122667075578974",
		Lure = 10,
		Power = 5,
		PreferredLuck = 50,
		Luck = 10,
		Resilience = 5,
		Rarity = "Uncommon",
		Mutation = "Entrenched",
		MutationChance = { 1, 100, 10 }
	},
	["Chitin Pellets"] = {
		Icon = "rbxassetid://124946044528420",
		Lure = 5,
		Power = 3,
		PreferredLuck = 78,
		Luck = 35,
		Resilience = 35,
		Rarity = "Common"
	},
	["Cacti Pulp"] = {
		Icon = "rbxassetid://75414727192055",
		Lure = 60,
		PreferredLuck = 95,
		Luck = 110,
		Resilience = -5,
		Rarity = "Legendary"
	},
	["Tropical Fruit Mix"] = {
		Icon = "rbxassetid://95907454062849",
		Lure = 50,
		PreferredLuck = 85,
		Luck = 50,
		Resilience = 15,
		Rarity = "Limited",
		Limited = true,
		ProgressSpeed = 5
	},
	["Icy Fisch’n Dots"] = {
		Icon = "rbxassetid://85274002745331",
		Lure = 10,
		PreferredLuck = 75,
		Luck = -5,
		Resilience = 50,
		Rarity = "Limited",
		Limited = true
	},
	["Cotton Candy Pieces"] = {
		Icon = "rbxassetid://82717532653131",
		Lure = 100,
		PreferredLuck = 55,
		Luck = 10,
		Resilience = -5,
		Rarity = "Limited",
		Limited = true
	},
	["Coral Pearl"] = {
		Icon = "rbxassetid://129790636535583",
		Lure = 45,
		PreferredLuck = 55,
		Luck = 190,
		Resilience = 20,
		Rarity = "Limited",
		Limited = true,
		ProgressSpeed = 10
	},
	Ragebait = {
		Icon = "rbxassetid://100946517093597",
		Lure = -2000,
		PreferredLuck = 1,
		Luck = 1500,
		Resilience = -5000,
		Rarity = "Special",
		XpMultiply = -5,
		ProgressSpeed = -50,
		ClientFishingPassives = {
			WyvernBehavior = {
				TriggerChance = 25,
				FollowTriggerInterval = 1,
				Duration = 3,
				Cooldown = 5,
				WarningTime = 1,
				AttackWidth = 0.15,
				ControlReduce = 0.5,
				ProgressReduce = 0.3,
				ImpulseStrength = 10
			},
			["Silly Fun Happy Rod"] = {},
			["Merlin's Staff"] = {},
			["Pinion's Aria"] = {
				DROP_HEIGHT = 30,
				DROP_RANGE = 0.3,
				DROP_TIME = 1,
				DROP_TIME_REDUCE = 0.975,
				MIN_DROP_TIME = 0.5,
				DROP_INTERVAL = 0.5,
				DROP_INTERVAL_REDUCE = 0.925,
				MIN_DROP_INTERVAL = 1,
				SUCCESS_CONTROL_INCREASE = 0.025,
				SUCCESS_PROGRESS_BOOST = 3,
				SUCCESS_PROGRESS_SPEED_INCREASE = 0.05,
				SUCCESS_PROGRESS_LOSS_REDUCTION = -0.025,
				SUCCESS_FISH_SLOW_FACTOR = 0.1,
				FAIL_CONTROL_REDUCE = 0.15,
				FAIL_PROGRESS_LOSS = -0.1,
				FAIL_PROGRESS_SPEED_REDUCE = -0.1,
				FAIL_PROGRESS_LOSS_INCREASE = 0.1,
				FAIL_FISH_SLOW_FACTOR = -0.5,
				ACCEL_INCREASE = 0.15,
				MAX_ACCEL_BOOST = 2,
				RESONANCE_REQUIREMENT = 1000,
				RESONANCE_FOLLOW_SPEED = 25,
				RESONANCE_CONTROL_REDUCE_RATE = 0.075,
				RESONANCE_PROGRESS_SPEED_INCREASE = 0.01,
				EXTERNAL_CONTROL_DEBUFF = 0.5,
				OVERRIDE_NOTE_IMG = "rbxassetid://113973039010423"
			},
			Ragebait = {}
		},
		Limited = true
	},
	["Blackwater Leech"] = {
		Icon = "rbxassetid://71168643240494",
		Lure = 5,
		PreferredLuck = 233,
		Luck = 35,
		Resilience = -5,
		Disturbance = 3,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Blackwater",
		MutationChance = { 1, 100, 10 },
		XpMultiply = 0.1
	},
	["Barnacle Cluster"] = {
		Icon = "rbxassetid://81318214933200",
		Lure = 45,
		PreferredLuck = 172,
		Luck = 125,
		Resilience = -25,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Barnacle",
		MutationChance = { 1, 100, 20 },
		ProgressSpeed = 15
	},
	["Shady Larva"] = {
		Icon = "rbxassetid://97890905817469",
		Lure = 20,
		PreferredLuck = 350,
		Luck = 200,
		Resilience = -20,
		Disturbance = 1,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Shady",
		MutationChance = { 1, 100, 25 }
	},
	Part = {
		Icon = "rbxassetid://72444096547318",
		Mutation = "Part",
		Lure = 0,
		PreferredLuck = 0,
		Luck = 0,
		Resilience = 0,
		Rarity = "Limited",
		Limited = true
	},
	Nectar = {
		Icon = "rbxassetid://100193856019570",
		Lure = 30,
		PreferredLuck = 500,
		Luck = -100,
		Resilience = 0,
		Rarity = "Unusual",
		Limited = true,
		FixedChanceFish = {
			Butterfly = 90
		}
	},
	["Marshmallow Chicks"] = {
		Icon = "rbxassetid://93498777781560",
		Lure = 35,
		PreferredLuck = 320,
		Luck = 190,
		Resilience = 5,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Marshmallow",
		MutationChance = { 1, 100, 50 },
		ProgressSpeed = 5
	},
	["Thorn Cluster"] = {
		Icon = "rbxassetid://138359899591573",
		Lure = 15,
		PreferredLuck = 350,
		Luck = 70,
		Resilience = 65,
		Rarity = "Limited",
		Limited = true,
		Disturbance = 2,
		ProgressSpeed = 5
	},
	["Obsidian-Bone"] = {
		Icon = "rbxassetid://71916542682416",
		Lure = -5,
		PreferredLuck = 250,
		Luck = 180,
		Resilience = 55,
		Rarity = "Exotic",
		Mutation = "Obsidian",
		Disturbance = 1,
		MutationChance = { 1, 100, 10 },
		ProgressSpeed = -2,
		Price = 7500
	},
	["Fischversation Hearts"] = {
		Icon = "rbxassetid://98497371916274",
		Mutation = "Candy",
		Lure = 20,
		PreferredLuck = 200,
		Luck = 150,
		Resilience = 15,
		Rarity = "Limited",
		Limited = true
	},
	["Berry Vine"] = {
		Icon = "rbxassetid://92266842130964",
		Lure = 10,
		PreferredLuck = 10,
		Luck = 20,
		Resilience = 0,
		Rarity = "Limited",
		Limited = true
	},
	["Bread Crumbs"] = {
		Icon = "rbxassetid://76166749574786",
		Lure = 8,
		PreferredLuck = 12,
		Luck = 12,
		Resilience = 8,
		Rarity = "Limited",
		Limited = true
	},
	["Noctic Larva"] = {
		Icon = "rbxassetid://132015546656044",
		Lure = 45,
		PreferredLuck = 300,
		Luck = 250,
		Resilience = 35,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Noctic",
		MutationChance = { 1, 100, 100 },
		ProgressSpeed = 15
	},
	["Corvid Algae"] = {
		Icon = "rbxassetid://130040854053932",
		Lure = 20,
		PreferredLuck = 350,
		Luck = 350,
		Resilience = 5,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Corvid",
		MutationChance = { 1, 100, 100 },
		ProgressSpeed = 5
	},
	["Small Pebbles"] = {
		Icon = "rbxassetid://138051124692532",
		Lure = 5,
		PreferredLuck = 10,
		Luck = 20,
		Resilience = 5,
		Rarity = "Limited",
		Limited = true
	},
	["Cookie Crumble"] = {
		Icon = "rbxassetid://98621322518786",
		Lure = 35,
		PreferredLuck = 320,
		Luck = 190,
		Resilience = 15,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Merry",
		MutationChance = { 1, 100, 10 }
	},
	["Fruitcake Flakes"] = {
		Icon = "rbxassetid://84117453444161",
		Lure = 15,
		PreferredLuck = 135,
		Luck = 180,
		Resilience = 50,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Merry",
		MutationChance = { 1, 100, 10 }
	},
	["Frostnova Bait"] = {
		Icon = "rbxassetid://124837407305551",
		Lure = 35,
		PreferredLuck = 120,
		Luck = 150,
		Resilience = 50,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Frostnova",
		MutationChance = { 1, 100, 30 },
		ProgressSpeed = 50
	},
	["Pumpkin Pieces"] = {
		Icon = "rbxassetid://114504690206576",
		Lure = 5,
		PreferredLuck = 120,
		Luck = 150,
		Resilience = 50,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Gravy",
		MutationChance = { 1, 100, 20 },
		ProgressSpeed = 10
	},
	["Cranberry Cluster"] = {
		Icon = "rbxassetid://122403049190756",
		Lure = 60,
		PreferredLuck = 70,
		Luck = 90,
		Resilience = -5,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Gravy",
		MutationChance = { 1, 100, 20 },
		ProgressSpeed = 25
	},
	["Gourd Bites"] = {
		Icon = "rbxassetid://103488070952855",
		Lure = 10,
		PreferredLuck = 100,
		Luck = 80,
		Resilience = 35,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Gravy",
		MutationChance = { 1, 100, 20 }
	},
	["Starlight Worm"] = {
		Icon = "rbxassetid://130760356284577",
		Lure = 30,
		PreferredLuck = 300,
		Luck = 100,
		Resilience = 15,
		Rarity = "Secret",
		Limited = true,
		Mutation = "Nova",
		MutationChance = { 1, 100, 30 },
		ProgressSpeed = 20
	},
	["Candy Corn"] = {
		Icon = "rbxassetid://113512853309050",
		Lure = 80,
		PreferredLuck = 150,
		Luck = 90,
		Resilience = -40,
		Rarity = "Limited",
		Limited = true
	},
	["Gummy Fish"] = {
		Icon = "rbxassetid://89838811379302",
		Lure = 30,
		PreferredLuck = 130,
		Luck = 85,
		Resilience = -5,
		Rarity = "Limited",
		Limited = true
	},
	Gobstopper = {
		Icon = "rbxassetid://71105831108185",
		Lure = -50,
		PreferredLuck = 300,
		Luck = 150,
		Resilience = 100,
		Rarity = "Limited",
		Limited = true
	},
	["Hallow-Pop"] = {
		Icon = "rbxassetid://92776826028846",
		Lure = 30,
		PreferredLuck = 155,
		Luck = 65,
		Resilience = 10,
		Rarity = "Limited",
		Limited = true
	},
	["Sour Gummy Worm"] = {
		Icon = "rbxassetid://107879301420393",
		Lure = 40,
		PreferredLuck = 195,
		Luck = 85,
		Resilience = -20,
		Rarity = "Limited",
		Limited = true
	},
	Taco = {
		Icon = "rbxassetid://87539476182048",
		Mutation = "Spicy",
		Lure = 100,
		PreferredLuck = 100,
		Luck = 100,
		Resilience = -20,
		Rarity = "Special",
		XpMultiply = 1,
		Limited = true
	},
	["Golden Coin"] = {
		Icon = "rbxassetid://117895646767362",
		Mutation = "Radiant",
		Lure = 0,
		PreferredLuck = 300,
		Luck = 300,
		Resilience = 0,
		Rarity = "Special",
		XpMultiply = 1,
		Limited = true
	},
	Singularity = {
		Icon = "rbxassetid://106266362085397",
		Mutation = "Surreal",
		Lure = -20,
		PreferredLuck = 0,
		Luck = 0,
		Resilience = 150,
		Rarity = "Special",
		XpMultiply = 1,
		Limited = true
	},
	UFO = {
		Icon = "rbxassetid://133811860015401",
		Mutation = "Alien",
		Lure = 77,
		PreferredLuck = 110,
		Luck = 177,
		Resilience = 70,
		Rarity = "Special",
		XpMultiply = 1,
		Limited = true
	},
	Boulder = {
		Icon = "rbxassetid://129878767779591",
		Mutation = "Stone",
		MutationChance = { 1, 100, 100 },
		Lure = -40,
		PreferredLuck = 10,
		Luck = -100,
		Resilience = 200,
		Disturbance = 3,
		Rarity = "Special",
		Limited = true,
		ProgressSpeed = -5
	},
	["Gurt Flakes"] = {
		Icon = "rbxassetid://115709205848104",
		Mutation = "Pink",
		MutationChance = { 1, 100, 50 },
		Lure = 50,
		PreferredLuck = 1000,
		Luck = 100,
		Resilience = 50,
		Disturbance = 5,
		Rarity = "Special",
		Limited = true,
		ProgressSpeed = 10
	},
	Ant = {
		Icon = "rbxassetid://71835820456161",
		Lure = -10,
		PreferredLuck = 90,
		Luck = 5,
		Resilience = -15,
		Rarity = "Trash",
		Limited = true,
		ProgressSpeed = 5
	},
	["Beetle Grub"] = {
		Icon = "rbxassetid://105174229397460",
		Lure = -5,
		PreferredLuck = 70,
		Luck = 15,
		Resilience = 5,
		Rarity = "Uncommon",
		Limited = true,
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 3,
				SlashDamage = 2.5,
				StunTime = 0.35,
				SourceType = "bait",
				SourceName = "Stag Beetle",
				SoundName = "stabbystab",
				IconName = "Default",
				IconColor = Color3.fromRGB(160, 82, 45),
				GradientColor = Color3.fromRGB(160, 82, 45)
			},
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 3,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "Stag Beetle",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(160, 82, 45),
				GradientColor = Color3.fromRGB(160, 82, 45)
			}
		}
	},
	Centipede = {
		Icon = "rbxassetid://105989049110593",
		Lure = 20,
		PreferredLuck = 200,
		Luck = 60,
		Resilience = -10,
		Rarity = "Legendary",
		Limited = true,
		XpMultiply = 1
	},
	Cricket = {
		Icon = "rbxassetid://138108366316913",
		Lure = 10,
		PreferredLuck = 90,
		Luck = 25,
		Resilience = 0,
		Rarity = "Unusual",
		Limited = true,
		XpMultiply = 0.5
	},
	Dragonfly = {
		Icon = "rbxassetid://117519458070322",
		Lure = 25,
		PreferredLuck = 160,
		Luck = 50,
		Resilience = -5,
		Rarity = "Exotic",
		Limited = true,
		ProgressSpeed = 20
	},
	Earthworm = {
		Icon = "rbxassetid://76933739253900",
		Lure = -15,
		PreferredLuck = 60,
		Luck = 10,
		Resilience = 20,
		Rarity = "Common",
		Limited = true,
		Mutation = "Dirty"
	},
	Glowworm = {
		Icon = "rbxassetid://86659602459947",
		Lure = 15,
		PreferredLuck = 300,
		Luck = 100,
		Resilience = 5,
		Rarity = "Secret",
		Limited = true,
		Mutation = "Glowy",
		ProgressSpeed = 50
	},
	Snail = {
		Icon = "rbxassetid://118347840774742",
		Lure = -20,
		PreferredLuck = 80,
		Luck = -30,
		Resilience = 30,
		Rarity = "Rare",
		Limited = true,
		Control = 0.1
	},
	["Stag Beetle"] = {
		Icon = "rbxassetid://107975714738894",
		Lure = 35,
		PreferredLuck = 120,
		Luck = 35,
		Resilience = -5,
		Piercing = 10,
		Rarity = "Mythical",
		Limited = true,
		ClientFishingPassives = {
			Generic_Slashes = {
				TriggerMode = "FishMove",
				SlashChance = 10,
				SlashDamage = 2.5,
				StunTime = 0.35,
				SourceType = "bait",
				SourceName = "Stag Beetle",
				SoundName = "stabbystab",
				IconName = "Default",
				IconColor = Color3.fromRGB(160, 82, 45),
				GradientColor = Color3.fromRGB(160, 82, 45)
			},
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 10,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "Stag Beetle",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(160, 82, 45),
				GradientColor = Color3.fromRGB(160, 82, 45)
			}
		}
	},
	Star = {
		Icon = "rbxassetid://85895036109272",
		Mutation = "Galaxy",
		Lure = 80,
		PreferredLuck = 120,
		Luck = 120,
		Resilience = -10,
		Rarity = "Special",
		XpMultiply = 1,
		Limited = true
	},
	["Tryhard Worm"] = {
		Icon = "rbxassetid://134690438417592",
		Lure = 45,
		PreferredLuck = 5000,
		Luck = 0,
		Resilience = 65,
		Rarity = "Special",
		Limited = true
	},
	Meteor = {
		Icon = "rbxassetid://78140806286048",
		Lure = 10,
		PreferredLuck = 55,
		Luck = 65,
		Resilience = 100,
		Rarity = "Limited",
		Limited = true
	},
	Umbrella = {
		Icon = "rbxassetid://71775608851867",
		Lure = 50,
		PreferredLuck = 125,
		Luck = 50,
		Resilience = 30,
		Rarity = "Limited",
		Limited = true
	},
	["Beach Ball"] = {
		Icon = "rbxassetid://71291086018125",
		Lure = 150,
		PreferredLuck = 5,
		Luck = 5,
		Resilience = 0,
		Rarity = "Limited",
		Limited = true
	},
	["Beached Pearl"] = {
		Icon = "rbxassetid://72150831526088",
		Lure = 95,
		PreferredLuck = 250,
		Luck = 300,
		Resilience = 30,
		Rarity = "Limited",
		Limited = true
	},
	Crawlurion = {
		Icon = "rbxassetid://84860326921778",
		Lure = 10,
		PreferredLuck = 25,
		Luck = 30,
		Resilience = 10,
		Rarity = "Limited",
		Limited = true
	},
	Moonhaze = {
		Icon = "rbxassetid://122138201465584",
		Lure = 60,
		PreferredLuck = 225,
		Luck = 230,
		Resilience = 5,
		Rarity = "Limited",
		Limited = true
	},
	Astrolure = {
		Icon = "rbxassetid://134629744900115",
		Mutation = "Galactic",
		Lure = 90,
		PreferredLuck = 175,
		Luck = 60,
		Resilience = 60,
		Rarity = "Limited",
		XpMultiply = 1,
		Limited = true
	},
	Nullbit = {
		Icon = "rbxassetid://80815966615997",
		Mutation = "Nullified",
		Lure = 60,
		PreferredLuck = 120,
		Luck = 120,
		Resilience = -20,
		Rarity = "Limited",
		XpMultiply = 1,
		Limited = true
	},
	Snare = {
		Icon = "rbxassetid://131502303758768",
		Lure = 80,
		PreferredLuck = 125,
		Luck = -10,
		Resilience = -20,
		Rarity = "Secret",
		XpMultiply = 1
	},
	["Golden Worm"] = {
		Icon = "rbxassetid://92588934474259",
		Lure = 20,
		PreferredLuck = 200,
		Luck = 100,
		Resilience = 45,
		Rarity = "Exotic"
	},
	["Glass Beetle"] = {
		Icon = "rbxassetid://108650710805383",
		Lure = 30,
		PreferredLuck = 125,
		Luck = -80,
		Resilience = 30,
		Rarity = "Rare"
	},
	["Neuro Slug"] = {
		Icon = "rbxassetid://98378589712685",
		Lure = -20,
		PreferredLuck = 90,
		Luck = 100,
		Resilience = 60,
		Rarity = "Legendary"
	},
	["Nightmare Larva"] = {
		Icon = "rbxassetid://139717203005579",
		Lure = 25,
		PreferredLuck = 120,
		Luck = 35,
		Resilience = 25,
		Rarity = "Mythical"
	},
	["Phantom Leech"] = {
		Icon = "rbxassetid://123505973177484",
		Lure = 10,
		PreferredLuck = 105,
		Luck = 30,
		Resilience = 25,
		Rarity = "Rare"
	},
	["Toxic Jelly Core"] = {
		Icon = "rbxassetid://103314073936320",
		Lure = -5,
		PreferredLuck = 180,
		Luck = 90,
		Resilience = 35,
		Rarity = "Legendary"
	},
	Lucky = {
		Icon = "rbxassetid://83124206397968",
		Mutation = "Blarney",
		MutationChance = { 1, 100, 50 },
		Lure = 20,
		PreferredLuck = 200,
		Luck = 150,
		Resilience = 15,
		Rarity = "Limited",
		Limited = true
	},
	["Clover Cluster"] = {
		Icon = "rbxassetid://78000509999396",
		Mutation = "Lucky Gold",
		MutationChance = { 1, 100, 50 },
		Lure = 25,
		PreferredLuck = 220,
		Luck = 170,
		Resilience = 5,
		Rarity = "Limited",
		Limited = true
	},
	["Chocolate Fish"] = {
		Icon = "rbxassetid://122149688355947",
		Mutation = "Chocolate",
		Lure = 20,
		PreferredLuck = 200,
		Luck = 150,
		Resilience = 15,
		Rarity = "Limited",
		Limited = true
	},
	Bagel = {
		Icon = "rbxassetid://108678002533415",
		Lure = 0,
		PreferredLuck = 75,
		Luck = 0,
		Resilience = 15,
		Rarity = "Common"
	},
	Garbage = {
		Icon = "rbxassetid://134913713768472",
		Lure = -5,
		PreferredLuck = 0,
		Luck = -500,
		Resilience = 50,
		Rarity = "Trash"
	},
	Worm = {
		Icon = "rbxassetid://133997443467885",
		Lure = 15,
		PreferredLuck = 75,
		Luck = 0,
		Resilience = 0,
		Rarity = "Common"
	},
	Insect = {
		Icon = "rbxassetid://82228384077490",
		Lure = 5,
		PreferredLuck = 75,
		Luck = 0,
		Resilience = 0,
		Rarity = "Common"
	},
	Maggot = {
		Icon = "rbxassetid://77502257509358",
		Lure = -10,
		PreferredLuck = 80,
		Luck = 35,
		Resilience = 0,
		Rarity = "Uncommon"
	},
	Squid = {
		Icon = "rbxassetid://132083884054870",
		Lure = -25,
		PreferredLuck = 105,
		Luck = 45,
		Resilience = 0,
		Rarity = "Unusual"
	},
	Seaweed = {
		Icon = "rbxassetid://78676762283786",
		Lure = 20,
		PreferredLuck = 95,
		Luck = 0,
		Resilience = 10,
		Rarity = "Unusual"
	},
	Coral = {
		Icon = "rbxassetid://88295442439044",
		Lure = 20,
		PreferredLuck = 100,
		Luck = 0,
		Resilience = 20,
		Rarity = "Unusual"
	},
	["Deep Coral"] = {
		Icon = "rbxassetid://71969712298871",
		Lure = 0,
		PreferredLuck = 150,
		Luck = -10,
		Resilience = 50,
		Rarity = "Legendary"
	},
	Flakes = {
		Icon = "rbxassetid://89483992302592",
		Lure = 10,
		PreferredLuck = 85,
		Luck = 0,
		Resilience = -3,
		Rarity = "Common"
	},
	Shrimp = {
		Icon = "rbxassetid://129458957024181",
		Lure = 0,
		PreferredLuck = 95,
		Luck = 25,
		Resilience = -5,
		Rarity = "Uncommon"
	},
	Krill = {
		Lure = 15,
		PreferredLuck = 90,
		Luck = 35,
		Resilience = -5,
		Rarity = "Uncommon",
		Icon = "rbxassetid://139178400427304",
		Price = 50
	},
	Magnet = {
		Icon = "rbxassetid://127635918006645",
		Lure = 0,
		PreferredLuck = 200,
		Luck = 0,
		Resilience = 0,
		Rarity = "Unusual"
	},
	["Truffle Worm"] = {
		Icon = "rbxassetid://93019675927218",
		Lure = -10,
		PreferredLuck = 300,
		Luck = 0,
		Resilience = 0,
		Rarity = "Legendary"
	},
	Minnow = {
		Icon = "rbxassetid://127324539778135",
		Lure = 0,
		PreferredLuck = 115,
		Luck = 0,
		Resilience = -10,
		Rarity = "Unusual"
	},
	Coal = {
		Icon = "rbxassetid://128813695014519",
		Lure = 0,
		PreferredLuck = 95,
		Luck = 0,
		Resilience = -10,
		Rarity = "Rare"
	},
	["Rapid Catcher"] = {
		Icon = "rbxassetid://123038194837270",
		Lure = 35,
		PreferredLuck = 0,
		Luck = 0,
		Resilience = -15,
		Rarity = "Rare"
	},
	["Instant Catcher"] = {
		Icon = "rbxassetid://105765233417193",
		Lure = 65,
		PreferredLuck = 0,
		Luck = -20,
		Resilience = -15,
		Rarity = "Legendary"
	},
	["Super Flakes"] = {
		Icon = "rbxassetid://105233590701549",
		Lure = 0,
		PreferredLuck = 200,
		Luck = 70,
		Resilience = -15,
		Rarity = "Rare"
	},
	["Night Shrimp"] = {
		Icon = "rbxassetid://93937013256967",
		Lure = 15,
		PreferredLuck = 200,
		Luck = 90,
		Resilience = 0,
		Rarity = "Legendary"
	},
	["Fish Head"] = {
		Icon = "rbxassetid://82318594895677",
		Lure = 10,
		PreferredLuck = 150,
		Luck = 0,
		Resilience = -10,
		Rarity = "Legendary"
	},
	["Weird Algae"] = {
		Icon = "rbxassetid://100508147066133",
		Lure = -35,
		PreferredLuck = 200,
		Luck = 200,
		Resilience = 0,
		Rarity = "Legendary"
	},
	["Shark Head"] = {
		Icon = "rbxassetid://134025031777629",
		Lure = -5,
		PreferredLuck = 225,
		Luck = 30,
		Resilience = 10,
		Rarity = "Mythical"
	},
	["Aurora Bait"] = {
		Icon = "rbxassetid://85141818620239",
		Lure = -5,
		PreferredLuck = 100,
		Luck = 30,
		Resilience = 10,
		Rarity = "Mythical",
		Limited = true,
		Mutation = "Aurora",
		MutationChance = { 1, 100, 30 }
	},
	["Peppermint Worm"] = {
		Icon = "rbxassetid://93911511219039",
		Lure = -5,
		PreferredLuck = 50,
		Luck = 30,
		Resilience = 20,
		Rarity = "Limited",
		Limited = true
	},
	["Holly Berry"] = {
		Icon = "rbxassetid://78831863135519",
		Lure = -5,
		PreferredLuck = 80,
		Luck = 30,
		Resilience = 10,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Jolly",
		MutationChance = { 1, 100, 20 }
	},
	["Hangman's Hook"] = {
		Icon = "rbxassetid://129988917083814",
		Lure = -5,
		PreferredLuck = 150,
		Luck = 35,
		Resilience = 20,
		ProgressSpeed = 45,
		Rarity = "Mythical"
	},
	["Kraken Tentacle"] = {
		Icon = "rbxassetid://81433219929632",
		Lure = 35,
		PreferredLuck = 100,
		Luck = 110,
		Resilience = 15,
		Rarity = "Exotic",
		WeightBoost = 5
	},
	["Golden Tentacle"] = {
		Icon = "rbxassetid://83405723534819",
		Lure = 50,
		PreferredLuck = 150,
		Luck = 140,
		Resilience = 20,
		Rarity = "Special",
		Limited = true,
		WeightBoost = 10,
		ProgressSpeed = 20
	},
	Lushrooms = {
		Lure = 10,
		PreferredLuck = 100,
		Luck = 20,
		Resilience = 10,
		Rarity = "Common",
		Icon = "rbxassetid://96329947106909"
	},
	["Ember Berries"] = {
		Lure = 5,
		PreferredLuck = 120,
		Luck = 45,
		Resilience = 15,
		Rarity = "Unusual",
		Icon = "rbxassetid://106591280919281"
	},
	["Crystal Bananas"] = {
		Lure = 0,
		PreferredLuck = 150,
		Luck = 90,
		Resilience = 25,
		Rarity = "Rare",
		Icon = "rbxassetid://132112236254457"
	},
	["Mist Worms"] = {
		Lure = 20,
		PreferredLuck = 100,
		Luck = 80,
		Resilience = 25,
		Rarity = "Legendary",
		Icon = "rbxassetid://75993334361705"
	},
	["Lagoon Leech"] = {
		Lure = 15,
		PreferredLuck = 75,
		Luck = -10,
		Resilience = 20,
		Rarity = "Rare",
		Icon = "rbxassetid://131228054836930"
	},
	["Sapphire Krill"] = {
		Lure = 5,
		PreferredLuck = 150,
		Luck = 125,
		Resilience = 40,
		Rarity = "Mythical",
		Icon = "rbxassetid://105153897307029"
	},
	["Gale Grub"] = {
		Lure = 30,
		PreferredLuck = 85,
		Luck = -10,
		Resilience = -5,
		Rarity = "Common",
		Icon = "rbxassetid://89278213759164"
	},
	["Luminous Larva"] = {
		Lure = 10,
		PreferredLuck = 200,
		Luck = 125,
		Resilience = 40,
		Rarity = "Exotic",
		Icon = "rbxassetid://98270395522373"
	},
	["Acidic Larva"] = {
		Lure = 20,
		PreferredLuck = 330,
		Luck = 15,
		Resilience = 25,
		Mutation = "Acidic",
		Rarity = "Limited",
		Limited = true,
		Icon = "rbxassetid://83391510643534"
	},
	["Stud Bait"] = {
		Icon = "rbxassetid://92827044886722",
		Lure = 50,
		PreferredLuck = 150,
		Luck = 40,
		Resilience = 20,
		Rarity = "Limited",
		Limited = true
	},
	["Colossal Ink Bait"] = {
		Icon = "rbxassetid://78817927104320",
		Lure = 5,
		PreferredLuck = 150,
		Luck = 150,
		Resilience = 40,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Colossal Ink",
		WeightBoost = 100
	},
	["Hourglass Bait"] = {
		Icon = "rbxassetid://136590369641722",
		Lure = 5,
		PreferredLuck = 150,
		Luck = 150,
		Resilience = 40,
		XpMultiply = 1,
		Rarity = "Limited",
		Limited = true,
		Mutation = "Neon",
		WeightBoost = 100
	},
	["Golden Shrimp Bait"] = {
		Icon = "rbxassetid://101398702799761",
		Lure = 15,
		PreferredLuck = 150,
		Luck = 150,
		Resilience = 10,
		Price = 50000,
		Rarity = "Secret",
		Mutation = "Golden",
		WeightBoost = 10
	},
	["Whale Bait"] = {
		Icon = "rbxassetid://76695597473114",
		Lure = -5,
		PreferredLuck = 180,
		Luck = 20,
		Resilience = 30,
		Price = 25000,
		Rarity = "Legendary"
	},
	Firefly = {
		Icon = "rbxassetid://122718564025965",
		Lure = 5,
		PreferredLuck = 80,
		Luck = 20,
		Resilience = 5,
		Rarity = "Common"
	},
	["Loopy Five Firefly"] = {
		Icon = "rbxassetid://97595101585575",
		Lure = 40,
		PreferredLuck = 120,
		Luck = 80,
		Resilience = 5,
		Rarity = "Legendary"
	},
	["Blue Ghost Firefly"] = {
		Icon = "rbxassetid://108255118580269",
		Lure = 35,
		PreferredLuck = 140,
		Luck = 110,
		Resilience = 8,
		Rarity = "Mythical"
	},
	["Gombak Bent-Winged Firefly"] = {
		Icon = "rbxassetid://126880350550913",
		Lure = 55,
		PreferredLuck = 180,
		Luck = 150,
		Resilience = 10,
		Rarity = "Secret"
	}
}

function Bait.Give(_, player, name, p2, flag: boolean?)
	local RunService = game:GetService("RunService")

	if not RunService:IsServer() then
		return false
	end

	local amount = (p2 == 0 or p2 == nil) and 1 or p2
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local v2, v3 = require(ReplicatedStorage.shared.modules:WaitForChild("character")).PS(player)

	if not v2 then
		return false
	end

	if Bait[name] or not v3 then
		local bait = v2:WaitForChild("Stats"):WaitForChild("bait")
		local child = bait:FindFirstChild("bait_" .. name)

		if child then
			child.Value += amount
		else
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = "bait_" .. name
			numberValue.Value = amount
			numberValue.Parent = bait
		end

		if not flag then
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			ReplicatedStorage2:WaitForChild("events"):WaitForChild("anno_bait"):FireClient(player, name, amount)
		end

		return true
	else
		warn((`Unknown bait "{name}" given to {player.Name}`))
		table.insert(v3.Data.NewFormat.FailedRewards, {
			Type = "Bait",
			Name = name,
			Amount = amount,
			Time = os.time()
		})
		return false
	end

	return false
end

return Bait