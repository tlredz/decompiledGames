local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Parent.RewardInfo)
return {
	DailyLogin = {
		Rewards = {
			[0] = {
				Rewards = { v.createCoinsReward(100, "Small") }
			},
			[1] = {
				Rewards = { v.createCoinsReward(175, "Small"), v.createSwordReward("Holy Axe") }
			},
			[2] = {
				Rewards = { v.createCoinsReward(425, "Med") }
			},
			[3] = {
				Rewards = { v.createCoinsReward(700, "Med") }
			},
			[4] = {
				Rewards = { v.createCoinsReward(1300, "Big"), v.createSwordReward("Holy Sword") }
			}
		}
	},
	Longterm = {
		Cooldown = 72000,
		Rewards = require3(script.LongtermLoginRewards).Rewards
	},
	D30 = {
		Cooldown = 72000,
		Rewards = require3(script.D30LoginRewards).Rewards,
		ConsecutiveRewards = {
			[5] = v.createExplosionReward("Ice Explosion"),
			[7] = v.createSwordReward("Void Sword"),
			[9] = v.createSwordReward("Dune Cleaver")
		}
	},
	Legacy = {
		Rewards = {
			{
				Credits = 60
			},
			{
				Credits = 180
			},
			{
				Credits = 360
			},
			{
				Credits = 520
			},
			{
				SwordSkins = { "Holy Sword" }
			}
		}
	}
}