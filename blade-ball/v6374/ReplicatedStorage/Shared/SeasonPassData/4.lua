local Balloons = require(script.Parent:WaitForChild("Currency"):WaitForChild("Balloons"))
local Coins = require(script.Parent:WaitForChild("Currency"):WaitForChild("Coins"))
return {
	StartTime = DateTime.fromUniversalTime(2024, 1, 24, 13),
	EndTime = DateTime.fromUniversalTime(2024, 3, 9, 17),
	Rewards = {
		FirstTime = {
			["Tier 1"] = {
				XPNeeded = 50,
				Basic = Coins(100),
				Premium = Coins(500)
			},
			["Tier 2"] = {
				XPNeeded = 100,
				Basic = Balloons(30),
				Premium = Balloons(65)
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
				Basic = Balloons(35),
				Premium = Balloons(75)
			},
			["Tier 5"] = {
				XPNeeded = 290,
				Basic = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 6"] = {
				XPNeeded = 360,
				Basic = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
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
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 4
				}
			},
			["Tier 9"] = {
				XPNeeded = 615,
				Basic = Balloons(35),
				Premium = Balloons(75)
			},
			["Tier 10"] = {
				XPNeeded = 710,
				Basic = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = Balloons(100)
			},
			["Tier 11"] = {
				XPNeeded = 810,
				Basic = Balloons(50),
				Premium = {
					Icon = "rbxassetid://16123062143",
					RewardType = "Emote",
					RewardStat = "Emote115",
					BackupReward = Balloons(65)
				}
			},
			["Tier 12"] = {
				XPNeeded = 915,
				Basic = Balloons(40),
				Premium = Balloons(80)
			},
			["Tier 13"] = {
				XPNeeded = 1025,
				Basic = Balloons(45),
				Premium = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 2
				}
			},
			["Tier 14"] = {
				XPNeeded = 1140,
				Premium = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 1
				}
			},
			["Tier 15"] = {
				XPNeeded = 1260,
				Basic = Balloons(45),
				Premium = Balloons(100)
			},
			["Tier 16"] = {
				XPNeeded = 1385,
				Basic = {
					Icon = "rbxassetid://16100521434",
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
				Premium = Balloons(90)
			},
			["Tier 18"] = {
				XPNeeded = 1655,
				Basic = Balloons(50),
				Premium = Balloons(150)
			},
			["Tier 19"] = {
				XPNeeded = 1805,
				Basic = Balloons(50),
				Premium = Balloons(150)
			},
			["Tier 20"] = {
				XPNeeded = 1955,
				Basic = Balloons(55),
				Premium = Balloons(110)
			},
			["Tier 21"] = {
				XPNeeded = 2115,
				Basic = Coins(100),
				Premium = Balloons(120)
			},
			["Tier 22"] = {
				XPNeeded = 2275,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Balloons(120)
			},
			["Tier 23"] = {
				XPNeeded = 2445,
				Basic = Balloons(100),
				Premium = Balloons(120)
			},
			["Tier 24"] = {
				XPNeeded = 2615,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Balloons(140)
			},
			["Tier 25"] = {
				XPNeeded = 2795,
				Basic = {
					Icon = "rbxassetid://16136497422",
					RewardType = "Sword",
					RewardStat = "New Year's Katana",
					BackupReward = Balloons(60)
				},
				Premium = Balloons(145)
			},
			["Tier 26"] = {
				XPNeeded = 2975,
				Basic = Balloons(75),
				Premium = Balloons(150)
			},
			["Tier 27"] = {
				XPNeeded = 3165,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Balloons(140)
			},
			["Tier 28"] = {
				XPNeeded = 3365,
				Basic = Balloons(70),
				Premium = Balloons(140)
			},
			["Tier 29"] = {
				XPNeeded = 3575,
				Basic = Balloons(75),
				Premium = Balloons(155)
			},
			["Tier 30"] = {
				XPNeeded = 3795,
				Premium = Balloons(150)
			},
			["Tier 31"] = {
				XPNeeded = 4025,
				Basic = Balloons(80),
				Premium = Balloons(160)
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
				Basic = Balloons(85),
				Premium = Balloons(170)
			},
			["Tier 34"] = {
				XPNeeded = 4775,
				Basic = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 1
				},
				Premium = Balloons(170)
			},
			["Tier 35"] = {
				XPNeeded = 5045,
				Basic = Balloons(90),
				Premium = Balloons(180)
			},
			["Tier 36"] = {
				XPNeeded = 5325,
				Basic = Balloons(85),
				Premium = Balloons(170)
			},
			["Tier 37"] = {
				XPNeeded = 5615,
				Basic = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16130315794",
					RewardType = "NewYearExplosion",
					Amount = 2
				}
			},
			["Tier 38"] = {
				XPNeeded = 5915,
				Basic = Balloons(100),
				Premium = Balloons(200)
			},
			["Tier 39"] = {
				XPNeeded = 6215,
				Basic = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 1
				},
				Premium = Balloons(200)
			},
			["Tier 40"] = {
				XPNeeded = 6515,
				Basic = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16136287074",
					RewardType = "Sword",
					RewardStat = "Firework Blaster",
					BackupReward = Balloons(150)
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
				Basic = Balloons(40),
				Premium = Balloons(80)
			},
			["Tier 4"] = {
				XPNeeded = 260,
				Basic = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 5"] = {
				XPNeeded = 350,
				Basic = Balloons(45),
				Premium = Balloons(90)
			},
			["Tier 6"] = {
				XPNeeded = 450,
				Basic = Balloons(40),
				Premium = Balloons(80)
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
				Premium = Balloons(90)
			},
			["Tier 9"] = {
				XPNeeded = 840,
				Basic = Balloons(45),
				Premium = Balloons(90)
			},
			["Tier 10"] = {
				XPNeeded = 1000,
				Basic = Balloons(50),
				Premium = Balloons(100)
			},
			["Tier 11"] = {
				XPNeeded = 1175,
				Basic = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://16100521434",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 12"] = {
				XPNeeded = 1375,
				Basic = Balloons(50),
				Premium = Balloons(100)
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
				Basic = Balloons(80),
				Premium = Balloons(160)
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
				Basic = Balloons(90),
				Premium = Balloons(180)
			},
			["Tier 18"] = {
				XPNeeded = 2825,
				Basic = Balloons(100),
				Premium = Balloons(200)
			},
			["Tier 19"] = {
				XPNeeded = 3150,
				Basic = Balloons(80),
				Premium = Balloons(160)
			},
			["Tier 20"] = {
				XPNeeded = 3500,
				Basic = Balloons(80),
				Premium = Balloons(80)
			}
		}
	}
}