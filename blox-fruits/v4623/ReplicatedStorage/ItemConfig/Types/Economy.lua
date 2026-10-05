local Type = require(game.ReplicatedStorage.Packages.Type)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Purchase With Item Id"] = "PurchaseWith",
	["Robux Price"] = "RobuxPrice",
	["Product Id"] = "ProductId",
	["Gamepass Id"] = "GamepassId",
	["Trade Reducer"] = "TradeReducer",
	["Is Giftable"] = "IsGiftable",
	["Can Be Featured"] = "CanBeFeatured",
	["Is Premium Random Item"] = "IsPremiumRandomItem"
}), Parse.Optional(Parse.Any)), Parse.Union(Parse.Interface({
	PurchaseWith = Parse.Optional(Parse.ItemIdOfType("Redeemable")),
	TradeReducer = Parse.Optional(Parse.And(Parse.Number, Type.numberConstrained(0, 1))),
	RobuxPrice = Parse.Nil,
	ProductId = Parse.Nil,
	GamepassId = Parse.Nil,
	IsGiftable = Parse.And(Parse.Boolean, Type.literal(false)),
	CanBeFeatured = Parse.And(Parse.Boolean, Type.literal(false)),
	IsPremiumRandomItem = Parse.Boolean
}), Parse.Interface({
	PurchaseWith = Parse.Nil,
	RobuxPrice = Parse.And(Parse.Integer, Type.numberMinExclusive(0)),
	ProductId = Parse.UnsignedInteger,
	GamepassId = Parse.Optional(Parse.UnsignedInteger),
	TradeReducer = Parse.Optional(Parse.And(Parse.Number, Type.numberConstrained(0, 1))),
	IsGiftable = Parse.Boolean,
	CanBeFeatured = Parse.Boolean,
	IsPremiumRandomItem = Parse.Boolean
}))))