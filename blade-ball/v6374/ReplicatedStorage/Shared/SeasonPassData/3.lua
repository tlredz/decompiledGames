local Cookies = require(script.Parent:WaitForChild("Currency"):WaitForChild("Cookies"))
local Coins = require(script.Parent:WaitForChild("Currency"):WaitForChild("Coins"))
return {
	StartTime = DateTime.fromUniversalTime(2023, 12, 18, 13),
	EndTime = DateTime.fromUniversalTime(2024, 1, 24, 17),
	Rewards = {
		FirstTime = {
			["Tier 1"] = {
				XPNeeded = 50,
				Basic = Coins(100),
				Premium = Coins(500)
			},
			["Tier 2"] = {
				XPNeeded = 100,
				Basic = Cookies(30),
				Premium = Cookies(65)
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
				Basic = Cookies(35),
				Premium = Cookies(75)
			},
			["Tier 5"] = {
				XPNeeded = 290,
				Basic = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 6"] = {
				XPNeeded = 360,
				Basic = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
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
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 4
				}
			},
			["Tier 9"] = {
				XPNeeded = 615,
				Basic = Cookies(35),
				Premium = Cookies(75)
			},
			["Tier 10"] = {
				XPNeeded = 710,
				Basic = {
					Icon = "rbxassetid://15719497167",
					RewardType = "Emote",
					RewardStat = "Emote58",
					BackupReward = Cookies(40)
				},
				Premium = Cookies(100)
			},
			["Tier 11"] = {
				XPNeeded = 810,
				Basic = Cookies(50),
				Premium = {
					Icon = "rbxassetid://15719497819",
					RewardType = "Emote",
					RewardStat = "Emote59",
					BackupReward = Cookies(65)
				}
			},
			["Tier 12"] = {
				XPNeeded = 915,
				Basic = Cookies(40),
				Premium = Cookies(80)
			},
			["Tier 13"] = {
				XPNeeded = 1025,
				Basic = Cookies(45),
				Premium = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 2
				}
			},
			["Tier 14"] = {
				XPNeeded = 1140,
				Premium = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 1
				}
			},
			["Tier 15"] = {
				XPNeeded = 1260,
				Basic = Cookies(45),
				Premium = Cookies(100)
			},
			["Tier 16"] = {
				XPNeeded = 1385,
				Basic = {
					Icon = "rbxassetid://15719439610",
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
				Premium = Cookies(90)
			},
			["Tier 18"] = {
				XPNeeded = 1655,
				Basic = Cookies(50),
				Premium = Cookies(150)
			},
			["Tier 19"] = {
				XPNeeded = 1805,
				Basic = Cookies(50),
				Premium = Cookies(150)
			},
			["Tier 20"] = {
				XPNeeded = 1955,
				Basic = Cookies(55),
				Premium = Cookies(110)
			},
			["Tier 21"] = {
				XPNeeded = 2115,
				Basic = Coins(100),
				Premium = Cookies(120)
			},
			["Tier 22"] = {
				XPNeeded = 2275,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Cookies(120)
			},
			["Tier 23"] = {
				XPNeeded = 2445,
				Basic = Cookies(100),
				Premium = Cookies(120)
			},
			["Tier 24"] = {
				XPNeeded = 2615,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Cookies(140)
			},
			["Tier 25"] = {
				XPNeeded = 2795,
				Basic = {
					Icon = "rbxassetid://15735411882",
					RewardType = "Sword",
					RewardStat = "Candycane Katana",
					BackupReward = Cookies(60)
				},
				Premium = Cookies(145)
			},
			["Tier 26"] = {
				XPNeeded = 2975,
				Basic = Cookies(75),
				Premium = Cookies(150)
			},
			["Tier 27"] = {
				XPNeeded = 3165,
				Basic = {
					Icon = "rbxassetid://14737693993",
					RewardType = "Boost",
					RewardStat = "Coins",
					Duration = 1800
				},
				Premium = Cookies(140)
			},
			["Tier 28"] = {
				XPNeeded = 3365,
				Basic = Cookies(70),
				Premium = Cookies(140)
			},
			["Tier 29"] = {
				XPNeeded = 3575,
				Basic = Cookies(75),
				Premium = Cookies(155)
			},
			["Tier 30"] = {
				XPNeeded = 3795,
				Premium = Cookies(150)
			},
			["Tier 31"] = {
				XPNeeded = 4025,
				Basic = Cookies(80),
				Premium = Cookies(160)
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
				Basic = Cookies(85),
				Premium = Cookies(170)
			},
			["Tier 34"] = {
				XPNeeded = 4775,
				Basic = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 1
				},
				Premium = Cookies(170)
			},
			["Tier 35"] = {
				XPNeeded = 5045,
				Basic = Cookies(90),
				Premium = Cookies(180)
			},
			["Tier 36"] = {
				XPNeeded = 5325,
				Basic = Cookies(85),
				Premium = Cookies(170)
			},
			["Tier 37"] = {
				XPNeeded = 5615,
				Basic = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15720082592",
					RewardType = "ChristmasExplosion",
					Amount = 2
				}
			},
			["Tier 38"] = {
				XPNeeded = 5915,
				Basic = Cookies(100),
				Premium = Cookies(200)
			},
			["Tier 39"] = {
				XPNeeded = 6215,
				Basic = {
					Icon = "rbxassetid://16039967646",
					RewardType = "PremiumSwordCrate",
					Amount = 1
				},
				Premium = Cookies(200)
			},
			["Tier 40"] = {
				XPNeeded = 6515,
				Basic = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15727991902",
					RewardType = "Sword",
					RewardStat = "Christmas Axe",
					BackupReward = Cookies(150)
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
				Basic = Cookies(40),
				Premium = Cookies(80)
			},
			["Tier 4"] = {
				XPNeeded = 260,
				Basic = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 5"] = {
				XPNeeded = 350,
				Basic = Cookies(45),
				Premium = Cookies(90)
			},
			["Tier 6"] = {
				XPNeeded = 450,
				Basic = Cookies(40),
				Premium = Cookies(80)
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
				Premium = Cookies(90)
			},
			["Tier 9"] = {
				XPNeeded = 840,
				Basic = Cookies(45),
				Premium = Cookies(90)
			},
			["Tier 10"] = {
				XPNeeded = 1000,
				Basic = Cookies(50),
				Premium = Cookies(100)
			},
			["Tier 11"] = {
				XPNeeded = 1175,
				Basic = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 1
				},
				Premium = {
					Icon = "rbxassetid://15719439610",
					RewardType = "Rolls",
					Amount = 3
				}
			},
			["Tier 12"] = {
				XPNeeded = 1375,
				Basic = Cookies(50),
				Premium = Cookies(100)
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
				Basic = Cookies(80),
				Premium = Cookies(160)
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
				Basic = Cookies(90),
				Premium = Cookies(180)
			},
			["Tier 18"] = {
				XPNeeded = 2825,
				Basic = Cookies(100),
				Premium = Cookies(200)
			},
			["Tier 19"] = {
				XPNeeded = 3150,
				Basic = Cookies(80),
				Premium = Cookies(160)
			},
			["Tier 20"] = {
				XPNeeded = 3500,
				Basic = Cookies(80),
				Premium = Cookies(80)
			}
		}
	}
}