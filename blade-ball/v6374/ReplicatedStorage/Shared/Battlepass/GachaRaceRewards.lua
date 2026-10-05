local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Avis Scythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("The Nooblade") }
		},
		{
			Rank = 10,
			Rewards = { v.createSciFiSpinReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createSciFiSpinReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Flowing Katana") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Santa's Wrecker") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Christmas Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Christmas Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Venom Blade") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Resolution Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "New Year Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "New Year Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Horizon Reaper") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Plasma Beam Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Galaxy Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Galaxy Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Allseeing Seer") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Blade of the Damned") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Eternal Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Eternal Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Icarus' Scythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Mortal's Demise") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Mythical Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Mythical Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Ocean's Fury") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Sandstorm Slasher") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Tropical Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Tropical Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Cybotic Greatsword") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Cyber King's Sword") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Techno Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Techno Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Soulreaper's Scythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Voidstrike Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Haunted Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Haunted Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Winter's Wrath") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Glacial Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Christmas Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Christmas Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Crystal Reaver") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Arctic King's Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Christmas Spins") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Christmas Spins") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("New Years Greatsword") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("New Years Slicer") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Mech Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Mech Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Rose Railgun") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Rose Backsword") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Mech Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Mech Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Voidhunter Scythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Aethertech Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Mech Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Mech Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Amethyst Greatsword") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Poison Ivy") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50, "Halloween Spin") }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25, "Halloween Spin") }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Voided Greatscythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Celestial Spear") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Duet of Destruction") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Melody of Ruin") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Dual Demonic Greatsword") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Demonic Greatsword") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Allseeing Spear") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Kingdom's Blade") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Bloomlight Greatscythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Celestial Staff") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Blizzard Kingscythe") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Ice Warrior") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	},
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("FROSTWALL") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Icebound Dominus") }
		},
		{
			Rank = 10,
			Rewards = { v.createGachaSpinsReward(50) }
		},
		{
			Rank = 50,
			Rewards = { v.createGachaSpinsReward(25) }
		}
	}
}