local Tween = {}
local pow = math.pow
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local asin = math.asin

local function linear(p, p2, p3, p4)
	return p3 * p / p4 + p2
end

local function inQuad(p, p2, p3, p4)
	return p3 * pow(p / p4, 2) + p2
end

local function outQuad(p, p2, p3, p4)
	local v = p / p4
	return -p3 * v * (v - 2) + p2
end

local function inOutQuad(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * pow(v, 2) + p2
	end

	return -p3 / 2 * ((v - 1) * (v - 3) - 1) + p2
end

local function outInQuad(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		local v2 = p3 / 2
		local v3 = v / p4
		return -v2 * v3 * (v3 - 2) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		return p3 / 2 * pow(v / p4, 2) + v2
	end
end

local function inCubic(p, p2, p3, p4)
	return p3 * pow(p / p4, 3) + p2
end

local function outCubic(p, p2, p3, p4)
	return p3 * (pow(p / p4 - 1, 3) + 1) + p2
end

local function inOutCubic(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * v * v * v + p2
	end

	local v2 = v - 2
	return p3 / 2 * (v2 * v2 * v2 + 2) + p2
end

local function outInCubic(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		return p3 / 2 * (pow(v / p4 - 1, 3) + 1) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		return p3 / 2 * pow(v / p4, 3) + v2
	end
end

local function inQuart(p, p2, p3, p4)
	return p3 * pow(p / p4, 4) + p2
end

local function outQuart(p, p2, p3, p4)
	return -p3 * (pow(p / p4 - 1, 4) - 1) + p2
end

local function inOutQuart(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * pow(v, 4) + p2
	end

	return -p3 / 2 * (pow(v - 2, 4) - 2) + p2
end

local function outInQuart(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		return -(p3 / 2) * (pow(v / p4 - 1, 4) - 1) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		return p3 / 2 * pow(v / p4, 4) + v2
	end
end

local function inQuint(p, p2, p3, p4)
	return p3 * pow(p / p4, 5) + p2
end

local function outQuint(p, p2, p3, p4)
	return p3 * (pow(p / p4 - 1, 5) + 1) + p2
end

local function inOutQuint(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * pow(v, 5) + p2
	end

	return p3 / 2 * (pow(v - 2, 5) + 2) + p2
end

local function outInQuint(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		return p3 / 2 * (pow(v / p4 - 1, 5) + 1) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		return p3 / 2 * pow(v / p4, 5) + v2
	end
end

local function inSine(p, p2, p3, p4)
	return -p3 * cos(p / p4 * 1.5707963267948966) + p3 + p2
end

local function outSine(p, p2, p3, p4)
	return p3 * sin(p / p4 * 1.5707963267948966) + p2
end

local function inOutSine(p, p2, p3, p4)
	return -p3 / 2 * (cos(3.141592653589793 * p / p4) - 1) + p2
end

local function outInSine(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		return p3 / 2 * sin(v / p4 * 1.5707963267948966) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		local v3 = p3 / 2
		return -v3 * cos(v / p4 * 1.5707963267948966) + v3 + v2
	end
end

local function inExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	return p3 * pow(2, 10 * (p / p4 - 1)) + p2 - p3 * 0.001
end

local function outExpo(p, p2, p3, p4)
	if p == p4 then
		return p2 + p3
	end

	return p3 * 1.001 * (-pow(2, -10 * p / p4) + 1) + p2
end

local function inOutExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	if p == p4 then
		return p2 + p3
	end

	local v = p / p4 * 2

	if v < 1 then
		return p3 / 2 * pow(2, 10 * (v - 1)) + p2 - p3 * 0.0005
	else
		return p3 / 2 * 1.0005 * (-pow(2, -10 * (v - 1)) + 2) + p2
	end
end

local function outInExpo(p, p2, p3, p4)
	if p < p4 / 2 then
		local v = p * 2
		local v2 = p3 / 2

		if v == p4 then
			return p2 + v2
		end

		return v2 * 1.001 * (-pow(2, -10 * v / p4) + 1) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		local v3 = p3 / 2

		if v == 0 then
			return v2
		end

		return v3 * pow(2, 10 * (v / p4 - 1)) + v2 - v3 * 0.001
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inCirc(p, p2, p3, p4)
	return -p3 * (sqrt(1 - pow(p / p4, 2)) - 1) + p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outCirc(p, p2, p3, p4)
	return p3 * sqrt(1 - pow(p / p4 - 1, 2)) + p2
end

local function inOutCirc(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return -p3 / 2 * (sqrt(1 - v * v) - 1) + p2
	else
		local v2 = v - 2
		return p3 / 2 * (sqrt(1 - v2 * v2) + 1) + p2
	end
end

local function outInCirc(p, p2, p3, p4)
	if p < p4 / 2 then
		return outCirc(p * 2, p2, p3 / 2, p4)
	else
		return inCirc(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4)
	end
end

local function calculatePAS(p, value, p2, p3)
	local selected = p or p3 * 0.3
	local v2 = value or 0

	if v2 < abs(p2) then
		return selected, p2, selected / 4
	end

	return selected, v2, selected / 6.283185307179586 * asin(p2 / v2)
end

local function inElastic(p, p2, p3, p4, value, p5)
	if p == 0 then
		return p2
	end

	local v = p / p4

	if v == 1 then
		return p2 + p3
	end

	local v2 = p5 or p4 * 0.3
	local v3 = value or 0
	local v4

	if v3 < abs(p3) then
		v4 = v2 / 4
		v3 = p3
	else
		v4 = v2 / 6.283185307179586 * asin(p3 / v3)
	end

	local v5 = v - 1
	return -(v3 * pow(2, 10 * v5) * sin((v5 * p4 - v4) * 6.283185307179586 / v2)) + p2
end

local function outElastic(p, p2, p3, p4, value, p5)
	if p == 0 then
		return p2
	end

	local v = p / p4

	if v == 1 then
		return p2 + p3
	end

	local v2 = p5 or p4 * 0.3
	local v3 = value or 0
	local v4

	if v3 < abs(p3) then
		v4 = v2 / 4
		v3 = p3
	else
		v4 = v2 / 6.283185307179586 * asin(p3 / v3)
	end

	return v3 * pow(2, -10 * v) * sin((v * p4 - v4) * 6.283185307179586 / v2) + p3 + p2
end

local function inOutElastic(p, p2, p3, p4, value, p5)
	if p == 0 then
		return p2
	end

	local v = p / p4 * 2

	if v == 2 then
		return p2 + p3
	end

	local v2 = p5 or p4 * 0.3
	local v3 = value or 0
	local v4

	if v3 < abs(p3) then
		v4 = v2 / 4
		v3 = p3
	else
		v4 = v2 / 6.283185307179586 * asin(p3 / v3)
	end

	local v5 = v - 1

	if v5 < 0 then
		return -0.5 * (v3 * pow(2, 10 * v5) * sin((v5 * p4 - v4) * 6.283185307179586 / v2)) + p2
	else
		return v3 * pow(2, -10 * v5) * sin((v5 * p4 - v4) * 6.283185307179586 / v2) * 0.5 + p3 + p2
	end
end

local function outInElastic(p, p2, p3, p4, p5, p6)
	if p < p4 / 2 then
		return (outElastic(p * 2, p2, p3 / 2, p4, p5, p6))
	end

	return (inElastic(p * 2 - p4, p2 + p3 / 2, p3 / 2, p4, p5, p6))
end

local function inBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4
	return p3 * v2 * v2 * ((v + 1) * v2 - v) + p2
end

local function outBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4 - 1
	return p3 * (v2 * v2 * ((v + 1) * v2 + v) + 1) + p2
end

local function inOutBack(p, p2, p3, p4, value)
	local v = (value or 1.70158) * 1.525
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 / 2 * (v2 * v2 * ((v + 1) * v2 - v)) + p2
	end

	local v3 = v2 - 2
	return p3 / 2 * (v3 * v3 * ((v + 1) * v3 + v) + 2) + p2
end

local function outInBack(p, p2, p3, p4, value)
	if p < p4 / 2 then
		local v = p * 2
		local v2 = p3 / 2
		local v3 = value or 1.70158
		local v4 = v / p4 - 1
		return v2 * (v4 * v4 * ((v3 + 1) * v4 + v3) + 1) + p2
	else
		local v = p * 2 - p4
		local v2 = p2 + p3 / 2
		local v3 = p3 / 2
		local v4 = value or 1.70158
		local v5 = v / p4
		return v3 * v5 * v5 * ((v4 + 1) * v5 - v4) + v2
	end
end

local function outBounce(p, p2, p3, p4)
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

local function inBounce(p, p2, p3, p4)
	return p3 - outBounce(p4 - p, 0, p3, p4) + p2
end

local function inOutBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return (p3 - outBounce(p4 - p * 2, 0, p3, p4) + 0) * 0.5 + p2
	else
		return outBounce(p * 2 - p4, 0, p3, p4) * 0.5 + p3 * 0.5 + p2
	end
end

local function outInBounce(p, p2, p3, p4)
	if p < p4 / 2 then
		return (outBounce(p * 2, p2, p3 / 2, p4))
	end

	local v = p * 2 - p4
	local v2 = p2 + p3 / 2
	local v3 = p3 / 2
	return v3 - outBounce(p4 - v, 0, v3, p4) + v2
end

function Tween.point(p, p2, p3)
	return p * (1 - p3) + p2 * p3
end

function Tween.sequence(p, p2, p3, p4)
	if p4 <= 0.5 then
		return Tween.point(p, p2, p4 * 2)
	end

	return Tween.point(p2, p3, (p4 - 0.5) * 2)
end

Tween.ease = {
	["in"] = {
		linear = linear,
		quad = inQuad,
		cubic = inCubic,
		quart = inQuart,
		quint = inQuint,
		sine = inSine,
		expo = inExpo,
		circ = inCirc,
		elastic = inElastic,
		back = inBack,
		bounce = inBounce
	},
	out = {
		quad = outQuad,
		cubic = outCubic,
		quart = outQuart,
		quint = outQuint,
		sine = outSine,
		expo = outExpo,
		circ = outCirc,
		elastic = outElastic,
		back = outBack,
		bounce = outBounce
	},
	inout = {
		quad = inOutQuad,
		cubic = inOutCubic,
		quart = inOutQuart,
		quint = inOutQuint,
		sine = inOutSine,
		expo = inOutExpo,
		circ = inOutCirc,
		elastic = inOutElastic,
		back = inOutBack,
		bounce = inOutBounce
	},
	outin = {
		quad = outInQuad,
		cubic = outInCubic,
		quart = outInQuart,
		quint = outInQuint,
		sine = outInSine,
		expo = outInExpo,
		circ = outInCirc,
		elastic = outInElastic,
		back = outInBack,
		bounce = outInBounce
	}
}
return Tween