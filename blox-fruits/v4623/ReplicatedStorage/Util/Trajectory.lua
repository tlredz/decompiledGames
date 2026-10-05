local createVector = vector.create
local Type = require(game.ReplicatedStorage.Packages.Type)
local PhysicsUtil = require(game.ReplicatedStorage.Packages.PhysicsUtil)
local ConversionUtil = require(game.ReplicatedStorage.Packages.ConversionUtil)
local strictInterface = Type.strictInterface({
	HighestPoint = Type.Vector3,
	GroundPoint = Type.Vector3,
	GroundPointOffsetX = Type.number,
	HighestPointOffsetY = Type.number,
	TargetOffsetX = Type.number,
	TargetOffsetY = Type.number,
	ArcLength = Type.number,
	AimDegrees = Type.number
})
local strictInterface2 = Type.strictInterface({
	Type = Type.literal("AimData"),
	Origin = Type.CFrame,
	Target = Type.Vector3,
	InitialVelocity = Type.Vector3,
	Arc = Type.optional(strictInterface)
})
local metersPerSecondSquared = ConversionUtil.Acceleration.Roblox.toMetersPerSecondSquared(-workspace.Gravity)

function getOrigin(vector2: Vector3, vector3: Vector3)
	return CFrame.lookAt(vector2 * createVector(1, 0, 1), vector3 * createVector(1, 0, 1)) + Vector3.new(
		0,
		vector2.Y,
		0
	)
end

function getInitialVelocityXY_m(p: number, p2: number, p3: number)
	local initialVelocityAtDistanceFromVelocityAndAcceleration = PhysicsUtil.getInitialVelocityAtDistanceFromVelocityAndAcceleration(
		0,
		p3,
		metersPerSecondSquared
	)
	local timeAtDistance = PhysicsUtil.getTimeAtDistance(initialVelocityAtDistanceFromVelocityAndAcceleration, 0, p3)
	return p / (p / p2 * timeAtDistance), initialVelocityAtDistanceFromVelocityAndAcceleration
end

function getInitialVelocity_rbx(vector2: Vector3, vector3: Vector3, p: number, p2: number, p3: number)
	local initialVelocityXY_m, v = getInitialVelocityXY_m(p, p2, p3)
	local vector4 = Vector3.new(
		0,
		ConversionUtil.Velocity.MetersPerSecond.toRoblox(v),
		-ConversionUtil.Velocity.MetersPerSecond.toRoblox(initialVelocityXY_m)
	)
	local unit = vector4.Unit
	return getOrigin(vector2, vector3):VectorToWorldSpace(unit) * vector4.Magnitude
end

local Trajectory = {
	MAX_ITERATIONS = 18,
	Types = {
		AimData = strictInterface2
	}
}

