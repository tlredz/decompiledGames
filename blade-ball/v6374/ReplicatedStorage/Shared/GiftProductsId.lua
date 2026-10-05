local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Shared.SeasonPassData)
local v3 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local v4 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData/External")
local v5 = require3(ReplicatedStorage2.Shared.LTM)
local _ = game.GameId == 4777817887
local v6 = {
	["Small Coin Pack"] = {
		productId = 1673245508,
		DisplayName = "Small Coin Pack"
	},
	["Medium Coin Pack"] = {
		productId = 1673245649,
		DisplayName = "Medium Coin Pack"
	},
	["Big Coin Pack"] = {
		productId = 1673245992,
		DisplayName = "Big Coin Pack"
	},
	["Huge Coin Pack"] = {
		productId = 1673246237,
		DisplayName = "Huge Coin Pack"
	},
	["Massive Coin Pack"] = {
		productId = 1673246302,
		DisplayName = "Massive Coin Pack"
	},
	GiftNebulaTenSpin = {
		productId = 1766215506,
		DisplayName = "Ten Nebula Spins"
	},
	GiftFrogTenSpin = {
		productId = 1809636820,
		DisplayName = "Ten Frog Spins"
	},
	GiftDevilKatanaTenSpin = {
		productId = 1821529242,
		DisplayName = "Ten Katana Spins"
	},
	GiftMatrixTenSpin = {
		productId = 1829221743,
		DisplayName = "Ten Encrypted Spins"
	},
	GiftTenFireDragonGacha = {
		productId = 1843780738,
		DisplayName = "Ten Fire Spins"
	},
	GiftTenIceDragonGacha = {
		productId = 1844458075,
		DisplayName = "Ten Ice Spins"
	},
	GiftTenChromaGacha = {
		productId = 1852344374,
		DisplayName = "Ten Chroma Spins"
	},
	GiftOneCyberGacha = {
		productId = 1880541600,
		DisplayName = "One Techno Spins"
	},
	GiftTenCyberGacha = {
		productId = 1880293927,
		DisplayName = "Ten Techno Spins"
	},
	GiftTenBorealisGacha = {
		productId = 1908075948,
		DisplayName = "Ten Borealis Spins"
	},
	GiftTenJackolanternGacha = {
		productId = 2257212764,
		DisplayName = "Ten Jack-o-Lantern Spins"
	},
	GiftTenEternalNightGacha = {
		productId = 2657342511,
		DisplayName = "Ten Eternal Night Spins"
	},
	GiftTenReindeerGacha = {
		productId = 2672143994,
		DisplayName = "Ten Reindeer Spins"
	},
	GiftOneArachnidGacha = {
		productId = 2700498058,
		DisplayName = "1 Arachnid Spin"
	},
	GiftTenArachnidGacha = {
		productId = 2699508066,
		DisplayName = "10 Arachnid Spins"
	},
	GiftFiftyArachnidGacha = {
		productId = 2700885179,
		DisplayName = "50 Arachnid Spins"
	},
	GiftTwoHundredFiftyArachnidGacha = {
		productId = 2700885178,
		DisplayName = "250 Arachnid Spins"
	},
	GiftOneKitsuneGacha = {
		productId = 2916609559,
		DisplayName = "1 Kitsune Spin"
	},
	GiftTenKitsuneGacha = {
		productId = 2916582859,
		DisplayName = "10 Kitsune Spins"
	},
	GiftFiftyKitsuneGacha = {
		productId = 2916582861,
		DisplayName = "50 Kitsune Spins"
	},
	GiftTwoHundredFiftyKitsuneGacha = {
		productId = 2916582851,
		DisplayName = "250 Kitsune Spins"
	},
	GiftOneBloomGacha = {
		productId = 3245229873,
		DisplayName = "1 Bloom Spin"
	},
	GiftTenBloomGacha = {
		productId = 3245222354,
		DisplayName = "10 Bloom Spins"
	},
	GiftFiftyBloomGacha = {
		productId = 3245222356,
		DisplayName = "50 Bloom Spins"
	},
	GiftTwoHundredFiftyBloomGacha = {
		productId = 3245222355,
		DisplayName = "250 Bloom Spins"
	},
	GiftOneVoidGacha = {
		productId = 3272744938,
		DisplayName = "1 Void Spin"
	},
	GiftTenVoidGacha = {
		productId = 3272742468,
		DisplayName = "10 Void Spins"
	},
	GiftFiftyVoidGacha = {
		productId = 3272742473,
		DisplayName = "50 Void Spins"
	},
	GiftTwoHundredFiftyVoidGacha = {
		productId = 3272742467,
		DisplayName = "250 Void Spins"
	},
	GiftOneChromeGacha = {
		productId = 3305412330,
		DisplayName = "1 Elemental Spin"
	},
	GiftTenChromeGacha = {
		productId = 3305412328,
		DisplayName = "10 Elemental Spins"
	},
	GiftFiftyChromeGacha = {
		productId = 3305412335,
		DisplayName = "50 Elemental Spins"
	},
	GiftTwoHundredFiftyChromeGacha = {
		productId = 3305412333,
		DisplayName = "250 Elemental Spins"
	},
	GiftOneBlossomGacha = {
		productId = 3344463136,
		DisplayName = "1 Blossom Spin"
	},
	GiftTenBlossomGacha = {
		productId = 3344463143,
		DisplayName = "10 Blossom Spins"
	},
	GiftFiftyBlossomGacha = {
		productId = 3344463141,
		DisplayName = "50 Blossom Spins"
	},
	GiftTwoHundredFiftyBlossomGacha = {
		productId = 3344463142,
		DisplayName = "250 Blossom Spins"
	},
	GiftOneOwlGacha = {
		productId = 3606732994,
		DisplayName = "1 Owl Spin"
	},
	GiftTenOwlGacha = {
		productId = 3412351762,
		DisplayName = "10 Owl Spins"
	},
	GiftFiftyOwlGacha = {
		productId = 3412351763,
		DisplayName = "50 Owl Spins"
	},
	GiftTwoHundredFiftyOwlGacha = {
		productId = 3412351766,
		DisplayName = "250 Owl Spins"
	},
	GiftOneSoccerGacha = {
		productId = 3606732994,
		DisplayName = "1 Soccer Spin"
	},
	GiftTenSoccerGacha = {
		productId = 3606732999,
		DisplayName = "10 Soccer Spins"
	},
	GiftFiftySoccerGacha = {
		productId = 3606733006,
		DisplayName = "50 Soccer Spins"
	},
	GiftTwoHundredFiftySoccerGacha = {
		productId = 3606733010,
		DisplayName = "250 Soccer Spins"
	},
	GiftOneKrakenGacha = {
		productId = 3612465317,
		DisplayName = "1 Kraken Spin"
	},
	GiftTenKrakenGacha = {
		productId = 3612465321,
		DisplayName = "10 Kraken Spins"
	},
	GiftFiftyKrakenGacha = {
		productId = 3612465330,
		DisplayName = "50 Kraken Spins"
	},
	GiftTwoHundredFiftyKrakenGacha = {
		productId = 3612465333,
		DisplayName = "250 Kraken Spins"
	},
	GiftOneKawaiiGacha = {
		productId = 3714759195,
		DisplayName = "1 Kawaii Spin"
	},
	GiftTenKawaiiGacha = {
		productId = 3714759198,
		DisplayName = "10 Kawaii Spins"
	},
	GiftFiftyKawaiiGacha = {
		productId = 3714759202,
		DisplayName = "50 Kawaii Spins"
	},
	GiftTwoHundredFiftyKawaiiGacha = {
		productId = 3714759210,
		DisplayName = "250 Kawaii Spins"
	},
	RobuxMerchantCrate = {
		productId = 1849905092,
		DisplayName = "Limited Royal Crate"
	},
	["Double Coins"] = {
		type = "GamePass",
		name = "2xCoins",
		productId = 1645644301,
		DisplayName = "Double Coins Gamepass"
	},
	VIP = {
		type = "GamePass",
		name = "VIP",
		productId = 1645644196,
		DisplayName = "VIP Gamepass"
	},
	["Instant Spin"] = {
		type = "GamePass",
		name = "FastUnbox",
		productId = 1645644410,
		DisplayName = "Instant Spin Gamepass"
	},
	["Trading Sign"] = {
		type = "GamePass",
		name = "TradingSign",
		productId = 1909328030,
		DisplayName = "Trading Sign Gamepass"
	},
	["Limited Sword"] = {
		productId = 1661944071,
		type = "Sword",
		name = "Hallow's Edge",
		DisplayName = "Hallow's Edge"
	},
	LimitedSwordEvent_Nebula_Dual = {
		productId = 1676651251,
		type = "Sword",
		name = "Dual Nebula Scythe",
		DisplayName = "Dual Nebula Scythe",
		Offsale = true
	},
	LimitedSwordEvent_Nebula_Single = {
		productId = 1676651366,
		type = "Sword",
		name = "Nebula Scythe",
		DisplayName = "Nebula Scythe",
		Offsale = true
	},
	LimitedSwordEvent_EtherBlade_Dual = {
		productId = 1681076133,
		type = "Sword",
		name = "Dual Ether Blade",
		DisplayName = "Dual Ether Blade",
		Offsale = true
	},
	LimitedSwordEvent_EtherBlade_Single = {
		productId = 1681075983,
		type = "Sword",
		name = "Ether Blade",
		DisplayName = "Ether Blade",
		Offsale = true
	},
	LimitedSwordEvent_Shield_Better = {
		productId = 1685472174,
		type = "Sword",
		name = "Empyrean Fortress",
		DisplayName = "Empyrean Fortress",
		Offsale = true
	},
	LimitedSwordEvent_Shield_Single = {
		productId = 1685471782,
		type = "Sword",
		name = "Vanguard Shield",
		DisplayName = "Vanguard Shield",
		Offsale = true
	},
	LimitedSwordEvent_NebulaLightning_Better = {
		productId = 1701417712,
		type = "Sword",
		name = "Dual Nebula's Lightning",
		DisplayName = "Dual Nebula's Lightning",
		Offsale = true
	},
	LimitedSwordEvent_NebulaLightning_Single = {
		productId = 1701417480,
		type = "Sword",
		name = "Nebula's Lightning",
		DisplayName = "Nebula's Lightning",
		Offsale = true
	},
	ElementalPack_Lightning = {
		type = "GiftGacha",
		productId = 1673405841,
		DisplayName = "Elemental Pack Lightning"
	},
	ElementalPack_Water = {
		type = "GiftGacha",
		productId = 1673406181,
		DisplayName = "Elemental Pack Water"
	},
	ElementalPack_Wind = {
		type = "GiftGacha",
		productId = 1673406032,
		DisplayName = "Elemental Pack Wind"
	},
	["Nebula Yoru"] = {
		type = "Sword",
		name = "Nebula Yoru",
		productId = 1713926517,
		DisplayName = "Nebula Yoru",
		Offsale = true
	},
	["Dual Nebula Yoru"] = {
		type = "Sword",
		productId = 1713926821,
		name = "Dual Nebula Yoru",
		DisplayName = "Dual Nebula Yoru",
		Offsale = true
	},
	["Blackhole Katana"] = {
		type = "Sword",
		productId = 1711194783,
		name = "Blackhole Katana",
		DisplayName = "Blackhole Katana",
		Offsale = true
	},
	["Dual Blackhole Katana"] = {
		type = "Sword",
		productId = 1711194996,
		name = "Dual Blackhole Katana",
		DisplayName = "Dual Blackhole Katana",
		Offsale = true
	},
	["Blackhole Scythe"] = {
		type = "Sword",
		productId = 1713935654,
		DisplayName = "Blackhole Scythe",
		name = "Blackhole Scythe",
		Offsale = true
	},
	["Nebula Claws"] = {
		type = "Sword",
		productId = 1719751642,
		DisplayName = "Nebula Claws",
		name = "Nebula Claws",
		Offsale = true
	},
	["Dual Blackhole Scythe"] = {
		type = "Sword",
		productId = 1713936304,
		DisplayName = "Dual Blackhole Scythe",
		name = "Dual Blackhole Scythe",
		Offsale = true
	},
	["Yin Yang Katana"] = {
		type = "Sword",
		productId = 1715657539,
		name = "Yin Yang Katana",
		DisplayName = "Yin Yang Katana",
		Offsale = true
	},
	["Dual Yin Yang Katana"] = {
		type = "Sword",
		productId = 1715657752,
		name = "Dual Yin Yang Katana",
		DisplayName = "Dual Yin Yang Katana",
		Offsale = true
	},
	["Kurogin Katana"] = {
		type = "Sword",
		productId = 1711188892,
		name = "Kurogin Katana",
		DisplayName = "Kurogin Katana",
		Offsale = true
	},
	["Dual Kurogin Katana"] = {
		type = "Sword",
		productId = 1711189225,
		name = "Dual Kurogin Katana",
		DisplayName = "Dual Kurogin Katana",
		Offsale = true
	},
	["Kurogin Scythe"] = {
		type = "Sword",
		productId = 1717384022,
		name = "Kurogin Scythe",
		DisplayName = "Kurogin Scythe",
		Offsale = true
	},
	["Dual Kurogin Scythe"] = {
		type = "Sword",
		productId = 1717373338,
		name = "Dual Kurogin Scythe",
		DisplayName = "Dual Kurogin Scythe",
		Offsale = true
	},
	["Raven Greatsword"] = {
		type = "Sword",
		productId = 1719251610,
		name = "Raven Greatsword",
		DisplayName = "Raven Greatsword",
		Offsale = true
	},
	["Dual Raven Greatsword"] = {
		type = "Sword",
		productId = 1719251689,
		name = "Dual Raven Greatsword",
		DisplayName = "Dual Raven Greatsword",
		Offsale = true
	},
	["Raven Scythe"] = {
		type = "Sword",
		productId = 1719251962,
		name = "Raven Scythe",
		DisplayName = "Raven Scythe",
		Offsale = true
	},
	["Dual Raven Scythe"] = {
		type = "Sword",
		productId = 1719252045,
		name = "Dual Raven Scythe",
		DisplayName = "Dual Raven Scythe",
		Offsale = true
	},
	["Yin Yang Scythe"] = {
		type = "Sword",
		productId = 1715658141,
		name = "Yin Yang Scythe",
		DisplayName = "Yin Yang Scythe",
		Offsale = true
	},
	["Dual Yin Yang Scythe"] = {
		type = "Sword",
		productId = 1715658580,
		name = "Dual Yin Yang Scythe",
		DisplayName = "Dual Yin Yang Scythe",
		Offsale = true
	},
	["Blackhole Pack"] = {
		type = "LimitedPack",
		productId = 1711194550,
		DisplayName = "Blackhole Pack",
		name = "Blackhole Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Blackhole Katana"
			},
			{
				Type = "Sword",
				ItemName = "Blackhole Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Super Blackhole"
			}
		},
		Offsale = true
	},
	["Dual Blackhole Pack"] = {
		type = "LimitedPack",
		productId = 1711194310,
		DisplayName = "Dual Blackhole Pack",
		name = "Dual Blackhole Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Blackhole Katana"
			},
			{
				Type = "Sword",
				ItemName = "Dual Blackhole Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Super Blackhole"
			}
		},
		Offsale = true
	},
	["Raven Pack"] = {
		type = "LimitedPack",
		productId = 1719256625,
		DisplayName = "Raven Pack",
		name = "Raven Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Raven Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Raven Greatsword"
			},
			{
				Type = "Explosion",
				ItemName = "Raven Blast"
			}
		},
		Offsale = true
	},
	["Dual Raven Pack"] = {
		type = "LimitedPack",
		productId = 1719256716,
		DisplayName = "Dual Raven Pack",
		name = "Dual Raven Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Raven Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Dual Raven Greatsword"
			},
			{
				Type = "Explosion",
				ItemName = "Raven Blast"
			}
		},
		Offsale = true
	},
	["Kurogin Pack"] = {
		type = "LimitedPack",
		productId = 1717413749,
		DisplayName = "Kurogin Pack",
		name = "Kurogin Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Kurogin Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Kurogin Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Kurogin Destruction"
			}
		},
		Offsale = true
	},
	["Dual Kurogin Pack"] = {
		type = "LimitedPack",
		productId = 1717414004,
		DisplayName = "Dual Kurogin Pack",
		name = "Dual Kurogin Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Kurogin Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Dual Kurogin Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Kurogin Destruction"
			}
		},
		Offsale = true
	},
	["Singularity Pack"] = {
		type = "LimitedPack",
		productId = 1711196212,
		DisplayName = "Singularity Pack",
		name = "Singularity Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Singularity Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Singularity Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Singularity Expulsion"
			}
		},
		Offsale = true
	},
	["Dual Singularity Pack"] = {
		type = "LimitedPack",
		productId = 1711195927,
		DisplayName = "Dual Singularity Pack",
		name = "Dual Singularity Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Singularity Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Dual Singularity Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Singularity Expulsion"
			}
		},
		Offsale = true
	},
	["Sakura Pack"] = {
		type = "LimitedPack",
		productId = 1711187139,
		DisplayName = "Sakura Pack",
		name = "Sakura Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Sakura Katana"
			},
			{
				Type = "Sword",
				ItemName = "Sakura Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Super Sakura"
			}
		},
		Offsale = true
	},
	["Yin Yang Pack"] = {
		type = "LimitedPack",
		productId = 1715658793,
		DisplayName = "Yin Yang Pack",
		name = "Yin Yang Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Yin Yang Katana"
			},
			{
				Type = "Sword",
				ItemName = "Yin Yang Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Yin Yang"
			}
		},
		Offsale = true
	},
	["Dual Yin Yang Pack"] = {
		type = "LimitedPack",
		productId = 1715659044,
		DisplayName = "Dual Yin Yang Pack",
		name = "Dual Yin Yang Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Yin Yang Katana"
			},
			{
				Type = "Sword",
				ItemName = "Dual Yin Yang Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Yin Yang"
			}
		},
		Offsale = true
	},
	["Dual Sakura Pack"] = {
		type = "LimitedPack",
		productId = 1711192801,
		DisplayName = "Dual Sakura Pack",
		name = "Dual Sakura Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Sakura Katana"
			},
			{
				Type = "Sword",
				ItemName = "Dual Sakura Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Super Sakura"
			}
		},
		Offsale = true
	},
	["Singularity Katana"] = {
		type = "Sword",
		productId = 1711154200,
		name = "Singularity Katana",
		DisplayName = "Singularity Katana",
		Offsale = true
	},
	["Dual Singularity Katana"] = {
		type = "Sword",
		productId = 1711154664,
		name = "Dual Singularity Katana",
		DisplayName = "Dual Singularity Katana",
		Offsale = true
	},
	["Singularity Scythe"] = {
		type = "Sword",
		productId = 1711155066,
		name = "Singularity Scythe",
		DisplayName = "Singularity Scythe",
		Offsale = true
	},
	["Dual Singularity Scythe"] = {
		type = "Sword",
		productId = 1713938323,
		name = "Dual Singularity Scythe",
		DisplayName = "Dual Singularity Scythe",
		Offsale = true
	},
	["Sakura Katana"] = {
		type = "Sword",
		productId = 1711190745,
		DisplayName = "Sakura Katana",
		name = "Sakura Katana",
		Offsale = true
	},
	["Dual Sakura Katana"] = {
		type = "Sword",
		productId = 1711190933,
		name = "Dual Sakura Katana",
		DisplayName = "Dual Sakura Katana",
		Offsale = true
	},
	["Sakura Scythe"] = {
		type = "Sword",
		productId = 1711187885,
		name = "Sakura Scythe",
		DisplayName = "Sakura Scythe",
		Offsale = true
	},
	["Dual Sakura Scythe"] = {
		type = "Sword",
		productId = 1711193468,
		name = "Dual Sakura Scythe",
		DisplayName = "Dual Sakura Scythe",
		Offsale = true
	},
	["Dragon Slayer"] = {
		type = "Sword",
		productId = 1713930981,
		name = "Dragon Slayer",
		DisplayName = "Dragon Slayer",
		Offsale = true
	},
	["Dual Dragon Slayer"] = {
		type = "Sword",
		productId = 1713932736,
		name = "Dual Dragon Slayer",
		DisplayName = "Dual Dragon Slayer",
		Offsale = true
	},
	["Wispwind Reaper"] = {
		type = "Sword",
		productId = 1719569184,
		name = "Wispwind Reaper",
		DisplayName = "Wispwind Reaper",
		Offsale = true
	},
	["Dual Wispwind Reaper"] = {
		type = "Sword",
		productId = 1719569365,
		name = "Dual Wispwind Reaper",
		DisplayName = "Dual Wispwind Reaper",
		Offsale = true
	},
	["Solar Edge"] = {
		type = "Sword",
		productId = 1766864749,
		name = "Solar Edge",
		DisplayName = "Solar Edge",
		Offsale = true
	},
	EasterPack = {
		type = "LimitedPack",
		productId = 1789076462,
		DisplayName = "Easter Bundle",
		name = "Easter Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Bunny Staff"
			},
			{
				Type = "Emote",
				ItemName = "Emote235"
			},
			{
				Type = "Explosion",
				ItemName = "Eggsplosive Exit"
			}
		}
	},
	["Asean Pack"] = {
		type = "GamePass",
		productId = 1664715007,
		DisplayName = "Asean Pack"
	},
	BattlepassSkipTier1 = {
		type = "SeasonPassSkipTier",
		skipAmount = 1,
		productId = require3(ReplicatedStorage2.Shared.SeasonPassSkip).SkipGifts[1],
		DisplayName = "Season Skip 1 Tier"
	},
	BattlepassSkipTier5 = {
		type = "SeasonPassSkipTier",
		skipAmount = 5,
		productId = require3(ReplicatedStorage2.Shared.SeasonPassSkip).SkipGifts[5],
		DisplayName = "Season Skip 5 Tiers"
	},
	BattlepassSkipTier10 = {
		type = "SeasonPassSkipTier",
		skipAmount = 10,
		productId = require3(ReplicatedStorage2.Shared.SeasonPassSkip).SkipGifts[10],
		DisplayName = "Season Skip 10 Tiers"
	},
	PremiumSeasonPass = {
		type = "SeasonPass",
		productId = v2.GiftSeasonPassProductId,
		DisplayName = `Premium {v3.SeasonData.Name} Season Pass`
	},
	GiftDragonCharacter = {
		type = "GiftCharacter",
		productId = 1749883219,
		DisplayName = "Dragon Elemental Character",
		name = "Dragon"
	},
	GiftSpecialResets1 = {
		type = "GiftGacha",
		productId = 1676262354,
		DisplayName = "Ability Training Resets x2"
	},
	GiftSpecialResets2 = {
		type = "GiftGacha",
		productId = 1676262500,
		DisplayName = "Ability Training Resets x10"
	},
	GiftSpecialResets3 = {
		type = "GiftGacha",
		productId = 1676262558,
		DisplayName = "Ability Training Resets x100"
	},
	GiftSpecialTrainingEventReset1 = {
		type = "GiftGacha",
		productId = 1931641291,
		DisplayName = "Sword Training Reset"
	},
	GiftSpecialTrainingEventReset2 = {
		type = "GiftGacha",
		productId = 1931641294,
		DisplayName = "Sword Training Reset"
	},
	GiftSpecialTrainingEventReset3 = {
		type = "GiftGacha",
		productId = 1931641292,
		DisplayName = "Sword Training Reset"
	},
	GiftSpecialTrainingEventReset4 = {
		type = "GiftGacha",
		productId = 1931641293,
		DisplayName = "Sword Training Reset"
	},
	GiftSpecialTrainingEventReset5 = {
		type = "GiftGacha",
		productId = 1931641295,
		DisplayName = "Sword Training Reset"
	},
	GiftSpecialTrainingEventReset6 = {
		type = "GiftGacha",
		productId = 1931641290,
		DisplayName = "Sword Training Reset"
	},
	["Stars Tier 1"] = {
		productId = 1771581987,
		DisplayName = "Stars Tier 1"
	},
	["Stars Tier 2"] = {
		productId = 1771581977,
		DisplayName = "Stars Tier 2"
	},
	["Stars Tier 3"] = {
		productId = 1771581984,
		DisplayName = "Stars Tier 3"
	},
	["Stars Tier 4"] = {
		productId = 1771581978,
		DisplayName = "Stars Tier 4"
	},
	["Stars Tier 5"] = {
		productId = 1771581982,
		DisplayName = "Stars Tier 5"
	},
	["Souls Tier 1"] = {
		productId = 1804500482,
		DisplayName = "Souls Tier 1"
	},
	["Souls Tier 2"] = {
		productId = 1804500478,
		DisplayName = "Souls Tier 2"
	},
	["Souls Tier 3"] = {
		productId = 1804500480,
		DisplayName = "Souls Tier 3"
	},
	["Souls Tier 4"] = {
		productId = 1804500479,
		DisplayName = "Souls Tier 4"
	},
	["Souls Tier 5"] = {
		productId = 1804500481,
		DisplayName = "Souls Tier 5"
	},
	["Crystals Tier 1"] = {
		productId = 1830626648,
		DisplayName = "Crystals Tier 1"
	},
	["Crystals Tier 2"] = {
		productId = 1830626655,
		DisplayName = "Crystals Tier 2"
	},
	["Crystals Tier 3"] = {
		productId = 1830626645,
		DisplayName = "Crystals Tier 3"
	},
	["Crystals Tier 4"] = {
		productId = 1830626654,
		DisplayName = "Crystals Tier 4"
	},
	["Crystals Tier 5"] = {
		productId = 1830626650,
		DisplayName = "Crystals Tier 5"
	},
	["Shells Tier 1"] = {
		productId = 1858489365,
		DisplayName = "Shells Tier 1"
	},
	["Shells Tier 2"] = {
		productId = 1858489362,
		DisplayName = "Shells Tier 2"
	},
	["Shells Tier 3"] = {
		productId = 1858489354,
		DisplayName = "Shells Tier 3"
	},
	["Shells Tier 4"] = {
		productId = 1858489357,
		DisplayName = "Shells Tier 4"
	},
	["Shells Tier 5"] = {
		productId = 1858489360,
		DisplayName = "Shells Tier 5"
	},
	["Chips Tier 1"] = {
		productId = 1903175089,
		DisplayName = "Chips Tier 1"
	},
	["Chips Tier 2"] = {
		productId = 1903175092,
		DisplayName = "Chips Tier 2"
	},
	["Chips Tier 3"] = {
		productId = 1903175090,
		DisplayName = "Chips Tier 3"
	},
	["Chips Tier 4"] = {
		productId = 1903175088,
		DisplayName = "Chips Tier 4"
	},
	["Chips Tier 5"] = {
		productId = 1903175091,
		DisplayName = "Chips Tier 5"
	},
	["Pumpkins Tier 1"] = {
		productId = 1668607741,
		DisplayName = "Pumpkins Tier 1"
	},
	["Pumpkins Tier 2"] = {
		productId = 1668607956,
		DisplayName = "Pumpkins Tier 2"
	},
	["Pumpkins Tier 3"] = {
		productId = 1668608165,
		DisplayName = "Pumpkins Tier 3"
	},
	["Pumpkins Tier 4"] = {
		productId = 1668608276,
		DisplayName = "Pumpkins Tier 4"
	},
	["Pumpkins Tier 5"] = {
		productId = 1668608428,
		DisplayName = "Pumpkins Tier 5"
	},
	["Snowflakes Tier 1"] = {
		productId = 2654100077,
		DisplayName = "Snowflakes Tier 1"
	},
	["Snowflakes Tier 2"] = {
		productId = 2654100080,
		DisplayName = "Snowflakes Tier 2"
	},
	["Snowflakes Tier 3"] = {
		productId = 2654100083,
		DisplayName = "Snowflakes Tier 3"
	},
	["Snowflakes Tier 4"] = {
		productId = 2654100079,
		DisplayName = "Snowflakes Tier 4"
	},
	["Snowflakes Tier 5"] = {
		productId = 2654100078,
		DisplayName = "Snowflakes Tier 5"
	},
	["Cookies Tier 1"] = {
		productId = 1712046028,
		DisplayName = "Cookies Tier 1"
	},
	["Cookies Tier 2"] = {
		productId = 1712046381,
		DisplayName = "Cookies Tier 2"
	},
	["Cookies Tier 3"] = {
		productId = 1712046665,
		DisplayName = "Cookies Tier 3"
	},
	["Cookies Tier 4"] = {
		productId = 1712046874,
		DisplayName = "Cookies Tier 4"
	},
	["Cookies Tier 5"] = {
		productId = 1712047173,
		DisplayName = "Cookies Tier 5"
	},
	["Fireworks Tier 1"] = {
		productId = 2690102698,
		DisplayName = "Fireworks Tier 1"
	},
	["Fireworks Tier 2"] = {
		productId = 2690102697,
		DisplayName = "Fireworks Tier 2"
	},
	["Fireworks Tier 3"] = {
		productId = 2690102700,
		DisplayName = "Fireworks Tier 3"
	},
	["Fireworks Tier 4"] = {
		productId = 2690102699,
		DisplayName = "Fireworks Tier 4"
	},
	["Fireworks Tier 5"] = {
		productId = 2690102696,
		DisplayName = "Fireworks Tier 5"
	},
	["Hearts Tier 1"] = {
		productId = 2838793747,
		DisplayName = "Hearts Tier 1"
	},
	["Hearts Tier 2"] = {
		productId = 2838793748,
		DisplayName = "Hearts Tier 2"
	},
	["Hearts Tier 3"] = {
		productId = 2838793746,
		DisplayName = "Hearts Tier 3"
	},
	["Hearts Tier 4"] = {
		productId = 2838793753,
		DisplayName = "Hearts Tier 4"
	},
	["Hearts Tier 5"] = {
		productId = 2838793756,
		DisplayName = "Hearts Tier 5"
	},
	[`{v3.SeasonData.Currency.Name} Tier 1`] = {
		productId = 3269126267,
		DisplayName = `{v3.SeasonData.Currency.Name} Tier 1`
	},
	[`{v3.SeasonData.Currency.Name} Tier 2`] = {
		productId = 3269126269,
		DisplayName = `{v3.SeasonData.Currency.Name} Tier 2`
	},
	[`{v3.SeasonData.Currency.Name} Tier 3`] = {
		productId = 3269126266,
		DisplayName = `{v3.SeasonData.Currency.Name} Tier 3`
	},
	[`{v3.SeasonData.Currency.Name} Tier 4`] = {
		productId = 3269126268,
		DisplayName = `{v3.SeasonData.Currency.Name} Tier 4`
	},
	[`{v3.SeasonData.Currency.Name} Tier 5`] = {
		productId = 3269126270,
		DisplayName = `{v3.SeasonData.Currency.Name} Tier 5`
	},
	GiftSpin1 = {
		productId = 1688228733,
		DisplayName = "1 Wheel Spin"
	},
	GiftSpin2 = {
		productId = 1688229204,
		DisplayName = "5 Wheel Spin"
	},
	GiftSpin3 = {
		productId = 1688229387,
		DisplayName = "10 Wheel Spin"
	},
	GiftThaiSpin1 = {
		productId = 1690066879,
		DisplayName = "Gift x1 Thai Spin"
	},
	GiftThaiSpin10 = {
		productId = 1690066940,
		DisplayName = "Gift x10 Thai Spins"
	},
	["1 Easter Egg"] = {
		productId = 1789229058,
		DisplayName = "1 Easter Egg"
	},
	["10 Easter Eggs"] = {
		productId = 1789229056,
		DisplayName = "10 Easter Eggs"
	},
	GiftBalloons1 = {
		productId = 1741175915,
		DisplayName = "Balloons Tier 1"
	},
	GiftBalloons2 = {
		productId = 1741176005,
		DisplayName = "Balloons Tier 2"
	},
	GiftBalloons3 = {
		productId = 1741176079,
		DisplayName = "Balloons Tier 3"
	},
	GiftBalloons4 = {
		productId = 1741176191,
		DisplayName = "Balloons Tier 4"
	},
	GiftBalloons5 = {
		productId = 1741176270,
		DisplayName = "Balloons Tier 5"
	},
	GiftBrasilRolls1 = {
		productId = 1703479795,
		DisplayName = "1 Brasil Roll"
	},
	GiftBrasilRolls10 = {
		productId = 1703480081,
		DisplayName = "10 Brasil Rolls"
	},
	GiftSeasonPassSpin1 = {
		type = "GiftGacha",
		productId = 3296277563,
		DisplayName = `1 {v4.Gacha}`
	},
	GiftSeasonPassSpin10 = {
		type = "GiftGacha",
		productId = 3296277560,
		DisplayName = `10 {v4.Gacha}`
	},
	GiftSeasonPassSpin50 = {
		type = "GiftGacha",
		productId = 3296277562,
		DisplayName = `50 {v4.Gacha}`
	},
	GiftSeasonPassSpin250 = {
		type = "GiftGacha",
		productId = 3296277561,
		DisplayName = `250 {v4.Gacha}`
	},
	GiftDungeonsSpin_1 = {
		productId = 3263131610,
		DisplayName = "1 Ronin's Spin"
	},
	GiftDungeonsSpin_3 = {
		productId = 3263131612,
		DisplayName = "3 Dungeon Spins"
	},
	GiftDungeonsSpin_10 = {
		productId = 3263131611,
		DisplayName = "10 Dungeon Spins"
	},
	GiftDungeonsSpin_50 = {
		productId = 3263131613,
		DisplayName = "50 Dungeon Spins"
	},
	["Crimson Eclipse"] = {
		type = "Sword",
		productId = 1724944286,
		name = "Crimson Eclipse",
		DisplayName = "Crimson Eclipse",
		Offsale = true
	},
	["Dual Crimson Eclipse"] = {
		type = "Sword",
		productId = 1724944916,
		name = "Dual Crimson Eclipse",
		DisplayName = "Dual Crimson Eclipse",
		Offsale = true
	},
	["Crimson Katana"] = {
		type = "Sword",
		productId = 1726012394,
		name = "Crimson Katana",
		DisplayName = "Crimson Katana",
		Offsale = true
	},
	["Dual Crimson Katana"] = {
		type = "Sword",
		productId = 1726012600,
		name = "Dual Crimson Katana",
		DisplayName = "Dual Crimson Katana",
		Offsale = true
	},
	["Prismatic Harvester"] = {
		type = "Sword",
		productId = 1724947255,
		name = "Prismatic Harvester",
		DisplayName = "Prismatic Harvester",
		Offsale = true
	},
	["Double Sided Prismatic"] = {
		type = "Sword",
		productId = 1724947475,
		name = "Double Sided Prismatic",
		DisplayName = "Double Sided Prismatic",
		Offsale = true
	},
	["Prismatic Katana"] = {
		type = "Sword",
		productId = 1726012746,
		name = "Prismatic Katana",
		DisplayName = "Prismatic Katana",
		Offsale = true
	},
	["Dual Prismatic Katana"] = {
		type = "Sword",
		productId = 1726012822,
		name = "Dual Prismatic Katana",
		DisplayName = "Dual Prismatic Katana",
		Offsale = true
	},
	["Crimson Pack"] = {
		type = "LimitedPack",
		productId = 1724946941,
		DisplayName = "Crimson Pack",
		name = "Crimson Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Crimson Eclipse"
			},
			{
				Type = "Sword",
				ItemName = "Crimson Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Crimson Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote76"
			}
		},
		Offsale = true
	},
	["Dual Crimson Pack"] = {
		type = "LimitedPack",
		productId = 1724946110,
		DisplayName = "Dual Crimson Pack",
		name = "Dual Crimson Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Crimson Eclipse"
			},
			{
				Type = "Sword",
				ItemName = "Dual Crimson Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Crimson Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote77"
			}
		},
		Offsale = true
	},
	["Prismatic Pack"] = {
		type = "LimitedPack",
		productId = 1724947642,
		DisplayName = "Prismatic Pack",
		name = "Prismatic Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Prismatic Harvester"
			},
			{
				Type = "Sword",
				ItemName = "Prismatic Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Prismatic Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote78"
			}
		},
		Offsale = true
	},
	["Double Sided Prismatic Pack"] = {
		type = "LimitedPack",
		productId = 1724948197,
		DisplayName = "Double Sided Prismatic Pack",
		name = "Double Sided Prismatic Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Double Sided Prismatic"
			},
			{
				Type = "Sword",
				ItemName = "Dual Prismatic Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Prismatic Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote79"
			}
		},
		Offsale = true
	},
	["Aetherial Azure Reckoner"] = {
		type = "Sword",
		productId = 1730792701,
		name = "Aetherial Azure Reckoner",
		DisplayName = "Aetherial Azure Reckoner",
		Offsale = true
	},
	["Dual Aetherial Azure Reckoner"] = {
		type = "Sword",
		productId = 1730794928,
		name = "Dual Aetherial Azure Reckoner",
		DisplayName = "Dual Aetherial Azure Reckoner",
		Offsale = true
	},
	["Aetherial Azure Katana"] = {
		type = "Sword",
		productId = 1730796122,
		name = "Aetherial Azure Katana",
		DisplayName = "Aetherial Azure Katana",
		Offsale = true
	},
	["Dual Aetherial Azure Katana"] = {
		type = "Sword",
		productId = 1730797256,
		name = "Dual Aetherial Azure Katana",
		DisplayName = "Dual Aetherial Azure Katana",
		Offsale = true
	},
	["Aetherial Azure Pack"] = {
		type = "LimitedPack",
		productId = 1730798333,
		DisplayName = "Aetherial Azure Pack",
		name = "Aetherial Azure Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Aetherial Azure Reckoner"
			},
			{
				Type = "Sword",
				ItemName = "Aetherial Azure Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Aetherial Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote103"
			}
		},
		Offsale = true
	},
	["Dual Aetherial Azure Pack"] = {
		type = "LimitedPack",
		productId = 1730799400,
		DisplayName = "Dual Aetherial Azure Pack",
		name = "Dual Aetherial Azure Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Aetherial Azure Reckoner"
			},
			{
				Type = "Sword",
				ItemName = "Dual Aetherial Azure Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Aetherial Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote104"
			}
		},
		Offsale = true
	},
	["Nebula Blade"] = {
		type = "LimitedPack",
		productId = 1730800376,
		DisplayName = "Nebula Blade",
		name = "Nebula Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Nebula Blade"
			}
		},
		Offsale = true
	},
	["Dual Nebula Blade + Nebula Explosion"] = {
		type = "LimitedPack",
		productId = 1730801450,
		DisplayName = "Dual Nebula Blade + Nebula Explosion",
		name = "Dual Nebula Blade + Nebula Explosion",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Nebula Blade"
			},
			{
				Type = "Explosion",
				ItemName = "Nebulas Explosion"
			}
		},
		Offsale = true
	},
	["Crystal Greatblade"] = {
		type = "LimitedPack",
		productId = 1736295071,
		DisplayName = "Crystal Greatblade",
		name = "Crystal Greatblade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Crystal Greatblade"
			},
			{
				Type = "Emote",
				ItemName = "Emote111"
			}
		},
		Offsale = true
	},
	["Dual Crystal Greatblade"] = {
		type = "LimitedPack",
		productId = 1736295589,
		DisplayName = "Dual Crystal Greatblade",
		name = "Dual Crystal Greatblade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Crystal Greatblade"
			},
			{
				Type = "Emote",
				ItemName = "Emote112"
			}
		},
		Offsale = true
	},
	["Crystal Reaperblade"] = {
		type = "Sword",
		productId = 1736756615,
		name = "Crystal Reaperblade",
		DisplayName = "Crystal Reaperblade",
		Offsale = true
	},
	["Dual Crystal Reaperblade"] = {
		type = "Sword",
		productId = 1736756762,
		name = "Dual Crystal Reaperblade",
		DisplayName = "Dual Crystal Reaperblade",
		Offsale = true
	},
	["Crystal Sword Pack"] = {
		type = "LimitedPack",
		productId = 1736759466,
		DisplayName = "Crystal Sword Pack",
		name = "Crystal Sword Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Crystal Greatblade"
			},
			{
				Type = "Sword",
				ItemName = "Crystal Reaperblade"
			},
			{
				Type = "Explosion",
				ItemName = "Crystal Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote113"
			}
		},
		Offsale = true
	},
	["Dual Crystal Sword Pack"] = {
		type = "LimitedPack",
		productId = 1736760478,
		DisplayName = "Dual Crystal Sword Pack",
		name = "Dual Crystal Sword Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Crystal Greatblade"
			},
			{
				Type = "Sword",
				ItemName = "Dual Crystal Reaperblade"
			},
			{
				Type = "Explosion",
				ItemName = "Crystal Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote114"
			}
		},
		Offsale = true
	},
	["Nebula Katana"] = {
		type = "LimitedPack",
		productId = 1741791635,
		DisplayName = "Nebula Katana",
		name = "Nebula Katana",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Nebula Katana"
			}
		},
		Offsale = true
	},
	["Dual Nebula Katana + Dark Matter Explosion"] = {
		type = "LimitedPack",
		productId = 1741792665,
		DisplayName = "Dual Nebula Katana + Dark Matter Explosion",
		name = "Dual Nebula Katana + Dark Matter Explosion",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Nebula Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Dark Matter Explosion"
			}
		},
		Offsale = true
	},
	["Nightfall Violin"] = {
		type = "LimitedPack",
		productId = 1741879642,
		DisplayName = "Nightfall Violin",
		name = "Nightfall Violin",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Nightfall Violin"
			},
			{
				Type = "Emote",
				ItemName = "Emote122"
			}
		},
		Offsale = true
	},
	["Nightfall Violin Pack"] = {
		type = "LimitedPack",
		productId = 1741793094,
		DisplayName = "Nightfall Violin Pack",
		name = "Nightfall Violin Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Nightfall Violin"
			},
			{
				Type = "Sword",
				ItemName = "Dual Nebula Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Violin Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote122"
			}
		},
		Offsale = true
	},
	["Voltfire Lash"] = {
		type = "LimitedPack",
		productId = 1746026529,
		DisplayName = "Voltfire Lash",
		name = "Voltfire Lash",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Voltfire Lash"
			},
			{
				Type = "Emote",
				ItemName = "Emote124"
			}
		},
		Offsale = true
	},
	["Dual Voltfire Lash"] = {
		type = "LimitedPack",
		productId = 1746026807,
		DisplayName = "Dual Voltfire Lash",
		name = "Dual Voltfire Lash",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Voltfire Lash"
			},
			{
				Type = "Emote",
				ItemName = "Emote125"
			}
		},
		Offsale = true
	},
	["Voltfire Blade"] = {
		type = "Sword",
		productId = 1746027856,
		name = "Voltfire Blade",
		DisplayName = "Voltfire Blade",
		Offsale = true
	},
	["Dual Voltfire Blade"] = {
		type = "Sword",
		productId = 1746028146,
		name = "Dual Voltfire Blade",
		DisplayName = "Dual Voltfire Blade",
		Offsale = true
	},
	["Voltfire Pack"] = {
		type = "LimitedPack",
		productId = 1746028955,
		DisplayName = "Voltfire Pack",
		name = "Voltfire Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Voltfire Blade"
			},
			{
				Type = "Sword",
				ItemName = "Voltfire Lash"
			},
			{
				Type = "Explosion",
				ItemName = "Voltfire Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote124"
			}
		},
		Offsale = true
	},
	["Dual Voltfire Pack"] = {
		type = "LimitedPack",
		productId = 1746029250,
		DisplayName = "Dual Voltfire Pack",
		name = "Dual Voltfire Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Voltfire Blade"
			},
			{
				Type = "Sword",
				ItemName = "Dual Voltfire Lash"
			},
			{
				Type = "Explosion",
				ItemName = "Voltfire Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote125"
			}
		},
		Offsale = true
	},
	["Love Blade"] = {
		type = "Sword",
		productId = 1751516990,
		name = "Love Blade",
		DisplayName = "Love Blade",
		Offsale = true
	},
	["Dual Love Blade"] = {
		type = "Sword",
		productId = 1751517255,
		name = "Dual Love Blade",
		DisplayName = "Dual Love Blade",
		Offsale = true
	},
	["Cupid's Bow"] = {
		type = "LimitedPack",
		productId = 1751517619,
		DisplayName = "Cupid's Bow",
		name = "Cupid's Bow",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Cupid's Bow"
			},
			{
				Type = "Emote",
				ItemName = "Emote142"
			}
		},
		Offsale = true
	},
	["Single Valentine's Pack"] = {
		type = "LimitedPack",
		productId = 1751517957,
		DisplayName = "Single Valentine's Pack",
		name = "Single Valentine's Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Love Blade"
			},
			{
				Type = "Sword",
				ItemName = "Cupid's Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Heart Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote142"
			}
		},
		Offsale = true
	},
	["Dual Valentine's Pack"] = {
		type = "LimitedPack",
		productId = 1751518379,
		DisplayName = "Dual Valentine's Pack",
		name = "Dual Valentine's Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Love Blade"
			},
			{
				Type = "Sword",
				ItemName = "Cupid's Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Heart Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote142"
			}
		},
		Offsale = true
	},
	["Lunar Parasol"] = {
		type = "LimitedPack",
		productId = 1751518668,
		DisplayName = "Lunar Parasol",
		name = "Lunar Parasol",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Lunar Parasol"
			},
			{
				Type = "Emote",
				ItemName = "Emote141"
			},
			{
				Type = "Explosion",
				ItemName = "Lunar Burst"
			}
		},
		Offsale = true
	},
	["DuoPass Golden Present"] = {
		productId = 1754671061,
		DisplayName = "Summer's Golden Present"
	},
	DuoPassBundle = {
		type = "LimitedPack",
		productId = 1754799091,
		DisplayName = "Valentine's Bundle",
		name = "Valentine's Bundle",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Rose Wand"
			},
			{
				Type = "Emote",
				ItemName = "Emote144"
			},
			{
				Type = "Explosion",
				ItemName = "Rose Bloom"
			}
		}
	},
	["Shadow Dagger"] = {
		type = "Sword",
		productId = 1756569920,
		name = "Shadow Dagger",
		DisplayName = "Shadow Dagger",
		Offsale = true
	},
	["Dual Shadow Daggers"] = {
		type = "LimitedPack",
		productId = 1756570732,
		DisplayName = "Dual Shadow Daggers",
		name = "Dual Shadow Daggers",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Shadow Daggers"
			},
			{
				Type = "Explosion",
				ItemName = "Shadow Vortex"
			}
		},
		Offsale = true
	},
	["Shadow Mirage"] = {
		type = "LimitedPack",
		productId = 1756572027,
		DisplayName = "Shadow Mirage",
		name = "Shadow Mirage",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Shadow Mirage"
			},
			{
				Type = "Emote",
				ItemName = "Emote152"
			},
			{
				Type = "Explosion",
				ItemName = "Shadow Vortex"
			}
		},
		Offsale = true
	},
	["Dual Shadow Mirage"] = {
		type = "LimitedPack",
		productId = 1756572333,
		DisplayName = "Dual Shadow Mirage",
		name = "Dual Shadow Mirage",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Shadow Mirage"
			},
			{
				Type = "Emote",
				ItemName = "Emote153"
			},
			{
				Type = "Explosion",
				ItemName = "Shadow Vortex"
			}
		},
		Offsale = true
	},
	["Shadow Pack"] = {
		type = "LimitedPack",
		productId = 1756573002,
		DisplayName = "Shadow Pack",
		name = "Shadow Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Shadow Dagger"
			},
			{
				Type = "Sword",
				ItemName = "Shadow Mirage"
			},
			{
				Type = "Emote",
				ItemName = "Emote152"
			},
			{
				Type = "Explosion",
				ItemName = "Shadow Vortex"
			}
		},
		Offsale = true
	},
	["Dual Shadow Pack"] = {
		type = "LimitedPack",
		productId = 1756573339,
		DisplayName = "Dual Shadow Pack",
		name = "Dual Shadow Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Shadow Daggers"
			},
			{
				Type = "Sword",
				ItemName = "Dual Shadow Mirage"
			},
			{
				Type = "Emote",
				ItemName = "Emote153"
			},
			{
				Type = "Explosion",
				ItemName = "Shadow Vortex"
			}
		},
		Offsale = true
	},
	["Crystal Hammer"] = {
		type = "Sword",
		productId = 1761768424,
		name = "Crystal Hammer",
		DisplayName = "Crystal Hammer",
		Offsale = true
	},
	["Dual Crystal Hammer"] = {
		type = "LimitedPack",
		productId = 1761768825,
		DisplayName = "Dual Crystal Hammer",
		name = "Dual Crystal Hammer",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Crystal Hammer"
			},
			{
				Type = "Explosion",
				ItemName = "Crystal Reveal"
			}
		},
		Offsale = true
	},
	["Crystal Scissors"] = {
		type = "LimitedPack",
		productId = 1761769056,
		DisplayName = "Crystal Scissors",
		name = "Crystal Scissors",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Crystal Scissors"
			},
			{
				Type = "Emote",
				ItemName = "Emote158"
			},
			{
				Type = "Explosion",
				ItemName = "Crystal Reveal"
			}
		},
		Offsale = true
	},
	["Crystal Pack"] = {
		type = "LimitedPack",
		productId = 1761770033,
		DisplayName = "Crystal Pack",
		name = "Crystal Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Crystal Scissors"
			},
			{
				Type = "Sword",
				ItemName = "Dual Crystal Hammer"
			},
			{
				Type = "Emote",
				ItemName = "Emote158"
			},
			{
				Type = "Explosion",
				ItemName = "Crystal Reveal"
			}
		},
		Offsale = true
	},
	["Void Blade"] = {
		type = "LimitedPack",
		productId = 1766541218,
		DisplayName = "Void Blade",
		name = "Void Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Void Blade"
			}
		},
		Offsale = true
	},
	["Dual Void Blades"] = {
		type = "LimitedPack",
		productId = 1766542346,
		DisplayName = "Dual Void Blades",
		name = "Dual Void Blades",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Void Blades"
			},
			{
				Type = "Explosion",
				ItemName = "Void Blast"
			}
		},
		Offsale = true
	},
	["Void Scythe"] = {
		type = "LimitedPack",
		productId = 1766541969,
		DisplayName = "Void Scythe",
		name = "Void Scythe",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Void Scythe"
			},
			{
				Type = "Emote",
				ItemName = "Emote161"
			}
		},
		Offsale = true
	},
	["Dual Void Scythes"] = {
		type = "LimitedPack",
		productId = 1766547663,
		DisplayName = "Dual Void Blades",
		name = "Dual Void Blades",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Void Scythes"
			},
			{
				Type = "Explosion",
				ItemName = "Void Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote162"
			}
		},
		Offsale = true
	},
	["Void Pack"] = {
		type = "LimitedPack",
		productId = 1766543092,
		DisplayName = "Void Pack",
		name = "Void Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Void Scythe"
			},
			{
				Type = "Sword",
				ItemName = "Void Blade"
			},
			{
				Type = "Explosion",
				ItemName = "Void Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote161"
			}
		},
		Offsale = true
	},
	["Dual Void Pack"] = {
		type = "LimitedPack",
		productId = 1766543688,
		DisplayName = "Dual Void Pack",
		name = "Dual Void Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Void Scythes"
			},
			{
				Type = "Sword",
				ItemName = "Dual Void Blades"
			},
			{
				Type = "Explosion",
				ItemName = "Void Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote162"
			}
		},
		Offsale = true
	},
	["Stardust Katana"] = {
		type = "LimitedPack",
		productId = 1771871362,
		DisplayName = "Stardust Katana",
		name = "Stardust Katana",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stardust Katana"
			}
		},
		Offsale = true
	},
	["Dual Stardust Katana"] = {
		type = "LimitedPack",
		productId = 1771872476,
		DisplayName = "Dual Stardust Katana",
		name = "Dual Stardust Katana",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Stardust Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Stardust Beam"
			},
			{
				Type = "Emote",
				ItemName = "Emote182"
			}
		},
		Offsale = true
	},
	["Stardust Bow"] = {
		type = "LimitedPack",
		productId = 1771873866,
		DisplayName = "Stardust Bow",
		name = "Stardust Bow",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stardust Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Stardust Beam"
			},
			{
				Type = "Emote",
				ItemName = "Emote178"
			}
		},
		Offsale = true
	},
	["Stardust Pack"] = {
		type = "LimitedPack",
		productId = 1771876937,
		DisplayName = "Stardust Pack",
		name = "Stardust Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stardust Katana"
			},
			{
				Type = "Sword",
				ItemName = "Stardust Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Stardust Beam"
			},
			{
				Type = "Emote",
				ItemName = "Emote178"
			}
		},
		Offsale = true
	},
	["Dual Stardust Pack"] = {
		type = "LimitedPack",
		productId = 1771876010,
		DisplayName = "Stardust Pack",
		name = "Stardust Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Stardust Katana"
			},
			{
				Type = "Sword",
				ItemName = "Stardust Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Stardust Beam"
			},
			{
				Type = "Emote",
				ItemName = "Emote178"
			},
			{
				Type = "Emote",
				ItemName = "Emote182"
			}
		},
		Offsale = true
	},
	["Princess Katana"] = {
		type = "LimitedPack",
		productId = 1776904290,
		DisplayName = "Princess Katana",
		name = "Princess Katana",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Princess Katana"
			}
		},
		Offsale = true
	},
	["Dual Princess Katana"] = {
		type = "LimitedPack",
		productId = 1776904287,
		DisplayName = "Dual Princess Katana",
		name = "Dual Princess Katana",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Princess Katana"
			},
			{
				Type = "Explosion",
				ItemName = "Princess Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote212"
			}
		},
		Offsale = true
	},
	["King Blade"] = {
		type = "LimitedPack",
		productId = 1776904288,
		DisplayName = "King Blade",
		name = "King Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "King Blade"
			},
			{
				Type = "Explosion",
				ItemName = "King Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote214"
			}
		},
		Offsale = true
	},
	["Queen Blade"] = {
		type = "LimitedPack",
		productId = 1776904300,
		DisplayName = "Queen Blade",
		name = "Queen Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Queen Blade"
			},
			{
				Type = "Explosion",
				ItemName = "Queen Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote213"
			}
		},
		Offsale = true
	},
	["Dual Royal Blades"] = {
		type = "LimitedPack",
		productId = 1776904294,
		DisplayName = "Dual Royal Blades",
		name = "Dual Royal Blades",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Royal Blades"
			},
			{
				Type = "Explosion",
				ItemName = "Royal Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote215"
			}
		},
		Offsale = true
	},
	["Stellar Blade"] = {
		type = "LimitedPack",
		productId = 1783956699,
		DisplayName = "Stellar Blade",
		name = "Stellar Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stellar Blade"
			}
		},
		Offsale = true
	},
	["Dual Stellar Blade"] = {
		type = "LimitedPack",
		productId = 1783957381,
		DisplayName = "Dual Stellar Blade",
		name = "Dual Stellar Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Stellar Blade"
			},
			{
				Type = "Emote",
				ItemName = "Emote223"
			}
		},
		Offsale = true
	},
	["Stellar Revolver"] = {
		type = "LimitedPack",
		productId = 1783957920,
		DisplayName = "Stellar Revolver",
		name = "Stellar Revolver",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stellar Revolver"
			},
			{
				Type = "Explosion",
				ItemName = "Planetary Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote221"
			}
		},
		Offsale = true
	},
	["Dual Stellar Revolver"] = {
		type = "LimitedPack",
		productId = 1783958461,
		DisplayName = "Dual Stellar Revolver",
		name = "Dual Stellar Revolver",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Stellar Revolver"
			},
			{
				Type = "Explosion",
				ItemName = "Triple Planetary Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote222"
			}
		},
		Offsale = true
	},
	["Stellar Pack"] = {
		type = "LimitedPack",
		productId = 1783959106,
		DisplayName = "Stellar Pack",
		name = "Stellar Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Stellar Revolver"
			},
			{
				Type = "Sword",
				ItemName = "Stellar Blade"
			},
			{
				Type = "Explosion",
				ItemName = "Planetary Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote221"
			}
		},
		Offsale = true
	},
	["Dual Stellar Pack"] = {
		type = "LimitedPack",
		productId = 1783959684,
		DisplayName = "Dual Stellar Pack",
		name = "Dual Stellar Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Stellar Blade"
			},
			{
				Type = "Sword",
				ItemName = "Dual Stellar Revolver"
			},
			{
				Type = "Explosion",
				ItemName = "Triple Planetary Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote222"
			},
			{
				Type = "Emote",
				ItemName = "Emote223"
			}
		},
		Offsale = true
	},
	["Blossom Blade"] = {
		type = "LimitedPack",
		productId = 1790919853,
		DisplayName = "Blossom Blade",
		name = "Blossom Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Blossom Blade"
			}
		},
		Offsale = true
	},
	["Dual Blossom Blade"] = {
		type = "LimitedPack",
		productId = 1790920489,
		DisplayName = "Dual Blossom Blade",
		name = "Dual Blossom Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Blossom Blade"
			},
			{
				Type = "Emote",
				ItemName = "Emote237"
			},
			{
				Type = "Explosion",
				ItemName = "Blossom Season"
			}
		},
		Offsale = true
	},
	["Blossom Scythe"] = {
		type = "LimitedPack",
		productId = 1790926925,
		DisplayName = "Blossom Scythe",
		name = "Blossom Scythe",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Blossom Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Cherry Blossom Tree"
			},
			{
				Type = "Emote",
				ItemName = "Emote238"
			}
		},
		Offsale = true
	},
	["Dual Blossom Scythe"] = {
		type = "LimitedPack",
		productId = 1790927449,
		DisplayName = "Dual Blossom Scythe",
		name = "Dual Blossom Scythe",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Blossom Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Cherry Blossom Tree"
			},
			{
				Type = "Emote",
				ItemName = "Emote239"
			}
		},
		Offsale = true
	},
	["Blossom Pack"] = {
		type = "LimitedPack",
		productId = 1790921192,
		DisplayName = "Blossom Pack",
		name = "Blossom Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Blossom Blade"
			},
			{
				Type = "Sword",
				ItemName = "Blossom Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Blossom Season"
			},
			{
				Type = "Emote",
				ItemName = "Emote238"
			}
		},
		Offsale = true
	},
	["Dual Blossom Pack"] = {
		type = "LimitedPack",
		productId = 1790922982,
		DisplayName = "Dual Blossom Pack",
		name = "Dual Blossom Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Blossom Blade"
			},
			{
				Type = "Sword",
				ItemName = "Dual Blossom Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Cherry Blossom Tree"
			},
			{
				Type = "Emote",
				ItemName = "Emote237"
			},
			{
				Type = "Emote",
				ItemName = "Emote239"
			}
		},
		Offsale = true
	},
	["Demonic Blade"] = {
		type = "LimitedPack",
		productId = 1798013787,
		DisplayName = "Demonic Blade",
		name = "Demonic Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Demonic Blade"
			}
		},
		Offsale = true
	},
	["Dual Demonic Blade"] = {
		type = "LimitedPack",
		productId = 1798015213,
		DisplayName = "Dual Demonic Blade",
		name = "Dual Demonic Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Demonic Blade"
			},
			{
				Type = "Emote",
				ItemName = "Emote250"
			},
			{
				Type = "Explosion",
				ItemName = "Demonic Chain"
			}
		},
		Offsale = true
	},
	["Demonic Scythe"] = {
		type = "LimitedPack",
		productId = 1798016051,
		DisplayName = "Demonic Scythe",
		name = "Demonic Scythe",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Demonic Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Summon Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote252"
			}
		},
		Offsale = true
	},
	["Dual Demonic Scythe"] = {
		type = "LimitedPack",
		productId = 1798017417,
		DisplayName = "Dual Demonic Scythe",
		name = "Dual Demonic Scythe",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Demonic Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Summon Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote251"
			}
		},
		Offsale = true
	},
	["Demonic Pack"] = {
		type = "LimitedPack",
		productId = 1798019309,
		DisplayName = "Demonic Pack",
		name = "Demonic Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Demonic Blade"
			},
			{
				Type = "Sword",
				ItemName = "Demonic Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Demonic Chain"
			},
			{
				Type = "Emote",
				ItemName = "Emote252"
			}
		},
		Offsale = true
	},
	["Dual Demonic Pack"] = {
		type = "LimitedPack",
		productId = 1798020037,
		DisplayName = "Dual Demonic Pack",
		name = "Dual Demonic Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Demonic Blade"
			},
			{
				Type = "Sword",
				ItemName = "Dual Demonic Scythe"
			},
			{
				Type = "Explosion",
				ItemName = "Summon Blast"
			},
			{
				Type = "Emote",
				ItemName = "Emote251"
			},
			{
				Type = "Emote",
				ItemName = "Emote250"
			}
		},
		Offsale = true
	},
	["Angel Greatsword"] = {
		type = "LimitedPack",
		productId = 1805232944,
		DisplayName = "Angel Greatsword",
		name = "Angel Greatsword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Angel Greatsword"
			},
			{
				Type = "Emote",
				ItemName = "Emote269"
			},
			{
				Type = "Explosion",
				ItemName = "Judgement"
			}
		},
		Offsale = true
	},
	["Devil Greatsword"] = {
		type = "LimitedPack",
		productId = 1805232947,
		DisplayName = "Devil Greatsword",
		name = "Devil Greatsword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Devil Greatsword"
			},
			{
				Type = "Emote",
				ItemName = "Emote270"
			},
			{
				Type = "Explosion",
				ItemName = "Devil's Curse"
			}
		},
		Offsale = true
	},
	["Dual Eternal Greatsword"] = {
		type = "LimitedPack",
		productId = 1805232949,
		DisplayName = "Dual Eternal Greatsword",
		name = "Dual Eternal Greatsword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Eternal Greatsword"
			},
			{
				Type = "Emote",
				ItemName = "Emote271"
			},
			{
				Type = "Explosion",
				ItemName = "Eternal"
			}
		},
		Offsale = true
	},
	["Heavenly Sword"] = {
		type = "LimitedPack",
		productId = 1805232938,
		DisplayName = "Heavenly Sword",
		name = "Heavenly Sword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Heavenly Sword"
			}
		},
		Offsale = true
	},
	["Dual Heavenly Sword"] = {
		type = "LimitedPack",
		productId = 1805232939,
		DisplayName = "Dual Heavenly Sword",
		name = "Dual Heavenly Sword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Heavenly Sword"
			},
			{
				Type = "Emote",
				ItemName = "Emote268"
			},
			{
				Type = "Explosion",
				ItemName = "Heavenly Explosion"
			}
		},
		Offsale = true
	},
	["Heavenly Chakram"] = {
		type = "LimitedPack",
		productId = 1805232948,
		DisplayName = "Heavenly Chakram",
		name = "Heavenly Chakram",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Heavenly Chakram"
			},
			{
				Type = "Emote",
				ItemName = "Emote253"
			},
			{
				Type = "Explosion",
				ItemName = "Heavenly Explosion"
			}
		},
		Offsale = true
	},
	["Heavenly Pack"] = {
		type = "LimitedPack",
		productId = 1805232937,
		DisplayName = "Heavenly Pack",
		name = "Heavenly Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Heavenly Sword"
			},
			{
				Type = "Sword",
				ItemName = "Heavenly Chakram"
			},
			{
				Type = "Explosion",
				ItemName = "Heavenly Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote253"
			}
		},
		Offsale = true
	},
	["Dual Heavenly Pack"] = {
		type = "LimitedPack",
		productId = 1805232940,
		DisplayName = "Dual Heavenly Pack",
		name = "Dual Heavenly Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Heavenly Sword"
			},
			{
				Type = "Sword",
				ItemName = "Heavenly Chakram"
			},
			{
				Type = "Explosion",
				ItemName = "Heavenly Explosion"
			},
			{
				Type = "Emote",
				ItemName = "Emote268"
			},
			{
				Type = "Emote",
				ItemName = "Emote253"
			}
		},
		Offsale = true
	},
	["Desert Blade"] = {
		type = "LimitedPack",
		productId = 1811876592,
		DisplayName = "Desert Blade",
		name = "Desert Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Desert Blade"
			}
		},
		Offsale = true
	},
	["Dual Desert Blade"] = {
		type = "LimitedPack",
		productId = 1811876596,
		DisplayName = "Dual Desert Blade",
		name = "Dual Desert Blade",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Desert Blade"
			},
			{
				Type = "Emote",
				ItemName = "Emote281"
			},
			{
				Type = "Explosion",
				ItemName = "Sand Dust"
			}
		},
		Offsale = true
	},
	["Desert Claws"] = {
		type = "LimitedPack",
		productId = 1811876588,
		DisplayName = "Desert Claws",
		name = "Desert Claws",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Desert Claws"
			},
			{
				Type = "Emote",
				ItemName = "Emote283"
			},
			{
				Type = "Explosion",
				ItemName = "Pyramid Scheme"
			}
		},
		Offsale = true
	},
	["Desert Pack"] = {
		type = "LimitedPack",
		productId = 1811876594,
		DisplayName = "Desert Pack",
		name = "Desert Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Desert Claws"
			},
			{
				Type = "Sword",
				ItemName = "Desert Blade"
			},
			{
				Type = "Emote",
				ItemName = "Emote281"
			},
			{
				Type = "Explosion",
				ItemName = "Sand Dust"
			}
		},
		Offsale = true
	},
	["Dual Desert Pack"] = {
		type = "LimitedPack",
		productId = 1811876586,
		DisplayName = "Dual Desert Pack",
		name = "Dual Desert Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Desert Claws"
			},
			{
				Type = "Sword",
				ItemName = "Dual Desert Blade"
			},
			{
				Type = "Explosion",
				ItemName = "Pyramid Scheme"
			},
			{
				Type = "Emote",
				ItemName = "Emote281"
			},
			{
				Type = "Emote",
				ItemName = "Emote283"
			}
		},
		Offsale = true
	},
	["Astral Sword"] = {
		type = "LimitedPack",
		productId = 1817056166,
		DisplayName = "Astral Sword",
		name = "Astral Sword",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Astral Sword"
			}
		},
		Offsale = true
	},
	["Dual Astral Swords"] = {
		type = "LimitedPack",
		productId = 1817058723,
		DisplayName = "Dual Astral Swords",
		name = "Dual Astral Swords",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Astral Swords"
			},
			{
				Type = "Emote",
				ItemName = "Emote296"
			},
			{
				Type = "Explosion",
				ItemName = "Astral Sky"
			}
		},
		Offsale = true
	},
	["Astral Bow"] = {
		type = "LimitedPack",
		productId = 1817059500,
		DisplayName = "Astral Bow",
		name = "Astral Bow",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Astral Bow"
			},
			{
				Type = "Emote",
				ItemName = "Emoet297"
			},
			{
				Type = "Explosion",
				ItemName = "Astral Moon"
			}
		},
		Offsale = true
	},
	["Astral Pack"] = {
		type = "LimitedPack",
		productId = 1817060214,
		DisplayName = "Astral Pack",
		name = "Astral Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Astral Sword"
			},
			{
				Type = "Sword",
				ItemName = "Astral Bow"
			},
			{
				Type = "Emote",
				ItemName = "Emote297"
			},
			{
				Type = "Explosion",
				ItemName = "Astral Sky"
			}
		},
		Offsale = true
	},
	["Dual Astral Pack"] = {
		type = "LimitedPack",
		productId = 1817062393,
		DisplayName = "Dual Astral Pack",
		name = "Dual Astral Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Dual Astral Swords"
			},
			{
				Type = "Sword",
				ItemName = "Astral Bow"
			},
			{
				Type = "Explosion",
				ItemName = "Astral Moon"
			},
			{
				Type = "Emote",
				ItemName = "Emote297"
			},
			{
				Type = "Emote",
				ItemName = "Emote296"
			}
		},
		Offsale = true
	},
	["Summer Pack"] = {
		type = "LimitedPack",
		productId = 1865615834,
		DisplayName = "Summer Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Eternal Waveblade"
			},
			{
				Type = "Explosion",
				ItemName = "Kraken's Embrace"
			},
			{
				Type = "Emote",
				ItemName = "Emote423"
			}
		},
		Offsale = true
	},
	["Winter Royale Pack"] = {
		type = "LimitedPack",
		productId = 2669574287,
		DisplayName = "Winter Royale Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Glacial Crown"
			},
			{
				Type = "Explosion",
				ItemName = "Crown Burst"
			},
			{
				Type = "Emote",
				ItemName = v.createEmoteReward("Royal Toast").Value
			}
		},
		Offsale = v5.getRecentLTM().Id ~= "WinterRoyale" or DateTime.now().UnixTimestamp > v5.getLTM("WinterRoyale").DateEndTime.UnixTimestamp
	},
	["Fates Pack"] = {
		type = "LimitedPack",
		productId = 2710643456,
		DisplayName = "Fates Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Glacial Crown"
			},
			{
				Type = "Explosion",
				ItemName = "Crown Burst"
			},
			{
				Type = "Emote",
				ItemName = v.createEmoteReward("Royal Toast").Value
			}
		},
		Offsale = v5.getRecentLTM().Id ~= "Fates" or DateTime.now().UnixTimestamp > v5.getLTM("Fates").DateEndTime.UnixTimestamp
	},
	["Flying Pack"] = {
		type = "LimitedPack",
		productId = 3234123577,
		DisplayName = "Zero Gravity Pack",
		Rewards = {
			{
				Type = "Sword",
				ItemName = "Shackled Celestial"
			},
			{
				Type = "Emote",
				ItemName = "Crown Burst"
			},
			{
				Type = "Emote",
				ItemName = v.createEmoteReward("Cloud 9").Value
			}
		},
		Offsale = v5.getRecentLTM().Id ~= "Flying" or DateTime.now().UnixTimestamp > v5.getLTM("Flying").DateEndTime.UnixTimestamp
	},
	["1 Resolution Rumble Spin"] = {
		productId = 2696037722,
		DisplayName = "1 Resolution Rumble Spin"
	},
	["10 Resolution Rumble Spins"] = {
		productId = 2696037721,
		DisplayName = "10 Resolution Rumble Spins"
	},
	ResetTournamentEventStrikes = {
		productId = 3448879410,
		DisplayName = "Reset Strikes",
		ServerOnly = true
	}
}
local v7 = require3(ReplicatedStorage2.Shared.BlackFridayPackData)
local blackFridayPack = {
	type = "LimitedPack",
	productId = 2665080001,
	DisplayName = "Black Friday Pack",
	Rewards = {}
}

