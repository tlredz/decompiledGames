local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local robloxstatemachine = require(ReplicatedStorage.Forbidden.Packages.robloxstatemachine)
local parent = script.Parent.Parent.Parent.Parent
local Debugging = require(parent.AI.Debugging)
local MessageQueue = require(parent.AI.MessageQueue)
local PathfindingProcessor = require(parent.AI.PathfindingProcessor)
local WaypointLooper = require(parent.AI.PathfindingProcessor.WaypointLooper)
local RetrackingOptimization = require(parent.AI.RetrackingOptimization)
local DirectMoveTo = require(parent.AI.DirectMoveTo)
local Common = require(parent.Common)
require(parent.AI.Types)
local tracking = robloxstatemachine.State.new("Tracking")

-- equivalent calls inferred from this helper; original call sites unknown
local function NewRequestHandler(data)
	local config = data.Config

	if MessageQueue.GetNewRequest(config.NPC) == nil then
		return
	end

	data.StateMachine:ChangeState("Idle")
end

function tracking.OnInit(_) end

function tracking:Pathfind(data)
	local config = data.Config
	local target = data.Target

	if not target then
		Debugging.Log(config.NPC, "No target set for Tracking state, cannot compute path.")
		return false
	end

	local path = PathfindingProcessor.ComputePath(config.NPC, target)

	if not path then
		Debugging.Log(config.NPC, "Failed to compute path for Tracking state.")
		return false
	end

	local v = config.WaypointSkipping.TrackingPathfindSkip > 1 and { table.unpack(
			path,
			(math.min(config.WaypointSkipping.TrackingPathfindSkip, #path))
		) } or path
	data.StateMachine:ChangeData("Waypoints", v)

	if #v > 1 then
		data.StateMachine:ChangeData("RecallType", "Pathfind")
	else
		data.StateMachine:ChangeData("RecallType", "DirectMoveTo")
	end

	local function completedSignal() end

	WaypointLooper.StartContinuity(config.NPC, target, v, completedSignal)
	return true
end

function tracking.OnEnter(_, p)
	if not p.NPC then
		error("No NPC in data!")
	end

	Debugging.Log(p.NPC, "Tracking: " .. p.NPC:GetFullName())
	p.StateMachine:ChangeData("LastTrackingRecall", 0)
	p.StateMachine:ChangeData("LastTargetPosition", createVector(1e999, 1e999, 1e999))
	p.StateMachine:ChangeData("Waypoints", {})
end

function tracking.OnHeartbeat(_, data)
	NewRequestHandler(data) -- equivalent call inferred; original call site unknown
	local config = data.Config
	local NPC = config.NPC
	local humanoid = NPC:FindFirstChildOfClass("Humanoid")

	if NPC == nil or humanoid == nil or humanoid.Health == 0 then
		Debugging.Log(NPC, "NPC is nil, has no Humanoid, or is dead in Tracking state, cannot continue.")
		data.StateMachine:ChangeState("Idle")
	elseif data.Target == nil then
		Debugging.Log(NPC, "Target is nil or invalid in Tracking state, cannot continue.")
		data.StateMachine:ChangeState("Idle")
	else
		local basePart = Common.GetBasePart(data.Target, true, NPC)

		if basePart == nil then
			Debugging.Log(NPC, "Target is nil or invalid in Tracking state, cannot continue.")
			data.StateMachine:ChangeState("Idle")
		else
			if config.DirectMoveTo.JumpHandler.Enabled and #data.Waypoints > 0 and data.Waypoints[1].Label == "ForbiddenDirectMoveTo" then
				DirectMoveTo.DoJumpTick(config.NPC, data.Target)
			end

			if data.LastTrackingRecall + RetrackingOptimization.GetDynamicRetrackTimer(
				NPC,
				data.Target,
				data.RecallType
			) > os.clock() then
				return
			end

			local magnitude = (data.LastTargetPosition - basePart.CFrame.Position).Magnitude

			if magnitude < config.Tracking.DistanceMovedThreshold then
				Debugging.LogWithVerbosity(
					NPC,
					6,
					string.format("Distance moved requirement not exceeded. (%.3f)", magnitude)
				)
				return
			end

			if not RetrackingOptimization.ShouldRetrack(NPC, data.Target, data.RecallType) then
				return
			end

			data.StateMachine:ChangeData("LastTrackingRecall", os.clock())
			Debugging.Log("Recalling!")

			if not tracking:Pathfind(data) then
				Debugging.Log(NPC, "Recall failed! Target: ", data.Target)
			end

			data.StateMachine:ChangeData("LastTargetPosition", basePart.CFrame.Position)
		end
	end
end

function tracking.OnLeave(_, p)
	local config = p.Config
	Debugging.Log(config.NPC, "Leaving Tracking State for ", config.NPC:GetFullName())
end

return tracking