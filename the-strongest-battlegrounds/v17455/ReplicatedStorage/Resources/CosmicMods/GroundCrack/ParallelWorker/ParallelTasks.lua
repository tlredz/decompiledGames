local createVector = vector.create
local ParallelTasks = {}

function ParallelTasks.CalculateSurfaceInfo(p, p2)
	local vector2 = -Vector3.FromNormalId(Enum.NormalId.Top)
	local v = math.abs(vector2.y) ~= 1 and createVector(0, 1, 0) or Vector3.new(vector2.y, 0, 0) or createVector(
		0,
		1,
		0
	)
	local v2 = CFrame.fromAxisAngle(v, 1.5707963267948966) * vector2
	local unit = vector2:Cross(v2).Unit
	return
		p * CFrame.fromMatrix(-vector2 * p2 / 2, v2, unit, vector2),
		(Vector2.new((p2 * v2).Magnitude, (p2 * unit).Magnitude))
end

function ParallelTasks.CalculateCameraProperties(p, cframe, p2, _)
	local pointToObjectSpace = cframe:PointToObjectSpace(p.p)
	local v = pointToObjectSpace.x / p2.x
	local v2 = pointToObjectSpace.y / p2.y
	local v3 = math.abs(v) * 2 + 1
	local v4 = math.abs(v2) * 2 + 1
	local v5 = math.sqrt(v3 * v3 + v4 * v4)
	local dot = (p.p - cframe.p):Dot(cframe.LookVector)
	local v6 = math.atan2(p2.y / 2, dot) * 2
	local v7 = math.clamp(math.deg(v6), 1, 120)
	local v8 = dot / (p2.y / 2 / math.tan(math.rad(v7) / 2))
	local v9 = (v6 > 2.0943951023931953 and v8 or 1) / v5
	return v, v2, v5, CFrame.new(0, 0, 0, v9, 0, 0, 0, v9, 0, 0, 0, 1), v7
end

return ParallelTasks