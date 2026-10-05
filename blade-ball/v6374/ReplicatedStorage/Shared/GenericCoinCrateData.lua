local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = {
	EndTime = DateTime.fromUniversalTime(2024, 9, 14, 17, 0).UnixTimestamp,
	Price = 5000,
	Rewards = {
		{
			Chance = 30,
			Reward = v.createSwordReward("Steel Fang")
		},
		{
			Chance = 25,
			Reward = v.createExplosionReward("Iron Blast")
		},
		{
			Chance = 15,
			Reward = v.createSwordReward("Iron Edge")
		},
		{
			Chance = 15,
			Reward = v.createExplosionReward("Dragon's Fury")
		},
		{
			Chance = 6,
			Reward = v.createEmoteReward("Hands on Hips"),
			FrameIndex = 7
		},
		{
			Chance = 5,
			Reward = v.createSwordReward("Silver Strike"),
			FrameIndex = 6
		},
		{
			Chance = 2.95,
			Reward = v.createEmoteReward("Warrior's Roar"),
			FrameIndex = 2
		},
		{
			Chance = 1,
			Reward = v.createSwordReward("Dragon's Claw"),
			FrameIndex = 1
		},
		{
			Chance = 0.05,
			Reward = v.createSwordReward("Eclipse Reaver"),
			FrameIndex = 5
		}
	}
}
return table.freeze(v2)