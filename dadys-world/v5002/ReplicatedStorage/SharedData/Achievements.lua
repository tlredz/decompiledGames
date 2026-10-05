local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))
local CATEGORIES = {
	TEST = "Test",
	DISTANCE = "Distance",
	EXTRACT = "Extract",
	FINDITEM = "FindItem",
	NICHE = "Niche",
	HOLIDAY = "Holiday",
	ICHORJAR = "IchorJar",
	EARNICHOR = "EarnIchor",
	GOSSIP = "Gossip",
	HIGHESTFLOOR = "HighestFloor",
	DANDYSBUDS = "DandysBuds",
	ABILITY = "Ability",
	TWISTED = "Twisted",
	STICKERS = "Stickers",
	FLOOREVENT = "FloorEvent",
	RESEARCH = "Research"
}
local v2 = {
	[CATEGORIES.DISTANCE] = "Distance",
	[CATEGORIES.EXTRACT] = "Extraction",
	[CATEGORIES.FINDITEM] = "Items",
	[CATEGORIES.NICHE] = "Niche",
	[CATEGORIES.HOLIDAY] = "Holiday",
	[CATEGORIES.ICHORJAR] = "Donation",
	[CATEGORIES.EARNICHOR] = "Ichor",
	[CATEGORIES.GOSSIP] = "Gossip",
	[CATEGORIES.HIGHESTFLOOR] = "Highest Floor",
	[CATEGORIES.DANDYSBUDS] = "Dandy's Buds",
	[CATEGORIES.ABILITY] = "Ability",
	[CATEGORIES.TWISTED] = "Twisted",
	[CATEGORIES.STICKERS] = "Stickers",
	[CATEGORIES.FLOOREVENT] = "Floor Event",
	[CATEGORIES.RESEARCH] = "Research"
}
local STATKEYS = {
	DISTANCE = "TravelDistance",
	EXTRACT = "GeneratorsCompleted",
	FINDITEM = "ItemsPickedUp",
	EARNICHOR = "TotalIchorEarned",
	DANDYGOSSIP = "DandyGossipsHeard",
	DYLEGOSSIP = "DyleGossipsHeard",
	HIGHESTFLOOR = "HighestFloor",
	ICHORDONATED = "IchorDonated",
	DYLEMAPCOMPLETIONS = "DyleMapCompletions",
	BUDSHELPED = "BudsHelped",
	GIGISTASHSEARCHES = "GigiStashSearches"
}
local DISPLAYTYPES = {
	PROGRESSBAR = "ProgressBar",
	CHECKBOX = "Checkbox"
}
local DIFFICULTIES = {
	NORMAL = "Normal",
	BRONZE = "Bronze",
	SILVER = "Silver",
	GOLD = "Gold",
	IRIDESCENT = "Iridescent"
}
local REWARDTYPES = {
	ICHOR = "Ichor",
	SKIN = "Skin",
	STICKER = "Sticker",
	TITLE = "Title"
}
local Achievements = {
	Enums = {
		STATKEYS = STATKEYS,
		CATEGORIES = CATEGORIES,
		REWARDTYPES = REWARDTYPES,
		DISPLAYTYPES = DISPLAYTYPES,
		DIFFICULTIES = DIFFICULTIES
	},
	Images = {
		[DIFFICULTIES.BRONZE] = "",
		[DIFFICULTIES.SILVER] = "",
		[DIFFICULTIES.GOLD] = "",
		[DIFFICULTIES.IRIDESCENT] = ""
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function AddCommas(value: number)
	local v8, v9, v10 = string.match(value, "^([^%d]*%d)(%d*)(.-)$")
	return v8 .. v9:reverse():gsub("(%d%d%d)", "%1,"):reverse() .. v10
end

Achievements.All = {
	Standard = {
		ID_1_SpeedWalker = {
			Name = "Speed Walker",
			Description = "Travel 50,000 Meters",
			Icon = "rbxassetid://109765903440375",
			Requirement = 50000,
			Category = CATEGORIES.DISTANCE,
			StatKey = STATKEYS.DISTANCE,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 877623959683599,
			TestBadgeID = 2712921450870460,
			TextFormat = function(value)
				return string.format("%s Meters", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "SpeedWalker"
				}
			}
		},
		ID_2_LongDistanceRunner = {
			Name = "Long Distance Runner",
			Description = "Travel 500,000 Meters",
			Icon = "rbxassetid://80475569282592",
			Requirement = 500000,
			Category = CATEGORIES.DISTANCE,
			StatKey = STATKEYS.DISTANCE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 2621659595090283,
			TestBadgeID = 374871115753676,
			TextFormat = function(value)
				return string.format("%s Meters", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "LongDistanceRunner"
				}
			}
		},
		ID_3_MarathonRunner = {
			Name = "Marathon Runner",
			Description = "Travel 5,000,000 Meters",
			Icon = "rbxassetid://132155766209222",
			Requirement = 5000000,
			Category = CATEGORIES.DISTANCE,
			StatKey = STATKEYS.DISTANCE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3453094775464298,
			TestBadgeID = 155424216582279,
			TextFormat = function(value)
				return string.format("%s Meters", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "MarathonRunner"
				}
			}
		},
		ID_4_MachineEnthusiast = {
			Name = "Machine Enthusiast",
			Description = "Complete 100 Machines",
			Icon = "rbxassetid://114194061620949",
			Requirement = 100,
			Category = CATEGORIES.EXTRACT,
			StatKey = STATKEYS.EXTRACT,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3631798460232143,
			TestBadgeID = 333128500224506,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Machines", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "MachineEnthusiast"
				}
			}
		},
		ID_5_MachineMaster = {
			Name = "Machine Master",
			Description = "Complete 1,000 Machines",
			Icon = "rbxassetid://115520134335328",
			Requirement = 1000,
			Category = CATEGORIES.EXTRACT,
			StatKey = STATKEYS.EXTRACT,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3650915651794012,
			TestBadgeID = 3524382028550093,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Machines", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "MachineMaster"
				}
			}
		},
		ID_6_THEMachine = {
			Name = "THE Machine",
			Description = "Complete 10,000 Machines",
			Icon = "rbxassetid://140599451991188",
			Requirement = 10000,
			Category = CATEGORIES.EXTRACT,
			StatKey = STATKEYS.EXTRACT,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 722525313992174,
			TestBadgeID = 4190392549481820,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Machines", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "THEMachine"
				}
			}
		},
		ID_7_ItemFinder = {
			Name = "Item Finder",
			Description = "Pick up 100 Items",
			Icon = "rbxassetid://96733962103360",
			Requirement = 100,
			Category = CATEGORIES.FINDITEM,
			StatKey = STATKEYS.FINDITEM,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 1188687859433142,
			TestBadgeID = 741856491757572,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Items", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "ItemFinder"
				}
			}
		},
		ID_8_ItemTracker = {
			Name = "Item Tracker",
			Description = "Pick up 1,000 Items",
			Icon = "rbxassetid://107149222929665",
			Requirement = 1000,
			Category = CATEGORIES.FINDITEM,
			StatKey = STATKEYS.FINDITEM,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3889118551056798,
			TestBadgeID = 2401878935100821,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Items", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "ItemTracker"
				}
			}
		},
		ID_9_ItemHunter = {
			Name = "Item Hunter",
			Description = "Pick up 10,000 Items",
			Icon = "rbxassetid://92533065099006",
			Requirement = 10000,
			Category = CATEGORIES.FINDITEM,
			StatKey = STATKEYS.FINDITEM,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 4343465570361894,
			TestBadgeID = 2635005681149088,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s Items", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "ItemHunter"
				}
			}
		},
		ID_10_HissyFit = {
			Name = "Hissy Fit",
			Description = "Complete Twisted Dyle's Floor as Shrimpo",
			Icon = "rbxassetid://139592882229838",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.IRIDESCENT,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2656794558205839,
			TestBadgeID = 3940340837768437,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "HissyFit"
				}
			}
		},
		ID_11_Sightseer = {
			Name = "Sightseer",
			Description = "Complete a match that has you travel to 15 unique floors",
			Icon = "rbxassetid://126075050246173",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3482040494566788,
			TestBadgeID = 474586113633783,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Sightseer"
				}
			}
		},
		ID_12_ClockedIn = {
			Name = "Clocked In",
			Description = "Beat Twisted Dyle's Floor",
			Icon = "rbxassetid://123262277211807",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			StatKey = STATKEYS.DYLEMAPCOMPLETIONS,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3784664997676455,
			TestBadgeID = 4063650476326302,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "ClockedIn"
				}
			}
		},
		ID_13_Overtime = {
			Name = "Overtime",
			Description = "Beat Twisted Dyle's Floor 25 times",
			Icon = "rbxassetid://82648992419617",
			Requirement = 25,
			Category = CATEGORIES.NICHE,
			StatKey = STATKEYS.DYLEMAPCOMPLETIONS,
			Difficulty = DIFFICULTIES.IRIDESCENT,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 1455062180787768,
			TestBadgeID = 1286836833865530,
			TextFormat = function(p)
				return string.format("%s/25", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Overtime"
				}
			}
		},
		ID_21_GossipBud = {
			Name = "Gossip Bud",
			Description = "Listen to 25 unique Gossips from Dandy",
			Icon = "rbxassetid://110211916493680",
			Requirement = 25,
			Category = CATEGORIES.GOSSIP,
			StatKey = STATKEYS.DANDYGOSSIP,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 4091661985543994,
			TestBadgeID = 2488269958993329,
			TextFormat = function(p)
				return string.format("%s/25", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "GossipBud"
				}
			}
		},
		ID_22_GossipTime = {
			Name = "Gossip Time",
			Description = "Listen to 25 unique Gossips from Dyle",
			Icon = "rbxassetid://95948052196117",
			Requirement = 25,
			Category = CATEGORIES.GOSSIP,
			StatKey = STATKEYS.DYLEGOSSIP,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3392126678094751,
			TestBadgeID = 1919858963422639,
			TextFormat = function(p)
				return string.format("%s/25", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "GossipTime"
				}
			}
		},
		ID_23_Only90MoreToGo = {
			Name = "Double Digits!",
			Description = "Complete Floor 10",
			Icon = "rbxassetid://76375952216233",
			Requirement = 10,
			Category = CATEGORIES.HIGHESTFLOOR,
			StatKey = STATKEYS.HIGHESTFLOOR,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 1032245889618935,
			TestBadgeID = 569210549358762,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("Floor %s", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Only90MoreToGo"
				}
			}
		},
		ID_24_Only75More = {
			Name = "Skilled Toon!",
			Description = "Complete Floor 25",
			Icon = "rbxassetid://104325217832682",
			Requirement = 25,
			Category = CATEGORIES.HIGHESTFLOOR,
			StatKey = STATKEYS.HIGHESTFLOOR,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 4450190261193609,
			TestBadgeID = 2478740034008851,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("Floor %s", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Only75More"
				}
			}
		},
		ID_25_Halfway50More = {
			Name = "Super Skilled Pro!",
			Description = "Complete Floor 50",
			Icon = "rbxassetid://98477149197678",
			Requirement = 50,
			Category = CATEGORIES.HIGHESTFLOOR,
			StatKey = STATKEYS.HIGHESTFLOOR,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2154751145157776,
			TestBadgeID = 3335906860757736,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("Floor %s", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Halfway50More"
				}
			}
		},
		ID_26_TwistedsFearMe = {
			Name = "Twisteds Fear Me",
			Description = "Complete Floor 100",
			Icon = "rbxassetid://81021848077886",
			Requirement = 100,
			Category = CATEGORIES.HIGHESTFLOOR,
			StatKey = STATKEYS.HIGHESTFLOOR,
			Difficulty = DIFFICULTIES.IRIDESCENT,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 489243865301208,
			TestBadgeID = 2779158652132324,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("Floor %s", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "TwistedsFearMe"
				}
			}
		},
		ID_31_FineDining = {
			Name = "Fine Dining",
			Description = "Eat from 10 unique bookshelves on a single floor as Squirm",
			Icon = "rbxassetid://96590106817247",
			Requirement = 1,
			Category = CATEGORIES.ABILITY,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 4143558488457660,
			TestBadgeID = 169968745171066,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "FineDining"
				}
			}
		},
		ID_32_StealthMission = {
			Name = "Stealth Mission",
			Description = "Complete a floor without being spotted",
			Icon = "rbxassetid://90732280862354",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2760697774110195,
			TestBadgeID = 1267328162469158,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "StealthMission"
				}
			}
		},
		ID_33_SpeedRunner = {
			Name = "Speed Runner",
			Description = "Complete any floor in under 1 minute",
			Icon = "rbxassetid://100322282761200",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2848365449687217,
			TestBadgeID = 4019738147373223,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "SpeedRunner"
				}
			}
		},
		ID_34_CenterOfAttention = {
			Name = "Center of Attention",
			Description = "Distract 6 or more Twisteds at the same time",
			Icon = "rbxassetid://105778955858013",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3440847134688213,
			TestBadgeID = 2128158307841750,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "CenterOfAttention"
				}
			}
		},
		ID_35_MasterOfMany = {
			Name = "Master Of Many",
			Description = "Complete Mastery on at least 20 Toons",
			Icon = "rbxassetid://125370851758870",
			Requirement = 20,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 1993385796775875,
			TestBadgeID = 641836323372941,
			TextFormat = function(p)
				return string.format("%s/20", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "MasterOfMany"
				}
			}
		},
		ID_36_WhatADeal = {
			Name = "What a Deal!",
			Description = "Buy all three of Dandy's Shop items in 1 visit.",
			Icon = "rbxassetid://88148427100816",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 1888594585132992,
			TestBadgeID = 616527481173089,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "WhatADeal"
				}
			}
		},
		ID_37_GearedUp = {
			Name = "Geared Up",
			Description = "Buy all three items in the pregame shop in a run",
			Icon = "rbxassetid://125279467401150",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3172075169422450,
			TestBadgeID = 2850619830414916,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "GearedUp"
				}
			}
		},
		ID_38_MainCharacter = {
			Name = "Main Character",
			Description = "Complete a floor with 8 unique Main Toons in a party",
			Icon = "rbxassetid://72569010647217",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.IRIDESCENT,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3561906072285403,
			TestBadgeID = 1318077407265417,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "MainCharacter"
				}
			}
		},
		ID_39_EggHunt26 = {
			Name = "Egg Hunt",
			Description = "Find all the eggs in the lobby!",
			Icon = "rbxassetid://99753882968305",
			Requirement = 10,
			Category = CATEGORIES.HOLIDAY,
			Holiday = "Easter",
			StatKey = nil,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 2931461048642135,
			TestBadgeID = 4043744474193085,
			TextFormat = function(p)
				return string.format("%s/10", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "EggHunt26"
				}
			}
		},
		ID_40_GetToWhere = {
			Name = "Get To Where?",
			Description = "Use a \"GTE\" sticker during panic mode.",
			Icon = "rbxassetid://75972627437816",
			Requirement = 1,
			Category = CATEGORIES.STICKERS,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3135840441668526,
			TestBadgeID = 771689208253640,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "GetToWhere"
				}
			}
		},
		ID_41_Attached = {
			Name = "Attached",
			Description = "Stay with Twisted Glisten for 30 seconds straight.",
			Icon = "rbxassetid://85983008538379",
			Requirement = 1,
			Category = CATEGORIES.TWISTED,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2295912274487741,
			TestBadgeID = 1981614498232218,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Attached"
				}
			}
		},
		ID_42_HelpfulHugger = {
			Name = "Helpful Hugger",
			Description = "Hug someone into the elevator during panic mode as Goob.",
			Icon = "rbxassetid://82911569801694",
			Requirement = 1,
			Category = CATEGORIES.ABILITY,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 1569127933432076,
			TestBadgeID = 820435121560181,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "HelpfulHugger"
				}
			}
		},
		ID_43_Investigator = {
			Name = "Investigator",
			Description = "Collect all research capsules available on any floor.",
			Icon = "rbxassetid://114163322841199",
			Requirement = 1,
			Category = CATEGORIES.RESEARCH,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2202640501871492,
			TestBadgeID = 2163813515919223,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Investigator"
				}
			}
		},
		ID_44_LightsOut = {
			Name = "Lights Out",
			Description = "Experience a blackout on a Floor with Twisted Brightney.",
			Icon = "rbxassetid://132896280381256",
			Requirement = 1,
			Category = CATEGORIES.TWISTED,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2931854353287793,
			TestBadgeID = 2834975337362132,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "LightsOut"
				}
			}
		},
		ID_45_CenterStage = {
			Name = "Center Stage",
			Description = "While playing as a Main Toon, complete a floor with Twisted Dandy.",
			Icon = "rbxassetid://131976456995074",
			Requirement = 1,
			Category = CATEGORIES.TWISTED,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 4384987076164678,
			TestBadgeID = 2342378951430561,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "CenterStage"
				}
			}
		},
		ID_46_EmptyHanded = {
			Name = "Empty Handed",
			Description = "Survive 5 floors in 1 run with no trinkets equipped.",
			Icon = "rbxassetid://87823392918851",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2620298369118337,
			TestBadgeID = 1101034517853625,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "EmptyHanded"
				}
			}
		},
		ID_47_SqueakyClean = {
			Name = "Squeaky Clean",
			Description = "Complete a floor with an active ichor leak without being affected by an ichor puddle.",
			Icon = "rbxassetid://112649491554892",
			Requirement = 1,
			Category = CATEGORIES.FLOOREVENT,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 702692543295728,
			TestBadgeID = 1422335176377145,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "SqueakyClean"
				}
			}
		},
		ID_48_Bedtime = {
			Name = "Bedtime",
			Description = "Use Astro's Nap Time ability to provide stamina to three toons at once while not inside the elevator.",
			Icon = "rbxassetid://82093422646425",
			Requirement = 1,
			Category = CATEGORIES.ABILITY,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 571506192866919,
			TestBadgeID = 1844086113824354,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Bedtime"
				}
			}
		},
		ID_49_WinningChoice = {
			Name = "Winning Choice",
			Description = "Choose a vote card with 8 unanimous votes.",
			Icon = "rbxassetid://88021962825328",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3510650343377317,
			TestBadgeID = 2483174036413541,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "WinningChoice"
				}
			}
		},
		ID_50_QuickReactionTime = {
			Name = "Quick Reaction Time",
			Description = "Complete 10 Perfect skill checks within a single Floor as a 1-star Skill Check Toon.",
			Icon = "rbxassetid://121050632283997",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 614575770108336,
			TestBadgeID = 606067926427423,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "QuickReactionTime"
				}
			}
		},
		ID_51_UnstoppablyHealthy = {
			Name = "Unstoppably Healthy",
			Description = "Fill all of your inventory slots with Medkits and/or Bandages.",
			Icon = "rbxassetid://122441010642688",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 1441070811031032,
			TestBadgeID = 2151022147474567,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "UnstoppablyHealthy"
				}
			}
		},
		ID_52_Teamwork = {
			Name = "Teamwork",
			Description = "Complete a duo machine alongside another player at the same time.",
			Icon = "rbxassetid://109963123423597",
			Requirement = 1,
			Category = CATEGORIES.EXTRACT,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3446266187542187,
			TestBadgeID = 1075853483015028,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Teamwork"
				}
			}
		},
		ID_53_AllTogether = {
			Name = "All Together",
			Description = "Complete a duo machine that 7 other toons directly contributed to.",
			Icon = "rbxassetid://129748206339572",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 3658261518066380,
			TestBadgeID = 262082398033859,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "AllTogether"
				}
			}
		},
		ID_54_Nurturer = {
			Name = "Nurturer",
			Description = "Help a Bud clear a Floor 10 times",
			Icon = "rbxassetid://77973245728705",
			Requirement = 10,
			LinkedBadgeID = 333306051922069,
			TestBadgeID = 691552646741945,
			Category = CATEGORIES.DANDYSBUDS,
			StatKey = STATKEYS.BUDSHELPED,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Nurturer"
				}
			}
		},
		ID_55_Caretaker = {
			Name = "Caretaker",
			Description = "Help a Bud clear a Floor 25 times",
			Icon = "rbxassetid://112080107124363",
			Requirement = 25,
			LinkedBadgeID = 3874843708216502,
			TestBadgeID = 2948453932141703,
			Category = CATEGORIES.DANDYSBUDS,
			StatKey = STATKEYS.BUDSHELPED,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Caretaker"
				}
			}
		},
		ID_56_Cultivator = {
			Name = "Cultivator",
			Description = "Help a Bud clear a Floor 50 times",
			Icon = "rbxassetid://77059413462548",
			Requirement = 50,
			LinkedBadgeID = 158725263606758,
			TestBadgeID = 1665517154263365,
			Category = CATEGORIES.DANDYSBUDS,
			StatKey = STATKEYS.BUDSHELPED,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "Cultivator"
				}
			}
		},
		ID_57_GreenThumb = {
			Name = "Green Thumb",
			Description = "Help a Bud clear a Floor 100 times",
			Icon = "rbxassetid://96201746270778",
			Requirement = 100,
			LinkedBadgeID = 140856239278347,
			TestBadgeID = 861066145159897,
			Category = CATEGORIES.DANDYSBUDS,
			StatKey = STATKEYS.BUDSHELPED,
			Difficulty = DIFFICULTIES.IRIDESCENT,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "GreenThumb"
				}
			}
		},
		ID_58_SwimmyBarnaby = {
			Name = "Just Keep Swimming",
			Description = "Get a score of 100 or higher in Swimmy Barnaby",
			Icon = "rbxassetid://96203904415939",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2571896086842758,
			TestBadgeID = 1428530706528632,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "SwimmyBarnaby"
				},
				{
					Type = REWARDTYPES.SKIN,
					Value = "SwimmyFinn"
				}
			}
		},
		ID_59_ExtinguishedConfidence = {
			Name = "Extinguished Confidence",
			Description = "Extinguish Twisted Waxwell's flame 10 times.",
			Icon = "rbxassetid://120672097072502",
			Requirement = 10,
			Category = CATEGORIES.TWISTED,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 570826629205751,
			TestBadgeID = 606227690567278,
			TextFormat = function(p)
				return string.format("%s/10", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "ExtinguishedConfidence"
				}
			}
		},
		ID_60_StashSearcher = {
			Name = "Stash Searcher",
			Description = "Search Twisted Gigi's stash 50 times",
			Icon = "rbxassetid://120534544941588",
			Requirement = 50,
			Category = CATEGORIES.TWISTED,
			StatKey = STATKEYS.GIGISTASHSEARCHES,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 1436834373428481,
			TestBadgeID = 1117258669451755,
			UseExisting = true,
			TextFormat = function(value)
				return string.format("%s/50", AddCommas(value))
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "StashSearcher"
				}
			}
		},
		ID_61_StockpiledStash = {
			Name = "Stockpiled Stash",
			Description = "While playing on a floor with Twisted Gigi, allow her stash to fill to capacity",
			Icon = "rbxassetid://136202922582396",
			Requirement = 1,
			Category = CATEGORIES.NICHE,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2896633082327520,
			TestBadgeID = 3504240544739508,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "StockpiledStash"
				}
			}
		},
		ID_62_TrickOrTreat26 = {
			Name = "Trick or Treat!",
			Description = "Open 50 Trick or Treat doors on any floor.",
			Icon = "rbxassetid://114817768342406",
			Requirement = 50,
			Category = CATEGORIES.HOLIDAY,
			Holiday = "Halloween",
			StatKey = nil,
			Difficulty = DIFFICULTIES.BRONZE,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 2010928559128659,
			TextFormat = function(p)
				return string.format("%s/50", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "TrickOrTreat26"
				}
			}
		},
		ID_63_HauntedGala26 = {
			Name = "Haunted Gala",
			Description = "Participate in 20 Haunted Gala floor events.",
			Icon = "rbxassetid://103118419540450",
			Requirement = 20,
			Category = CATEGORIES.HOLIDAY,
			Holiday = "Halloween",
			StatKey = nil,
			Difficulty = DIFFICULTIES.SILVER,
			DisplayType = DISPLAYTYPES.PROGRESSBAR,
			LinkedBadgeID = 3225809034817222,
			TextFormat = function(p)
				return string.format("%s/20", p)
			end,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "HauntedGala26"
				}
			}
		},
		ID_64_LockedAway26 = {
			Name = "Locked Away",
			Description = "Complete Gourdy's Halloween 2026 quest.",
			Icon = "rbxassetid://110092547920833",
			Requirement = 1,
			Category = CATEGORIES.HOLIDAY,
			Holiday = "Halloween",
			StatKey = nil,
			Difficulty = DIFFICULTIES.GOLD,
			DisplayType = DISPLAYTYPES.CHECKBOX,
			LinkedBadgeID = 2145206125690761,
			Reward = {
				{
					Type = REWARDTYPES.TITLE,
					Value = "LockedAway26"
				}
			}
		}
	}
}
local v8 = {}

for k, v9 in pairs(Achievements.All.Standard) do
	v9.ID = k
	v9.NumericIndex = tonumber(k:gmatch("%d+")()) or -1
	v8[#v8 + 1] = { k, v9.NumericIndex }
	v9.CategoryDisplayName = v2[v9.Category] or tostring(v9.Category)
end

table.sort(v8, function(a, b)
	return a[2] < b[2]
end)
local isTestRealm = Universe:IsTestRealm()

for k, v9 in pairs(v8) do
	local v10 = Achievements.All.Standard[v9[1]]
	Achievements.All.Standard[v9[1]].MedalNumber = k

	if isTestRealm and v10.LinkedBadgeID and v10.TestBadgeID then
		Achievements.All.Standard[v9[1]].LinkedBadgeID = v10.TestBadgeID
	end
end

return Achievements