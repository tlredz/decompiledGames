local createVector = vector.create

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function f(p: number)
	if p >= 0.0031308 then
		return p ^ 0.4166666666666667 * 1.055 - 0.055
	end

	return p * 12.92
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function fInv(p: number)
	if p >= 0.04045 then
		return ((p + 0.055) / 1.055) ^ 2.4
	end

	return p / 12.92
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cbrt(p: number)
	if p >= 0 then
		return p ^ 0.3333333333333333
	end

	return -(-p) ^ 0.3333333333333333
end

local Oklab = {}

function Oklab.fromSRGB(vector2: Vector3)
	local v = fInv(vector2.x)
	local v2 = fInv(vector2.y)
	local v3 = fInv(vector2.z)
	local vector3 = vector.create(v, v2, v3)
	local v5 = cbrt(vector.dot(createVector(0.41222146, 0.53633255, 0.051445995), vector3))
	local v7 = cbrt(vector.dot(createVector(0.2119035, 0.6806995, 0.10739696), vector3))
	local v9 = cbrt(vector.dot(createVector(0.08830246, 0.28171885, 0.6299787), vector3))
	local vector4 = vector.create(v5, v7, v9)
	return (vector.create(
		vector.dot(createVector(0.21045426, 0.7936178, -0.004072047), vector4),
		vector.dot(createVector(1.9779985, -2.4285922, 0.4505937), vector4),
		(vector.dot(createVector(0.025904037, 0.78277177, -0.80867577), vector4))
	))
end

function Oklab.toSRGB(vector2: Vector3)
	local vector3 = vector.create(
		vector.dot(createVector(1, 0.39633778, 0.21580376), vector2),
		vector.dot(createVector(1, -0.105561346, -0.06385417), vector2),
		(vector.dot(createVector(1, -0.08948418, -1.2914855), vector2))
	)
	local v = vector3 * vector3 * vector3
	local vector4 = vector.create(
		vector.dot(createVector(4.0767417, -3.3077116, 0.23096994), v),
		vector.dot(createVector(-1.268438, 2.6097574, -0.34131938), v),
		(vector.dot(createVector(-0.0041960864, -0.7034186, 1.7076147), v))
	)
	local v2 = f(vector4.x)
	local v3 = f(vector4.y)
	local v4 = f(vector4.z)
	return (vector.create(v2, v3, v4))
end

return Oklab