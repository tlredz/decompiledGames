local Bounds = {
	ClampTopLeft = function(point: Vector2, point2: Vector2, point3: Vector2)
		local v = math.min(4, math.max(0, point3.X - point2.X) / 2)
		local v2 = math.min(4, math.max(0, point3.Y - point2.Y) / 2)
		local v3 = math.max(v, point3.X - point2.X - 4)
		local v4 = math.max(v2, point3.Y - point2.Y - 4)
		return Vector2.new(math.clamp(point.X, v, v3), (math.clamp(point.Y, v2, v4)))
	end
}

function Bounds.ClampCentre(point: Vector2, point2: Vector2, point3: Vector2)
	return Bounds.ClampTopLeft(point - point2 * 0.5, point2, point3) + point2 * 0.5
end

function Bounds.ClampCornerOffset(point: Vector2, point2: Vector2, point3: Vector2)
	return Bounds.ClampTopLeft(point3 + point - point2, point2, point3) + point2 - point3
end

return Bounds