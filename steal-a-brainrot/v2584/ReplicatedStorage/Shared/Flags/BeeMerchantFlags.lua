local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated(
	"Game.BeeMerchant.HoneyPrices",
	Asserts.Map(Asserts.String, Asserts.IntegerNonNegative),
	{
		["Conetto Morsetto"] = 20,
		["Honey Honey Bear"] = 40,
		["Queen Bee"] = 100,
		["S'more Serat"] = 200,
		Bumbatron = 400
	}
)
return table.freeze({
	HoneyPrices = replicated
})