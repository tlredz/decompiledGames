local Frustums = {}
Frustums.__index = Frustums

function Frustums.new(data, p: number, p2: string, flag: boolean)
	local object = setmetatable({}, Frustums)
	local cFrame = data.CFrame
	local v = math.rad(data.MaxAxisFieldOfView) / 2
	local v2 = math.rad(data.FieldOfView) / 2
	local planes = {}

	if not flag then
		local v4 = cFrame * CFrame.new(0, 0, data.NearPlaneZ)
		local v5 = -v4.LookVector
		table.insert(planes, { v5, (-v5):Dot(v4.Position) })
		local v6 = cFrame * CFrame.new(0, 0, -p)
		local lookVector = v6.LookVector
		table.insert(planes, { lookVector, (-lookVector):Dot(v6.Position) })
	end

	if p2 == "Full" or p2 == "Horizontal" then
		local v4 = -(cFrame * CFrame.Angles(0, v, 0)).RightVector
		table.insert(planes, { v4, (-v4):Dot(cFrame.Position) })
		local rightVector = (cFrame * CFrame.Angles(0, -v, 0)).RightVector
		table.insert(planes, { rightVector, (-rightVector):Dot(cFrame.Position) })
	end

	if p2 == "Full" or p2 == "Vertical" then
		local v4 = -(cFrame * CFrame.Angles(-v2, 0, 0)).UpVector
		table.insert(planes, { v4, (-v4):Dot(cFrame.Position) })
		local upVector = (cFrame * CFrame.Angles(v2, 0, 0)).UpVector
		table.insert(planes, { upVector, (-upVector):Dot(cFrame.Position) })
	end

	object.planes = planes
	return object
end

function Frustums.ContainsPoint(p, vector: Vector3)
	for _, plane in p.planes do
		if vector:Dot(plane[1]) + plane[2] >= 0 then
			return false
		end
	end

	return true
end

function Frustums.ContainsSphere(p, vector: Vector3, p2: number)
	for _, plane in p.planes do
		if p2 <= vector:Dot(plane[1]) + plane[2] then
			return false
		end
	end

	return true
end

function Frustums.ContainsCylinder(p, vector: Vector3, p2: number, p3: number)
	for _, plane in ipairs(p.planes) do
		local v = plane[1]
		local v2 = plane[2]

		if p2 * (1 - v.Y * v.Y) ^ 0.5 + p3 / 2 * math.abs(v.Y) <= vector:Dot(v) + v2 then
			return false
		end
	end

	return true
end

function Frustums:ContainsBoxAABB(vector: Vector3, vector2: Vector3)
	local v = "INSIDE"

	for _, plane in ipairs(self.planes) do
		local vector3 = plane[1]
		local v2 = plane[2]
		local vector4 = Vector3.new(
			vector3.X > 0 and vector.X or vector2.X,
			vector3.Y > 0 and vector.Y or vector2.Y,
			vector3.Z > 0 and vector.Z or vector2.Z
		)
		local vector5 = Vector3.new(
			vector3.X > 0 and vector2.X or vector.X,
			vector3.Y > 0 and vector2.Y or vector.Y,
			vector3.Z > 0 and vector2.Z or vector.Z
		)

		if vector3:Dot((Vector3.new(vector4.X, vector4.Y, vector4.Z))) + v2 > 0 then
			return false
		end

		if not (vector3:Dot((Vector3.new(vector5.X, vector5.Y, vector5.Z))) + v2 >= 0) then
			continue
		end

		v = "Intersect"
	end

	return v
end

function Frustums:ContainsBoxAABBFromCFrame(cframe: CFrame, vector: Vector3)
	local vector2 = vector * 0.5
	local rightVector = cframe.RightVector
	local upVector = cframe.UpVector
	local lookVector = cframe.LookVector
	local position = cframe.Position
	return self:ContainsBoxAABB(
		Vector3.new(
			position.X - math.abs(rightVector.X * vector2.X) - math.abs(upVector.X * vector2.Y) - math.abs(lookVector.X * vector2.Z),
			position.Y - math.abs(rightVector.Y * vector2.X) - math.abs(upVector.Y * vector2.Y) - math.abs(lookVector.Y * vector2.Z),
			position.Z - math.abs(rightVector.Z * vector2.X) - math.abs(upVector.Z * vector2.Y) - math.abs(lookVector.Z * vector2.Z)
		),
		(Vector3.new(
			position.X + math.abs(rightVector.X * vector2.X) + math.abs(upVector.X * vector2.Y) + math.abs(lookVector.X * vector2.Z),
			position.Y + math.abs(rightVector.Y * vector2.X) + math.abs(upVector.Y * vector2.Y) + math.abs(lookVector.Y * vector2.Z),
			position.Z + math.abs(rightVector.Z * vector2.X) + math.abs(upVector.Z * vector2.Y) + math.abs(lookVector.Z * vector2.Z)
		))
	)
end

function Frustums.ContainsBox(p, cframe: CFrame, vector: Vector3)
	local v = {}

	for i = -1, 1, 2 do
		for i2 = -1, 1, 2 do
			for i3 = -1, 1, 2 do
				table.insert(
					v,
					(cframe:PointToWorldSpace((Vector3.new(i * vector.X / 2, i2 * vector.Y / 2, i3 * vector.Z / 2))))
				)
			end
		end
	end

	for _, plane in ipairs(p.planes) do
		local flag = true

		for _, vector2 in ipairs(v) do
			if not (vector2:Dot(plane[1]) + plane[2] <= 0) then
				continue
			end

			flag = false
			break
		end

		if flag then
			return false
		end
	end

	return true
end

return Frustums