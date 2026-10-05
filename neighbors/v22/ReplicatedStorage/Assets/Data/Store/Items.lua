local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Type = require(script.Parent.Parent.Type)
game:GetService("RunService")
local Currency = require(ReplicatedStorage.Modules.Currency)
local Holiday = require(ReplicatedStorage.Modules.Holiday)
_G.TempIcon = "rbxassetid://134070335226937"
local generator = Currency.Generator(1)
local Items = {
	["Spitball Straw"] = {
		Display = "Spitball Straw",
		Price = 400,
		Description = "Don't get caught",
		Icon = "rbxassetid://77888676613731",
		RoundIcon = "rbxassetid://122131735231987",
		NewTool = os.time({
			year = 2026,
			month = 8,
			day = 18,
			hour = 0,
			min = 0,
			sec = 0
		}),
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Coin Flip"] = {
		Display = "Coin Flip",
		Price = 750,
		Description = "Heads or tails...? Heads gets you 25 seconds of immunity & movement boosts, and tails gets you... Nothing.",
		Icon = "rbxassetid://131001994116360",
		RoundIcon = "rbxassetid://104134568413196",
		HolidayItem = true,
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Bomb = {
		Display = "Bomb",
		Price = 1650,
		Description = "KABOOOOOOOOOOOOOOOM!",
		Icon = "rbxassetid://109772647239322",
		RoundIcon = "rbxassetid://112537354575226",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Tornado Jar"] = {
		Display = "Tornado Jar",
		Price = generator(1500),
		Description = "Try not to get caught in it yourself!",
		Icon = "rbxassetid://81440068213826",
		RoundIcon = "rbxassetid://114502712508781",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Heart Snatcher"] = {
		Display = "Heart Snatcher",
		Price = 1000,
		Description = "Take their heart in your hands",
		Icon = "rbxassetid://116980629442640",
		RoundIcon = "rbxassetid://89412221548354",
		Offsale = false,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["The Force"] = {
		Display = "The Force",
		Price = generator(20),
		Description = "Come to the darkside",
		Icon = "rbxassetid://140321498402624",
		RoundIcon = "rbxassetid://113670615845201",
		Offsale = true,
		Group = Type.Item.Props,
		Toxic = false
	},
	["Snowball Launcher"] = {
		Display = "Snowball Launcher",
		Offsale = false,
		Price = 1e999,
		Description = "No more cold hands, it's time to change to the big guns.",
		Icon = "rbxassetid://110400509099792",
		RoundIcon = "rbxassetid://15556108925",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		SpecialShop = true,
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Donation Tool"] = {
		Display = "Donation Tool",
		Price = 250,
		Description = "Receive donations from other players!",
		Icon = "rbxassetid://89586223102941",
		RoundIcon = "rbxassetid://122243492423791",
		Group = Type.Item.Utility
	},
	["Chicken Toy"] = {
		Display = "Chicken Toy",
		Price = 350,
		Description = "Wack people with the wacky chicken!",
		Icon = "rbxassetid://117466184844332",
		RoundIcon = "rbxassetid://93035312352350",
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 11,
				day = 26,
				hour = 0,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2025,
				month = 12,
				day = 5,
				hour = 0,
				min = 0,
				sec = 0
			})
		},
		Group = Type.Item.Utility
	},
	OldLasso = {
		Display = "OldLasso",
		Price = 1e999,
		Offsale = true,
		Description = "This rope isn't gonna tie itself... With this, you can drag players and tie them to any wall or ceiling!",
		Icon = "rbxassetid://13261332482",
		Group = Type.Item.Toxic,
		Toxic = true,
		QuestItem = true
	},
	["Bee Swarm"] = {
		Display = "Bee Swarm",
		Price = 275,
		Description = "Annoying, noisy, and a little stingy.",
		Icon = "rbxassetid://111627361739898",
		RoundIcon = "rbxassetid://106342081853348",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Echo Fork"] = {
		Display = "Echo Fork",
		Price = 550,
		Description = "High frequencies, echoey, and annoying.",
		Icon = "rbxassetid://108637313650734",
		RoundIcon = "rbxassetid://118683119610693",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Egg Staff"] = {
		Display = "Egg Staff",
		Price = 0,
		Description = "A special item to remember the Egg Hunt!",
		Icon = "rbxassetid://107653229525033",
		RoundIcon = "rbxassetid://126530238988976",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Toxic,
		Toxic = false
	},
	["Egg Basket"] = {
		Display = "Egg Basket",
		Price = 0,
		Description = "A special item to remember the Egg Hunt!",
		Icon = "rbxassetid://100095627423790",
		RoundIcon = "rbxassetid://99987138645707",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Props,
		Toxic = false
	},
	Rose = {
		Display = "Rose",
		Price = generator(20),
		Description = "A flower for... I don't know, do you know somebody?",
		Icon = "rbxassetid://140321498402624",
		RoundIcon = "rbxassetid://113670615845201",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Props,
		Toxic = false
	},
	["Full Counter"] = {
		Display = "Full Counter",
		Price = generator(1000),
		Description = "Make yourself invincible.",
		Icon = "rbxassetid://127304582054848",
		RoundIcon = "rbxassetid://137277840717869",
		Group = Type.Item.Utility,
		Toxic = true,
		Skins = "Full Counter Case"
	},
	Key = {
		Display = "Key",
		Price = generator(75),
		Description = "Trap your friends in rooms, ha!",
		Icon = "rbxassetid://129555308253960",
		RoundIcon = "rbxassetid://118000487044603",
		Group = Type.Item.Misc,
		Toxic = false
	},
	Pillow = {
		Display = "Pillow",
		Price = generator(80),
		Description = "PILLOWW FIGHTTT!!!!",
		Icon = "rbxassetid://85410796412218",
		RoundIcon = "rbxassetid://74528634355878",
		RectSize = Vector2.new(190, 185),
		Group = Type.Item.Toxic,
		Toxic = false
	},
	["Cupid Bow"] = {
		Display = "Cupid Bow",
		Price = 725,
		Description = "I've seen hearts turn to stone when struck with this. Mine never went back to normal though.",
		Icon = "rbxassetid://113651898691030",
		RoundIcon = "rbxassetid://97712621169757",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Paintball Gun"] = {
		Display = "Paintball Gun",
		Price = generator(135),
		Description = "You NEED an automatic way to hit your enemies...",
		Icon = "rbxassetid://125773474680266",
		RoundIcon = "rbxassetid://76542844250471",
		Offsale = false,
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Paintball Gun Case"
	},
	["Invisibility Potion"] = {
		Display = "Invisibility Potion",
		Description = "Gulp! Now you're invisible!",
		Icon = "rbxassetid://100342222833026",
		RoundIcon = "rbxassetid://139941938939926",
		Price = generator(325),
		Group = Type.Item.Misc,
		Toxic = false
	},
	["Krampus Pitchfork"] = {
		Display = "Krampus Pitchfork",
		Icon = "rbxassetid://92639565027072",
		RoundIcon = "rbxassetid://88477215356031",
		Price = 0,
		Description = "",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Offsale = false,
		Group = Type.Item.Carry,
		Toxic = true
	},
	GingerbreadMan = {
		Display = "Gingerbread Morph",
		Price = 1e999,
		Description = [[
Use on other people to temporarily turn them into a Gingerbread man!

You can't catch me, I'm the Gingerbread man!]],
		Icon = "rbxassetid://75684753074479",
		RoundIcon = "rbxassetid://100301135222476",
		Tags = { "christmas" },
		SpecialShop = true,
		OffSale = false,
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Freeze Ray"] = {
		Display = "Freeze Ray",
		Price = 1e999,
		Description = "Is it just me, or is it chilly in here?",
		Icon = "rbxassetid://139044175856480",
		RoundIcon = "rbxassetid://81958513115691",
		Tags = { "christmas" },
		SpecialShop = true,
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Candy Bucket"] = {
		Display = "Candy Bucket",
		Price = 1,
		Description = "Useful for holding candy.",
		Icon = "rbxassetid://135243612361804",
		RoundIcon = "rbxassetid://107578097641672",
		Tags = { "halloween" },
		SpecialShop = true,
		Group = Type.Item.Props,
		Toxic = false,
		LimitedTime = {
			Start = os.time({
				year = 2024,
				month = 10,
				day = 1,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2024,
				month = 11,
				day = 7,
				hour = 4,
				min = 0,
				sec = 0
			})
		}
	},
	["Pot'O'Gold"] = {
		Display = "Pot'O'Gold",
		Price = 25,
		Description = "Toss some gold around!",
		Icon = "rbxassetid://140003487353045",
		RoundIcon = "rbxassetid://138541386747867",
		RectSize = Vector2.one * 185,
		Group = Type.Item.Props,
		Toxic = false,
		LimitedTime = {
			Start = 1,
			End = 1
		}
	},
	Flashlight = {
		Display = "Flashlight",
		Price = 5,
		Description = "Illuminates the darkness, revealing the secrets beneath.",
		Icon = "rbxassetid://100635519434895",
		RoundIcon = "rbxassetid://78826960237076",
		Tags = { "halloween" },
		SpecialShop = true,
		Group = Type.Item.Utility,
		Toxic = false,
		LimitedTime = {
			Start = os.time({
				year = 2024,
				month = 10,
				day = 1,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2024,
				month = 11,
				day = 7,
				hour = 4,
				min = 0,
				sec = 0
			})
		}
	},
	BeamOfLight = {
		Display = "BeamOfLight",
		Price = 1e999,
		Description = "Illuminates the darkness, revealing the secrets beneath.",
		Icon = "rbxassetid://15106715265",
		Tags = { "halloween" },
		QuestItem = false,
		Group = Type.Item.Props,
		Toxic = false,
		Offsale = true
	},
	LaserPointer = {
		Display = "Laser Pointer",
		Price = 1e999,
		Description = "For cats.",
		Icon = "rbxassetid://15106715265",
		QuestItem = false,
		Group = Type.Item.Utility,
		Toxic = false,
		Offsale = true
	},
	["Death Note"] = {
		Display = "Death Note",
		Price = 1e999,
		Description = "IT'S MY PERFECT VICTORY",
		Icon = "rbxassetid://105263752921639",
		RoundIcon = "rbxassetid://97917549153039",
		Group = Type.Item.Toxic,
		Toxic = true,
		BannerItem = true
	},
	["Heat Vision"] = {
		Display = "Heat Vision",
		Price = 1e999,
		Description = "Yummerz",
		Icon = "rbxassetid://132146902048542",
		Group = Type.Item.Toxic,
		Toxic = true,
		BannerItem = true
	},
	Teddy = {
		Display = "Teddy Bear",
		Price = generator(5),
		Description = "At least teddy won't skip me",
		Icon = "rbxassetid://136882161054948",
		RoundIcon = "rbxassetid://100183354118301",
		Group = Type.Item.Props,
		Toxic = false
	},
	Megaphone = {
		Display = "Megaphone",
		Price = generator(260),
		Description = "Make sure EVERYONE hears your terrible opinions.",
		Icon = "rbxassetid://86425286887628",
		RoundIcon = "rbxassetid://110043382477754",
		VoiceChatTool = true,
		Group = Type.Item.Utility,
		Toxic = false
	},
	HeliumBalloon = {
		Display = "Helium Balloon",
		Price = generator(40),
		Description = "Become your inner chipmunk. (Makes your voice higher)",
		Icon = "rbxassetid://80456168646501",
		RoundIcon = "rbxassetid://16442573218",
		VoiceChatTool = true,
		Group = Type.Item.Utility,
		Toxic = false
	},
	SulfurHexafluorideBalloon = {
		Display = "Sulfur Hexafluoride Balloon",
		Price = generator(40),
		Description = "Become someone's father. (Makes your voice deeper)",
		Icon = "rbxassetid://95564085253920",
		RoundIcon = "rbxassetid://16442573601",
		VoiceChatTool = true,
		Group = Type.Item.Utility,
		Toxic = false
	},
	["Bloxy Cola"] = {
		Display = "Bloxy Cola",
		Price = generator(5),
		Description = "Mmmmm... Bloxy cola...",
		Icon = "rbxassetid://136016267431655",
		RoundIcon = "rbxassetid://127569417776484",
		Group = Type.Item.Props,
		Toxic = false,
		Skins = "Bloxy Cola Case"
	},
	Guitar = {
		Display = "Guitar",
		Price = generator(70),
		Description = "Hit 'em with smooth music.",
		Icon = "rbxassetid://105698143668080",
		RoundIcon = "rbxassetid://81859428476765",
		CustomSkinName = "Instrument",
		Group = Type.Item.Props,
		Toxic = false,
		Skins = "Guitar Case"
	},
	Cheezburger = {
		Display = "Cheezburger",
		Price = generator(15),
		Description = "Yes, you can have one!",
		Icon = "rbxassetid://132601268732572",
		RoundIcon = "rbxassetid://91058699210086",
		Group = Type.Item.Props,
		Toxic = false
	},
	Popcorn = {
		Display = "Popcorn",
		Price = generator(15),
		Description = "Butter filled perfection!",
		Icon = "rbxassetid://102082853369203",
		RoundIcon = "rbxassetid://89407809839067",
		Group = Type.Item.Props,
		Toxic = false
	},
	Clipboard = {
		Display = "Clipboard",
		Price = generator(25),
		Description = "Let me jot that down...",
		Icon = "rbxassetid://73263284376363",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Protection Charm"] = {
		Display = "Shield",
		Price = 10000,
		Description = "Protect yourself from ALL TOOLS!!!",
		Icon = "rbxassetid://134070335226937",
		Offsale = true,
		Group = Type.Item.Utility,
		Toxic = false
	},
	Airhorn = {
		Display = "Airhorn",
		Price = generator(120),
		Description = "GET LOUD IN HERE...",
		Icon = "rbxassetid://115156236888046",
		RoundIcon = "rbxassetid://132238222078513",
		RectSize = Vector2.new(175, 175),
		Group = Type.Item.Utility,
		Toxic = false
	},
	Shove = {
		Display = "Shove Tool",
		Price = generator(25),
		Description = "Shove the target down on the floor. Winner winner!",
		Icon = "rbxassetid://89617673778434",
		RoundIcon = "rbxassetid://137609976966531",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Growth Potion"] = {
		Display = "Growth Potion",
		Price = generator(300),
		Description = "Uhhh.. *grows*",
		Icon = "rbxassetid://109691026617030",
		RoundIcon = "rbxassetid://102908099448835",
		Group = Type.Item.Misc,
		Toxic = false,
		Skins = "Growth Potion Case"
	},
	Scissors = {
		Display = "Scissors",
		Price = generator(550),
		Description = "*Snip* *Snip*... Press Y to inspect when equipped!",
		Icon = "rbxassetid://106692547634226",
		RoundIcon = "rbxassetid://138293404325220",
		Group = Type.Item.Misc,
		Toxic = false
	},
	["Water Gun"] = {
		Display = "Water Gun",
		Price = 1e999,
		Description = "Walk down em' down with loads of water.",
		Icon = "rbxassetid://101725602650863",
		RoundIcon = "rbxassetid://118977839660603",
		SpecialShop = true,
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Offsale = false,
		Group = Type.Item.Props,
		Toxic = false
	},
	["Pet Tool"] = {
		Display = "Pet Tool",
		Price = generator(500),
		Description = "MEOW!",
		Icon = "rbxassetid://135838869035896",
		RoundIcon = "rbxassetid://79623656839739",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Gravity Coil"] = {
		Display = "Gravity Coil",
		Price = generator(35),
		Original = 400,
		Description = "Soar the skies!",
		Icon = "rbxassetid://75900520545546",
		RoundIcon = "rbxassetid://93565711133809",
		Group = Type.Item.Utility,
		Toxic = false
	},
	["Speed Coil"] = {
		Display = "Speed Coil",
		Price = generator(45),
		Description = "VROOM VROOM! GOTTA GO FAST!",
		Icon = "rbxassetid://85182208710578",
		RoundIcon = "rbxassetid://74110235817782",
		Group = Type.Item.Utility,
		Toxic = false
	},
	["Wooden Sign"] = {
		Display = "Wooden Sign",
		Price = generator(30),
		Description = "It's a sign! You can write whatever you want on it.",
		Icon = "rbxassetid://100457769574742",
		RoundIcon = "rbxassetid://91473849369456",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Turkey Leg"] = {
		Display = "Turkey Leg",
		Price = generator(5),
		Description = "Turkey.. turkey!!",
		Icon = "rbxassetid://86409042236355",
		RoundIcon = "rbxassetid://88809455139340",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Spray Paint"] = {
		Display = "Spray Paint",
		Price = generator(200),
		Original = 800,
		Description = "Draw anything you want! Comes in a few colors too. Pretty cool!",
		Icon = "rbxassetid://128489036015606",
		RoundIcon = "rbxassetid://86391008098182",
		Group = Type.Item.Utility,
		Toxic = false
	},
	["Magic 8 Ball"] = {
		Display = "Magic 8 Ball",
		Price = generator(30),
		Original = 250,
		Description = "The Magic 8 Ball knows the answer to everything... Ask it and you shall receive.",
		Icon = "rbxassetid://137683194380511",
		RoundIcon = "rbxassetid://125298478294522",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Ice Cream"] = {
		Display = "Ice Cream",
		Price = generator(10),
		Description = "Yum! We all scream for ice cream!",
		Icon = "rbxassetid://88838017522101",
		RoundIcon = "rbxassetid://102837147065186",
		Group = Type.Item.Props,
		Toxic = false,
		Skins = "Ice Cream Case"
	},
	Slap = {
		Display = "Slap Tool",
		Price = generator(90),
		Description = "Huh? I dare you to say it again.",
		Icon = "rbxassetid://113451408608917",
		RoundIcon = "rbxassetid://114744478997799",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Spit = {
		Display = "Spit Tool",
		Price = generator(70),
		Description = "SCRAH! SCRAH!",
		Icon = "rbxassetid://84729402650515",
		RoundIcon = "rbxassetid://105496439766461",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Tomato = {
		Display = "Tomato Tool",
		Price = generator(20),
		Description = "Throw tomatoes at those who SUCK!",
		Icon = "rbxassetid://93397087238435",
		RoundIcon = "rbxassetid://78425877512320",
		Skins = "Tomato Case",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Water Balloon"] = {
		Display = "Water Balloon",
		Price = 100,
		Description = "Throw water balloons at those who SUCK!",
		Icon = "rbxassetid://92547472237679",
		RoundIcon = "rbxassetid://122680672824084",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Pie = {
		Display = "Pie",
		Price = generator(35),
		Description = "Like the Tomato, but with a Pie! What a mess!",
		Icon = "rbxassetid://75459391841444",
		RoundIcon = "rbxassetid://88118000996103",
		LimitedTime = {
			Start = os.time({
				year = 2024,
				month = 11,
				day = 24,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2024,
				month = 11,
				day = 30,
				hour = 4,
				min = 0,
				sec = 0
			})
		},
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Decoy Tool"] = {
		Display = "Decoy Tool",
		Price = generator(250),
		Description = "Transform into whoever you click!",
		Icon = "rbxassetid://85479482950460",
		RoundIcon = "rbxassetid://80627111679025",
		Group = Type.Item.Utility,
		Toxic = false,
		Skins = "Decoy Tool Case"
	},
	Kick = {
		Display = "Kick Tool",
		Price = generator(125),
		Description = "A stronger version of Shove. Push the target A LOT further!",
		Icon = "rbxassetid://136648156908760",
		RoundIcon = "rbxassetid://135409786212687",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Baseball Bat"] = {
		Display = "Baseball Bat",
		Price = generator(300),
		Description = "Hit a home run on your friends to send them FLYING!",
		Icon = "rbxassetid://132435151406562",
		RoundIcon = "rbxassetid://116847992875143",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Baseball Bat Case"
	},
	Camera = {
		Display = "Camera",
		Price = generator(35),
		Description = "Caught in 4k!",
		Icon = "rbxassetid://118913974408337",
		RoundIcon = "rbxassetid://86359792461214",
		Group = Type.Item.Props,
		Toxic = false,
		Skins = "Camera Case"
	},
	Fireworks = {
		Display = "Fireworks",
		Price = 1000,
		Description = "Celebrate special occasions with these fireworks!",
		Icon = "rbxassetid://13941356630",
		LimitedTime = {
			Start = 1,
			End = 1
		},
		Group = Type.Item.Misc,
		Toxic = false
	},
	Clippers = {
		Display = "Hair Clippers",
		Price = generator(150),
		Description = "60% of a clean fade, 40% of a botched cut. Are you a good barber? (Hair regrows back to normal after a few minutes)",
		Icon = "rbxassetid://92215937362507",
		RoundIcon = "rbxassetid://91687467667867",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Clippers Case"
	},
	["Hair Snatch"] = {
		Display = "Hair Snatcher",
		Price = generator(100),
		Description = "Snatch the hair right off someone else's head!",
		Icon = "rbxassetid://121706481814917",
		RoundIcon = "rbxassetid://88104557378895",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Blackout = {
		Display = "Blackout",
		Price = generator(250),
		Description = "Turn off the lights and let the clock tick.",
		Icon = "rbxassetid://100637552605152",
		RoundIcon = "rbxassetid://131861724794697",
		Offsale = false,
		Group = Type.Item.Toxic,
		Toxic = false
	},
	Puppeteer = {
		Display = "Puppeteer",
		Price = generator(1350),
		Description = "Wrap your strings around another player and control their movements.",
		Icon = "rbxassetid://114557842911910",
		RoundIcon = "rbxassetid://110985613875341",
		Group = Type.Item.Toxic,
		Toxic = false
	},
	["Bubble Blower"] = {
		Display = "Bubble Blower",
		Price = generator(240),
		Description = "Trap your target inside a bubble.",
		Icon = "rbxassetid://76666025756874",
		RoundIcon = "rbxassetid://102140044433897",
		Group = Type.Item.Toxic,
		Toxic = false
	},
	Makeup = {
		Display = "Makeup",
		Price = generator(180),
		Description = "Give your friends a glamorous makeover with a beatiful hairstyle and flawless makeup!",
		Icon = "rbxassetid://84243075257410",
		RoundIcon = "rbxassetid://137563997285234",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	Scythe = {
		Display = "Scythe",
		Price = 150,
		Description = "Become the reaper of heads!",
		Icon = "rbxassetid://114185874176237",
		RoundIcon = "rbxassetid://88750103301040",
		Tags = { "halloween" },
		Group = Type.Item.Toxic,
		Toxic = true,
		SpecialShop = false,
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
		}
	},
	Skull = {
		Display = "Mr. Spooky",
		Price = 99,
		Description = "What is bro yappin bout?",
		Icon = "rbxassetid://95351280659756",
		RoundIcon = "rbxassetid://125476631186155",
		Tags = { "halloween" },
		Group = Type.Item.Toxic,
		Toxic = true,
		SpecialShop = true,
		LimitedTime = {
			Start = os.time({
				year = 2024,
				month = 10,
				day = 1,
				hour = 4,
				min = 0,
				sec = 0
			}),
			End = os.time({
				year = 2024,
				month = 11,
				day = 7,
				hour = 4,
				min = 0,
				sec = 0
			})
		}
	},
	Blowdryer = {
		Display = "Blowdryer",
		Price = generator(50),
		Description = "Got a friend with a HORRIBLE haircut? With this blowdryer, you can fix it! (Reverts changes made by hair-altering tools, ex. Clippers)",
		Icon = "rbxassetid://114688514116882",
		RoundIcon = "rbxassetid://114688514116882",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Blowdryer Case"
	},
	["Hair Brush"] = {
		Display = "Hair Brush",
		Price = generator(135),
		Description = "60% chance a of nice hairstyle, 40% of a botched one. Are you a good stylist? (Hair regrows back to normal after a few minutes)",
		Icon = "rbxassetid://96044677726924",
		RoundIcon = "rbxassetid://104005651806331",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Hair Brush Case"
	},
	Carry = {
		Display = "Carry Tool",
		Price = generator(145),
		Description = "Carry whoever you want!",
		Icon = "rbxassetid://128501429637064",
		RoundIcon = "rbxassetid://13010230517",
		Group = Type.Item.Carry,
		Toxic = true
	},
	["Shopping Cart"] = {
		Display = "Shopping Cart",
		Price = generator(130),
		Description = "Put your friend in it and take 'em for a spin!",
		Icon = "rbxassetid://74234912936773",
		RoundIcon = "rbxassetid://126909624789455",
		Group = Type.Item.Carry,
		Toxic = true
	},
	["Throw Player"] = {
		Display = "Throw Tool",
		Price = generator(130),
		Description = "LAUNCH EM!! You can carry someone and then yeet them!",
		Icon = "rbxassetid://89188189599159",
		RoundIcon = "rbxassetid://83113766428505",
		Group = Type.Item.Carry,
		Toxic = true
	},
	["Pepper Spray"] = {
		Display = "Pepper Spray",
		Price = generator(45),
		Description = "An elite self defence tool. Make sure you aim at their face!",
		Icon = "rbxassetid://129205764969678",
		RoundIcon = "rbxassetid://113144345502316",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Giggle Spray"] = {
		Display = "Giggle Spray",
		Price = generator(70),
		Description = "An elite self defence tool. Make sure you aim at their face!",
		Icon = "rbxassetid://127621125174936",
		RoundIcon = "rbxassetid://93760137193480",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Sticky Note"] = {
		Display = "Sticky Note",
		Price = generator(90),
		Description = "Write a custom message and leave your mark!",
		Icon = "rbxassetid://133218754121677",
		RoundIcon = "rbxassetid://98443750258251",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Selfie Stick"] = {
		Display = "Selfie Stick",
		Price = generator(30),
		Description = "Everybody say CHEESE!",
		Icon = "rbxassetid://136123614551193",
		RoundIcon = "rbxassetid://107259061203934",
		Group = Type.Item.Utility,
		Toxic = false
	},
	["Superhuman Grab"] = {
		Display = "Superhuman Grab",
		Price = generator(200),
		Description = "It is scientifically impossible to lift someone up into the air with one hand... But it's possible in Neighbors!",
		Icon = "rbxassetid://97455565431044",
		RoundIcon = "rbxassetid://73965500275341",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Shoulder Carry"] = {
		Display = "Shoulder Carry",
		Price = generator(150),
		Description = "Lift people onto your shoulders!",
		Icon = "rbxassetid://87575268560163",
		RoundIcon = "rbxassetid://124668603585640",
		Group = Type.Item.Carry,
		Toxic = true
	},
	Handcuffs = {
		Display = "Handcuffs",
		Price = generator(75),
		Description = "Place people under arrest using these handcuffs.",
		Icon = "rbxassetid://77253452760941",
		RoundIcon = "rbxassetid://76021315923172",
		Group = Type.Item.Carry,
		Toxic = true,
		Skins = "Handcuffs Case"
	},
	["Lasso Tool"] = {
		Display = "Lasso Tool",
		Price = generator(400),
		Description = "This rope isn't gonna tie itself... With this, you can drag players and tie them to any wall or ceiling!",
		Icon = "rbxassetid://135216400897190",
		RoundIcon = "rbxassetid://85167444943788",
		Group = Type.Item.Carry,
		Toxic = true,
		Skins = "Lasso Tool Case"
	},
	["Weather Controller"] = {
		Display = "Weather Controller",
		Price = 1e999,
		Description = "Using this super high tech device, you can control the weather!",
		Icon = "rbxassetid://15113356745",
		Offsale = true,
		QuestItem = true,
		Group = Type.Item.Utility,
		Toxic = false
	},
	Moneybag = {
		Display = "Moneybag",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://16659163",
		Offsale = true,
		QuestItem = true,
		Group = Type.Item.Misc,
		Toxic = false,
		DisableAdjustment = true
	},
	["Jumpscare Tool"] = {
		Display = "Jumpscare Tool",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://126810086437973",
		RoundIcon = "rbxassetid://113545724114581",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = false
	},
	openyourmonkey = {
		Display = "openyourmonkey",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://87458722430006",
		Offsale = true,
		Group = Type.Item.Props,
		Toxic = false
	},
	RipSponge = {
		Display = "RipSponge",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://109511126112819",
		Offsale = true,
		Group = Type.Item.Props,
		Toxic = false
	},
	SpongebobHorn = {
		Display = "Spongebob Foghorn",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://109511126112819",
		Offsale = true,
		Group = Type.Item.Props,
		Toxic = false
	},
	["Kylo Lightsaber"] = {
		Display = "Kylo Ren's Lightsaber",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://1182470584",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = false
	},
	["RGB Lightsaber"] = {
		Display = "RGB Lightsaber",
		Price = 1e999,
		Description = "FunPiggy...",
		Icon = "rbxassetid://1182470584",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = false,
		QuestItem = true
	},
	["Gravity Gun"] = {
		Display = "Gravity Gun",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://129777500585271",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = false
	},
	["Classic Sword"] = {
		Display = "Linked Sword",
		Price = 1e999,
		Description = "hello guys",
		Icon = "http://www.roblox.com/asset/?id=124987047",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = false,
		DisableAdjustment = true
	},
	MP7 = {
		Display = "MP7-SD",
		Price = 1e999,
		Description = "hello guys",
		Icon = "rbxassetid://76652450048955",
		Offsale = true,
		Group = Type.Item.Toxic,
		Toxic = true,
		QuestItem = true,
		DisableAdjustment = true
	},
	FartTool = {
		Display = "Fart Tool",
		Price = 9999,
		Description = "Fart on your enemies!",
		Icon = "rbxassetid://100913096689433",
		Offsale = true,
		Group = Type.Item.Misc,
		Toxic = false
	},
	DebugAttributeViewer = {
		Display = "DebugAttributeViewer",
		Price = 1e999,
		Description = "for karl",
		Icon = "rbxassetid://70560876296747",
		Offsale = true,
		QuestItem = true,
		Group = Type.Item.Utility,
		Toxic = false,
		DisableAdjustment = true
	},
	["Video Camera"] = {
		Display = "Video Camera",
		Price = generator(40),
		Description = "Caught in 4k 60 FPS",
		Icon = "rbxassetid://138196987862249",
		RoundIcon = "rbxassetid://76094351560809",
		Group = Type.Item.Props,
		Toxic = false
	},
	["Frying Pan"] = {
		Display = "Frying Pan",
		Price = generator(110),
		Description = "Hit others with this frying pan to concuss them! Just don't go too pan crazy...",
		Icon = "rbxassetid://103724371232725",
		RoundIcon = "rbxassetid://100681046484787",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Super Punch"] = {
		Display = "Super Punch",
		Price = generator(300),
		Description = "Your foes will never be left undefeated when using this teleporting super punch!",
		Icon = "rbxassetid://113414729049319",
		RoundIcon = "rbxassetid://100405574575952",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Boxing Gloves"] = {
		Display = "Boxing Gloves",
		Price = generator(165),
		Description = "Box 'em up!",
		Icon = "rbxassetid://78533285955994",
		RoundIcon = "rbxassetid://124368729206671",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Boxing Gloves Case"
	},
	Dodgeball = {
		Display = "Dodgeball",
		Price = generator(225),
		Description = "Didn't you always leave PE class feeling targetted? Now you can get revenge!",
		Icon = "rbxassetid://115182060648763",
		RoundIcon = "rbxassetid://102954380354401",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Dodgeball Case"
	},
	NeighborBall = {
		Display = "Capture Capsule",
		Price = generator(180),
		Description = "Capture your friends in this small little capsule! Kind of reminds me of something...",
		Icon = "rbxassetid://120073170501659",
		RoundIcon = "rbxassetid://99420433104590",
		Group = Type.Item.Carry,
		Toxic = true,
		Skins = "Capture Capsule Case"
	},
	Pitchfork = {
		Display = "Pitchfork",
		Price = 450,
		Description = "Impale your foes and throw them back to hell.",
		Icon = "rbxassetid://133867789274260",
		RoundIcon = "rbxassetid://92792958712804",
		Tags = { "halloween" },
		SpecialShop = false,
		Group = Type.Item.Carry,
		Toxic = true,
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
		}
	},
	EndlessPitchfork = {
		Display = "Endless Pitchfork",
		Price = 1e999,
		Description = "Impale LOTS of your foes and throw them back to hell.",
		Icon = "rbxassetid://15090748311",
		Offsale = true,
		Group = Type.Item.Carry,
		Toxic = true
	},
	["Mouse Trap"] = {
		Display = "Mouse Trap",
		Price = generator(35),
		Description = "Drop this mouse trap to trip your friends!",
		Icon = "rbxassetid://120413395848130",
		RoundIcon = "rbxassetid://118370810122791",
		GroupOnly = true,
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Mouse Trap Case"
	},
	Taser = {
		Display = "Taser",
		Price = generator(150),
		Description = "Ever been shocked before? It's not fun.",
		Icon = "rbxassetid://101964031899426",
		RoundIcon = "rbxassetid://134456645593570",
		Group = Type.Item.Toxic,
		Toxic = true,
		Skins = "Taser Case"
	},
	Jetpack = {
		Display = "Jetpack",
		Price = generator(875),
		Description = [[
You can fly and stuff like that.
(You CANNOT fly over to other houses with this)]],
		Icon = "rbxassetid://134850587290489",
		RoundIcon = "rbxassetid://89430655752720",
		Group = Type.Item.Utility,
		Toxic = false,
		Skins = "Jetpack Case"
	},
	Segway = {
		Display = "Segway",
		Price = 900,
		Description = "Zoomer.",
		Icon = "rbxassetid://14511412211",
		Offsale = true,
		RefundOwners = true,
		Group = Type.Item.Utility,
		Toxic = false,
		Skins = "Segway Case",
		QuestItem = true,
		DisableAdjustment = true
	},
	["Paper Bag"] = {
		Display = "Paper Bag",
		Price = generator(120),
		Description = "Put this bag over your friends heads to blind them!",
		Icon = "rbxassetid://77655796654176",
		RoundIcon = "rbxassetid://114796183472838",
		Group = Type.Item.Toxic,
		Skins = "Paper Bag Case",
		Toxic = true
	},
	Fishbowl = {
		Display = "Fishbowl",
		Price = generator(160),
		Description = "Put this bowl over your friends head to make them quiet!",
		Icon = "rbxassetid://91570146025787",
		RoundIcon = "rbxassetid://105744147352949",
		Group = Type.Item.Toxic,
		Skins = "Paper Bag Case",
		Toxic = true
	},
	["Prop Hunt"] = {
		Display = "Prop Hunt",
		Price = generator(60),
		Description = "Transform into objects all around the Neighbors world!",
		Icon = "rbxassetid://116449561874749",
		Group = Type.Item.Utility,
		Toxic = false,
		VerifiedOnly = true
	},
	["Fright Time"] = {
		Display = "Fright Time",
		Price = 6666,
		Description = "Click on players give them a mega jumpscare!",
		Icon = "rbxassetid://70739012802242",
		RoundIcon = "rbxassetid://113545724114581",
		Tags = { "halloween" },
		Group = Type.Item.Toxic,
		SpecialShop = false,
		ForceCurrency = "Credits",
		Toxic = true,
		LimitedTime = {
			Start = os.time({
				year = 2025,
				month = 10,
				day = 2,
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
		}
	},
	["Boogie Time"] = {
		Display = "Boogie Time",
		Price = generator(85),
		Description = "It's party time!!!",
		Icon = "rbxassetid://113350243169752",
		RoundIcon = "rbxassetid://107443178409561",
		Group = Type.Item.Toxic,
		Skins = "Boogie Time Case",
		Toxic = true
	},
	Bottle = {
		Display = "Funky Drink",
		Price = generator(15),
		Description = "Funky things happen when you drink the Funky Drink™️",
		Icon = "rbxassetid://78755552960135",
		RoundIcon = "rbxassetid://105206282280335",
		Group = Type.Item.Props,
		Toxic = false,
		AdultOnly = true
	},
	["Bonk Hammer"] = {
		Display = "Bonk Hammer",
		Price = generator(175),
		Description = "Funky things happen when you bonk the neighborions!",
		Icon = "rbxassetid://81955634866173",
		RoundIcon = "rbxassetid://126871612667381",
		Group = Type.Item.Toxic,
		Toxic = true
	},
	["Blue Tulip"] = {
		Display = "Blue Tulip",
		Price = generator(15),
		Description = "Make your neighbors happy with these colorful plants!",
		Icon = "rbxassetid://133046711298144",
		RoundIcon = "rbxassetid://93049704947367",
		Group = Type.Item.Props,
		Toxic = false,
		Skins = "Blue Tulip Case"
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function UTC(data)
	if not data then
		return DateTime.now().UnixTimestamp
	end

	if data == 1 then
		return 1
	end

	return DateTime.fromUniversalTime(data.year, data.month, data.day, data.hour, data.min, data.sec).UnixTimestamp
end

local currentHoliday = Holiday:GetCurrentHoliday()

for k, v in next, Items, nil do
	v.Name = k
end

if currentHoliday.Deadline then
	for _, v in next, Items, nil do
		if not v.HolidayItem then
			continue
		end

		local v3 = UTC(currentHoliday.Deadline.End) -- equivalent call inferred; original call site unknown
		local v4 = UTC(currentHoliday.Deadline.Start) -- equivalent call inferred; original call site unknown
		local v5 = v3 - v4

		if currentHoliday.Items and table.find(currentHoliday.Items, v.Name) and not (v5 <= 0) then
			v.Offsale = false
			local newTool = UTC(currentHoliday.Deadline.Start) -- equivalent call inferred; original call site unknown
			v.NewTool = newTool
		else
			v.Price = 1e999
			v.LimitedTime = {
				Start = 1,
				End = 1
			}
			v.Offsale = false
			v.NewTool = nil
		end
	end

	for _, v in Holiday:GetAllHolidays() do
		for _, v2 in v.Items or {} do
			local v3 = Items[v2]
			local start

			if v.Deadline then
				local v6 = UTC(v.Deadline.Start) -- equivalent call inferred; original call site unknown
				start = v6 or 1
			else
				start = 1
			end

			local v6

			if v.Deadline then
				local v8 = UTC(v.Deadline.End) -- equivalent call inferred; original call site unknown
				v6 = v8 or 1
			else
				v6 = 1
			end

			v3.LimitedTime = {
				Start = start,
				End = v6
			}
		end
	end
end

for _, v in next, Items, nil do
	if v.NewTool and DateTime.now().UnixTimestamp - v.NewTool >= 1209600 then
		v.NewTool = nil
	end
end

return Items