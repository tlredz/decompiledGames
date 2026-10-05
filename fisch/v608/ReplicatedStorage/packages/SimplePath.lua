local v = {
	TIME_VARIANCE = 0.07,
	COMPARISON_CHECKS = 1,
	JUMP_WHEN_STUCK = true
}
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

-- equivalent calls inferred from this helper; original call sites unknown
local function output(error2, p)
	error2((error2 == error and "SimplePath Error: " or "SimplePath: ") .. p)
end

local SimplePath = {
	StatusType = {
		Idle = "Idle",
		Active = "Active"
	},
	ErrorType = {
		LimitReached = "LimitReached",
		TargetUnreachable = "TargetUnreachable",
		ComputationError = "ComputationError",
		AgentStuck = "AgentStuck"
	}
}

function SimplePath:__index(p)
	if p == "Stopped" and not self._humanoid then
		local error2 = error
		output(error2, "Attempt to use Path.Stopped on a non-humanoid.") -- equivalent call inferred; original call site unknown
	end

	return self._events[p] and self._events[p].Event or p == "LastError" and self._lastError or p == "Status" and self._status or SimplePath[p]
end

local part = Instance.new("Part")
part.Size = vector.create(0.3, 0.3, 0.3)
part.Anchored = true
part.CanCollide = false
part.Material = Enum.Material.Neon
part.Shape = Enum.PartType.Ball

-- equivalent calls inferred from this helper; original call sites unknown
local function declareError(p, lastError)
	p._lastError = lastError
	p._events.Error:Fire(lastError)
end

local function createVisualWaypoints(_waypoints)
	local clones = {}

	for _, v2 in ipairs(_waypoints) do
		local clone = part:Clone()
		clone.Position = v2.Position
		clone.Parent = workspace
		clone.Color = v2 == _waypoints[#_waypoints] and Color3.fromRGB(0, 255, 0) or v2.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(
			255,
			0,
			0
		) or Color3.fromRGB(255, 139, 0)
		table.insert(clones, clone)
	end

	return clones
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyVisualWaypoints(_visualWaypoints)
	if _visualWaypoints then
		for _, v2 in ipairs(_visualWaypoints) do
			v2:Destroy()
		end
	end
end

