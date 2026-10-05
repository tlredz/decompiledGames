local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	{
		Rank = 1,
		Reward = v.createSwordReward("Mystical Crossbow")
	},
	{
		Rank = 3,
		Reward = v.createSwordReward("Keyblade")
	},
	{
		Rank = 10,
		Reward = v.createExplosionReward("Blue Hexplosion")
	}
}