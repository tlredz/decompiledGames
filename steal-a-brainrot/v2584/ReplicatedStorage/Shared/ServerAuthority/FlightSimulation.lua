local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local isServer = RunService:IsServer()

local function dprint(...) end

local waverider = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Tools"):WaitForChild("Waverider")
local idleAnimation = waverider:WaitForChild("IdleAnimation")
local movingAnimation = waverider:WaitForChild("MovingAnimation")
local FlightSimulation = {
	FlyingAttribute = "FlightActive",
	GearAttribute = "FlightGear",
	SpeedAttribute = "FlightSpeed"
}
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getContext(instance)
	return (instance:FindFirstChild("ToolInputContext"))
end

local function getAction(instance, childName: string)
	local context = getContext(instance) -- equivalent call inferred; original call site unknown
	local inputAction = context and context:FindFirstChild(childName)

	if inputAction and inputAction:IsA("InputAction") then
		return inputAction
	end

	return nil
end

local function getActivateState(instance)
	local context = getContext(instance) -- equivalent call inferred; original call site unknown
	local toolActivate = context and context:FindFirstChild("ToolActivate")

	if not (toolActivate and toolActivate:IsA("InputAction")) then
		toolActivate = nil
	end

	return toolActivate ~= nil and toolActivate:GetState() == true
end

local function getMoveAction(instance)
	local inputContexts = instance:FindFirstChild("InputContexts")
	local characterContext = inputContexts and inputContexts:FindFirstChild("CharacterContext")
	local moveAction = characterContext and characterContext:FindFirstChild("MoveAction")

	if moveAction and moveAction:IsA("InputAction") then
		return moveAction
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCameraLook(instance)
	return instance:GetCameraState().CFrame.LookVector
end

local function getEquippedFlightTool(instance)
	local tool = instance:FindFirstChildWhichIsA("Tool")

	if tool and tool:GetAttribute("FlightGear") then
		return tool
	end

	return nil
end

local function ensureMovers(parent)
	local v4 = parent:FindFirstChild("FlightLinearVelocity")
	local flightCharacterAlignOrientation = parent:FindFirstChild("FlightCharacterAlignOrientation")

	if v4 and v4:IsA("LinearVelocity") and flightCharacterAlignOrientation and flightCharacterAlignOrientation:IsA("AlignOrientation") then
		return v4, flightCharacterAlignOrientation
	end

	local attachment = parent:FindFirstChild("FlightMoverAttachment")

	if not (attachment and attachment:IsA("Attachment")) then
		attachment = Instance.new("Attachment")
		attachment.Name = "FlightMoverAttachment"
		attachment.Parent = parent
	end

	if not (v4 and v4:IsA("LinearVelocity")) then
		v4 = Instance.new("LinearVelocity")
		v4.Name = "FlightLinearVelocity"
		v4.Attachment0 = attachment
		v4.RelativeTo = Enum.ActuatorRelativeTo.World
		v4.ForceLimitMode = Enum.ForceLimitMode.Magnitude
		v4.MaxForce = 0
		v4.VectorVelocity = createVector(0, 0, 0)
		v4.Enabled = false
		v4.Parent = parent
	end

	if flightCharacterAlignOrientation and flightCharacterAlignOrientation:IsA("AlignOrientation") then
		return v4, flightCharacterAlignOrientation
	end

	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Name = "FlightCharacterAlignOrientation"
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.RigidityEnabled = false
	alignOrientation.MaxTorque = 0
	alignOrientation.Responsiveness = 40
	alignOrientation.Enabled = false
	alignOrientation.Parent = parent
	return v4, alignOrientation
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFlying(instance)
	return instance:GetAttribute("FlightActive") == true
end

local function applyFlyingSideEffects(_, instance, parent2, platformStand: boolean)
	if platformStand then
		ensureMovers(parent2)
	end

	local parent = parent2.Parent
	local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.PlatformStand = platformStand

		if not platformStand then
			humanoid.AutoRotate = true
		end
	end

	instance:SetAttribute("IsActive", platformStand)
	local v4 = v[instance]

	if v4 and v4.config.onFlyingChanged then
		local onFlyingChanged = v4.config.onFlyingChanged
		local success, result = pcall(onFlyingChanged, platformStand, instance, parent2)

		if not success then
			warn((`[FlightSimulation] onFlyingChanged error for {instance.Name}: {tostring(result)}`))
		end
	end
end

