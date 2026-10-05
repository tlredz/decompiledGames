local createVector = vector.create
local Graph = require(script.Parent.Parent.Graph)
local Range = require(script.Parent.Parent.Range)
local PartConstants = require(script.Parent.Parent.PartConstants)
local directionVectors = PartConstants.DirectionVectors
local cframe = CFrame.new(1000000000, 1000000000, 1000000000)
local PDataBuilder = {}

local function rollRange(p)
	return Range.RandomValueFromRange(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rollAxis(p, p2, i, p3)
	if p2 and p3 > 0 then
		return p.Min + (p.Max - p.Min) * ((i - 0.5) / p3)
	end

	return Range.RandomValueFromRange(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randomAxis()
	local vector2 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)

	if vector2.Magnitude < 0.001 then
		return createVector(0, 1, 0)
	end

	return vector2.Unit
end

local function launchDir(data, p, i, p2)
	local v = directionVectors[data.EmissionDirection] or directionVectors[Enum.NormalId.Top]
	local vector2 = CFrame.new()[v.vector] * v.multiplier

	if data.BurstMode == "Ring" then
		local cross = vector2:Cross(createVector(1, 0, 0))

		if cross.Magnitude < 0.01 then
			cross = vector2:Cross(createVector(0, 0, 1))
		end

		local unit = cross.Unit
		local cross2 = vector2:Cross(unit)
		local v2 = (i - 0.5) / p2 * 2 * 3.141592653589793 + (math.random() - 0.5) * 0.2
		local X = math.rad(data.SpreadAngle.X)
		local v3 = (unit * math.cos(v2) + cross2 * math.sin(v2)) * math.cos(X) + vector2 * math.sin(X)
		return p.Rotation:VectorToWorldSpace(v3)
	else
		local spreadAngle = data.SpreadAngle or Vector2.new(0, 0)
		local cframe2 = CFrame.lookAt(createVector(0, 0, 0), vector2)

		if spreadAngle.X > 0 or spreadAngle.Y > 0 then
			cframe2 *= CFrame.Angles(
				math.rad((math.random() * 2 - 1) * spreadAngle.X),
				math.rad((math.random() * 2 - 1) * spreadAngle.Y),
				0
			)
		end

		return p.Rotation:VectorToWorldSpace(cframe2.LookVector)
	end
end

function PDataBuilder:rollChunks(data, data2, p2)
	local v = not (data.RenderTemplate and data.RenderTemplate:IsA("BasePart")) and createVector(1, 1, 1) or data.RenderTemplate.Size or createVector(
		1,
		1,
		1
	)
	local chunkCount = data.ChunkCount
	local chunkCount2 = math.clamp(math.floor(Range.RandomValueFromRange(chunkCount) + 0.5), 1, data2.chunkCap)
	self._chunkCount = chunkCount2
	local curScale = not data.Scale and 1 or Graph.QueryPointsWithTime(0, data.Scale, self.Seeds.Scale) or 1
	self._curScale = curScale

	for i = 1, data2.chunkCap do
		local part = data2.parts[i]

		if i <= chunkCount2 then
			local v4 = rollAxis(data.PosX, data.PosXEven, i, chunkCount2) -- equivalent call inferred; original call site unknown
			local v5 = rollAxis(data.PosY, data.PosYEven, i, chunkCount2) -- equivalent call inferred; original call site unknown
			local v6 = rollAxis(data.PosZ, data.PosZEven, i, chunkCount2) -- equivalent call inferred; original call site unknown
			local position

			if data.PosMode == "Global" then
				position = p2.Position + Vector3.new(v4, v5, v6)
			else
				position = (p2 * CFrame.new(v4, v5, v6)).Position
			end

			local baseSize = data2.baseSize
			local chunkScale = data.ChunkScale
			baseSize[i] = v * Range.RandomValueFromRange(chunkScale)
			data2.halfExt[i] = data2.baseSize[i] * 0.5
			local v7 = not data.Speed and 0 or Graph.QueryPointsWithTime(0, data.Speed, Graph.GenerateSeed(data.Speed)) or 0
			local v8 = launchDir(data, p2, i, chunkCount2) * v7
			local v9 = randomAxis() -- equivalent call inferred; original call site unknown
			local tumbleSpeed = data.TumbleSpeed
			local v10 = math.rad((Range.RandomValueFromRange(tumbleSpeed))) * (math.random() < 0.5 and -1 or 1)
			local cframe2 = CFrame.Angles(math.random() * 6.283, math.random() * 6.283, math.random() * 6.283)
			data2.launchVel[i] = v8
			data2.launchAng[i] = v9 * v10
			data2.spawnPos[i] = position
			data2.spawnRot[i] = cframe2
			data2.trajs[i] = nil
			local bounciness = data2.bounciness
			local bounciness2 = data.Bounciness
			bounciness[i] = math.clamp(Range.RandomValueFromRange(bounciness2), 0, 1)
			data2.touched[i] = false
			data2.writeCFs[i] = cframe2 + position
			local v11 = part
			local v12 = i
			pcall(function()
				v11.Size = data2.baseSize[v12] * math.max(curScale, 0.01)
				v11.CFrame = cframe2 + position
			end)
		else
			local v4 = part
			pcall(function()
				v4.Anchored = true
				v4.CanCollide = false
				v4.CanTouch = false
				v4.CFrame = cframe
			end)
			data2.launchVel[i] = createVector(0, 0, 0)
			data2.launchAng[i] = createVector(0, 0, 0)
			data2.spawnPos[i] = cframe.Position
			data2.spawnRot[i] = CFrame.identity
			data2.trajs[i] = nil
			data2.touched[i] = false
			data2.writeCFs[i] = cframe
		end
	end
end

function PDataBuilder.build(sourceItem, data, visualPart, rig, lifeTime, data2, p5)
	local seeds = {
		Scale = Graph.GenerateSeed(data.Scale),
		Brightness = Graph.GenerateSeed(data.Brightness),
		Transparency = Graph.GenerateSeed(data.Transparency),
		Timescale = Graph.GenerateSeed(data.Timescale)
	}
	local v2 = {
		Type = "Rocks",
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
			Scale = data.Scale,
			Brightness = data.Brightness,
			Transparency = data.Transparency,
			Timescale = data.Timescale,
			Color = data.Color
		},
		Seeds = seeds,
		_effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime),
		_gravity = data.Gravity or 196.2,
		_friction = math.clamp(data.Friction or 0.3, 0, 1),
		_sinkOut = data.SinkOut ~= false,
		_inheritFloor = data.InheritFloor == true,
		_hitFired = false,
		_ownsOnHit = true
	}
	local v3 = nil

	if data2 then
		local v4

		if data2.EventOriginResolver then
			v4 = data2.EventOriginResolver()
		end

		local v5 = v4 or data2.EventOriginCF

		if v5 then
			v3 = data2.UseFullOrigin and v5 or CFrame.new(v5.Position) * sourceItem.CFrame.Rotation
		end
	end

	if not v3 and p5 and p5.Parent then
		v3 = PartConstants.resolveLinkCFrame(p5)
	end

	PDataBuilder.rollChunks(v2, data, rig, v3 or sourceItem.CFrame)
	return v2
end

return PDataBuilder