require(game.ReplicatedStorage.Economy.ItemId)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Item Id"] = "ItemId",
	["Storage Key"] = "StorageKey",
	["Id Type"] = "IdType",
	Label = "DebugLabel"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	ItemId = Parse.ItemId,
	StorageKey = Parse.String,
	IdType = Parse.ItemIdType,
	DebugLabel = Parse.Optional(Parse.String)
})))