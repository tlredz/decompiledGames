local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = {
	DoorNamePrefix = "TrickOrTreatDoor",
	Range = 45,
	DrawRange = 300,
	FlickerDuration = 0.75,
	IdleMoodInterval = 0.5,
	PixelsPerStud = 100,
	MinCameraDistance = 1.5,
	ViewportFovMin = 1,
	ViewportFovMax = 120,
	DefaultEmergeDepth = 6,
	GlowEmergeDepth = 4,
	DefaultEmergeTime = 1.6,
	DefaultRetreatTime = 1,
	SettleTime = 0.3,
	CompletionTimeout = 4,
	FollowParts = {
		Chain = "Torso",
		DyleChain = "Torso"
	},
	SmokeTexture = "rbxasset://textures/particles/smoke_main.dds",
	FogPresets = {
		Light = 0.6,
		Normal = 1,
		Heavy = 1.7
	},
	FogBurst = 26,
	PreloadRetries = 3,
	WarmFrames = 8,
	Moods = {
		Neutral = {
			primary = Color3.fromRGB(255, 140, 40),
			secondary = Color3.fromRGB(255, 215, 110),
			ambient = Color3.fromRGB(70, 28, 8)
		},
		Treat = {
			primary = Color3.fromRGB(255, 170, 50),
			secondary = Color3.fromRGB(255, 225, 140),
			ambient = Color3.fromRGB(80, 40, 10)
		},
		Trick = {
			primary = Color3.fromRGB(255, 45, 30),
			secondary = Color3.fromRGB(255, 120, 60),
			ambient = Color3.fromRGB(70, 6, 4)
		}
	},
	DoorHaze = true
}
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local v2 = {}
local random = Random.new()

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function smoothstep(p)
	return p * p * (3 - 2 * p)
end

local function setLocalVisible(folder, p)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, instance in ipairs(descendants) do
		if instance:IsA("BasePart") then
			instance.LocalTransparencyModifier = p and 0 or 1
		elseif instance:IsA("Decal") then
			if instance:GetAttribute("PortalBaseT") == nil then
				instance:SetAttribute("PortalBaseT", instance.Transparency)
			end

			instance.Transparency = not p and 1 or instance:GetAttribute("PortalBaseT") or 1
		end
	end
end

local function setPartVisible(instance, p)
	instance.LocalTransparencyModifier = p and 0 or 1

	for _, decal in ipairs(instance:GetChildren()) do
		if not decal:IsA("Decal") then
			continue
		end

		if decal:GetAttribute("PortalBaseT") == nil then
			decal:SetAttribute("PortalBaseT", decal.Transparency)
		end

		decal.Transparency = not p and 1 or decal:GetAttribute("PortalBaseT") or 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pivotOf(model)
	return model:IsA("Model") and model:GetPivot() or model.CFrame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPivot(model, cFrame)
	if model:IsA("Model") then
		model:PivotTo(cFrame)
	else
		model.CFrame = cFrame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRig(model)
	return model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function partCount(part)
	local v3 = part:IsA("BasePart") and 1 or 0

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			v3 += 1
		end
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isComplete(instance)
	local portalPartCount = instance:GetAttribute("PortalPartCount")
	return portalPartCount == nil or portalPartCount <= partCount(instance)
end

local function loadClip(folder, p)
	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local v3 = nil

	for _, animation in ipairs(folder:GetDescendants()) do
		if not (animation:IsA("Animation") and animation.Name == p) then
			continue
		end

		v3 = animation
		break
	end

	if not v3 then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local success, result = pcall(function()
		local track = animator:LoadAnimation(v3)
		track.Looped = true
		return track
	end)
	return success and result or nil
end

local function playClip(p, p2)
	local v3 = loadClip(p, p2)

	if v3 then
		v3:Play()
	end

	return v3
end

local function isPosing(data)
	local isPlaying = data.IsPlaying

	if isPlaying then
		if data.Length > 0 and data.TimePosition > 0 and data.WeightTarget > 0 then
			isPlaying = data.WeightCurrent >= data.WeightTarget * 0.99
		else
			isPlaying = false
		end
	end

	return isPlaying
end

local function rigPosed(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return true
	end

	for _, v3 in ipairs(animator:GetPlayingAnimationTracks()) do
		local isPlaying = v3.IsPlaying

		if isPlaying then
			if v3.Length > 0 and v3.TimePosition > 0 and v3.WeightTarget > 0 then
				isPlaying = v3.WeightCurrent >= v3.WeightTarget * 0.99
			else
				isPlaying = false
			end
		end

		if isPlaying then
			return true
		end
	end

	return false
end

local function displayCopy(instance)
	local clone = instance:Clone()
	local rig = isRig(clone) -- equivalent call inferred; original call site unknown
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)

	for _, instance2 in ipairs(descendants) do
		if instance2:IsA("LuaSourceContainer") then
			instance2:Destroy()
		elseif instance2:IsA("BasePart") then
			instance2.CanCollide = false
			instance2.CanQuery = false
			instance2.CanTouch = false
			instance2.Anchored = not rig or instance2.Name == "HumanoidRootPart" or instance2.Name == "RootPart"
		end
	end

	return clone
end

local object = setmetatable({}, {
	__mode = "k"
})
local v3 = {}
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function warmNext()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "PortalWarmup"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

		while #v3 > 0 do
			local v4 = table.remove(v3, 1)

			if not v4.Parent then
				continue
			end

			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Size = UDim2.fromOffset(1, 1)
			viewportFrame.BackgroundTransparency = 1
			local camera = Instance.new("Camera")
			camera.Parent = viewportFrame
			viewportFrame.CurrentCamera = camera
			local clone = v4:Clone()

			for _, luaSourceContainer in ipairs(clone:GetDescendants()) do
				if luaSourceContainer:IsA("LuaSourceContainer") then
					luaSourceContainer:Destroy()
				end
			end

			clone.Parent = viewportFrame

			if clone:IsA("Model") then
				local boundingBox, v5 = clone:GetBoundingBox()
				camera.CFrame = CFrame.lookAt(
					boundingBox.Position + Vector3.new(0, 0, v5.Magnitude),
					boundingBox.Position
				)
			end

			viewportFrame.Parent = screenGui

			for _ = 1, v.WarmFrames do
				RunService.RenderStepped:Wait()
			end

			viewportFrame:Destroy()
		end

		screenGui:Destroy()
		flag = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preloadModel(folder)
	if object[folder] then
		return
	end

	object[folder] = true
	task.spawn(function()
		local descendants = folder:GetDescendants()
		table.insert(descendants, folder)

		for i = 1, v.PreloadRetries do
			local v4 = {}
			pcall(function()
				ContentProvider:PreloadAsync(descendants, function(p, p2)
					if p2 == Enum.AssetFetchStatus.Failure or p2 == Enum.AssetFetchStatus.TimedOut then
						table.insert(v4, p)
					end
				end)
			end)

			if #v4 == 0 then
				break
			end

			descendants = v4
			task.wait(i * 2)
		end

		table.insert(v3, folder)
		warmNext() -- equivalent call inferred; original call site unknown
	end)
