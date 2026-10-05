local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.Spritesheets)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Adornee Item Id"] = "Adornee",
	["Is Default"] = "IsDefault",
	["Is Chromatic"] = "IsChromatic",
	["Physical Item Id"] = "Physical",
	["Equipped Adornee Sprite Key"] = "EquippedAdorneeSprite"
}), Parse.Optional(Parse.Any)), Parse.Union(Parse.Interface({
	Type = Parse.And(Parse.String, Type.literal("Fruit", "Sword", "Aura")),
	IsDefault = Parse.Boolean,
	IsChromatic = Parse.Boolean,
	EquippedAdorneeSprite = Parse.Optional(Parse.Sprite),
	Adornee = Parse.ItemId,
	Physical = Parse.Optional(Parse.ItemId)
}), Parse.Interface({
	Type = Parse.Nil,
	IsDefault = Parse.Boolean,
	IsChromatic = Parse.Optional(Parse.Boolean),
	EquippedAdorneeSprite = Parse.Nil,
	Adornee = Parse.Nil,
	Physical = Parse.Nil
}))))