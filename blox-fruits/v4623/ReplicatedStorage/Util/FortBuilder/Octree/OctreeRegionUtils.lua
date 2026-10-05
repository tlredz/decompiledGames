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
local OctreeRegionUtils = {
	create = function(p, p2, p3, p4, p5, p6, parent, parentIndex)
		local v2 = p4 / 2
		local v3 = p5 / 2
		local v4 = p6 / 2
		return {
			subRegions = {},
			lowerBounds = { p - v2, p2 - v3, p3 - v4 },
			upperBounds = { p + v2, p2 + v3, p3 + v4 },
			position = { p, p2, p3 },
			size = { p4, p5, p6 },
			parent = parent,
			depth = parent and parent.depth + 1 or 1,
			parentIndex = parentIndex,
			nodes = {},
			node_count = 0
		}
	end,
	addNode = function(parent, p)
		assert(p, "Bad node")

		while parent do
			if not parent.nodes[p] then
				parent.nodes[p] = p
				parent.node_count += 1
			end

			parent = parent.parent
		end
	end,
	moveNode = function(parent, parent2, p)
		assert(parent.depth == parent2.depth, "fromLowest.depth ~= toLowest.depth")
		assert(parent ~= parent2, "fromLowest == toLowest")

		while parent ~= parent2 do
			assert(parent.nodes[p], "Not in currentFrom")
			assert(parent.node_count > 0, "No nodes in currentFrom")
			parent.nodes[p] = nil
			parent.node_count -= 1

			if parent.node_count <= 0 and parent.parentIndex then
				assert(parent.parent, "Bad currentFrom.parent")
				assert(parent.parent.subRegions[parent.parentIndex] == parent, "Not in subregion")
				parent.parent.subRegions[parent.parentIndex] = nil
			end

			assert(not parent2.nodes[p], "Failed to add")
			parent2.nodes[p] = p
			parent2.node_count += 1
			parent = parent.parent
			parent2 = parent2.parent
		end
	end,
	removeNode = function(parent, p)
		assert(p, "Bad node")

		while parent do
			assert(parent.nodes[p], "Not in current")
			assert(parent.node_count > 0, "Current has bad node count")
			parent.nodes[p] = nil
			parent.node_count -= 1

			if parent.node_count <= 0 and parent.parentIndex then
				assert(parent.parent, "No parent")
				assert(parent.parent.subRegions[parent.parentIndex] == parent, "Not in subregion")
				parent.parent.subRegions[parent.parentIndex] = nil
			end

			parent = parent.parent
		end
	end,
	getSearchRadiusSquared = function(p, p2, p3)
		local v2 = p + 0.8660254037844386 * p2
		return v2 * v2 + p3
	end
}

