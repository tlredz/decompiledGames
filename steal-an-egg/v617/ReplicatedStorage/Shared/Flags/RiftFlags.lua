local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local v = {
	Retired = FastFlags.Replicated("Game.Rift.Retired", Asserts.Boolean, false),
	SwapAtUnix = FastFlags.Replicated("Game.Rift.SwapAtUnix", Asserts.IntegerPositive, 1790434800),
	SpeedPowerRequirement = FastFlags.Replicated("Game.Rift.SpeedPowerRequirement", Asserts.FiniteNonNegative, 170000),
	RotationSeconds = FastFlags.Replicated("Game.Rift.RotationSeconds", Asserts.IntegerPositive, 10800),
	PityThreshold = FastFlags.Replicated("Game.Rift.PityThreshold", Asserts.IntegerNonNegative, 50),
	PityWeights = FastFlags.Replicated(
		"Game.Rift.PityWeights",
		Asserts.Array(Asserts.FiniteNonNegative),
		{ 48, 37, 15 }
	),
	PityResetsOnNaturalWin = FastFlags.Replicated("Game.Rift.PityResetsOnNaturalWin", Asserts.Boolean, true),
	FreeRefreshesPerDay = FastFlags.Replicated("Game.Rift.FreeRefreshesPerDay", Asserts.IntegerNonNegative, 2),
	SpawnAreaId = FastFlags.Replicated("Game.Rift.SpawnAreaId", Asserts.String, ""),
	BannerWeights = FastFlags.Replicated(
		"Game.Rift.BannerWeights",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{}
	),
	PetWeights = FastFlags.Replicated(
		"Game.Rift.PetWeights",
		Asserts.Map(Asserts.String, Asserts.FiniteNonNegative),
		{}
	),
	RecipesEnabled = FastFlags.Replicated("Game.Rift.Recipes.Enabled", Asserts.Boolean, true),
	RerollOnRotation = FastFlags.Replicated("Game.Rift.Recipes.RerollOnRotation", Asserts.Boolean, true),
	MinSpawnChance = FastFlags.Replicated("Game.Rift.Recipes.MinSpawnChance", Asserts.FiniteNonNegative, 2),
	MaxSpawnChance = FastFlags.Replicated("Game.Rift.Recipes.MaxSpawnChance", Asserts.FiniteNonNegative, 100),
	EasyBand = FastFlags.Replicated("Game.Rift.Recipes.EasyBand", Asserts.FiniteNonNegative, 22),
	MediumBand = FastFlags.Replicated("Game.Rift.Recipes.MediumBand", Asserts.FiniteNonNegative, 10),
	HardPenalty = FastFlags.Replicated("Game.Rift.Recipes.HardPenalty", Asserts.FiniteNonNegative, 0.35),
	ExtendBelow = FastFlags.Replicated("Game.Rift.Recipes.ExtendBelow", Asserts.IntegerNonNegative, 2),
	SlotOverrides = FastFlags.Replicated(
		"Game.Rift.Recipes.SlotOverrides",
		Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.FiniteNonNegative)),
		{}
	),
	RequireEasyPet = FastFlags.Replicated("Game.Rift.Recipes.RequireEasyPet", Asserts.Boolean, true),
	MaxEasyPets = FastFlags.Replicated("Game.Rift.Recipes.MaxEasyPets", Asserts.IntegerNonNegative, 3),
	MaxHardPets = FastFlags.Replicated("Game.Rift.Recipes.MaxHardPets", Asserts.IntegerNonNegative, 1),
	MaxNonEasyPets = FastFlags.Replicated("Game.Rift.Recipes.MaxNonEasyPets", Asserts.IntegerNonNegative, 2),
	AllowDuplicatePets = FastFlags.Replicated("Game.Rift.Recipes.AllowDuplicatePets", Asserts.Boolean, false),
	MaxRecipeAttempts = FastFlags.Replicated("Game.Rift.Recipes.MaxRecipeAttempts", Asserts.IntegerPositive, 100),
	ExcludedPets = FastFlags.Replicated("Game.Rift.Recipes.ExcludedPets", Asserts.Array(Asserts.String), {}),
	BannerRanges = FastFlags.Replicated(
		"Game.Rift.Recipes.BannerRanges",
		Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.String)),
		{}
	),
	ZoneLadderOverride = FastFlags.Replicated("Game.Rift.Recipes.ZoneLadderOverride", Asserts.Array(Asserts.String), {})
}
return table.freeze(v)