local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Seconds = 300,
		Reward = v.createSeasonPassCurrencyReward(10)
	},
	{
		Seconds = 900,
		Reward = v.createSeasonPassCurrencyReward(15)
	},
	{
		Seconds = 1800,
		Reward = v.createSeasonPassCurrencyReward(25)
	},
	{
		Seconds = 3600,
		Reward = v.createSeasonPassCurrencyReward(50)
	},
	{
		Seconds = 10800,
		Reward = v.createSeasonPassCurrencyReward(75)
	},
	{
		Seconds = 18000,
		Reward = v.createSwordReward("Cherry Blossom Coreblade"),
		FallbackReward = v.createSeasonPassCurrencyReward(100)
	}
}