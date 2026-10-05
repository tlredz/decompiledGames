local createVector = vector.create
local SharedRocketLauncher = {
	HU = 0.06666666666666667,
	PROJECTILE_TAG = "TF2Rocket",
	CLIP_SIZE = 4,
	FIRE_INTERVAL = 0.8,
	DEPLOY_TIME = 0.5,
	RELOAD_FIRST = 0.92,
	RELOAD_NEXT = 0.8,
	ROCKET_SPEED = 73.33333333333333,
	ROCKET_RADIUS = 0.2,
	MAX_DISTANCE = 1000,
	AIM_RANGE = 133.33333333333334,
	MUZZLE_OFFSET = createVector(0.8000001, -0.20000002, -1.5666667),
	BASE_DAMAGE = 90,
	SPLASH_RADIUS = 9.733333333333333,
	SELF_SPLASH_RADIUS = 8.066666666666666,
	SPLASH_MIN_SCALE = 0.5,
	RAMP_UP = 0.25,
	FALL_OFF = 0.472,
	RAMP_DISTANCE = 34.13333333333333,
	SELF_AIRBORNE_DAMAGE_SCALE = 0.6,
	HEALTH_SCALE = 0.5,
	PUSH_SCALE_OTHER = 6,
	PUSH_SCALE_SELF_AIR = 10,
	PUSH_SCALE_SELF_GROUND = 5,
	AIR_ACCELERATE = 10,
	AIR_WISH_SPEED = 240,
	AIR_SPEED_CAP = 30,
	velocityScale = function()
		return (math.sqrt(workspace.Gravity * 0.06666666666666667 / 800))
	end,
	accelerationScale = function()
		return workspace.Gravity / 800
	end
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function simpleSpline(p: number)
	return p * 3 * p - p * 2 * p * p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rampMultiplier(magnitude: number)
	local v2 = simpleSpline(1 - math.clamp(magnitude / SharedRocketLauncher.RAMP_DISTANCE, 0, 2) / 2) * 2 - 1

	if v2 > 0 then
		return 1 + SharedRocketLauncher.RAMP_UP * v2
	end

	return 1 + SharedRocketLauncher.FALL_OFF * v2
end

local function distanceToBounds(vector2: Vector3, vector3: Vector3)
	local v = vector2 - vector3
	return (v - Vector3.new(
		math.clamp(v.X, -1.633333444595337, 1.633333444595337),
		math.clamp(v.Y, -2.766666889190674, 2.766666889190674),
		(math.clamp(v.Z, -1.633333444595337, 1.633333444595337))
	)).Magnitude
end

function SharedRocketLauncher.isAirborne(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { instance }
	local v = humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0
	local v2 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight + v + 0.6
	return workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -v2, 0), raycastParams) == nil
end

function SharedRocketLauncher.getDamage(data)
	local BASE_DAMAGE = SharedRocketLauncher.BASE_DAMAGE
	local SELF_SPLASH_RADIUS, magnitude

	if data.isSelf then
		SELF_SPLASH_RADIUS = SharedRocketLauncher.SELF_SPLASH_RADIUS
		magnitude = (data.victimPosition - data.explosion).Magnitude
	else
		SELF_SPLASH_RADIUS = SharedRocketLauncher.SPLASH_RADIUS

		if data.isDirectHit then
			magnitude = 0
		else
			local v = data.explosion - data.victimPosition
			magnitude = (v - Vector3.new(
				math.clamp(v.X, -1.633333444595337, 1.633333444595337),
				math.clamp(v.Y, -2.766666889190674, 2.766666889190674),
				(math.clamp(v.Z, -1.633333444595337, 1.633333444595337))
			)).Magnitude
		end

		if data.attackerPosition then
			local v = rampMultiplier((data.attackerPosition - data.victimPosition).Magnitude) -- equivalent call inferred; original call site unknown
			BASE_DAMAGE *= v
		end
	end

	if SELF_SPLASH_RADIUS < magnitude then
		return 0
	end

	local v = BASE_DAMAGE * (1 - (1 - SharedRocketLauncher.SPLASH_MIN_SCALE) * (magnitude / SELF_SPLASH_RADIUS))

	if data.isSelf and data.airborne then
		return v * SharedRocketLauncher.SELF_AIRBORNE_DAMAGE_SCALE
	end

	return v
end

function SharedRocketLauncher.getPushVelocity(data, p: number)
	if p <= 0 then
		return createVector(0, 0, 0)
	end

	local PUSH_SCALE_OTHER = SharedRocketLauncher.PUSH_SCALE_OTHER

	if data.isSelf then
		if data.airborne then
			PUSH_SCALE_OTHER = SharedRocketLauncher.PUSH_SCALE_SELF_AIR
		else
			PUSH_SCALE_OTHER = SharedRocketLauncher.PUSH_SCALE_SELF_GROUND
		end
	end

	local v = data.victimPosition - createVector(0, 0.6666667, 0) - data.explosion
	local v2 = v.Magnitude < 0.001 and createVector(0, 1, 0) or v
	local v3 = math.min(p * 0.9480387188069228 * PUSH_SCALE_OTHER, 1000)
	return v2.Unit * v3 * SharedRocketLauncher.velocityScale()
end

return SharedRocketLauncher