local Util = {}

function Util.getTriangleArea(vector: Vector3, vector2: Vector3, vector3: Vector3)
	return 0.5 * (vector2 - vector):Cross(vector3 - vector).Magnitude
end

function Util.getGuiPosition(p: number, p2: number, rect: Rect, point: Vector2, flag: boolean?)
	local v = (Vector3.new(p, 0, p2) - Vector3.new(rect.Min.X, 0, rect.Min.Y)) / Vector3.new(rect.Width, 1, rect.Height)
	local v2 = math.round(v.X * point.X)
	local v3 = math.round(v.Z * point.Y)

	if flag then
		return (UDim2.fromOffset(math.clamp(v2, 0, point.X), (math.clamp(v3, 0, point.Y))))
	end

	return (UDim2.fromOffset(v2, v3))
end

function Util.getGlobalVector3FromUDim2(udim: UDim2, rect: Rect, point: Vector2)
	return Vector3.new(rect.Min.X, 0, rect.Min.Y) + Vector3.new(
		rect.Width * (udim.X.Scale + udim.X.Offset / point.X),
		0,
		rect.Height * (udim.Y.Scale + udim.Y.Offset / point.Y)
	)
end

return Util