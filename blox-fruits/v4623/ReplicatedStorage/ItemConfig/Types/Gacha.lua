local Type = require(game.ReplicatedStorage.Packages.Type)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Base Gacha Weight"] = "BaseWeight",
	["Max Gacha Chance"] = "MaxChance"
}), Parse.Optional(Parse.Any)), Parse.Union(Parse.Interface({
	BaseWeight = Parse.And(Parse.Integer, Type.numberConstrained(1, 100000)),
	MaxChance = Parse.Optional(Parse.Percent)
}), Parse.Interface({
	BaseWeight = Parse.Nil,
	MaxChance = Parse.Nil
}))))