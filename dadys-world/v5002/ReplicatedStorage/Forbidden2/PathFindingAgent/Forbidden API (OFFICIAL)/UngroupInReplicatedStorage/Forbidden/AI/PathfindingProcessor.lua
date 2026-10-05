local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")
local robloxstatemachine = require(ReplicatedStorage.Forbidden.Packages.robloxstatemachine)
local parent = script.Parent.Parent
local ConfigHandler = require(parent.AI.ConfigHandler)
local DirectMoveTo = require(parent.AI.DirectMoveTo)
local Common = require(parent.Common)
local Debugging = require(parent.AI.Debugging)
require(parent.AI.Types)
local v = {}
local v2 = {}
local v3 = {}
local PathfindingProcessor = {
	InitializeStateMachine = function(instance)
		if v[instance] then
			return
		end

		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			error("NPC Human is nil!")
		end

		local directory = robloxstatemachine:LoadDirectory(script.States)
		local idle = robloxstatemachine.new("Idle", directory, {
			Config = ConfigHandler.GetActiveConfig(instance),
			NPC = instance,
			Target = nil,
			Waypoints = {},
			LastTrackingRecall = 0,
			RecallType = "DirectMoveTo"
		})
		idle.StateChanged:Connect(function()
			local previousState = idle:GetPreviousState()
			local currentState = idle:GetCurrentState()
			Debugging.Log(instance, "State Changed: [", previousState, "] -> [", currentState, "]")
		end)
		idle.Data.StateMachine = idle
		v[instance] = idle

		local function DestroyStateMachine()
			Debugging.Log(instance, "Destroying State Machine for NPC: ", instance:GetFullName())

			if not v[instance] then
				return
			end

			v[instance]:Destroy()
			v[instance] = nil

			if v3[instance].PathObject then
				v3[instance].PathObject:Destroy()
			end

			v3[instance] = nil
			v2[instance] = nil
			collectgarbage("count")
		end

		humanoid.Died:Connect(DestroyStateMachine)
		instance.Destroying:Connect(DestroyStateMachine)
	end,
	PrintStateMachines = function()
		print(v)
	end
}

local function onPathBlocked(p, _: number)
	if v[p] == nil then
		return
	end

	if v[p].State.Name == "Idle" then
	end
end

local function onPathUnblocked(p, _: number)
	if v[p] == nil then
		return
	end

	if v[p].State.Name == "Idle" then
	end
end

local function ConfigurePath(p, pathObject)
	if v3[p] == nil then
		v3[p] = {
			AgentInfo = ConfigHandler.GetActiveConfig(p).AgentInfo,
			PathObject = pathObject,
			UsingPathfind = false
		}
	else
		v3[p].PathObject = pathObject
	end

	v3[p].UsingPathfind = true
	v2[p] = {}
end

local TablesAreEqual

TablesAreEqual = function(list, list2)
	if #list ~= #list2 then
		return false
	end

	for k, v4 in pairs(list) do
		local v5 = typeof(v4) == "table"
		local v6 = list2[k] == "table"

		if v5 and not v6 or v6 and not v5 or v5 and v6 and not TablesAreEqual(v4, list2[k]) or v4 ~= list2[k] then
			return false
		end
	end

	return true
end

local function GetPath(p)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if v3[p] and v3[p].PathObject and TablesAreEqual(v3[p].AgentInfo, activeConfig.AgentInfo) then
		return v3[p].PathObject
	end

	local path = PathfindingService:CreatePath(activeConfig.AgentInfo)
	path.Blocked:Connect(function(_: number)
		local v4 = p

		if v[v4] == nil then
			return
		end

		if v[v4].State.Name == "Idle" then
		end
	end)
	path.Unblocked:Connect(function(_: number)
		local v4 = p

		if v[v4] == nil then
			return
		end

		if v[v4].State.Name == "Idle" then
		end
	end)

	if not v3[p] then
		v3[p] = {}
	end

	if v3[p].PathObject then
		Debris:AddItem(v3[p].PathObject, 0)
	end

	v3[p].AgentInfo = activeConfig.AgentInfo
	v3[p].PathObject = path
	return path
end

function PathfindingProcessor.ComputePath(p, p2)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if Common.GetBasePart(p2, true, p) == nil then
		error("Could not convert Target into an Actual Instance")
	end

	if DirectMoveTo.CanUseDirectMoveTo(p, p2) then
		if v3[p] == nil then
			v3[p] = {}
		end

		v3[p].UsingPathfind = false
		return { PathWaypoint.new(
				DirectMoveTo.GetDirectMoveToPosition(p, p2),
				Enum.PathWaypointAction.Walk,
				"ForbiddenDirectMoveTo"
			) }
	else
		local pathObject = GetPath(p)
		ConfigurePath(p, pathObject)
		local basePart = Common.GetBasePart(p)
		local basePart2 = Common.GetBasePart(p2, true, p)
		pathObject:ComputeAsync(basePart.Position, basePart2.Position)

		if pathObject.Status == Enum.PathStatus.Success then
			return pathObject:GetWaypoints()
		end

		task.spawn(activeConfig.Hooks.PathingFailed, p, "Path Not Found")
		return nil
	end
end

function PathfindingProcessor.RawCompute(vector: Vector3, vector2: Vector3, p)
	local path = PathfindingService:CreatePath(p)
	path:ComputeAsync(vector, vector2)

	if path.Status == Enum.PathStatus.Success then
		return path:GetWaypoints()
	end

	return nil
end

return PathfindingProcessor