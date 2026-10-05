local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local stage14LocalNPC = ReplicatedStorage:WaitForChild("Stage14LocalNPC")
local v = {}
local v2 = {}
local v3 = false

local function applyGateState(items)
	for _, item in items do
		if not item.part.Parent then
			continue
		end

		item.part.Transparency = v3 and 1 or item.transparency
		local part = item.part
		part.CanCollide = not v3 and item.canCollide
		local part2 = item.part
		part2.CanTouch = not v3 and item.canTouch
		local part3 = item.part
		part3.CanQuery = not v3 and item.canQuery
	end
end

local function registerGate(folder)
	if v2[folder] then
		return
	end

	local v4 = {
		parts = {},
		descendantConnection = nil
	}
	v2[folder] = v4

	local function addPart(part)
		if not part:IsA("BasePart") then
			return
		end

		for _, part2 in v4.parts do
			if part2.part == part then
				return
			end
		end

		local v5 = {
			part = part,
			transparency = part.Transparency,
			canCollide = part.CanCollide,
			canTouch = part.CanTouch,
			canQuery = part.CanQuery
		}
		table.insert(v4.parts, v5)
		applyGateState({ v5 })
	end

	addPart(folder)

	for _, descendant in folder:GetDescendants() do
		addPart(descendant)
	end

	if not folder:IsA("BasePart") then
		v4.descendantConnection = folder.DescendantAdded:Connect(addPart)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setGatesOpen(flag: boolean)
	v3 = flag

	for _, v4 in v2 do
		applyGateState(v4.parts)
	end
end

local function numberAttribute(attributeName: string, p: number)
	local attribute = stage14LocalNPC:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

local function isInsideZone(instance, position: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
		instance.Size.Y / 2,
		30
	) and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

local function loadTrack(animator, clone, p: string)
	local animation = clone:FindFirstChild(p .. "Animation", true)

	if animation and animation:IsA("Animation") and animation.AnimationId ~= "" then
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		return track
	else
		local attribute = stage14LocalNPC:GetAttribute(p .. "AnimationId")

		if typeof(attribute) ~= "string" or attribute == "" then
			return nil
		end

		local animation2 = Instance.new("Animation")
		animation2.AnimationId = attribute
		local track = animator:LoadAnimation(animation2)
		animation2:Destroy()
		track.Looped = true
		return track
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeCountdownGui()
	local stage14LocalNPCCountdownGui = playerGui:FindFirstChild("Stage14LocalNPCCountdownGui")

	if stage14LocalNPCCountdownGui then
		stage14LocalNPCCountdownGui:Destroy()
	end
end

