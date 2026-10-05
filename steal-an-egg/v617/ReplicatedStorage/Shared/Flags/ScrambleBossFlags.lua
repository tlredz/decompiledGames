local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)

-- equivalent calls inferred from this helper; original call sites unknown
local function isEnabledByDefault()
	return Environment.IsDevPlace() or Environment.IsTestPlace() or RunService:IsStudio()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isScheduledByDefault()
	return (Environment.IsDevPlace() or Environment.IsTestPlace()) and not RunService:IsStudio()
end

local v = {
	ContentEnabled = FastFlags.Replicated("Game.ScrambleBoss.ContentEnabled", Asserts.Boolean, isEnabledByDefault()),
	BossMaxHealth = FastFlags.Replicated("Game.ScrambleBoss.BossMaxHealth", Asserts.FinitePositive, 9000),
	HealthPerExtraPlayer = FastFlags.Replicated("Game.ScrambleBoss.HealthPerExtraPlayer", Asserts.Range(0, 10), 0.45),
	PlayerHitDamage = FastFlags.Replicated("Game.ScrambleBoss.PlayerHitDamage", Asserts.FinitePositive, 60),
	OverheatDamageMultiplier = FastFlags.Replicated(
		"Game.ScrambleBoss.OverheatDamageMultiplier",
		Asserts.Range(1, 20),
		3
	),
	OverheatSeconds = FastFlags.Replicated("Game.ScrambleBoss.OverheatSeconds", Asserts.Range(2, 30), 8),
	PhaseTwoHealthFraction = FastFlags.Replicated(
		"Game.ScrambleBoss.PhaseTwoHealthFraction",
		Asserts.Range(0.05, 0.95),
		0.5
	),
	HazardDamage = FastFlags.Replicated("Game.ScrambleBoss.HazardDamage", Asserts.Range(0, 100), 8.333333333333334),
	CrocTargets = FastFlags.Replicated("Game.ScrambleBoss.CrocTargets", Asserts.IntegerRange(1, 10), 3),
	CrocChaseSeconds = FastFlags.Replicated("Game.ScrambleBoss.CrocChaseSeconds", Asserts.Range(1, 30), 6),
	DronesPerPlayer = FastFlags.Replicated("Game.ScrambleBoss.DronesPerPlayer", Asserts.IntegerRange(0, 10), 2),
	BallTargetSeconds = FastFlags.Replicated("Game.ScrambleBoss.BallTargetSeconds", Asserts.Range(1, 30), 5),
	BallSpeedFraction = FastFlags.Replicated("Game.ScrambleBoss.BallSpeedFraction", Asserts.Range(0.1, 3), 0.9),
	BallStunSeconds = FastFlags.Replicated("Game.ScrambleBoss.BallStunSeconds", Asserts.Range(1, 60), 30),
	GlassHitsPerPlayer = FastFlags.Replicated("Game.ScrambleBoss.GlassHitsPerPlayer", Asserts.IntegerRange(1, 100), 3),
	GlassCrashes = FastFlags.Replicated("Game.ScrambleBoss.GlassCrashes", Asserts.IntegerRange(1, 10), 3),
	HumanHits = FastFlags.Replicated("Game.ScrambleBoss.HumanHits", Asserts.IntegerRange(1, 10), 3),
	SamplesReward = FastFlags.Replicated("Game.ScrambleBoss.SamplesReward", Asserts.IntegerRange(0, 1000000), 1750),
	ScheduleEnabled = FastFlags.Replicated("Game.ScrambleBoss.ScheduleEnabled", Asserts.Boolean, isScheduledByDefault()),
	ScheduleIntervalSeconds = FastFlags.Replicated(
		"Game.ScrambleBoss.ScheduleIntervalSeconds",
		Asserts.IntegerRange(300, 86400),
		1800
	),
	PortalSpawnFrom = FastFlags.Replicated("Game.ScrambleBoss.PortalSpawnFrom", Asserts.String, "Volcano"),
	PortalSpawnTo = FastFlags.Replicated("Game.ScrambleBoss.PortalSpawnTo", Asserts.String, "Titan Temple"),
	PortalIdleCloseSeconds = FastFlags.Replicated(
		"Game.ScrambleBoss.PortalIdleCloseSeconds",
		Asserts.Range(30, 3600),
		300
	),
	SamplesWalletId = FastFlags.Replicated(
		"Game.ScrambleBoss.SamplesWalletId",
		Asserts.AllOf(Asserts.ASCIIRange(0, 64), Asserts.Pattern("^[%w_%-]*$")),
		"DrScrambleBoss"
	)
}
return table.freeze(v)