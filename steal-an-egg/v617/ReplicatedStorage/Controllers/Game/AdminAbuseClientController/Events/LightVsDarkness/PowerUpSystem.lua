local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Shake = require(ReplicatedStorage.Client.Shake)
local FallenPowerUp = require(ReplicatedStorage.Data.FallenPowerUp)
local LightVsDarknessEventFlags = require(ReplicatedStorage.Shared.Flags.LightVsDarknessEventFlags)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local lightVsDarknessSounds = ReplicatedStorage.Assets.Sounds:WaitForChild("LightVsDarknessSounds")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
local v = nil
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local v6 = 0
local v7 = nil
local now = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function serverNow()
	return Workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function keypoint(p: number, p2: number)
	return NumberSequenceKeypoint.new(p, p2)
end

local function itemsFolder()
	local v8 = v5

	if v8 ~= nil then
		return v8
	end

	local folder = Instance.new("Folder")
	folder.Name = "LightVsDarknessPowerUps"
	folder.Parent = Workspace
	maid:Add(folder)
	maid:Add(function()
		v5 = nil
	end)
	v5 = folder
	return folder
end

local function stripModel(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end
end

local function vfxEnabled()
	return LightVsDarknessEventFlags.PowerUpDropVfxEnabled:Get()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function punchEnabled()
	return LightVsDarknessEventFlags.PowerUpDropVfxEnabled:Get() and LightVsDarknessEventFlags.PowerUpDropPunchEnabled:Get()
end

local function soundsEnabled()
	return LightVsDarknessEventFlags.PowerUpDropSoundsEnabled:Get()
end

local function cometScale()
	return LightVsDarknessEventFlags.PowerUpCometScale:Get()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function headPixels(lerped: Vector3)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return FallenPowerUp.HeadPixelMin
	end

	local v8 = math.max((currentCamera.CFrame.Position - lerped).Magnitude, 1)
	return (math.clamp(
		FallenPowerUp.HeadPixelRef * LightVsDarknessEventFlags.PowerUpCometScale:Get() / v8,
		FallenPowerUp.HeadPixelMin,
		FallenPowerUp.HeadPixelMax
	))
end

local function skyTargetY(p)
	local v8 = v7

	if v8 == nil or not LightVsDarknessEventFlags.PowerUpSkyLiftEnabled:Get() then
		return p.Y
	end

	return v8
end

local function fxAnchor(position: Vector3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	return part
end

local function playPickupSound()
	local collectChargedRing = lightVsDarknessSounds:FindFirstChild("CollectChargedRing")

	if collectChargedRing == nil or not collectChargedRing:IsA("Sound") then
		return
	end

	local clone = collectChargedRing:Clone()
	clone.Parent = collectChargedRing.Parent
	clone.PlayOnRemove = true
	clone.PlaybackSpeed = 1.15
	task.defer(function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRiser()
	local sound = Instance.new("Sound")
	sound.SoundId = FallenPowerUp.RiserSoundId
	sound.Volume = FallenPowerUp.RiserVolume
	sound.PlayOnRemove = true
	sound.Parent = SoundService
	task.defer(function()
		sound:Destroy()
	end)
end

local function playLandSound(vector2: Vector3)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(vector2)
	local sound = Instance.new("Sound")
	sound.SoundId = FallenPowerUp.ImpactSoundId
	sound.Volume = FallenPowerUp.ImpactVolume
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMaxDistance = FallenPowerUp.ImpactRangeStuds
	sound.PlayOnRemove = true
	sound.Parent = part
	part.Parent = itemsFolder()
	task.defer(function()
		part:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundRing(vector2: Vector3, markerStartStuds: number, color: Color3)
	local v8 = vector2 + Vector3.new(0, FallenPowerUp.MarkerLiftStuds, 0)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(v8)
	part.Size = Vector3.new(markerStartStuds, FallenPowerUp.MarkerThickStuds, markerStartStuds)
	local decal = Instance.new("Decal")
	decal.Name = "Ring"
	decal.Face = Enum.NormalId.Top
	decal.Texture = FallenPowerUp.MarkerTexture
	decal.Color3 = color
	decal.Parent = part
	return part, decal
end

local function playShockwave(vector2: Vector3, color: Color3)
	local parent, decal = groundRing(vector2, 8, color) -- equivalent call inferred; original call site unknown
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = FallenPowerUp.LandFlashBrightness
	pointLight.Range = FallenPowerUp.LandFlashRangeStuds
	pointLight.Parent = parent
	parent.Parent = itemsFolder()
	local tweenInfo2 = TweenInfo.new(FallenPowerUp.ShockwaveSeconds, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local shockwaveStuds = FallenPowerUp.ShockwaveStuds
	TweenService:Create(parent, tweenInfo2, {
		Size = Vector3.new(shockwaveStuds, FallenPowerUp.MarkerThickStuds, shockwaveStuds)
	}):Play()
	TweenService:Create(decal, tweenInfo2, {
		Transparency = 1
	}):Play()
	TweenService:Create(pointLight, tweenInfo, {
		Brightness = 0
	}):Play()
	task.delay(FallenPowerUp.ShockwaveSeconds + 0.2, function()
		parent:Destroy()
	end)
end

local function playImpact(position: Vector3, color: Color3)
	local bigHitGroundAttach = ReplicatedStorage.Assets.Particles:FindFirstChild("BigHitGroundAttach")

	if bigHitGroundAttach == nil then
		return
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(position)
	part.Parent = Workspace
	local clone = bigHitGroundAttach:Clone()
	clone.Parent = part

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = ColorSequence.new(color)
		emitter:Emit(emitter:GetAttribute("EmitCount") or 18)
	end

	if clone:IsA("ParticleEmitter") then
		clone.Color = ColorSequence.new(color)
		clone:Emit(clone:GetAttribute("EmitCount") or 18)
	end

	task.delay(3, function()
		part:Destroy()
	end)
end

local function playSpawnBurst(vector2: Vector3, color: Color3, burstOriginScale: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(vector2)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = FallenPowerUp.BurstShockTexture
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Lifetime = NumberRange.new(0.45, 0.6)
	particleEmitter.Rate = 0
	particleEmitter.Speed = NumberRange.new(0)
	particleEmitter.Rotation = NumberRange.new(0, 360)
	local v9 = keypoint(0, burstOriginScale * 2) -- equivalent call inferred; original call site unknown
	local v10 = burstOriginScale * 11
	particleEmitter.Size = NumberSequence.new({
		v9,
		NumberSequenceKeypoint.new(0.4, v10),
		keypoint(1, burstOriginScale * 15)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.7, 0.5),
		keypoint(1, 1)
	})
	particleEmitter.Parent = part
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Texture = FallenPowerUp.BurstGlowTexture
	particleEmitter2.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	particleEmitter2.LightEmission = 1
	particleEmitter2.LightInfluence = 0
	particleEmitter2.Lifetime = NumberRange.new(0.35)
	particleEmitter2.Rate = 0
	particleEmitter2.Speed = NumberRange.new(0)
	local v11 = burstOriginScale * 10
	particleEmitter2.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, v11), keypoint(1, 0) })
	particleEmitter2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), keypoint(1, 1) })
	particleEmitter2.Parent = part
	local particleEmitter3 = Instance.new("ParticleEmitter")
	particleEmitter3.Texture = FallenPowerUp.BurstGlowTexture
	particleEmitter3.Color = ColorSequence.new(color)
	particleEmitter3.LightEmission = 1
	particleEmitter3.LightInfluence = 0
	particleEmitter3.Lifetime = NumberRange.new(0.5, 0.8)
	particleEmitter3.Rate = 0
	particleEmitter3.Speed = NumberRange.new(burstOriginScale * 16, burstOriginScale * 26)
	particleEmitter3.SpreadAngle = Vector2.new(180, 180)
	particleEmitter3.Drag = 5
	local v12 = burstOriginScale * 0.8
	particleEmitter3.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, v12), keypoint(1, 0) })
	particleEmitter3.Parent = part
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 6
	pointLight.Range = burstOriginScale * 30
	pointLight.Parent = part
	part.Parent = itemsFolder()
	particleEmitter:Emit(2)
	particleEmitter2:Emit(1)
	particleEmitter3:Emit((math.floor(burstOriginScale * 24)))
	TweenService:Create(pointLight, tweenInfo, {
		Brightness = 0
	}):Play()
	task.delay(2, function()
		part:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFx(state)
	local fx = state.Fx

	if fx ~= nil then
		state.Fx = nil
		fx:Destroy()
	end

	local mark = state.Mark

	if mark ~= nil then
		state.Mark = nil
		state.Ring = nil
		mark:Destroy()
	end

	local head = state.Head

	if head ~= nil then
		state.Head = nil
		head:Destroy()
	end
end

local function buildHead(p, color: Color3)
	local basePart = p.Model:FindFirstChildWhichIsA("BasePart")

	if basePart == nil then
		return
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "CometHead"
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Adornee = basePart
	billboardGui.Size = UDim2.fromOffset(FallenPowerUp.HeadPixelMin, FallenPowerUp.HeadPixelMin)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = FallenPowerUp.HeadGlowTexture
	imageLabel.ImageColor3 = color
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = billboardGui
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = FallenPowerUp.HeadGlowTexture
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel2.Size = UDim2.fromScale(FallenPowerUp.HeadCoreScale, FallenPowerUp.HeadCoreScale)
	imageLabel2.Parent = billboardGui
	billboardGui.Parent = basePart
	p.Head = billboardGui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildMark(p, vector2: Vector3, color: Color3)
	local mark, ring = groundRing(vector2, FallenPowerUp.MarkerStartStuds, color) -- equivalent call inferred; original call site unknown
	mark.Parent = itemsFolder()
	p.Mark = mark
	p.Ring = ring
end

local function buildTail(p, vector2: Vector3, vector3: Vector3, color: Color3, p2: number)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(vector2)
	part.CFrame = CFrame.lookAt(vector2, vector3)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 0, p2)
	attachment2.Parent = part
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Texture = FallenPowerUp.TailTexture
	beam.TextureMode = Enum.TextureMode.Stretch
	beam.TextureLength = 1
	beam.TextureSpeed = 0.6
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = FallenPowerUp.TailWidthStuds
	beam.Width1 = FallenPowerUp.TailTipWidthStuds
	beam.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.25, color),
		ColorSequenceKeypoint.new(1, color)
	})
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.6, 0.45),
		keypoint(1, 1)
	})
	beam.Parent = part
	local clone = beam:Clone()
	clone.Width0 = FallenPowerUp.TailWidthStuds * FallenPowerUp.PlumeWidthScale
	clone.Width1 = FallenPowerUp.TailTipWidthStuds * FallenPowerUp.PlumeWidthScale
	clone.TextureSpeed = 0.25
	clone.Color = ColorSequence.new(color)
	local plumeTransparency = FallenPowerUp.PlumeTransparency
	clone.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, plumeTransparency),
		NumberSequenceKeypoint.new(0.7, 0.9),
		keypoint(1, 1)
	})
	clone.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = FallenPowerUp.BurstGlowTexture
	particleEmitter.Color = ColorSequence.new(color)
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Lifetime = NumberRange.new(0.35, 0.55)
	particleEmitter.Rate = FallenPowerUp.TailSparkRate
	particleEmitter.Speed = NumberRange.new(2, 6)
	particleEmitter.SpreadAngle = Vector2.new(35, 35)
	local tailSparkStuds = FallenPowerUp.TailSparkStuds
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, tailSparkStuds), keypoint(1, 0) })
	particleEmitter.Parent = attachment
	part.Parent = itemsFolder()
	p.Fx = part
