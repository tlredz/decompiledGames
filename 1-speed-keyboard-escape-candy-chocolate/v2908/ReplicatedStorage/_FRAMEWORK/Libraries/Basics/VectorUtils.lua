local createVector = vector.create
local VectorUtils = {}

function VectorUtils.getVector3FromAngle(p: number, vector2: Vector3)
	local vector3 = not (vector2.Magnitude > 0) and createVector(0, 1, 0) or vector2.Unit
	local vector4 = math.abs((vector3:Dot(createVector(0, 0, 1)))) < 0.999 and createVector(0, 0, 1) or createVector(
		1,
		0,
		0
	)
	local unit = (vector4 - vector3 * vector4:Dot(vector3)).Unit
	local unit2 = vector3:Cross(unit).Unit
	return unit * math.cos(p) + unit2 * math.sin(p)
end

function VectorUtils.rotateVectorAroundY(data, p: number)
	local v = math.cos(p)
	local v2 = math.sin(p)

	if typeof(data) == "Vector2" then
		return Vector2.new(data.X * v + data.Y * v2, -data.X * v2 + data.Y * v)
	end

	return (Vector3.new(data.X * v + data.Z * v2, data.Y, -data.X * v2 + data.Z * v))
end

function VectorUtils.getVectorYAngle(data)
	if typeof(data) == "Vector2" then
		return (math.atan2(data.Y, data.X))
	end

	return (math.atan2(data.Z, data.X))
end

return VectorUtils