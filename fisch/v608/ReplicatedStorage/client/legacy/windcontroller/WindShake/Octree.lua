local OctreeNode = require(script.OctreeNode)
local OctreeRegionUtils = require(script.OctreeRegionUtils)
local v = {
	{ 0.25, 0.25, -0.25 },
	{ -0.25, 0.25, -0.25 },
	{ 0.25, 0.25, 0.25 },
	{ -0.25, 0.25, 0.25 },
	{ 0.25, -0.25, -0.25 },
	{ -0.25, -0.25, -0.25 },
	{ 0.25, -0.25, 0.25 },
	{ -0.25, -0.25, 0.25 }
}
local Octree = {
	ClassName = "Octree"
}
Octree.__index = Octree
local new = OctreeNode.new
local getNeighborsWithinRadius = OctreeRegionUtils.GetNeighborsWithinRadius

function Octree.new()
	return (setmetatable({
		MaxDepth = 4,
		MaxRegionSize = table.create(3, 512),
		RegionHashMap = {}
	}, Octree))
end

function Octree:ClearNodes()
	self.MaxDepth = 4
	self.MaxRegionSize = table.create(3, 512)
	table.clear(self.RegionHashMap)
end

function Octree.GetAllNodes(p)
	local count = 0
	local result = {}

	for _, list in next, p.RegionHashMap, nil do
		for _, v2 in ipairs(list) do
			for k in next, v2.Nodes, nil do
				count += 1
				result[count] = k
			end
		end
	end

	return result
end

function Octree.CreateNode(p, vector: Vector3, p2)
	if typeof(vector) ~= "Vector3" then
		error("Bad position value")
	end

	if not p2 then
		error("Bad object value.")
	end

	local v2 = new(p, p2)
	v2:SetPosition(vector)
	return v2
end

function Octree.RadiusSearch(data, vector: Vector3, value: number)
	if typeof(vector) ~= "Vector3" then
		error("Bad position value")
	end

	if type(value) ~= "number" then
		error("Bad radius value")
	end

	local X = vector.X
	local Y = vector.Y
	local Z = vector.Z
	local v2 = value + 0.8660254037844386 * data.MaxRegionSize[1]
	local v3 = v2 * v2 + 1e-9
	local v4 = {}
	local v5 = {}
	local v6 = 0
	local v7 = 0

	for _, list in next, data.RegionHashMap, nil do
		for _, v8 in ipairs(list) do
			local position = v8.Position
			local v9 = position[1]
			local v10 = position[2]
			local v11 = position[3]
			local v12 = X - v9
			local v13 = Y - v10
			local v14 = Z - v11

			if v12 * v12 + v13 * v13 + v14 * v14 <= v3 then
				v6, v7 = getNeighborsWithinRadius(v8, value, X, Y, Z, v4, v5, data.MaxDepth, v6, v7)
			end
		end
	end

	return v4, v5
end

local function NearestNeighborSort(p, p2)
	return p.Distance2 < p2.Distance2
end

function Octree.KNearestNeighborsSearch(data, vector: Vector3, p: number, value: number)
	if typeof(vector) ~= "Vector3" then
		error("Bad position value")
	end

	if type(value) ~= "number" then
		error("Bad radius value")
	end

	local X = vector.X
	local Y = vector.Y
	local Z = vector.Z
	local v2 = value + 0.8660254037844386 * data.MaxRegionSize[1]
	local v3 = v2 * v2 + 1e-9
	local v4 = {}
	local v5 = {}
	local v6 = 0
	local v7 = 0

	for _, list in next, data.RegionHashMap, nil do
		for _, v8 in ipairs(list) do
			local position = v8.Position
			local v9 = position[1]
			local v10 = position[2]
			local v11 = position[3]
			local v12 = X - v9
			local v13 = Y - v10
			local v14 = Z - v11

			if v12 * v12 + v13 * v13 + v14 * v14 <= v3 then
				v6, v7 = getNeighborsWithinRadius(v8, value, X, Y, Z, v4, v5, data.MaxDepth, v6, v7)
			end
		end
	end

	local v8 = table.create(v7)

	for i, distance in ipairs(v5) do
		v8[i] = {
			Distance2 = distance,
			Index = i
		}
	end

	table.sort(v8, NearestNeighborSort)
	local v9 = math.min(v7, p)
	local result = table.create(v9)
	local distance2s = table.create(v9)

	for i = 1, v9 do
		local v10 = v8[i]
		distance2s[i] = v10.Distance2
		result[i] = v4[v10.Index]
	end

	return result, distance2s
