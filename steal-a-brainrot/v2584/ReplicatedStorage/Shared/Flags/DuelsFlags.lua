local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
require(ReplicatedStorage.Datas.ServerData)
local replicated = FastFlags.Replicated("Duels.PreTeleportSelection", Asserts.Boolean, false)
local replicated2 = FastFlags.Replicated("Duels.MedusaCooldownDecreasePerMinute", Asserts.FiniteNonNegative, 5)
return table.freeze({
	PreTeleportSelection = replicated,
	MedusaCooldownDecreasePerMinute = replicated2
})