local createVector = vector.create
local BeamSpline = {}

local function f_a(p: number)
	local v = 1 - p
	return p * 3 * v * v
end

local function f_b(p: number)
	local v = 1 - p
	return p * 3 * p * v
end

local function K(p: number)
	local v = 1 - p
	return v * v * (p * 2 + 1)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function L(p: number)
	return p * p * (3 - p * 2)
end

function BeamSpline._computeBezierApproxControlPoints(callback, value: number?)
	local v = value or 10

	if v % 2 ~= 0 then
		v += 1
	end

	local v2 = 1 / v
	local v3 = table.create(v + 1)
	local v4 = callback(0)

	for i = 0, v do
		local v5 = i * v2
		v3[i + 1] = callback(v5) - v4
	end

	local vector2 = v3[1]
	local vector3 = v3[#v3]
	local unit = ((callback(0.0001) - callback(-0.0001)) / 0.0002).Unit
	local unit2 = ((callback(1.0001) - callback(0.9999)) / 0.0002).Unit

	if unit ~= unit then
		unit = (v3[2] - vector2).Unit

		if unit ~= unit then
			unit = (callback(1) - callback(0)).Unit
			assert(unit == unit, "NaN near space curve(0) tangent")
		end
	end

	if unit2 ~= unit2 then
		unit2 = (vector3 - v3[#v3 - 1]).Unit

		if unit2 ~= unit2 then
			unit2 = (callback(1) - callback(0)).Unit
			assert(unit2 == unit2, "NaN near space curve(1) tangent")
		end
	end

	local total = 0
	local total2 = 0

	for i = 0, v do
		local v5 = i * v2
		local v6 = 1 - v5
		local vector4 = v6 * v6 * (v5 * 2 + 1) * vector2 + L(v5) * vector3 - v3[i + 1]
		local v7 = 1 - v5
		local v8 = v5 * 3 * v7 * v7 * unit:Dot(vector4)
		local v9 = 1 - v5
		local v10 = v5 * 3 * v5 * v9 * unit2:Dot(vector4)
		local v11 = (i == 0 or i == v) and 1 or i % 2 == 1 and 4 or 2
		total += v11 * v8
		total2 += v11 * v10
	end

	local v5 = total * (v2 / 3)
	local v6 = total2 * (v2 / 3)
	local v7 = v5 * 2
	local v8 = v6 * 2
	local v9 = 0.12857142857142856 * unit:Dot(unit2)
	local v10 = 0.02938775510204082 - v9 * v9

	if math.abs(v10) < 1e-12 then
		local v11 = 0.5 * (vector3 - vector2).Magnitude
		return vector2 + v4, (vector2 + vector3) * 0.5 + v4, (vector2 + vector3) * 0.5 + v4, vector3 + v4, v11, v11
	end

	local v11 = -(v7 * 0.17142857142857143 - v9 * v8) / v10
	local v12 = -(v8 * 0.17142857142857143 - v9 * v7) / v10
	return
		vector2 + v4,
		vector2 + v4 + v11 * unit,
		vector3 + v4 + v12 * unit2,
		vector3 + v4,
		math.abs(v11),
		(math.abs(v12))
end

function BeamSpline.cubicBezier(p: number, vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3)
	local v = 1 - p
	local v2 = v * v
	local v3 = p * p
	return v2 * v * vector2 + v2 * 3 * p * vector3 + v * 3 * v3 * vector4 + v3 * p * vector5
end

local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(1, 0, 0)):Inverse()

function BeamSpline:applyBezierControlPointsToBeam(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, curveSize: number, curveSize2: number)
	assert(self.Attachment0 ~= nil)
	assert(self.Attachment1 ~= nil)
	self.Attachment0.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), vector3 - vector2) * inverse + vector2
	self.Attachment1.WorldCFrame = CFrame.lookAt(createVector(0, 0, 0), vector5 - vector4) * inverse + vector5
	self.CurveSize0 = curveSize
	self.CurveSize1 = curveSize2
