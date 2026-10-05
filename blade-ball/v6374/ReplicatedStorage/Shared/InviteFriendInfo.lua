local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	ResetCurrentDayRewards = 86400,
	ResetRewards = 86400,
	ResetFriendsCooldown = 86400,
	RewardCooldown = 10800,
	RewardsPerDay = 3,
	Rewards = {
		{
			duration = 600,
			reward = v.createGachaSpinsReward(1)
		},
		{
			duration = 1200,
			reward = v.createGachaSpinsReward(2)
		},
		{
			duration = 1800,
			reward = v.createGachaSpinsReward(3)
		}
	}
}