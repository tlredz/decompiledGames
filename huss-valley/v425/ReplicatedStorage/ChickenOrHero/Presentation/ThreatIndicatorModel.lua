local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function flat(p)
	return (Vector3.new(p.X, 0, p.Z))
end

local ThreatIndicatorModel = {}

function ThreatIndicatorModel.sample(p, p2, p3, p4, p5, data)
	if math.abs(p4.Y - p.Y) > data.MaxHeightDifference then
		return nil
	end

	local v2 = flat(p4 - p) -- equivalent call inferred; original call site unknown
	local magnitude = v2.Magnitude
	local v3 = flat(p3) -- equivalent call inferred; original call site unknown

	if magnitude < 0.05 or data.MaxDistance <= magnitude or v3.Magnitude < 0.01 then
		return nil
	end

	local unit = v3.Unit
	local unit2 = v2.Unit
	local dot = (Vector3.new(p2.X, 0, p2.Z) - Vector3.new(p5.X, 0, p5.Z)):Dot(unit2)

	if data.NearDistance < magnitude and dot < data.MinClosingSpeed then
		return nil
	end

	local strength = math.clamp(1 - (magnitude - data.NearDistance) / (data.MaxDistance - data.NearDistance), 0, 1) * 0.8 + 0.2
	return {
		angle = math.atan2(unit2:Dot(unit:Cross(createVector(0, 1, 0))), (unit2:Dot(unit))),
		strength = strength,
		distance = magnitude
	}
end

function ThreatIndicatorModel.sector(p, items, p2)
	local v = 0

	for _, item in items do
		local v2 = math.abs((math.atan2(math.sin(p - item.angle), (math.cos(p - item.angle)))))

		if v2 < p2 then
			v = math.max(v, item.strength * (1 - v2 / p2))
		end
	end

	return v
end

return ThreatIndicatorModel