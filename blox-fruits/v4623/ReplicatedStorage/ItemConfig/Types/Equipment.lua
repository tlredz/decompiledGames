local Type = require(game.ReplicatedStorage.Packages.Type)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Adornee Item Id"] = "Adornee",
	["Is Aura Bound"] = "IsAuraBound",
	["Mastery Requirement"] = "MasteryRequirement",
	Slot = "Slots"
}), Parse.Optional(Parse.Any)), Parse.Union(Parse.Interface({
	Slots = Parse.OfSize(
		Parse.Array(Parse.Optional(Parse.And(Parse.String, Type.literal("Crown", "BodyArmor", "Seats", "Helmet")))),
		Type.numberMin(1)
	),
	MasteryRequirement = Parse.Optional(Parse.And(Parse.Integer, Type.numberMinExclusive(0))),
	IsAuraBound = Parse.Boolean,
	Adornee = Parse.ItemId
}), Parse.Interface({
	Slots = Parse.Nil,
	IsAuraBound = Parse.Boolean,
	Adornee = Parse.Nil
}))))