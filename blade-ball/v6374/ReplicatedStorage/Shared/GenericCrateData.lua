local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = {
	EndTime = DateTime.fromUniversalTime(2026, 3, 7, 18).UnixTimestamp,
	Price = 5000,
	ShowLegacyExistCounts = false,
	Currency = "Credits",
	CurrencyDisplayName = "Coin",
	CurrencyDisplayNamePlural = "Coins",
	SpinAmounts = { 1 },
	CooldownPerCrate = 4.140000000000001,
	Rewards = {
		{
			Chance = 28,
			Reward = v.createTitleReward("P2W")
		},
		{
			Chance = 24,
			Reward = v.createTitleReward("67")
		},
		{
			Chance = 20,
			Reward = v.createTitleReward("2026")
		},
		{
			Chance = 13,
			Reward = v.createTitleReward("Clutch")
		},
		{
			Chance = 8,
			Reward = v.createTitleReward("Dot")
		},
		{
			Chance = 6,
			Reward = v.createTitleReward("Titan")
		},
		{
			Chance = 1,
			Reward = v.createTitleReward("GOAT")
		}
	}
}
return table.freeze(v2)