function vKeyPoint(p: number, value)
	if type(value) == "number" then
		return (NumberSequenceKeypoint.new(p, value))
	end

	return (ColorSequenceKeypoint.new(p, value))
end

return function(p: number, p2: number, p3, p4, value: number?)
	local v = value or 0.01
	assert(v, "bad blend")
	local v2 = {}

	if p2 < p then
		local v3 = p2
		p2 = p
		p = v3
		v3 = p3
		p3 = p4
		p4 = v3
	end

	local function insertPoint(p5: number, p6)
		local v3 = v2[#v2]

		if v3 then
			local v4 = math.clamp(math.max(p5, v3.Time + 0.01), 0, 1)

			if v4 == 0 then
				v2[1] = vKeyPoint(v4, p6)
			elseif v3.Time < 1 then
				table.insert(v2, vKeyPoint(v4, p6))
			end
		else
			table.insert(v2, vKeyPoint(0, p6))
		end
	end

	insertPoint(0, p4)
	insertPoint(p - v / 2, p4)
	insertPoint(p, p3)
	insertPoint(p2, p3)
	insertPoint(p2 + v / 2, p4)
	insertPoint(1, p4)

	if typeof(p3) == "Color3" then
		return (ColorSequence.new(v2))
	end

	return (NumberSequence.new(v2))
end