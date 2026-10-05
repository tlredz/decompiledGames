local createVector = vector.create
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local Shake = require(ReplicatedStorage.Client.Shake)
local EggActionMovement = require(script.Parent.EggActionMovement)
local Log = require(ReplicatedStorage.Packages.Log)
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local PlayVFX = require(ReplicatedStorage.UserGenerated.VFX.PlayVFX)
local VisibleBounds = require(ReplicatedStorage.Shared.Utils.VisibleBounds)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local color = Color3.fromRGB(170, 30, 30)
local color2 = Color3.fromRGB(255, 214, 110)
local color3 = Color3.fromRGB(255, 196, 80)
local color4 = Color3.fromRGB(150, 150, 150)
local color5 = Color3.new(1, 1, 1)
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local v = Log.new()
local transient = Workspace:FindFirstChild("Transient") or Workspace
local random = Random.new()
local v2 = nil
local v3 = {}

if RunService:IsClient() then
	task.spawn(Preload.WarmSounds, 128148316301690, 87821961053710, 92093418106897)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOutSine(p: number)
	return TweenService:GetValue(p, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMutationTint(mutationId: string?)
	local v4 = Mutations.Get(mutationId or BossMastery.MutationId)

	if v4 == nil then
		return color
	end

	return v4.Tint
end

local function liveModel(p)
	local model = p.GetModel()

	if model == nil or not model:IsDescendantOf(Workspace) then
		return nil
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncHighlight(p)
	local model = p.GetModel()

	if model == nil or not model:IsDescendantOf(Workspace) then
		model = nil
	end

	if p.Highlight.Adornee ~= model then
		p.Highlight.Adornee = model
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setScreenGlow(p, value: number, backgroundColor: Color3?)
	local backgroundTransparency = 1 - math.clamp(value, 0, 1)

	for _, screenEdge in p.ScreenEdges do
		screenEdge.BackgroundTransparency = backgroundTransparency

		if backgroundColor ~= nil then
			screenEdge.BackgroundColor3 = backgroundColor
		end
	end
end

local function fadeOutScreenGlow(screenGlow, items)
	local v4 = nil

	for _, item in items do
		v4 = TweenService:Create(item, tweenInfo, {
			BackgroundTransparency = 1
		})
		v4:Play()
	end

	if v4 ~= nil then
		v4.Completed:Once(function()
			screenGlow:Destroy()
		end)
	end

	Debris:AddItem(screenGlow, 1.6)
end

local function createScreenEdge(screenGui, backgroundColor: Color3, anchorPoint: Vector2, position: UDim2, size: UDim2, rotation: number)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = anchorPoint
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Position = position
	frame.Size = size
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Rotation = rotation
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient.Parent = frame
	frame.Parent = screenGui
	return frame
end

local function createScreenGlow(fillColor: Color3)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(playerGui ~= nil, "Local player is missing PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MutationConsumableGlow"
	screenGui.DisplayOrder = 5
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	return screenGui, {
		createScreenEdge(
			screenGui,
			fillColor,
			Vector2.new(0.5, 0),
			UDim2.fromScale(0.5, 0),
			UDim2.fromScale(1, 0.22),
			90
		),
		createScreenEdge(
			screenGui,
			fillColor,
			Vector2.new(0.5, 1),
			UDim2.fromScale(0.5, 1),
			UDim2.fromScale(1, 0.22),
			270
		),
		createScreenEdge(
			screenGui,
			fillColor,
			Vector2.new(0, 0.5),
			UDim2.fromScale(0, 0.5),
			UDim2.fromScale(0.22, 1),
			0
		),
		(createScreenEdge(
			screenGui,
			fillColor,
			Vector2.new(1, 0.5),
			UDim2.fromScale(1, 0.5),
			UDim2.fromScale(0.22, 1),
			180
		))
	}
end

local function offsetModel(state, cframe: CFrame)
	if not state.Motion then
		return
	end

	local model = state.GetModel()

	if model == nil or not model:IsDescendantOf(Workspace) then
		model = nil
	end

	if model == nil or model.PrimaryPart == nil then
		return
	end

	state.Moved = true
	EggActionMovement.SetPivot(model, state.Pivot * cframe)
end

local function restoreModel(state)
	if not state.Moved then
		return
	end

	state.Moved = false
	local model = state.GetModel()

	if model == nil or not model:IsDescendantOf(Workspace) then
		model = nil
	end

	if model == nil or model.PrimaryPart == nil then
		return
	end

	EggActionMovement.SetPivot(model, state.Pivot)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function moveHost(data, p: number)
	local v4 = not data.Motion and 0 or p
	data.Host.CFrame = CFrame.new(data.Pivot.Position + data.CenterOffset + createVector(0, 1, 0) * v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundCFrame(p)
	local v4 = p.Pivot.Position + p.CenterOffset
	return CFrame.new((Vector3.new(v4.X, p.Pivot.Position.Y, v4.Z)))
end

local function measureModel(cframe: CFrame, p)
	local position = cframe.Position + createVector(0, 1, 0)
	local v4 = createVector(2, 2, 2)

	if p == nil then
		return position - cframe.Position, v4
	end

	local v5, v6 = VisibleBounds(p)

	if v6.Magnitude > 0 then
		position = v5.Position
		v4 = v6
	end

	return position - cframe.Position, v4
end

local function createHost(cFrame: CFrame, vector2: Vector3)
	local part = Instance.new("Part")
	part.Name = "MutationConsumableFeedback"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = vector2 * 0.8
	part.CFrame = cFrame
	part.Parent = transient
	return part
end

local function createEmitter(parent, data)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = data.Name
	particleEmitter.Texture = data.Texture
	particleEmitter.Color = data.Color
	particleEmitter.Size = data.Size
	particleEmitter.Transparency = data.Transparency
	particleEmitter.Lifetime = data.Lifetime
	particleEmitter.Speed = data.Speed
	particleEmitter.Acceleration = data.Acceleration or createVector(0, 0, 0)
	particleEmitter.Drag = data.Drag or 0
	particleEmitter.LightEmission = data.LightEmission or 0
	particleEmitter.LightInfluence = data.LightInfluence or 0
	particleEmitter.RotSpeed = data.RotSpeed or NumberRange.new(0)
	particleEmitter.Rotation = data.Rotation or NumberRange.new(0)
	particleEmitter.Rate = data.Rate or 0
	particleEmitter.SpreadAngle = data.SpreadAngle or Vector2.new(180, 180)
	particleEmitter.Orientation = data.Orientation or Enum.ParticleOrientation.FacingCamera
	particleEmitter.Squash = data.Squash or NumberSequence.new(0)
	particleEmitter.Shape = Enum.ParticleEmitterShape.Sphere
	particleEmitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
	particleEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	particleEmitter.Enabled = false
	particleEmitter.Parent = parent
	return particleEmitter
end

local function openScene(pivot: CFrame, getModel, fillColor: Color3, color6: Color3)
	local v4 = v2

	if v4 ~= nil then
		v2 = nil
		v4.Trove:Destroy()
	end

	local adornee = getModel()
	local position = pivot.Position + createVector(0, 1, 0)
	local v6 = createVector(2, 2, 2)

	if adornee ~= nil then
		local v7, v8 = VisibleBounds(adornee)

		if v8.Magnitude > 0 then
			position = v7.Position
			v6 = v8
		end
	end

	local centerOffset = position - pivot.Position
	local cframe = CFrame.new(pivot.Position + centerOffset)
	local part = Instance.new("Part")
	part.Name = "MutationConsumableFeedback"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = v6 * 0.8
	part.CFrame = cframe
	part.Parent = transient
	local attachment = Instance.new("Attachment")
	attachment.Name = "Center"
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "Base"
	attachment2.Position = Vector3.new(0, -part.Size.Y * 0.5 / 0.8, 0)
	attachment2.Parent = part
	local highlight = Instance.new("Highlight")
	highlight.Name = "Glow"
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = fillColor
	highlight.OutlineColor = color6
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Adornee = adornee
	highlight.Parent = part
	local screenGlow, screenEdges = createScreenGlow(fillColor)
	local maid = Trove.new()
	local v9 = {
		GetModel = getModel,
		Pivot = pivot,
		Radius = math.max(v6.X, v6.Y, v6.Z) * 0.5,
		CenterOffset = centerOffset,
		Host = part,
		Center = attachment,
		Base = attachment2,
		Highlight = highlight,
		ScreenEdges = screenEdges,
		Trove = maid,
		Motion = not GuiService.ReducedMotionEnabled,
		Moved = false
	}
	maid:Add(highlight)
	maid:Add(function()
		for _, emitter in part:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(part, 3)
		fadeOutScreenGlow(screenGlow, screenEdges)
		local v10 = v9

		if not v10.Moved then
			return
		end

		v10.Moved = false
		local model = v10.GetModel()

		if model == nil or not model:IsDescendantOf(Workspace) then
			model = nil
		end

		if model ~= nil then
			if model.PrimaryPart == nil then
				return
			else
				EggActionMovement.SetPivot(model, v10.Pivot)
			end
		end
	end)
	v2 = v9
	return v9
end

local function runScene(p, p2: number, callback)
	local v4 = 0
	local preRenderConnection = nil
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v4 = math.min(v4 + dt, p2)
		syncHighlight(p) -- equivalent call inferred; original call site unknown
		callback(v4)

		if v4 < p2 then
			return
		end

		preRenderConnection:Disconnect()

		if v2 ~= p then
			return
		end

		v2 = nil
		p.Trove:Destroy()
	end)
	p.Trove:Add(preRenderConnection)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p, namedSound, options)
	local v4 = options or {}
	v4.MaxDistance = v4.MaxDistance or 70
	Audio.Play(namedSound, p.Host.CFrame, v4)
end

local function findNamedSound(childName: string)
	local sounds = ReplicatedStorage.Assets:FindFirstChild("Sounds")
	local sound

	if sounds then
		sound = sounds:FindFirstChild(childName)
	end

	if sound ~= nil and sound:IsA("Sound") then
		return sound
	end

	v:AtWarning():Log((`Missing ReplicatedStorage.Assets.Sounds.{childName}; sound skipped`))
	return nil
end

local function emitImpactVfx(p)
	local particles = ReplicatedStorage.Assets:FindFirstChild("Particles")
	local bigHitGroundAttach

	if particles then
		bigHitGroundAttach = particles:FindFirstChild("BigHitGroundAttach")
	end

	if bigHitGroundAttach == nil then
		v:AtWarning():Log("Missing ReplicatedStorage.Assets.Particles.BigHitGroundAttach; impact VFX skipped")
		return
	end

	local cFrame = groundCFrame(p) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Name = "MutationConsumableFeedback"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0.080000006, 0.080000006, 0.080000006)
	part.CFrame = cFrame
	part.Parent = transient
	Debris:AddItem(part, 10)
	local clone = bigHitGroundAttach:Clone()

	if not TryCall(PlayVFX, part, cFrame, clone) then
		clone:Destroy()
	end
