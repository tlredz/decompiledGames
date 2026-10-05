local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local color = Color3.fromRGB(255, 40, 40)
local color2 = Color3.fromRGB(201, 94, 36)
local color3 = Color3.fromRGB(150, 95, 235)
local color4 = Color3.fromRGB(201, 94, 36)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local localPlayer = nil
local v = nil
local v2 = {}
local v3 = {}
local now = 0

local function readNumberAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function readSettings(model)
	local meteorsPerSecond = model:GetAttribute("MeteorsPerSecond")
	local v4 = {
		meteorsPerSecond = math.max(0, typeof(meteorsPerSecond) ~= "number" and 1 or meteorsPerSecond),
		warnDuration = 0,
		delay = 0,
		fallDuration = 0,
		fallHeight = 0,
		impactRadius = 0,
		maxActive = 0
	}
	local warnDuration = model:GetAttribute("WarnDuration")
	v4.warnDuration = math.max(0, typeof(warnDuration) ~= "number" and 0.5 or warnDuration)
	local delay = model:GetAttribute("Delay")
	v4.delay = math.max(0, typeof(delay) ~= "number" and 0 or delay)
	local fallDuration = model:GetAttribute("FallDuration")
	v4.fallDuration = math.max(0.05, typeof(fallDuration) ~= "number" and 0.28 or fallDuration)
	local fallHeight = model:GetAttribute("FallHeight")
	v4.fallHeight = math.max(1, typeof(fallHeight) ~= "number" and 70 or fallHeight)
	local impactRadius = model:GetAttribute("ImpactRadius")
	v4.impactRadius = math.max(0.5, typeof(impactRadius) ~= "number" and 14 or impactRadius)
	local maxActive = model:GetAttribute("MaxActive")
	v4.maxActive = math.max(1, (math.floor(typeof(maxActive) ~= "number" and 12 or maxActive)))
	return v4
end

local function checkTrapReady(model)
	if not model:IsA("Model") then
		return false, nil, "MeteorTrap tag must be placed on a Model"
	end

	local meteorArea = model:FindFirstChild("MeteorArea")
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local meteorKeycap

	if assets then
		meteorKeycap = assets:FindFirstChild("MeteorKeycap")
	end

	if meteorArea and meteorArea:IsA("BasePart") and meteorKeycap and (meteorKeycap:IsA("Model") or meteorKeycap:IsA("BasePart")) then
		return true, {
			area = meteorArea,
			template = meteorKeycap
		}, ""
	end

	return false, nil, "MeteorTrap requires a MeteorArea BasePart and ReplicatedStorage.Assets.MeteorKeycap"
end

local function getRandomPositionInArea(area)
	local v4 = area.Size * 0.5
	local v5 = (math.random() * 2 - 1) * math.max(0, v4.X - 4)
	local v6 = (math.random() * 2 - 1) * math.max(0, v4.Z - 4)
	return (area.CFrame * CFrame.new(v5, -v4.Y, v6)).Position
end

local function isLocalPlayerHit(randomPositionInArea: Vector3, impactRadius: number)
	local v4 = localPlayer
	local character

	if v4 then
		character = v4.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local v5 = humanoidRootPart.Position - randomPositionInArea
		return Vector2.new(v5.X, v5.Z).Magnitude <= impactRadius
	else
		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function killLocalPlayer()
	local v4 = localPlayer
	local character

	if v4 then
		character = v4.Character
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid and humanoid.Health > 0 then
		humanoid.Health = 0
	end
end

local function hardenVisual(part)
	if part:IsA("BasePart") then
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
	end

	for _, part2 in part:GetDescendants() do
		if not part2:IsA("BasePart") then
			continue
		end

		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CastShadow = false
	end
end

local function setVisualCFrame(instance, cFrame: CFrame)
	if instance:IsA("Model") then
		instance:PivotTo(cFrame)
	elseif instance:IsA("BasePart") then
		instance.CFrame = cFrame
	end
end

