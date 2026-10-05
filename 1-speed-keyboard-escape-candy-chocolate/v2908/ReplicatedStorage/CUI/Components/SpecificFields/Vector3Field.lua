local createVector = vector.create
local FieldValueUtils = require(script.Parent.FieldValueUtils)
return function(_, _, object)
	local extended = object:extend("Vector3Field")

	function extended.TextToValue(object2, p: string)
		local splitNumberText = FieldValueUtils.SplitNumberText(p)

		if #splitNumberText == 1 then
			return createVector(1, 1, 1) * splitNumberText[1]
		end

		if #splitNumberText >= 3 then
			return (Vector3.new(splitNumberText[1], splitNumberText[2], splitNumberText[3]))
		end

		return object2:GetValue() or createVector(0, 0, 0)
	end

	function extended.ValueToText(_, vector2: Vector3)
		return ("%s, %s, %s"):format(
			FieldValueUtils.FormatNumber(vector2.X),
			FieldValueUtils.FormatNumber(vector2.Y),
			FieldValueUtils.FormatNumber(vector2.Z)
		)
	end

	return extended
end