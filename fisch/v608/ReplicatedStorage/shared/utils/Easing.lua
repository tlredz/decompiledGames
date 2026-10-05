local sin = math.sin
local cos = math.cos
local asin = math.asin

local function Linear(p, p2, p3, p4)
	return p3 * p / p4 + p2
end

local function Smooth(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v * (3 - 2 * v) + p2
end

local function Smoother(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v * v * (v * (6 * v - 15) + 10) + p2
end

local function RevBack(p, p2, p3, p4)
	local v = 1 - p / p4
	return p3 * (1 - (sin(v * 1.5707963267948966) + sin(v * 3.141592653589793) * (cos(v * 3.141592653589793) + 1) * 0.5)) + p2
end

local function RidiculousWiggle(p, p2, p3, p4)
	return p3 * sin(sin(p / p4 * 3.141592653589793) * 1.5707963267948966) + p2
end

local function Spring(p, p2, p3, p4)
	local v = p / p4
	return (1 + -2.72 ^ (-6.9 * v) * cos(-20.106192982974676 * v)) * p3 + p2
end

local function SoftSpring(p, p2, p3, p4)
	local v = p / p4
	return (1 + -2.72 ^ (-7.5 * v) * cos(-10.053096491487338 * v)) * p3 + p2
end

local function InQuad(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v + p2
end

local function OutQuad(p, p2, p3, p4)
	local v = p / p4
	return -p3 * v * (v - 2) + p2
end

local function InOutQuad(p, p2, p3, p4)
	local v = p / p4 * 2
	return v < 1 and p3 * 0.5 * v * v + p2 or -p3 * 0.5 * ((v - 1) * (v - 3) - 1) + p2
end

local function OutInQuad(p, p2, p3, p4)
	if p < p4 * 0.5 then
		local v = 2 * p / p4
		return -0.5 * p3 * v * (v - 2) + p2
	end

	local v = (p * 2 - p4) / p4
	local v2 = 0.5 * p3
	return v2 * v * v + p2 + v2
end

local function InCubic(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v * v + p2
end

local function OutCubic(p, p2, p3, p4)
	local v = p / p4 - 1
	return p3 * (v * v * v + 1) + p2
end

local function InOutCubic(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 * 0.5 * v * v * v + p2
	end

	local v2 = v - 2
	return p3 * 0.5 * (v2 * v2 * v2 + 2) + p2
end

local function OutInCubic(p, p2, p3, p4)
	if p < p4 * 0.5 then
		local v = p * 2 / p4 - 1
		return p3 * 0.5 * (v * v * v + 1) + p2
	end

	local v = (p * 2 - p4) / p4
	local v2 = p3 * 0.5
	return v2 * v * v * v + p2 + v2
end

local function InQuart(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v * v * v + p2
end

local function OutQuart(p, p2, p3, p4)
	local v = p / p4 - 1
	return -p3 * (v * v * v * v - 1) + p2
end

local function InOutQuart(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 * 0.5 * v * v * v * v + p2
	end

	local v2 = v - 2
	return -p3 * 0.5 * (v2 * v2 * v2 * v2 - 2) + p2
end

local function OutInQuart(p, p2, p3, p4)
	if p < p4 * 0.5 then
		local v = p * 2 / p4 - 1
		return -(p3 * 0.5) * (v * v * v * v - 1) + p2
	end

	local v = (p * 2 - p4) / p4
	local v2 = p3 * 0.5
	return v2 * v * v * v * v + p2 + v2
end

local function InQuint(p, p2, p3, p4)
	local v = p / p4
	return p3 * v * v * v * v * v + p2
end

local function OutQuint(p, p2, p3, p4)
	local v = p / p4 - 1
	return p3 * (v * v * v * v * v + 1) + p2
end

local function InOutQuint(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return p3 * 0.5 * v * v * v * v * v + p2
	end

	local v2 = v - 2
	return p3 * 0.5 * (v2 * v2 * v2 * v2 * v2 + 2) + p2
end

local function OutInQuint(p, p2, p3, p4)
	if p < p4 * 0.5 then
		local v = p * 2 / p4 - 1
		return p3 * 0.5 * (v * v * v * v * v + 1) + p2
	end

	local v = (p * 2 - p4) / p4
	local v2 = p3 * 0.5
	return v2 * v * v * v * v * v + p2 + v2
end

local function InSine(p, p2, p3, p4)
	return -p3 * cos(p / p4 * 1.5707963267948966) + p3 + p2
end

local function OutSine(p, p2, p3, p4)
	return p3 * sin(p / p4 * 1.5707963267948966) + p2
end

local function InOutSine(p, p2, p3, p4)
	return -p3 * 0.5 * (cos(3.141592653589793 * p / p4) - 1) + p2
end

local function OutInSine(p, p2, p3, p4)
	local v = p3 * 0.5
	local v2, v3, v4

	if p < p4 * 0.5 then
		v2 = v * sin(p * 2 / p4 * 1.5707963267948966) + p2

		if not v2 then
			v3 = -v
			v4 = (p * 2 - p4) / p4 * 1.5707963267948966
			return v3 * cos(v4) + 2 * v + p2
		end
	else
		v3 = -v
		v4 = (p * 2 - p4) / p4 * 1.5707963267948966
		return v3 * cos(v4) + 2 * v + p2
	end

	return v2
end

local function InExpo(p, p2, p3, p4)
	return p == 0 and p2 or p3 * 2 ^ (10 * (p / p4 - 1)) + p2 - p3 * 0.001
end

local function OutExpo(p, p2, p3, p4)
	return p == p4 and p2 + p3 or p3 * 1.001 * (1 - 2 ^ (-10 * p / p4)) + p2
end

local function InOutExpo(p, p2, p3, p4)
	local v = p / p4 * 2
	return v == 0 and p2 or v == 2 and p2 + p3 or v < 1 and p3 * 0.5 * 2 ^ (10 * (v - 1)) + p2 - p3 * 0.0005 or p3 * 0.5 * 1.0005 * (2 - 2 ^ (-10 * (v - 1))) + p2
end

local function OutInExpo(p, p2, p3, p4)
	local v = p3 * 0.5
	return p < p4 * 0.5 and (p * 2 == p4 and p2 + v or v * 1.001 * (1 - 2 ^ (-20 * p / p4)) + p2) or p * 2 - p4 == 0 and p2 + v or v * 2 ^ (10 * ((p * 2 - p4) / p4 - 1)) + p2 + v - v * 0.001
end

local function InCirc(p, p2, p3, p4)
	local v = p / p4
	return -p3 * ((1 - v * v) ^ 0.5 - 1) + p2
end

local function OutCirc(p, p2, p3, p4)
	local v = p / p4 - 1
	return p3 * (1 - v * v) ^ 0.5 + p2
end

local function InOutCirc(p, p2, p3, p4)
	local v = p / p4 * 2

	if v < 1 then
		return -p3 * 0.5 * ((1 - v * v) ^ 0.5 - 1) + p2
	end

	local v2 = v - 2
	return p3 * 0.5 * ((1 - v2 * v2) ^ 0.5 + 1) + p2
end

local function OutInCirc(p, p2, p3, p4)
	local v = p3 * 0.5

	if p < p4 * 0.5 then
		local v2 = p * 2 / p4 - 1
		return v * (1 - v2 * v2) ^ 0.5 + p2
	end

	local v2 = (p * 2 - p4) / p4
	return -v * ((1 - v2 * v2) ^ 0.5 - 1) + p2 + v
end

local function InElastic(p, p2, p3, p4, p5, p6)
	local v = p / p4 - 1
	local v2 = p6 or p4 * 0.3
	local v3

	if v == -1 and p2 then
		return p2
	else
		v3 = v == 0 and p2 + p3

		if not v3 then
			local v4, v5, v6, v7, v8

			if p5 and not (p5 < (p3 >= 0 and p3 or 0 - p3)) then
				v4 = p5 * 2 ^ (10 * v)
				v5 = v * p4
				v6 = v2 / 6.283185307179586
				v7 = p3 / p5
				v8 = (v5 - v6 * asin(v7)) * 6.283185307179586 / v2
				return -(v4 * sin(v8)) + p2
			else
				v3 = -(p3 * 2 ^ (10 * v) * sin((v * p4 - v2 * 0.25) * 6.283185307179586 / v2)) + p2

				if not v3 then
					v4 = p5 * 2 ^ (10 * v)
					v5 = v * p4
					v6 = v2 / 6.283185307179586
					v7 = p3 / p5
					v8 = (v5 - v6 * asin(v7)) * 6.283185307179586 / v2
					return -(v4 * sin(v8)) + p2
				end
			end
		end
	end

	return v3
end

local function OutElastic(p, p2, p3, p4, p5, p6)
	local v = p / p4
	local v2 = p6 or p4 * 0.3
	local v3

	if v == 0 and p2 then
		return p2
	else
		v3 = v == 1 and p2 + p3

		if not v3 then
			local v4, v5, v6, v7, v8

			if p5 and not (p5 < (p3 >= 0 and p3 or 0 - p3)) then
				v4 = p5 * 2 ^ (-10 * v)
				v5 = v * p4
				v6 = v2 / 6.283185307179586
				v7 = p3 / p5
				v8 = (v5 - v6 * asin(v7)) * 6.283185307179586 / v2
				return v4 * sin(v8) + p3 + p2
			else
				v3 = p3 * 2 ^ (-10 * v) * sin((v * p4 - v2 * 0.25) * 6.283185307179586 / v2) + p3 + p2

				if not v3 then
					v4 = p5 * 2 ^ (-10 * v)
					v5 = v * p4
					v6 = v2 / 6.283185307179586
					v7 = p3 / p5
					v8 = (v5 - v6 * asin(v7)) * 6.283185307179586 / v2
					return v4 * sin(v8) + p3 + p2
				end
			end
		end
	end

	return v3
end

local function InOutElastic(p, p2, p3, p4, value, p5)
	if p == 0 then
		return p2
	end

	local v = p / p4 * 2 - 1

	if v == 1 then
		return p2 + p3
	end

	local v2 = p5 or p4 * 0.45
	local v3 = value or 0
	local v4

	if v3 and not (v3 < (p3 >= 0 and p3 or 0 - p3)) then
		v4 = v2 / 6.283185307179586 * asin(p3 / v3)
	else
		v4 = v2 * 0.25
		v3 = p3
	end

	if v < 1 then
		return -0.5 * v3 * 2 ^ (10 * v) * sin((v * p4 - v4) * 6.283185307179586 / v2) + p2
	else
		return v3 * 2 ^ (-10 * v) * sin((v * p4 - v4) * 6.283185307179586 / v2) * 0.5 + p3 + p2
	end
end

local function OutInElastic(p, p2, p3, p4, p5, p6)
	if p < p4 * 0.5 then
		return (OutElastic(p * 2, p2, p3 * 0.5, p4, p5, p6))
	end

	return (InElastic(p * 2 - p4, p2 + p3 * 0.5, p3 * 0.5, p4, p5, p6))
end

local function InBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4
	return p3 * v2 * v2 * ((v + 1) * v2 - v) + p2
end

local function OutBack(p, p2, p3, p4, value)
	local v = value or 1.70158
	local v2 = p / p4 - 1
	return p3 * (v2 * v2 * ((v + 1) * v2 + v) + 1) + p2
end

local function InOutBack(p, p2, p3, p4, value)
	local v = (value or 1.70158) * 1.525
	local v2 = p / p4 * 2

	if v2 < 1 then
		return p3 * 0.5 * (v2 * v2 * ((v + 1) * v2 - v)) + p2
	end

	local v3 = v2 - 2
	return p3 * 0.5 * (v3 * v3 * ((v + 1) * v3 + v) + 2) + p2
end

local function OutInBack(p, p2, p3, p4, value)
	local v = p3 * 0.5
	local v2 = value or 1.70158

	if p < p4 * 0.5 then
		local v3 = p * 2 / p4 - 1
		return v * (v3 * v3 * ((v2 + 1) * v3 + v2) + 1) + p2
	end

	local v3 = (p * 2 - p4) / p4
	return v * v3 * v3 * ((v2 + 1) * v3 - v2) + p2 + v
end

local function OutBounce(p, p2, p3, p4)
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

local function InBounce(p, p2, p3, p4)
	return p3 - OutBounce(p4 - p, 0, p3, p4) + p2
end

local function InOutBounce(p, p2, p3, p4)
	if p < p4 * 0.5 then
		return (p3 - OutBounce(p4 - p * 2, 0, p3, p4) + 0) * 0.5 + p2
	else
		return OutBounce(p * 2 - p4, 0, p3, p4) * 0.5 + p3 * 0.5 + p2
	end
end

local function OutInBounce(p, p2, p3, p4)
	if p < p4 * 0.5 then
		return (OutBounce(p * 2, p2, p3 * 0.5, p4))
	end

	local v = p * 2 - p4
	local v2 = p2 + p3 * 0.5
	local v3 = p3 * 0.5
	return v3 - OutBounce(p4 - v, 0, v3, p4) + v2
end

return table.freeze({
	In = table.freeze({
		Linear = Linear,
		Sine = InSine,
		Back = InBack,
		Quad = InQuad,
		Quart = InQuart,
		Quint = InQuint,
		Bounce = InBounce,
		Elastic = InElastic,
		Exponential = InExpo,
		Circular = InCirc,
		Cubic = InCubic,
		Smooth = Smooth,
		Smoother = Smoother,
		RevBack = RevBack,
		RidiculousWiggle = RidiculousWiggle,
		Spring = Spring,
		SoftSpring = SoftSpring
	}),
	Out = table.freeze({
		Linear = Linear,
		Sine = OutSine,
		Back = OutBack,
		Quad = OutQuad,
		Quart = OutQuart,
		Quint = OutQuint,
		Bounce = OutBounce,
		Elastic = OutElastic,
		Exponential = OutExpo,
		Circular = OutCirc,
		Cubic = OutCubic,
		Smooth = Smooth,
		Smoother = Smoother,
		RevBack = RevBack,
		RidiculousWiggle = RidiculousWiggle,
		Spring = Spring,
		SoftSpring = SoftSpring
	}),
	InOut = table.freeze({
		Linear = Linear,
		Sine = InOutSine,
		Back = InOutBack,
		Quad = InOutQuad,
		Quart = InOutQuart,
		Quint = InOutQuint,
		Bounce = InOutBounce,
		Elastic = InOutElastic,
		Exponential = InOutExpo,
		Circular = InOutCirc,
		Cubic = InOutCubic,
		Smooth = Smooth,
		Smoother = Smoother,
		RevBack = RevBack,
		RidiculousWiggle = RidiculousWiggle,
		Spring = Spring,
		SoftSpring = SoftSpring
	}),
	OutIn = table.freeze({
		Linear = Linear,
		Sine = OutInSine,
		Back = OutInBack,
		Quad = OutInQuad,
		Quart = OutInQuart,
		Quint = OutInQuint,
		Bounce = OutInBounce,
		Elastic = OutInElastic,
		Exponential = OutInExpo,
		Circular = OutInCirc,
		Cubic = OutInCubic,
		Smooth = Smooth,
		Smoother = Smoother,
		RevBack = RevBack,
		RidiculousWiggle = RidiculousWiggle,
		Spring = Spring,
		SoftSpring = SoftSpring
	})
})