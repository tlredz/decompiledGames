local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)
local Util = require(game.ReplicatedStorage.Util)
local sound = Util.Sound
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local frozen = table.freeze({
	NODES_NAME = "FountainWireNodes",
	REPAIR_ATTRIBUTE = "FountainWireRepairId",
	ROLE_ATTRIBUTE = "FountainWireRole",
	TRANSPARENCY_ATTRIBUTE = "FountainWireOriginalTransparency",
	BROKEN_ROLE = "Broken",
	REPAIRED_ROLE = "Repaired",
	STATIC_ROLE = "Static",
	HIT_TAG = "M1HitRegistry",
	WAIT_TIMEOUT = 30,
	FOUNTAIN_NAME = "Fountain",
	GEAR_NAME = "Meshes/Bloxfruits_Scrap1_Circle",
	JUNKYARD_NAMES = table.freeze({ "ScrapJunk1", "ScrapJunk2" }),
	HIT_SOUNDS = table.freeze({
		"FountainCitySFX.BF_FountainCity_Fix_Snapped_Wires_01",
		"FountainCitySFX.BF_FountainCity_Fix_Snapped_Wires_02",
		"FountainCitySFX.BF_FountainCity_Fix_Snapped_Wires_03"
	}),
	SHOCK_SOUNDS = table.freeze({
		"FountainCitySFX.BF_FountainCity_Wires_Zap_Player_01",
		"FountainCitySFX.BF_FountainCity_Wires_Zap_Player_02",
		"FountainCitySFX.BF_FountainCity_Wires_Zap_Player_03"
	}),
	SPARK_SOUND = "FountainCitySFX.Snapped_Wires_AmbientSparking_01",
	SPARK_SOUND_FADE = 0.25,
	FEEDBACK_NAME = "FountainWireRepairFeedback",
	SPARK_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds",
	SPARK_RATE = 4,
	SPARK_ARC_RATE = 14,
	SPARK_BURST = 5,
	BOLT_PARTS = 10,
	BOLT_THICKNESS = 0.14,
	BOLT_PULSE_LENGTH = 2,
	STRIKE_DURATION = 0.45,
	STRIKE_PULSE_LENGTH = 1.35,
	STRIKE_THICKNESS = 0.19,
	ARC_HEIGHT_SCALE = 0.36,
	ARC_HEIGHT_MIN = 1.5,
	ARC_HEIGHT_MAX = 2.4,
	CONDUCTORS = table.freeze({ table.freeze({
			left = "RedLeft",
			right = "RedRight",
			color = Color3.fromRGB(255, 68, 68)
		}), table.freeze({
			left = "BlueLeft",
			right = "BlueRight",
			color = Color3.fromRGB(72, 166, 255)
		}), table.freeze({
			left = "GreenLeft",
			right = "GreenRight",
			color = Color3.fromRGB(82, 255, 137)
		}) }),
	REPAIRED_COLOR = Color3.fromRGB(84, 255, 178),
	FINALE_COLOR = Color3.fromRGB(92, 181, 255),
	SHOCK_COLOR = Color3.fromRGB(128, 210, 255),
	STORM_ARC_COLOR = Color3.fromRGB(145, 215, 255),
	STORM_ARC_DURATION = 0.95,
	STORM_ARC_HEIGHT_MAX = 18,
	STORM_ARC_HEIGHT_MIN = 8,
	STORM_ARC_HEIGHT_SCALE = 0.28,
	STORM_ARC_INTERVAL_MAX = 0.45,
	STORM_ARC_INTERVAL_MIN = 0.25,
	STORM_ARC_MAX_SPAN = 130,
	STORM_ARC_MIN_SPAN = 18,
	STORM_ARC_PARTS = 20,
	STORM_ARCS_PER_BURST = 3,
	STORM_ARC_THICKNESS = 0.3,
	STORM_CLOUD_HEIGHT = 150,
	STORM_CLOUD_NAME = "FountainWireStormCloud",
	STORM_FOLDER_NAME = "FountainWireStormVFX",
	STORM_GEAR_CLEARANCE = 2,
	STORM_STRIKE_COUNT = 4,
	STORM_STRIKE_DURATION = 0.5,
	STORM_STRIKE_GAP = 0.16,
	STORM_STRIKE_PARTS = 20,
	STORM_STRIKE_THICKNESS = 0.26,
	FEEDBACK_TWEEN_INFO = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
})
local v = {
	findNodes = function()
		local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
		local model

		if _WorldOrigin then
			model = _WorldOrigin:FindFirstChild(frozen.NODES_NAME)
		end

		if model and model:IsA("Model") then
			return model
		end

		return nil
	end
}

