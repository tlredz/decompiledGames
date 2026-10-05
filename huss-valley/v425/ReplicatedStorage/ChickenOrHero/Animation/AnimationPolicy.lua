local AnimationPolicy = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - 2 * v)
end

function AnimationPolicy.angle(p, vector)
	if p.Magnitude < 0.01 or vector.Magnitude < 0.01 then
		return 0
	end

	return (math.deg((math.atan2(vector:Cross(p).Y, (vector:Dot(p))))))
end

function AnimationPolicy.poseScale(p)
	local v = math.clamp((math.abs(p) - 90) / 45, 0, 1)
	return 1 - v * v * (3 - 2 * v)
end

function AnimationPolicy.weights(p, p2, p3, p4)
	local v = math.abs(p2)
	local v2 = math.max(0, v - (v <= 90 and v or 180 - v) * AnimationPolicy.poseScale(p2))
	local v3 = smooth((v2 - 90) / 90) -- equivalent call inferred; original call site unknown
	local v4

	if v2 <= 90 then
		v4 = smooth(v2 / 90)

		if not v4 then
			v4 = 1 - v3
		end
	else
		v4 = 1 - v3
	end

	local v5 = math.max(0, 1 - v4 - v3)
	local v6 = smooth((p - 0.2) / 1.8) -- equivalent call inferred; original call site unknown
	local v7 = smooth((p / p3 - p4.RunBlendStart) / (p4.RunBlendEnd - p4.RunBlendStart)) -- equivalent call inferred; original call site unknown
	return {
		Idle = 1 - v6,
		Walk = v6 * v5 * (1 - v7),
		Run = v6 * v5 * v7,
		Left = not (p2 >= 0) and 0 or v6 * v4 or 0,
		Right = not (p2 < 0) and 0 or v6 * v4 or 0,
		Back = v6 * v3
	}
end

return AnimationPolicy