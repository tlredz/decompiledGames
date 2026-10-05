local createVector = vector.create
local v = {
	createVector(-0.1, 19.9, -35.1),
	createVector(-1, 20.4, -34.3),
	createVector(-1.7, 20, -34.5),
	createVector(-2.2, 19.5, -34.9),
	createVector(-2.3, 19.5, -35.3),
	createVector(-2.1, 20.1, -35.6),
	createVector(-1.9, 20.9, -35.9),
	createVector(0.7, 24, -36.3),
	createVector(6.1, 29.5, -35.6),
	createVector(12.5, 35.2, -32.6),
	createVector(18.8, 40.2, -26.8),
	createVector(24.3, 43.8, -18.3),
	createVector(28.2, 45.8, -7.2),
	createVector(29.4, 45.7, 5.4),
	createVector(26.7, 43.7, 18.1),
	createVector(20.1, 40.8, 28.7),
	createVector(10.2, 37.8, 35.4),
	createVector(1.5, 35.6, 37.8),
	createVector(-1.1, 34.5, 37.9),
	createVector(-0.4, 34.5, 37.4),
	createVector(3.9, 37.9, 35.4),
	createVector(9.6, 50.3, 26.3),
	createVector(6.3, 63, 2.6),
	createVector(-6.6, 54.8, -23.2),
	createVector(-26.6, 26.8, -24.8)
}
local ScrambleBossHazards = {
	BodyRadius = 1.6
}

-- equivalent calls inferred from this helper; original call sites unknown
local function flat(vector2: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z))
end

function ScrambleBossHazards.ActiveSeconds(data)
	if data.Kind == "Ring" then
		return (data.Radius or 0) / math.max(data.Speed or 1, 1)
	end

	if data.Kind == "Line" then
		return (data.Travel or 0) / math.max(data.Speed or 1, 1)
	end

	return data.Duration or 0.25
end

function ScrambleBossHazards.Dodgeable(p)
	return p.Kind == "Ring" or p.Kind == "Line" or p.Kind == "Sweep" or p.Kind == "Beam"
end

function ScrambleBossHazards.BeamProgress(p, value: number)
	local v2 = math.max(p.Duration or 1, 0.05)
	local v3 = math.clamp(value, 0, v2)

	if p.Ramp == nil then
		local v4 = v3 / v2
		return v4 * v4 * (3 - v4 * 2)
	end

	local v4 = math.clamp(p.Ramp, 0.01, v2 / 2)
	local v5 = 1 / (v2 - v4)

	if v3 < v4 then
		return v5 * v3 * v3 / (v4 * 2)
	end

	if v2 - v4 < v3 then
		local v6 = v2 - v3
		return 1 - v5 * v6 * v6 / (v4 * 2)
	else
		return v5 * (v3 - v4 / 2)
	end
end

function ScrambleBossHazards.BeamHeading(p, p2: number)
	local direction = p.Direction or createVector(0, 0, 1)
	local unit = Vector3.new(direction.X, 0, direction.Z).Unit
	local beamProgress = ScrambleBossHazards.BeamProgress(p, p2)
	return CFrame.Angles(0, math.rad(p.Angle or 0) * beamProgress, 0) * unit
end

function ScrambleBossHazards.RingRadius(p, p2: number)
	return (math.min((p.Speed or 0) * math.max(p2, 0), p.Radius or 0))
end

function ScrambleBossHazards.LineOffset(p, p2: number)
	return (math.min((p.Speed or 0) * math.max(p2, 0), p.Travel or 0))
end

function ScrambleBossHazards.Contains(data, p: number, vector2: Vector3, flag: boolean, p2: number)
	if p < 0 or ScrambleBossHazards.ActiveSeconds(data) < p or flag and ScrambleBossHazards.Dodgeable(data) then
		return false
	end

	local vector3 = flat(vector2 - data.Origin) -- equivalent call inferred; original call site unknown
	local magnitude = vector3.Magnitude
	local v3 = p2 + 1.6

	if data.Kind == "Ring" then
		return math.abs(magnitude - ScrambleBossHazards.RingRadius(data, p)) <= (data.Width or 2) / 2 + v3
	end

	if data.Kind == "Line" then
		local direction = data.Direction or createVector(0, 0, 1)
		local unit = Vector3.new(direction.X, 0, direction.Z).Unit
		local cross = unit:Cross(createVector(0, 1, 0))
		local dot = vector3:Dot(unit)
		local v4 = math.abs((vector3:Dot(cross)))
		return math.abs(dot - ScrambleBossHazards.LineOffset(data, p)) <= (data.Width or 2) / 2 + v3 and v4 <= (data.Length or 0) / 2 + v3
	else
		if data.Kind == "Strike" or data.Kind == "Missile" or data.Kind == "Puddle" or data.Kind == "Grab" or data.Kind == "Sweep" or data.Kind == "Blast" then
			return magnitude <= (data.Radius or 0) + v3
		end

		if data.Kind == "Lane" then
			local direction = data.Direction or createVector(0, 0, 1)
			local unit = Vector3.new(direction.X, 0, direction.Z).Unit
			local cross = unit:Cross(createVector(0, 1, 0))
			local dot = vector3:Dot(unit)
			return -v3 <= dot and dot <= (data.Length or 0) + v3 and math.abs((vector3:Dot(cross))) <= (data.Width or 0) / 2 + v3
		elseif data.Kind == "Beam" then
			local vector4 = ScrambleBossHazards.BeamHeading(data, p)
			local dot = vector3:Dot(vector4)
			return -v3 <= dot and dot <= (data.Length or 0) + v3 and math.abs((vector3:Dot(vector4:Cross(createVector(
				0,
				1,
				0
			))))) <= (data.Width or 0) / 2 + v3
		elseif data.Kind == "Pillars" then
			for _, v4 in data.Points or {} do
				local v5 = vector2 - v4

				if Vector3.new(v5.X, 0, v5.Z).Magnitude <= (data.Radius or 0) + v3 then
					return true
				end
			end

			return false
		else
			if data.Kind ~= "Cone" or (data.Radius or 0) + v3 < magnitude then
				return false
			end

			if magnitude < 4 then
				return true
			end

			local direction = data.Direction or createVector(0, 0, 1)
			local unit = Vector3.new(direction.X, 0, direction.Z).Unit
			local v4 = math.clamp(vector3.Unit:Dot(unit), -1, 1)
			return math.rad((data.Angle or 60) / 2) + math.atan2(v3, magnitude) >= math.acos(v4)
		end
	end
end

function ScrambleBossHazards.ClawAt(p: number)
	local v2 = math.clamp((p - 0.8125) / 0.0625, 0, #v - 1)
	local v3 = math.floor(v2)
	return v[v3 + 1]:Lerp(v[math.min(v3 + 2, #v)], v2 - v3)
end

function ScrambleBossHazards.GripCFrame(vector2: Vector3)
	local v2 = vector2 - createVector(0, 3, 0)
	local vector3 = Vector3.new(-v2.X, 0, -v2.Z)

	if vector3.Magnitude < 0.001 then
		return CFrame.new(v2)
	end

	return CFrame.lookAt(v2, v2 + vector3)
end

function ScrambleBossHazards.Reach(data)
	if data.Kind == "Line" then
		return (data.Travel or 0) + (data.Length or 0) / 2
	end

	if data.Kind == "Lane" or data.Kind == "Beam" then
		return (data.Length or 0) + (data.Width or 0)
	end

	if data.Kind == "Pillars" then
		return 1000
	end

	return data.Radius or 0
end

return ScrambleBossHazards