end

local function buildBeacon(state, vector2: Vector3, color: Color3)
	destroyFx(state) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = CFrame.new(vector2)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, FallenPowerUp.BeaconBaseStuds, 0)
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, FallenPowerUp.BeaconHeightStuds, 0)
	attachment2.Parent = part
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.Texture = FallenPowerUp.BeaconTexture
	beam.TextureMode = Enum.TextureMode.Stretch
	beam.TextureLength = 1
	beam.TextureSpeed = 0.35
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = FallenPowerUp.BeaconWidthStuds
	beam.Width1 = 1.2
	beam.Color = ColorSequence.new(color)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(0.75, 0.55),
		keypoint(1, 1)
	})
	beam.Parent = part
	part.Parent = itemsFolder()
	state.Fx = part
end

local function playLandShake(vector2: Vector3)
	if not LightVsDarknessEventFlags.PowerUpLandShakeEnabled:Get() then
		return
	end

	local v8 = LightVsDarknessEventFlags.PowerUpLandShakeRadiusStuds:Get()
	local primaryPart = Player.FindPrimaryPart(localPlayer)
	local v9 = math.clamp(
		1 - (primaryPart == nil and 1e999 or (primaryPart.Position - vector2).Magnitude) / math.max(v8, 1),
		0,
		1
	) ^ FallenPowerUp.LandShakeFalloff
	local seconds = FallenPowerUp.GlobalBumpSeconds + (FallenPowerUp.LandShakeSeconds - FallenPowerUp.GlobalBumpSeconds) * v9
	local magnitude = FallenPowerUp.GlobalBumpIntensity + (FallenPowerUp.LandShakeIntensity - FallenPowerUp.GlobalBumpIntensity) * v9
	Shake.Play({
		Seconds = seconds,
		Magnitude = magnitude,
		Shape = "Pulse"
	})
