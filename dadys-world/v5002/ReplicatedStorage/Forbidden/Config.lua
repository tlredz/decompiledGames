local warn2 = warn or print
local Config = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v = {
	DistanceMovedThreshold = 1,
	DynamicRetrackTimerMin_Pathfind = 0.3,
	DynamicRetrackTimerMax_Pathfind = 0.6,
	DynamicRetrackTimerMin_DirectMove = 0.15,
	DynamicRetrackTimerMax_DirectMove = 0.4,
	EnablePrediction = true,
	MovementPredictionMagnitude = 1,
	CollinearOffset = 0.25,
	WaypointSkipCount = 2,
	WaypointSkipCountTracking = 3,
	DirectMoveToActivationDistance = 60,
	DirectMoveToHeightLimit = 10,
	DirectMoveToEnabled = true,
	DirectMoveToTrackingOnly = true,
	DirectMoveToWallCheck = false,
	DirectMoveToWidthCheck = false,
	FloorCheckMinDistance = false,
	FloorCheckFailHeight = 12,
	FloorCheckRaycastSpacing = 5,
	FloorCheckAlwaysRaycastDistance = 2,
	LOSSeeThroughTransparentParts = false,
	LOSSeeThroughNonCollidable = true,
	LOSMinimumTransparency = 0.001,
	LOSFilterAttempts = 10,
	PathfindingLinkReached = nil,
	OnWaypointReached = nil,
	OnPathingFailed = nil,
	OnGoalReached = nil,
	OnPathingStarted = nil,
	OnMovingToWaypoint = nil,
	OnStuck = nil,
	DebugEnabled = false,
	DebugVerbosity = 3,
	DebugOutputToConsole = true,
	DebugStateTransitions = false,
	DebugWaypointMovement = false,
	JumpHandlerEnabled = false,
	JumpOnWaypoint = false,
	JumpMinStuckTime = 0.15,
	JumpCooldown = 0.5,
	JumpDistanceFromGoal = 1.5,
	JumpVelocityThreshold = 0.6,
	UnstuckJumpPower = 10,
	AgentRadius = 1.6,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentCanClimb = false,
	WaypointSpacing = 4,
	AgentCost = {
		LaneClimb = 1e999,
		LaneDrop = 1e999,
		LaneLift = 1e999,
		LaneMesh = 1e999,
		LaneBreach = 1e999,
		LaneHop = 1e999,
		LaneCross = 1e999
	},
	PhysDensity = 1.2,
	PhysFriction = 0.3,
	PhysElasticity = 0,
	PhysFrictionWeight = 100,
	PhysElasticityWeight = 1,
	PhysShapeBall = true,
	TurnSpeedPenaltyEnabled = false,
	TurnSpeedPenaltyMin = 0.6,
	TurnSpeedPenaltyRecovery = 3,
	TurnSpeedPenaltyThreshold = 0.7,
	TurnSpeedPenaltyHoldTime = 0.8
}
local movementPredictionMagnitude = v.MovementPredictionMagnitude
Config.FLANK_PREDICTION_MAGNITUDE = 14
Config.NORMAL_PREDICTION_MAGNITUDE = movementPredictionMagnitude
local v2 = {}

function Config.GetConfig(p)
	if object[p] then
		return object[p]
	end

	local v3 = {}

	for k, v4 in pairs(v) do
		v3[k] = v4
	end

	object[p] = v3
	return object[p]
end

function Config.CreatePreset(p, p2)
	v2[p] = p2
end

function Config.ApplyPreset(p, p2)
	local v3 = v2[p2]

	if not v3 then
		warn2("Preset not found:", p2)
		return
	end

	local config = Config.GetConfig(p)

	for k, v4 in pairs(v3) do
		config[k] = v4
	end
end

function Config.Cleanup(p)
	object[p] = nil
end

local v3 = {}

function Config.SetDefaults(items)
	for k, item in pairs(items) do
		if v[k] == nil then
			if not v3[k] then
				v3[k] = true
				warn2(string.format(
					"[Config] SetDefaults: unknown key %q ignored (typo? see DEFAULT_CONFIG)",
					(tostring(k))
				))
			end
		elseif type(item) == type(v[k]) or k == "FloorCheckMinDistance" and (type(item) == "boolean" or type(item) == "number") then
			v[k] = item

			for _, v4 in pairs(object) do
				v4[k] = item
			end
		else
			warn2(string.format("[Config] SetDefaults: %s expects %s, got %s - ignored", k, type(v[k]), (type(item))))
		end
	end
end

function Config.SetCutOffFlank(p, p2)
	local config = Config.GetConfig(p)
	config.EnablePrediction = true
	config.MovementPredictionMagnitude = p2 and 14 or movementPredictionMagnitude
end

function Config.SetCutOffFlankGlobal(p)
	Config.SetDefaults({
		EnablePrediction = true,
		MovementPredictionMagnitude = p and 14 or movementPredictionMagnitude
	})
end

function Config.GetDefaults()
	local result = {}

	for k, v4 in pairs(v) do
		if type(v4) ~= "function" then
			result[k] = v4
		end
	end

	return result
end

function Config.GetActiveCount()
	local count = 0

	for _ in pairs(object) do
		count += 1
	end

	return count
end

Config.CreatePreset("FastChaser", {
	DynamicRetrackTimerMax_Pathfind = 2,
	DynamicRetrackTimerMax_DirectMove = 0.5,
	CollinearOffset = 0.5
})
Config.CreatePreset("SlowPatrol", {
	DynamicRetrackTimerMax_Pathfind = 5,
	DynamicRetrackTimerMax_DirectMove = 2,
	DistanceMovedThreshold = 2
})
Config.CreatePreset("PreciseChaser", {
	CollinearOffset = 0.1,
	MovementPredictionMagnitude = 3,
	WaypointSkipCount = 2
})
Config.CreatePreset("TightKiteable", {
	PhysFriction = 0.6,
	PhysDensity = 1,
	MovementPredictionMagnitude = 0.7
})
return Config