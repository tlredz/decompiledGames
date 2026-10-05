local Bezier = {}

function Bezier.quadratic(p: number, vector: Vector3, vector2: Vector3, vector3: Vector3)
	return (1 - p) ^ 2 * vector + (1 - p) * 2 * p * vector2 + p ^ 2 * vector3
end

function Bezier.quadraticVec2(p: number, point: Vector2, point2: Vector2, point3: Vector2)
	return (1 - p) ^ 2 * point + (1 - p) * 2 * p * point2 + p ^ 2 * point3
end

return Bezier