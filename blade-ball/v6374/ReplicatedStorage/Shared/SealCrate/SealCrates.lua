local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
return {
	IsActive = function()
		return v2.GetFFlag("SealCrateEnabled", false) and v2.GetFFlag("SealCrateEndTime", 0) > workspace:GetServerTimeNow()
	end,
	BigReward = v.createSwordReward("Slime"),
	Crates = {
		Free = {
			Icon = "rbxassetid://89176156553098",
			Rewards = {
				[v.createExplosionReward("Slime Splash")] = 50,
				[v.createEmoteReward("Quiet All")] = 30,
				[v.createSwordReward("Toxic Tendril")] = 15,
				[v.createSwordReward("Slime Sword")] = 4,
				[v.createSwordReward("Super Bow")] = 0.995,
				[v.createSwordReward("Slime")] = 0.005
			}
		},
		Chroma = {
			Icon = "rbxassetid://71196966932096",
			Rewards = {
				[v.createExplosionReward("Slime Splash")] = 40,
				[v.createEmoteReward("Quiet All")] = 24.5,
				[v.createSwordReward("Toxic Tendril")] = 20,
				[v.createSwordReward("Slime Sword")] = 12,
				[v.createSwordReward("Super Bow")] = 2,
				[v.createSwordReward("Slime")] = 1
			},
			DevProducts = {
				[1] = 2686720387,
				[3] = 2686720390,
				[10] = 2686720388
			},
			GiftDevProducts = {
				[10] = 2686720389
			}
		}
	},
	LimitedStockRewardId = "Slime",
	FreeCrateKillsRequirement = 25,
	OpenedFreeCrateRequirement = 50,
	OpenedFreeCrateChromaRewardAmount = 3
}