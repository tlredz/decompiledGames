local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
require(ReplicatedStorage.Shared.Modules.Environment)
local v = {
	RingSpacingStuds = FastFlags.Replicated("Game.LightVsDarkness.RingSpacingStuds", Asserts.FinitePositive, 22),
	GuardRingRadii = FastFlags.Replicated(
		"Game.LightVsDarkness.GuardRingRadii",
		Asserts.Map(Asserts.String, Asserts.FinitePositive),
		{
			["1"] = 12,
			["2"] = 20,
			["3"] = 28
		}
	),
	RingsPerGuardRing = FastFlags.Replicated("Game.LightVsDarkness.RingsPerGuardRing", Asserts.IntegerPositive, 12),
	GuardCirclesByArea = FastFlags.Replicated(
		"Game.LightVsDarkness.GuardCirclesByArea",
		Asserts.Map(Asserts.String, Asserts.IntegerNonNegative),
		{
			Forest = 0,
			Lake = 0,
			Desert = 0,
			Jungle = 0,
			Snow = 0,
			Volcano = 0,
			["Abyss Ocean"] = 1,
			Prehistoric = 1,
			Cosmic = 2,
			CherryBlossom = 2
		}
	),
	FlyHeightStuds = FastFlags.Replicated("Game.LightVsDarkness.FlyHeightStuds", Asserts.FinitePositive, 50),
	FlyingLeanEnabled = FastFlags.Replicated("Game.LightVsDarkness.FlyingLeanEnabled", Asserts.Boolean, true),
	MilestoneSpeedBoostSeconds = FastFlags.Replicated(
		"Game.LightVsDarkness.MilestoneSpeedBoostSeconds",
		Asserts.FinitePositive,
		600
	),
	CollectRadiusPadding = FastFlags.Replicated("Game.LightVsDarkness.CollectRadiusPadding", Asserts.FinitePositive, 2),
	PowerUpsPerDrop = FastFlags.Replicated("Game.LightVsDarkness.PowerUpsPerDrop", Asserts.IntegerPositive, 10),
	LatePowerUpZones = FastFlags.Replicated(
		"Game.LightVsDarkness.LatePowerUpZones",
		Asserts.Array(Asserts.String),
		{ "Cherry Blossom", "Titan Temple", "Light Dark" }
	),
	LatePowerUpZoneChance = FastFlags.Replicated("Game.LightVsDarkness.LatePowerUpZoneChance", Asserts.Range(0, 1), 1),
	PowerUpDurationSeconds = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpDurationSeconds",
		Asserts.Map(Asserts.String, Asserts.FinitePositive),
		{
			Magnet = 20,
			x2Rings = 20,
			Fusion = 20
		}
	),
	PowerUpUnclaimedSeconds = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpUnclaimedSeconds",
		Asserts.FinitePositive,
		45
	),
	MagnetRadiusStuds = FastFlags.Replicated("Game.LightVsDarkness.MagnetRadiusStuds", Asserts.FinitePositive, 40),
	PowerUpRingMultiplier = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpRingMultiplier",
		Asserts.IntegerPositive,
		4
	),
	PowerUpDropRevampEnabled = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpDropRevampEnabled",
		Asserts.Boolean,
		true
	),
	PowerUpFallSeconds = FastFlags.Replicated("Game.LightVsDarkness.PowerUpFallSeconds", Asserts.FinitePositive, 2.4),
	PowerUpFallHeightStuds = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpFallHeightStuds",
		Asserts.FinitePositive,
		220
	),
	PowerUpSafeZoneMarginStuds = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpSafeZoneMarginStuds",
		Asserts.FinitePositive,
		10
	),
	PowerUpStackDurations = FastFlags.Replicated("Game.LightVsDarkness.PowerUpStackDurations", Asserts.Boolean, true),
	PowerUpDropVfxEnabled = FastFlags.Replicated("Game.LightVsDarkness.PowerUpDropVfxEnabled", Asserts.Boolean, true),
	PowerUpDropPunchEnabled = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpDropPunchEnabled",
		Asserts.Boolean,
		true
	),
	PowerUpCometScale = FastFlags.Replicated("Game.LightVsDarkness.PowerUpCometScale", Asserts.FinitePositive, 1),
	PowerUpDropSoundsEnabled = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpDropSoundsEnabled",
		Asserts.Boolean,
		true
	),
	PowerUpLandShakeEnabled = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpLandShakeEnabled",
		Asserts.Boolean,
		true
	),
	PowerUpLandShakeRadiusStuds = FastFlags.Replicated(
		"Game.LightVsDarkness.PowerUpLandShakeRadiusStuds",
		Asserts.FinitePositive,
		42
	),
	PowerUpSkyLiftEnabled = FastFlags.Replicated("Game.LightVsDarkness.PowerUpSkyLiftEnabled", Asserts.Boolean, true)
}
return table.freeze(v)