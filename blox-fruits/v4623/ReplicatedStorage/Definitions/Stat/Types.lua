local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local StatTypes = require(game.ReplicatedStorage.Types.StatTypes)
local Types = {
	SimpleType = StatTypes.SimpleType,
	ComplexType = StatTypes.ComplexType,
	FullType = StatTypes.FullType,
	VariantType = StatTypes.VariantType,
	StatIndex = StatTypes.StatIndex,
	StatIcon = StatTypes.StatIcon,
	Modification = StatTypes.Modification,
	StatValue = StatTypes.StatValue,
	ValueForm = TypeUtil.Types.BetterLiteral(
		"Add",
		"Add1Multiply",
		"AddOrMultiply",
		"AddOrMultiplyFavorAdd",
		"Boolean",
		"Cooldown",
		"Multiply",
		"RawMultiply"
	)
}
Types.VariantDefinition = Type.strictInterface({
	_AddressType = Type.literal("Variant"),
	Index = Type.strictInterface({
		Key = Types.VariantType,
		Stat = Types.ComplexType
	}),
	Description = Type.string,
	EffectSuffix = Type.string,
	Icon = Types.StatIcon
})
Types.StatDefinition = TypeUtil.Types.BetterUnion({
	Simple = Type.strictInterface({
		_AddressType = Type.literal("Stat"),
		StatType = Type.literal("Simple"),
		Key = Types.SimpleType,
		DisplayName = Type.string,
		ValueForm = Types.ValueForm,
		Description = Type.string,
		EffectSuffix = Type.string,
		Icon = Types.StatIcon
	}),
	Complex = Type.strictInterface({
		_AddressType = Type.literal("Stat"),
		StatType = Type.literal("Complex"),
		Key = Types.ComplexType,
		DisplayName = Type.string,
		ValueForm = Types.ValueForm,
		Variants = Type.array(Types.VariantDefinition)
	})
})
return Types