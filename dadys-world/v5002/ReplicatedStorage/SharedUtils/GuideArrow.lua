local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
assert(RunService:IsClient(), "GuideArrow is client-only")
local localPlayer = Players.LocalPlayer
local rainbow = {
	DefaultArrivalDistance = 8,
	CurveFactor = 1,
	BeamColor = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(190, 104, 98)),
		ColorSequenceKeypoint.new(0.21, Color3.fromRGB(218, 133, 65)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(253, 234, 141)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(168, 189, 153)),
		ColorSequenceKeypoint.new(0.78, Color3.fromRGB(108, 157, 184)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 125, 159))
	}),
	TransparencyFaded = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.298973, 0),
		NumberSequenceKeypoint.new(0.599921, 0),
		NumberSequenceKeypoint.new(1, 0)
	}),
	TransparencySolid = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) }),
	SourceWidth = 50,
	TargetWidth = 25,
	Segments = 25,
	Texture = "rbxassetid://88504991739433",
	TextureLength = 35,
	TextureSpeed = -1,
	TextureMode = Enum.TextureMode.Wrap,
	ZOffset = 0,
	LightInfluence = 1,
	BeamColorIsOneTotalSequence = false
}
local normal = {
	DefaultArrivalDistance = 8,
	CurveFactor = 1,
	BeamColor = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(123, 152, 255))
	}),
	BeamColorIsOneTotalSequence = true,
	TransparencyFaded = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2528, 0.2125),
		NumberSequenceKeypoint.new(0.8082, 0.2562),
		NumberSequenceKeypoint.new(1, 1)
	}),
	TransparencySolid = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2528, 0.2125),
		NumberSequenceKeypoint.new(0.8082, 0.2562),
		NumberSequenceKeypoint.new(1, 1)
	}),
	SourceWidth = 5,
	TargetWidth = 1,
	Segments = 10,
	Texture = "rbxassetid://105741286930701",
	TextureLength = 5,
	TextureSpeed = -1,
	TextureMode = Enum.TextureMode.Stretch,
	ZOffset = 5,
	LightInfluence = 0
}
local v3 = {
	Normal = normal,
	Rainbow = rainbow
}

local function resolveStyle(value)
	if type(value) == "string" then
		local v4 = v3[value]

		if v4 then
			return v4
		end

		warn(("[GuideArrow] unknown style %q; falling back to Normal"):format(value))
		return normal
	elseif type(value) == "table" then
		return value
	else
		return normal
	end
end

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local function safeCancel(object)
	if object then
		object:Cancel()
	end
end

local v4 = nil
local thread = nil
local v5 = nil

local function createAnchorPart(name: string)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Massless = true
	return part
end

local function createArrowBeam(attachment, sourceAttachment, data)
	local beam = Instance.new("Beam")
	beam.Name = "ArrowBeam"
	beam.Attachment0 = attachment
	beam.Attachment1 = sourceAttachment
	beam.Color = data.BeamColor
	beam.Segments = data.Segments
	beam.CurveSize0 = 0
	beam.CurveSize1 = 0
	beam.LightEmission = 0
	beam.LightInfluence = data.LightInfluence
	beam.Brightness = 1
	beam.FaceCamera = true
	beam.TextureMode = data.TextureMode
	beam.ZOffset = data.ZOffset
	beam.Width0 = 0
	beam.Width1 = 0
	beam.Transparency = data.TransparencyFaded
	beam.Texture = data.Texture
	beam.TextureLength = data.TextureLength
	beam.TextureSpeed = data.TextureSpeed
	beam.Parent = attachment
	return beam
end

-- equivalent calls inferred from this helper; original call sites unknown
local function widthAtNode(p: number, count: number, p2)
	if count <= 0 then
		return p2.TargetWidth
	end

	local v6 = p / count
	return p2.SourceWidth + (p2.TargetWidth - p2.SourceWidth) * v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getArrowTransparency(i: number, _: number, p)
	if i == 1 then
		return p.TransparencyFaded
	end

	return p.TransparencySolid
end

