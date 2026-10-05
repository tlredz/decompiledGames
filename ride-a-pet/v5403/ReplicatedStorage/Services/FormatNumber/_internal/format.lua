local enums = require(script.Parent.enums)
local formatter_settings = require(script.Parent.formatter_settings)
local v = {}

local function internal_get_digits(list, p: number, p2: number, p3: number)
	local v2

	if p2 <= 0 then
		v2 = string.rep("0", -p2 + 1)
		p2 = 1
	else
		v2 = ""
	end

	local v3 = p3 - math.max(p, p2 - 1)
	local v4

	if v3 <= 0 then
		v4 = ""
	else
		v4 = string.rep("0", v3)
		p3 = p
	end

	return v2 .. (p < p2 and "" or string.char(table.unpack(list, p2, p3))) .. v4
end

function v.strip_trailing_zero(p, p2: number)
	if p2 < 0 then
		return 0
	end

	while p[p2] == 0 do
		p2 -= 1
	end

	return p2
end

function v:round_sig(p: number, p2: number, flag: boolean, p3: number)
	local v2 = 0

	if not (p2 < p) then
		return p, v2
	end

	local v3 = nil
	local v4

	if p2 < 0 then
		v4 = -1
	elseif self[p2 + 1] > 5 then
		v4 = 1
	elseif self[p2 + 1] ~= 5 then
		v4 = -1
	elseif p2 + 1 < p then
		v4 = 1
	else
		v4 = 0
	end

	local v5

	if p3 == enums.RoundingMode.CEILING then
		v5 = flag and 1 or -2
	elseif p3 == enums.RoundingMode.FLOOR then
		v5 = flag and -2 or 1
	elseif p3 == enums.RoundingMode.UP then
		v5 = -2
	elseif p3 == enums.RoundingMode.DOWN then
		v5 = 1
	elseif p3 == enums.RoundingMode.HALF_EVEN then
		v5 = p2 <= 0 and 0 or self[p2] % -2
	else
		v5 = p3 == enums.RoundingMode.HALF_DOWN and 0 or p3 == enums.RoundingMode.HALF_UP and -1 or v3
	end

	if v5 < v4 then
		while self[p2] == 9 and p2 > 0 do
			p2 -= 1
		end

		if p2 <= 0 then
			self[1] = 1
			v2 = 1 - p2
			p2 = 1
		else
			self[p2] += 1
		end
	end

	p = v.strip_trailing_zero(self, p2)
	return p, v2
end

function v:resolve_int_frac(p: number, p2: number, p3: number, p4: number, p5: number?, list2: string)
	for i = 1, p do
		self[i] += 48
	end

	local v2, v3

	if p2 < p3 and p4 < p2 + 1 then
		v2 = "0"
		v3 = ""
	else
		v2 = internal_get_digits(self, p, p3, p2)
		v3 = internal_get_digits(self, p, p2 + 1, p4)
	end

	if p5 and p5 <= p2 - p3 + 1 then
		local v4

		if list2 == "%" then
			v4 = "%0%%"
		elseif #list2 > 1 then
			v4 = "%0" .. string.reverse(list2)
		else
			v4 = "%0" .. list2
		end

		v2 = string.reverse((string.gsub(string.reverse(v2), "...", v4, (p2 - p3) / 3)))
	end

	return v2, v3
end

