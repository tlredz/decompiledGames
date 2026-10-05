require(script.Parent.Types)

local function checkConfigCoherent(data)
	if data.minRideSpeed > data.maxRideSpeed then
		return false, "wallRide: minRideSpeed must stay below or equal to maxRideSpeed"
	end

	if data.minEjectSpeed > data.maxEjectSpeed then
		return false, "wallRide: minEjectSpeed must stay below or equal to maxEjectSpeed"
	end

	if data.maxHorizontalSpeed >= 400 then
		return
			false,
			"wallRide: maxHorizontalSpeed must stay below the server speed limit, otherwise the ejection arms a teleport strike"
	end

	if data.rideDotThreshold <= data.holdDotThreshold then
		return
			false,
			"wallRide: rideDotThreshold must stay above holdDotThreshold, otherwise a ride detaches on the frame it attaches"
	end

	if data.maxRideDuration > 0 and data.maxRideDuration <= data.slideGrace then
		return false, "wallRide: maxRideDuration must stay above slideGrace when the duration is bounded"
	end

	return true, nil
end

local Config = {}

function Config.default()
	return {
		probeDistance = 3.5,
		probeHeights = { -1, 0, 1 },
		maxSurfaceAngle = 25,
		groundProbeDistance = 3.5,
		attributeSearchDepth = 4,
		speedRatio = 1,
		minRideSpeed = 12,
		maxRideSpeed = 300,
		stickSpeed = 2,
		orientationSmoothing = 0.12,
		tiltAngle = 18,
		slideGrace = 0.4,
		slideAcceleration = 22,
		maxFallSpeed = 45,
		baseEjectSpeed = 22,
		ejectSpeedRatio = 0.35,
		minEjectSpeed = 18,
		maxEjectSpeed = 130,
		normalWeight = 1,
		upWeight = 0.85,
		preserveMomentum = true,
		momentumWeight = 0.6,
		maxHorizontalSpeed = 340,
		attachStates = {
			Enum.HumanoidStateType.Freefall,
			Enum.HumanoidStateType.Jumping,
			Enum.HumanoidStateType.Running
		},
		requiresAirborne = false,
		minEntrySpeed = 14,
		rideDotThreshold = 0.4,
		headOnThreshold = 0.7,
		holdDotThreshold = 0.1,
		reattachCooldown = 0.2,
		reattachRequiresDifferentWall = true,
		lostWallGrace = 0.12,
		maxRideDuration = 2.5,
		rideAll = false,
		tagName = "RideableWall",
		attributeNames = {
			rideable = "Rideable",
			speedMultiplier = "RideSpeedMultiplier",
			slideMultiplier = "RideSlideMultiplier",
			jumpMultiplier = "RideJumpMultiplier",
			maxAngle = "RideMaxAngle",
			maxDuration = "RideMaxDuration",
			noJump = "RideNoJump"
		},
		animations = nil,
		useRunAnimation = true,
		animationSpeedReference = 16,
		animationMaxSpeed = 1.75,
		getUp = nil,
		getMoveDirection = nil,
		isHostDriven = nil,
		onAttach = nil,
		onDetach = nil,
		onJump = nil,
		onRide = nil,
		onProbe = nil,
		onMotionOwned = nil
	}
end

function Config.merge(p, p2)
	local clone = table.clone(p)
	local clone2 = table.clone(p.attributeNames)

	for k, v in p2 do
		if v ~= nil and k ~= "attributeNames" then
			clone[k] = v
		end
	end

	for k, v in p2.attributeNames or {} do
		clone2[k] = v
	end

	clone.attributeNames = clone2
	local flag, v

	if clone.minRideSpeed > clone.maxRideSpeed then
		flag = false
		v = "wallRide: minRideSpeed must stay below or equal to maxRideSpeed"
	elseif clone.minEjectSpeed > clone.maxEjectSpeed then
		flag = false
		v = "wallRide: minEjectSpeed must stay below or equal to maxEjectSpeed"
	elseif clone.maxHorizontalSpeed >= 400 then
		flag = false
		v = "wallRide: maxHorizontalSpeed must stay below the server speed limit, otherwise the ejection arms a teleport strike"
	elseif clone.rideDotThreshold <= clone.holdDotThreshold then
		flag = false
		v = "wallRide: rideDotThreshold must stay above holdDotThreshold, otherwise a ride detaches on the frame it attaches"
	elseif clone.maxRideDuration > 0 and clone.maxRideDuration <= clone.slideGrace then
		flag = false
		v = "wallRide: maxRideDuration must stay above slideGrace when the duration is bounded"
	else
		flag = true
	end

	if flag then
		return clone
	end

	error(v)
end

return Config