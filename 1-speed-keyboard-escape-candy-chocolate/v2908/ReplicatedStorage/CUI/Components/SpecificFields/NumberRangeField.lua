local FieldValueUtils = require(script.Parent.FieldValueUtils)
return function(_, _, object)
	local extended = object:extend("NumberRangeField")

	function extended.TextToValue(object2, p: string)
		local splitNumberText = FieldValueUtils.SplitNumberText(p)

		if #splitNumberText == 1 then
			return NumberRange.new(splitNumberText[1])
		end

		if #splitNumberText >= 2 then
			return NumberRange.new(
				math.min(splitNumberText[1], splitNumberText[2]),
				(math.max(splitNumberText[1], splitNumberText[2]))
			)
		end

		return object2:GetValue() or NumberRange.new(0)
	end

	function extended.ValueToText(_, range: NumberRange)
		if range.Min == range.Max then
			return FieldValueUtils.FormatNumber(range.Min)
		end

		return ("%s, %s"):format(FieldValueUtils.FormatNumber(range.Min), FieldValueUtils.FormatNumber(range.Max))
	end

	return extended
end