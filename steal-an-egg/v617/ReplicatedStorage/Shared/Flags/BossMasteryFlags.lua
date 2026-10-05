local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local v = {
	TokensPerKill = FastFlags.Replicated("Game.BossMastery.TokensPerKill", Asserts.IntegerNonNegative, 1200),
	MilestoneKillOverrides = FastFlags.Replicated(
		"Game.BossMastery.MilestoneKillOverrides",
		Asserts.Map(Asserts.String, Asserts.IntegerPositive),
		{}
	),
	MilestoneRewardIdOverrides = FastFlags.Replicated(
		"Game.BossMastery.MilestoneRewardIdOverrides",
		Asserts.Map(Asserts.String, Asserts.String),
		{}
	),
	TokenBoostPercentOverrides = FastFlags.Replicated(
		"Game.BossMastery.TokenBoostPercentOverrides",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{}
	),
	ShopPriceOverrides = FastFlags.Replicated(
		"Game.BossMastery.ShopPriceOverrides",
		Asserts.Map(Asserts.String, Asserts.IntegerPositive),
		{}
	),
	ShopProductIds = FastFlags.Replicated("Game.BossMastery.ShopProductIds", Asserts.Array(Asserts.String), {
		"CashBooster",
		"SpeedBoost",
		"TreadmillBooster",
		"MutationConsumable"
	}),
	InfiniteRewardEveryKills = FastFlags.Replicated(
		"Game.BossMastery.InfiniteRewardEveryKills",
		Asserts.IntegerPositive,
		10
	),
	InfiniteRewardId = FastFlags.Replicated("Game.BossMastery.InfiniteRewardId", Asserts.String, "RotationMutatedEgg"),
	InfiniteBannerWeights = FastFlags.Replicated(
		"Game.BossMastery.InfiniteBannerWeights",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{
			Verdant = 55,
			Umbral = 40,
			Radiant = 5
		}
	),
	CashBoosterDurationSeconds = FastFlags.Replicated(
		"Game.BossMastery.CashBoosterDurationSeconds",
		Asserts.FinitePositive,
		600
	),
	CashBoosterMultiplier = FastFlags.Replicated("Game.BossMastery.CashBoosterMultiplier", Asserts.FinitePositive, 2),
	EggGrowthBoostDurationSeconds = FastFlags.Replicated(
		"Game.BossMastery.EggGrowthBoostDurationSeconds",
		Asserts.FinitePositive,
		300
	),
	EggGrowthBoostMultiplier = FastFlags.Replicated(
		"Game.BossMastery.EggGrowthBoostMultiplier",
		Asserts.FinitePositive,
		1.25
	),
	LuckBoostDurationSeconds = FastFlags.Replicated(
		"Game.BossMastery.LuckBoostDurationSeconds",
		Asserts.FinitePositive,
		300
	),
	LuckBoostExtraPercent = FastFlags.Replicated(
		"Game.BossMastery.LuckBoostExtraPercent",
		Asserts.FiniteNonNegative,
		25
	),
	SpeedBoostDurationSeconds = FastFlags.Replicated(
		"Game.BossMastery.SpeedBoostDurationSeconds",
		Asserts.FinitePositive,
		300
	),
	SpeedBoostMultiplier = FastFlags.Replicated("Game.BossMastery.SpeedBoostMultiplier", Asserts.FinitePositive, 1.25),
	TreadmillBoostDurationSeconds = FastFlags.Replicated(
		"Game.BossMastery.TreadmillBoostDurationSeconds",
		Asserts.FinitePositive,
		600
	),
	TreadmillBoostMultiplier = FastFlags.Replicated(
		"Game.BossMastery.TreadmillBoostMultiplier",
		Asserts.FinitePositive,
		2
	),
	MutationConsumableSuccessPercent = FastFlags.Replicated(
		"Game.BossMastery.MutationConsumableSuccessPercent",
		Asserts.Range(0, 100),
		10
	),
	TrapsPerPurchase = FastFlags.Replicated("Game.BossMastery.TrapsPerPurchase", Asserts.IntegerPositive, 1)
}
return table.freeze(v)