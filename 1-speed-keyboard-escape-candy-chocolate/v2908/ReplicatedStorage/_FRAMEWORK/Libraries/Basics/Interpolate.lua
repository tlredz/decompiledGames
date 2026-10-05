local function lerp(p, p2, p3: number)
	local typeName = typeof(p)
	assert(typeName == typeof(p2), "p0 and p1 must have the same type")

	if typeName == "number" then
		return (math.lerp(p, p2, p3))
	elseif typeName == "CFrame" then
		return p:Lerp(p2, p3)
	elseif typeName == "Color3" then
		return p:Lerp(p2, p3)
	elseif typeName == "NumberRange" then
		return NumberRange.new(math.lerp(p.Min, p2.Min, p3), (math.lerp(p.Max, p2.Max, p3)))
	elseif typeName == "Vector2" then
		return p:Lerp(p2, p3)
	elseif typeName == "Vector3" then
		return p:Lerp(p2, p3)
	elseif typeName == "UDim2" then
		return p:Lerp(p2, p3)
	end

	error((`Unsupported interpolation type: {typeName}`))
end

local function clampedLerp(p, p2, value: number)
	return lerp(p, p2, math.clamp(value, 0, 1))
end

local function bezier(p, p2, p3, p4: number)
	return lerp(lerp(p, p2, p4), lerp(p2, p3, p4), p4)
end

local Interpolate = {}
Interpolate.lerp = lerp
Interpolate.clampedLerp = clampedLerp

function Interpolate.preciseLerp(p, p2, p3: number, p4: number)
	assert(p4 > 0, "duration must be greater than zero")
	return lerp(p, p2, 1 - math.pow(0.01, p3 / p4))
end

function Interpolate.clampedPreciseLerp(p, p2, p3: number, p4: number)
	assert(p4 > 0, "duration must be greater than zero")
	return clampedLerp(p, p2, 1 - math.pow(0.01, p3 / p4))
end

Interpolate.bezier = bezier

function Interpolate.cubicBezier(p, p2, p3, p4, p5: number)
	return bezier(lerp(p, p2, p5), lerp(p2, p3, p5), lerp(p3, p4, p5), p5)
end

function Interpolate.easeCubicBezier(p: number, p2: number, p3: number, p4: number, p5: number)
	if p5 <= 0 or p5 >= 1 then
		return p5
	end

	local zero = Vector2.zero
	local vector = Vector2.new(p, p2)
	local vector2 = Vector2.new(p3, p4)
	local one = Vector2.one
	local v = lerp(zero, vector, p5)
	local v2 = lerp(vector, vector2, p5)
	local v3 = lerp(vector2, one, p5)
	return lerp(lerp(v, v2, p5), lerp(v2, v3, p5), p5).Y
end

function Interpolate.getAlphaInRange(p: number, p2: number, p3: number)
	assert(p ~= p2, "rangeStart and rangeEnd must be different")

	if p < p2 then
		return (math.clamp((p3 - p) / (p2 - p), 0, 1))
	end

	return (math.clamp((p - p3) / (p - p2), 0, 1))
end

function Interpolate.moveTowards(p: number, p2: number, p3: number)
	assert(p3 >= 0, "maxDelta cannot be negative")
	local v = p2 - p

	if math.abs(v) <= p3 then
		return p2
	end

	return p + math.sign(v) * p3
end

return Interpolate