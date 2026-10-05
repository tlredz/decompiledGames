local OctreeRegionUtils = require(script.Parent.OctreeRegionUtils)
local OctreeNode = {
	ClassName = "OctreeNode"
}
OctreeNode.__index = OctreeNode

function OctreeNode.new(p, p2)
	local self = setmetatable({}, OctreeNode)
	self._octree = p or error("No octree")
	self._object = p2 or error("No object")
	self._currentLowestRegion = nil
	self._position = nil
	return self
end

function OctreeNode:KNearestNeighborsSearch(p2, p3)
	return self._octree:KNearestNeighborsSearch(self._position, p2, p3)
end

function OctreeNode:GetObject()
	return self._object
end

function OctreeNode:RadiusSearch(p2)
	return self._octree:RadiusSearch(self._position, p2)
end

function OctreeNode:GetPosition()
	return self._position
end

function OctreeNode:GetRawPosition()
	return self._px, self._py, self._pz
end

function OctreeNode:SetPosition(position)
	if self._position == position then
		return
	end

	local x = position.x
	local y = position.y
	local z = position.z
	self._px = x
	self._py = y
	self._pz = z
	self._position = position

	if self._currentLowestRegion and OctreeRegionUtils.inRegionBounds(self._currentLowestRegion, x, y, z) then
		return
	end

	local orCreateLowestSubRegion = self._octree:GetOrCreateLowestSubRegion(x, y, z)

	if self._currentLowestRegion then
		OctreeRegionUtils.moveNode(self._currentLowestRegion, orCreateLowestSubRegion, self)
	else
		OctreeRegionUtils.addNode(orCreateLowestSubRegion, self)
	end

	self._currentLowestRegion = orCreateLowestSubRegion
end

function OctreeNode:Destroy()
	if self._currentLowestRegion then
		OctreeRegionUtils.removeNode(self._currentLowestRegion, self)
	end
end

return OctreeNode