local module = require("./Matrix/Tetrominoes")
local Matrix = {}
Matrix.__index = Matrix

function Matrix.new(template)
	local self = setmetatable({}, Matrix)
	self.grid = {}
	self.template = template
	self.rows = #template
	self.cols = #template[1]
	self:reset()
	return self
end

function Matrix:reset()
	table.clear(self.grid)

	for k, v in pairs(self.template) do
		self.grid[k] = table.clone(v)
	end
end

function Matrix.print(data)
	for i = data.rows, 1, -1 do
		local v = ""

		for i2 = 1, data.cols do
			v ..= `{data.grid[i][i2]}`
		end

		print(v)
	end
end

function Matrix:computeBlocks(flag: boolean)
	local function shuffle(list)
		for i = #list, 2, -1 do
			local v = math.random(i)
			local v2 = list[v]
			local v3 = list[i]
			list[i] = v2
			list[v] = v3
		end

		return list
	end

	local function getBlockOptions()
		return (shuffle(table.clone(module.getLegalTypes())))
	end

	self:reset()
	local v = shuffle(table.clone(module.getLegalTypes()))
	local result = {}

	for i = 1, self.rows do
		for i2 = 1, self.cols do
			if self.grid[i][i2] ~= 1 then
				continue
			end

			local validBlock, v2 = self:getValidBlock(i, i2, v)

			if not validBlock then
				continue
			end

			table.insert(result, self:placeBlock(i, i2, validBlock, v2))
			table.remove(v, table.find(v, validBlock))

			if #v == 0 then
				v = shuffle(table.clone(module.getLegalTypes()))
			end
		end
	end

	local illegalTypes = module.getIllegalTypes()

	for i = 1, self.rows do
		for i2 = 1, self.cols do
			if self.grid[i][i2] ~= 1 then
				continue
			end

			local validBlock, v2 = self:getValidBlock(i, i2, illegalTypes)
			table.insert(result, self:placeBlock(i, i2, validBlock, v2))
		end
	end

	if flag ~= true then
		return result
	end

	local function arePiecesTouching(data, data2)
		local tetrominoCoordinates = module.getTetrominoCoordinates(data.block_type, data.rotation)
		local tetrominoCoordinates2 = module.getTetrominoCoordinates(data2.block_type, data2.rotation)

		if not (tetrominoCoordinates and tetrominoCoordinates2) then
			return false
		end

		local v2 = {}

		for _, tetrominoCoordinate in ipairs(tetrominoCoordinates) do
			table.insert(v2, { data.position.X + tetrominoCoordinate[1], data.position.Y + tetrominoCoordinate[2] })
		end

		local v3 = {}

		for _, tetrominoCoordinate in ipairs(tetrominoCoordinates2) do
			table.insert(v3, { data2.position.X + tetrominoCoordinate[1], data2.position.Y + tetrominoCoordinate[2] })
		end

		for _, v4 in ipairs(v2) do
			for _, v5 in ipairs(v3) do
				if math.abs(v4[1] - v5[1]) + math.abs(v4[2] - v5[2]) == 1 then
					return true
				end
			end
		end

		return false
	end

	local v2 = nil
	local v3 = nil

	if #result >= 2 then
		local function getShuffledIndexArray(_: number)
			local v4 = {}

			for i = 1, #result do
				v4[i] = i
			end

			return (shuffle(v4))
		end

		local _ = #result
		local v4 = {}

		for i = 1, #result do
			v4[i] = i
		end

		local v5 = shuffle(v4)

		for i = 1, 20 do
			local v6 = result[v5[(i - 1) % #result + 1]]

			if v6.block_type == "Mono" then
				if i == 20 then
					v2 = v6
				end
			else
				v2 = v6
				break
			end
		end

		local _ = #result
		local v6 = {}

		for i = 1, #result do
			v6[i] = i
		end

		local v7 = shuffle(v6)

		for i = 1, 20 do
			local v8 = result[v7[(i - 1) % #result + 1]]

			if v8 == v2 or v8.block_type == "Mono" or arePiecesTouching(v2, v8) then
				if i == 20 then
					v3 = v8
				end
			else
				v3 = v8
				break
			end
		end
	end

	if v2 and v3 then
		local v4 = { v2, v3 }
		self:reset()

		for _, v5 in ipairs(v4) do
			self:placeBlock(v5.position.X, v5.position.Y, v5.block_type, v5.rotation)
		end

		result = v4
	end

	return result
end

function Matrix:getValidBlock(p: number, p2: number, items)
	for _, item in pairs(items) do
		local tetrominoRotations = module.getTetrominoRotations(item)
		local v = math.random(tetrominoRotations)

		for i = 1, tetrominoRotations do
			local v2 = (v + i) % tetrominoRotations + 1

			if self:canPlaceBlock(p, p2, item, v2) then
				return item, v2
			end
		end
	end

	return nil, -1
end

function Matrix:canPlaceBlock(p: number, p2: number, p3: string, p4: number)
	local tetrominoCoordinates = module.getTetrominoCoordinates(p3, p4)

	if not tetrominoCoordinates then
		return false
	end

	for _, tetrominoCoordinate in pairs(tetrominoCoordinates) do
		local v = p + tetrominoCoordinate[1]
		local v2 = p2 + tetrominoCoordinate[2]

		if v < 1 or self.rows < v or v2 < 1 or self.cols < v2 then
			return false
		end

		if self.grid[v][v2] ~= 1 then
			return false
		end
	end

	return true
end

function Matrix:placeBlock(p2: number, p3: number, block_type: string, rotation: number)
	local tetrominoCoordinates = module.getTetrominoCoordinates(block_type, rotation)

	if not tetrominoCoordinates then
		return nil
	end

	for _, tetrominoCoordinate in pairs(tetrominoCoordinates) do
		local v = p2 + tetrominoCoordinate[1]
		local v2 = p3 + tetrominoCoordinate[2]
		self.grid[v][v2] = 0
	end

	return {
		position = Vector2.new(p2, p3),
		rotation = rotation,
		block_type = block_type
	}
end

return Matrix