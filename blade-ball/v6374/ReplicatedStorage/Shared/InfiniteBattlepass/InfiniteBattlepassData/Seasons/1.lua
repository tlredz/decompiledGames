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
	Name = "Blackhole",
	StartTimestamp = DateTime.fromUniversalTime(2026, 1, 10, 16).UnixTimestamp,
	EndTimestamp = DateTime.fromUniversalTime(2026, 3, 28, 16).UnixTimestamp,
	Gacha = v3.Gacha,
	Crate = v3.Crate,
	ExplosionCrate = v3.ExplosionCrate,
	ExplosionCrateId = v3.ExplosionCrateId,
	Currency = v3.Currency,
	Rewards = v.createInfiniteRewards({
		seed = "infinite-battlepass-testing",
		rewards = {
			[1] = {
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[5] = {
				free = v2.createEmoteReward("Load It Up")
			},
			[10] = {
				free = v2.createEmoteReward("Robot Swing")
			},
			[15] = {
				free = v2.createSwordReward("Starlight Shardblade")
			},
			[20] = {
				premium = v2.createEmoteReward("Left and Right")
			},
			[25] = {
				free = v2.createExplosionReward("Pulsar Pulse")
			},
			[30] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal"),
				premium = v2.createSwordReward("Cosmic Current Rapier")
			},
			[45] = {
				free = v2.createSwordReward("Orion Arc Katana"),
				premium = v2.createEmoteReward("Ridin Dancing")
			},
			[60] = {
				free = v2.createExplosionReward("Aurora Splash"),
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[65] = {
				premium = v2.createSwordReward("Astra Nova Longblade")
			},
			[75] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal")
			},
			[80] = {
				free = v2.createSwordReward("Lunar Halo Cutlass")
			},
			[90] = {
				free = v2.createSwordReward("Deep Space Fang"),
				premium = v2.createSwordReward("Voidglass Edge")
			},
			[100] = {
				premium = v2.createExplosionReward("Void Ripple")
			},
			[105] = {
				free = v2.createSwordReward("Meteorwake Shortsword")
			},
			[120] = {
				free = v2.createBattlepassSelectionCrateReward(1, "Normal"),
				premium = v2.createSwordReward("Perihelion Sunsteel")
			},
			[135] = {
				premium = v2.createSwordReward("Galactic Tide Greatsword")
			},
			[150] = {
				premium = v2.createBattlepassSelectionCrateReward(1, "Premium")
			},
			[180] = {
				premium = v2.createExplosionReward("Galactic Shatter")
			},
			[200] = {
				free = v2.createExplosionReward("Blackhole Burst")
			},
			[220] = {
				premium = v2.createExplosionReward("Supercluster Detonation")
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
				v2.createAbilityFreeTrialReward("Quantum Arena", 900),
				v2.createAbilityFreeTrialReward("Infinity", 900),
				v2.createAbilityFreeTrialReward("Slashes of Fury", 900),
				v2.createAbilityFreeTrialReward("Titan Blade", 900),
				v2.createAbilityFreeTrialReward("Death Slash", 900),
				v2.createAbilityFreeTrialReward("Dribble", 900)
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
				v2.createAbilityFreeTrialReward("Quantum Arena", 900),
				v2.createAbilityFreeTrialReward("Infinity", 900),
				v2.createAbilityFreeTrialReward("Slashes of Fury", 900),
				v2.createAbilityFreeTrialReward("Titan Blade", 900),
				v2.createAbilityFreeTrialReward("Death Slash", 900),
				v2.createAbilityFreeTrialReward("Dribble", 900)
			}, v2.createBoostReward("BattlepassLuck", 5))
		}
	})
}