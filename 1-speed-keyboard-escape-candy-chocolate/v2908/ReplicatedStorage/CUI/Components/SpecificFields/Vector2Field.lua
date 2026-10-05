local FieldValueUtils = require(script.Parent.FieldValueUtils)
return function(_, _, object)
	local extended = object:extend("Vector2Field")

	function extended.TextToValue(object2, p: string)
		local splitNumberText = FieldValueUtils.SplitNumberText(p)

		if #splitNumberText == 1 then
			return Vector2.one * splitNumberText[1]
		end

		if #splitNumberText >= 2 then
			return Vector2.new(splitNumberText[1], splitNumberText[2])
		end

		return object2:GetValue() or Vector2.zero
	end

	function extended.ValueToText(_, point: Vector2)
		return ("%s, %s"):format(FieldValueUtils.FormatNumber(point.X), FieldValueUtils.FormatNumber(point.Y))
	end

	return extended
end