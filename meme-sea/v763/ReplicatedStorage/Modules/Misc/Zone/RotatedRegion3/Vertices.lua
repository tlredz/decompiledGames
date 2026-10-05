local createVector = vector.create
local v = {
	createVector(1, 1, 1),
	createVector(-1, 1, 1),
	createVector(-1, 1, -1),
	createVector(1, 1, -1),
	createVector(1, -1, 1),
	createVector(-1, -1, 1),
	createVector(-1, -1, -1),
	createVector(1, -1, -1)
}
local v2 = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8
}

local function fromIndexArray(list)
	local result = {}

	for i = 1, #list do
		result[i] = v[list[i]]
	end

	return result
end

local function cylinder(p)
	local v3 = 6.283185307179586 / p
	local result = {}

	for i = 1, p do
		local v4 = CFrame.fromAxisAngle(createVector(1, 0, 0), i * v3) * createVector(0, 1, 0)
		result[i] = createVector(1, 0, 0) + v4
		result[p + i] = createVector(-1, 0, 0) + v4
	end

	return result
end

local function icoSphere(p)
	local result = {
		createVector(-1, 1.618034, 0),
		createVector(1, 1.618034, 0),
		createVector(-1, -1.618034, 0),
		createVector(1, -1.618034, 0),
		createVector(0, -1, 1.618034),
		createVector(0, 1, 1.618034),
		createVector(0, -1, -1.618034),
		createVector(0, 1, -1.618034),
		createVector(1.618034, 0, -1),
		createVector(1.618034, 0, 1),
		createVector(-1.618034, 0, -1),
		createVector(-1.618034, 0, 1)
	}
	local v3 = {}

	local function split(p2, p3)
		local v4 = p2 < p3 and p2 .. "," .. p3 or p3 .. "," .. p2

		if not v3[v4] then
			result[#result + 1] = (result[p2] + result[p3]) / 2
			v3[v4] = #result
		end

		return v3[v4]
	end

	local v4 = {
		1,
		12,
		6,
		1,
		6,
		2,
		1,
		2,
		8,
		1,
		8,
		11,
		1,
		11,
		12,
		2,
		6,
		10,
		6,
		12,
		5,
		12,
		11,
		3,
		11,
		8,
		7,
		8,
		2,
		9,
		4,
		10,
		5,
		4,
		5,
		3,
		4,
		3,
		7,
		4,
		7,
		9,
		4,
		9,
		10,
		5,
		10,
		6,
		3,
		5,
		12,
		7,
		3,
		11,
		9,
		7,
		8,
		10,
		9,
		2
	}

	for _ = 1, p do
		for i = #v4, 1, -3 do
			local v5 = v4[i - 2]
			local v6 = v4[i - 1]
			local v7 = v4[i]
			local v8 = v5 < v6 and v5 .. "," .. v6 or v6 .. "," .. v5

			if not v3[v8] then
				result[#result + 1] = (result[v5] + result[v6]) / 2
				v3[v8] = #result
			end

			local v9 = v3[v8]
			local v10 = v6 < v7 and v6 .. "," .. v7 or v7 .. "," .. v6

			if not v3[v10] then
				result[#result + 1] = (result[v6] + result[v7]) / 2
				v3[v10] = #result
			end

			local v11 = v3[v10]
			local v12 = v7 < v5 and v7 .. "," .. v5 or v5 .. "," .. v7

			if not v3[v12] then
				result[#result + 1] = (result[v7] + result[v5]) / 2
				v3[v12] = #result
			end

			local v13 = v3[v12]
			v4[#v4 + 1] = v5
			v4[#v4 + 1] = v9
			v4[#v4 + 1] = v13
			v4[#v4 + 1] = v6
			v4[#v4 + 1] = v11
			v4[#v4 + 1] = v9
			v4[#v4 + 1] = v7
			v4[#v4 + 1] = v13
			v4[#v4 + 1] = v11
			v4[#v4 + 1] = v9
			v4[#v4 + 1] = v11
			v4[#v4 + 1] = v13
			table.remove(v4, i)
			table.remove(v4, i - 1)
			table.remove(v4, i - 2)
		end
	end

	for i = 1, #result do
		result[i] = result[i].Unit
	end

	return result
end

local function vertShape(cframe, p, list)
	local result = {}

	for i = 1, #list do
		result[i] = cframe:PointToWorldSpace(list[i] * p)
	end

	return result
end

local function getCentroidFromSet(list)
	local v3 = list[1]

	for _ = 2, #list do
		v3 += list[2]
	end

	return v3 / #list
end

local function classify(part)
	if part.ClassName == "Part" then
		if part.Shape == Enum.PartType.Block then
			return "Block"
		end

		if part.Shape == Enum.PartType.Cylinder then
			return "Cylinder"
		end

		if part.Shape == Enum.PartType.Ball then
			return "Ball"
		end
	else
		if part.ClassName == "WedgePart" then
			return "Wedge"
		end

		if part.ClassName == "CornerWedgePart" then
			return "CornerWedge"
		end

		if part:IsA("BasePart") then
			return "Block"
		end
	end
end

local v3 = {}
local v4 = {
	1,
	2,
	5,
	6,
	7,
	8
}
local v5 = {
	4,
	5,
	6,
	7,
	8
}

for i = 1, #v2 do
	v3[i] = v[v2[i]]
end

local v6 = {}

for i = 1, #v4 do
	v6[i] = v[v4[i]]
end

local v7 = {}

for i = 1, #v5 do
	v7[i] = v[v5[i]]
end

local v8 = cylinder(20)
local v9 = icoSphere(2)
local Vertices = {}

function Vertices.Block(p, p2)
	return (vertShape(p, p2, v3))
end

function Vertices.Wedge(p, p2)
	return (vertShape(p, p2, v6))
end

function Vertices.CornerWedge(p, p2)
	return (vertShape(p, p2, v7))
end

function Vertices.Cylinder(p, p2)
	return (vertShape(p, p2, v8))
end

function Vertices.Ball(p, p2)
	return (vertShape(p, p2, v9))
end

Vertices.GetCentroid = getCentroidFromSet
Vertices.Classify = classify
return Vertices