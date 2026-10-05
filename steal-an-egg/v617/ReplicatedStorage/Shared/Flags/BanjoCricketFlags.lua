local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
return table.freeze({
	Enabled = FastFlags.Replicated("Game.BanjoCricket.Enabled", Asserts.Boolean, true),
	Stages = FastFlags.Replicated("Game.BanjoCricket.Stages", Asserts.IntegerRange(1, BanjoCricket.MaxStages), 5)
})