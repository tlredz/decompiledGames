local year = os.date("!*t").year + 1
local Server = require(game.ReplicatedStorage.Modules.Server)
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Bundles = {
	{
		Name = "Student Starter Pack",
		Display = "Student Starter Pack",
		Description = "",
		Icon = "rbxassetid://79521432229446",
		ProductId = 3709052411,
		AdultProductId = 3709051968,
		TestProductId = 3709052411,
		StarterPack = true,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 8,
				day = 20,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 9,
				day = 15,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Credits = 150,
		Emotes = { "Masterpiece", "Barbell" },
		Titles = { "Bully" },
		Backgrounds = { "LazyAfternoon" },
		Banners = { "ColorfulCorridor" },
		Items = { "Spitball Straw" },
		Avatars = { "Brainss" }
	},
	{
		Name = "Back to School Bundle",
		Display = "Back to School Bundle",
		Description = "Pick up your pen and paper!",
		Icon = "rbxassetid://137664263001615",
		ProductId = 3708928657,
		AdultProductId = 3708928755,
		TestProductId = 3708928657,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 8,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Crayon Bat",
			"Milk Carton",
			"Graffiti Bat",
			"Classroom Capture",
			"Note Taking Clippers",
			"Stapler Taser",
			"Teachers Pet Brush",
			"Paint Jetpack",
			"Pencil Pack",
			"X's and O's Crushers"
		}
	},
	{
		Name = "Decal Morph Tool",
		Display = "Decal Morph Tool",
		Description = "Transform into a Decal to spook or surprise your Neighbors!",
		Icon = "rbxassetid://101717197827817",
		ProductId = 3567130543,
		AdultProductId = 3567131136,
		TestProductId = 3567130543,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 3,
				day = 31,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 4,
				day = 14,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {},
		Items = { "2D-ify" }
	},
	{
		Name = "Christmas Bundle 2",
		Display = "Christmas Bundle",
		Description = "Ho Ho Ho, Merry Christmas!",
		Icon = "rbxassetid://82038266763724",
		ProductId = 3471689958,
		AdultProductId = 3471689841,
		TestProductId = 2673666540,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Present Jetpack",
			"Pine Bat",
			"Globe Capsule",
			"Pepperlash",
			"Peppermint Taser"
		}
	},
	{
		Name = "Valentines Bundle",
		Display = "Valentines Bundle",
		Description = "Buy this for people that you love",
		Icon = "rbxassetid://16334424822",
		ProductId = 1752553377,
		AdultProductId = 1752554444,
		TestProductId = 2673666540,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Heart Wings",
			"Eternal Blossom Wings",
			"Heart Cloud",
			"Bouquet Bat",
			"Heart Bat",
			"FlowerCord",
			"Heart Ball"
		}
	},
	{
		Name = "Valentines Bundle 2",
		Display = "Valentines Bundle 2",
		Description = "Will you be my valentine?",
		Icon = "rbxassetid://110227658704536",
		ProductId = 2975130339,
		AdultProductId = 2975094822,
		TestProductId = 2975164113,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Compassionate Clippers",
			"Rosie's Ball",
			"Blush Brush",
			"Heart Pack",
			"Valentine Jet",
			"Valwings",
			"Bouquet Bat",
			"Cupid's Capsule",
			"Bouquet"
		}
	},
	{
		Name = "Valentines Bundle 3",
		Display = "Valentines Bundle 3",
		Description = "Will you be my valentine?",
		Icon = "rbxassetid://135817136622754",
		ProductId = 3516861377,
		AdultProductId = 3516863156,
		TestProductId = 3516861377,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Love Surge",
			"Rose Sting",
			"Ribbon Snare",
			"Cupid Shock",
			"Sweet Bruiser",
			"Cupid Core",
			"Cupids Guard",
			"Throne of Hearts",
			"Love Burst",
			"Love Bear Bat"
		}
	},
	{
		Name = "St Patrick Bundle",
		Display = "St Patrick Bundle",
		Description = "Blah blah blah",
		Icon = "rbxassetid://16710084113",
		ProductId = 1773844435,
		AdultProductId = 1773844641,
		TestProductId = 2673666708,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 3,
				day = 1,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 3,
				day = 22,
				hour = 4,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Catch’O’Ball",
			"Clover Bat",
			"Leprechaun's Ball",
			"Shamrock Dryer",
			"Clippers of Chance",
			"Majestic Clover Wings",
			"Lucky Luminary",
			"Enchanting Brush",
			"SaintPatRope"
		}
	},
	{
		Name = "St Patrick Bundle 3",
		Display = "St Patrick Bundle 3",
		Description = "Make sure top wear green",
		Icon = "rbxassetid://104700680598045",
		ProductId = 3548561235,
		AdultProductId = 3548564215,
		TestProductId = 3548561235,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Pot o' Pain",
			"Clover Crusher",
			"Clover Catcher",
			"Rainbow Shocker",
			"Lepre' Capture",
			"Lucky Drums Jetpack",
			"Wings o' Luck",
			"Pot o' Punch",
			"Lepre' Punch",
			"Windy Clover Jetpack"
		}
	},
	{
		Name = "Ramadan Bundle",
		Display = "Ramadan Bundle",
		Description = "Blah blah blah",
		Icon = "rbxassetid://95165992084971",
		ProductId = 3547625369,
		AdultProductId = 3547625380,
		TestProductId = 2673666708,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 3,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 3,
				day = 12,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Radiant Star",
			"Crescent Lasso",
			"Lunar Thruster",
			"Radiant Rise",
			"Midnight Crescent"
		}
	},
	{
		Name = "St Patrick Bundle 2",
		Display = "St Patrick Bundle 2",
		Description = "Make sure to wear green!!!",
		Icon = "rbxassetid://89011615011644",
		ProductId = 3241355658,
		AdultProductId = 3241355898,
		TestProductId = 3241356147,
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 3,
				day = 15,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 3,
				day = 24,
				hour = 4,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Cloverburst Wings",
			"Lucky Lift",
			"Fortune Capsule",
			"Shamrock Ball",
			"Charm Bat",
			"Leprechaun's Clippers"
		},
		Items = { "Pot'O'Gold" }
	},
	{
		Name = "Easter Bundle",
		Display = "Easter Bundle",
		Description = "Eggs n dat",
		Icon = "rbxassetid://16885900599",
		ProductId = 1786815220,
		AdultProductId = 1786814906,
		TestProductId = 2673666834,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 3,
				day = 26,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 4,
				day = 12,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Bat of Bountiful Blasts",
			"Captivating Capsule of Confinement",
			"Egg of Elusive Evasion",
			"Breezy Blaster of Brilliance",
			"Eggshell Wings",
			"Hare Hopper",
			"Lapin Lasso",
			"Carrot Powered Clippers",
			"Bunny Brush"
		}
	},
	{
		Name = "Easter Bundle 2",
		Display = "Easter Bundle 2",
		Description = "Who's ready for an easter egg hunt!?!?",
		Icon = "rbxassetid://91115003354085",
		ProductId = 3259236520,
		AdultProductId = 3259236775,
		TestProductId = 3259236158,
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 4,
				day = 10,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 5,
				day = 11,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Eggstriker",
			"The Egg Trapper",
			"Hard Candy Wings",
			"Egg Euphoria",
			"EggPack",
			"Bunny Blower",
			"Easter's Lost Trimmers",
			"Easter Brush"
		}
	},
	{
		Name = "Easter Bundle 3",
		Display = "Easter Bundle 3",
		Description = "Some pretty AWESOME EASTER THEMED SKINS",
		Icon = "rbxassetid://91115003354085",
		ProductId = 3566872670,
		AdultProductId = 3566871509,
		TestProductId = 3566872670,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 3,
				day = 31,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 4,
				day = 14,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Yolk Bat",
			"Bunny Clippers",
			"Easter Zapper",
			"Easter Egg Brush",
			"Egg Snatcher",
			"Bunny Ball",
			"Egg Meadow Capture",
			"Egg Basket Jetpack",
			"Bunny Gloves"
		}
	},
	{
		Name = "Summer Bundle",
		Display = "Summer Bundle",
		Description = "Cool skins n dat for the sunny hot summer n dat!",
		Icon = "rbxassetid://17663319833",
		ProductId = 1838053200,
		AdultProductId = 1838053311,
		TestProductId = 2673666940,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 5,
				day = 31,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 8,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Duck",
			"Abyssal Bat",
			"Sunstrike Bat",
			"Coconut",
			"Lego Blocks",
			"Moth Wings",
			"Divine Wings",
			"Candy Frisbee",
			"Mint Frisbee",
			"Cartoony Paintball Gun"
		}
	},
	{
		Name = "Summer Bundle 2",
		Display = "Summer Bundle 2",
		Description = "Summers almost over... heres our final skins!",
		Icon = "rbxassetid://18888706914",
		ProductId = 1892923764,
		AdultProductId = 1892924014,
		TestProductId = 2673667054,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 5,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Monarch Butterfly Wings",
			"Tinkerbell Wings",
			"Frostbite Bat",
			"Fiery Frisbee",
			"Rainbow Pack",
			"Turtle Shell",
			"Dog Bone",
			"Soap"
		}
	},
	{
		Name = "Summer Bundle 3",
		Display = "Summer Bundle 3",
		Description = "Summers almost over once again... heres our final skins!",
		Icon = "rbxassetid://74445639906200",
		ProductId = 3331997180,
		AdultProductId = 3333610830,
		TestProductId = 3331925533,
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Jetski Jetpack",
			"Worm Lasso",
			"Carbo Clippers",
			"Melted Coco",
			"Wafer Vanilla",
			"Red Bellflower",
			"Sand Potion",
			"Sprinkill Trap",
			"Melon Capsule",
			"Heartbit Capsule",
			"Breezcap Jetpack",
			"Pizza Jetpack",
			"Cornball Bat",
			"Downpour Bat",
			"Bandaged Gloves",
			"Cheetah Gloves"
		}
	},
	{
		Name = "Summer Bundle 4",
		Display = "Summer Bundle 4",
		Description = "Cool skins for the sunny hot summer and splashes!",
		Icon = "rbxassetid://91429833250391",
		ProductId = 3610230881,
		AdultProductId = 3610231100,
		TestProductId = 3610230881,
		LimitedTime = {
			Start = os.time({
				year = 2026,
				month = 7,
				day = 16,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Ice Cream Bat",
			"Sunbathe Ball",
			"Beach Day Clippers",
			"Banana Shocker",
			"Seaside Capture",
			"Sundial Capture",
			"Popsicle Pack",
			"Coconut Dusters",
			"Deep Sea Jetpack",
			"Trinket Lasso"
		}
	},
	{
		Name = "Halloween Bundle",
		Display = "Halloween Bundle",
		Description = "Spooky season is here!",
		Icon = "rbxassetid://90063597832289",
		ProductId = 2164638506,
		AdultProductId = 2164621386,
		TestProductId = 2673667253,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 10,
				day = 10,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 11,
				day = 7,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Ripper Wings",
			"Fear Flight",
			"Soul Trap",
			"Coffin Buzzer",
			"Spiderweb Lasso",
			"Evil Broom",
			"Franken Bat"
		}
	},
	{
		Name = "Halloween Bundle 2",
		Display = "Halloween Bundle 2",
		Description = "Spooky season is here once again!",
		Icon = "rbxassetid://138951004732408",
		ProductId = 3420965904,
		AdultProductId = 3420966407,
		TestProductId = 3420964489,
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 10,
				day = 3,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 11,
				day = 7,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"Butcher Wings",
			"Jack-O-Pack",
			"Cursed Slugger",
			"Eternal Lasso",
			"Boney Clippers",
			"Jack-O-Clippers"
		}
	},
	{
		Name = "8-Bit Bundle",
		Display = "8-Bit Bundle",
		Description = "Just like the old times!",
		Icon = "rbxassetid://15373712621",
		ProductId = 2660190712,
		AdultProductId = 2660190856,
		TestProductId = 2673667366,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 11,
				day = 10,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = year,
				month = 12,
				day = 7,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Skins = {
			"8-Bit Sapphire Wings",
			"8-Bit Growth Potion",
			"8-Bit Baseball Bat",
			"8-Bit Boogie Time",
			"8-Bit Dodgeball",
			"8-Bit Paper Bag",
			"8-Bit Shocker",
			"8-Bit Capsule",
			"8-Bit Gloves",
			"8-Bit Zapper",
			"8-Bit Decoy"
		}
	},
	{
		Name = "4th of July Bundle",
		Display = "4th of July Bundle",
		Description = "Happy 4th of July!",
		Icon = "rbxassetid://83374860996672",
		ProductId = 3607980333,
		AdultProductId = 3607980334,
		TestProductId = 3607980333,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Skins = {
			"Spiritual Soarer",
			"American Lasso",
			"Star Spangled Taser",
			"Liberated Ball",
			"Independence Brush",
			"Independent Clippers",
			"Heroic Gloves",
			"Freedom Bat",
			"Freedom Zapper",
			"Eagle Wings"
		}
	},
	{
		Name = "Christmas Bundle",
		Display = "Christmas Bundle",
		Description = "Ho Ho Ho, Merry Christmas!!!",
		Icon = "rbxassetid://78821634517925",
		ProductId = 2670708077,
		AdultProductId = 2670707477,
		TestProductId = 2673667495,
		LimitedTime = {
			Start = os.time({
				year = year,
				month = 12,
				day = 5,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = 1736049600
		},
		Skins = {
			"Christmas Lights Lasso",
			"Santa's Styler",
			"Gift Capsule",
			"Elf Pack",
			"Santa's Sleigh"
		},
		Items = { "Krampus Pitchfork" }
	}
}

local function appendContents(list, items, p: string)
	if not items then
		return
	end

	for _, item in items do
		table.insert(list, (`{item} ({p})`))
	end
end

for _, v2 in pairs(Bundles) do
	if not v2.StarterPack then
		continue
	end

	local v3 = {}

	if v2.Credits then
		table.insert(v3, (`{v2.Credits} Credits`))
	end

	local skins = v2.Skins

	if skins then
		for _, skin in skins do
			table.insert(v3, (`{skin} (Skin)`))
		end
	end

	local items = v2.Items

	if items then
		for _, item in items do
			table.insert(v3, (`{item} (Tool)`))
		end
	end

	local emotes = v2.Emotes

	if emotes then
		for _, emote in emotes do
			table.insert(v3, (`{emote} (Emote)`))
		end
	end

	local titles = v2.Titles

	if titles then
		for _, title in titles do
			table.insert(v3, (`{title} (Title)`))
		end
	end

	local backgrounds = v2.Backgrounds

	if backgrounds then
		for _, background in backgrounds do
			table.insert(v3, (`{background} (Profile Background)`))
		end
	end

	local banners = v2.Banners

	if banners then
		for _, banner in banners do
			table.insert(v3, (`{banner} (Profile Banner)`))
		end
	end

	local avatars = v2.Avatars

	if avatars then
		for _, avatar in avatars do
			table.insert(v3, (`{avatar} (Avatar Decoration)`))
		end
	end

	v2.Description = `Includes: {table.concat(v3, ", ")}!`
end

for _, v2 in pairs(Bundles) do
	if Server:IsAdultServer() then
		v2.ProductId = v2.AdultProductId
	end

	if Server:IsTestServer() and v2.TestProductId then
		v2.ProductId = v2.TestProductId
	end
end

if RunService:IsClient() then
	task.spawn(function()
		for _, v2 in pairs(Bundles) do
			local v3 = v2
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(v3.ProductId, Enum.InfoType.Product)
			end)

			if success then
				v2.Price = result.PriceInRobux
			else
				v2.Price = "???"
			end

			v2.Ready = true
		end
	end)
end

return Bundles