local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return table.freeze({
	{
		{
			Reward = v.createSwordReward("Alienated Backscythe"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Alienated Backblade"),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(50),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 100
		}
	},
	{
		{
			Reward = v.createSwordReward("Alienated Backscythe"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Alienated Backblade"),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(50),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 100
		}
	},
	{
		{
			Reward = v.createSwordReward("Ghostly Vanquish"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Stellar Guard"),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(50),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 100
		}
	},
	{
		{
			Reward = v.createSwordReward("Amethyst Slicer"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Corrupted Staff"),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(50),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 100
		}
	},
	{
		{
			Reward = v.createSwordReward("Oceanic Captain"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Undead Flames"),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(50),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 100
		}
	},
	{
		{
			Reward = v.createAbilityReward("Fracture"),
			Top = 3
		},
		{
			Reward = v.createGachaSpinsReward(25),
			Top = 10
		},
		{
			Reward = v.createGachaSpinsReward(10),
			Top = 25
		},
		{
			Reward = v.createGachaSpinsReward(5),
			Top = 100
		}
	}
})