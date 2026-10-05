local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Price = 200,
		Currency = "BunnyCoins",
		Reward = v.createExplosionReward("Pastel Burst"),
		ReplionPath = { "ExplosionSkins", "Unlocked", "Pastel Burst" },
		WithinPath = true
	},
	{
		Price = 50,
		Currency = "BunnyCoins",
		Reward = v.createSwordReward("Crested Blade"),
		ReplionPath = { "SwordSkins", "Unlocked", "Crested Blade" }
	},
	{
		Price = 300,
		Currency = "BunnyCoins",
		Reward = v.createSwordReward("Jester Blade"),
		ReplionPath = { "SwordSkins", "Unlocked", "Jester Blade" }
	},
	{
		Price = 250,
		Currency = "BunnyCoins",
		Reward = v.createExplosionReward("Gummy Pop"),
		ReplionPath = { "ExplosionSkins", "Unlocked", "Gummy Pop" }
	}
}