local function ensureRender(list, p)
	local count = #list

	if not v4 then
		local folder = Instance.new("Folder")
		folder.Name = "GuideArrow"
		folder.Parent = workspace
		local part = Instance.new("Part")
		part.Name = "GuideArrowSource"
		part.Size = createVector(0.1, 0.1, 0.1)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Massless = true
		part.Parent = folder
		local attachment = Instance.new("Attachment")
		attachment.Name = "GuideAttachmentSource"
		attachment.Parent = part
		v4 = {
			folder = folder,
			sourcePart = part,
			sourceAttachment = attachment,
			nodeParts = {},
			nodeAttachments = {},
			arrowBeams = {},
			nodeTweens = {},
			beamTweens = {},
			dyingNodes = {}
		}
	end

	while #v4.nodeParts < count do
		local v6 = #v4.nodeParts + 1
		local sourceAttachment = v6 == 1 and v4.sourceAttachment or v4.nodeAttachments[v6 - 1]
		local part = Instance.new("Part")
		part.Name = "GuideArrowNode"
		part.Size = createVector(0.1, 0.1, 0.1)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Massless = true
		part.CFrame = sourceAttachment.WorldCFrame
		part.Parent = v4.folder
		local attachment = Instance.new("Attachment")
		attachment.Name = "GuideAttachmentTarget"
		attachment.Parent = part
		table.insert(v4.nodeParts, part)
		table.insert(v4.nodeAttachments, attachment)
		table.insert(v4.arrowBeams, (createArrowBeam(attachment, sourceAttachment, p)))
	end

	while count < #v4.nodeParts do
		local count2 = #v4.nodeParts
		local part = table.remove(v4.nodeParts)
		table.remove(v4.nodeAttachments)
		local beam = table.remove(v4.arrowBeams)
		local nodeTween = v4.nodeTweens[count2]

		if nodeTween then
			nodeTween:Cancel()
		end

		v4.nodeTweens[count2] = nil
		local beamTween = v4.beamTweens[count2]

		if beamTween then
			beamTween:Cancel()
		end

		v4.beamTweens[count2] = nil
		local cFrame

		if count == 0 then
			cFrame = v4.sourcePart.CFrame
		else
			cFrame = CFrame.new(list[count])
		end

		local tween = TweenService:Create(part, tweenInfo, {
			CFrame = cFrame
		})
		local v9 = {
			part = part,
			beam = beam,
			tween = tween
		}
		table.insert(v4.dyingNodes, v9)
		tween.Completed:Connect(function()
			if v4 then
				for i, dyingNode in ipairs(v4.dyingNodes) do
					if dyingNode ~= v9 then
						continue
					end

					table.remove(v4.dyingNodes, i)
					break
				end
			end

			if part.Parent then
				part:Destroy()
			end
		end)
		tween:Play()
	end
end

local function computeBisector(vector2: Vector3, position: Vector3, vector3: Vector3, p)
	local DISTANCE_EPSILON = 0.001
	local vector4 = Vector3.new(position.X - vector2.X, 0, position.Z - vector2.Z)
	local vector5 = Vector3.new(vector3.X - position.X, 0, vector3.Z - position.Z)
	local v6 = 0
	local cframe = CFrame.new(position)

	if not (vector4.Magnitude > DISTANCE_EPSILON and vector5.Magnitude > DISTANCE_EPSILON) then
		return cframe, v6
	end

	local unit = vector4.Unit
	local unit2 = vector5.Unit
	local v7 = unit + unit2

	if not (v7.Magnitude > DISTANCE_EPSILON) then
		return cframe, v6
	end

	local unit3 = v7.Unit
	local v8 = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))
	v6 = math.min(vector4.Magnitude, vector5.Magnitude) * p.CurveFactor * math.sin(v8 / 2)
	local vector6 = -unit3
	local cross = vector6:Cross(createVector(0, 1, 0))

	if cross.Magnitude > DISTANCE_EPSILON then
		local unit4 = cross.Unit
		local unit5 = unit4:Cross(vector6).Unit
		cframe = CFrame.fromMatrix(position, vector6, unit5, unit4)
	end

	return cframe, v6
end

