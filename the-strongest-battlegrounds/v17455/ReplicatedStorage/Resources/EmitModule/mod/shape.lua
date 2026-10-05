local createVector = vector.create
local module = require("./utility")
local Shape = {
	getSurfaceCFrame = function(cframe: CFrame, vector2: Vector3, position: Vector3)
		local v = math.abs((vector2:Dot(createVector(0, 1, 0)))) > 0.99 and createVector(0, 0, 1) or createVector(
			0,
			1,
			0
		)
		local cframe2 = CFrame.lookAt(createVector(0, 0, 0), vector2, v)
		return cframe * CFrame.new(position) * cframe2
	end
}

function Shape.getPointWithinBox(p: number, cframe: CFrame, vector2: Vector3, p2)
	local random = Random.new(p)
	local vector3 = vector2 / 2
	local vector4 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1)) * vector3
	return (Shape.getSurfaceCFrame(cframe, Vector3.FromNormalId(p2), vector4))
end

function Shape.getPointOnBox(p: number, cframe: CFrame, vector2: Vector3, p2)
	local random = Random.new(p)
	local vector3 = Vector3.FromNormalId(p2)
	local vector4 = vector2 / 2
	local v = createVector(1, 1, 1) - vector3:Abs()
	local v2 = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1)) * vector4 * v
	return (Shape.getSurfaceCFrame(cframe, vector3, v2 + vector3 * vector4))
end

function Shape.getPointWithinCylinder(p: number, p2: number, p3: number, cframe: CFrame, vector2: Vector3, p4)
	local random = Random.new(p)
	local v = math.sqrt((random:NextNumber(p2, 1)))
	local number = random:NextNumber(0, 6.283185307179586)

	if p4 == Enum.NormalId.Left or p4 == Enum.NormalId.Right then
		cframe *= CFrame.fromOrientation(0, 1.5707963267948966 * (p4 == Enum.NormalId.Right and -1 or 1), 0)
		vector2 = Vector3.new(vector2.Z, vector2.Y, vector2.X)
	elseif p4 == Enum.NormalId.Front or p4 == Enum.NormalId.Back then
		cframe *= CFrame.fromOrientation(0, 3.141592653589793, 0)
	end

	local v2 = 1 - random:NextNumber() ^ module.lerp(0.5, 1, (math.sqrt(p3)))
	local lerped = module.lerp(1, p3, v2)
	local vector3 = Vector3.new(v2 * 2 - 1, v * math.sin(number) * lerped, v * math.cos(number) * lerped) * vector2 / 2
	local vector4 = Vector3.new(0, math.sin(number) * lerped, math.cos(number) * lerped) * vector2 / 2
	local vector5 = Vector3.new(0, math.cos(number) * lerped, -math.sin(number) * lerped) * vector2 / 2
	local unit = vector5.Magnitude > 0.001 and vector5.Unit or cframe.UpVector
	return cframe * CFrame.new(vector3) * CFrame.lookAt(createVector(0, 0, 0), vector4, unit)
end

function Shape.getPointWithinSphere(p: number, p2: number, p3: number, cframe: CFrame, vector2: Vector3, p4)
	debug.profilebegin("getPointWithinSphere")
	local random = Random.new(p)
	local number = random:NextNumber()
	local number2 = random:NextNumber()
	local v = number * 2 * 3.141592653589793
	local v2 = math.acos(2 * number2 - 1) * p3
	local v3 = random:NextNumber(p2, 1) ^ 0.3333333333333333
	local v4 = math.sin(v)
	local v5 = math.cos(v)
	local v6 = math.sin(v2)
	local v7 = math.cos(v2)
	local vector3 = Vector3.FromNormalId(p4)

	if p4 == Enum.NormalId.Left or p4 == Enum.NormalId.Right then
		vector2 = Vector3.new(vector2.Z, vector2.Y, vector2.X)
	elseif p4 == Enum.NormalId.Top or p4 == Enum.NormalId.Bottom then
		vector2 = Vector3.new(vector2.X, vector2.Z, vector2.Y)
	end

	local vector4 = vector2 / 2
	local surfaceCFrame = Shape.getSurfaceCFrame(cframe, vector3, createVector(0, 0, 0))
	local vector5 = Vector3.new(v3 * v6 * v5, v3 * v6 * v4, v3 * v7) * vector4
	local vector6 = Vector3.new(-v6 * v4, v6 * v5, 0) * vector4
	local v8 = not (vector6.Magnitude > 0.001) and createVector(1, 0, 0) or vector6.Unit
	local v9 = surfaceCFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(vector5) * CFrame.lookAt(
		createVector(0, 0, 0),
		vector5,
		v8
	)
	debug.profileend()
	return v9
end

function Shape.getPointWithinDisc(p: number, p2: number, p3: number, cframe: CFrame, vector2: Vector3, p4)
	debug.profilebegin("getPointWithinDisc")
	local random = Random.new(p)
	local vector3 = Vector3.FromNormalId(p4)
	local v = createVector(1, 1, 1) - vector3:Abs() * p2
	local vector4 = vector2 / 2
	local number = random:NextNumber(p2, 1)
	local lerped = module.lerp(1, 0.5, p3 ^ 4)
	local v2 = random:NextNumber(1 - p3, 1) ^ lerped
	local number2 = random:NextNumber(0, 6.283185307179586)
	local vector5 = Vector3.new(number * 2 - 1, v2 * math.sin(number2), v2 * math.cos(number2))

	if p4 == Enum.NormalId.Bottom or p4 == Enum.NormalId.Top then
		vector5 = Vector3.new(vector5.Z, vector5.X, vector5.Y)
	elseif p4 == Enum.NormalId.Front or p4 == Enum.NormalId.Back then
		vector5 = Vector3.new(vector5.Y, vector5.Z, vector5.X)
	end

	local vector6 = vector5 * (vector4 * v)
	local surfaceCFrame = Shape.getSurfaceCFrame(cframe, vector3, vector6 + vector3 * p2 * vector4)
	debug.profileend()
	return surfaceCFrame
end

return Shape