for _, reward in v7.Rewards do
	table.insert(blackFridayPack.Rewards, {
		Type = reward.Type,
		ItemName = reward.Value
	})
end

task.delay(math.max(v7.EndTime.UnixTimestamp + 86400 - DateTime.now().UnixTimestamp, 0), function()
	blackFridayPack.Offsale = true
end)
v6.BlackFridayPack = blackFridayPack
local v9 = require3(ReplicatedStorage2.Shared.ValentinesBundle)

for _, bundle in v9.Bundles do
	local v10 = {
		type = "LimitedPack",
		productId = bundle.GiftProductId,
		name = bundle.GiftName,
		DisplayName = bundle.GiftName,
		Rewards = {}
	}

	for _, reward in bundle.Rewards do
		table.insert(v10.Rewards, {
			Type = reward.Type,
			ItemName = reward.Value
		})
	end

	task.delay(math.max(v9.EndTime.UnixTimestamp - DateTime.now().UnixTimestamp + 3600, 0), function()
		v10.Offsale = true
	end)
	v6[bundle.GiftName] = v10
end

local v10 = require3(ReplicatedStorage2.Shared.SantaMarket.SantaMarketData)

for _, item in v10.Items do
	local v11 = {
		type = item.Reward.Type,
		productId = item.GiftDevProduct,
		name = item.Reward.Value,
		DisplayName = item.Reward.DisplayName
	}
	task.delay(math.max(v10.EndTimestamp - DateTime.now().UnixTimestamp, 0), function()
		v11.Offsale = true
	end)
	v6[item.Reward.DisplayName] = v11
