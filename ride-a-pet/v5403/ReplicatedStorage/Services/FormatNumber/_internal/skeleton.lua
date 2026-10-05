local formatter_settings = require(script.Parent.formatter_settings)
local enums = require(script.Parent.enums)
local v = {
	[enums.SignDisplay.AUTO] = nil,
	[enums.SignDisplay.ALWAYS] = "sign-always",
	[enums.SignDisplay.NEVER] = "sign-never",
	[enums.SignDisplay.EXCEPT_ZERO] = "sign-except-zero",
	[enums.SignDisplay.NEGATIVE] = "sign-negative"
}

local function notation_to_skeleton(notation)
	local v2, v3

	if notation.type == enums._Internal.NotationType.SCIENTIFIC then
		v2 = true
		v3 = notation.power10Scale == 3 and "engineering" or "scientific"

		if notation.minExponentDigits ~= 1 then
			v3 ..= "/*" .. string.rep("e", notation.minExponentDigits)
		end

		if notation.exponentSignDisplay == enums.SignDisplay.AUTO then
			return true, v3
		end

		return v2, v3 .. "/" .. v[notation.exponentSignDisplay]
	else
		if notation.type == enums._Internal.NotationType.SIMPLE then
			return true, nil
		end

		v2 = false
		v3 = "Compact notation skeleton is not supported for being represented as a skeleton string in this module"
		return false, v3
	end
end

local function precision_to_skeleton(precision)
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local min = nil
	local max = nil
	local min2 = nil
	local max2 = nil

	if precision.type == enums._Internal.PrecisionType.FRACTION then
		min = precision.min
		max = precision.max
	elseif precision.type == enums._Internal.PrecisionType.SIGNFICANT then
		min2 = precision.min
		max2 = precision.max
	elseif precision.type == enums._Internal.PrecisionType.FRACTION_SIGNIFICANT then
		min = precision.minFractionDigits
		max = precision.maxFractionDigits

		if precision.sourcedWithSignificantDigits then
			min2 = precision.minSignificantDigits
			max2 = precision.maxSignificantDigits
		elseif precision.roundingPriority == enums.RoundingPriority.RELAXED then
			min2 = precision.maxSignificantDigits
			max2 = formatter_settings.MAX_PRECISION
		else
			max2 = precision.maxSignificantDigits
			min2 = 1
		end
	else
		v2 = "precision-unlimited"
	end

	if min then
		if max == 0 then
			v3 = "precision-integer"
		else
			local v5 = "." .. string.rep("0", min)

			if max == formatter_settings.MAX_PRECISION then
				v3 = v5 .. "*"
			else
				v3 = v5 .. string.rep("#", max - min)
			end
		end
	end

	if min2 then
		local v5 = string.rep("@", min2)

		if max2 == formatter_settings.MAX_PRECISION then
			v4 = v5 .. "*"
		else
			v4 = v5 .. string.rep("#", max2 - min2)
		end
	end

	if not v3 then
		return v4 or v2
	end

	if not v4 then
		return v3
	end

	v3 ..= "/" .. v4

	if precision.type ~= enums._Internal.PrecisionType.FRACTION_SIGNIFICANT or not precision.sourcedWithSignificantDigits then
		return v3
	end

	if precision.roundingPriority == enums.RoundingPriority.RELAXED then
		return v3 .. "r"
	end

	return v3 .. "s"
end

local v2 = {
	[enums.RoundingMode.CEILING] = "rounding-mode-ceiling",
	[enums.RoundingMode.FLOOR] = "rounding-mode-floor",
	[enums.RoundingMode.DOWN] = "rounding-mode-down",
	[enums.RoundingMode.UP] = "rounding-mode-up",
	[enums.RoundingMode.HALF_EVEN] = "rounding-mode-half-even",
	[enums.RoundingMode.HALF_DOWN] = "rounding-mode-half-down",
	[enums.RoundingMode.HALF_UP] = "rounding-half-up"
}
local v3 = {
	[enums.GroupingStrategy.OFF] = "group-off",
	[enums.GroupingStrategy.MIN2] = "group-min2",
	[enums.GroupingStrategy.ON_ALIGNED] = "group-on-aligned"
}

