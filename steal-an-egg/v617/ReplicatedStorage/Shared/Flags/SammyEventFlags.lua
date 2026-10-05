local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local v = {
	PickupSpacingStuds = FastFlags.Replicated("Game.SammyEvent.PickupSpacingStuds", Asserts.FinitePositive, 22),
	CollectRadiusPadding = FastFlags.Replicated("Game.SammyEvent.CollectRadiusPadding", Asserts.FinitePositive, 2),
	MagnetRadiusStuds = FastFlags.Replicated("Game.SammyEvent.MagnetRadiusStuds", Asserts.FinitePositive, 32),
	PickupRespawnSeconds = FastFlags.Replicated("Game.SammyEvent.PickupRespawnSeconds", Asserts.FinitePositive, 5),
	EmpChargePerPickupMaxPlayers = FastFlags.Replicated(
		"Game.SammyEvent.EmpChargePerPickupMaxPlayers",
		Asserts.FinitePositive,
		RunService:IsStudio() and 2 or 0.05
	),
	EmpChargePerPickupMinPlayers = FastFlags.Replicated(
		"Game.SammyEvent.EmpChargePerPickupMinPlayers",
		Asserts.FinitePositive,
		RunService:IsStudio() and 2 or 0.15
	),
	LaserFireSeconds = FastFlags.Replicated("Game.SammyEvent.LaserFireSeconds", Asserts.FinitePositive, 3),
	SammyStunSeconds = FastFlags.Replicated("Game.SammyEvent.SammyStunSeconds", Asserts.FinitePositive, 10),
	SammyChaseRadiusStuds = FastFlags.Replicated("Game.SammyEvent.SammyChaseRadiusStuds", Asserts.FinitePositive, 4000),
	SammyHitDistanceStuds = FastFlags.Replicated("Game.SammyEvent.SammyHitDistanceStuds", Asserts.FinitePositive, 12),
	SammyWalkSpeed = FastFlags.Replicated("Game.SammyEvent.SammyWalkSpeed", Asserts.FinitePositive, 60),
	SammyFlatRadiusStuds = FastFlags.Replicated("Game.SammyEvent.SammyFlatRadiusStuds", Asserts.FinitePositive, 25),
	SammyRagdollSeconds = FastFlags.Replicated("Game.SammyEvent.SammyRagdollSeconds", Asserts.FinitePositive, 2.5),
	SammyChaseGraceSeconds = FastFlags.Replicated("Game.SammyEvent.SammyChaseGraceSeconds", Asserts.FinitePositive, 4),
	SammyShakeRadiusStuds = FastFlags.Replicated("Game.SammyEvent.SammyShakeRadiusStuds", Asserts.FinitePositive, 120),
	BrainrotScaleInSeconds = FastFlags.Replicated("Game.SammyEvent.BrainrotScaleInSeconds", Asserts.FinitePositive, 0.6),
	BrainrotCarrySpeedMalus = FastFlags.Replicated("Game.SammyEvent.BrainrotCarrySpeedMalus", Asserts.Range(0, 1), 0.15),
	BenCarrySpeedMalus = FastFlags.Replicated("Game.SammyEvent.BenCarrySpeedMalus", Asserts.Range(0, 1), 0.78),
	CageHealthPerPlayer = FastFlags.Replicated("Game.SammyEvent.CageHealthPerPlayer", Asserts.IntegerPositive, 10),
	BrainrotsPerPlayer = FastFlags.Replicated("Game.SammyEvent.BrainrotsPerPlayer", Asserts.IntegerPositive, 1),
	SammyWave3PickupMultiplier = FastFlags.Replicated(
		"Game.SammyEvent.SammyWave3PickupMultiplier",
		Asserts.FinitePositive,
		1.5
	),
	SammyScorePerCoin = FastFlags.Replicated("Game.SammyEvent.SammyScorePerCoin", Asserts.FinitePositive, 1),
	SammyScorePerBrainrot = FastFlags.Replicated("Game.SammyEvent.SammyScorePerBrainrot", Asserts.FinitePositive, 1000),
	SammyGroundSlamEnabled = FastFlags.Replicated("Game.SammyEvent.SammyGroundSlamEnabled", Asserts.Boolean, true),
	SammySlamRadiusStuds = FastFlags.Replicated("Game.SammyEvent.SammySlamRadiusStuds", Asserts.FinitePositive, 45),
	SammySlamMinSeconds = FastFlags.Replicated("Game.SammyEvent.SammySlamMinSeconds", Asserts.FinitePositive, 5),
	SammySlamMaxSeconds = FastFlags.Replicated("Game.SammyEvent.SammySlamMaxSeconds", Asserts.FinitePositive, 10),
	SammyBomberEnabled = FastFlags.Replicated("Game.SammyEvent.SammyBomberEnabled", Asserts.Boolean, true),
	SammyElephantsEnabled = FastFlags.Replicated("Game.SammyEvent.SammyElephantsEnabled", Asserts.Boolean, true),
	SammyBomberMinSeconds = FastFlags.Replicated("Game.SammyEvent.SammyBomberMinSeconds", Asserts.FinitePositive, 5),
	SammyBomberMaxSeconds = FastFlags.Replicated("Game.SammyEvent.SammyBomberMaxSeconds", Asserts.FinitePositive, 10)
}
return table.freeze(v)