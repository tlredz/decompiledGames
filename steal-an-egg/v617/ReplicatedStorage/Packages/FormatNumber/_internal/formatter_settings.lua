local enums = require(script.Parent.enums)
local v = {
	MAX_PRECISION = 2147483647
}

function v.resolve_min_max_sig(data, p)
	local v2 = nil
	local MAX_PRECISION = nil

	if data.type == enums._Internal.PrecisionType.SIGNFICANT then
		return data.min, data.max
	end

	if data.type == enums._Internal.PrecisionType.FRACTION then
		return p + data.min, p + data.max
	end

	if data.type == enums._Internal.PrecisionType.FRACTION_SIGNIFICANT then
		local v3 = p + data.minFractionDigits
		local v4 = p + data.maxFractionDigits
		local minSignificantDigits = data.minSignificantDigits
		local maxSignificantDigits = data.maxSignificantDigits

		if data.roundingPriority == enums.RoundingPriority.RELAXED then
			v2 = math.max(v3, minSignificantDigits)
			MAX_PRECISION = math.max(v4, maxSignificantDigits)
		else
			v2 = math.min(v3, minSignificantDigits)
			MAX_PRECISION = math.min(v4, maxSignificantDigits)
		end

		if data.sourcedWithSignificantDigits then
			return v2, MAX_PRECISION
		end

		return v3, MAX_PRECISION
	else
		if data.type == enums._Internal.PrecisionType.UNLIMITED then
			MAX_PRECISION = v.MAX_PRECISION
			v2 = 1
		end

		return v2, MAX_PRECISION
	end
end

local frozen = table.freeze({
	[enums.ENumberFormatSymbols.kDecimalSeparatorSymbol] = ".",
	[enums.ENumberFormatSymbols.kGroupingSeparatorSymbol] = ",",
	[enums.ENumberFormatSymbols.kMinusSignSymbol] = "-",
	[enums.ENumberFormatSymbols.kPlusSignSymbol] = "+",
	[enums.ENumberFormatSymbols.kExponentialSymbol] = "E",
	[enums.ENumberFormatSymbols.kInfinitySymbol] = "∞",
	[enums.ENumberFormatSymbols.kNaNSymbol] = "NaN"
})

function v.generate_from_sign_enum(p)
	local negative = nil
	local negativeZero = nil
	local positiveZero = nil
	local positive = nil

	if p == enums.SignDisplay.AUTO then
		negative = true
		negativeZero = true
		positiveZero = false
		positive = false
	elseif p == enums.SignDisplay.ALWAYS then
		negative = true
		negativeZero = true
		positiveZero = true
		positive = true
	elseif p == enums.SignDisplay.NEVER then
		negative = false
		negativeZero = false
		positiveZero = false
		positive = false
	elseif p == enums.SignDisplay.NEGATIVE then
		negative = true
		negativeZero = false
		positiveZero = false
		positive = false
	elseif p == enums.SignDisplay.EXCEPT_ZERO then
		negative = true
		negativeZero = false
		positiveZero = false
		positive = true
	end

	return table.freeze({
		negative = negative,
		negativeZero = negativeZero,
		positiveZero = positiveZero,
		positive = positive
	})
end

function v.linked_list_to_dict(parent)
	local v3 = {}

	while parent do
		if not v3[parent.key] then
			v3[parent.key] = parent.value
		end

		parent = parent.parent
	end

	return table.freeze(v3)
end

function v.resolve_settings(data)
	local v3 = {
		notation = data.notation or table.freeze({
			type = enums._Internal.NotationType.SIMPLE
		})
	}
	local v4 = v3.notation.type == enums._Internal.NotationType.COMPACT

	if data.precision then
		v3.precision = data.precision
	else
		local precision

		if v4 then
			precision = table.freeze({
				type = enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
				minFractionDigits = 0,
				maxFractionDigits = 0,
				minSignificantDigits = 1,
				maxSignificantDigits = 2,
				roundingPriority = enums.RoundingPriority.RELAXED
			})
		else
			precision = table.freeze({
				type = enums._Internal.PrecisionType.FRACTION,
				min = 0,
				max = 6
			})
		end

		v3.precision = precision
	end

	if data.roundingMode then
		v3.roundingMode = data.roundingMode
	else
		local roundingMode

		if v4 or v3.notation.type == enums._Internal.NotationType.SCIENTIFIC then
			roundingMode = enums.RoundingMode.DOWN
		else
			roundingMode = enums.RoundingMode.HALF_EVEN
		end

		v3.roundingMode = roundingMode
	end

	if data.grouping then
		local grouping = data.grouping
		v3.minGrouping = grouping == enums.GroupingStrategy.MIN2 and 5 or grouping == enums.GroupingStrategy.ON_ALIGNED and 4 or nil
	else
		v3.minGrouping = v4 and 5 or 4
	end

	v3.integerWidth = data.integerWidth or table.freeze({
		min = 1,
		max = -1
	})
	v3.symbols = data.symbols or frozen

	if data.sign then
		v3.displaySignAt = v.generate_from_sign_enum(data.sign)
	else
		v3.displaySignAt = v.generate_from_sign_enum(enums.SignDisplay.AUTO)
	end

	v3.alwaysDisplayDecimal = data.decimal == enums.DecimalSeparatorDisplay.ALWAYS
	return table.freeze(v3)
end

return table.freeze(v)