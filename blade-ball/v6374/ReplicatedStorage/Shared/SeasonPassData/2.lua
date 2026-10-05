local Snowflakes = require(script.Parent:WaitForChild("Currency"):WaitForChild("Snowflakes"))
local Coins = require(script.Parent:WaitForChild("Currency"):WaitForChild("Coins"))
return {
	StartTime = DateTime.fromUniversalTime(2023, 11, 20, 13),
	EndTime = DateTime.fromUniversalTime(2023, 12, 23, 17),
	Rewards = {
		FirstTime = {
			["Tier 1"] = {
				XPNeeded = 50,
				Basic = Coins(100),
				Premium = Coins(500)
			},
			["Tier 2"] = {
				XPNeeded = 100,
				Basic = Snowflakes(30),
				Premium = Snowflakes(65)
			},
			["Tier 3"] = {
				XPNeeded = 160,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 900
				},
				Premium = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				}
			},
			["Tier 4"] = {
				XPNeeded = 220,
				Basic = Snowflakes(35),
				Premium = Snowflakes(75)
			},
			["Tier 5"] = {
				XPNeeded = 290,
				Basic = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 6"] = {
				XPNeeded = 360,
				Basic = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 3
				}
			},
			["Tier 7"] = {
				XPNeeded = 440,
				Basic = Coins(150),
				Premium = Coins(600)
			},
			["Tier 8"] = {
				XPNeeded = 525,
				Basic = {
					Icon = "rbxassetid://14737617340",
					RewardType = "FreeInstantSpin",
					Duration = 900,
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 4
				}
			},
			["Tier 9"] = {
				XPNeeded = 615,
				Basic = Snowflakes(35),
				Premium = Snowflakes(75)
			},
			["Tier 10"] = {
				XPNeeded = 710,
				Basic = {
					Icon = "rbxassetid://15442381655",
					RewardType = "Emote",
					RewardStat = "Emote29",
					BackupReward = Snowflakes(40)
				},
				Premium = Snowflakes(100)
			},
			["Tier 11"] = {
				XPNeeded = 810,
				Basic = Snowflakes(50),
				Premium = {
					Icon = "rbxassetid://15442620806",
					RewardType = "Emote",
					RewardStat = "Emote30",
					BackupReward = Snowflakes(65)
				}
			},
			["Tier 12"] = {
				XPNeeded = 915,
				Basic = Snowflakes(40),
				Premium = Snowflakes(80)
			},
			["Tier 13"] = {
				XPNeeded = 1025,
				Basic = Snowflakes(45),
				Premium = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 2
				}
			},
			["Tier 14"] = {
				XPNeeded = 1140,
				Premium = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 1
				}
			},
			["Tier 15"] = {
				XPNeeded = 1260,
				Basic = Snowflakes(45),
				Premium = Snowflakes(100)
			},
			["Tier 16"] = {
				XPNeeded = 1385,
				Basic = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = Coins(500)
			},
			["Tier 17"] = {
				XPNeeded = 1515,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 900
				},
				Premium = Snowflakes(90)
			},
			["Tier 18"] = {
				XPNeeded = 1655,
				Basic = Snowflakes(50),
				Premium = Snowflakes(150)
			},
			["Tier 19"] = {
				XPNeeded = 1805,
				Basic = Snowflakes(50),
				Premium = Snowflakes(150)
			},
			["Tier 20"] = {
				XPNeeded = 1955,
				Basic = Snowflakes(55),
				Premium = Snowflakes(110)
			},
			["Tier 21"] = {
				XPNeeded = 2115,
				Basic = Coins(100),
				Premium = Snowflakes(120)
			},
			["Tier 22"] = {
				XPNeeded = 2275,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Snowflakes(120)
			},
			["Tier 23"] = {
				XPNeeded = 2445,
				Basic = {
					Icon = "rbxassetid://15433481350",
					RewardType = "Sword",
					RewardStat = "Glacier Shard",
					BackupReward = Snowflakes(60)
				},
				Premium = Snowflakes(120)
			},
			["Tier 24"] = {
				XPNeeded = 2615,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Snowflakes(140)
			},
			["Tier 25"] = {
				XPNeeded = 2795,
				Basic = Snowflakes(70),
				Premium = Snowflakes(145)
			},
			["Tier 26"] = {
				XPNeeded = 2975,
				Basic = Snowflakes(75),
				Premium = Snowflakes(150)
			},
			["Tier 27"] = {
				XPNeeded = 3165,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Snowflakes(140)
			},
			["Tier 28"] = {
				XPNeeded = 3365,
				Basic = Snowflakes(70),
				Premium = Snowflakes(140)
			},
			["Tier 29"] = {
				XPNeeded = 3575,
				Basic = Snowflakes(75),
				Premium = Snowflakes(155)
			},
			["Tier 30"] = {
				XPNeeded = 3795,
				Premium = Snowflakes(150)
			},
			["Tier 31"] = {
				XPNeeded = 4025,
				Basic = Snowflakes(80),
				Premium = Snowflakes(160)
			},
			["Tier 32"] = {
				XPNeeded = 4265,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 900
				},
				Premium = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 3600
				}
			},
			["Tier 33"] = {
				XPNeeded = 4515,
				Basic = Snowflakes(85),
				Premium = Snowflakes(170)
			},
			["Tier 34"] = {
				XPNeeded = 4775,
				Basic = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 1
				},
				Premium = Snowflakes(170)
			},
			["Tier 35"] = {
				XPNeeded = 5045,
				Basic = Snowflakes(90),
				Premium = Snowflakes(180)
			},
			["Tier 36"] = {
				XPNeeded = 5325,
				Basic = Snowflakes(85),
				Premium = Snowflakes(170)
			},
			["Tier 37"] = {
				XPNeeded = 5615,
				Basic = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423844834",
					RewardType = "WinterExplosion",
					Amount = 2
				}
			},
			["Tier 38"] = {
				XPNeeded = 5915,
				Basic = Snowflakes(100),
				Premium = Snowflakes(200)
			},
			["Tier 39"] = {
				XPNeeded = 6215,
				Basic = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 1
				},
				Premium = Snowflakes(200)
			},
			["Tier 40"] = {
				XPNeeded = 6515,
				Basic = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15433482001",
					RewardType = "Sword",
					RewardStat = "Arctic Edge",
					BackupReward = Snowflakes(150)
				}
			}
		},
		RerunPass = {
			["Tier 1"] = {
				XPNeeded = 50,
				Basic = Coins(100),
				Premium = Coins(200)
			},
			["Tier 2"] = {
				XPNeeded = 110,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 900
				},
				Premium = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				}
			},
			["Tier 3"] = {
				XPNeeded = 180,
				Basic = Snowflakes(40),
				Premium = Snowflakes(80)
			},
			["Tier 4"] = {
				XPNeeded = 260,
				Basic = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 5"] = {
				XPNeeded = 350,
				Basic = Snowflakes(45),
				Premium = Snowflakes(90)
			},
			["Tier 6"] = {
				XPNeeded = 450,
				Basic = Snowflakes(40),
				Premium = Snowflakes(80)
			},
			["Tier 7"] = {
				XPNeeded = 565,
				Basic = Coins(250),
				Premium = Coins(500)
			},
			["Tier 8"] = {
				XPNeeded = 695,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 900
				},
				Premium = Snowflakes(90)
			},
			["Tier 9"] = {
				XPNeeded = 840,
				Basic = Snowflakes(45),
				Premium = Snowflakes(90)
			},
			["Tier 10"] = {
				XPNeeded = 1000,
				Basic = Snowflakes(50),
				Premium = Snowflakes(100)
			},
			["Tier 11"] = {
				XPNeeded = 1175,
				Basic = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15423847400",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 12"] = {
				XPNeeded = 1375,
				Basic = Snowflakes(50),
				Premium = Snowflakes(100)
			},
			["Tier 13"] = {
				XPNeeded = 1575,
				Basic = Coins(250),
				Premium = Coins(500)
			},
			["Tier 14"] = {
				XPNeeded = 1775,
				Basic = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 2
				}
			},
			["Tier 15"] = {
				XPNeeded = 2000,
				Basic = Snowflakes(80),
				Premium = Snowflakes(160)
			},
			["Tier 16"] = {
				XPNeeded = 2250,
				Basic = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 2
				}
			},
			["Tier 17"] = {
				XPNeeded = 2525,
				Basic = Snowflakes(90),
				Premium = Snowflakes(180)
			},
			["Tier 18"] = {
				XPNeeded = 2825,
				Basic = Snowflakes(100),
				Premium = Snowflakes(200)
			},
			["Tier 19"] = {
				XPNeeded = 3150,
				Basic = Snowflakes(80),
				Premium = Snowflakes(160)
			},
			["Tier 20"] = {
				XPNeeded = 3500,
				Basic = Snowflakes(80),
				Premium = Snowflakes(80)
			}
		}
	}
}