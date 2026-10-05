local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	CNYEvent = {
		EndTime = DateTime.fromUniversalTime(2026, 2, 28, 17),
		Partition = "cnyevent",
		LeaderboardId = 1,
		MaxClaimDays = 3,
		DailyRewards = {
			{
				{
					Rank = 1,
					Rewards = { v.createSwordReward("PLACEHOLDER") }
				},
				{
					Rank = 10,
					Rewards = { v.createSwordReward("PLACEHOLDER") }
				},
				{
					Rank = 50,
					Rewards = { v.createGachaSpinsReward(25) }
				}
			}
		},
		AwardTime = 2,
		Disabled = false
	}
}