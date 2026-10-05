local RunService = game:GetService("RunService")
assert(not RunService:IsClient())
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")
local EncodingService = game:GetService("EncodingService")
require(script.Types)
local Easing = require(script.Easing)
local rect = Rect.new(64, 64, 192, 192)
local uDim = UDim2.fromScale(0, 0)
local uDim2 = UDim2.fromScale(1, 1)
local success, PNG = pcall(require, script.PNG)

if not success then
	PNG = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HexToColor3(sc: string)
	local v = tonumber(string.sub(sc, 2, 3), 16) or 0
	local v2 = tonumber(string.sub(sc, 4, 5), 16) or 0
	local v3 = tonumber(string.sub(sc, 6, 7), 16) or 0
	return Color3.fromRGB(v, v2, v3)
end

local function IsPropertyAnimated(p)
	return p ~= nil and p.a == 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasAnimatedOpacity(ks)
	if ks == nil then
		return false
	end

	local o = ks.o
	return o ~= nil and o.a == 1
end

local function SubdivideCubicBezier(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number, p9: number, list)
	for i = 1, p9 do
		local v = i / p9
		local v2 = 1 - v
		local v3 = v2 * v2
		local v4 = v3 * v2
		local v5 = v * v
		local v6 = v5 * v
		table.insert(
			list,
			{
				v4 * p + v3 * 3 * v * p3 + v2 * 3 * v5 * p5 + v6 * p7,
				v4 * p2 + v3 * 3 * v * p4 + v2 * 3 * v5 * p6 + v6 * p8
			}
		)
	end
end

