local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
require(packages.Synchronizer)
require(ReplicatedStorage.Datas.ServerData)
local TacoMerchantData = require(ReplicatedStorage.Datas.TacoMerchantData)
local ValentinesShop = require(ReplicatedStorage.Datas.ValentinesShop)
local Shop = {
	[3312891057] = {
		Display = "[Rainbow Machine] Fill Now",
		Callback = function(_)
			return false
		end,
		Type = "RainbowMachine"
	},
	[3337520317] = {
		Display = "[Bubblegum Machine] Fill Now",
		Callback = function(_)
			return false
		end,
		Type = "RainbowMachine"
	},
	[3312944986] = {
		Display = "1x Spin (Rainbow Wheel)",
		Identifier = "x1",
		Type = "RainbowSpinWheel",
		Value = 1
	},
	[3312945232] = {
		Display = "1x Spin (Rainbow Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "RainbowSpinWheel",
		Value = 1
	},
	[3312945488] = {
		Display = "3x Spins (Rainbow Wheel)",
		Identifier = "x3",
		Type = "RainbowSpinWheel",
		Value = 3
	},
	[3312944807] = {
		Display = "10x Spins (Rainbow Wheel)",
		Identifier = "x10",
		Type = "RainbowSpinWheel",
		Value = 10
	},
	[3307371795] = {
		Display = "1x Spin (Bloodmoon Wheel)",
		Identifier = "x1",
		Type = "BloodmoonWheelSpin",
		Value = 1
	},
	[3307372046] = {
		Display = "1x Spin (Bloodmoon Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "BloodmoonWheelSpin",
		Value = 1
	},
	[3307372342] = {
		Display = "3x Spins (Bloodmoon Wheel)",
		Identifier = "x3",
		Type = "BloodmoonWheelSpin",
		Value = 3
	},
	[3307372798] = {
		Display = "10x Spins (Bloodmoon Wheel)",
		Identifier = "x10",
		Type = "BloodmoonWheelSpin",
		Value = 10
	},
	[3322567440] = {
		Display = "1x Spin (Candy Wheel)",
		Identifier = "x1",
		Type = "CandyWheelSpin",
		Value = 1
	},
	[3322568083] = {
		Display = "1x Spin (Candy Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "CandyWheelSpin",
		Value = 1
	},
	[3322567771] = {
		Display = "3x Spins (Candy Wheel)",
		Identifier = "x3",
		Type = "CandyWheelSpin",
		Value = 3
	},
	[3322567871] = {
		Display = "10x Spins (Candy Wheel)",
		Identifier = "x10",
		Type = "CandyWheelSpin",
		Value = 10
	},
	[3345489415] = {
		Display = "1x Spin (Molten Wheel)",
		Identifier = "x1",
		Type = "MoltenWheelSpin",
		Value = 1
	},
	[3345489701] = {
		Display = "1x Spin (Molten Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "MoltenWheelSpin",
		Value = 1
	},
	[3345489943] = {
		Display = "3x Spins (Molten Wheel)",
		Identifier = "x3",
		Type = "MoltenWheelSpin",
		Value = 3
	},
	[3345489151] = {
		Display = "10x Spins (Molten Wheel)",
		Identifier = "x10",
		Type = "MoltenWheelSpin",
		Value = 10
	},
	[3377020181] = {
		Display = "1x Spin (Galaxy Wheel)",
		Identifier = "x1",
		Type = "GalaxyWheelSpin",
		Value = 1
	},
	[3377020567] = {
		Display = "1x Spin (Galaxy Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "GalaxyWheelSpin",
		Value = 1
	},
	[3377021022] = {
		Display = "3x Spins (Galaxy Wheel)",
		Identifier = "x3",
		Type = "GalaxyWheelSpin",
		Value = 3
	},
	[3377020761] = {
		Display = "10x Spins (Galaxy Wheel)",
		Identifier = "x10",
		Type = "GalaxyWheelSpin",
		Value = 10
	},
	[3414123796] = {
		Display = "1x Spin (Yin Yang Wheel)",
		Identifier = "x1",
		Type = "YinYangWheelSpin",
		Value = 1
	},
	[3414123985] = {
		Display = "1x Spin (Yin Yang Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "YinYangWheelSpin",
		Value = 1
	},
	[3414124199] = {
		Display = "3x Spins (Yin Yang Wheel)",
		Identifier = "x3",
		Type = "YinYangWheelSpin",
		Value = 3
	},
	[3414124509] = {
		Display = "10x Spins (Yin Yang Wheel)",
		Identifier = "x10",
		Type = "YinYangWheelSpin",
		Value = 10
	},
	[3456071068] = {
		Display = "1x Spin (Radioactive Wheel)",
		Identifier = "x1",
		Type = "RadioactiveWheelSpin",
		Value = 1
	},
	[3456071066] = {
		Display = "1x Spin (Radioactive Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "RadioactiveWheelSpin",
		Value = 1
	},
	[3456071067] = {
		Display = "3x Spins (Radioactive Wheel)",
		Identifier = "x3",
		Type = "RadioactiveWheelSpin",
		Value = 3
	},
	[3456071065] = {
		Display = "10x Spins (Radioactive Wheel)",
		Identifier = "x10",
		Type = "RadioactiveWheelSpin",
		Value = 10
	},
	[3488386426] = {
		Display = "1x Spin (Christmas Wheel)",
		Identifier = "x1",
		Type = "ChristmasWheelSpin",
		Value = 1
	},
	[3488386429] = {
		Display = "1x Spin (Christmas Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "ChristmasWheelSpin",
		Value = 1
	},
	[3488386430] = {
		Display = "3x Spin (Christmas Wheel)",
		Identifier = "x3",
		Type = "ChristmasWheelSpin",
		Value = 3
	},
	[3488386428] = {
		Display = "10x Spin (Christmas Wheel)",
		Identifier = "x10",
		Type = "ChristmasWheelSpin",
		Value = 10
	},
	[3499648585] = {
		Display = "1x Spin (Cursed Wheel)",
		Identifier = "x1",
		Type = "CursedWheelSpin",
		Value = 1
	},
	[3499648586] = {
		Display = "1x Spin (Cursed Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "CursedWheelSpin",
		Value = 1
	},
	[3499648590] = {
		Display = "3x Spins (Cursed Wheel)",
		Identifier = "x3",
		Type = "CursedWheelSpin",
		Value = 3
	},
	[3499648587] = {
		Display = "10x Spins (Cursed Wheel)",
		Identifier = "x10",
		Type = "CursedWheelSpin",
		Value = 10
	},
	[3541032363] = {
		Display = "1x Spin (Divine Wheel)",
		Identifier = "x1",
		Type = "DivineWheelSpin",
		Value = 1
	},
	[3541032360] = {
		Display = "1x Spin (Divine Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "DivineWheelSpin",
		Value = 1
	},
	[3541032362] = {
		Display = "3x Spins (Divine Wheel)",
		Identifier = "x3",
		Type = "DivineWheelSpin",
		Value = 3
	},
	[3541032361] = {
		Display = "10x Spins (Divine Wheel)",
		Identifier = "x10",
		Type = "DivineWheelSpin",
		Value = 10
	},
	[3576344385] = {
		Display = "1x Spin (Cyber Wheel)",
		Identifier = "x1",
		Type = "CyberWheelSpin",
		Value = 1
	},
	[3576344388] = {
		Display = "1x Spin (Cyber Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "CyberWheelSpin",
		Value = 1
	},
	[3576344387] = {
		Display = "3x Spins (Cyber Wheel)",
		Identifier = "x3",
		Type = "CyberWheelSpin",
		Value = 3
	},
	[3576344389] = {
		Display = "10x Spins (Cyber Wheel)",
		Identifier = "x10",
		Type = "CyberWheelSpin",
		Value = 10
	},
	[3604076040] = {
		Display = "1x Spin (Phantom Wheel)",
		Identifier = "x1",
		Type = "PhantomWheelSpin",
		Value = 1
	},
	[3604076042] = {
		Display = "1x Spin (Phantom Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "PhantomWheelSpin",
		Value = 1
	},
	[3604076044] = {
		Display = "3x Spins (Phantom Wheel)",
		Identifier = "x3",
		Type = "PhantomWheelSpin",
		Value = 3
	},
	[3604076046] = {
		Display = "10x Spins (Phantom Wheel)",
		Identifier = "x10",
		Type = "PhantomWheelSpin",
		Value = 10
	},
	[3611250645] = {
		Display = "1x Spin (Crystal Wheel)",
		Identifier = "x1",
		Type = "CrystalWheelSpin",
		Value = 1
	},
	[3611250647] = {
		Display = "1x Spin (Crystal Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "CrystalWheelSpin",
		Value = 1
	},
	[3611250649] = {
		Display = "3x Spins (Crystal Wheel)",
		Identifier = "x3",
		Type = "CrystalWheelSpin",
		Value = 3
	},
	[3611250653] = {
		Display = "10x Spins (Crystal Wheel)",
		Identifier = "x10",
		Type = "CrystalWheelSpin",
		Value = 10
	},
	[3715911830] = {
		Display = "1x Spin (Eclipse Wheel)",
		Identifier = "x1",
		Type = "EclipseWheelSpin",
		Value = 1
	},
	[3715911832] = {
		Display = "1x Spin (Eclipse Wheel) DISCOUNT",
		Identifier = "x1",
		Type = "EclipseWheelSpin",
		Value = 1
	},
	[3715911837] = {
		Display = "3x Spins (Eclipse Wheel)",
		Identifier = "x3",
		Type = "EclipseWheelSpin",
		Value = 3
	},
	[3715911840] = {
		Display = "10x Spins (Eclipse Wheel)",
		Identifier = "x10",
		Type = "EclipseWheelSpin",
		Value = 10
	},
	[3296448740] = {
		Display = "2x Server Luck",
		Type = "ServerLuck",
		Index = 1
	},
	[3296448922] = {
		Display = "4x Server Luck",
		Type = "ServerLuck",
		Index = 2
	},
	[3520574597] = {
		Display = "8x Server Luck",
		Type = "ServerLuck",
		Index = 3
	},
	[3296367737] = {
		Display = "VIP",
		Type = "GamepassProduct",
		GiftProduct = 3484585104,
		GiftProductNoRegional = 3296367737
	},
	[3296367604] = {
		Display = "Admin Commands",
		Attribute = "AdminCommands",
		Type = "GamepassProduct",
		GiftProduct = 3484585108,
		GiftProductNoRegional = 3296367604
	},
	[3296367825] = {
		Display = "2x Money",
		Attribute = "2xMoney",
		Type = "GamepassProduct",
		GiftProduct = 3484585101,
		GiftProductNoRegional = 3296367825
	},
	[3290160693] = {
		Display = "Cash Pack #1",
		Type = "Coins",
		Value = 3000,
		GiftProduct = 3484554689,
		GiftProductNoRegional = 3484554697
	},
	[3290160783] = {
		Display = "Cash Pack #2",
		Type = "Coins",
		Value = 25000,
		GiftProduct = 3484554693,
		GiftProductNoRegional = 3484554695
	},
	[3290160857] = {
		Display = "Cash Pack #3",
		Type = "Coins",
		Value = 100000,
		GiftProduct = 3484554718,
		GiftProductNoRegional = 3484554700
	},
	[3290160954] = {
		Display = "Cash Pack #4",
		Type = "Coins",
		Value = 500000,
		GiftProduct = 3484554694,
		GiftProductNoRegional = 3484554723
	},
	[3290161030] = {
		Display = "Cash Pack #5",
		Type = "Coins",
		Value = 1000000,
		GiftProduct = 3484554719,
		GiftProductNoRegional = 3484554724
	},
	[3290152459] = {
		Display = "Blackhole Slap",
		Type = "Item",
		Icon = "rbxassetid://88520285647604",
		GiftProduct = 3484554727,
		GiftProductNoRegional = 3484554725
	},
	[3290152552] = {
		Display = "Laser Gun",
		Type = "Item",
		Icon = "rbxassetid://127461267233201",
		GiftProduct = 3484554707,
		GiftProductNoRegional = 3484554701
	},
	[3290152513] = {
		Display = "Flying Carpet",
		Type = "Item",
		GiftProduct = 3484554722,
		GiftProductNoRegional = 3484554691
	},
	[3442807551] = {
		Display = "Witch's Broom",
		Type = "Item"
	},
	[3290152611] = {
		Display = "Ban Hammer",
		Type = "Item",
		Icon = "rbxassetid://113735454516185",
		GiftProduct = 3484554720,
		GiftProductNoRegional = 3484554717
	},
	[1227013099] = {
		Display = "Admin Commands",
		Attribute = "AdminCommands",
		Type = "Gamepass"
	},
	[1229510262] = {
		Display = "VIP",
		Type = "Gamepass"
	},
	[1228591447] = {
		Display = "2x Money",
		Attribute = "2xMoney",
		Type = "Gamepass"
	},
	[3290334159] = {
		Display = "Starter Pack",
		Type = "Pack",
		Rewards = {
			Items = { "Blackhole Slap", "Coil Combo" },
			Animals = { "Brr Brr Patapim" },
			Coins = 1000
		},
		GiftProduct = 3484554690,
		GiftProductNoRegional = 3484554721
	},
	[3442292161] = {
		Display = "Halloween Pack",
		Type = "Pack",
		Rewards = {
			Items = { "Witch's Broom" },
			Animals = { "Spooky Lucky Block", "Spooky Lucky Block", "Spooky Lucky Block" },
			Coins = 0
		}
	},
	[3483721069] = {
		Display = "Santa's Sleigh",
		Type = "Item",
		Icon = "rbxassetid://106575011463424",
		GiftProduct = 3484554698,
		GiftProductNoRegional = 3484554726
	},
	[3481756179] = {
		Display = "Santa's Sleigh Pack",
		Type = "Pack",
		Icon = "rbxassetid://106575011463424",
		Rewards = {
			Items = { "Santa's Sleigh" },
			Animals = { "Premium Festive Lucky Block", "Premium Festive Lucky Block" },
			Coins = 0
		},
		GiftProduct = 3484576546,
		GiftProductNoRegional = 3484576544
	},
	[3536298171] = {
		Display = "Cupid's Wings",
		Type = "Item",
		Icon = "rbxassetid://125592127726740",
		GiftProduct = 3536298176,
		GiftProductNoRegional = 3536298172
	},
	[3536298173] = {
		Display = "Cupid's Wings Pack",
		Type = "Pack",
		Icon = "rbxassetid://125592127726740",
		Rewards = {
			Items = { "Cupid's Wings" },
			Animals = { "Premium Heart Lucky Block", "Premium Heart Lucky Block" },
			Coins = 0
		},
		GiftProduct = 3536298177,
		GiftProductNoRegional = 3536298175
	},
	[3603521272] = {
		Display = "Waverider",
		Type = "Item",
		Icon = "rbxassetid://125399512921257",
		GiftProduct = 3603521289,
		GiftProductNoRegional = 3603521271
	},
	[3603521291] = {
		Display = "Waverider Pack",
		Type = "Pack",
		Icon = "rbxassetid://125399512921257",
		Rewards = {
			Items = { "Waverider" },
			Animals = { "Premium Octo Lucky Block", "Premium Octo Lucky Block" },
			Coins = 0
		},
		GiftProduct = 3603521318,
		GiftProductNoRegional = 3603521319
	},
	[3709239100] = {
		Display = "Flying Bee",
		Type = "Item",
		Icon = "rbxassetid://76801179428894",
		GiftProduct = 3709239109,
		GiftProductNoRegional = 3709239111
	},
	[3709239112] = {
		Display = "Flying Bee Pack",
		Type = "Pack",
		Icon = "rbxassetid://76801179428894",
		Rewards = {
			Items = { "Flying Bee" },
			Animals = { "Premium Bee Lucky Block", "Premium Bee Lucky Block" },
			Coins = 0
		},
		GiftProduct = 3709239113,
		GiftProductNoRegional = 3709239115
	},
	[3483709817] = {
		Display = "Gingerbread Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://126481609231646",
		Rewards = {
			Items = {},
			Animals = { "Premium Festive Lucky Block" },
			Base = { "Gingerbread" },
			Coins = 0
		},
		GiftProduct = 3484576542,
		GiftProductNoRegional = 3484576545
	},
	[3483736285] = {
		Display = "Gingerbread Base",
		Type = "Base",
		Icon = "rbxassetid://126481609231646",
		Value = "Gingerbread",
		GiftProduct = 3484554704,
		GiftProductNoRegional = 3484554692
	},
	[3531055926] = {
		Display = "Rose Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://110395949945587",
		Rewards = {
			Items = {},
			Animals = { "Premium Heart Lucky Block" },
			Base = { "Rose" },
			Coins = 0
		},
		GiftProduct = 3531055922,
		GiftProductNoRegional = 3531055924
	},
	[3531055923] = {
		Display = "Rose Base",
		Type = "Base",
		Icon = "rbxassetid://110395949945587",
		Value = "Rose",
		GiftProduct = 3531055927,
		GiftProductNoRegional = 3531055925
	},
	[3555794280] = {
		Display = "Pot of Gold Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://90829604470739",
		Rewards = {
			Items = {},
			Animals = { "Premium Leprechaun Lucky Block" },
			Base = { "Pot of Gold" },
			Coins = 0
		},
		GiftProduct = 3555794278,
		GiftProductNoRegional = 3555794279
	},
	[3555794276] = {
		Display = "Pot of Gold Base",
		Type = "Base",
		Icon = "rbxassetid://90829604470739",
		Value = "Pot of Gold",
		GiftProduct = 3555794275,
		GiftProductNoRegional = 3555794277
	},
	[3569489656] = {
		Display = "Bunny Basket Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://114643827804140",
		Rewards = {
			Items = {},
			Animals = { "Premium Egg Lucky Block" },
			Base = { "Bunny Basket" },
			Coins = 0
		},
		GiftProduct = 3569489657,
		GiftProductNoRegional = 3569489653
	},
	[3569489655] = {
		Display = "Bunny Basket Base",
		Type = "Base",
		Icon = "rbxassetid://114643827804140",
		Value = "Bunny Basket",
		GiftProduct = 3569489654,
		GiftProductNoRegional = 3569489652
	},
	[3603521290] = {
		Display = "Octo Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://91644424173568",
		Rewards = {
			Items = {},
			Animals = { "Premium Octo Lucky Block" },
			Base = { "Octo" },
			Coins = 0
		},
		GiftProduct = 3603521281,
		GiftProductNoRegional = 3603521279
	},
	[3603521320] = {
		Display = "Octo Base",
		Type = "Base",
		Icon = "rbxassetid://91644424173568",
		Value = "Octo",
		GiftProduct = 3603521265,
		GiftProductNoRegional = 3603521270
	},
	[3709239086] = {
		Display = "Bee Emperor Base Pack",
		Type = "Pack",
		Icon = "rbxassetid://129074613556681",
		Rewards = {
			Items = {},
			Animals = { "Premium Bee Lucky Block", "Premium Bee Lucky Block" },
			Base = { "Bee Emperor" },
			Coins = 0
		},
		GiftProduct = 3709239092,
		GiftProductNoRegional = 3709239098
	},
	[3709239084] = {
		Display = "Bee Emperor Base",
		Type = "Base",
		Icon = "rbxassetid://129074613556681",
		Value = "Bee Emperor",
		GiftProduct = 3709239089,
		GiftProductNoRegional = 3709239094
	},
	[3301638537] = {
		Display = "Unlock Base",
		Type = "UnlockBase"
	},
	[3312023518] = {
		Display = "Unlock First Floor",
		Type = "UnlockBase"
	},
	[3312023590] = {
		Display = "Unlock Second Floor",
		Type = "UnlockBase"
	},
	[3312023715] = {
		Display = "Unlock Third Floor",
		Type = "UnlockBase"
	},
	[3329528158] = {
		Display = "Mythic Lucky Block",
		Type = "LuckyBlock",
		Value = "Mythic Lucky Block"
	},
	[3329527999] = {
		Display = "Brainrot God Lucky Block",
		Type = "LuckyBlock",
		Value = "Brainrot God Lucky Block"
	},
	[3329528437] = {
		Display = "Secret Lucky Block",
		Type = "LuckyBlock",
		Value = "Secret Lucky Block"
	},
	[3437062543] = {
		Display = "+3 Secret Lucky Block",
		Type = "LuckyBlock",
		Value = "Secret Lucky Block",
		Amount = 3
	},
	[3437979356] = {
		Display = "+8 Secret Lucky Block",
		Type = "LuckyBlock",
		Value = "Secret Lucky Block",
		Amount = 8
	},
	[3437989614] = {
		Display = "+1 Secret, Brainrot God, Mythic Lucky Block",
		Type = "LuckyBlock",
		Value = { "Secret Lucky Block", "Brainrot God Lucky Block", "Mythic Lucky Block" }
	},
	[3478819642] = {
		Display = "Premium Festive Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Festive Lucky Block"
	},
	[3478819641] = {
		Display = "+3 Premium Festive Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Festive Lucky Block",
		Amount = 3
	},
	[3478819648] = {
		Display = "+10 Premium Festive Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Festive Lucky Block",
		Amount = 10
	},
	[3531057541] = {
		Display = "Premium Heart Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Heart Lucky Block"
	},
	[3531057803] = {
		Display = "+3 Premium Heart Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Heart Lucky Block",
		Amount = 3
	},
	[3531057804] = {
		Display = "+10 Premium Heart Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Heart Lucky Block",
		Amount = 10
	},
	[3555794271] = {
		Display = "Premium Leprechaun Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Leprechaun Lucky Block"
	},
	[3555794270] = {
		Display = "+3 Premium Leprechaun Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Leprechaun Lucky Block",
		Amount = 3
	},
	[3555794274] = {
		Display = "+10 Premium Leprechaun Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Leprechaun Lucky Block",
		Amount = 10
	},
	[3569489649] = {
		Display = "Premium Egg Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Egg Lucky Block"
	},
	[3569489650] = {
		Display = "+3 Premium Egg Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Egg Lucky Block",
		Amount = 3
	},
	[3569489651] = {
		Display = "+10 Premium Egg Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Egg Lucky Block",
		Amount = 10
	},
	[3603521263] = {
		Display = "Premium Octo Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Octo Lucky Block"
	},
	[3603521264] = {
		Display = "+3 Premium Octo Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Octo Lucky Block",
		Amount = 3
	},
	[3603521280] = {
		Display = "+10 Premium Octo Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Octo Lucky Block",
		Amount = 10
	},
	[3709239077] = {
		Display = "Premium Bee Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Bee Lucky Block"
	},
	[3709239080] = {
		Display = "+3 Premium Bee Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Bee Lucky Block",
		Amount = 3
	},
	[3709239082] = {
		Display = "+10 Premium Bee Lucky Block",
		Type = "LuckyBlock",
		Value = "Premium Bee Lucky Block",
		Amount = 10
	},
	[3450973929] = {
		Display = "Cupcake Koala",
		Type = "MerchantBrainrot",
		Value = "Cupcake Koala"
	},
	[3450973937] = {
		Display = "Doi Doi Do",
		Type = "MerchantBrainrot",
		Value = "Doi Doi Do"
	},
	[3450973935] = {
		Display = "Clickerino Crabo",
		Type = "MerchantBrainrot",
		Value = "Clickerino Crabo"
	},
	[3450973930] = {
		Display = "Stoppo Luminino",
		Type = "MerchantBrainrot",
		Value = "Stoppo Luminino"
	},
	[3450973932] = {
		Display = "Money Money Man",
		Type = "MerchantBrainrot",
		Value = "Money Money Man"
	},
	[3450973934] = {
		Display = "Noo La Polizia",
		Type = "MerchantBrainrot",
		Value = "Noo La Polizia"
	},
	[3450973933] = {
		Display = "Pirulitoita Bicicleteira",
		Type = "MerchantBrainrot",
		Value = "Pirulitoita Bicicleteira"
	},
	[3450973936] = {
		Display = "Los Puggies",
		Type = "MerchantBrainrot",
		Value = "Los Puggies"
	},
	[3609216525] = {
		Display = "Los Tictacs",
		Type = "BrainrotTraderBrainrot",
		Value = "Los Tictacs"
	},
	[3609216532] = {
		Display = "Los Tangcitos",
		Type = "BrainrotTraderBrainrot",
		Value = "Los Tangcitos"
	},
	[3609216534] = {
		Display = "Los Sigmas",
		Type = "BrainrotTraderBrainrot",
		Value = "Los Sigmas"
	},
	[3609216536] = {
		Display = "Los Cornis",
		Type = "BrainrotTraderBrainrot",
		Value = "Los Cornis"
	},
	[3354160217] = {
		Display = "Reveal Now",
		Type = "FuseMachineRevealNow",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local FuseMachineService = require(ServerScriptService.Services.FuseMachineService)
			return FuseMachineService:PurchaseRevealNow(p)
		end,
		GiftProduct = 3484554699,
		GiftProductNoRegional = 3484554702
	},
	[3483927303] = {
		Display = "Fuse Machine Luck",
		Type = "FuseMachineLuck",
		Callback = function(_)
			local ServerScriptService = game:GetService("ServerScriptService")
			local FuseMachineService = require(ServerScriptService.Services.FuseMachineService)
			return FuseMachineService:AddLuck()
		end
	},
	[3394964472] = {
		Display = "Craft Now - Epic",
		Type = "CraftingMachineClaimNow",
		Callback = function(_)
			return false
		end
	},
	[3394964604] = {
		Display = "Craft Now - Legendary",
		Type = "CraftingMachineClaimNow",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local CraftingMachineService = require(ServerScriptService.Services.CraftingMachineService)
			return CraftingMachineService:PurchaseCraftNow(p, "Legendary")
		end
	},
	[3394964736] = {
		Display = "Craft Now - Mythic",
		Type = "CraftingMachineClaimNow",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local CraftingMachineService = require(ServerScriptService.Services.CraftingMachineService)
			return CraftingMachineService:PurchaseCraftNow(p, "Mythic")
		end
	},
	[3394965881] = {
		Display = "Craft Now - Brainrot God",
		Type = "CraftingMachineClaimNow",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local CraftingMachineService = require(ServerScriptService.Services.CraftingMachineService)
			return CraftingMachineService:PurchaseCraftNow(p, "Brainrot God")
		end
	},
	[3394969112] = {
		Display = "Craft Now - Secret",
		Type = "CraftingMachineClaimNow",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local CraftingMachineService = require(ServerScriptService.Services.CraftingMachineService)
			return CraftingMachineService:PurchaseCraftNow(p, "Secret")
		end
	},
	[3532165598] = {
		Display = "Skip Cupid's Machine",
		Type = "CupidsMachineSkip",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local CupidsMachineService = require(ServerScriptService.Services.CupidsMachineService)
			return CupidsMachineService:PurchaseSkip(p)
		end
	},
	[3467217692] = {
		Display = "Recover [1]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217695] = {
		Display = "Recover [2]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217689] = {
		Display = "Recover [3]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217690] = {
		Display = "Recover [4]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217694] = {
		Display = "Recover [5]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217691] = {
		Display = "Recover [6]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3467217693] = {
		Display = "Recover [7]",
		Type = "AdventCalendarRecover",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local AdventService = require(ServerScriptService.Services.AdventService)
			return (AdventService:Recover(p))
		end
	},
	[3477983793] = {
		Display = "Festive 67",
		Type = "MerchShopItem",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local MerchShopService = require(ServerScriptService.Services.MerchShopService)
			return (MerchShopService:AwardItem(p, "Festive 67", {
				ignoreMutations = true
			}))
		end
	},
	[3568906008] = {
		Display = "Boppin Bunny",
		Type = "MerchShopItem",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local MerchShopService = require(ServerScriptService.Services.MerchShopService)
			return (MerchShopService:AwardItem(p, "Boppin Bunny"))
		end
	},
	[3487835433] = {
		Display = "Los Jolly Combinasionas",
		Type = "SantaMerchantBrainrot",
		Value = "Los Jolly Combinasionas"
	},
	[3487835436] = {
		Display = "Money Money Reindeer",
		Type = "SantaMerchantBrainrot",
		Value = "Money Money Reindeer"
	},
	[3487835435] = {
		Display = "Jolly Jolly Sahur",
		Type = "SantaMerchantBrainrot",
		Value = "Jolly Jolly Sahur"
	},
	[3487835440] = {
		Display = "Ginger Gerat",
		Type = "SantaMerchantBrainrot",
		Value = "Ginger Gerat"
	},
	[3646897652] = {
		Display = "Conetto Morsetto",
		Type = "BeeMerchantBrainrot",
		Value = "Conetto Morsetto"
	},
	[3646897760] = {
		Display = "Honey Honey Bear",
		Type = "BeeMerchantBrainrot",
		Value = "Honey Honey Bear"
	},
	[3646897853] = {
		Display = "Queen Bee",
		Type = "BeeMerchantBrainrot",
		Value = "Queen Bee"
	},
	[3646898016] = {
		Display = "S'more Serat",
		Type = "BeeMerchantBrainrot",
		Value = "S'more Serat"
	},
	[3646898142] = {
		Display = "Bumbatron",
		Type = "BeeMerchantBrainrot",
		Value = "Bumbatron"
	},
	[3520721003] = {
		Display = "+1 Speed Upgrade",
		Type = "TsunamiSpeedUpgrade",
		Callback = function(p)
			local ServerScriptService = game:GetService("ServerScriptService")
			local TsunamiEventService = require(ServerScriptService.Services.TsunamiEventService)
			return TsunamiEventService:IncreaseUpgrade(p, 1)
		end
	}
}
Shop[3520721003] = {
	Display = "+1 Speed",
	Type = "TsunamiSpeedUpgrade",
	Callback = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		local TsunamiEventService = require(ServerScriptService.Services.TsunamiEventService)
		return TsunamiEventService:IncreaseUpgrade(p, 1)
	end
}
Shop[3520721005] = {
	Display = "+5 Speed",
	Type = "TsunamiSpeedUpgrade",
	Callback = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		local TsunamiEventService = require(ServerScriptService.Services.TsunamiEventService)
		return TsunamiEventService:IncreaseUpgrade(p, 5)
	end
}
Shop[3520721004] = {
	Display = "+10 Speed",
	Type = "TsunamiSpeedUpgrade",
	Callback = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		local TsunamiEventService = require(ServerScriptService.Services.TsunamiEventService)
		return TsunamiEventService:IncreaseUpgrade(p, 10)
	end
}
Shop[3596422616] = {
	Display = "2x Money Boost (30m)",
	Type = "MoneyBoost",
	Callback = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		local BoostService = require(ServerScriptService.Services.BoostService)
		BoostService:Set(p, "2xMoneyBoost", 1800, false)
		return true
	end
}

