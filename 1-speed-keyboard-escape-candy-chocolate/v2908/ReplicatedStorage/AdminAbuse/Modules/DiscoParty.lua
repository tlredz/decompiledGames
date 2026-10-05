local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiscoPartyConfig = require(script.DiscoPartyConfig)
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local CCPulse = require(ReplicatedStorage.Utilities.Events.CCPulse)
local LightingSnapshot = require(ReplicatedStorage.Utilities.Events.LightingSnapshot)
local discoConfig = DiscoPartyConfig.DiscoConfig
local discoBallFieldConfig = DiscoPartyConfig.DiscoBallFieldConfig
local spotlightConfig = DiscoPartyConfig.SpotlightConfig
local v = CCPulse.new({
	name = "DiscoParty",
	colorSpeed = 0.5,
	satAmp = 0.12,
	brightAmp = 0.03
})
local v2 = PartyEvent.new({
	DisplayName = "Disco Party",
	Sounds = { "rbxassetid://139838794512700" }
})

-- equivalent calls inferred from this helper; original call sites unknown
local function setCF(part, cFrame)
	if part:IsA("BasePart") then
		part.CFrame = cFrame
	else
		part:PivotTo(cFrame)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function faceNormalVector(p)
	if p == Enum.NormalId.Front then
		return createVector(0, 0, -1)
	end

	if p == Enum.NormalId.Back then
		return createVector(0, 0, 1)
	end

	if p == Enum.NormalId.Right then
		return createVector(1, 0, 0)
	end

	if p == Enum.NormalId.Left then
		return createVector(-1, 0, 0)
	end

	if p == Enum.NormalId.Top then
		return createVector(0, 1, 0)
	end

	return createVector(0, -1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function faceCorrectionCFrame(vector2: Vector3)
	local v3 = math.abs(vector2.Y) > 0.99 and createVector(0, 0, 1) or createVector(0, 1, 0)
	return CFrame.lookAt(createVector(0, 0, 0), vector2, v3):Inverse()
end

local function pickKeycapNearPosition(children, vector2: Vector3, p: number, p2: number, p3)
	local parts = {}

	for _, part in children do
		if not (part ~= p3 and part:IsA("BasePart")) then
			continue
		end

		local v3 = part.Position - vector2
		local v4 = v3.X * v3.X + v3.Z * v3.Z

		if p * p <= v4 and v4 <= p2 * p2 then
			table.insert(parts, part)
		end
	end

	if #parts == 0 then
		return nil
	end

	return parts[math.random(1, #parts)]
end

local function pickSpotlightPair(position: Vector3)
	local keycaps = workspace:FindFirstChild("Keycaps")

	if not keycaps then
		return nil, nil
	end

	local children = keycaps:GetChildren()

	if #children == 0 then
		return nil, nil
	end

	local v3 = pickKeycapNearPosition(
		children,
		position,
		spotlightConfig.SpawnRadiusMin,
		spotlightConfig.SpawnRadiusMax
	)

	if not v3 then
		return nil, nil
	end

	local v4 = pickKeycapNearPosition(
		children,
		position,
		spotlightConfig.LookAtRadiusMin,
		spotlightConfig.LookAtRadiusMax,
		v3
	)

	if v4 then
		return v3, v4
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newSpotlightState(p: number)
	return {
		instance = nil,
		light = nil,
		beam = nil,
		glow = nil,
		faceCorrection = nil,
		baseCF = nil,
		nextAttempt = (p - 1) * (spotlightConfig.CycleSec / spotlightConfig.Count),
		phase = (p - 1) * spotlightConfig.PhaseOffsetSec,
		nextColorUpdate = 0
	}
end

local function trySwitchSpotlight(janitor, _spotlightTemplate, _spotlight, instance, lastNow, _fxFolder)
	if lastNow < _spotlight.nextAttempt or not _spotlightTemplate then
		return
	end

	local v3, v4 = pickSpotlightPair(instance.Position)

	if not (v3 and v4) then
		_spotlight.nextAttempt = lastNow + spotlightConfig.RetrySec
		return
	end

	_spotlight.nextAttempt = lastNow + spotlightConfig.CycleSec

	if not _spotlight.instance then
		local instance2 = janitor:Add(_spotlightTemplate:Clone())
		instance2.Parent = _fxFolder
		local spotLight = instance2:FindFirstChildWhichIsA("SpotLight", true)
		local beam = instance2:FindFirstChildWhichIsA("Beam", true)
		local beamBase = instance2:FindFirstChild("BeamBase", true)
		_spotlight.instance = instance2
		_spotlight.light = spotLight
		_spotlight.beam = beam
		_spotlight.glow = beamBase
		local v6

		if spotLight then
			v6 = spotLight.Face
		else
			v6 = Enum.NormalId.Front
		end

		local v7 = faceNormalVector(v6) -- equivalent call inferred; original call site unknown
		_spotlight.faceCorrection = faceCorrectionCFrame(v7)
	end

	local v5 = v3.Position + Vector3.new(0, spotlightConfig.SpawnYOffset, 0)
	local v6 = v4.Position - v5
	local v7 = v6.Magnitude < 0.001 and createVector(0, -1, 0) or v6
	_spotlight.baseCF = CFrame.lookAt(v5, v5 + v7.Unit) * _spotlight.faceCorrection
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newDiscoBallState(p: number)
	return {
		instance = nil,
		light = nil,
		particle = nil,
		basePos = nil,
		spinAngle = 0,
		nextAttempt = (p - 1) * (discoBallFieldConfig.CycleSec / discoBallFieldConfig.Count),
		phase = (p - 1) * discoBallFieldConfig.PhaseOffsetSec,
		nextColorUpdate = 0
	}
end

local function trySwitchDiscoBall(janitor, _discoBallFieldTemplate, _discoBall, instance, lastNow, _fxFolder)
	if lastNow < _discoBall.nextAttempt or not _discoBallFieldTemplate then
		return
	end

	local keycaps = workspace:FindFirstChild("Keycaps")
	local children = keycaps and keycaps:GetChildren()
	local v3 = children and pickKeycapNearPosition(
		children,
		instance.Position,
		discoBallFieldConfig.SpawnRadiusMin,
		discoBallFieldConfig.SpawnRadiusMax
	)

	if not v3 then
		_discoBall.nextAttempt = lastNow + discoBallFieldConfig.RetrySec
		return
	end

	_discoBall.nextAttempt = lastNow + discoBallFieldConfig.CycleSec

	if not _discoBall.instance then
		local instance2 = janitor:Add(_discoBallFieldTemplate:Clone())
		instance2.Parent = _fxFolder

		if instance2:IsA("Model") then
			instance2:ScaleTo(2)
		elseif instance2:IsA("BasePart") then
			instance2.Size *= 2
		end

		local basePart

		if instance2:IsA("BasePart") then
			basePart = instance2
		else
			basePart = instance2:FindFirstChildWhichIsA("BasePart", true)
		end

		local light = basePart and janitor:Add(Instance.new("PointLight"))

		if light then
			light.Brightness = 2
			light.Range = 16
			light.Color = Color3.fromRGB(255, 255, 255)
			light.Parent = basePart
		end

		local attachment = instance2:FindFirstChild("Attachment", true)
		local particleEmitter = attachment and attachment:FindFirstChildWhichIsA("ParticleEmitter")
		_discoBall.instance = instance2
		_discoBall.light = light
		_discoBall.particle = particleEmitter
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 20),
			NumberSequenceKeypoint.new(1, 0)
		})
	end

	_discoBall.basePos = v3.Position + Vector3.new(0, discoBallFieldConfig.SpawnYOffset, 0)
