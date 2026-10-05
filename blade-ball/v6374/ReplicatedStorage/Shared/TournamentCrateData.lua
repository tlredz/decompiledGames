local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.ServerInfo)
local dateTime = DateTime.fromUniversalTime(2024, 3, 16, 16)
return {
	SpinTable = function(items, p: number)
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
	end,
	RewardPool = {
		{
			Probability = 25,
			Reward = v.createSwordReward("Bronze Sword")
		},
		{
			Probability = 20,
			Reward = v.createSwordReward("Silver Blade")
		},
		{
			Probability = 10,
			Reward = v.createSwordReward("Golden Sword")
		},
		{
			Probability = 5,
			Reward = v.createSwordReward("Diamond Sword")
		},
		{
			Probability = 10,
			Reward = v.createExplosionReward("Comic Boom Explosion")
		},
		{
			Probability = 16,
			Reward = v.createEmoteReward("Emote156")
		},
		{
			Probability = 10,
			Reward = v.createEmoteReward("Emote157")
		},
		{
			Probability = 3,
			Reward = v.createEmoteReward("Emote154")
		},
		{
			Probability = 1,
			Reward = v.createSwordReward("Emerald Katana"),
			Replacement = {
				Reward = v.createExplosionReward("RIP")
			}
		}
	},
	TimeLength = dateTime,
	DailyLoginStreaks = {
		{
			Streak = 1,
			Tickets = 1
		},
		{
			Streak = 3,
			Tickets = 3
		},
		{
			Streak = 5,
			Tickets = 5
		},
		{
			Streak = 7,
			Tickets = 7
		}
	}
}