local createVector = vector.create
local Utilities = {}
local cframe = CFrame.fromEulerAnglesXYZ(0, 3.141592653589793, 0)

function Utilities.lerp(p: number, p2: number, p3: number)
	return p * (1 - p3) + p2 * p3
end

function Utilities.screenToPhysicalSize(p)
	local viewportSize = p.ViewportSize
	local v = viewportSize.X / viewportSize.Y
	local v2 = math.tan((math.rad(p.FieldOfView / 2))) * 2
	return (Vector3.new(v * v2, v2, 0))
end

function Utilities.worldToScreenPoint(p, cframe2: CFrame)
	local objectSpace = p.CFrame:ToObjectSpace(cframe2)
	local v = -(objectSpace.Position / objectSpace.Z) / Utilities.screenToPhysicalSize(p)
	return Vector2.new(v.X + 0.5, -v.Y + 0.5) * p.ViewportSize, objectSpace
end

function Utilities.isCircleVisible(point: Vector2, p: number, p2)
	local viewportSize = p2.ViewportSize
	local v = point - Vector2.new(p, p)
	local v2 = point + Vector2.new(p, p)

	if v.X > viewportSize.X or v.Y > viewportSize.Y then
		return
	end

	if v2.X < 0 or v2.Y < 0 then
		return
	else
		return true
	end
end

function Utilities.worldToScreenSize(p, position: Vector3, p2: number)
	return math.abs(p2 / p.CFrame:ToObjectSpace(CFrame.new(position)).Z) / Utilities.screenToPhysicalSize(p).Magnitude * p.ViewportSize.Magnitude
end

function Utilities.getSurfaceInfo(instance)
	local cFrame = instance.CFrame
	local size = instance.Size
	local vector2 = Vector3.FromNormalId(Enum.NormalId.Back)
	local v = math.abs(vector2.y) ~= 1 and createVector(0, 1, 0) or Vector3.new(vector2.y, 0, 0) or createVector(
		0,
		1,
		0
	)
	local v2 = CFrame.fromAxisAngle(v, 1.5707963267948966) * vector2
	local unit = vector2:Cross(v2).Unit
	return
		cFrame * CFrame.fromMatrix(-vector2 * size / 2, v2, unit, vector2),
		(Vector3.new((size * v2).Magnitude, (size * unit).Magnitude, (size * vector2).Magnitude))
end

function Utilities.computeCamData(cframe2: CFrame, cframe3: CFrame, vector2: Vector3, p)
	local v = cframe3 * Vector3.new(0, vector2.Y / 2, 0)
	local v2 = cframe3 * Vector3.new(0, -vector2.Y / 2, 0)
	local vector3 = cframe2.LookVector:Cross(cframe3.UpVector)
	local unit = vector3:Dot(vector3) > 0 and vector3.Unit or cframe2.RightVector
	local inverse = CFrame.fromMatrix(cframe2.Position, unit, cframe3.UpVector, unit:Cross(cframe3.UpVector)):Inverse()
	local v3 = inverse * v2
	local v4 = inverse * v
	local unit2 = (v3 * createVector(0, 1, 1)).Unit
	local unit3 = (v4 * createVector(0, 1, 1)).Unit
	local v5 = math.sign(unit2.y) * math.acos((unit2:Dot(createVector(0, 0, -1))))
	local v6 = math.sign(unit3.y) * math.acos((unit3:Dot(createVector(0, 0, -1))))
	local v7 = math.tan(math.rad(p.FieldOfView) / 2) * 2
	local v8 = (math.tan(v6) - math.tan(v5)) / v7
	local vectorToObjectSpace = cframe3:VectorToObjectSpace(cframe3.Position - cframe2.Position)
	local v9 = vectorToObjectSpace * createVector(1, 0, 1)
	local v10 = vectorToObjectSpace * createVector(0, 1, 1)
	local dot = v9.Unit:Dot(createVector(0, 0, -1))
	local v11 = (cframe3:VectorToObjectSpace(cframe2.LookVector) * createVector(1, 0, 1)).Unit:Dot(v9.Unit) / (createVector(
		0,
		0,
		-1
	)):Dot(v9.Unit)
	local v12 = math.sqrt(1 - dot * dot) / dot
	local v13 = vector2.X / vector2.X
	local v14 = math.sign(vectorToObjectSpace.x * vectorToObjectSpace.z) * v12
	local v15 = v10.y / v10.z * v13
	local v16 = math.abs(v11 * v8 * v13)
	local v17 = { ((cframe3 - cframe3.Position) * cframe * CFrame.new(0, 0, 0, 1, 0, 0, 0, v13, 0, v14, v15, v16)):GetComponents() }
	local v18 = {}

	for i = 1, #v17 do
		v18[i] = math.abs(v17[i])
	end

	local v19 = math.max(table.unpack(v18))
	local cFrame = CFrame.new(
		v17[1],
		v17[2],
		v17[3],
		v17[4] / v19,
		v17[5] / v19,
		v17[6] / v19,
		v17[7] / v19,
		v17[8] / v19,
		v17[9] / v19,
		v17[10] / v19,
		v17[11] / v19,
		v17[12] / v19
	) + cframe2.Position
	return {
		FieldOfView = p.FieldOfView,
		CFrame = cFrame,
		Focus = cFrame * CFrame.new(0, 0, cframe2:PointToObjectSpace(cframe3.Position).Z)
	}
end

function Utilities.getNames(instance)
	local names = {}

	for _, child in pairs(instance:GetChildren()) do
		table.insert(names, child.Name)
	end

	return table.unpack(names)
end

return Utilities