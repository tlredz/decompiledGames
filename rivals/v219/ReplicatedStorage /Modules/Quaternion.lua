local createVector = vector.create
local Quaternion = {
	_type = "Quaternion",
	_TO_STRING_CHAR = nil
}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetType(data)
	if data == nil then
		return "nil"
	end

	local metatable = getmetatable(data)

	if type(metatable) == "table" and metatable._type ~= nil then
		return (tostring(metatable._type))
	end

	return (typeof(data))
end

local function _safeUnit(vector2: Vector3, vector3: Vector3)
	if vector2.Magnitude > 5e-7 then
		return vector2.Unit
	end

	return vector3
end

local function new(value: number?, value2: number?, value3: number?, value4: number?)
	local self = setmetatable({
		X = value or 0,
		Y = value2 or 0,
		Z = value3 or 0,
		W = value4 or 1,
		_cached = {}
	}, Quaternion)
	table.freeze(self)
	return self
end

Quaternion.new = new
Quaternion.identity = new(0, 0, 0, 1)
Quaternion.zero = new(0, 0, 0, 0)

local function _Orthonormalize(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local DISTANCE_EPSILON = 5e-7
	local vector5 = not (vector2.Magnitude > DISTANCE_EPSILON) and createVector(1, 0, 0) or vector2.Unit
	local cross = vector5:Cross(not (vector3.Magnitude > DISTANCE_EPSILON) and createVector(0, 1, 0) or vector3.Unit)
	local unit

	if cross.Magnitude > DISTANCE_EPSILON then
		unit = cross.Unit
	else
		local cross2 = vector5:Cross(createVector(0, 1, 0))
		unit = not (cross2.Magnitude > DISTANCE_EPSILON) and createVector(1, 0, 0) or cross2.Unit
	end

	local unit2 = unit:Cross(vector5).Unit

	if unit:Dot(vector4) < 0 then
		unit = -unit
	end

	return vector5, unit2, unit
end

local function _fromOrthonormalizedMatrix(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local X = vector2.X
	local Y = vector2.Y
	local Z = vector2.Z
	local X2 = vector3.X
	local Y2 = vector3.Y
	local Z2 = vector3.Z
	local X3 = vector4.X
	local Y3 = vector4.Y
	local Z3 = vector4.Z
	local v = X + Y2 + Z3
	local v2, v3, v4, v5

	if v > 0 then
		local v6 = math.sqrt(v + 1) * 2
		v2 = (Z2 - Y3) / v6
		v3 = (X3 - Z) / v6
		v4 = (Y - X2) / v6
		v5 = v6 * 0.25
	elseif Y2 < X and Z3 < X then
		local v6 = math.sqrt(X + 1 - Y2 - Z3) * 2
		v2 = v6 * 0.25
		v3 = (X2 + Y) / v6
		v4 = (X3 + Z) / v6
		v5 = (Z2 - Y3) / v6
	elseif Z3 < Y2 then
		local v6 = math.sqrt(Y2 + 1 - X - Z3) * 2
		v2 = (X2 + Y) / v6
		v3 = v6 * 0.25
		v4 = (Y3 + Z2) / v6
		v5 = (X3 - Z) / v6
	else
		local v6 = math.sqrt(Z3 + 1 - X - Y2) * 2
		v2 = (X3 + Z) / v6
		v3 = (Y3 + Z2) / v6
		v4 = v6 * 0.25
		v5 = (Y - X2) / v6
	end

	return (new(v2, v3, v4, v5))
end

function Quaternion.fromAxisAngle(vector2: Vector3, p: number)
	local v = not (vector2.Magnitude > 5e-7) and createVector(1, 0, 0) or vector2.Unit
	local v2 = p / 2
	local v3 = math.sin(v2)
	return (new(v3 * v.X, v3 * v.Y, v3 * v.Z, math.cos(v2)))
end

function Quaternion.fromAxisAngleFast(vector2: Vector3, p: number)
	local v = p / 2
	local v2 = vector2 * math.sin(v)
	return (new(v2.X, v2.Y, v2.Z, math.cos(v)))
end

function Quaternion.fromEulerVector(vector2: Vector3)
	local magnitude = vector2.Magnitude

	if not (magnitude > 0) then
		return Quaternion.identity
	end

	local v = vector2 / magnitude
	local halfMagnitude = magnitude / 2
	local v3 = v * math.sin(halfMagnitude)
	return (new(v3.X, v3.Y, v3.Z, math.cos(halfMagnitude)))
end

function Quaternion.fromCFrame(cframe: CFrame)
	local axisAngle, v = cframe:Orthonormalize():ToAxisAngle()
	local v2 = not (axisAngle.Magnitude > 5e-7) and createVector(1, 0, 0) or axisAngle.Unit
	local v3 = v / 2
	local v4 = math.sin(v3)
	return (new(v4 * v2.X, v4 * v2.Y, v4 * v2.Z, math.cos(v3)))
end

function Quaternion:fromCFrameFast()
	local axisAngle, v = self:ToAxisAngle()
	local v2 = v / 2
	local v3 = axisAngle * math.sin(v2)
	return (new(v3.X, v3.Y, v3.Z, math.cos(v2)))
end

function Quaternion.fromMatrix(vector2: Vector3, vector3: Vector3, vector4: Vector3?)
	return (_fromOrthonormalizedMatrix(_Orthonormalize(vector2, vector3, vector4 or vector2:Cross(vector3))))
end

function Quaternion.fromMatrixFast(vector2: Vector3, vector3: Vector3, vector4: Vector3?)
	return (_fromOrthonormalizedMatrix(vector2.Unit, vector3.Unit, vector4 or vector2:Cross(vector3).Unit))
end

function Quaternion.lookAt(vector2: Vector3, vector3: Vector3, vector4: Vector3?)
	local DISTANCE_EPSILON = 5e-7
	local v = vector3 - vector2
	local vector5 = not (v.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, 1) or v.Unit
	local v2 = vector4 or createVector(0, 1, 0)
	local cross = vector5:Cross(not (v2.Magnitude > DISTANCE_EPSILON) and createVector(0, 1, 0) or v2.Unit)

	if cross.Magnitude > DISTANCE_EPSILON then
		local unit = cross.Unit
		return (_fromOrthonormalizedMatrix(unit, unit:Cross(vector5).Unit, -vector5))
	else
		local cross2 = vector5:Cross(createVector(1, 0, 0))

		if cross2.Magnitude > DISTANCE_EPSILON then
			local unit = cross2.Unit
			return (_fromOrthonormalizedMatrix(unit, unit:Cross(vector5).Unit, -vector5))
		else
			local vector6 = (createVector(0, 0, 1)):Cross(vector5)
			local v3 = vector6 * vector6:Dot(createVector(0, 1, 0))
			return (_fromOrthonormalizedMatrix(vector5:Cross(v3), v3, -vector5))
		end
	end
end

local function fromEulerAnglesXYZ(p: number, p2: number, p3: number)
	local v = math.cos(p / 2)
	local v2 = math.sin(p / 2)
	local v3 = math.cos(p2 / 2)
	local v4 = math.sin(p2 / 2)
	local v5 = math.cos(p3 / 2)
	local v6 = math.sin(p3 / 2)
	local v7 = v2 * v3
	local v8 = v * v4
	local v9 = v * v3
	local v10 = v2 * v4
	return (new(v7 * v5 + v8 * v6, v8 * v5 - v7 * v6, v9 * v6 + v10 * v5, v9 * v5 - v10 * v6))
end

Quaternion.fromEulerAnglesXYZ = fromEulerAnglesXYZ
Quaternion.Angles = fromEulerAnglesXYZ

local function fromEulerAnglesYXZ(p: number, p2: number, p3: number)
	local v = math.cos(p / 2)
	local v2 = math.sin(p / 2)
	local v3 = math.cos(p2 / 2)
	local v4 = math.sin(p2 / 2)
	local v5 = math.cos(p3 / 2)
	local v6 = math.sin(p3 / 2)
	local v7 = v2 * v3
	local v8 = v * v4
	local v9 = v * v3
	local v10 = v2 * v4
	return (new(v7 * v5 + v8 * v6, v8 * v5 - v7 * v6, v9 * v6 - v10 * v5, v9 * v5 + v10 * v6))
end

Quaternion.fromEulerAnglesYXZ = fromEulerAnglesYXZ
Quaternion.fromOrientation = fromEulerAnglesYXZ

function Quaternion.fromEulerAngles(p: number, p2: number, p3: number, p4)
	local v = p4 or Enum.RotationOrder.XYZ
	local v2 = math.cos(p / 2)
	local v3 = math.cos(p2 / 2)
	local v4 = math.cos(p3 / 2)
	local v5 = math.sin(p / 2)
	local v6 = math.sin(p2 / 2)
	local v7 = math.sin(p3 / 2)
	local v8 = v5 * v3
	local v9 = v2 * v6
	local v10 = v2 * v3
	local v11 = v5 * v6
	local v12 = nil
	local v13 = nil
	local v14 = nil
	local v15 = nil
	local name = v.Name

	if name == "XYZ" then
		v12 = v8 * v4 + v9 * v7
		v13 = v9 * v4 - v8 * v7
		v14 = v10 * v7 + v11 * v4
		v15 = v10 * v4 - v11 * v7
	elseif name == "YXZ" then
		v12 = v8 * v4 + v9 * v7
		v13 = v9 * v4 - v8 * v7
		v14 = v10 * v7 - v11 * v4
		v15 = v10 * v4 + v11 * v7
	elseif name == "ZXY" then
		v12 = v8 * v4 - v9 * v7
		v13 = v9 * v4 + v8 * v7
		v14 = v10 * v7 + v11 * v4
		v15 = v10 * v4 - v11 * v7
	elseif name == "ZYX" then
		v12 = v8 * v4 - v9 * v7
		v13 = v9 * v4 + v8 * v7
		v14 = v10 * v7 - v11 * v4
		v15 = v10 * v4 + v11 * v7
	elseif name == "YZX" then
		v12 = v8 * v4 + v9 * v7
		v13 = v9 * v4 + v8 * v7
		v14 = v10 * v7 - v11 * v4
		v15 = v10 * v4 - v11 * v7
	elseif name == "XZY" then
		v12 = v8 * v4 - v9 * v7
		v13 = v9 * v4 - v8 * v7
		v14 = v10 * v7 + v11 * v4
		v15 = v10 * v4 + v11 * v7
	end

	return (new(v12, v13, v14, v15))
end

function Quaternion.fromVector(vector2: Vector3, value: number?)
	return (new(vector2.X, vector2.Y, vector2.Z, value or 0))
end

function Quaternion.RandomQuaternion(value: number)
	local random = Random.new(value or 1)
	local sqrt = math.sqrt
	local sin = math.sin
	local cos = math.cos
	return function()
		local number = random:NextNumber(0, 1)
		local number2 = random:NextNumber(0, 1)
		local number3 = random:NextNumber(0, 1)
		local v = 1 - number
		local v2 = sqrt(number)
		local v3 = sqrt(v)
		local v4 = 6.283185307179586 * number2
		local v5 = 6.283185307179586 * number3
		return (new(v3 * sin(v4), v3 * cos(v4), v2 * sin(v5), v2 * cos(v5)))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Add(data, data2)
	return (new(data.X + data2.X, data.Y + data2.Y, data.Z + data2.Z, data.W + data2.W))
end

Quaternion.__add = Add
Quaternion.Add = Add

-- equivalent calls inferred from this helper; original call sites unknown
local function Sub(data, data2)
	return (new(data.X - data2.X, data.Y - data2.Y, data.Z - data2.Z, data.W - data2.W))
end

Quaternion.__sub = Sub
Quaternion.Sub = Sub

local function Mul(data, data2)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local X2 = data2.X
	local Y2 = data2.Y
	local Z2 = data2.Z
	local W2 = data2.W
	return (new(
		W * X2 + X * W2 + Y * Z2 - Z * Y2,
		W * Y2 - X * Z2 + Y * W2 + Z * X2,
		W * Z2 + X * Y2 - Y * X2 + Z * W2,
		W * W2 - X * X2 - Y * Y2 - Z * Z2
	))
end

Quaternion.__mul = Mul
Quaternion.Mul = Mul

function Quaternion.Scale(data, p: number)
	return (new(data.X * p, data.Y * p, data.Z * p, data.W * p))
end

function Quaternion:MulCFrameR(cframe: CFrame)
	return self:ToCFrame() * cframe
end

function Quaternion:MulCFrameL(cframe: CFrame)
	return cframe * self:ToCFrame()
end

function Quaternion:RotateVector(vector2: Vector3)
	return Mul(self * new(vector2.X, vector2.Y, vector2.Z, 0), self:Conjugate()):Vector()
end

function Quaternion.CombineImaginary(p, vector2: Vector3)
	return (Mul(new(vector2.X, vector2.Y, vector2.Z, 0), p))
end

local function Div(p, cframe)
	return (Mul(p, cframe:Inverse()))
end

Quaternion.__div = Div
Quaternion.Div = Div

function Quaternion.ScaleInv(data, p: number)
	return (new(data.X / p, data.Y / p, data.Z / p, data.W / p))
end

local function unm(data)
	return (new(-data.X, -data.Y, -data.Z, -data.W))
end

Quaternion.__unm = unm
Quaternion.Unm = unm
Quaternion.Negate = unm

local function Pow(cframe, p: number)
	if p == -1 then
		return cframe:Inverse()
	end

	local W = cframe.W
	local X = cframe.X
	local Y = cframe.Y
	local Z = cframe.Z
	local v = X * X + Y * Y + Z * Z
	local v2 = math.sqrt(W * W + v)
	local v3 = math.sqrt(v)
	local v4 = v2 ^ p

	if v3 <= v2 * 5e-7 then
		return Quaternion.new(0, 0, 0, v4)
	end

	local v5 = X / v3
	local v6 = Y / v3
	local v7 = Z / v3
	local v8 = p * math.atan2(v3, W)
	local v9 = math.cos(v8)
	local v10 = v4 * math.sin(v8)
	local v11 = v4 * v9
	local v12 = v10 * v5
	local v13 = v10 * v6
	local v14 = v10 * v7
	return Quaternion.new(v12, v13, v14, v11)
end

Quaternion.__pow = Pow
Quaternion.Pow = Pow

local function eq(data, data2)
	local type2 = GetType(data) -- equivalent call inferred; original call site unknown
	local type3 = GetType(data2) -- equivalent call inferred; original call site unknown

	if type2 ~= "Quaternion" or type3 ~= type2 then
		return false
	end

	return data.X == data2.X and data.Y == data2.Y and data.Z == data2.Z and data.W == data2.W
end

Quaternion.__eq = eq
Quaternion.Eq = eq

local function lt(object, object2)
	return object:Length() < object2:Length()
end

Quaternion.__lt = lt
Quaternion.Lt = lt

local function le(object, object2)
	return object:Length() <= object2:Length()
end

Quaternion.__le = le
Quaternion.Le = le

local function Exp(data)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local v = math.exp(data.W)
	local v2 = X * X + Y * Y + Z * Z

	if v2 > 0 then
		local v3 = v2 ^ 0.5
		local v4 = v * math.sin(v3) / v3
		return (new(X * v4, Y * v4, Z * v4, v * math.cos(v3)))
	else
		return (new(0, 0, 0, v))
	end
end

Quaternion.Exp = Exp

function Quaternion.ExpMap(p, p2)
	return (Mul(p, Exp(p2)))
end

function Quaternion.ExpMapSym(p, p2)
	local pow = Pow(p, 0.5)
	return (Mul(Mul(pow, Exp(p2)), pow))
end

local function Log(data)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local v = X * X + Y * Y + Z * Z
	local v2 = W * W + v

	if not (v2 > 0) then
		return (new(0, 0, 0, -1e999))
	end

	if v > 0 then
		local v3 = v2 ^ 0.5
		local v4 = math.acos(W / v3) / v ^ 0.5
		return (new(X * v4, Y * v4, Z * v4, math.log(v3)))
	else
		return (new(0, 0, 0, math.log(v2) / 2))
	end
end

Quaternion.Log = Log

function Quaternion:LogMap(p)
	return (Log(Mul(self:Inverse(), p)))
end

function Quaternion.LogMapSym(p, p2)
	local pow = Pow(p, -0.5)
	return (Log(Mul(Mul(pow, p2), pow)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Length(data)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	return (X * X + Y * Y + Z * Z + W * W) ^ 0.5
end

Quaternion.Length = Length
Quaternion.__len = Length

function Quaternion.LengthSquared(data)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	return X * X + Y * Y + Z * Z + W * W
end

function Quaternion.Hypot(data)
	local v = math.max(data.X, data.Y, data.Z, data.W)

	if not (v > 0) then
		return 0
	end

	return Length(new(data.X / v, data.Y / v, data.Z / v, data.W / v)) * v
end

function Quaternion.Normalize(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown

	if length > 0 then
		return (new(data.X / length, data.Y / length, data.Z / length, data.W / length))
	end

	return Quaternion.identity
end

function Quaternion.IsUnit(data, value: number)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	return (value or 5e-7) > math.abs(1 - (X * X + Y * Y + Z * Z + W * W) ^ 0.5)
end

function Quaternion:ToCFrame(vector2: Vector3?)
	local length = Length(self) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(self.X / length, self.Y / length, self.Z / length, self.W / length)
	else
		identity = Quaternion.identity
	end

	local v2 = vector2 or Vector3.new()
	return CFrame.new(v2.X, v2.Y, v2.Z, identity.X, identity.Y, identity.Z, identity.W)
end

function Quaternion:Dot(data2)
	return self.X * data2.X + self.Y * data2.Y + self.Z * data2.Z + self.W * data2.W
end

function Quaternion:Conjugate()
	return (new(-self.X, -self.Y, -self.Z, self.W))
end

function Quaternion:Inverse()
	local X = self.X
	local Y = self.Y
	local Z = self.Z
	local W = self.W
	local v = X * X + Y * Y + Z * Z + W * W
	return (new(-self.X / v, -self.Y / v, -self.Z / v, self.W / v))
end

local function Negate(data)
	return (new(-data.X, -data.Y, -data.Z, -data.W))
end

Quaternion.Negate = Negate
Quaternion.__unm = Negate

function Quaternion.Difference(data, data2)
	if data.X * data2.X + data.Y * data2.Y + data.Z * data2.Z + data.W * data2.W < 0 then
		data = new(-data.X, -data.Y, -data.Z, -data.W)
	end

	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local v2 = X * X + Y * Y + Z * Z + W * W
	return (Mul(new(-data.X / v2, -data.Y / v2, -data.Z / v2, data.W / v2), data2))
end

function Quaternion:Distance(p)
	return Length(Log(Mul(self:Inverse(), p))) * 2
end

function Quaternion.DistanceSym(data, data2)
	if data.X * data2.X + data.Y * data2.Y + data.Z * data2.Z + data.W * data2.W < 0 then
		data = new(-data.X, -data.Y, -data.Z, -data.W)
	end

	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local v3 = X * X + Y * Y + Z * Z + W * W
	return Length(Log(Mul(new(-data.X / v3, -data.Y / v3, -data.Z / v3, data.W / v3), data2))) * 2
end

function Quaternion.DistanceChord(data, data2)
	if data.X * data2.X + data.Y * data2.Y + data.Z * data2.Z + data.W * data2.W < 0 then
		data = new(-data.X, -data.Y, -data.Z, -data.W)
	end

	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local v3 = X * X + Y * Y + Z * Z + W * W
	local log = Log(Mul(new(-data.X / v3, -data.Y / v3, -data.Z / v3, data.W / v3), data2))
	return math.sin(Length(log) * 2 / 2) * 2
end

function Quaternion.DistanceAbs(data, data2)
	local sub = Sub(data, data2) -- equivalent call inferred; original call site unknown
	local add = Add(data, data2) -- equivalent call inferred; original call site unknown
	local length = Length(sub) -- equivalent call inferred; original call site unknown
	local length2 = Length(add) -- equivalent call inferred; original call site unknown

	if length < length2 then
		return length
	end

	return length2
end

function Quaternion.Slerp(data, data2, p: number)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local length2 = Length(data2) -- equivalent call inferred; original call site unknown
	local identity2

	if length2 > 0 then
		identity2 = new(data2.X / length2, data2.Y / length2, data2.Z / length2, data2.W / length2)
	else
		identity2 = Quaternion.identity
	end

	local v3 = identity.X * identity2.X + identity.Y * identity2.Y + identity.Z * identity2.Z + identity.W * identity2.W

	if v3 < 0 then
		identity = new(-identity.X, -identity.Y, -identity.Z, -identity.W)
		v3 = -v3
	end

	if v3 >= 1 then
		local sub = Sub(identity2, identity) -- equivalent call inferred; original call site unknown
		local add = Add(identity, new(sub.X * p, sub.Y * p, sub.Z * p, sub.W * p)) -- equivalent call inferred; original call site unknown
		local length3 = Length(add) -- equivalent call inferred; original call site unknown

		if length3 > 0 then
			return (new(add.X / length3, add.Y / length3, add.Z / length3, add.W / length3))
		end

		return Quaternion.identity
	else
		local v4 = math.acos(v3)
		local v5 = math.sin(v4)
		local v6 = v4 * p
		local v7 = math.sin(v6)
		local v8 = math.cos(v6) - v3 * v7 / v5
		local v9 = v7 / v5
		local add = Add(
			new(identity.X * v8, identity.Y * v8, identity.Z * v8, identity.W * v8),
			new(identity2.X * v9, identity2.Y * v9, identity2.Z * v9, identity2.W * v9)
		) -- equivalent call inferred; original call site unknown
		local length3 = Length(add) -- equivalent call inferred; original call site unknown

		if length3 > 0 then
			return (new(add.X / length3, add.Y / length3, add.Z / length3, add.W / length3))
		end

		return Quaternion.identity
	end
end

function Quaternion.IdentitySlerp(p, p2: number)
	if p.W < 0 then
		return -Pow(-p, p2)
	end

	return Pow(p, p2)
end

local function SlerpFunction(data, data2)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local length2 = Length(data2) -- equivalent call inferred; original call site unknown
	local identity2

	if length2 > 0 then
		identity2 = new(data2.X / length2, data2.Y / length2, data2.Z / length2, data2.W / length2)
	else
		identity2 = Quaternion.identity
	end

	local v3 = identity2
	local v4 = identity.X * v3.X + identity.Y * v3.Y + identity.Z * v3.Z + identity.W * v3.W

	if v4 < 0 then
		identity = new(-identity.X, -identity.Y, -identity.Z, -identity.W)
		v4 = -v4
	end

	if v4 >= 1 then
		local sub = Sub(identity2, identity) -- equivalent call inferred; original call site unknown
		return function(p: number)
			local sub2 = sub
			local add = Add(identity, new(sub2.X * p, sub2.Y * p, sub2.Z * p, sub2.W * p)) -- equivalent call inferred; original call site unknown
			local length3 = Length(add) -- equivalent call inferred; original call site unknown

			if length3 > 0 then
				return (new(add.X / length3, add.Y / length3, add.Z / length3, add.W / length3))
			end

			return Quaternion.identity
		end
	else
		local v5 = math.acos(v4)
		local v6 = math.sin(v5)
		return function(p: number)
			local v7 = v5 * p
			local v8 = math.sin(v7)
			local v9 = math.cos(v7) - v4 * v8 / v6
			local v10 = v8 / v6
			local v11 = identity
			local v13 = identity2
			local add = Add(
				new(v11.X * v9, v11.Y * v9, v11.Z * v9, v11.W * v9),
				new(v13.X * v10, v13.Y * v10, v13.Z * v10, v13.W * v10)
			) -- equivalent call inferred; original call site unknown
			local length3 = Length(add) -- equivalent call inferred; original call site unknown

			if length3 > 0 then
				return (new(add.X / length3, add.Y / length3, add.Z / length3, add.W / length3))
			end

			return Quaternion.identity
		end
	end
end

Quaternion.SlerpFunction = SlerpFunction

function Quaternion.Intermediates(p, p2, p3: number, flag: boolean?)
	local v = flag or false
	local v2 = 1 / (p3 + 1)
	local slerpFunction = SlerpFunction(p, p2)
	local result = v and { p } or {}

	for i = 1, p3 do
		table.insert(result, (slerpFunction(v2 * i)))
	end

	if v then
		table.insert(result, p2)
	end

	return result
end

function Quaternion.Derivative(data, vector2: Vector3)
	return (Mul(new(data.X * 0.5, data.Y * 0.5, data.Z * 0.5, data.W * 0.5), new(vector2.X, vector2.Y, vector2.Z, 0)))
end

function Quaternion.Integrate(data, vector2: Vector3, p: number)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local v2 = vector2 * p
	local magnitude = v2.Magnitude

	if not (magnitude > 0) then
		return identity
	end

	local v3 = v2 / magnitude
	local v4 = not (v3.Magnitude > 5e-7) and createVector(1, 0, 0) or v3.Unit
	local halfMagnitude = magnitude / 2
	local v6 = math.sin(halfMagnitude)
	local mul = Mul(identity, new(v6 * v4.X, v6 * v4.Y, v6 * v4.Z, math.cos(halfMagnitude)))
	local length2 = Length(mul) -- equivalent call inferred; original call site unknown

	if length2 > 0 then
		return (new(mul.X / length2, mul.Y / length2, mul.Z / length2, mul.W / length2))
	end

	return Quaternion.identity
end

function Quaternion:AngularVelocity(p, p2: number)
	if p2 > 0 then
		return self:Difference(p):ToEulerVector() / p2
	end

	return (Vector3.new())
end

function Quaternion:MinimalRotation(object2)
	local _, vector2, _ = self:ToMatrixVectors()
	local _, v, _ = object2:ToMatrixVectors()
	local cross = vector2:Cross(v)
	local v2 = math.atan2(cross.Magnitude, (vector2:Dot(v)))
	local v3 = not (cross.Magnitude > 5e-7) and createVector(1, 0, 0) or cross.Unit
	local v4 = v2 / 2
	local v5 = math.sin(v4)
	return (new(v5 * v3.X, v5 * v3.Y, v5 * v3.Z, math.cos(v4)))
end

function Quaternion.ApproxEq(data, data2, value: number?)
	if data.X * data2.X + data.Y * data2.Y + data.Z * data2.Z + data.W * data2.W < 0 then
		data = new(-data.X, -data.Y, -data.Z, -data.W)
	end

	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	local v4 = X * X + Y * Y + Z * Z + W * W
	return Length(Log(Mul(new(-data.X / v4, -data.Y / v4, -data.Z / v4, data.W / v4), data2))) * 2 < (value or 5e-7)
end

function Quaternion.IsNaN(data)
	local X = data.X
	local Y = data.Y
	local Z = data.Z
	local W = data.W
	return X ~= X or Y ~= Y or Z ~= Z or W ~= W
end

local function _toRotationMatrix(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = X * X
	local v3 = Y * Y
	local v4 = Z * Z
	local v5 = W * W
	local v6 = v2 - v3 - v4 + v5
	local v7 = -v2 + v3 - v4 + v5
	local v8 = -v2 - v3 + v4 + v5
	local v9 = X * Y
	local v10 = Z * W
	local v11 = 2 * (v9 + v10)
	local v12 = 2 * (v9 - v10)
	local v13 = X * Z
	local v14 = Y * W
	local v15 = 2 * (v13 - v14)
	local v16 = 2 * (v13 + v14)
	local v17 = Y * Z
	local v18 = X * W
	local v19 = 2 * (v17 + v18)
	return v6, v12, v16, v11, v7, 2 * (v17 - v18), v15, v19, v8
end

function Quaternion:ToAxisAngle()
	local length = Length(self) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(self.X / length, self.Y / length, self.Z / length, self.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = math.acos(W) * 2
	local v3 = math.sqrt(1 - W * W)

	if v3 < 5e-7 then
		return Vector3.new(X, Y, Z), v2
	end

	return Vector3.new(X / v3, Y / v3, Z / v3), v2
end

function Quaternion:ToEulerVector()
	local length = Length(self) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(self.X / length, self.Y / length, self.Z / length, self.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = math.acos(W) * 2
	local v3 = math.sqrt(1 - W * W)

	if v3 < 5e-7 then
		return Vector3.new(X, Y, Z) * v2
	end

	return Vector3.new(X / v3, Y / v3, Z / v3) * v2
end

function Quaternion.ToMatrix(p)
	return _toRotationMatrix(p)
end

function Quaternion:ToMatrixVectors()
	local v, v2, v3, v4, v5, v6, v7, v8, v9 = _toRotationMatrix(self)
	return Vector3.new(v, v4, v7), Vector3.new(v2, v5, v8), (Vector3.new(v3, v6, v9))
end

function Quaternion:Vector()
	return (Vector3.new(self.X, self.Y, self.Z))
end

function Quaternion.Real(p)
	return (new(0, 0, 0, p.W))
end

function Quaternion.Imaginary(data)
	return (new(data.X, data.Y, data.Z, 0))
end

local function ToEulerAnglesXYZ(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = Y * W + X * Z

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 > 0 and 1 or -1
		return v3 * 2 * math.atan2(Z, W), v3 * 3.141592653589793 / 2, 0
	end

	local v3 = Y * Y
	return
		math.atan2(2 * (X * W - Y * Z), 1 - 2 * (X * X + v3)),
		math.asin(2 * v2),
		(math.atan2(2 * (Z * W - X * Y), 1 - 2 * (Z * Z + v3)))
end

local function ToEulerAnglesXZY(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = Z * W - X * Y

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 >= 0 and 1 or -1
		return v3 * 2 * -math.atan2(Y, W), 0, v3 * 3.141592653589793 / 2
	end

	local v3 = Z * Z
	return
		math.atan2(2 * (X * W + Y * Z), 1 - 2 * (X * X + v3)),
		math.atan2(2 * (X * Z + Y * W), 1 - 2 * (Y * Y + v3)),
		(math.asin(2 * v2))
end

local function ToEulerAnglesYXZ(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = X * W - Y * Z

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 >= 0 and 1 or -1
		return v3 * 3.141592653589793 / 2, v3 * 2 * -math.atan2(Z, W), 0
	end

	local v3 = X * X
	return
		math.asin(2 * v2),
		math.atan2(2 * (X * Z + Y * W), 1 - 2 * (Y * Y + v3)),
		(math.atan2(2 * (X * Y + Z * W), 1 - 2 * (Z * Z + v3)))
end

local function ToEulerAnglesYZX(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = Z * W + X * Y

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 >= 0 and 1 or -1
		return 0, v3 * 2 * math.atan2(X, W), v3 * 3.141592653589793 / 2
	end

	local v3 = Z * Z
	return
		math.atan2(2 * (X * W - Y * Z), 1 - 2 * (X * X + v3)),
		math.atan2(2 * (Y * W - X * Z), 1 - 2 * (Y * Y + v3)),
		(math.asin(2 * v2))
end

local function ToEulerAnglesZXY(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = X * W + Y * Z

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 >= 0 and 1 or -1
		return v3 * 3.141592653589793 / 2, 0, v3 * 2 * math.atan2(Y, W)
	end

	local v3 = X * X
	return
		math.asin(2 * v2),
		math.atan2(2 * (Y * W - X * Z), 1 - 2 * (Y * Y + v3)),
		(math.atan2(2 * (Z * W - X * Y), 1 - 2 * (Z * Z + v3)))
end

local function ToEulerAnglesZYX(data)
	local length = Length(data) -- equivalent call inferred; original call site unknown
	local identity

	if length > 0 then
		identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
	else
		identity = Quaternion.identity
	end

	local X = identity.X
	local Y = identity.Y
	local Z = identity.Z
	local W = identity.W
	local v2 = Y * W - X * Z

	if math.abs(v2) > 0.4999995 then
		local v3 = v2 >= 0 and 1 or -1
		return 0, v3 * 3.141592653589793 / 2, v3 * 2 * -math.atan2(X, W)
	end

	local v3 = Y * Y
	return
		math.atan2(2 * (X * W + Y * Z), 1 - 2 * (X * X + v3)),
		math.asin(2 * v2),
		(math.atan2(2 * (X * Y + Z * W), 1 - 2 * (Z * Z + v3)))
end

local v = {
	XYZ = ToEulerAnglesXYZ,
	XZY = ToEulerAnglesXZY,
	YZX = ToEulerAnglesYZX,
	YXZ = ToEulerAnglesYXZ,
	ZXY = ToEulerAnglesZXY,
	ZYX = ToEulerAnglesZYX
}

function Quaternion.ToEulerAngles(p, p2)
	return v[(p2 or Enum.RotationOrder.XYZ).Name](p)
end

Quaternion.ToEulerAnglesXYZ = ToEulerAnglesXYZ
Quaternion.ToEulerAnglesYXZ = ToEulerAnglesYXZ
Quaternion.ToOrientation = ToEulerAnglesYXZ

local function GetComponents(data)
	return data.X, data.Y, data.Z, data.W
end

Quaternion.GetComponents = GetComponents
Quaternion.components = GetComponents

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p: number, _TO_STRING_CHAR: number?)
	if not _TO_STRING_CHAR then
		return (tostring(p))
	end

	local v2 = math.max(0, _TO_STRING_CHAR)
	local v3 = string.format("%%.%df", v2)
	return (string.format(v3, p))
end

local function ToString(data, _TO_STRING_CHAR: number?)
	if Quaternion._TO_STRING_CHAR then
		_TO_STRING_CHAR = Quaternion._TO_STRING_CHAR
	end

	local v2 = round(data.X, _TO_STRING_CHAR) -- equivalent call inferred; original call site unknown
	local v4 = round(data.Y, _TO_STRING_CHAR) -- equivalent call inferred; original call site unknown
	local v6 = round(data.Z, _TO_STRING_CHAR) -- equivalent call inferred; original call site unknown
	local v8 = round(data.W, _TO_STRING_CHAR) -- equivalent call inferred; original call site unknown
	return v2 .. ", " .. v4 .. ", " .. v6 .. ", " .. v8
end

Quaternion.__tostring = ToString
Quaternion.ToString = ToString

function Quaternion.__index(data, value)
	local v2 = Quaternion[value]

	if v2 then
		return v2
	end

	local v3 = string.lower(value)
	local v4 = rawget(data, "_cached")

	if v3 == "unit" then
		if v4.unit then
			return v4.unit
		end

		local length = Length(data) -- equivalent call inferred; original call site unknown
		local identity

		if length > 0 then
			identity = new(data.X / length, data.Y / length, data.Z / length, data.W / length)
		else
			identity = Quaternion.identity
		end

		v4.unit = identity
		return identity
	else
		if v3 ~= "magnitude" then
			return nil
		end

		if v4.magnitude then
			return v4.magnitude
		end

		local magnitude = Length(data) -- equivalent call inferred; original call site unknown
		v4.magnitude = magnitude
		return magnitude
	end
end

function Quaternion.__newindex(_, p)
	error(tostring(p) .. " cannot be assigned to")
end

table.freeze(Quaternion)
return Quaternion