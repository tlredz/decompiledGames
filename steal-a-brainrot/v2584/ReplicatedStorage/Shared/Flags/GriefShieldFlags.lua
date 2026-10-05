local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Game.GriefShield.BubbleWarmupEnabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated("Game.GriefShield.Duration", Asserts.FinitePositive, 20)
local replicated3 = FastFlags.Replicated("Game.GriefShield.Cooldown", Asserts.FinitePositive, 30)
return table.freeze({
	BubbleWarmupEnabled = replicated,
	Duration = replicated2,
	Cooldown = replicated3
})