local function createTelegraphPart(name: string, vector2: Vector3, p: number, transparency: number, p2: number)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Transparency = transparency
	part.Size = Vector3.new(0.1, p, p)
	part.CFrame = CFrame.new(vector2 + Vector3.new(0, p2, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = Workspace
	return part
end

local function createImpactTelegraph(randomPositionInArea: Vector3, impactRadius: number, warnDuration: number)
	local v4 = impactRadius * 2
	local telegraphPart = createTelegraphPart("MeteorTrapImpactBoundary", randomPositionInArea, v4, 0.92, 0.58)
	local telegraphPart2 = createTelegraphPart("MeteorTrapImpactFill", randomPositionInArea, 0.1, 0.82, 0.62)
	local v5 = math.max(warnDuration, 0.05)
	TweenService:Create(telegraphPart2, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
		Size = Vector3.new(0.1, v4, v4)
	}):Play()
	return telegraphPart, telegraphPart2
end

local function createImpactSplash(randomPositionInArea: Vector3, impactRadius: number)
	local part = Instance.new("Part")
	part.Name = "MeteorTrapSplashFx"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(120, 90, 200)
	part.Transparency = 0.35
	part.Size = createVector(0.15, 0.6, 0.6)
	part.CFrame = CFrame.new(randomPositionInArea + createVector(0, 0.1, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Parent = Workspace
	local tween = TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.15, impactRadius * 1.6, impactRadius * 1.6),
		Transparency = 1
	})
	tween.Completed:Once(function()
		part:Destroy()
	end)
	tween:Play()
	Debris:AddItem(part, 1)
end

local function createExplosion(randomPositionInArea: Vector3, impactRadius: number)
	local part = Instance.new("Part")
	part.Name = "MeteorTrapExplosionFx"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(randomPositionInArea + createVector(0, 1, 0))
	part.Parent = Workspace
	local sound = Instance.new("Sound")
	sound.Name = "Explosion"
	sound.SoundId = "rbxassetid://137364256909483"
	sound.Volume = 2.5
	sound.PlaybackSpeed = 1 + (math.random() * 2 - 1) * 0.15
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 40
	sound.RollOffMaxDistance = 250
	sound.Parent = part
	sound:Play()
	local part2 = Instance.new("Part")
	part2.Name = "Flash"
	part2.Shape = Enum.PartType.Ball
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Material = Enum.Material.Neon
	part2.Color = color2
	part2.Transparency = 0.05
	part2.Size = Vector3.new(impactRadius * 0.4, impactRadius * 0.4, impactRadius * 0.4)
	part2.CFrame = part.CFrame
	part2.Parent = part
	TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(impactRadius * 1.6, impactRadius * 1.6, impactRadius * 1.6),
		Transparency = 1
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color2
	pointLight.Brightness = 8
	pointLight.Range = impactRadius * 2.5
	pointLight.Shadows = false
	pointLight.Parent = part2
	TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Brightness = 0
	}):Play()
	local part3 = Instance.new("Part")
	part3.Name = "Shockwave"
	part3.Shape = Enum.PartType.Cylinder
	part3.Anchored = true
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.CastShadow = false
	part3.Material = Enum.Material.Neon
	part3.Color = color2
	part3.Transparency = 0.2
	part3.Size = Vector3.new(0.1, impactRadius * 0.3, impactRadius * 0.3)
	part3.CFrame = CFrame.new(randomPositionInArea + createVector(0, 0.3, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	part3.Parent = part
	TweenService:Create(part3, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, impactRadius * 2.6, impactRadius * 2.6),
		Transparency = 1
	}):Play()
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(color3)
	particleEmitter.LightEmission = 0.8
	particleEmitter.LightInfluence = 0
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, impactRadius * 0.12),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.7)
	particleEmitter.Speed = NumberRange.new(impactRadius * 1.5, impactRadius * 3.5)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Drag = 5
	particleEmitter.Acceleration = createVector(0, -70, 0)
	particleEmitter.Rate = 0
	particleEmitter.Enabled = false
	particleEmitter.Parent = part
	particleEmitter:Emit(50)
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particleEmitter2.Color = ColorSequence.new(color4)
	particleEmitter2.LightInfluence = 1
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, impactRadius * 0.4),
		NumberSequenceKeypoint.new(1, impactRadius * 1.1)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.2, 0.55),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.7, 1.3)
	particleEmitter2.Speed = NumberRange.new(impactRadius * 0.4, impactRadius * 1.1)
	particleEmitter2.SpreadAngle = Vector2.new(90, 90)
	particleEmitter2.Drag = 3
	particleEmitter2.Acceleration = createVector(0, 8, 0)
	particleEmitter2.Rate = 0
	particleEmitter2.Enabled = false
	particleEmitter2.Parent = part
	particleEmitter2:Emit(14)
	Debris:AddItem(part, 2.5)
end

