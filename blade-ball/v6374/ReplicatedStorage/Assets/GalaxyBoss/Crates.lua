game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RewardInfo = require(ReplicatedStorage.Common.RewardInfo)
return {
	{
		displayName = "Broken Ogre Crate",
		name = "Crate1",
		icon = "rbxassetid://131447376640472",
		xp = 200,
		rewards = {
			[RewardInfo.createCoinsReward(250, "Small")] = 36,
			[RewardInfo.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)] = 24,
			[RewardInfo.createCoinsReward(800, "Med")] = 6,
			[RewardInfo.createSwordReward("Ember Blade")] = 17,
			[RewardInfo.createExplosionReward("Ember Burst")] = 5,
			[RewardInfo.createExplosionReward("Inferno Rebirth")] = 3
		}
	},
	{
		displayName = "Ogre Crate",
		name = "Crate2",
		icon = "rbxassetid://96618464070901",
		xp = 400,
		rewards = {
			[RewardInfo.createCoinsReward(500, "Med")] = 35,
			[RewardInfo.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)] = 37,
			[RewardInfo.createCoinsReward(1200, "Med")] = 6,
			[RewardInfo.createSwordReward("Flame Edge")] = 12,
			[RewardInfo.createExplosionReward("Ember Burst")] = 6,
			[RewardInfo.createExplosionReward("Inferno Rebirth")] = 4
		}
	},
	{
		displayName = "Evolved Ogre Crate",
		name = "Crate3",
		icon = "rbxassetid://140415766400166",
		xp = 800,
		rewards = {
			[RewardInfo.createCoinsReward(1000, "Big")] = 42,
			[RewardInfo.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)] = 39.3,
			[RewardInfo.createCoinsReward(1800, "Huge")] = 6,
			[RewardInfo.createSwordReward("Blazing Saber")] = 0.7,
			[RewardInfo.createExplosionReward("Ember Burst")] = 7,
			[RewardInfo.createExplosionReward("Inferno Rebirth")] = 5
		}
	},
	{
		displayName = "Frost Ice Ogre Crate",
		name = "Crate4",
		icon = "rbxassetid://105376484120860",
		xp = 1600,
		rewards = {
			[RewardInfo.createCoinsReward(1250, "Huge")] = 40.9,
			[RewardInfo.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)] = 37,
			[RewardInfo.createCoinsReward(2000, "Huge")] = 5,
			[RewardInfo.createCoinsReward(3500, "Massive")] = 1,
			[RewardInfo.createSwordReward("Inferno Reaver")] = 0.1,
			[RewardInfo.createExplosionReward("Ember Burst")] = 10,
			[RewardInfo.createExplosionReward("Inferno Rebirth")] = 6
		}
	},
	{
		displayName = "Undead Ogre Crate",
		name = "Crate5",
		icon = "rbxassetid://139228865323049",
		xp = 4000,
		rewards = {
			[RewardInfo.createCoinsReward(1750, "Massive")] = 42.9,
			[RewardInfo.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)] = 42,
			[RewardInfo.createCoinsReward(2250, "Huge")] = 6,
			[RewardInfo.createCoinsReward(3500, "Massive")] = 2,
			[RewardInfo.createEmoteReward("Warm Up")] = 5,
			[RewardInfo.createEmoteReward("Phoenix's Rise")] = 2,
			[RewardInfo.createSwordReward("Winged Warrior")] = 0.1
		}
	}
}