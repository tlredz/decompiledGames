local createVector = vector.create

function getDebugPart(p: string, p2)
	local v = workspace:FindFirstChild(p .. "_IKLegDebug")

	if v ~= nil then
		return v
	end

	v = Instance.new("Part")
	v.Color = Color3.fromHSV(math.random(), 1, 1)
	v.CastShadow = false
	v.CanCollide = false
	v.CanTouch = false
	v.CanQuery = false
	v.TopSurface = 0
	v.BottomSurface = 0
	v.Anchored = true
	v.Name = p .. "_IKLegDebug"
	v.Parent = p2 or workspace
	return v
end

local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()

function visualizeVector(p: string, vector2: Vector3, vector3: Vector3, p2: number, p3: number)
	local debugPart = getDebugPart(p)
	local unit = vector3.Unit
	debugPart.Size = Vector3.new(p3, p3, p2)
	debugPart.CFrame = CFrame.lookAt(vector2, vector2 + unit * p2) * CFrame.new(0, 0, -p2 * 0.5 + 0.01 * math.random())
	debugPart.Material = Enum.Material.Neon

	if debugPart:GetAttribute("ColorAlreadySet") == nil then
		debugPart.Color = Color3.fromHSV(math.random(), 1, 1)
		debugPart:SetAttribute("ColorAlreadySet", true)
	end

	local v = math.atan2(unit.X, unit.Z)
	local v2 = math.acos(unit.Y)
	local _ = ((v + 3.141592653589793) / 12.566370614359172 + v2 / 6.283185307179586) % 1
	local debugPart2 = getDebugPart(p .. "_Arrowhead")
	debugPart2.Shape = Enum.PartType.Ball
	debugPart2.Size = Vector3.new(p3, p3, p3) * 2
	debugPart2.CFrame = CFrame.new(vector2 + unit * p2)
	debugPart2.Color = debugPart.Color
	debugPart2.Material = Enum.Material.Neon
	return debugPart
end

function visualizeCircle(p: string, p2: number, vector2: Vector3, vector3: Vector3?)
	local debugPart = getDebugPart(p .. "_Circle")
	debugPart.Shape = Enum.PartType.Cylinder
	debugPart.Size = Vector3.new(0.1, p2 * 2, p2 * 2)
	debugPart.Transparency = 0.4
	local v = math.random() * 0.01
	debugPart.CFrame = CFrame.lookAt(createVector(0, 0, 0), vector3 or createVector(0, 1, 0)) * CFrame.new(0, 0, -v) * inverse + vector2
	return debugPart
end

function visualizePoint(p: string, position: Vector3, value: number?)
	local debugPart = getDebugPart(p .. "_Point")
	local v = value or 0.5
	debugPart.Shape = Enum.PartType.Ball
	debugPart.Size = Vector3.new(v * 2, v * 2, v * 2)
	debugPart.Transparency = 0.8
	debugPart.CFrame = CFrame.new(position)
	return debugPart
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectVectorOntoPlane(vector2, unit)
	local unit2 = unit.Unit
	return vector2 - vector2:Dot(unit2) * unit2
end

local function computeSphereSphereIntersectionRadiusAndCenter(vector2: Vector3, p: number, vector3: Vector3, p2: number)
	local magnitude = (vector3 - vector2).Magnitude
	assert(magnitude <= p + p2, "positionA and positionB too far apart for sphere-sphere IK intersection solution")

	if magnitude < math.abs(p - p2) then
		return p, vector2
	end

	local v = math.sqrt(4 * magnitude ^ 2 * p ^ 2 - (magnitude ^ 2 - p2 ^ 2 + p ^ 2) ^ 2) / (2 * magnitude)

	if p < p2 and magnitude < p2 then
		return v, vector3 + math.sqrt(p2 ^ 2 - v ^ 2) * (vector2 - vector3).Unit
	end

	return v, vector2 + math.sqrt(p ^ 2 - v ^ 2) * (vector3 - vector2).Unit
end

local function slerp(vector2: Vector3, vector3: Vector3, p: number)
	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local dot = unit:Dot(unit2)

	if dot > 0.9995 then
		return (unit + p * (unit2 - unit)).Unit
	end

	local v = math.clamp(dot, -1, 1)
	local v2 = math.acos(v) * p
	local v3 = math.sin(v2)
	local unit3 = (unit2 - unit * v).Unit

	if v < -0.9995 then
		unit3 = CFrame.lookAlong(createVector(0, 0, 0), unit).RightVector
	end

	return (unit * math.cos(v2) + unit3 * v3).Unit
end

local function compute2JointIKPosition(vector2: Vector3, p: number, vector3: Vector3, p2: number, vector4: Vector3, _: string, vector5: Vector3)
	if vector2 == vector3 then
		warn("positionA == positionB")
		return vector2
	end

	local magnitude = (vector3 - vector2).Magnitude

	if p + p2 <= magnitude then
		return vector2 * 0.5 + vector3 * 0.5
	end

	local unit = vector4.Unit
	assert(unit == unit, "projectOntoIntersection.Unit is a NaN vector")
	local v, v2 = computeSphereSphereIntersectionRadiusAndCenter(vector2, p, vector3, p2)
	local _ = (vector3 - vector2).Unit
	local unit2 = (vector3 - vector2).Unit
	assert(
		math.abs((unit:Dot(unit2))) < 1,
		"projectOntoIntersection.Unit is parallel or anti-parallel to (positionB - positionA).Unit"
	)
	local selected = v2 + v * (projectVectorOntoPlane(unit, unit2)).Unit

	if not vector5 then
		return selected, selected - vector2
	end

	selected = v2 + v * (projectVectorOntoPlane(
		slerp(projectVectorOntoPlane(vector2 + vector5 - v2, unit2), selected - v2, 0.1),
		unit2
	)).Unit
	return selected, selected - vector2
end

return compute2JointIKPosition