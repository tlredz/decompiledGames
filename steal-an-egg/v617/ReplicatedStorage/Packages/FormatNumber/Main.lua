local _internal = require(script.Parent._internal)
local Notation = require(script.Notation)
local Precision = require(script.Precision)
local IntegerWidth = require(script.IntegerWidth)
local DecimalFormatSymbols = require(script.DecimalFormatSymbols)
local enums = _internal.enums
local v = {}
local v2 = {}
local create_init_function = _internal.class.create_init_function(
	"NumberFormatter",
	nil,
	v2,
	nil,
	_internal.class.ImmutabilityType.NUMBER_FORMATTER
)

function v2.Notation(p, p2)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "notation",
		value = _internal.class.try_coerce(2, p2, "Notation"),
		parent = _internal.class.get_data(p)
	})
end

function v2.Precision(p, p2)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "precision",
		value = _internal.class.try_coerce(2, p2, "Precision"),
		parent = _internal.class.get_data(p)
	})
end

function v2.RoundingMode(p, p2: number)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "roundingMode",
		value = _internal.class.try_coerce_enum(2, p2, enums.RoundingMode),
		parent = _internal.class.get_data(p)
	})
end

function v2.Grouping(p, p2: number)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "grouping",
		value = _internal.class.try_coerce_enum(2, p2, enums.GroupingStrategy),
		parent = _internal.class.get_data(p)
	})
end

function v2.IntegerWidth(p, p2)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "integerWidth",
		value = _internal.class.try_coerce(2, p2, "IntegerWidth"),
		parent = _internal.class.get_data(p)
	})
end

function v2.Symbols(p, p2)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "symbols",
		value = _internal.class.try_coerce(2, p2, "DecimalFormatSymbols"),
		parent = _internal.class.get_data(p)
	})
end

function v2.Sign(p, p2: number)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "sign",
		value = _internal.class.try_coerce_enum(2, p2, enums.SignDisplay),
		parent = _internal.class.get_data(p)
	})
end

function v2.Decimal(p, p2: number)
	_internal.class.try_coerce(1, p, "NumberFormatter")
	return create_init_function({
		key = "decimal",
		value = _internal.class.try_coerce_enum(2, p2, enums.DecimalSeparatorDisplay),
		parent = _internal.class.get_data(p)
	})
end

local function resolve_nf_data(p)
	return _internal.formatter_settings.resolve_settings(_internal.formatter_settings.linked_list_to_dict(p))
end

function v2.Format(p, value: number)
	_internal.class.try_coerce(1, p, "NumberFormatter")

	if type(value) == "string" then
		error(
			"Argument #2 as a string interpreted as decimal is not currently supported, please cast the argument to a double if you want the string to be interpreted as a double",
			2
		)
	end

	local try_coerce = _internal.class.try_coerce(2, value, "number")
	local get_resolved_data = _internal.class.get_resolved_data(p, resolve_nf_data)
	local symbols = get_resolved_data.symbols
	local v3, v4, v5

	if try_coerce == try_coerce then
		if try_coerce == 1e999 or try_coerce == -1e999 then
			v3 = try_coerce < 0
			v4 = symbols[enums.ENumberFormatSymbols.kInfinitySymbol]
			v5 = false
		else
			local decimal_conversion, v6, v7

			if try_coerce == 0 then
				v3 = math.atan2(try_coerce, -1) < 0
				v6 = 0
				v7 = 1
			else
				v3 = try_coerce < 0
				decimal_conversion, v6, v7 = _internal.decimal_conversion.from_double((math.abs(try_coerce)))
			end

			v4, v5 = _internal.format.format_unsigned_finite(decimal_conversion, v6, v7, v3, get_resolved_data)
		end
	else
		v3 = string.byte(string.pack(">d", try_coerce)) >= 128
		v4 = symbols[enums.ENumberFormatSymbols.kNaNSymbol]
		v5 = true
	end

	return (_internal.format.display_sign(v4, v3, v5, get_resolved_data.displaySignAt, get_resolved_data.symbols))
end

function v2.ToSkeleton(p)
	local try_coerce = _internal.class.try_coerce(1, p, "NumberFormatter")
	return _internal.skeleton.settings_to_skeleton(_internal.formatter_settings.linked_list_to_dict(try_coerce))
end

function v.with()
	return create_init_function(nil)
end

function v.forSkeleton(p: string)
	local try_coerce = _internal.class.try_coerce(1, p, "string")
	local to_option_linked_list, v3 = _internal.skeleton.to_option_linked_list(try_coerce)

	if to_option_linked_list then
		return to_option_linked_list, (create_init_function(v3))
	end

	return to_option_linked_list, v3
end

return table.freeze({
	NumberFormatter = table.freeze(v),
	Notation = Notation,
	Precision = Precision,
	RoundingPriority = enums.RoundingPriority,
	RoundingMode = enums.RoundingMode,
	GroupingStrategy = enums.GroupingStrategy,
	IntegerWidth = IntegerWidth,
	DecimalFormatSymbols = DecimalFormatSymbols,
	ENumberFormatSymbols = enums.ENumberFormatSymbols,
	SignDisplay = enums.SignDisplay,
	DecimalSeparatorDisplay = enums.DecimalSeparatorDisplay
})