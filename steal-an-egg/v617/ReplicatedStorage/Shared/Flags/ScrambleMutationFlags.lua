local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
return table.freeze({
	SuccessPercent = FastFlags.Replicated("Game.Scramble.MutationConsumableSuccessPercent", Asserts.Range(0, 100), 10)
})