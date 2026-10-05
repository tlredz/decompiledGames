local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Environment = require(ReplicatedStorage.Shared.Modules.Environment)

-- equivalent calls inferred from this helper; original call sites unknown
local function isBossEventEnabledByDefault()
	return Environment.IsDevPlace() or Environment.IsTestPlace()
end

local v = {
	ContentEnabled = FastFlags.Replicated("Game.BossEvent.ContentEnabled", Asserts.Boolean, false),
	Enabled = FastFlags.Replicated("Game.BossEvent.Enabled", Asserts.Boolean, isBossEventEnabledByDefault()),
	WindowDurationSeconds = FastFlags.Replicated("Game.BossEvent.WindowDurationSeconds", Asserts.FinitePositive, 330),
	BossMaxHealth = FastFlags.Replicated("Game.BossEvent.BossMaxHealth", Asserts.FinitePositive, 7000),
	HealthScalesWithPlayers = FastFlags.Replicated(
		"Game.BossEvent.HealthScalesWithPlayers",
		Asserts.Map(Asserts.String, Asserts.Range(1, 100)),
		{
			["1"] = 1,
			["2"] = 1.4,
			["3"] = 1.9,
			["4"] = 2.25,
			["5"] = 2.8,
			["6"] = 3.4,
			["7"] = 3.9
		}
	),
	SpawnCountdownSeconds = FastFlags.Replicated("Game.BossEvent.SpawnCountdownSeconds", Asserts.FinitePositive, 15),
	PlayerHitDamage = FastFlags.Replicated(
		"Game.BossEvent.PlayerHitDamage",
		Asserts.FinitePositive,
		RunService:IsStudio() and 1000 or 100
	),
	CrystalHealthPerPlayer = FastFlags.Replicated(
		"Game.BossEvent.CrystalHealthPerPlayer",
		Asserts.IntegerPositive,
		RunService:IsStudio() and 1 or 5
	)
}
return table.freeze(v)