local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		{
			Rank = 1,
			Rewards = { v.createSwordReward("Angelic Cleaver") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Solarflare Glaive") }
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
			Rewards = { v.createSwordReward("Savior Greatsword") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Cursed Obsession") }
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
			Rewards = { v.createSwordReward("Avalanche Blade") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Iridescent Stormblade") }
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
			Rewards = { v.createSwordReward("Eternal Autumn") }
		},
		{
			Rank = 5,
			Rewards = { v.createSwordReward("Lover's Axe") }
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
			Rewards = { v.createSwordReward("Rose Piercer") }
		},
		{
			Rank = 5,
			Rewards = { v.createExplosionReward("Purple Heart") }
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