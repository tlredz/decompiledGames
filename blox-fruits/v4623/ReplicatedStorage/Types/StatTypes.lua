require(game.ReplicatedStorage.Packages.Result)
local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local StatTypes = {
	Modification = TypeUtil.Types.BetterLiteral("Multiply", "Add", "Boolean"),
	ComplexType = TypeUtil.Types.BetterLiteral(
		"AllDamage",
		"AllResist",
		"SeaMaterialDropRate",
		"SeaDamage",
		"SeaResist",
		"PvpLeech",
		"PveLeech",
		"Cooldown",
		"DashLength",
		"LogiaDamage",
		"ZoanDamage",
		"PveDamage",
		"AllSpeed"
	),
	SimpleType = TypeUtil.Types.BetterLiteral(
		"SpeedMultiplier",
		"Health",
		"Energy",
		"SummerTokenMult",
		"CandyMult",
		"HeartsMult",
		"MagnetTokenMult",
		"Friendship",
		"ObservationRange",
		"HealthRegen",
		"DodgeBoost",
		"EnergyRegen",
		"EXPBoost",
		"SeaDamageReduction",
		"SkyjumpBoost",
		"RageGain",
		"TerrorReducer",
		"Melee",
		"Sword",
		"Demon Fruit",
		"Gun",
		"DefenseIgnore",
		"DashSpeed",
		"MoneyRate",
		"Defense",
		"Unbreakable",
		"JumpHeight",
		"MaxStats",
		"FlashStepRange",
		"DashEfficiency",
		"AirJumpEfficiency",
		"DamageToEnergy"
	)
}
StatTypes.FullType = Type.union(StatTypes.ComplexType, StatTypes.SimpleType)
StatTypes.VariantType = TypeUtil.Types.BetterLiteral(
	"All",
	"Gun",
	"Sword",
	"Fruit",
	"Melee",
	"Ground",
	"Air",
	"FlashStep"
)
StatTypes.StatIcon = Type.strictInterface({
	Main = TypeUtil.Types.ImageData,
	Modifier = Type.optional(TypeUtil.Types.ImageData),
	ModifierColor = Type.optional(Type.Color3),
	Variant = Type.optional(TypeUtil.Types.ImageData),
	VariantColor = Type.optional(Type.Color3)
})
StatTypes.StatIndex = Type.union(Type.strictInterface({
	StatType = Type.literal("Complex"),
	Type = StatTypes.ComplexType,
	Variant = StatTypes.VariantType
}), Type.strictInterface({
	StatType = Type.literal("Simple"),
	Type = StatTypes.SimpleType
}))
StatTypes.StatValue = Type.strictInterface({
	Index = StatTypes.StatIndex,
	Modification = StatTypes.Modification,
	Icon = StatTypes.StatIcon,
	DisplayName = Type.string,
	Description = Type.string,
	Value = Type.number,
	Text = Type.string,
	FullText = Type.string
})
return StatTypes