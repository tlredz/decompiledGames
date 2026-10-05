local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3("../Types")
local v = require3("../Rewards")
local v2 = require3("@game/ReplicatedStorage/Common/RewardInfo")
local v3 = require3("../External")
return {
	Name = "Wild West",
	StartTimestamp = require3(game.ReplicatedStorage.ServerInfo).isTestGame() and os.time() or DateTime.fromUniversalTime(
		2026,
		4,
		25,
		16
	).UnixTimestamp,
	EndTimestamp = DateTime.fromUniversalTime(2026, 6, 13, 17).UnixTimestamp,
	Gacha = v3.Gacha,
	Crate = v3.Crate,
	ExplosionCrate = v3.ExplosionCrate,
	ExplosionCrateId = v3.ExplosionCrateId,
	Currency = v3.Currency,
	Rewards = v.createInfiniteRewards({
		seed = "infinite-wild-west-edition",
		rewards = {
			[1] = {
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[5] = {
				free = v2.createSwordReward("Deadeye Glacier")
			},
			[10] = {
				free = v2.createSwordReward("Deadman's Edge")
			},
			[15] = {
				free = v2.createSwordReward("Diamond Dagger")
			},
			[20] = {
				premium = v2.createSwordReward("Astral Whisper")
			},
			[25] = {
				free = v2.createSwordReward("Emerald Cyclone")
			},
			[30] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal"),
				premium = v2.createSwordReward("Abyssal Spike")
			},
			[45] = {
				free = v2.createSwordReward("Abyssal Colossus"),
				premium = v2.createSwordReward("Nightfall Blade")
			},
			[60] = {
				free = v2.createSwordReward("Crimson Whisper"),
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[65] = {
				premium = v2.createSwordReward("Infernal Slasher")
			},
			[75] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal")
			},
			[80] = {
				free = v2.createSwordReward("Dust Devil Cleaver")
			},
			[90] = {
				free = v2.createSwordReward("Void Sovereign"),
				premium = v2.createSwordReward("Toxic Reaper")
			},
			[100] = {
				premium = v2.createSwordReward("Frostcore Edge")
			},
			[105] = {
				free = v2.createSwordReward("Aurora Prism")
			},
			[120] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal"),
				premium = v2.createSwordReward("Voidfang Eclipse")
			},
			[135] = {
				premium = v2.createSwordReward("Outlaw's Oath")
			},
			[150] = {
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[180] = {
				premium = v2.createSwordReward("Frostveil Twins")
			},
			[200] = {
				free = v2.createSwordReward("Celestial Scepter")
			},
			[220] = {
				premium = v2.createExplosionReward("High Noon")
			},
			[250] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal"),
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			}
		},
		pool = {
			{
				reward = v2.createCoinsReward(100, "Small"),
				chance = 12
			},
			{
				reward = v2.createCoinsReward(500, "Med"),
				chance = 10
			},
			{
				reward = v2.createCoinsReward(1000, "Big"),
				chance = 5
			},
			{
				reward = v2.createSeasonPassCurrencyReward(100),
				chance = 10
			},
			{
				reward = v2.createSeasonPassCurrencyReward(120),
				chance = 8
			},
			{
				reward = v2.createSeasonPassCurrencyReward(140),
				chance = 6
			},
			{
				reward = v2.createSeasonPassCurrencyReward(500),
				chance = 4
			},
			{
				reward = v2.createBoostReward("Coins2x", 5),
				chance = 5
			},
			{
				reward = v2.createBoostReward("BattlepassLuck", 5),
				chance = 5
			},
			{
				reward = v2.createGachaSpinsReward(1),
				chance = 3
			},
			v.createRandomPool(2, {
				v2.createAbilityFreeTrialReward("Quantum Arena", 300),
				v2.createAbilityFreeTrialReward("Infinity", 300),
				v2.createAbilityFreeTrialReward("Slashes of Fury", 300),
				v2.createAbilityFreeTrialReward("Titan Blade", 300),
				v2.createAbilityFreeTrialReward("Death Slash", 300),
				v2.createAbilityFreeTrialReward("Dribble", 300)
			}, v2.createCoinsReward(500, "Med"))
		},
		premiumEmptyChance = 0.5,
		premiumPool = {
			{
				reward = v2.createBoostReward("Coins2x", 5),
				chance = 5
			},
			{
				reward = v2.createBoostReward("BattlepassLuck", 5),
				chance = 5
			},
			v.createRandomPool(2, {
				v2.createAbilityFreeTrialReward("Quantum Arena", 300),
				v2.createAbilityFreeTrialReward("Infinity", 300),
				v2.createAbilityFreeTrialReward("Slashes of Fury", 300),
				v2.createAbilityFreeTrialReward("Titan Blade", 300),
				v2.createAbilityFreeTrialReward("Death Slash", 300),
				v2.createAbilityFreeTrialReward("Dribble", 300)
			}, v2.createBoostReward("BattlepassLuck", 5))
		}
	})
}