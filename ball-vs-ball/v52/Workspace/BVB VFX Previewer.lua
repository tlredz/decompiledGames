local createVector = vector.create
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local Workspace = game:GetService("Workspace")
local EffectLifetime = require(script:WaitForChild("EffectLifetime"))

if RunService:IsRunning() then
	return
end

local ForgeVFX = require(script.ForgeVFX)
ForgeVFX.init()
local v = { "播放音效", "PlaySound" }
local cframe = CFrame.new(0, 500, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local cframe2 = CFrame.new(0, 0, -15.4749756, -1, 0, 0, 0, 1, 0, 0, 0, -1)
local cframe3 = CFrame.new(-12.8999939, -1.8581848, 0.4680176, -0.866025448, 0, 0.5, 0, 1, 0, -0.5, 0, -0.866025448)
local cframe4 = CFrame.new(0, -3.1158104, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
local vector2 = Vector2.new(4.75, 0)
local vector3 = Vector2.new(-4.75, 0)
local color = Color3.fromRGB(235, 64, 64)
local color2 = Color3.fromRGB(64, 128, 235)
local v2 = {
	["结算击杀特效"] = "kill",
	kill = "kill",
	["结算死亡特效"] = "death",
	death = "death",
	["结算跳杀特效"] = "windup",
	["jump kill"] = "windup",
	["结算跳杀拖尾"] = "trail",
	["jump kill trail"] = "trail",
	["爆炸特效"] = "explosion",
	explosion = "explosion"
}
local v3 = {
	"kill",
	"death",
	"windup",
	"trail",
	"explosion"
}

local function collectEffectSet(folder)
	local models = {}
	local count = 0

	for _, model in folder:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local match = model.Name:match("_([^_]+)$")
		local v4 = match and v2[string.lower(match)]

		if not v4 or models[v4] then
			continue
		end

		models[v4] = model
		count += 1
	end

	return models, count
end

local function getSelectedEffectFolder()
	local v4 = Selection:Get()

	if #v4 ~= 1 then
		return nil, nil
	end

	local folder = v4[1]

	if not folder:IsA("Folder") then
		return nil, nil
	end

	local v5, v6 = collectEffectSet(folder)

	if v6 == 0 then
		return nil, nil
	end

	return folder, v5
end

local parent = nil
local v5 = {}
local v6 = {}
local count = 0
local v7 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function setNonArchivable(folder)
	folder.Archivable = false

	for _, descendant in folder:GetDescendants() do
		descendant.Archivable = false
	end
end

local function lockParts(folder)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Locked = true
		end
	end

	if folder:IsA("BasePart") then
		folder.Locked = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p)
	table.insert(v6, p)
end

local function clearScene()
	count += 1
	v7 = 0

	for _, connection in v6 do
		connection:Disconnect()
	end

	table.clear(v6)
	table.clear(v5)

	if parent then
		parent:Destroy()
		parent = nil
	end
end

local function makePart(name: string, size: Vector3, cFrame: CFrame, color3: Color3, model)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cFrame
	part.Color = color3
	part.Material = Enum.Material.Plastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.Locked = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Archivable = false
	part.Parent = model
	return part
end

local function getNumberAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function playParticleEmitterForDuration(instance, duration: number)
	local rate = instance.Rate

	if rate <= 0 then
		task.wait(duration)
		return
	end

	local v8 = 1 / rate
	local total = 0
	local v9 = 0

	while total < duration and instance.Parent and not EffectLifetime.isVisualHidden(instance) do
		local v10 = RunService.Heartbeat:Wait()
		total += v10
		v9 += v10
		local count2 = 0

		while v8 <= v9 do
			v9 -= v8
			instance:Emit(1)
			count2 += 1

			if count2 >= 25 then
				break
			end
		end
	end
end

local function playParticleEmitter(instance)
	local emitDelay = instance:GetAttribute("EmitDelay")
	local v8 = typeof(emitDelay) ~= "number" and 0 or emitDelay
	local emitDuration = instance:GetAttribute("EmitDuration")
	local v9 = typeof(emitDuration) ~= "number" and 0 or emitDuration

	if v8 > 0 then
		task.wait(v8)
	end

	if not instance.Parent or EffectLifetime.isVisualHidden(instance) then
		return
	end

	if v9 > 0 then
		playParticleEmitterForDuration(instance, v9)
		return
	end

	local emitCount = instance:GetAttribute("EmitCount")
	instance:Emit(typeof(emitCount) ~= "number" and 10 or emitCount)
end

local v8 = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function getPreviewSoundPlayer(instance)
	local parent2 = parent

	if not (parent2 and instance.Parent) then
		return nil
	end

	local v10 = v8[instance]

	if not (v10 and v10.Parent) then
		local targetInstance = parent2:FindFirstChild("PreviewAudioOutput")

		if not targetInstance then
			targetInstance = Instance.new("AudioDeviceOutput")
			targetInstance.Name = "PreviewAudioOutput"
			targetInstance.Archivable = false
			targetInstance.Parent = parent2
		end

		v10 = Instance.new("AudioPlayer")
		v10.Name = instance.Name
		v10.Asset = instance.SoundId
		v10.Archivable = false
		v10.Parent = parent2
		local wire = Instance.new("Wire")
		wire.SourceInstance = v10
		wire.TargetInstance = targetInstance
		wire.Archivable = false
		wire.Parent = v10
		v8[instance] = v10
		local destroyingConnection = nil
		destroyingConnection = instance.Destroying:Connect(function()
			if v8[instance] == v10 then
				v8[instance] = nil
			end

			v10:Destroy()

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end
		end)
	end

	v10.Volume = instance.Volume
	v10.PlaybackSpeed = instance.PlaybackSpeed
	return v10
end

local function playSound(object2)
	if RunService:IsRunning() then
		object2:Play()
		return
	end

	local previewSoundPlayer = getPreviewSoundPlayer(object2)

	if previewSoundPlayer then
		previewSoundPlayer:Play()
	end
end

local function collectSoundsByName(folder)
	local soundsByName = {}

	for _, sound in ipairs(folder:GetDescendants()) do
		if sound:IsA("Sound") and soundsByName[sound.Name] == nil then
			soundsByName[sound.Name] = sound
		end
	end

	return soundsByName
end

local function findLocalAnimationClip(p)
	local ServerStorage = game:GetService("ServerStorage")
	local RBX_ANIMSAVES = ServerStorage:FindFirstChild("RBX_ANIMSAVES")

	if not (RBX_ANIMSAVES and p) then
		return nil
	end

	local v9 = nil

	for _, objectValue in RBX_ANIMSAVES:GetChildren() do
		if not (objectValue:IsA("ObjectValue") and objectValue.Value == p) then
			continue
		end

		v9 = objectValue
		break
	end

	local v11 = v9 or RBX_ANIMSAVES:FindFirstChild(p.Name)

	if not v11 then
		return nil
	end

	local customAnimation = v11:FindFirstChild("CustomAnimation")

	if customAnimation and customAnimation:IsA("AnimationClip") then
		return customAnimation
	end

	return v11:FindFirstChildWhichIsA("AnimationClip")
end

local function loadAnimationTracks(folder, p)
	local v9 = collectSoundsByName(folder)
	local localAnimationClip = findLocalAnimationClip(p)
	object[folder] = nil
	local tracks = {}

	for _, animationController in ipairs(folder:GetDescendants()) do
		if not animationController:IsA("AnimationController") then
			continue
		end

		local animator = animationController:FindFirstChildOfClass("Animator")
		local v10 = folder:FindFirstChildWhichIsA("Animation", true)

		if not (animator and v10 and v10:IsA("Animation")) then
			continue
		end

		if localAnimationClip then
			local success, result = pcall(function()
				local AnimationClipProvider = game:GetService("AnimationClipProvider")
				return AnimationClipProvider:RegisterAnimationClip(localAnimationClip)
			end)

			if success then
				v10 = Instance.new("Animation")
				v10.AnimationId = result
				object[folder] = localAnimationClip
			else
				warn(string.format(
					"[BVBVFXPreviewer] Failed to register local animation, falling back to the published animation: %s",
					(tostring(result))
				))
			end
		end

		local track2 = animator:LoadAnimation(v10)

		local function onSoundEvent(value: string)
			local v11 = v9[value] or v9[value:gsub("^音效", "Sound")] or v9[value:gsub("^Sound", "音效")]

			if v11 then
				task.spawn(playSound, v11)
			end
		end

		for _, v11 in v do
			track2:GetMarkerReachedSignal(v11):Connect(onSoundEvent)
		end

		v5[animator] = true
		table.insert(tracks, track2)
	end

	return tracks
end

local function computeCleanupDuration(clone, p)
	local v9 = collectSoundsByName(clone)
	local previewSoundPlayers = {}

	for _, v10 in v9 do
		local previewSoundPlayer = getPreviewSoundPlayer(v10)

		if previewSoundPlayer then
			table.insert(previewSoundPlayers, previewSoundPlayer)
		end
	end

	local v10 = os.clock() + 5

	while true do
		local v11 = true

		for _, v12 in previewSoundPlayers do
			if not v12.Parent or v12.IsReady then
				continue
			end

			v11 = false
		end

		if v11 or not clone.Parent or v10 <= os.clock() then
			return EffectLifetime.prepare(clone, p, {
				localClip = object[clone],
				resolveSound = function(value: string)
					return v9[value] or v9[value:gsub("^音效", "Sound")] or v9[value:gsub("^Sound", "音效")]
				end,
				eventNames = {
					["播放音效"] = true,
					PlaySound = true
				},
				durationOfSound = function(p2)
					local v12 = v8[p2]
					local v13

					if v12 and v12.TimeLength > 0 then
						v13 = v12.TimeLength
					else
						v13 = not (p2.TimeLength > 0) and 3 or p2.TimeLength
					end

					return v13 / math.max(p2.PlaybackSpeed, 0.01)
				end
			})
		else
			task.wait()
		end
	end
end

local function repositionIfNeeded(model, p)
	if p and model:IsA("Model") then
		if typeof(p) == "CFrame" then
			model:PivotTo(p)
		else
			local pivot = model:GetPivot()
			model:PivotTo(CFrame.new(p) * (pivot - pivot.Position))
		end
	end
end

local function triggerEffects(folder, instance, p)
	local v9 = p or loadAnimationTracks(folder, instance)
	local v10 = #v9 > 0

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			task.spawn(playParticleEmitter, descendant)
		elseif descendant:IsA("Sound") and not v10 then
			task.spawn(playSound, descendant)
		end
	end

	for _, v11 in ipairs(v9) do
		v11.Looped = false
		v11:Play()
	end

	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAfter(instance, duration: number)
	task.delay(duration, function()
		if instance.Parent then
			instance:Destroy()
		end
	end)
end

local function playForgeEffectClone(instance, p)
	if not parent then
		return 0
	end

	local clone = instance:Clone()
	setNonArchivable(clone) -- equivalent call inferred; original call site unknown
	lockParts(clone)
	clone.Parent = parent
	repositionIfNeeded(clone, p)
	local v9 = EffectLifetime.begin(clone)
	local v10 = loadAnimationTracks(clone, instance)
	EffectLifetime.suspendVisuals(clone, v9)
	local v11, v12 = computeCleanupDuration(clone, v10)

	if not (clone.Parent and EffectLifetime.isCurrent(clone, v9)) then
		return 0
	end

	local v13 = EffectLifetime.begin(clone)
	v7 = math.max(v7, os.clock() + v11)

	for _, v14 in v10 do
		v14.Looped = false
		v14:Play()
	end

	EffectLifetime.scheduleVisualCleanup(clone, v13, v12)
	local v14 = ForgeVFX.emit(clone)
	local v15 = false
	local v16 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if v15 and v16 and clone.Parent then
			clone:Destroy()
		end
	end

	v14.Finished:finally(function()
		v16 = true
		cleanup() -- equivalent call inferred; original call site unknown
	end)
	task.delay(v11, function()
		v15 = true
		cleanup() -- equivalent call inferred; original call site unknown
	end)
	return v11
end

local function playEffectClone(instance, p)
	if not (instance and parent) then
		return 0
	end

	if instance:HasTag("ForgeVFX") then
		return (playForgeEffectClone(instance, p))
	end

	local clone = instance:Clone()
	setNonArchivable(clone) -- equivalent call inferred; original call site unknown
	lockParts(clone)
	clone.Parent = parent
	repositionIfNeeded(clone, p)
	local v9 = EffectLifetime.begin(clone)
	local v10 = loadAnimationTracks(clone, instance)
	EffectLifetime.suspendVisuals(clone, v9)
	local v11, v12 = computeCleanupDuration(clone, v10)

	if not (clone.Parent and EffectLifetime.isCurrent(clone, v9)) then
		return 0
	end

	local v13 = EffectLifetime.begin(clone)
	v7 = math.max(v7, os.clock() + v11)
	triggerEffects(clone, instance, v10)
	EffectLifetime.scheduleVisualCleanup(clone, v13, v12)
	destroyAfter(clone, v11) -- equivalent call inferred; original call site unknown
	return v11
end

local function bezierComponent(p: number, p2: number, p3: number)
	local v9 = p2 * 3 - p3 * 3 + 1
	local v10 = p3 * 3 - p2 * 6
	local v11 = p2 * 3
	return ((v9 * p + v10) * p + v11) * p, (v9 * 3 * p + v10 * 2) * p + v11
end

local function solveBezierT(p: number, p2: number, p3: number)
	local v9 = p

	for _ = 1, 8 do
		local v10 = p2 * 3 - p3 * 3 + 1
		local v11 = p3 * 3 - p2 * 6
		local v12 = p2 * 3
		local v13 = ((v10 * v9 + v11) * v9 + v12) * v9
		local v14 = (v10 * 3 * v9 + v11 * 2) * v9 + v12

		if math.abs(v14) < 1e-6 then
			break
		end

		v9 -= (v13 - p) / v14

		if v9 ~= v9 or v9 < 0 or v9 > 1 then
			break
		end

		if math.abs(v13 - p) < 1e-6 then
			return v9
		end
	end

	local v10 = 0
	local v11 = 1

	for _ = 1, 24 do
		local v12 = (v10 + v11) * 0.5
		local v13 = p2 * 3 - p3 * 3 + 1
		local v14 = p3 * 3 - p2 * 6
		local v15 = p2 * 3
		local v16 = ((v13 * v12 + v14) * v12 + v15) * v12
		local _ = (v13 * 3 * v12 + v14 * 2) * v12 + v15

		if v16 < p then
			v10 = v12
		else
			v11 = v12
		end
	end

	return (v10 + v11) * 0.5
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutQuad(p: number)
	return 1 - (1 - p) * (1 - p)
end

local function worldFromArena(cframe5: CFrame, point: Vector2, p: number)
	return cframe5:PointToWorldSpace((Vector3.new(point.X, point.Y, -p)))
end

local function getArenaBallCFrame(cframe5: CFrame, vector4: Vector3)
	return CFrame.lookAt(vector4, vector4 + cframe5.UpVector, cframe5.LookVector)
end

local function buildBall(name: string, color3: Color3, cframe5: CFrame, vector4: Vector2, folder)
	local model = Instance.new("Model")
	model.Name = name
	model.Archivable = false
	local part = Instance.new("Part")
	part.Name = "Hitbox"
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(3, 3, 3)
	part.Color = color3
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.Locked = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Archivable = false
	local pointToWorldSpace = cframe5:PointToWorldSpace((Vector3.new(vector4.X, vector4.Y, -2.6)))
	part.CFrame = CFrame.lookAt(pointToWorldSpace, pointToWorldSpace + cframe5.UpVector, cframe5.LookVector)
	part.Parent = model
	model.PrimaryPart = part
	model.Parent = folder
	return model
end

local function buildBoard(cframe5: CFrame, folder)
	local model = Instance.new("Model")
	model.Name = "Board"
	model.Archivable = false
	model.Parent = folder
	local color3 = Color3.new(0.262745, 0.262745, 0.262745)
	local color4 = Color3.new(0.141176, 0.141176, 0.141176)
	makePart(
		"Floor",
		createVector(16.5, 1.45, 16.5),
		cframe5 * CFrame.new(0, 0, 1.1749945, 1, 0, 0, 0, 0, 1, 0, -1, 0),
		color3,
		model
	)
	makePart(
		"Frame",
		createVector(17.1, 1.7, 0.3),
		cframe5 * CFrame.new(-8.4, 0, -0.25, 0, 0, 1, -1, 0, 0, 0, -1, 0),
		color4,
		model
	)
	makePart(
		"Frame",
		createVector(17.1, 1.7, 0.3),
		cframe5 * CFrame.new(8.4, 0, -0.25, 0, 0, 1, -1, 0, 0, 0, -1, 0),
		color4,
		model
	)
	makePart(
		"Frame",
		createVector(16.5, 1.7, 0.3),
		cframe5 * CFrame.new(0, -8.4, -0.25, 1, 0, 0, 0, 0, 1, 0, -1, 0),
		color4,
		model
	)
	makePart(
		"Frame",
		createVector(16.5, 1.7, 0.3),
		cframe5 * CFrame.new(0, 8.4, -0.25, 1, 0, 0, 0, 0, 1, 0, -1, 0),
		color4,
		model
	)
end

local function buildCharacter(cframe5: CFrame, folder)
	local v9 = cframe5 * cframe3
	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(
			Instance.new("HumanoidDescription"),
			Enum.HumanoidRigType.R15
		)
	end)

	if not success then
		result = Players:CreateHumanoidModelFromDescription(
			Instance.new("HumanoidDescription"),
			Enum.HumanoidRigType.R15
		)
	end

	result.Name = "LoserPlayer"
	local animate = result:FindFirstChild("Animate")

	if animate then
		animate:Destroy()
	end

	local humanoid = result:FindFirstChildOfClass("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameDisplayDistance = 0
	humanoid.HealthDisplayDistance = 0
	local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")
	result:PivotTo(v9 * cframe4 * CFrame.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0) * result:GetPivot():ToObjectSpace(humanoidRootPart.CFrame):Inverse())

	for _, part in result:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.Anchored = true
	end

	lockParts(result)
	setNonArchivable(result) -- equivalent call inferred; original call site unknown
	result.Parent = folder
	return humanoidRootPart
