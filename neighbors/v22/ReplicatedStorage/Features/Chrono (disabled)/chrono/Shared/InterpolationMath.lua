local createVector = vector.create
require(script.Parent.Types)
local Config = require(script.Parent.Config)
local InterpolationMath = {}

function InterpolationMath.Hermite(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number, p2: number)
	local v = vector4 or createVector(0, 0, 0)
	local v2 = vector5 or createVector(0, 0, 0)

	if not p2 or p2 == 0 then
		return vector2:Lerp(vector3, p)
	end

	local v3 = p * p
	local v4 = v3 * p
	local v5 = v4 * 2 - v3 * 3 + 1
	local v6 = v4 - v3 * 2 + p
	local v7 = v4 * -2 + v3 * 3
	local v8 = v4 - v3
	return vector2 * v5 + v * p2 * v6 + vector3 * v7 + v2 * p2 * v8
end

function InterpolationMath.VelocityAt(p, p2: number, cframe: CFrame, value: number?)
	if not p then
		return createVector(0, 0, 0)
	end

	local position = p.value.Position
	local t = p.t
	local position2 = cframe.Position
	local v = value or 0.05
	local v2 = p2 - t

	if v2 <= 1e-6 then
		return createVector(0, 0, 0)
	end

	if v * 3 < v2 and Config.FLAGS.SNAPSHOT_INTERPOLATION_FIX then
		v2 = v
	end

	if Config.FLAGS.VELOCITY_CALC_FIX then
		v2 = math.max(v2, v)
	end

	return (position2 - position) / v2
end

function InterpolationMath.CalculateVelocity(vector2: Vector3, p: number, vector3: Vector3, p2: number, value: number?)
	local v = value or 0.05
	local v2 = p2 - p

	if v2 <= 1e-6 then
		return createVector(0, 0, 0)
	end

	if v * 3 < v2 and Config.FLAGS.SNAPSHOT_INTERPOLATION_FIX then
		v2 = v
	end

	if Config.FLAGS.VELOCITY_CALC_FIX then
		v2 = math.max(v2, v)
	end

	return (vector3 - vector2) / v2
end

return InterpolationMath