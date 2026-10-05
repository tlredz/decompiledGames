local createVector = vector.create
local exp = math.exp
local sin = math.sin
local cos = math.cos
local min = math.min
local sqrt = math.sqrt
local round = math.round

local function magnitudeSq(items)
	local total = 0

	for _, item in items do
		total += item ^ 2
	end

	return total
end

local function distanceSq(items, p)
	local total = 0

	for k, item in items do
		total += (p[k] - item) ^ 2
	end

	return total
end

local function matrixToAxis(cframe: CFrame)
	local axisAngle, v = cframe:ToAxisAngle()
	return axisAngle * v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function axisToMatrix(vector2: Vector3)
	local magnitude = vector2.Magnitude

	if magnitude > 1e-6 then
		return CFrame.fromAxisAngle(vector2.Unit, magnitude)
	end

	return CFrame.identity
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function inverseGammaCorrectD65(p: number)
	return p < 0.0404482362771076 and p / 12.92 or (p + 0.055) ^ 2.4 * 0.87941546140213
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function gammaCorrectD65(p: number)
	return p < 0.0031306684425 and p * 12.92 or p ^ 0.4166666666666667 * 1.055 - 0.055
end

local function rgbToLuv(value: Color3)
	local R = value.R
	local G = value.G
	local B = value.B
	local v = inverseGammaCorrectD65(R)
	local v2 = inverseGammaCorrectD65(G)
	local v3 = inverseGammaCorrectD65(B)
	local v4 = 0.9257063972951867 * v - 0.8333736323779866 * v2 - 0.09209820666085898 * v3
	local v5 = 0.2125862307855956 * v + 0.7151703037034108 * v2 + 0.0722004986433362 * v3
	local v6 = 3.6590806972265884 * v + 11.442689580057424 * v2 + 4.114991502426484 * v3
	local v7 = v5 > 0.008856451679035631 and 116 * v5 ^ 0.3333333333333333 - 16 or 903.296296296296 * v5
	local v8, v9

	if v6 > 1e-14 then
		v8 = v7 * v4 / v6
		v9 = v7 * (9 * v5 / v6 - 0.46832)
	else
		v8 = -0.19783 * v7
		v9 = -0.46832 * v7
	end

	return { v7, v8, v9 }
end

local function luvToRgb(list)
	local v = list[1]

	if v < 0.0197955 then
		return Color3.new(0, 0, 0)
	end

	local v2 = list[2] / v + 0.19783
	local v3 = list[3] / v + 0.46832
	local v4 = (v + 16) / 116
	local v5 = v4 > 0.20689655172413793 and v4 * v4 * v4 or v4 * 0.12841854934601665 - 0.01771290335807126
	local v6 = v5 * v2 / v3
	local v7 = v5 * ((3 - v2 * 0.75) / v3 - 5)
	local v8 = v6 * 7.2914074 - v5 * 1.537208 - v7 * 0.4986286
	local v9 = v6 * -2.180094 + v5 * 1.8757561 + v7 * 0.0415175
	local v10 = v6 * 0.1253477 - v5 * 0.2040211 + v7 * 1.0569959

	if v8 < 0 and v8 < v9 and v8 < v10 then
		v9 -= v8
		v10 -= v8
		v8 = 0
	elseif v9 < 0 and v9 < v10 then
		v8 -= v9
		v10 -= v9
		v9 = 0
	elseif v10 < 0 then
		v8 -= v10
		v9 -= v10
		v10 = 0
	end

	local v11 = gammaCorrectD65(v8)
	local v12 = min(v11, 1)
	local v13 = gammaCorrectD65(v9)
	local v14 = min(v13, 1)
	local v15 = gammaCorrectD65(v10)
	return Color3.new(v12, v14, (min(v15, 1)))
end

local class = {}
class.__index = class

