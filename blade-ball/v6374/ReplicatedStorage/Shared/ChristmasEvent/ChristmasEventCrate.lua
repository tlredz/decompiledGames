local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	Items = {
		{
			Probability = 35,
			Reward = v.createSwordReward("Icicle Splinter"),
			ItemType = "Sword"
		},
		{
			Probability = 20,
			Reward = v.createSwordReward("Caroler’s Steel"),
			ItemType = "Sword"
		},
		{
			Probability = 40,
			Reward = v.createSwordReward("Frozen Bellblade"),
			ItemType = "Sword"
		},
		{
			Probability = 3.45,
			Reward = v.createSwordReward("Frostnova Frostblade"),
			ItemType = "Sword"
		},
		{
			Probability = 1,
			Reward = v.createSwordReward("Elven Carveblade"),
			ItemType = "Sword"
		},
		{
			Probability = 0.5,
			Reward = v.createSwordReward("Krampusbane"),
			ItemType = "Sword"
		},
		{
			Probability = 0.05,
			Reward = v.createSwordReward("Corrupted Staff"),
			ItemType = "Sword"
		}
	},
	SpinTable = function(items, p)
		local total = 0

		for _, item in items do
			total += item.Probability
		end

		local v2 = Random.new(p):NextNumber() * total
		local total2 = 0

		for k, item in items do
			total2 += item.Probability

			if v2 <= total2 then
				return k, item
			end
		end

		return nil
	end
}