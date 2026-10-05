local value = Enum.PartType.Block.Value
local value2 = Enum.PartType.Ball.Value
local value3 = Enum.PartType.Cylinder.Value
local value4 = Enum.PartType.Wedge.Value
local value5 = Enum.PartType.CornerWedge.Value
local v = table.create(1024)

for i = 0, 1023 do
	local v2 = bit32.band(bit32.bor(bit32.lshift(i, 16), i), 4278190335)
	local v3 = bit32.band(bit32.bor(bit32.lshift(v2, 8), v2), 251719695)
	local v4 = bit32.band(bit32.bor(bit32.lshift(v3, 4), v3), 51130563)
	local v5 = bit32.band(bit32.bor(bit32.lshift(v4, 2), v4), 153391689)
	v[i + 1] = v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function expandBits(p: number)
	return v[bit32.band(p, 1023) + 1]
end

local Geometry = {}

function Geometry.unionBounds(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
	return vector.min(vector2, vector4), (vector.max(vector3, vector5))
end

function Geometry.getObjectBounds(cframe: CFrame, vector2: Vector3)
	local position = cframe.Position
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local lookVector = cframe.LookVector
	local vector3 = Vector3.new(
		math.abs(rightVector.X) * vector2.X + math.abs(upVector.X) * vector2.Y + math.abs(lookVector.X) * vector2.Z,
		math.abs(rightVector.Y) * vector2.X + math.abs(upVector.Y) * vector2.Y + math.abs(lookVector.Y) * vector2.Z,
		math.abs(rightVector.Z) * vector2.X + math.abs(upVector.Z) * vector2.Y + math.abs(lookVector.Z) * vector2.Z
	)
	return position - vector3, position + vector3
end

function Geometry.getMortonScale(vector2: Vector3, vector3: Vector3)
	local vector4 = vector3 - vector2
	return 1023 / vector4.X, 1023 / vector4.Y, 1023 / vector4.Z
end

function Geometry.positionToMortonCode(vector2: Vector3, vector3: Vector3, p: number, p2: number, p3: number)
	local v2 = math.floor((math.clamp((vector2.X - vector3.X) * p, 0, 1023)))
	local v3 = math.floor((math.clamp((vector2.Y - vector3.Y) * p2, 0, 1023)))
	local v4 = math.floor((math.clamp((vector2.Z - vector3.Z) * p3, 0, 1023)))
	return (bit32.bor(expandBits(v2), bit32.lshift(expandBits(v3), 1), (bit32.lshift(expandBits(v4), 2))))
end

function Geometry.isPointInShape(vector2: Vector3, cframe: CFrame, vector3: Vector3, p: number)
	if p == value then
		local vector4 = vector.abs((cframe:PointToObjectSpace(vector2)))
		return vector.min(vector4, vector3) == vector4
	end

	if p == value3 then
		local position = cframe.Position
		local X = vector3.X
		local v2 = position - cframe.RightVector * X
		local v3 = vector2 - v2
		local rightVector = cframe.RightVector
		local v4 = vector.dot(v3, rightVector)

		if v4 >= 0 and v4 <= X * 2 then
			local vector4 = v2 + rightVector * v4
			return vector.dot(vector2 - vector4, vector2 - vector4) <= vector3.Y * vector3.Y
		else
			return false
		end
	elseif p == value2 then
		local v2 = vector3.X * vector3.X
		local position = cframe.Position
		return vector.dot(position - vector2, position - vector2) <= v2
	elseif p == value4 then
		local pointToObjectSpace = cframe:PointToObjectSpace(vector2)
		local vector4 = vector.abs(pointToObjectSpace)

		if vector.min(vector4, vector3) ~= vector4 then
			return false
		end

		local vector5 = vector3 * 2
		return pointToObjectSpace.Y / vector5.Y - pointToObjectSpace.Z / vector5.Z <= 0
	else
		if p ~= value5 then
			return false
		end

		local vector4 = vector3 * 2
		local pointToObjectSpace = cframe:PointToObjectSpace(vector2)

		if vector.dot(pointToObjectSpace, (vector.normalize((Vector3.new(0, vector4.Z, vector4.Y))))) > 0 then
			return false
		end

		if vector.dot(pointToObjectSpace, (vector.normalize((Vector3.new(-vector4.Y, vector4.X, 0))))) > 0 then
			return false
		end

		local vector5 = vector.abs(pointToObjectSpace)
		return vector.min(vector5, vector3) == vector5
	end
end

return Geometry