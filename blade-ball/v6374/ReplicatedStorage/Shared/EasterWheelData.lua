local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local start

if require3(ReplicatedStorage2.ServerInfo).isTestGame() then
	start = DateTime.now()
else
	start = DateTime.fromUniversalTime(2024, 3, 30, 12)
end

return {
	Start = start,
	End = DateTime.fromUniversalTime(2024, 4, 12, 17),
	GuaranteedReward = v.createSwordReward("Easter Scythe"),
	HourlyReward = v.createEasterWheelSpinsReward(1),
	Lucks = {
		1.5,
		2,
		2.5,
		3
	},
	StreakHoursRewards = {
		{
			Reward = v.createEasterWheelSpinsReward(1),
			TimeStamp = 3600
		},
		{
			Reward = v.createEasterWheelSpinsReward(2),
			TimeStamp = 7200
		},
		{
			Reward = v.createEasterWheelSpinsReward(4),
			TimeStamp = 10800
		},
		{
			Reward = v.createEasterWheelSpinsReward(8),
			TimeStamp = 14400
		}
	},
	Inner = {
		Item1 = {
			Angle = -36.3,
			Probability = 10,
			Reward = v.createExplosionReward("Easter Explosion")
		},
		Item2 = {
			Angle = 54,
			Probability = 40,
			Reward = v.createEmoteReward("Emote230")
		},
		Item3 = {
			Angle = 143.2,
			Probability = 40,
			Reward = v.createBunnyCurrencyReward(250)
		},
		Item4 = {
			Angle = 231,
			Probability = 10,
			Advance = true,
			IconId = ""
		}
	},
	Middle = {
		Item1 = {
			Angle = 0.5,
			Probability = 10,
			Reward = v.createCoinsReward(2500, "Huge"),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Singularity", 900),
				ExpireTime = 1713286800
			}
		},
		Item2 = {
			Angle = 62.4,
			Probability = 45,
			Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853")
		},
		Item3 = {
			Angle = 119.4,
			Probability = 15,
			Advance = true,
			IconId = ""
		},
		Item4 = {
			Angle = 178.3,
			Probability = 12,
			Reward = v.createBunnyCurrencyReward(100),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Dribble", 900),
				ExpireTime = 1713286800
			}
		},
		Item5 = {
			Angle = 238,
			Probability = 10,
			Reward = v.createEasterGachaSpinReward(1),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Dragon Spirit", 900),
				ExpireTime = 1713286800
			}
		},
		Item6 = {
			Angle = 296.4,
			Probability = 13,
			Reward = v.createBunnyCurrencyReward(100),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Calming Deflection", 900),
				ExpireTime = 1713286800
			}
		}
	},
	Outer = {
		Item1 = {
			Angle = 0,
			Probability = 10,
			Reward = v.createWheelSpinReward(1),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Serpent Shadow Clone", 900),
				ExpireTime = 1713286800
			}
		},
		Item2 = {
			Angle = 46.7,
			Probability = 15,
			Reward = v.createExplosionReward("Slime Egg"),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Death Slash", 900),
				ExpireTime = 1713286800
			}
		},
		Item3 = {
			Angle = 91.4,
			Probability = 15,
			Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853"),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Phantom", 900),
				ExpireTime = 1713286800
			}
		},
		Item4 = {
			Angle = 137.4,
			Probability = 20,
			Reward = v.createEasterWheelSpinsReward(1),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Titan Blade", 900),
				ExpireTime = 1713286800
			}
		},
		Item5 = {
			Angle = 180,
			Probability = 10,
			Reward = v.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Continuity Zero", 900),
				ExpireTime = 1713286800
			}
		},
		Item6 = {
			Angle = 223,
			Probability = 25,
			Advance = true,
			Lucky = true,
			IconId = ""
		},
		Item7 = {
			Angle = 269.5,
			Probability = 8,
			Reward = v.createCoinsReward(1000, "Small"),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Infinity", 900),
				ExpireTime = 1713286800
			}
		},
		Item8 = {
			Angle = 313.7,
			Probability = 2,
			Reward = v.createCoinsReward(2500, "Small"),
			AbilityTrial = {
				Reward = v.createAbilityFreeTrialReward("Quantum Arena", 900),
				ExpireTime = 1713286800
			}
		}
	}
}