local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Game.Rebirth.ConsumeRequirementsOnly", Asserts.Boolean, true)
return table.freeze({
	ConsumeRequirementsOnly = replicated
})