local function computeCurveAt(p: number, p2)
	if not v4 then
		return
	end

	local v6 = #v4.nodeParts

	if p < 1 or v6 <= p then
		return
	end

	local position = p == 1 and v4.sourcePart.Position or v4.nodeParts[p - 1].Position
	local cFrame, curveSize = computeBisector(position, v4.nodeParts[p].Position, v4.nodeParts[p + 1].Position, p2)
	v4.nodeParts[p].CFrame = cFrame
	v4.arrowBeams[p].CurveSize0 = curveSize
	v4.arrowBeams[p + 1].CurveSize1 = curveSize
end

local function sampleColorSequenceAt(sequence, value: number)
	local v6 = math.clamp(value, 0, 1)
	local keypoints = sequence.Keypoints

	if v6 <= keypoints[1].Time then
		return keypoints[1].Value
	end

	if keypoints[#keypoints].Time <= v6 then
		return keypoints[#keypoints].Value
	end

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= v6 and v6 <= keypoint2.Time) then
			continue
		end

		local v7 = keypoint2.Time - keypoint.Time

		if v7 <= 0 then
			return keypoint.Value
		end

		return keypoint.Value:Lerp(keypoint2.Value, (v6 - keypoint.Time) / v7)
	end

	return keypoints[#keypoints].Value
end

local function sliceColorSequence(beamColor, p: number, p2: number)
	if math.abs(p2 - p) < 1e-6 then
		return ColorSequence.new(sampleColorSequenceAt(beamColor, p))
	end

	local v6 = math.min(p, p2)
	local v7 = math.max(p, p2)
	local colorSequenceKeypoints = { ColorSequenceKeypoint.new(0, sampleColorSequenceAt(beamColor, p)) }
	local v8 = {}

	for _, keypoint in ipairs(beamColor.Keypoints) do
		if v6 < keypoint.Time and keypoint.Time < v7 then
			table.insert(v8, {
				Time = (keypoint.Time - p) / (p2 - p),
				Value = keypoint.Value
			})
		end
	end

	table.sort(v8, function(a, b)
		return a.Time < b.Time
	end)

	for _, v9 in ipairs(v8) do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v9.Time, v9.Value))
	end

	table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, sampleColorSequenceAt(beamColor, p2)))
	return ColorSequence.new(colorSequenceKeypoints)
end

local function renderChain(list, p)
	ensureRender(list, p)
	local count = #list

	if count == 0 then
		return
	end

	for i = 1, count do
		local arrowBeam = v4.arrowBeams[i]
		local arrowTransparency = getArrowTransparency(i, nil, p) -- equivalent call inferred; original call site unknown
		arrowBeam.Transparency = arrowTransparency
		local width = widthAtNode(i, count, p) -- equivalent call inferred; original call site unknown
		arrowBeam.Width0 = width
		local width2 = widthAtNode(i - 1, count, p) -- equivalent call inferred; original call site unknown
		arrowBeam.Width1 = width2

		if p.BeamColorIsOneTotalSequence then
			arrowBeam.Color = sliceColorSequence(p.BeamColor, i / count, (i - 1) / count)
		end
	end

	local v6 = table.create(count)
	v6[1] = CFrame.new(list[1])

	if count > 1 then
		v6[count] = CFrame.new(list[count])
	end

	local v7 = table.create(count)

	for i = 2, count - 1 do
		local v8, v9 = computeBisector(list[i - 1], list[i], list[i + 1], p)
		v6[i] = v8
		v7[i] = v9
	end

	for i = 1, count do
		local nodeTween = v4.nodeTweens[i]

		if nodeTween then
			nodeTween:Cancel()
		end

		local v8

		if i == 1 then
			v8 = {
				Position = list[1]
			}
		else
			v8 = {
				CFrame = v6[i]
			}
		end

		local tween = TweenService:Create(v4.nodeParts[i], tweenInfo, v8)
		v4.nodeTweens[i] = tween
		tween:Play()
	end

	for i = 2, count do
		local v8 = {}
		local v9 = i - 1

		if v9 >= 2 and v9 <= count - 1 then
			v8.CurveSize1 = v7[v9]
		end

		if i >= 2 and i <= count - 1 then
			v8.CurveSize0 = v7[i]
		elseif i == count then
			v8.CurveSize0 = 0
		end

		if not next(v8) then
			continue
		end

		local beamTween = v4.beamTweens[i]

		if beamTween then
			beamTween:Cancel()
		end

		local tween = TweenService:Create(v4.arrowBeams[i], tweenInfo, v8)
		v4.beamTweens[i] = tween
		tween:Play()
	end
