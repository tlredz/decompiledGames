local OctreeRegionUtils = require(script.OctreeRegionUtils)
local OctreeNode = require(script.OctreeNode)
local Octree = {
	ClassName = "Octree"
}
Octree.__index = Octree

function Octree.new()
	local self = setmetatable({}, Octree)
	self._maxRegionSize = { 512, 512, 512 }
	self._maxDepth = 4
	self._regionHashMap = {}
	return self
end

function Octree:GetAllNodes()
	local result = {}

	for _, v in pairs(self._regionHashMap) do
		for _, v2 in pairs(v) do
			for k, _ in pairs(v2.nodes) do
				result[#result + 1] = k
			end
		end
	end

	return result
end

function Octree.CreateNode(p, p2, p3)
	assert(typeof(p2) == "Vector3", "Bad position value")
	assert(p3, "Bad object value")
	local v = OctreeNode.new(p, p3)
	v:SetPosition(p2)
	return v
end

function Octree:RadiusSearch(data, value)
	assert(typeof(data) == "Vector3", "Bad position")
	assert(type(value) == "number", "Bad radius")
	return self:_radiusSearch(data.x, data.y, data.z, value)
end

function Octree:KNearestNeighborsSearch(data, p, value)
	assert(typeof(data) == "Vector3", "Bad position")
	assert(type(value) == "number", "Bad radius")
	local _radiusSearch, v = self:_radiusSearch(data.x, data.y, data.z, value)
	local v2 = {}

	for k, dist in pairs(v) do
		table.insert(v2, {
			dist2 = dist,
			index = k
		})
	end

	table.sort(v2, function(a, b)
		return a.dist2 < b.dist2
	end)
	local dist2s = {}
	local result = {}

	for i = 1, math.min(#v2, p) do
		local v3 = v2[i]
		dist2s[#dist2s + 1] = v3.dist2
		result[#result + 1] = _radiusSearch[v3.index]
	end

	return result, dist2s
end

function Octree:GetOrCreateLowestSubRegion(p, p2, p3)
	local _getOrCreateRegion = self:_getOrCreateRegion(p, p2, p3)
	return OctreeRegionUtils.getOrCreateSubRegionAtDepth(_getOrCreateRegion, p, p2, p3, self._maxDepth)
end

function Octree:_radiusSearch(p, p2, p3, p4)
	local v = self._maxRegionSize[1]
	local searchRadiusSquared = OctreeRegionUtils.getSearchRadiusSquared(p4, v, 1e-9)
	local v2 = {}
	local v3 = {}

	for _, v4 in pairs(self._regionHashMap) do
		for _, v5 in pairs(v4) do
			local position = v5.position
			local v6 = position[1]
			local v7 = position[2]
			local v8 = position[3]
			local v9 = p - v6
			local v10 = p2 - v7
			local v11 = p3 - v8

			if v9 * v9 + v10 * v10 + v11 * v11 <= searchRadiusSquared then
				OctreeRegionUtils.getNeighborsWithinRadius(v5, p4, p, p2, p3, v2, v3, self._maxDepth)
			end
		end
	end

	return v2, v3
end

function Octree:_getRegion(p2, p3, p4)
	return OctreeRegionUtils.findRegion(self._regionHashMap, self._maxRegionSize, p2, p3, p4)
end

function Octree:_getOrCreateRegion(p2, p3, p4)
	return OctreeRegionUtils.getOrCreateRegion(self._regionHashMap, self._maxRegionSize, p2, p3, p4)
end

return Octree