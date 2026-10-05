local v = {
	distance = function(data, value)
		local v2 = math.max(data.Duration, 0.01)
		local v3 = math.min(data.MotionBlendIn or 0.02, v2 * 0.25)
		local v4 = math.min(data.MotionBrake or 0.12, v2 * 0.45)
		local v5 = math.clamp(data.EntrySpeed or 0, 0, data.Distance / math.max(v3, 0.001))
		local v6 = math.max(0, (data.Distance - v5 * v3 / 2) / (v2 - (v3 + v4) / 2))
		local v7 = math.clamp(value, 0, v2)

		if v7 <= v3 then
			return v5 * v7 + (v6 - v5) * v7 * v7 / (v3 * 2)
		end

		local v8 = (v5 + v6) * v3 / 2

		if v7 <= v2 - v4 then
			return v8 + v6 * (v7 - v3)
		end

		local v9 = v8 + v6 * (v2 - v4 - v3)
		local v10 = v7 - (v2 - v4)
		return v9 + v6 * v10 - v6 * v10 * v10 / (v4 * 2)
	end
}

function v.speed(p, p2, p3)
	if p3 <= 0 then
		return 0
	end

	return (math.max(0, (v.distance(p, p2 + p3) - v.distance(p, p2)) / p3))
end

return table.freeze(v)