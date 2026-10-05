local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local color = Color3.fromRGB(255, 255, 255)
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 20, 45))
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 224, 204), Color3.fromRGB(255, 178, 127))
local colorSequence3 = ColorSequence.new(Color3.fromRGB(255, 178, 127), Color3.fromRGB(197, 136, 98))
local colorSequence4 = ColorSequence.new(Color3.fromRGB(255, 112, 82), Color3.fromRGB(170, 65, 48))
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local localPlayer = nil
local maid = nil
local v = {}
local v2 = {}
local v3 = {}
local now = os.clock()
local enabled2 = false

local function findBasePart(instance, childName: string)
	local part = instance:FindFirstChild(childName, true)

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function getPositiveAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" and attribute > 0 then
		return attribute
	end

	return p
end

local function isInsideZone(part, vector2: Vector3)
	local pointToObjectSpace = part.CFrame:PointToObjectSpace(vector2)
	local halfSize = part.Size / 2

	if part:IsA("Part") and part.Shape == Enum.PartType.Cylinder then
		local v6 = pointToObjectSpace.Y / halfSize.Y
		local v7 = pointToObjectSpace.Z / halfSize.Z
		return math.abs(pointToObjectSpace.X) <= halfSize.X and v6 * v6 + v7 * v7 <= 1
	else
		return math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
	end
end

local function checkTrapReady(model)
	if not model:IsA("Model") then
		return false, nil, "World1G2Stage4 tag must be placed on a Model"
	end

	local stageZone = model:FindFirstChild("StageZone", true)

	if not (stageZone and stageZone:IsA("BasePart")) then
		stageZone = nil
	end

	local point = model:FindFirstChild("Point", true)

	if not (point and point:IsA("BasePart")) then
		point = nil
	end

	local eye1 = model:FindFirstChild("Eye1", true)

	if not (eye1 and eye1:IsA("BasePart")) then
		eye1 = nil
	end

	local eye2 = model:FindFirstChild("Eye2", true)

	if not (eye2 and eye2:IsA("BasePart")) then
		eye2 = nil
	end

	local exposureGui = model:FindFirstChild("ExposureGui", true)

	if not (exposureGui and exposureGui:IsA("ScreenGui")) then
		exposureGui = nil
	end

	local frame

	if exposureGui then
		frame = exposureGui:FindFirstChild("Frame", true)
	end

	local fill

	if frame then
		fill = frame:FindFirstChild("Fill", true)
	end

	if stageZone and point and eye1 and eye2 and exposureGui and frame and frame:IsA("GuiObject") and fill and fill:IsA("GuiObject") then
		return true, {
			stageZone = stageZone,
			point = point,
			eyes = { eye1, eye2 },
			exposureGui = exposureGui,
			laserSound = model:FindFirstChild("LaserSound", true),
			heartbeatSound = model:FindFirstChild("HeartbeatSound", true)
		}, ""
	end

	return false, nil, "The tagged model requires StageZone, Point, Eye1, Eye2, and ExposureGui with Frame and Fill"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createAttachment(parent, name: string)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.Parent = parent
	return attachment
end

local function createBeam(parent, attachment, object)
	local attachment2 = createAttachment(parent, "Stage9LaserOrigin") -- equivalent call inferred; original call site unknown
	local beam = Instance.new("Beam")
	beam.Name = "Stage9Laser"
	beam.Attachment0 = attachment2
	beam.Attachment1 = attachment
	beam.Color = colorSequence
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.Width0 = 0.4
	beam.Width1 = 0.3
	beam.Enabled = false
	beam.Parent = parent
	object:Add(beam)
	object:Add(attachment2)
	return beam
end

