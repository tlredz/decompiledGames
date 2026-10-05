local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)

local function explosion(p)
	return {
		Chance = 1,
		Item = {
			Explosions = { p }
		}
	}
end

local v2 = {
	explosion("Explosion Blue"),
	explosion("Explosion Green"),
	explosion("Explosion Purple"),
	explosion("Explosion Red"),
	explosion("Explosion White"),
	explosion("Lightning Green"),
	explosion("Lightning Normal"),
	explosion("Lightning Purple"),
	explosion("Lightning Red"),
	explosion("Lightning White"),
	(explosion("Lightning Yellow"))
}
local v3 = {
	explosion("Sakura Blue"),
	explosion("Sakura Green"),
	explosion("Sakura Normal"),
	explosion("Sakura Purple"),
	explosion("Sakura Red"),
	explosion("Sakura Yellow"),
	explosion("Waterblast Black"),
	explosion("Waterblast Green"),
	explosion("Waterblast Normal"),
	explosion("Waterblast Purple"),
	explosion("Waterblast Red"),
	(explosion("Waterblast Yellow"))
}
local v4 = {
	explosion("Blackhole Blue"),
	explosion("Blackhole Green"),
	explosion("Blackhole Normal"),
	explosion("Blackhole Red"),
	explosion("Blackhole White"),
	(explosion("Blackhole Yellow"))
}
local lootbox = {}
local v6 = {}
local v7 = {}
local v8 = {}
local lootbox2 = {}
local lootbox3 = {}
local lootbox4 = {}
local lootbox5 = {}

for _, child in pairs(game.ReplicatedStorage.Misc.DataExplosions:GetChildren()) do
	child:GetAttribute("Rarity")
	local v13

	if child:GetAttribute("SubText") == "LIVE EVENT" then
		v13 = lootbox
	end

	if (child:GetAttribute("Unobtainable") ~= true or v13 == lootbox) and v13 then
		v13[#v13 + 1] = {
			Chance = child:GetAttribute("Chance") or 1,
			Item = {
				Explosions = { child.Name }
			}
		}
	end
end

for k, v13 in v:GetListByRarity() do
	local v14 = nil

	if k == "Normal" then
		v14 = v8
	elseif k == "Rare" then
		v14 = v7
	elseif k == "Legendary" then
		v14 = v6
	end

	if not v14 then
		continue
	end

	for _, v15 in v13 do
		if v15.Unobtainable ~= true then
			v14[#v14 + 1] = {
				Chance = 1,
				Item = {
					Swords = { v15.Name }
				}
			}
		end
	end
end

