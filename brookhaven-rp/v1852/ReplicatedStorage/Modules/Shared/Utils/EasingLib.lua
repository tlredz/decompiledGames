local EasingLib = {
	linear = function(p, p2, p3, p4)
		return p3 * p / p4 + p2
	end,
	inQuad = function(p, p2, p3, p4)
		return p3 * math.pow(p / p4, 2) + p2
	end,
	outQuad = function(p, p2, p3, p4)
		local v = p / p4
		return -p3 * v * (v - 2) + p2
	end,
	inOutQuad = function(p, p2, p3, p4)
		local v = p / p4 * 2

		if v < 1 then
			return p3 / 2 * math.pow(v, 2) + p2
		end

		return -p3 / 2 * ((v - 1) * (v - 3) - 1) + p2
	end
}

function EasingLib.outInQuad(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outQuad(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inQuad(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inCubic(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 3) + p2
end

function EasingLib.outCubic(p, p2, p3, p4)
	return p3 * (math.pow(p / p4 - 1, 3) + 1) + p2
end

function EasingLib.inOutCubic(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * v * v * v + p2
	end

	local v2 = v - 2
	return p3 / 2 * (v2 * v2 * v2 + 2) + p2
end

function EasingLib.outInCubic(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outCubic(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inCubic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inQuart(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 4) + p2
end

function EasingLib.outQuart(p, p2, p3, p4)
	local v = p / p4 - 1
	return -p3 * (math.pow(v, 4) - 1) + p2
end

function EasingLib.inOutQuart(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * math.pow(v, 4) + p2
	end

	local v2 = v - 2
	return -p3 / 2 * (math.pow(v2, 4) - 2) + p2
end

function EasingLib.outInQuart(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outQuart(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inQuart(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inQuint(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 5) + p2
end

function EasingLib.outQuint(p, p2, p3, p4)
	return p3 * (math.pow(p / p4 - 1, 5) + 1) + p2
end

function EasingLib.inOutQuint(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * math.pow(v, 5) + p2
	end

	local v2 = v - 2
	return p3 / 2 * (math.pow(v2, 5) + 2) + p2
end

function EasingLib.outInQuint(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outQuint(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inQuint(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inSine(p, p2, p3, p4)
	return -p3 * math.cos(p / p4 * 1.5707963267948966) + p3 + p2
end

function EasingLib.outSine(p, p2, p3, p4)
	return p3 * math.sin(p / p4 * 1.5707963267948966) + p2
end

function EasingLib.inOutSine(p, p2, p3, p4)
	return -p3 / 2 * (math.cos(3.141592653589793 * p / p4) - 1) + p2
end

function EasingLib.outInSine(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outSine(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inSine(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	return p3 * math.pow(2, 10 * (p / p4 - 1)) + p2 - p3 * 0.001
end

function EasingLib.outExpo(p, p2, p3, p4)
	if p == p4 then
		return p2 + p3
	end

	return p3 * 1.001 * (-math.pow(2, -10 * p / p4) + 1) + p2
end

function EasingLib.inOutExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	if p == p4 then
		return p2 + p3
	end

	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * math.pow(2, 10 * (v - 1)) + p2 - p3 * 0.0005
	end

	local v2 = v - 1
	return p3 / 2 * 1.0005 * (-math.pow(2, -10 * v2) + 2) + p2
end

function EasingLib.outInExpo(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outExpo(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inExpo(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inCirc(p, p2, p3, p4)
	local v = p / p4
	return -p3 * (math.sqrt(1 - math.pow(v, 2)) - 1) + p2
end

function EasingLib.outCirc(p, p2, p3, p4)
	return p3 * math.sqrt(1 - math.pow(p / p4 - 1, 2)) + p2
end

function EasingLib.inOutCirc(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return -p3 / 2 * (math.sqrt(1 - v * v) - 1) + p2
	end

	local v2 = v - 2
	return p3 / 2 * (math.sqrt(1 - v2 * v2) + 1) + p2
end

function EasingLib.outInCirc(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outCirc(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inCirc(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

function EasingLib.inElastic(p, p2, p3, p4, p5, p6)
	if p == 0 then
		return p2
	end

	local v = p / p4

	if v == 1 then
		return p2 + p3
	end

	local v2 = p6 or p4 * 0.3
	local v3

	if p5 and not (p5 < math.abs(p3)) then
		v3 = v2 / 6.283185307179586 * math.asin(p3 / p5)
	else
		v3 = v2 / 4
		p5 = p3
	end

	local v4 = v - 1
	return -(p5 * math.pow(2, 10 * v4) * math.sin((v4 * p4 - v3) * 6.283185307179586 / v2)) + p2
end

function EasingLib.outElastic(p, p2, p3, p4, p5, p6)
	if p == 0 then
		return p2
	end

	local v = p / p4

	if v == 1 then
		return p2 + p3
	end

	local v2 = p6 or p4 * 0.3
	local v3

	if p5 and not (p5 < math.abs(p3)) then
		v3 = v2 / 6.283185307179586 * math.asin(p3 / p5)
	else
		v3 = v2 / 4
		p5 = p3
	end

	return p5 * math.pow(2, -10 * v) * math.sin((v * p4 - v3) * 6.283185307179586 / v2) + p3 + p2
end

function EasingLib.inOutElastic(p, p2, p3, p4, value, p5)
	if p == 0 then
		return p2
	end

	local v = p / p4 * 2

	if v == 2 then
		return p2 + p3
	end

	local v2 = p5 or p4 * 0.44999999999999996
	local v3 = value or 0
	local v4

	if v3 and not (v3 < math.abs(p3)) then
		v4 = v2 / 6.283185307179586 * math.asin(p3 / v3)
	else
		v4 = v2 / 4
		v3 = p3
	end

	if v < 1 then
		local v5 = v - 1
		return -0.5 * (v3 * math.pow(2, 10 * v5) * math.sin((v5 * p4 - v4) * 6.283185307179586 / v2)) + p2
	end

	local v5 = v - 1
	return v3 * math.pow(2, -10 * v5) * math.sin((v5 * p4 - v4) * 6.283185307179586 / v2) * 0.5 + p3 + p2
end

function EasingLib.outInElastic(p, p2, p3, p4, p5, p6)
	if p < p4 / 2 then
		return EasingLib.outElastic(p * 2, p2, p3 / 2, p4, p5, p6)
	end

	return EasingLib.inElastic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4, p5, p6)
end

function EasingLib.inBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4
	return p3 * v2 * v2 * ((v + 1) * v2 - v) + p2
end

function EasingLib.outBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4 - 1
	return p3 * (v2 * v2 * ((v + 1) * v2 + v) + 1) + p2
end

function EasingLib.inOutBack(p, p2, p3, p4, value)
	local v = (value or 1.70158) * 1.525
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * (v2 * v2 * ((v + 1) * v2 - v)) + p2
	end

	local v3 = v2 - 2
	return p3 / 2 * (v3 * v3 * ((v + 1) * v3 + v) + 2) + p2
end

function EasingLib.outInBack(p, p2, p3, p4, p5)
	if p < p4 / 2 then
		return EasingLib.outBack(p * 2, p2, p3 / 2, p4, p5)
	end

	return EasingLib.inBack(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4, p5)
end

function EasingLib.outBounce(p, p2, p3, p4)
	local v = p / p4

	if v < 0.36363636363636365 then
		return p3 * (7.5625 * v * v) + p2
	end

	if v < 0.7272727272727273 then
		local v2 = v - 0.5454545454545454
		return p3 * (7.5625 * v2 * v2 + 0.75) + p2
	end

	if v < 0.9090909090909091 then
		local v2 = v - 0.8181818181818182
		return p3 * (7.5625 * v2 * v2 + 0.9375) + p2
	end

	local v2 = v - 0.9545454545454546
	return p3 * (7.5625 * v2 * v2 + 0.984375) + p2
end

function EasingLib.inBounce(p, p2, p3, p4)
	return p3 - EasingLib.outBounce(p4 - p, 0, p3, p4) + p2
end

function EasingLib.inOutBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.inBounce(p * 2, 0, p3, p4) * 0.5 + p2
	end

	return EasingLib.outBounce(p * 2 - p4, 0, p3, p4) * 0.5 + p3 * 0.5 + p2
end

function EasingLib.outInBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return EasingLib.outBounce(p * 2, p2, p3 / 2, p4)
	end

	return EasingLib.inBounce(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
end

return EasingLib