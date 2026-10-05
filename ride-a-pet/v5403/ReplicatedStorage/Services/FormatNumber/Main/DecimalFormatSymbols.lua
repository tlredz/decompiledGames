local _internal = require(script.Parent.Parent._internal)
local v = {}
local v2 = {}
local create_init_function = _internal.class.create_init_function(
	"DecimalFormatSymbols",
	nil,
	v2,
	nil,
	_internal.class.ImmutabilityType.SYMBOLS
)

function v2.GetSymbol(p, p2: number)
	return _internal.class.try_coerce(1, p, "DecimalFormatSymbols")[_internal.class.try_coerce_enum(
		2,
		p2,
		_internal.enums.ENumberFormatSymbols
	)]
end

function v2.SetSymbol(p, p2: number, p3: string)
	local try_coerce = _internal.class.try_coerce(1, p, "DecimalFormatSymbols")
	try_coerce[_internal.class.try_coerce_enum(2, p2, _internal.enums.ENumberFormatSymbols)] = _internal.class.try_coerce(
		3,
		p3,
		"string"
	)
end

function v.createWithLastResortData()
	return create_init_function({
		[_internal.enums.ENumberFormatSymbols.kDecimalSeparatorSymbol] = ".",
		[_internal.enums.ENumberFormatSymbols.kGroupingSeparatorSymbol] = "",
		[_internal.enums.ENumberFormatSymbols.kMinusSignSymbol] = "-",
		[_internal.enums.ENumberFormatSymbols.kPlusSignSymbol] = "+",
		[_internal.enums.ENumberFormatSymbols.kExponentialSymbol] = "E",
		[_internal.enums.ENumberFormatSymbols.kInfinitySymbol] = "∞",
		[_internal.enums.ENumberFormatSymbols.kNaNSymbol] = "�"
	})
end

return table.freeze(v)