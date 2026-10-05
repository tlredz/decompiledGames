local Type = require(game.ReplicatedStorage.Packages.Type)
require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.Spritesheets)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Tile Overlays"] = "TileOverlays",
	["Sort Priority"] = "SortPriority",
	["Stack Key"] = "StackKey",
	["Stack Priority"] = "StackPriority",
	["Max Stack"] = "MaxStack",
	["Tile Appearance"] = "TileAppearance",
	["Outline Appearance"] = "OutlineAppearance",
	["Stack Display Name"] = "StackDisplayName",
	["Stack Display Category"] = "StackDisplayCategory",
	["Stack Category Icon Sprite Key"] = "StackCategoryIcon",
	["Can Showcase"] = "CanShowcase"
}), Parse.Optional(Parse.Any)), Parse.Interface({
	Groups = Parse.OfSize(Parse.Array(Parse.PseudoEnumItem("InventoryItemGroup")), Type.numberMin(1)),
	Brackets = Parse.OfSize(Parse.Array(Parse.PseudoEnumItem("InventoryItemBracket")), Type.numberMin(1)),
	Tags = Parse.Array(Parse.PseudoEnumItem("InventoryItemTag")),
	Actions = Parse.Array(Parse.PseudoEnumItem("InventoryAction")),
	TileOverlays = Parse.Array(Parse.PseudoEnumItem("InventoryTileOverlay")),
	SortPriority = Parse.Optional(Parse.And(Parse.Number, Type.numberMinExclusive(0))),
	StackKey = Parse.Optional(Parse.String),
	StackDisplayName = Parse.Optional(Parse.String),
	StackDisplayCategory = Parse.Optional(Parse.String),
	StackPriority = Parse.Optional(Parse.UnsignedInteger),
	StackCategoryIcon = Parse.Optional(Parse.Sprite),
	MaxStack = Parse.Optional(Parse.UnsignedInteger),
	CanShowcase = Parse.Boolean,
	TileAppearance = Parse.PseudoEnumItem("InventoryTileAppearance"),
	OutlineAppearance = Parse.PseudoEnumItem("InventoryOutlineAppearance")
})))