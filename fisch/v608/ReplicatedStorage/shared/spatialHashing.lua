local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.jecs)
local world = require(ReplicatedStorage.shared.ecs.world)
local components = require(ReplicatedStorage.shared.ecs.components)
local chunks = {}

local function getChunkedVector(vector2: Vector3)
	return (vector.create(vector2.x // 50, 0, vector2.z // 50))
end

local SpatialHashing = {}
SpatialHashing.chunks = chunks

function SpatialHashing.insertChunkAt(vector2: Vector3)
	assert(chunks[vector2] == nil, (`chunk {vector2} already exists`))
	assert(vector.create(vector2.x // 50, 0, vector2.z // 50) == vector2, (`invalid chunk vector {vector2}`))
	local entity = world:entity()
	world:set(entity, components.SpatialChunk, {})
	world:set(entity, components.Position, vector2)
	return entity
end

function SpatialHashing.getChunkAt(vector2: Vector3)
	return chunks[vector.create(vector2.x // 50, 0, vector2.z // 50)]
end

function SpatialHashing.getChunkVectorFromVector(vector2: Vector3)
	return (vector.create(vector2.x // 50, 0, vector2.z // 50))
end

function SpatialHashing.getVectorFromChunkVector(vector2: Vector3)
	return vector2 * 50
end

return SpatialHashing