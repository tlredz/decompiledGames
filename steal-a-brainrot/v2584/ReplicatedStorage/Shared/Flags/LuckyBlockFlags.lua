local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated(
	"LuckyBlocks.OddsOverride",
	Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.FiniteNonNegative)),
	{}
)
local replicated2 = FastFlags.Replicated("LuckyBlocks.TimersDisabled", Asserts.Boolean, true)
return table.freeze({
	OddsOverride = replicated,
	TimersDisabled = replicated2
})