local createVector = vector.create
local FieldValueUtils = require(script.Parent.FieldValueUtils)
return function(_, _, object)
	local extended = object:extend("CFrameField")

	function extended.TextToValue(object2, p: string)
		local splitNumberText = FieldValueUtils.SplitNumberText(p)

		if #splitNumberText == 1 then
			return CFrame.new(createVector(1, 1, 1) * splitNumberText[1])
		end

		if #splitNumberText >= 3 and #splitNumberText < 6 then
			return CFrame.new(splitNumberText[1], splitNumberText[2], splitNumberText[3])
		end

		if #splitNumberText >= 6 then
			return CFrame.new(splitNumberText[1], splitNumberText[2], splitNumberText[3]) * CFrame.fromOrientation(
				math.rad(splitNumberText[4]),
				math.rad(splitNumberText[5]),
				(math.rad(splitNumberText[6]))
			)
		end

		return object2:GetValue() or CFrame.new()
	end

	function extended.ValueToText(_, cframe: CFrame)
		local orientation, v, v2 = cframe:ToOrientation()
		return ("%s, %s, %s, %s, %s, %s"):format(
			FieldValueUtils.FormatNumber(cframe.Position.X),
			FieldValueUtils.FormatNumber(cframe.Position.Y),
			FieldValueUtils.FormatNumber(cframe.Position.Z),
			FieldValueUtils.FormatNumber((math.deg(orientation))),
			FieldValueUtils.FormatNumber((math.deg(v))),
			FieldValueUtils.FormatNumber((math.deg(v2)))
		)
	end

	return extended
end