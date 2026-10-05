local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Game.EquipBrainrots.Enabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated("Game.EquipBrainrots.SimpleSelect", Asserts.Boolean, true)
return table.freeze({
	Enabled = replicated,
	SimpleSelect = replicated2
})