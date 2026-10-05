game:GetService("RunService")
local parent = script.Parent.Parent.Parent
require(parent.AI.Types)
local ConfigHandler = require(parent.AI.ConfigHandler)
local WaypointsVisualization = require(parent.AI.Visualization.WaypointsVisualization)
local Debugging = require(parent.AI.Debugging)
local WaypointLooper = {}
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isValid(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health ~= 0
end

local function LoopThroughWaypoints(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		error("nil human")
	end

	local activeConfig = ConfigHandler.GetActiveConfig(instance)
	local v2 = v[instance]
	local requestId = v2.RequestId
	local target = v2.Target
	local waypoints = v2.waypoints
	local completedSignal = v2.CompletedSignal
	local v3 = #waypoints
	local count = 0
	task.spawn(activeConfig.Hooks.PathingStarted, instance, waypoints)

	if activeConfig.Visualization.Enabled and activeConfig.Visualization.Path then
		WaypointsVisualization.VisualizeWaypoints(instance, waypoints)
	end

	for i = 1, v3 do
		if requestId ~= v[instance].RequestId then
			break
		end

		local valid = isValid(instance) -- equivalent call inferred; original call site unknown
		local v4 = valid and waypoints[i]

		if not v4 then
			break
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatString(p: number)
			return string.format("%.2f", p)
		end

		if activeConfig.Debugging.MovingToWaypoint then
			local log = Debugging.Log
			local v5 = formatString(v4.Position.X) -- equivalent call inferred; original call site unknown
			local v6 = formatString(v4.Position.Y) -- equivalent call inferred; original call site unknown
			local Z = v4.Position.Z
			log(
				instance,
				"Moving to waypoint: ",
				"(",
				v5,
				", ",
				v6,
				", ",
				string.format("%.2f", Z),
				") ",
				" with action: ",
				v4.Action,
				" and label: ",
				v4.Label
			)
		end

		if v4.Action == Enum.PathWaypointAction.Custom then
			task.spawn(activeConfig.Hooks.MovingToWaypoint, instance, v4, "PathfindingLink")

			if activeConfig.Hooks.PathfindingLinkReached(instance, v4) then
				continue
			else
				error("The PathfindingLinkReached returned false or nil, meaning it was unsuccessful for the Label: " .. v4.Label)
			end
		end

		if v4.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end

		humanoid:MoveTo(v4.Position)

		if v4.Label == "ForbiddenDirectMoveTo" then
			task.spawn(activeConfig.Hooks.MovingToWaypoint, instance, v4, "DirectMoveTo")
		else
			task.spawn(activeConfig.Hooks.MovingToWaypoint, instance, v4, "Pathing")
		end

		local v5 = humanoid.MoveToFinished:Wait()

		if v5 or not activeConfig.Unstucking.Enabled then
			if not (v5 or activeConfig.Unstucking.Enabled) then
				task.spawn(activeConfig.Hooks.PathingFailed, instance, "Stuck Limit Reached")
				break
			end
		else
			local log = Debugging.Log
			local v6 = formatString(v4.Position.X) -- equivalent call inferred; original call site unknown
			local v7 = formatString(v4.Position.Y) -- equivalent call inferred; original call site unknown
			local Z = v4.Position.Z
			log(
				instance,
				"Failed to move to waypoint: ",
				"(",
				v6,
				", ",
				v7,
				", ",
				string.format("%.2f", Z),
				") with action: ",
				v4.Action,
				" and label: ",
				v4.Label
			)
			count += 1

			if activeConfig.Unstucking.MaxStuckCount <= count then
				Debugging.Log(instance, "Max stuck count reached, breaking out of the loop.")
				task.spawn(activeConfig.Hooks.PathingFailed, instance, "Stuck Limit Reached")
				break
			else
				if activeConfig.Unstucking.FireStuckHook then
					if activeConfig.Hooks.Stuck(instance, target) then
						if requestId ~= v[instance].RequestId then
							break
						end

						Debugging.Log(instance, "Stuck hook was successful, continuing to next waypoint.")
					else
						if requestId ~= v[instance].RequestId then
							break
						end

						Debugging.Log(instance, "Stuck hook was unsuccessful, breaking out of the loop.")
						break
					end
				end

				if not (v5 or activeConfig.Unstucking.Enabled) then
					task.spawn(activeConfig.Hooks.PathingFailed, instance, "Stuck Limit Reached")
					break
				end
			end
		end
	end

	if requestId == v2.RequestId then
		completedSignal()
		activeConfig.Hooks.GoalReached(instance, v2.Target)
		WaypointLooper.EndContinuity(instance)
	end
end

function WaypointLooper.StartContinuity(p, target, waypoints, completedSignal)
	if not v[p] then
		v[p] = {
			RequestId = 0,
			Target = nil,
			index = 1,
			waypoints = {},
			CompletedSignal = function() end
		}
	end

	local v2 = v[p]
	v2.RequestId = v[p].RequestId + 1
	v2.Target = target
	v2.index = 1
	v2.waypoints = waypoints
	v2.CompletedSignal = completedSignal
	task.spawn(LoopThroughWaypoints, p)
end

function WaypointLooper.EndContinuity(p)
	local v2 = v[p]

	if v2 == nil then
		return
	end

	v2.RequestId = v[p].RequestId + 1
	v2.Target = nil
	v2.index = 1
	v2.waypoints = {}

	function v2.CompletedSignal() end
end

function WaypointLooper.TriggerCleanup(p)
	v[p] = nil
end

return WaypointLooper