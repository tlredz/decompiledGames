local SpearThrustGeometry = {
	SHEATHED_GAP = -0.1,
	SHEATHED_FORWARD_OFFSET = 1,
	SHEATHED_TILT_DEGREES = 20,
	screenRight = function(point: Vector2)
		return Vector2.new(-point.Y, point.X)
	end
}

function SpearThrustGeometry.resolvePose(point: Vector2, unit: Vector2, p: number, p2: number, p3: number, value: number)
	local screenRight = SpearThrustGeometry.screenRight(unit)
	local SHEATHED_TILT_DEGREES = math.rad(SpearThrustGeometry.SHEATHED_TILT_DEGREES)
	local SHEATHED_FORWARD_OFFSET = SpearThrustGeometry.SHEATHED_FORWARD_OFFSET
	local v = p + p3 * 0.5 + SpearThrustGeometry.SHEATHED_GAP
	local v2 = unit * math.cos(SHEATHED_TILT_DEGREES) - screenRight * math.sin(SHEATHED_TILT_DEGREES)
	local v3 = point + unit * SHEATHED_FORWARD_OFFSET + screenRight * ((v - SHEATHED_FORWARD_OFFSET * math.sin(SHEATHED_TILT_DEGREES)) / math.cos(SHEATHED_TILT_DEGREES))
	local v4 = point + unit * (p + p2 * 0.5)
	local v5 = math.clamp(value, 0, 1)
	local lerped = v3:Lerp(v4, v5)
	local lerped2 = v2:Lerp(unit, v5)

	if lerped2.Magnitude > 1e-6 then
		unit = lerped2.Unit
	end

	return lerped, unit
end

function SpearThrustGeometry.resolveSegment(point: Vector2, point2: Vector2, p: number, p2: number, p3: number, p4: number)
	local pose, v = SpearThrustGeometry.resolvePose(point, point2, p, p2, p3, p4)
	local v2 = v * (p2 * 0.5)
	return pose - v2, pose + v2
end

return SpearThrustGeometry