function Trajectory.getTrajectorySolver(p: number, targetY: number, value: number, p3: number?, flag: boolean?)
	local targetX = math.max(p ~= p and 0 or p, 2)
	local v2 = math.clamp(value, -80, 80)
	local v3

	if p3 then
		v3 = p3 + 1

		if v3 >= 18 then
			v2 = 80
		else
			v2 = math.clamp(value + (80 - value) * (v3 / 18), -80, 80)
		end
	else
		v3 = 0
	end

	local v4 = math.rad(v2)
	local v5 = math.sqrt((targetX - 0) ^ 2 + (targetY - 0) ^ 2) * 0.5
	local v6 = math.cos(v4) * v5
	local v7 = math.sin(v4) * v5
	local v8 = v6 ^ 2
	local v9 = v7 - 0
	local v10 = targetY - 0
	local v11 = targetX ^ 2
	local v12 = -v6 / targetX
	local v13 = (v12 * v10 + v9) / (v12 * v11 + v8)

	if v13 > 0 and v2 < 90 and v3 < 18 and flag ~= true then
		return Trajectory.getTrajectorySolver(targetX, targetY, value, v3)
	end

	local v14 = (v9 - v13 * v8) / v6

	-- equivalent calls inferred from this helper; original call sites unknown
	local function formula(p4: number)
		return v13 * p4 ^ 2 + v14 * p4 + 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function derivative(p4: number)
		return v13 * 2 * p4 + v14
	end

	local function arcLengthAntiderivative(p4: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function F(p5)
			local v15 = derivative(p5) -- equivalent call inferred; original call site unknown
			local v16 = math.sqrt(1 + v15 ^ 2)
			return (v15 * v16 + math.log(v15 + v16)) / (v13 * 4)
		end

		local v15 = F(p4) -- equivalent call inferred; original call site unknown
		return (math.abs(v15 - F(0)))
	end

	local function arcAreaAntiderivative(p4: number)
		return v13 / 3 * p4 ^ 3 + v14 / 2 * p4 ^ 2 + p4 * 0
	end

	local groundX = -v14 / v13
	local highestPointX = groundX / 2

	if highestPointX < 0 and v3 < 18 and flag ~= true then
		return Trajectory.getTrajectorySolver(targetX, targetY, value, v3)
	end

	local highestPointY = formula(highestPointX) -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function F(p4)
		local v18 = derivative(p4) -- equivalent call inferred; original call site unknown
		local v19 = math.sqrt(1 + v18 ^ 2)
		return (v18 * v19 + math.log(v18 + v19)) / (v13 * 4)
	end

	local v18 = F(targetX) -- equivalent call inferred; original call site unknown
	local v19 = math.abs(v18 - F(0))

	if targetX * 2 < v19 and v3 < 18 and flag ~= true or targetX < highestPointX and v3 < 18 and flag ~= true then
		return Trajectory.getTrajectorySolver(targetX, targetY, value, v3)
	end

	local v20 = {
		TargetX = targetX,
		TargetY = targetY,
		AimDegrees = math.deg(v4),
		HighestPointY = highestPointY,
		HighestPointX = highestPointX,
		GroundX = groundX,
		Iterations = v3 or 0,
		Length = 0,
		getY = 0,
		getDervative = 0,
		getArcLength = 0,
		getArcArea = 0
	}

	local function F2(p4)
		local v21 = derivative(p4) -- equivalent call inferred; original call site unknown
		local v22 = math.sqrt(1 + v21 ^ 2)
		return (v21 * v22 + math.log(v21 + v22)) / (v13 * 4)
	end

	local v21 = derivative(targetX) -- equivalent call inferred; original call site unknown
	local v22 = math.sqrt(1 + v21 ^ 2)
	local v23 = (v21 * v22 + math.log(v21 + v22)) / (v13 * 4)
	local v24 = derivative(0) -- equivalent call inferred; original call site unknown
	local v25 = math.sqrt(1 + v24 ^ 2)
	v20.Length = math.abs(v23 - (v24 * v25 + math.log(v24 + v25)) / (v13 * 4))
	v20.getY = formula
	v20.getDervative = derivative
	v20.getArcLength = arcLengthAntiderivative
	v20.getArcArea = arcAreaAntiderivative
	table.freeze(v20)
	return v20
end

function Trajectory.getArcAim(vector2: Vector3, vector3: Vector3)
	local meter = ConversionUtil.Length.Roblox.toMeter(((vector3 - vector2) * createVector(1, 0, 1)).Magnitude)
	local meter2 = ConversionUtil.Length.Roblox.toMeter((vector3 - vector2).Y)
	local trajectorySolver = Trajectory.getTrajectorySolver(meter, meter2, 20)

	if trajectorySolver.Iterations >= 18 then
		trajectorySolver = Trajectory.getTrajectorySolver(meter, meter2, -80)
	end

	local initialVelocity_rbx = getInitialVelocity_rbx(
		vector2,
		vector3,
		trajectorySolver.TargetX,
		trajectorySolver.HighestPointX,
		trajectorySolver.HighestPointY
	)
	local unit = ((vector3 - vector2) * createVector(1, 0, 1)).Unit
	return {
		Type = "AimData",
		Origin = getOrigin(vector2, vector3),
		Target = vector3,
		InitialVelocity = initialVelocity_rbx,
		Arc = {
			HighestPoint = vector2 + unit * ConversionUtil.Length.Meter.toRoblox(trajectorySolver.GroundX) + createVector(
				0,
				1,
				0
			) * ConversionUtil.Length.Meter.toRoblox(trajectorySolver.HighestPointY),
			GroundPoint = vector2 + unit * ConversionUtil.Length.Meter.toRoblox(trajectorySolver.GroundX),
			GroundPointOffsetX = ConversionUtil.Length.Meter.toRoblox(trajectorySolver.GroundX),
			HighestPointOffsetY = ConversionUtil.Length.Meter.toRoblox(trajectorySolver.HighestPointY),
			TargetOffsetX = ConversionUtil.Length.Meter.toRoblox(trajectorySolver.TargetX),
			TargetOffsetY = ConversionUtil.Length.Meter.toRoblox(trajectorySolver.TargetY),
			ArcLength = ConversionUtil.Length.Meter.toRoblox(trajectorySolver.Length),
			AimDegrees = trajectorySolver.AimDegrees
		}
	}, trajectorySolver
end

function Trajectory.getTiltAim(vector2: Vector3, vector3: Vector3, p: number)
	return {
		Type = "AimData",
		Origin = getOrigin(vector2, vector3),
		Target = vector3,
		InitialVelocity = (vector3 - vector2).Unit * p
	}
end

function Trajectory.traceTrajectory(vector2: Vector3, vector3: Vector3, p, p2: number, flag: boolean?)
	local origin = getOrigin(vector2, vector3)
	local v = p.TargetX / p2
	local points = {}
	local total = 0

	for i = 0, p2 do
		local v3 = i * v
		local Y = p.getY(v3)
		local position = origin.Position
		local lookVector = origin.LookVector

		if flag then
			v3 = ConversionUtil.Length.Meter.toRoblox(v3)
		end

		local v4 = position + lookVector * v3

		if flag then
			Y = ConversionUtil.Length.Meter.toRoblox(Y)
		end

		local v6 = v4 + Vector3.new(0, Y, 0)
		total += (v6 - (points[i] or vector2)).Magnitude
		table.insert(points, v6)
	end

	return {
		Points = points,
		Length = total
	}
end

function Trajectory.render(p, list)
	local count = #list
	local count2 = #p.Points

	if count == 0 or count2 == 0 then
		return
	end

	assert(count == count2 - 1, "Must have exactly one less part than points")
	local cFrames = table.create(#list)

	for i = 1, count do
		local v = list[i]
		local point = p.Points[i]
		local point2 = p.Points[i + 1]
		local v2 = point2 - point
		v.Size = Vector3.new(v.Size.X, v.Size.Y, v2.Magnitude)
		v.CFrame = CFrame.lookAt(point, point2) * CFrame.new(0, 0, -v.Size.Z / 2)
		cFrames[i] = v.CFrame
	end

	workspace:BulkMoveTo(list, cFrames, Enum.BulkMoveMode.FireCFrameChanged)
end

function Trajectory.animate(p, p2: number)
	local points = p.Points

	if p2 <= 0 then
		return points[1]
	end

	if p.Length <= p2 then
		return points[#points]
	end

	local total = 0

	for i = 1, #points - 1 do
		local point = points[i]
		local point2 = points[i + 1]
		local magnitude = (point2 - point).Magnitude

		if p2 <= total + magnitude then
			return point:Lerp(point2, (p2 - total) / magnitude)
		else
			total += magnitude
		end
	end

	return points[#points]
end

function Trajectory:alignBeam(data, value: number?)
	local v = value or 0
	assert(v, "bad minTransparency")
	local attachment0 = self.Attachment0

	if not attachment0 then
		return
	end

	local attachment1 = self.Attachment1

	if not attachment1 then
		return
	end

	local arc = data.Arc

	if not arc then
		return
	end

	local target = data.Target
	local v2 = 0
	local position

	if arc.TargetOffsetX < arc.GroundPointOffsetX then
		position = data.Origin.Position
		assert(position, "bad P0")
		target = arc.GroundPoint
	else
		local unit = ((data.Origin.Position - data.Target) * createVector(1, 0, 1)).Unit
		local v3 = (arc.TargetOffsetX - arc.GroundPointOffsetX / 2) * 2
		position = data.Target + unit * v3
		v2 = data.Origin.Position.Y - data.Target.Y
	end

	assert(position, "bad P0")
	local Y = (arc.HighestPoint - position).Y
	local v3 = target - position
	local magnitude = v3.Magnitude
	local v4 = position + v3.Unit * (magnitude / 3) + createVector(0, 1, 0) * (4 * Y / 3)
	local curveSize = math.sqrt(magnitude ^ 2 + 16 * Y ^ 2) * 0.3333333333333333
	local unit = (position - target).Unit
	local unit2 = (v4 - position).Unit
	local unit3 = unit2:Cross(unit).Unit
	local unit4 = unit3:Cross(unit2).Unit
	local cframe = CFrame.new(
		position.X,
		position.Y,
		position.Z,
		unit2.X,
		unit3.X,
		unit4.X,
		unit2.Y,
		unit3.Y,
		unit4.Y,
		unit2.Z,
		unit3.Z,
		unit4.Z
	)
	local eulerAngles, v6, v7 = cframe:ToEulerAngles()
	local worldCFrame = CFrame.new(target.X, target.Y, target.Z) * CFrame.Angles(-eulerAngles, v6, v7)
	self.CurveSize0 = curveSize
	self.CurveSize1 = curveSize
	attachment0.WorldCFrame = cframe
	attachment1.WorldCFrame = worldCFrame
	local initialVelocity_rbx = getInitialVelocity_rbx(
		position,
		target,
		ConversionUtil.Length.Roblox.toMeter((position - target).Magnitude),
		ConversionUtil.Length.Roblox.toMeter((position - target).Magnitude / 2),
		ConversionUtil.Length.Roblox.toMeter(arc.HighestPointOffsetY + v2)
	)
	local magnitude2 = ((target - position) * createVector(1, 0, 1)).Magnitude
	local v9 = position
	local total = 0
	local total2 = 0
	local count = 0
	local v10 = 1e999
	local v11 = 0

	while total < 5 and total2 < arc.ArcLength * 2 do
		count += 1
		total += 0.03333333333333333
		local v12 = initialVelocity_rbx * 0.03333333333333333
		local magnitude3 = v12.Magnitude
		v9 += v12
		initialVelocity_rbx += Vector3.new(0, -workspace.Gravity, 0) * 0.03333333333333333
		local v13 = v9 - v12

		if arc.TargetOffsetX < arc.GroundPointOffsetX then
			local magnitude4 = (Ray.new(v13 - v12.Unit * 100000, v12.Unit * 1000000):ClosestPoint(data.Target) - v13).Magnitude
			local magnitude5 = ((v9 - position) * createVector(1, 0, 1)).Magnitude

			if magnitude4 < magnitude3 and magnitude4 > 0 and magnitude4 < v10 then
				v11 = total2 + magnitude4
				v10 = magnitude4
				total2 += magnitude3
			elseif magnitude2 < magnitude5 then
				break
			else
				total2 += magnitude3
			end
		else
			local magnitude4 = (Ray.new(v13 - v12.Unit * 100000, v12.Unit * 1000000):ClosestPoint(data.Origin.Position) - v13).Magnitude
			local magnitude5 = ((data.Origin.Position - target) * createVector(1, 0, 1)).Magnitude

			if magnitude4 <= magnitude3 and magnitude4 >= 0 and magnitude4 < v10 then
				v11 = total2 + magnitude4
				v10 = magnitude4
				total2 += magnitude3
			elseif magnitude2 < magnitude5 then
				break
			else
				total2 += magnitude3
			end
		end
	end

	local v12 = v11 / total2
	local success, result = pcall(function()
		if arc.TargetOffsetX < arc.GroundPointOffsetX then
			v12 = math.clamp((math.floor(v12 / 0.05) + -1) * 0.05, 0.05, 1)
			self.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.05, v),
				NumberSequenceKeypoint.new(v12 - 0.0001, v),
				NumberSequenceKeypoint.new(v12, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		else
			v12 = math.clamp((math.ceil(v12 / 0.05) + 1) * 0.05, 0, 0.95)
			self.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(v12, 1),
				NumberSequenceKeypoint.new(v12 + 0.0001, v),
				NumberSequenceKeypoint.new(0.95, v),
				NumberSequenceKeypoint.new(1, 1)
			})
		end
	end)

	if not success then
		warn(result)
	end
end

return Trajectory