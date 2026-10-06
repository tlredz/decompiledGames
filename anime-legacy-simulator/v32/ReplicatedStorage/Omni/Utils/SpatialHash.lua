local class = {}
class.__index = class

function class:GetCellFromPosition(vector: Vector3, p: number)
	return math.floor(vector.X / p), math.floor(vector.Y / p), (math.floor(vector.Z / p))
end

function class:GetGrid(size: number)
	local result = {}

	if self.GridCooldown then
		local now = tick()
		local v = now - self.LastGridUpdate

		if self.CachedGrid and v < self.GridCooldown and size == self.CachedGrid.Size then
			return self.CachedGrid.List
		else
			self.LastGridUpdate = now
		end
	end

	for _, object2 in self.Objects do
		local cellFromPosition, v, v2 = self:GetCellFromPosition(object2.Position, size)
		local v3 = cellFromPosition .. "," .. v .. "," .. v2
		result[v3] = result[v3] or {}
		table.insert(result[v3], object2)
	end

	self.CachedGrid = {
		List = result,
		Size = size
	}
	return result
end

function class.Insert(p, p2)
	if table.find(p.Objects, p2) then
		return
	end

	table.insert(p.Objects, p2)
end

function class.Remove(p, p2)
	local index = table.find(p.Objects, p2)

	if not index then
		return
	end

	table.remove(p.Objects, index)
end

function class:ResetCooldown()
	self.CachedGrid = nil
end

function class:GetNearby(vector: Vector3, p: number)
	local grid = self:GetGrid(p)
	local cellFromPosition, v, v2 = self:GetCellFromPosition(vector, p)
	local result = {}

	for i = -1, 1 do
		for i2 = -1, 1 do
			for i3 = -1, 1 do
				local v3 = cellFromPosition + i .. "," .. v + i2 .. "," .. v2 + i3

				if not grid[v3] then
					continue
				end

				for _, v4 in ipairs(grid[v3]) do
					table.insert(result, v4)
				end
			end
		end
	end

	return result
end

return {
	new = function(gridCooldown: number?)
		local self = setmetatable({}, class)
		self.Objects = {}
		self.CachedGrid = nil
		self.LastGridUpdate = 0
		self.GridCooldown = gridCooldown
		return self
	end
}