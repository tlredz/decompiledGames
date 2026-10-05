local createVector = vector.create

local function support(data, data2, p, p2)
	return (math.abs((data.XVector:Dot(p))) * data2.X + math.abs((data.YVector:Dot(p))) * data2.Y + math.abs((data.ZVector:Dot(p))) * data2.Z) * p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spinCF(p, p2, p3)
	local magnitude = p2.Magnitude

	if magnitude * p3 < 0.0001 then
		return p
	end

	return CFrame.fromAxisAngle(p2 * (1 / magnitude), magnitude * p3) * p
end

local function planeCrossTime(vector2, vector3, vector4, normal, p, p2)
	local v = 0.5 * vector4:Dot(normal)
	local dot = vector3:Dot(normal)
	local v2 = vector2:Dot(normal) - p

	if math.abs(v) < 1e-6 then
		if math.abs(dot) < 1e-9 then
			return nil
		end

		local v3 = -v2 / dot

		if v3 >= 0 and v3 <= p2 then
			return v3
		end

		return nil
	else
		local v3 = dot * dot - 4 * v * v2

		if v3 < 0 then
			return nil
		end

		local v4 = math.sqrt(v3)
		local selected = (-dot - v4) / (2 * v)
		local selected2 = (-dot + v4) / (2 * v)

		if selected2 < selected then
			selected2, selected = selected, selected2
		end

		if selected >= 0 and selected <= p2 then
			return selected
		end

		if selected2 >= 0 and selected2 <= p2 then
			return selected2
		end

		return nil
	end
end

local function restPose(data, data2, normal)
	local dot = data.XVector:Dot(normal)
	local dot2 = data.YVector:Dot(normal)
	local dot3 = data.ZVector:Dot(normal)
	local v = math.abs(dot) / math.max(data2.X, 0.05)
	local v2 = math.abs(dot2) / math.max(data2.Y, 0.05)
	local v3 = math.abs(dot3) / math.max(data2.Z, 0.05)
	local vector2, X

	if v2 <= v and v3 <= v then
		vector2 = data.XVector * (dot >= 0 and 1 or -1)
		X = data2.X
	elseif v3 <= v2 then
		vector2 = data.YVector * (dot2 >= 0 and 1 or -1)
		X = data2.Y
	else
		vector2 = data.ZVector * (dot3 >= 0 and 1 or -1)
		X = data2.Z
	end

	local v4 = math.clamp(vector2:Dot(normal), -1, 1)
	local cross = vector2:Cross(normal)

	if cross.Magnitude > 0.00001 and v4 < 0.9999 then
		return CFrame.fromAxisAngle(cross.Unit, (math.acos(v4))) * data, X
	end

	return data, X
end

local Trajectory = {}

