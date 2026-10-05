local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated(
	"Game.TacoMerchant.TacoPrices",
	Asserts.Map(Asserts.String, Asserts.IntegerNonNegative),
	{
		["Burrito Bat"] = 100,
		["Tacoturbo Tacorito"] = 500,
		Nachorilla = 1500,
		["Sammyni Truckini"] = 3500
	}
)
return table.freeze({
	TacoPrices = replicated
})