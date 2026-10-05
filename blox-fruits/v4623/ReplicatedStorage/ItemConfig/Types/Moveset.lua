local Type = require(game.ReplicatedStorage.Packages.Type)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Physical Item Id"] = "Physical",
	["Skill Redirect"] = "SkillRedirect"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	Type = Parse.Optional(Parse.And(Parse.String, Type.literal("Fruit", "Gun", "Sword", "FightingStyle"))),
	Physical = Parse.Optional(Parse.ItemIdOfType("PhysicalMoveset")),
	SkillRedirect = Parse.Optional(Parse.ItemIdOfType("Moveset"))
})))