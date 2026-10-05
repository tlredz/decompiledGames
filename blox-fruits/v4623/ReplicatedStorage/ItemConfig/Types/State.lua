require(game.ReplicatedStorage.PseudoEnum)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Equip Method"] = "EquipMethod",
	["Storage Method"] = "StorageMethod"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	StorageMethod = Parse.PseudoEnumItem("ItemStorageMethod"),
	EquipMethod = Parse.Optional(Parse.PseudoEnumItem("ItemEquipMethod"))
})))