function class.new(p: number, p2: number, p3, rawGoal, metadata)
	local intermediate = metadata.toIntermediate(p3)
	return (setmetatable({
		d = p,
		f = p2,
		g = metadata.toIntermediate(rawGoal),
		p = intermediate,
		v = table.create(#intermediate, 0),
		metadata = metadata,
		rawGoal = rawGoal
	}, class))
end

function class:setGoal(rawGoal)
	self.rawGoal = rawGoal
	self.g = self.metadata.toIntermediate(rawGoal)
end

function class:setDampingRatio(p2: number)
	self.d = p2
end

function class:setFrequency(p2: number)
	self.f = p2
end

function class:setPosition(p)
	self.p = self.metadata.toIntermediate(p)
	self.v = table.create(#self.p, 0)
end

function class:getPosition()
	return self.metadata.fromIntermediate(self.p)
end

function class:addVelocity(p2)
	local intermediate = self.metadata.toIntermediate(p2)

	for k, v in intermediate do
		self.v[k] = (self.v[k] or 0) + v
	end
end

function class:canSleep()
	local total = 0

	for _, v in self.v do
		total += v ^ 2
	end

	if total > 0.0001 then
		return false
	end

	local p = self.p
	local g = self.g
	local total2 = 0

	for k, v in p do
		total2 += (g[k] - v) ^ 2
	end

	return not (total2 > 6.781684027777778e-8)
end

function class:step(p: number)
	local d = self.d
	local v = self.f * 2 * 3.141592653589793
	local g = self.g
	local p2 = self.p
	local v2 = self.v

	if d == 1 then
		local v4 = exp(-v * p)
		local v5 = p * v4
		local v6 = v4 + v5 * v
		local v7 = v4 - v5 * v
		local v8 = v5 * v * v

		for i = 1, #p2 do
			local v9 = p2[i] - g[i]
			p2[i] = v9 * v6 + v2[i] * v5 + g[i]
			v2[i] = v2[i] * v7 - v9 * v8
		end
	elseif d < 1 then
		local v4 = exp(-d * v * p)
		local v6 = sqrt(1 - d * d)
		local v8 = cos(p * v * v6)
		local v10 = sin(p * v * v6)
		local v11

		if v6 > 0.00001 then
			v11 = v10 / v6
		else
			local v12 = p * v
			v11 = v12 + (v12 * v12 * (v6 * v6) * (v6 * v6) / 20 - v6 * v6) * (v12 * v12 * v12) / 6
		end

		local v12

		if v * v6 > 0.00001 then
			v12 = v10 / (v * v6)
		else
			local v13 = v * v6
			v12 = p + (p * p * (v13 * v13) * (v13 * v13) / 20 - v13 * v13) * (p * p * p) / 6
		end

		for i = 1, #p2 do
			local v13 = p2[i] - g[i]
			p2[i] = (v13 * (v8 + v11 * d) + v2[i] * v12) * v4 + g[i]
			v2[i] = (v2[i] * (v8 - v11 * d) - v13 * (v11 * v)) * v4
		end
	else
		local v4 = sqrt(d * d - 1)
		local v5 = -v * (d - v4)
		local v6 = -v * (d + v4)
		local v8 = exp(v5 * p)
		local v10 = exp(v6 * p)

		for i = 1, #p2 do
			local v11 = p2[i] - g[i]
			local v12 = (v2[i] - v11 * v5) / (2 * v * v4)
			local v13 = v8 * (v11 - v12)
			p2[i] = v13 + v12 * v10 + g[i]
			v2[i] = v13 * v5 + v12 * v10 * v6
		end
	end

	return self.metadata.fromIntermediate(self.p)
end

local class2 = {}
class2.__index = class2

function class2.new(p: number, p2: number, cframe: CFrame, cframe2: CFrame)
	return (setmetatable({
		d = p,
		f = p2,
		g = cframe2.Rotation,
		p = cframe.Rotation,
		v = createVector(0, 0, 0)
	}, class2))
end

function class2:setGoal(cframe: CFrame)
	self.g = cframe.Rotation
end

function class2:setDampingRatio(p2: number)
	self.d = p2
end

function class2:setFrequency(p2: number)
	self.f = p2
end

function class2:setPosition(cframe: CFrame)
	self.p = cframe.Rotation
	self.v = createVector(0, 0, 0)
end

function class2:getPosition()
	return self.p
end

function class2:addVelocity(vector2: Vector3)
	self.v += vector2
end

function class2:canSleep()
	if self.v.Magnitude > 0.0017453292519943296 then
		return false
	end

	local axisAngle, v = (self.p * self.g:Inverse()):ToAxisAngle()
	return not ((axisAngle * v).Magnitude > 0.00017453292519943296)
end

function class2:step(p: number)
	local d = self.d
	local v = self.f * 2 * 3.141592653589793
	local g = self.g
	local p2 = self.p
	local v2 = self.v
	local axisAngle, v3 = (p2 * g:Inverse()):ToAxisAngle()
	local v4 = axisAngle * v3
	local v6 = exp(-d * v * p)
	local v7, v8

	if d == 1 then
		local v10 = axisToMatrix((v4 * (1 + v * p) + v2 * p) * v6) -- equivalent call inferred; original call site unknown
		v7 = v10 * g
		v8 = (v2 * (1 - p * v) - v4 * (p * v * v)) * v6
	elseif d < 1 then
		local v10 = sqrt(1 - d * d)
		local v12 = cos(p * v * v10)
		local v14 = sin(p * v * v10)
		local v15

		if v * v10 > 0.00001 then
			v15 = v14 / (v * v10)
		else
			v15 = p
		end

		local v16

		if v10 > 0.00001 then
			v16 = v14 / v10
		else
			v16 = p * v
		end

		local v18 = axisToMatrix((v4 * (v12 + v16 * d) + v2 * v15) * v6) -- equivalent call inferred; original call site unknown
		v7 = v18 * g
		v8 = (v2 * (v12 - v16 * d) - v4 * (v16 * v)) * v6
	else
		local v10 = sqrt(d * d - 1)
		local v11 = -v * (d - v10)
		local v12 = -v * (d + v10)
		local v13 = (v2 - v4 * v11) / (2 * v * v10)
		local v16 = (v4 - v13) * exp(v11 * p)
		local v18 = v13 * exp(v12 * p)
		local v20 = axisToMatrix(v16 + v18) -- equivalent call inferred; original call site unknown
		v7 = v20 * g
		v8 = v16 * v11 + v18 * v12
	end

	self.p = v7
	self.v = v8
	return v7
end

local vector3 = {
	springType = class.new,
	toIntermediate = function(data)
		return { data.X, data.Y, data.Z }
	end,
	fromIntermediate = function(list)
		return (Vector3.new(list[1], list[2], list[3]))
	end
}
local class3 = {}
class3.__index = class3

function class3.new(p: number, p2: number, cframe: CFrame, cframe2: CFrame, _)
	return (setmetatable({
		rawGoal = cframe2,
		_position = class.new(p, p2, cframe.Position, cframe2.Position, vector3),
		_rotation = class2.new(p, p2, cframe.Rotation, cframe2.Rotation)
	}, class3))
end

function class3:setGoal(rawGoal: CFrame)
	self.rawGoal = rawGoal
	self._position:setGoal(rawGoal.Position)
	self._rotation:setGoal(rawGoal.Rotation)
end

function class3:setDampingRatio(p2: number)
	self._position:setDampingRatio(p2)
	self._rotation:setDampingRatio(p2)
end

function class3:setFrequency(p2: number)
	self._position:setFrequency(p2)
	self._rotation:setFrequency(p2)
end

function class3:setPosition(cframe: CFrame)
	self._position:setPosition(cframe.Position)
	self._rotation:setPosition(cframe.Rotation)
end

function class3:getPosition()
	return self._rotation:getPosition() + self._position:getPosition()
end

function class3:addVelocity(cframe: CFrame)
	self._position:addVelocity(cframe.Position)
	local _rotation = self._rotation
	local axisAngle, v2 = cframe.Rotation:ToAxisAngle()
	_rotation:addVelocity(axisAngle * v2)
end

function class3:canSleep()
	return self._position:canSleep() and self._rotation:canSleep()
end

function class3:step(p2: number)
	local v2 = self._position:step(p2)
	return self._rotation:step(p2) + v2
end

local v2 = {
	boolean = {
		springType = class.new,
		toIntermediate = function(p)
			return { p and 1 or 0 }
		end,
		fromIntermediate = function(list)
			return list[1] >= 0.5
		end
	},
	number = {
		springType = class.new,
		toIntermediate = function(p)
			return { p }
		end,
		fromIntermediate = function(list)
			return list[1]
		end
	},
	NumberRange = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.Min, p.Max }
		end,
		fromIntermediate = function(list)
			return NumberRange.new(list[1], (math.max(list[1], list[2])))
		end
	},
	UDim = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.Scale, p.Offset }
		end,
		fromIntermediate = function(list)
			return UDim.new(list[1], (round(list[2])))
		end
	},
	UDim2 = {
		springType = class.new,
		toIntermediate = function(p)
			local X = p.X
			local Y = p.Y
			return {
				X.Scale,
				X.Offset,
				Y.Scale,
				Y.Offset
			}
		end,
		fromIntermediate = function(list)
			return UDim2.new(list[1], round(list[2]), list[3], (round(list[4])))
		end
	},
	Vector2 = {
		springType = class.new,
		toIntermediate = function(p)
			return { p.X, p.Y }
		end,
		fromIntermediate = function(list)
			return Vector2.new(list[1], list[2])
		end
	},
	Vector3 = vector3,
	Color3 = {
		springType = class.new,
		toIntermediate = rgbToLuv,
		fromIntermediate = luvToRgb
	},
	ColorSequence = {
		springType = class.new,
		toIntermediate = function(sequence)
			local keypoints = sequence.Keypoints
			local v3 = rgbToLuv(keypoints[1].Value)
			local v4 = rgbToLuv(keypoints[#keypoints].Value)
			return {
				v3[1],
				v3[2],
				v3[3],
				v4[1],
				v4[2],
				v4[3]
			}
		end,
		fromIntermediate = function(list)
			return ColorSequence.new(luvToRgb({ list[1], list[2], list[3] }), luvToRgb({ list[4], list[5], list[6] }))
		end
	},
	CFrame = {
		springType = class3.new,
		toIntermediate = error,
		fromIntermediate = error
	}
}
local Solver = {}

function Solver.isSupported(p)
	return v2[typeof(p)] ~= nil
end

function Solver.new(p: number, p2: number, p3, p4)
	local v3 = v2[typeof(p4)]
	assert(v3, (`ReplicatedSpring: unsupported spring type "{typeof(p4)}"`))
	assert(
		typeof(p3) == typeof(p4),
		(`ReplicatedSpring: start type "{typeof(p3)}" does not match goal type "{typeof(p4)}"`)
	)
	return (v3.springType(p, p2, p3, p4, v3))
end

return Solver