local Grid = {}
Grid.__index = Grid

function Grid.new(value)
	local self = setmetatable({}, Grid)
	self.CellSize = value or 2000
	self.Grid = {}
	return self
end

function Grid:GetGridCoordinates(p2)
	return math.floor(p2.X / self.CellSize), (math.floor(p2.Z / self.CellSize))
end

function Grid:GetCell(gridX, gridZ)
	if not self.Grid[gridX] then
		self.Grid[gridX] = {}
	end

	if not self.Grid[gridX][gridZ] then
		self.Grid[gridX][gridZ] = {
			GridX = gridX,
			GridZ = gridZ,
			WorldX = gridX * self.CellSize,
			WorldZ = gridZ * self.CellSize,
			Objects = {}
		}
	end

	return self.Grid[gridX][gridZ]
end

function Grid:GetCurrentGrid(p)
	local gridCoordinates, v = self:GetGridCoordinates(p)
	return self:GetCell(gridCoordinates, v)
end

function Grid:GetNeighboringCells(p, value)
	local v = value or 1
	local gridCoordinates, v2 = self:GetGridCoordinates(p)
	local cells = {}

	for i = gridCoordinates - v, gridCoordinates + v do
		for i2 = v2 - v, v2 + v do
			if i ~= gridCoordinates or i2 ~= v2 then
				table.insert(cells, self:GetCell(i, i2))
			end
		end
	end

	return cells
end

function Grid:GetCellsInRadius(p, value)
	local v = value or 1
	local gridCoordinates, v2 = self:GetGridCoordinates(p)
	local cells = {}

	for i = gridCoordinates - v, gridCoordinates + v do
		for i2 = v2 - v, v2 + v do
			table.insert(cells, self:GetCell(i, i2))
		end
	end

	return cells
end

function Grid:AddObject(p, p2)
	local currentGrid = self:GetCurrentGrid(p2)

	if table.find(currentGrid.Objects, p) then
		return currentGrid
	end

	table.insert(currentGrid.Objects, p)
	return currentGrid
end

function Grid:RemoveObject(p, p2)
	local currentGrid = self:GetCurrentGrid(p2)

	for i, object2 in ipairs(currentGrid.Objects) do
		if object2 ~= p then
			continue
		end

		table.remove(currentGrid.Objects, i)
		break
	end
end

function Grid:MoveObject(p, p2, p3)
	self:RemoveObject(p, p2)
	self:AddObject(p, p3)
end

function Grid:GetObjectsInCurrentCell(p)
	return self:GetCurrentGrid(p).Objects
end

function Grid:GetObjectsInNeighboringCells(p, p2)
	local neighboringCells = self:GetNeighboringCells(p, p2)
	local result = {}

	for _, neighboringCell in ipairs(neighboringCells) do
		for _, object2 in ipairs(neighboringCell.Objects) do
			table.insert(result, object2)
		end
	end

	return result
end

function Grid.GetCellCenter(p, p2, p3)
	return (Vector3.new(p2 * p.CellSize + p.CellSize / 2, 0, p3 * p.CellSize + p.CellSize / 2))
end

return Grid