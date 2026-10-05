local createVector = vector.create
local VectorMap = {}
VectorMap.__index = VectorMap

function VectorMap.new(value: number?)
	return (setmetatable({
		_voxelSize = value or 50,
		_voxels = {}
	}, VectorMap))
end

function VectorMap:_debugDrawVoxel(vector2: Vector3)
	local part = Instance.new("Part")
	part.Name = tostring(vector2)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1) * self._voxelSize
	part.Position = vector2 * self._voxelSize + createVector(1, 1, 1) * (self._voxelSize / 2)
	part.Parent = workspace
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color3.new(0, 0, 1)
	selectionBox.Adornee = part
	selectionBox.Parent = part
	task.delay(0.03333333333333333, part.Destroy, part)
end

function VectorMap:AddObject(vector2: Vector3, instance)
	local className = instance.ClassName
	local _voxelSize = self._voxelSize
	local vector3 = Vector3.new(
		math.floor(vector2.X / _voxelSize),
		math.floor(vector2.Y / _voxelSize),
		(math.floor(vector2.Z / _voxelSize))
	)
	local _voxel = self._voxels[vector3]

	if _voxel == nil then
		self._voxels[vector3] = {
			[className] = { instance }
		}
		return vector3
	end

	if _voxel[className] == nil then
		_voxel[className] = { instance }
		return vector3
	end

	table.insert(_voxel[className], instance)
	return vector3
end

function VectorMap:RemoveObject(vector2: Vector3, instance)
	local _voxel = self._voxels[vector2]

	if _voxel == nil then
		return
	end

	local className = instance.ClassName

	if _voxel[className] == nil then
		return
	end

	local v = _voxel[className]

	for k, v2 in v do
		if v2 ~= instance then
			continue
		end

		local count = #v
		v[k] = v[count]
		v[count] = nil
		break
	end

	if #v == 0 then
		_voxel[className] = nil

		if next(_voxel) == nil then
			self._voxels[vector2] = nil
		end
	end
end

function VectorMap:GetVoxel(vector2: Vector3)
	return self._voxels[vector2]
end

function VectorMap:ForEachObjectInRegion(vector2: Vector3, vector3: Vector3, callback)
	local _voxelSize = self._voxelSize
	local v = math.min(vector3.X, vector2.X)
	local v2 = math.min(vector3.Y, vector2.Y)
	local v3 = math.min(vector3.Z, vector2.Z)
	local v4 = math.max(vector3.X, vector2.X)
	local v5 = math.max(vector3.Y, vector2.Y)
	local v6 = math.max(vector3.Z, vector2.Z)

	for i = math.floor(v / _voxelSize), math.floor(v4 / _voxelSize) do
		for i2 = math.floor(v3 / _voxelSize), math.floor(v6 / _voxelSize) do
			for i3 = math.floor(v2 / _voxelSize), math.floor(v5 / _voxelSize) do
				local _voxel = self._voxels[Vector3.new(i, i3, i2)]

				if not _voxel then
					continue
				end

				for k, v7 in _voxel do
					for _, v8 in v7 do
						callback(k, v8)
					end
				end
			end
		end
	end
end

function VectorMap:ForEachObjectInView(data, p2: number, callback)
	local _voxelSize = self._voxelSize
	local cFrame = data.CFrame
	local position = cFrame.Position
	local rightVector = cFrame.RightVector
	local upVector = cFrame.UpVector
	local v = p2 / 2
	local v2 = math.tan((math.rad((data.FieldOfView + 5) / 2))) * p2
	local v3 = v2 * (data.ViewportSize.X / data.ViewportSize.Y)
	local v4 = cFrame * CFrame.new(0, 0, -p2)
	local v5 = v4 * Vector3.new(-v3, v2, 0)
	local v6 = v4 * Vector3.new(v3, v2, 0)
	local v7 = v4 * Vector3.new(-v3, -v2, 0)
	local v8 = v4 * Vector3.new(v3, -v2, 0)
	local inverse = (cFrame * CFrame.new(0, 0, -v)):Inverse()
	local unit = upVector:Cross(v8 - position).Unit
	local unit2 = upVector:Cross(v7 - position).Unit
	local unit3 = rightVector:Cross(position - v6).Unit
	local unit4 = rightVector:Cross(position - v8).Unit
	local min = position:Min(v5):Min(v6):Min(v7):Min(v8)
	local max = position:Max(v5):Max(v6):Max(v7):Max(v8)
	local vector2 = Vector3.new(
		math.floor(min.X / _voxelSize),
		math.floor(min.Y / _voxelSize),
		(math.floor(min.Z / _voxelSize))
	)
	local vector3 = Vector3.new(
		math.floor(max.X / _voxelSize),
		math.floor(max.Y / _voxelSize),
		(math.floor(max.Z / _voxelSize))
	)

	local function isPointInView(vector4: Vector3)
		local v9 = inverse * vector4

		if v3 < v9.X or v9.X < -v3 then
			return false
		end

		if not (v2 < v9.Y or v9.Y < -v2) and not (v < v9.Z or v9.Z < -v) then
			local v10 = vector4 - position
			return not (unit:Dot(v10) < 0 or unit2:Dot(v10) > 0 or unit3:Dot(v10) < 0 or unit4:Dot(v10) > 0)
		end

		return false
	end

	for i = vector2.X, vector3.X do
		local v9 = i * _voxelSize
		local v10 = v9 + _voxelSize
		local v11 = math.clamp(v4.X, v9, v10)

		for i2 = vector2.Y, vector3.Y do
			local v12 = i2 * _voxelSize
			local v13 = v12 + _voxelSize
			local v14 = math.clamp(v4.Y, v12, v13)

			for i3 = vector2.Z, vector3.Z do
				local v15 = i3 * _voxelSize
				local v16 = v15 + _voxelSize

				if not isPointInView(Vector3.new(v11, v14, (math.clamp(v4.Z, v15, v16)))) then
					continue
				end

				local v17 = vector2.Z - 1
				local Z = vector3.Z
				local v18 = i3

				while i3 <= Z do
					local v19 = math.floor((i3 + Z) / 2)

					if isPointInView(Vector3.new(
						v11,
						v14,
						(math.clamp(v4.Z, v19 * _voxelSize, v19 * _voxelSize + _voxelSize))
					)) then
						i3 = v19 + 1
						v17 = v19
					else
						Z = v19 - 1
					end
				end

				for i4 = v18, v17 do
					local _voxel = self._voxels[Vector3.new(i, i2, i4)]

					if not _voxel then
						continue
					end

					for k, v19 in _voxel do
						for _, v20 in v19 do
							callback(k, v20)
						end
					end
				end

				break
			end
		end
	end
end

function VectorMap:ClearAll()
	self._voxels = {}
end

return VectorMap