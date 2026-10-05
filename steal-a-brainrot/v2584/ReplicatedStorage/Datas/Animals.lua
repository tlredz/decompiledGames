local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local datas = ReplicatedStorage:WaitForChild("Datas")
local LuckyBlocks = require(datas.LuckyBlocks)
require(datas.Rarities)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Updates = require(shared.Updates)
local Animals = {
	["Noobini Pizzanini"] = {
		DisplayName = "Noobini Pizzanini",
		Rarity = "Common",
		Price = 25,
		Generation = 1,
		RoadWeight = 100,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Lirilì Larilà"] = {
		DisplayName = "Lirilì Larilà",
		Rarity = "Common",
		Price = 250,
		Generation = 3,
		RoadWeight = 55,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Tim Cheese"] = {
		DisplayName = "Tim Cheese",
		Rarity = "Common",
		Price = 500,
		Generation = 5,
		RoadWeight = 50,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	Fluriflura = {
		DisplayName = "Fluriflura",
		Rarity = "Common",
		Price = 750,
		Generation = 7,
		RoadWeight = 45,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Svinina Bombardino"] = {
		DisplayName = "Svinina Bombardino",
		Rarity = "Common",
		Price = 1250,
		Generation = 10,
		RoadWeight = 40,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Talpa Di Fero"] = {
		DisplayName = "Talpa Di Fero",
		Rarity = "Common",
		Price = 1000,
		Generation = 9,
		RoadWeight = 43,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Pipi Kiwi"] = {
		DisplayName = "Pipi Kiwi",
		Rarity = "Common",
		Price = 1500,
		Generation = 13,
		RoadWeight = 37,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Pipi Corni"] = {
		DisplayName = "Pipi Corni",
		Rarity = "Common",
		Price = 1750,
		Generation = 14,
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = true
		}
	},
	["Raccooni Jandelini"] = {
		DisplayName = "Raccooni Jandelini",
		Rarity = "Common",
		Price = 1350,
		Generation = 12,
		ObtainedFrom = {
			Source = "Admin Abuse War",
			Obtainable = false
		}
	},
	Tartaragno = {
		DisplayName = "Tartaragno",
		Rarity = "Common",
		Price = 1500,
		Generation = 13,
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		}
	},
	["Noobini Santanini"] = {
		DisplayName = "Noobini Santanini",
		Rarity = "Common",
		Price = 1300,
		Generation = 11,
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		}
	},
	["Holy Arepa"] = {
		DisplayName = "Holy Arepa",
		Rarity = "Common",
		Price = 1750,
		Generation = 14,
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		}
	},
	["Trippi Troppi"] = {
		DisplayName = "Trippi Troppi",
		Rarity = "Rare",
		Price = 2000,
		Generation = 15,
		RoadWeight = 30,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Gangster Footera"] = {
		DisplayName = "Gangster Footera",
		Rarity = "Rare",
		Price = 4000,
		Generation = 30,
		RoadWeight = 25,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Boneca Ambalabu"] = {
		DisplayName = "Boneca Ambalabu",
		Rarity = "Rare",
		Price = 5000,
		Generation = 40,
		RoadWeight = 20,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Ta Ta Ta Ta Sahur"] = {
		DisplayName = "Ta Ta Ta Ta Sahur",
		Rarity = "Rare",
		Price = 7500,
		Generation = 55,
		RoadWeight = 17
	},
	["Tric Trac Baraboom"] = {
		DisplayName = "Tric Trac Baraboom",
		Rarity = "Rare",
		Price = 9000,
		Generation = 65,
		RoadWeight = 15,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bandito Bobritto"] = {
		DisplayName = "Bandito Bobritto",
		Rarity = "Rare",
		Price = 4500,
		Generation = 35,
		RoadWeight = 22.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Cacto Hipopotamo"] = {
		DisplayName = "Cacto Hipopotamo",
		Rarity = "Rare",
		Price = 6500,
		Generation = 50,
		RoadWeight = 18.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Pipi Avocado"] = {
		DisplayName = "Pipi Avocado",
		Rarity = "Rare",
		Price = 9500,
		Generation = 70,
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		}
	},
	["Pinealotto Fruttarino"] = {
		DisplayName = "Pinealotto Fruttarino",
		Rarity = "Rare",
		Price = 9750,
		Generation = 75,
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		}
	},
	["Cupcake Koala"] = {
		DisplayName = "Cupcake Koala",
		Rarity = "Rare",
		Price = 8000,
		Generation = 60,
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		}
	},
	["Frogo Elfo"] = {
		DisplayName = "Frogo Elfo",
		Rarity = "Rare",
		Price = 9250,
		Generation = 67,
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		}
	},
	["Pengolino Nuvoletto"] = {
		DisplayName = "Pengolino Nuvoletto",
		Rarity = "Rare",
		Price = 9600,
		Generation = 72,
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		}
	},
	["Cappuccino Assassino"] = {
		DisplayName = "Cappuccino Assassino",
		Rarity = "Epic",
		Price = 10000,
		Generation = 75,
		RoadWeight = 13,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Brr Brr Patapim"] = {
		DisplayName = "Brr Brr Patapim",
		Rarity = "Epic",
		Price = 15000,
		Generation = 100,
		RoadWeight = 10,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Trulimero Trulicina"] = {
		DisplayName = "Trulimero Trulicina",
		Rarity = "Epic",
		Price = 20000,
		Generation = 125,
		RoadWeight = 7,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bananita Dolphinita"] = {
		DisplayName = "Bananita Dolphinita",
		Rarity = "Epic",
		Price = 25000,
		Generation = 150,
		RoadWeight = 5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Brri Brri Bicus Dicus Bombicus"] = {
		DisplayName = "Brri Brri Bicus Dicus Bombicus",
		Rarity = "Epic",
		Price = 30000,
		Generation = 175,
		RoadWeight = 3.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bambini Crostini"] = {
		DisplayName = "Bambini Crostini",
		Rarity = "Epic",
		Price = 22500,
		Generation = 135,
		RoadWeight = 6,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Perochello Lemonchello"] = {
		DisplayName = "Perochello Lemonchello",
		Rarity = "Epic",
		Price = 27500,
		Generation = 160,
		RoadWeight = 4.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Avocadini Guffo"] = {
		DisplayName = "Avocadini Guffo",
		Rarity = "Epic",
		Price = 35000,
		Generation = 225,
		RoadWeight = 3,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Salamino Penguino"] = {
		DisplayName = "Salamino Penguino",
		Rarity = "Epic",
		Price = 40000,
		Generation = 250,
		RoadWeight = 2.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Ti Ti Ti Sahur"] = {
		DisplayName = "Ti Ti Ti Sahur",
		Rarity = "Epic",
		Price = 37500,
		Generation = 225,
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		}
	},
	["Penguino Cocosino"] = {
		DisplayName = "Penguino Cocosino",
		Rarity = "Epic",
		Price = 45000,
		Generation = 300,
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		}
	},
	["Avocadini Antilopini"] = {
		DisplayName = "Avocadini Antilopini",
		Rarity = "Epic",
		Price = 17500,
		Generation = 115,
		RoadWeight = 8.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Malame Amarele"] = {
		DisplayName = "Malame Amarele",
		Rarity = "Epic",
		Price = 23500,
		Generation = 140,
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		}
	},
	["Mangolini Parrocini"] = {
		DisplayName = "Mangolini Parrocini",
		Rarity = "Epic",
		Price = 38500,
		Generation = 235,
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		}
	},
	["Mummio Rappitto"] = {
		DisplayName = "Mummio Rappitto",
		Rarity = "Epic",
		Price = 47500,
		Generation = 325,
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		}
	},
	["Frogato Pirato"] = {
		DisplayName = "Frogato Pirato",
		Rarity = "Epic",
		Price = 39000,
		Generation = 240,
		ObtainedFrom = {
			Source = "Witch's Fuse",
			Obtainable = false
		}
	},
	["Wombo Rollo"] = {
		DisplayName = "Wombo Rollo",
		Rarity = "Epic",
		Price = 42500,
		Generation = 275,
		RoadWeight = 1.75,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Doi Doi Do"] = {
		DisplayName = "Doi Doi Do",
		Rarity = "Epic",
		Price = 41000,
		Generation = 260,
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		}
	},
	["Penguin Tree"] = {
		DisplayName = "Penguin Tree",
		Rarity = "Epic",
		Price = 42000,
		Generation = 270,
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		}
	},
	["Gato Celesto"] = {
		DisplayName = "Gato Celesto",
		Rarity = "Epic",
		Price = 40000,
		Generation = 250,
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		}
	},
	["Burbaloni Loliloli"] = {
		DisplayName = "Burbaloni Loliloli",
		Rarity = "Legendary",
		Price = 35000,
		Generation = 200,
		RoadWeight = 1,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Chimpanzini Bananini"] = {
		DisplayName = "Chimpanzini Bananini",
		Rarity = "Legendary",
		Price = 50000,
		Generation = 300,
		RoadWeight = 0.75,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Ballerina Cappuccina"] = {
		DisplayName = "Ballerina Cappuccina",
		Rarity = "Legendary",
		Price = 100000,
		Generation = 500,
		RoadWeight = 0.55,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Chef Crabracadabra"] = {
		DisplayName = "Chef Crabracadabra",
		Rarity = "Legendary",
		Price = 150000,
		Generation = 600,
		RoadWeight = 0.5,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Glorbo Fruttodrillo"] = {
		DisplayName = "Glorbo Fruttodrillo",
		Rarity = "Legendary",
		Price = 200000,
		Generation = 750,
		RoadWeight = 0.45,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Blueberrinni Octopusini"] = {
		DisplayName = "Blueberrinni Octopusini",
		Rarity = "Legendary",
		Price = 250000,
		Generation = 1000,
		RoadWeight = 0.4,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Lionel Cactuseli"] = {
		DisplayName = "Lionel Cactuseli",
		Rarity = "Legendary",
		Price = 175000,
		Generation = 650,
		RoadWeight = 0.47,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Pandaccini Bananini"] = {
		DisplayName = "Pandaccini Bananini",
		Rarity = "Legendary",
		Price = 300000,
		Generation = 1250,
		RoadWeight = 0.35,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Strawberrelli Flamingelli"] = {
		DisplayName = "Strawberrelli Flamingelli",
		Rarity = "Legendary",
		Price = 275000,
		Generation = 1150,
		RoadWeight = 0.37,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Cocosini Mama"] = {
		ObtainedFrom = {
			Source = "First Fuse Machine",
			Obtainable = false
		},
		DisplayName = "Cocosini Mama",
		Rarity = "Legendary",
		Price = 285000,
		Generation = 1200
	},
	["Pi Pi Watermelon"] = {
		DisplayName = "Pi Pi Watermelon",
		Rarity = "Legendary",
		Price = 315000,
		Generation = 1300,
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		}
	},
	["Sigma Boy"] = {
		DisplayName = "Sigma Boy",
		Rarity = "Legendary",
		Price = 325000,
		Generation = 1350,
		RoadWeight = 0.3,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Pipi Potato"] = {
		DisplayName = "Pipi Potato",
		Rarity = "Legendary",
		Price = 265000,
		Generation = 1100,
		RoadWeight = 0.385,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Quivioli Ameleonni"] = {
		DisplayName = "Quivioli Ameleonni",
		Rarity = "Legendary",
		Price = 225000,
		Generation = 900,
		RoadWeight = 0.425,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Caramello Filtrello"] = {
		DisplayName = "Caramello Filtrello",
		Rarity = "Legendary",
		Price = 255000,
		Generation = 1050,
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		}
	},
	["Sigma Girl"] = {
		DisplayName = "Sigma Girl",
		Rarity = "Legendary",
		Price = 340000,
		Generation = 1800,
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		}
	},
	Quackula = {
		DisplayName = "Quackula",
		Rarity = "Legendary",
		Price = 310000,
		Generation = 1275,
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		}
	},
	["Buho de Fuego"] = {
		DisplayName = "Buho de Fuego",
		Rarity = "Legendary",
		Price = 345000,
		Generation = 1850,
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		}
	},
	["Clickerino Crabo"] = {
		DisplayName = "Clickerino Crabo",
		Rarity = "Legendary",
		Price = 250000,
		Generation = 1000,
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		}
	},
	Puffaball = {
		DisplayName = "Puffaball",
		Rarity = "Legendary",
		Price = 330000,
		Generation = 1500,
		ObtainedFrom = {
			Source = "Fishing Event",
			Obtainable = false
		}
	},
	["Chocco Bunny"] = {
		DisplayName = "Chocco Bunny",
		Rarity = "Legendary",
		Price = 327500,
		Generation = 1400,
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		}
	},
	["Sealo Regalo"] = {
		DisplayName = "Sealo Regalo",
		Rarity = "Legendary",
		Price = 342500,
		Generation = 1825,
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		}
	},
	["Buho del Cielo"] = {
		DisplayName = "Buho del Cielo",
		Rarity = "Legendary",
		Price = 325000,
		Generation = 1350,
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		}
	},
	["Seraphino Gruyero"] = {
		DisplayName = "Seraphino Gruyero",
		Rarity = "Legendary",
		Price = 347500,
		Generation = 1900,
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		}
	},
	["Bandito Axolito"] = {
		DisplayName = "Bandito Axolito",
		Rarity = "Legendary",
		Price = 290000,
		Generation = 1225,
		ObtainedFrom = {
			Source = "Cyber Craft",
			Obtainable = false
		}
	},
	["Electro Quacko"] = {
		DisplayName = "Electro Quacko",
		Rarity = "Legendary",
		Price = 345000,
		Generation = 1850,
		ObtainedFrom = {
			Source = "Cyber Craft",
			Obtainable = false
		}
	},
	["Frigo Camelo"] = {
		DisplayName = "Frigo Camelo",
		Rarity = "Mythic",
		Price = 350000,
		Generation = 2000,
		RoadWeight = 0.2,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Orangutini Ananassini"] = {
		DisplayName = "Orangutini Ananassini",
		Rarity = "Mythic",
		Price = 400000,
		Generation = 2100,
		RoadWeight = 0.18,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bombardiro Crocodilo"] = {
		DisplayName = "Bombardiro Crocodilo",
		Rarity = "Mythic",
		Price = 500000,
		Generation = 2500,
		RoadWeight = 0.15,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bombombini Gusini"] = {
		DisplayName = "Bombombini Gusini",
		Rarity = "Mythic",
		Price = 1000000,
		Generation = 5000,
		RoadWeight = 0.14,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Rhino Toasterino"] = {
		DisplayName = "Rhino Toasterino",
		Rarity = "Mythic",
		Price = 450000,
		Generation = 2150,
		RoadWeight = 0.16
	},
	["Cavallo Virtuoso"] = {
		DisplayName = "Cavallo Virtuoso",
		Rarity = "Mythic",
		Price = 2500000,
		Generation = 7500,
		RoadWeight = 0.1,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Spioniro Golubiro"] = {
		DisplayName = "Spioniro Golubiro",
		Rarity = "Mythic",
		Price = 750000,
		Generation = 3500
	},
	["Zibra Zubra Zibralini"] = {
		DisplayName = "Zibra Zubra Zibralini",
		Rarity = "Mythic",
		Price = 1500000,
		Generation = 6000
	},
	["Tigrilini Watermelini"] = {
		DisplayName = "Tigrilini Watermelini",
		Rarity = "Mythic",
		Price = 1750000,
		Generation = 6500
	},
	["Gorillo Watermelondrillo"] = {
		DisplayName = "Gorillo Watermelondrillo",
		Rarity = "Mythic",
		Price = 3000000,
		Generation = 8000,
		RoadWeight = 0.08,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	Avocadorilla = {
		ObtainedFrom = {
			Source = "First Fuse Machine",
			Obtainable = false
		},
		DisplayName = "Avocadorilla",
		Rarity = "Mythic",
		Price = 2000000,
		Generation = 7000
	},
	["Ganganzelli Trulala"] = {
		ObtainedFrom = {
			Source = "First Fuse Machine",
			Obtainable = false
		},
		DisplayName = "Ganganzelli Trulala",
		Rarity = "Mythic",
		Price = 3750000,
		Generation = 9000,
		IgnoreIndexCounter = true
	},
	["Tob Tobi Tobi"] = {
		ObtainedFrom = {
			Source = "First Fuse Machine",
			Obtainable = false
		},
		DisplayName = "Tob Tobi Tobi",
		Rarity = "Mythic",
		Price = 3250000,
		Generation = 8500,
		IgnoreIndexCounter = true
	},
	["Te Te Te Sahur"] = {
		DisplayName = "Te Te Te Sahur",
		Rarity = "Mythic",
		Price = 4000000,
		Generation = 9500,
		RoadWeight = 0.07,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Tracoducotulu Delapeladustuz"] = {
		DisplayName = "Tracoducotulu Delapeladustuz",
		Rarity = "Mythic",
		Price = 4250000,
		Generation = 12000,
		RoadWeight = 0.06,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	Lerulerulerule = {
		DisplayName = "Lerulerulerule",
		Rarity = "Mythic",
		Price = 3500000,
		Generation = 8750,
		RoadWeight = 0.75,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	Carloo = {
		DisplayName = "Carloo",
		Rarity = "Mythic",
		Price = 4500000,
		Generation = 13500,
		IgnoreIndexCounter = true
	},
	["Carrotini Brainini"] = {
		DisplayName = "Carrotini Brainini",
		Rarity = "Mythic",
		Price = 4750000,
		Generation = 15000
	},
	["Brutto Gialutto"] = {
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		},
		DisplayName = "Brutto Gialutto",
		Rarity = "Mythic",
		Price = 600000,
		Generation = 3000
	},
	["Gorillo Subwoofero"] = {
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		},
		DisplayName = "Gorillo Subwoofero",
		Rarity = "Mythic",
		Price = 2750000,
		Generation = 7750
	},
	["Los Noobinis"] = {
		DisplayName = "Los Noobinis",
		Rarity = "Mythic",
		Price = 4350000,
		Generation = 12500,
		ObtainedFrom = {
			Source = "Cyber Craft",
			Obtainable = false
		}
	},
	["Rhino Helicopterino"] = {
		ObtainedFrom = {
			Source = "First Craft Machine",
			Obtainable = false
		},
		DisplayName = "Rhino Helicopterino",
		Rarity = "Mythic",
		Price = 4100000,
		Generation = 11000
	},
	["Toiletto Focaccino"] = {
		DisplayName = "Toiletto Focaccino",
		Rarity = "Mythic",
		Price = 4850000,
		Generation = 16000,
		RoadWeight = 0.05,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Cachorrito Melonito"] = {
		DisplayName = "Cachorrito Melonito",
		Rarity = "Mythic",
		Price = 4400000,
		Generation = 13000,
		RoadWeight = 0.055,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Bananito Bandito"] = {
		DisplayName = "Bananito Bandito",
		Rarity = "Mythic",
		Price = 4900000,
		Generation = 16500
	},
	["Magi Ribbitini"] = {
		ObtainedFrom = {
			Source = "Haunted Fuse",
			Obtainable = true
		},
		DisplayName = "Magi Ribbitini",
		Rarity = "Mythic",
		Price = 4200000,
		Generation = 11500
	},
	["Jacko Spaventosa"] = {
		ObtainedFrom = {
			Source = "Witch's Fuse",
			Obtainable = false
		},
		DisplayName = "Jacko Spaventosa",
		Rarity = "Mythic",
		Price = 4875000,
		Generation = 16250
	},
	["Stoppo Luminino"] = {
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		},
		DisplayName = "Stoppo Luminino",
		Rarity = "Mythic",
		Price = 3000000,
		Generation = 8000
	},
	["Centrucci Nuclucci"] = {
		ObtainedFrom = {
			Source = "Brainrot Trader",
			Obtainable = false
		},
		DisplayName = "Centrucci Nuclucci",
		Rarity = "Mythic",
		Price = 4800000,
		Generation = 15500
	},
	["Jingle Jingle Sahur"] = {
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		},
		DisplayName = "Jingle Jingle Sahur",
		Rarity = "Mythic",
		Price = 4300000,
		Generation = 12250
	},
	["Tree Tree Tree Sahur"] = {
		ObtainedFrom = {
			Source = "Santa's Fuse",
			Obtainable = false
		},
		DisplayName = "Tree Tree Tree Sahur",
		Rarity = "Mythic",
		Price = 4950000,
		Generation = 17000
	},
	["Spongini Quackini"] = {
		DisplayName = "Spongini Quackini",
		Rarity = "Mythic",
		Price = 4400000,
		Generation = 13000,
		ObtainedFrom = {
			Source = "OG Fuse",
			Obtainable = false
		}
	},
	["Fizzy Soda"] = {
		DisplayName = "Fizzy Soda",
		Rarity = "Mythic",
		Price = 4975000,
		Generation = 17250,
		ObtainedFrom = {
			Source = "OG Fuse",
			Obtainable = false
		}
	},
	Harpuccino = {
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		},
		DisplayName = "Harpuccino",
		Rarity = "Mythic",
		Price = 4650000,
		Generation = 14000
	},
	["Berenjello Angello"] = {
		ObtainedFrom = {
			Source = "Divine Fuse",
			Obtainable = false
		},
		DisplayName = "Berenjello Angello",
		Rarity = "Mythic",
		Price = 5500000,
		Generation = 18000
	},
	["Bee Loco"] = {
		ObtainedFrom = {
			Source = "Cyber Craft",
			Obtainable = false
		},
		DisplayName = "Bee Loco",
		Rarity = "Mythic",
		Price = 4500000,
		Generation = 13500
	},
	["Orbi Mochi"] = {
		ObtainedFrom = {
			Source = "Cyber Craft",
			Obtainable = false
		},
		DisplayName = "Orbi Mochi",
		Rarity = "Mythic",
		Price = 6000000,
		Generation = 18500
	},
	Cocoteddy = {
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		},
		DisplayName = "Cocoteddy",
		Rarity = "Mythic",
		Price = 4750000,
		Generation = 15000
	},
	Bucketoro = {
		ObtainedFrom = {
			Source = "Summer Fuse",
			Obtainable = false
		},
		DisplayName = "Bucketoro",
		Rarity = "Mythic",
		Price = 5750000,
		Generation = 18250
	},
	["Tic Tic Ribbit"] = {
		DisplayName = "Tic Tic Ribbit",
		ObtainedFrom = {
			Source = "RNG Machine",
			Obtainable = false
		},
		Rarity = "Mythic",
		Price = 6250000,
		Generation = 18750
	},
	["Chihuanini Taconini"] = {
		DisplayName = "Chihuanini Taconini",
		Rarity = "Brainrot God",
		Price = 8500000,
		Generation = 45000,
		IgnoreIndexCounter = true,
		SpawnVFX = "Taco",
		SpawnDelay = 3
	},
	["Cocofanto Elefanto"] = {
		DisplayName = "Cocofanto Elefanto",
		Rarity = "Brainrot God",
		Price = 6500000,
		Generation = 19000,
		RoadWeight = 0.05,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Tralalero Tralala"] = {
		DisplayName = "Tralalero Tralala",
		Rarity = "Brainrot God",
		Price = 10000000,
		Generation = 50000,
		RoadWeight = 0.01,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Odin Din Din Dun"] = {
		DisplayName = "Odin Din Din Dun",
		Rarity = "Brainrot God",
		Price = 15000000,
		Generation = 75000,
		RoadWeight = 0.007
	},
	["Girafa Celestre"] = {
		DisplayName = "Girafa Celestre",
		Rarity = "Brainrot God",
		Price = 7500000,
		Generation = 20000,
		RoadWeight = 0.03,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Trenostruzzo Turbo 3000"] = {
		DisplayName = "Trenostruzzo Turbo 3000",
		Rarity = "Brainrot God",
		Price = 25000000,
		Generation = 150000,
		RoadWeight = 0.005,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	Matteo = {
		DisplayName = "Matteo",
		Rarity = "Brainrot God",
		Price = 10000000,
		Generation = 50000,
		IgnoreIndexCounter = true,
		SpawnVFX = "Matteo",
		SpawnDelay = 3,
		ObtainedFrom = {
			Source = "Admin Abuse",
			Obtainable = false
		}
	},
	["Tigroligre Frutonni"] = {
		DisplayName = "Tigroligre Frutonni",
		Rarity = "Brainrot God",
		Price = 14000000,
		Generation = 60000
	},
	["Orcalero Orcala"] = {
		DisplayName = "Orcalero Orcala",
		Rarity = "Brainrot God",
		Price = 25000000,
		Generation = 100000
	},
	["Unclito Samito"] = {
		DisplayName = "Unclito Samito",
		Rarity = "Brainrot God",
		Price = 20000000,
		Generation = 75000,
		IgnoreIndexCounter = true,
		ObtainedFrom = {
			Source = "Admin Abuse",
			Obtainable = false
		}
	},
	["Gattatino Nyanino"] = {
		DisplayName = "Gattatino Nyanino",
		Rarity = "Brainrot God",
		Price = 7500000,
		Generation = 35000,
		IgnoreIndexCounter = true,
		SpawnVFX = "Gattatino Nyanino",
		SpawnDelay = 9,
		ObtainedFrom = {
			Source = "Admin Abuse",
			Obtainable = false
		}
	},
	["Espresso Signora"] = {
		DisplayName = "Espresso Signora",
		Rarity = "Brainrot God",
		Price = 25000000,
		Generation = 70000,
		IgnoreIndexCounter = true,
		ObtainedFrom = {
			Source = "Admin Abuse",
			Obtainable = false
		}
	},
	["Ballerino Lololo"] = {
		DisplayName = "Ballerino Lololo",
		Rarity = "Brainrot God",
		Price = 35000000,
		Generation = 200000,
		RoadWeight = 0.0001,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Piccione Macchina"] = {
		DisplayName = "Piccione Macchina",
		Rarity = "Brainrot God",
		Price = 40000000,
		Generation = 225000,
		RoadWeight = 0.0008,
		ObtainedFrom = {
			Source = "The Red Carpet",
			Obtainable = true
		}
	},
	["Los Crocodillitos"] = {
		ObtainedFrom = {
			Source = "Bombardiro Event",
			Obtainable = false
		},
		DisplayName = "Los Crocodillitos",
		Rarity = "Brainrot God",
		Price = 12500000,
		Generation = 55000
	}
}
Animals["Los Crocodillitos"] = {
	DisplayName = "Los Crocodillitos",
	Rarity = "Brainrot God",
	Price = 12500000,
	Generation = 55000,
	ObtainedFrom = {
		Source = "Bombardiro Event",
		Obtainable = false
	}
}
Animals["Tukanno Bananno"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Tukanno Bananno",
	Rarity = "Brainrot God",
	Price = 22500000,
	Generation = 100000,
	IgnoreIndexCounter = true
}
Animals["Trippi Troppi Troppa Trippa"] = {
	DisplayName = "Trippi Troppi Troppa Trippa",
	Rarity = "Brainrot God",
	Price = 30000000,
	Generation = 175000,
	RoadWeight = 0.0035,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Tungtungtungcitos"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Los Tungtungtungcitos",
	Rarity = "Brainrot God",
	Price = 37500000,
	Generation = 210000,
	IgnoreIndexCounter = true
}
Animals["Bulbito Bandito Traktorito"] = {
	DisplayName = "Bulbito Bandito Traktorito",
	Rarity = "Brainrot God",
	Price = 35000000,
	Generation = 205000,
	IgnoreIndexCounter = true
}
Animals["Los Orcalitos"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Los Orcalitos",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 235000,
	IgnoreIndexCounter = true
}
Animals["Tipi Topi Taco"] = {
	ObtainedFrom = {
		Source = "Taco Event",
		Obtainable = false
	},
	DisplayName = "Tipi Topi Taco",
	Rarity = "Brainrot God",
	Price = 20000000,
	Generation = 75000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Bombardini Tortinii"] = {
	ObtainedFrom = {
		Source = "Taco Event",
		Obtainable = false
	},
	DisplayName = "Bombardini Tortinii",
	Rarity = "Brainrot God",
	Price = 50000000,
	Generation = 225000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Tralalita Tralala"] = {
	DisplayName = "Tralalita Tralala",
	Rarity = "Brainrot God",
	Price = 20000000,
	Generation = 100000,
	RoadWeight = 0.006,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Urubini Flamenguini"] = {
	DisplayName = "Urubini Flamenguini",
	Rarity = "Brainrot God",
	Price = 30000000,
	Generation = 150000,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals.Alessio = {
	DisplayName = "Alessio",
	Rarity = "Brainrot God",
	Price = 17500000,
	Generation = 85000,
	IgnoreIndexCounter = true
}
Animals.Pakrahmatmamat = {
	DisplayName = "Pakrahmatmamat",
	Rarity = "Brainrot God",
	Price = 37500000,
	Generation = 215000,
	RoadWeight = 0.0009,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Bombinitos"] = {
	DisplayName = "Los Bombinitos",
	Rarity = "Brainrot God",
	Price = 42500000,
	Generation = 220000,
	IgnoreIndexCounter = true
}
Animals["Brr es Teh Patipum"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Brr es Teh Patipum",
	Rarity = "Brainrot God",
	Price = 40000000,
	Generation = 225000,
	IgnoreIndexCounter = true
}
Animals["Tartaruga Cisterna"] = {
	DisplayName = "Tartaruga Cisterna",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 250000,
	ObtainedFrom = {
		Source = "This is obtained from Sammy's Base",
		Obtainable = false,
		FullText = true
	}
}
Animals["Cacasito Satalito"] = {
	DisplayName = "Cacasito Satalito",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 240000,
	RoadWeight = 0.0006,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Mastodontico Telepiedone"] = {
	DisplayName = "Mastodontico Telepiedone",
	Rarity = "Brainrot God",
	Price = 47500000,
	Generation = 275000
}
Animals["Crabbo Limonetta"] = {
	DisplayName = "Crabbo Limonetta",
	Rarity = "Brainrot God",
	Price = 46000000,
	Generation = 235000,
	IgnoreIndexCounter = true
}
Animals["Gattito Tacoto"] = {
	DisplayName = "Gattito Tacoto",
	Rarity = "Brainrot God",
	Price = 32500000,
	Generation = 165000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Los Tipi Tacos"] = {
	DisplayName = "Los Tipi Tacos",
	Rarity = "Brainrot God",
	Price = 46000000,
	Generation = 260000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Las Capuchinas"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Las Capuchinas",
	Rarity = "Brainrot God",
	Price = 32500000,
	Generation = 185000
}
Animals["Orcalita Orcala"] = {
	DisplayName = "Orcalita Orcala",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 240000,
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	}
}
Animals["Piccionetta Macchina"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Piccionetta Macchina",
	Rarity = "Brainrot God",
	Price = 47000000,
	Generation = 270000
}
Animals["Anpali Babel"] = {
	ObtainedFrom = {
		Source = "This was obtained from the Craft Machine",
		Obtainable = false,
		FullText = true
	},
	DisplayName = "Anpali Babel",
	Rarity = "Brainrot God",
	Price = 48000000,
	Generation = 280000
}
Animals["Extinct Ballerina"] = {
	ObtainedFrom = {
		Source = "Extinct Event",
		Obtainable = false
	},
	DisplayName = "Extinct Ballerina",
	Rarity = "Brainrot God",
	Price = 23500000,
	Generation = 125000,
	SpawnVFX = "Extinct",
	SpawnDelay = 3
}
Animals["Tractoro Dinosauro"] = {
	DisplayName = "Tractoro Dinosauro",
	Rarity = "Brainrot God",
	Price = 42500000,
	Generation = 230000,
	RoadWeight = 0.00065,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Belula Beluga"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Belula Beluga",
	Rarity = "Brainrot God",
	Price = 60000000,
	Generation = 290000
}
Animals["Capi Taco"] = {
	ObtainedFrom = {
		Source = "Taco Event",
		Obtainable = false
	},
	DisplayName = "Capi Taco",
	Rarity = "Brainrot God",
	Price = 31000000,
	Generation = 155000,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Corn Corn Corn Sahur"] = {
	ObtainedFrom = {
		Source = "The Piñata",
		Obtainable = false
	},
	DisplayName = "Corn Corn Corn Sahur",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 250000
}
Animals["Brasilini Berimbini"] = {
	DisplayName = "Brasilini Berimbini",
	Rarity = "Brainrot God",
	Price = 55000000,
	Generation = 285000,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals.Squalanana = {
	DisplayName = "Squalanana",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 250000,
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	}
}
Animals["Pop Pop Sahur"] = {
	DisplayName = "Pop Pop Sahur",
	Rarity = "Brainrot God",
	Price = 65000000,
	Generation = 295000
}
Animals["Vampira Cappucina"] = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "Vampira Cappucina",
	Rarity = "Brainrot God",
	Price = 24500000,
	Generation = 125000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Witching Hour",
	SpawnDelay = 3
}
Animals["Jacko Jack Jack"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Jacko Jack Jack",
	Rarity = "Brainrot God",
	Price = 30000000,
	Generation = 150000
}
Animals.Snailenzo = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Snailenzo",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 250000
}
Animals["Tentacolo Tecnico"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Tentacolo Tecnico",
	Rarity = "Brainrot God",
	Price = 62500000,
	Generation = 292500
}
Animals.Pakrahmatmatina = {
	DisplayName = "Pakrahmatmatina",
	Rarity = "Brainrot God",
	Price = 40500000,
	Generation = 225000,
	ObtainedFrom = {
		Source = "Pole Game",
		Obtainable = false
	}
}
Animals["Bambu Bambu Sahur"] = {
	DisplayName = "Bambu Bambu Sahur",
	Rarity = "Brainrot God",
	Price = 47500000,
	Generation = 275000,
	ObtainedFrom = {
		Source = "Indonesia Event",
		Obtainable = false
	}
}
Animals["Krupuk Pagi Pagi"] = {
	DisplayName = "Krupuk Pagi Pagi",
	Rarity = "Brainrot God",
	Price = 60000000,
	Generation = 290000,
	ObtainedFrom = {
		Source = "Indonesia Event",
		Obtainable = false
	}
}
Animals["Mummy Ambalabu"] = {
	DisplayName = "Mummy Ambalabu",
	Rarity = "Brainrot God",
	Price = 45000000,
	Generation = 250000
}
Animals["Cappuccino Clownino"] = {
	DisplayName = "Cappuccino Clownino",
	Rarity = "Brainrot God",
	Price = 48500000,
	Generation = 285000
}
Animals["Skull Skull Skull"] = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "Skull Skull Skull",
	Rarity = "Brainrot God",
	Price = 60000000,
	Generation = 290000
}
Animals.Aquanaut = {
	DisplayName = "Aquanaut",
	Rarity = "Brainrot God",
	Price = 45500000,
	Generation = 245000,
	RoadWeight = 0.00055,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Frio Ninja"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Frio Ninja",
	Rarity = "Brainrot God",
	Price = 46500000,
	Generation = 265000
}
Animals["Money Money Man"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Money Money Man",
	Rarity = "Brainrot God",
	Price = 17500000,
	Generation = 65000
}
Animals["Noo La Polizia"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Noo La Polizia",
	Rarity = "Brainrot God",
	Price = 67000000,
	Generation = 280000
}
Animals["Los Chihuaninis"] = {
	DisplayName = "Los Chihuaninis",
	Rarity = "Brainrot God",
	Price = 32000000,
	Generation = 160000
}
Animals["Los Gattitos"] = {
	DisplayName = "Los Gattitos",
	Rarity = "Brainrot God",
	Price = 47500000,
	Generation = 275000
}
Animals["Granchiello Spiritell"] = {
	ObtainedFrom = {
		Source = "Fishing Event",
		Obtainable = false
	},
	DisplayName = "Granchiello Spiritell",
	Rarity = "Brainrot God",
	Price = 46000000,
	Generation = 260000
}
Animals["Ballerina Peppermintina"] = {
	DisplayName = "Ballerina Peppermintina",
	Rarity = "Brainrot God",
	Price = 37500000,
	Generation = 215000,
	SpawnVFX = "Winter Hour",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Advent/Winter Hour",
		Obtainable = false
	}
}
Animals["Ginger Globo"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Ginger Globo",
	Rarity = "Brainrot God",
	Price = 45750000,
	Generation = 257500
}
Animals["Ginger Cisterna"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Ginger Cisterna",
	Rarity = "Brainrot God",
	Price = 63500000,
	Generation = 293500
}
Animals["Yeti Claus"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Yeti Claus",
	Rarity = "Brainrot God",
	Price = 45750000,
	Generation = 257500
}
Animals["Buho de Noelo"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Buho de Noelo",
	Rarity = "Brainrot God",
	Price = 46750000,
	Generation = 267500
}
Animals.Chrismasmamat = {
	DisplayName = "Chrismasmamat",
	Rarity = "Brainrot God",
	Price = 47750000,
	Generation = 277500
}
Animals["Cocoa Assassino"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Cocoa Assassino",
	Rarity = "Brainrot God",
	Price = 61000000,
	Generation = 291000
}
Animals["Pandanini Frostini"] = {
	DisplayName = "Pandanini Frostini",
	Rarity = "Brainrot God",
	Price = 64000000,
	Generation = 294000
}
Animals["Tootini Shrimpini"] = {
	ObtainedFrom = {
		Source = "New Year's Event",
		Obtainable = false
	},
	DisplayName = "Tootini Shrimpini",
	Rarity = "Brainrot God",
	Price = 46000000,
	Generation = 260000,
	SpawnVFX = "New Years 2026",
	SpawnDelay = 3
}
Animals["Boba Panda"] = {
	DisplayName = "Boba Panda",
	Rarity = "Brainrot God",
	Price = 47000000,
	Generation = 270000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Dolphini Jetskini"] = {
	DisplayName = "Dolphini Jetskini",
	Rarity = "Brainrot God",
	Price = 64500000,
	Generation = 294500,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Luv Luv Luv"] = {
	DisplayName = "Luv Luv Luv",
	Rarity = "Brainrot God",
	Price = 48250000,
	Generation = 282500,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Karkerheart Luvkur"] = {
	DisplayName = "Karkerheart Luvkur",
	Rarity = "Brainrot God",
	Price = 67500000,
	Generation = 297500,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Divino Platypio"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Divino Platypio",
	Rarity = "Brainrot God",
	Price = 32000000,
	Generation = 160000
}
Animals["Astrolero Cervalero"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Astrolero Cervalero",
	Rarity = "Brainrot God",
	Price = 48000000,
	Generation = 280000
}
Animals["Dumborino Miracello"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Dumborino Miracello",
	Rarity = "Brainrot God",
	Price = 75000000,
	Generation = 315000
}
Animals.Patteo = {
	DisplayName = "Patteo",
	Rarity = "Brainrot God",
	Price = 57500000,
	Generation = 287500,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Clovkur Kurkur"] = {
	DisplayName = "Clovkur Kurkur",
	Rarity = "Brainrot God",
	Price = 70000000,
	Generation = 305000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Bunny Tralala"] = {
	DisplayName = "Bunny Tralala",
	Rarity = "Brainrot God",
	Price = 47000000,
	Generation = 270000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Eggdin Egg Egg Dun"] = {
	DisplayName = "Eggdin Egg Egg Dun",
	Rarity = "Brainrot God",
	Price = 72500000,
	Generation = 310000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals.Pineaplino = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Pineaplino",
	Rarity = "Brainrot God",
	Price = 35000000,
	Generation = 200000,
	IgnoreIndexCounter = true
}
Animals["Lazy Ducky"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Lazy Ducky",
	Rarity = "Brainrot God",
	Price = 45500000,
	Generation = 255000,
	IgnoreIndexCounter = true
}
Animals["Cola Cat"] = {
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	},
	DisplayName = "Cola Cat",
	Rarity = "Brainrot God",
	Price = 78500000,
	Generation = 323000
}
Animals["Tenini Ballini"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Tenini Ballini",
	Rarity = "Brainrot God",
	Price = 77000000,
	Generation = 320000
}
Animals.Appelini = {
	DisplayName = "Appelini",
	Rarity = "Brainrot God",
	Price = 69000000,
	Generation = 300000,
	RoadWeight = 0.0004,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Trenotubo Axolotrico 9000"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Trenotubo Axolotrico 9000",
	Rarity = "Brainrot God",
	Price = 45500000,
	Generation = 255000
}
Animals["Pretzo Robo"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Pretzo Robo",
	Rarity = "Brainrot God",
	Price = 77000000,
	Generation = 320000
}
Animals["Lumaca Malefica"] = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Lumaca Malefica",
	Rarity = "Brainrot God",
	Price = 46500000,
	Generation = 265000
}
Animals["Robo Grafito"] = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Robo Grafito",
	Rarity = "Brainrot God",
	Price = 76000000,
	Generation = 317500
}
Animals["Sundrilla Sundae"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Sundrilla Sundae",
	Rarity = "Brainrot God",
	Price = 31000000,
	Generation = 180000
}
Animals["Lemonita Splashita"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Lemonita Splashita",
	Rarity = "Brainrot God",
	Price = 48000000,
	Generation = 280000
}
Animals["Flippo Marino"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Flippo Marino",
	Rarity = "Brainrot God",
	Price = 75500000,
	Generation = 316000
}
Animals["Tortuginni Sandcastlini"] = {
	DisplayName = "Tortuginni Sandcastlini",
	Rarity = "Brainrot God",
	Price = 76000000,
	Generation = 317500,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals.Quackalena = {
	DisplayName = "Quackalena",
	Rarity = "Brainrot God",
	Price = 46500000,
	Generation = 265000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Beavo Potto"] = {
	DisplayName = "Beavo Potto",
	Rarity = "Brainrot God",
	Price = 75000000,
	Generation = 315000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals["Koala Parabala"] = {
	DisplayName = "Koala Parabala",
	Rarity = "Brainrot God",
	Price = 35000000,
	Generation = 200000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Hippo Jacuzzo"] = {
	DisplayName = "Hippo Jacuzzo",
	Rarity = "Brainrot God",
	Price = 48250000,
	Generation = 282500,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["La Vacca Saturno Saturnita"] = {
	DisplayName = "La Vacca Saturno Saturnita",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 325000,
	RoadWeight = 0.0003,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Tralaleritos"] = {
	DisplayName = "Los Tralaleritos",
	Rarity = "Secret",
	Price = 100000000,
	Generation = 500000,
	RoadWeight = 0.0001,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Graipuss Medussi"] = {
	DisplayName = "Graipuss Medussi",
	Rarity = "Secret",
	Price = 250000000,
	Generation = 1000000,
	RoadWeight = 1e-6,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["La Grande Combinasion"] = {
	DisplayName = "La Grande Combinasion",
	Rarity = "Secret",
	OverheadYOffsetModifier = 0.8,
	Price = 1000000000,
	Generation = 10000000,
	RoadWeight = 1e-8,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Sammyni Spyderini"] = {
	DisplayName = "Sammyni Spyderini",
	Rarity = "Secret",
	Price = 85000000,
	Generation = 330000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Los Spyderinis",
	SpawnDelay = 3.5,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Garama and Madundung"] = {
	DisplayName = "Garama and Madundung",
	Rarity = "Secret",
	Price = 10000000000,
	Generation = 50000000,
	RoadWeight = 1e-10,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Torrtuginni Dragonfrutini"] = {
	DisplayName = "Torrtuginni Dragonfrutini",
	Rarity = "Secret",
	Price = 125000000,
	Generation = 350000
}
Animals["Las Tralaleritas"] = {
	DisplayName = "Las Tralaleritas",
	Rarity = "Secret",
	Price = 150000000,
	Generation = 650000,
	RoadWeight = 0.00007,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Pot Hotspot"] = {
	DisplayName = "Pot Hotspot",
	Rarity = "Secret",
	Price = 600000000,
	Generation = 2500000
}
Animals["Nuclearo Dinossauro"] = {
	DisplayName = "Nuclearo Dinossauro",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 15000000,
	RoadWeight = 1e-10,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Las Vaquitas Saturnitas"] = {
	DisplayName = "Las Vaquitas Saturnitas",
	Rarity = "Secret",
	Price = 200000000,
	Generation = 750000,
	ObtainedFrom = {
		Source = "La Vacca Ritual",
		Obtainable = false
	}
}
Animals["Chicleteira Bicicleteira"] = {
	DisplayName = "Chicleteira Bicicleteira",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 3500000,
	RoadWeight = 1e-7,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Agarrini la Palini"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Agarrini la Palini",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 425000,
	IgnoreIndexCounter = true
}
Animals["Los Combinasionas"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Los Combinasionas",
	Rarity = "Secret",
	Price = 2000000000,
	Generation = 15000000,
	IgnoreIndexCounter = true
}
Animals["Karkerkar Kurkur"] = {
	DisplayName = "Karkerkar Kurkur",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 325000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Karkerkar Kurkur",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Dragon Cannelloni"] = {
	DisplayName = "Dragon Cannelloni",
	Rarity = "Secret",
	Price = 250000000000,
	Generation = 250000000,
	RoadWeight = 1e-15,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Hotspotsitos"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "Los Hotspotsitos",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 20000000,
	IgnoreIndexCounter = true
}
Animals["Esok Sekolah"] = {
	DisplayName = "Esok Sekolah",
	Rarity = "Secret",
	Price = 3500000000,
	Generation = 30000000,
	IgnoreIndexCounter = true
}
Animals["Nooo My Hotspot"] = {
	ObtainedFrom = {
		Source = "Taco Event",
		Obtainable = false
	},
	DisplayName = "Nooo My Hotspot",
	Rarity = "Secret",
	Price = 500000000,
	Generation = 1500000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Los Matteos"] = {
	DisplayName = "Los Matteos",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 325000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Matteo",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Matteo Ritual",
		Obtainable = false
	}
}
Animals["Job Job Job Sahur"] = {
	DisplayName = "Job Job Job Sahur",
	Rarity = "Secret",
	Price = 175000000,
	Generation = 700000,
	RoadWeight = 5e-6,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Dul Dul Dul"] = {
	DisplayName = "Dul Dul Dul",
	Rarity = "Secret",
	Price = 150000000,
	Generation = 375000,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Blackhole Goat"] = {
	DisplayName = "Blackhole Goat",
	Rarity = "Secret",
	Price = 75000000,
	Generation = 400000,
	IgnoreIndexCounter = true
}
Animals["Los Spyderinis"] = {
	DisplayName = "Los Spyderinis",
	Rarity = "Secret",
	Price = 125000000,
	Generation = 425000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Los Spyderinis",
	SpawnDelay = 3.5,
	ObtainedFrom = {
		Source = "Spyderini Ritual",
		Obtainable = false
	}
}
Animals["Ketupat Kepat"] = {
	DisplayName = "Ketupat Kepat",
	Rarity = "Secret",
	Price = 5000000000,
	Generation = 35000000,
	RoadWeight = 5e-11,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["La Supreme Combinasion"] = {
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	},
	DisplayName = "La Supreme Combinasion",
	Rarity = "Secret",
	Price = 200000000000,
	Generation = 200000000,
	IgnoreIndexCounter = true
}
Animals["Bisonte Giuppitere"] = {
	DisplayName = "Bisonte Giuppitere",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 325000,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "This is obtained from Sammy's Base",
		Obtainable = false,
		FullText = true
	}
}
Animals["Guerriro Digitale"] = {
	DisplayName = "Guerriro Digitale",
	Rarity = "Secret",
	Price = 120000000,
	Generation = 550000,
	IgnoreIndexCounter = true
}
Animals["Ketchuru and Musturu"] = {
	DisplayName = "Ketchuru and Musturu",
	Rarity = "Secret",
	Price = 7500000000,
	Generation = 42500000,
	RoadWeight = 2.5e-11,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Spaghetti Tualetti"] = {
	DisplayName = "Spaghetti Tualetti",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 60000000
}
Animals["Los Nooo My Hotspotsitos"] = {
	DisplayName = "Los Nooo My Hotspotsitos",
	Rarity = "Secret",
	Price = 1000000000,
	Generation = 5500000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Trenostruzzo Turbo 4000"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Trenostruzzo Turbo 4000",
	Rarity = "Secret",
	Price = 90000000,
	Generation = 335000
}
Animals["Fragola La La La"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Fragola La La La",
	Rarity = "Secret",
	Price = 4250000000,
	Generation = 32500000
}
Animals["La Sahur Combinasion"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "La Sahur Combinasion",
	Rarity = "Secret",
	Price = 550000000,
	Generation = 2000000
}
Animals["La Karkerkar Combinasion"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "La Karkerkar Combinasion",
	Rarity = "Secret",
	Price = 160000000,
	Generation = 600000,
	IgnoreIndexCounter = true
}
Animals.Tralaledon = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Tralaledon",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 27500000
}
Animals["Los Bros"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Los Bros",
	Rarity = "Secret",
	Price = 2600000000,
	Generation = 24000000
}
Animals["Los Chicleteiras"] = {
	DisplayName = "Los Chicleteiras",
	Rarity = "Secret",
	Price = 1200000000,
	Generation = 7000000,
	SpawnVFX = "Los Chicleteiras",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Chicleteira Ritual",
		Obtainable = false
	}
}
Animals.Chachechi = {
	DisplayName = "Chachechi",
	Rarity = "Secret",
	Price = 85000000,
	Generation = 400000,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Extinct Tralalero"] = {
	ObtainedFrom = {
		Source = "Extinct Event",
		Obtainable = false
	},
	DisplayName = "Extinct Tralalero",
	Rarity = "Secret",
	Price = 125000000,
	Generation = 450000,
	SpawnVFX = "Extinct",
	SpawnDelay = 3
}
Animals["Extinct Matteo"] = {
	ObtainedFrom = {
		Source = "Extinct Event",
		Obtainable = false
	},
	DisplayName = "Extinct Matteo",
	Rarity = "Secret",
	Price = 162500000,
	Generation = 625000,
	SpawnVFX = "Extinct",
	SpawnDelay = 3
}
Animals["67"] = {
	DisplayName = "67",
	Rarity = "Secret",
	Price = 1250000000,
	Generation = 7500000
}
Animals["Las Sis"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Las Sis",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 17500000
}
Animals["Celularcini Viciosini"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Celularcini Viciosini",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 22500000
}
Animals["La Extinct Grande"] = {
	ObtainedFrom = {
		Source = "Extinct Event",
		Obtainable = false
	},
	DisplayName = "La Extinct Grande",
	Rarity = "Secret",
	Price = 3250000000,
	Generation = 23500000,
	SpawnVFX = "Extinct",
	SpawnDelay = 3,
	IgnoreIndexCounter = true
}
Animals["Quesadilla Crocodila"] = {
	DisplayName = "Quesadilla Crocodila",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Tacorita Bicicleta"] = {
	ObtainedFrom = {
		Source = "Taco Event",
		Obtainable = false
	},
	DisplayName = "Tacorita Bicicleta",
	Rarity = "Secret",
	Price = 2250000000,
	Generation = 16500000,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["La Cucaracha"] = {
	DisplayName = "La Cucaracha",
	Rarity = "Secret",
	Price = 110000000,
	Generation = 475000,
	SpawnVFX = "Mexico",
	SpawnDelay = 3.5,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["To to to Sahur"] = {
	DisplayName = "To to to Sahur",
	Rarity = "Secret",
	Price = 575000000,
	Generation = 2250000,
	RoadWeight = 5e-7,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Mariachi Corazoni"] = {
	ObtainedFrom = {
		Source = "The Piñata",
		Obtainable = false
	},
	DisplayName = "Mariachi Corazoni",
	Rarity = "Secret",
	Price = 1750000000,
	Generation = 12500000,
	IgnoreIndexCounter = true
}
Animals["Los Tacoritas"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Los Tacoritas",
	Rarity = "Secret",
	Price = 4000000000,
	Generation = 32000000
}
Animals["Tictac Sahur"] = {
	DisplayName = "Tictac Sahur",
	Rarity = "Secret",
	Price = 6000000000,
	Generation = 37500000,
	RoadWeight = 3.5e-11,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Yess my examine"] = {
	DisplayName = "Yess my Examen",
	Rarity = "Secret",
	Price = 130000000,
	Generation = 575000,
	ObtainedFrom = {
		Source = "Dul Dul Ritual",
		Obtainable = false
	}
}
Animals["Karker Sahur"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Karker Sahur",
	Rarity = "Secret",
	Price = 185000000,
	Generation = 725000
}
Animals["Noo my examine"] = {
	DisplayName = "Noo my Examen",
	Rarity = "Secret",
	Price = 4250000000,
	Generation = 32500000,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Dul Dul Ritual",
		Obtainable = false
	}
}
Animals["Money Money Puggy"] = {
	DisplayName = "Money Money Puggy",
	Rarity = "Secret",
	Price = 2600000000,
	Generation = 21000000,
	RoadWeight = 5e-10,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Primos"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Los Primos",
	Rarity = "Secret",
	Price = 3750000000,
	Generation = 31000000
}
Animals["Tang Tang Keletang"] = {
	DisplayName = "Tang Tang Keletang",
	Rarity = "Secret",
	Price = 4500000000,
	Generation = 33500000,
	RoadWeight = 7.5e-11,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Perrito Burrito"] = {
	DisplayName = "Perrito Burrito",
	Rarity = "Secret",
	Price = 250000000,
	Generation = 1000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Chillin Chili"] = {
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	DisplayName = "Chillin Chili",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 25000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	IgnoreIndexCounter = true
}
Animals["Los Tortus"] = {
	DisplayName = "Los Tortus",
	Rarity = "Secret",
	Price = 100000000,
	Generation = 500000
}
Animals["Los Karkeritos"] = {
	DisplayName = "Los Karkeritos",
	Rarity = "Secret",
	Price = 200000000,
	Generation = 750000,
	SpawnVFX = "Karkerkar Kurkur",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Karker Ritual",
		Obtainable = false
	}
}
Animals["Los Jobcitos"] = {
	DisplayName = "Los Jobcitos",
	Rarity = "Secret",
	Price = 500000000,
	Generation = 1500000
}
Animals["Los 67"] = {
	DisplayName = "Los 67",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 22500000
}
Animals["La Secret Combinasion"] = {
	DisplayName = "La Secret Combinasion",
	Rarity = "Secret",
	Price = 50000000000,
	Generation = 125000000
}
Animals["Burguro And Fryuro"] = {
	DisplayName = "Burguro And Fryuro",
	Rarity = "Secret",
	Price = 75000000000,
	Generation = 150000000,
	RoadWeight = 2e-14
}
Animals["Zombie Tralala"] = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "Zombie Tralala",
	Rarity = "Secret",
	Price = 100000000,
	Generation = 500000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Witching Hour",
	SpawnDelay = 3
}
Animals["Vulturino Skeletono"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Vulturino Skeletono",
	Rarity = "Secret",
	Price = 110000000,
	Generation = 500000
}
Animals.Frankentteo = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "Frankentteo",
	Rarity = "Secret",
	Price = 175000000,
	Generation = 700000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Witching Hour",
	SpawnDelay = 3
}
Animals["La Vacca Jacko Linterino"] = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "La Vacca Jacko Linterino",
	Rarity = "Secret",
	Price = 225000000,
	Generation = 850000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Witching Hour",
	SpawnDelay = 3
}
Animals["Chicleteirina Bicicleteirina"] = {
	DisplayName = "Chicleteirina Bicicleteirina",
	Rarity = "Secret",
	Price = 850000000,
	Generation = 4000000,
	RoadWeight = 5e-8,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals.Eviledon = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Eviledon",
	Rarity = "Secret",
	Price = 3850000000,
	Generation = 31500000
}
Animals["La Spooky Grande"] = {
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	DisplayName = "La Spooky Grande",
	Rarity = "Secret",
	Price = 2900000000,
	Generation = 24500000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Witching Hour",
	SpawnDelay = 3
}
Animals["Los Mobilis"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Los Mobilis",
	Rarity = "Secret",
	Price = 2700000000,
	Generation = 22000000
}
Animals["Spooky and Pumpky"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Spooky and Pumpky",
	Rarity = "Secret",
	Price = 25000000000,
	Generation = 80000000
}
Animals["Boatito Auratito"] = {
	DisplayName = "Boatito Auratito",
	Rarity = "Secret",
	Price = 115000000,
	Generation = 525000,
	IgnoreIndexCounter = true,
	SpawnVFX = "Indonesia",
	SpawnDelay = 3.5,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Horegini Boom"] = {
	DisplayName = "Horegini Boom",
	Rarity = "Secret",
	Price = 650000000,
	Generation = 2750000,
	ObtainedFrom = {
		Source = "Aura Boat",
		Obtainable = false
	}
}
Animals["Rang Ring Bus"] = {
	DisplayName = "Rang Ring Bus",
	Rarity = "Secret",
	Price = 1100000000,
	Generation = 6000000,
	ObtainedFrom = {
		Source = "Pole Game",
		Obtainable = false
	}
}
Animals["Mieteteira Bicicleteira"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Mieteteira Bicicleteira",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 26000000
}
Animals["Quesadillo Vampiro"] = {
	DisplayName = "Quesadillo Vampiro",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 3500000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Burrito Bandito"] = {
	DisplayName = "Burrito Bandito",
	Rarity = "Secret",
	Price = 850000000,
	Generation = 4000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Chipso and Queso"] = {
	DisplayName = "Chipso and Queso",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 25000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals.Jackorilla = {
	DisplayName = "Jackorilla",
	Rarity = "Secret",
	Price = 80000000,
	Generation = 315000
}
Animals["Pumpkini Spyderini"] = {
	DisplayName = "Pumpkini Spyderini",
	Rarity = "Secret",
	Price = 165000000,
	Generation = 650000
}
Animals.Trickolino = {
	DisplayName = "Trickolino",
	Rarity = "Secret",
	Price = 235000000,
	Generation = 900000
}
Animals.Telemorte = {
	DisplayName = "Telemorte",
	Rarity = "Secret",
	Price = 550000000,
	Generation = 2000000
}
Animals["Pot Pumpkin"] = {
	ObtainedFrom = {
		Source = "Halloween Event",
		Obtainable = false
	},
	DisplayName = "Pot Pumpkin",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000
}
Animals["Noo my Candy"] = {
	DisplayName = "Noo my Candy",
	Rarity = "Secret",
	Price = 900000000,
	Generation = 5000000,
	ObtainedFrom = {
		Source = "Trick Or Treat",
		Obtainable = false
	}
}
Animals["Los Spooky Combinasionas"] = {
	DisplayName = "Los Spooky Combinasionas",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 20000000
}
Animals["La Casa Boo"] = {
	DisplayName = "La Casa Boo",
	Rarity = "Secret",
	Price = 40000000000,
	Generation = 100000000
}
Animals["La Taco Combinasion"] = {
	DisplayName = "La Taco Combinasion",
	Rarity = "Secret",
	Price = 5000000000,
	Generation = 35000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["1x1x1x1"] = {
	DisplayName = "1x1x1x1",
	Rarity = "Secret",
	Price = 255555555,
	Generation = 1111111,
	ObtainedFrom = {
		Source = "Cave Ritual",
		Obtainable = false
	}
}
Animals["John Doe"] = {
	DisplayName = "John Doe",
	Rarity = "Secret",
	Price = 1250000000,
	Generation = 7500000,
	ObtainedFrom = {
		Source = "Cave Ritual",
		Obtainable = false
	}
}
Animals["Capitano Moby"] = {
	DisplayName = "Capitano Moby",
	Rarity = "Secret",
	Price = 125000000000,
	Generation = 160000000,
	RoadWeight = 1e-14,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Guest 666"] = {
	DisplayName = "Guest 666",
	Rarity = "Secret",
	Price = 15666666666,
	Generation = 66666666,
	ObtainedFrom = {
		Source = "Cave Ritual",
		Obtainable = false
	}
}
Animals["Pirulitoita Bicicleteira"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Pirulitoita Bicicleteira",
	Rarity = "Secret",
	Price = 600000000,
	Generation = 2500000
}
Animals["Los Puggies"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Los Puggies",
	Rarity = "Secret",
	Price = 7000000000,
	Generation = 40000000,
	SpawnVFX = "Los Puggies",
	SpawnDelay = 3
}
Animals["Los Spaghettis"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Los Spaghettis",
	Rarity = "Secret",
	Price = 20000000000,
	Generation = 70000000
}
Animals["Fragrama and Chocrama"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Fragrama and Chocrama",
	Rarity = "Secret",
	Price = 40000000000,
	Generation = 100000000
}
Animals["Swag Soda"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Swag Soda",
	Rarity = "Secret",
	Price = 1800000000,
	Generation = 13000000
}
Animals.Orcaledon = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Orcaledon",
	Rarity = "Secret",
	Price = 7000000000,
	Generation = 40000000
}
Animals["Los Cucarachas"] = {
	DisplayName = "Los Cucarachas",
	Rarity = "Secret",
	Price = 300000000,
	Generation = 1250000
}
Animals["Los Burritos"] = {
	DisplayName = "Los Burritos",
	Rarity = "Secret",
	Price = 1400000000,
	Generation = 8500000
}
Animals["Los Quesadillas"] = {
	DisplayName = "Los Quesadillas",
	Rarity = "Secret",
	Price = 875000000,
	Generation = 4500000
}
Animals["Cuadramat and Pakrahmatmamat"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Cuadramat and Pakrahmatmamat",
	Rarity = "Secret",
	Price = 400000000,
	Generation = 1400000
}
Animals["Fishino Clownino"] = {
	ObtainedFrom = {
		Source = "Fishing Event",
		Obtainable = false
	},
	DisplayName = "Fishino Clownino",
	Rarity = "Secret",
	Price = 48500000000,
	Generation = 120000000
}
Animals["Los Planitos"] = {
	ObtainedFrom = {
		Source = "Brainrot Trader",
		Obtainable = false
	},
	DisplayName = "Los Planitos",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 18500000
}
Animals["W or L"] = {
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	DisplayName = "W or L",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 30000000
}
Animals["Lavadorito Spinito"] = {
	DisplayName = "Lavadorito Spinito",
	Rarity = "Secret",
	Price = 8000000000,
	Generation = 45000000,
	RoadWeight = 1.5e-11,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Gobblino Uniciclino"] = {
	ObtainedFrom = {
		Source = "Thanksgiving Event",
		Obtainable = false
	},
	DisplayName = "Gobblino Uniciclino",
	Rarity = "Secret",
	Price = 2850000000,
	Generation = 27500000
}
Animals["Giftini Spyderini"] = {
	DisplayName = "Giftini Spyderini",
	Rarity = "Secret",
	Price = 240000000,
	Generation = 999999,
	ObtainedFrom = {
		Source = "This was obtained from the North Pole",
		Obtainable = false,
		FullText = true
	}
}
Animals["Cooki and Milki"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Cooki and Milki",
	Rarity = "Secret",
	Price = 100000000000,
	Generation = 155000000
}
Animals["25"] = {
	ObtainedFrom = {
		Source = "Advent Calendar",
		Obtainable = false
	},
	DisplayName = "25",
	Rarity = "Secret",
	Price = 600000000,
	Generation = 2500000
}
Animals["La Vacca Prese Presente"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "La Vacca Prese Presente",
	Rarity = "Secret",
	Price = 160000000,
	Generation = 600000
}
Animals["Reindeer Tralala"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Reindeer Tralala",
	Rarity = "Secret",
	Price = 160000000,
	Generation = 600000,
	SpawnVFX = "Winter Hour",
	SpawnDelay = 3
}
Animals.Santteo = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Santteo",
	Rarity = "Secret",
	Price = 210000000,
	Generation = 800000,
	SpawnVFX = "Winter Hour",
	SpawnDelay = 3
}
Animals["Please my Present"] = {
	ObtainedFrom = {
		Source = "Advent Calendar",
		Obtainable = false
	},
	DisplayName = "Please my Present",
	Rarity = "Secret",
	Price = 350000000,
	Generation = 1300000
}
Animals["List List List Sahur"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "List List List Sahur",
	Rarity = "Secret",
	Price = 550000000,
	Generation = 2000000,
	SpawnVFX = "Winter Hour",
	SpawnDelay = 3
}
Animals["Ho Ho Ho Sahur"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Ho Ho Ho Sahur",
	Rarity = "Secret",
	Price = 725000000,
	Generation = 3250000
}
Animals["Chicleteira Noelteira"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Chicleteira Noelteira",
	Rarity = "Secret",
	Price = 2000000000,
	Generation = 15000000
}
Animals["La Jolly Grande"] = {
	DisplayName = "La Jolly Grande",
	Rarity = "Secret",
	Price = 3500000000,
	Generation = 30000000,
	SpawnVFX = "Winter Hour",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Christmas Wheel Spin",
		Obtainable = false
	}
}
Animals["Los Candies"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Los Candies",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 23000000
}
Animals["Triplito Tralaleritos"] = {
	DisplayName = "Triplito Tralaleritos",
	Rarity = "Secret",
	Price = 230000000,
	Generation = 875000
}
Animals["Santa Hotspot"] = {
	DisplayName = "Santa Hotspot",
	Rarity = "Secret",
	Price = 625000000,
	Generation = 2600000
}
Animals["La Ginger Sekolah"] = {
	DisplayName = "La Ginger Sekolah",
	Rarity = "Secret",
	Price = 23000000000,
	Generation = 75000000
}
Animals["Reinito Sleighito"] = {
	DisplayName = "Reinito Sleighito",
	Rarity = "Secret",
	Price = 60000000000,
	Generation = 140000000
}
Animals["Naughty Naughty"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Naughty Naughty",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000
}
Animals["Noo my Present"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Noo my Present",
	Rarity = "Secret",
	Price = 1100000000,
	Generation = 6000000
}
Animals["Los 25"] = {
	DisplayName = "Los 25",
	Rarity = "Secret",
	Price = 1500000000,
	Generation = 10000000
}
Animals.Chimnino = {
	DisplayName = "Chimnino",
	Rarity = "Secret",
	Price = 1900000000,
	Generation = 14000000
}
Animals["Festive 67"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Festive 67",
	Rarity = "Secret",
	Price = 16000000000,
	Generation = 67000000,
	IgnoreIndexCounter = true
}
Animals["Swaggy Bros"] = {
	DisplayName = "Swaggy Bros",
	Rarity = "Secret",
	Price = 7000000000,
	Generation = 40000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals.Bunnyman = {
	ObtainedFrom = {
		Source = "Advent Calendar",
		Obtainable = false
	},
	DisplayName = "Bunnyman",
	Rarity = "Secret",
	Price = 500000000,
	Generation = 1500000
}
Animals["Dragon Gingerini"] = {
	ObtainedFrom = {
		Source = "Santa's Fuse",
		Obtainable = false
	},
	DisplayName = "Dragon Gingerini",
	Rarity = "Secret",
	Price = 350000000000,
	Generation = 350000000
}
Animals["Donkeyturbo Express"] = {
	ObtainedFrom = {
		Source = "Christmas Event",
		Obtainable = false
	},
	DisplayName = "Donkeyturbo Express",
	Rarity = "Secret",
	Price = 1250000000,
	Generation = 7500000
}
Animals["Money Money Reindeer"] = {
	DisplayName = "Money Money Reindeer",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 25000000,
	SpawnVFX = "Money Money Reindeer",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Santa's Market",
		Obtainable = false
	}
}
Animals["Los Jolly Combinasionas"] = {
	ObtainedFrom = {
		Source = "Santa's Market",
		Obtainable = false
	},
	DisplayName = "Los Jolly Combinasionas",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 20000000
}
Animals["Jolly Jolly Sahur"] = {
	ObtainedFrom = {
		Source = "Santa's Market",
		Obtainable = false
	},
	DisplayName = "Jolly Jolly Sahur",
	Rarity = "Secret",
	Price = 8000000000,
	Generation = 45000000
}
Animals["Ginger Gerat"] = {
	ObtainedFrom = {
		Source = "Santa's Market",
		Obtainable = false
	},
	DisplayName = "Ginger Gerat",
	Rarity = "Secret",
	Price = 22500000000,
	Generation = 75000000
}
Animals["Rocco Disco"] = {
	ObtainedFrom = {
		Source = "New Year's Event",
		Obtainable = false
	},
	DisplayName = "Rocco Disco",
	Rarity = "Secret",
	Price = 150000000,
	Generation = 650000,
	SpawnVFX = "New Years 2026",
	SpawnDelay = 3
}
Animals["Bunito Bunito Spinito"] = {
	ObtainedFrom = {
		Source = "New Year's Event",
		Obtainable = false
	},
	DisplayName = "Bunito Bunito Spinito",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000,
	SpawnVFX = "New Years 2026",
	SpawnDelay = 3
}
Animals["Tuff Toucan"] = {
	ObtainedFrom = {
		Source = "New Year's Event",
		Obtainable = false
	},
	DisplayName = "Tuff Toucan",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 26000000,
	SpawnVFX = "New Years 2026",
	SpawnDelay = 3
}
Animals.Cerberus = {
	DisplayName = "Cerberus",
	Rarity = "Secret",
	Price = 150000000000,
	Generation = 175000000,
	RoadWeight = 3e-15,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals.GOAT = {
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	},
	DisplayName = "GOAT",
	Rarity = "Secret",
	Price = 237500000,
	Generation = 950000
}
Animals["Brunito Marsito"] = {
	DisplayName = "Brunito Marsito",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 3500000,
	ObtainedFrom = {
		Source = "This was spawned during Bruno's Concert Event",
		Obtainable = false,
		FullText = true
	}
}
Animals["Los Trios"] = {
	DisplayName = "Los Trios",
	Rarity = "Secret",
	Price = 175000000,
	Generation = 700000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Chill Puppy"] = {
	DisplayName = "Chill Puppy",
	Rarity = "Secret",
	Price = 850000000,
	Generation = 4000000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals.Arcadopus = {
	ObtainedFrom = {
		Source = "Tsunami LTM",
		Obtainable = false
	},
	DisplayName = "Arcadopus",
	Rarity = "Secret",
	Price = 900000000,
	Generation = 5000000
}
Animals["Spinny Hammy"] = {
	DisplayName = "Spinny Hammy",
	Rarity = "Secret",
	Price = 2300000000,
	Generation = 17000000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Bacuru and Egguru"] = {
	DisplayName = "Bacuru and Egguru",
	Rarity = "Secret",
	Price = 3850000000,
	Generation = 24000000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Ketupat Bros"] = {
	DisplayName = "Ketupat Bros",
	Rarity = "Secret",
	Price = 65000000000,
	Generation = 145000000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Hydra Dragon Cannelloni"] = {
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	},
	DisplayName = "Hydra Dragon Cannelloni",
	Rarity = "Secret",
	Price = 300000000000,
	Generation = 300000000
}
Animals["Mi Gatito"] = {
	DisplayName = "Mi Gatito",
	Rarity = "Secret",
	Price = 725000000,
	Generation = 3250000,
	SpawnVFX = "Mi Gatito",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	}
}
Animals["Los Mi Gatitos"] = {
	DisplayName = "Los Mi Gatitos",
	Rarity = "Secret",
	Price = 1150000000,
	Generation = 6500000,
	SpawnVFX = "Mi Gatito",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Mi Gatito Ritual",
		Obtainable = false
	}
}
Animals["Popcuru and Fizzuru"] = {
	DisplayName = "Popcuru and Fizzuru",
	Rarity = "Secret",
	Price = 135000000000,
	Generation = 170000000,
	ObtainedFrom = {
		Source = "OG Fuse",
		Obtainable = false
	}
}
Animals["Love Love Love Sahur"] = {
	DisplayName = "Love Love Love Sahur",
	Rarity = "Secret",
	Price = 250000000,
	Generation = 1000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Cupid Cupid Sahur"] = {
	DisplayName = "Cupid Cupid Sahur",
	Rarity = "Secret",
	Price = 715000000,
	Generation = 3100000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Cupid's Machine",
		Obtainable = false
	}
}
Animals["Cupid Hotspot"] = {
	DisplayName = "Cupid Hotspot",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 3500000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Noo my Heart"] = {
	DisplayName = "Noo my Heart",
	Rarity = "Secret",
	Price = 1800000000,
	Generation = 13000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Chicleteira Cupideira"] = {
	DisplayName = "Chicleteira Cupideira",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 17500000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Lovin Rose"] = {
	DisplayName = "Lovin Rose",
	Rarity = "Secret",
	Price = 4250000000,
	Generation = 32500000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Cupid's Machine",
		Obtainable = false
	}
}
Animals["La Romantic Grande"] = {
	DisplayName = "La Romantic Grande",
	Rarity = "Secret",
	Price = 7000000000,
	Generation = 40000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Rosetti Tualetti"] = {
	DisplayName = "Rosetti Tualetti",
	Rarity = "Secret",
	Price = 10000000000,
	Generation = 50000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Love Love Bear"] = {
	DisplayName = "Love Love Bear",
	Rarity = "Secret",
	Price = 225000000000,
	Generation = 225000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Cupid's Machine",
		Obtainable = false
	}
}
Animals["Rosey and Teddy"] = {
	DisplayName = "Rosey and Teddy",
	Rarity = "Secret",
	Price = 130000000000,
	Generation = 165000000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Los Sweethearts"] = {
	DisplayName = "Los Sweethearts",
	Rarity = "Secret",
	Price = 2250000000,
	Generation = 16500000,
	SpawnVFX = "Valentines",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "First Fuse Machine",
		Obtainable = false
	}
}
Animals["Sammyni Fattini"] = {
	DisplayName = "Sammyni Fattini",
	Rarity = "Secret",
	Price = 20000000000,
	Generation = 70000000
}
Animals["La Food Combinasion"] = {
	DisplayName = "La Food Combinasion",
	Rarity = "Secret",
	Price = 30000000000,
	Generation = 90000000
}
Animals["Los Sekolahs"] = {
	DisplayName = "Los Sekolahs",
	Rarity = "Secret",
	Price = 45000000000,
	Generation = 110000000
}
Animals["Los Amigos"] = {
	DisplayName = "Los Amigos",
	Rarity = "Secret",
	Price = 55000000000,
	Generation = 130000000
}
Animals["Tirilikalika Tirilikalako"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Tirilikalika Tirilikalako",
	Rarity = "Secret",
	Price = 7500000000,
	Generation = 42500000
}
Animals.Antonio = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Antonio",
	Rarity = "Secret",
	Price = 50000000000,
	Generation = 125000000
}
Animals["Elefanto Frigo"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Elefanto Frigo",
	Rarity = "Secret",
	Price = 175000000000,
	Generation = 185000000
}
Animals["Signore Carapace"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Signore Carapace",
	Rarity = "Secret",
	Price = 275000000000,
	Generation = 275000000
}
Animals.Fishboard = {
	DisplayName = "Fishboard",
	Rarity = "Secret",
	Price = 215000000,
	Generation = 825000,
	RoadWeight = 4e-6,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["DJ Panda"] = {
	DisplayName = "DJ Panda",
	Rarity = "Secret",
	Price = 2500000000,
	Generation = 17500000,
	RoadWeight = 3e-9,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Ventoliero Pavonero"] = {
	DisplayName = "Ventoliero Pavonero",
	Rarity = "Secret",
	Price = 15500000000,
	Generation = 65000000,
	RoadWeight = 7e-12,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Celestial Pegasus"] = {
	DisplayName = "Celestial Pegasus",
	Rarity = "Secret",
	Price = 150000000000,
	Generation = 175000000
}
Animals["Tacorillo Crocodillo"] = {
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	DisplayName = "Tacorillo Crocodillo",
	Rarity = "Secret",
	Price = 1500000000,
	Generation = 12500000,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Nacho Spyder"] = {
	DisplayName = "Nacho Spyder",
	Rarity = "Secret",
	Price = 10000000000,
	Generation = 50000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Paradiso Axolottino"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Paradiso Axolottino",
	Rarity = "Secret",
	Price = 235000000,
	Generation = 900000
}
Animals["Serafinna Medusella"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Serafinna Medusella",
	Rarity = "Secret",
	Price = 1000000000,
	Generation = 5500000
}
Animals["Cigno Fulgoro"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Cigno Fulgoro",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 20000000
}
Animals["Los Cupids"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Los Cupids",
	Rarity = "Secret",
	Price = 3500000000,
	Generation = 30000000
}
Animals.Griffin = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Griffin",
	Rarity = "Secret",
	Price = 400000000000,
	Generation = 400000000
}
Animals["La Vacca Lepre Lepreino"] = {
	DisplayName = "La Vacca Lepre Lepreino",
	Rarity = "Secret",
	Price = 255000000,
	Generation = 1100000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Luck Luck Luck Sahur"] = {
	DisplayName = "Luck Luck Luck Sahur",
	Rarity = "Secret",
	Price = 800000000,
	Generation = 3750000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Noo my Gold"] = {
	DisplayName = "Noo my Gold",
	Rarity = "Secret",
	Price = 1850000000,
	Generation = 13500000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Snailo Clovero"] = {
	DisplayName = "Snailo Clovero",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 18500000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Gold Gold Gold"] = {
	DisplayName = "Gold Gold Gold",
	Rarity = "Secret",
	Price = 8000000000,
	Generation = 45000000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Fortunu and Cashuru"] = {
	DisplayName = "Fortunu and Cashuru",
	Rarity = "Secret",
	Price = 55000000000,
	Generation = 130000000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Cloverat Clapat"] = {
	ObtainedFrom = {
		Source = "St Patricks Event",
		Obtainable = false
	},
	DisplayName = "Cloverat Clapat",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 60000000,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Dug dug dug"] = {
	ObtainedFrom = {
		Source = "First Craft Machine",
		Obtainable = false
	},
	DisplayName = "Dug dug dug",
	Rarity = "Secret",
	Price = 5000000000,
	Generation = 35000000
}
Animals["La Lucky Grande"] = {
	DisplayName = "La Lucky Grande",
	Rarity = "Secret",
	Price = 7000000000,
	Generation = 40000000,
	SpawnVFX = "Clover",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Eid Eid Eid Sahur"] = {
	DisplayName = "Eid Eid Eid Sahur",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 3500000,
	ObtainedFrom = {
		Source = "Eid Event",
		Obtainable = false
	}
}
Animals.Granny = {
	DisplayName = "Granny",
	Rarity = "Secret",
	Price = 850000000,
	Generation = 4000000,
	SpawnVFX = "Granny",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Granny's Funeral Event",
		Obtainable = false
	}
}
Animals["Foxini Lanternini"] = {
	ObtainedFrom = {
		Source = "Eid Event",
		Obtainable = false
	},
	DisplayName = "Foxini Lanternini",
	Rarity = "Secret",
	Price = 47500000000,
	Generation = 115000000
}
Animals.Buntteo = {
	ObtainedFrom = {
		Source = "Easter Event",
		Obtainable = false
	},
	DisplayName = "Buntteo",
	Rarity = "Secret",
	Price = 225000000,
	Generation = 850000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Bunny Bunny Bunny Sahur"] = {
	ObtainedFrom = {
		Source = "Easter Event",
		Obtainable = false
	},
	DisplayName = "Bunny Bunny Bunny Sahur",
	Rarity = "Secret",
	Price = 575000000,
	Generation = 2250000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Noo my Eggs"] = {
	ObtainedFrom = {
		Source = "Easter Event",
		Obtainable = false
	},
	DisplayName = "Noo my Eggs",
	Rarity = "Secret",
	Price = 1200000000,
	Generation = 7000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["La Easter Grande"] = {
	DisplayName = "La Easter Grande",
	Rarity = "Secret",
	Price = 12500000000,
	Generation = 55000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Easter Easter Easter Sahur"] = {
	DisplayName = "Easter Easter Easter Sahur",
	Rarity = "Secret",
	Price = 300000000,
	Generation = 1250000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Los Bunitos"] = {
	DisplayName = "Los Bunitos",
	Rarity = "Secret",
	Price = 865000000,
	Generation = 4250000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals.Baskito = {
	DisplayName = "Baskito",
	Rarity = "Secret",
	Price = 2100000000,
	Generation = 16000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Churrito Bunnito"] = {
	DisplayName = "Churrito Bunnito",
	Rarity = "Secret",
	Price = 2600000000,
	Generation = 21000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Quackini Snackini"] = {
	ObtainedFrom = {
		Source = "Egg Town Event",
		Obtainable = false
	},
	DisplayName = "Quackini Snackini",
	Rarity = "Secret",
	Price = 15500000000,
	Generation = 65000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Hopilikalika Hopilikalako"] = {
	DisplayName = "Hopilikalika Hopilikalako",
	Rarity = "Secret",
	Price = 12500000000,
	Generation = 55000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Boppin Bunny"] = {
	DisplayName = "Boppin Bunny",
	Rarity = "Secret",
	Price = 25000000000,
	Generation = 80000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	IgnoreIndexCounter = true,
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	}
}
Animals["Hydra Bunny"] = {
	DisplayName = "Hydra Bunny",
	Rarity = "Secret",
	Price = 175000000000,
	Generation = 185000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Bunny and Eggy"] = {
	ObtainedFrom = {
		Source = "Divine Fuse",
		Obtainable = false
	},
	DisplayName = "Bunny and Eggy",
	Rarity = "Secret",
	Price = 135000000000,
	Generation = 170000000,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Globa Steppa"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Globa Steppa",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 27500000,
	IgnoreIndexCounter = true
}
Animals["Rico Dinero"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Rico Dinero",
	Rarity = "Secret",
	Price = 7500000000,
	Generation = 42500000,
	IgnoreIndexCounter = true
}
Animals["Pancake and Syrup"] = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Pancake and Syrup",
	Rarity = "Secret",
	Price = 50000000000,
	Generation = 125000000,
	IgnoreIndexCounter = true
}
Animals.Arcadragon = {
	ObtainedFrom = {
		Source = "DLC Code",
		Obtainable = false
	},
	DisplayName = "Arcadragon",
	Rarity = "Secret",
	Price = 215000000000,
	Generation = 215000000,
	IgnoreIndexCounter = true
}
Animals.Berryno = {
	DisplayName = "Berryno",
	Rarity = "Secret",
	Price = 500000000,
	Generation = 1500000,
	RoadWeight = 7e-7,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals.Strawberrita = {
	DisplayName = "Strawberrita",
	Rarity = "Secret",
	Price = 1150000000,
	Generation = 6500000,
	RoadWeight = 3e-8
}
Animals.Bananito = {
	DisplayName = "Bananito",
	Rarity = "Secret",
	Price = 2000000000,
	Generation = 15000000,
	RoadWeight = 8e-9,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Cash or Card"] = {
	DisplayName = "Cash or Card",
	Rarity = "Secret",
	Price = 40000000000,
	Generation = 100000000,
	RoadWeight = 3e-14,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Los Mariachis"] = {
	ObtainedFrom = {
		Source = "The Piñata",
		Obtainable = false
	},
	DisplayName = "Los Mariachis",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 30000000
}
Animals["Buho de Volto"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Buho de Volto",
	Rarity = "Secret",
	Price = 650000000,
	Generation = 2750000
}
Animals["Futbolini Skatini"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Futbolini Skatini",
	Rarity = "Secret",
	Price = 875000000,
	Generation = 4500000
}
Animals["Camera Ramena"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Camera Ramena",
	Rarity = "Secret",
	Price = 2300000000,
	Generation = 17000000
}
Animals["Gym Bros"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Gym Bros",
	Rarity = "Secret",
	Price = 7500000000,
	Generation = 42500000
}
Animals["Money Money Bros"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Money Money Bros",
	Rarity = "Secret",
	Price = 9000000000,
	Generation = 47000000
}
Animals["Los Chillis"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Los Chillis",
	Rarity = "Secret",
	Price = 22500000000,
	Generation = 75000000
}
Animals["Los Hackers"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Los Hackers",
	Rarity = "Secret",
	Price = 22500000000,
	Generation = 75000000
}
Animals["Duggy Bros"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Duggy Bros",
	Rarity = "Secret",
	Price = 30000000000,
	Generation = 90000000
}
Animals["Kalika Bros"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Kalika Bros",
	Rarity = "Secret",
	Price = 47500000000,
	Generation = 115000000
}
Animals["Digi Narwhal"] = {
	ObtainedFrom = {
		Source = "Cyber Craft",
		Obtainable = false
	},
	DisplayName = "Digi Narwhal",
	Rarity = "Secret",
	Price = 200000000000,
	Generation = 200000000
}
Animals.Flancito = {
	DisplayName = "Flancito",
	Rarity = "Secret",
	Price = 800000000,
	Generation = 3750000,
	ObtainedFrom = {
		Source = "SAB's Anniversary Event",
		Obtainable = false
	}
}
Animals["La Anniversary Grande"] = {
	DisplayName = "La Anniversary Grande",
	Rarity = "Secret",
	Price = 10000000000,
	Generation = 50000000,
	SpawnVFX = "Taco",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals["Sammyni Cakini"] = {
	DisplayName = "Sammyni Cakini",
	Rarity = "Secret",
	Price = 25500000000,
	Generation = 85000000,
	ObtainedFrom = {
		Source = "SAB's Anniversary Event",
		Obtainable = false
	}
}
Animals["Jelly Moby"] = {
	DisplayName = "Jelly Moby",
	Rarity = "Secret",
	Price = 150000000000,
	Generation = 175000000,
	ObtainedFrom = {
		Source = "SAB's Anniversary Event",
		Obtainable = false
	}
}
Animals["Hippo Golazo"] = {
	DisplayName = "Hippo Golazo",
	Rarity = "Secret",
	Price = 300000000,
	Generation = 1250000,
	ObtainedFrom = {
		Source = "Soccer Board",
		Obtainable = false
	},
	SpawnVFX = "LiveSoccer",
	SpawnDelay = 3
}
Animals["Ref Ref Ref Sahur"] = {
	DisplayName = "Ref Ref Ref Sahur",
	Rarity = "Secret",
	Price = 650000000,
	Generation = 2750000,
	ObtainedFrom = {
		Source = "Soccer Board",
		Obtainable = false
	},
	SpawnVFX = "LiveSoccer",
	SpawnDelay = 3
}
Animals["Esok Goala"] = {
	DisplayName = "Esok Goala",
	Rarity = "Secret",
	Price = 4250000000,
	Generation = 32500000,
	ObtainedFrom = {
		Source = "Soccer Board",
		Obtainable = false
	},
	SpawnVFX = "LiveSoccer",
	SpawnDelay = 3
}
Animals["Los Admins"] = {
	DisplayName = "Los Admins",
	Rarity = "Secret",
	Price = 35000000000,
	Generation = 95000000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Los Tictacs"] = {
	DisplayName = "Los Tictacs",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 60000000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Moby Bros"] = {
	DisplayName = "Moby Bros",
	Rarity = "Secret",
	Price = 225000000000,
	Generation = 225000000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Los Tangcitos"] = {
	DisplayName = "Los Tangcitos",
	Rarity = "Secret",
	Price = 7500000000,
	Generation = 42500000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Los Sigmas"] = {
	DisplayName = "Los Sigmas",
	Rarity = "Secret",
	Price = 580000000,
	Generation = 2300000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Los Cornis"] = {
	DisplayName = "Los Cornis",
	Rarity = "Secret",
	Price = 715000000,
	Generation = 3100000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Eggdin Egg Egg Dun Egg"] = {
	DisplayName = "Eggdin Egg Egg Dun Egg",
	Rarity = "Easter",
	Price = 72500000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 300,
		Animals = {
			{
				Name = "Eggdin Egg Egg Dun",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Bunny Tralala Egg"] = {
	DisplayName = "Bunny Tralala Egg",
	Rarity = "Easter",
	Price = 47000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 300,
		Animals = {
			{
				Name = "Bunny Tralala",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Easter Easter Easter Sahur Egg"] = {
	DisplayName = "Easter Easter Easter Sahur Egg",
	Rarity = "Easter",
	Price = 300000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Easter Easter Easter Sahur",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Noo my Eggs Egg"] = {
	DisplayName = "Noo my Eggs Egg",
	Rarity = "Easter",
	Price = 1200000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Noo my Eggs",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Buntteo Egg"] = {
	DisplayName = "Buntteo Egg",
	Rarity = "Easter",
	Price = 225000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Buntteo",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Hopilikalika Hopilikalako Egg"] = {
	DisplayName = "Hopilikalika Hopilikalako Egg",
	Rarity = "Easter",
	Price = 12500000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Hopilikalika Hopilikalako",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Los Bunitos Egg"] = {
	DisplayName = "Los Bunitos Egg",
	Rarity = "Easter",
	Price = 865000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Los Bunitos",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Hydra Bunny Egg"] = {
	DisplayName = "Hydra Bunny Egg",
	Rarity = "Easter",
	Price = 175000000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Hydra Bunny",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Baskito Egg"] = {
	DisplayName = "Baskito Egg",
	Rarity = "Easter",
	Price = 2100000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Baskito",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Quackini Snackini Egg"] = {
	DisplayName = "Quackini Snackini Egg",
	Rarity = "Easter",
	Price = 15500000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Quackini Snackini",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Churrito Bunnito Egg"] = {
	DisplayName = "Churrito Bunnito Egg",
	Rarity = "Easter",
	Price = 2600000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Churrito Bunnito",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Bunny Bunny Bunny Sahur Egg"] = {
	DisplayName = "Bunny Bunny Bunny Sahur Egg",
	Rarity = "Easter",
	Price = 575000000,
	Generation = 0,
	SpawnVFX = "Easter",
	SpawnDelay = 3,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Bunny Bunny Bunny Sahur",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals.Glaciator = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Glaciator",
	Rarity = "Secret",
	Price = 580000000,
	Generation = 2300000
}
Animals["Flipa Sandala"] = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Flipa Sandala",
	Rarity = "Secret",
	Price = 1100000000,
	Generation = 6000000
}
Animals.Abyssaloco = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Abyssaloco",
	Rarity = "Secret",
	Price = 4333333333,
	Generation = 33333333
}
Animals.Rubrikiko = {
	ObtainedFrom = {
		Source = "Backrooms Event",
		Obtainable = false
	},
	DisplayName = "Rubrikiko",
	Rarity = "Secret",
	Price = 20000000000,
	Generation = 70000000
}
Animals["Bombardiro Vaccariro"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Bombardiro Vaccariro",
	Rarity = "Secret",
	Price = 250000000,
	Generation = 1000000
}
Animals["Ombrello Topolino"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Ombrello Topolino",
	Rarity = "Secret",
	Price = 1150000000,
	Generation = 6500000
}
Animals["Capitano Gullini"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Capitano Gullini",
	Rarity = "Secret",
	Price = 2700000000,
	Generation = 22000000
}
Animals["Coco and Mango"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Coco and Mango",
	Rarity = "Secret",
	Price = 4500000000,
	Generation = 33500000
}
Animals["Dragon Aquanini"] = {
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	DisplayName = "Dragon Aquanini",
	Rarity = "Secret",
	Price = 375000000000,
	Generation = 375000000
}
Animals["Steakini Fattini"] = {
	DisplayName = "Steakini Fattini",
	Rarity = "Secret",
	Price = 12500000000,
	Generation = 55000000,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals.Caylusaurus = {
	DisplayName = "Caylusaurus",
	Rarity = "Secret",
	Price = 12500000000,
	Generation = 55000000,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	}
}
Animals.Craburger = {
	DisplayName = "Craburger",
	Rarity = "Secret",
	Price = 350000000,
	Generation = 1300000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Rocketini Frostini"] = {
	DisplayName = "Rocketini Frostini",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000,
	ObtainedFrom = {
		Source = "Sammy's Code",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals.Octoball = {
	DisplayName = "Octoball",
	Rarity = "Secret",
	Price = 725000000,
	Generation = 3250000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Sushi Inu"] = {
	DisplayName = "Sushi Inu",
	Rarity = "Secret",
	Price = 1300000000,
	Generation = 8000000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Girafini Raftini"] = {
	DisplayName = "Girafini Raftini",
	Rarity = "Secret",
	Price = 2600000000,
	Generation = 18000000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Frullato Framingo"] = {
	DisplayName = "Frullato Framingo",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 20000000,
	ObtainedFrom = {
		Source = "Sammy's Code",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Los Fruits"] = {
	DisplayName = "Los Fruits",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 23000000,
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Sand Sand Sand"] = {
	DisplayName = "Sand Sand Sand",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 30000000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Bearito Cabinito"] = {
	DisplayName = "Bearito Cabinito",
	Rarity = "Secret",
	Price = 21000000000,
	Generation = 72500000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals.Venuspino = {
	DisplayName = "Venuspino",
	Rarity = "Secret",
	Price = 150000000000,
	Generation = 175000000,
	ObtainedFrom = {
		Source = "Summer Fuse",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals.Kraken = {
	DisplayName = "Kraken",
	Rarity = "Secret",
	Price = 200000000000,
	Generation = 200000000,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Gelato Lumacho"] = {
	DisplayName = "Gelato Lumacho",
	Rarity = "Secret",
	Price = 400000000,
	Generation = 1400000,
	ObtainedFrom = {
		Source = "Summer Hour",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals.Aquarino = {
	DisplayName = "Aquarino",
	Rarity = "Secret",
	Price = 865000000,
	Generation = 4250000,
	ObtainedFrom = {
		Source = "Summer Hour",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Chicleteira Surfeiteira"] = {
	DisplayName = "Chicleteira Surfeiteira",
	Rarity = "Secret",
	Price = 2100000000,
	Generation = 16000000,
	ObtainedFrom = {
		Source = "Summer Hour",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["La Summer Grande"] = {
	DisplayName = "La Summer Grande",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 60000000,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["4th Bros"] = {
	DisplayName = "4th Bros",
	Rarity = "Secret",
	Price = 800000000,
	Generation = 3750000,
	ObtainedFrom = {
		Source = "Admin Abuse",
		Obtainable = false
	},
	SpawnVFX = "4th of July",
	SpawnDelay = 3.5
}
Animals["Var Var Var"] = {
	DisplayName = "Var Var Var",
	Rarity = "Secret",
	Price = 1000000000,
	Generation = 5500000,
	ObtainedFrom = {
		Source = "Soccer Board",
		Obtainable = false
	},
	SpawnVFX = "LiveSoccer",
	SpawnDelay = 3
}
Animals["Bufalino Boomberino"] = {
	DisplayName = "Bufalino Boomberino",
	Rarity = "Secret",
	Price = 4000000000,
	Generation = 32000000,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	SpawnVFX = "4th of July",
	SpawnDelay = 3.5
}
Animals["Capitano Americano"] = {
	DisplayName = "Capitano Americano",
	Rarity = "Secret",
	Price = 21000000000,
	Generation = 72500000,
	ObtainedFrom = {
		Source = "Limited Quantity Craft",
		Obtainable = false
	},
	SpawnVFX = "4th of July",
	SpawnDelay = 3.5
}
Animals["Noodle Noodle Poodle"] = {
	DisplayName = "Noodle Noodle Poodle",
	Rarity = "Secret",
	Price = 3000000000,
	Generation = 27500000,
	RoadWeight = 8.75e-11,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = false
	}
}
Animals.Grabatron = {
	DisplayName = "Grabatron",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 62500000,
	ObtainedFrom = {
		Source = "DLC Codes",
		Obtainable = false
	}
}
Animals["Rubiko and Kubiko"] = {
	DisplayName = "Rubiko and Kubiko",
	Rarity = "Secret",
	Price = 21000000000,
	Generation = 72500000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Cangurato Gelato"] = {
	DisplayName = "Cangurato Gelato",
	Rarity = "Secret",
	Price = 23500000000,
	Generation = 77500000,
	RoadWeight = 7e-14,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Toro Españolo"] = {
	DisplayName = "Toro Españolo",
	Rarity = "Secret",
	Price = 575000000,
	Generation = 2250000,
	ObtainedFrom = {
		Source = "Spain Event",
		Obtainable = false
	},
	SpawnVFX = "Spain",
	SpawnDelay = 3
}
Animals["Chicleteira Champeona"] = {
	DisplayName = "Chicleteira Champeona",
	Rarity = "Secret",
	Price = 2850000000,
	Generation = 19000000,
	ObtainedFrom = {
		Source = "Spain Event",
		Obtainable = false
	},
	SpawnVFX = "Spain",
	SpawnDelay = 3
}
Animals["Examen Bros"] = {
	DisplayName = "Examen Bros",
	Rarity = "Secret",
	Price = 20000000000,
	Generation = 70000000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Pizza and Ranch"] = {
	DisplayName = "Pizza and Ranch",
	Rarity = "Secret",
	Price = 55000000000,
	Generation = 130000000,
	RoadWeight = 2.5e-14
}
Animals["Los Secret Combinasionas"] = {
	DisplayName = "Los Secret Combinasionas",
	Rarity = "Secret",
	Price = 75000000000,
	Generation = 150000000,
	ObtainedFrom = {
		Source = "Los Traders",
		Obtainable = false
	}
}
Animals["Yess my Resume"] = {
	DisplayName = "Yess my Resume",
	Rarity = "Secret",
	Price = 560000000,
	Generation = 2100000,
	SpawnVFX = "Job Job Job Sahur",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Job Ritual",
		Obtainable = true
	}
}
Animals["Noo my Resume"] = {
	DisplayName = "Noo my Resume",
	Rarity = "Secret",
	Price = 4250000000,
	Generation = 32500000,
	SpawnVFX = "Job Job Job Sahur",
	SpawnDelay = 3,
	ObtainedFrom = {
		Source = "Job Ritual",
		Obtainable = true
	}
}
Animals["Gelatina Volatina"] = {
	DisplayName = "Gelatina Volatina",
	Rarity = "Secret",
	Price = 590000000,
	Generation = 2400000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Conetto Morsetto"] = {
	DisplayName = "Conetto Morsetto",
	Rarity = "Secret",
	Price = 1500000000,
	Generation = 10000000,
	ObtainedFrom = {
		Source = "Bee Merchant",
		Obtainable = false
	}
}
Animals["Pogo Pogo Penguin"] = {
	DisplayName = "Pogo Pogo Penguin",
	Rarity = "Secret",
	Price = 1750000000,
	Generation = 12500000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Peschito Machito"] = {
	DisplayName = "Peschito Machito",
	Rarity = "Secret",
	Price = 2850000000,
	Generation = 19000000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Honey Honey Bear"] = {
	DisplayName = "Honey Honey Bear",
	Rarity = "Secret",
	Price = 4000000000,
	Generation = 32000000,
	ObtainedFrom = {
		Source = "Bee Merchant",
		Obtainable = false
	}
}
Animals["Scorpino Coasterino"] = {
	DisplayName = "Scorpino Coasterino",
	Rarity = "Secret",
	Price = 9250000000,
	Generation = 47500000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Queen Bee"] = {
	DisplayName = "Queen Bee",
	Rarity = "Secret",
	Price = 15500000000,
	Generation = 65000000,
	ObtainedFrom = {
		Source = "Bee Merchant",
		Obtainable = false
	}
}
Animals["S'more Serat"] = {
	DisplayName = "S'more Serat",
	Rarity = "Secret",
	Price = 25500000000,
	Generation = 85000000,
	ObtainedFrom = {
		Source = "Bee Merchant",
		Obtainable = false
	}
}
Animals.Yetimatic = {
	DisplayName = "Yetimatic",
	Rarity = "Secret",
	Price = 27500000000,
	Generation = 87500000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["La Breakfast Combinasion"] = {
	DisplayName = "La Breakfast Combinasion",
	Rarity = "Secret",
	Price = 130000000000,
	Generation = 165000000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals.Bumbatron = {
	DisplayName = "Bumbatron",
	Rarity = "Secret",
	Price = 140000000000,
	Generation = 172500000,
	ObtainedFrom = {
		Source = "Bee Merchant",
		Obtainable = false
	}
}
Animals.Polaroidini = {
	DisplayName = "Polaroidini",
	Rarity = "Secret",
	Price = 13500000000,
	Generation = 55000000,
	ObtainedFrom = {
		Source = "DLC Codes",
		Obtainable = false
	}
}
Animals["Candini Fluffini"] = {
	DisplayName = "Candini Fluffini",
	Rarity = "Secret",
	Price = 14000000000,
	Generation = 57500000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["La Fuse Machine"] = {
	DisplayName = "La Fuse Machine",
	Rarity = "Secret",
	Price = 35000000000,
	Generation = 95000000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Burrito Bat"] = {
	DisplayName = "Burrito Bat",
	Rarity = "Secret",
	Price = 1200000000,
	Generation = 7000000,
	ObtainedFrom = {
		Source = "Taco Merchant",
		Obtainable = false
	}
}
Animals["Tacoturbo Tacorito"] = {
	DisplayName = "Tacoturbo Tacorito",
	Rarity = "Secret",
	Price = 2750000000,
	Generation = 26000000,
	ObtainedFrom = {
		Source = "Taco Merchant",
		Obtainable = false
	}
}
Animals.Nachorilla = {
	DisplayName = "Nachorilla",
	Rarity = "Secret",
	Price = 9250000000,
	Generation = 47500000,
	ObtainedFrom = {
		Source = "Taco Merchant",
		Obtainable = false
	}
}
Animals["Sammyni Truckini"] = {
	DisplayName = "Sammyni Truckini",
	Rarity = "Secret",
	Price = 45000000000,
	Generation = 110000000,
	ObtainedFrom = {
		Source = "Taco Merchant",
		Obtainable = false
	}
}
Animals["Honey Honey Narwhal"] = {
	DisplayName = "Honey Honey Narwhal",
	Rarity = "Secret",
	Price = 237500000,
	Generation = 950000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals["Rosatops Triceratino"] = {
	DisplayName = "Rosatops Triceratino",
	Rarity = "Secret",
	Price = 715000000,
	Generation = 3100000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals["Syrup Samurai"] = {
	DisplayName = "Syrup Samurai",
	Rarity = "Secret",
	Price = 1175000000,
	Generation = 6700000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals["Motorino Bumbino"] = {
	DisplayName = "Motorino Bumbino",
	Rarity = "Secret",
	Price = 2250000000,
	Generation = 16500000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals["Pop Pop Petalini"] = {
	DisplayName = "Pop Pop Petalini",
	Rarity = "Secret",
	Price = 15000000000,
	Generation = 62500000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals.Orchidox = {
	DisplayName = "Orchidox",
	Rarity = "Secret",
	Price = 215000000000,
	Generation = 215000000,
	ObtainedFrom = {
		Source = "Bee Block",
		Obtainable = false
	}
}
Animals.Gub = {
	DisplayName = "Gub",
	Rarity = "Secret",
	Price = 900000000,
	Generation = 5000000,
	RoadWeight = 4e-8,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Sir Mangus"] = {
	DisplayName = "Sir Mangus",
	Rarity = "Secret",
	Price = 1250000000,
	Generation = 7500000,
	RoadWeight = 2e-8,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Gattino Hydrantino"] = {
	DisplayName = "Gattino Hydrantino",
	Rarity = "Secret",
	Price = 1950000000,
	Generation = 14500000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Puffino Builderino"] = {
	DisplayName = "Puffino Builderino",
	Rarity = "Secret",
	Price = 3750000000,
	Generation = 31000000,
	ObtainedFrom = {
		Source = "RNG Machine",
		Obtainable = false
	}
}
Animals["Pelican Pachetto"] = {
	DisplayName = "Pelican Pachetto",
	Rarity = "Secret",
	Price = 525000000,
	Generation = 1750000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Deputy Leopard"] = {
	DisplayName = "Deputy Leopard",
	Rarity = "Secret",
	Price = 2600000000,
	Generation = 18000000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Chicli Chicla"] = {
	DisplayName = "Chicli Chicla",
	Rarity = "Secret",
	Price = 9250000000,
	Generation = 47500000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Panda Popanda"] = {
	DisplayName = "Panda Popanda",
	Rarity = "Secret",
	Price = 16000000000,
	Generation = 67000000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["La Craft Machine"] = {
	DisplayName = "La Craft Machine",
	Rarity = "Secret",
	Price = 22500000000,
	Generation = 75000000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Gold and Diamond"] = {
	DisplayName = "Gold and Diamond",
	Rarity = "Secret",
	Price = 25500000000,
	Generation = 85000000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Los Dragons"] = {
	DisplayName = "Los Dragons",
	Rarity = "Secret",
	Price = 425000000000,
	Generation = 425000000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Zebrino Pianino"] = {
	DisplayName = "Zebrino Pianino",
	Rarity = "Secret",
	Price = 1225000000,
	Generation = 7250000,
	ObtainedFrom = {
		Source = "OG Craft",
		Obtainable = false
	}
}
Animals["Hydra Serpent"] = {
	DisplayName = "Hydra Serpent",
	Rarity = "Secret",
	Price = 220000000000,
	Generation = 220000000,
	RoadWeight = 2e-15,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	}
}
Animals["Ranito Pepito"] = {
	DisplayName = "Ranito Pepito",
	Rarity = "Secret",
	Price = 237500000,
	Generation = 950000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Ski Ski Skunki"] = {
	DisplayName = "Ski Ski Skunki",
	Rarity = "Secret",
	Price = 510000000,
	Generation = 1600000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Capibaro Celestino"] = {
	DisplayName = "Capibaro Celestino",
	Rarity = "Secret",
	Price = 525000000,
	Generation = 1750000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Pin Pin Pengu"] = {
	DisplayName = "Pin Pin Pengu",
	Rarity = "Secret",
	Price = 580000000,
	Generation = 2300000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Rexino Ramino"] = {
	DisplayName = "Rexino Ramino",
	Rarity = "Secret",
	Price = 625000000,
	Generation = 2600000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Rockarino Rockara"] = {
	DisplayName = "Rockarino Rockara",
	Rarity = "Secret",
	Price = 700000000,
	Generation = 3000000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Qamar Camelamp"] = {
	DisplayName = "Qamar Camelamp",
	Rarity = "Secret",
	Price = 740000000,
	Generation = 3300000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Marino Submarino"] = {
	DisplayName = "Marino Submarino",
	Rarity = "Secret",
	Price = 775000000,
	Generation = 3600000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals.Lavamanta = {
	DisplayName = "Lavamanta",
	Rarity = "Secret",
	Price = 3250000000,
	Generation = 28500000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Lionello Casarello"] = {
	DisplayName = "Lionello Casarello",
	Rarity = "Secret",
	Price = 14500000000,
	Generation = 58500000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals.Draculino = {
	DisplayName = "Draculino",
	Rarity = "Secret",
	Price = 48500000000,
	Generation = 120000000,
	ObtainedFrom = {
		Source = "Jump for Eggs LTM",
		Obtainable = true
	}
}
Animals["Penguino Pumpkino"] = {
	DisplayName = "Penguino Pumpkino",
	Rarity = "Epic",
	Price = 38500,
	Generation = 235,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Frostino Vampiro"] = {
	DisplayName = "Frostino Vampiro",
	Rarity = "Mythic",
	Price = 5250000,
	Generation = 17500,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Vampi Ribbitini"] = {
	DisplayName = "Vampi Ribbitini",
	Rarity = "Brainrot God",
	Price = 32500000,
	Generation = 185000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Mummelo Bandello"] = {
	DisplayName = "Mummelo Bandello",
	Rarity = "Brainrot God",
	Price = 55000000,
	Generation = 285000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals.Mortaruga = {
	DisplayName = "Mortaruga",
	Rarity = "Brainrot God",
	Price = 78500000,
	Generation = 324000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Los Treaters"] = {
	DisplayName = "Los Treaters",
	Rarity = "Secret",
	Price = 275500000,
	Generation = 1200000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Fangaro Lupino"] = {
	DisplayName = "Fangaro Lupino",
	Rarity = "Secret",
	Price = 1225000000,
	Generation = 7250000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Oni Oni Panda"] = {
	DisplayName = "Oni Oni Panda",
	Rarity = "Secret",
	Price = 2800000000,
	Generation = 27000000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Sammyni Spookyni"] = {
	DisplayName = "Sammyni Spookyni",
	Rarity = "Secret",
	Price = 25000000000,
	Generation = 80000000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Plant Bros"] = {
	DisplayName = "Plant Bros",
	Rarity = "Secret",
	Price = 300000000000,
	Generation = 300000000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals.Phoenix = {
	DisplayName = "Phoenix",
	Rarity = "Secret",
	Price = 425000000000,
	Generation = 425000000,
	ObtainedFrom = {
		Source = "Haunted Fuse",
		Obtainable = true
	},
	IsEnabled = function()
		return Updates.Methods.IsEnabled("Update-10/03/2026")
	end
}
Animals["Skibidi Toilet"] = {
	DisplayName = "Skibidi Toilet",
	Rarity = "OG",
	Price = 450000000000,
	Generation = 450000000,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	},
	TriggerEvent = "Skibidi",
	SpawnVFX = "Skibidi Toilet",
	SpawnDelay = 3,
	IgnoreIndexCounter = true
}
Animals["Strawberry Elephant"] = {
	DisplayName = "Strawberry Elephant",
	Rarity = "OG",
	Price = 750000000000,
	Generation = 750000000,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	},
	TriggerEvent = "Strawberry",
	SpawnVFX = "Strawberry",
	SpawnDelay = 3.5,
	IgnoreIndexCounter = true
}
Animals["Spyder Elephant"] = {
	DisplayName = "Spyder Elephant",
	Rarity = "OG",
	Price = 1000000000000,
	Generation = 1000000000,
	HideFromIndex = true,
	IgnoreIndexCounter = true,
	TriggerEvent = "Strawberry",
	SpawnVFX = "Strawberry",
	SpawnDelay = 3.5
}
Animals["Headless Horseman"] = {
	ObtainedFrom = {
		Source = "Witch's Fuse",
		Obtainable = false
	},
	DisplayName = "Headless Horseman",
	Rarity = "OG",
	Price = 600000000000,
	Generation = 600000000
}
Animals.Meowl = {
	DisplayName = "Meowl",
	Rarity = "OG",
	Price = 650000000000,
	Generation = 600000000,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	},
	TriggerEvent = "Meowl",
	SpawnVFX = "Meowl",
	SpawnDelay = 3.5,
	IgnoreIndexCounter = true
}
Animals["John Pork"] = {
	DisplayName = "John Pork",
	Rarity = "OG",
	Price = 500000000000,
	Generation = 500000000,
	ObtainedFrom = {
		Source = "The Red Carpet",
		Obtainable = true
	},
	TriggerEventBeforeDelay = true,
	TriggerEvent = "John Pork",
	TriggerEventDelay = 0,
	SpawnVFX = "John Pork",
	SpawnDelay = 3,
	IgnoreIndexCounter = true
}
Animals["Mythic Lucky Block"] = {
	DisplayName = "Lucky Block",
	Rarity = "Mythic",
	Price = 2500000,
	Generation = 0,
	RoadWeight = 0.05,
	LuckyBlock = LuckyBlocks["Mythic Lucky Block"],
	HideFromIndex = true
}
Animals["Brainrot God Lucky Block"] = {
	DisplayName = "Lucky Block",
	Rarity = "Brainrot God",
	Price = 25000000,
	Generation = 0,
	RoadWeight = 0.001,
	LuckyBlock = LuckyBlocks["Brainrot God Lucky Block"],
	HideFromIndex = true
}
Animals["Secret Lucky Block"] = {
	DisplayName = "Lucky Block",
	Rarity = "Secret",
	Price = 750000000,
	Generation = 0,
	RoadWeight = 7e-7,
	LuckyBlock = LuckyBlocks["Secret Lucky Block"],
	HideFromIndex = true
}
Animals["Admin Lucky Block"] = {
	DisplayName = "Lucky Block",
	Rarity = "Admin",
	Price = 100000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Admin Lucky Block"],
	HideFromIndex = true
}
Animals["Taco Lucky Block"] = {
	DisplayName = "Lucky Block",
	Rarity = "Taco",
	Price = 50000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Taco Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Los Lucky Blocks"] = {
	DisplayName = "Los Lucky Blocks",
	Rarity = "Admin",
	Price = 250000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Los Lucky Blocks"],
	HideFromIndex = true
}
Animals["Spooky Lucky Block"] = {
	DisplayName = "Spooky Lucky Block",
	Rarity = "Spooky",
	Price = 350000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Spooky Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Spooky",
	SpawnDelay = 3
}
Animals["Los Taco Blocks"] = {
	DisplayName = "Los Taco Blocks",
	Rarity = "Taco",
	Price = 300000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Los Taco Blocks"],
	HideFromIndex = true,
	SpawnVFX = "Taco",
	SpawnDelay = 3
}
Animals["Festive Lucky Block"] = {
	DisplayName = "Festive Lucky Block",
	Rarity = "Festive",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Festive Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Christmas",
	SpawnDelay = 3
}
Animals["Premium Festive Lucky Block"] = {
	DisplayName = "Premium Festive Lucky Block",
	Rarity = "Festive",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Festive Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Christmas",
	SpawnDelay = 3
}
Animals["Heart Lucky Block"] = {
	DisplayName = "Heart Lucky Block",
	Rarity = "Valentines",
	Price = 350000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Heart Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Premium Heart Lucky Block"] = {
	DisplayName = "Premium Heart Lucky Block",
	Rarity = "Valentines",
	Price = 350000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Heart Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Valentines",
	SpawnDelay = 3
}
Animals["Leprechaun Lucky Block"] = {
	DisplayName = "Leprechaun Lucky Block",
	Rarity = "St Patrick's",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Leprechaun Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Premium Leprechaun Lucky Block"] = {
	DisplayName = "Premium Leprechaun Lucky Block",
	Rarity = "St Patrick's",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Leprechaun Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Clover",
	SpawnDelay = 3
}
Animals["Egg Lucky Block"] = {
	DisplayName = "Egg Lucky Block",
	Rarity = "Easter",
	Price = 500000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Egg Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Premium Egg Lucky Block"] = {
	DisplayName = "Premium Egg Lucky Block",
	Rarity = "Easter",
	Price = 500000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Egg Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Octo Lucky Block"] = {
	DisplayName = "Octo Lucky Block",
	Rarity = "Summer",
	Price = 600000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Octo Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Premium Octo Lucky Block"] = {
	DisplayName = "Premium Octo Lucky Block",
	Rarity = "Summer",
	Price = 600000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Octo Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Summer",
	SpawnDelay = 3
}
Animals["Bee Lucky Block"] = {
	DisplayName = "Bee Lucky Block",
	Rarity = "Honey",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Bee Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Bee",
	SpawnDelay = 3
}
Animals["Premium Bee Lucky Block"] = {
	DisplayName = "Premium Bee Lucky Block",
	Rarity = "Honey",
	Price = 400000000,
	Generation = 0,
	LuckyBlock = LuckyBlocks["Premium Bee Lucky Block"],
	HideFromIndex = true,
	SpawnVFX = "Bee",
	SpawnDelay = 3
}
Animals["Cavallo Virtuoso Egg"] = {
	DisplayName = "Cavallo Virtuoso Egg",
	Rarity = "Mythic",
	Price = 1250000,
	Generation = 0,
	Egg = {
		Timer = 15,
		Animals = {
			{
				Name = "Cavallo Virtuoso",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Tartaruga Cisterna Egg"] = {
	DisplayName = "Tartaruga Cisterna Egg",
	Rarity = "Brainrot God",
	Price = 22500000,
	Generation = 0,
	Egg = {
		Timer = 30,
		Animals = {
			{
				Name = "Tartaruga Cisterna",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Graipuss Medussi Egg"] = {
	DisplayName = "Graipuss Medussi Egg",
	Rarity = "Secret",
	Price = 125000000,
	Generation = 0,
	Egg = {
		Timer = 60,
		Animals = {
			{
				Name = "Graipuss Medussi",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Zebrino Pianino Egg"] = {
	DisplayName = "Zebrino Pianino Egg",
	Rarity = "Secret",
	Price = 612500000,
	Generation = 0,
	Egg = {
		Timer = 450,
		Animals = {
			{
				Name = "Zebrino Pianino",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Extinct Ballerina Egg"] = {
	DisplayName = "Extinct Ballerina Egg",
	Rarity = "Brainrot God",
	Price = 11750000,
	Generation = 0,
	Egg = {
		Timer = 20,
		Animals = {
			{
				Name = "Extinct Ballerina",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Craburger Egg"] = {
	DisplayName = "Craburger Egg",
	Rarity = "Secret",
	Price = 175000000,
	Generation = 0,
	Egg = {
		Timer = 75,
		Animals = {
			{
				Name = "Craburger",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Rexino Ramino Egg"] = {
	DisplayName = "Rexino Ramino Egg",
	Rarity = "Secret",
	Price = 312500000,
	Generation = 0,
	Egg = {
		Timer = 180,
		Animals = {
			{
				Name = "Rexino Ramino",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Qamar Camelamp Egg"] = {
	DisplayName = "Qamar Camelamp Egg",
	Rarity = "Secret",
	Price = 370000000,
	Generation = 0,
	Egg = {
		Timer = 240,
		Animals = {
			{
				Name = "Qamar Camelamp",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["La Grande Combinasion Egg"] = {
	DisplayName = "La Grande Combinasion Egg",
	Rarity = "Secret",
	Price = 500000000,
	Generation = 0,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "La Grande Combinasion",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Frio Ninja Egg"] = {
	DisplayName = "Frio Ninja Egg",
	Rarity = "Brainrot God",
	Price = 23250000,
	Generation = 0,
	Egg = {
		Timer = 30,
		Animals = {
			{
				Name = "Frio Ninja",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Ski Ski Skunki Egg"] = {
	DisplayName = "Ski Ski Skunki Egg",
	Rarity = "Secret",
	Price = 255000000,
	Generation = 0,
	Egg = {
		Timer = 120,
		Animals = {
			{
				Name = "Ski Ski Skunki",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Rockarino Rockara Egg"] = {
	DisplayName = "Rockarino Rockara Egg",
	Rarity = "Secret",
	Price = 350000000,
	Generation = 0,
	Egg = {
		Timer = 240,
		Animals = {
			{
				Name = "Rockarino Rockara",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Chill Puppy Egg"] = {
	DisplayName = "Chill Puppy Egg",
	Rarity = "Secret",
	Price = 425000000,
	Generation = 0,
	Egg = {
		Timer = 600,
		Animals = {
			{
				Name = "Chill Puppy",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Yetimatic Egg"] = {
	DisplayName = "Yetimatic Egg",
	Rarity = "Secret",
	Price = 13750000000,
	Generation = 0,
	Egg = {
		Timer = 2100,
		Animals = {
			{
				Name = "Yetimatic",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Sammyni Spyderini Egg"] = {
	DisplayName = "Sammyni Spyderini Egg",
	Rarity = "Secret",
	Price = 42500000,
	Generation = 0,
	Egg = {
		Timer = 45,
		Animals = {
			{
				Name = "Sammyni Spyderini",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Pin Pin Pengu Egg"] = {
	DisplayName = "Pin Pin Pengu Egg",
	Rarity = "Secret",
	Price = 290000000,
	Generation = 0,
	Egg = {
		Timer = 180,
		Animals = {
			{
				Name = "Pin Pin Pengu",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Chicleteira Bicicleteira Egg"] = {
	DisplayName = "Chicleteira Bicicleteira Egg",
	Rarity = "Secret",
	Price = 375000000,
	Generation = 0,
	Egg = {
		Timer = 300,
		Animals = {
			{
				Name = "Chicleteira Bicicleteira",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Sir Mangus Egg"] = {
	DisplayName = "Sir Mangus Egg",
	Rarity = "Secret",
	Price = 625000000,
	Generation = 0,
	Egg = {
		Timer = 600,
		Animals = {
			{
				Name = "Sir Mangus",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Draculino Egg"] = {
	DisplayName = "Draculino Egg",
	Rarity = "Secret",
	Price = 24250000000,
	Generation = 0,
	Egg = {
		Timer = 2700,
		Animals = {
			{
				Name = "Draculino",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Fishboard Egg"] = {
	DisplayName = "Fishboard Egg",
	Rarity = "Secret",
	Price = 107500000,
	Generation = 0,
	Egg = {
		Timer = 60,
		Animals = {
			{
				Name = "Fishboard",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Marino Submarino Egg"] = {
	DisplayName = "Marino Submarino Egg",
	Rarity = "Secret",
	Price = 387500000,
	Generation = 0,
	Egg = {
		Timer = 300,
		Animals = {
			{
				Name = "Marino Submarino",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Arcadopus Egg"] = {
	DisplayName = "Arcadopus Egg",
	Rarity = "Secret",
	Price = 450000000,
	Generation = 0,
	Egg = {
		Timer = 360,
		Animals = {
			{
				Name = "Arcadopus",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Swag Soda Egg"] = {
	DisplayName = "Swag Soda Egg",
	Rarity = "Secret",
	Price = 900000000,
	Generation = 0,
	Egg = {
		Timer = 900,
		Animals = {
			{
				Name = "Swag Soda",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Capitano Moby Egg"] = {
	DisplayName = "Capitano Moby Egg",
	Rarity = "Secret",
	Price = 62500000000,
	Generation = 0,
	Egg = {
		Timer = 3000,
		Animals = {
			{
				Name = "Capitano Moby",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Ranito Pepito Egg"] = {
	DisplayName = "Ranito Pepito Egg",
	Rarity = "Secret",
	Price = 118750000,
	Generation = 0,
	Egg = {
		Timer = 75,
		Animals = {
			{
				Name = "Ranito Pepito",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["To to to Sahur Egg"] = {
	DisplayName = "To to to Sahur Egg",
	Rarity = "Secret",
	Price = 287500000,
	Generation = 0,
	Egg = {
		Timer = 180,
		Animals = {
			{
				Name = "To to to Sahur",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Burrito Bat Egg"] = {
	DisplayName = "Burrito Bat Egg",
	Rarity = "Secret",
	Price = 600000000,
	Generation = 0,
	Egg = {
		Timer = 450,
		Animals = {
			{
				Name = "Burrito Bat",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Lavamanta Egg"] = {
	DisplayName = "Lavamanta Egg",
	Rarity = "Secret",
	Price = 1625000000,
	Generation = 0,
	Egg = {
		Timer = 1500,
		Animals = {
			{
				Name = "Lavamanta",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Cerberus Egg"] = {
	DisplayName = "Cerberus Egg",
	Rarity = "Secret",
	Price = 75000000000,
	Generation = 0,
	Egg = {
		Timer = 3300,
		Animals = {
			{
				Name = "Cerberus",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Capibaro Celestino Egg"] = {
	DisplayName = "Capibaro Celestino Egg",
	Rarity = "Secret",
	Price = 262500000,
	Generation = 0,
	Egg = {
		Timer = 90,
		Animals = {
			{
				Name = "Capibaro Celestino",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Cupid Cupid Sahur Egg"] = {
	DisplayName = "Cupid Cupid Sahur Egg",
	Rarity = "Secret",
	Price = 357500000,
	Generation = 0,
	Egg = {
		Timer = 240,
		Animals = {
			{
				Name = "Cupid Cupid Sahur",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["DJ Panda Egg"] = {
	DisplayName = "DJ Panda Egg",
	Rarity = "Secret",
	Price = 1250000000,
	Generation = 0,
	Egg = {
		Timer = 1200,
		Animals = {
			{
				Name = "DJ Panda",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Lionello Casarello Egg"] = {
	DisplayName = "Lionello Casarello Egg",
	Rarity = "Secret",
	Price = 7250000000,
	Generation = 0,
	Egg = {
		Timer = 1800,
		Animals = {
			{
				Name = "Lionello Casarello",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Dragon Cannelloni Egg"] = {
	DisplayName = "Dragon Cannelloni Egg",
	Rarity = "Secret",
	Price = 125000000000,
	Generation = 0,
	Egg = {
		Timer = 3600,
		Animals = {
			{
				Name = "Dragon Cannelloni",
				Chance = 100
			}
		}
	},
	HideFromIndex = true
}
Animals["Gold Egg"] = {
	DisplayName = "Gold Egg",
	Rarity = "Secret",
	Price = 0,
	Generation = 0,
	HideFromIndex = true,
	HideGeneration = true,
	HidePrice = true,
	HideRarity = true,
	HideOverhead = true,
	SpawnVFX = "Easter",
	SpawnDelay = 3
}
Animals["Gold Elf"] = {
	DisplayName = "Gold Elf",
	Rarity = "Secret",
	Price = 0,
	Generation = 0,
	HideFromIndex = true,
	HideOverhead = true,
	SpawnVFX = "Gold Elf",
	SpawnDelay = 3
}
Animals["Wheelchair Granny"] = {
	DisplayName = "Granny",
	Rarity = "Secret",
	TriggerEvent = "Rip My Granny",
	TriggerEventDelay = 7,
	TriggerEventOptions = { "RunIntro" },
	SpawnVFX = "Granny",
	SpawnDelay = 3,
	IgnoreIndexCounter = true,
	Price = 0,
	Generation = 0,
	HideFromIndex = true,
	HideOverhead = true
}

if not RunService:IsServer() then
	return Animals
end

local ServerStorage = game:GetService("ServerStorage")
local ServerRoadWeights = require(ServerStorage.Modules.ServerRoadWeights)

for k, serverRoadWeight in ServerRoadWeights do
	if Animals[k] then
		Animals[k].RoadWeight = serverRoadWeight
	end
end

return Animals