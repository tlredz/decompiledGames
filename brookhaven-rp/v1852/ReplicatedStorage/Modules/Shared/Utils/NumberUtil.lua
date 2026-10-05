return {
	phi = 1.618033988749895,
	goldenFraction = 0.618033988749895,
	basicallyZero = 0.001,
	fullCircle = 6.283185307179586,
	quarterCircle = 1.5707963267948966,
	Commas = function(p, value)
		local v = tonumber(p)

		if not v then
			return nil
		end

		local v2 = v < 0
		local v3 = tostring((math.abs(v)))
		return (v2 and "-" or "") .. (value or "") .. (#v3 % 3 == 0 and v3:reverse():gsub("(%d%d%d)", "%1,"):reverse():sub(2) or v3:reverse():gsub(
			"(%d%d%d)",
			"%1,"
		):reverse())
	end
}