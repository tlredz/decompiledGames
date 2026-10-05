local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = v2.isTestGame() and true
local coinsReward = v.createCoinsReward(0, "Small")
coinsReward.Icon = ""
local HourlyWheelData = {
	Id = "Crystal",
	DisplayName = "Crystal",
	ReplionPath = "HourlyWheel.Crystal",
	Products = {
		Spinx1 = 2320419773,
		Spinx1First = 2320420398
	},
	StreakHoursRewards = {
		{
			Reward = v.createHourlyWheelSpinsReward(1, "Crystal"),
			Luck = 0.5,
			TimeStamp = 3600
		},
		{
			Reward = v.createHourlyWheelSpinsReward(2, "Crystal"),
			Luck = 1,
			TimeStamp = 7200
		},
		{
			Reward = v.createHourlyWheelSpinsReward(4, "Crystal"),
			Luck = 1.5,
			TimeStamp = 10800
		},
		{
			Reward = v.createHourlyWheelSpinsReward(8, "Crystal"),
			Luck = 2,
			TimeStamp = 14400
		}
	},
	Start = 0,
	End = 0,
	GuaranteedRewards = 0,
	GuaranteedRewardChanceRestOn = "Item4",
	HourlyReward = 0,
	Inner = 0,
	Middle = 0,
	Outer = 0
}
local start

if v4 then
	start = DateTime.now()
else
	start = DateTime.fromUnixTimestamp(1748104200)
end

HourlyWheelData.Start = start
HourlyWheelData.End = DateTime.fromUnixTimestamp(DateTime.fromUniversalTime(2025, 10, 3, 17).UnixTimestamp + 1209600)
HourlyWheelData.GuaranteedRewards = {
	{
		Chance = v4 and 92 or 5,
		Reward = v.createSwordReward("Coral Greatsword"),
		LimitedStock = true,
		Replacement = {
			Reward = v.createSwordReward("Flowing Waterblade"),
			Chance = v4 and 90.5 or 5
		},
		ShouldUseReplacement = function(object)
			local v6

			if RunService:IsClient() then
				v6 = v3.Client:WaitReplion("LimitedStockItems")
			else
				v6 = v3.Server:WaitReplion("LimitedStockItems")
			end

			if not (v6 and v6:Get("Loaded")) then
				return true
			end

			local v7 = v6:Get({ "Stock", "Coral Greatsword" })
			return not v7 or v7 <= 0 or object:Get("ReceivedHourlyWheelCoralGreatsword") == true
		end
	}
}
HourlyWheelData.HourlyReward = v.createHourlyWheelSpinsReward(1, "Crystal")
HourlyWheelData.Inner = {
	Item4 = {
		Angle = 235,
		Probability = v4 and 92 or 5,
		Advance = true,
		IconId = ""
	},
	Item2 = {
		Angle = 56,
		Probability = v4 and 2 or 40,
		Reward = v.createEmoteReward("Air Guitar")
	},
	Item3 = {
		Angle = 144,
		Probability = v4 and 2 or 40,
		Reward = v.createSeasonPassCurrencyReward(150)
	},
	Item1 = {
		Angle = -33,
		Probability = v4 and 4 or 15,
		Reward = v.createExplosionReward("Infernal Bloom")
	}
}
HourlyWheelData.Middle = {
	Item3 = {
		Angle = 56,
		Probability = v4 and 80 or 15,
		Advance = true,
		IconId = ""
	},
	Item2 = {
		Angle = 118,
		Probability = v4 and 5 or 45,
		Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853")
	},
	Item6 = {
		Angle = 300,
		Probability = v4 and 3 or 13,
		Reward = v.createSeasonPassCurrencyReward(50),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Calming Deflection", 900),
			ExpireTime = 1748363400
		}
	},
	Item4 = {
		Angle = 180,
		Probability = v4 and 2 or 12,
		Reward = v.createSeasonPassCurrencyReward(50),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Dribble", 900),
			ExpireTime = 1748363400
		}
	},
	Item5 = {
		Angle = 235,
		Probability = v4 and 5 or 10,
		Reward = v.createWheelSpinReward(1),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Dragon Spirit", 900),
			ExpireTime = 1748363400
		}
	},
	Item1 = {
		Angle = 2,
		Probability = 5,
		Reward = v.createCoinsReward(2500, "Huge"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Singularity", 900),
			ExpireTime = 1748363400
		}
	}
}
HourlyWheelData.Outer = {
	Item6 = {
		Angle = 179,
		Probability = v4 and 65 or 25,
		Advance = true,
		Lucky = true,
		IconId = ""
	},
	Item2 = {
		Angle = 45,
		Probability = v4 and 5 or 15,
		Reward = v.createExplosionReward("Core Breach"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Death Slash", 900),
			ExpireTime = 1748363400
		}
	},
	Item3 = {
		Angle = 89,
		Probability = v4 and 5 or 15,
		Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Phantom", 900),
			ExpireTime = 1748363400
		}
	},
	Item4 = {
		Angle = 133.5,
		Probability = v4 and 5 or 20,
		Reward = v.createHourlyWheelSpinsReward(1, "Crystal"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Titan Blade", 900),
			ExpireTime = 1748363400
		}
	},
	Item5 = {
		Angle = 225,
		Probability = v4 and 5 or 10,
		Reward = v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Continuity Zero", 900),
			ExpireTime = 1748363400
		}
	},
	Item1 = {
		Angle = 3.5,
		Probability = v4 and 5 or 7,
		Reward = v.createCoinsReward(500, "Med"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Serpent Shadow Clone", 900),
			ExpireTime = 1748363400
		}
	},
	Item7 = {
		Angle = 269,
		Probability = 6,
		Reward = v.createCoinsReward(1000, "Big"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Infinity", 900),
			ExpireTime = 1748363400
		}
	},
	Item8 = {
		Angle = 317,
		Probability = 2,
		Reward = v.createCoinsReward(2500, "Huge"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Quantum Arena", 900),
			ExpireTime = 1748363400
		}
	}
}
return HourlyWheelData