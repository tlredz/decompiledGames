local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = nil
local v2 = nil
local attachment = nil
local highlight = nil
local v3 = nil
local v4 = nil
local v5 = nil
local uDim = nil
local v6 = nil
local v7 = nil
local position = nil
local v8 = nil
local scale = 1
local v9 = 0
local enabled = false
local v11 = {}
local v12 = {}
local v13 = 0
local color = Color3.fromRGB(255, 210, 230)
local color2 = Color3.fromRGB(255, 170, 205)
local color3 = Color3.fromRGB(255, 35, 155)
local color4 = Color3.fromRGB(255, 90, 205)
local color5 = Color3.fromRGB(255, 25, 35)
local color6 = Color3.fromRGB(145, 0, 10)

local function makeExposureGradient(p: number)
	local v14, v15

	if p < 0.5 then
		local v16 = p / 0.5
		v14 = color:Lerp(color3, v16)
		v15 = color2:Lerp(color4, v16)
	else
		local v16 = (p - 0.5) / 0.5
		v14 = color3:Lerp(color5, v16)
		v15 = color4:Lerp(color6, v16)
	end

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, v14),
		ColorSequenceKeypoint.new(0.55, v15),
		ColorSequenceKeypoint.new(1, v14)
	})
end

local function waitForDescendant(model, childName: string)
	local child = model:FindFirstChild(childName, true)

	while not child and model.Parent do
		task.wait(0.1)
		child = model:FindFirstChild(childName, true)
	end

	return child
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearCharacterEffects()
	if attachment then
		attachment:Destroy()
		attachment = nil
	end

	if highlight then
		highlight:Destroy()
		highlight = nil
	end
end

local function setupCharacter(instance)
	clearCharacterEffects() -- equivalent call inferred; original call site unknown
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 15)

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	attachment = Instance.new("Attachment")
	attachment.Name = "Stage9LaserTarget"
	attachment.Parent = humanoidRootPart

	if v then
		for _, beam in v.beams do
			beam.Attachment1 = attachment
		end
	end

	highlight = Instance.new("Highlight")
	highlight.Name = "Stage9ExposureHighlight"
	highlight.Adornee = instance
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = Color3.fromRGB(255, 40, 40)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	highlight.Parent = instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyGui()
	if v3 then
		v3:Destroy()
	end

	v3 = nil
	v4 = nil
	v5 = nil
	uDim = nil
	v6 = nil
	v7 = nil
	position = nil
	v8 = nil
	scale = 1
end

local function createGuiIfAvailable()
	if v3 or not v then
		return
	end

	local exposureGui = v.model:FindFirstChild("ExposureGui", true)

	if not (exposureGui and exposureGui:IsA("ScreenGui")) then
		return
	end

	local clone = exposureGui:Clone()
	clone.Name = "Stage9ExposureGui"
	clone.Enabled = true
	clone.ResetOnSpawn = false
	clone.Parent = playerGui
	v3 = clone
	local exposureFill = clone:FindFirstChild("ExposureFill", true) or clone:FindFirstChild("Fill", true)

	if exposureFill and exposureFill:IsA("GuiObject") then
		v4 = exposureFill
		uDim = UDim2.new(1, 0, exposureFill.Size.Y.Scale, exposureFill.Size.Y.Offset)
		local v14 = exposureFill:FindFirstChildWhichIsA("UIGradient")

		if not v14 then
			v14 = Instance.new("UIGradient")
			v14.Parent = exposureFill
		end

		v6 = v14
		local parent = exposureFill.Parent

		if parent and parent:IsA("GuiObject") then
			v7 = parent
			position = parent.Position
			local v15 = parent:FindFirstChildWhichIsA("UIScale")

			if not v15 then
				v15 = Instance.new("UIScale")
				v15.Name = "Stage9ExposurePulseScale"
				v15.Parent = parent
			end

			v8 = v15
			scale = v15.Scale
		end
	end

	local exposureText = clone:FindFirstChild("ExposureText", true) or clone:FindFirstChild("Value", true)

	if exposureText and exposureText:IsA("TextLabel") then
		v5 = exposureText
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBeamEnabled(p: number, flag: boolean)
	if v and v.beams[p] then
		v.beams[p].Enabled = flag and attachment ~= nil
	end
