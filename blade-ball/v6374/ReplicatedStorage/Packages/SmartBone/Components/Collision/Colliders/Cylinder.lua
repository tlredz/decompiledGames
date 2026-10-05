local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

local function solve(p, p2, max, p3)
	local v = math.clamp((p3 - p):Dot(p2), -max, max)
	return p + p2 * v, v
end

local function ProjectOnPlane(p, p2, p3)
	return p3 - (p3 - p):Dot(p2) * p2
end

local function ClosestPointFunc(p, data, p2)
	local v = (data.Y < data.Z and data.Y or data.Z) * 0.5
	local v2 = data.X * 0.5
	local position = p.Position
	local rightVector = p.RightVector
	local v3 = math.clamp((p2 - position):Dot(rightVector), -v2, v2)
	local v4 = position + rightVector * v3
	local v5 = p.Position + -p.RightVector * v2
	local v6 = p.Position + p.RightVector * v2
	local v7 = -p.RightVector
	local rightVector2 = p.RightVector
	local v8 = p2 - (p2 - v5):Dot(v7) * v7
	local v9 = p2 - (p2 - v6):Dot(rightVector2) * rightVector2

	local function GetFinalProj(p3, p4)
		local safeUnit = SafeUnit(p3 - p4) -- equivalent call inferred; original call site unknown
		local magnitude = (p3 - p4).Magnitude
		return p4 + safeUnit * (magnitude < v and magnitude or v)
	end

	local safeUnit2 = SafeUnit(v8 - v5) -- equivalent call inferred; original call site unknown
	local magnitude = (v8 - v5).Magnitude
	local v12

	if magnitude < v then
		v12 = magnitude or v
	else
		v12 = v
	end

	local v13 = v5 + safeUnit2 * v12
	local safeUnit3 = SafeUnit(v9 - v6) -- equivalent call inferred; original call site unknown
	local magnitude2 = (v9 - v6).Magnitude
	local v16

	if magnitude2 < v then
		v16 = magnitude2 or v
	else
		v16 = v
	end

	local v17 = v6 + safeUnit3 * v16
	local magnitude3 = (v4 - p2).Magnitude
	local safeUnit4 = SafeUnit(p2 - v4) -- equivalent call inferred; original call site unknown
	local v20 = magnitude3 <= v
	local v21 = v4 + safeUnit4 * v
	local magnitude4 = (v17 - p2).Magnitude
	local magnitude5 = (v13 - p2).Magnitude
	local v22 = math.min(magnitude4, magnitude5, (v21 - p2).Magnitude)

	if v3 == v2 or v22 == magnitude4 then
		return (SafeUnit(p2 - v17)):Dot(rightVector2) < 0, v17, rightVector2
	end

	if v3 ~= -v2 and v22 ~= magnitude5 then
		return v20, v21, safeUnit4
	end

	return (SafeUnit(p2 - v13)):Dot(v7) < 0, v13, v7
end

return function(p, p2, p3, p4)
	local v, v2, v3 = ClosestPointFunc(p, p2, p3)

	if v then
		return v, v2, v3
	end

	return (v2 - p3).Magnitude < p4, v2, v3
end