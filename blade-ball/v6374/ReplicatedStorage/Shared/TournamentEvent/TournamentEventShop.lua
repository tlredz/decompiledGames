local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return table.freeze({
	{
		Reward = v.createSwordReward("Arcsteel Katana"),
		Price = 1
	},
	{
		Reward = v.createExplosionReward("Dust Puff"),
		Price = 2
	},
	{
		Reward = v.createEmoteReward("Pendulum"),
		Price = 2
	},
	{
		Reward = v.createEmoteReward("Dancing Skeleton"),
		Price = 5
	},
	{
		Reward = v.createSwordReward("Stormforged Shortblade"),
		Price = 3
	},
	{
		Reward = v.createEmoteReward("Stylish Water Angel"),
		Price = 5
	},
	{
		Reward = v.createSwordReward("Orbit Spear"),
		Price = 50,
		LimitedStockId = "Orbit Spear"
	}
})