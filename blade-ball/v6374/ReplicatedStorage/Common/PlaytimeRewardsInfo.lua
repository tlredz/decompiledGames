local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.RewardInfo)
return {
	Rewards = {
		{
			Duration = 300,
			Reward = v.createCrateKeyReward("Sword", 1, "Sword Crate", "rbxassetid://15049301853")
		},
		{
			Duration = 600,
			Reward = v.createCoinsReward(100, "Small")
		},
		{
			Duration = 900,
			Reward = v.createWheelSpinReward(1)
		},
		{
			Duration = 1200,
			Reward = v.createCoinsReward(150, "Med")
		},
		{
			Duration = 1500,
			Reward = v.createWheelSpinReward(1)
		},
		{
			Duration = 1800,
			Reward = v.createCrateKeyReward(
				"PremiumExplosion",
				1,
				"Premium Explosion Crate",
				"rbxassetid://15049303003"
			)
		}
	}
}