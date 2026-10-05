local createVector = vector.create
local Graph = require(script.Parent.Parent.Graph)
local Range = require(script.Parent.Parent.Range)
local AxisLinks = require(script.Parent.Parent.AxisLinks)
local PartConstants = require(script.Parent.Parent.PartConstants)
local Turbulence = require(script.Parent.Parent.Turbulence)
local Endpoints = require(script.Parent.Endpoints)
local directionVectors = PartConstants.DirectionVectors
local PDataBuilder = {
	liveGraph = function(p)
		if not p or Graph.IsStatic(p) and Graph.GetStaticValue(p, 0) == 0 then
			return nil
		end

		return p
	end,
	liveColor = function(sequence)
		if not sequence or typeof(sequence) ~= "ColorSequence" then
			return nil
		end

		local keypoints = sequence.Keypoints

		if #keypoints <= 1 then
			local value = keypoints[1] and keypoints[1].Value

			if not value or value.R > 0.999 and value.G > 0.999 and value.B > 0.999 then
				return nil
			end
		end

		return sequence
	end
}

function PDataBuilder.build(sourceItem, state, visualPart, rig, lifeTime, p5)
	state.Speed = PDataBuilder.liveGraph(state.Speed)
	state.PosOffsetX = PDataBuilder.liveGraph(state.PosOffsetX)
	state.PosOffsetY = PDataBuilder.liveGraph(state.PosOffsetY)
	state.PosOffsetZ = PDataBuilder.liveGraph(state.PosOffsetZ)
	state.Turbulence = Turbulence.isLive(state.Turbulence)
	local seeds = {
		Brightness = Graph.GenerateSeed(state.Brightness),
		Transparency = Graph.GenerateSeed(state.Transparency),
		Thickness = Graph.GenerateSeed(state.Thickness),
		Timescale = Graph.GenerateSeed(state.Timescale),
		Speed = Graph.GenerateSeed(state.Speed),
		PosOffsetX = Graph.GenerateSeed(state.PosOffsetX),
		PosOffsetY = Graph.GenerateSeed(state.PosOffsetY),
		PosOffsetZ = Graph.GenerateSeed(state.PosOffsetZ),
		Turbulence = Graph.GenerateSeed(state.Turbulence)
	}
	AxisLinks.applyGraphAxisAliases(state, seeds, state.AxisLinks)
	local acceleration = state.Acceleration or createVector(0, 0, 0)
	local v2 = {
		Type = "Lightning",
		VisualPart = visualPart,
		_rig = rig,
		Events = state.Events,
		StartTime = os.clock(),
		TotalKeyFrames = math.max(1, state.TotalKeyFrames),
		CurrentStep = 0,
		LifeTime = lifeTime,
		PartLife = state.PartLife or 0,
		_sourceItem = sourceItem,
		Graphs = {
			Color = state.Color,
			Gradient = PDataBuilder.liveColor(state.Gradient),
			Brightness = state.Brightness,
			Transparency = state.Transparency,
			Thickness = state.Thickness,
			Timescale = state.Timescale,
			Speed = state.Speed,
			PosOffsetX = state.PosOffsetX,
			PosOffsetY = state.PosOffsetY,
			PosOffsetZ = state.PosOffsetZ,
			Turbulence = state.Turbulence
		},
		Seeds = seeds,
		_effectiveElapsed = Graph.InitialEffectiveElapsed(state.Timescale, seeds.Timescale, lifeTime),
		_endpointMode = state.TargetMode == "Seek" and "Seek" or state.TargetMode == "Point" and state.Target and state.Target.Parent and "Point" or "Directional",
		_target = state.Target,
		_seekRadius = math.max(Range.RandomValueFromRange(state.SeekRadius), 1),
		_seekRetarget = state.SeekRetarget == true,
		_seekBias = math.clamp(state.SeekBias or 0, 0, 1),
		_retargetSpeed = math.max(state.RetargetSpeed or 0, 0),
		_ownsOnHit = true,
		_length = math.max(0.1, Range.RandomValueFromRange(state.Length)),
		_segCount = math.clamp(math.floor(Range.RandomValueFromRange(state.SegmentCount) + 0.5), 2, rig.mainSegs),
		_amplitude = Range.RandomValueFromRange(state.Amplitude),
		_decay = Range.RandomValueFromRange(state.AmplitudeDecay),
		_forkChance = Range.RandomValueFromRange(state.ForkChance),
		_forkDepth = math.floor(Range.RandomValueFromRange(state.ForkDepth) + 0.5),
		_forkLenScale = Range.RandomValueFromRange(state.ForkLengthScale),
		_sag = Range.RandomValueFromRange(state.Sag),
		_sagShape = Range.RandomValueFromRange(state.SagShape),
		_shapeMode = state.ShapeMode or "Jitter",
		_scrollSpeed = Range.RandomValueFromRange(state.ScrollSpeed),
		_waves = math.max(0.25, Range.RandomValueFromRange(state.Waves)),
		_scrollPhase = 0,
		_noiseSeedA = math.random() * 1000,
		_noiseSeedB = 500 + math.random() * 1000,
		_jitterAccum = 0,
		_lSpeed = state.GrowthSpeed or 0,
		_growReversed = (state.GrowthSpeed or 0) < 0,
		_tipDist = 0,
		_revealPtr = 0,
		_nestedAlive = { true },
		_accel = acceleration,
		_drag = state.Drag or 0,
		_dispMode = state.DisplacementMode or "Global",
		_motionOffset = createVector(0, 0, 0),
		_motionAccelVel = createVector(0, 0, 0),
		_hasMotion = state.Speed ~= nil or acceleration.Magnitude > 0,
		_hasDisp = state.PosOffsetX ~= nil or state.PosOffsetY ~= nil or state.PosOffsetZ ~= nil,
		_hasTurb = state.Turbulence ~= nil,
		_turbFreq = state.TurbulenceFrequency or 1,
		_turbSeed = math.random() * 997 + 0.5,
		_turbRaw = nil
	}
	local randomValueFromRange = Range.RandomValueFromRange(state.JitterRate)
	v2._jitterInterval = randomValueFromRange > 0 and 1 / randomValueFromRange or 1e999
	local v3 = directionVectors[state.EmissionDirection] or directionVectors[Enum.NormalId.Top]
	local v4 = CFrame.new()[v3.vector] * v3.multiplier
	local spreadAngle = state.SpreadAngle or Vector2.new(0, 0)
	local rangeAxes = AxisLinks.sampleRangeAxes(state, state.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, p5)
	local rotation = PartConstants.composeRotation(
		state.RotOrder or "Global",
		rangeAxes.RotX or 0,
		rangeAxes.RotY or 0,
		rangeAxes.RotZ or 0
	)
	local cframe = CFrame.lookAt(createVector(0, 0, 0), v4)

	if state.DirMode == "Local" then
		cframe *= rotation
	end

	if spreadAngle.X > 0 or spreadAngle.Y > 0 then
		cframe *= CFrame.Angles(
			math.rad((math.random() * 2 - 1) * spreadAngle.X),
			math.rad((math.random() * 2 - 1) * spreadAngle.Y),
			0
		)
	end

	v2._dirLocalVec = cframe.LookVector
	v2._dirGlobal = state.DirMode == "Global"
	v2._originRot = rotation
	local rangeAxes2 = AxisLinks.sampleRangeAxes(state, state.AxisLinks, { "PosX", "PosY", "PosZ" }, Range, p5)
	local posX = rangeAxes2.PosX or 0
	local posY = rangeAxes2.PosY or 0
	local posZ = rangeAxes2.PosZ or 0

	if posX == 0 and posY == 0 and posZ == 0 then
		v2._originOffset = nil
	else
		v2._originOffset = Vector3.new(posX, posY, posZ)
		v2._originOffsetGlobal = state.PosMode == "Global"
	end

	Endpoints.sampleShape(v2, state, sourceItem)
	return v2
end

return PDataBuilder