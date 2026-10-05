local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetWanderArea = require(script.Parent.AssetWanderArea)
require(ReplicatedStorage.Data.Assets)
local frozen = table.freeze({
	0,
	0.6108652381980153,
	-0.6108652381980153,
	1.2217304763960306,
	-1.2217304763960306,
	1.8325957145940461,
	-1.8325957145940461,
	2.443460952792061,
	-2.443460952792061,
	3.141592653589793
})

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateLocalFlatDirection(unit: Vector3, p: number)
	local v = math.cos(p)
	local v2 = math.sin(p)
	return (Vector3.new(unit.X * v - unit.Z * v2, 0, unit.X * v2 + unit.Z * v))
end

local function distanceToAreaEdge(p, pointToObjectSpace: Vector3, unit: Vector3)
	local halfExtents, v = AssetWanderArea.HalfExtents(p)
	local v2 = 1e999
	local v3 = 1e999

	if unit.X > 0 then
		v2 = (halfExtents - pointToObjectSpace.X) / unit.X
	elseif unit.X < 0 then
		v2 = (-halfExtents - pointToObjectSpace.X) / unit.X
	end

	if unit.Z > 0 then
		v3 = (v - pointToObjectSpace.Z) / unit.Z
	elseif unit.Z < 0 then
		v3 = (-v - pointToObjectSpace.Z) / unit.Z
	end

	return (math.max(math.min(v2, v3) - 2, 0))
end

local function ownerAwayDirection(instance, vector: Vector3, vector2: Vector3)
	local DISTANCE_THRESHOLD = 0
	local vector3 = Vector3.new(vector2.X - vector.X, 0, vector2.Z - vector.Z)

	if vector3.Magnitude > DISTANCE_THRESHOLD then
		return vector3.Unit
	end

	local vector4 = Vector3.new(vector2.X - instance.Position.X, 0, vector2.Z - instance.Position.Z)

	if vector4.Magnitude > DISTANCE_THRESHOLD then
		return vector4.Unit
	end

	local lookVector = instance.CFrame.LookVector
	local vector5 = Vector3.new(lookVector.X, 0, lookVector.Z)
	assert(vector5.Magnitude > DISTANCE_THRESHOLD, "Asset area must provide a horizontal retreat direction")
	return vector5.Unit
end

return {
	Destination = function(p, p2, p3, vector: Vector3, vector2: Vector3)
		local pointToObjectSpace = p.CFrame:PointToObjectSpace(vector2)
		local v = ownerAwayDirection(p, vector, vector2)
		local vectorToObjectSpace = p.CFrame:VectorToObjectSpace(v)
		local vector3 = Vector3.new(vectorToObjectSpace.X, 0, vectorToObjectSpace.Z)
		assert(vector3.Magnitude > 0, "Retreat direction must be horizontal")
		local unit = vector3.Unit
		local v2 = unit
		local v3 = -1e999
		local v4 = 0

		for _, v5 in ipairs(frozen) do
			local unit2 = (rotateLocalFlatDirection(unit, v5)).Unit
			local v6 = distanceToAreaEdge(p, pointToObjectSpace, unit2)
			local v7 = v6 * (math.max(unit2:Dot(unit), 0) + 0.6)

			if not (v3 < v7) then
				continue
			end

			v2 = unit2
			v4 = v6
			v3 = v7
		end

		if v4 <= 0 then
			return AssetWanderArea.RandomPoint(p, p2)
		end

		if p3.MaxTravelDistance ~= nil then
			v4 = math.min(p3.MaxTravelDistance, v4)
		end

		local v5 = pointToObjectSpace + v2 * v4
		return (p.CFrame * CFrame.new(v5.X, 0, v5.Z)).Position
	end
}