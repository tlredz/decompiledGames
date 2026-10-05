local createVector = vector.create
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function tangentFromNormal(normal: Vector3, side, vector2: Vector3)
	if side == "right" then
		return normal:Cross(vector2).Unit
	end

	return vector2:Cross(normal).Unit
end

local function clampPlanar(vector2: Vector3, vector3: Vector3, p: number)
	local v = vector3 * vector2:Dot(vector3)
	local v2 = vector2 - v
	local magnitude = v2.Magnitude

	if p < magnitude then
		return v + v2 * (p / magnitude)
	end

	return vector2
end

local function rollFromSide(p, p2)
	local tiltAngle = math.rad(p2.tiltAngle)

	if p == "right" then
		return -tiltAngle
	end

	return tiltAngle
end

local Motion = {}

function Motion.computeTangent(p, vector2: Vector3)
	local normal = p.normal

	if p.side == "right" then
		return normal:Cross(vector2).Unit
	end

	return vector2:Cross(normal).Unit
end

function Motion.resolveRideSpeed(p: number, data, p2)
	return (math.min(
		math.clamp(p * data.speedRatio, data.minRideSpeed, data.maxRideSpeed) * p2.speedMultiplier,
		data.maxHorizontalSpeed
	))
end

function Motion.resolveFallSpeed(p: number, data, p2)
	local v = math.max(p - data.slideGrace, 0)
	return (math.min(data.slideAcceleration * v * p2.slideMultiplier, data.maxFallSpeed))
end

function Motion.computeFrame(rideSpeed: number, verticalSpeed: number, p3, vector2: Vector3, p4)
	local tangent = tangentFromNormal(p3.normal, p3.side, vector2) -- equivalent call inferred; original call site unknown
	local v2 = {
		commanded = tangent * rideSpeed + vector2 * verticalSpeed - p3.normal * p4.stickSpeed,
		tangent = tangent,
		rideSpeed = rideSpeed,
		verticalSpeed = verticalSpeed,
		roll = 0
	}
	local side = p3.side
	local tiltAngle = math.rad(p4.tiltAngle)

	if side == "right" then
		tiltAngle = -tiltAngle
	end

	v2.roll = tiltAngle
	return v2
end

function Motion.resolveOrientation(instance, p, vector2: Vector3, p2, p3: number)
	local position = instance.Position
	local v = CFrame.lookAt(position, position + p.tangent, vector2) * CFrame.Angles(0, 0, p.roll)
	local v2 = not (p2.orientationSmoothing > 0) and 1 or math.clamp(p3 / p2.orientationSmoothing, 0, 1)
	return instance.CFrame:Lerp(v, v2)
end

function Motion:apply(p2, p3: number)
	self.AssemblyLinearVelocity = p2.commanded + createVector(0, 1, 0) * (workspace.Gravity * p3)
	self.AssemblyAngularVelocity = createVector(0, 0, 0)
end

function Motion.computeEject(p, p2, vector2: Vector3, data)
	local v = math.clamp(
		data.baseEjectSpeed + p.rideSpeed * data.ejectSpeedRatio,
		data.minEjectSpeed,
		data.maxEjectSpeed
	) * p2.jumpMultiplier
	local vector3 = (p2.normal * data.normalWeight + vector2 * data.upWeight).Unit * v

	if data.preserveMomentum then
		vector3 += p.tangent * p.rideSpeed * data.momentumWeight
	end

	local maxHorizontalSpeed = data.maxHorizontalSpeed
	local v2 = vector2 * vector3:Dot(vector2)
	local v3 = vector3 - v2
	local magnitude = v3.Magnitude

	if maxHorizontalSpeed < magnitude then
		return v2 + v3 * (maxHorizontalSpeed / magnitude)
	end

	return vector3
end

return Motion