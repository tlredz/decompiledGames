local Server = require(game.ReplicatedStorage.Modules.Server)
local v = {
	Default = {
		[1] = 3354788137,
		[5] = 3354788546,
		[10] = 3354789124
	},
	AdultServer = {
		[1] = 3373216248,
		[5] = 3373216446,
		[10] = 3373216623
	},
	TestServer = {
		[1] = 3354899645,
		[5] = 3354907538,
		[10] = 3354907652
	}
}
local eventBanners = {
	BTS = {
		Display = "Back to School",
		Description = "Get your pen and papers ready!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(0, 144, 77), Color3.fromRGB(255, 247, 0)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://138380535781635",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Penciled Out", "Toothache Dodger", "Loner" },
			Rare = { "Craft Trimmers", "Bookworm", "Bento Capsule" },
			Royalty = { "Art", "Chalkline Lasso" },
			Unique = { "Valedictorian" },
			["???"] = {}
		}
	},
	Summer = {
		Display = "Summer Banner",
		Description = "Enjoy the summer waves and sand with these skins.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(205, 208, 17), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://108671195625053",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Beach Trimmer", "Sandbox Reprisal", "Sovereign Shells" },
			Rare = { "Beach Block", "Surfer" },
			Royalty = { "Golden Hour", "Surfboards" },
			Unique = { "Sandsmasher" },
			["???"] = { "Glider" }
		}
	},
	July = {
		Display = "4th of July Banner",
		Description = "Test your luck for some explosive and patriotic skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(0, 0, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://132529491605399",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Eagles Embrace", "Founders Hat" },
			Rare = { "Freedom Taser", "Star Spangled Gloves", "Duke of July" },
			Royalty = { "Feathered Lasso", "Spiritual Surfboard", "Mr. Firework" },
			Unique = { "Patty Dodger" },
			["???"] = {}
		}
	},
	Easter = {
		Display = "Easter Banner",
		Description = "Hunt your luck for some egg-cellent seasonal skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(253, 222, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(146, 208, 255), Color3.fromRGB(170, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://94738648795871",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Chick Ring", "Egg Zapper", "Hollow" },
			Rare = { "Choco Egg", "Peep Chain", "Marshmallow" },
			Royalty = { "Bunny Bat", "Hatchling Ball" },
			Unique = { "Egg Throne" },
			["???"] = {}
		}
	},
	["St Patricks Day"] = {
		Display = "St Patricks Day",
		Description = "Test your luck for some lucky lucky skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(213, 216, 31),
			HeaderColor = ColorSequence.new(Color3.fromRGB(29, 223, 18), Color3.fromRGB(12, 128, 22)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://78615071101368",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Coin Swirl", "Fortunes Snare", "Enchanter" },
			Rare = { "Dodge o' Gold", "Four Leaf Bat", "Enchanted" },
			Royalty = { "Pot o' Taser", "Lucky Topper" },
			Unique = { "Pot of Gold" },
			["???"] = {}
		}
	},
	Ramadan = {
		Display = "Ramadan Banner",
		Description = "Test your luck for some radiant and luminous skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(216, 216, 216),
			HeaderColor = ColorSequence.new(Color3.fromRGB(50, 97, 118), Color3.fromRGB(61, 109, 128)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://116656840782170",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Luminous Lasso", "Hanging Glow", "Gilded Moon" },
			Rare = { "Aura Aviator", "Fanous Flight", "Emerald Fanous" },
			Royalty = { "Devoted", "Radiant" },
			Unique = { "Celestial Carpet" },
			["???"] = {}
		}
	},
	Valentines = {
		Display = "Valentines Banner",
		Description = "Test your luck for some lovely and cupid skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(216, 216, 216),
			HeaderColor = ColorSequence.new(Color3.fromRGB(255, 37, 37), Color3.fromRGB(214, 105, 105)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://79701881577092",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Heartlock Chain", "Crimson Kisses" },
			Rare = { "Cupid Orbit", "Vow Keeper" },
			Royalty = {
				"Cuddle King",
				"Tower of Love Bat",
				"Thorns of Love",
				"Love Delight"
			},
			Unique = { "Heart Balloons" },
			["???"] = {}
		}
	},
	MeanGreen = {
		Display = "Mean Green Banner",
		Description = "Test your luck for some mischief and naughty skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(216, 216, 216),
			HeaderColor = ColorSequence.new(Color3.fromRGB(85, 170, 0), Color3.fromRGB(0, 170, 0)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://117343979419604",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Naughty Bat", "Grouch" },
			Rare = { "Naughty Lasso", "Santa's Elf" },
			Royalty = { "Mischief Ball", "Wreath" },
			Unique = { "Mischief Gloves", "Gift Snatcher" },
			["???"] = { "Naughty Jetpack", "Holiday Menace" }
		}
	},
	Halloween = {
		Display = "Hallows Banner",
		Description = "Test your luck for some spooky skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(216, 216, 216),
			HeaderColor = ColorSequence.new(Color3.fromRGB(150, 50, 0), Color3.fromRGB(0, 0, 0)),
			HeaderFont = "rbxassetid://12187372382",
			HeaderWeight = Enum.FontWeight.Regular,
			HeaderTextSizeMultiplier = 1.25,
			BackgroundImage = "rbxassetid://105290824803335",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Wand", "Cursed Pulse", "Hallows Pulse" },
			Rare = { "Graveyard Clippers", "Night Hallow" },
			Royalty = { "Bloodbind", "Bonebreaker" },
			Unique = { "Hell Capsule", "Eternally Cursed", "Death Note" },
			["???"] = { "Spine Soarer", "Dreadful King" }
		}
	},
	Thanksgiving = {
		Display = "Thanksgiving Banner",
		Description = "Test your luck for some delicious, stuffed treats!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 170, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(170, 85, 0), Color3.fromRGB(0, 0, 0)),
			HeaderFont = "rbxassetid://12187372382",
			HeaderWeight = Enum.FontWeight.Regular,
			HeaderTextSizeMultiplier = 1.25,
			BackgroundImage = "rbxassetid://122167710043250",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Tenderized Capsule", "PilgrimProfile", "Pumpkin Pie" },
			Rare = { "Stuffed Ball", "Pilgrim's Omen" },
			Royalty = { "Autumn Lasso", "Cornfield King", "Tenderized Bat" },
			Unique = { "Stuffed Jetpack" },
			["???"] = {}
		}
	},
	["1NewYears"] = {
		Display = "New Years Banner",
		Description = "Test your luck for the EXCLUSIVE new years skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://103533367538292",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {
				"Reinvented",
				"Fireworks Decor",
				"Resolution Lasso",
				"New Years Decor",
				"2026"
			},
			Rare = {
				"Confetti Gloves",
				"Firework Slugger",
				"Party Blower",
				"New Years Bat",
				"Disco Ball"
			},
			Royalty = { "Confetti Taser", "Firework Lasso", "New Years Jetpack" },
			Unique = { "Firework Jetpack", "Time Keeper" },
			["???"] = {}
		}
	}
}
local banners = {
	Autumn = {
		Display = "Autumn Banner",
		Description = "Test your luck for some autumn skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(152, 84, 38),
			HeaderColor = ColorSequence.new(Color3.fromRGB(152, 86, 42), Color3.fromRGB(0, 0, 0)),
			HeaderFont = "rbxassetid://12187372382",
			HeaderWeight = Enum.FontWeight.Regular,
			HeaderTextSizeMultiplier = 1.25,
			BackgroundImage = "rbxassetid://128946901256250",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Leafy Acorns" },
			Rare = { "Harvest Hands", "Chestnut Taser", "Friendly Raccoon" },
			Royalty = { "Acorn Club", "Leafy Capsule", "Harvest" },
			Unique = { "Crispy Clippers", "Cinnamon" },
			["???"] = {}
		}
	},
	Pastel = {
		Display = "Pastel Banner",
		Description = "Get some fresh kitty gear right here.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(255, 120, 255), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://75815964566145",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Purrfect Dodgeball", "Petal Chan" },
			Royalty = { "Meowster", "Fluffy Flower", "Hello Sparky" },
			Unique = { "Kitty Clippers", "Princess Kitty", "Cozy Kitty" },
			["???"] = { "Fluffy Flight Jetpack" }
		}
	},
	Hacker = {
		Display = "Hacker Banner",
		Description = "Do you want to escape the Matrix? HACKERMAN!.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(0, 148, 12),
			HeaderColor = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://113681923167292",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Glitch" },
			Royalty = { "Binary Ball", "Dominus Hackerous", "Byte Capsule" },
			Unique = {
				"Bit Breaker Taser",
				"Glitch Wires",
				"Crypto Clippers",
				"Glitched"
			},
			["???"] = { "Mr Robot" }
		}
	},
	Anime = {
		Display = "Anime Banner",
		Description = "Try your luck to become an Anime protagnoist... or villain.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(11, 96, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(208, 194, 5), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://89442087961413",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Dark Clouds" },
			Royalty = {
				"Tsunami",
				"Secret Art Lasso",
				"Pirate King",
				"Void Gloves"
			},
			Unique = { "Capsule of Hope", "Speed Hero Jetpack", "Revenger Bat" },
			["???"] = { "Saiyan" }
		}
	},
	Heavenly = {
		Display = "Heavenly Banner",
		Description = "Perhaps you can obtain one of these Heavenly Items!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(205, 208, 17), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://76631333299379",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Heavenly Capture", "Stained Glass" },
			Royalty = {
				"Heavenly Taser",
				"Doves",
				"Glassy Ball",
				"Angelic Ball"
			},
			Unique = { "Seraphim", "Angelic Bat", "Fallen Angel" },
			["???"] = { "Holy Wings" }
		}
	},
	Kitty = {
		Display = "Kitty Banner",
		Description = "Test your luck for some Cat-like creations!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(208, 114, 199), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://128002467982448",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Fluffdrive Clippers", "Pawmaster" },
			Royalty = { "Whisker Jetpack", "Kitty Paws", "Fuzzle Capture" },
			Unique = { "Kitty Ears", "Snug Bat", "Flufflord" },
			["???"] = { "Pawser Gloves" }
		}
	},
	Steampunk = {
		Display = "Steampunk Banner",
		Description = "Test your luck for some Steampunk Inventions!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(161, 126, 0), Color3.fromRGB(0, 0, 0)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://132875508172776",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Smelter Clippers", "Brasskeeper" },
			Rare = { "Cinder Lasso", "Steamworks" },
			Royalty = { "Ironclad Gloves", "Airship" },
			Unique = { "Emberjet", "Infernum Bat" },
			["???"] = { "Clockwork" }
		}
	},
	School = {
		Display = "Back to School Banner",
		Description = "Hit the books and rule the playground with some A+ Skins!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(51, 104, 89), Color3.fromRGB(30, 56, 34)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://91845466805796",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Recess Rope", "Bully", "Nerd" },
			Rare = { "Scribble Strike", "Study Nook" },
			Royalty = { "Nerdy Clippers" },
			Unique = { "Pencil Pitcher" },
			["???"] = { "Jetbag" }
		}
	},
	Toy = {
		Display = "Toy Banner",
		Description = "Test your luck for some Toy-riffic Treasures!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(147, 188, 206), Color3.fromRGB(83, 164, 203)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://138287647350734",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Lightyear Clippers", "Deputy Drip" },
			Rare = { "Nebula Catcher", "Brickmaster", "Cuddly Bear" },
			Royalty = { "One-Eyed Punch", "Chomper" },
			Unique = { "Yee-haw Bat" },
			["???"] = { "Winding Jetpack" }
		}
	},
	Superhero = {
		Display = "Superhero Banner",
		Description = "Test your luck for some Heroic Swag!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(0, 0, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(85, 170, 255), Color3.fromRGB(42, 84, 126)),
			HeaderFont = "rbxasset://fonts/families/ComicNeueAngular.json",
			HeaderWeight = Enum.FontWeight.Bold,
			BackgroundImage = "rbxassetid://88574439855369",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Wonder Lash" },
			Rare = { "The Raven" },
			Royalty = { "Villain", "Starstriker Bat", "The Shield" },
			Unique = { "Power of Friendship", "Bat Hero", "Heat Vision" },
			["???"] = { "Superhero" }
		}
	},
	Alien = {
		Display = "Alien Banner",
		Description = "Beam in for some Out-of-this-World Swag!",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 255, 255),
			HeaderColor = ColorSequence.new(Color3.fromRGB(0, 0, 112), Color3.fromRGB(36, 55, 166)),
			HeaderFont = "rbxasset://fonts/families/DenkOne.json",
			HeaderWeight = Enum.FontWeight.Regular,
			BackgroundImage = "rbxassetid://81872207565806",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "One-Eyed Clippers", "Cosmic Cow-Napping" },
			Rare = {
				"Plasma Lasso",
				"Gamma Ball",
				"Hypno-Hop",
				"Skyfire"
			},
			Royalty = { "Abducta-Bat", "Gleeble Glorp" },
			Unique = { "Tiny Traveler", "Beep-Boop", "Alien" },
			["???"] = { "Lightsword" }
		}
	},
	Emo = {
		Display = "Emo Banner",
		Description = "Dark style, your rebellion loud.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(255, 0, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(99, 0, 0)),
			HeaderFont = "rbxasset://fonts/families/DenkOne.json",
			HeaderWeight = Enum.FontWeight.Regular,
			BackgroundImage = "rbxassetid://118757933609899",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Nocturne Clippers", "Bleak Capture" },
			Royalty = {
				"Heart & Dagger",
				"Thorned Lasso",
				"Bleeder",
				"Sad Skulls"
			},
			Unique = { "Vexed Bat", "Static Taser", "Blood Sucker" },
			["???"] = {}
		}
	},
	Pharaoh = {
		Display = "Pharaoh Banner",
		Description = "An ancient power, regal and commanding.",
		Theme = {
			HeaderTextColor = Color3.fromRGB(199, 192, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(173, 168, 8)),
			HeaderFont = "rbxasset://fonts/families/DenkOne.json",
			HeaderWeight = Enum.FontWeight.Regular,
			BackgroundImage = "rbxassetid://122211695031582",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = { "Anubis" },
			Rare = { "Uneyed Brush", "Ancient Capsule", "Pharaoh" },
			Royalty = { "Septre Bat", "Ancient Lasso", "Cleopatra" },
			Unique = { "Beetle Ball", "Curse of Ra", "Scarab Circlet" },
			["???"] = {}
		}
	},
	["Guts & Bones"] = {
		Display = "Guts & Bones",
		Description = "Not a berserk reference... or is it?",
		Theme = {
			HeaderTextColor = Color3.fromRGB(125, 0, 0),
			HeaderColor = ColorSequence.new(Color3.fromRGB(109, 109, 109), Color3.fromRGB(255, 255, 255)),
			HeaderFont = "rbxasset://fonts/families/DenkOne.json",
			HeaderWeight = Enum.FontWeight.Regular,
			BackgroundImage = "rbxassetid://114273623122422",
			ImageScaleType = Enum.ScaleType.Crop
		},
		ProductIds = v.Default,
		CurrencyPrices = {},
		Items = {
			Common = {},
			Uncommon = {},
			Rare = { "Withering Rose", "Guts" },
			Royalty = { "Bones", "Flesh Lasso", "Cutup Clippers" },
			Unique = { "Redistal Bat", "Ribonic Jetpack", "Wilted Rose" },
			["???"] = { "Berserk" }
		}
	}
}
local allBanners = {}

for k, v5 in banners do
	allBanners[k] = v5
end

for k, v5 in eventBanners do
	allBanners[k] = v5
end

if Server:IsAdultServer() then
	for _, v5 in banners do
		v5.ProductIds = v.AdultServer
	end

	for _, v5 in eventBanners do
		v5.ProductIds = v.AdultServer
	end
elseif Server:IsTestServer() then
	for _, v5 in banners do
		v5.ProductIds = v.TestServer
	end

	for _, v5 in eventBanners do
		v5.ProductIds = v.TestServer
	end
end

for _, v5 in allBanners do
	v5.CreditCost = v5.CreditCost or 200
end

return {
	Banners = banners,
	EventBanners = eventBanners,
	AllBanners = allBanners
}