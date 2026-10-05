local createVector = vector.create
local Graph = require(script.Parent.Parent.Graph)
local Range = require(script.Parent.Parent.Range)
local PartConstants = require(script.Parent.Parent.PartConstants)
local Turbulence = require(script.Parent.Parent.Turbulence)
local AxisLinks = require(script.Parent.Parent.AxisLinks)
local Anchors = require(script.Parent.Anchors)
local directionVectors = PartConstants.DirectionVectors
local PDataBuilder = {}

local function liveGraph(p)
	if not p or Graph.IsStatic(p) and Graph.GetStaticValue(p, 0) == 0 then
		return nil
	end

	return p
end

function PDataBuilder:readRopeParams(data, p, p2)
	self._pinMode = data.PinMode or "BothEnds"
	self._target = data.Target
	self._pinStart = true
	self._pinEnd = self._pinMode == "BothEnds" and data.Target ~= nil or self._pinMode == "Launch"
	self._segCount = math.clamp(math.floor(Range.RandomValueFromRange(data.SegmentCount) + 0.5), 2, p.segCap)
	self._stiffness = math.clamp(math.floor((data.Stiffness or 4) + 0.5), 1, 10)
	self._bendStiffness = math.clamp(data.BendStiffness or 0, 0, 1)
	self._damping = math.clamp(data.Damping or 0.03, 0, 0.5)
	self._gravity = data.Gravity or createVector(0, -40, 0)
	self._windAmp = Range.RandomValueFromRange(data.WindAmplitude)
	self._windFreq = data.WindFrequency or 2
	self._growIn = math.clamp(data.GrowIn or 0, 0, 0.9)
	self._deathMode = data.DeathMode or "None"
	self._deathWindow = math.clamp(data.DeathWindow or 0.2, 0.05, 0.9)
	local thicknessProfile = data.ThicknessProfile
	local v = not thicknessProfile or Graph.IsStatic(thicknessProfile)
	local v2

	if not v then
		v2 = Graph.GenerateSeed(thicknessProfile) or nil
	end

	for i = 1, p.segCap do
		if v then
			p.widthScale[i] = not thicknessProfile and 1 or Graph.GetStaticValue(thicknessProfile, 1) or 1
		else
			p.widthScale[i] = math.max(Graph.QueryPointsWithTime((i - 0.5) / p.segCap, thicknessProfile, v2), 0.05)
		end
	end

	self._motionTarget = data.MotionTarget or "Start"
	self._dispMode = data.DisplacementMode or "Global"
	local posOffsetX = data.PosOffsetX

	if posOffsetX then
		if Graph.IsStatic(posOffsetX) and Graph.GetStaticValue(posOffsetX, 0) == 0 then
			posOffsetX = nil
		end
	else
		posOffsetX = nil
	end

	local posOffsetY = data.PosOffsetY

	if posOffsetY then
		if Graph.IsStatic(posOffsetY) and Graph.GetStaticValue(posOffsetY, 0) == 0 then
			posOffsetY = nil
		end
	else
		posOffsetY = nil
	end

	local posOffsetZ = data.PosOffsetZ

	if posOffsetZ then
		if Graph.IsStatic(posOffsetZ) and Graph.GetStaticValue(posOffsetZ, 0) == 0 then
			posOffsetZ = nil
		end
	else
		posOffsetZ = nil
	end

	self.Graphs.PosOffsetX = posOffsetX
	self.Graphs.PosOffsetY = posOffsetY
	self.Graphs.PosOffsetZ = posOffsetZ
	self._hasDisp = (posOffsetX or posOffsetY or posOffsetZ) ~= nil

	if posOffsetX then
		self.Seeds.PosOffsetX = self.Seeds.PosOffsetX or Graph.GenerateSeed(posOffsetX)
	end

	if posOffsetY then
		self.Seeds.PosOffsetY = self.Seeds.PosOffsetY or Graph.GenerateSeed(posOffsetY)
	end

	if posOffsetZ then
		self.Seeds.PosOffsetZ = self.Seeds.PosOffsetZ or Graph.GenerateSeed(posOffsetZ)
	end

	local live = Turbulence.isLive(data.Turbulence)
	self.Graphs.Turbulence = live
	self._hasTurb = live ~= nil

	if live then
		self.Seeds.Turbulence = self.Seeds.Turbulence or Graph.GenerateSeed(live)
		self._turbFreq = data.TurbulenceFrequency or 1
		self._turbSeed = self._turbSeed or math.random() * 997 + 0.5
	end

	local rangeAxes = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, p2)
	local rotation = PartConstants.composeRotation(
		data.RotOrder or "Global",
		rangeAxes.RotX or 0,
		rangeAxes.RotY or 0,
		rangeAxes.RotZ or 0
	)
	self._spawnRot = rotation
	local rangeAxes2 = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "PosX", "PosY", "PosZ" }, Range, p2)
	self._spawnOff = Vector3.new(rangeAxes2.PosX or 0, rangeAxes2.PosY or 0, rangeAxes2.PosZ or 0)
	self._spawnOffMode = data.PosMode or "Local"
	self._spawnTarget = data.SpawnTarget or "Start"
	local start = Anchors.resolveStart(self)
	local spreadAngle = data.SpreadAngle or Vector2.new(0, 0)

	local function composeDir(p3)
		local v3 = directionVectors[p3] or directionVectors[Enum.NormalId.Front]
		local v4 = CFrame.new()[v3.vector] * v3.multiplier
		local v5 = CFrame.lookAt(createVector(0, 0, 0), v4) * rotation

		if spreadAngle.X > 0 or spreadAngle.Y > 0 then
			v5 *= CFrame.Angles(
				math.rad((math.random() * 2 - 1) * spreadAngle.X),
				math.rad((math.random() * 2 - 1) * spreadAngle.Y),
				0
			)
		end

		return start.Rotation:VectorToWorldSpace(v5.LookVector)
	end

	self._motionDir = composeDir(data.EmissionDirection)
	self._speedDir = composeDir(data.MotionDirection or data.EmissionDirection)
	local speed = data.Speed

	if speed then
		if Graph.IsStatic(speed) and Graph.GetStaticValue(speed, 0) == 0 then
			speed = nil
		end
	else
		speed = nil
	end

	self.Graphs.Speed = speed

	if speed then
		self.Seeds.Speed = self.Seeds.Speed or Graph.GenerateSeed(speed)
	end

	self._accel = data.Acceleration or createVector(0, 0, 0)
	self._drag = data.Drag or 0
	self._hasMotion = speed ~= nil or self._accel.Magnitude > 0
	self._motionOffset = createVector(0, 0, 0)
	self._motionAccelVel = createVector(0, 0, 0)

	if self._pinMode == "Launch" then
		local v3 = math.max(Range.RandomValueFromRange(data.LaunchSpeed), 1)
		self._launchOrigin = start.Position
		self._launchT = nil
		local position = nil

		if data.Target then
			local success, result = pcall(PartConstants.resolveLinkCFrame, data.Target)

			if success and result then
				position = result.Position
			end
		end

		if position then
			local v4 = position - start.Position
			local launchT = math.max(v4.Magnitude / v3, 0.05)
			self._launchVel = v4 * (1 / launchT) - self._gravity * (launchT * 0.5)
			self._launchT = launchT
		else
			self._launchVel = self._motionDir * v3
		end
	end

	local randomValueFromRange = Range.RandomValueFromRange(data.RopeLength)

	if randomValueFromRange <= 0 then
		local v3 = math.max(data.Slack or 1.2, 1)
		local v4 = 10

		if (self._pinMode == "BothEnds" or self._pinMode == "Launch") and data.Target then
			local success, result = pcall(PartConstants.resolveLinkCFrame, data.Target)

			if success and result then
				v4 = math.max((result.Position - start.Position).Magnitude, 1)
			end
		end

		randomValueFromRange = v4 * v3
	end

	self._restLen = math.max(randomValueFromRange / self._segCount, 0.05)
