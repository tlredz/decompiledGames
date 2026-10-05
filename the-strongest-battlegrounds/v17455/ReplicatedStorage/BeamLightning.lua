game:GetService("ReplicatedStorage")
local BeamLightning = {}
BeamLightning.__index = BeamLightning
local Bezier = require(script.Bezier)
local Tweening = require(script.Tweening)
local BeamLightningCache = require(script.BeamLightningCache)
local terrain = workspace.Terrain

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateAttachment(p, name)
	local attachment = BeamLightningCache.GetAttachment(p)
	attachment.Name = name
	attachment.Visible = false
	return attachment
end

local function AlignAttachments(list, terrain2, value, p)
	local result = {}

	for i = 1, #list - (p and 1 or 0) do
		local attachment = CreateAttachment(terrain2, "Attachment" .. tostring(i + (value or 0) + (p and 1 or 0))) -- equivalent call inferred; original call site unknown

		if i == #list then
			attachment.WorldPosition = list[i]
		else
			attachment.WorldPosition = list[i + (p and 1 or 0)]
		end

		table.insert(result, attachment)
	end

	return result
end

local function AlignAttachmentsV2(list, list2, tweenTime, easingStyle, easingDirection, p)
	for i = 1, #list2 - (p and 1 or 0) do
		Tweening.TweenProperty(list[i], tweenTime, easingStyle, easingDirection, {
			WorldPosition = list2[i + (p and 1 or 0)]
		}):Play()
	end

	return list
end

local library = require(game.ReplicatedStorage.library)
library = library.PlayTween

local function MakeBeam(attachment, attachment2, width, width2, data, terrain2, i, _)
	local beam = BeamLightningCache.GetBeam(terrain2)
	beam.Enabled = true
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Width0 = width
	beam.Width1 = width2
	beam.Texture = data == nil and "" or data.Texture
	beam.Segments = data == nil and 3 or data.Segments
	beam.FaceCamera = data == nil or data.FaceCamera
	local transparency

	if data == nil then
		transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
	else
		transparency = data.Transparency
	end

	beam.Transparency = transparency
	beam.Brightness = data == nil and 3 or data.Brightness
	local color

	if data == nil then
		color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(109, 192, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(109, 192, 255))
		})
	else
		color = data.Color
	end

	beam.Color = color
	beam.LightEmission = data == nil and 0 or data.LightEmission
	beam.LightInfluence = data == nil and 0 or data.LightInfluence
	beam.TextureLength = data == nil and 1 or data.TextureLength
	beam.TextureSpeed = data == nil and 1 or data.TextureSpeed
	beam.Name = "Beam" .. i .. "-" .. tostring(i + 1)
	return beam
end

local function SliceGradient(color, p: number, p2: number)
	local colorSequenceKeypoints = {}
	local keypoints = color.Keypoints

	local function sampleAt(p3)
		for _, keypoint in ipairs(keypoints) do
			if math.abs(keypoint.Time - p3) < 0.001 then
				return keypoint.Value
			end
		end

		for i = 1, #keypoints - 1 do
			local keypoint = keypoints[i]
			local keypoint2 = keypoints[i + 1]

			if not (keypoint.Time <= p3 and p3 <= keypoint2.Time) then
				continue
			end

			local v = (p3 - keypoint.Time) / (keypoint2.Time - keypoint.Time)
			return keypoint.Value:Lerp(keypoint2.Value, v)
		end

		return keypoints[#keypoints].Value
	end

	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(0, sampleAt(p)))

	for _, keypoint in ipairs(keypoints) do
		if not (p < keypoint.Time and keypoint.Time < p2) then
			continue
		end

		local v = (keypoint.Time - p) / (p2 - p)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v, keypoint.Value))
	end

	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, sampleAt(p2)))
	return ColorSequence.new(colorSequenceKeypoints)
end

