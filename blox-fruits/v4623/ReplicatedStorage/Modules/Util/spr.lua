local createVector = vector.create
local RunService = game:GetService("RunService")
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

local class = {}
class.__index = class

function class.new(p: number, p2: number, p3, rawGoal, typedat)
	local intermediate = typedat.toIntermediate(p3)
	return (setmetatable({
		d = p,
		f = p2,
		g = intermediate,
		p = intermediate,
		v = table.create(#intermediate, 0),
		typedat = typedat,
		rawGoal = rawGoal
	}, class))
end

function class:setGoal(rawGoal)
	self.rawGoal = rawGoal
	self.g = self.typedat.toIntermediate(rawGoal)
end

function class:setDampingRatio(p2: number)
	self.d = p2
end

function class:setFrequency(p2: number)
	self.f = p2
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

	return self.typedat.fromIntermediate(self.p)
end

local class2 = {}
class2.__index = class2

-- equivalent calls inferred from this helper; original call sites unknown
local function angleBetween(cframe: CFrame, g: CFrame)
	local _, v = g:ToObjectSpace(cframe):ToAxisAngle()
	return (math.abs(v))
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

function class2.new(p: number, p2: number, cframe: CFrame, cframe2: CFrame)
	return (setmetatable({
		d = p,
		f = p2,
		g = cframe2,
		p = cframe,
		v = createVector(0, 0, 0)
	}, class2))
end

function class2:setGoal(cframe: CFrame)
	self.g = cframe
end

function class2:setDampingRatio(p2: number)
	self.d = p2
end

function class2:setFrequency(p2: number)
	self.f = p2
end

function class2:canSleep()
	local v = angleBetween(self.p, self.g) < 0.00017453292519943296
	local v2 = self.v.Magnitude < 0.0017453292519943296
	return v and v2
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
		local vector2 = (v4 * (1 + v * p) + v2 * p) * v6
		local v9 = axisToMatrix(vector2) -- equivalent call inferred; original call site unknown
		v7 = v9 * g
		v8 = (v2 * (1 - p * v) - v4 * (p * v * v)) * v6
	elseif d < 1 then
		local v10 = sqrt(1 - d * d)
		local v12 = cos(p * v * v10)
		local v14 = sin(p * v * v10)
		local v15 = v14 / (v * v10)
		local v16 = v14 / v10
		local vector2 = (v4 * (v12 + v16 * d) + v2 * v15) * v6
		local v17 = axisToMatrix(vector2) -- equivalent call inferred; original call site unknown
		v7 = v17 * g
		v8 = (v2 * (v12 - v16 * d) - v4 * (v16 * v)) * v6
	else
		local v10 = sqrt(d * d - 1)
		local v11 = -v * (d - v10)
		local v12 = -v * (d + v10)
		local v13 = (v2 - v4 * v11) / (2 * v * v10)
		local v16 = (v4 - v13) * exp(v11 * p)
		local v18 = v13 * exp(v12 * p)
		local vector2 = v16 + v18
		local v19 = axisToMatrix(vector2) -- equivalent call inferred; original call site unknown
		v7 = v19 * g
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

function class3:canSleep()
	return self._position:canSleep() and self._rotation:canSleep()
end

function class3:step(p2)
	local vector2 = self._position:step(p2)
	return self._rotation:step(p2) + vector2
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function inverseGammaCorrectD65(p)
	return p < 0.0404482362771076 and p / 12.92 or 0.87941546140213 * (p + 0.055) ^ 2.4
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function gammaCorrectD65(p)
	return p < 0.0031306684425 and 12.92 * p or 1.055 * p ^ 0.4166666666666667 - 0.055
end

local function rgbToLuv(value: Color3)
	local R = value.R
	local G = value.G
	local B = value.B
	local v2 = inverseGammaCorrectD65(R)
	local v3 = inverseGammaCorrectD65(G)
	local v4 = inverseGammaCorrectD65(B)
	local v5 = 0.9257063972951867 * v2 - 0.8333736323779866 * v3 - 0.09209820666085898 * v4
	local v6 = 0.2125862307855956 * v2 + 0.7151703037034108 * v3 + 0.0722004986433362 * v4
	local v7 = 3.6590806972265884 * v2 + 11.442689580057424 * v3 + 4.114991502426484 * v4
	local v8 = v6 > 0.008856451679035631 and 116 * v6 ^ 0.3333333333333333 - 16 or 903.296296296296 * v6
	local v9, v10

	if v7 > 1e-14 then
		v9 = v8 * v5 / v7
		v10 = v8 * (9 * v6 / v7 - 0.46832)
	else
		v9 = -0.19783 * v8
		v10 = -0.46832 * v8
	end

	return { v8, v9, v10 }
end

local function luvToRgb(list)
	local v2 = list[1]

	if v2 < 0.0197955 then
		return Color3.new(0, 0, 0)
	end

	local v3 = list[2] / v2 + 0.19783
	local v4 = list[3] / v2 + 0.46832
	local v5 = (v2 + 16) / 116
	local v6 = v5 > 0.20689655172413793 and v5 * v5 * v5 or v5 * 0.12841854934601665 - 0.01771290335807126
	local v7 = v6 * v3 / v4
	local v8 = v6 * ((3 - v3 * 0.75) / v4 - 5)
	local v9 = v7 * 7.2914074 - v6 * 1.537208 - v8 * 0.4986286
	local v10 = v7 * -2.180094 + v6 * 1.8757561 + v8 * 0.0415175
	local v11 = v7 * 0.1253477 - v6 * 0.2040211 + v8 * 1.0569959

	if v9 < 0 and v9 < v10 and v9 < v11 then
		v10 -= v9
		v11 -= v9
		v9 = 0
	elseif v10 < 0 and v10 < v11 then
		v9 -= v10
		v11 -= v10
		v10 = 0
	elseif v11 < 0 then
		v9 -= v11
		v10 -= v11
		v11 = 0
	end

	local v12 = gammaCorrectD65(v9)
	local v13 = min(v12, 1)
	local v14 = gammaCorrectD65(v10)
	local v15 = min(v14, 1)
	local v16 = gammaCorrectD65(v11)
	return Color3.new(v13, v15, (min(v16, 1)))
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
			return NumberRange.new(list[1], list[2])
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
local v3 = {
	Pivot = {
		class = "PVInstance",
		get = function(instance)
			return instance:GetPivot()
		end,
		set = function(instance, cframe: CFrame)
			instance:PivotTo(cframe)
		end
	},
	Scale = {
		class = "Model",
		get = function(object)
			return object:GetScale()
		end,
		set = function(instance, p: number)
			instance:ScaleTo(p)
		end
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getProperty(camera, k: string)
	local v4 = v3[k]

	if v4 and camera:IsA(v4.class) then
		return v4.get(camera)
	end

	return camera[k]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setProperty(instance, k: string, p)
	local v4 = v3[k]

	if v4 and instance:IsA(v4.class) then
		v4.set(instance, p)
	else
		instance[k] = p
	end
end

local v4 = {}
local v5 = {}
local v6 = {}

local function processSprings(items, dt: number)
	for k, item in items do
		for k2, v7 in item do
			if v7:canSleep() then
				item[k2] = nil
				setProperty(k, k2, v7.rawGoal) -- equivalent call inferred; original call site unknown
			else
				setProperty(k, k2, v7:step(dt)) -- equivalent call inferred; original call site unknown
			end
		end

		if next(item) then
			continue
		end

		items[k] = nil
		local v7 = v6[k]

		if not v7 then
			continue
		end

		v6[k] = nil

		for _, callback in v7 do
			task.spawn(callback)
		end
	end
end

RunService.PreSimulation:Connect(function(dt)
	processSprings(v4, dt)
end)
RunService.PostSimulation:Connect(function(dt)
	processSprings(v5, dt)
end)

local function assertType(p: number, p2: string, value: string, p3)
	if not value:find((typeof(p3))) then
		error(`bad argument #{p} to {p2} ({value} expected, got {typeof(p3)})`, 3)
	end
end

return table.freeze({
	getState = function(camera, p: string?)
		local v7

		if camera:IsA("Camera") then
			v7 = v5
		else
			v7 = v4
		end

		local selected = v7 and v7[camera]

		if selected and p then
			return selected[p]
		end

		return selected
	end,
	target = function(camera, p: number, p2: number, items)
		if not ("Instance"):find((typeof(camera))) then
			error(`bad argument #{1} to spr.target (Instance expected, got {typeof(camera)})`, 3)
		end

		if not ("number"):find((typeof(p))) then
			error(`bad argument #{2} to spr.target (number expected, got {typeof(p)})`, 3)
		end

		if not ("number"):find((typeof(p2))) then
			error(`bad argument #{3} to spr.target (number expected, got {typeof(p2)})`, 3)
		end

		if not ("table"):find((typeof(items))) then
			error(`bad argument #{4} to spr.target (table expected, got {typeof(items)})`, 3)
		end

		if p ~= p or p < 0 then
			error(("expected damping ratio >= 0; got %.2f"):format(p), 2)
		end

		if p2 ~= p2 or p2 < 0 then
			error(("expected undamped frequency >= 0; got %.2f"):format(p2), 2)
		end

		local v7

		if camera:IsA("Camera") then
			v7 = v5
		else
			v7 = v4
		end

		local v8 = v7[camera]

		if not v8 then
			v8 = {}
			v7[camera] = v8
		end

		for k, item in items do
			local property = getProperty(camera, k) -- equivalent call inferred; original call site unknown

			if typeof(item) ~= typeof(property) then
				error(`bad property {k} to spr.target ({typeof(property)} expected, got {typeof(item)})`, 2)
			end

			if p2 == 1e999 then
				setProperty(camera, k, item) -- equivalent call inferred; original call site unknown
				v8[k] = nil
			else
				local v9 = v8[k]

				if not v9 then
					local v10 = v2[typeof(item)]

					if not v10 then
						error("unsupported type: " .. typeof(item), 2)
					end

					v9 = v10.springType(p, p2, property, item, v10)
					v8[k] = v9
				end

				v9:setGoal(item)
				v9:setDampingRatio(p)
				v9:setFrequency(p2)
			end
		end

		if not next(v8) then
			v7[camera] = nil
		end
	end,
	stop = function(p, p2: string?)
		if not ("Instance"):find((typeof(p))) then
			error(`bad argument #{1} to spr.stop (Instance expected, got {typeof(p)})`, 3)
		end

		if not ("string|nil"):find((typeof(p2))) then
			error(`bad argument #{2} to spr.stop (string|nil expected, got {typeof(p2)})`, 3)
		end

		if p2 then
			local v7 = v4[p] or v5[p]

			if v7 then
				v7[p2] = nil
			end
		else
			v4[p] = nil
			v5[p] = nil
		end
	end,
	completed = function(p, callback)
		if not ("Instance"):find((typeof(p))) then
			error(`bad argument #{1} to spr.completed (Instance expected, got {typeof(p)})`, 3)
		end

		if not ("function"):find((typeof(callback))) then
			error(`bad argument #{2} to spr.completed (function expected, got {typeof(callback)})`, 3)
		end

		local v7 = v6[p]

		if v7 then
			table.insert(v7, callback)
		else
			v6[p] = { callback }
		end
	end
})