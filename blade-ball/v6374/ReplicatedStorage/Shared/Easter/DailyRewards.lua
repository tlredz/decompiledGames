local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Streak = 1,
		FreeReward = v.createBunnyCurrencyReward(100),
		PremiumReward = v.createSwordReward("Bunny's Apprenticeblade")
	},
	{
		Streak = 2,
		FreeReward = v.createBunnyCurrencyReward(125),
		PremiumReward = v.createBunnyCurrencyReward(250)
	},
	{
		Streak = 3,
		FreeReward = v.createBunnyCurrencyReward(150),
		PremiumReward = v.createEmoteReward("Flip n Footstep")
	},
	{
		Streak = 4,
		FreeReward = v.createBunnyCurrencyReward(200),
		PremiumReward = v.createBunnyCurrencyReward(400)
	},
	{
		Streak = 5,
		FreeReward = v.createBunnyCurrencyReward(250),
		PremiumReward = v.createEmoteReward("Giant Egg")
	},
	{
		Streak = 6,
		FreeReward = v.createBunnyCurrencyReward(300),
		PremiumReward = v.createBunnyCurrencyReward(600)
	},
	{
		Streak = 7,
		FreeReward = v.createBunnyCurrencyReward(350),
		PremiumReward = v.createSwordReward("Pastel Easterblade")
	}
}