end

local function scaleSequence(size, p: number)
	local numberSequenceKeypoints = table.create(#size.Keypoints)

	for k, keypoint in size.Keypoints do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function emitFractureVfx(p)
	local particles = ReplicatedStorage.Assets:FindFirstChild("Particles")
	local fractureVFX

	if particles then
		fractureVFX = particles:FindFirstChild("FractureVFX")
	end

	if fractureVFX == nil then
		v:AtWarning():Log("Missing ReplicatedStorage.Assets.Particles.FractureVFX; fracture VFX skipped")
		return
	end

	local cFrame = p.Host.CFrame
	local v4 = createVector(1, 1, 1) * p.Radius * 2
	local part = Instance.new("Part")
	part.Name = "MutationConsumableFeedback"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = v4 * 0.8
	part.CFrame = cFrame
	part.Parent = transient
	Debris:AddItem(part, 6)
	local v5 = math.clamp(p.Radius / 10.7, 0.12, 1)

	for _, emitter in fractureVFX:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Enabled = false
		clone.Size = scaleSequence(emitter.Size, v5)
		clone.Speed = NumberRange.new(emitter.Speed.Min * v5, emitter.Speed.Max * v5)
		clone.Parent = part
		clone:Emit((math.max(1, (math.round(emitter.Rate * 0.55)))))
	end
end

local function shakeOffset(p, p2: number, p3: number)
	local v4 = math.min(p.Radius * 0.08, 0.3) * p3
	local v5 = p3 * 0.12217304763960307
	return CFrame.new(random:NextNumber(-1, 1) * v4, p2 + random:NextNumber(-1, 1) * v4, random:NextNumber(-1, 1) * v4) * CFrame.Angles(
		random:NextNumber(-1, 1) * v5,
		0,
		random:NextNumber(-1, 1) * v5
	)
end

local function createSuccessEmitters(data, mutationTint: Color3, lerped: Color3)
	local radius = data.Radius
	return {
		Twinkle = createEmitter(data.Host, {
			Name = "Twinkle",
			Texture = "rbxassetid://78284231250884",
			Color = ColorSequence.new(color5, color2),
			Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.4),
				NumberSequenceKeypoint.new(1, 0)
			}),
			Transparency = NumberSequence.new(0),
			Lifetime = NumberRange.new(0.35, 0.6),
			Speed = NumberRange.new(0),
			LightEmission = 1,
			Rate = 18
		}),
		Flare = createEmitter(data.Center, {
			Name = "Flare",
			Texture = "rbxassetid://85665154415342",
			Color = ColorSequence.new(color5, color2),
			Size = NumberSequence.new(math.min(radius * 3, 10), (math.min(radius * 5, 10))),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(0.4, 0.45),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(0.6),
			Speed = NumberRange.new(0),
			LightEmission = 1,
			RotSpeed = NumberRange.new(40),
			Rotation = NumberRange.new(-180, 180)
		}),
		Ring = createEmitter(data.Base, {
			Name = "Ring",
			Texture = "rbxassetid://109600784699514",
			Color = ColorSequence.new(color2, lerped),
			Size = NumberSequence.new(0, (math.min(radius * 6, 10))),
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }),
			Lifetime = NumberRange.new(0.6),
			Speed = NumberRange.new(0.5),
			SpreadAngle = Vector2.zero,
			LightEmission = 1,
			Orientation = Enum.ParticleOrientation.VelocityPerpendicular
		}),
		Sparks = createEmitter(data.Host, {
			Name = "Sparks",
			Texture = "rbxassetid://78284231250884",
			Color = ColorSequence.new(color2, mutationTint),
			Size = NumberSequence.new(0.5, 0),
			Transparency = NumberSequence.new(0, 1),
			Lifetime = NumberRange.new(0.7, 1.2),
			Speed = NumberRange.new(radius * 8, radius * 14),
			Drag = 5,
			LightEmission = 1,
			SpreadAngle = Vector2.new(25, 25)
		}),
		Streaks = createEmitter(data.Host, {
			Name = "Streaks",
			Texture = "rbxassetid://78284231250884",
			Color = ColorSequence.new(color5, color2),
			Size = NumberSequence.new(0.35, 0),
			Transparency = NumberSequence.new(0, 1),
			Lifetime = NumberRange.new(0.35, 0.5),
			Speed = NumberRange.new(radius * 18, radius * 26),
			Drag = 8,
			LightEmission = 1,
			SpreadAngle = Vector2.new(10, 10),
			Orientation = Enum.ParticleOrientation.VelocityParallel,
			Squash = NumberSequence.new(-1.5)
		}),
		Embers = createEmitter(data.Host, {
			Name = "Embers",
			Texture = "rbxassetid://128641440631741",
			Color = ColorSequence.new(color2, mutationTint),
			Size = NumberSequence.new(0.25, 0),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.1, 0),
				NumberSequenceKeypoint.new(1, 1)
			}),
			Lifetime = NumberRange.new(1.8, 2.6),
			Speed = NumberRange.new(1, 2.5),
			Acceleration = createVector(0, 3.5, 0),
			Drag = 1.5,
			LightEmission = 1,
			Rate = 20
		})
	}
