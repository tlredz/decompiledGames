require(script.Parent.Types)

local function checkConfigCoherent(data)
	if data.probeDistance <= 0 then
		return false, "wallClimb: probeDistance must stay above 0"
	end

	if data.absorbClearance < 0 then
		return false, "wallClimb: absorbClearance must not be negative"
	end

	if data.maxWallHeight <= 0 then
		return false, "wallClimb: maxWallHeight must stay above 0"
	end

	if data.heightProbeOffset <= 0 then
		return false, "wallClimb: heightProbeOffset must stay above 0"
	end

	if data.heightSteps < 1 then
		return false, "wallClimb: heightSteps must be at least 1"
	end

	if data.heightBoostRatio <= 0 then
		return false, "wallClimb: heightBoostRatio must stay above 0"
	end

	return true, nil
end

local Config = {}

function Config.default()
	return {
		probeDistance = 3,
		probeHeights = { -1.5, 0, 1.5 },
		probeAngles = { 0, -20, 20 },
		maxSurfaceAngle = 25,
		attributeSearchDepth = 4,
		maxWallHeight = 120,
		heightProbeOffset = 1,
		heightSteps = 7,
		heightOvershoot = 4,
		heightBoostRatio = 1,
		minBoostSpeed = 0,
		maxBoostSpeed = 0,
		wallPushSpeed = 6,
		absorbImpact = true,
		absorbClearance = 1.5,
		blockedStates = { Enum.HumanoidStateType.Physics },
		inputDotThreshold = 0.35,
		resetOnOppositeWall = true,
		resetNormalDot = -0.3,
		climbAll = false,
		tagName = "ClimbableWall",
		attributeNames = {
			climbable = "Climbable",
			boostMultiplier = "ClimbBoostMultiplier",
			maxAngle = "ClimbMaxAngle",
			noBoost = "ClimbNoBoost"
		},
		getUp = nil,
		getGravity = nil,
		getMoveDirection = nil,
		isAirborne = nil,
		onReady = nil,
		onLost = nil,
		onBoost = nil,
		onProbe = nil
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

	if clone.probeDistance <= 0 then
		flag = false
		v = "wallClimb: probeDistance must stay above 0"
	elseif clone.absorbClearance < 0 then
		flag = false
		v = "wallClimb: absorbClearance must not be negative"
	elseif clone.maxWallHeight <= 0 then
		flag = false
		v = "wallClimb: maxWallHeight must stay above 0"
	elseif clone.heightProbeOffset <= 0 then
		flag = false
		v = "wallClimb: heightProbeOffset must stay above 0"
	elseif clone.heightSteps < 1 then
		flag = false
		v = "wallClimb: heightSteps must be at least 1"
	elseif clone.heightBoostRatio <= 0 then
		flag = false
		v = "wallClimb: heightBoostRatio must stay above 0"
	else
		flag = true
	end

	if flag then
		return clone
	end

	error(v)
end

return Config