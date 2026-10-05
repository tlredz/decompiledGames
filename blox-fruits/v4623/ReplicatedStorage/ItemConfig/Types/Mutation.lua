local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Physical Item Id"] = "Physical",
	["Adornee Item Id"] = "Adornee"
}), Parse.Optional(Parse.Any)), Parse.Union(Parse.Interface({
	Physical = Parse.Optional(Parse.ItemIdOfType("PhysicalMoveset")),
	Adornee = Parse.Optional(Parse.ItemIdOfType("Moveset"))
}), Parse.Interface({
	Physical = Parse.Nil,
	Adornee = Parse.Nil
}))))