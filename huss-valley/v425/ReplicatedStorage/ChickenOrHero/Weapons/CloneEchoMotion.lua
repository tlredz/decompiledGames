local createVector = vector.create
local numberSequences = {}
local v = {}

for i = 0, 20 do
	local v2 = i / 20 * 0.7 + 0.3
	numberSequences[i] = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.12, v2),
		NumberSequenceKeypoint.new(0.8, (math.min(1, v2 + 0.08))),
		NumberSequenceKeypoint.new(1, 1)
	})
end

function v.build(instance)
	if instance:GetAttribute("CloneEchoVersion") ~= 2 then
		return nil
	end

	local v2 = {
		part = instance,
		orbits = {},
		echoes = {},
		phase = (instance.Position.X * 0.37 + instance.Position.Z * 0.21) % 6.283185307179586
	}

	for i = 1, 2 do
		local child = instance:FindFirstChild("SurgeOrbit" .. i .. "Start")
		local child2 = instance:FindFirstChild("SurgeOrbit" .. i .. "End")
		local child3 = instance:FindFirstChild("SurgeOrbit" .. i .. "Core")
		local child4 = instance:FindFirstChild("SurgeOrbit" .. i .. "Glow")

		if not (child and child2 and child3 and child4) then
			return nil
		end

		table.insert(v2.orbits, {
			a = child,
			b = child2,
			core = child3,
			glow = child4,
			radius = i == 1 and 0.97 or 0.88,
			tilt = i == 1 and 0.35 or -0.55,
			direction = i == 1 and 1 or -1
		})
		local v3 = {
			points = {},
			beams = {},
			side = i == 1 and -1 or 1
		}

		for i2 = 1, 5 do
			local child5 = instance:FindFirstChild("BladeEcho" .. i .. "Point" .. i2)

			if not child5 then
				return nil
			end

			table.insert(v3.points, {
				attachment = child5,
				rest = child5:GetAttribute("EchoRestPosition")
			})
		end

		for i2 = 1, 4 do
			local child5 = instance:FindFirstChild("BladeEcho" .. i .. "Edge" .. i2)

			if not child5 then
				return nil
			end

			table.insert(v3.beams, child5)
		end

		table.insert(v2.echoes, v3)
	end

	return v2
end

function v:step(p, object, p2)
	local part = self.part

	if not (object and part.Parent and self.orbits[1].core.Enabled) then
		return
	end

	local magnitude = (object.CFrame.Position - part.Position).Magnitude

	if (p2 < 1 and 38 or 58) < magnitude then
		return
	end

	local worldToViewportPoint, v2 = object:WorldToViewportPoint(part.Position)

	if not v2 or worldToViewportPoint.Z <= 0 then
		return
	end

	local scale = part.Size.X / 0.12
	local v4 = p + self.phase

	for k, orbit in self.orbits do
		local v5 = v4 * 1.9 * orbit.direction + (k - 1) * 3.141592653589793
		local v6 = orbit.radius * scale
		local v9 = CFrame.new(0, 0.12 * scale, 0.03 * scale) * CFrame.Angles(
			orbit.tilt + math.sin(v4 * 0.8 + k) * 0.18,
			0,
			0
		)

		local function pose(p3, p4)
			local vector2 = Vector3.new(math.cos(p4) * v6, math.sin(p4) * v6, 0)
			local vector3 = Vector3.new(-math.sin(p4), math.cos(p4), 0)
			p3.CFrame = v9 * CFrame.fromMatrix(
				vector2,
				vector3,
				createVector(0, 0, 1),
				vector3:Cross(createVector(0, 0, 1))
			)
		end

		pose(orbit.a, v5)
		pose(orbit.b, v5 + 2.4085543677521746)

		if self.scale == scale then
			continue
		end

		local curveSize = 0.9163746114688174 * v6
		orbit.core.CurveSize0 = curveSize
		orbit.core.CurveSize1 = curveSize
		orbit.glow.CurveSize0 = curveSize
		orbit.glow.CurveSize1 = curveSize
	end

	self.scale = scale

	for k, v5 in self.echoes do
		local v6 = (v4 * 0.62 + (k - 1) * 0.5) % 1
		local v7 = math.sin(v6 * 3.141592653589793)
		local v8 = 0.15 + v6 * 0.5
		local v9 = CFrame.new(v5.side * v8 * scale, v6 * 0.15 * scale, 0.07 * scale) * CFrame.Angles(
			0,
			0,
			v5.side * v6 * 0.08
		)

		for _, point in v5.points do
			point.attachment.CFrame = v9 * CFrame.new(point.rest * scale)
		end

		local fade = math.clamp(math.floor((1 - v7) * 20 + 0.5), 0, 20)

		if v5.fade == fade then
			continue
		end

		v5.fade = fade

		for _, beam in v5.beams do
			beam.Transparency = numberSequences[fade]
		end
	end
end

return table.freeze(v)