end

local function updateDiscoBallPose(_discoBall, lastNow, p)
	local basePos = _discoBall.basePos

	if not (basePos and _discoBall.instance and _discoBall.instance.Parent) then
		return
	end

	local v3 = math.sin((lastNow + _discoBall.phase) * discoBallFieldConfig.BobSpeed) * discoBallFieldConfig.BobAmplitude
	_discoBall.spinAngle += discoBallFieldConfig.SpinRad * p
	setCF(_discoBall.instance, CFrame.new(basePos + Vector3.new(0, v3, 0)) * CFrame.Angles(0, _discoBall.spinAngle, 0)) -- equivalent call inferred; original call site unknown
end

local function updateDiscoBallColor(_discoBall, lastNow)
	if not (_discoBall.light or _discoBall.particle) or lastNow < _discoBall.nextColorUpdate then
		return
	end

	_discoBall.nextColorUpdate = lastNow + DiscoPartyConfig.ColorUpdateIntervalSec
	local v3 = (lastNow + _discoBall.phase) * discoBallFieldConfig.LightSpeed % 1
	local color = Color3.fromHSV(v3, 0.85, 1)

	if _discoBall.light then
		_discoBall.light.Color = color
	end

	if _discoBall.particle then
		_discoBall.particle.Color = ColorSequence.new(color)
	end