end

function v3.PlaySuccess(data)
	assert(type(data) == "table", "PlaySuccess expects a params table")
	assert(typeof(data.Pivot) == "CFrame", "PlaySuccess expects the egg's base pivot")
	assert(type(data.GetModel) == "function", "PlaySuccess expects a model getter")
	assert(data.OnReveal == nil or type(data.OnReveal) == "function", "PlaySuccess reveal callback must be a function")
	assert(
		data.OnFinished == nil or type(data.OnFinished) == "function",
		"PlaySuccess finished callback must be a function"
	)
	local pivot = data.Pivot
	local onReveal = data.OnReveal
	local onFinished = data.OnFinished
	local mutationTint = getMutationTint(data.MutationId) -- equivalent call inferred; original call site unknown
	local lerped = mutationTint:Lerp(color5, 0.35)
	local v4 = openScene(pivot, data.GetModel, lerped, color2)

	if onFinished ~= nil then
		v4.Trove:Add(function()
			task.spawn(onFinished)
		end)
	end

	local successEmitters = createSuccessEmitters(v4, mutationTint, lerped)
	local v5 = math.min(v4.Radius * 0.25, 0.8)

	local function spinOffset(p: number)
		if not v4.Motion then
			return CFrame.identity
		end

		local v6

		if p <= 0 then
			v6 = 0
		elseif p < 5.25 then
			v6 = 49.480084294039244 * (p / 5.25) ^ 4
		elseif p >= 5.95 then
			v6 = 62.83185307179586
		else
			local v7 = (p - 5.25) / 0.7
			v6 = 49.480084294039244 + 13.351768777756618 * v7 * (2 - v7)
		end

		return CFrame.Angles(0, v6, 0)
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function performFracture()
		if flag then
			return
		end

		flag = true
		emitFractureVfx(v4)
	end

	playSound(v4, 128148316301690, {
		TimePosition = 0.1200000000000001
	}) -- equivalent call inferred; original call site unknown
	successEmitters.Twinkle.Enabled = true
	local v6 = false
	local v7 = false
	local v8 = false

	local function fn(p: number)
		local highlight = v4.Highlight

		if p < 6.11 then
			local v9 = math.min(p / 5.95, 1)
			local v10 = v9 * v9
			local v11 = math.sin(p * (v9 * 46 + 14)) * 0.2 + 0.8
			highlight.FillTransparency = 1 - v10 * 0.55 * v11
			highlight.OutlineTransparency = 1 - v10 * v11
			setScreenGlow(v4, v10 * 0.4 * v11, lerped:Lerp(color2, v9)) -- equivalent call inferred; original call site unknown

			if p < 0.9 then
				local v15 = TweenService:GetValue(p / 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) * 3
				moveHost(v4, v15) -- equivalent call inferred; original call site unknown
				local v17 = v4
				local v18 = CFrame.new(0, v15, 0) * spinOffset(p)

				if not v17.Motion then
					return
				end

				local model = v17.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v17.Moved = true
					EggActionMovement.SetPivot(model, v17.Pivot * v18)
				end
			elseif p < 5.25 then
				local v14 = (p - 0.9) / 4.35

				if not v8 and v14 >= 0.45 then
					v8 = true
					successEmitters.Embers.Rate = 10
					successEmitters.Embers.Enabled = true
				end

				local value = TweenService:GetValue(
					math.min(v14 / 1, 1),
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In
				)
				local v15 = v4
				local v16 = v15.Motion and 3 or 0
				v15.Host.CFrame = CFrame.new(v15.Pivot.Position + v15.CenterOffset + createVector(0, 1, 0) * v16)
				local v17 = v4
				local v18 = shakeOffset(v4, 3, value) * spinOffset(p)

				if not v17.Motion then
					return
				end

				local model = v17.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v17.Moved = true
					EggActionMovement.SetPivot(model, v17.Pivot * v18)
				end
			elseif p < 5.95 then
				if not v7 then
					v7 = true
					performFracture() -- equivalent call inferred; original call site unknown
					successEmitters.Twinkle.Rate = 40
					successEmitters.Embers.Enabled = false
					successEmitters.Flare:Emit(1)
					successEmitters.Sparks:Emit(18)
				end

				local v14 = (p - 5.25) / 0.7
				local v15 = 3 + 1.25 * TweenService:GetValue(v14, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				local v16 = (1 - v14) * 0.35
				moveHost(v4, v15) -- equivalent call inferred; original call site unknown
				local v18 = v4
				local v19 = shakeOffset(v4, v15, v16) * spinOffset(p)

				if not v18.Motion then
					return
				end

				local model = v18.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v18.Moved = true
					EggActionMovement.SetPivot(model, v18.Pivot * v19)
				end
			else
				performFracture() -- equivalent call inferred; original call site unknown
				local v14 = math.lerp(
					4.25,
					0,
					(TweenService:GetValue((p - 5.95) / 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In))
				)
				moveHost(v4, v14) -- equivalent call inferred; original call site unknown
				local v16 = v4
				local v17 = CFrame.new(0, v14, 0) * spinOffset(p)

				if not v16.Motion then
					return
				end

				local model = v16.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v16.Moved = true
					EggActionMovement.SetPivot(model, v16.Pivot * v17)
				end
			end
		else
			if not v6 then
				v6 = true
				performFracture() -- equivalent call inferred; original call site unknown
				local v9 = v4
				local _ = v9.Motion
				v9.Host.CFrame = CFrame.new(v9.Pivot.Position + v9.CenterOffset + createVector(0, 1, 0) * 0)
				local namedSound = findNamedSound("MechaHatch")

				if namedSound ~= nil then
					playSound(v4, namedSound) -- equivalent call inferred; original call site unknown
				end

				task.delay(0.18, function()
					if v2 == v4 then
						playSound(v4, 87821961053710) -- equivalent call inferred; original call site unknown
					end
				end)
				emitImpactVfx(v4)

				if v4.Motion then
					Shake.Play({
						Seconds = 0.45,
						Magnitude = 1
					})
				end

				successEmitters.Twinkle.Rate = 8
				successEmitters.Flare:Emit(1)
				successEmitters.Ring:Emit(1)
				successEmitters.Sparks:Emit(36)
				successEmitters.Streaks:Emit(16)
				successEmitters.Embers.Rate = 22
				successEmitters.Embers:Emit(18)
				successEmitters.Embers.Enabled = true

				if onReveal ~= nil then
					task.spawn(onReveal)
				end
			end

			local v9 = p - 6.11
			local v10 = math.clamp(v9 / 1.2, 0, 1)
			highlight.FillTransparency = math.lerp(
				0.1,
				1,
				TweenService:GetValue(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			)
			local v11 = math.clamp(v9 / 1.6, 0, 1)
			highlight.OutlineTransparency = math.lerp(0.05, 1, easeInOutSine(v11))
			local value = TweenService:GetValue(
				math.clamp(v9 / 0.12, 0, 1),
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)
			local v12 = math.clamp(v9 / 3, 0, 1)
			local v13 = 1 - TweenService:GetValue(v12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			setScreenGlow(v4, math.lerp(0.4, 1, value) * v13, color2:Lerp(lerped, v12)) -- equivalent call inferred; original call site unknown

			if v9 >= 1.2 then
				successEmitters.Embers.Enabled = false
			end

			if v9 >= 1.6 then
				successEmitters.Twinkle.Enabled = false
			end

			if v9 < 0.36 then
				local v16 = v9 / 0.36
				local v17 = (1 - v16) * (1 - v16)
				local v18 = v5 * math.abs((math.sin(6.283185307179586 * v16))) * v17
				local v19 = v4
				local cframe = CFrame.new(0, v18, 0)

				if not v19.Motion then
					return
				end

				local model = v19.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v19.Moved = true
					EggActionMovement.SetPivot(model, v19.Pivot * cframe)
				end
			else
				local v16 = v4

				if not v16.Moved then
					return
				end

				v16.Moved = false
				local model = v16.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					else
						EggActionMovement.SetPivot(model, v16.Pivot)
					end
				end
			end
		end
	end

	local v9 = 0
	local preRenderConnection = nil
	local v10 = 7.91
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v9 = math.min(v9 + dt, v10)
		syncHighlight(v4) -- equivalent call inferred; original call site unknown
		fn(v9)

		if v9 < v10 then
			return
		end

		preRenderConnection:Disconnect()

		if v2 ~= v4 then
			return
		end

		v2 = nil
		v4.Trove:Destroy()
	end)
	v4.Trove:Add(preRenderConnection)
end

function v3.PlayFailure(data)
	assert(type(data) == "table", "PlayFailure expects a params table")
	assert(typeof(data.Pivot) == "CFrame", "PlayFailure expects the egg's base pivot")
	assert(type(data.GetModel) == "function", "PlayFailure expects a model getter")
	assert(
		data.OnVerdict == nil or type(data.OnVerdict) == "function",
		"PlayFailure verdict callback must be a function"
	)
	assert(
		data.OnFinished == nil or type(data.OnFinished) == "function",
		"PlayFailure finished callback must be a function"
	)
	local onVerdict = data.OnVerdict
	local onFinished = data.OnFinished
	local mutationTint = getMutationTint(data.MutationId) -- equivalent call inferred; original call site unknown
	local lerped = mutationTint:Lerp(color5, 0.35)
	local v4 = openScene(data.Pivot, data.GetModel, lerped, color2)
	local radius = v4.Radius

	if onFinished ~= nil then
		v4.Trove:Add(function()
			task.spawn(onFinished)
		end)
	end

	local successEmitters = createSuccessEmitters(v4, mutationTint, lerped)
	local emitter = createEmitter(v4.Host, {
		Name = "FailSparks",
		Texture = "rbxassetid://78284231250884",
		Color = ColorSequence.new(color3, color4),
		Size = NumberSequence.new(0.3, 0),
		Transparency = NumberSequence.new(0, 1),
		Lifetime = NumberRange.new(0.4, 0.8),
		Speed = NumberRange.new(radius * 3, radius * 5),
		Acceleration = createVector(0, -25, 0),
		Drag = 2,
		LightEmission = 1,
		SpreadAngle = Vector2.new(40, 40)
	})
	local emitter2 = createEmitter(v4.Host, {
		Name = "Smoke",
		Texture = "rbxasset://textures/particles/smoke_main.dds",
		Color = ColorSequence.new(color4, color4:Lerp(Color3.new(0, 0, 0), 0.3)),
		Size = NumberSequence.new(radius * 0.5, radius * 1.1),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		}),
		Lifetime = NumberRange.new(1.4, 2.2),
		Speed = NumberRange.new(1, 2),
		Acceleration = createVector(0, 1.2, 0),
		Drag = 1,
		LightInfluence = 1,
		RotSpeed = NumberRange.new(-20, 20),
		Rotation = NumberRange.new(-180, 180),
		Rate = 10
	})
	local emitter3 = createEmitter(v4.Base, {
		Name = "Dust",
		Texture = "rbxassetid://109600784699514",
		Color = ColorSequence.new(color4),
		Size = NumberSequence.new(0, (math.min(radius * 5, 10))),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new(0.55),
		Speed = NumberRange.new(0.4),
		SpreadAngle = Vector2.zero,
		LightInfluence = 1,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular
	})
	local v5 = math.min(radius * 0.12, 0.45)
	local v6 = Audio.Play(128148316301690, v4.Host.CFrame, {
		MaxDistance = 70,
		TimePosition = 0.1200000000000001
	})
	successEmitters.Twinkle.Enabled = true
	local v7 = 0
	local v8 = 0
	local v9 = 0
	local v10 = false
	local v11 = false
	local v12 = false
	local v13 = 0
	local v14 = 0

	local function fn(p: number)
		local v15 = p - v7
		v7 = p
		local highlight = v4.Highlight

		if p < 3.45 then
			local v16 = math.clamp((p - 2.9) / 0.55, 0, 1)
			local v17 = v16 * (math.sin(p * 53) * 0.5 + 0.5)
			local v18 = math.min(p / 5.95, 1)
			local v19 = v18 * v18
			local v20 = (math.sin(p * (v18 * 46 + 14)) * 0.2 + 0.8) * (1 - v17 * 0.65)
			highlight.FillTransparency = 1 - v19 * 0.55 * v20
			highlight.OutlineTransparency = 1 - v19 * v20
			setScreenGlow(v4, v19 * 0.4 * v20, lerped:Lerp(color2, v18)) -- equivalent call inferred; original call site unknown
			v9 = 37.69911184307752 * (p / 5.25) ^ 3

			if p < 2.9 then
				v8 = 49.480084294039244 * (p / 5.25) ^ 4
			else
				v9 *= 1 - v17 * 0.65
				v8 += v9 * v15
			end

			if p < 0.9 then
				local v24 = TweenService:GetValue(p / 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) * 3
				moveHost(v4, v24) -- equivalent call inferred; original call site unknown
				local v26 = v4
				local v27 = CFrame.new(0, v24, 0) * CFrame.Angles(0, v8, 0)

				if not v26.Motion then
					return
				end

				local model = v26.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v26.Moved = true
					EggActionMovement.SetPivot(model, v26.Pivot * v27)
				end
			else
				local v23 = (p - 0.9) / 4.35

				if not v10 and v23 >= 0.45 then
					v10 = true
					successEmitters.Embers.Rate = 10
					successEmitters.Embers.Enabled = true
				end

				local v24 = TweenService:GetValue(math.min(v23 / 1, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.In) * (v16 * 0.3500000000000001 + 1)
				local v25 = 3 + 0.85 * TweenService:GetValue(v16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				moveHost(v4, v25) -- equivalent call inferred; original call site unknown
				local v27 = v4
				local v28 = shakeOffset(v4, v25, v24) * CFrame.Angles(0, v8, 0)

				if not v27.Motion then
					return
				end

				local model = v27.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v27.Moved = true
					EggActionMovement.SetPivot(model, v27.Pivot * v28)
				end
			end
		else
			if not v11 then
				v11 = true

				if v6 ~= nil then
					v6:Stop()
				end

				playSound(v4, 92093418106897) -- equivalent call inferred; original call site unknown
				successEmitters.Twinkle.Enabled = false
				successEmitters.Embers.Enabled = false
				emitter:Emit(9)
				emitter2.Enabled = true

				if onVerdict ~= nil then
					task.spawn(onVerdict)
				end
			end

			local v16 = p - 3.45
			local v17 = math.clamp(v16 / 0.22, 0, 1)
			local v18 = 1 - math.clamp(v16 / 2.2, 0, 1)
			local v19 = math.sin(p * 24) * 0.3 + 0.7
			local v20 = math.lerp(0.18491278864486976, v19 * 0.5, v17) * v18 * v18
			local v21 = math.lerp(0.3362050702633995, v19 * 0.7, v17) * v18 * v18
			highlight.FillTransparency = 1 - v20
			highlight.OutlineTransparency = 1 - v21
			highlight.FillColor = lerped:Lerp(color4, v17)
			highlight.OutlineColor = color2:Lerp(color4, v17)

			if p < 3.8000000000000003 then
				setScreenGlow(v4, (1 - v17) * 0.1344820281053598, highlight.FillColor) -- equivalent call inferred; original call site unknown
			else
				setScreenGlow(v4, math.clamp(1 - (p - 3.8000000000000003) / 0.35, 0, 1) * 0.3, color4) -- equivalent call inferred; original call site unknown
			end

			if emitter2.Enabled and p >= 4.800000000000001 then
				emitter2.Enabled = false
			end

			if p < 3.8000000000000003 then
				v9 *= math.max(1 - v15 * 6, 0)
				v8 += v9 * v15
				local v22

				if p >= 3.5700000000000003 then
					local v23 = (p - 3.5700000000000003) / 0.23
					v22 = (1 - v23 * v23) * 3.85
				else
					v22 = 3.85
				end

				moveHost(v4, v22) -- equivalent call inferred; original call site unknown
				local v24 = v4
				local v25 = CFrame.new(0, v22, 0) * CFrame.Angles(0, v8, 0)

				if not v24.Motion then
					return
				end

				local model = v24.GetModel()

				if model == nil or not model:IsDescendantOf(Workspace) then
					model = nil
				end

				if model ~= nil then
					if model.PrimaryPart == nil then
						return
					end

					v24.Moved = true
					EggActionMovement.SetPivot(model, v24.Pivot * v25)
				end
			else
				if not v12 then
					v12 = true
					local v22 = v4
					local _ = v22.Motion
					v22.Host.CFrame = CFrame.new(v22.Pivot.Position + v22.CenterOffset + createVector(0, 1, 0) * 0)
					v13 = v8
					v14 = math.ceil(v13 / 6.283185307179586) * 6.283185307179586
					local namedSound = findNamedSound("ImpactBoom")

					if namedSound ~= nil then
						playSound(v4, namedSound, {
							Volume = 0.7
						}) -- equivalent call inferred; original call site unknown
					end

					if v4.Motion then
						Shake.Play({
							Seconds = 0.28,
							Magnitude = 0.5
						})
					end

					emitter3:Emit(1)
					emitter2:Emit(9)
					emitter:Emit(6)
				end

				local v22 = p - 3.8000000000000003
				local v24 = easeInOutSine(math.clamp(v22 / 1, 0, 1)) -- equivalent call inferred; original call site unknown
				local v25 = math.lerp(v13, v14, v24)

				if v22 < 0.42 then
					local v26 = v22 / 0.42
					local v27 = (1 - v26) * (1 - v26)
					local v28 = math.sin(6.283185307179586 * v26)
					local v29 = v4
					local v30 = CFrame.new(0, v5 * math.abs(v28) * v27, 0) * CFrame.Angles(0, v25, 0) * CFrame.Angles(
						0,
						0,
						v28 * 0.08726646259971647 * v27
					)

					if not v29.Motion then
						return
					end

					local model = v29.GetModel()

					if model == nil or not model:IsDescendantOf(Workspace) then
						model = nil
					end

					if model ~= nil then
						if model.PrimaryPart == nil then
							return
						end

						v29.Moved = true
						EggActionMovement.SetPivot(model, v29.Pivot * v30)
					end
				elseif v22 < 1.6199999999999999 then
					local v26 = math.sin((v22 - 0.42) / 1.2 * 3.141592653589793) * 0.06981317007977318
					local v27 = v4
					local v28 = CFrame.Angles(0, v25, 0) * CFrame.Angles(v26, 0, 0)

					if not v27.Motion then
						return
					end

					local model = v27.GetModel()

					if model == nil or not model:IsDescendantOf(Workspace) then
						model = nil
					end

					if model ~= nil then
						if model.PrimaryPart == nil then
							return
						end

						v27.Moved = true
						EggActionMovement.SetPivot(model, v27.Pivot * v28)
					end
				else
					local v26 = v4

					if not v26.Moved then
						return
					end

					v26.Moved = false
					local model = v26.GetModel()

					if model == nil or not model:IsDescendantOf(Workspace) then
						model = nil
					end

					if model ~= nil then
						if model.PrimaryPart == nil then
							return
						else
							EggActionMovement.SetPivot(model, v26.Pivot)
						end
					end
				end
			end
		end
	end

	local v15 = 0
	local preRenderConnection = nil
	local v16 = 5.65
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		v15 = math.min(v15 + dt, v16)
		syncHighlight(v4) -- equivalent call inferred; original call site unknown
		fn(v15)

		if v15 < v16 then
			return
		end

		preRenderConnection:Disconnect()

		if v2 ~= v4 then
			return
		end

		v2 = nil
		v4.Trove:Destroy()
	end)
	v4.Trove:Add(preRenderConnection)
end

return table.freeze(v3)