local function int_width_to_skeleton(integerWidth)
	if integerWidth.max == -1 then
		return "integer-width/*" .. string.rep("0", integerWidth.min)
	end

	if integerWidth.max == 0 and integerWidth.min == 0 then
		return "integer-width-trunc"
	end

	return "integer-width/" .. string.rep("#", integerWidth.max - integerWidth.min) .. string.rep("0", integerWidth.min)
end

local v4 = {
	[enums.DecimalSeparatorDisplay.AUTO] = nil,
	[enums.DecimalSeparatorDisplay.ALWAYS] = "decimal-always"
}
local Skeleton = {
	settings_to_skeleton = function(data)
		local v5 = {}
		local joined = nil
		local v6

		if data.notation then
			local v7
			v6, v7 = notation_to_skeleton(data.notation)

			if v6 then
				table.insert(v5, v7)
			else
				joined = v7
			end
		else
			v6 = true
		end

		if not v6 then
			return v6, joined
		end

		if data.precision then
			table.insert(v5, (precision_to_skeleton(data.precision)))
		end

		if data.roundingMode then
			table.insert(v5, v2[data.roundingMode])
		end

		if data.grouping then
			table.insert(v5, v3[data.grouping])
		end

		if data.integerWidth then
			table.insert(v5, (int_width_to_skeleton(data.integerWidth)))
		end

		if data.decimal then
			table.insert(v5, v4[data.decimal])
		end

		joined = table.concat(v5, " ")
		return v6, joined
	end
}
local v5 = {
	["notation-simple"] = "notation",
	["precision-unlimited"] = "precision",
	[".+"] = "precision",
	["rounding-mode-ceiling"] = "roundingMode",
	["rounding-mode-floor"] = "roundingMode",
	["rounding-mode-down"] = "roundingMode",
	["rounding-mode-up"] = "roundingMode",
	["rounding-mode-half-even"] = "roundingMode",
	["rounding-mode-half-down"] = "roundingMode",
	["rounding-mode-half-up"] = "roundingMode",
	["group-off"] = "grouping",
	["group-min2"] = "grouping",
	["group-on-aligned"] = "grouping",
	[",_"] = "grouping",
	[",?"] = "grouping",
	[",!"] = "grouping",
	["sign-auto"] = "sign",
	["sign-always"] = "sign",
	["sign-never"] = "sign",
	["sign-except-zero"] = "sign",
	["sign-negative"] = "sign",
	["+!"] = "sign",
	["+_"] = "sign",
	["+?"] = "sign",
	["+-"] = "sign",
	["decimal-auto"] = "decimal",
	["decimal-always"] = "decimal"
}
local v6 = {
	["notation-simple"] = table.freeze({
		type = enums._Internal.NotationType.SIMPLE
	}),
	["precision-unlimited"] = table.freeze({
		type = enums._Internal.PrecisionType.UNLIMITED
	}),
	[".+"] = table.freeze({
		type = enums._Internal.PrecisionType.UNLIMITED
	}),
	["rounding-mode-ceiling"] = enums.RoundingMode.CEILING,
	["rounding-mode-floor"] = enums.RoundingMode.FLOOR,
	["rounding-mode-down"] = enums.RoundingMode.DOWN,
	["rounding-mode-up"] = enums.RoundingMode.UP,
	["rounding-mode-half-even"] = enums.RoundingMode.HALF_EVEN,
	["rounding-mode-half-down"] = enums.RoundingMode.HALF_DOWN,
	["rounding-mode-half-up"] = enums.RoundingMode.HALF_UP,
	["group-off"] = enums.GroupingStrategy.OFF,
	["group-min2"] = enums.GroupingStrategy.MIN2,
	["group-on-aligned"] = enums.GroupingStrategy.ON_ALIGNED,
	[",_"] = enums.GroupingStrategy.OFF,
	[",?"] = enums.GroupingStrategy.MIN2,
	[",!"] = enums.GroupingStrategy.ON_ALIGNED,
	["sign-auto"] = enums.SignDisplay.AUTO,
	["sign-always"] = enums.SignDisplay.ALWAYS,
	["sign-never"] = enums.SignDisplay.NEVER,
	["sign-except-zero"] = enums.SignDisplay.EXCEPT_ZERO,
	["sign-negative"] = enums.SignDisplay.NEGATIVE,
	["+!"] = enums.SignDisplay.ALWAYS,
	["+_"] = enums.SignDisplay.NEVER,
	["+?"] = enums.SignDisplay.EXCEPT_ZERO,
	["+-"] = enums.SignDisplay.NEGATIVE,
	["decimal-auto"] = enums.DecimalSeparatorDisplay.AUTO,
	["decimal-always"] = enums.DecimalSeparatorDisplay.ALWAYS
}