function v.waitForNodes()
	local nodes = v.findNodes()

	if nodes then
		return nodes
	end

	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace:WaitForChild(
		"_WorldOrigin",
		frozen.WAIT_TIMEOUT
	)

	if not _WorldOrigin then
		return nil
	end

	local model = _WorldOrigin:FindFirstChild(frozen.NODES_NAME) or _WorldOrigin:WaitForChild(
		frozen.NODES_NAME,
		frozen.WAIT_TIMEOUT
	)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

function v.getState(p)
	local _fountainWireRepairState = p.MiscData._fountainWireRepairState

	if _fountainWireRepairState then
		return _fountainWireRepairState
	end

	local fountainWireRepairState = {
		arcConnection = nil,
		arcSchedule = nil,
		presentation = nil,
		proxies = {},
		setup = nil,
		strikeBolts = {},
		stormActive = false,
		stormBolts = {},
		stormFolder = nil,
		stormGeneration = 0,
		wires = {},
		staticParts = {},
		repairedCount = 0,
		totalWires = 0,
		available = false,
		finishing = false,
		retryPending = false
	}
	p.MiscData._fountainWireRepairState = fountainWireRepairState
	return fountainWireRepairState
end

function v:setProxyEnabled(canQuery: boolean)
	if not self.Parent then
		return
	end

	self.LocalTransparencyModifier = 1
	self.CanCollide = false
	self.CanQuery = canQuery
	self.CanTouch = false
end

function v.destroyBolts(list)
	for _, v2 in list do
		v2:Destroy()
	end

	table.clear(list)
end

function v.findJunkyardGears()
	local map = workspace:FindFirstChild("Map")
	local model

	if map then
		model = map:FindFirstChild(frozen.FOUNTAIN_NAME)
	end

	if not (model and model:IsA("Model")) then
		return {}
	end

	local parts = {}

	for _, part in model:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == frozen.GEAR_NAME) then
			continue
		end

		local parent = part.Parent

		while parent and parent ~= model do
			if table.find(frozen.JUNKYARD_NAMES, parent.Name) then
				table.insert(parts, part)
				break
			else
				parent = parent.Parent
			end
		end
	end

	return parts
end

function v.getStormOrigin()
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
	local v2

	if _WorldOrigin then
		v2 = _WorldOrigin:FindFirstChild(frozen.STORM_CLOUD_NAME)
	end

	local model = v2 or workspace:FindFirstChild(frozen.STORM_CLOUD_NAME)

	if model and model:IsA("Model") then
		return model:GetPivot().Position
	end

	local nodes = v.findNodes()

	if nodes then
		return nodes:GetBoundingBox().Position + createVector(0, 1, 0) * frozen.STORM_CLOUD_HEIGHT
	end

	return nil
end

function v.trackBolt(list, instance, p: number)
	table.insert(list, instance)
	task.delay(p + 0.1, function()
		instance:Destroy()
		local index = table.find(list, instance)

		if index then
			table.remove(list, index)
		end
	end)
end

function v.createStormBolt(p, vector2: Vector3, vector3: Vector3, p2: number, p3: number, p4: number, curveSize: number)
	local stormFolder = p.stormFolder

	if not stormFolder then
		return
	end

	local magnitude = (vector3 - vector2).Magnitude
	local v2 = LightningBoltShafi.new({
		WorldAxis = createVector(0, 1, 0),
		WorldPosition = vector2
	}, {
		WorldAxis = createVector(-0, -1, -0),
		WorldPosition = vector3
	}, p2, p3, stormFolder, frozen.STORM_ARC_COLOR)
	v2.CurveSize0 = curveSize
	v2.CurveSize1 = curveSize
	v2.MinRadius = 0.12
	v2.MaxRadius = math.clamp(magnitude * 0.045, 0.65, 1.6)
	v2.Frequency = 1.3
	v2.AnimationSpeed = 3.7
	v2.MinThicknessMultiplier = 0.8
	v2.MaxThicknessMultiplier = 1.45
	v2.PulseLength = 1.35
	v2.PulseSpeed = (v2.PulseLength + 1) / p4
	v2.FadeLength = 0.42
	v2.ContractFrom = 0.82
	v.trackBolt(p.stormBolts, v2, p4)