local function getNonHumanoidWaypoint(state)
	for i = 2, #state._waypoints do
		if (state._waypoints[i].Position - state._waypoints[i - 1].Position).Magnitude > 0.1 then
			return i
		end
	end

	return 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setJumpState(p)
	pcall(function()
		if p._humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and p._humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			p._humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function move(data)
	if data._waypoints[data._currentWaypoint].Action == Enum.PathWaypointAction.Jump then
		setJumpState(data) -- equivalent call inferred; original call site unknown
	end

	data._humanoid:MoveTo(data._waypoints[data._currentWaypoint].Position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectMoveConnection(state)
	state._moveConnection:Disconnect()
	state._moveConnection = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invokeWaypointReached(data)
	local _waypoint = data._waypoints[data._currentWaypoint - 1]
	local _waypoint2 = data._waypoints[data._currentWaypoint]
	data._events.WaypointReached:Fire(data._agent, _waypoint, _waypoint2)
end

local function moveToFinished(state, p)
	if not getmetatable(state) then
		return
	end

	if state._humanoid then
		if p and state._currentWaypoint + 1 <= #state._waypoints then
			if state._currentWaypoint + 1 < #state._waypoints then
				invokeWaypointReached(state) -- equivalent call inferred; original call site unknown
			end

			state._currentWaypoint += 1
			move(state) -- equivalent call inferred; original call site unknown
		elseif p then
			disconnectMoveConnection(state) -- equivalent call inferred; original call site unknown
			state._status = SimplePath.StatusType.Idle
			destroyVisualWaypoints(state._visualWaypoints) -- equivalent call inferred; original call site unknown
			state._visualWaypoints = nil
			state._events.Reached:Fire(state._agent, state._waypoints[state._currentWaypoint])
		else
			disconnectMoveConnection(state) -- equivalent call inferred; original call site unknown
			state._status = SimplePath.StatusType.Idle
			destroyVisualWaypoints(state._visualWaypoints) -- equivalent call inferred; original call site unknown
			state._visualWaypoints = nil
			declareError(state, state.ErrorType.TargetUnreachable) -- equivalent call inferred; original call site unknown
		end
	elseif p and state._currentWaypoint + 1 <= #state._waypoints then
		invokeWaypointReached(state) -- equivalent call inferred; original call site unknown
		state._currentWaypoint += 1
	elseif p then
		destroyVisualWaypoints(state._visualWaypoints) -- equivalent call inferred; original call site unknown
		state._visualWaypoints = nil
		state._target = nil
		state._events.Reached:Fire(state._agent, state._waypoints[state._currentWaypoint])
	else
		destroyVisualWaypoints(state._visualWaypoints) -- equivalent call inferred; original call site unknown
		state._visualWaypoints = nil
		state._target = nil
		declareError(state, state.ErrorType.TargetUnreachable) -- equivalent call inferred; original call site unknown
	end
end

local function comparePosition(data)
	if data._currentWaypoint == #data._waypoints then
		return
	end

	data._position._count = not ((data._agent.PrimaryPart.Position - data._position._last).Magnitude <= 0.07) and 0 or data._position._count + 1 or 0
	data._position._last = data._agent.PrimaryPart.Position

	if data._position._count >= data._settings.COMPARISON_CHECKS then
		if data._settings.JUMP_WHEN_STUCK then
			setJumpState(data) -- equivalent call inferred; original call site unknown
		end

		declareError(data, data.ErrorType.AgentStuck) -- equivalent call inferred; original call site unknown
	end
end

function SimplePath.GetNearestCharacter(p)
	local magnitude = 1e999
	local character = nil

	for _, v2 in ipairs(Players:GetPlayers()) do
		if not (v2.Character and (v2.Character.PrimaryPart.Position - p).Magnitude < magnitude) then
			continue
		end

		character = v2.Character
		magnitude = (v2.Character.PrimaryPart.Position - p).Magnitude
	end

	return character
end

function SimplePath.new(model, p, p2)
	if not (model and model:IsA("Model") and model.PrimaryPart) then
		local error2 = error
		output(error2, "Pathfinding agent must be a valid Model Instance with a set PrimaryPart.") -- equivalent call inferred; original call site unknown
	end

	local object = setmetatable({
		_settings = p2 or v,
		_events = {
			Reached = Instance.new("BindableEvent"),
			WaypointReached = Instance.new("BindableEvent"),
			Blocked = Instance.new("BindableEvent"),
			Error = Instance.new("BindableEvent"),
			Stopped = Instance.new("BindableEvent")
		},
		_agent = model,
		_humanoid = model:FindFirstChildOfClass("Humanoid"),
		_path = PathfindingService:CreatePath(p),
		_status = "Idle",
		_t = 0,
		_position = {
			_last = Vector3.new(),
			_count = 0
		}
	}, SimplePath)

	for k, v2 in pairs(v) do
		object._settings[k] = object._settings[k] == nil and v2 or object._settings[k]
	end

	object._path.Blocked:Connect(function(...)
		if object._currentWaypoint <= ... then
			local v2 = object._currentWaypoint + 1

			if ... <= v2 and object._humanoid then
				setJumpState(object) -- equivalent call inferred; original call site unknown
				object._events.Blocked:Fire(object._agent, object._waypoints[...])
			end
		end
	end)
	return object
end

function SimplePath:Destroy()
	for _, _event in ipairs(self._events) do
		_event:Destroy()
	end

	self._events = nil

	if rawget(self, "_visualWaypoints") then
		destroyVisualWaypoints(self._visualWaypoints) -- equivalent call inferred; original call site unknown
		self._visualWaypoints = nil
	end

	self._path:Destroy()
	setmetatable(self, nil)

	for k, _ in pairs(self) do
		self[k] = nil
	end
end

function SimplePath:Stop()
	if self._humanoid then
		if self._status == SimplePath.StatusType.Idle then
			local v2 = (function(p)
				warn(debug.traceback(p))
			end == error and "SimplePath Error: " or "SimplePath: ") .. "Attempt to run Path:Stop() in idle state"
			warn(debug.traceback(v2))
		else
			disconnectMoveConnection(self) -- equivalent call inferred; original call site unknown
			self._status = SimplePath.StatusType.Idle
			destroyVisualWaypoints(self._visualWaypoints) -- equivalent call inferred; original call site unknown
			self._visualWaypoints = nil
			self._events.Stopped:Fire(self._model)
		end
	else
		local error2 = error
		output(error2, "Attempt to call Path:Stop() on a non-humanoid.") -- equivalent call inferred; original call site unknown
	end
end

function SimplePath:Run(part2)
	if not part2 and not self._humanoid and self._target then
		moveToFinished(self, true)
		return
	end

	if not part2 or typeof(part2) ~= "Vector3" and not part2:IsA("BasePart") then
		local error2 = error
		output(error2, "Pathfinding target must be a valid Vector3 or BasePart.") -- equivalent call inferred; original call site unknown
	end

	if os.clock() - self._t <= self._settings.TIME_VARIANCE and self._humanoid then
		task.wait(os.clock() - self._t)
		declareError(self, self.ErrorType.LimitReached) -- equivalent call inferred; original call site unknown
		return false
	else
		if self._humanoid then
			self._t = os.clock()
		end

		local success, _ = pcall(function()
			self._path:ComputeAsync(
				self._agent.PrimaryPart.Position,
				typeof(part2) == "Vector3" and part2 or part2.Position
			)
		end)

		if success and self._path.Status ~= Enum.PathStatus.NoPath and not (#self._path:GetWaypoints() < 2) and (not self._humanoid or self._humanoid:GetState() ~= Enum.HumanoidStateType.Freefall) then
			self._status = self._humanoid and SimplePath.StatusType.Active or SimplePath.StatusType.Idle
			self._target = part2
			pcall(function()
				self._agent.PrimaryPart:SetNetworkOwner(nil)
			end)
			self._waypoints = self._path:GetWaypoints()
			self._currentWaypoint = 2

			if self._humanoid then
				comparePosition(self)
			end

			destroyVisualWaypoints(self._visualWaypoints) -- equivalent call inferred; original call site unknown
			self._visualWaypoints = self.Visualize and createVisualWaypoints(self._waypoints)
			self._moveConnection = self._humanoid and (self._moveConnection or self._humanoid.MoveToFinished:Connect(function(...)
				moveToFinished(self, ...)
			end))

			if self._humanoid then
				self._humanoid:MoveTo(self._waypoints[self._currentWaypoint].Position)
			elseif #self._waypoints == 2 then
				self._target = nil
				destroyVisualWaypoints(self._visualWaypoints) -- equivalent call inferred; original call site unknown
				self._visualWaypoints = nil
				self._events.Reached:Fire(self._agent, self._waypoints[2])
			else
				self._currentWaypoint = getNonHumanoidWaypoint(self)
				moveToFinished(self, true)
			end

			return true
		else
			destroyVisualWaypoints(self._visualWaypoints) -- equivalent call inferred; original call site unknown
			self._visualWaypoints = nil
			task.wait()
			declareError(self, self.ErrorType.ComputationError) -- equivalent call inferred; original call site unknown
			return false
		end
	end
end

return SimplePath