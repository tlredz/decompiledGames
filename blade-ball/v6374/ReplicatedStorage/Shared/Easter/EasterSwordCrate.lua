local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Reward = v.createSwordReward("Dawn Petal"),
		Chance = 0.35,
		ChanceColor = Color3.fromRGB(20, 255, 235)
	},
	{
		Reward = v.createSwordReward("Springtide Edge"),
		Chance = 0.27,
		ChanceColor = Color3.fromRGB(20, 255, 235)
	},
	{
		Reward = v.createSwordReward("Spring Bloom"),
		Chance = 0.2245,
		ChanceColor = Color3.fromRGB(20, 255, 235)
	},
	{
		Reward = v.createSwordReward("Egg's Blossom"),
		Chance = 0.08,
		ChanceColor = Color3.fromRGB(255, 204, 20)
	},
	{
		Reward = v.createSwordReward("Spring's Guardian"),
		Chance = 0.05,
		ChanceColor = Color3.fromRGB(255, 204, 20)
	},
	{
		Reward = v.createSwordReward("Hare's Honor"),
		Chance = 0.02,
		ChanceColor = Color3.fromRGB(255, 204, 20)
	},
	{
		Reward = v.createSwordReward("Hatchling's Honor"),
		Chance = 0.005,
		ChanceColor = Color3.fromRGB(255, 20, 20)
	},
	{
		Reward = v.createSwordReward("Eggquinox Blade"),
		Chance = 0.0005,
		ChanceColor = Color3.fromRGB(255, 20, 20)
	}
}