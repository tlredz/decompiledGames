local createVector = vector.create
local ContactCatchGeometry = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function flat(p)
	return (Vector3.new(p.X, 0, p.Z))
end

function ContactCatchGeometry.inReach(p, p2, p3, data)
	local v = p3 - p
	local v2 = flat(v) -- equivalent call inferred; original call site unknown
	local v3 = flat(p2) -- equivalent call inferred; original call site unknown
	return math.abs(v.Y) <= data.Height and v2.Magnitude <= data.ReachDistance and v2.Magnitude > 0.01 and v3.Magnitude > 0.01 and v3.Unit:Dot(v2.Unit) >= math.cos((math.rad(data.ReachHalfAngle)))
end

function ContactCatchGeometry.commitDistance(p, p2, p3, data)
	local v = flat(p) -- equivalent call inferred; original call site unknown
	local v2

	if v.Magnitude > 0.01 then
		local v3 = p2 or createVector(0, 0, 0)
		local v4 = p3 or createVector(0, 0, 0)
		v2 = math.clamp(
			(Vector3.new(v3.X, 0, v3.Z) - Vector3.new(v4.X, 0, v4.Z)):Dot(v.Unit),
			0,
			(data.MaxObservedSpeed or 90) * 2
		)
	else
		v2 = 0
	end

	return (math.min(
		data.CommitDistance,
		(data.CommitBaseDistance or data.HandRadius) + v2 * (data.CommitLeadTime or 0)
	))
end

function ContactCatchGeometry.steer(p, p2, p3, value, data)
	local DISTANCE_EPSILON = 0.01
	local v = flat(p) -- equivalent call inferred; original call site unknown
	local v2 = flat(p2) -- equivalent call inferred; original call site unknown
	local v3 = flat(p3) -- equivalent call inferred; original call site unknown

	if v.Magnitude < DISTANCE_EPSILON or v2.Magnitude < DISTANCE_EPSILON or v3.Magnitude < DISTANCE_EPSILON then
		return p2
	end

	local unit = v.Unit
	local unit2 = v2.Unit
	local unit3 = v3.Unit
	local v4 = math.atan2(unit:Cross(unit3).Y, (unit:Dot(unit3)))
	local v5 = CFrame.fromAxisAngle(
		createVector(0, 1, 0),
		(math.clamp(v4, -math.rad(data.WindupAimLimit), (math.rad(data.WindupAimLimit))))
	) * unit
	local v6 = math.atan2(unit2:Cross(v5).Y, (unit2:Dot(v5)))
	local v7 = math.rad(data.WindupAimRate) * math.clamp(value, 0, data.Windup)
	return CFrame.fromAxisAngle(createVector(0, 1, 0), (math.clamp(v6, -v7, v7))) * unit2
end

function ContactCatchGeometry.canCommit(p, p2, p3, p4, p5, p6)
	local v2 = flat(p3 - p) -- equivalent call inferred; original call site unknown
	local v3 = flat(p2) -- equivalent call inferred; original call site unknown
	return v2.Magnitude > 0.01 and v2.Magnitude <= ContactCatchGeometry.commitDistance(v2, p5, p6, p4) and math.abs(p3.Y - p.Y) <= p4.Height and v3.Magnitude > 0.01 and v3.Unit:Dot(v2.Unit) >= math.cos((math.rad(p4.CommitHalfAngle)))
end

local HitReplayMath = require(script.Parent.HitReplayMath)

function ContactCatchGeometry.contains(p, p2, p3, p4)
	return HitReplayMath.sweep(p, p, p3, p3, p2, HitReplayMath.bounds("Melee", p4))
end

function ContactCatchGeometry.sweep(p, p2, p3, p4, p5, p6)
	return HitReplayMath.sweep(p, p2, p3, p4, p5, HitReplayMath.bounds("Melee", p6))
end

return ContactCatchGeometry