local FieldValueUtils = require(script.Parent.FieldValueUtils)
return function(_, _, object)
	local extended = object:extend("NumberField")

	function extended.TextToValue(object2, p: string)
		return tonumber(p) or object2:GetValue() or 0
	end

	function extended.ValueToText(_, p: number)
		return FieldValueUtils.FormatNumber(p)
	end

	return extended
end