local function spawnDrop(state, data)
	local randomPositionInArea = getRandomPositionInArea(state.area)
	local v4 = "drop" .. tostring(state.nextDropId)
	state.nextDropId += 1
	state.activeCount += 1
	local v5 = Janitor.new()
	state.janitor:Add(v5, "Destroy", v4)
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finishDrop()
		if v6 or v2[state.model] ~= state then
			v6 = true
			return
		end

		v6 = true
		state.activeCount -= 1
		state.janitor:Remove(v4)
	end

	local impactTelegraph, v7 = createImpactTelegraph(randomPositionInArea, data.impactRadius, data.warnDuration)

	local function startFall()
		local clone = state.template:Clone()
		hardenVisual(clone)
		local cframe = CFrame.new(randomPositionInArea)
		local cFrame = cframe + Vector3.new(0, data.fallHeight, 0)

		if clone:IsA("Model") then
			clone:PivotTo(cFrame)
		elseif clone:IsA("BasePart") then
			clone.CFrame = cFrame
		end

		clone.Parent = Workspace
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = cFrame
		cFrameValue.Parent = clone
		local valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			if clone.Parent then
				local instance = clone
				local cFrame2 = cFrameValue.Value

				if instance:IsA("Model") then
					instance:PivotTo(cFrame2)
				elseif instance:IsA("BasePart") then
					instance.CFrame = cFrame2
				end
			end
		end)
		local tween = TweenService:Create(
			cFrameValue,
			TweenInfo.new(data.fallDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				Value = cframe
			}
		)
		tween.Completed:Once(function()
			valueChangedConnection:Disconnect()

			if clone.Parent then
				if isLocalPlayerHit(randomPositionInArea, data.impactRadius) then
					killLocalPlayer() -- equivalent call inferred; original call site unknown
				end

				createImpactSplash(randomPositionInArea, data.impactRadius)
				createExplosion(randomPositionInArea, data.impactRadius)
			end

			finishDrop() -- equivalent call inferred; original call site unknown
		end)
		tween:Play()
		v5:Add(clone)
		v5:Add(valueChangedConnection)
		v5:Add(tween, "Cancel")
	end

	local v8 = data.warnDuration + data.delay
	local thread

	if v8 > 0 then
		thread = task.delay(v8, startFall)
	end

	if thread == nil then
		startFall()
	end

	v5:Add(impactTelegraph)
	v5:Add(v7)

	if thread then
		v5:Add(thread, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTrapSetup(k, p)
	local janitor = Janitor.new()
	v2[k] = {
		model = k,
		area = p.area,
		template = p.template,
		janitor = janitor,
		spawnCredit = 0,
		activeCount = 0,
		nextDropId = 1
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownTrap(k)
	v3[k] = nil
	local v4 = v2[k]

	if v4 then
		v4.janitor:Destroy()
		v2[k] = nil
	end
end

local function queueTrap(model)
	if v2[model] == nil and v3[model] == nil then
		if model:IsA("Model") then
			v3[model] = {
				nextRetry = 0,
				warnAt = os.clock() + 10,
				warned = false
			}
		else
			logger:warn("MeteorTrap tag must be placed on a Model", model:GetFullName())
		end
	end
end

local function retryPending(now2: number)
	for k, v4 in v3 do
		if k.Parent == nil then
			v3[k] = nil
		elseif v4.nextRetry <= now2 then
			v4.nextRetry = now2 + 0.5
			local v5, v6, v7 = checkTrapReady(k)

			if v5 and v6 then
				applyTrapSetup(k, v6) -- equivalent call inferred; original call site unknown
				v3[k] = nil
			elseif v4.warnAt <= now2 and not v4.warned then
				v4.warned = true
				logger:warn(v7, k:GetFullName())
			end
		end
	end
end

local function updateTrap(state, p: number)
	local v4 = readSettings(state.model)

	if v4.meteorsPerSecond <= 0 then
		state.spawnCredit = 0
		return
	end

	state.spawnCredit = math.min(state.spawnCredit + p * v4.meteorsPerSecond, v4.maxActive)

	while state.spawnCredit >= 1 and state.activeCount < v4.maxActive do
		state.spawnCredit -= 1
		spawnDrop(state, v4)
	end
end

local function updateClient()
	local now2 = os.clock()
	local v4 = math.min(now2 - now, 0.1)
	now = now2
	retryPending(now2)

	for k, v5 in v2 do
		if k.Parent and v5.area.Parent then
			updateTrap(v5, v4)
		else
			teardownTrap(k) -- equivalent call inferred; original call site unknown

			if k.Parent then
				queueTrap(k)
			end
		end
	end
end

local function startClient()
	localPlayer = Players.LocalPlayer
	now = os.clock()

	for _, v4 in CollectionService:GetTagged("MeteorTrap") do
		queueTrap(v4)
	end

	retryPending(os.clock())
	local connection = CollectionService:GetInstanceAddedSignal("MeteorTrap"):Connect(queueTrap)
	local connection2 = CollectionService:GetInstanceRemovedSignal("MeteorTrap"):Connect(teardownTrap)
	v = Janitor.new()
	v:Add(connection)
	v:Add(connection2)
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClient()
		end
	end,
	OnUpdate = function()
		if RunService:IsClient() then
			updateClient()
		end
	end
})
return {}