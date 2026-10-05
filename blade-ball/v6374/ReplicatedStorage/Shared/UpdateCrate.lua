local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
return {
	CurrentCrate = "Default",
	BigReward = v.createSwordReward("Slime"),
	Crates = {
		Default = {
			Icon = "rbxassetid://89176156553098",
			Rewards = {
				Tier1 = {
					Chance = 40,
					Icon = "rbxassetid://83780768962644",
					Contents = {
						{
							Reward = v.createCoinsReward(100, "Big"),
							Chance = 40
						},
						{
							Reward = v.createSeasonPassCurrencyReward(25),
							Chance = 20
						},
						{
							Reward = v.createBoostReward("Coins2x", 10),
							Chance = 20
						},
						{
							Reward = v.createWheelSpinReward(1),
							Chance = 15
						},
						{
							Reward = v.createGachaSpinsReward(1),
							Chance = 5
						}
					}
				},
				Tier2 = {
					Chance = 35,
					Icon = "rbxassetid://134858975779767",
					CustomTierColor = Color3.fromRGB(152, 255, 108),
					Contents = {
						{
							Reward = v.createGachaSpinsReward(1),
							Chance = 26
						},
						{
							Reward = v.createSeasonPassCurrencyReward(50),
							Chance = 20
						},
						{
							Reward = v.createBoostReward("Coins2x", 15),
							Chance = 16
						},
						{
							Reward = v.createWheelSpinReward(3),
							Chance = 16
						},
						{
							Reward = v.createCrateKeyReward(
								"PremiumSword",
								1,
								"Premium Sword Crate",
								"rbxassetid://16039967646"
							),
							Chance = 16
						},
						{
							Reward = v.createSwordReward("Titansteel Saber"),
							Chance = 6
						}
					}
				},
				Tier3 = {
					Chance = 20,
					Icon = "rbxassetid://80562863480820",
					CustomTierColor = Color3.fromRGB(255, 235, 82),
					Contents = {
						{
							Reward = v.createCoinsReward(2500, "Big"),
							Chance = 45
						},
						{
							Reward = v.createGachaSpinsReward(2),
							Chance = 20
						},
						{
							Reward = v.createWheelSpinReward(5),
							Chance = 15
						},
						{
							Reward = v.createSeasonPassCurrencyReward(100),
							Chance = 10
						},
						{
							Reward = v.createBoostReward("Coins2x", 30),
							Chance = 5
						},
						{
							Reward = v.createSwordReward("Oblivion Edge"),
							Chance = 5
						}
					}
				},
				Tier4 = {
					Chance = 4,
					Icon = "rbxassetid://139424675945983",
					CustomTierColor = Color3.fromRGB(255, 62, 97),
					Contents = {
						{
							Reward = v.createGachaSpinsReward(5),
							Chance = 50
						},
						{
							Reward = v.createExplosionReward("Slime Splash"),
							Chance = 18
						},
						{
							Reward = v.createGachaSpinsReward(3),
							Chance = 17
						},
						{
							Reward = v.createSeasonPassCurrencyReward(150),
							Chance = 8
						},
						{
							Reward = v.createWheelSpinReward(5),
							Chance = 4
						},
						{
							Reward = v.createSwordReward("Celestial Vanguard"),
							Chance = 3
						}
					}
				},
				Tier5 = {
					Chance = 1,
					Icon = "rbxassetid://138605065274280",
					CustomTierColor = Color3.fromRGB(53, 151, 255),
					Contents = {
						{
							Reward = v.createGachaSpinsReward(15),
							Chance = 70
						},
						{
							Reward = v.createCoinsReward(20000, "Big"),
							Chance = 29.9
						},
						{
							Reward = v.createSwordReward("Aurelius"),
							Chance = 0.1
						}
					}
				}
			}
		}
	},
	LimitedStockRewardId = "Aurelius",
	LimitedStockRewardInitialStock = 3
}