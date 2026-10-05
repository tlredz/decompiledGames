local function SafeCast(vector: Vector3, vector2: Vector3, p: number, p2)
	local X = vector.X
	local Y = vector.Y
	local Z = vector.Z
	local v = vector2.X - X
	local v2 = vector2.Y - Y
	local v3 = vector2.Z - Z
	local v4 = math.sqrt(v * v + v2 * v2 + v3 * v3)

	if v4 == 0 then
		return nil
	end

	local v5, raycastResult

	if p > 0 then
		v5 = 0.15
		raycastResult = workspace:Spherecast(
			Vector3.new(X - v * v5 / v4, Y - v2 * v5 / v4, Z - v3 * v5 / v4),
			p,
			Vector3.new(v * (v4 + v5) / v4, v2 * (v4 + v5) / v4, v3 * (v4 + v5) / v4),
			p2
		)
	else
		v5 = 0.001
		raycastResult = workspace:Raycast(
			Vector3.new(X - v * v5 / v4, Y - v2 * v5 / v4, Z - v3 * v5 / v4),
			Vector3.new(v * (v4 + v5) / v4, v2 * (v4 + v5) / v4, v3 * (v4 + v5) / v4),
			p2
		)
	end

	if not raycastResult then
		return nil
	end

	local alpha = math.clamp((raycastResult.Distance - v5) / v4, 0, 1)
	return {
		Alpha = alpha,
		Instance = raycastResult.Instance,
		Material = raycastResult.Material,
		Position = raycastResult.Position,
		Normal = raycastResult.Normal,
		Ending = Vector3.new(X + v * alpha, Y + v2 * alpha, Z + v3 * alpha)
	}
end

return SafeCast