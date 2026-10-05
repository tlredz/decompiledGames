local _internal = require(script.Parent.Parent._internal)
local v = {}
local v2 = {}
local create_init_function = _internal.class.create_init_function(
	"Notation",
	nil,
	v,
	nil,
	_internal.class.ImmutabilityType.DEFAULT
)
local v3 = {}
local create_init_function2 = _internal.class.create_init_function(
	"ScientificNotation",
	"Notation",
	v3,
	v2,
	_internal.class.ImmutabilityType.DEFAULT
)

function v3.WithMinExponentDigits(p, p2: number)
	local try_coerce = _internal.class.try_coerce(1, p, "ScientificNotation")
	local try_coerce_range = _internal.class.try_coerce_range(2, p2, 1, 999)
	local clone = table.clone(try_coerce)
	clone.minExponentDigits = try_coerce_range
	return create_init_function2(clone)
end

function v3.WithExponentSignDisplay(p, p2: number)
	local try_coerce = _internal.class.try_coerce(1, p, "ScientificNotation")
	local try_coerce_enum = _internal.class.try_coerce_enum(2, p2, _internal.enums.SignDisplay)
	local clone = table.clone(try_coerce)
	clone.exponentSignDisplay = try_coerce_enum
	clone.displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(try_coerce_enum)
	return create_init_function2(clone)
end

_internal.class.create_init_function("CompactNotation", "Notation", {}, v2, _internal.class.ImmutabilityType.DEFAULT)
_internal.class.create_init_function("SimpleNotation", "Notation", {}, v2, _internal.class.ImmutabilityType.DEFAULT)

function v.scientific()
	return create_init_function2({
		type = _internal.enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = 1,
		minExponentDigits = 1,
		exponentSignDisplay = _internal.enums.SignDisplay.AUTO,
		displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(_internal.enums.SignDisplay.AUTO)
	})
end

function v.engineering()
	return create_init_function2({
		type = _internal.enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = 3,
		minExponentDigits = 1,
		exponentSignDisplay = _internal.enums.SignDisplay.AUTO,
		displayExponentSignAt = _internal.formatter_settings.generate_from_sign_enum(_internal.enums.SignDisplay.AUTO)
	})
end

function v.compactWithSuffixThousands(p)
	local try_coerce = _internal.class.try_coerce(1, p, "{string}")
	local index = table.find(try_coerce, "")

	if index then
		error(string.format("Index %d is an empty string, please double check the suffixes", index), 2)
	elseif #try_coerce == 0 then
		error("Suffixes is empty", 2)
	end

	return create_init_function({
		type = _internal.enums._Internal.NotationType.COMPACT,
		power10Scale = 3,
		suffixes = try_coerce,
		suffixesLength = #try_coerce
	})
end

function v.simple()
	return create_init_function({
		type = _internal.enums._Internal.NotationType.SIMPLE
	})
end

return table.freeze(v)