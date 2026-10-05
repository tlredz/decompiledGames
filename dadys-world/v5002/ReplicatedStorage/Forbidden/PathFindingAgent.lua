local createVector = vector.create
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PathFindingAgent = {}
PathFindingAgent.__index = PathFindingAgent

local function GetAgentPath(path, position, position2)
	local success, _ = pcall(function()
		path:ComputeAsync(position, position2)
	end)

	if not success or path.Status ~= Enum.PathStatus.Success then
		return
	end

	local waypoints = path:GetWaypoints()
	local v = 2
	local flag = false
	local blockedConnection = nil
	blockedConnection = path.Blocked:Connect(function(p)
		if v <= p then
			flag = true
			blockedConnection:Disconnect()
		end
	end)
	return function()
		if flag then
			return false
		end

		v += 1

		if waypoints[v] then
			return waypoints[v].Position
		end

		blockedConnection:Disconnect()
		return false
	end
end

local function FindRandomWalkVector(p, p2)
	local count = 0
	local v

	while true do
		count += 1
		local v2 = math.random(-p2, p2)
		local v3 = math.random(-p2, p2)
		v = p + Vector3.new(v2, 0, v3)
		local v4 = p - Vector3.new(v2, 0, v3) + createVector(4, 4, 4)
		local region = Region3.new(v, v4)

		if game.Workspace:IsRegion3Empty(region) then
			break
		end

		if count >= 10 then
			return
		end
	end

	return v
end

function PathFindingAgent.CreateAgent(_, agent, settings)
	local self = setmetatable({}, PathFindingAgent)
	self.Agent = agent
	self.Settings = settings
	self.is_activated = nil
	self.movement_states = {
		InPath = 0,
		WaitingForPath = 1,
		Idling = 2,
		Dead = 3,
		Pathfinding = 4,
		Chasing = 5
	}
	self.status_states = {
		Activated = 0,
		DeActivated = 1,
		Contained = 2
	}
	self.curr_movement_state = self.movement_states.Idling
	self.curr_status_state = self.status_states.DeActivated
	self.update_connection = nil
	self.Humanoid = self.Agent:WaitForChild("Humanoid")
	self.HumanoidRootPart = self.Agent:WaitForChild("HumanoidRootPart")
	self.Torso = self.Agent:WaitForChild("Torso")
	local _, bounding_box = self.Agent:GetBoundingBox()
	self.bounding_box = bounding_box

	for _, part in pairs(self.Agent:GetChildren()) do
		part:IsA("BasePart")
	end

	return self
end

function PathFindingAgent:Activate()
	self.update_connection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
	self.is_activated = true
end

function PathFindingAgent:Disable()
	if not self.is_activated then
		return
	end

	self.update_connection:Disconnect()
	self.current_movement_state = self.Movemenet_States.Idle
end

function PathFindingAgent:FindClosestTarget()
	local players = Players:GetPlayers()
	local v = 1e999
	local v2 = nil

	for _, player in ipairs(players) do
		local character = player.Character

		if not character then
			return
		end

		local vector2 = character.HumanoidRootPart.Position - self.HumanoidRootPart.Position
		local dot = vector2:Dot(vector2)

		if not (dot < v) then
			continue
		end

		v2 = player
		v = dot
	end

	if v2 then
		return v2.Character, v
	end

	return warn("No Closest Target Found")
end

function PathFindingAgent:StraightLineToTarget(p)
	if not p then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { self.Agent }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local position = self.HumanoidRootPart.Position
	local position2 = p.HumanoidRootPart.Position
	local cFrame = p.HumanoidRootPart.CFrame
	local v = math.sign(((position2 - position):Dot(cFrame.RightVector)))
	local bounding_box = self.bounding_box
	local v2 = self.HumanoidRootPart.CFrame * Vector3.new(-v * bounding_box.X / 2, 0, bounding_box.Z / 2)
	local raycastResult = workspace:Raycast(v2, position2 - v2, raycastParams)

	if raycastResult then
		return raycastResult.Instance.Parent == p
	end
end

function PathFindingAgent:PathfindToTarget(p)
	local agentPath = GetAgentPath(PathfindingService:CreatePath({
		AgentRadius = 4,
		AgentHeight = 1,
		AgentCanJump = false
	}), self.HumanoidRootPart.Position, p.HumanoidRootPart.Position)

	if not agentPath then
		self.curr_movement_state = self.movement_states.WaitingForPath
		return
	end

	while true do
		local v2 = (self.curr_movement_state ~= self.movement_states.Idling or self.curr_movement_state ~= self.movement_states.Chasing) and agentPath()

		if not v2 then
			break
		end

		self.Humanoid:MoveTo(v2)

		repeat
			local position3 = self.HumanoidRootPart.Position
			local dot = (position3 - v2):Dot(position3 - v2)
			self.Humanoid:MoveTo(v2)
			RunService.Heartbeat:Wait()
		until dot <= self.Settings.Waypoint_Threshold * self.Settings.Waypoint_Threshold or self.curr_movement_state == self.movement_states.Idling or self.curr_movement_state == self.movement_states.Chasing
	end

	if self.curr_movement_state == self.movement_states.Pathfinding then
		self.curr_movement_state = self.movement_states.WaitingForPath
	end
end

function PathFindingAgent:PathfindToPosition() end

function PathFindingAgent:ChaseTarget(p)
	while self.curr_movement_state ~= self.movement_states.Idling and self:StraightLineToTarget(p) do
		self.Humanoid:MoveTo(p.HumanoidRootPart.Position)
		RunService.Heartbeat:Wait()
	end

	self.curr_movement_state = self.movement_states.WaitingForPath
end

function PathFindingAgent:Update()
	if self.status_states ~= self.status_states.Activated then
		return
	end

	local closestTarget, v = self:FindClosestTarget()
	local v2

	if closestTarget then
		v2 = v < self.Settings.SCP_RANGE * self.Settings.SCP_RANGE and closestTarget or nil
	end

	if v2 then
		if self.curr_movement_state == self.movement_states.Pathfinding then
			if self:StraightLineToTarget(v2) then
				self.curr_movement_state = self.movement_states.Chasing
				self:ChaseTarget(v2)
				return
			end
		elseif self.curr_movement_state == self.movement_states.WaitingForPath then
			self.Humanoid:MoveTo(self.HumanoidRootPart.CFrame * createVector(0, 0, -5))
		elseif self.curr_movement_state == self.movement_states.Chasing then
			return
		end

		self.curr_movement_state = self.movement_states.Pathfinding
		self:PathfindToTarget(v2)
	else
		self.curr_movement_state = self.movement_states.Idling
		local _ = self.Settings.RandomWalkBounds
		self:PathfindToPosition(nil)
	end
end

return PathFindingAgent