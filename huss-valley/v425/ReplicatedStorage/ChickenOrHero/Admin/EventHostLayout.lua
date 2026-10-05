return table.freeze({
	panel = function(p, p2, p3)
		if p3 and p3 > 0 then
			p2 = math.min(p2, p3)
		end

		local v = math.max(1, (math.min(680, p * 0.9)))
		local v2 = math.max(1, math.min(760, p2 * 0.92) * 0.7)

		if v >= 560 then
			return v, v2, p2, 2
		end

		return v, v2, p2, 1
	end,
	toast = function(p, p2)
		return math.min(760, p * 0.92), math.clamp(p2 * 0.18, 84, 144) * 0.7
	end
})