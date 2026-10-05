local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Currency = require(ReplicatedStorage.Modules.Currency)
local Holiday = require(ReplicatedStorage.Modules.Holiday)
local generator = Currency.Generator(1)
local Titles = {
	["Basic Titles"] = {
		Description = "Some basic titles! What do you think?",
		Icon = "http://www.roblox.com/asset/?id=81358130306896",
		IconSize = 1,
		Color = Color3.fromRGB(190, 243, 255),
		Price = generator(5),
		Items = {
			Common = {
				"Introvert",
				"Extrovert",
				"Delicate",
				"Doctor",
				"Wizard",
				"Priest",
				"Gamer",
				"Captain",
				"Hero"
			},
			Uncommon = {
				"Untameable",
				"Killer",
				"Struggler",
				"Empath",
				"Insomniac"
			},
			Rare = {
				"Blessed",
				"Thinker",
				"Chief",
				"Saint",
				"Phantom"
			},
			Royalty = { "The Shadow", "Legend", "Sunshine" },
			Unique = { "Father", "Atomic", "Don" },
			["???"] = { "Chad", "Chill", "404" }
		}
	},
	["Title Set"] = {
		Description = "A case containing a ton of different titles!",
		Icon = "http://www.roblox.com/asset/?id=13107934104",
		IconSize = 1,
		Color = Color3.fromRGB(245, 207, 135),
		Price = generator(25),
		Items = {
			Common = {
				"Gangster",
				"Scientist",
				"Explorer",
				"Sassy",
				"Troll",
				"Lonely",
				"Superstar",
				"Fugitive",
				"Artist"
			},
			Uncommon = {
				"Wild Dog",
				"Toxic",
				"Neko",
				"Sus",
				"Hacker",
				"Jester",
				"Samurai",
				"Knight",
				"Witch",
				"Outlaw",
				"Cowboy"
			},
			Rare = {
				"Prince",
				"Professor",
				"Conqueror",
				"Demon",
				"Protagonist",
				"Apex Predator",
				"Pirate",
				"Ninja",
				"Gaslighter"
			},
			Royalty = {
				"Mastermind",
				"Devil",
				"Alpha",
				"UwU",
				"Faceless",
				"Brother",
				"Reaper"
			},
			Unique = {
				"Sigma",
				"Evil",
				"King",
				"President",
				"Emperor"
			},
			["???"] = { "Godfather", "The Almighty", "His Majesty" }
		}
	},
	["Prestige Pack"] = {
		Description = "A pack containing titles for the prestigious. It may even be animated...",
		Icon = "http://www.roblox.com/asset/?id=14120628516",
		IconSize = 1,
		Color = Color3.fromRGB(207, 165, 255),
		Price = generator(100),
		Items = {
			Common = { "Paragon", "Enigma", "Catalyst" },
			Uncommon = { "Valkyrie", "Celestial", "Savant" },
			Rare = { "Guardian", "Seraph", "Oracle" },
			Royalty = { "Vanguard", "Voyager", "Rebel" },
			Unique = { "Maverick", "Juggernaut", "Astral" },
			["???"] = { "One Above All" }
		}
	},
	["Back to School"] = {
		Description = "Get your pen and papers ready!",
		Icon = "rbxassetid://81304159232800",
		IconSize = 1,
		Color = Color3.fromRGB(255, 206, 108),
		Offsale = false,
		Price = 300,
		Items = {
			Common = {
				"Transfer",
				"Newcomer",
				"Student",
				"Dropout",
				"Coach"
			},
			Uncommon = {
				"Counselor",
				"Teacher",
				"Vice Principal",
				"Therapist",
				"Janitor"
			},
			Rare = { "Principal", "Librarian" },
			Royalty = { "Nurse", "Substitute", "Nerd" },
			Unique = { "Class Clown", "Teacher's Pet" },
			["???"] = {},
			Collectible = { "Loner", "Valedictorian", "Bully" }
		}
	},
	["Easter Pack 2"] = {
		Description = "Nah. I'd win",
		Icon = "rbxassetid://16874902311",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Offsale = true,
		Price = 350,
		Limited = false,
		Items = {
			Common = {},
			Uncommon = {
				"Scrambled",
				"Hopscotch",
				"Spring Chick",
				"Florist",
				"Spring",
				"Carrotman"
			},
			Rare = {
				"Peeps",
				"Basket Case",
				"Daffodil",
				"Hare",
				"Bunny"
			},
			Royalty = {
				"Cottontail",
				"Egg Hunter",
				"Jellybean",
				"Peep"
			},
			Unique = { "Pastel Dream", "Eggspert" },
			["???"] = { "Golden Egg" },
			Collectible = {}
		}
	},
	["St. Patricks Day Pack"] = {
		Description = "We found all these titles in a pot of gold!",
		Icon = "rbxassetid://16707213876",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Price = 400,
		Offsale = true,
		Items = {
			Common = { "Celtic", "Piper" },
			Uncommon = { "Shamrock", "Clover" },
			Rare = { "Leprechaun" },
			Royalty = { "Emerald" },
			Unique = { "Pot'O Gold" },
			["???"] = { "Rainbow" }
		}
	},
	["St. Patricks Day Pack 2"] = {
		Description = "We found all these titles in a pot of gold!",
		Icon = "rbxassetid://120844364787796",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Price = 400,
		Offsale = true,
		Limited = true,
		Items = {
			Common = {
				"Lucky",
				"Irish",
				"Charmer",
				"Enchanter"
			},
			Uncommon = { "Druid", "Talisman", "Relic" },
			Rare = { "Enchanted", "Fernbound" },
			Royalty = { "Gold Keeper", "Mr. Emerald" },
			Unique = { "Cloverlord" },
			["???"] = {}
		}
	},
	["Valentines Pack"] = {
		Description = "Happy Valentines Day! You won't be lonely when you have these titles to get!",
		Icon = "rbxassetid://16280205132",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Price = 350,
		Offsale = true,
		Items = {
			Common = { "Cupid", "Sweetheart", "Love Bug" },
			Uncommon = { "Rose", "Dove" },
			Rare = { "Jewel", "Darling" },
			Royalty = { "Twin Flame", "Toast of Love" },
			Unique = { "King of Hearts" },
			["???"] = { "Mr. Valentine", "HEARTBREAKER 💔" }
		}
	},
	["Valentines Pack 2"] = {
		Description = "Happy Valentines Day! You won't be lonely when you have these titles to get!",
		Icon = "rbxassetid://135817136622754",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Price = 350,
		Offsale = true,
		Limited = true,
		Items = {
			Common = { "Snuggs", "Stoneheart" },
			Uncommon = { "First Love", "Toast of Love" },
			Rare = { "Old Flame", "Lovethorn" },
			Royalty = { "Twin Flame", "Unstable 🥀" },
			Unique = { "Crush", "Overthinker" },
			["???"] = { "Ex.", "HEARTBREAKER 💔" }
		}
	},
	["Hallows Pack 2"] = {
		Description = "Happy Halloween! Now will it be a trick... or treat...?",
		Icon = "rbxassetid://15057571518",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Offsale = true,
		Price = generator(25),
		Special = false,
		Items = {
			Common = { "Haunted", "Zombie" },
			Uncommon = { "Skeleton", "Boo" },
			Rare = { "Corpse", "Decaying" },
			Royalty = { "Specter", "Fiend" },
			Unique = { "Nightmare", "Forsaken" },
			["???"] = { "Thing", "Wednesday" },
			Collectible = {}
		}
	},
	["Santa's Pack"] = {
		Description = "Ho Ho Ho! Merry Christmas! Come grab my titles!",
		Icon = "rbxassetid://15517850512",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Offsale = true,
		Price = 300,
		Items = {
			Common = {
				"Holly",
				"Jolly",
				"Starlight",
				"Joyful",
				"Festive",
				"Merry"
			},
			Uncommon = {
				"Frosty",
				"Gingerbread",
				"Reindeer",
				"Nutcracker",
				"Mistletoe",
				"Snowflake"
			},
			Rare = {
				"Jingle-Bells",
				"North-Pole",
				"Candy Cane",
				"Elf"
			},
			Royalty = { "Jack Frost", "Yeti", "Snow Angel" },
			Unique = { "Grinch" },
			["???"] = { "Santa" },
			Collectible = {}
		}
	},
	["New Years Pack"] = {
		Description = "New Years Toys",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(255, 255, 127),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Time Keeper", "Reinvented" }
		}
	},
	["Summer Titles"] = {
		Description = "Happy Summer or whatever u call it",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Offsale = true,
		Price = 400,
		Items = {
			Common = { "Chatty", "Stinky", "Karen" },
			Uncommon = { "Narcissist" },
			Rare = { "Angel" },
			Royalty = { "Goddess" },
			Unique = { "Dangerous" },
			["???"] = {},
			Collectible = { "Skibidi Toilet", "Treasure Hunter" }
		}
	},
	["Summer Titles 2"] = {
		Description = "Happy Summer 2026!",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(255, 206, 108),
		Offsale = true,
		Price = 300,
		Items = {
			Common = { "Lifeguard", "Boiled", "Puppetmaster" },
			Uncommon = { "Sunsoaked", "Loudmouth" },
			Rare = { "Crybaby", "Hot Stuff" },
			Royalty = { "Barb" },
			Unique = { "Manipulator", "Honey" },
			["???"] = { "Skibidi Sigma" },
			Collectible = {}
		}
	},
	["Summer Titles 3"] = {
		Description = "Happy Summer 2026!",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(255, 206, 108),
		Offsale = true,
		Price = 300,
		Items = {
			Common = { "Diver", "Swimmer", "Islander" },
			Uncommon = { "Sailer", "Skipper", "Sunseeker" },
			Rare = { "Wave Rider", "Baddie", "Diva" },
			Royalty = { "Doll", "Model" },
			Unique = { "Boss", "Delulu" },
			["???"] = { "Menace" },
			Collectible = {}
		}
	},
	["Hallows Banner"] = {
		Description = "Time of Heroes",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(190, 19, 31),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Eternally Cursed", "Night Hallow", "Dreadful King" }
		}
	},
	["Valentines Banner Pack"] = {
		Description = "Time of Love",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(190, 19, 31),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Vow Keeper", "Cuddle King" }
		}
	},
	["Superhero Pack"] = {
		Description = "Time of Heroes",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(190, 19, 31),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Vigilante", "Villain", "Superhero" }
		}
	},
	["Alien Pack"] = {
		Description = "Time of Aliens",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(190, 19, 31),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Alien", "Beep-Boop" }
		}
	},
	["Toy Pack"] = {
		Description = "Time of Toys",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(85, 170, 255),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Chomper", "Brickmaster" }
		}
	},
	["Steampunk Pack"] = {
		Description = "Time of Steam",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(85, 170, 255),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Brasskeeper", "Clockwork" }
		}
	},
	["Kitty Pack"] = {
		Description = "Time of Kitties",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(85, 170, 255),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Flufflord", "Pawmaster" }
		}
	},
	["Emo Pack"] = {
		Description = "Time of Emo",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(85, 170, 255),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Blood Sucker", "Bleeder" }
		}
	},
	["Pharaoh Pack"] = {
		Description = "Time of the Pharoahs",
		Icon = "rbxassetid://17687824438",
		IconSize = 1,
		Color = Color3.fromRGB(85, 170, 255),
		Offsale = true,
		Price = generator(50),
		Items = {
			Common = {},
			Uncommon = {},
			Rare = {},
			Royalty = {},
			Unique = {},
			["???"] = {},
			Collectible = { "Blood Sucker", "Bleeder" }
		}
	},
	["Thanksgiving Pack"] = {
		Description = "Gobble, Gobble, Gobble! Turkey Season!!!",
		Icon = "rbxassetid://126019432365476",
		IconSize = 1,
		Color = Color3.fromRGB(33, 33, 33),
		Offsale = true,
		Price = 300,
		Items = {
			Common = {
				"Forager",
				"Gatherer",
				"Faster",
				"Carver"
			},
			Uncommon = { "Pilgrim" },
			Rare = { "Mender", "Baker" },
			Royalty = {
				"Gobbler",
				"Seedling",
				"Leafling",
				"Cornucopian",
				"Hearthkeeper",
				"Corn King"
			},
			Unique = { "Grateful", "Turkeyman" },
			["???"] = {},
			Collectible = {}
		}
	}
}

local function toUnixTime(value)
	if typeof(value) == "number" then
		return value
	end

	return os.time(value)
end

for _, v in Holiday:GetAllHolidays() do
	local v2 = v.TitlePack and Titles[v.TitlePack]
	local deadline = v.Deadline

	if not (v2 and deadline) then
		continue
	end

	local now = os.time()
	local offsale = true
	local start = deadline.Start

	if typeof(start) ~= "number" then
		start = os.time(start)
	end

	if not (now < start) then
		local v4 = deadline.End

		if typeof(v4) ~= "number" then
			v4 = os.time(v4)
		end

		offsale = v4 < now
	end

	v2.Offsale = offsale
end

return Titles