end

for k, crate in require3(ReplicatedStorage2.Shared.SealCrate.SealCrates).Crates do
	if not crate.GiftDevProducts then
		continue
	end

	for k2, giftDevProduct in crate.GiftDevProducts do
		v6[`Seal{k}_{k2}`] = {
			type = "SealCrate",
			productId = giftDevProduct,
			name = `Seal{k}`,
			DisplayName = `{k2}{k == "Chroma" and "" or k} Slime Crates`
		}
	end
end

for _, item in require3(ReplicatedStorage2.Shared.Merchant.MerchantFinisherData).Items do
	local v11 = {
		type = item.Reward.Type,
		productId = item.GiftDevProduct,
		name = item.Reward.Value,
		DisplayName = item.Reward.DisplayName,
		ServerOnly = true
	}
	v6[item.Reward.DisplayName] = v11
end

local v11 = require3(ReplicatedStorage2.Shared.LimitedTimePackData)

for k, v12 in v11 do
	for k2, option in v12.options do
		local v13 = {
			type = "LimitedTimePack",
			productId = option.giftProduct,
			name = v12.name,
			DisplayName = v12.name,
			Rewards = {},
			Offsale = workspace:GetServerTimeNow() > v12.endTimestamp
		}

		for _, reward in v12.rewards do
			table.insert(v13.Rewards, {
				Type = reward.Type,
				ItemName = reward.Value
			})
		end

		v6[`{k}_{k2}`] = v13
	end
