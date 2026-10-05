local createVector = vector.create
local fac

fac = function(p: number)
	if p == 0 then
		return 1
	end

	return p * fac(p - 1)
end

local Bezier = {}
local class = {}
class.__index = class

function Bezier.new(points)
	return (setmetatable({
		Points = points
	}, class))
end

function Bezier.fromParts(instance)
	local children = instance:GetChildren()
	table.sort(children, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	local positions = {}

	for _, v in children do
		table.insert(positions, v.Position)
	end

	return Bezier.new(positions)
end

function Bezier.random(cframe, p: number, range: NumberRange, value: number?)
	local v = value or 0.9

	if typeof(cframe) == "Vector3" then
		cframe = CFrame.new(cframe) * CFrame.fromEulerAnglesYXZ(
			math.random() * 3.141592653589793 * 2 - 3.141592653589793,
			math.random() * 3.141592653589793 * 2 - 3.141592653589793,
			math.random() * 3.141592653589793 * 2 - 3.141592653589793
		)
	end

	local positions = { cframe.Position }

	for _ = 1, p - 1 do
		local v2 = math.random(range.Min, range.Max)
		local v3 = v2 * v / 2
		local v4 = cframe.LookVector * v2 + cframe.Position
		local v5 = CFrame.new(v4.X, v4.Y, v4.Z, select(4, cframe:GetComponents())) * CFrame.new(
			math.random(-v3, v3),
			math.random(-v3, v3),
			0
		)
		table.insert(positions, v5.Position)
		local cframe2 = CFrame.lookAt(cframe.Position, v5.Position)
		cframe = CFrame.new(v5.X, v5.Y, v5.Z, select(4, cframe2:GetComponents()))
	end

	return Bezier.new(positions)
end

function class:DeCasteljau(p2: number)
	local v = { unpack(self.Points) }
	local count = #v

	for i = 1, count - 1 do
		for i2 = 1, count - i do
			v[i2] = v[i2] * (1 - p2) + v[i2 + 1] * p2
		end
	end

	return v[1]
end

function class.GetPoint(p, p2: number)
	local points = p.Points
	local v = #points - 1
	local v2 = createVector(0, 0, 0)

	for i = 0, v do
		local v3 = v == 0 and 1 or v * fac(v - 1)
		local v4 = i == 0 and 1 or i * fac(i - 1)
		local v5 = v - i
		v2 += v3 / (v4 * (v5 == 0 and 1 or v5 * fac(v5 - 1))) * p2 ^ i * (1 - p2) ^ (v - i) * points[i + 1]
	end

	return v2
end

function class:Polynomial()
	local points = self.Points
	local v = #points - 1
	local result = {}

	for i = 0, v do
		local v2 = createVector(0, 0, 0)

		for i2 = 0, i do
			local v3 = (-1) ^ (i2 + i) * points[i2 + 1]
			local v4 = i2 == 0 and 1 or i2 * fac(i2 - 1)
			local v5 = i - i2
			v2 += v3 / (v4 * (v5 == 0 and 1 or v5 * fac(v5 - 1)))
		end

		local v3 = v2 * (v == 0 and 1 or v * fac(v - 1))
		local v4 = v - i
		result[i] = v3 / (v4 == 0 and 1 or v4 * fac(v4 - 1))
	end

	return function(p2: number)
		local v2 = createVector(0, 0, 0)

		for i = 0, v do
			v2 += p2 ^ i * result[i]
		end

		return v2
	end, result
end

function class:UpdateLUT(value: number?, flag: boolean?)
	local v = value or 101
	local _ = self.Points
	local LUT = {}
	local total = 0
	local v3 = nil

	for i = 0, v - 1 do
		local deCasteljau = self:DeCasteljau(i / (v - 1))

		if i ~= 0 then
			total += (v3 - deCasteljau).Magnitude
		end

		LUT[i] = total
		v3 = deCasteljau
	end

	self.LUT = LUT
	self.Length = total

	if flag or self.RMFLUT then
		local derivative = self:GetDerivative(-0.001)
		local unit = (derivative + self:GetSecondDerivative(-0.001)):Cross(derivative).Unit
		local RMFLUT = {
			[0] = {
				self:DeCasteljau(0),
				derivative,
				unit,
				unit:Cross(derivative)
			}
		}

		for i = 0, 99 do
			local v5 = RMFLUT[i]
			local v6 = (i + 1) / 100
			local v7 = { self:DeCasteljau(v6), self:GetDerivative(v6) }
			local vector2 = v7[1] - v5[1]
			local dot = vector2:Dot(vector2)
			local v8 = v5[3] - vector2 * 2 / dot * vector2:Dot(v5[3])
			local v9 = v5[2] - vector2 * 2 / dot * vector2:Dot(v5[2])
			local vector3 = v7[2] - v9
			v7[3] = v8 - vector3 * 2 / vector3:Dot(vector3) * vector3:Dot(v8)
			v7[4] = v7[3]:Cross(v7[2])
			RMFLUT[i + 1] = v7
		end

		self.RMFLUT = RMFLUT
	end
end

function class:ConvertT(p: number)
	if not self.Length then
		self:UpdateLUT()
	end

	local LUT = self.LUT
	local v = self.Length * p
	local v2 = 0
	local v3 = 0

	for k, v4 in LUT do
		if not (v4 <= v and v2 < v4) then
			continue
		end

		v3 = k
		v2 = v4
	end

	if v2 == v then
		return v3 / #LUT
	end

	if LUT[v3 + 1] then
		return (v3 + (v - v2) / (LUT[v3 + 1] - v2)) / #LUT
	end

	return (v3 + (v - v2) / (LUT[v3 - 1] - v2)) / #LUT
end

function class:GetDerivative(p2: number)
	local points = self.Points
	local v = #points - 2
	local v2 = createVector(0, 0, 0)

	for i = 0, v do
		local v3 = v == 0 and 1 or v * fac(v - 1)
		local v4 = i == 0 and 1 or i * fac(i - 1)
		local v5 = v - i
		v2 += v3 / (v4 * (v5 == 0 and 1 or v5 * fac(v5 - 1))) * p2 ^ i * (1 - p2) ^ (v - i) * (points[i + 2] - points[i + 1])
	end

	return v2 * (v + 1)
end

function class:GetSecondDerivative(p2: number)
	local points = self.Points
	local v = #points - 3
	local v2 = createVector(0, 0, 0)

	for i = 0, v do
		local v3 = v == 0 and 1 or v * fac(v - 1)
		local v4 = i == 0 and 1 or i * fac(i - 1)
		local v5 = v - i
		v2 += v3 / (v4 * (v5 == 0 and 1 or v5 * fac(v5 - 1))) * p2 ^ i * (1 - p2) ^ (v - i) * ((v + 2) * (v + 1) * (points[i + 3] - 2 * points[i + 2] + points[i + 1]))
	end

	return v2
end

function class:CreateDerivativeCurve(value: number?)
	local v = value or 1
	local points = self.Points
	local v2 = {}

	for i = 1, #points - v do
		local v3 = createVector(0, 0, 0)

		for i2 = 0, v do
			local v4 = (-1) ^ (v - i2)
			local v5 = v == 0 and 1 or v * fac(v - 1)
			local v6 = i2 == 0 and 1 or i2 * fac(i2 - 1)
			local v7 = v - i2
			v3 += v4 * (v5 / (v6 * (v7 == 0 and 1 or v7 * fac(v7 - 1)))) * points[i + i2]
		end

		table.insert(v2, v3)
	end

	return Bezier.new(v2)
end

function class:GetCurvature(p: number)
	local derivative = self:GetDerivative(p)
	return derivative:Cross(self:GetSecondDerivative(p)).Magnitude / derivative.Magnitude ^ 3
end

function class.GetIterations(p, p2: number, callback)
	local v = callback or class.DeCasteljau
	local result = {}

	for i = 0, p2 - 1 do
		table.insert(result, v(p, i / (p2 - 1)))
	end

	return result
end

function class.Subdivide(p, value: number?)
	local points = p.Points
	local count = #points
	local v = {}
	local v2 = value or 0.5
	local v3 = {}

	for i = 1, count - 1 do
		for i2 = 1, count - i do
			if i2 == 1 then
				table.insert(v3, points[1])
			end

			if i2 == count - i then
				table.insert(v, points[i2 + 1])
			end

			points[i2] = points[i2] * (1 - v2) + points[i2 + 1] * v2
		end
	end

	table.insert(v3, points[1])
	table.insert(v, points[1])
	return Bezier.new(v3), Bezier.new(v)
end

function class.ElevateDegree(p, value: number?)
	local v = nil

	for _ = 1, value or 1 do
		local v2 = v or p.Points
		v = {}
		local count = #v2
		v[1] = v2[1]
		v[count + 1] = v2[count]

		for i = 2, count do
			v[i] = (i - 1) / count * v2[i - 1] + (count - i + 1) / count * v2[i]
		end
	end

	return Bezier.new(v)
end

local ModuleScript

if script:FindFirstChildWhichIsA("ModuleScript") then
	ModuleScript = require(script:FindFirstChildWhichIsA("ModuleScript"))
else
	ModuleScript = nil
end

local function len(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count - 1
end

local function findRoots(list)
	local count = 0
	local result = {}

	for _ in list do
		count += 1
	end

	for i = 0, count - 1 - 1 do
		result[i] = 0
	end

	local count2 = 0

	for _ in list do
		count2 += 1
	end

	local v2 = count2 - 1
	local cmplx = ModuleScript.cmplx(0, 1)
	local v3 = math.pow(math.abs(list[0] / list[v2]), 1 / v2)
	local v4 = 6.283185307179586 / v2
	local v5 = v4 / (v2 + 1)

	for i = 0, v2 - 1 do
		result[i] = ModuleScript.cmplx(v3, 0) * ModuleScript.exp(cmplx * ModuleScript.cmplx(v4 * i + v5, 0))
	end

	local v6 = {}

	for i = 0, v2 do
		v6[i] = 0
	end

	local cmplx2 = ModuleScript.cmplx(1e-14, 0)
	local count3 = 0
	local total = 0
	local count4 = 0

	for _ in v6 do
		count3 += 1
	end

	for i = 0, count3 - 1 - 1 do
		total += ModuleScript.pow(ModuleScript.abs(v6[i] - result[i]), 2)
	end

	local sqrt = ModuleScript.sqrt(total)

	while cmplx2 < sqrt and count4 < 10000 do
		count4 += 1

		for k, v8 in result do
			v6[k] = ModuleScript.cmplx(v8.Re, v8.Im)
		end

		local count5 = 0

		for _ in result do
			count5 += 1
		end

		for i = 0, count5 - 1 do
			local count6 = 0

			for _ in list do
				count6 += 1
			end

			local v9 = count6 - 1 + 1
			local cmplx3 = ModuleScript.cmplx(0, 0)
			local cmplx4 = ModuleScript.cmplx(list[v9 - 1], 0)

			for i2 = v9 - 2, 0, -1 do
				cmplx3 = cmplx3 * v6[i] + cmplx4
				cmplx4 = ModuleScript.cmplx(list[i2], 0) + v6[i] * cmplx4
			end

			local v10 = cmplx4 / cmplx3
			local cmplx5 = ModuleScript.cmplx(0, 0)
			local count7 = 0

			for _ in v6 do
				count7 += 1
			end

			for i2 = 0, count7 - 1 - 1 do
				if i2 ~= i then
					cmplx5 += 1 / (v6[i] - v6[i2])
				end
			end

			result[i] -= v10 / (1 - v10 * cmplx5)
		end

		local count6 = 0
		local total2 = 0

		for _ in v6 do
			count6 += 1
		end

		for i = 0, count6 - 1 - 1 do
			total2 += ModuleScript.pow(ModuleScript.abs(v6[i] - result[i]), 2)
		end

		sqrt = ModuleScript.sqrt(total2)
	end

	for k, v8 in result do
		result[k] = v8.Re
	end

	return result
end

function class:GetExtrema()
	if not ModuleScript then
		error("GetExtrema requires the installation of another module, please check the Bézier module or docs for more information.")
	end

	local _, v = self:CreateDerivativeCurve():Polynomial()
	local result = {}

	for _, v2 in { "X", "Y", "Z" } do
		local v3 = 0
		local v4 = 1
		local v5 = self:DeCasteljau(v3)[v2]
		local v6 = self:DeCasteljau(v4)[v2]
		local v7 = {}

		for k, v8 in v do
			v7[k] = v8[v2]
		end

		local roots = findRoots(v7)

		for _, root in roots do
			if not (root > 0.01 and root < 0.99) then
				continue
			end

			local v8 = self:DeCasteljau(root)[v2]

			if v6 < v5 then
				if v8 < v6 then
					v4 = root
					v6 = v8
				end

				if v5 < v8 then
					v3 = root
					v5 = v8
				end
			else
				if v8 < v5 then
					v3 = root
					v5 = v8
				end

				if v6 < v8 then
					v4 = root
					v6 = v8
				end
			end
		end

		result[v2] = { v3, v4 }
	end

	return result
end

function class:GetBoundingBox(flag: boolean?, flag2: boolean?)
	if flag then
		if not flag2 then
			local extrema = self:GetExtrema()
			return
				Vector3.new(
					self:DeCasteljau(extrema.X[1]).X,
					self:DeCasteljau(extrema.Y[1]).Y,
					self:DeCasteljau(extrema.Z[1]).Z
				),
				(Vector3.new(
					self:DeCasteljau(extrema.X[2]).X,
					self:DeCasteljau(extrema.Y[2]).Y,
					self:DeCasteljau(extrema.Z[2]).Z
				))
		end

		local point = self.Points[1]
		local v = {}

		for _, point2 in self.Points do
			table.insert(v, point2 - point)
		end

		local count = #v
		local v2 = math.atan2(v[count].Z, v[count].X)

		for k, v3 in v do
			v[k] = Vector3.new(
				v3.X * math.cos(-v2) - v3.Z * math.sin(-v2),
				v3.Y,
				v3.X * math.sin(-v2) + v3.Z * math.cos(-v2)
			)
		end

		local v3 = Bezier.new(v)
		local extrema = v3:GetExtrema()
		local X = v3:DeCasteljau(extrema.X[1]).X
		local X2 = v3:DeCasteljau(extrema.X[2]).X
		local Y = v3:DeCasteljau(extrema.Y[1]).Y
		local Y2 = v3:DeCasteljau(extrema.Y[2]).Y
		local Z = v3:DeCasteljau(extrema.Z[1]).Z
		local Z2 = v3:DeCasteljau(extrema.Z[2]).Z
		local vector2 = Vector3.new(math.abs(X2 - X), math.abs(Y2 - Y), (math.abs(Z2 - Z)))
		local vector3 = Vector3.new((X + X2) / 2, (Y + Y2) / 2, (Z + Z2) / 2)
		local midpoint = (Vector3.new(0, 0, -vector2.Z) + vector3 * 2) / 2
		local vector4 = Vector3.new(
			point.X + vector3.X * math.cos(v2) - vector3.Z * math.sin(v2),
			point.Y + vector3.Y,
			point.Z + vector3.X * math.sin(v2) + vector3.Z * math.cos(v2)
		)
		local vector5 = Vector3.new(
			point.X + midpoint.X * math.cos(v2) - midpoint.Z * math.sin(v2),
			point.Y + midpoint.Y,
			point.Z + midpoint.X * math.sin(v2) + midpoint.Z * math.cos(v2)
		)
		return CFrame.lookAt(vector4, vector5), vector2, Vector3.new(X, Y, Z), (Vector3.new(X2, Y2, Z2))
	else
		local X = 1e999
		local X2 = -1e999
		local Z = X2
		local Z2 = X
		local Y = Z
		local Y2 = Z2
		Z = Y
		Z2 = Y2
		Y = Z

		for _, point in self.Points do
			if point.X < X then
				X = point.X
			end

			if X2 < point.X then
				X2 = point.X
			end

			if point.Y < Y2 then
				Y2 = point.Y
			end

			if Y < point.Y then
				Y = point.Y
			end

			if point.Z < Z2 then
				Z2 = point.Z
			end

			if Z < point.Z then
				Z = point.Z
			end
		end

		return Vector3.new(X, Y2, Z2), (Vector3.new(X2, Y, Z))
	end
end

function class:GetNormal(p: number)
	if not self.RMFLUT then
		self:UpdateLUT(nil, true)
	end

	local RMFLUT = self.RMFLUT
	local count = 0

	for _ in RMFLUT do
		count += 1
	end

	local v = count - 1
	local v2 = p * v
	local v3 = math.floor(v2)

	if v2 == v3 then
		return {
			o = RMFLUT[v3][1],
			dt = RMFLUT[v3][2],
			r = RMFLUT[v3][3],
			n = RMFLUT[v3][4]
		}
	end

	local v4 = v3 + 1
	local v5 = v3 / v
	local v6 = (p - v5) / (v4 / v - v5)
	local result = {}

	for k, v7 in {
		"o",
		"dt",
		"r",
		"n"
	} do
		result[v7] = RMFLUT[v3][k]:Lerp(RMFLUT[v4][k], v6)
	end

	return result
end

local deepCopy

deepCopy = function(items)
	local result = {}

	for k, item in items do
		if type(item) == "table" then
			item = deepCopy(item)
		end

		result[k] = item
	end

	return result
end

function class.Clone(p)
	return (setmetatable(deepCopy(p), class))
end

function class.Destroy(list)
	table.clear(list)
	setmetatable(list, nil)
end

return Bezier