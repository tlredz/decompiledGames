local v = {
	FallSeconds = 0.55,
	BounceSeconds = 0.4,
	MagnetDelay = 1.02,
	MagnetSeconds = 0.52
}

function v.GroundPosition(vector: Vector3, vector2: Vector3, p: number)
	local v2 = math.clamp(p / v.FallSeconds, 0, 1)

	if v2 < 1 then
		return vector:Lerp(vector2, v2) + Vector3.new(0, v2 * 4 * (1 - v2) * 2, 0)
	end

	local v3 = math.clamp((p - v.FallSeconds) / v.BounceSeconds, 0, 1)
	return vector2 + Vector3.new(0, math.abs((math.sin(v3 * 3.141592653589793 * 2))) * (1 - v3) ^ 2 * 1.1, 0)
end

function v.MagnetPosition(vector: Vector3, vector2: Vector3, value: number)
	local v2 = math.clamp(value, 0, 1)
	return vector:Lerp(vector2, v2 * v2) + Vector3.new(0, math.sin(v2 * 3.141592653589793) ^ 2 * 0.65, 0)
end

return table.freeze(v)