end

local v12 = require3(ReplicatedStorage2.Shared.LimitedSwordPacksData)
local isServer = RunService:IsServer()
RunService:IsClient()
local v13

if isServer then
	local ServerScriptService = game:GetService("ServerScriptService")
	v13 = require3(ServerScriptService.Game.CoreGameModules.FFlagServer)
else
	v13 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStartDate(p)
	return p.FFlagStartTime and v13:GetKey(p.FFlagStartTime) or p.RootFFlagStartTime and v13:GetKey(p.RootFFlagStartTime) or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEndDate(p)
	return p.FFlagEndTime and v13:GetKey(p.FFlagEndTime) or p.RootFFlagEndTime and v13:GetKey(p.RootFFlagEndTime) or 0
end

for _, v14 in pairs(v12) do
	local v15 = {}

	for _, reward in pairs(v14.Rewards) do
		for _, reward2 in pairs(reward.Rewards) do
			local giftId = reward2.GiftId
			local giftName = reward2.GiftName
			local item = reward2.Item

			if not (giftId and giftName and item and item.Type == "List") then
				continue
			end

			local rewards = {}

			for _, v17 in item.Value do
				table.insert(rewards, {
					Type = v17.Type,
					ItemName = v17.Value
				})
			end

			local v17 = {
				type = "LimitedPack",
				productId = giftId,
				DisplayName = giftName,
				name = giftName,
				Rewards = rewards
			}
			v6[giftName] = v17
			table.insert(v15, v17)
		end
	end

	if not (#v15 > 0) then
		continue
	end

	local offsale = false
	local v17 = v14
	local v18 = v15

	local function updateOffsale()
		if not v13:IsDataReady() then
			return
		end

		local unixTimestamp = DateTime.now().UnixTimestamp
		local v20

		if unixTimestamp < getStartDate(v17) then
			v20 = true
		else
			v20 = getEndDate(v17) <= unixTimestamp
		end

		if offsale == v20 then
			return
		end

		offsale = v20

		for k, v21 in v18 do
			v21.Offsale = offsale
		end
	end

	v13.DataUpdatedEvent:Connect(updateOffsale)

	if v13.DataReadyEvent then
		v13.DataReadyEvent:Connect(updateOffsale)
	end

	task.spawn(updateOffsale)
end

return table.freeze(v6)