local function showCountdown(text: string, flag: boolean)
	removeCountdownGui() -- equivalent call inferred; original call site unknown
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Stage14LocalNPCCountdownGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.36)
	textLabel.Size = UDim2.fromScale(0.55, 0.18)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBlack
	textLabel.Text = text
	local textColor

	if flag then
		textColor = Color3.fromRGB(255, 45, 45)
	else
		textColor = Color3.fromRGB(255, 170, 35)
	end

	textLabel.TextColor3 = textColor
	textLabel.TextScaled = true
	textLabel.Parent = screenGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 4
	uIStroke.Parent = textLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setState(state, state2: string)
	if state.state == state2 then
		return
	end

	state.state = state2

	if state2 == "Chasing" or state2 == "Returning" then
		if state.idleTrack and state.idleTrack.IsPlaying then
			state.idleTrack:Stop(0.15)
		end

		if state.walkTrack and not state.walkTrack.IsPlaying then
			state.walkTrack:Play(0.15)
		end
	else
		if state.walkTrack and state.walkTrack.IsPlaying then
			state.walkTrack:Stop(0.15)
		end

		if state.idleTrack and not state.idleTrack.IsPlaying then
			state.idleTrack:Play(0.15)
		end
	end

	if state2 == "Chasing" then
		if state.chaseMusic and not state.chaseMusic.IsPlaying then
			state.chaseMusic:Play()
		end
	elseif state.chaseMusic and state.chaseMusic.IsPlaying then
		state.chaseMusic:Stop()
	end

	if state2 == "Returning" then
		state.lastReturnPosition = state.root.Position
		state.lastReturnProgressTime = os.clock()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPath(p)
	p.waypoints = {}
	p.waypointIndex = 0
	p.lastPathRequest = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestPath(state, vector: Vector3)
	if state.computingPath then
		return
	end

	state.computingPath = true
	local position = state.root.Position
	task.spawn(function()
		local agentRadius = stage14LocalNPC:GetAttribute("AgentRadius")
		local v5 = {
			AgentRadius = typeof(agentRadius) ~= "number" and 2 or agentRadius,
			AgentHeight = 0,
			AgentCanJump = false,
			AgentCanClimb = false,
			WaypointSpacing = 0
		}
		local agentHeight = stage14LocalNPC:GetAttribute("AgentHeight")
		v5.AgentHeight = typeof(agentHeight) ~= "number" and 5 or agentHeight
		local waypointSpacing = stage14LocalNPC:GetAttribute("WaypointSpacing")
		v5.WaypointSpacing = typeof(waypointSpacing) ~= "number" and 4 or waypointSpacing
		local path = PathfindingService:CreatePath(v5)
		local v6 = pcall(function()
			path:ComputeAsync(position, vector)
		end)

		if state.alive and v6 and path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()

			if #waypoints >= 2 then
				state.waypoints = waypoints
				state.waypointIndex = 2
			end
		end

		state.computingPath = false
	end)
end

local function hasLineOfSight(state, vector: Vector3)
	local character = localPlayer.Character
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local filterDescendantsInstances

	if character then
		filterDescendantsInstances = { state.model, character }
	else
		filterDescendantsInstances = { state.model }
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local position = state.root.Position
	local vector2 = Vector3.new(vector.X - position.X, 0, vector.Z - position.Z)
	return workspace:Raycast(position, vector2, raycastParams) == nil
end

local function moveTowards(state, vector: Vector3, p: number, p2: number)
	local now = os.clock()
	local v4 = now - state.lastPathRequest
	local pathRecompute = stage14LocalNPC:GetAttribute("PathRecompute")

	if (typeof(pathRecompute) ~= "number" and 0.35 or pathRecompute) <= v4 then
		state.lastPathRequest = now
		requestPath(state, vector) -- equivalent call inferred; original call site unknown
	end

	local position = nil

	if hasLineOfSight(state, vector) then
		position = vector
	elseif state.waypointIndex > 0 and state.waypointIndex <= #state.waypoints then
		position = state.waypoints[state.waypointIndex].Position
		local magnitude = Vector2.new(state.root.Position.X - position.X, state.root.Position.Z - position.Z).Magnitude
		local waypointReach = stage14LocalNPC:GetAttribute("WaypointReach")

		if magnitude <= (typeof(waypointReach) ~= "number" and 3 or waypointReach) then
			state.waypointIndex += 1

			if state.waypoints[state.waypointIndex] then
				position = state.waypoints[state.waypointIndex].Position or nil
			else
				position = nil
			end
		end
	end

	if not position then
		return
	end

	local position2 = state.root.Position
	local v5 = position.X - position2.X
	local v6 = position.Z - position2.Z
	local v7 = math.sqrt(v5 * v5 + v6 * v6)

	if v7 <= 0.05 then
		return
	end

	local v8 = math.min(p * math.min(p2, 0.1), v7)
	local vector2 = Vector3.new(position2.X + v5 / v7 * v8, state.spawnCFrame.Position.Y, position2.Z + v6 / v7 * v8)
	local v9 = vector2 + Vector3.new(v5 / v7, 0, v6 / v7)
	state.model:PivotTo(CFrame.lookAt(vector2, v9))

	if state.footstep then
		local v10 = now - state.lastFootstep
		local footstepInterval = stage14LocalNPC:GetAttribute("FootstepInterval")

		if (typeof(footstepInterval) ~= "number" and 0.5 or footstepInterval) <= v10 then
			state.lastFootstep = now
			state.footstep:Play()
		end
	end
