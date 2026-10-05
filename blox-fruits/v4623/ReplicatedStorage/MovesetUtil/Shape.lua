local Shape = {}

function Shape.posInCylinder(vector: Vector3, vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local unit = vector3.Unit
	return (vector - (vector2 + math.clamp(unit:Dot(vector - vector2) / p2, 0, 1) * unit * p2)).Magnitude < p
end

function Shape.posInCone(vector: Vector3, vector2: Vector3, vector3: Vector3, p: number, p2: number, value: number?)
	local unit = vector3.Unit
	local v = math.clamp(unit:Dot(vector - vector2) / p2, 0, 1)
	local v2 = vector2 + v * unit * p2
	local v3 = v * p
	return (vector - v2).Magnitude < v3 + (value or 0) / 2
end

function Shape.cylinderCFrame(vector: Vector3, vector2: Vector3, p: number)
	return CFrame.new(vector, vector + vector2) * CFrame.new(0, 0, -p / 2)
end

return Shape