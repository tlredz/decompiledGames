local function springCoefficients(p: number, p2: number, p3: number)
	if p == 0 or p3 == 0 then
		return 1, 0, 0, 1
	end

	if p2 > 1 then
		local v = math.sqrt(p2 ^ 2 - 1)
		local v2 = -0.5 / (v * p3)
		local v3 = p3 * (v + p2) * -1
		local v4 = p3 * (v - p2)
		local v5 = math.exp(p * v3)
		local v6 = math.exp(p * v4)
		return (v6 * v3 - v5 * v4) * v2, (v5 - v6) * v2 / p3, (v6 - v5) * v2 * p3, (v5 * v3 - v6 * v4) * v2
	elseif p2 == 1 then
		local v = p * p3
		local v2 = v * -1
		local v3 = math.exp(v2)
		return v3 * (v + 1), v3 * p, v3 * (v2 * p3), v3 * (v2 + 1)
	else
		local v = p3 * math.sqrt(1 - p2 ^ 2)
		local v2 = 1 / v
		local v3 = math.exp(p * -1 * p3 * p2)
		local v4 = math.sin(v * p)
		local v5 = math.cos(v * p)
		local v6 = v3 * v4
		local v7 = v3 * v5
		local v8 = v6 * p3 * p2 * v2
		return v8 + v7, v6 * v2, (v6 * v + p3 * p2 * v8) * -1, v7 - v8
	end
end

return springCoefficients