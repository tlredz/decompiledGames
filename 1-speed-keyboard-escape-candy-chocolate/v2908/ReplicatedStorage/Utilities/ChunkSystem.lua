local ChunkSystem = {}
ChunkSystem.__index = ChunkSystem

-- equivalent calls inferred from this helper; original call sites unknown
local function Round(p, chunkSize)
	return math.floor(p / chunkSize + 0.5) * chunkSize
end

local function Round2D(p, p2)
	return Round(p.x, p2), Round(p.z, p2)
end

local function Round3D(data, p)
	return Round(data.x, p), Round(data.y, p), Round(data.z, p)
end

local Chunk = require(script.Chunk)

function ChunkSystem.new(dimensions, value)
	local self = setmetatable({}, ChunkSystem)

	if dimensions ~= 2 and dimensions ~= 3 then
		warn("Must be two or three dimensions!")
		return
	end

	if not value or typeof(value) ~= "number" then
		warn("No specified chunk size!")
		return
	end

	local chunkSize = Round(value, 1) -- equivalent call inferred; original call site unknown
	self.Dimensions = dimensions
	self.ChunkSize = chunkSize
	self.Grid = {}
	return self
end

function ChunkSystem:GetChunk(p, p2)
	self:_assertPosition(p)
	local _getChunk = self:_getChunk(p)

	if _getChunk then
		return _getChunk
	end

	if p2 then
		return self:_createChunk(p)
	end
end

function ChunkSystem:RemoveChunk(p)
	self:_removeChunk(p)
end

function ChunkSystem:_assertPosition(p)
	local typeName = typeof(p)
	assert(typeName == "Vector3", (`Input Position must be a Vector3! Got: {typeName}`))
end

function ChunkSystem:_getChunk(data)
	if self.Dimensions == 2 then
		local chunkSize = self.ChunkSize
		return self:_getChunkXY(Round(data.x, chunkSize), Round(data.z, chunkSize))
	end

	local chunkSize = self.ChunkSize
	return self:_getChunkXYZ(Round(data.x, chunkSize), Round(data.y, chunkSize), Round(data.z, chunkSize))
end

function ChunkSystem:_getChunkXY(p2, p3)
	local grid = self.Grid

	if grid[p2] then
		return grid[p2][p3]
	end
end

function ChunkSystem:_getChunkXYZ(p2, p3, p4)
	local grid = self.Grid

	if grid[p2] and grid[p2][p3] then
		return grid[p2][p3][p4]
	end
end

function ChunkSystem:_createChunk(data2)
	if self.Dimensions == 2 then
		local chunkSize = self.ChunkSize
		local round = Round(data2.x, chunkSize) -- equivalent call inferred; original call site unknown
		local round2 = Round(data2.z, chunkSize) -- equivalent call inferred; original call site unknown
		local grid = self.Grid

		if not grid[round] then
			grid[round] = {}
		end

		local v3 = grid[round][round2]

		if not v3 then
			v3 = Chunk.new(self, (Vector3.new(round, 0, round2)))
			grid[round][round2] = v3
		end

		return v3
	else
		local chunkSize = self.ChunkSize
		local round = Round(data2.x, chunkSize) -- equivalent call inferred; original call site unknown
		local round2 = Round(data2.y, chunkSize) -- equivalent call inferred; original call site unknown
		local round3 = Round(data2.z, chunkSize) -- equivalent call inferred; original call site unknown
		local grid = self.Grid

		if not grid[round] then
			grid[round] = {}
		end

		if not grid[round][round2] then
			grid[round][round2] = {}
		end

		local v4 = grid[round][round2][round3]

		if not v4 then
			v4 = Chunk.new(self, (Vector3.new(round, round2, round3)))
			grid[round][round2][round3] = v4
		end

		return v4
	end
end

function ChunkSystem:_removeChunk(data2)
	if self.Dimensions == 2 then
		local chunkSize = self.ChunkSize
		local round = Round(data2.x, chunkSize) -- equivalent call inferred; original call site unknown
		local round2 = Round(data2.z, chunkSize) -- equivalent call inferred; original call site unknown
		local grid = self.Grid

		if grid[round] and grid[round][round2] then
			grid[round][round2] = nil
		end
	else
		local chunkSize = self.ChunkSize
		local round = Round(data2.x, chunkSize) -- equivalent call inferred; original call site unknown
		local round2 = Round(data2.y, chunkSize) -- equivalent call inferred; original call site unknown
		local round3 = Round(data2.z, chunkSize) -- equivalent call inferred; original call site unknown
		local grid = self.Grid

		if grid[round] and grid[round][round2] and grid[round][round2][round3] then
			grid[round][round2][round3] = nil
		end
	end
end

return ChunkSystem