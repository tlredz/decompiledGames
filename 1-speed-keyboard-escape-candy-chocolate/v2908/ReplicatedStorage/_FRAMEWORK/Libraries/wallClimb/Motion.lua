require(script.Parent.Types)
local Motion = {
	resolveBoostSpeed = function(p: number, p2: number, data, p3)
		local v = math.max(p, 0) * data.heightBoostRatio * p3.boostMultiplier
		local v2 = math.max(math.sqrt(p2 * 2 * v), data.minBoostSpeed)

		if data.maxBoostSpeed > 0 then
			return (math.min(v2, data.maxBoostSpeed))
		end

		return v2
	end
}

function Motion.computeBoost(p: number, p2: number, vector: Vector3, p3, p4)
	return vector * Motion.resolveBoostSpeed(p, p2, p4, p3) + p3.normal * p4.wallPushSpeed
end

function Motion.absorbImpact(vector: Vector3, vector2: Vector3, p: number, p2: number, p3: number)
	local v = -vector:Dot(vector2)
	local v2 = v * p3 - math.max(p - p2, 0)

	if v > 0 and v2 > 0 then
		return vector + vector2 * (v2 / p3)
	end

	return vector
end

return Motion