for k, product in ValentinesShop.Products do
	Shop[product.discountedProductId] = {
		Display = `[20% OFF] {Shop[k].Display}`,
		Type = "ValentinesGift",
		NoGift = true,
		Callback = function(p, p2)
			local ServerScriptService = game:GetService("ServerScriptService")
			local ValentinesShopService = require(ServerScriptService.Services.ValentinesShopService)
			return ValentinesShopService:ProcessGiftPurchase(p, p2)
		end
	}
end

for _, brainrot in TacoMerchantData.Brainrots do
	if brainrot.ProductId <= 0 then
		continue
	end

	assert(Shop[brainrot.ProductId] == nil, (`Duplicate Taco Merchant ProductId {brainrot.ProductId}`))
	Shop[brainrot.ProductId] = {
		Display = brainrot.Brainrot,
		Type = "TacoMerchantBrainrot",
		Value = brainrot.Brainrot
	}
end

for k, v in {
	[3714849332] = "Cavallo Virtuoso Egg",
	[3714849334] = "Tartaruga Cisterna Egg",
	[3714849336] = "Eggdin Egg Egg Dun Egg",
	[3714849339] = "Graipuss Medussi Egg",
	[3714849347] = "Extinct Ballerina Egg",
	[3714849350] = "Craburger Egg",
	[3714849353] = "Frio Ninja Egg",
	[3714849354] = "Sammyni Spyderini Egg",
	[3714849356] = "Fishboard Egg",
	[3714849361] = "Ranito Pepito Egg",
	[3714849364] = "Capibaro Celestino Egg",
	[3714849370] = "Zebrino Pianino Egg",
	[3714849373] = "Rexino Ramino Egg",
	[3714849379] = "Qamar Camelamp Egg",
	[3714849381] = "La Grande Combinasion Egg",
	[3714849383] = "Ski Ski Skunki Egg",
	[3714849388] = "Rockarino Rockara Egg",
	[3714849389] = "Chill Puppy Egg",
	[3714849392] = "Pin Pin Pengu Egg",
	[3714849396] = "Chicleteira Bicicleteira Egg",
	[3714849400] = "Marino Submarino Egg",
	[3714849404] = "Arcadopus Egg",
	[3714849406] = "To to to Sahur Egg",
	[3714849409] = "Burrito Bat Egg",
	[3714849411] = "Cupid Cupid Sahur Egg",
	[3714849417] = "Yetimatic Egg",
	[3714849421] = "Sir Mangus Egg",
	[3714849426] = "Swag Soda Egg",
	[3714849429] = "Lavamanta Egg",
	[3714849432] = "DJ Panda Egg",
	[3714849434] = "Lionello Casarello Egg",
	[3714849439] = "Draculino Egg",
	[3714849442] = "Capitano Moby Egg",
	[3714849447] = "Cerberus Egg",
	[3714849451] = "Dragon Cannelloni Egg"
} do
	assert(Shop[k] == nil, (`Duplicate Jump LTM Hatch Skip ProductId {k}`))
	local v2 = v
	Shop[k] = {
		Display = `Skip Timer - {v}`,
		Type = "JumpLTMHatchSkip",
		Value = v,
		NoGift = true,
		Callback = function(p, p2)
			local ServerScriptService = game:GetService("ServerScriptService")
			local JumpLTMService = require(ServerScriptService.Services.JumpLTMService)
			return JumpLTMService:ProcessHatchSkipReceipt(p, v2)
		end
	}
end

return Shop