end

function BeamSpline:applyBezierControlPointsAndTorsionToBeam(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, curveSize: number, curveSize2: number, vector6: Vector3, vector7: Vector3)
	assert(self.Attachment0 ~= nil)
	assert(self.Attachment1 ~= nil)
	local unit = (vector3 - vector2).Unit
	local dot = vector6:Dot(unit)
	local v = vector6 - dot * unit
	local cframe = CFrame.fromMatrix(vector2, unit, v.Unit)
	local unit2 = (vector5 - vector4).Unit
	local dot2 = vector7:Dot(unit2)
	local v2 = vector7 - dot2 * unit2
	local cframe2 = CFrame.fromMatrix(vector5, unit2, v2.Unit)

	if math.abs(dot) > 0.999 then
		print("BeamSpline.applyBezierControlPointsAndTorsionToBeam soft warning: Torsion vector at Attachment0 parallel to curve. Change either spaceCurve or torsionCurve to avoid this.")
		cframe = CFrame.lookAt(createVector(0, 0, 0), vector3 - vector2) * inverse + vector2
	end

	if math.abs(dot2) > 0.999 then
		print("BeamSpline.applyBezierControlPointsAndTorsionToBeam soft warning: Torsion vector at Attachment1 parallel to curve. Change either spaceCurve or torsionCurve to avoid this.")
		cframe2 = CFrame.lookAt(createVector(0, 0, 0), vector5 - vector4) * inverse + vector5
	end

	self.Attachment0.WorldCFrame = cframe
	self.Attachment1.WorldCFrame = cframe2
	self.CurveSize0 = curveSize
	self.CurveSize1 = curveSize2
end

function BeamSpline.drawSpaceCurveWithBeamArray(callback, list, p: number?)
	local count = #list

	for i, v in ipairs(list) do
		local v4 = (i - 1) / count
		local v5 = i / count
		local _computeBezierApproxControlPoints, v6, v7, v8, v9, v10 = BeamSpline._computeBezierApproxControlPoints(
			function(p2: number)
				return callback(math.map(p2, 0, 1, v4, v5))
			end,
			p
		)
		BeamSpline.applyBezierControlPointsToBeam(v, _computeBezierApproxControlPoints, v6, v7, v8, v9, v10)
	end
end

function BeamSpline.draw(callback, callback2, callback3, list, p: number?)
	local count = #list

	for i, v in ipairs(list) do
		local v2 = (i - 1) / count
		local v3 = i / count
		local _computeBezierApproxControlPoints, v6, v7, v8, v9, v10 = BeamSpline._computeBezierApproxControlPoints(
			function(p2: number)
				return callback(math.map(p2, 0, 1, v2, v3))
			end,
			p
		)
		local v11 = callback3(v2)
		local v12 = callback3(v3)
		v.Width0 = callback2(v2)
		v.Width1 = callback2(v3)
		BeamSpline.applyBezierControlPointsAndTorsionToBeam(
			v,
			_computeBezierApproxControlPoints,
			v6,
			v7,
			v8,
			v9,
			v10,
			v11,
			v12
		)
	end
end

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

function BeamSpline.forceDisableRobloxBeamLOD(list)
	for _, v in ipairs(list) do
		CollectionService:AddTag(v, "Beam")

		if v:GetAttribute("DesiredSegments") == nil then
			v:SetAttribute("DesiredSegments", v.Segments)
		end
	end
end

local function RecalculateBeamSegments()
	for _, v in CollectionService:GetTagged("Beam") do
		local attachment0 = v.Attachment0
		local attachment1 = v.Attachment1

		if not (attachment0 and attachment1) then
			continue
		end

		local desiredSegments = v:GetAttribute("DesiredSegments")

		if not v:GetAttribute("DesiredSegments") then
			desiredSegments = v.Segments
			v:SetAttribute("DesiredSegments", v.Segments)
		end

		local cFrame = workspace.CurrentCamera.CFrame
		local v2 = math.max(
			(cFrame.Position - attachment0.WorldPosition).Magnitude,
			(cFrame.Position - attachment1.WorldPosition).Magnitude
		)
		local v3 = math.max(0, (math.min(1, UserSettings().GameSettings.SavedQualityLevel.Value / 10)))
		v.Segments = math.ceil(desiredSegments / math.clamp((1 - (v2 - 200) / 800) * v3, 0.1, 1))
	end