end

local function preloadFolder(childName)
	task.spawn(function()
		local child = ReplicatedStorage:WaitForChild(childName, 60)

		if not child then
			return
		end

		for _, child2 in ipairs(child:GetChildren()) do
			preloadModel(child2) -- equivalent call inferred; original call site unknown
		end

		child.ChildAdded:Connect(preloadModel)
	end)
end

local v4 = "PortalScenes"
task.spawn(function()
	local child = ReplicatedStorage:WaitForChild(v4, 60)

	if not child then
		return
	end

	for _, child2 in ipairs(child:GetChildren()) do
		preloadModel(child2) -- equivalent call inferred; original call site unknown
	end

	child.ChildAdded:Connect(preloadModel)
end)
local v5 = "PortalPreload"
task.spawn(function()
	local child = ReplicatedStorage:WaitForChild(v5, 60)

	if not child then
		return
	end

	for _, child2 in ipairs(child:GetChildren()) do
		preloadModel(child2) -- equivalent call inferred; original call site unknown
	end

	child.ChildAdded:Connect(preloadModel)
end)
task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({ v.SmokeTexture })
	end)
end)

local function actorTemplate(childName)
	local portalPreload = ReplicatedStorage:FindFirstChild("PortalPreload")
	local model = portalPreload and childName and portalPreload:FindFirstChild(childName)

	if not (model and model:IsA("Model") and model) then
		model = nil
	end

	return model
end

local function readDoorConfig(instance)
	local portalConfig = instance:FindFirstChild("PortalConfig")
	local moods = {}

	for k, mood in pairs(v.Moods) do
		moods[k] = {
			primary = portalConfig and portalConfig:GetAttribute(k .. "Primary") or mood.primary,
			secondary = portalConfig and portalConfig:GetAttribute(k .. "Secondary") or mood.secondary,
			ambient = portalConfig and portalConfig:GetAttribute(k .. "Ambient") or mood.ambient
		}
	end

	return {
		range = portalConfig and portalConfig:GetAttribute("Range") or v.Range,
		drawRange = portalConfig and portalConfig:GetAttribute("DrawRange") or v.DrawRange,
		flickerDuration = portalConfig and portalConfig:GetAttribute("FlickerDuration") or v.FlickerDuration,
		moods = moods
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roomToWorld(data, p)
	return data.back.CFrame * cframe * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function worldToRoom(p, p2)
	return (p.back.CFrame * cframe):ToObjectSpace(p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCameraInFront(p, p2)
	return p.back.CFrame:PointToObjectSpace(p2.Position).Z < 0
end

local function glassSides(data, size, p, cameraInFront)
	local v6 = 0.5 * (math.abs(data.XVector.Z) * size.X + math.abs(data.YVector.Z) * size.Y + math.abs(data.ZVector.Z) * size.Z)
	local v7 = data.Position.Z + v6 < 0
	return v7, data.Position.Z - v6 >= 0 or not v7 and p and cameraInFront
end

local function emitter(items, parent)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = v.SmokeTexture
	particleEmitter.LightInfluence = 0
	particleEmitter.Enabled = false

	for k, item in pairs(items) do
		particleEmitter[k] = item
	end

	particleEmitter:SetAttribute("PortalGenerated", true)
	particleEmitter.Parent = parent
	return particleEmitter
end

local function generateWorldFX(back)
	emitter({
		Name = "DoorMist",
		Rate = 11,
		Lifetime = NumberRange.new(3.5, 5.5),
		Speed = NumberRange.new(0.3, 0.8),
		SpreadAngle = Vector2.new(20, 20),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-12, 12),
		Drag = 1.2,
		LightEmission = 0.5,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3.5),
			NumberSequenceKeypoint.new(0.5, 7),
			NumberSequenceKeypoint.new(1, 9)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		}),
		EmissionDirection = Enum.NormalId.Front,
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	}, back)
	local attachment = Instance.new("Attachment")
	attachment.Name = "Threshold"
	attachment.CFrame = CFrame.new(0, -back.Size.Y / 2 + 0.4, -0.8)
	attachment:SetAttribute("PortalGenerated", true)
	attachment.Parent = back
	emitter({
		Name = "FloorFog",
		Rate = 14,
		Lifetime = NumberRange.new(4, 6.5),
		Speed = NumberRange.new(1.2, 2.4),
		SpreadAngle = Vector2.new(55, 8),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-6, 6),
		Drag = 0.9,
		Acceleration = createVector(0, -0.15, 0),
		LightEmission = 0.4,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(0.6, 8),
			NumberSequenceKeypoint.new(1, 11)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0.45),
			NumberSequenceKeypoint.new(1, 1)
		}),
		EmissionDirection = Enum.NormalId.Front
	}, attachment)
	emitter({
		Name = "FogBurst",
		Rate = 0,
		Lifetime = NumberRange.new(3, 5),
		Speed = NumberRange.new(7, 12),
		SpreadAngle = Vector2.new(40, 18),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-20, 20),
		Drag = 2.6,
		Acceleration = createVector(0, -0.4, 0),
		LightEmission = 0.45,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 3),
			NumberSequenceKeypoint.new(0.4, 9),
			NumberSequenceKeypoint.new(1, 14)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(0.15, 0.38),
			NumberSequenceKeypoint.new(1, 1)
		}),
		EmissionDirection = Enum.NormalId.Front
	}, attachment):SetAttribute("BurstCount", v.FogBurst)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "Front"
	attachment2.CFrame = CFrame.new(0, 0, -0.6)
	attachment2:SetAttribute("PortalGenerated", true)
	attachment2.Parent = back
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "PortalLight"
	pointLight.Range = 16
	pointLight.Brightness = 2
	pointLight.Shadows = true
	pointLight.Enabled = false
	pointLight:SetAttribute("PortalGenerated", true)
	pointLight.Parent = attachment2

	if not v.DoorHaze then
		return
	end

	emitter({
		Name = "DoorHaze",
		Rate = 2.5,
		Lifetime = NumberRange.new(7, 10),
		Speed = NumberRange.new(0.6, 1.4),
		SpreadAngle = Vector2.new(35, 25),
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-4, 4),
		Drag = 0.35,
		LightEmission = 0.8,
		Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 8),
			NumberSequenceKeypoint.new(0.5, 16),
			NumberSequenceKeypoint.new(1, 22)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.35, 0.86),
			NumberSequenceKeypoint.new(1, 1)
		}),
		EmissionDirection = Enum.NormalId.Front,
		Shape = Enum.ParticleEmitterShape.Box,
		ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	}, back)
	local pointLight2 = Instance.new("PointLight")
	pointLight2.Name = "HazeLight"
	pointLight2.Range = 28
	pointLight2.Brightness = 0.7
	pointLight2.Shadows = false
	pointLight2.Enabled = false
	pointLight2:SetAttribute("PortalGenerated", true)
	pointLight2.Parent = attachment2
