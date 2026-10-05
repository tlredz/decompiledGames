local _internal = require(script.Parent.Parent._internal)
local v = {}
local v2 = {}
local create_init_function = _internal.class.create_init_function(
	"Precision",
	nil,
	v2,
	nil,
	_internal.class.ImmutabilityType.DEFAULT
)
local v3 = {}
local create_init_function2 = _internal.class.create_init_function(
	"FractionPrecision",
	"Precision",
	v3,
	v2,
	_internal.class.ImmutabilityType.DEFAULT
)

function v3.WithMinDigits(p, p2: number)
	local try_coerce = _internal.class.try_coerce(1, p, "FractionPrecision")
	local try_coerce_range = _internal.class.try_coerce_range(2, p2, 1, 999)
	return create_init_function({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = try_coerce.min,
		maxFractionDigits = try_coerce.max,
		minSignificantDigits = 1,
		maxSignificantDigits = try_coerce_range,
		roundingPriority = _internal.enums.RoundingPriority.RELAXED,
		sourcedWithSignificantDigits = false
	})
end

function v3.WithMaxDigits(p, p2: number)
	local try_coerce = _internal.class.try_coerce(1, p, "FractionPrecision")
	local try_coerce_range = _internal.class.try_coerce_range(2, p2, 1, 999)
	return create_init_function({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = try_coerce.min,
		maxFractionDigits = try_coerce.max,
		minSignificantDigits = 1,
		maxSignificantDigits = try_coerce_range,
		roundingPriority = _internal.enums.RoundingPriority.STRICT,
		sourcedWithSignificantDigits = false
	})
end

function v3.WithSignificantDigits(p, p2: number, p3: number, p4: number)
	local try_coerce = _internal.class.try_coerce(1, p, "FractionPrecision")
	local try_coerce_range = _internal.class.try_coerce_range(2, p2, 1, 999)
	local try_coerce_range2 = _internal.class.try_coerce_range(3, p3, 1, 999)
	local try_coerce_enum = _internal.class.try_coerce_enum(4, p4, _internal.enums.RoundingPriority)
	return create_init_function({
		type = _internal.enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
		minFractionDigits = try_coerce.min,
		maxFractionDigits = try_coerce.max,
		minSignificantDigits = try_coerce_range,
		maxSignificantDigits = try_coerce_range2,
		roundingPriority = try_coerce_enum,
		sourcedWithSignificantDigits = true
	})
end

local create_init_function3 = _internal.class.create_init_function(
	"SignificantDigitsPrecision",
	"Precision",
	{},
	v2,
	_internal.class.ImmutabilityType.DEFAULT
)

function v.unlimited()
	return create_init_function({
		type = _internal.enums._Internal.PrecisionType.UNLIMITED
	})
end

function v.integer()
	return create_init_function2({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = 0,
		max = 0
	})
end

function v.fixedFraction(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 0, 999)
	return create_init_function2({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = try_coerce_range,
		max = try_coerce_range
	})
end

function v.minFraction(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 0, 999)
	return create_init_function2({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = try_coerce_range,
		max = _internal.formatter_settings.MAX_PRECISION
	})
end

function v.maxFraction(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 0, 999)
	return create_init_function2({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = 0,
		max = try_coerce_range
	})
end

function v.minMaxFraction(p: number, p2: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 0, 999)
	local try_coerce_range2 = _internal.class.try_coerce_range(2, p2, try_coerce_range, 999)
	return create_init_function2({
		type = _internal.enums._Internal.PrecisionType.FRACTION,
		min = try_coerce_range,
		max = try_coerce_range2
	})
end

function v.fixedSignificantDigits(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 1, 999)
	return create_init_function3({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = try_coerce_range,
		max = try_coerce_range
	})
end

function v.minSignificantDigits(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 1, 999)
	return create_init_function3({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = try_coerce_range,
		max = _internal.formatter_settings.MAX_PRECISION
	})
end

function v.maxSignificantDigits(p: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 1, 999)
	return create_init_function3({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = 1,
		max = try_coerce_range
	})
end

function v.minMaxSignificantDigits(p: number, p2: number)
	local try_coerce_range = _internal.class.try_coerce_range(1, p, 1, 999)
	local try_coerce_range2 = _internal.class.try_coerce_range(2, p2, try_coerce_range, 999)
	return create_init_function3({
		type = _internal.enums._Internal.PrecisionType.SIGNFICANT,
		min = try_coerce_range,
		max = try_coerce_range2
	})
end

return table.freeze(v)