local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local cframe = CFrame.new(0, 0, -3.35)
return table.freeze({
	ChargeMaxDuration = FastFlags.Replicated("BanHammer.ChargeMaxDuration", Asserts.FinitePositive, 2.5),
	Cooldown = FastFlags.Replicated("BanHammer.Cooldown", Asserts.FiniteNonNegative, 2),
	MinForce = FastFlags.Replicated("BanHammer.MinForce", Asserts.FiniteNonNegative, 1000),
	MaxForce = FastFlags.Replicated("BanHammer.MaxForce", Asserts.FiniteNonNegative, 2800),
	MinRagdollDuration = FastFlags.Replicated("BanHammer.MinRagdollDuration", Asserts.FiniteNonNegative, 2),
	MaxRagdollDuration = FastFlags.Replicated("BanHammer.MaxRagdollDuration", Asserts.FiniteNonNegative, 6),
	MinRadius = FastFlags.Replicated("BanHammer.MinRadius", Asserts.FinitePositive, 10),
	MaxRadius = FastFlags.Replicated("BanHammer.MaxRadius", Asserts.FinitePositive, 20),
	TargettingTTL = FastFlags.Replicated("BanHammer.TargettingTTL", Asserts.Finite, 0.3),
	SlamOffset = cframe
})