local function BezierShapeToPolyline(data)
	local v = data.v
	local i = data.i
	local o = data.o
	local count = #v

	if count == 0 then
		return {}
	end

	local result = {
		{ v[1][1], v[1][2] }
	}
	local v2

	if data.c then
		v2 = count
	else
		v2 = count - 1
	end

	for i2 = 1, v2 do
		local v3 = not (i2 < count) and 1 or i2 + 1
		local v4 = v[i2]
		local v5 = v[v3]
		local v6 = o[i2]
		local v7 = i[v3]
		local v8 = v4[1]
		local v9 = v4[2]
		local v10 = v8 + v6[1]
		local v11 = v9 + v6[2]
		local v12 = v5[1] + v7[1]
		local v13 = v5[2] + v7[2]
		local v14 = v5[1]
		local v15 = v5[2]
		local v16

		if math.abs(v6[1]) < 0.01 and math.abs(v6[2]) < 0.01 and math.abs(v7[1]) < 0.01 then
			v16 = math.abs(v7[2]) < 0.01
		else
			v16 = false
		end

		if v16 then
			table.insert(result, { v14, v15 })
		else
			SubdivideCubicBezier(v8, v9, v10, v11, v12, v13, v14, v15, 12, result)
		end
	end

	return result
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function Cross2D(p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	return (p3 - p) * (p6 - p2) - (p4 - p2) * (p5 - p)
end

local function PointInTriangle(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local cross2D = Cross2D(p, p2, p3, p4, p5, p6)
	local cross2D2 = Cross2D(p, p2, p5, p6, p7, p8)
	local cross2D3 = Cross2D(p, p2, p7, p8, p3, p4)
	local v4 = cross2D < 0 or cross2D2 < 0 or cross2D3 < 0
	local v5 = cross2D > 0 or cross2D2 > 0 or cross2D3 > 0
	return not (v4 and v5)
end

local function IsConvexPolygon(list)
	local count = #list

	if count < 3 then
		return false
	end

	local v = 0

	for i = 1, count do
		local v2 = not (i < count) and 1 or i + 1
		local v3 = not (v2 < count) and 1 or v2 + 1
		local cross2D = Cross2D(list[i][1], list[i][2], list[v2][1], list[v2][2], list[v3][1], list[v3][2])

		if cross2D == 0 then
			continue
		end

		if v == 0 then
			if cross2D > 0 then
				v = 1
			else
				v = -1
			end
		elseif cross2D > 0 and v < 0 or cross2D < 0 and v > 0 then
			return false
		end
	end

	return true
end

local function TriangulateFan(list)
	local result = {}

	for i = 2, #list - 1 do
		table.insert(result, { list[1], list[i], list[i + 1] })
	end

	return result
end

local function TriangulateEarClip(list)
	local count = #list

	if count < 3 then
		return {}
	end

	if count == 3 then
		return {
			{ list[1], list[2], list[3] }
		}
	end

	if IsConvexPolygon(list) then
		return (TriangulateFan(list))
	end

	local v = table.create(count)
	local total = 0

	for i = 1, count do
		v[i] = i
		local v2 = not (i < count) and 1 or i + 1
		total += (list[v2][1] - list[i][1]) * (list[v2][2] + list[i][2])
	end

	if total > 0 then
		local v2 = table.create(count)

		for i = 1, count do
			v2[i] = v[count - i + 1]
		end

		v = v2
	end

	local count2 = #v
	local v2 = count2 * count2
	local count3 = 0
	local v3 = 1
	local result = {}

	while count2 > 2 and count3 < v2 do
		count3 += 1
		v3 = count2 < v3 and 1 or v3
		local v4

		if v3 > 1 then
			v4 = v3 - 1
		else
			v4 = count2
		end

		local v5 = not (v3 < count2) and 1 or v3 + 1
		local v6 = list[v[v4]]
		local v7 = list[v[v3]]
		local v8 = list[v[v5]]

		if Cross2D(v6[1], v6[2], v7[1], v7[2], v8[1], v8[2]) > 0 then
			local flag = true

			for i = 1, count2 do
				if not (i ~= v4 and i ~= v3 and i ~= v5) then
					continue
				end

				if not PointInTriangle(list[v[i]][1], list[v[i]][2], v6[1], v6[2], v7[1], v7[2], v8[1], v8[2]) then
					continue
				end

				flag = false
				break
			end

			if flag then
				table.insert(result, { v6, v7, v8 })
				table.remove(v, v3)
				count2 -= 1

				if count2 < v3 then
					v3 = 1
				end
			else
				v3 += 1
			end
		else
			v3 += 1
		end
	end

	return result
end

local function CreateWedge(parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://83051256678409"
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = parent
	return imageLabel
end

local function UpdateTriangle(p, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, imageColor: Color3, imageTransparency: number)
	local v = p4 - p2
	local v2 = p5 - p3
	local v3 = p6 - p2
	local v4 = p7 - p3

	if v * v4 - v2 * v3 < 0 then
		v = p6 - p2
		v2 = p7 - p3
		v3 = p4 - p2
		v4 = p5 - p3
	end

	local v5 = math.sqrt(v * v + v2 * v2)
	local v6 = math.sqrt(v3 * v3 + v4 * v4)

	if v5 < 1e-6 or v6 < 1e-6 then
		p.A.Visible = false
		p.B.Visible = false
	else
		local v7 = v / v5
		local v8 = v2 / v5
		local v9 = v3 * v7 + v4 * v8
		local v10 = v3 - v7 * v9
		local v11 = v4 - v8 * v9
		local v12 = math.sqrt(v10 * v10 + v11 * v11)

		if v12 < 1e-6 then
			p.A.Visible = false
			p.B.Visible = false
		else
			local rotation = math.atan2(v8, v7) * 57.29577951308232
			local A = p.A
			A.Visible = true
			A.Position = UDim2.fromScale(p2, p3)
			A.Size = UDim2.fromScale(math.max(v9, 0.0001), v12)
			A.Rotation = rotation
			A.AnchorPoint = Vector2.zero
			A.ImageColor3 = imageColor
			A.ImageTransparency = imageTransparency
			local B = p.B
			local v14 = v5 - v9
			B.Visible = v14 > 1e-6

			if B.Visible then
				local v15 = p2 + v7 * v5
				local v16 = p3 + v8 * v5
				B.Position = UDim2.fromScale(v15, v16)
				B.Size = UDim2.fromScale(math.max(v14, 0.0001), v12)
				B.Rotation = rotation + 180
				B.AnchorPoint = Vector2.zero
				B.ImageColor3 = imageColor
				B.ImageTransparency = imageTransparency
			end
		end
	end
end

local function CreateTrianglePair(parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://83051256678409"
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = parent
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Image = "rbxassetid://83051256678409"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.BorderSizePixel = 0
	imageLabel2.Size = UDim2.fromScale(1, 1)
	imageLabel2.Parent = parent
	return {
		A = imageLabel,
		B = imageLabel2
	}
end

local function BuildFilledPath(p, bezierShape, parent, p2: number, p3: number, color: Color3, imageTransparency: number)
	local bezierShapeToPolyline = BezierShapeToPolyline(bezierShape)

	if #bezierShapeToPolyline < 3 then
		return
	end

	local v2 = table.create(#bezierShapeToPolyline)

	for k, v3 in bezierShapeToPolyline do
		v2[k] = { v3[1] / p2, v3[2] / p3 }
	end

	local triangulateEarClip = TriangulateEarClip(v2)
	local triangles = p.Triangles or {}

	for k, v4 in triangulateEarClip do
		local v5

		if k <= #triangles then
			v5 = triangles[k]
		else
			v5 = {
				A = 0,
				B = 0
			}
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Image = "rbxassetid://83051256678409"
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.Parent = parent
			v5.A = imageLabel
			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Image = "rbxassetid://83051256678409"
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.BorderSizePixel = 0
			imageLabel2.Size = UDim2.fromScale(1, 1)
			imageLabel2.Parent = parent
			v5.B = imageLabel2
			table.insert(triangles, v5)
		end

		UpdateTriangle(v5, v4[1][1], v4[1][2], v4[2][1], v4[2][2], v4[3][1], v4[3][2], color, imageTransparency)
	end

	for i = #triangulateEarClip + 1, #triangles do
		triangles[i].A.Visible = false
		triangles[i].B.Visible = false
	end

	p.Triangles = triangles
end

local function BuildStrokedPath(p, bezierShape, parent, p2: number, p3: number, backgroundColor: Color3, backgroundTransparency: number, scalarAtFrame: number, items, value: number?, value2: number?, value3: number?)
	local bezierShapeToPolyline = BezierShapeToPolyline(bezierShape)

	if #bezierShapeToPolyline < 2 then
		return
	end

	local segments = p.Segments or {}
	local total = 0
	local v2 = { 0 }
	local v3 = value3 or 0
	local v4 = value or 0
	local v5 = value2 or 100

	for i = 2, #bezierShapeToPolyline do
		local v6 = bezierShapeToPolyline[i][1] - bezierShapeToPolyline[i - 1][1]
		local v7 = bezierShapeToPolyline[i][2] - bezierShapeToPolyline[i - 1][2]
		total += math.sqrt(v6 * v6 + v7 * v7)
		v2[i] = total
	end

	local v6 = nil

	if items then
		local v7 = {}

		for _, item in items do
			if item.v then
				table.insert(v7, Easing.EvaluateScalar(item.v, 0))
			end
		end

		if #v7 > 0 then
			v6 = v7
		end
	end

	local v7 = scalarAtFrame / math.min(p2, p3)
	local count = 0

	for i = 2, #bezierShapeToPolyline do
		local v8 = bezierShapeToPolyline[i - 1]
		local v9 = bezierShapeToPolyline[i]
		local v10 = v9[1] - v8[1]
		local v11 = v9[2] - v8[2]
		local v12 = math.sqrt(v10 * v10 + v11 * v11)

		if v12 < 0.01 then
			continue
		end

		local v13 = ((v2[i - 1] + v2[i]) * 0.5 / math.max(total, 1e-6) * 100 + v3) % 100

		if v13 < v4 or v5 < v13 then
			continue
		end

		local visible = true

		if v6 then
			local v15 = v2[i - 1]
			local total2 = 0

			for _, v16 in v6 do
				total2 += v16
			end

			if total2 > 0 then
				local v16 = v15 % total2
				local total3 = 0

				for k, v18 in v6 do
					total3 += v18

					if not (v16 < total3) then
						continue
					end

					visible = k % 2 == 1
					break
				end
			end
		end

		count += 1
		local v15

		if count <= #segments then
			v15 = segments[count]
		else
			v15 = Instance.new("Frame")
			v15.BorderSizePixel = 0
			v15.AnchorPoint = Vector2.new(0, 0.5)
			v15.Parent = parent
			table.insert(segments, v15)
		end

		v15.Visible = visible

		if not visible then
			continue
		end

		local rotation = math.atan2(v11, v10) * 57.29577951308232
		local v17 = v12 / p2
		v15.Position = UDim2.fromScale(v8[1] / p2, v8[2] / p3)
		v15.Size = UDim2.fromScale(v17, v7)
		v15.Rotation = rotation
		v15.BackgroundColor3 = backgroundColor
		v15.BackgroundTransparency = backgroundTransparency
	end

	for i = count + 1, #segments do
		segments[i].Visible = false
	end

	p.Segments = segments
end

local function BuildLinearGradient(parent, g, s, e, p: number)
	local uIGradient = Instance.new("UIGradient")
	local p2 = g.p
	local k = g.k
	local vector = Easing.EvaluateVector(k, p, {})
	local colorSequenceKeypoints = {}

	for i = 0, p2 - 1 do
		local v = i * 4
		local v2 = vector[v + 1] or i / math.max(p2 - 1, 1)
		local v3 = vector[v + 2] or 1
		local v4 = vector[v + 3] or 1
		local v5 = vector[v + 4] or 1
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(math.clamp(v2, 0, 1), Color3.new(v3, v4, v5)))
	end

	local v = #colorSequenceKeypoints < 2 and {
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	} or colorSequenceKeypoints
	uIGradient.Color = ColorSequence.new(v)
	local vector2 = Easing.EvaluateVector(s, p, { 0, 0 })
	local vector3 = Easing.EvaluateVector(e, p, { 1, 0 })
	local v2 = vector3[1] - vector2[1]
	uIGradient.Rotation = math.atan2(vector3[2] - vector2[2], v2) * 57.29577951308232
	uIGradient.Parent = parent
	return uIGradient
end

local function BuildRadialGradientApprox(parent, g, s, e, p: number, p2: number, p3: number)
	local p4 = g.p
	local vector = Easing.EvaluateVector(g.k, p, {})
	local vector2 = Easing.EvaluateVector(s, p, { p2 / 2, p3 / 2 })
	local vector3 = Easing.EvaluateVector(e, p, { p2, p3 / 2 })
	local v = vector2[1]
	local v2 = vector2[2]
	local v3 = vector3[1] - v
	local v4 = vector3[2] - v2
	local v5 = math.sqrt(v3 * v3 + v4 * v4)
	local v6 = math.min(p4, 6)
	local result = {}

	for i = v6, 1, -1 do
		local v7 = i / v6
		local v8 = math.min(math.floor(v7 * (p4 - 1)), p4 - 1) * 4
		local v9 = vector[v8 + 2] or 1
		local v10 = vector[v8 + 3] or 1
		local v11 = vector[v8 + 4] or 1
		local v12 = v5 * 2 * v7
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(v / p2, v2 / p3)
		frame.Size = UDim2.fromScale(v12 / p2, v12 / p3)
		frame.BackgroundColor3 = Color3.new(v9, v10, v11)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.5, 0)
		uICorner.Parent = frame
		frame.Parent = parent
		table.insert(result, frame)
	end

	return result
end

local function ApplyTransform(p, data, p2: number, p3: number, p4: number, flag: boolean, p5: number, p6: number)
	if data == nil then
		return
	end

	local p7 = data.p
	local v

	if p7 == nil or type(p7) ~= "table" then
		v = { 0, 0 }
	elseif p7.s == true then
		v = { Easing.EvaluateScalarAtFrame(p7.x, p2, 0), (Easing.EvaluateScalarAtFrame(p7.y, p2, 0)) }
	else
		v = Easing.EvaluateVector(p7, p2, { 0, 0 })
	end

	local vector = Easing.EvaluateVector(data.s, p2, { 100, 100 })
	local scalarAtFrame = Easing.EvaluateScalarAtFrame(data.r, p2, 0)
	local scalarAtFrame2 = Easing.EvaluateScalarAtFrame(data.o, p2, 100)
	local vector2 = Easing.EvaluateVector(data.a, p2, { 0, 0 })
	local v2 = vector[1] / 100
	local v3 = vector[2] / 100
	p.Position = UDim2.fromScale(v[1] / p3, v[2] / p4)
	p.Rotation = scalarAtFrame
	p.Size = UDim2.fromScale(p5 * v2, p6 * v3)

	if flag then
		p.GroupTransparency = 1 - scalarAtFrame2 / 100
	end

	local v4 = p5 * v2 * p3
	local v5 = p6 * v3 * p4

	if (vector2[1] ~= 0 or vector2[2] ~= 0) and v4 > 0 and v5 > 0 then
		p.AnchorPoint = Vector2.new(math.clamp(vector2[1] / v4, 0, 1), (math.clamp(vector2[2] / v5, 0, 1)))
	end
end

local function CollectShapeInfo(it)
	local c = nil
	local o = nil
	local c2 = nil
	local o2 = nil
	local w = nil
	local ks = nil
	local da = nil
	local s = nil
	local e = nil
	local o3 = nil
	local m = nil
	local v = nil
	local mm = nil

	for _, item in it do
		if item.hd then
			continue
		end

		local ty = item.ty

		if ty == "fl" then
			c = item.c
			o = item.o
		elseif ty == "st" then
			c2 = item.c
			o2 = item.o
			w = item.w
			da = item.da
		elseif ty == "sh" then
			ks = item.ks
		elseif ty == "tr" then
			v = item
		elseif ty == "tm" then
			s = item.s
			e = item.e
			o3 = item.o
			m = item.m
		elseif ty == "mm" then
			mm = item.mm
		end
	end

	return c, o, c2, o2, w, ks, da, s, e, o3, m, v, mm
end

local BuildShapeGroup

BuildShapeGroup = function(shape, parent, p2: number, p3: number, p4: number)
	local it = shape.it or {}
	local fillColor, fillOpacity, strokeColor, strokeOpacity, strokeWidth, pathData, v7, v8, v9, v10, _, v11, _ = CollectShapeInfo(it)
	local flag = false

	for _, v13 in it do
		if v13.ty ~= "tr" then
			continue
		end

		local o = v13.o
		local v14

		if o == nil then
			v14 = false
		else
			v14 = o.a == 1
		end

		if not v14 then
			continue
		end

		flag = true
		break
	end

	local v13

	if flag then
		v13 = Instance.new("CanvasGroup")
	else
		v13 = Instance.new("Frame")
	end

	v13.BackgroundTransparency = 1
	v13.BorderSizePixel = 0
	v13.Size = uDim2
	v13.Position = uDim
	v13.Parent = parent

	if v11 then
		ApplyTransform(v13, {
			a = v11.a,
			p = v11.p,
			s = v11.s,
			r = v11.r,
			o = v11.o
		}, p4, p2, p3, flag, 1, 1)
	end

	local result = {
		Shape = shape,
		Frame = v13,
		Children = {},
		FillColor = fillColor,
		FillOpacity = fillOpacity,
		StrokeColor = strokeColor,
		StrokeOpacity = strokeOpacity,
		StrokeWidth = strokeWidth,
		PathData = pathData,
		IsAnimatedPath = pathData ~= nil and pathData.a == 1
	}
	local color = Easing.EvaluateColor(fillColor, p4)
	local backgroundTransparency = 1 - Easing.EvaluateScalarAtFrame(fillOpacity, p4, 100) / 100
	local color2 = Easing.EvaluateColor(strokeColor, p4)
	local transparency = 1 - Easing.EvaluateScalarAtFrame(strokeOpacity, p4, 100) / 100
	local scalarAtFrame = Easing.EvaluateScalarAtFrame(strokeWidth, p4, 0)
	local scalarAtFrame2 = Easing.EvaluateScalarAtFrame(v8, p4, 0)
	local scalarAtFrame3 = Easing.EvaluateScalarAtFrame(v9, p4, 100)
	local scalarAtFrame4 = Easing.EvaluateScalarAtFrame(v10, p4, 0)
	local v17 = 0

	for _, v18 in it do
		if v18.ty == "op" and v18.a then
			v17 = Easing.EvaluateScalarAtFrame(v18.a, p4, 0)
		end
	end

	for _, v18 in it do
		if v18.hd then
			continue
		end

		local ty = v18.ty

		if ty == "sh" then
			local bezierShape = Easing.EvaluateBezierShape(v18.ks, p4)

			if bezierShape and v17 ~= 0 then
				local total = 0
				local total2 = 0

				for _, v19 in bezierShape.v do
					total += v19[1]
					total2 += v19[2]
				end

				local v19 = total / #bezierShape.v
				local v20 = total2 / #bezierShape.v
				local v21 = v17 / math.max(
					math.sqrt((bezierShape.v[1][1] - v19) ^ 2 + (bezierShape.v[1][2] - v20) ^ 2),
					1
				) + 1
				local v22 = table.create(#bezierShape.v)

				for k, v23 in bezierShape.v do
					v22[k] = { v19 + (v23[1] - v19) * v21, v20 + (v23[2] - v20) * v21 }
				end

				bezierShape = {
					v = v22,
					i = bezierShape.i,
					o = bezierShape.o,
					c = bezierShape.c
				}
			end

			if bezierShape then
				if fillColor then
					BuildFilledPath(result, bezierShape, v13, p2, p3, color, backgroundTransparency)
				end

				if strokeColor and scalarAtFrame > 0 then
					BuildStrokedPath(
						result,
						bezierShape,
						v13,
						p2,
						p3,
						color2,
						transparency,
						scalarAtFrame,
						v7,
						scalarAtFrame2,
						scalarAtFrame3,
						scalarAtFrame4
					)
				end
			end
		elseif ty == "rc" then
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			local vector = Easing.EvaluateVector(v18.s, p4, { 100, 100 })
			local vector2 = Easing.EvaluateVector(v18.p, p4, { 0, 0 })
			local scalarAtFrame5 = Easing.EvaluateScalarAtFrame(v18.r, p4, 0)
			frame.Size = UDim2.fromScale(vector[1] / p2, vector[2] / p3)
			frame.Position = UDim2.fromScale(vector2[1] / p2, vector2[2] / p3)
			frame.AnchorPoint = Vector2.new(0.5, 0.5)

			if fillColor then
				frame.BackgroundColor3 = color
				frame.BackgroundTransparency = backgroundTransparency
			else
				frame.BackgroundTransparency = 1
			end

			if scalarAtFrame5 > 0 then
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(0, scalarAtFrame5)
				uICorner.Parent = frame
				result.UICorner = uICorner
			end

			if strokeColor and scalarAtFrame > 0 then
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = color2
				uIStroke.Transparency = transparency
				uIStroke.Thickness = scalarAtFrame / math.min(p2, p3)
				uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				if not pcall(function()
					uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end) then
					uIStroke.Thickness = scalarAtFrame
				end

				uIStroke.Parent = frame
				result.UIStroke = uIStroke
			end

			frame.Parent = v13
			result.Frame = frame
		elseif ty == "el" then
			local frame = Instance.new("Frame")
			frame.BorderSizePixel = 0
			local vector = Easing.EvaluateVector(v18.s, p4, { 100, 100 })
			local vector2 = Easing.EvaluateVector(v18.p, p4, { 0, 0 })
			frame.Size = UDim2.fromScale(vector[1] / p2, vector[2] / p3)
			frame.Position = UDim2.fromScale(vector2[1] / p2, vector2[2] / p3)
			frame.AnchorPoint = Vector2.new(0.5, 0.5)

			if fillColor then
				frame.BackgroundColor3 = color
				frame.BackgroundTransparency = backgroundTransparency
			else
				frame.BackgroundTransparency = 1
			end

			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.5, 0)
			uICorner.Parent = frame
			result.UICorner = uICorner

			if strokeColor and scalarAtFrame > 0 then
				local uIStroke = Instance.new("UIStroke")
				uIStroke.Color = color2
				uIStroke.Transparency = transparency
				uIStroke.Thickness = scalarAtFrame / math.min(p2, p3)
				uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				pcall(function()
					uIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				end)
				uIStroke.Parent = frame
				result.UIStroke = uIStroke
			end

			frame.Parent = v13
			result.Frame = frame
		elseif ty == "gf" or ty == "gs" then
			local t = v18.t or 1

			if v18.g then
				if t == 1 then
					result.UIGradient = BuildLinearGradient(v13, v18.g, v18.s, v18.e, p4)
				elseif t == 2 then
					BuildRadialGradientApprox(v13, v18.g, v18.s, v18.e, p4, p2, p3)
				end
			end
		elseif ty == "gr" then
			local shapeGroup = BuildShapeGroup(v18, v13, p2, p3, p4)

			if result.Children then
				table.insert(result.Children, shapeGroup)
			end
		elseif ty == "rp" then
			local scalarAtFrame5 = Easing.EvaluateScalarAtFrame(v18.c, p4, 1)
			local tr = v18.tr

			if tr and scalarAtFrame5 > 1 then
				local scalarAtFrame6 = Easing.EvaluateScalarAtFrame(tr.so, p4, 100)
				local scalarAtFrame7 = Easing.EvaluateScalarAtFrame(tr.eo, p4, 100)

				for i = 0, math.floor(scalarAtFrame5) - 1 do
					local frame = Instance.new("Frame")
					frame.BackgroundTransparency = 1
					frame.BorderSizePixel = 0
					frame.Size = uDim2
					frame.BackgroundTransparency = 1 - math.lerp(
						scalarAtFrame6,
						scalarAtFrame7,
						i / math.max(scalarAtFrame5 - 1, 1)
					) / 100
					local _ = {
						p = tr.p,
						s = tr.s,
						r = tr.r,
						a = tr.a,
						o = tr.o
					}
					local vector = Easing.EvaluateVector(tr.p, p4, { 0, 0 })
					Easing.EvaluateVector(tr.s, p4, { 100, 100 })
					local scalarAtFrame8 = Easing.EvaluateScalarAtFrame(tr.r, p4, 0)
					frame.Position = UDim2.fromScale(vector[1] * i / p2, vector[2] * i / p3)
					frame.Rotation = scalarAtFrame8 * i
					frame.Parent = v13

					for _, v19 in it do
						if v19.ty == "gr" and v19 ~= shape then
							BuildShapeGroup(v19, frame, p2, p3, p4)
						end
					end
				end
			end
		end
	end

	return result
end

local function BuildShapeLayer(p, p2, p3: number, p4: number, p5: number)
	local shapes = p.shapes

	if shapes == nil then
		return {}
	end

	local result = {}

	for i = #shapes, 1, -1 do
		local shape = shapes[i]

		if shape.hd or shape.ty ~= "gr" then
			continue
		end

		table.insert(result, (BuildShapeGroup(shape, p2, p3, p4, p5)))
	end

	return result
end

local function BuildTextLayer(p, parent, _: number, p2: number, p3: number)
	local t = p.t

	if t == nil then
		return nil
	end

	local d = t.d

	if d == nil then
		return nil
	end

	local k = d.k

	if k == nil or #k == 0 then
		return nil
	end

	local s = nil

	for _, v in k do
		if v.t == nil or v.t <= p3 then
			s = v.s
		end
	end

	if s == nil then
		s = k[1].s
	end

	if s == nil then
		return nil
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Size = uDim2
	textLabel.Text = s.t or ""
	textLabel.TextScaled = false
	textLabel.RichText = false
	textLabel.TextSize = (s.s or 24) / p2 * 100

	if s.fc then
		local fc = s.fc
		textLabel.TextColor3 = Color3.new(fc[1] or 1, fc[2] or 1, fc[3] or 1)
	end

	local j = s.j or 0

	if j == 0 then
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
	elseif j == 1 then
		textLabel.TextXAlignment = Enum.TextXAlignment.Right
	else
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
	end

	textLabel.TextYAlignment = Enum.TextYAlignment.Top

	if s.f then
		local success2, result = pcall(function()
			return Enum.Font[s.f]
		end)

		if success2 and result then
			textLabel.Font = result
		else
			textLabel.Font = Enum.Font.GothamMedium
		end
	end

	textLabel.Parent = parent
	return textLabel
end

local function BuildImageLayer(p, parent, p2, _: number, _: number)
	local refId = p.refId

	if refId == nil then
		return nil
	end

	local v = p2[refId]

	if v == nil then
		return nil
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Size = uDim2
	imageLabel.ScaleType = Enum.ScaleType.Stretch

	if v.e == 1 and v.p then
		local p3 = v.p

		if string.sub(p3, 1, 22) == "data:image/png;base64," then
			local v2 = string.sub(p3, 23)

			if PNG then
				local success2, result = pcall(function()
					local base64Decode = EncodingService:Base64Decode(buffer.fromstring(v2))
					return PNG.decode(base64Decode)
				end)

				if success2 and result then
					local success3, result2 = pcall(function()
						return AssetService:CreateEditableImage({
							Size = Vector2.new(result.width, result.height)
						})
					end)

					if success3 and result2 and pcall(function()
						result2:WritePixelsBuffer(Vector2.zero, Vector2.new(result.width, result.height), result.pixels)
					end) then
						imageLabel.ImageContent = Content.fromObject(result2)
					end
				end
			end
		elseif string.sub(p3, 1, 23) == "data:image/jpeg;base64," then
			warn("[Lottie] Embedded JPEG not supported, skipping image layer:", p.nm or "")
		end
	elseif v.p and not v.e then
		imageLabel.Image = v.p
	end

	imageLabel.Parent = parent
	return imageLabel
end

local function BuildDropShadow(p, parent, p2: number, p3: number, p4: number)
	local ef = p.ef

	if ef == nil then
		return
	end

	for _, v in ef do
		if v.ty ~= 25 then
			continue
		end

		local ef2 = v.ef

		if ef2 == nil then
			continue
		end

		local color = Color3.new(0, 0, 0)
		local v2 = 0
		local v3 = 5
		local v4 = 5
		local v5 = 0.5

		for _, v6 in ef2 do
			local ty = v6.ty

			if ty == nil then
				continue
			end

			if ty == 1 then
				color = Easing.EvaluateColor(v6.v, p4)
			elseif ty == 0 then
				v5 = Easing.EvaluateScalarAtFrame(v6.v, p4, 128) / 255
			elseif ty == 3 then
				v2 = Easing.EvaluateScalarAtFrame(v6.v, p4, 0)
			elseif ty == 2 then
				v3 = Easing.EvaluateScalarAtFrame(v6.v, p4, 5)
			elseif ty == 4 then
				v4 = Easing.EvaluateScalarAtFrame(v6.v, p4, 5)
			end
		end

		local v6 = math.rad(v2 + 180)
		local v7 = math.cos(v6) * v3 / p2
		local v8 = math.sin(v6) * v3 / p3
		local v9 = (v4 * 2 + math.max(p2, p3)) / math.max(p2, p3)
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = "rbxassetid://100849323991833"
		imageLabel.ScaleType = Enum.ScaleType.Slice
		imageLabel.SliceCenter = rect
		imageLabel.ImageColor3 = color
		imageLabel.ImageTransparency = 1 - v5
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.fromScale(v7 + 0.5, v8 + 0.5)
		imageLabel.Size = UDim2.fromScale(v9, v9)
		imageLabel.ZIndex = -1
		imageLabel.Parent = parent
		break
	end
end

local BuildLayers

BuildLayers = function(layers, parent, p, w: number, h: number, p2: number)
	local v = {}
	local result = {}

	for i = #layers, 1, -1 do
		local layer = layers[i]

		if layer.hd then
			continue
		end

		local ty = layer.ty
		local animatedOpacity = HasAnimatedOpacity(layer.ks) -- equivalent call inferred; original call site unknown
		local frame2

		if ty == 1 then
			frame2 = Instance.new("Frame")
			frame2.BorderSizePixel = 0
			local color

			if layer.sc then
				color = HexToColor3(layer.sc)
			else
				color = Color3.new(0, 0, 0)
			end

			frame2.BackgroundColor3 = color
			frame2.BackgroundTransparency = 0
			frame2.Size = UDim2.fromScale((layer.sw or w) / w, (layer.sh or h) / h)
		else
			if animatedOpacity then
				frame2 = Instance.new("CanvasGroup")
			else
				frame2 = Instance.new("Frame")
			end

			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.Size = uDim2
		end

		frame2.Name = layer.nm or `Layer_{layer.ind or i}`
		local scale = frame2.Size.X.Scale
		local scale2 = frame2.Size.Y.Scale
		local v5 = {
			Layer = layer,
			Frame = frame2,
			BaseSizeX = scale,
			BaseSizeY = scale2
		}

		if layer.ind then
			v[layer.ind] = v5
		end

		if ty == 4 then
			v5.Shapes = BuildShapeLayer(layer, frame2, w, h, p2)
		elseif ty == 5 then
			v5.TextLabel = BuildTextLayer(layer, frame2, w, h, p2)
		elseif ty == 2 then
			v5.ImageLabel = BuildImageLayer(layer, frame2, p, w, h)
		elseif ty == 0 then
			local refId = layer.refId

			if refId and p[refId] then
				local v6 = p[refId]

				if v6.layers then
					local w2 = layer.w or v6.w or w
					local h2 = layer.h or v6.h or h
					frame2.ClipsDescendants = true
					frame2.Size = UDim2.fromScale(w2 / w, h2 / h)
					v5.Children = BuildLayers(v6.layers, frame2, p, w2, h2, p2)
				end
			end
		end

		BuildDropShadow(layer, frame2, w, h, p2)

		if layer.masksProperties then
			for _, masksProperty in layer.masksProperties do
				if not (masksProperty.mode == "a" or masksProperty.mode == nil) then
					continue
				end

				local bezierShape = Easing.EvaluateBezierShape(masksProperty.pt, p2)

				if not bezierShape then
					continue
				end

				local v6 = 1e999
				local v7 = 1e999
				local v8 = -1e999
				local v9 = -1e999

				for _, v10 in bezierShape.v do
					v6 = math.min(v6, v10[1])
					v7 = math.min(v7, v10[2])
					v8 = math.max(v8, v10[1])
					v9 = math.max(v9, v10[2])
				end

				local frame = Instance.new("Frame")
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.ClipsDescendants = true
				frame.Position = UDim2.fromScale(v6 / w, v7 / h)
				frame.Size = UDim2.fromScale((v8 - v6) / w, (v9 - v7) / h)
				frame.Parent = parent
				frame2.Parent = frame
				v5.MatteClip = frame
			end
		end

		ApplyTransform(frame2, layer.ks, p2, w, h, animatedOpacity, scale, scale2)
		local v6 = p2 - (layer.st or 0)
		frame2.Visible = layer.ip <= v6 and v6 < layer.op
		table.insert(result, v5)
	end

	for _, v2 in result do
		local layer = v2.Layer

		if layer.parent and v[layer.parent] then
			local v3 = v[layer.parent]
			v2.Frame.Parent = v3.Frame
		elseif v2.MatteClip == nil then
			v2.Frame.Parent = parent
		end
	end

	for i = 1, #result - 1 do
		local v2 = result[i]
		local v3 = result[i + 1]

		if not v3.Layer.tt then
			continue
		end

		local v4 = nil

		for _, v6 in v2.Shapes or {} do
			if not v6.PathData then
				continue
			end

			v4 = Easing.EvaluateBezierShape(v6.PathData, p2)
			break
		end

		if not v4 then
			continue
		end

		local v6 = 1e999
		local v7 = 1e999
		local v8 = -1e999
		local v9 = -1e999

		for _, v10 in v4.v do
			v6 = math.min(v6, v10[1])
			v7 = math.min(v7, v10[2])
			v8 = math.max(v8, v10[1])
			v9 = math.max(v9, v10[2])
		end

		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.Position = UDim2.fromScale(v6 / w, v7 / h)
		frame.Size = UDim2.fromScale((v8 - v6) / w, (v9 - v7) / h)
		frame.Parent = parent
		v3.Frame.Parent = frame
		v3.MatteClip = frame
		v2.Frame.Visible = false
	end

	return result
end

local fn
local RenderLayerNodes

RenderLayerNodes = function(items, p: number, p2: number, p3: number)
	for _, item in items do
		local layer = item.Layer
		local v = p - (layer.st or 0)
		local visible

		if layer.ip <= v then
			visible = v < layer.op
		else
			visible = false
		end

		item.Frame.Visible = visible

		if not visible then
			continue
		end

		local isA = item.Frame:IsA("CanvasGroup")
		ApplyTransform(item.Frame, layer.ks, v, p2, p3, isA, item.BaseSizeX, item.BaseSizeY)

		if item.Shapes then
			for _, shape in item.Shapes do
				fn(shape, v, p2, p3)
			end
		end

		if item.Children then
			local w = layer.w or p2
			local h = layer.h or p3
			local v3

			if layer.tm then
				v3 = Easing.EvaluateScalarAtFrame(layer.tm, v, 0) * (layer.op - layer.ip)
			else
				v3 = v
			end

			RenderLayerNodes(item.Children, v3, w, h)
		end

		if not (item.TextLabel and layer.t) then
			continue
		end

		local d = layer.t.d

		if not (d and d.k) then
			continue
		end

		local s = nil

		for _, v3 in d.k do
			if v3.t == nil or v3.t <= v then
				s = v3.s
			end
		end

		if not s then
			continue
		end

		item.TextLabel.Text = s.t or ""

		if s.fc then
			item.TextLabel.TextColor3 = Color3.new(s.fc[1] or 1, s.fc[2] or 1, s.fc[3] or 1)
		end
	end
end

fn = function(data, p: number, p2: number, p3: number)
	if data.Children then
		for _, v in data.Children do
			fn(v, p, p2, p3)
		end
	end

	if data.IsAnimatedPath and data.PathData then
		local bezierShape = Easing.EvaluateBezierShape(data.PathData, p)

		if bezierShape and data.Frame then
			local color = Easing.EvaluateColor(data.FillColor, p)
			local scalarAtFrame = Easing.EvaluateScalarAtFrame(data.FillOpacity, p, 100)

			if data.FillColor then
				BuildFilledPath(data, bezierShape, data.Frame, p2, p3, color, 1 - scalarAtFrame / 100)
			end

			if data.StrokeColor then
				local color2 = Easing.EvaluateColor(data.StrokeColor, p)
				local scalarAtFrame2 = Easing.EvaluateScalarAtFrame(data.StrokeOpacity, p, 100)
				local scalarAtFrame3 = Easing.EvaluateScalarAtFrame(data.StrokeWidth, p, 0)

				if scalarAtFrame3 > 0 then
					BuildStrokedPath(
						data,
						bezierShape,
						data.Frame,
						p2,
						p3,
						color2,
						1 - scalarAtFrame2 / 100,
						scalarAtFrame3
					)
				end
			end
		end
	elseif data.FillColor then
		local fillColor = data.FillColor
		local v

		if fillColor == nil then
			v = false
		else
			v = fillColor.a == 1
		end

		if v then
			local color = Easing.EvaluateColor(data.FillColor, p)
			local v2 = 1 - Easing.EvaluateScalarAtFrame(data.FillOpacity, p, 100) / 100

			if data.Triangles then
				for _, triangle in data.Triangles do
					if triangle.A.Visible then
						triangle.A.ImageColor3 = color
						triangle.A.ImageTransparency = v2
					end

					if not triangle.B.Visible then
						continue
					end

					triangle.B.ImageColor3 = color
					triangle.B.ImageTransparency = v2
				end
			end

			if data.Frame and data.Frame.BackgroundTransparency < 1 then
				data.Frame.BackgroundColor3 = color
				data.Frame.BackgroundTransparency = v2
			end
		end
	end

	if data.StrokeColor then
		local strokeColor = data.StrokeColor
		local v

		if strokeColor == nil then
			v = false
		else
			v = strokeColor.a == 1
		end

		if v then
			local color = Easing.EvaluateColor(data.StrokeColor, p)
			local scalarAtFrame = Easing.EvaluateScalarAtFrame(data.StrokeOpacity, p, 100)

			if data.Segments then
				for _, segment in data.Segments do
					if not segment.Visible then
						continue
					end

					segment.BackgroundColor3 = color
					segment.BackgroundTransparency = 1 - scalarAtFrame / 100
				end
			end

			if data.UIStroke then
				data.UIStroke.Color = color
				data.UIStroke.Transparency = 1 - scalarAtFrame / 100
			end
		end
	end
end

return (table.freeze({
	Parse = function(json: string)
		return (HttpService:JSONDecode(json))
	end,
	Create = function(animation)
		local w = animation.w
		local h = animation.h
		local ip = animation.ip
		local op = animation.op
		local fr = animation.fr
		local frame = Instance.new("Frame")
		frame.Name = animation.nm or "LottieAnimation"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.Size = uDim2
		local assetsById = {}

		if animation.assets then
			for _, asset in animation.assets do
				assetsById[asset.id] = asset
			end
		end

		return {
			Animation = animation,
			Root = frame,
			Layers = BuildLayers(animation.layers, frame, assetsById, w, h, ip),
			AssetMap = assetsById,
			Duration = (op - ip) / fr,
			Width = w,
			Height = h
		}
	end,
	Render = function(data, p: number)
		local animation = data.Animation
		local ip = animation.ip
		local op = animation.op
		local fr = animation.fr
		local v = op - ip
		local v2 = ip + p * fr % v
		RenderLayerNodes(data.Layers, v2, data.Width, data.Height)
	end,
	Destroy = function(self)
		self.Root:Destroy()
		table.clear(self.Layers)
		table.clear(self.AssetMap)
	end
}))