end

local function buildScene()
	clearScene()
	local folder = Instance.new("Folder")
	folder.Name = "BVBVFXPreview"
	folder.Archivable = false
	folder.Parent = Workspace
	parent = folder
	local anchorCFrame = cframe
	buildBoard(anchorCFrame, folder)
	local ball = buildBall("RedBall_Winner", color, anchorCFrame, vector2, folder)
	local ball2 = buildBall("BlueBall_Loser", color2, anchorCFrame, vector3, folder)
	local character = buildCharacter(anchorCFrame, folder)
	return {
		anchorCFrame = anchorCFrame,
		cameraMarkerCFrame = anchorCFrame * cframe2,
		winnerBall = ball,
		loserBall = ball2,
		loserRootPart = character
	}
end

local function resolveJumpKillBulge(p)
	local lookVector = p.anchorCFrame.LookVector
	local v10 = p.cameraMarkerCFrame.Position - p.anchorCFrame.Position

	if lookVector:Dot(v10) < 0 then
		lookVector = -lookVector
	end

	local v11 = math.min(6, math.abs((lookVector:Dot(v10))) * 0.6)
	return lookVector.Unit, v11
end

local function playSequence(name: string, p, fn)
	for _, v9 in v3 do
		if not p[v9] then
			warn(string.format("[BVBVFXPreviewer] %s is missing node \"%s\"; skipping that stage", name, v9))
		end
	end

	local scene = buildScene()
	local v9 = count
	local folder = Instance.new("Folder")
	folder.Name = "AudioWarmup"
	folder.Archivable = false
	folder.Parent = parent
	local v10 = {}

	for _, folder2 in p do
		for _, sound in folder2:GetDescendants() do
			if not sound:IsA("Sound") or sound.SoundId == "" or v10[sound.SoundId] then
				continue
			end

			v10[sound.SoundId] = true
			local audioPlayer = Instance.new("AudioPlayer")
			audioPlayer.Asset = sound.SoundId
			audioPlayer.Archivable = false
			audioPlayer.Parent = folder
		end
	end

	local function alive()
		return v9 == count
	end

	local currentCamera = Workspace.CurrentCamera
	local cameraMarkerCFrame = scene.cameraMarkerCFrame
	local cFrame = currentCamera.CFrame
	local lastTime = os.clock()
	local v11 = nil
	track(RunService.RenderStepped:Connect(function()
		local focusCFrame = cFrame:Lerp(
			cameraMarkerCFrame,
			easeOutQuad(math.clamp((os.clock() - lastTime) / 0.5, 0, 1))
		)

		if v11 then
			local v13 = os.clock() - v11.startTime

			if v13 >= 3.0999999999999996 then
				currentCamera.FieldOfView = v11.startFov
				v11 = nil
			elseif v13 >= 2.8 then
				local v15 = easeOutQuad(math.clamp((v13 - 2.8) / 0.3, 0, 1))
				focusCFrame = v11.focusCFrame:Lerp(cameraMarkerCFrame, v15)
				currentCamera.FieldOfView = v11.targetFov + (v11.startFov - v11.targetFov) * v15
			elseif v13 >= 1.3 then
				focusCFrame = v11.focusCFrame
				currentCamera.FieldOfView = v11.targetFov
			else
				local v15 = easeOutQuad(math.clamp(v13 / 1.3, 0, 1))
				focusCFrame = cameraMarkerCFrame:Lerp(v11.focusCFrame, v15)
				local v16 = math.clamp(v13 / 1.3, 0, 1)
				currentCamera.FieldOfView = v11.startFov + (v11.targetFov - v11.startFov) * v16
			end
		end

		currentCamera.CFrame = focusCFrame
		currentCamera.Focus = CFrame.new(scene.anchorCFrame.Position)
	end)) -- equivalent call inferred; original call site unknown
	track(RunService.Heartbeat:Connect(function(dt)
		for k in v5 do
			if k.Parent and k:IsDescendantOf(Workspace) then
				k:StepAnimations(dt)
			else
				v5[k] = nil
			end
		end
	end)) -- equivalent call inferred; original call site unknown
	local position = scene.loserRootPart.Position
	local anchorCFrame = scene.anchorCFrame

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finishSequence(p2: number)
		local v12 = math.max(p2, v7 - os.clock(), 0)
		task.delay(v12, function()
			if v9 == count then
				fn()
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onImpact(p2: number)
		finishSequence(math.max(playEffectClone(p.explosion, position), p2 + 1.3 + 1.5 + 0.3 - os.clock(), 0)) -- equivalent call inferred; original call site unknown
	end

	local function beginFlight()
		local winnerBall = scene.winnerBall
		local v12 = scene
		local lookVector = v12.anchorCFrame.LookVector
		local v14 = v12.cameraMarkerCFrame.Position - v12.anchorCFrame.Position

		if lookVector:Dot(v14) < 0 then
			lookVector = -lookVector
		end

		local v15 = math.min(6, math.abs((lookVector:Dot(v14))) * 0.6)
		local unit = lookVector.Unit
		local pivot = winnerBall:GetPivot()
		local position2 = pivot.Position
		local rotation = pivot.Rotation
		local lastTime2 = os.clock()
		local trails = {}
		local v16 = 0
		local clone

		if p.trail and parent then
			clone = p.trail:Clone()
			setNonArchivable(clone) -- equivalent call inferred; original call site unknown
			lockParts(clone)

			for _, trail in ipairs(clone:GetDescendants()) do
				if not trail:IsA("Trail") then
					continue
				end

				table.insert(trails, trail)
				v16 = math.max(v16, trail.Lifetime)
				trail.Enabled = false
			end

			clone:PivotTo(winnerBall:GetPivot())
			clone.Parent = parent
		else
			clone = nil
		end

		local v17 = false
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finishTrail()
			if flag then
				return
			end

			flag = true

			for _, v18 in trails do
				v18.Enabled = false
			end

			if clone then
				destroyAfter(clone, v16 + 0.1) -- equivalent call inferred; original call site unknown
			end
		end

		local heartbeatConnection2 = nil
		heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			if v9 == count and winnerBall.Parent then
				local v18 = math.clamp((os.clock() - lastTime2) / 1.3, 0, 1)
				local v19 = solveBezierT(v18, 0.5, 0.9)
				local v20 = ((v19 * 3.0999999999999996 + -4.199999999999999) * v19 + 2.0999999999999996) * v19
				local _ = (v19 * 9.299999999999999 + -8.399999999999999) * v19 + 2.0999999999999996
				local v21 = math.sin(3.141592653589793 * v20)
				winnerBall:PivotTo(rotation + (position2:Lerp(position, v20) + createVector(0, 1, 0) * (v21 * 6) + unit * (v15 * v21)))

				if v18 >= 1 then
					heartbeatConnection2:Disconnect()
					finishTrail() -- equivalent call inferred; original call site unknown
					winnerBall:Destroy()
					onImpact(lastTime2) -- equivalent call inferred; original call site unknown
				elseif clone and not flag then
					clone:PivotTo(winnerBall:GetPivot())

					if not v17 then
						v17 = true

						for _, v23 in trails do
							v23.Enabled = true
						end
					end
				end
			else
				heartbeatConnection2:Disconnect()
				finishTrail() -- equivalent call inferred; original call site unknown
			end
		end)
		track(heartbeatConnection2) -- equivalent call inferred; original call site unknown
		local cframe5 = CFrame.lookAt(cameraMarkerCFrame.Position, position)
		v11 = {
			startTime = os.clock(),
			startFov = currentCamera.FieldOfView,
			targetFov = currentCamera.FieldOfView * 1,
			focusCFrame = cameraMarkerCFrame:Lerp(cframe5, 0.8)
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function beginJumpKill()
		task.delay(1, function()
			if v9 ~= count then
				return
			end

			local position2 = scene.winnerBall:GetPivot().Position
			playEffectClone(p.windup, anchorCFrame.Rotation + position2)
			task.delay(0.4, function()
				if v9 == count then
					beginFlight()
				end
			end)
		end)
	end

	local function beginKill()
		local loserBall = scene.loserBall
		playEffectClone(p.kill, loserBall:GetPivot().Position)
		local pivot = loserBall:GetPivot()
		local position2 = pivot.Position
		local v12 = 7 + math.random() * 6
		local v13 = 7 + math.random() * 6
		local lastTime2 = os.clock()
		local heartbeatConnection2 = nil
		heartbeatConnection2 = RunService.Heartbeat:Connect(function()
			if v9 ~= count or not loserBall.Parent then
				heartbeatConnection2:Disconnect()
				return
			end

			local v14 = os.clock() - lastTime2

			if v14 >= 0.5 then
				heartbeatConnection2:Disconnect()
				loserBall:PivotTo(pivot)
				loserBall:Destroy()
				playEffectClone(p.death, position2)
				beginJumpKill() -- equivalent call inferred; original call site unknown
			else
				local v15 = 0.35 * (1 - v14 / 0.5)
				local v16 = math.sin(v14 * v12 * 3.141592653589793 * 2) * v15
				local v17 = math.sin(v14 * v13 * 3.141592653589793 * 2 + 1.5707963267948966) * v15
				local vectorToWorldSpace = anchorCFrame:VectorToWorldSpace((Vector3.new(v16, v17, 0)))
				loserBall:PivotTo(pivot.Rotation + (position2 + vectorToWorldSpace))
			end
		end)
		track(heartbeatConnection2) -- equivalent call inferred; original call site unknown
	end

	task.delay(0.5, function()
		if v9 == count then
			beginKill()
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BVBVFXPreviewerGui"
screenGui.Archivable = false
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 10
local textButton = Instance.new("TextButton")
textButton.Name = "PreviewButton"
textButton.AnchorPoint = Vector2.new(0.5, 0.5)
textButton.Position = UDim2.fromScale(0.5, 0.5)
textButton.Size = UDim2.fromOffset(220, 64)
textButton.BackgroundColor3 = Color3.fromRGB(235, 64, 64)
textButton.AutoButtonColor = true
textButton.Font = Enum.Font.GothamBold
textButton.TextColor3 = Color3.new(1, 1, 1)
textButton.TextSize = 22
textButton.Text = "▶ Preview"
textButton.Visible = false
textButton.Archivable = false
textButton.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 12)
uICorner.Archivable = false
uICorner.Parent = textButton
local uIStroke = Instance.new("UIStroke")
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke.Color = Color3.new(1, 1, 1)
uIStroke.Thickness = 2
uIStroke.Archivable = false
uIStroke.Parent = textButton
local textLabel = Instance.new("TextLabel")
textLabel.Name = "FolderName"
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.new(0.5, 0, 1, 6)
textLabel.Size = UDim2.fromOffset(320, 20)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.Gotham
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextStrokeTransparency = 0.4
textLabel.TextSize = 16
textLabel.Archivable = false
textLabel.Parent = textButton
screenGui.Parent = CoreGui
local button = plugin:CreateToolbar("BVB VFX Previewer"):CreateButton(
	"Preview Toggle",
	"Turn kill-effect preview on/off (off by default)",
	"rbxassetid://95465406282583"
)
button.ClickableWhenViewportHidden = true
local flag = false
local v9 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshFromSelection()
	if not v9 or flag then
		return
	end

	local v10 = Selection:Get()
	local folder

	if #v10 == 1 then
		folder = v10[1]

		if folder:IsA("Folder") then
			local _, v11 = collectEffectSet(folder)

			if v11 == 0 then
				folder = nil
			end
		else
			folder = nil
		end
	end

	if folder then
		textLabel.Text = folder.Name
		textButton.Visible = true
	else
		textButton.Visible = false

		if parent then
			clearScene()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabled(flag2: boolean)
	if v9 == flag2 then
		return
	end

	v9 = flag2
	button:SetActive(v9)

	if v9 then
		if v9 then
			if flag then
				return
			end

			local v10 = Selection:Get()
			local folder

			if #v10 == 1 then
				folder = v10[1]

				if folder:IsA("Folder") then
					local _, v11 = collectEffectSet(folder)

					if v11 == 0 then
						folder = nil
					end
				else
					folder = nil
				end
			end

			if folder then
				textLabel.Text = folder.Name
				textButton.Visible = true
			else
				textButton.Visible = false

				if parent then
					clearScene()
				end
			end
		end
	else
		textButton.Visible = false
		clearScene()
	end
end

button.Click:Connect(function()
	setEnabled(not v9) -- equivalent call inferred; original call site unknown
end)

local function onPreviewActivated()
	if not v9 or flag then
		return
	end

	local v10 = Selection:Get()
	local folder, v11

	if #v10 == 1 then
		folder = v10[1]

		if folder:IsA("Folder") then
			local v12
			v11, v12 = collectEffectSet(folder)

			if v12 == 0 then
				folder = nil
				v11 = nil
			end
		else
			folder = nil
		end
	end

	if folder and v11 then
		flag = true
		textButton.Visible = false
		playSequence(folder.Name, v11, function()
			flag = false

			for _, connection in v6 do
				connection:Disconnect()
			end

			table.clear(v6)

			if v9 then
				if flag then
					return
				end

				local v12 = Selection:Get()
				local folder2

				if #v12 == 1 then
					folder2 = v12[1]

					if folder2:IsA("Folder") then
						local _, v13 = collectEffectSet(folder2)

						if v13 == 0 then
							folder2 = nil
						end
					else
						folder2 = nil
					end
				end

				if folder2 then
					textLabel.Text = folder2.Name
					textButton.Visible = true
				else
					textButton.Visible = false

					if parent then
						clearScene()
					end
				end
			end
		end)
	elseif v9 then
		if flag then
			return
		end

		local v12 = Selection:Get()
		local folder2

		if #v12 == 1 then
			folder2 = v12[1]

			if folder2:IsA("Folder") then
				local _, v13 = collectEffectSet(folder2)

				if v13 == 0 then
					folder2 = nil
				end
			else
				folder2 = nil
			end
		end

		if folder2 then
			textLabel.Text = folder2.Name
			textButton.Visible = true
		else
			textButton.Visible = false

			if parent then
				clearScene()
			end
		end
	end
end

textButton.Activated:Connect(onPreviewActivated)
local selectionChangedConnection = Selection.SelectionChanged:Connect(refreshFromSelection)
plugin.Unloading:Connect(function()
	selectionChangedConnection:Disconnect()
	clearScene()
	screenGui:Destroy()
	ForgeVFX.deinit()
end)
refreshFromSelection() -- equivalent call inferred; original call site unknown