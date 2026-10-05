local ReplicatedStorage = game:GetService("ReplicatedStorage")
local robloxstatemachine = require(ReplicatedStorage.Forbidden.Packages.robloxstatemachine)
local parent = script.Parent.Parent.Parent.Parent
local Debugging = require(parent.AI.Debugging)
local MessageQueue = require(parent.AI.MessageQueue)
local PathfindingProcessor = require(parent.AI.PathfindingProcessor)
local WaypointLooper = require(parent.AI.PathfindingProcessor.WaypointLooper)
require(parent.Common)
local DirectMoveTo = require(parent.AI.DirectMoveTo)
require(parent.AI.Types)
local pathing = robloxstatemachine.State.new("Pathing")

local function NewRequestHandler(data)
	local config = data.Config
	local newRequest = MessageQueue.GetNewRequest(config.NPC)

	if not (newRequest ~= nil and data.Request ~= newRequest) then
		return
	end

	data.StateMachine:ChangeState("Idle")
	return true
end

function pathing.OnInit(_) end

function pathing.OnEnter(_, data)
	data.StateMachine:ChangeData("Waypoints", {})

	if not data.NPC then
		error("No NPC in data!")
	end

	Debugging.Log(data.NPC, "Pathing: " .. data.NPC:GetFullName())
	local config = data.Config
	local target = data.Target

	if not target then
		Debugging.Log(config.NPC, "No target set for Pathing state, cannot compute path.")
		return
	end

	local path = PathfindingProcessor.ComputePath(config.NPC, target)

	if not path then
		Debugging.Log(config.NPC, "Failed to compute path for Pathing state.")
		return
	end

	local v = config.WaypointSkipping.RegularPathfindSkip > 1 and { table.unpack(
			path,
			(math.min(config.WaypointSkipping.RegularPathfindSkip, #path))
		) } or path
	data.StateMachine:ChangeData("Waypoints", v)
	local request = data.Request

	local function completedSignal()
		if data.StateMachine:GetCurrentState() ~= "Pathing" then
			Debugging.Log(config.NPC, "Pathing state has changed, stopping waypoint looper.")
			return
		end

		Debugging.Log(config.NPC, "Pathing completed for ", config.NPC:GetFullName())

		if request ~= data.Request then
			Debugging.Log(config.NPC, "Request has changed during pathing, stopping current pathing.")
			return
		end

		data.Request.ProcessingState = "Processed"
		data.StateMachine:ChangeState("Idle")
	end

	WaypointLooper.StartContinuity(config.NPC, target, v, completedSignal)
end

function pathing.OnHeartbeat(_, data)
	local config = data.Config
	local newRequest = MessageQueue.GetNewRequest(config.NPC)
	local flag

	if not (newRequest == nil or data.Request == newRequest) then
		data.StateMachine:ChangeState("Idle")
		flag = true
	end

	if flag then
		return
	end

	local config2 = data.Config
	local target = data.Target

	if not target then
		Debugging.Log(config2.NPC, "No target set for Pathing state, cannot continue pathing.")
	elseif config2.DirectMoveTo.JumpHandler.Enabled and not config2.DirectMoveTo.TrackingOnly and #data.Waypoints > 0 and data.Waypoints[1].Label == "ForbiddenDirectMoveTo" then
		DirectMoveTo.DoJumpTick(config2.NPC, target)
	end
end

function pathing.OnLeave(p)
	local config = p.Data.Config
	Debugging.Log(config.NPC, "Leaving Pathing State for ", config.NPC:GetFullName())
end

return pathing