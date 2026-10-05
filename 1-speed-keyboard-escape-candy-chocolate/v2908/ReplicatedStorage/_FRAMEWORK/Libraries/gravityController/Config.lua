require(script.Parent.Types)

local function checkConfigCoherent(clone)
	if clone.maxHorizontalSpeed >= 400 then
		return
			false,
			"gravityController: maxHorizontalSpeed must stay below the server speed limit, otherwise walking arms a teleport strike"
	end

	if clone.groundRingCount < 1 or clone.groundRingCount % 1 ~= 0 then
		return false, "gravityController: groundRingCount must be a positive integer"
	end

	if clone.groundDistance <= clone.colliderRadius then
		return
			false,
			"gravityController: groundDistance must stay above colliderRadius, otherwise the ground is never seen"
	end

	if clone.maxTravelSeconds < 0 then
		return false, "gravityController: maxTravelSeconds cannot be negative"
	end

	if clone.minGroundDot <= 0 then
		return false, "gravityController: minGroundDot must stay above 0, the surface follow divides by it"
	end

	if clone.groundSnapAngle < 0 or clone.groundSnapAngle >= 90 then
		return false, "gravityController: groundSnapAngle must stay between 0 and 90 degrees"
	end

	if clone.jumpGravityScale <= 0 then
		return false, "gravityController: jumpGravityScale must stay above 0, a jump under no gravity never lands"
	end

	return true, nil
end

local Config = {}

function Config.default()
	return {
		blendTau = 0.08,
		colliderRadius = 1,
		colliderForwardOffset = 0.1,
		groundDistance = 2.2,
		groundRingRadius = 0.6,
		groundRingCount = 4,
		minGroundDot = 0.3,
		groundSnapAngle = 55,
		stepHeight = 1.2,
		stickSpeed = 4,
		groundResponsiveness = 24,
		airResponsiveness = 3,
		turnResponsiveness = 18,
		orientationResponsiveness = 200,
		maxHorizontalSpeed = 340,
		maxFallSpeed = 250,
		maxTravelSeconds = 1,
		travelProbeDistance = 1000,
		unfollowedInstances = {},
		jumpCooldown = 0.2,
		jumpMultiplier = 1,
		jumpGravityScale = 1,
		climbSpeedRatio = 0.7,
		climbReach = 2,
		climbRegrabCooldown = 0.3,
		animationFadeTime = 0.2,
		onProbe = nil,
		onStateChanged = nil
	}
end

function Config.merge(p, items)
	local clone = table.clone(p)

	for k, item in items do
		if item ~= nil then
			clone[k] = item
		end
	end

	local v, v2 = checkConfigCoherent(clone)

	if v then
		return clone
	end

	error(v2)
end

return Config