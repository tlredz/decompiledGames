local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Game.BeeLuckyBlockEvent.SpawnRequirement", Asserts.IntegerPositive, 50)
return table.freeze({
	SpawnRequirement = replicated
})