local function skeleton_to_scientific_notation(value)
	local v7, v8, v9 = string.match(value, "^(%a+)/?([^/]*)/?([^/]*)$")
	local minExponentDigits = 1
	local AUTO = enums.SignDisplay.AUTO

	if v7 ~= "scientific" and v7 ~= "engineering" then
		return nil
	end

	if string.match(v8, "^[%*%+]e+$") then
		minExponentDigits = #v8 - 1
		v8 = v9
	elseif string.match(v9, "^[%*%+]e+$") then
		minExponentDigits = #v9 - 1
	end

	if v8 ~= "" then
		if string.sub(v8, 1, 5) ~= "sign-" then
			return nil
		end

		AUTO = v6[v8]
	end

	if minExponentDigits > 999 then
		return nil
	end

	return table.freeze({
		type = enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = v7 == "engineering" and 3 or 1,
		minExponentDigits = minExponentDigits,
		exponentSignDisplay = AUTO,
		displayExponentSignAt = formatter_settings.generate_from_sign_enum(AUTO)
	})
end

local function skeleton_to_scientific_notation_concise(value)
	local v7, v8 = string.match(value, "^(EE?)(.+)$")

	if not v7 then
		return nil
	end

	local v9, v10 = string.match(v8, "^(%+[!%?])(.+)$")
	local AUTO

	if v9 then
		AUTO = v6[v9]
	else
		AUTO = enums.SignDisplay.AUTO
		v10 = v8
	end

	if not string.match(v10, "^0+$") or #v10 > 999 then
		return nil
	end

	return table.freeze({
		type = enums._Internal.NotationType.SCIENTIFIC,
		power10Scale = v7 == "EE" and 3 or 1,
		minExponentDigits = #v10,
		exponentSignDisplay = AUTO,
		displayExponentSignAt = formatter_settings.generate_from_sign_enum(AUTO)
	})
end

