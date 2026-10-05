local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = {
	[0] = 100,
	[1] = 500,
	[2] = 1000,
	[3] = 1000
}
local GlobalTieredCrate = {}

function GlobalTieredCrate.getTier(list, p)
	for i = #list - 1, 1, -1 do
		if list[i] < p then
			return i + 1
		end
	end

	return 1
end

function GlobalTieredCrate.getPrice(p: number, p2: number)
	local v3 = p - 1
	return math.round(math.map(p2, 0, 1, v2[v3], v2[p]) / 10) * 10
end

GlobalTieredCrate.CrateId = "Constellation"
GlobalTieredCrate.Rewards = {
	{
		[v.createSwordReward("Orange Phoenixblade")] = 0.546,
		[v.createExplosionReward("Volcanic Burst")] = 0.25,
		[v.createSwordReward("Fire Fang Blade")] = 0.1,
		[v.createExplosionReward("Hellish Landscape")] = 0.004,
		[v.createSwordReward("Dragon Tail Fan")] = 0.1
	},
	{
		[v.createSwordReward("Orange Phoenixblade")] = 0.609,
		[v.createExplosionReward("Volcanic Burst")] = 0.25,
		[v.createSwordReward("Fire Fang Blade")] = 0.1,
		[v.createExplosionReward("Hellish Landscape")] = 0.04,
		[v.createSwordReward("Devil Hornblade")] = 0.001
	},
	{
		[v.createSwordReward("Orange Phoenixblade")] = 0.5539,
		[v.createExplosionReward("Volcanic Burst")] = 0.25,
		[v.createSwordReward("Fire Fang Blade")] = 0.15,
		[v.createExplosionReward("Hellish Landscape")] = 0.046,
		[v.createSwordReward("Hellfire King")] = 0.0001
	}
}
GlobalTieredCrate.ContributionsLuck = {
	{
		Required = 100,
		Luck = 1.25
	},
	{
		Required = 1000,
		Luck = 1.5
	},
	{
		Required = 5000,
		Luck = 2
	}
}
return GlobalTieredCrate