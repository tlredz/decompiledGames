return {
	RandomValueFromRange = function(range: NumberRange)
		if range.Min == range.Max then
			return range.Min
		end

		return range.Min + (range.Max - range.Min) * math.random()
	end
}