end

local function buildItem(item)
	local kindById = FallenPowerUp.KindById(item.Kind)
	local modelFor = FallenPowerUp.ModelFor(item.Kind)

	if kindById == nil or modelFor == nil then
		return
	end

	local vector2 = Vector3.new(item.SX, item.SY, item.SZ)
	local clone = modelFor:Clone()
	stripModel(clone)
	clone.Name = `PowerUp{item.Id}`
	clone:PivotTo(CFrame.new(vector2))
	local highlight = Instance.new("Highlight")
	highlight.FillColor = kindById.Color
	highlight.OutlineColor = kindById.Color
	highlight.FillTransparency = FallenPowerUp.HighlightFillTransparency
	highlight.OutlineTransparency = FallenPowerUp.HighlightOutlineTransparency
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = clone
	highlight.Parent = clone
	TweenService:Create(highlight, FallenPowerUp.HighlightPulse, {
		FillTransparency = FallenPowerUp.HighlightPulseFill
	}):Play()
	local basePart = clone:FindFirstChildWhichIsA("BasePart")

	if basePart ~= nil then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = kindById.Color
		pointLight.Brightness = FallenPowerUp.LightBrightness
		pointLight.Range = FallenPowerUp.LightRangeStuds
		pointLight.Parent = basePart
	end

	local scale = clone:GetScale() * FallenPowerUp.WorldScale
	local boundingBox, v9 = clone:GetBoundingBox()
	local rest = math.max(clone:GetPivot().Position.Y - (boundingBox.Position.Y - v9.Y * 0.5), 0) * FallenPowerUp.WorldScale + FallenPowerUp.BobStuds + FallenPowerUp.HoverStuds
	local v11 = Workspace:GetServerTimeNow() < item.LandAt
	local flight

	if v11 and punchEnabled() then
		flight = scale * FallenPowerUp.FlightScale * LightVsDarknessEventFlags.PowerUpCometScale:Get()
	else
		flight = scale
	end

	clone:ScaleTo(flight)
	clone.Parent = itemsFolder()
	local v13 = {
		Item = item,
		Model = clone,
		Scale = scale,
		AskedAt = 0,
		Landed = false,
		Start = vector2,
		BaseY = item.Y,
		Fx = nil,
		Mark = nil,
		Ring = nil,
		Head = nil,
		Flight = flight,
		ShrinkAt = 0,
		Rest = rest
	}
	v2[item.Id] = v13

	if v11 and LightVsDarknessEventFlags.PowerUpDropVfxEnabled:Get() then
		local vector3 = Vector3.new(item.X, item.Y, item.Z)
		local v14 = (vector2 - vector3).Magnitude / math.max(item.FallSeconds or 1, 0.1)
		local v15 = math.clamp(
			FallenPowerUp.TailLengthStuds * v14 / FallenPowerUp.TailSpeedRef,
			FallenPowerUp.TailLengthStuds,
			FallenPowerUp.TailMaxLengthStuds
		)
		buildTail(v13, vector2, vector3, kindById.Color, v15)

		if punchEnabled() then
			buildHead(v13, kindById.Color)
			buildMark(v13, vector3, kindById.Color) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyRendered(k: number)
	local v8 = v2[k]

	if v8 == nil then
		return
	end

	v2[k] = nil
	destroyFx(v8) -- equivalent call inferred; original call site unknown
	v8.Model:Destroy()