end

local function GetOrCreateRegion(p, p2: number, p3: number, p4: number)
	local regionHashMap = p.RegionHashMap
	local maxRegionSize = p.MaxRegionSize
	local v2 = maxRegionSize[1]
	local v3 = maxRegionSize[2]
	local v4 = maxRegionSize[3]
	local v5 = math.floor(p2 / v2 + 0.5)
	local v6 = math.floor(p3 / v3 + 0.5)
	local v7 = math.floor(p4 / v4 + 0.5)
	local v8 = v5 * 73856093 + v6 * 19351301 + v7 * 83492791
	local v9 = regionHashMap[v8]

	if not v9 then
		v9 = {}
		regionHashMap[v8] = v9
	end

	local v10 = v2 * v5
	local v11 = v3 * v6
	local v12 = v4 * v7

	for _, v13 in ipairs(v9) do
		local position = v13.Position

		if position[1] == v10 and position[2] == v11 and position[3] == v12 then
			return v13
		end
	end

	local v13 = v2 / 2
	local v14 = v3 / 2
	local v15 = v4 / 2
	local v16 = {
		Depth = 1,
		LowerBounds = { v10 - v13, v11 - v14, v12 - v15 },
		NodeCount = 0,
		Nodes = {},
		Parent = nil,
		ParentIndex = nil,
		Position = { v10, v11, v12 },
		Size = { v2, v3, v4 },
		SubRegions = {},
		UpperBounds = { v10 + v13, v11 + v14, v12 + v15 }
	}
	table.insert(v9, v16)
	return v16
end

function Octree.GetOrCreateLowestSubRegion(p, p2: number, p3: number, p4: number)
	local parent = GetOrCreateRegion(p, p2, p3, p4)
	local maxDepth = p.MaxDepth

	for _ = parent.Depth, maxDepth do
		local position = parent.Position
		local parentIndex = position[1] < p2 and 1 or 2

		if p3 <= position[2] then
			parentIndex += 4
		end

		if position[3] <= p4 then
			parentIndex += 2
		end

		local subRegions = parent.SubRegions
		local subRegion = subRegions[parentIndex]

		if not subRegion then
			local size = parent.Size
			local v4 = v[parentIndex]
			local v5 = size[1]
			local v6 = size[2]
			local v7 = size[3]
			local v8 = position[1] + v4[1] * v5
			local v9 = position[2] + v4[2] * v6
			local v10 = position[3] + v4[3] * v7
			local v11 = v5 / 2
			local v12 = v6 / 2
			local v13 = v7 / 2
			local v14 = v11 / 2
			local v15 = v12 / 2
			local v16 = v13 / 2
			local lowerBounds = { v8 - v14, v9 - v15, v10 - v16 }
			local upperBounds = { v8 + v14, v9 + v15, v10 + v16 }
			subRegion = {
				Depth = not parent and 1 or parent.Depth + 1 or 1,
				LowerBounds = lowerBounds,
				NodeCount = 0,
				Nodes = {},
				Parent = parent,
				ParentIndex = parentIndex,
				Position = { v8, v9, v10 },
				Size = { v11, v12, v13 },
				SubRegions = {},
				UpperBounds = upperBounds
			}
			subRegions[parentIndex] = subRegion
		end

		parent = subRegion
	end

	return parent
end

return Octree