local function skeleton_to_precision(value)
	local v7, v8, v9 = string.match(value, "^%.((0*)#*)(.*)$")

	if not v7 then
		v7, v9 = string.match(value, "^(precision%-integer)(.*)$")
	end

	if v7 then
		local v10, MAX_PRECISION

		if v7 == "precision-integer" then
			v10 = 0
			MAX_PRECISION = 0
		else
			v10 = #v8
			MAX_PRECISION = #v7
		end

		if string.match(v9, "^[%*%+]") and v8 == v7 then
			v9 = string.sub(v9, 2)
			MAX_PRECISION = -1
		end

		if v10 > 999 or MAX_PRECISION > 999 then
			return nil
		end

		if MAX_PRECISION == -1 then
			MAX_PRECISION = formatter_settings.MAX_PRECISION
		end

		if string.sub(v9, 1, 1) == "/" then
			local sourcedWithSignificantDigits = false
			local v12, v13, v14 = string.match(v9, "^/((@+)#*)([%*%+rs]?)$")

			if not v12 or v14 == "" and v13 ~= "@" or (v14 == "*" or v14 == "+") and v13 ~= v12 then
				return nil
			end

			local maxSignificantDigits, minSignificantDigits

			if v14 == "" then
				maxSignificantDigits = #v12
				minSignificantDigits = 1
				v14 = "s"
			elseif v14 == "*" or v14 == "+" then
				maxSignificantDigits = #v13
				minSignificantDigits = 1
				v14 = "r"
			else
				minSignificantDigits = #v13
				maxSignificantDigits = #v12
				sourcedWithSignificantDigits = true
			end

			if minSignificantDigits > 999 or maxSignificantDigits > 999 then
				return nil
			end

			local v17 = {
				type = enums._Internal.PrecisionType.FRACTION_SIGNIFICANT,
				minFractionDigits = v10,
				maxFractionDigits = MAX_PRECISION,
				minSignificantDigits = minSignificantDigits,
				maxSignificantDigits = maxSignificantDigits,
				roundingPriority = 0,
				sourcedWithSignificantDigits = 0
			}
			local roundingPriority

			if v14 == "r" then
				roundingPriority = enums.RoundingPriority.RELAXED
			else
				roundingPriority = enums.RoundingPriority.STRICT
			end

			v17.roundingPriority = roundingPriority
			v17.sourcedWithSignificantDigits = sourcedWithSignificantDigits
			return table.freeze(v17)
		elseif v9 == "" then
			return table.freeze({
				type = enums._Internal.PrecisionType.FRACTION,
				min = v10,
				max = MAX_PRECISION
			})
		else
			return nil
		end
	else
		local v10, v11, v12 = string.match(value, "^((@+)#*)([%*%+]?)$")

		if not v10 then
			return nil
		end

		local count = #v11
		local MAX_PRECISION = #v10

		if v12 ~= "" then
			if count ~= MAX_PRECISION then
				return nil
			end

			string.sub(v12, 2)
			MAX_PRECISION = -1
		end

		if count > 999 or MAX_PRECISION > 999 then
			return nil
		end

		if MAX_PRECISION == -1 then
			MAX_PRECISION = formatter_settings.MAX_PRECISION
		end

		return table.freeze({
			type = enums._Internal.PrecisionType.SIGNFICANT,
			min = count,
			max = MAX_PRECISION
		})
	end
end

local function skeleton_to_int_width(value)
	if value == "integer-width-trunc" then
		return table.freeze({
			min = 0,
			max = 0
		})
	end

	local v7 = string.match(value, "^integer%-width/[%*%+](0*)$")

	if v7 then
		if #v7 > 999 then
			return nil
		end

		return table.freeze({
			min = #v7,
			max = -1
		})
	else
		local v8, v9 = string.match(value, "^integer%-width/(#*(0*))$")

		if v8 and v8 ~= "" and not (#v8 > 999 or #v9 > 999) then
			return table.freeze({
				min = #v9,
				max = #v8
			})
		end

		return nil
	end
end

local function skeleton_to_int_width_concise(value)
	if string.match(value, "^0+$") and #value < 1000 then
		return (table.freeze({
			min = #value,
			max = -1
		}))
	end

	return nil
end

function Skeleton.to_option_linked_list(value)
	local v7 = {}
	local parent = nil

	for k, v9 in string.gmatch(value, "()(%S+)") do
		local v10 = v5[v9]
		local v11

		if v10 then
			v11 = v6[v9]
		end

		if not v11 then
			v11 = skeleton_to_scientific_notation(v9) or skeleton_to_scientific_notation_concise(v9)

			if v11 then
				v10 = "notation"
			end
		end

		if not v11 then
			v11 = skeleton_to_precision(v9)

			if v11 then
				v10 = "precision"
			end
		end

		if not v11 then
			v11 = skeleton_to_int_width(v9) or skeleton_to_int_width_concise(v9)

			if v11 then
				v10 = "integerWidth"
			end
		end

		if v10 and not v7[v10] then
			v7[v10] = true
			parent = {
				key = v10,
				value = v11,
				parent = parent
			}
		else
			return
				false,
				string.format("number skeleton syntax error near '%*' at position %d", string.gsub(v9, "'", "\\'"), k)
		end
	end

	return true, parent
end

return Skeleton