function OctreeRegionUtils.getNeighborsWithinRadius(p, p2, p3, p4, p5, list, list2, p6)
	assert(p6, "Bad maxDepth")
	local v2 = p.size[1] / 2
	local searchRadiusSquared = OctreeRegionUtils.getSearchRadiusSquared(p2, v2, 1e-6)
	local v3 = p2 * p2

	for _, subRegion in pairs(p.subRegions) do
		local position = subRegion.position
		local v4 = position[1]
		local v5 = position[2]
		local v6 = position[3]
		local v7 = p3 - v4
		local v8 = p4 - v5
		local v9 = p5 - v6

		if not (v7 * v7 + v8 * v8 + v9 * v9 <= searchRadiusSquared) then
			continue
		end

		if subRegion.depth == p6 then
			for k, _ in pairs(subRegion.nodes) do
				local rawPosition, v10, v11 = k:GetRawPosition()
				local v12 = p3 - rawPosition
				local v13 = p4 - v10
				local v14 = p5 - v11
				local v15 = v12 * v12 + v13 * v13 + v14 * v14

				if not (v15 <= v3) then
					continue
				end

				list[#list + 1] = k:GetObject()
				list2[#list2 + 1] = v15
			end
		else
			OctreeRegionUtils.getNeighborsWithinRadius(subRegion, p2, p3, p4, p5, list, list2, p6)
		end
	end
end

function OctreeRegionUtils.getOrCreateSubRegionAtDepth(p, p2, p3, p4, p5)
	for _ = p.depth, p5 do
		local subRegionIndex = OctreeRegionUtils.getSubRegionIndex(p, p2, p3, p4)
		local subRegion = p.subRegions[subRegionIndex]

		if not subRegion then
			subRegion = OctreeRegionUtils.createSubRegion(p, subRegionIndex)
			p.subRegions[subRegionIndex] = subRegion
		end

		p = subRegion
	end

	return p
end

function OctreeRegionUtils.createSubRegion(p, p2)
	local size = p.size
	local position = p.position
	local v2 = v[p2]
	local v3 = position[1] + v2[1] * size[1]
	local v4 = position[2] + v2[2] * size[2]
	local v5 = position[3] + v2[3] * size[3]
	local v6 = size[1] / 2
	local v7 = size[2] / 2
	local v8 = size[3] / 2
	return OctreeRegionUtils.create(v3, v4, v5, v6, v7, v8, p, p2)
end

function OctreeRegionUtils.inRegionBounds(p, p2, p3, p4)
	local lowerBounds = p.lowerBounds
	local upperBounds = p.upperBounds
	return lowerBounds[1] <= p2 and p2 <= upperBounds[1] and lowerBounds[2] <= p3 and p3 <= upperBounds[2] and lowerBounds[3] <= p4 and p4 <= upperBounds[3]
end

function OctreeRegionUtils.getSubRegionIndex(p, p2, p3, p4)
	local v2 = p.position[1] < p2 and 1 or 2

	if p3 <= p.position[2] then
		v2 += 4
	end

	if p.position[3] <= p4 then
		return v2 + 2
	end

	return v2
end

function OctreeRegionUtils.getTopLevelRegionHash(p, p2, p3)
	return p * 73856093 + p2 * 19351301 + p3 * 83492791
end

function OctreeRegionUtils.getTopLevelRegionCellIndex(list, p, p2, p3)
	return math.floor(p / list[1] + 0.5), math.floor(p2 / list[2] + 0.5), (math.floor(p3 / list[3] + 0.5))
end

function OctreeRegionUtils.getTopLevelRegionPosition(list, p, p2, p3)
	return list[1] * p, list[2] * p2, list[3] * p3
end

function OctreeRegionUtils.areEqualTopRegions(p, p2, p3, p4)
	local position = p.position
	return position[1] == p2 and position[2] == p3 and position[3] == p4
end

function OctreeRegionUtils.findRegion(p, p2, p3, p4, p5)
	local topLevelRegionCellIndex, v2, v3 = OctreeRegionUtils.getTopLevelRegionCellIndex(p2, p3, p4, p5)
	local v4 = p[OctreeRegionUtils.getTopLevelRegionHash(topLevelRegionCellIndex, v2, v3)]

	if not v4 then
		return nil
	end

	local topLevelRegionPosition, v5, v6 = OctreeRegionUtils.getTopLevelRegionPosition(
		p2,
		topLevelRegionCellIndex,
		v2,
		v3
	)

	for _, v7 in pairs(v4) do
		if OctreeRegionUtils.areEqualTopRegions(v7, topLevelRegionPosition, v5, v6) then
			return v7
		end
	end

	return nil
end

function OctreeRegionUtils:getOrCreateRegion(list, p2, p3, p4)
	local topLevelRegionCellIndex, v2, v3 = OctreeRegionUtils.getTopLevelRegionCellIndex(list, p2, p3, p4)
	local topLevelRegionHash = OctreeRegionUtils.getTopLevelRegionHash(topLevelRegionCellIndex, v2, v3)
	local v4 = self[topLevelRegionHash]

	if not v4 then
		v4 = {}
		self[topLevelRegionHash] = v4
	end

	local topLevelRegionPosition, v5, v6 = OctreeRegionUtils.getTopLevelRegionPosition(
		list,
		topLevelRegionCellIndex,
		v2,
		v3
	)

	for _, v7 in pairs(v4) do
		if OctreeRegionUtils.areEqualTopRegions(v7, topLevelRegionPosition, v5, v6) then
			return v7
		end
	end

	local v7 = OctreeRegionUtils.create(topLevelRegionPosition, v5, v6, list[1], list[2], list[3])
	table.insert(v4, v7)
	return v7
end

return OctreeRegionUtils