end

local function updateVisualState()
	local stage9Inside = localPlayer:GetAttribute("Stage9Inside") == true
	local stage9VisibleEyes = localPlayer:GetAttribute("Stage9VisibleEyes")
	local stage9Exposure = localPlayer:GetAttribute("Stage9Exposure")
	local stage9ExposureLimit = localPlayer:GetAttribute("Stage9ExposureLimit")
	local v14 = typeof(stage9VisibleEyes) ~= "number" and 0 or stage9VisibleEyes
	local v15 = math.clamp(
		(typeof(stage9Exposure) ~= "number" and 0 or stage9Exposure) / ((typeof(stage9ExposureLimit) ~= "number" or not (stage9ExposureLimit > 0)) and 3 or stage9ExposureLimit),
		0,
		1
	)
	enabled = stage9Inside
	v9 = v15

	for k, v16 in v12 do
		v16.Enabled = stage9Inside and k.Parent ~= nil
	end

	setBeamEnabled(1, stage9Inside and v14 % 2 == 1) -- equivalent call inferred; original call site unknown
	setBeamEnabled(2, stage9Inside and v14 >= 2) -- equivalent call inferred; original call site unknown

	if v then
		if not v.laserSound then
			local laserSound = v.model:FindFirstChild("LaserSound", true)

			if laserSound and laserSound:IsA("Sound") then
				v.laserSound = laserSound
				v.laserBaseVolume = laserSound.Volume
			end
		end

		if not v.heartbeatSound then
			local heartbeatSound = v.model:FindFirstChild("HeartbeatSound", true)

			if heartbeatSound and heartbeatSound:IsA("Sound") then
				v.heartbeatSound = heartbeatSound
				v.heartbeatBaseVolume = heartbeatSound.Volume
				v.heartbeatBaseSpeed = heartbeatSound.PlaybackSpeed
			end
		end

		local v18 = stage9Inside and v14 > 0
		local laserSound = v.laserSound

		if laserSound then
			laserSound.Looped = true
			laserSound.Volume = v.laserBaseVolume

			if v18 and not laserSound.IsPlaying then
				laserSound:Play()
			elseif not v18 and laserSound.IsPlaying then
				laserSound:Stop()
			end
		end

		local heartbeatSound = v.heartbeatSound
		local v19 = stage9Inside and v15 > 0.02

		if heartbeatSound then
			heartbeatSound.Looped = true
			heartbeatSound.Volume = v.heartbeatBaseVolume * (v15 * 0.75 + 0.25)
			heartbeatSound.PlaybackSpeed = v.heartbeatBaseSpeed * (v15 * 0.4 + 0.85)

			if v19 and not heartbeatSound.IsPlaying then
				heartbeatSound:Play()
			elseif not v19 and heartbeatSound.IsPlaying then
				heartbeatSound:Stop()
			end
		end
	end

	if highlight then
		highlight.Enabled = stage9Inside and v14 > 0
		highlight.FillTransparency = 0.75 - v15 * 0.45
	end

	if stage9Inside then
		createGuiIfAvailable()
	else
		destroyGui() -- equivalent call inferred; original call site unknown
	end

	if v4 and uDim then
		v4.Size = UDim2.new(uDim.X.Scale * v15, math.round(uDim.X.Offset * v15), uDim.Y.Scale, uDim.Y.Offset)
	end

	if v6 then
		v6.Color = makeExposureGradient(v15)
	end

	if v5 then
		v5.Text = string.format("%d%%", (math.round(v15 * 100)))
	end
end

local function registerObstacle(instance)
	if v12[instance] then
		return
	end

	if not (instance:IsA("Model") or instance:IsA("BasePart")) then
		warn("[Stage9EyesLaser][Client] W4S9Obstacle doit être sur un Model ou une BasePart :", instance:GetFullName())
		return
	end

	local highlight2 = Instance.new("Highlight")
	highlight2.Name = "Stage9ObstacleHighlight"
	highlight2.Adornee = instance
	highlight2.FillTransparency = 1
	highlight2.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight2.OutlineTransparency = 0
	highlight2.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight2.Enabled = enabled
	highlight2.Parent = instance
	v12[instance] = highlight2
