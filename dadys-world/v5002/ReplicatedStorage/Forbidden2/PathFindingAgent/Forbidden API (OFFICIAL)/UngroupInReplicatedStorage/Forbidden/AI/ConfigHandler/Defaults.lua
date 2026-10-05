local createVector = vector.create
require(script.Parent.Parent.Types)

local function nullbind() end

local parent = script.Parent.Parent.Parent
local Common = require(parent.Common)
local Defaults = {
	StopType = "CurrentPosition",
	Unstucking = {}
}
Defaults.Unstucking.Enabled = true
Defaults.Unstucking.FireStuckHook = true
Defaults.Unstucking.MaxStuckCount = 2
Defaults.RequestPrioritization = {}
Defaults.RequestPrioritization.PreferTimeOverPriority = {}
Defaults.RequestPrioritization.PreferTimeOverPriority.Enabled = true
Defaults.RequestPrioritization.PreferTimeOverPriority.ResetOlderRequests = true
Defaults.AgentInfo = {}
Defaults.AgentInfo.AgentRadius = 2.5
Defaults.AgentInfo.AgentHeight = 5
Defaults.AgentInfo.AgentCanJump = true
Defaults.AgentInfo.AgentCanClimb = false
Defaults.AgentInfo.WaypointSpacing = 4
Defaults.AgentInfo.Cost = {
	Obstacle = 1e999
}
Defaults.Visualization = {}
Defaults.Visualization.Enabled = false
Defaults.Visualization.Path = true
Defaults.Visualization.PathColor = Color3.fromRGB(98, 87, 255)
Defaults.Visualization.Celling = false
Defaults.Visualization.CellingColor = Color3.fromRGB(0, 255, 0)
Defaults.Visualization.MovetoRaycast = false
Defaults.Visualization.MovetoRaycastColor = Color3.fromRGB(0, 0, 255)
Defaults.Visualization.Tether = false
Defaults.Visualization.TetherColor = Color3.fromRGB(255, 255, 0)
Defaults.Tracking = {}
Defaults.Tracking.Enabled = false
Defaults.Tracking.CollinearTargetPositionOffset = 0.25
Defaults.Tracking.PredictionMagnitude = 2
Defaults.Tracking.DistanceMovedThreshold = 1
Defaults.WaypointSkipping = {}
Defaults.WaypointSkipping.RegularPathfindSkip = 2
Defaults.WaypointSkipping.TrackingPathfindSkip = 3
Defaults.Tracking.DynamicRetrack = {}
Defaults.Tracking.DynamicRetrack.MoveTo = {}
Defaults.Tracking.DynamicRetrack.MoveTo.MinTimer = 0
Defaults.Tracking.DynamicRetrack.MoveTo.MaxTimer = 1

function Defaults.Tracking.DynamicRetrack.MoveTo.GetRetrackTimeFunction(p, p2)
	return math.max(Common.GetDistanceFromNPCToTarget(p, p2) - 20, 0) / 40
end

function Defaults.Tracking.DynamicRetrack.MoveTo.ShouldRetrackFunction(_, _)
	return true
end

Defaults.Tracking.DynamicRetrack.Pathfind = {}
Defaults.Tracking.DynamicRetrack.Pathfind.MinTimer = 0.5
Defaults.Tracking.DynamicRetrack.Pathfind.MaxTimer = 3

function Defaults.Tracking.DynamicRetrack.Pathfind.GetRetrackTimeFunction(p, p2)
	return Common.GetDistanceFromNPCToTarget(p, p2) / 80
end

function Defaults.Tracking.DynamicRetrack.Pathfind.ShouldRetrackFunction(_, _)
	return true
end

Defaults.DirectMoveTo = {}
Defaults.DirectMoveTo.Enabled = true
Defaults.DirectMoveTo.ActivationDistance = 60
Defaults.DirectMoveTo.HeightLimit = 10
Defaults.DirectMoveTo.TrackingOnly = true
Defaults.DirectMoveTo.AvoidUseHook = nullbind
Defaults.DirectMoveTo.Raycast = {}
Defaults.DirectMoveTo.Raycast.Enabled = true
Defaults.DirectMoveTo.Raycast.Range = Defaults.DirectMoveTo.ActivationDistance + 10
Defaults.DirectMoveTo.Raycast.SeeThroughTransparentParts = false
Defaults.DirectMoveTo.Raycast.SeeThroughNonCollidable = true
Defaults.DirectMoveTo.Raycast.MinimumTransparency = 0.001
Defaults.DirectMoveTo.Raycast.FilterAttempts = 10
Defaults.DirectMoveTo.Raycast.OffsetFromOrigin = createVector(0, 0, 0)
Defaults.DirectMoveTo.Raycast.OffsetFromTarget = createVector(0, 0, 0)

function Defaults.DirectMoveTo.Raycast.FilterFunction(_)
	return false
end

Defaults.DirectMoveTo.JumpHandler = {}
Defaults.DirectMoveTo.JumpHandler.Enabled = true
Defaults.DirectMoveTo.JumpHandler.MinConditionReachedTime = 0.25
Defaults.DirectMoveTo.JumpHandler.NextJumpMinTime = 1
Defaults.DirectMoveTo.JumpHandler.DistanceFromMoveToPoint = 2
Defaults.DirectMoveTo.JumpHandler.CustomJumpFunction = nil
Defaults.DirectMoveTo.CheckFloor = {}
Defaults.DirectMoveTo.CheckFloor.Enabled = true
Defaults.DirectMoveTo.CheckFloor.FailHeight = 12
Defaults.DirectMoveTo.CheckFloor.RaycastSpacing = 5
Defaults.DirectMoveTo.CheckFloor.AlwaysRaycastThisDistance = 2
Defaults.DirectMoveTo.CheckFloor.CheckFrequencyTimer = 1
Defaults.DirectMoveTo.CheckFloor.BlockDirectMoveToTimer = 3
Defaults.DirectMoveTo.CheckFloor.DisableIfDistanceIsLessThan = Defaults.AgentInfo.AgentRadius * 3
Defaults.Hooks = {}

function Defaults.Hooks.PathfindingLinkReached(p, p2)
	local basePart = Common.GetBasePart(p)

	if basePart then
		basePart.CFrame = CFrame.new(p2.Position)
	end

	return true
end

Defaults.Hooks.MovingToWaypoint = nullbind

function Defaults.Hooks.Stuck(instance, _)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not (humanoid ~= nil and humanoid.Health ~= 0) then
		return false
	end

	local basePart = Common.GetBasePart(instance)

	if basePart == nil then
		return false
	end

	local position = basePart.CFrame.Position
	local unit = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit

	if unit.X ~= unit.X then
		return false
	end

	humanoid:MoveTo(position + unit * 10)
	humanoid.Jump = true
	task.wait(1)
	return true
end

Defaults.Hooks.GoalReached = nullbind
Defaults.Hooks.StartAcknowledged = nullbind
Defaults.Hooks.StopAcknowledged = nullbind
Defaults.Hooks.PathingFailed = nullbind
Defaults.Hooks.PathingStarted = nullbind
Defaults.Debugging = {}
Defaults.Debugging.Enabled = false
Defaults.Debugging.OutputToConsole = true
Defaults.Debugging.StateTransitioning = true
Defaults.Debugging.MovingToWaypoint = false
Defaults.Debugging.Verbosity = 3
return Defaults