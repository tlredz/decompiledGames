local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Rank = 3,
		Rewards = { v.createSwordReward("Resolution Rumble Champion") }
	},
	{
		Rank = 10,
		Rewards = { v.createSwordReward("Resolution Rumble Warrior") }
	},
	{
		Rank = 25,
		Rewards = { v.createExplosionReward("2025") }
	}
}