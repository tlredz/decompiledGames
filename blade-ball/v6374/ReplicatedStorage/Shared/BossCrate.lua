local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		displayName = "Crate 1",
		name = "Crate1",
		icon = "rbxassetid://81466892641107",
		xp = 200,
		rewards = {
			[v.createCoinsReward(250, "Small")] = 40.2,
			[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")] = 26.8,
			[v.createCoinsReward(800, "Med")] = 17,
			[v.createSwordReward("Stone Aeroblades")] = 15,
			[v.createGoldenNuggetReward(1)] = 1
		}
	},
	{
		displayName = "Crate 2",
		name = "Crate2",
		icon = "rbxassetid://115001473838574",
		xp = 400,
		rewards = {
			[v.createCoinsReward(500, "Med")] = 35.24,
			[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")] = 37.26,
			[v.createCoinsReward(1200, "Med")] = 6,
			[v.createSwordReward("Stone Nunchucks")] = 20,
			[v.createGoldenNuggetReward(1)] = 1.5
		}
	},
	{
		displayName = "Crate 3",
		name = "Crate3",
		icon = "rbxassetid://125325010518854",
		xp = 800,
		rewards = {
			[v.createCoinsReward(1000, "Big")] = 34.61,
			[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")] = 32.39,
			[v.createCoinsReward(1800, "Huge")] = 6,
			[v.createSwordReward("Stone Katana")] = 25,
			[v.createGoldenNuggetReward(1)] = 2
		}
	},
	{
		displayName = "Crate 4",
		name = "Crate4",
		icon = "rbxassetid://104327753351909",
		xp = 1600,
		rewards = {
			[v.createCoinsReward(1250, "Big")] = 32.29,
			[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")] = 29.21,
			[v.createCoinsReward(2000, "Huge")] = 6,
			[v.createSwordReward("Stone Scythe")] = 30,
			[v.createGoldenNuggetReward(1)] = 2.5
		}
	},
	{
		displayName = "Crate 5",
		name = "Crate5",
		icon = "rbxassetid://133337596552558",
		xp = 4000,
		rewards = {
			[v.createCoinsReward(1750, "Big")] = 21.53,
			[v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")] = 21.17,
			[v.createCoinsReward(2250, "Huge")] = 4,
			[v.createSwordReward("Stone Scythe")] = 33.3,
			[v.createGoldenNuggetReward(1)] = 20
		}
	}
}