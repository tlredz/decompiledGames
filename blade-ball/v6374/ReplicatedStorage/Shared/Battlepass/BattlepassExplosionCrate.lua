local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local rewards = {
	{
		Chance = 27,
		Reward = v.createSwordReward("Frostbite Reaver")
	},
	{
		Chance = 25,
		Reward = v.createSwordReward("Snowbound Shiv")
	},
	{
		Chance = 16,
		Reward = v.createSwordReward("Tinsel Cutter")
	},
	{
		Chance = 15,
		Reward = v.createSwordReward("Snowdrift Slasher")
	},
	{
		Chance = 10,
		Reward = v.createSwordReward("Glacial Tyrant")
	},
	{
		Chance = 4,
		Reward = v.createSwordReward("Firwood Blade")
	},
	{
		Chance = 2,
		Reward = v.createSwordReward("Polar Dominion")
	},
	{
		Chance = 1,
		Reward = v.createSwordReward("Frostnova Saber")
	}
}
return {
	Rewards = rewards,
	SpinTable = function(p: number)
		local total = 0

		for _, v3 in ipairs(rewards) do
			total += v3.Chance
		end

		local v3 = Random.new(p):NextNumber() * total
		local total2 = 0

		for i, v4 in ipairs(rewards) do
			total2 += v4.Chance

			if v3 <= total2 then
				return i, v4
			end
		end

		return nil
	end
}