local function tryToggle(player, tool, humanoidRootPart)
	local now = os.clock()

	if (tool:GetAttribute("FlightToggleCooldown") or 0.35) > now - (v3[player] or -1e999) then
		return
	end

	local flying = isFlying(humanoidRootPart) -- equivalent call inferred; original call site unknown

	if not flying then
		if player:GetAttribute("NoFlyZone") then
			return
		end

		if isServer then
			local v4 = v[tool]

			if v4 and v4.config.canToggle and not v4.config.canToggle() then
				return
			end
		end
	end

	v3[player] = now
	local v4 = not flying
	dprint("toggle", tool.Name, player.Name, "->", v4)
	humanoidRootPart:SetAttribute("FlightActive", v4)

	if isServer then
		task.defer(applyFlyingSideEffects, player, tool, humanoidRootPart, v4)
	end
end

local function driveFlight(player, tool, humanoidRootPart, p: number)
	local flightLinearVelocity = humanoidRootPart:FindFirstChild("FlightLinearVelocity")
	local flightCharacterAlignOrientation = humanoidRootPart:FindFirstChild("FlightCharacterAlignOrientation")

	if not (flightLinearVelocity and flightCharacterAlignOrientation) or not isServer and (RunService:GetPredictionStatus(flightLinearVelocity) == Enum.PredictionStatus.None or RunService:GetPredictionStatus(flightCharacterAlignOrientation) == Enum.PredictionStatus.None) then
		return
	end

	local inputContexts = player:FindFirstChild("InputContexts")
	local characterContext = inputContexts and inputContexts:FindFirstChild("CharacterContext")
	local moveAction = characterContext and characterContext:FindFirstChild("MoveAction")

	if not (moveAction and moveAction:IsA("InputAction")) then
		moveAction = nil
	end

	local zero = Vector2.zero

	if moveAction then
		local state = moveAction:GetState()

		if typeof(state) == "Vector2" then
			zero = state
		end
	end

	local cameraLook = getCameraLook(player) -- equivalent call inferred; original call site unknown
	local rightVector = cameraLook:Cross(createVector(0, 1, 0))

	if rightVector.Magnitude < 0.001 then
		rightVector = humanoidRootPart.CFrame.RightVector
	end

	local unit = rightVector.Unit
	local humanoid = humanoidRootPart.Parent and humanoidRootPart.Parent:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.AutoRotate then
		humanoid.AutoRotate = false
	end

	if not flightLinearVelocity.Enabled then
		flightLinearVelocity.Enabled = true
	end

	if flightLinearVelocity.MaxForce < 1000000 then
		flightLinearVelocity.MaxForce = 1000000
	end

	if not flightCharacterAlignOrientation.Enabled then
		flightCharacterAlignOrientation.Enabled = true
	end

	if flightCharacterAlignOrientation.MaxTorque < 1000000 then
		flightCharacterAlignOrientation.MaxTorque = 1000000
	end

	local flightSpeed = tool:GetAttribute("FlightSpeed") or 85
	local flightAcceleration = tool:GetAttribute("FlightAcceleration") or 14
	local v4 = cameraLook * zero.Y + unit * (zero.X * 0.6666666666666666)
	local v5 = not (v4.Magnitude > 0.05) and createVector(0, 0, 0) or v4 * flightSpeed
	flightLinearVelocity.VectorVelocity = flightLinearVelocity.VectorVelocity:Lerp(
		v5,
		1 - math.exp(-flightAcceleration * p)
	)

	if tool:GetAttribute("FlightFaceMovement") == true and v4.Magnitude > 0.05 then
		cameraLook = v4.Unit
	end

	flightCharacterAlignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), cameraLook, createVector(0, 1, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTrack(animator, p)
	return (animator:GetTrackByAnimationId(p.AnimationId))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrLoadTrack(animator, animation)
	return animator:GetTrackByAnimationId(animation.AnimationId) or animator:LoadAnimation(animation)
end

local function updateFlightAnimation(tool, humanoidRootPart)
	local parent = humanoidRootPart.Parent
	local humanoid = parent and parent:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator or RunService:GetPredictionStatus(humanoidRootPart) == Enum.PredictionStatus.None or RunService:GetPredictionStatus(animator) == Enum.PredictionStatus.None then
		return
	end

	local magnitude, v4

	if tool and tool.Name == "Waverider" and humanoidRootPart:GetAttribute("FlightActive") == true then
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

		if magnitude > 5 then
			v4 = "Moving"
		else
			v4 = "Idle"
		end
	else
		v4 = "None"
		magnitude = 0
	end

	local track = getTrack(animator, idleAnimation) -- equivalent call inferred; original call site unknown
	local track2 = getTrack(animator, movingAnimation) -- equivalent call inferred; original call site unknown

	if v4 == "Moving" then
		if track and track.IsPlaying then
			track:Stop(0.2)
		end

		if not track2 then
			track2 = getOrLoadTrack(animator, movingAnimation)
		end

		assert(track2)
		track2.Looped = true
		track2.Priority = Enum.AnimationPriority.Movement

		if not track2.IsPlaying then
			track2:Play(0.2)
		end

		track2:AdjustSpeed((math.clamp(
			magnitude / math.max(not tool and 85 or tool:GetAttribute("FlightSpeed") or 85, 1),
			0.1,
			4
		)))
	elseif v4 == "Idle" then
		if track2 and track2.IsPlaying then
			track2:Stop(0.2)
		end

		if not track then
			track = getOrLoadTrack(animator, idleAnimation)
		end

		assert(track)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle

		if not track.IsPlaying then
			track:Play(0.2)
		end
	else
		if track and track.IsPlaying then
			track:Stop(0.2)
		end

		if track2 and track2.IsPlaying then
			track2:Stop(0.2)
		end
	end

	if humanoidRootPart:GetAttribute("FlightAnimationState") ~= v4 then
		humanoidRootPart:SetAttribute("FlightAnimationState", v4)
	end
end

local function processPlayer(player, p: number)
	local character = player.Character

	if not character then
		v2[player] = false
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		v2[player] = false
		return
	end

	local tool = character:FindFirstChildWhichIsA("Tool")

	if not (tool and tool:GetAttribute("FlightGear")) then
		tool = nil
	end

	local context = getContext(player) -- equivalent call inferred; original call site unknown
	local toolActivate = context and context:FindFirstChild("ToolActivate")

	if not (toolActivate and toolActivate:IsA("InputAction")) then
		toolActivate = nil
	end

	local v4

	if toolActivate == nil then
		v4 = false
	else
		v4 = toolActivate:GetState() == true
	end

	local v5 = v2[player] or false
	v2[player] = v4

	if v4 and not v5 then
		local tool2 = character:FindFirstChildWhichIsA("Tool")
		dprint(
			"activate rising edge",
			player.Name,
			"flightTool=",
			not tool and "<none>" or tool.Name or "<none>",
			"equippedAny=",
			tool2 and tool2.Name or "<none>"
		)
	end

	if tool and v4 and not v5 then
		tryToggle(player, tool, humanoidRootPart)
	end

	if tool and humanoidRootPart:GetAttribute("FlightActive") == true then
		driveFlight(player, tool, humanoidRootPart, p)
	else
		local flightLinearVelocity = humanoidRootPart:FindFirstChild("FlightLinearVelocity")

		if flightLinearVelocity and (flightLinearVelocity.Enabled or flightLinearVelocity.VectorVelocity.Magnitude > 0) then
			flightLinearVelocity.VectorVelocity = createVector(0, 0, 0)
			flightLinearVelocity.MaxForce = 0
			flightLinearVelocity.Enabled = false
		end

		local flightCharacterAlignOrientation = humanoidRootPart:FindFirstChild("FlightCharacterAlignOrientation")

		if flightCharacterAlignOrientation and flightCharacterAlignOrientation.Enabled then
			flightCharacterAlignOrientation.MaxTorque = 0
			flightCharacterAlignOrientation.Enabled = false
		end
	end

	updateFlightAnimation(tool, humanoidRootPart)
end

function FlightSimulation.register(instance, options)
	assert(isServer, "FlightSimulation.register is server-only")
	local config = options or {}
	v[instance] = {
		tool = instance,
		config = config
	}
	instance:SetAttribute("FlightGear", true)
	instance:SetAttribute("FlightSpeed", not config.getSpeed and 85 or config.getSpeed())
	instance:SetAttribute("FlightAcceleration", not config.getAcceleration and 14 or config.getAcceleration())
	instance:SetAttribute("FlightToggleCooldown", not config.getToggleCooldown and 0.35 or config.getToggleCooldown())
	instance:SetAttribute("FlightFaceMovement", config.faceMovement == true)
	dprint("register", instance.Name, "speed", instance:GetAttribute("FlightSpeed"))

	local function resolveRoot()
		local parent = instance.Parent

		if parent and parent:IsA("Model") then
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				return humanoidRootPart
			end
		end

		return nil
	end

	local parent = instance.Parent
	local humanoidRootPart

	if parent and parent:IsA("Model") then
		humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end
	else
		humanoidRootPart = nil
	end

	instance.Equipped:Connect(function()
		local parent2 = instance.Parent
		local humanoidRootPart2

		if parent2 and parent2:IsA("Model") then
			humanoidRootPart2 = parent2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
				humanoidRootPart2 = nil
			end
		end

		humanoidRootPart = humanoidRootPart2 or humanoidRootPart
	end)
	instance.Unequipped:Connect(function()
		local v5 = humanoidRootPart
		local playerFromCharacter = v5 and v5.Parent and v5:GetAttribute("FlightActive") == true and Players:GetPlayerFromCharacter(v5.Parent)

		if playerFromCharacter then
			FlightSimulation.setFlying(playerFromCharacter, instance, v5, false)
		end
	end)
	instance.Destroying:Once(function()
		v[instance] = nil
	end)
end

function FlightSimulation.autoRegisterByName(p: string, options)
	assert(isServer, "FlightSimulation.autoRegisterByName is server-only")
	local v4 = options or {}

	local function tryRegister(tool)
		if tool:IsA("Tool") and tool.Name == p and v[tool] == nil then
			for _, script in tool:GetDescendants() do
				if not ((script:IsA("Script") or script:IsA("LocalScript")) and (script.Name == "Script" or script.Name == "LocalScript")) then
					continue
				end

				script:Destroy()
			end

			FlightSimulation.register(tool, v4)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watch(instance)
		if not instance then
			return
		end

		for _, child in instance:GetChildren() do
			tryRegister(child)
		end

		instance.ChildAdded:Connect(tryRegister)
	end

	local function onPlayer(player)
		watch(player:FindFirstChildOfClass("Backpack")) -- equivalent call inferred; original call site unknown
		player.ChildAdded:Connect(function(backpack2)
			if backpack2:IsA("Backpack") then
				watch(backpack2) -- equivalent call inferred; original call site unknown
			end
		end)

		if player.Character then
			watch(player.Character) -- equivalent call inferred; original call site unknown
		end

		player.CharacterAdded:Connect(function(character)
			if not character then
				return
			end

			for _, child in character:GetChildren() do
				tryRegister(child)
			end

			character.ChildAdded:Connect(tryRegister)
		end)
	end

	for _, v5 in Players:GetPlayers() do
		onPlayer(v5)
	end

	Players.PlayerAdded:Connect(onPlayer)
	dprint("autoRegisterByName watching for", p)
end

function FlightSimulation.unregister(instance)
	assert(isServer, "FlightSimulation.unregister is server-only")
	v[instance] = nil
	instance:SetAttribute("FlightGear", nil)
	local parent = instance.Parent

	if parent and parent:IsA("Model") then
		local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart:GetAttribute("FlightActive") == true then
			local playerFromCharacter = Players:GetPlayerFromCharacter(parent)
			humanoidRootPart:SetAttribute("FlightActive", false)

			if playerFromCharacter then
				task.defer(applyFlyingSideEffects, playerFromCharacter, instance, humanoidRootPart, false)
			end
		end
	end
end

function FlightSimulation.setFlying(p, p2, instance, flightActive: boolean)
	assert(isServer, "FlightSimulation.setFlying is server-only")

	if instance:GetAttribute("FlightActive") == true == flightActive then
		return
	end

	instance:SetAttribute("FlightActive", flightActive)
	task.defer(applyFlyingSideEffects, p, p2, instance, flightActive)
end

function FlightSimulation.refresh(instance)
	local v4 = v[instance]

	if not v4 then
		return
	end

	local config = v4.config
	instance:SetAttribute("FlightSpeed", not config.getSpeed and 85 or config.getSpeed())
	instance:SetAttribute("FlightAcceleration", not config.getAcceleration and 14 or config.getAcceleration())
	instance:SetAttribute("FlightToggleCooldown", not config.getToggleCooldown and 0.35 or config.getToggleCooldown())
end

function FlightSimulation.isCharacterFlying(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart") and humanoidRootPart:GetAttribute("FlightActive") == true
end

if ServerAuthority.isEnabled() then
	dprint("binding flight simulation loop (SA enabled)")
	RunService:BindToSimulation(function(p: number)
		if isServer then
			for _, v4 in Players:GetPlayers() do
				processPlayer(v4, p)
			end
		else
			local localPlayer = Players.LocalPlayer

			if localPlayer then
				processPlayer(localPlayer, p)
			end
		end
	end, Enum.StepFrequency.Hz60, 3000)
else
	dprint("SA disabled -- flight simulation loop NOT bound (legacy mode)")
end

Players.PlayerRemoving:Connect(function(player)
	v2[player] = nil
	v3[player] = nil
end)
return FlightSimulation