local OctreeNode = {
	ClassName = "OctreeNode"
}
OctreeNode.__index = OctreeNode

function OctreeNode.new(p, p2)
	return (setmetatable({
		Octree = p or error("No octree"),
		Object = p2 or error("No object"),
		CurrentLowestRegion = nil,
		Position = nil,
		PositionX = nil,
		PositionY = nil,
		PositionZ = nil
	}, OctreeNode))
end

function OctreeNode:KNearestNeighborsSearch(p2: number, p3: number)
	return self.Octree:KNearestNeighborsSearch(self.Position, p2, p3)
end

function OctreeNode.GetObject(p)
	warn("OctreeNode:GetObject is deprecated.")
	return p.Object
end

function OctreeNode:RadiusSearch(p2: number)
	return self.Octree:RadiusSearch(self.Position, p2)
end

function OctreeNode.GetPosition(p)
	warn("OctreeNode:GetPosition is deprecated.")
	return p.Position
end

function OctreeNode.GetRawPosition(data)
	return data.PositionX, data.PositionY, data.PositionZ
end

function OctreeNode:SetPosition(position: Vector3)
	if self.Position == position then
		return
	end

	local X = position.X
	local Y = position.Y
	local Z = position.Z
	self.PositionX = X
	self.PositionY = Y
	self.PositionZ = Z
	self.Position = position

	if self.CurrentLowestRegion then
		local currentLowestRegion = self.CurrentLowestRegion
		local lowerBounds = currentLowestRegion.LowerBounds
		local upperBounds = currentLowestRegion.UpperBounds

		if lowerBounds[1] <= X and X <= upperBounds[1] and lowerBounds[2] <= Y and Y <= upperBounds[2] and lowerBounds[3] <= Z and Z <= upperBounds[3] then
			return
		end
	end

	local orCreateLowestSubRegion = self.Octree:GetOrCreateLowestSubRegion(X, Y, Z)

	if self.CurrentLowestRegion then
		local currentLowestRegion = self.CurrentLowestRegion

		if currentLowestRegion.Depth ~= orCreateLowestSubRegion.Depth then
			error("fromLowest.Depth ~= toLowest.Depth")
		end

		if currentLowestRegion == orCreateLowestSubRegion then
			error("fromLowest == toLowest")
		end

		local parent = orCreateLowestSubRegion

		while currentLowestRegion ~= parent do
			local nodes = currentLowestRegion.Nodes

			if not nodes[self] then
				error("CurrentFrom.Nodes doesn't have a node here.")
			end

			local nodeCount = currentLowestRegion.NodeCount

			if nodeCount <= 0 then
				error("NodeCount is <= 0.")
			end

			local nodeCount2 = nodeCount - 1
			nodes[self] = nil
			currentLowestRegion.NodeCount = nodeCount2
			local parentIndex = currentLowestRegion.ParentIndex

			if nodeCount2 <= 0 and parentIndex then
				local parent2 = currentLowestRegion.Parent

				if not parent2 then
					error("CurrentFrom.Parent doesn't exist.")
				end

				local subRegions = parent2.SubRegions

				if subRegions[parentIndex] ~= currentLowestRegion then
					error("Failed equality check.")
				end

				subRegions[parentIndex] = nil
			end

			local nodes2 = parent.Nodes

			if nodes2[self] then
				error("CurrentTo.Nodes already has a node here.")
			end

			nodes2[self] = self
			parent.NodeCount += 1
			currentLowestRegion = currentLowestRegion.Parent
			parent = parent.Parent
		end
	else
		local parent = orCreateLowestSubRegion

		while parent do
			local nodes = parent.Nodes

			if not nodes[self] then
				nodes[self] = self
				parent.NodeCount += 1
			end

			parent = parent.Parent
		end
	end

	self.CurrentLowestRegion = orCreateLowestSubRegion
end

function OctreeNode.Destroy(p)
	local currentLowestRegion = p.CurrentLowestRegion

	if currentLowestRegion then
		while currentLowestRegion do
			local nodes = currentLowestRegion.Nodes

			if not nodes[p] then
				error("CurrentFrom.Nodes doesn't have a node here.")
			end

			local nodeCount = currentLowestRegion.NodeCount

			if nodeCount <= 0 then
				error("NodeCount is <= 0.")
			end

			local nodeCount2 = nodeCount - 1
			nodes[p] = nil
			currentLowestRegion.NodeCount = nodeCount2
			local parent = currentLowestRegion.Parent
			local parentIndex = currentLowestRegion.ParentIndex

			if nodeCount2 <= 0 and parentIndex then
				if not parent then
					error("Current.Parent doesn't exist.")
				end

				local subRegions = parent.SubRegions

				if subRegions[parentIndex] ~= currentLowestRegion then
					error("Failed equality check.")
				end

				subRegions[parentIndex] = nil
			end

			currentLowestRegion = parent
		end
	end
end

return OctreeNode