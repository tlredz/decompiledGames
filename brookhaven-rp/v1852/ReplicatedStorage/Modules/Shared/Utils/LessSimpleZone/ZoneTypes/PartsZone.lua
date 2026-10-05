local parent = script.Parent.Parent
require(parent.Types)
local SimpleZone = require(parent.SimpleZone)
local Vertices = require(parent.Vertices)
local CreateQueryFunction = require(script.CreateQueryFunction)
local Utility = require(script.Utility)
local BVH = SimpleZone.BVH
local v = {}
setmetatable(v, {
	__index = SimpleZone.ZoneClass
})

function v:UpdateVolume(parts)
	local boxesVertices, points = Utility.getBoxesVertices(Vertices, parts)
	self._volume = {
		points = points,
		parts = parts,
		bvh = BVH.createBVH(boxesVertices)
	}
end

function v:GetRandomPoint()
	local points = self._volume.points
	local point = points[math.random(1, #points)]
	return Utility.getRandomPointInSimplex(3, point)
end

function v:IsPointWithinZone(vector: Vector3)
	for _, box in self._volume.boxes do
		local cframe = box.cframe
		local size = box.size

		if Utility.isPointInBox(vector, cframe, size) and Utility.isPointInShape(vector, box.part) then
			return true
		end
	end

	return false
end

function v:CombineWith(p)
	if p._ztype ~= "Parts" then
		warn("Can only merge Parts zones with other Parts zones.")
		return
	end

	local _volume = p._volume
	local parts = self._volume.parts
	self:UpdateVolume((table.move(_volume.parts, 1, #_volume.parts, #parts + 1, parts)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initializeVolume(parts)
	local boxesVertices, points = Utility.getBoxesVertices(Vertices, parts)
	return {
		points = points,
		boxes = boxesVertices,
		parts = parts,
		bvh = BVH.createBVH(boxesVertices)
	}
end

local function pz_new(parts, p2)
	local volume = initializeVolume(parts) -- equivalent call inferred; original call site unknown
	local internal = SimpleZone.newInternal(p2, CreateQueryFunction(BVH), v)
	internal._ztype = "Parts"
	internal._volume = volume
	return internal
end

return pz_new