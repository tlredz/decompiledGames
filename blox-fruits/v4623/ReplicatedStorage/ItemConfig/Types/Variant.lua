local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Parse = require(game.ReplicatedStorage.Util.Parse)
require(script.Parent.Shared)
return (Parse.Chain(Parse.Map(Parse.Translate({
	["Is Foundation"] = "IsFoundation",
	["Mutation Item Id"] = "Mutation",
	["Variant Of Item Id"] = "VariantOf"
}), Parse.Optional(Parse.Any)), Parse.And(Parse.Interface({
	IsFoundation = Parse.Optional(Parse.Boolean),
	Mutation = Parse.Optional(Parse.ItemId),
	VariantOf = Parse.Optional(Parse.ItemId)
}), TypeUtil.Types.BetterUnion({
	Foundation = Type.strictInterface({
		IsFoundation = Type.literal(true),
		Mutation = Type.optional(TypeUtil.Types.ItemId())
	}),
	Variant = Type.strictInterface({
		IsFoundation = Type.literal(false),
		Mutation = Type.optional(TypeUtil.Types.ItemId()),
		VariantOf = Type.optional(TypeUtil.Types.ItemId())
	})
}))))