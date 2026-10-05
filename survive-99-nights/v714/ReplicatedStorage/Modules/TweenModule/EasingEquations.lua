function Bounce(p)
	if p < 0.36363636363636365 then
		return 7.5625 * p ^ 2
	end

	if p < 0.7272727272727273 then
		return 7.5625 * (p - 0.5454545454545454) ^ 2 + 0.75
	end

	if p < 0.9090909090909091 then
		return 7.5625 * (p - 0.8181818181818182) ^ 2 + 0.9375
	end

	return 7.5625 * (p - 0.9545454545454546) ^ 2 + 0.984375
end

local EasingEquations = {}

function EasingEquations.Linear(p, _)
	return p
end

function EasingEquations.ReturnBounce(p, p2)
	if p2 == "Out" then
		return (math.sin((1 - p) ^ 3 * 3.141592653589793))
	end
end

function EasingEquations.LinearSlowed(p, p2)
	if p2 == "In" then
		return p ^ 1.2
	elseif p2 == "Out" then
		return -(1 - p) ^ 1.2 + 1
	end

	if p2 ~= "InOut" then
		return
	end

	local v = p * 2

	if v < 1 then
		return 0.5 * v ^ 2
	end

	return -0.5 * ((v - 1) * (v - 3) - 1)
end

function EasingEquations.Quad(p, p2)
	if p2 == "In" then
		return p ^ 2
	elseif p2 == "Out" then
		return -1 * p * (p - 2)
	end

	if p2 ~= "InOut" then
		return
	end

	local v = p * 2

	if v < 1 then
		return 0.5 * v ^ 2
	end

	return -0.5 * ((v - 1) * (v - 3) - 1)
end

function EasingEquations.Cubic(p, p2)
	if p2 == "In" then
		return p ^ 3
	elseif p2 == "Out" then
		return (p - 1) ^ 3 + 1
	end

	if p2 ~= "InOut" then
		return
	end

	local v = p * 2

	if v < 1 then
		return 0.5 * v ^ 3
	end

	return 0.5 * ((v - 2) ^ 3 + 2)
end

function EasingEquations.Quart(p, p2)
	if p2 == "In" then
		return p ^ 4
	elseif p2 == "Out" then
		return -1 * ((p - 1) ^ 4 - 1)
	end

	if p2 ~= "InOut" then
		return
	end

	local v = p * 2

	if v < 1 then
		return 0.5 * v ^ 4
	end

	return -0.5 * ((v - 2) ^ 4 - 2)
end

function EasingEquations.Quint(p, p2)
	if p2 == "In" then
		return p ^ 5
	elseif p2 == "Out" then
		return (p - 1) ^ 5 + 1
	end

	if p2 ~= "InOut" then
		return
	end

	local v = p * 2

	if v < 1 then
		return 0.5 * v ^ 5
	end

	return 0.5 * ((v - 2) ^ 5 + 2)
end

function EasingEquations.Sine(p, p2)
	if p2 == "In" then
		return math.cos(p * 1.5707963267948966) * -1 + 1
	elseif p2 == "Out" then
		return (math.sin(p * 1.5707963267948966))
	elseif p2 == "InOut" then
		return (math.cos(p * 3.141592653589793) - 1) * -0.5
	end
end

function EasingEquations.Expo(p, p2)
	if p2 == "In" then
		if p == 0 then
			return 0
		end

		return 2 ^ (10 * (p - 1)) - 0.001
	elseif p2 == "Out" then
		if p == 1 then
			return 1
		end

		return 1.001 * (-2 ^ (-10 * p) + 1)
	else
		if p2 ~= "InOut" then
			return
		end

		if p == 0 or p == 1 then
			return p
		end

		local v = p * 2

		if v < 1 then
			return 0.5 * 2 ^ (10 * (v - 1)) - 0.0005
		end

		return 0.50025 * (-2 ^ (-10 * (v - 1)) + 2)
	end
end

function EasingEquations.Elastic(p, p2, options)
	local v = options or {}

	if p2 == "In" then
		if p == 0 or p == 1 then
			return p
		end

		local period = v.Period or 0.3
		local v2 = math.max(v.Amplitude or 1, 1)
		local v3 = v2 < 1 and period / 4 or period / 6.283185307179586 * math.asin(1 / v2)
		local v4 = p - 1
		return -(v2 * 2 ^ (10 * v4) * math.sin((v4 - v3) * 6.283185307179586 / period))
	elseif p2 == "Out" then
		if p == 0 or p == 1 then
			return p
		end

		local period = v.Period or 0.3
		local v2 = math.max(v.Amplitude or 1, 1)
		local v3 = v2 < 1 and period / 4 or period / 6.283185307179586 * math.asin(1 / v2)
		return v2 * 2 ^ (-10 * p) * math.sin((p - v3) * 6.283185307179586 / period) + 1
	else
		if p2 ~= "InOut" then
			return
		end

		if p == 0 or p == 1 then
			return p
		end

		local period = v.Period or 0.44999999999999996
		local v2 = math.max(v.Amplitude or 1, 1)
		local v3 = p * 2
		local v4 = v2 < 1 and period / 4 or period / 6.283185307179586 * math.asin(1 / v2)

		if v3 < 1 then
			local v5 = v3 - 1
			return -0.5 * (v2 * 2 ^ (10 * v5) * math.sin((v5 - v4) * 6.283185307179586 / period))
		end

		local v5 = v3 - 1
		return v2 * 2 ^ (-10 * v5) * math.sin((v5 - v4) * 6.283185307179586 / period) * 0.5 + 1
	end
end

function EasingEquations.Bounce(p, p2)
	if p2 == "In" then
		return 1 - Bounce(1 - p)
	elseif p2 == "Out" then
		return Bounce(p)
	end

	if p2 ~= "InOut" then
		return
	end

	if p < 0.5 then
		return (1 - Bounce(1 - p * 2)) * 0.5
	end

	return Bounce(p * 2 - 1) * 0.5 + 0.5
end

return EasingEquations