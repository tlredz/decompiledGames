local createVector = vector.create
local dot = Vector3.new().Dot
local cross = Vector3.new().Cross
local clamp = math.clamp

-- equivalent calls inferred from this helper; original call sites unknown
local function SafeUnit(p)
	if p.Magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClosestPointOnLineSegment(p, p2, p3)
	local v = p2 - p
	return p + clamp(dot(p3 - p, v) / dot(v, v), 0, 1) * v
end

local function ProjectOnPlane(p, p2, p3)
	return p3 - (p3 - p):Dot(p2) * p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SameSide(p, p2, p3, p4)
	return dot(cross(p4 - p3, p - p3), (cross(p4 - p3, p2 - p3))) >= 0
end

local function PointInTriangle(p, p2, p3, p4)
	if SameSide(p, p2, p3, p4) and SameSide(p, p3, p2, p4) and SameSide(p, p4, p2, p3) then
		return true
	end

	return false
end

local function ClosestPointOnTri(p, p2, p3, p4)
	local closestPointOnLineSegment = ClosestPointOnLineSegment(p, p2, p4) -- equivalent call inferred; original call site unknown
	local closestPointOnLineSegment2 = ClosestPointOnLineSegment(p2, p3, p4) -- equivalent call inferred; original call site unknown
	local closestPointOnLineSegment3 = ClosestPointOnLineSegment(p3, p, p4) -- equivalent call inferred; original call site unknown
	local safeUnit = SafeUnit(cross(p2 - p, p3 - p)) -- equivalent call inferred; original call site unknown
	local v6 = p4 - (p4 - (p + p2 + p3) * 0.3333):Dot(safeUnit) * safeUnit
	local v9

	if dot(cross(p3 - p2, p4 - p2), (cross(p3 - p2, p - p2))) >= 0 then
		if SameSide(p4, p2, p, p3) then
			v9 = SameSide(p4, p3, p, p2)
		else
			v9 = false
		end
	else
		v9 = false
	end

	if v9 then
		return v6, safeUnit
	end

	local magnitude = (closestPointOnLineSegment - p4).Magnitude
	local magnitude2 = (closestPointOnLineSegment2 - p4).Magnitude
	local magnitude3 = (closestPointOnLineSegment3 - p4).Magnitude
	local v10 = math.min(magnitude, magnitude2, magnitude3)

	if v10 == magnitude then
		return closestPointOnLineSegment, safeUnit
	end

	if v10 == magnitude2 then
		return closestPointOnLineSegment2, safeUnit
	end

	if v10 == magnitude3 then
		return closestPointOnLineSegment3, safeUnit
	end

	return p4, safeUnit
end

return ClosestPointOnTri