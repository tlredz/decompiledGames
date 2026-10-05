local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

local function ClosestPointFunc(p, p2, p3)
	local magnitude = (p - p3).Magnitude
	local safeUnit = SafeUnit(p3 - p) -- equivalent call inferred; original call site unknown
	return magnitude <= p2, p + safeUnit * p2, safeUnit
end

return function(p, data, p2, p3)
	local position = p.Position
	local v = math.min(data.X, data.Y, data.Z) * 0.5
	local magnitude = (position - p2).Magnitude
	local safeUnit = SafeUnit(p2 - position) -- equivalent call inferred; original call site unknown
	local selected = magnitude <= v
	local v5 = position + safeUnit * v

	if selected then
		return selected, v5, safeUnit
	end

	return (v5 - p2).Magnitude < p3, v5, safeUnit
end