end

local function fadeRendered(k: number)
	local v8 = v2[k]

	if v8 == nil then
		return
	end

	v2[k] = nil
	destroyFx(v8) -- equivalent call inferred; original call site unknown
	local model = v8.Model

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		elseif descendant:IsA("Highlight") then
			TweenService:Create(descendant, tweenInfo, {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		elseif descendant:IsA("PointLight") then
			TweenService:Create(descendant, tweenInfo, {
				Brightness = 0
			}):Play()
		end
	end

	task.delay(0.3, function()
		model:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearItems()
	v = nil

	for k in v2 do
		destroyRendered(k) -- equivalent call inferred; original call site unknown
	end

	table.clear(v2)
end

local function adoptBatch(p: number, items)
	clearItems() -- equivalent call inferred; original call site unknown
	v = p
	local v8 = serverNow() -- equivalent call inferred; original call site unknown
	local vector2 = nil

	for _, item in items do
		buildItem(item)

		if vector2 == nil and v8 < item.LandAt then
			vector2 = Vector3.new(item.SX, item.SY, item.SZ)
		end
	end

	if vector2 ~= nil and LightVsDarknessEventFlags.PowerUpDropVfxEnabled:Get() then
		playSpawnBurst(vector2, Color3.fromRGB(255, 240, 200), FallenPowerUp.BurstOriginScale)
	end

	if vector2 ~= nil and LightVsDarknessEventFlags.PowerUpDropSoundsEnabled:Get() then
		playRiser() -- equivalent call inferred; original call site unknown
	end
end

local function onDropped(p: number, p2)
	adoptBatch(p, p2)
end

local function onCleared(p: number)
	if p ~= v then
		return
	end

	v = nil

	for k in v2 do
		fadeRendered(k)
	end

	table.clear(v2)
end

local function onCollected(p: number, p2: number, targetUserId: number)
	if p ~= v then
		return
	end

	local v8 = v2[p2]

	if v8 == nil then
		return
	end

	v2[p2] = nil
	destroyFx(v8) -- equivalent call inferred; original call site unknown
	local kindById = FallenPowerUp.KindById(v8.Item.Kind)

	if kindById ~= nil then
		playImpact(v8.Model:GetPivot().Position, kindById.Color)
	end

	v3[v8.Model] = {
		Model = v8.Model,
		From = v8.Model:GetPivot().Position,
		StartedAt = os.clock(),
		Scale = v8.Model:GetScale(),
		TargetUserId = targetUserId
	}

	if targetUserId == localPlayer.UserId then
		playPickupSound()
	end
end

local function onSky(value)
	if type(value) ~= "number" then
		value = nil
	end

	v7 = value
end

local function stepAbsorbs(now2: number)
	for k, v8 in v3 do
		if k.Parent == nil then
			v3[k] = nil
		else
			local v9 = (now2 - v8.StartedAt) / FallenPowerUp.AbsorbSeconds

			if v9 >= 1 then
				v3[k] = nil
				k:Destroy()
			else
				local playerByUserId = Players:GetPlayerByUserId(v8.TargetUserId)
				local part

				if playerByUserId ~= nil then
					part = Player.FindRootPart(playerByUserId)
				end

				local from

				if part == nil or not part:IsA("BasePart") then
					from = v8.From
				else
					from = part.Position
				end

				local v10 = v9 * v9
				k:PivotTo(CFrame.new(v8.From:Lerp(from, v10)))
				k:ScaleTo((math.max(v8.Scale * (1 - 0.92 * v9), 0.05)))
			end
		end
	end
end

local function stepItems(now2: number, p: number)
	local v8 = serverNow() -- equivalent call inferred; original call site unknown
	local primaryPart = Player.FindPrimaryPart(localPlayer)
	local v9 = v
	local v10 = 1 - math.exp(-FallenPowerUp.SkyLiftResponse * p)

	for k, v11 in v2 do
		local item = v11.Item
		local landAt = item.LandAt
		local Y = v7

		if Y == nil or not LightVsDarknessEventFlags.PowerUpSkyLiftEnabled:Get() then
			Y = item.Y
		end

		if v8 < landAt then
			v11.BaseY = Y
			local fallSeconds = item.FallSeconds or LightVsDarknessEventFlags.PowerUpFallSeconds:Get()
			local v12 = math.clamp(1 - (landAt - v8) / fallSeconds, 0, 1)
			local vector2 = Vector3.new(item.X, Y, item.Z)
			local lerped = v11.Start:Lerp(vector2, v12 ^ FallenPowerUp.FallEase)
			v11.Model:PivotTo(CFrame.new(lerped) * CFrame.Angles(0, now2 * FallenPowerUp.SpinSpeed, 0))
			local fx = v11.Fx

			if fx ~= nil and (vector2 - lerped).Magnitude > 0.5 then
				fx.CFrame = CFrame.lookAt(lerped, vector2)
			end

			local head = v11.Head

			if head ~= nil then
				local v13 = headPixels(lerped) -- equivalent call inferred; original call site unknown
				head.Size = UDim2.fromOffset(v13, v13)
			end

			local mark = v11.Mark
			local ring = v11.Ring

			if mark ~= nil then
				local v13 = FallenPowerUp.MarkerStartStuds + (FallenPowerUp.MarkerEndStuds - FallenPowerUp.MarkerStartStuds) * v12
				mark.Size = Vector3.new(v13, FallenPowerUp.MarkerThickStuds, v13)
				mark.CFrame = CFrame.new(item.X, Y + FallenPowerUp.MarkerLiftStuds, item.Z)
			end

			if ring ~= nil then
				ring.Transparency = 0.5 - math.abs((math.sin(now2 * FallenPowerUp.MarkerPulseSpeed))) * 0.35
			end
		else
			if not v11.Landed then
				v11.Landed = true
				v11.ShrinkAt = now2
				v11.BaseY = Y
				local vector2 = Vector3.new(item.X, Y, item.Z)
				destroyFx(v11) -- equivalent call inferred; original call site unknown
				local kindById = FallenPowerUp.KindById(item.Kind)

				if kindById ~= nil then
					playImpact(vector2, kindById.Color)

					if punchEnabled() then
						playShockwave(vector2, kindById.Color)
					end

					if LightVsDarknessEventFlags.PowerUpDropVfxEnabled:Get() then
						buildBeacon(v11, vector2, kindById.Color)
					end
				end

				if LightVsDarknessEventFlags.PowerUpDropSoundsEnabled:Get() then
					playLandSound(vector2)
				end

				playLandShake(vector2)
			end

			local v12 = now2 - v11.ShrinkAt

			if v12 < FallenPowerUp.LandScaleSeconds and v11.Flight ~= v11.Scale then
				local v13 = v12 / FallenPowerUp.LandScaleSeconds
				v11.Model:ScaleTo(v11.Flight + (v11.Scale - v11.Flight) * v13)
			elseif v11.Model:GetScale() ~= v11.Scale then
				v11.Model:ScaleTo(v11.Scale)
			end

			v11.BaseY += (Y - v11.BaseY) * v10
			local vector2 = Vector3.new(item.X, v11.BaseY, item.Z)
			local v13 = math.sin(now2 * FallenPowerUp.BobSpeed + k) * FallenPowerUp.BobStuds
			v11.Model:PivotTo(CFrame.new(vector2 + Vector3.new(0, v11.Rest + v13, 0)) * CFrame.Angles(
				0,
				now2 * FallenPowerUp.SpinSpeed,
				0
			))
			local fx = v11.Fx

			if fx ~= nil then
				fx.CFrame = CFrame.new(vector2)
			end

			if v9 ~= nil and primaryPart ~= nil and now2 - v11.AskedAt > FallenPowerUp.PickupRetrySeconds and (primaryPart.Position - vector2).Magnitude <= FallenPowerUp.PickupRadiusStuds then
				v11.AskedAt = now2
				Remotes.LightVsDarkness.AskCollectPowerUp:FireServer(v9, k)
			end
		end
	end
end

local function activeKinds(p, p2: number)
	local result = {}

	for _, v8 in FallenPowerUp.KindList do
		if p2 < FallenPowerUp.ActiveUntil(p, v8) then
			table.insert(result, v8)
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAuraKind(p)
	if p.Clone ~= nil then
		p.Clone:Destroy()
	end

	p.Attachment:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAura(p)
	local v8 = v4[p]

	if v8 == nil then
		return
	end

	v4[p] = nil

	for _, v9 in v8.ByKind do
		destroyAuraKind(v9) -- equivalent call inferred; original call site unknown
	end
end

local function buildAuraKind(kindById, root)
	local attachment = Instance.new("Attachment")
	attachment.Name = `PowerUpAura{kindById.Id}`
	attachment.Parent = root
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Color = ColorSequence.new(kindById.Color)
	particleEmitter.LightEmission = 0.65
	particleEmitter.Lifetime = NumberRange.new(0.55, 0.9)
	particleEmitter.Rate = 16
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-40, 40)
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Speed = NumberRange.new(1.5, 3)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Parent = attachment
	local modelFor = FallenPowerUp.ModelFor(kindById.Id)
	local clone

	if modelFor ~= nil then
		clone = modelFor:Clone()
		stripModel(clone)
		clone.Name = `PowerUpHalo{kindById.Id}`
		clone:ScaleTo(clone:GetScale() * FallenPowerUp.HeadCloneScale)
		clone.Parent = itemsFolder()
	end

	return {
		Clone = clone,
		Emitter = particleEmitter,
		Attachment = attachment
	}
end

local function syncAuras(p: number)
	for _, v8 in Players:GetPlayers() do
		local character = v8.Character
		local part = Player.FindRootPart(v8)
		local v9 = (character == nil or part == nil or not part:IsA("BasePart")) and {} or activeKinds(v8, p)
		local v10 = v4[v8]

		if #v9 == 0 then
			if v10 ~= nil then
				destroyAura(v8) -- equivalent call inferred; original call site unknown
			end
		else
			if v10 ~= nil and (v10.Character ~= character or v10.Root.Parent == nil) then
				destroyAura(v8) -- equivalent call inferred; original call site unknown
				v10 = nil
			end

			if v10 == nil then
				v10 = {
					Character = character,
					Root = part,
					ByKind = {}
				}
				v4[v8] = v10
			end

			local v11 = {}

			for _, v12 in v9 do
				v11[v12] = true

				if v10.ByKind[v12] ~= nil then
					continue
				end

				local kindById = FallenPowerUp.KindById(v12)

				if kindById ~= nil then
					v10.ByKind[v12] = buildAuraKind(kindById, v10.Root)
				end
			end

			for k, v12 in v10.ByKind do
				if v11[k] then
					continue
				end

				v10.ByKind[k] = nil
				destroyAuraKind(v12) -- equivalent call inferred; original call site unknown
			end
		end
	end

	for k in v4 do
		if k.Parent ~= nil then
			continue
		end

		destroyAura(k) -- equivalent call inferred; original call site unknown
	end
end

local function stepAuras(now2: number)
	for _, v8 in v4 do
		local root = v8.Root

		if root.Parent == nil then
			continue
		end

		local v9 = {}

		for k, auraKind in v8.ByKind do
			table.insert(v9, {
				Kind = k,
				AuraKind = auraKind
			})
		end

		table.sort(v9, function(a, b)
			local kindById = FallenPowerUp.KindById(a.Kind)
			local kindById2 = FallenPowerUp.KindById(b.Kind)
			return (not kindById and 0 or kindById.Order) < (not kindById2 and 0 or kindById2.Order)
		end)
		local v10 = #v9

		for k, v11 in v9 do
			local clone = v11.AuraKind.Clone

			if not (clone ~= nil and clone.Parent ~= nil) then
				continue
			end

			local v12 = (k - (v10 + 1) / 2) * FallenPowerUp.HeadCloneGapStuds
			local v13 = math.sin(now2 * FallenPowerUp.BobSpeed + k) * FallenPowerUp.HeadCloneBobStuds
			local v14 = root.Position + Vector3.new(0, FallenPowerUp.HeadCloneHoverStuds + v13, 0) + root.CFrame.RightVector * v12
			clone:PivotTo(CFrame.new(v14) * CFrame.Angles(0, now2 * FallenPowerUp.HeadCloneSpinSpeed, 0))
		end
	end
end

local function step()
	local now2 = os.clock()
	local v8 = math.clamp(now2 - now, 0, 0.25)
	now = now2
	local v9 = serverNow() -- equivalent call inferred; original call site unknown
	stepItems(now2, v8)
	stepAbsorbs(now2)
	stepAuras(now2)

	if now2 - v6 >= 0.2 then
		v6 = now2
		syncAuras(v9)
	end
end

local function start()
	maid:Clean()
	v6 = 0
	v7 = nil
	now = os.clock()
	maid:Connect(Remotes.LightVsDarkness.PowerUpsDropped.OnClientEvent, onDropped)
	maid:Connect(Remotes.LightVsDarkness.PowerUpsCleared.OnClientEvent, onCleared)
	maid:Connect(Remotes.LightVsDarkness.PowerUpCollected.OnClientEvent, onCollected)
	maid:Connect(Remotes.LightVsDarkness.PowerUpsSky.OnClientEvent, onSky)
	maid:Connect(RunService.Heartbeat, step)
	maid:Add(function()
		clearItems() -- equivalent call inferred; original call site unknown
		v7 = nil

		for k in v3 do
			k:Destroy()
		end

		table.clear(v3)

		for k in v4 do
			destroyAura(k) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Add(task.spawn(function()
		local v8, v9, v10 = Remotes.LightVsDarkness.FetchPowerUps:InvokeServer()

		if type(v10) ~= "number" then
			v10 = nil
		end

		v7 = v10

		if type(v8) == "number" and type(v9) == "table" and v == nil then
			adoptBatch(v8, v9)
		end
	end))
end

local function stop()
	maid:Clean()
end

return function(_)
	return {
		Start = start,
		Stop = stop
	}
end