local parent = script.Parent.Parent
require(parent.Types)
local SimpleZone = require(parent.SimpleZone)
local CreateQueryFunction = require(script.CreateQueryFunction)
local BVH = SimpleZone.BVH
local v = {}
setmetatable(v, {
	__index = SimpleZone.ZoneClass
})

function v:UpdateVolume(boxes)
	local BVH2, leaves = BVH.createBVH(boxes)
	self._volume = {
		bvh = BVH2,
		leaves = leaves,
		boxes = boxes
	}
end

function v:GetRandomPoint()
	local leaves = self._volume.leaves

	if #leaves == 0 then
		warn("No leaf nodes found in BVH!")
		return nil
	end

	local leave = leaves[math.random(1, #leaves)]
	local cframe = leave.cframe
	local size = leave.size
	return (cframe:PointToWorldSpace((Vector3.new(
		math.random() * size.X - size.X / 2,
		math.random() * size.Y - size.Y / 2,
		math.random() * size.Z - size.Z / 2
	))))
end

function v:IsPointWithinZone(vector: Vector3)
	for _, leave in self._volume.leaves do
		local halfSize = leave.size / 2
		local pointToObjectSpace = leave.cframe:PointToObjectSpace(vector)
		local v4 = math.abs(pointToObjectSpace.X) <= halfSize.X
		local v5 = math.abs(pointToObjectSpace.Y) <= halfSize.Y
		local v6 = math.abs(pointToObjectSpace.Z) <= halfSize.Z

		if v4 and v5 and v6 then
			return true
		end
	end

	return false
end

function v:CombineWith(p)
	if p._ztype ~= "Boxes" then
		warn("Can only merge Boxes zones with other Boxes zones.")
		return
	end

	local _volume = p._volume
	local boxes = self._volume.boxes
	self:UpdateVolume((table.move(_volume.boxes, 1, #_volume.boxes, #boxes + 1, boxes)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initializeVolume(p)
	local BVH2, leaves = BVH.createBVH(p)
	return {
		bvh = BVH2,
		leaves = leaves
	}
end

local function bz_new(p, p2)
	local volume = initializeVolume(p) -- equivalent call inferred; original call site unknown
	local internal = SimpleZone.newInternal(p2, CreateQueryFunction(BVH), v)
	internal._ztype = "Boxes"
	internal._volume = volume
	return internal
end

return bz_new