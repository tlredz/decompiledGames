local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	StartTime = DateTime.fromUniversalTime(2023, 12, 24, 16),
	EndTime = DateTime.fromUniversalTime(2023, 12, 29, 16),
	Rewards = {
		Day1 = {
			Reward1 = v.createCoinsReward(500, "Small"),
			Reward2 = v.createEmoteReward("Emote53"),
			Reward3 = v.createCrateKeyReward("PremiumSword", 2, "Premium Sword", "rbxassetid://16039967646"),
			Expiration = 0
		},
		Day2 = {
			Reward1 = v.createCoinsReward(1000, "Medium"),
			Expiration = 86400
		},
		Day3 = {
			Reward1 = v.createCoinsReward(1500, "Big"),
			Expiration = 86400
		},
		Day4 = {
			Reward1 = v.createCoinsReward(2000, "Huge"),
			Expiration = 86400
		},
		Day5 = {
			Reward1 = v.createCrateKeyReward("PremiumSword", 4, "Premium Sword", "rbxassetid://16039967646"),
			Expiration = 86400
		}
	}
}