end

RunService:BindToRenderStep("BeamLOD", Enum.RenderPriority.Camera.Value + 1, RecalculateBeamSegments)

function BeamSpline.applyTransparencySequence(sequence, list)
	local count = #list

	if count == 0 then
		return
	end

	local keypoints = sequence.Keypoints
	local count2 = #keypoints

	local function sampleAt(p: number)
		if p <= keypoints[1].Time then
			return keypoints[1].Value, keypoints[1].Envelope
		end

		if keypoints[count2].Time <= p then
			return keypoints[count2].Value, keypoints[count2].Envelope
		end

		for i = 1, count2 - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= p and p <= keypoint2.Time) then
				continue
			end

			local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			return math.lerp(keypoint.Value, keypoint2.Value, v), (math.lerp(keypoint.Envelope, keypoint2.Envelope, v))
		end

		return keypoints[count2].Value, keypoints[count2].Envelope
	end

	for i, v in ipairs(list) do
		local v2 = (i - 1) / count
		local v3 = i / count
		local v4 = v3 - v2
		local numberSequenceKeypoints = {}
		local v5, v6 = sampleAt(v2)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, v5, v6))

		for _, keypoint in ipairs(keypoints) do
			if not (v2 < keypoint.Time and keypoint.Time < v3) then
				continue
			end

			local v7 = (keypoint.Time - v2) / v4
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v7, keypoint.Value, keypoint.Envelope))
		end

		local v7, v8 = sampleAt(v3)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, v7, v8))
		table.sort(numberSequenceKeypoints, function(a, b)
			return a.Time < b.Time
		end)
		v.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end
end

function BeamSpline.applyColorSequence(sequence, list)
	local count = #list

	if count == 0 then
		return
	end

	local keypoints = sequence.Keypoints
	local count2 = #keypoints

	local function sampleAt(p: number)
		if p <= keypoints[1].Time then
			return keypoints[1].Value
		end

		if keypoints[count2].Time <= p then
			return keypoints[count2].Value
		end

		for i = 1, count2 - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= p and p <= keypoint2.Time) then
				continue
			end

			local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			return keypoint.Value:Lerp(keypoint2.Value, v)
		end

		return keypoints[count2].Value
	end

	for i, v in ipairs(list) do
		local v2 = (i - 1) / count
		local v3 = i / count
		local v4 = v3 - v2
		local colorSequenceKeypoints = {}
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(0, sampleAt(v2)))

		for _, keypoint in ipairs(keypoints) do
			if not (v2 < keypoint.Time and keypoint.Time < v3) then
				continue
			end

			local v5 = (keypoint.Time - v2) / v4
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v5, keypoint.Value))
		end

		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, sampleAt(v3)))
		table.sort(colorSequenceKeypoints, function(a, b)
			return a.Time < b.Time
		end)
		v.Color = ColorSequence.new(colorSequenceKeypoints)
	end
end

function BeamSpline.beamToBezierControlPoints(data)
	assert(data.Attachment0, "Beam.Attachment0 must be set")
	assert(data.Attachment1, "Beam.Attachment1 must be set")
	local worldPosition = data.Attachment0.WorldPosition
	local worldPosition2 = data.Attachment1.WorldPosition
	local rightVector = data.Attachment0.WorldCFrame.RightVector
	local rightVector2 = data.Attachment1.WorldCFrame.RightVector
	return
		worldPosition,
		worldPosition + rightVector * data.CurveSize0,
		worldPosition2 - rightVector2 * data.CurveSize1,
		worldPosition2
end

return BeamSpline