local function applyTrapSetup(model, state)
	local janitor = Janitor.new()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local clone = state.exposureGui:Clone()
	clone.Enabled = false
	clone.Parent = playerGui
	janitor:Add(clone)
	local frame = clone:FindFirstChild("Frame", true)
	local fill = frame:FindFirstChild("Fill", true)
	local exposureValue = clone:FindFirstChild("Value", true)

	if not (exposureValue and exposureValue:IsA("TextLabel")) then
		exposureValue = nil
	end

	local uIGradient = fill:FindFirstChildWhichIsA("UIGradient")
	local part = Instance.new("Part")
	part.Name = "Stage9LaserTarget"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Parent = Workspace
	janitor:Add(part)
	local attachment = createAttachment(part, "Target") -- equivalent call inferred; original call site unknown
	janitor:Add(attachment)
	local beams = { createBeam(state.eyes[1], attachment, janitor), (createBeam(state.eyes[2], attachment, janitor)) }
	local highlight = Instance.new("Highlight")
	highlight.Name = "Stage9TargetHighlight"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color
	highlight.FillTransparency = 1
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0.25
	highlight.Enabled = false
	highlight.Parent = Workspace
	janitor:Add(highlight)

	if state.laserSound and state.laserSound:IsA("Sound") then
		state.laserSound.Looped = true
	else
		state.laserSound = nil
	end

	if state.heartbeatSound and state.heartbeatSound:IsA("Sound") then
		state.heartbeatSound.Looped = true
	else
		state.heartbeatSound = nil
	end

	v[model] = {
		model = model,
		stageZone = state.stageZone,
		point = state.point,
		eyes = state.eyes,
		beams = beams,
		targetPart = part,
		characterHighlight = highlight,
		exposureGui = clone,
		exposureFrame = frame,
		exposureFill = fill,
		exposureValue = exposureValue,
		exposureGradient = uIGradient,
		baseFramePosition = frame.Position,
		baseFrameSize = frame.Size,
		baseFillSize = fill.Size,
		laserSound = state.laserSound,
		heartbeatSound = state.heartbeatSound,
		exposure = 0,
		inside = false,
		exposed = false,
		janitor = janitor
	}
	v2[model] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownTrap(k)
	v2[k] = nil
	local v5 = v[k]

	if v5 then
		if v5.laserSound then
			v5.laserSound:Stop()
		end

		if v5.heartbeatSound then
			v5.heartbeatSound:Stop()
		end

		v5.janitor:Destroy()
		v[k] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queueTrap(p)
	if v[p] == nil and v2[p] == nil then
		v2[p] = {
			nextRetry = 0,
			warnAt = os.clock() + 10,
			warned = false
		}
	end
end

local function retryPendingTraps(now2: number)
	for model, v5 in v2 do
		if model.Parent == nil then
			v2[model] = nil
		elseif v5.nextRetry <= now2 then
			v5.nextRetry = now2 + 0.5
			local v6, v7, v8 = checkTrapReady(model)

			if v6 and v7 and model:IsA("Model") then
				applyTrapSetup(model, v7)
			elseif v5.warnAt <= now2 and not v5.warned then
				v5.warned = true
				logger:warn(v8, model:GetFullName())
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSoundPlaying(object, flag: boolean)
	if object then
		if flag and not object.IsPlaying then
			object:Play()
		elseif not flag and object.IsPlaying then
			object:Stop()
		end
	end
end

local function isInsideTaggedSafeZone(position: Vector3)
	for _, part in CollectionService:GetTagged("W1G2S4Obstacle") do
		if part:IsA("BasePart") and part.Name == "SafeZone" and isInsideZone(part, position) then
			return true
		end
	end

	return false
end

local function hasLineOfSight(state, instance)
	if isInsideTaggedSafeZone(instance.Position) then
		return false
	end

	local position = state.point.Position
	local tagged = CollectionService:GetTagged("W1G2S4Obstacle")

	if #tagged == 0 then
		return true
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = tagged
	raycastParams.IgnoreWater = true
	local v5 = instance.Size.X * 0.4

	for _, v6 in {
		createVector(0, 0, 0),
		Vector3.new(0, instance.Size.Y, 0),
		Vector3.new(v5, 0, 0),
		(Vector3.new(-v5, 0, 0))
	} do
		if Workspace:Raycast(position, instance.CFrame:PointToWorldSpace(v6) - position, raycastParams) == nil then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setObstacleHighlightEnabled(enabled: boolean)
	for _, v5 in v3 do
		v5.Enabled = enabled
	end
end

local function setupObstacle(instance)
	if v3[instance] == nil and (instance:IsA("Model") or instance:IsA("BasePart")) then
		local highlight = Instance.new("Highlight")
		highlight.Name = "Stage9ObstacleHighlight"
		highlight.Adornee = instance
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.fromRGB(255, 80, 150)
		highlight.FillTransparency = 1
		highlight.OutlineColor = color
		highlight.OutlineTransparency = 0.25
		highlight.Enabled = enabled2
		highlight.Parent = Workspace
		v3[instance] = highlight
	end
end

local function teardownObstacle(p)
	local v5 = v3[p]

	if v5 then
		v5:Destroy()
		v3[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function killLocalPlayer()
	local v5 = localPlayer
	local character

	if v5 then
		character = v5.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, math.round(udim.X.Offset * p), udim.Y.Scale * p, (math.round(udim.Y.Offset * p)))
end