end

local function startCountdown(state)
	setState(state, "Countdown") -- equivalent call inferred; original call site unknown
	state.countdownToken += 1
	local countdownToken = state.countdownToken
	local countdown = stage14LocalNPC:GetAttribute("Countdown")
	local v4 = math.max(1, (math.floor(typeof(countdown) ~= "number" and 5 or countdown)))
	task.spawn(function()
		for i = v4, 1, -1 do
			if not state.alive or state.countdownToken ~= countdownToken or state.state ~= "Countdown" then
				return
			end

			showCountdown("BBNOS INCOMING  " .. i, false)
			task.wait(1)
		end

		if not state.alive or state.countdownToken ~= countdownToken or state.state ~= "Countdown" then
			return
		end

		showCountdown("RUN!", true)
		task.delay(1.2, removeCountdownGui)
		setGatesOpen(true) -- equivalent call inferred; original call site unknown
		clearPath(state) -- equivalent call inferred; original call site unknown
		setState(state, "Chasing") -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupZone(p)
	local v4 = v[p]

	if not v4 then
		return
	end

	v4.alive = false
	v4.countdownToken += 1
	v4.hitboxConnection:Disconnect()
	v4.model:Destroy()
	v[p] = nil
	removeCountdownGui() -- equivalent call inferred; original call site unknown
end

local function setupZone(part)
	if not part:IsA("BasePart") or v[part] then
		return
	end

	local clone = stage14LocalNPC:Clone()
	clone.Name = "Stage14LocalNPC_Local"
	clone.Parent = workspace
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local hitbox = clone:FindFirstChild("Hitbox", true)

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and hitbox and hitbox:IsA("BasePart") then
		local v4 = humanoid:FindFirstChildOfClass("Animator")

		if not v4 then
			v4 = Instance.new("Animator")
			v4.Parent = humanoid
		end

		for _, part2 in clone:GetDescendants() do
			if part2:IsA("BasePart") then
				part2.CanCollide = false
			end
		end

		humanoidRootPart.Anchored = true
		hitbox.CanTouch = true
		local pivot = stage14LocalNPC:GetPivot()
		clone:PivotTo(pivot)
		local chaseMusic = humanoidRootPart:FindFirstChild("ChaseMusic")
		local footstep = humanoidRootPart:FindFirstChild("Footstep")
		local touchedConnection = hitbox.Touched:Connect(function(otherPart)
			local character = localPlayer.Character

			if not (character and otherPart:IsDescendantOf(character)) then
				return
			end

			local humanoid2 = character:FindFirstChildOfClass("Humanoid")

			if humanoid2 and humanoid2.Health > 0 then
				humanoid2.Health = 0
			end
		end)
		local v5 = {
			zone = part,
			model = clone,
			root = humanoidRootPart,
			humanoid = humanoid,
			spawnCFrame = pivot,
			state = "Idle",
			alive = true,
			countdownToken = 0,
			waypoints = {},
			waypointIndex = 0,
			computingPath = false,
			lastPathRequest = 0,
			walkTrack = loadTrack(v4, clone, "Walk"),
			idleTrack = loadTrack(v4, clone, "Idle"),
			chaseMusic = 0,
			footstep = 0,
			lastFootstep = 0,
			hitboxConnection = 0,
			lastReturnPosition = 0,
			lastReturnProgressTime = 0
		}

		if not (chaseMusic and chaseMusic:IsA("Sound")) then
			chaseMusic = nil
		end

		v5.chaseMusic = chaseMusic

		if not (footstep and footstep:IsA("Sound")) then
			footstep = nil
		end

		v5.footstep = footstep
		v5.hitboxConnection = touchedConnection
		v5.lastReturnPosition = humanoidRootPart.Position
		v5.lastReturnProgressTime = os.clock()
		v[part] = v5

		if v5.idleTrack then
			v5.idleTrack:Play(0.1)
		end
	else
		warn("[Stage14LocalNPC] HumanoidRootPart, Humanoid ou Hitbox introuvable dans", stage14LocalNPC:GetFullName())
		clone:Destroy()
	end
end

RunService.PreRender:Connect(function(dt)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	for k, v4 in v do
		if k:IsDescendantOf(workspace) and v4.model.Parent then
			local v5

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0 and humanoidRootPart then
				v5 = isInsideZone(k, humanoidRootPart.Position)
			else
				v5 = false
			end

			if v4.state == "Idle" then
				if v5 then
					startCountdown(v4)
				end
			elseif v4.state == "Countdown" then
				if not v5 then
					v4.countdownToken += 1
					removeCountdownGui() -- equivalent call inferred; original call site unknown
					setState(v4, "Idle") -- equivalent call inferred; original call site unknown
				end
			elseif v4.state == "Chasing" then
				if v5 then
					if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						local position = humanoidRootPart.Position
						local chaseSpeed = stage14LocalNPC:GetAttribute("ChaseSpeed")
						moveTowards(v4, position, typeof(chaseSpeed) ~= "number" and 60 or chaseSpeed, dt)
					end
				else
					clearPath(v4) -- equivalent call inferred; original call site unknown
					setState(v4, "Returning") -- equivalent call inferred; original call site unknown
				end
			elseif v4.state == "Returning" then
				local v6 = v4.root.Position - v4.spawnCFrame.Position
				local magnitude = Vector2.new(v6.X, v6.Z).Magnitude

				if Vector2.new(
					v4.root.Position.X - v4.lastReturnPosition.X,
					v4.root.Position.Z - v4.lastReturnPosition.Z
				).Magnitude >= 0.5 then
					v4.lastReturnPosition = v4.root.Position
					v4.lastReturnProgressTime = os.clock()
				end

				local returnStuckTimeout = stage14LocalNPC:GetAttribute("ReturnStuckTimeout")
				local v7 = (typeof(returnStuckTimeout) ~= "number" and 3 or returnStuckTimeout) <= os.clock() - v4.lastReturnProgressTime
				local stopDistance = stage14LocalNPC:GetAttribute("StopDistance")

				if magnitude <= (typeof(stopDistance) ~= "number" and 3 or stopDistance) or v7 then
					v4.model:PivotTo(v4.spawnCFrame)
					clearPath(v4) -- equivalent call inferred; original call site unknown
					setState(v4, "Idle") -- equivalent call inferred; original call site unknown
					setGatesOpen(false) -- equivalent call inferred; original call site unknown
				else
					local position = v4.spawnCFrame.Position
					local returnSpeed = stage14LocalNPC:GetAttribute("ReturnSpeed")
					moveTowards(v4, position, typeof(returnSpeed) ~= "number" and 70 or returnSpeed, dt)
				end
			end
		else
			cleanupZone(k) -- equivalent call inferred; original call site unknown
		end
	end
end)

for _, v4 in CollectionService:GetTagged("World4Stage14LocalNPCAttackZone") do
	task.spawn(setupZone, v4)
end

CollectionService:GetInstanceAddedSignal("World4Stage14LocalNPCAttackZone"):Connect(function(p)
	task.spawn(setupZone, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage14LocalNPCAttackZone"):Connect(function(part)
	if part:IsA("BasePart") then
		cleanupZone(part) -- equivalent call inferred; original call site unknown
	end
end)

for _, v4 in CollectionService:GetTagged("W4S14Gate") do
	registerGate(v4)
end

CollectionService:GetInstanceAddedSignal("W4S14Gate"):Connect(registerGate)
CollectionService:GetInstanceRemovedSignal("W4S14Gate"):Connect(function(p)
	local v4 = v2[p]

	if v4 and v4.descendantConnection then
		v4.descendantConnection:Disconnect()
	end

	v2[p] = nil
end)