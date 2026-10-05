local createVector = vector.create
local Icosphere = {}

local function createIcosahedronVertices()
	local result = {}
	table.insert(result, createVector(-1, 1.618034, 0))
	table.insert(result, createVector(1, 1.618034, 0))
	table.insert(result, createVector(-1, -1.618034, 0))
	table.insert(result, createVector(1, -1.618034, 0))
	table.insert(result, createVector(0, -1, 1.618034))
	table.insert(result, createVector(0, 1, 1.618034))
	table.insert(result, createVector(0, -1, -1.618034))
	table.insert(result, createVector(0, 1, -1.618034))
	table.insert(result, createVector(1.618034, 0, -1))
	table.insert(result, createVector(1.618034, 0, 1))
	table.insert(result, createVector(-1.618034, 0, -1))
	table.insert(result, createVector(-1.618034, 0, 1))

	for k, v in result do
		result[k] = v.Unit
	end

	return result
end

local function createIcosahedronFaces(_)
	return {
		{ 1, 6, 2 },
		{ 1, 2, 8 },
		{ 1, 8, 11 },
		{ 1, 11, 12 },
		{ 1, 12, 6 },
		{ 2, 6, 10 },
		{ 6, 12, 5 },
		{ 12, 11, 3 },
		{ 11, 8, 7 },
		{ 8, 2, 9 },
		{ 4, 10, 9 },
		{ 4, 5, 10 },
		{ 4, 3, 5 },
		{ 4, 7, 3 },
		{ 4, 9, 7 },
		{ 10, 5, 6 },
		{ 5, 3, 12 },
		{ 3, 7, 11 },
		{ 7, 9, 8 },
		{ 9, 10, 2 }
	}
end

local function getMidpoint(vector2: Vector3, vector3: Vector3)
	return ((vector2 + vector3) * 0.5).Unit
end

local function subdivideTriangles(icosahedronVertices, icosahedronFaces)
	local result = {}
	local v = {}
	local result2 = {}

	for k, item in icosahedronVertices do
		result[k] = item
	end

	local function getOrCreateMidpoint(p: number, p2: number)
		local v2 = math.min(p, p2) .. "," .. math.max(p, p2)

		if v[v2] then
			return v[v2]
		end

		local unit = ((result[p] + result[p2]) * 0.5).Unit
		table.insert(result, unit)
		local count = #result
		v[v2] = count
		return count
	end

	for _, item in icosahedronFaces do
		local v2 = item[1]
		local v3 = item[2]
		local v4 = item[3]
		local v5 = math.min(v2, v3) .. "," .. math.max(v2, v3)
		local v6

		if v[v5] then
			v6 = v[v5]
		else
			table.insert(result, ((result[v2] + result[v3]) * 0.5).Unit)
			v6 = #result
			v[v5] = v6
		end

		local v7 = math.min(v3, v4) .. "," .. math.max(v3, v4)
		local v8

		if v[v7] then
			v8 = v[v7]
		else
			table.insert(result, ((result[v3] + result[v4]) * 0.5).Unit)
			v8 = #result
			v[v7] = v8
		end

		local v9 = math.min(v4, v2) .. "," .. math.max(v4, v2)
		local v10

		if v[v9] then
			v10 = v[v9]
		else
			table.insert(result, ((result[v4] + result[v2]) * 0.5).Unit)
			v10 = #result
			v[v9] = v10
		end

		table.insert(result2, { v2, v6, v10 })
		table.insert(result2, { v3, v8, v6 })
		table.insert(result2, { v4, v10, v8 })
		table.insert(result2, { v6, v8, v10 })
	end

	return result, result2
end

