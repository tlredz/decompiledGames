local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local v = {
	Enabled = FastFlags.Replicated("Game.Scramble.TradeIn.Enabled", Asserts.Boolean, true),
	SpeedPowerRequirement = FastFlags.Replicated(
		"Game.Scramble.TradeIn.SpeedPowerRequirement",
		Asserts.FiniteNonNegative,
		170000
	),
	RotationSeconds = FastFlags.Replicated(
		"Game.Scramble.TradeIn.RotationSeconds",
		Asserts.IntegerRange(3600, 86400),
		3600
	),
	PityThreshold = FastFlags.Replicated("Game.Scramble.TradeIn.PityThreshold", Asserts.IntegerNonNegative, 200),
	FreeRefreshesPerDay = FastFlags.Replicated(
		"Game.Scramble.TradeIn.FreeRefreshesPerDay",
		Asserts.IntegerNonNegative,
		2
	),
	SpawnAreaId = FastFlags.Replicated("Game.Scramble.TradeIn.SpawnAreaId", Asserts.String, ""),
	BannerWeights = FastFlags.Replicated(
		"Game.Scramble.TradeIn.BannerWeights",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{}
	),
	PetWeights = FastFlags.Replicated(
		"Game.Scramble.TradeIn.PetWeights",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{}
	),
	RecipesEnabled = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.Enabled", Asserts.Boolean, true),
	RerollOnRotation = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.RerollOnRotation", Asserts.Boolean, true),
	MinSpawnChance = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.MinSpawnChance", Asserts.FiniteNonNegative, 2),
	MaxSpawnChance = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.MaxSpawnChance",
		Asserts.FiniteNonNegative,
		100
	),
	EasyBand = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.EasyBand", Asserts.FiniteNonNegative, 22),
	MediumBand = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.MediumBand", Asserts.FiniteNonNegative, 10),
	HardPenalty = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.HardPenalty", Asserts.FiniteNonNegative, 0.35),
	ExtendBelow = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.ExtendBelow", Asserts.IntegerNonNegative, 2),
	SlotOverrides = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.SlotOverrides",
		Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.FiniteNonNegative)),
		{}
	),
	RequireEasyPet = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.RequireEasyPet", Asserts.Boolean, true),
	MaxEasyPets = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.MaxEasyPets", Asserts.IntegerNonNegative, 3),
	MaxHardPets = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.MaxHardPets", Asserts.IntegerNonNegative, 1),
	MaxNonEasyPets = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.MaxNonEasyPets", Asserts.IntegerNonNegative, 2),
	AllowDuplicatePets = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.AllowDuplicatePets",
		Asserts.Boolean,
		false
	),
	MaxRecipeAttempts = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.MaxRecipeAttempts",
		Asserts.IntegerPositive,
		100
	),
	ExcludedPets = FastFlags.Replicated("Game.Scramble.TradeIn.Recipes.ExcludedPets", Asserts.Array(Asserts.String), {}),
	BannerRanges = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.BannerRanges",
		Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.String)),
		{}
	),
	ZoneLadderOverride = FastFlags.Replicated(
		"Game.Scramble.TradeIn.Recipes.ZoneLadderOverride",
		Asserts.Array(Asserts.String),
		{}
	)
}
return table.freeze(v)