end

local function updateSpotlightPose(_spotlight, lastNow)
	local baseCF = _spotlight.baseCF

	if not (baseCF and _spotlight.instance and _spotlight.instance.Parent) then
		return
	end

	local v3 = lastNow + _spotlight.phase
	local v4 = math.sin(v3 * spotlightConfig.BobSpeed) * spotlightConfig.BobAmplitude
	local v5 = math.sin(v3 * spotlightConfig.SweepSpeed) * spotlightConfig.SweepAngle
	local v6 = math.sin(v3 * spotlightConfig.ShakeSpeedY) * spotlightConfig.ShakeAngle
	local v7 = math.cos(v3 * spotlightConfig.ShakeSpeedZ) * spotlightConfig.ShakeAngle
	local cFrame = CFrame.new(0, v4, 0) * baseCF * CFrame.Angles(v5, v6, v7)
	setCF(_spotlight.instance, cFrame) -- equivalent call inferred; original call site unknown
end

local function updateSpotlightColor(_spotlight, lastNow)
	if not (_spotlight.light or _spotlight.glow or _spotlight.beam) or lastNow < _spotlight.nextColorUpdate then
		return
	end

	_spotlight.nextColorUpdate = lastNow + DiscoPartyConfig.ColorUpdateIntervalSec
	local v3 = (lastNow + _spotlight.phase) * spotlightConfig.LightSpeed % 1
	local color = Color3.fromHSV(v3, 0.85, 1)

	if _spotlight.light then
		_spotlight.light.Color = color
	end

	if _spotlight.glow then
		_spotlight.glow.Color = color
	end

	if _spotlight.beam then
		_spotlight.beam.Color = ColorSequence.new(color)
	end
end

