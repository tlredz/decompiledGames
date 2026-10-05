local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	EndTime = 1754175599,
	Items = {
		{
			Reward = v.createFinisherReward("Queen Blade"),
			Stock = 125,
			DevProduct = 3343290320,
			GiftDevProduct = 3343290323
		},
		{
			Reward = v.createFinisherReward("King Blade"),
			Stock = 125,
			DevProduct = 3343290321,
			GiftDevProduct = 3343290326
		},
		{
			Reward = v.createFinisherReward("Chroma Blade"),
			Stock = 125,
			DevProduct = 3343290331,
			GiftDevProduct = 3343290324
		},
		{
			Reward = v.createFinisherReward("Moonflower Katana"),
			Stock = 100,
			DevProduct = 3343290325,
			GiftDevProduct = 3343290322
		},
		{
			Reward = v.createFinisherReward("Noob"),
			Stock = 15,
			DevProduct = 3343290330,
			GiftDevProduct = 3343290333
		}
	},
	MaxItemsPerPool = 5
}