end

function v.getGearArcPosition(instance)
	local v2 = instance.Size * 0.5
	local cFrame = instance.CFrame
	local v3 = math.abs(cFrame.RightVector.Y) * v2.X + math.abs(cFrame.UpVector.Y) * v2.Y + math.abs(cFrame.LookVector.Y) * v2.Z
	return instance.Position + createVector(0, 1, 0) * (v3 + frozen.STORM_GEAR_CLEARANCE)
end

function v.chooseGearPair(list)
	if #list < 2 then
		return nil, nil
	end

	local v2 = list[math.random(1, #list)]
	local v3 = 1e999
	local v4 = 1e999
	local v5 = nil
	local v6 = nil

	for _, v7 in list do
		if not (v7 ~= v2 and v7.Parent) then
			continue
		end

		local magnitude = (v7.Position - v2.Position).Magnitude

		if magnitude < v3 then
			v6 = v7
			v3 = magnitude
		end

		if not (frozen.STORM_ARC_MIN_SPAN <= magnitude and magnitude <= frozen.STORM_ARC_MAX_SPAN and magnitude < v4) then
			continue
		end

		v5 = v7
		v4 = magnitude
	end

	return v2, v5 or v6
end

function v.spawnStormStrike(p, p2)
	local stormOrigin = v.getStormOrigin()

	if not (stormOrigin and p2.Parent) then
		return
	end

	local gearArcPosition = v.getGearArcPosition(p2)
	local vector2 = Vector3.new(
		gearArcPosition.X + math.random(-18, 18),
		stormOrigin.Y,
		gearArcPosition.Z + math.random(-18, 18)
	)
	v.createStormBolt(
		p,
		vector2,
		gearArcPosition,
		frozen.STORM_STRIKE_PARTS,
		frozen.STORM_STRIKE_THICKNESS,
		frozen.STORM_STRIKE_DURATION,
		0
	)
end

function v.spawnGearArc(p, p2)
	local gearPair, v2 = v.chooseGearPair(p2)

	if not (gearPair and v2) then
		return
	end

	local gearArcPosition = v.getGearArcPosition(gearPair)
	local gearArcPosition2 = v.getGearArcPosition(v2)
	local magnitude = (gearArcPosition2 - gearArcPosition).Magnitude
	v.createStormBolt(
		p,
		gearArcPosition,
		gearArcPosition2,
		frozen.STORM_ARC_PARTS,
		frozen.STORM_ARC_THICKNESS,
		frozen.STORM_ARC_DURATION,
		(math.clamp(magnitude * frozen.STORM_ARC_HEIGHT_SCALE, frozen.STORM_ARC_HEIGHT_MIN, frozen.STORM_ARC_HEIGHT_MAX))
	)
end

function v:clearStorm()
	self.stormGeneration += 1
	self.stormActive = false
	v.destroyBolts(self.stormBolts)

	if self.stormFolder then
		self.stormFolder:Destroy()
		self.stormFolder = nil
	end
end

function v:setStormActive(flag: boolean)
	if self.stormActive == flag and (not flag or self.stormFolder ~= nil) then
		return
	end

	v.clearStorm(self)

	if not flag then
		return
	end

	self.stormActive = true
	local stormGeneration = self.stormGeneration
	local folder = Instance.new("Folder")
	folder.Name = frozen.STORM_FOLDER_NAME
	folder.Parent = workspace
	self.stormFolder = folder
	task.spawn(function()
		local junkyardGears = v.findJunkyardGears()

		while self.stormActive and self.stormGeneration == stormGeneration and #junkyardGears < 2 do
			task.wait(0.5)
			junkyardGears = v.findJunkyardGears()
		end

		if not self.stormActive or self.stormGeneration ~= stormGeneration then
			return
		end

		for _ = 1, frozen.STORM_STRIKE_COUNT do
			v.spawnStormStrike(self, junkyardGears[math.random(1, #junkyardGears)])
			task.wait(frozen.STORM_STRIKE_GAP)
		end

		while self.stormActive and self.stormGeneration == stormGeneration do
			if #junkyardGears < 2 or not junkyardGears[1].Parent then
				junkyardGears = v.findJunkyardGears()
			end

			for _ = 1, frozen.STORM_ARCS_PER_BURST do
				v.spawnGearArc(self, junkyardGears)
			end

			local v2 = frozen.STORM_ARC_INTERVAL_MIN + math.random() * (frozen.STORM_ARC_INTERVAL_MAX - frozen.STORM_ARC_INTERVAL_MIN)
			task.wait(v2)
		end
	end)
end

function v:clearPresentation()
	if self.arcConnection then
		self.arcConnection:Disconnect()
		self.arcConnection = nil
	end

	v.destroyBolts(self.strikeBolts)

	for _, wire in self.wires do
		v.setSparkSound(wire, false)

		if not wire.arc then
			continue
		end

		v.destroyBolts(wire.arc.bolts)

		for _, spark in wire.arc.sparks do
			spark.Enabled = false
			spark:Clear()
		end
	end

	for _, proxy in self.proxies do
		v.setProxyEnabled(proxy, false)
	end

	table.clear(self.proxies)

	if self.presentation then
		self.presentation:Destroy()
		self.presentation = nil
	end

	table.clear(self.wires)
	table.clear(self.staticParts)
	self.repairedCount = 0
	self.totalWires = 0
	self.finishing = false
end

function v:resetState()
	v.clearPresentation(self)
	v.clearStorm(self)
	self.arcSchedule = nil
	self.setup = nil
	self.available = false
end

function v.getOriginalTransparency(instance)
	local attribute = instance:GetAttribute(frozen.TRANSPARENCY_ATTRIBUTE)

	if typeof(attribute) == "number" then
		return (math.clamp(attribute, 0, 1))
	end

	return 0
end

function v:setPartVisible(flag: boolean)
	if self and self.Parent then
		self.LocalTransparencyModifier = 0
		self.Transparency = not flag and 1 or v.getOriginalTransparency(self)
	end
end

function v.isFiniteNumber(value)
	return typeof(value) == "number" and value == value and math.abs(value) < 1000000000000
end

function v.parseArcSchedule(data)
	if typeof(data) ~= "table" then
		return nil
	end

	local duration = data.duration
	local epoch = data.epoch
	local period = data.period
	local phaseStep = data.phaseStep

	if v.isFiniteNumber(duration) and v.isFiniteNumber(epoch) and v.isFiniteNumber(period) and v.isFiniteNumber(phaseStep) and not (duration < 0.1 or period <= duration or period > 30 or phaseStep < 0 or period <= phaseStep) then
		return {
			duration = duration,
			epoch = epoch,
			period = period,
			phaseStep = phaseStep
		}
	end

	return nil
end

function v.createSparkEmitter(parent, color: Color3)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = `{parent.Name}FlyingSparks`
	particleEmitter.Texture = frozen.SPARK_TEXTURE
	particleEmitter.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Brightness = 5
	particleEmitter.Lifetime = NumberRange.new(0.2, 0.46)
	particleEmitter.Rate = frozen.SPARK_RATE
	particleEmitter.Speed = NumberRange.new(7, 15)
	particleEmitter.Drag = 3.5
	particleEmitter.Acceleration = createVector(0, -18, 0)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
	particleEmitter.Rotation = NumberRange.new(0, 360)
	particleEmitter.RotSpeed = NumberRange.new(-320, 320)
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.22),
		NumberSequenceKeypoint.new(0.45, 0.12),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.65, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Enabled = false
	particleEmitter.Parent = parent
	return particleEmitter
end

function v.findEndpoint(p, childName: string)
	local attachment

	if p.repaired then
		attachment = p.repaired:FindFirstChild(childName)
	end

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	local attachment2

	if p.broken then
		attachment2 = p.broken:FindFirstChild(childName)
	end

	if attachment2 and attachment2:IsA("Attachment") then
		return attachment2
	end

	return nil
end

function v.createArcVisual(p)
	local endpoints = {}
	local sparks = {}

	for _, v3 in frozen.CONDUCTORS do
		local endpoint = v.findEndpoint(p, v3.left)
		local endpoint2 = v.findEndpoint(p, v3.right)

		if not (endpoint and endpoint2) then
			return nil
		end

		endpoints[v3.left] = endpoint
		endpoints[v3.right] = endpoint2
		table.insert(sparks, v.createSparkEmitter(endpoint, v3.color))
		table.insert(sparks, v.createSparkEmitter(endpoint2, v3.color))
	end

	return {
		bolts = {},
		cycle = -1,
		endpoints = endpoints,
		isArcing = false,
		sparks = sparks
	}
end

function v.playRandom(list, p)
	if not p then
		return
	end

	sound:Play(list[math.random(#list)], p)
end

function v:setSparkSound(flag: boolean)
	if flag then
		local broken = self.broken

		if self.sparkSound or not broken then
			return
		end

		local sparkSound = sound:Play(frozen.SPARK_SOUND, broken)
		sparkSound.Looped = true
		self.sparkSound = sparkSound
	else
		local sparkSound = self.sparkSound

		if sparkSound then
			self.sparkSound = nil
			sound:FadeOut(sparkSound, frozen.SPARK_SOUND_FADE)
		end
	end
end

function v.setSparksEnabled(p, enabled: boolean)
	for _, spark in p.sparks do
		spark.Enabled = enabled
		spark.Rate = frozen.SPARK_RATE

		if not enabled then
			spark:Clear()
		end
	end
end

function v.spawnArcBolts(p, p2)
	local presentation = p.presentation
	local arcSchedule = p.arcSchedule

	if not (presentation and arcSchedule) then
		return
	end

	for _, v2 in frozen.CONDUCTORS do
		local endpoint = p2.endpoints[v2.left]
		local endpoint2 = p2.endpoints[v2.right]
		local magnitude = (endpoint2.WorldPosition - endpoint.WorldPosition).Magnitude
		local curveSize = math.clamp(magnitude * frozen.ARC_HEIGHT_SCALE, frozen.ARC_HEIGHT_MIN, frozen.ARC_HEIGHT_MAX)
		local v4 = {
			WorldAxis = createVector(0, 1, 0),
			WorldPosition = endpoint.WorldPosition
		}
		local v5 = {
			WorldAxis = createVector(-0, -1, -0),
			WorldPosition = endpoint2.WorldPosition
		}
		local v6 = LightningBoltShafi.new(v4, v5, frozen.BOLT_PARTS, frozen.BOLT_THICKNESS, presentation, v2.color)
		v6.CurveSize0 = curveSize
		v6.CurveSize1 = curveSize
		v6.MinRadius = 0.03
		v6.MaxRadius = math.clamp(magnitude * 0.07, 0.24, 0.45)
		v6.Frequency = 1.45
		v6.AnimationSpeed = 3.2
		v6.MinThicknessMultiplier = 0.7
		v6.MaxThicknessMultiplier = 1.2
		v6.PulseLength = frozen.BOLT_PULSE_LENGTH
		v6.PulseSpeed = (frozen.BOLT_PULSE_LENGTH + 1) / arcSchedule.duration
		v6.FadeLength = 0.38
		v6.ContractFrom = 0.8
		table.insert(p2.bolts, v6)
	end
end

function v.getEndpointColor(p: string)
	for _, v2 in frozen.CONDUCTORS do
		if p == v2.left or p == v2.right then
			return v2.color
		end
	end

	return frozen.SHOCK_COLOR
end

function v.resolveStrikeEndpoint(p, value, vector2: Vector3)
	if typeof(value) == "string" then
		local endpoint = p.endpoints[value]

		if endpoint and endpoint.Parent then
			return endpoint, v.getEndpointColor(value)
		end
	end

	local v2 = 1e999
	local v3 = nil
	local v4 = ""

	for k, endpoint in p.endpoints do
		if not endpoint.Parent then
			continue
		end

		local v5 = (vector2 - endpoint.WorldPosition).Magnitude ^ 2

		if not (v5 < v2) then
			continue
		end

		v4 = k
		v3 = endpoint
		v2 = v5
	end

	return v3, v.getEndpointColor(v4)
end

function v.spawnPlayerStrike(p, p2, p3, p4)
	local presentation = p.presentation
	local arc = p2.arc

	if not (presentation and arc) then
		return
	end

	local strikeEndpoint, v2 = v.resolveStrikeEndpoint(arc, p3, p4.WorldPosition)

	if not strikeEndpoint then
		return
	end

	local magnitude = (p4.WorldPosition - strikeEndpoint.WorldPosition).Magnitude
	local v3 = LightningBoltShafi.new(strikeEndpoint, p4, frozen.BOLT_PARTS, frozen.STRIKE_THICKNESS, presentation, v2)
	v3.CurveSize0 = 0
	v3.CurveSize1 = 0
	v3.MinRadius = 0.12
	v3.MaxRadius = math.clamp(magnitude * 0.08, 0.5, 1)
	v3.Frequency = 1.8
	v3.AnimationSpeed = 4.5
	v3.MinThicknessMultiplier = 0.75
	v3.MaxThicknessMultiplier = 1.3
	v3.PulseLength = frozen.STRIKE_PULSE_LENGTH
	v3.PulseSpeed = (frozen.STRIKE_PULSE_LENGTH + 1) / frozen.STRIKE_DURATION
	v3.FadeLength = 0.3
	v3.ContractFrom = 0.75
	v.trackBolt(p.strikeBolts, v3, frozen.STRIKE_DURATION)
end

function v.setArcActive(p, state, isArcing: boolean, cycle: number)
	if state.isArcing == isArcing and (not isArcing or state.cycle == cycle) then
		return
	end

	v.destroyBolts(state.bolts)
	state.isArcing = isArcing
	state.cycle = cycle

	for _, spark in state.sparks do
		local rate

		if isArcing then
			rate = frozen.SPARK_ARC_RATE
		else
			rate = frozen.SPARK_RATE
		end

		spark.Rate = rate

		if isArcing then
			spark:Emit(frozen.SPARK_BURST)
		end
	end

	if isArcing then
		v.spawnArcBolts(p, state)
	end
end

function v.applyWireVisual(p, data)
	v.setPartVisible(data.broken, not data.repairedState)
	v.setPartVisible(data.repaired, data.repairedState)
	v.setSparkSound(data, not data.repairedState)

	if not data.arc then
		return
	end

	if not data.repairedState then
		v.setSparksEnabled(data.arc, true)
		return
	end

	v.setArcActive(p, data.arc, false, -1)
	v.setSparksEnabled(data.arc, false)
end

function v.getArcState(data, p: number, p2: number)
	local v2 = p2 - data.epoch - (p - 1) * data.phaseStep

	if v2 < 0 then
		return false, -1
	end

	local v3 = math.floor(v2 / data.period)
	return v2 - v3 * data.period < data.duration, v3
end

function v.updateArcs(data)
	local arcSchedule = data.arcSchedule

	if not arcSchedule or not data.presentation or data.finishing then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for _, wire in data.wires do
		local arc = wire.arc

		if not arc then
			continue
		end

		if wire.repairedState then
			v.setArcActive(data, arc, false, -1)
		else
			local arcState, v2 = v.getArcState(arcSchedule, wire.arcIndex, serverTimeNow)
			v.setArcActive(data, arc, arcState, v2)
		end
	end
end

function v:startArcScheduler()
	if self.arcConnection then
		self.arcConnection:Disconnect()
	end

	v.updateArcs(self)
	self.arcConnection = RunService.Heartbeat:Connect(function()
		v.updateArcs(self)
	end)
end

function v.getSetupIds(items)
	if typeof(items) ~= "table" then
		return nil
	end

	local v2 = {}
	local result = {}

	for _, item in items do
		if typeof(item) ~= "string" or v2[item] then
			return nil
		end

		v2[item] = true
		table.insert(result, item)
	end

	table.sort(result)

	if #result > 0 then
		return result
	end

	return nil
end

function v.addPresentationPart(p, instance)
	CollectionService:RemoveTag(instance, frozen.HIT_TAG)
	instance.Anchored = true
	instance.CanCollide = false
	instance.CanQuery = false
	instance.CanTouch = false
	instance.Transparency = 1
	instance.LocalTransparencyModifier = 0
	local attribute = instance:GetAttribute(frozen.ROLE_ATTRIBUTE)

	if attribute == frozen.STATIC_ROLE then
		table.insert(p.staticParts, instance)
		v.setPartVisible(instance, true)
	else
		local attribute2 = instance:GetAttribute(frozen.REPAIR_ATTRIBUTE)
		local v2

		if typeof(attribute2) == "string" then
			v2 = p.wires[attribute2]
		end

		if not v2 then
			return
		end

		if attribute == frozen.BROKEN_ROLE then
			v2.broken = instance
		elseif attribute == frozen.REPAIRED_ROLE then
			v2.repaired = instance
		end
	end
end

function v.buildPresentation(p, state, p2)
	local setupIds = v.getSetupIds(p2)
	local folder = v.waitForNodes()

	if not (setupIds and folder) then
		return false
	end

	v.clearPresentation(state)

	for k, setupId in setupIds do
		state.wires[setupId] = {
			arc = nil,
			arcIndex = k,
			broken = nil,
			proxy = nil,
			repaired = nil,
			revision = 0,
			repairedState = not state.available,
			sparkSound = nil
		}
	end

	local clone = folder:Clone()
	clone.Name = `FountainWirePresentation_{p.Player.UserId}`
	state.presentation = clone
	clone.Parent = workspace

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			v.addPresentationPart(state, part)
		end
	end

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:GetAttribute(frozen.ROLE_ATTRIBUTE) == frozen.BROKEN_ROLE) then
			continue
		end

		local attribute = part:GetAttribute(frozen.REPAIR_ATTRIBUTE)
		local v2

		if typeof(attribute) == "string" then
			v2 = state.wires[attribute]
		end

		if not v2 then
			continue
		end

		table.insert(state.proxies, part)
		v2.proxy = part
		v.setProxyEnabled(part, state.available)
	end

	for k, wire in state.wires do
		if wire.broken and wire.proxy and wire.repaired then
			wire.arc = v.createArcVisual(wire)

			if wire.arc then
				v.applyWireVisual(state, wire)
			else
				warn((`[Fountain Wire Repair] Local presentation is missing Wire5 endpoints for {k}`))
				v.clearPresentation(state)
				return false
			end
		else
			warn((`[Fountain Wire Repair] Local presentation is missing a variant for {k}`))
			v.clearPresentation(state)
			return false
		end
	end

	state.totalWires = #setupIds
	state.repairedCount = 0
	state.finishing = false

	if state.available then
		v.startArcScheduler(state)
	end

	return true
end

function v.retryPresentation(p, state)
	if state.retryPending then
		return
	end

	state.retryPending = true
	task.delay(1, function()
		state.retryPending = false
		local setup = state.setup

		if state.finishing or state.presentation or not setup then
			return
		end

		if not v.buildPresentation(p, state, setup) then
			v.retryPresentation(p, state)
		end
	end)
end

function v:setAvailability(available, p2, p3, p4)
	local state = v.getState(self)

	if typeof(available) ~= "boolean" or typeof(p4) ~= "boolean" then
		return
	end

	v.setStormActive(state, p4)
	local setupIds = v.getSetupIds(p2)

	if not setupIds then
		return
	end

	local arcSchedule

	if available then
		arcSchedule = v.parseArcSchedule(p3)
	end

	if available and not arcSchedule then
		return
	end

	self.Progress = 0
	state.available = available
	state.arcSchedule = arcSchedule
	state.setup = setupIds

	if not v.buildPresentation(self, state, setupIds) then
		v.retryPresentation(self, state)
	end
end

function v:resetProgress(p2, p3)
	local state = v.getState(self)

	if not state.available then
		return
	end

	local setupIds = v.getSetupIds(p2)
	local arcSchedule = v.parseArcSchedule(p3)

	if not (setupIds and arcSchedule) then
		return
	end

	state.arcSchedule = arcSchedule
	state.setup = setupIds

	if not v.buildPresentation(self, state, setupIds) then
		v.retryPresentation(self, state)
	end

	self.Progress = 0
end

function v.flashInstance(p, color: Color3)
	if not (p and p.Parent) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = frozen.FEEDBACK_NAME
	highlight.Adornee = p
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.15
	highlight.OutlineTransparency = 0
	highlight.Parent = p
	local tween = TweenService:Create(highlight, frozen.FEEDBACK_TWEEN_INFO, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	tween.Completed:Once(function()
		tween:Destroy()

		if highlight.Parent then
			highlight:Destroy()
		end
	end)
	tween:Play()
end

function v:handleWireHit(value, revision, value2, value3)
	local state = v.getState(self)
	local v2

	if typeof(value) == "string" then
		v2 = state.wires[value]
	end

	if not state.available or state.finishing or not v2 or v2.repairedState or typeof(revision) ~= "number" or revision % 1 ~= 0 or revision <= v2.revision or typeof(value2) ~= "number" or value2 % 1 ~= 0 or value2 ~= state.repairedCount + 1 or typeof(value3) ~= "number" or value3 % 1 ~= 0 or value3 ~= state.totalWires or value3 < value2 then
		return
	end

	v2.revision = revision
	v2.repairedState = true
	state.repairedCount = value2
	self.Progress = value2

	if v2.proxy then
		v.setProxyEnabled(v2.proxy, false)
	end

	v.applyWireVisual(state, v2)
	local repaired = v2.repaired or v2.broken
	v.playRandom(frozen.HIT_SOUNDS, repaired)
	v.flashInstance(repaired, frozen.REPAIRED_COLOR)
end

function v.handleElectrocuted(p, value, p2)
	local state = v.getState(p)
	local v2

	if typeof(value) == "string" then
		v2 = state.wires[value]
	end

	if not state.available or state.finishing or not v2 or v2.repairedState then
		return
	end

	if v2.arc then
		for _, spark in v2.arc.sparks do
			spark:Emit(frozen.SPARK_BURST * 2)
		end
	end

	v.flashInstance(v2.broken, frozen.SHOCK_COLOR)
	local character = p.Player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	v.playRandom(frozen.SHOCK_SOUNDS, humanoidRootPart)
	v.flashInstance(character, frozen.SHOCK_COLOR)
	local attachment = Instance.new("Attachment")
	attachment.Name = "FountainWireElectrocution"
	attachment.Parent = humanoidRootPart
	v.spawnPlayerStrike(state, v2, p2, attachment)

	for _, v3 in frozen.CONDUCTORS do
		local sparkEmitter = v.createSparkEmitter(attachment, v3.color)
		sparkEmitter.Rate = 0
		sparkEmitter:Emit(frozen.SPARK_BURST * 2)
	end

	task.delay(0.75, function()
		if attachment.Parent then
			attachment:Destroy()
		end
	end)
end

function v:playFinale(p2)
	local state = v.getState(self)

	if not state.available or state.finishing then
		return
	end

	if p2 == true then
		state.repairedCount = state.totalWires
		self.Progress = state.totalWires

		for _, wire in state.wires do
			wire.repairedState = true

			if wire.proxy then
				v.setProxyEnabled(wire.proxy, false)
			end

			v.applyWireVisual(state, wire)
		end
	end

	if state.repairedCount ~= state.totalWires then
		return
	end

	state.finishing = true
	v.setStormActive(state, false)

	if state.arcConnection then
		state.arcConnection:Disconnect()
		state.arcConnection = nil
	end

	for _, proxy in state.proxies do
		v.setProxyEnabled(proxy, false)
	end

	for _, staticPart in state.staticParts do
		v.flashInstance(staticPart, frozen.FINALE_COLOR)
	end

	for _, wire in state.wires do
		if wire.arc then
			v.setArcActive(state, wire.arc, false, -1)
		end

		v.flashInstance(wire.repaired, frozen.FINALE_COLOR)
	end
end

local FountainWireRepair = {}
FountainWireRepair.Repeatable = true

function FountainWireRepair.OnLoad(object)
	v.getState(object)
	object:FireServer("Initialize")
end

function FountainWireRepair.OnComplete(p)
	p.Progress = 0
	v.resetState(v.getState(p))
end

FountainWireRepair.RemoteEvents = {
	Reset = function(p)
		p.Progress = 0
		v.resetState(v.getState(p))
	end,
	Availability = function(p, p2, p3, p4, p5)
		v.setAvailability(p, p2, p3, p4, p5)
	end,
	ResetProgress = function(p, p2, p3)
		v.resetProgress(p, p2, p3)
	end,
	WireHit = function(p, p2, p3, p4, p5)
		v.handleWireHit(p, p2, p3, p4, p5)
	end,
	Electrocuted = function(p, p2, p3)
		v.handleElectrocuted(p, p2, p3)
	end,
	Finale = function(p, p2)
		v.playFinale(p, p2)
	end
}
return FountainWireRepair