function v2.OnStart(_, state, _, p, _)
	v:setup(state.janitor)
	LightingSnapshot.acquireShared()
	LightingSnapshot.capture({
		"ClockTime",
		"Brightness",
		"Ambient",
		"OutdoorAmbient",
		"FogColor"
	}):apply({
		ClockTime = 0,
		Brightness = 2,
		Ambient = Color3.fromRGB(45, 40, 70),
		OutdoorAmbient = Color3.fromRGB(45, 40, 70),
		FogColor = Color3.fromRGB(30, 15, 55)
	})
	local v3 = state.janitor:Add(Instance.new("Folder"))
	v3.Name = "DiscoPartyLocal"
	v3.Parent = workspace
	state._fxFolder = v3
	state._ball = nil
	state._ballLight = nil
	state._ballParticle = nil
	state._ballAngle = 0
	state._lastNow = nil
	state._ballNextColorUpdate = 0
	state._spotlightTemplate = ReplicatedStorage.Assets.Events.DiscoParty:FindFirstChild(spotlightConfig.Model)

	if not state._spotlightTemplate then
		warn((`[DiscoParty] Modèle "{spotlightConfig.Model}" introuvable dans ReplicatedStorage`))
	end

	state._spotlights = {}

	for i = 1, spotlightConfig.Count do
		state._spotlights[i] = newSpotlightState(i)
	end

	state._discoBallFieldTemplate = ReplicatedStorage.Assets.Events.DiscoParty:FindFirstChild(discoBallFieldConfig.Model)

	if not state._discoBallFieldTemplate then
		warn((`[DiscoParty] Modèle "{discoBallFieldConfig.Model}" introuvable dans ReplicatedStorage`))
	end

	state._discoBalls = {}

	for i = 1, discoBallFieldConfig.Count do
		state._discoBalls[i] = newDiscoBallState(i)
	end

	local child = ReplicatedStorage.Assets.Events.DiscoParty:FindFirstChild(discoConfig.BallModel)

	if not child then
		warn((`[DiscoParty] Modèle "{discoConfig.BallModel}" introuvable dans ReplicatedStorage`))
		return
	end

	local part = state.janitor:Add(child:Clone())
	part.Parent = v3
	state._ball = part
	local basePart

	if part:IsA("BasePart") then
		basePart = part
	else
		basePart = part:FindFirstChildWhichIsA("BasePart", true)
	end

	if basePart then
		local ballLight = state.janitor:Add(Instance.new("PointLight"))
		ballLight.Brightness = 2
		ballLight.Range = 16
		ballLight.Color = Color3.fromRGB(255, 255, 255)
		ballLight.Parent = basePart
		state._ballLight = ballLight
	end

	local attachment = part:FindFirstChild("Attachment", true)
	state._ballParticle = attachment and attachment:FindFirstChildWhichIsA("ParticleEmitter")
	setCF(part, CFrame.new(p.Position + Vector3.new(0, discoConfig.YOffset, 0))) -- equivalent call inferred; original call site unknown
end

function v2.OnRender(_, state, lastNow, _, instance, _)
	v:update(lastNow)
	local v3 = lastNow - (state._lastNow or lastNow)
	state._lastNow = lastNow
	local _ball = state._ball

	if _ball and _ball.Parent and instance and instance.Parent and v3 > 0 then
		state._ballAngle += discoConfig.SpinRad * v3
		setCF(
			_ball,
			CFrame.new(instance.Position + Vector3.new(0, discoConfig.YOffset, 0)) * CFrame.Angles(
				0,
				state._ballAngle,
				0
			)
		) -- equivalent call inferred; original call site unknown
	end

	if (state._ballLight or state._ballParticle) and state._ballNextColorUpdate <= lastNow then
		state._ballNextColorUpdate = lastNow + DiscoPartyConfig.ColorUpdateIntervalSec
		local v4 = lastNow * discoConfig.LightSpeed % 1
		local color = Color3.fromHSV(v4, 0.85, 1)

		if state._ballLight then
			state._ballLight.Color = color
		end

		if state._ballParticle then
			state._ballParticle.Color = ColorSequence.new(color)
		end
	end

	if instance and instance.Parent and state._fxFolder then
		for _, _spotlight in state._spotlights do
			trySwitchSpotlight(state.janitor, state._spotlightTemplate, _spotlight, instance, lastNow, state._fxFolder)
			updateSpotlightPose(_spotlight, lastNow)
			updateSpotlightColor(_spotlight, lastNow)
		end

		for _, _discoBall in state._discoBalls do
			trySwitchDiscoBall(
				state.janitor,
				state._discoBallFieldTemplate,
				_discoBall,
				instance,
				lastNow,
				state._fxFolder
			)
			updateDiscoBallPose(_discoBall, lastNow, v3)
			updateDiscoBallColor(_discoBall, lastNow)
		end
	end
end

function v2.OnStop(_, _)
	LightingSnapshot.releaseShared()
end

return v2