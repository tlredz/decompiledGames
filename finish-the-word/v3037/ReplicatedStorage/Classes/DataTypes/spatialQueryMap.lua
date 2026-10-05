local createVector = vector.create
local import = _G.import("vectorUtil")
local floor2 = import.floor2
local _ = import.ceil2
local SpatialQueryMap = {
	prototype = {}
}

function SpatialQueryMap.new(offset, p2, cellSize)
	return (setmetatable({
		Cells = {},
		Size = floor2(p2 / cellSize),
		Offset = offset,
		CellSize = cellSize
	}, {
		__index = SpatialQueryMap.prototype
	}))
end

function SpatialQueryMap.prototype.addCell(p, p2)
	p.Cells[p2] = {}
	return p.Cells[p2]
end

function SpatialQueryMap.prototype:getCell(p)
	local cellId = self:getCellId(p)
	local cells = self.Cells
	local selected = cells[cellId] or {}
	cells[cellId] = selected
	return selected
end

function SpatialQueryMap.prototype:getCellVec(p2)
	return floor2((Vector2.new(p2.X, p2.Z) - self.Offset) / self.CellSize)
end

function SpatialQueryMap.prototype:getCellId(p)
	local cellVec = self:getCellVec(p)
	local size = self.Size
	return cellVec.X + cellVec.Y * size.X
end

function SpatialQueryMap.prototype:getPartCell(p)
	return self:getCell(p.Position)
end

function SpatialQueryMap.prototype:insert(p)
	local partCell = self:getPartCell(p)
	partCell[p] = true
end

function SpatialQueryMap.prototype:remove(p)
	local partCell = self:getPartCell(p)
	partCell[p] = nil
end

function SpatialQueryMap.prototype:getCellPos(p)
	local v = self:getCellVec(p) * self.CellSize + self.Offset
	return Vector3.new(v.X, 0, v.Y) + createVector(1, 0, 1) * self.CellSize / 2
end

function SpatialQueryMap.prototype:iter(p, callback)
	local cellPos = self:getCellPos(p)

	for k, _ in pairs(self:getCell(cellPos)) do
		local v = callback(k)

		if v ~= 1 and v == 2 then
			break
		end
	end

	for i = 0, 7 do
		local v = 0.7853981633974483 * i
		local v2 = Vector3.new(math.sin(v), 0, (math.cos(v))) * self.CellSize

		for k, _ in pairs(self:getCell(self:getCellPos(cellPos + v2))) do
			local v4 = callback(k)

			if v4 ~= 1 and v4 == 2 then
				break
			end
		end
	end
end

function SpatialQueryMap.prototype:has(p)
	local v = nil
	self:iter(p, function()
		v = true
		return 2
	end)
	return v
end

return SpatialQueryMap