local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local coinsReward = v.createCoinsReward(0)
coinsReward.Icon = ""
local SynthWheelData = {
	Products = {
		Spinx1 = 1888566537,
		Spinx1First = 1888566536
	},
	StreakHoursRewards = {
		{
			Reward = v.createSynthWheelSpinsReward(1),
			TimeStamp = 3600
		},
		{
			Reward = v.createSynthWheelSpinsReward(2),
			TimeStamp = 7200
		},
		{
			Reward = v.createSynthWheelSpinsReward(4),
			TimeStamp = 10800
		},
		{
			Reward = v.createSynthWheelSpinsReward(8),
			TimeStamp = 14400
		}
	},
	Start = 0,
	End = 0,
	GuaranteedReward = 0,
	GuaranteedReplacement = nil,
	HourlyReward = 0,
	Inner = 0,
	Middle = 0,
	Outer = 0
}
local start

if v2.isTestGame() then
	start = DateTime.now()
else
	start = DateTime.fromUniversalTime(2024, 7, 27, 12)
end

SynthWheelData.Start = start
SynthWheelData.End = DateTime.fromUniversalTime(2024, 8, 10, 16)
SynthWheelData.GuaranteedReward = v.createAbilityReward("Doppelganger")
SynthWheelData.HourlyReward = v.createSynthWheelSpinsReward(1)
SynthWheelData.Inner = {
	Item1 = {
		Angle = -33,
		Probability = 15,
		Reward = v.createExplosionReward("Phantom Echo")
	},
	Item2 = {
		Angle = 56,
		Probability = 40,
		Reward = v.createEmoteReward("Emote447")
	},
	Item3 = {
		Angle = 144,
		Probability = 40,
		Reward = v.createSeasonPassCurrencyReward(150)
	},
	Item4 = {
		Angle = 235,
		Probability = 5,
		Advance = true,
		IconId = ""
	}
}
SynthWheelData.Middle = {
	Item3 = {
		Angle = 56,
		Probability = 15,
		Advance = true,
		IconId = ""
	},
	Item2 = {
		Angle = 118,
		Probability = 45,
		Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853")
	},
	Item6 = {
		Angle = 300,
		Probability = 13,
		Reward = v.createSeasonPassCurrencyReward(50),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Singularity", 900),
			ExpireTime = 1717520400
		}
	},
	Item4 = {
		Angle = 180,
		Probability = 12,
		Reward = v.createSeasonPassCurrencyReward(50),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Dribble", 900),
			ExpireTime = 1717520400
		}
	},
	Item5 = {
		Angle = 235,
		Probability = 10,
		Reward = v.createCoinsReward(200, "Small"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Bunny Leap", 900),
			ExpireTime = 1717520400
		}
	},
	Item1 = {
		Angle = 2,
		Probability = 5,
		Reward = v.createCoinsReward(2500, "Huge"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Slash of Duality", 900),
			ExpireTime = 1717520400
		}
	}
}
SynthWheelData.Outer = {
	Item1 = {
		Angle = 3.5,
		Probability = 10,
		Reward = v.createCoinsReward(500, "Med"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Serpent Shadow Clone", 900),
			ExpireTime = 1717520400
		}
	},
	Item2 = {
		Angle = 45,
		Probability = 15,
		Reward = v.createExplosionReward("Tidal Drench"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Death Slash", 900),
			ExpireTime = 1717520400
		}
	},
	Item3 = {
		Angle = 89,
		Probability = 15,
		Reward = v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://15049301853"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Phantom", 900),
			ExpireTime = 1717520400
		}
	},
	Item4 = {
		Angle = 133.5,
		Probability = 15,
		Reward = v.createSynthWheelSpinsReward(1),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Titan Blade", 900),
			ExpireTime = 1717520400
		}
	},
	Item5 = {
		Angle = 225,
		Probability = 10,
		Reward = v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Continuity Zero", 900),
			ExpireTime = 1717520400
		}
	},
	Item6 = {
		Angle = 179,
		Probability = 25,
		Advance = true,
		Lucky = true,
		IconId = ""
	},
	Item7 = {
		Angle = 269,
		Probability = 8,
		Reward = v.createCoinsReward(1000, "Big"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Infinity", 900),
			ExpireTime = 1717520400
		}
	},
	Item8 = {
		Angle = 317,
		Probability = 2,
		Reward = v.createCoinsReward(2500, "Huge"),
		AbilityTrial = {
			Reward = v.createAbilityFreeTrialReward("Quantum Arena", 900),
			ExpireTime = 1717520400
		}
	}
}
return SynthWheelData