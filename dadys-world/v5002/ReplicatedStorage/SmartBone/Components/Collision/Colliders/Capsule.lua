local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function solve(position, upVector, max, p)
	return position + upVector * math.clamp((p - position):Dot(upVector), -max, max)
end

local function ClosestPointFunc(p, p2, p3, p4)
	local v2 = solve(p.Position, p.UpVector, p2 * 0.5, p4) -- equivalent call inferred; original call site unknown
	local magnitude = (v2 - p4).Magnitude
	local safeUnit = SafeUnit(p4 - v2) -- equivalent call inferred; original call site unknown
	return magnitude <= p3, v2 + safeUnit * p3, safeUnit
end

return function(p, data, p2, p3)
	local v = (data.Y < data.Z and data.Y or data.Z) * 0.5
	local X = data.X
	local v2 = p * CFrame.Angles(1.5707963267948966, -1.5707963267948966, 0)
	local v4 = solve(v2.Position, v2.UpVector, X * 0.5, p2) -- equivalent call inferred; original call site unknown
	local magnitude = (v4 - p2).Magnitude
	local safeUnit = SafeUnit(p2 - v4) -- equivalent call inferred; original call site unknown
	local selected = magnitude <= v
	local v8 = v4 + safeUnit * v

	if selected then
		return selected, v8, safeUnit
	end

	return (v8 - p2).Magnitude < p3, v8, safeUnit
end