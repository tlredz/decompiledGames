local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Parent.Parent.Common.RewardInfo)
local v2 = require3(script.Parent.Parent.ServerInfo)
local unixTimestamp

if v2.isTestGame() or v2.isDevPlaceGame() then
	unixTimestamp = DateTime.fromUniversalTime(2025, 11, 28).UnixTimestamp
else
	unixTimestamp = DateTime.fromUniversalTime(2025, 12, 1).UnixTimestamp
end

return {
	MaxDayToStart = 31,
	DayToEnd = 31,
	StartTimestamp = unixTimestamp,
	CountdownStart = unixTimestamp - ((v2.isTestGame() or v2.isDevPlaceGame()) and 4 or 2) * 86400,
	LoginRewards = {
		[3] = v.createGachaSpinsReward(3),
		[7] = v.createGachaSpinsReward(7),
		[14] = v.createGachaSpinsReward(14),
		[19] = v.createChristmasSelectionCrate(1)
	},
	RecoverProductIds = {
		[2] = 1697730910,
		[3] = 1697730942,
		[4] = 1697731006,
		[5] = 1697731092,
		[6] = 1697731158,
		[7] = 1697731217
	},
	SelectionCrate = {
		{
			Reward = v.createSwordReward("Northern Warrior")
		},
		{
			Reward = v.createEmoteReward("Christmas Carols")
		},
		{
			Reward = v.createExplosionReward("Holiday Treeburst")
		},
		{
			Reward = v.createAbilityFreeTrialReward("Quantum Arena", 259200)
		},
		{
			NeedPreviousRewards = true,
			Reward = v.createSwordReward("???")
		}
	},
	UnrecoverableDays = {},
	HighlightedDays = {
		[7] = "Gold",
		[13] = "Gold",
		[20] = "Gold",
		[25] = "Gold"
	},
	Rewards = {
		v.createListReward({ v.createSeasonPassCurrencyReward(25), v.createGachaSpinsReward(1) }, nil, nil, true),
		v.createEmoteReward("Emote1096"),
		v.createListReward(
			{ v.createSeasonPassCurrencyReward(50), v.createAbilityFreeTrialReward("Titan Blade", 900) },
			nil,
			nil,
			true
		),
		v.createGachaSpinsReward(1),
		v.createSeasonPassCurrencyReward(50),
		v.createEmoteReward("Emote1095"),
		v.createListReward(
			{ v.createGachaSpinsReward(1), v.createAbilityFreeTrialReward("Infinity", 900) },
			nil,
			nil,
			true
		),
		v.createSeasonPassCurrencyReward(75),
		v.createGachaSpinsReward(1),
		v.createSwordReward("Tidal Verdance"),
		v.createGachaSpinsReward(1),
		v.createSeasonPassCurrencyReward(75),
		v.createChristmasSelectionCrate(1),
		v.createGachaSpinsReward(1),
		v.createListReward(
			{ v.createSeasonPassCurrencyReward(100), v.createAbilityFreeTrialReward("Slashes of Fury", 900) },
			nil,
			nil,
			true
		),
		v.createGachaSpinsReward(1),
		v.createSwordReward("Glacial Seraph Staff"),
		v.createGachaSpinsReward(1),
		v.createSwordReward("Winterlord Aetherbrand"),
		v.createSeasonPassCurrencyReward(100),
		v.createAbilityFreeTrialReward("Death Slash", 900),
		v.createGachaSpinsReward(1),
		v.createSeasonPassCurrencyReward(150),
		v.createGachaSpinsReward(1),
		v.createChristmasSelectionCrate(1),
		v.createSeasonPassCurrencyReward(175),
		v.createGachaSpinsReward(1),
		v.createSeasonPassCurrencyReward(200),
		v.createGachaSpinsReward(1),
		v.createSwordReward("Crescent Frost Reaver"),
		(v.createChristmasSelectionCrate(1))
	}
}