local function updateExposureUI(data, p: number, p2: number)
	data.exposureGui.Enabled = data.inside
	data.exposureFill.Size = UDim2.new(
		data.baseFillSize.X.Scale * p,
		math.round(data.baseFillSize.X.Offset * p),
		data.baseFillSize.Y.Scale,
		data.baseFillSize.Y.Offset
	)

	if data.exposureValue then
		data.exposureValue.Text = `EXPOSURE  {math.round(p * 100)}%`
	end

	if data.exposureGradient then
		local exposureGradient = data.exposureGradient
		local color2

		if p >= 0.65 then
			color2 = colorSequence4
		elseif p >= 0.35 then
			color2 = colorSequence3
		else
			color2 = colorSequence2
		end

		exposureGradient.Color = color2
	end

	if p >= 0.65 then
		local v5 = (p - 0.65) / 0.35
		local v6 = v5 * 5 + 2
		local v7 = math.sin(p2 * 14) * (v5 * 0.035 + 0.025) + 1
		data.exposureFrame.Position = data.baseFramePosition + UDim2.fromOffset(
			(math.random() - 0.5) * v6,
			(math.random() - 0.5) * v6
		)
		local exposureFrame = data.exposureFrame
		local baseFrameSize = data.baseFrameSize
		exposureFrame.Size = UDim2.new(
			baseFrameSize.X.Scale * v7,
			math.round(baseFrameSize.X.Offset * v7),
			baseFrameSize.Y.Scale * v7,
			(math.round(baseFrameSize.Y.Offset * v7))
		)
	else
		data.exposureFrame.Position = data.baseFramePosition
		data.exposureFrame.Size = data.baseFrameSize
	end
end

local function updateTrap(state, now2: number, p: number, character, humanoidRootPart, humanoid)
	state.inside = character ~= nil and humanoidRootPart ~= nil and humanoid ~= nil and humanoid.Health > 0 and isInsideZone(
		state.stageZone,
		humanoidRootPart.Position
	)

	if state.inside and character and humanoidRootPart then
		state.targetPart.CFrame = humanoidRootPart.CFrame
		state.exposed = hasLineOfSight(state, humanoidRootPart)
	else
		state.exposed = false
	end

	local exposureLimit = state.model:GetAttribute("ExposureLimit")
	local v6 = (typeof(exposureLimit) ~= "number" or not (exposureLimit > 0)) and 2 or exposureLimit

	if state.inside and state.exposed then
		state.exposure = math.min(v6, state.exposure + p)
	else
		local exposureRecoveryRate = state.model:GetAttribute("ExposureRecoveryRate")
		local v7 = (typeof(exposureRecoveryRate) ~= "number" or not (exposureRecoveryRate > 0)) and 2 or exposureRecoveryRate
		state.exposure = math.max(0, state.exposure - v7 * p)
	end

	for _, beam in state.beams do
		beam.Enabled = state.inside and state.exposed
	end

	state.characterHighlight.Adornee = character
	state.characterHighlight.Enabled = state.inside and state.exposed
	local laserSound = state.laserSound
	local exposed = state.inside and state.exposed
	setSoundPlaying(laserSound, exposed) -- equivalent call inferred; original call site unknown
	setSoundPlaying(state.heartbeatSound, state.inside and state.exposure > 0) -- equivalent call inferred; original call site unknown

	if state.heartbeatSound then
		local v8 = math.clamp(state.exposure / v6, 0, 1)
		state.heartbeatSound.Volume = v8 * 0.75 + 0.25
		state.heartbeatSound.PlaybackSpeed = v8 * 0.65 + 0.85
	end

	if v6 <= state.exposure then
		state.exposure = 0
		killLocalPlayer() -- equivalent call inferred; original call site unknown
	end

	updateExposureUI(state, math.clamp(state.exposure / v6, 0, 1), now2)
end

local function updateClient()
	local now2 = os.clock()
	local v5 = math.min(now2 - now, 0.1)
	now = now2
	retryPendingTraps(now2)
	local v6 = localPlayer
	local character

	if v6 then
		character = v6.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	local v7 = false

	for k, v8 in v do
		if k.Parent == nil then
			teardownTrap(k) -- equivalent call inferred; original call site unknown
		else
			updateTrap(v8, now2, v5, character, humanoidRootPart, humanoid)
			v7 = v7 or v8.inside
		end
	end

	if v7 ~= enabled2 then
		enabled2 = v7
		setObstacleHighlightEnabled(v7) -- equivalent call inferred; original call site unknown
	end
end

local function startClient()
	localPlayer = Players.LocalPlayer
	maid = Janitor.new()
	now = os.clock()

	for _, v5 in CollectionService:GetTagged("World1G2Stage4") do
		queueTrap(v5) -- equivalent call inferred; original call site unknown
	end

	for _, v5 in CollectionService:GetTagged("W1G2S4ObstacleVisual") do
		setupObstacle(v5)
	end

	maid:Add(CollectionService:GetInstanceAddedSignal("World1G2Stage4"):Connect(queueTrap))
	maid:Add(CollectionService:GetInstanceRemovedSignal("World1G2Stage4"):Connect(teardownTrap))
	maid:Add(CollectionService:GetInstanceAddedSignal("W1G2S4ObstacleVisual"):Connect(setupObstacle))
	maid:Add(CollectionService:GetInstanceRemovedSignal("W1G2S4ObstacleVisual"):Connect(teardownObstacle))
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClient()
		end
	end,
	OnRender = function()
		if RunService:IsClient() then
			updateClient()
		end
	end
})
return {}