local function Linear(p)
	return p
end

local function Bezier(p, p2, p3, p4)
	if not (p and p2 and p3 and p4) then
		error("Need 4 numbers to construct a Bezier curve", 0)
	end

	if not (p >= 0 and p <= 1 and p3 >= 0 and p3 <= 1) then
		error("The x values must be within range [0, 1]", 0)
	end

	if p == p2 and p3 == p4 then
		return Linear
	end

	local v = {}

	for i = 0, 10 do
		local v2 = i / 10
		v[i] = (((1 - 3 * p3 + 3 * p3) * v2 + (3 * p3 - 6 * p)) * v2 + 3 * p) * v2
	end

	return function(p5)
		if p == p2 and p3 == p4 then
			return Linear
		end

		if p5 == 0 or p5 == 1 then
			return p5
		end

		local v2 = 1
		local v3 = 0

		while v2 ~= 10 and v[v2] <= p5 do
			v3 += 0.1
			v2 += 1
		end

		local v4 = v2 - 1
		local v5 = v3 + (p5 - v[v4]) / (v[v4 + 1] - v[v4]) / 10
		local v6 = 3 * (1 - 3 * p3 + 3 * p) * v5 * v5 + 2 * (3 * p3 - 6 * p) * v5 + 3 * p

		if v6 >= 0.001 then
			for _ = 0, 3 do
				local v7 = 3 * (1 - 3 * p3 + 3 * p) * v5 * v5 + 2 * (3 * p3 - 6 * p) * v5 + 3 * p
				v5 -= ((((1 - 3 * p3 + 3 * p) * v5 + (3 * p3 - 6 * p)) * v5 + 3 * p) * v5 - p5) / v7
			end
		elseif v6 ~= 0 then
			local v7 = v3 + 0.1
			local v8 = 0
			local v9 = nil
			v5 = nil

			while math.abs(v8) > 1e-7 and v9 < 10 do
				v5 = v3 + (v7 - v3) / 2
				v8 = (((1 - 3 * p3 + 3 * p) * v5 + (3 * p3 - 6 * p)) * v5 + 3 * p) * v5 - p5

				if v8 > 0 then
					v7 = v5
				else
					v3 = v5
				end

				v9 += 1
			end
		end

		return (((1 - 3 * p4 + 3 * p2) * v5 + (3 * p4 - 6 * p2)) * v5 + 3 * p2) * v5
	end
end

return Bezier