end

local function unregisterObstacle(p)
	local v14 = v12[p]

	if v14 then
		v14:Destroy()
	end

	v12[p] = nil
end

local function isPointInsidePart(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	local v14 = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v14.X and math.abs(pointToObjectSpace.Y) <= v14.Y and math.abs(pointToObjectSpace.Z) <= v14.Z
end

local function getLocalVisibility(data, position2: Vector3)
	local characters = {
		data.zone,
		data.detectionPoint,
		data.eyes[1],
		data.eyes[2]
	}

	for _, v14 in Players:GetPlayers() do
		if v14.Character then
			table.insert(characters, v14.Character)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.IgnoreWater = true
	local v14 = position2 - data.detectionPoint.Position

	if v14.Magnitude <= 0 or workspace:Raycast(data.detectionPoint.Position, v14, raycastParams) then
		return 0
	end

	return 3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetLocalExposure()
	v13 = 0
	localPlayer:SetAttribute("Stage9Inside", false)
	localPlayer:SetAttribute("Stage9Exposure", 0)
	localPlayer:SetAttribute("Stage9VisibleEyes", 0)
end

local function updateLocalDetection(p: number)
	local v14 = v
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if v14 and humanoid and not (humanoid.Health <= 0) and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local zone = v14.zone
		local position2 = humanoidRootPart.Position
		local pointToObjectSpace = zone.CFrame:PointToObjectSpace(position2)
		local v15 = zone.Size * 0.5
		local v16

		if math.abs(pointToObjectSpace.X) <= v15.X and math.abs(pointToObjectSpace.Y) <= v15.Y then
			v16 = math.abs(pointToObjectSpace.Z) <= v15.Z
		else
			v16 = false
		end

		if v16 then
			local exposureLimit = v14.model:GetAttribute("ExposureLimit")
			local exposureRecoveryRate = v14.model:GetAttribute("ExposureRecoveryRate")
			local v17 = (typeof(exposureLimit) ~= "number" or not (exposureLimit > 0)) and 2.3 or exposureLimit
			local v18 = (typeof(exposureRecoveryRate) ~= "number" or not (exposureRecoveryRate >= 0)) and 1 or exposureRecoveryRate
			local localVisibility = getLocalVisibility(v14, humanoidRootPart.Position)

			if localVisibility > 0 then
				v13 = math.min(v17, v13 + p)
			else
				v13 = math.max(0, v13 - p * v18)
			end

			localPlayer:SetAttribute("Stage9Inside", true)
			localPlayer:SetAttribute("Stage9Exposure", v13)
			localPlayer:SetAttribute("Stage9ExposureLimit", v17)
			localPlayer:SetAttribute("Stage9VisibleEyes", localVisibility)

			if v17 <= v13 then
				humanoid.Health = 0
			end

			return
		end
	end

	resetLocalExposure() -- equivalent call inferred; original call site unknown
end

local function findNeckForHead(taggedHead)
	local parent = taggedHead.Parent

	while parent do
		if parent:IsA("Model") then
			for _, animationConstraint in parent:GetDescendants() do
				if not animationConstraint:IsA("AnimationConstraint") then
					continue
				end

				local attachment1 = animationConstraint.Attachment1

				if attachment1 and attachment1.Parent == taggedHead then
					return animationConstraint
				end
			end

			for _, motor6D in parent:GetDescendants() do
				if motor6D:IsA("Motor6D") and motor6D.Part1 == taggedHead then
					return motor6D
				end
			end
		end

		parent = parent.Parent
	end

	return nil
end

local function resolveTaggedHead(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if not instance:IsA("Model") then
		return nil
	end

	local head = instance:FindFirstChild("Head", true)

	if head and head:IsA("BasePart") then
		return head
	end

	return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
end

local function registerTrackingHead(instance)
	if v11[instance] then
		return
	end

	local taggedHead = resolveTaggedHead(instance)

	if not taggedHead then
		warn(
			"[Stage9EyesLaser][Client] Le tag de tête doit être sur une BasePart ou un Model :",
			instance:GetFullName()
		)
		return
	end

	local neckForHead = findNeckForHead(taggedHead)

	if neckForHead then
		v11[instance] = {
			head = taggedHead,
			joint = neckForHead,
			currentYaw = 0,
			currentPitch = 0
		}
	else
		warn("[Stage9EyesLaser][Client] Aucun AnimationConstraint/Motor6D relié à", taggedHead:GetFullName())
	end
end

local function unregisterTrackingHead(p)
	v11[p] = nil
end

local function getTrackingTarget()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position + createVector(0, 1.5, 0)
	end

	return nil
end

local function getJointFrame(animationConstraint)
	if animationConstraint:IsA("AnimationConstraint") then
		local attachment0 = animationConstraint.Attachment0

		if attachment0 then
			return attachment0.WorldCFrame
		end
	elseif animationConstraint.Part0 then
		return animationConstraint.Part0.CFrame * animationConstraint.C0
	end

	return nil
end

RunService.PreSimulation:Connect(function(dt)
	local v14

	if enabled then
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			v14 = humanoidRootPart.Position + createVector(0, 1.5, 0)
		end
	end

	local v15 = 1 - math.exp(-7 * dt)

	for k, v16 in v11 do
		if k.Parent and v16.joint.Parent then
			local v17 = 0
			local v18 = 0
			local joint = v16.joint
			local worldCFrame

			if joint:IsA("AnimationConstraint") then
				local attachment0 = joint.Attachment0

				if attachment0 then
					worldCFrame = attachment0.WorldCFrame
				end
			elseif joint.Part0 then
				worldCFrame = joint.Part0.CFrame * joint.C0
			end

			if v14 then
				if not worldCFrame then
					continue
				end

				local vectorToObjectSpace = worldCFrame:VectorToObjectSpace(v14 - worldCFrame.Position)
				local magnitude = Vector2.new(vectorToObjectSpace.X, vectorToObjectSpace.Z).Magnitude
				v17 = math.clamp(
					math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
					-1.2217304763960306,
					1.2217304763960306
				)
				v18 = math.clamp(math.atan2(vectorToObjectSpace.Y, magnitude), -0.6108652381980153, 0.6108652381980153)
			end

			v16.currentYaw += (v17 - v16.currentYaw) * v15
			v16.currentPitch += (v18 - v16.currentPitch) * v15
			local cframe = CFrame.Angles(v16.currentPitch, v16.currentYaw, 0)
			v16.joint.Transform = cframe * v16.joint.Transform
		else
			v11[k] = nil
		end
	end
end)
RunService.RenderStepped:Connect(function()
	if not (v7 and position and v8) then
		return
	end

	if enabled and v9 >= 0.65 then
		local v14 = math.clamp((v9 - 0.65) / 0.35, 0, 1)
		local now = os.clock()
		local v15 = math.sin(now * 37) * 3 * v14
		local v16 = math.cos(now * 43) * 2 * v14
		local v17 = (v14 * 0.045 + 0.025) * (math.sin(now * (v14 * 6 + 8)) * 0.5 + 0.5)
		v7.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset + math.round(v15),
			position.Y.Scale,
			position.Y.Offset + math.round(v16)
		)
		v8.Scale = scale * (v17 + 1)
	else
		v7.Position = position
		v8.Scale = scale
	end
end)

local function cleanupStage()
	if v then
		if v.laserSound then
			v.laserSound:Stop()
			v.laserSound.Volume = v.laserBaseVolume
		end

		if v.heartbeatSound then
			v.heartbeatSound:Stop()
			v.heartbeatSound.Volume = v.heartbeatBaseVolume
			v.heartbeatSound.PlaybackSpeed = v.heartbeatBaseSpeed
		end

		for _, beam in v.beams do
			beam:Destroy()
		end

		for _, sourceAttachment in v.sourceAttachments do
			sourceAttachment:Destroy()
		end
	end

	v = nil
	destroyGui() -- equivalent call inferred; original call site unknown
end

local function setupStage(model)
	if not model:IsA("Model") or v or v2 then
		return
	end

	v2 = model
	local part = waitForDescendant(model, "Eye1")
	local part2 = waitForDescendant(model, "Eye2")
	local part3 = waitForDescendant(model, "StageZone")
	local part4 = waitForDescendant(model, "Point")

	if part and part:IsA("BasePart") and part2 and part2:IsA("BasePart") then
		if part3 and part3:IsA("BasePart") and part4 and part4:IsA("BasePart") then
			local v14 = {
				model = model,
				zone = part3,
				detectionPoint = part4,
				eyes = { part, part2 },
				sourceAttachments = {},
				beams = {},
				laserSound = nil,
				heartbeatSound = nil,
				laserBaseVolume = 1,
				heartbeatBaseVolume = 1,
				heartbeatBaseSpeed = 1
			}
			local laserSound = model:FindFirstChild("LaserSound", true)

			if laserSound and laserSound:IsA("Sound") then
				v14.laserSound = laserSound
				v14.laserBaseVolume = laserSound.Volume
			end

			local heartbeatSound = model:FindFirstChild("HeartbeatSound", true)

			if heartbeatSound and heartbeatSound:IsA("Sound") then
				v14.heartbeatSound = heartbeatSound
				v14.heartbeatBaseVolume = heartbeatSound.Volume
				v14.heartbeatBaseSpeed = heartbeatSound.PlaybackSpeed
			end

			for k, eye in v14.eyes do
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "Stage9LaserSource" .. k
				attachment2.Parent = eye
				local beam = Instance.new("Beam")
				beam.Name = "Stage9EyeBeam" .. k
				beam.Attachment0 = attachment2
				beam.Attachment1 = attachment
				beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
				beam.LightEmission = 1
				beam.LightInfluence = 0
				beam.FaceCamera = true
				beam.Width0 = 0.22
				beam.Width1 = 0.08
				beam.Transparency = NumberSequence.new(0.1)
				beam.Enabled = false
				beam.Parent = eye
				table.insert(v14.sourceAttachments, attachment2)
				table.insert(v14.beams, beam)
			end

			v = v14
			v2 = nil
			updateVisualState()
		else
			v2 = nil
			warn("[Stage9EyesLaser][Client] StageZone ou Point introuvable dans", model:GetFullName())
		end
	else
		v2 = nil
		warn("[Stage9EyesLaser][Client] Eye1 ou Eye2 introuvable dans", model:GetFullName())
	end
end

for _, v14 in CollectionService:GetTagged("World4Stage9EyesLaser") do
	task.spawn(setupStage, v14)
end

CollectionService:GetInstanceAddedSignal("World4Stage9EyesLaser"):Connect(function(p)
	task.spawn(setupStage, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage9EyesLaser"):Connect(function(p)
	if v2 == p then
		v2 = nil
	end

	if v and v.model == p then
		cleanupStage()
	end
end)

for _, v14 in {
	"Stage9Inside",
	"Stage9Exposure",
	"Stage9ExposureLimit",
	"Stage9VisibleEyes"
} do
	localPlayer:GetAttributeChangedSignal(v14):Connect(updateVisualState)
end

localPlayer.CharacterAdded:Connect(function(character)
	task.spawn(setupCharacter, character)
	task.defer(updateVisualState)
end)

if localPlayer.Character then
	task.spawn(setupCharacter, localPlayer.Character)
end

for _, v14 in CollectionService:GetTagged("World4Stage9TrackingHead") do
	task.spawn(registerTrackingHead, v14)
end

CollectionService:GetInstanceAddedSignal("World4Stage9TrackingHead"):Connect(function(p)
	task.spawn(registerTrackingHead, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage9TrackingHead"):Connect(unregisterTrackingHead)

for _, v14 in CollectionService:GetTagged("W4S9Obstacle") do
	registerObstacle(v14)
end

CollectionService:GetInstanceAddedSignal("W4S9Obstacle"):Connect(registerObstacle)
CollectionService:GetInstanceRemovedSignal("W4S9Obstacle"):Connect(unregisterObstacle)
task.spawn(function()
	while true do
		local v14 = 0.1

		if v then
			local detectionInterval = v.model:GetAttribute("DetectionInterval")

			if typeof(detectionInterval) == "number" and detectionInterval >= 0.05 then
				v14 = detectionInterval
			end
		end

		updateLocalDetection(v14)
		task.wait(v14)
	end
end)