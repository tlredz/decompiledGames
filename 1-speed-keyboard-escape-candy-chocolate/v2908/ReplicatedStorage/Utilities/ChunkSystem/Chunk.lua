local createVector = vector.create
local Chunk = {}
Chunk.__index = Chunk

function Chunk.new(chunkSystem, position)
	local self = setmetatable({}, Chunk)
	self.ChunkSystem = chunkSystem
	self.Objects = {}
	self.Position = position
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Fill(list, objects)
	for i = 1, #objects do
		local v = objects[i]

		if v then
			table.insert(list, v)
		end
	end
end

function Chunk:GetObjects(p)
	if not p then
		return self.Objects
	end

	local v = {}
	Fill(v, self.Objects) -- equivalent call inferred; original call site unknown

	if p == "Adjacent" then
		local _getAdjacentChunks = self:_getAdjacentChunks()

		if _getAdjacentChunks then
			for i = 1, #_getAdjacentChunks do
				local _getAdjacentChunk = _getAdjacentChunks[i]

				if not _getAdjacentChunk then
					continue
				end

				Fill(v, _getAdjacentChunk.Objects) -- equivalent call inferred; original call site unknown
			end

			return v
		end
	elseif p == "Surrounding" then
		local _getSurroundingChunks = self:_getSurroundingChunks()

		if _getSurroundingChunks then
			for i = 1, #_getSurroundingChunks do
				local _getSurroundingChunk = _getSurroundingChunks[i]

				if not _getSurroundingChunk then
					continue
				end

				Fill(v, _getSurroundingChunk.Objects) -- equivalent call inferred; original call site unknown
			end
		end
	end

	return v
end

function Chunk:AddObject(p)
	self:_addObject(p)
end

function Chunk:AddObjects(list)
	for i = 1, #list do
		local v = list[i]

		if v then
			self:_addObject(v)
		end
	end
end

function Chunk:RemoveObject(p)
	self:_removeObject(p)
end

function Chunk:ObjectExists(p)
	self:_objectExists(p)
end

function Chunk:GetAdjacentChunks()
	return self:_getAdjacentChunks()
end

function Chunk:GetSurroundingChunks()
	return self:_getSurroundingChunks()
end

function Chunk:GetPosition()
	return self.Position
end

function Chunk:_draw(p)
	if not self.Drawn then
		self.Drawn = true
		local part = Instance.new("Part", workspace)
		part.Anchored = true
		part.Transparency = 0.5
		part.Size = createVector(1, 1, 1) * self.ChunkSystem.ChunkSize
		part.CFrame = CFrame.new(self.Position)
		delay(p, function()
			self.Drawn = false
			part:Destroy()
		end)
	end
end

function Chunk:_addObject(value)
	assert(typeof(value) == "Instance" or typeof(value) == "table", "Object must be an instance or a table!")
	table.insert(self.Objects, value)
end

function Chunk:_removeObject(value)
	assert(typeof(value) == "Instance" or typeof(value) == "table", "Object must be an instance or a table!")

	for i = 1, #self.Objects do
		if self.Objects[i] == value then
			table.remove(self.Objects, i)
		end
	end
end

function Chunk:_objectExists(value)
	assert(typeof(value) == "Instance" or typeof(value) == "table", "Object must be an instance or a table!")

	for i = 1, #self.Objects do
		if self.Objects[i] == value then
			return true
		end
	end

	return false
end

function Chunk:_getAdjacentChunks()
	local chunkSystem = self.ChunkSystem
	local chunkSize = chunkSystem.ChunkSize
	local dimensions = chunkSystem.Dimensions
	local position = self:GetPosition()

	if dimensions == 2 then
		local x = position.x
		local z = position.z
		return {
			chunkSystem:_getChunkXY(x - chunkSize, z),
			chunkSystem:_getChunkXY(x + chunkSize, z),
			chunkSystem:_getChunkXY(x, z - chunkSize),
			chunkSystem:_getChunkXY(x, z + chunkSize)
		}
	else
		if dimensions ~= 3 then
			return
		end

		local x = position.x
		local y = position.y
		local z = position.z
		return {
			chunkSystem:_getChunkXYZ(x - chunkSize, y, z),
			chunkSystem:_getChunkXYZ(x + chunkSize, y, z),
			chunkSystem:_getChunkXYZ(x, y - chunkSize, z),
			chunkSystem:_getChunkXYZ(x, y + chunkSize, z),
			chunkSystem:_getChunkXYZ(x, y, z - chunkSize),
			chunkSystem:_getChunkXYZ(x, y, z + chunkSize)
		}
	end
end

function Chunk:_getSurroundingChunks()
	local chunkSystem = self.ChunkSystem
	local chunkSize = chunkSystem.ChunkSize
	local dimensions = chunkSystem.Dimensions
	local position = self:GetPosition()

	if dimensions == 2 then
		local x = position.x
		local z = position.z
		local result = {}

		for i = x - chunkSize, x + chunkSize, chunkSize do
			for i2 = z - chunkSize, z + chunkSize, chunkSize do
				local _getChunkXY = chunkSystem:_getChunkXY(i, i2)

				if _getChunkXY and _getChunkXY ~= self then
					table.insert(result, _getChunkXY)
				end
			end
		end

		return result
	else
		if dimensions ~= 3 then
			return
		end

		local x = position.x
		local y = position.y
		local z = position.z
		local result = {}

		for i = x - chunkSize, x + chunkSize, chunkSize do
			for i2 = y - chunkSize, y + chunkSize, chunkSize do
				for i3 = z - chunkSize, z + chunkSize, chunkSize do
					local _getChunkXYZ = chunkSystem:_getChunkXYZ(i, i2, i3)

					if _getChunkXYZ and _getChunkXYZ ~= self then
						table.insert(result, _getChunkXYZ)
					end
				end
			end
		end

		return result
	end
end

return Chunk