local function ConnectBeams(_, p, p2, p3, attachments, p4)
	local v = #attachments - 1
	local v2 = math.floor(#attachments / 2)
	local v3 = (p2 - p) / v2
	local v4 = (p2 - p3) / (v - v2)
	local result = {}

	for i = 1, v do
		local v5 = attachments[i]
		local v6 = attachments[i + 1]
		local v7, v8

		if i <= v2 then
			v7 = p + v3 * (i - 1)
			v8 = p + v3 * i
		else
			local v9 = i - v2
			v7 = p2 - v4 * (v9 - 1)
			v8 = p2 - v4 * v9
		end

		local beam = MakeBeam(v5, v6, v7, v8, p4, terrain, i)

		if p4 and p4.Color and typeof(p4.Color) == "ColorSequence" then
			local v10 = (i - 1) / v
			local v11 = i / v
			beam.Color = SliceGradient(p4.Color, v10, v11)
		end

		table.insert(result, beam)
	end

	return result
end

local function ScramblePoints(list, part, part2, intensity)
	local cframe = CFrame.lookAt(part.Position, part2.Position)
	local v = cframe.RightVector * (math.random(-50, 50) * 0.1 * intensity) + cframe.UpVector * (math.random(-50, 50) * 0.1 * intensity) + cframe.LookVector * (math.random(
		-20,
		20
	) * 0.1 * intensity)

	for k, v2 in pairs(list) do
		if k ~= 1 and k ~= #list then
			list[k] = v2 + v
		end
	end

	return list
end

function BeamLightning.new(part, part2, value: number, value2: number, midPointCF: CFrame, value3: number, value4: number, value5: number, value6: number, value7: string, value8: string, _: number, value9: number, p: number, p2)
	local object = setmetatable({}, BeamLightning)
	object.Attachments = {}
	object.Part1 = part
	object.Part2 = part2
	object.MidPointCF = midPointCF
	object.Beams = {}
	object.BeamFolder = {}
	object.Curve1Attachments = {}
	object.Curve2Attachments = {}

	if part == nil or part2 == nil or typeof(part) ~= "Instance" or typeof(part2) ~= "Instance" then
		error("PART1 OR PART2 DO NOT MEET THE REQUIREMENTS OF A PART")
	end

	object.Segments = value or 5
	object.CurveSize = value2 or 5
	object.MidPointCF = midPointCF or CFrame.new(0, 0, 0)
	object.TweenTime = value6 or 1
	object.EasingStyle = value7 or "Quad"
	object.EasingDirection = value8 or "Out"
	object.Intensity = value9 or 1
	local magnitude = (part.Position - part2.Position).Magnitude
	local cframe = CFrame.lookAt(part.Position, part2.Position)
	object.MidPoint = (cframe * CFrame.new(0, 0, -magnitude / 2) * object.MidPointCF).Position
	local v4 = p or math.random(-180, 180)
	local v5

	if math.floor(object.Segments) % 2 == 0 then
		v5 = object.Segments / 2 - 1
	else
		v5 = math.floor(object.Segments / 2)
	end

	local v6 = {
		CurvePoint1 = cframe * CFrame.Angles(0, 0, (math.rad(v4))) * CFrame.new(0, object.CurveSize, -magnitude / 4),
		CurvePoint2 = cframe * CFrame.Angles(0, 0, (math.rad(v4))) * CFrame.new(
			0,
			-object.CurveSize,
			-magnitude / 2 + -magnitude / 4
		)
	}
	local v7 = math.random(11, 22) * 0.1
	local v8 = math.random(11, 22) * 0.1
	local v9 = {
		CurvePoint1 = cframe * CFrame.Angles(0, 0, (math.rad(v4))) * CFrame.new(
			0,
			object.CurveSize * v7,
			-magnitude / 4
		),
		CurvePoint2 = cframe * CFrame.Angles(0, 0, (math.rad(v4))) * CFrame.new(
			0,
			-object.CurveSize * v8,
			-magnitude / 2 + -magnitude / 4
		)
	}
	local v10 = { part.Position, v6.CurvePoint1.Position, object.MidPoint }
	local v11 = { object.MidPoint, v6.CurvePoint2.Position, part2.Position }
	local v12 = { part.Position, v9.CurvePoint1.Position, object.MidPoint }
	local v13 = { object.MidPoint, v9.CurvePoint2.Position, part2.Position }
	local bezierPoints = Bezier.GenerateBezierPoints(v10, v5)
	local scramblePoints = ScramblePoints(Bezier.GenerateBezierPoints(v12, v5), part, part2, object.Intensity)
	object.Curve1Attachments = AlignAttachments(bezierPoints, workspace.Terrain)
	AlignAttachmentsV2(
		object.Curve1Attachments,
		scramblePoints,
		object.TweenTime,
		object.EasingStyle,
		object.EasingDirection
	)
	local bezierPoints3 = Bezier.GenerateBezierPoints(v11, v5)
	local scramblePoints2 = ScramblePoints(Bezier.GenerateBezierPoints(v13, v5), part, part2, object.Intensity)
	object.Curve2Attachments = AlignAttachments(bezierPoints3, workspace.Terrain, v5, true)
	AlignAttachmentsV2(
		object.Curve2Attachments,
		scramblePoints2,
		object.TweenTime,
		object.EasingStyle,
		object.EasingDirection,
		true
	)
	object:AddAttachments()
	object.Beams = ConnectBeams(part, value3 or 0, value4 or 1, value5 or 0, object.Attachments, p2)
	return object
end

function BeamLightning.Destroy(list, value, value2, value3, value4)
	local v = value3 or "Quad"
	local v2 = value4 or "Out"

	if list.LightningLoop then
		list.LightningLoop:EndLoop()
	end

	for _, beam in pairs(list.Beams) do
		Tweening.TweenProperty(beam, value or 1, v, v2, {
			Width0 = 0,
			Width1 = 0
		}):Play()
		local v3 = beam
		task.delay(value or 1, function()
			v3.Enabled = false
		end)
		local v4 = beam
		task.delay(value2 or 1, function()
			BeamLightningCache.ReturnBeam(v4)
		end)
	end

	list.Beams = nil
	list.Curve1Attachments = nil
	list.Curve2Attachments = nil
	task.delay(value2 or 1, function()
		for _, attachment in pairs(list.Attachments) do
			BeamLightningCache.ReturnAttachment(attachment)
		end

		list.Attachments = nil
		table.clear(list)
		list = nil
	end)
end

function BeamLightning:AddAttachments()
	for _, curve1Attachment in pairs(self.Curve1Attachments) do
		table.insert(self.Attachments, curve1Attachment)
	end

	for _, curve2Attachment in pairs(self.Curve2Attachments) do
		table.insert(self.Attachments, curve2Attachment)
	end
end

return BeamLightning