for _, v13 in v:GetSwordsInRarity("Unique") do
	local crate = v13.Crate

	if not crate then
		continue
	end

	local chance = v13.Chance

	if not chance then
		continue
	end

	if crate == "ChristmasSwordCrate" then
		lootbox5[#lootbox5 + 1] = {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		}
	elseif crate == "HalloweenSwordCrate" then
		lootbox4[#lootbox4 + 1] = {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		}
	elseif crate == "LunarSwordCrate" then
		lootbox3[#lootbox3 + 1] = {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		}
	elseif crate == "LiveEvent" then
		lootbox[#lootbox + 1] = {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		}
	elseif crate == "DungeonSwordCrate" then
		table.insert(lootbox2, {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		})
	end
end

for _, v13 in v:GetSwordsInRarity("Secret") do
	local crate = v13.Crate

	if not crate then
		continue
	end

	local chance = v13.Chance

	if chance and crate == "DungeonSwordCrate" then
		table.insert(lootbox2, {
			Chance = chance,
			Item = {
				Swords = { v13.Name }
			}
		})
	end
end

local _ = {
	Sword = {
		Common = v8,
		Rare = v7,
		Legendary = v6
	},
	Explosions = {
		Common = v2,
		Rare = v3,
		Legendary = v4
	}
}
return {
	NormalExplosionCrate = {
		{
			Chance = 1,
			Item = {
				Lootbox = v4
			}
		},
		{
			Chance = 10,
			Item = {
				Lootbox = v3
			}
		},
		{
			Chance = 89,
			Item = {
				Lootbox = v2
			}
		}
	},
	PremiumExplosionCrate = {
		{
			Chance = 10,
			Item = {
				Lootbox = v4
			}
		},
		{
			Chance = 90,
			Item = {
				Lootbox = v3
			}
		}
	},
	NormalSwordCrate = {
		{
			Chance = 1,
			Item = {
				Lootbox = v6
			}
		},
		{
			Chance = 10,
			Item = {
				Lootbox = v7
			}
		},
		{
			Chance = 89,
			Item = {
				Lootbox = v8
			}
		}
	},
	PremiumSwordCrate = {
		{
			Chance = 10,
			Item = {
				Lootbox = v6
			}
		},
		{
			Chance = 90,
			Item = {
				Lootbox = v7
			}
		}
	},
	LunarSwordCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = lootbox3
			}
		}
	},
	HalloweenSwordCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = lootbox4
			}
		}
	},
	ChristmasSwordCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = lootbox5
			}
		}
	},
	DungeonSwordCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = lootbox2
			}
		}
	},
	SmallChestOfCoins = {
		{
			Chance = 80,
			Icon = "rbxassetid://14713794582",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 100 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 15,
			Icon = "rbxassetid://14713779371",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 250 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 4,
			Icon = "rbxassetid://14713785287",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 350 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 1,
			Icon = "rbxassetid://14713787523",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 500 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	BigChestOfCoins = {
		{
			Chance = 70,
			Icon = "rbxassetid://14713797174",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 250 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 20,
			Icon = "rbxassetid://14713794582",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 500 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 8,
			Icon = "rbxassetid://14713779371",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 750 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 1.9,
			Icon = "rbxassetid://14713785287",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 1000 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 0.1,
			Icon = "rbxassetid://14713787523",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 1500 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	AncientSwordChest = {
		{
			Chance = 75,
			Icon = "rbxassetid://15316186440",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Ancient Cutlass" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 20,
			Icon = "rbxassetid://15316201428",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Ancient Spear" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 4,
			Icon = "rbxassetid://15316213854",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Great Axe" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 0.9,
			Icon = "rbxassetid://15316216519",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Halberd" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 0.1,
			Icon = "rbxassetid://15316219581",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Runic Wrecker" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	LiveEventCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = lootbox
			}
		}
	},
	ClanSwordCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Starburst Pop" }
						},
						Chance = 50
					},
					{
						Item = {
							Swords = { "Evolved Royal Sword" }
						},
						Chance = 40
					},
					{
						Item = {
							Swords = { "Royal Sovereign" }
						},
						Chance = 9
					},
					{
						Item = {
							Swords = { "Imperial Monarch" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	ClanMagicalCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Starflare" }
						},
						Chance = 35
					},
					{
						Item = {
							Swords = { "Titan Fang" }
						},
						Chance = 35
					},
					{
						Item = {
							Emotes = { "Bring It!" }
						},
						Chance = 19
					},
					{
						Item = {
							Swords = { "Runesteel" }
						},
						Chance = 10
					},
					{
						Item = {
							Swords = { "Plasma Katana" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	SerpentLiveEventCrate = {
		{
			Chance = 100,
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Serpent's Rage" }
						},
						Chance = 30.5
					},
					{
						Item = {
							Swords = { "Serpent's Lance" }
						},
						Chance = 31
					},
					{
						Item = {
							Emotes = { "Emote35" }
						},
						Chance = 23
					},
					{
						Item = {
							Swords = { "Serpent's Fang" }
						},
						Chance = 10.5
					},
					{
						Item = {
							Abilities = { "Serpent Shadow Clone" }
						},
						Chance = 5
					}
				}
			}
		}
	},
	SecretSwordCrate = {
		{
			Chance = 75,
			Icon = "rbxassetid://0",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Phoenix Rebirth" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 20,
			Icon = "rbxassetid://0",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Frozen Eternity" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 5,
			Icon = "rbxassetid://0",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Dragon's Wraith" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	CyberSecretSwordCrate = {
		{
			Chance = 70,
			Icon = "rbxassetid://17300302515",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Architect" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 30,
			Icon = "rbxassetid://17300312892",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Subversion" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	DungeonSecretSwordCrate = {
		{
			Chance = 100,
			Icon = "rbxassetid://17196820524",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Celestial Aegis" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	SecretExplosionCrate = {
		{
			Chance = 50,
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "L Explosion" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 50,
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Disco Ball" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	DailyQuestCrate = {
		{
			Chance = 25,
			CrateName = "DailyQuestCoinCrate",
			CrateType = "Coins"
		},
		{
			Chance = 25,
			CrateName = "DailyQuestSwordCrate",
			CrateType = "Sword"
		},
		{
			Chance = 25,
			CrateName = "DailyQuestExplosionCrate",
			CrateType = "Explosion"
		},
		{
			Chance = 25,
			CrateName = "DailyQuestEmoteCrate",
			CrateType = "Emote"
		}
	},
	DailyQuestCoinCrate = {
		{
			Chance = 40,
			ItemName = "100Coins",
			Icon = "rbxassetid://14713794582",
			ActualReward = {
				Credits = 100
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 100 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 30,
			ItemName = "150Coins",
			ActualReward = {
				Credits = 150
			},
			Icon = "rbxassetid://14713794582",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 150 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 15,
			ItemName = "200Coins",
			ActualReward = {
				Credits = 200
			},
			Icon = "rbxassetid://14713779371",
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 200 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 10,
			ItemName = "250Coins",
			Icon = "rbxassetid://14713785287",
			ActualReward = {
				Credits = 250
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 250 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 5,
			ItemName = "300Coins",
			Icon = "rbxassetid://14713794582",
			ActualReward = {
				Credits = 300
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Coins = { 300 .. "Coins" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	DailyQuestSwordCrate = {
		{
			Chance = 38,
			Icon = "rbxassetid://15316186440",
			ItemName = "Grass Blade",
			ItemType = "Sword",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Grass Blade" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 38,
			Icon = "rbxassetid://15316201428",
			ItemName = "Fire Blade",
			ItemType = "Sword",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Fire Blade" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 19,
			Icon = "rbxassetid://15316213854",
			ItemName = "Water Blade",
			ItemType = "Sword",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Water Blade" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 5,
			Icon = "rbxassetid://15316213854",
			ItemName = "Electric Blade",
			ItemType = "Sword",
			Item = {
				Lootbox = {
					{
						Item = {
							Swords = { "Electric Blade" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	DailyQuestExplosionCrate = {
		{
			Chance = 38,
			ItemName = "Pastel Rainbow",
			ItemType = "Explosion",
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Pastel Rainbow" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 35,
			ItemName = "Hacker Explosion",
			ItemType = "Explosion",
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Hacker Explosion" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 19,
			ItemName = "Butterfly Explosion",
			ItemType = "Explosion",
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Butterfly Explosion" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 8,
			ItemName = "Nuclear Explosion",
			ItemType = "Explosion",
			Item = {
				Lootbox = {
					{
						Item = {
							Explosions = { "Nuclear Explosion" }
						},
						Chance = 1
					}
				}
			}
		}
	},
	DailyQuestEmoteCrate = {
		{
			Chance = 38,
			ItemName = "Emote126",
			ItemType = "Emote",
			ActualReward = {
				Emote = "Emote126"
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Emote = { "Emote126" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 35,
			ItemName = "Emote127",
			ItemType = "Emote",
			ActualReward = {
				Emote = "Emote127"
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Emote = { "Emote127" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 19,
			ItemName = "Emote129",
			ItemType = "Emote",
			ActualReward = {
				Emote = "Emote129"
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Emote = { "Emote129" }
						},
						Chance = 1
					}
				}
			}
		},
		{
			Chance = 8,
			ItemName = "Emote128",
			ItemType = "Emote",
			ActualReward = {
				Emote = "Emote128"
			},
			Item = {
				Lootbox = {
					{
						Item = {
							Emote = { "Emote128" }
						},
						Chance = 1
					}
				}
			}
		}
	}
}