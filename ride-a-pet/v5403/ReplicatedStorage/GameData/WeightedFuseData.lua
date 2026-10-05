local v = {
	MODEL_VERSION = "weighted-fuse-legendary-v12",
	REQUIRED_INPUTS = 4,
	HYDRA_HARD_CAP = 0.05,
	TUNING_LIMITS = {
		inputQualityMin = 0,
		inputQualityMax = 100,
		outputMultiplierMin = 1e-6,
		outputMultiplierMax = 1000000,
		rarityMultiplierMin = 1e-6,
		rarityMultiplierMax = 1000000,
		weakestShareMin = 0,
		weakestShareMax = 1
	},
	RARITIES = {
		"Legendary",
		"Mythic",
		"Divine",
		"Ethereal"
	},
	PETS = {
		{
			name = "Horse",
			rarity = "Legendary",
			income = 350,
			speed = 101,
			jump = 108,
			id = "horse",
			quality = 10,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Wolf",
			rarity = "Legendary",
			income = 375,
			speed = 102,
			jump = 102,
			id = "wolf",
			quality = 12,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Shark",
			rarity = "Legendary",
			income = 400,
			speed = 103,
			jump = 114,
			id = "shark",
			quality = 14,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "llama",
			name = "Llama",
			rarity = "Legendary",
			quality = 16,
			income = 425,
			speed = 104,
			jump = 118,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Platypus",
			rarity = "Legendary",
			income = 450,
			speed = 105,
			jump = 114,
			id = "platypus",
			quality = 18,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Lion",
			rarity = "Legendary",
			income = 510,
			speed = 107,
			jump = 120,
			id = "lion",
			quality = 20,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "highland_cow",
			name = "Bison",
			rarity = "Legendary",
			quality = 22,
			income = 625,
			speed = 108,
			jump = 100,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Ostrich",
			rarity = "Legendary",
			income = 750,
			speed = 110,
			jump = 86,
			id = "ostrich",
			quality = 24,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "fennec",
			name = "Fennec",
			rarity = "Legendary",
			quality = 26,
			income = 900,
			speed = 115,
			jump = 130,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Fox",
			rarity = "Mythic",
			income = 1200,
			speed = 120,
			jump = 105,
			id = "fox",
			quality = 32,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Boar",
			rarity = "Mythic",
			income = 1800,
			speed = 122,
			jump = 105,
			id = "boar",
			quality = 35,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "okapi",
			name = "Okapi",
			rarity = "Mythic",
			quality = 37,
			income = 2000,
			speed = 123,
			jump = 110,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Giraffe",
			rarity = "Mythic",
			income = 2200,
			speed = 125,
			jump = 83,
			id = "giraffe",
			quality = 39,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "white_tiger",
			name = "White Tiger",
			rarity = "Mythic",
			quality = 41,
			income = 2800,
			speed = 128,
			jump = 130,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Cheetah",
			rarity = "Mythic",
			income = 3500,
			speed = 130,
			jump = 117,
			id = "cheetah",
			quality = 44,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "anaconda",
			name = "Anaconda",
			rarity = "Mythic",
			quality = 46,
			income = 4000,
			speed = 132,
			jump = 105,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Monkey",
			rarity = "Mythic",
			income = 4500,
			speed = 135,
			jump = 160,
			id = "monkey",
			quality = 48,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "black_stallion",
			name = "Black Stallion",
			rarity = "Mythic",
			quality = 50,
			income = 5400,
			speed = 140,
			jump = 150,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Unicorn",
			rarity = "Divine",
			income = 30000,
			speed = 150,
			jump = 135,
			movementSpeed = 140,
			id = "unicorn",
			quality = 56,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Flamingo",
			rarity = "Divine",
			income = 40000,
			speed = 155,
			jump = 145,
			id = "flamingo",
			quality = 59,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "scorpion",
			name = "Scorpion",
			rarity = "Divine",
			quality = 61,
			income = 45000,
			speed = 158,
			jump = 135,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "TRex",
			rarity = "Divine",
			income = 50000,
			speed = 160,
			jump = 100,
			movementSpeed = 150,
			id = "trex",
			quality = 63,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "grizzly",
			name = "Grizzly Bear",
			rarity = "Divine",
			quality = 65,
			income = 75000,
			speed = 170,
			jump = 125,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Phoenix",
			rarity = "Divine",
			income = 100000,
			speed = 180,
			jump = 146,
			movementSpeed = 170,
			id = "phoenix",
			quality = 68,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "jackalope",
			name = "Jackalope",
			rarity = "Divine",
			quality = 70,
			income = 125000,
			speed = 183,
			jump = 170,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Peacock",
			rarity = "Divine",
			income = 150000,
			speed = 185,
			jump = 120,
			id = "peacock",
			quality = 72,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "black_panther",
			name = "Black Panther",
			rarity = "Divine",
			quality = 74,
			income = 180000,
			speed = 190,
			jump = 155,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Cerberus",
			rarity = "Ethereal",
			income = 15000000,
			speed = 200,
			jump = 143,
			movementSpeed = 210,
			id = "cerberus",
			quality = 80,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "el_toro",
			name = "El Toro",
			rarity = "Ethereal",
			quality = 82,
			income = 20000000,
			speed = 212,
			jump = 145,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Komodo",
			rarity = "Ethereal",
			income = 25000000,
			speed = 215,
			jump = 150,
			movementSpeed = 225,
			id = "komodo",
			quality = 84,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "stone_golem",
			name = "Stone Golem",
			rarity = "Ethereal",
			quality = 86,
			income = 60000000,
			speed = 228,
			jump = 130,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Kitsune",
			rarity = "Ethereal",
			income = 90000000,
			speed = 240,
			jump = 170,
			id = "kitsune",
			quality = 90,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "fenrir",
			name = "Fenrir",
			rarity = "Ethereal",
			quality = 93,
			income = 120000000,
			speed = 238,
			jump = 165,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			id = "hellhound",
			name = "Hellhound",
			rarity = "Ethereal",
			quality = 95,
			income = 140000000,
			speed = 245,
			jump = 160,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true
		},
		{
			name = "Dragon",
			rarity = "Ethereal",
			income = 150000000,
			speed = 210,
			jump = 150,
			id = "dragon",
			quality = 97,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			name = "Griffin",
			rarity = "Ethereal",
			income = 160000000,
			jump = 150,
			walkSpeed = 243,
			flySpeed = 213,
			id = "griffin",
			quality = 99,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		},
		{
			id = "hydra",
			name = "Hydra Dragon",
			rarity = "Ethereal",
			quality = 100,
			income = 165000000,
			jump = 175,
			isFuse = true,
			statsSource = "proposal",
			inputAllowed = true,
			walkSpeed = 250,
			flySpeed = 216
		},
		{
			name = "Volkaris",
			rarity = "Secret",
			income = 170000000,
			speed = 230,
			jump = 150,
			id = "volkaris",
			quality = 100,
			isFuse = false,
			statsSource = "attached-place",
			inputAllowed = true
		}
	},
	ANCHORS = {
		{
			score = 10,
			weights = {
				llama = 65,
				highland_cow = 34,
				fennec = 1
			},
			orderedIds = { "llama", "highland_cow", "fennec" }
		},
		{
			score = 14,
			weights = {
				llama = 56,
				highland_cow = 42,
				fennec = 2
			},
			orderedIds = { "llama", "highland_cow", "fennec" }
		},
		{
			score = 18,
			weights = {
				llama = 44,
				highland_cow = 52,
				fennec = 4
			},
			orderedIds = { "llama", "highland_cow", "fennec" }
		},
		{
			score = 20,
			weights = {
				llama = 34,
				highland_cow = 60,
				fennec = 6
			},
			orderedIds = { "llama", "highland_cow", "fennec" }
		},
		{
			score = 22,
			weights = {
				llama = 24,
				highland_cow = 69,
				fennec = 7
			},
			orderedIds = { "llama", "highland_cow", "fennec" }
		},
		{
			score = 24,
			weights = {
				llama = 15,
				highland_cow = 75,
				fennec = 8,
				okapi = 2
			},
			orderedIds = {
				"llama",
				"highland_cow",
				"fennec",
				"okapi"
			}
		},
		{
			score = 26,
			weights = {
				llama = 6,
				highland_cow = 82.5,
				fennec = 9,
				okapi = 2.5
			},
			orderedIds = {
				"llama",
				"highland_cow",
				"fennec",
				"okapi"
			}
		},
		{
			score = 27,
			weights = {
				highland_cow = 86,
				fennec = 11,
				okapi = 3
			},
			orderedIds = { "highland_cow", "fennec", "okapi" }
		},
		{
			score = 29,
			weights = {
				fennec = 9,
				okapi = 89,
				white_tiger = 2
			},
			orderedIds = { "fennec", "okapi", "white_tiger" }
		},
		{
			score = 30,
			weights = {
				fennec = 4,
				okapi = 84,
				white_tiger = 10,
				anaconda = 2
			},
			orderedIds = {
				"fennec",
				"okapi",
				"white_tiger",
				"anaconda"
			}
		},
		{
			score = 31,
			weights = {
				okapi = 71,
				white_tiger = 26,
				anaconda = 3
			},
			orderedIds = { "okapi", "white_tiger", "anaconda" }
		},
		{
			score = 32,
			weights = {
				okapi = 65,
				white_tiger = 25,
				anaconda = 8,
				black_stallion = 2
			},
			orderedIds = {
				"okapi",
				"white_tiger",
				"anaconda",
				"black_stallion"
			}
		},
		{
			score = 35,
			weights = {
				okapi = 50,
				white_tiger = 33.5,
				anaconda = 14,
				black_stallion = 2.5
			},
			orderedIds = {
				"okapi",
				"white_tiger",
				"anaconda",
				"black_stallion"
			}
		},
		{
			score = 38,
			weights = {
				okapi = 30,
				white_tiger = 44,
				anaconda = 23,
				black_stallion = 3
			},
			orderedIds = {
				"okapi",
				"white_tiger",
				"anaconda",
				"black_stallion"
			}
		},
		{
			score = 40,
			weights = {
				white_tiger = 57,
				anaconda = 40,
				black_stallion = 3
			},
			orderedIds = { "white_tiger", "anaconda", "black_stallion" }
		},
		{
			score = 41,
			weights = {
				white_tiger = 52,
				anaconda = 43,
				black_stallion = 4,
				scorpion = 1
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 42,
			weights = {
				white_tiger = 47,
				anaconda = 46,
				black_stallion = 5.7,
				scorpion = 1.3
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 44,
			weights = {
				white_tiger = 35,
				anaconda = 56,
				black_stallion = 7,
				scorpion = 2
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 46,
			weights = {
				white_tiger = 22,
				anaconda = 67.5,
				black_stallion = 8,
				scorpion = 2.5
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 48,
			weights = {
				white_tiger = 10,
				anaconda = 79,
				black_stallion = 8,
				scorpion = 3
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 50,
			weights = {
				white_tiger = 3,
				anaconda = 85,
				black_stallion = 9,
				scorpion = 3
			},
			orderedIds = {
				"white_tiger",
				"anaconda",
				"black_stallion",
				"scorpion"
			}
		},
		{
			score = 51,
			weights = {
				anaconda = 86,
				black_stallion = 11,
				scorpion = 3
			},
			orderedIds = { "anaconda", "black_stallion", "scorpion" }
		},
		{
			score = 52,
			weights = {
				anaconda = 42,
				black_stallion = 11,
				scorpion = 45.5,
				grizzly = 1.5
			},
			orderedIds = {
				"anaconda",
				"black_stallion",
				"scorpion",
				"grizzly"
			}
		},
		{
			score = 53,
			weights = {
				black_stallion = 9,
				scorpion = 89,
				grizzly = 2
			},
			orderedIds = { "black_stallion", "scorpion", "grizzly" }
		},
		{
			score = 54,
			weights = {
				black_stallion = 4,
				scorpion = 84,
				grizzly = 10,
				jackalope = 2
			},
			orderedIds = {
				"black_stallion",
				"scorpion",
				"grizzly",
				"jackalope"
			}
		},
		{
			score = 55,
			weights = {
				scorpion = 71,
				grizzly = 26,
				jackalope = 3
			},
			orderedIds = { "scorpion", "grizzly", "jackalope" }
		},
		{
			score = 56,
			weights = {
				scorpion = 65,
				grizzly = 25,
				jackalope = 8,
				black_panther = 2
			},
			orderedIds = {
				"scorpion",
				"grizzly",
				"jackalope",
				"black_panther"
			}
		},
		{
			score = 59,
			weights = {
				scorpion = 50,
				grizzly = 33.5,
				jackalope = 14,
				black_panther = 2.5
			},
			orderedIds = {
				"scorpion",
				"grizzly",
				"jackalope",
				"black_panther"
			}
		},
		{
			score = 62,
			weights = {
				scorpion = 30,
				grizzly = 44,
				jackalope = 23,
				black_panther = 3
			},
			orderedIds = {
				"scorpion",
				"grizzly",
				"jackalope",
				"black_panther"
			}
		},
		{
			score = 66,
			weights = {
				grizzly = 55,
				jackalope = 42,
				black_panther = 3
			},
			orderedIds = { "grizzly", "jackalope", "black_panther" }
		},
		{
			score = 68,
			weights = {
				grizzly = 48,
				jackalope = 47,
				black_panther = 4,
				el_toro = 1
			},
			orderedIds = {
				"grizzly",
				"jackalope",
				"black_panther",
				"el_toro"
			}
		},
		{
			score = 70,
			weights = {
				grizzly = 36,
				jackalope = 56,
				black_panther = 6.5,
				el_toro = 1.5
			},
			orderedIds = {
				"grizzly",
				"jackalope",
				"black_panther",
				"el_toro"
			}
		},
		{
			score = 72,
			weights = {
				grizzly = 20,
				jackalope = 70,
				black_panther = 8,
				el_toro = 2
			},
			orderedIds = {
				"grizzly",
				"jackalope",
				"black_panther",
				"el_toro"
			}
		},
		{
			score = 74,
			weights = {
				grizzly = 5,
				jackalope = 83.5,
				black_panther = 9,
				el_toro = 2.5
			},
			orderedIds = {
				"grizzly",
				"jackalope",
				"black_panther",
				"el_toro"
			}
		},
		{
			score = 74.5,
			weights = {
				jackalope = 86.4,
				black_panther = 11,
				el_toro = 2.6
			},
			orderedIds = { "jackalope", "black_panther", "el_toro" }
		},
		{
			score = 76,
			weights = {
				jackalope = 42,
				black_panther = 11,
				el_toro = 45.5,
				stone_golem = 1.5
			},
			orderedIds = {
				"jackalope",
				"black_panther",
				"el_toro",
				"stone_golem"
			}
		},
		{
			score = 77,
			weights = {
				black_panther = 9,
				el_toro = 89.25,
				stone_golem = 1.75
			},
			orderedIds = { "black_panther", "el_toro", "stone_golem" }
		},
		{
			score = 78,
			weights = {
				black_panther = 4,
				el_toro = 89.5,
				stone_golem = 6.25,
				fenrir = 0.25
			},
			orderedIds = {
				"black_panther",
				"el_toro",
				"stone_golem",
				"fenrir"
			}
		},
		{
			score = 79,
			weights = {
				el_toro = 90,
				stone_golem = 9.4,
				fenrir = 0.6
			},
			orderedIds = { "el_toro", "stone_golem", "fenrir" }
		},
		{
			score = 80,
			weights = {
				el_toro = 85.7,
				stone_golem = 12.56,
				fenrir = 1.5,
				hellhound = 0.24
			},
			orderedIds = {
				"el_toro",
				"stone_golem",
				"fenrir",
				"hellhound"
			}
		},
		{
			score = 82,
			weights = {
				el_toro = 61.475,
				stone_golem = 35.48,
				fenrir = 2.625,
				hellhound = 0.42
			},
			orderedIds = {
				"el_toro",
				"stone_golem",
				"fenrir",
				"hellhound"
			}
		},
		{
			score = 84,
			weights = {
				el_toro = 34.25,
				stone_golem = 61.4,
				fenrir = 3.75,
				hellhound = 0.6
			},
			orderedIds = {
				"el_toro",
				"stone_golem",
				"fenrir",
				"hellhound"
			}
		},
		{
			score = 86,
			weights = {
				el_toro = 8.2,
				stone_golem = 81.84,
				fenrir = 9,
				hellhound = 0.96
			},
			orderedIds = {
				"el_toro",
				"stone_golem",
				"fenrir",
				"hellhound"
			}
		},
		{
			score = 86.5,
			weights = {
				stone_golem = 87.505,
				fenrir = 11.175,
				hellhound = 1.32
			},
			orderedIds = { "stone_golem", "fenrir", "hellhound" }
		},
		{
			score = 87.5,
			weights = {
				stone_golem = 80.5525,
				fenrir = 17.625,
				hellhound = 1.76,
				hydra = 0.0625
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 90,
			weights = {
				stone_golem = 62.95,
				fenrir = 32.8,
				hellhound = 4,
				hydra = 0.25
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 93,
			weights = {
				stone_golem = 44.875,
				fenrir = 44.5,
				hellhound = 10,
				hydra = 0.625
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 95,
			weights = {
				stone_golem = 30,
				fenrir = 49,
				hellhound = 20,
				hydra = 1
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 97,
			weights = {
				stone_golem = 15,
				fenrir = 42,
				hellhound = 40,
				hydra = 3
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 99,
			weights = {
				stone_golem = 8,
				fenrir = 33,
				hellhound = 55,
				hydra = 4
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		},
		{
			score = 100,
			weights = {
				stone_golem = 3,
				fenrir = 27,
				hellhound = 65,
				hydra = 5
			},
			orderedIds = {
				"stone_golem",
				"fenrir",
				"hellhound",
				"hydra"
			}
		}
	},
	MIXED_RARITY_BRIDGES = {
		{
			rarity = "Legendary",
			petId = "fennec",
			startsAboveScore = 26,
			endsAtScore = 29,
			maximumPercent = 11,
			maximumAddedPercentagePoints = 2
		},
		{
			rarity = "Mythic",
			petId = "black_stallion",
			startsAboveScore = 50,
			endsAtScore = 53,
			maximumPercent = 11,
			maximumAddedPercentagePoints = 2
		},
		{
			rarity = "Divine",
			petId = "black_panther",
			startsAboveScore = 74,
			endsAtScore = 77,
			maximumPercent = 11,
			maximumAddedPercentagePoints = 2
		}
	},
	DEFAULT_CONFIG = {
		inputWeights = {
			horse = 10,
			wolf = 12,
			shark = 14,
			llama = 16,
			platypus = 18,
			lion = 20,
			highland_cow = 22,
			ostrich = 24,
			fennec = 26,
			fox = 32,
			boar = 35,
			okapi = 37,
			giraffe = 39,
			white_tiger = 41,
			cheetah = 44,
			anaconda = 46,
			monkey = 48,
			black_stallion = 50,
			unicorn = 56,
			flamingo = 59,
			scorpion = 61,
			trex = 63,
			grizzly = 65,
			phoenix = 68,
			jackalope = 70,
			peacock = 72,
			black_panther = 74,
			cerberus = 80,
			el_toro = 82,
			komodo = 84,
			stone_golem = 86,
			kitsune = 90,
			fenrir = 93,
			hellhound = 95,
			dragon = 97,
			griffin = 99,
			hydra = 100,
			volkaris = 100
		},
		outputWeights = {
			llama = 1,
			highland_cow = 1,
			fennec = 1,
			okapi = 1,
			white_tiger = 1,
			anaconda = 1,
			black_stallion = 1,
			scorpion = 1,
			grizzly = 1,
			jackalope = 1,
			black_panther = 1,
			el_toro = 1,
			stone_golem = 1,
			fenrir = 1,
			hellhound = 1,
			hydra = 1
		},
		rarityWeights = {
			Legendary = 1,
			Mythic = 1,
			Divine = 1,
			Ethereal = 1
		},
		weakestShare = 0,
		hydraCap = 0.05
	}
}
v.RARITIES = {
	"Legendary",
	"Mythic",
	"Divine",
	"Ethereal",
	"Secret"
}

for _, v2 in ipairs(v.RARITIES) do
	v.DEFAULT_CONFIG.rarityWeights[v2] = 1
end

v.FUSE_PETS = {}

for _, v2 in ipairs(v.PETS) do
	if v2.isFuse then
		table.insert(v.FUSE_PETS, v2)
	end
end

v.DEFAULT_CONFIG.fuseLuckEnabled = false
v.DEFAULT_CONFIG.fuseLuckBoost = 0.15
local deepFreeze

deepFreeze = function(list)
	if type(list) == "table" and not table.isfrozen(list) then
		for _, v2 in pairs(list) do
			deepFreeze(v2)
		end

		table.freeze(list)
	end

	return list
end

return (deepFreeze(v))