local function createDualMesh(icosahedronVertices, icosahedronFaces)
	local v = {}

	for i = 1, #icosahedronVertices do
		v[i] = {}
	end

	local units = {}

	for k, item in icosahedronFaces do
		local v2 = createVector(0, 0, 0)

		for _, v3 in item do
			v2 += icosahedronVertices[v3]
			table.insert(v[v3], k)
		end

		units[k] = (v2 / #item).Unit
	end

	local result = {}

	for i = 1, #icosahedronVertices do
		local v2 = v[i]

		if not (#v2 > 0) then
			continue
		end

		local v3 = {}

		for _, v4 in v2 do
			table.insert(v3, units[v4])
		end

		local v5 = icosahedronVertices[i]
		table.sort(v3, function(a, b)
			return (a - v5).Unit:Cross((b - v5).Unit):Dot(v5) > 0
		end)
		table.insert(result, v3)
	end

	return result
end

local function scaleToRadius(dualMesh, p: number)
	local result = {}

	for _, item in dualMesh do
		local v = {}

		for _, v2 in item do
			table.insert(v, v2 * p)
		end

		table.insert(result, v)
	end

	return result
end

function Icosphere.generate(p: number, value: number?)
	local icosahedronVertices = createIcosahedronVertices()
	local icosahedronFaces = createIcosahedronFaces(icosahedronVertices)

	for _ = 1, value or 1 do
		icosahedronVertices, icosahedronFaces = subdivideTriangles(icosahedronVertices, icosahedronFaces)
	end

	return (scaleToRadius(createDualMesh(icosahedronVertices, icosahedronFaces), p))
end

function Icosphere.generateSeparated(p: number, p2: number?)
	local generate = Icosphere.generate(p, p2)
	local result = {}
	local result2 = {}

	for _, v in generate do
		if #v == 5 then
			table.insert(result2, v)
		elseif #v == 6 then
			table.insert(result, v)
		end
	end

	return result, result2
end

local function deepCopyShape(clones)
	local clone = table.clone(clones)

	for k, item in clones do
		clones[k] = table.clone(item)
	end

	return clone
end

local buf = buffer.create(8)

-- equivalent calls inferred from this helper; original call sites unknown
local function getStepsKey(value: number, value2: number)
	buffer.writef32(buf, 0, value)
	buffer.writef32(buf, 4, value2)
	return buffer.readstring(buf, 0, 8)
end

local v = {}

function Icosphere.generateWithSteps(value: number, value2: number)
	local stepsKey = getStepsKey(value, value2) -- equivalent call inferred; original call site unknown
	local v2 = v[stepsKey]

	if v2 then
		return (deepCopyShape(v2))
	end

	local icosahedronVertices = createIcosahedronVertices()
	local icosahedronFaces = createIcosahedronFaces(icosahedronVertices)
	local v3 = math.floor(value2)
	local v4 = value2 - v3

	for _ = 1, v3 do
		icosahedronVertices, icosahedronFaces = subdivideTriangles(icosahedronVertices, icosahedronFaces)
	end

	if v4 > 0.1 then
		local v5 = {}
		local v6 = {}
		local v7 = {}

		for k, icosahedronVertice in icosahedronVertices do
			v5[k] = icosahedronVertice
		end

		local function getOrCreateMidpoint(p: number, p2: number)
			local v8 = math.min(p, p2) .. "," .. math.max(p, p2)

			if v6[v8] then
				return v6[v8]
			end

			local unit = ((v5[p] + v5[p2]) * 0.5).Unit
			table.insert(v5, unit)
			local count = #v5
			v6[v8] = count
			return count
		end

		for k, icosahedronFace in icosahedronFaces do
			if k / #icosahedronFaces < v4 then
				local v8 = icosahedronFace[1]
				local v9 = icosahedronFace[2]
				local v10 = icosahedronFace[3]
				local v11 = math.min(v8, v9) .. "," .. math.max(v8, v9)
				local v12

				if v6[v11] then
					v12 = v6[v11]
				else
					table.insert(v5, ((v5[v8] + v5[v9]) * 0.5).Unit)
					v12 = #v5
					v6[v11] = v12
				end

				local v13 = math.min(v9, v10) .. "," .. math.max(v9, v10)
				local v14

				if v6[v13] then
					v14 = v6[v13]
				else
					table.insert(v5, ((v5[v9] + v5[v10]) * 0.5).Unit)
					v14 = #v5
					v6[v13] = v14
				end

				local v15 = math.min(v10, v8) .. "," .. math.max(v10, v8)
				local v16

				if v6[v15] then
					v16 = v6[v15]
				else
					table.insert(v5, ((v5[v10] + v5[v8]) * 0.5).Unit)
					v16 = #v5
					v6[v15] = v16
				end

				table.insert(v7, { v8, v12, v16 })
				table.insert(v7, { v9, v14, v12 })
				table.insert(v7, { v10, v16, v14 })
				table.insert(v7, { v12, v14, v16 })
			else
				table.insert(v7, icosahedronFace)
			end
		end

		icosahedronFaces = v7
		icosahedronVertices = v5
	end

	local v5 = scaleToRadius(createDualMesh(icosahedronVertices, icosahedronFaces), value)
	v[stepsKey] = deepCopyShape(v5)
	return v5
end

function Icosphere.getDensityOptions()
	return {
		{
			name = "Very Low",
			vertices = 12,
			subdivisions = 0
		},
		{
			name = "Low",
			vertices = 42,
			subdivisions = 1
		},
		{
			name = "Medium-Low",
			vertices = 92,
			subdivisions = 1.5
		},
		{
			name = "Medium",
			vertices = 162,
			subdivisions = 2
		},
		{
			name = "Medium-High",
			vertices = 362,
			subdivisions = 2.5
		},
		{
			name = "High",
			vertices = 642,
			subdivisions = 3
		},
		{
			name = "Very High",
			vertices = 2562,
			subdivisions = 4
		}
	}
end

return Icosphere