end

local function clearRender()
	if not v4 then
		return
	end

	for _, nodeTween in pairs(v4.nodeTweens) do
		if nodeTween then
			nodeTween:Cancel()
		end
	end

	for _, beamTween in pairs(v4.beamTweens) do
		if beamTween then
			beamTween:Cancel()
		end
	end

	for _, dyingNode in ipairs(v4.dyingNodes) do
		local tween = dyingNode.tween

		if tween then
			tween:Cancel()
		end
	end

	v4.folder:Destroy()
	v4 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCharacterRoot()
	local character = localPlayer and localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function hasCharacterArrivedAtDestination(p: number?, p2)
	if not v5 then
		return false
	end

	local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

	if characterRoot then
		return (p or p2.DefaultArrivalDistance) >= (characterRoot.Position - v5).Magnitude
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startArrowThread(callback, p)
	thread = task.spawn(function()
		while true do
			RunService.Heartbeat:Wait()

			if not v4 then
				break
			end

			local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

			if characterRoot then
				v4.sourcePart.CFrame = characterRoot.CFrame
			end

			computeCurveAt(1, p)

			if not callback() then
				continue
			end

			clearRender()
			v5 = nil
			thread = nil
			break
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginGuide(p, callback, value)
	if thread then
		task.cancel(thread)
		thread = nil
	end

	renderChain(p, value)
	startArrowThread(callback, value) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endGuide()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	v5 = nil
	clearRender()
end

local GuideArrow = {}

function GuideArrow.SetDestination(_, vector2: Vector3?, p: number?, value)
	if vector2 then
		if type(value) == "string" then
			local v6 = v3[value]

			if v6 then
				value = v6
			else
				warn(("[GuideArrow] unknown style %q; falling back to Normal"):format(value))
				value = normal
			end
		elseif type(value) ~= "table" then
			value = normal
		end

		v5 = vector2

		local function fn()
			local v7 = p
			local v8 = value

			if not v5 then
				return false
			end

			local characterRoot = getCharacterRoot() -- equivalent call inferred; original call site unknown

			if characterRoot then
				return (v7 or v8.DefaultArrivalDistance) >= (characterRoot.Position - v5).Magnitude
			end

			return false
		end

		beginGuide({ vector2 }, fn, value) -- equivalent call inferred; original call site unknown
	else
		endGuide() -- equivalent call inferred; original call site unknown
	end
end

function GuideArrow.SetDestinationUntil(_, vector2: Vector3?, callback, value)
	if vector2 and callback then
		v5 = vector2

		if type(value) == "string" then
			local v7 = v3[value]

			if v7 then
				value = v7
			else
				warn(("[GuideArrow] unknown style %q; falling back to Normal"):format(value))
				value = normal
			end
		elseif type(value) ~= "table" then
			value = normal
		end

		beginGuide({ vector2 }, callback, value) -- equivalent call inferred; original call site unknown
	else
		endGuide() -- equivalent call inferred; original call site unknown
	end
end

function GuideArrow.SetChain(_, list, value)
	if list and #list > 0 then
		if type(value) == "string" then
			local v6 = v3[value]

			if v6 then
				value = v6
			else
				warn(("[GuideArrow] unknown style %q; falling back to Normal"):format(value))
				value = normal
			end
		elseif type(value) ~= "table" then
			value = normal
		end

		v5 = list[#list]

		if thread then
			renderChain(list, value)
			return
		end

		local function fn()
			return false
		end

		beginGuide(list, fn, value) -- equivalent call inferred; original call site unknown
	else
		endGuide() -- equivalent call inferred; original call site unknown
	end
end

return GuideArrow