end

local function ensureWorldFX(state)
	if state.fxEmitters then
		return
	end

	local back = state.back

	for _, descendant in ipairs(back:GetDescendants()) do
		if descendant:GetAttribute("PortalGenerated") then
			descendant:Destroy()
		end
	end

	if not back:GetAttribute("AuthoredFX") then
		generateWorldFX(back)
	end

	state.fxEmitters = {}
	state.fxLights = {}
	state.fxBursts = {}

	for _, descendant in ipairs(back:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") and descendant:GetAttribute("BurstCount") then
			table.insert(state.fxBursts, descendant)
		elseif descendant:IsA("ParticleEmitter") then
			if descendant:GetAttribute("BaseRate") == nil then
				descendant:SetAttribute("BaseRate", descendant.Rate)
			end

			table.insert(state.fxEmitters, descendant)
		elseif descendant:IsA("Light") then
			table.insert(state.fxLights, descendant)

			if descendant:GetAttribute("BaseBrightness") == nil then
				descendant:SetAttribute("BaseBrightness", descendant.Brightness)
			end
		end
	end
end

local function addMistCards(p, worldModel, p2, p3, p4, transparency)
	for i = 1, p2 do
		local v6 = p3 + (p4 - p3) * ((i - 1) / math.max(p2 - 1, 1))
		local part = Instance.new("Part")
		part.Name = "PortalMist"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Size = createVector(30, 26, 0.05)
		part.CFrame = CFrame.new(0, 0, -v6)
		part.Transparency = transparency
		part.Parent = worldModel
		table.insert(p.mist, {
			part = part,
			home = part.CFrame,
			base = transparency,
			phase = random:NextNumber(0, 6.283185307179586),
			mix = (i - 1) / math.max(p2 - 1, 1)
		})
	end
end

local function buildScene(state, model)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local isGlow = model == nil
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "PortalGui_" .. state.door.Name .. "_" .. (not model and "Glow" or model.Name or "Glow")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = v.PixelsPerStud
	surfaceGui.LightInfluence = 0
	surfaceGui.Brightness = 1.4
	surfaceGui.ClipsDescendants = true
	surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	surfaceGui.Enabled = false
	surfaceGui.Adornee = state.back
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Clip"
	frame.BackgroundColor3 = Color3.fromRGB(6, 3, 10)
	frame.BackgroundTransparency = isGlow and 1 or 0
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.ClipsDescendants = true
	frame.Parent = surfaceGui
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "Scene"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Ambient = isGlow and Color3.new() or Color3.fromRGB(215, 205, 225)
	viewportFrame.LightColor = isGlow and Color3.new() or Color3.new(1, 1, 1)
	viewportFrame.LightDirection = createVector(0.3, -0.7, -1)
	viewportFrame.Parent = frame
	local camera = Instance.new("Camera")
	camera.FieldOfView = 70
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	local v7 = {
		name = not model and "Glow" or model.Name or "Glow",
		isGlow = isGlow,
		gui = surfaceGui,
		viewport = viewportFrame,
		camera = camera,
		world = worldModel,
		emergeDepth = isGlow and v.GlowEmergeDepth or model:GetAttribute("EmergeDepth") or v.DefaultEmergeDepth,
		moodPrimary = {},
		moodSecondary = {},
		blinkers = {},
		movers = {},
		mist = {}
	}

	if isGlow then
		addMistCards(v7, worldModel, 1, 1.5, 1.5, 0.9)
		addMistCards(v7, worldModel, 5, v.GlowEmergeDepth + 0.8, 16, 0.72)
		return v7
	else
		local folder = displayCopy(model)

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("LayerCollector") or descendant:IsA("ProximityPrompt") then
				descendant:Destroy()
			end
		end

		local opening = folder:FindFirstChild("Opening", true)

		if opening and opening:IsA("BasePart") then
			opening.Transparency = 1
			folder.WorldPivot = opening.CFrame
		else
			warn("[TrickOrTreatPortal] scene " .. model.Name .. " has no Opening part; using its pivot")
		end

		folder:PivotTo(cframe)
		folder.Parent = worldModel
		local fogDensity = model:GetAttribute("FogDensity")
		local v8 = fogDensity == nil and 1 or fogDensity

		if v8 > 0 then
			addMistCards(v7, worldModel, 4, 2, 18, math.clamp(1 - 0.08 * v8, 0.6, 0.97))
		end

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				local mood = descendant:GetAttribute("Mood")

				if mood == "Primary" then
					table.insert(v7.moodPrimary, descendant)
				elseif mood == "Secondary" then
					table.insert(v7.moodSecondary, descendant)
				end

				if descendant:GetAttribute("Blink") ~= nil then
					table.insert(v7.blinkers, {
						part = descendant,
						phase = tonumber(descendant:GetAttribute("Blink")) or 0
					})
				end
			end

			if descendant:IsA("BasePart") or descendant:IsA("Model") then
				local spin = descendant:GetAttribute("Spin")
				local bob = descendant:GetAttribute("Bob")
				local glide = descendant:GetAttribute("Glide")

				if spin or bob or glide then
					table.insert(v7.movers, {
						inst = descendant,
						home = pivotOf(descendant),
						spin = typeof(spin) == "Vector3" and spin or createVector(0, 0, 0),
						bob = tonumber(bob) or 0,
						glide = tonumber(glide) or 0,
						phase = random:NextNumber(0, 6.283185307179586)
					})
				end
			end

			if not isRig(descendant) then
				continue
			end

			local clip = descendant:GetAttribute("Clip") or "Idle"
			local v9 = loadClip(descendant, clip)

			if v9 then
				v9:Play()
			end
		end

		return v7
	end
end

local function project(p, active, cFrame)
	local X = p.back.Size.X
	local Y = p.back.Size.Y
	local pointToObjectSpace = p.back.CFrame:PointToObjectSpace(cFrame.Position)
	local v6 = math.max(-pointToObjectSpace.Z, v.MinCameraDistance)
	local vector2 = Vector2.new(0.5 - pointToObjectSpace.X / X, 0.5 - pointToObjectSpace.Y / Y)
	local fieldOfView = math.clamp(
		math.deg(math.atan(math.max(X / 2 + math.abs(pointToObjectSpace.X), Y / 2 + math.abs(pointToObjectSpace.Y)) * 1.08 / v6) * 2),
		v.ViewportFovMin,
		v.ViewportFovMax
	)
	local v8 = v6 * math.tan((math.rad(fieldOfView / 2)))
	active.camera.FieldOfView = fieldOfView
	active.camera.CFrame = CFrame.new(-pointToObjectSpace.X, pointToObjectSpace.Y, v6)
	active.viewport.Size = UDim2.fromScale(v8 * 2 / X, v8 * 2 / Y)
	active.viewport.Position = UDim2.fromScale(vector2.X, vector2.Y)
end

local function animateScene(active, now)
	for _, mover in ipairs(active.movers) do
		local v6 = math.sin(now * 1.6 + mover.phase) * mover.bob
		local v7 = (math.sin(now * 0.35 + mover.phase) * 0.5 + 0.5) * mover.glide
		setPivot(
			mover.inst,
			mover.home * CFrame.new(0, v6, v7) * CFrame.Angles(
				now * mover.spin.X,
				now * mover.spin.Y,
				now * mover.spin.Z
			)
		) -- equivalent call inferred; original call site unknown
	end

	for _, blinker in ipairs(active.blinkers) do
		blinker.part.Transparency = math.sin(now * 5 + blinker.phase) > 0.3 and 0 or 0.85
	end

	for _, v6 in ipairs(active.mist) do
		local cframe2 = CFrame.new(math.sin(now * 0.21 + v6.phase) * 2.5, math.cos(now * 0.17 + v6.phase) * 1.2, 0)
		v6.part.CFrame = v6.home * cframe2
		v6.part.Transparency = math.clamp(v6.base + math.sin(now * 0.6 + v6.phase) * 0.06, 0, 0.98)
	end
end

local function selectScene(state)
	local portalScene = state.door:GetAttribute("PortalScene") or "Glow"
	local model

	if portalScene == "Glow" then
		model = nil
	else
		local portalScenes = ReplicatedStorage:FindFirstChild("PortalScenes")
		model = portalScenes and portalScenes:FindFirstChild(portalScene)

		if not (model and model:IsA("Model")) then
			warn("[TrickOrTreatPortal] scene '" .. tostring(portalScene) .. "' not in ReplicatedStorage.PortalScenes; using Glow")
			portalScene = "Glow"
			model = nil
		end
	end

	local scene = state.scenes[portalScene]

	if not scene then
		if model and not object[model] then
			object[model] = true
			task.spawn(function()
				local descendants = model:GetDescendants()
				table.insert(descendants, model)

				for i = 1, v.PreloadRetries do
					local v6 = {}
					pcall(function()
						ContentProvider:PreloadAsync(descendants, function(p, p2)
							if p2 == Enum.AssetFetchStatus.Failure or p2 == Enum.AssetFetchStatus.TimedOut then
								table.insert(v6, p)
							end
						end)
					end)

					if #v6 == 0 then
						break
					end

					descendants = v6
					task.wait(i * 2)
				end

				table.insert(v3, model)
				warmNext() -- equivalent call inferred; original call site unknown
			end)
		end

		scene = buildScene(state, model)
		state.scenes[portalScene] = scene
	end

	state.active = scene
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fogScale(p)
	return v.FogPresets[p.door:GetAttribute("PortalFog")] or v.FogPresets.Normal
end

local function burstFog(p)
	local v6 = fogScale(p) -- equivalent call inferred; original call site unknown

	for _, fxBurst in ipairs(p.fxBursts) do
		fxBurst:Emit((math.floor((fxBurst:GetAttribute("BurstCount") or v.FogBurst) * v6 + 0.5)))
	end
end

local function setWorldFX(state, p)
	local worldFxScale = fogScale(state) -- equivalent call inferred; original call site unknown

	if state.worldFxOn == p and state.worldFxScale == worldFxScale then
		return
	end

	state.worldFxOn = p
	state.worldFxScale = worldFxScale

	for _, fxEmitter in ipairs(state.fxEmitters) do
		fxEmitter.Rate = (fxEmitter:GetAttribute("BaseRate") or fxEmitter.Rate) * worldFxScale
		fxEmitter.Enabled = p
	end

	for _, fxLight in ipairs(state.fxLights) do
		fxLight.Enabled = p
	end
end

local function setFrameGlow(data, p)
	local enabled = p and data.door:GetAttribute("TrickOrTreatSpent") ~= true

	for _, beam in ipairs(data.beams) do
		beam.Enabled = enabled
	end

	for _, frameLight in ipairs(data.frameLights) do
		frameLight.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flickerIn(p)
	task.spawn(function()
		local flickerDuration = p.config.flickerDuration
		local total = 0

		while total < flickerDuration and p.inRange do
			setFrameGlow(p, random:NextNumber() < 0.25 + total / flickerDuration * 0.7)
			local number = random:NextNumber(0.03, 0.09)
			task.wait(number)
			total += number
		end

		setFrameGlow(p, p.inRange)
	end)
end

local function pulseLevel(p, p2)
	if p == "Throb" then
		local v6 = math.sin(p2 * 2.6) * 0.5 + 0.5
		return v6 * v6, math.max(0, (math.sin(p2 * 0.8))) ^ 8
	elseif p == "Heartbeat" then
		local v6 = p2 % 1.1
		return math.min(1, math.exp(-((v6 - 0.05) / 0.07) ^ 2) + math.exp(-((v6 - 0.3) / 0.08) ^ 2) * 0.7), 0
	end

	if p ~= "Flicker" then
		return math.sin(p2 * 0.9) * 0.5 + 0.5, math.max(0, (math.sin(p2 * 0.31))) ^ 6
	end

	if math.noise(p2 * 7.3, 0.5) < -0.22 then
		return 0.04, 0
	end

	return 0.7 + 0.3 * math.noise(p2 * 23.1, 3.7), 0
end

local function applyMood(state, p, now, p2)
	local door = state.door
	local v6 = state.config.moods[door:GetAttribute("PortalMood")] or state.config.moods.Neutral
	local portalPrimary = door:GetAttribute("PortalPrimary") or v6.primary
	local portalSecondary = door:GetAttribute("PortalSecondary") or v6.secondary
	local portalAmbient = door:GetAttribute("PortalAmbient") or v6.ambient
	local v7 = math.min(1, p * 4)
	state.primary = state.primary:Lerp(portalPrimary, v7)
	state.secondary = state.secondary:Lerp(portalSecondary, v7)
	state.ambient = state.ambient:Lerp(portalAmbient, v7)
	local primary = state.primary
	local secondary = state.secondary
	local ambient = state.ambient
	local v9, v10 = pulseLevel(not p2 and "Calm" or door:GetAttribute("PortalPulse") or "Calm", now)

	for _, beam in ipairs(state.beams) do
		beam.Color = ColorSequence.new(ambient:Lerp(primary, 0.55 + 0.45 * v9), secondary)
	end

	for _, frameLight in ipairs(state.frameLights) do
		frameLight.Color = primary
	end

	local v11

	if door:GetAttribute("PortalFxFrom") == nil then
		v11 = false
	else
		v11 = door:GetAttribute("PortalFxTo") ~= nil
	end

	local portalFxFrom = v11 and door:GetAttribute("PortalFxFrom") or primary:Lerp(secondary, 0.3)
	local portalFxTo = v11 and door:GetAttribute("PortalFxTo") or ambient:Lerp(primary, 0.4)
	state.fxFrom = (state.fxFrom or portalFxFrom):Lerp(portalFxFrom, v7)
	state.fxTo = (state.fxTo or portalFxTo):Lerp(portalFxTo, v7)
	local colorSequence = ColorSequence.new(state.fxFrom, state.fxTo)

	for _, list in ipairs({ state.fxEmitters, state.fxBursts }) do
		for _, v12 in ipairs(list) do
			if not v12:GetAttribute("KeepColor") then
				v12.Color = colorSequence
			end
		end
	end

	for _, fxLight in ipairs(state.fxLights) do
		if not fxLight:GetAttribute("KeepColor") then
			fxLight.Color = primary
		end

		fxLight.Brightness = (fxLight:GetAttribute("BaseBrightness") or 2) * (0.3 + v9 * 1.1 + v10 * 0.7)
	end

	local active = state.active

	for _, v12 in ipairs(active.mist) do
		v12.part.Color = active.isGlow and primary:Lerp(ambient, v12.mix * 0.55) or ambient:Lerp(
			primary,
			0.35 + v12.mix * 0.3
		)
	end

	if active.isGlow then
		if p2 then
			state.back.Transparency = 0
			state.back.Color = ambient:Lerp(primary, 0.35 + v9 * 0.55 + v10 * 0.1)
		else
			state.back.Color = ambient
			state.back.Transparency = 0
		end
	else
		state.back.Color = Color3.new()
		state.back.Transparency = 0

		for _, v12 in ipairs(active.moodPrimary) do
			v12.Color = primary
		end

		for _, v12 in ipairs(active.moodSecondary) do
			v12.Color = secondary
		end

		active.viewport.LightColor = primary:Lerp(Color3.new(1, 1, 1), 0.45 + 0.25 * v9)
		active.viewport.Ambient = ambient:Lerp(Color3.new(1, 1, 1), 0.6 + 0.2 * v9)
	end
end

local function copySource(instance)
	local portalActor = instance:GetAttribute("PortalActor")
	local portalPreload = ReplicatedStorage:FindFirstChild("PortalPreload")
	local model = portalPreload and portalActor and portalPreload:FindFirstChild(portalActor)

	if not (model and model:IsA("Model") and model) then
		model = nil
	end

	return model or instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyCopies(walk)
	if walk.viewCopy then
		walk.viewCopy:Destroy()
		walk.viewCopy = nil
	end

	if walk.worldCopy then
		walk.worldCopy:Destroy()
		walk.worldCopy = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holdHidden(p, child)
	if p.hideConnections[child] then
		return
	end

	setLocalVisible(child, false)
	p.hideConnections[child] = child.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 1
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseHidden(data, k)
	local hideConnection = data.hideConnections[k]

	if hideConnection then
		hideConnection:Disconnect()
		data.hideConnections[k] = nil
	end

	if k.Parent then
		setLocalVisible(k, true)
	end
end

local function makeCopies(_, state, model)
	state.viewCopy = displayCopy(model)
	state.viewCopy:SetAttribute("PortalCopyOf", state.real.Name)
	state.viewCopy.Parent = state.world
	state.worldCopy = displayCopy(model)
	state.worldCopy:SetAttribute("PortalCopyOf", state.real.Name)
	setLocalVisible(state.worldCopy, false)
	state.worldCopy.Parent = workspace
	local descendants = state.viewCopy:GetDescendants()
	local descendants2 = state.worldCopy:GetDescendants()
	table.insert(descendants, 1, state.viewCopy)
	table.insert(descendants2, 1, state.worldCopy)
	state.partPairs = {}
	local v6 = {}

	for i, part in ipairs(descendants2) do
		local part2 = descendants[i]

		if not (part2 and part:IsA("BasePart") and part2:IsA("BasePart")) then
			continue
		end

		local v7 = {
			view = part2,
			world = part
		}
		table.insert(state.partPairs, v7)
		v6[part.Name] = v6[part.Name] or v7
	end

	for _, partPair in ipairs(state.partPairs) do
		local followPart = v.FollowParts[partPair.world.Name]
		local leader

		if followPart then
			leader = v6[followPart] or nil
		end

		partPair.leader = leader
	end

	state.clips = {}

	local function load(p, p2)
		local v7 = loadClip(p, p2)

		if v7 then
			table.insert(state.clips, v7)
		end

		return v7
	end

	if isRig(model) then
		local viewIdle = loadClip(state.viewCopy, "Idle")

		if viewIdle then
			table.insert(state.clips, viewIdle)
		end

		state.viewIdle = viewIdle
		local viewWalk = loadClip(state.viewCopy, "Walk")

		if viewWalk then
			table.insert(state.clips, viewWalk)
		end

		state.viewWalk = viewWalk
		local worldWalk = loadClip(state.worldCopy, "Walk")

		if worldWalk then
			table.insert(state.clips, worldWalk)
		end

		state.worldWalk = worldWalk
		local worldIdle = loadClip(state.worldCopy, "Idle")

		if worldIdle then
			table.insert(state.clips, worldIdle)
		end

		state.worldIdle = worldIdle
	end
end

local function copiesPosed(walk)
	local v6 = false

	for _, clip in ipairs(walk.clips) do
		if clip.Length <= 0 then
			return false
		end

		if not clip.IsPlaying then
			continue
		end

		v6 = true
		local isPlaying = clip.IsPlaying

		if isPlaying then
			if clip.Length > 0 and clip.TimePosition > 0 and clip.WeightTarget > 0 then
				isPlaying = clip.WeightCurrent >= clip.WeightTarget * 0.99
			else
				isPlaying = false
			end
		end

		if not isPlaying then
			return false
		end
	end

	return v6 or #walk.clips == 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showCopies(walk)
	local v6 = walk.from.Position.Z < 0
	setLocalVisible(walk.viewCopy, v6)
	setLocalVisible(walk.worldCopy, not v6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function beginWalking(state, startedAt)
	state.startedAt = startedAt

	if state.viewIdle then
		state.viewIdle:Stop(0.15)
	end

	if state.viewWalk then
		state.viewWalk:Play()
	end

	if state.worldWalk then
		state.worldWalk:Play()
	end
end

local function settleIntoReal(walk, instance, settleUntil)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		walk.settleUntil = settleUntil
		return
	end

	local followers = {}

	for _, source in ipairs(animator:GetPlayingAnimationTracks()) do
		if not (source.Animation and source.WeightTarget > 0) then
			continue
		end

		for _, v8 in ipairs({ walk.viewCopy, walk.worldCopy }) do
			local humanoid2 = v8:FindFirstChildOfClass("Humanoid")
			local animator2 = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")
			local animator3 = animator2
			local v9 = source
			local success, result = pcall(function()
				return animator3 and animator3:LoadAnimation(v9.Animation)
			end)

			if not (success and result) then
				continue
			end

			result.Looped = source.Looped
			result.Priority = source.Priority
			result:Play(v.SettleTime, source.WeightTarget, source.Speed)
			table.insert(followers, {
				track = result,
				source = source
			})
		end
	end

	if #followers == 0 then
		return
	end

	for _, clip in ipairs(walk.clips) do
		if clip.IsPlaying then
			clip:Stop(v.SettleTime)
		end
	end

	walk.followers = followers
	walk.settleUntil = settleUntil + v.SettleTime
end

local function followRealClocks(walk)
	for _, v6 in ipairs(walk.followers or {}) do
		if v6.track.Length > 0 and v6.source.IsPlaying then
			v6.track.TimePosition = v6.source.TimePosition
		end
	end
end

local function startWalk(data, child, reverse, p2)
	local walk = data.walks[child]

	if walk then
		destroyCopies(walk) -- equivalent call inferred; original call site unknown
	end

	if not (reverse or data.hideConnections[child]) then
		setLocalVisible(child, false)
		data.hideConnections[child] = child.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1
			end
		end)
	end

	local portalActor = child:GetAttribute("PortalActor")
	local portalPreload = ReplicatedStorage:FindFirstChild("PortalPreload")
	local model = portalPreload and portalActor and portalPreload:FindFirstChild(portalActor)

	if not (model and model:IsA("Model") and model) then
		model = nil
	end

	local v6 = model or child

	if v6 == child then
		local portalPartCount = child:GetAttribute("PortalPartCount")

		if portalPartCount ~= nil and not (portalPartCount <= partCount(child)) then
			local v7 = os.clock() + v.CompletionTimeout

			while true do
				local portalPartCount2 = child:GetAttribute("PortalPartCount")

				if portalPartCount2 == nil or portalPartCount2 <= partCount(child) or not (child.Parent and os.clock() < v7) then
					break
				end

				task.wait()
			end
		end
	end

	local active = data.active
	local v7 = pivotOf(child) -- equivalent call inferred; original call site unknown
	local to = worldToRoom(data, v7) -- equivalent call inferred; original call site unknown
	local v9 = CFrame.new(to.Position.X, to.Position.Y, -active.emergeDepth) * to.Rotation
	local door = data.door
	local v10 = {
		real = child,
		reverse = reverse,
		world = active.world,
		from = 0,
		to = 0,
		duration = 0,
		createdAt = 0
	}
	local from

	if reverse then
		from = to * cframe or v9
	else
		from = v9
	end

	v10.from = from

	if reverse then
		to = v9 * cframe or to
	end

	v10.to = to
	v10.duration = reverse and (door:GetAttribute("PortalRetreatTime") or v.DefaultRetreatTime) or door:GetAttribute("PortalEmergeTime") or v.DefaultEmergeTime
	v10.createdAt = os.clock()
	makeCopies(data, v10, v6)
	setPivot(v10.viewCopy, v10.from) -- equivalent call inferred; original call site unknown
	local worldCopy = v10.worldCopy
	local cFrame = roomToWorld(data, v10.from) -- equivalent call inferred; original call site unknown
	setPivot(worldCopy, cFrame) -- equivalent call inferred; original call site unknown
	setLocalVisible(v10.viewCopy, false)
	data.walks[child] = v10

	if reverse or p2 then
		beginWalking(v10, os.clock()) -- equivalent call inferred; original call site unknown
	elseif v10.viewIdle then
		v10.viewIdle:Play()
	end
end

local function tickWalks(data, now, openNow, cFrame)
	local cameraInFront = isCameraInFront(data, cFrame) -- equivalent call inferred; original call site unknown

	for k, walk in pairs(data.walks) do
		if walk.viewCopy and walk.viewCopy.Parent ~= data.active.world then
			walk.viewCopy.Parent = data.active.world
		end

		if k.Parent or walk.reverse then
			if not walk.posed then
				if copiesPosed(walk) or now - walk.createdAt > v.CompletionTimeout then
					walk.posed = true

					if walk.reverse and not data.hideConnections[k] then
						setLocalVisible(k, false)
						data.hideConnections[k] = k.DescendantAdded:Connect(function(part)
							if part:IsA("BasePart") then
								part.LocalTransparencyModifier = 1
							end
						end)
					end

					showCopies(walk) -- equivalent call inferred; original call site unknown
				else
					if walk.reverse and not openNow then
						destroyCopies(walk) -- equivalent call inferred; original call site unknown
						data.walks[k] = nil
					end

					continue
				end
			end

			if not walk.startedAt then
				if not openNow then
					continue
				end

				beginWalking(walk, now) -- equivalent call inferred; original call site unknown
			end

			local v6 = now - walk.startedAt
			local v7 = math.clamp(v6 / walk.duration, 0, 1)
			local v8

			if walk.reverse then
				local magnitude = (walk.to.Position - walk.from.Position).Magnitude

				if v7 < 1 then
					v8 = walk.from:Lerp(walk.to, v7 * 0.35 + v7 * 0.65 * v7)
				else
					local v9 = 1.65 * magnitude / walk.duration
					v8 = walk.to * CFrame.new(0, 0, -v9 * (v6 - walk.duration))
				end
			else
				v8 = walk.from:Lerp(walk.to, smoothstep(v7))
			end

			setPivot(walk.viewCopy, v8) -- equivalent call inferred; original call site unknown
			local worldCopy = walk.worldCopy
			local cFrame3 = roomToWorld(data, v8) -- equivalent call inferred; original call site unknown
			setPivot(worldCopy, cFrame3) -- equivalent call inferred; original call site unknown

			for _, partPair in ipairs(walk.partPairs) do
				if partPair.leader then
					continue
				end

				local cFrame2 = partPair.world.CFrame
				local inView, inWorld = glassSides(
					(data.back.CFrame * cframe):ToObjectSpace(cFrame2),
					partPair.world.Size,
					openNow,
					cameraInFront
				)
				partPair.inView = inView
				partPair.inWorld = inWorld
			end

			for _, partPair in ipairs(walk.partPairs) do
				local leader = partPair.leader or partPair
				setPartVisible(partPair.view, leader.inView)
				setPartVisible(partPair.world, leader.inWorld)
			end

			if not walk.reverse then
				if walk.settleUntil then
					followRealClocks(walk)
				elseif walk.duration - v.SettleTime <= v6 then
					settleIntoReal(walk, k, now)
				end
			end

			if v7 >= 1 then
				if walk.reverse then
					if not openNow then
						destroyCopies(walk) -- equivalent call inferred; original call site unknown
						data.walks[k] = nil
					end
				elseif isComplete(k) and rigPosed(k) and walk.settleUntil and walk.settleUntil <= now or now - walk.startedAt > walk.duration + v.CompletionTimeout then
					releaseHidden(data, k) -- equivalent call inferred; original call site unknown
					destroyCopies(walk) -- equivalent call inferred; original call site unknown
					data.walks[k] = nil
				elseif not (walk.standing or walk.settleUntil) then
					walk.standing = true

					if walk.worldIdle then
						if walk.worldWalk then
							walk.worldWalk:Stop(0.2)
						end

						walk.worldIdle:Play()
					end
				end
			end
		else
			destroyCopies(walk) -- equivalent call inferred; original call site unknown
			data.walks[k] = nil
			releaseHidden(data, k) -- equivalent call inferred; original call site unknown
		end
	end
end

local function hideWorld(folder, p)
	local descendants = folder:GetDescendants()
	table.insert(descendants, folder)

	for _, part in ipairs(descendants) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = p and 1 or 0
		end
	end
end

local function buildMirror(p, folder)
	local active = p.active
	local clone = folder:Clone()
	local descendants = folder:GetDescendants()
	local descendants2 = clone:GetDescendants()
	table.insert(descendants, 1, folder)
	table.insert(descendants2, 1, clone)
	local pairs2 = {}

	for i, part in ipairs(descendants) do
		local part2 = descendants2[i]

		if not (part2 and part:IsA("BasePart") and part2:IsA("BasePart")) then
			continue
		end

		local decals = {}

		for _, decal in ipairs(part2:GetChildren()) do
			if decal:IsA("Decal") then
				table.insert(decals, {
					decal = decal,
					base = decal.Transparency
				})
			end
		end

		table.insert(pairs2, {
			real = part,
			copy = part2,
			base = part2.Transparency,
			decals = decals
		})
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("ObjectValue") or descendant:IsA("Constraint") or descendant:IsA("Humanoid") or descendant:IsA("AnimationController") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.LocalTransparencyModifier = 0
		end
	end

	if clone:IsA("BasePart") then
		clone.Anchored = true
		clone.LocalTransparencyModifier = 0
	end

	clone:SetAttribute("PortalCopyOf", folder.Name)
	clone.Parent = active.world
	p.mirrors[folder] = {
		copy = clone,
		pairs = pairs2
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCopyPartVisible(pair, p)
	pair.copy.Transparency = not p and 1 or pair.base or 1

	for _, decal in ipairs(pair.decals) do
		decal.decal.Transparency = p and decal.base or 1
	end
end

local function tickMirrors(p, openNow, cFrame)
	local cameraInFront = isCameraInFront(p, cFrame) -- equivalent call inferred; original call site unknown

	for instance, mirror in pairs(p.mirrors) do
		if mirror.copy.Parent ~= p.active.world then
			mirror.copy.Parent = p.active.world
		end

		if instance.Parent then
			if CollectionService:HasTag(instance, "PortalMirror") then
				for _, pair in ipairs(mirror.pairs) do
					local real = pair.real

					if real.Parent then
						local cFrame2 = worldToRoom(p, real.CFrame) -- equivalent call inferred; original call site unknown
						local v7, v8 = glassSides(cFrame2, real.Size, openNow, cameraInFront)
						pair.copy.CFrame = cFrame2
						setCopyPartVisible(pair, v7)
						real.LocalTransparencyModifier = v8 and 0 or 1
					else
						setCopyPartVisible(pair, false) -- equivalent call inferred; original call site unknown
					end
				end
			else
				mirror.copy:Destroy()
				p.mirrors[instance] = nil
				hideWorld(instance, false)
			end
		elseif not openNow then
			mirror.copy:Destroy()
			p.mirrors[instance] = nil
		end
	end
end

local function adoptMirror(instance)
	hideWorld(instance, true)
	local portalDoor = instance:WaitForChild("PortalDoor", 5)
	local v6 = os.clock() + v.CompletionTimeout

	while portalDoor and not portalDoor.Value and os.clock() < v6 do
		task.wait()
	end

	local value = portalDoor and portalDoor.Value
	local v7

	if value then
		v7 = v2[value]
	else
		v7 = value
	end

	while value and not v7 and os.clock() < v6 do
		task.wait()
		v7 = v2[value]
	end

	while true do
		local portalPartCount = instance:GetAttribute("PortalPartCount")

		if portalPartCount == nil or portalPartCount <= partCount(instance) or not (instance.Parent and os.clock() < v6) then
			break
		end

		task.wait()
	end

	if v7 and instance.Parent and v7.active and CollectionService:HasTag(instance, "PortalMirror") then
		buildMirror(v7, instance)
	elseif instance.Parent then
		hideWorld(instance, false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOpenNow(p)
	return p.doorPart.CFrame.LookVector:Dot(p.back.CFrame.LookVector) > -0.985
end

local function retreatAll(state)
	for _, child in ipairs(state.door:GetChildren()) do
		if not (child:GetAttribute("PortalEmerge") and (child:IsA("Model") or child:IsA("BasePart"))) then
			continue
		end

		task.spawn(startWalk, state, child, true, true)
	end
end

local function watchDoor(state)
	local door = state.door
	state.connections = {
		door.ChildAdded:Connect(function(child)
			if not child:GetAttribute("PortalEmerge") then
				return
			end

			holdHidden(state, child) -- equivalent call inferred; original call site unknown
			task.defer(function()
				if child.Parent == door then
					startWalk(state, child, false, isOpenNow(state))
				end
			end)
		end),
		door:GetAttributeChangedSignal("PortalScene"):Connect(function()
			selectScene(state)
		end),
		door:GetAttributeChangedSignal("PortalPhase"):Connect(function()
			if door:GetAttribute("PortalPhase") == "Retreat" then
				retreatAll(state)
			end
		end),
		door:GetAttributeChangedSignal("TrickOrTreatSpent"):Connect(function()
			setFrameGlow(state, state.inRange)
		end)
	}
end

local function disposeRecord(data)
	for _, scene in pairs(data.scenes) do
		scene.gui:Destroy()
	end

	for _, walk in pairs(data.walks) do
		destroyCopies(walk) -- equivalent call inferred; original call site unknown
	end

	for _, mirror in pairs(data.mirrors) do
		mirror.copy:Destroy()
	end

	for _, hideConnection in pairs(data.hideConnections) do
		hideConnection:Disconnect()
	end

	for _, connection in ipairs(data.connections) do
		connection:Disconnect()
	end
end

local function update(p)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local now = os.clock()
	local cFrame = currentCamera.CFrame

	for k, v6 in pairs(v2) do
		if k.Parent then
			local magnitude = (v6.back.Position - cFrame.Position).Magnitude
			local inRange = magnitude <= v6.config.range or v6.inRange and magnitude <= v6.config.drawRange

			if inRange ~= v6.inRange then
				v6.inRange = inRange

				if inRange then
					flickerIn(v6) -- equivalent call inferred; original call site unknown
				else
					setFrameGlow(v6, false)
				end
			end

			local openNow = isOpenNow(v6) -- equivalent call inferred; original call site unknown
			local v8 = inRange and (openNow or k:GetAttribute("PortalActive") == true)

			for _, scene in pairs(v6.scenes) do
				scene.gui.Enabled = v8 and scene == v6.active
			end

			setWorldFX(v6, inRange and openNow)

			if inRange or (v6.idleMoodAt or 0) <= now then
				local v9

				if inRange then
					v9 = p
				else
					v9 = now - (v6.moodAt or now)
				end

				v6.moodAt = now
				v6.idleMoodAt = now + v.IdleMoodInterval
				applyMood(v6, v9, now, inRange and openNow)
			end

			if v8 then
				project(v6, v6.active, cFrame)
				animateScene(v6.active, now)
			end

			if openNow and not v6.wasOpen and inRange then
				burstFog(v6)
			end

			v6.wasOpen = openNow
			tickWalks(v6, now, openNow, cFrame)
			tickMirrors(v6, openNow, cFrame)
		else
			disposeRecord(v6)
			v2[k] = nil
		end
	end
end

local function adopt(instance)
	if v2[instance] then
		return
	end

	local back = instance:WaitForChild("Back", 10)
	local door = instance:WaitForChild("Door", 10)

	if not back or not door or not instance.Parent or v2[instance] then
		return
	end

	local descendants = {}
	local descendants2 = {}
	local glows = instance:FindFirstChild("Glows")

	if glows then
		for _, descendant in ipairs(glows:GetDescendants()) do
			if descendant:IsA("Beam") then
				table.insert(descendants, descendant)
			elseif descendant:IsA("Light") then
				table.insert(descendants2, descendant)
			end
		end
	end

	local config = readDoorConfig(instance)
	local v7 = {
		door = instance,
		back = back,
		doorPart = door,
		config = config,
		beams = descendants,
		frameLights = descendants2,
		inRange = false,
		scenes = {},
		active = nil,
		walks = {},
		mirrors = {},
		wasOpen = false,
		hideConnections = {},
		connections = {},
		primary = config.moods.Neutral.primary,
		secondary = config.moods.Neutral.secondary,
		ambient = config.moods.Neutral.ambient
	}
	back.Material = Enum.Material.Neon
	local success, result = pcall(function()
		ensureWorldFX(v7)
		selectScene(v7)
	end)

	if not success then
		warn("[TrickOrTreatPortal] build failed for " .. instance:GetFullName() .. ": " .. tostring(result))
		return
	end

	setFrameGlow(v7, false)
	watchDoor(v7)
	v2[instance] = v7
	print("[TrickOrTreatPortal] adopted " .. instance:GetFullName() .. " scene=" .. v7.active.name)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDoor(model)
	return model:IsA("Model") and model.Name:sub(1, #v.DoorNamePrefix) == v.DoorNamePrefix
end

for _, model in ipairs(workspace:GetDescendants()) do
	if isDoor(model) then
		task.spawn(adopt, model)
	end
end

workspace.DescendantAdded:Connect(function(model)
	if isDoor(model) then
		task.spawn(adopt, model)
	end
end)

for _, v6 in ipairs(CollectionService:GetTagged("PortalMirror")) do
	task.spawn(adoptMirror, v6)
end

CollectionService:GetInstanceAddedSignal("PortalMirror"):Connect(function(p)
	task.spawn(adoptMirror, p)
end)
RunService:BindToRenderStep("TrickOrTreatPortal", Enum.RenderPriority.Camera.Value + 1, update)