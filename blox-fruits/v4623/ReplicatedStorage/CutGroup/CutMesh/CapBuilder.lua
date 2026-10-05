local createVector = vector.create

local function planeProject3DTo2D(vector2: Vector3, planeCFrame: CFrame)
	local lookVector = planeCFrame.LookVector
	local unit = lookVector:Cross(math.abs(lookVector.Y) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
	local unit2 = lookVector:Cross(unit).Unit
	local vector3 = vector2 - planeCFrame.Position
	return Vector2.new(vector3:Dot(unit), vector3:Dot(unit2))
end

local function signedArea2D(list)
	local total = 0

	for i = 1, #list do
		local v = list[i]
		local v2 = list[i % #list + 1]
		total += v.X * v2.Y - v2.X * v.Y
	end

	return total * 0.5
end

local function dedupePoints(list, p: number)
	local result = {}
	local result2 = {}

	for i, v in ipairs(list) do
		local v2 = nil

		for i2, v4 in ipairs(result) do
			if not ((v4 - v).Magnitude <= p) then
				continue
			end

			v2 = i2
			break
		end

		if v2 then
			result2[i] = v2
		else
			table.insert(result, v)
			result2[i] = #result
		end
	end

	return result, result2
end

local function extractLoops(_, items)
	local v = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function edgeKey(p, p2)
		if p < p2 then
			return p .. "|" .. p2
		end

		return p2 .. "|" .. p
	end

	local function walkLoop(k, p)
		local result = {}
		table.insert(result, k)
		table.insert(result, p)
		local v2 = v
		local v3 = edgeKey(k, p) -- equivalent call inferred; original call site unknown
		v2[v3] = true
		local v4 = k

		while true do
			local v5 = nil

			for _, v7 in ipairs(items[p]) do
				if v7 == v4 then
					continue
				end

				local v9 = edgeKey(p, v7) -- equivalent call inferred; original call site unknown

				if v[v9] then
					continue
				end

				v5 = v7
				break
			end

			if not v5 then
				return nil
			end

			table.insert(result, v5)
			local v7 = v
			local v8 = edgeKey(p, v5) -- equivalent call inferred; original call site unknown
			v7[v8] = true

			if v5 == k then
				result[#result] = nil
				return result
			else
				v4 = p
				p = v5
			end
		end
	end

	local result = {}

	for k, list in pairs(items) do
		for _, v2 in ipairs(list) do
			local v3 = edgeKey(k, v2) -- equivalent call inferred; original call site unknown

			if v[v3] then
				continue
			end

			local v4 = walkLoop(k, v2)

			if v4 and #v4 >= 3 then
				table.insert(result, v4)
			end
		end
	end

	return result
end

local function triangulate(list)
	local v = {}

	for i = 1, #list do
		v[i] = i
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isConvex(p, p2, p3, p4)
		local v2 = list[p]
		local v3 = list[p2]
		local v4 = list[p3]
		local v5 = (v3.X - v2.X) * (v4.Y - v2.Y) - (v3.Y - v2.Y) * (v4.X - v2.X)
		return p4 and v5 > 0 and true or not p4 and v5 < 0
	end

	local function inside(p, p2, p3, p4)
		local vector2 = p4 - p2
		local vector3 = p3 - p2
		local v2 = p - p2
		local dot = vector2:Dot(vector2)
		local dot2 = vector2:Dot(vector3)
		local dot3 = vector2:Dot(v2)
		local dot4 = vector3:Dot(vector3)
		local dot5 = vector3:Dot(v2)
		local v3 = 1 / (dot * dot4 - dot2 * dot2 + 1e-6)
		local v4 = (dot4 * dot3 - dot2 * dot5) * v3
		local v5 = (dot * dot5 - dot2 * dot3) * v3
		return v4 >= 0 and v5 >= 0 and v4 + v5 <= 1
	end

	local v2 = signedArea2D(list) > 0
	local count = 0
	local result = {}

	while #v > 3 and count < 4000 do
		count += 1
		local v3 = false

		for i = 1, #v do
			local v4 = v[(i - 2) % #v + 1]
			local v5 = v[i]
			local v6 = v[i % #v + 1]

			if not isConvex(v4, v5, v6, v2) then
				continue
			end

			local v7 = list[v4]
			local v8 = list[v5]
			local v9 = list[v6]
			local v10 = false

			for _, v12 in ipairs(v) do
				if not (v12 ~= v4 and v12 ~= v5 and v12 ~= v6 and inside(list[v12], v7, v8, v9)) then
					continue
				end

				v10 = true
				break
			end

			if v10 then
				continue
			end

			table.insert(result, { v4, v5, v6 })
			table.remove(v, i)
			v3 = true
			break
		end

		if not v3 then
			break
		end
	end

	if #v == 3 then
		table.insert(result, { v[1], v[2], v[3] })
	end

	return result
end

local function cleanLoop(list, list2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function isColinear(p, p2, p3)
		local v = p2 - p
		local v2 = p3 - p
		return math.abs(v.X * v2.Y - v.Y * v2.X) < 1e-6
	end

	local count = #list2
	local result = {}
	local result2 = {}

	for i = 1, count do
		local v3 = list2[(i - 2) % count + 1]
		local v4 = list2[i]
		local v5 = list2[i % count + 1]

		if (v4 - v3).Magnitude < 1e-6 or isColinear(v3, v4, v5) then
			continue
		end

		table.insert(result, list[i])
		table.insert(result2, list2[i])
	end

	return result, result2
end

return {
	BuildCapsFromSegments = function(data)
		local cutSegments = data.cutSegments
		local planeCFrame = data.planeCFrame
		local meshLeft = data.meshLeft
		local meshRight = data.meshRight
		local dominantColor = data.dominantColor
		local meshToWorld = data.meshToWorld
		local v = {}

		for _, cutSegment in ipairs(cutSegments) do
			table.insert(v, cutSegment.A)
			table.insert(v, cutSegment.B)
		end

		local v2, v3 = dedupePoints(v, 0.005)
		local v4 = {}

		for i = 1, #v2 do
			v4[i] = {}
		end

		local v5 = 1

		for _, _ in ipairs(cutSegments) do
			local v6 = v3[v5]
			local v7 = v5 + 1
			local v8 = v3[v7]
			v5 = v7 + 1

			if not (v6 and v8) then
				continue
			end

			table.insert(v4[v6], v8)
			table.insert(v4[v8], v6)
		end

		local v6 = extractLoops(v2, v4)

		if #v6 == 0 then
			return
		end

		local lookVector = planeCFrame.LookVector
		local v7 = -planeCFrame.LookVector
		local v8 = meshRight:AddNormal(lookVector)
		local v9 = meshLeft:AddNormal(v7)
		local v10 = meshRight:AddColor(dominantColor, 1)
		local v11 = meshLeft:AddColor(dominantColor, 1)

		for _, list in ipairs(v6) do
			local v12 = {}
			local v13 = {}

			for _, v14 in ipairs(list) do
				local v15 = v2[v14]
				table.insert(v12, v15)
				table.insert(v13, planeProject3DTo2D(v15, planeCFrame))
			end

			if signedArea2D(v13) >= 0 then
				local v14 = {}
				local v15 = {}

				for i = #v12, 1, -1 do
					table.insert(v14, v12[i])
					table.insert(v15, v13[i])
				end

				v13 = v15
				v12 = v14
			end

			local v14, v15 = cleanLoop(v12, v13)

			if #v14 < 3 then
				warn("CapBuilder: loop collapsed, skipping")
			else
				local v16 = triangulate(v15)

				for _, v17 in ipairs(v16) do
					local v18 = v17[1]
					local v19 = v17[2]
					local v20 = v17[3]
					local pointToObjectSpace = meshToWorld:PointToObjectSpace(v14[v18])
					local pointToObjectSpace2 = meshToWorld:PointToObjectSpace(v14[v19])
					local pointToObjectSpace3 = meshToWorld:PointToObjectSpace(v14[v20])
					local v21 = meshRight:AddTriangle(
						meshRight:AddVertex(pointToObjectSpace),
						meshRight:AddVertex(pointToObjectSpace2),
						(meshRight:AddVertex(pointToObjectSpace3))
					)
					meshRight:SetFaceNormals(v21, { v8, v8, v8 })
					meshRight:SetFaceColors(v21, { v10, v10, v10 })
					local pointToObjectSpace4 = meshToWorld:PointToObjectSpace(v14[v18])
					local pointToObjectSpace5 = meshToWorld:PointToObjectSpace(v14[v20])
					local pointToObjectSpace6 = meshToWorld:PointToObjectSpace(v14[v19])
					local v22 = meshLeft:AddTriangle(
						meshLeft:AddVertex(pointToObjectSpace4),
						meshLeft:AddVertex(pointToObjectSpace5),
						(meshLeft:AddVertex(pointToObjectSpace6))
					)
					meshLeft:SetFaceNormals(v22, { v9, v9, v9 })
					meshLeft:SetFaceColors(v22, { v11, v11, v11 })
				end
			end
		end
	end
}