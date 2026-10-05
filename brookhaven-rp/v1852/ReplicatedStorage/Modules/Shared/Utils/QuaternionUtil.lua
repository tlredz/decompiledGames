local QuaternionUtil = {}

function QuaternionUtil.encode(cframe: CFrame)
	local axisAngle, v = cframe:ToAxisAngle()
	local v2 = v / 2
	local v3 = math.sin(v2)
	local v4 = math.cos(v2)
	local v5 = axisAngle.X * v3
	local v6 = axisAngle.Y * v3
	local v7 = axisAngle.Z * v3
	local abs = math.abs
	local v8 = abs(v4)
	local v9

	if v8 < abs(v5) then
		v8 = abs(v5)
		v9 = 1
	else
		v9 = 0
	end

	if v8 < abs(v6) then
		v8 = abs(v6)
		v9 = 2
	end

	local maxIdx = v8 < abs(v7) and 3 or v9

	if maxIdx == 0 then
		if v4 < 0 then
			v5 = -v5
			v6 = -v6
			v7 = -v7
		end
	else
		if maxIdx == 1 then
			if v5 < 0 then
				v6 = -v6
				v7 = -v7
				v4 = -v4
			end
		else
			if maxIdx == 2 then
				if v6 < 0 then
					v5 = -v5
					v7 = -v7
					v4 = -v4
				end
			else
				if v7 < 0 then
					v5 = -v5
					v6 = -v6
					v4 = -v4
				end

				v7 = v6
			end

			v6 = v5
		end

		v5 = v4
	end

	return {
		maxIdx = maxIdx,
		a = v5,
		b = v6,
		c = v7
	}
end

function QuaternionUtil.decode(p: number, p2: number, p3: number, p4: number)
	local v = math.sqrt((math.max(0, 1 - p2 * p2 - p3 * p3 - p4 * p4)))

	if p == 0 then
		local v2 = v
		v = p4
		p4 = p3
		p3 = p2
		p2 = v2
	elseif p == 1 then
		local v2 = v
		v = p4
		p4 = p3
		p3 = v2
	elseif p == 2 then
		v, p4 = p4, v
	end

	local v2 = math.sqrt(p2 * p2 + p3 * p3 + p4 * p4 + v * v)

	if v2 > 0 then
		p2 /= v2
		p3 /= v2
		p4 /= v2
		v /= v2
	end

	return p3, p4, v, p2
end

return QuaternionUtil