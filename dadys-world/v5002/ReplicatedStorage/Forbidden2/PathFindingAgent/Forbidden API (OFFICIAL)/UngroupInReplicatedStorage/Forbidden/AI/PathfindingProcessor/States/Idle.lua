local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent.Parent.Parent.Parent
local robloxstatemachine = require(ReplicatedStorage.Forbidden.Packages.robloxstatemachine)
require(parent.AI.Types)
local Debugging = require(parent.AI.Debugging)
local MessageQueue = require(parent.AI.MessageQueue)
require(parent.AI.ConfigHandler)
local WaypointLooper = require(parent.AI.PathfindingProcessor.WaypointLooper)
local WaypointsVisualization = require(parent.AI.Visualization.WaypointsVisualization)
local Common = require(parent.Common)
local idle = robloxstatemachine.State.new("Idle")

local function StopNPCByStopType(config)
	if config.StopType == "CurrentPosition" then
		local basePart = Common.GetBasePart(config.NPC)
		local humanoid = config.NPC:FindFirstChildOfClass("Humanoid")

		if basePart and humanoid then
			humanoid:MoveTo(basePart.CFrame.Position)
			basePart.CFrame = basePart.CFrame
		else
			Debugging.Log(config.NPC, "StopNPCByStopType: No ActualNPC or NPCHuman found.")
		end
	end

	local _ = config.StopType == "NoStopLogic"
end

local function NewRequestHandler(data)
	local config = data.Config
	local newRequest = MessageQueue.GetNewRequest(config.NPC)

	if newRequest == nil or (newRequest.ProcessingState == "Processing" or newRequest.ProcessingState == "Processed") then
		return
	end

	MessageQueue.SetActiveRequest(config.NPC, newRequest)

	if newRequest.RequestType == "Stop" then
		if data.Request == nil then
			return
		end

		data.Request.ProcessingState = "Processed"
		WaypointLooper.EndContinuity(config.NPC)
		task.spawn(config.Hooks.StopAcknowledged, config.NPC, newRequest.Target)
		WaypointsVisualization.DeleteVisualization(config.NPC)

		if data.Target ~= nil then
			StopNPCByStopType(config)
		end

		newRequest.ProcessingState = "Processed"
		data.StateMachine:ChangeData("Target", nil)
	else
		data.StateMachine:ChangeData("Request", newRequest)
		data.StateMachine:ChangeData("Target", newRequest.Target)

		if not newRequest.Target then
			Debugging.Log(config.NPC, "No target set for Idle state, cannot change to Pathing or Tracking.")
			return
		end

		config:ApplyNow()
		task.spawn(config.Hooks.StartAcknowledged, config.NPC, newRequest.Target)

		if config.Tracking.Enabled and typeof(newRequest.Target) == "Instance" then
			data.StateMachine:ChangeState("Tracking")
		else
			data.StateMachine:ChangeState("Pathing")
		end
	end
end

function idle.OnInit(_) end

function idle.OnEnter(_, p)
	if not p.NPC then
		error("No NPC in data!")
	end

	Debugging.Log(p.NPC, "Idle: " .. p.NPC:GetFullName())

	if p.Request and p.Request.FinishedSignal then
		p.Request.FinishedSignal:Fire()
	end
end

function idle.OnHeartbeat(_, p)
	local success, result = pcall(function()
		NewRequestHandler(p)
	end)

	if not success then
		print("StateMachine error:", result)
	end
end

function idle.OnLeave(p)
	local config = p.Data.Config
	Debugging.Log(config.NPC, "Leaving Idle State for ", config.NPC:GetFullName())
end

return idle