function Trajectory.build(p, p2, rot, p4, p5, p6, p7, p8, p9, callback)
	local segs = {}
	local vector2 = Vector3.new(0, -p7, 0)
	local total = 0
	local result = {
		segs = segs,
		impactT = nil,
		hit = nil,
		restT = 1e999
	}

	for i = 0, 3 do
		local v2 = i == 0 and 6 or 4
		local v3 = math.min(math.max(p2.Y, 0) / math.max(p7, 1) * 2 + 1.5, 6)
		local v4 = v3 / v2
		local v5 = p
		local hit = nil
		local v7 = nil

		for i2 = 1, v2 do
			local v8 = i2 * v4
			local v9 = p + p2 * v8 + vector2 * (0.5 * v8 * v8)
			local v10 = v9 - v5

			if v10.Magnitude > 0.0001 then
				local unit = v10.Unit
				local v11 = support(rot, p5, unit, p6)
				local v12 = callback(v5, v10 + unit * v11)

				if v12 then
					local v13 = math.clamp((v12.Position - v5).Magnitude / (v10.Magnitude + v11), 0, 1)
					local v14 = (i2 - 1) * v4 + v4 * v13
					local v16 = spinCF(rot, p4, v14) -- equivalent call inferred; original call site unknown
					local v17 = support(v16, p5, v12.Normal, p6)
					local v18 = v12.Position:Dot(v12.Normal) + v17
					v7 = planeCrossTime(p, p2, vector2, v12.Normal, v18, v3) or v14
					hit = v12
					break
				end
			end

			v5 = v9
		end

		if not hit then
			segs[#segs + 1] = {
				kind = 1,
				t0 = total,
				p0 = p,
				v0 = p2,
				rot0 = rot,
				w = p4
			}
			return result
		end

		local normal = hit.Normal
		local vector3 = p2 + vector2 * v7
		local rot2 = spinCF(rot, p4, v7) -- equivalent call inferred; original call site unknown
		local v9 = support(rot2, p5, normal, p6)
		local v10 = p + p2 * v7 + vector2 * (0.5 * v7 * v7)
		segs[#segs + 1] = {
			kind = 1,
			t0 = total,
			p0 = p,
			v0 = p2,
			rot0 = rot,
			w = p4
		}
		total += v7

		if not result.impactT then
			result.impactT = total
			result.hit = hit
		end

		local dot = vector3:Dot(normal)
		local v11 = vector3 - normal * dot

		if -dot * p8 > 6 and normal.Y > 0.3 and i < 3 then
			p2 = v11 * (1 - p9) + normal * (-dot * p8)
			local cross = normal:Cross(v11)

			if cross.Magnitude > 0.0001 and v11.Magnitude > 0.5 then
				p4 = cross.Unit * (v11.Magnitude / math.max(v9, 0.1))
			end

			rot = rot2
			p = v10
		else
			local magnitude = v11.Magnitude
			local v12 = math.max(p9 * p7 * 0.5, 10)
			local v13 = math.min(magnitude / v12, 2)
			local unit = magnitude > 0.001 and v11.Unit or createVector(1, 0, 0)
			local rotF, v15 = restPose(rot2, p5, normal)
			-- equivalent calls inferred from this helper; original call sites unknown
			local normal2 = normal
			local v17 = hit.Position:Dot(normal)

			local function planeSeat(vector4, p10)
				return vector4 + normal2 * (v17 + p10 - vector4:Dot(normal2))
			end

			local v18 = planeSeat(v10, v9) -- equivalent call inferred; original call site unknown
			local v20 = planeSeat(v18 + unit * (magnitude * v13 - v12 * 0.5 * v13 * v13), v15 * p6) -- equivalent call inferred; original call site unknown
			segs[#segs + 1] = {
				kind = 2,
				t0 = total,
				dur = math.max(v13, 0.15),
				p0 = v18,
				p1 = v20,
				rot0 = rot2,
				rotF = rotF
			}
			local v21 = total + math.max(v13, 0.15)
			segs[#segs + 1] = {
				kind = 3,
				t0 = v21,
				cf = rotF + v20
			}
			result.restT = v21
			return result
		end
	end

	return result
end

function Trajectory.evaluate(p, p2, p3)
	local segs = p.segs
	local seg = segs[1]

	for i = 2, #segs do
		if segs[i].t0 <= p2 then
			seg = segs[i]
		else
			break
		end
	end

	if seg.kind == 1 then
		local v = math.max(p2 - seg.t0, 0)
		local v2 = seg.p0 + seg.v0 * v + Vector3.new(0, -0.5 * p3 * v * v, 0)
		local rot0 = seg.rot0
		local w = seg.w
		local magnitude = w.Magnitude

		if not (magnitude * v < 0.0001) then
			rot0 = CFrame.fromAxisAngle(w * (1 / magnitude), magnitude * v) * rot0
		end

		return rot0 + v2
	else
		if seg.kind ~= 2 then
			return seg.cf
		end

		local v = math.clamp((p2 - seg.t0) / seg.dur, 0, 1)
		local v2 = 1 - (1 - v) * (1 - v)
		return seg.rot0:Lerp(seg.rotF, v2) + seg.p0:Lerp(seg.p1, v2)
	end
end

return Trajectory