function v.format_expt(p, p2, p3, data)
	local v2 = ""
	local v3

	if p < 0 then
		v3 = tostring(-p)

		if data.negative then
			v2 = p2[enums.ENumberFormatSymbols.kMinusSignSymbol]
		end
	elseif p == 0 then
		v3 = "0"

		if data.positiveZero then
			v2 = p2[enums.ENumberFormatSymbols.kPlusSignSymbol]
		end
	else
		v3 = tostring(p)

		if data.positive then
			v2 = p2[enums.ENumberFormatSymbols.kPlusSignSymbol]
		end
	end

	local v4 = string.rep("0", p3 - #v3) .. v3
	return p2[enums.ENumberFormatSymbols.kExponentialSymbol] .. v2 .. v4
end

function v.resolve_with_notation(_, p, p2, data, p3)
	local v2 = nil
	local v3 = nil
	local v4 = nil

	if p <= 0 then
		if data.type == enums._Internal.NotationType.SCIENTIFIC then
			v2 = v.format_expt(0, p3, data.minExponentDigits, data.displayExponentSignAt)
		end
	elseif data.type == enums._Internal.NotationType.SIMPLE then
		p2 += p
	else
		local power10Scale = data.power10Scale
		local v5 = p2 + p - 1
		local v6 = math.floor(v5 / power10Scale)
		p2 = v5 - v6 * power10Scale + 1

		if data.type == enums._Internal.NotationType.COMPACT then
			local suffixesLength = data.suffixesLength

			if suffixesLength < v6 then
				p2 += (v6 - suffixesLength) * power10Scale
				v2 = data.suffixes[suffixesLength]
			elseif v6 < 0 then
				p2 += v6 * power10Scale
			elseif v6 ~= 0 then
				v2 = data.suffixes[v6]
			end

			if v6 >= 0 and v6 < suffixesLength then
				v4 = data.suffixes[v6 + 1]
				v3 = power10Scale
			end
		else
			v2 = v.format_expt(v6 * power10Scale, p3, data.minExponentDigits, data.displayExponentSignAt)
			v4 = v.format_expt((v6 + 1) * power10Scale, p3, data.minExponentDigits, data.displayExponentSignAt)
			v3 = power10Scale
		end
	end

	return p2, v2, v3, v4
end

function v.format_unsigned_finite(p, p2, p3, p4, data)
	local min = data.integerWidth.min
	local max = data.integerWidth.max
	local notation = data.notation
	local symbols = data.symbols
	local resolve_with_notation, v2, v3, v4 = v.resolve_with_notation(p, p2, p3, notation, symbols)
	local resolve_min_max_sig, v5 = formatter_settings.resolve_min_max_sig(data.precision, resolve_with_notation)
	local round_sig, v6 = v.round_sig(p, p2, v5, p4, data.roundingMode)
	local v7 = round_sig == 0

	if v6 > 0 then
		if resolve_with_notation == v3 then
			assert(v6 == 1)
			v2 = v4
			resolve_with_notation = 1
		else
			resolve_with_notation += v6
		end

		local v8
		resolve_min_max_sig, v8 = formatter_settings.resolve_min_max_sig(data.precision, resolve_with_notation)
	elseif v7 then
		local v8
		resolve_min_max_sig, v8 = formatter_settings.resolve_min_max_sig(data.precision, 1)
		resolve_with_notation = 1
	end

	if resolve_with_notation < min then
		max = min
	elseif max == -1 or not (max < resolve_with_notation) then
		max = resolve_with_notation
	end

	local resolve_int_frac, v8 = v.resolve_int_frac(
		p,
		round_sig,
		resolve_with_notation,
		math.max(resolve_with_notation, 0) - max + 1,
		math.max(round_sig, resolve_min_max_sig),
		data.minGrouping,
		symbols[enums.ENumberFormatSymbols.kGroupingSeparatorSymbol]
	)

	if data.alwaysDisplayDecimal or v8 ~= "" then
		resolve_int_frac ..= symbols[enums.ENumberFormatSymbols.kDecimalSeparatorSymbol] .. v8
	end

	if v2 then
		resolve_int_frac ..= v2
	end

	return resolve_int_frac, v7
end

function v.display_sign(p, p2, p3, data, p4)
	local v2, negativeZero

	if p2 then
		v2 = p4[enums.ENumberFormatSymbols.kMinusSignSymbol]

		if p3 then
			negativeZero = data.negativeZero
		else
			negativeZero = data.negative
		end
	else
		v2 = p4[enums.ENumberFormatSymbols.kPlusSignSymbol]

		if p3 then
			negativeZero = data.positiveZero
		else
			negativeZero = data.positive
		end
	end

	if negativeZero then
		return v2 .. p
	end

	return p
end

return table.freeze(v)