end

function PDataBuilder.build(sourceItem, data, visualPart, rig, lifeTime, data2, parentLink)
	local seeds = {
		Brightness = Graph.GenerateSeed(data.Brightness),
		Transparency = Graph.GenerateSeed(data.Transparency),
		Thickness = Graph.GenerateSeed(data.Thickness),
		Timescale = Graph.GenerateSeed(data.Timescale)
	}
	local v2 = {
		Type = "Rope",
		VisualPart = visualPart,
		_rig = rig,
		Events = data.Events,
		StartTime = os.clock(),
		TotalKeyFrames = math.max(1, data.TotalKeyFrames),
		CurrentStep = 0,
		LifeTime = lifeTime,
		PartLife = data.PartLife or 0,
		_sourceItem = sourceItem,
		Graphs = {
			Color = data.Color,
			Brightness = data.Brightness,
			Transparency = data.Transparency,
			Thickness = data.Thickness,
			Timescale = data.Timescale
		},
		Seeds = seeds,
		_effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime),
		_parentLink = parentLink,
		_accum = 0,
		_windPhase = 0,
		_windSeedA = math.random() * 1000,
		_windSeedB = 500 + math.random() * 1000
	}

	if data2 then
		local v3

		if data2.EventOriginResolver then
			v3 = data2.EventOriginResolver()
		end

		local v4 = v3 or data2.EventOriginCF

		if v4 then
			v2._startCFOverride = data2.UseFullOrigin and v4 or CFrame.new(v4.Position) * sourceItem.CFrame.Rotation
		end
	end

	PDataBuilder.readRopeParams(v2, data, rig, data2)
	v2._launchArrived = false
	v2._released = false
	return v2
end

return PDataBuilder