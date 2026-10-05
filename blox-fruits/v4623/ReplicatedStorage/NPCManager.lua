local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.NPCManager.Types)
local Config = require(ReplicatedStorage.NPCManager.NPC.Config)
local NPCInteractionConfig = require(ReplicatedStorage.NPCManager.NPCInteractionConfig)
local State = require(ReplicatedStorage.NPCManager.State)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local AttributeCounter = require(ReplicatedStorage.Util.AttributeCounter)
local Staging = require(ReplicatedStorage.NPCManager.Staging)
local frozen = table.freeze({
	NPC_TICK_CYCLE_DURATION = 0.2,
	NPC_TICK_MIN_SPREAD_WAIT = 0.016666666666666666,
	NPC_LOAD_LOGGING_ENABLED = false,
	NPC_LOAD_STALL_LOG_DELAY = 5,
	PROGRAMMATIC_DIALOGUE_START_WAIT_TIMEOUT = 5,
	GAMEPAD_THUMBSTICK_DEADZONE = 0.2,
	HUMANOID_MOVE_DIRECTION_DEADZONE = 0.05
})
local v = {}
local Classes = require(ReplicatedStorage.NPCManager.NPC.Classes)
local RayMap = require(ReplicatedStorage.Util.RayMap)
local v2 = {
	_wasInitialized = false
}
local v3 = {}
local v4 = {}
local count = 0
local fn
local v5 = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Down] = true,
	[Enum.KeyCode.Left] = true,
	[Enum.KeyCode.Right] = true,
	[Enum.KeyCode.DPadUp] = true,
	[Enum.KeyCode.DPadDown] = true,
	[Enum.KeyCode.DPadLeft] = true,
	[Enum.KeyCode.DPadRight] = true
}

function v2.getNPCDebugPath(instance)
	if not instance then
		return "<nil>"
	end

	local success, result = pcall(function()
		return instance:GetFullName()
	end)

	if success then
		return result
	end

	return instance.Name
end

function v2.logNPCLoad(p: string)
	if frozen.NPC_LOAD_LOGGING_ENABLED then
		print((`[NPCManager][Load] {p}`))
	end
end

function v2.warnNPCLoad(p: string)
	if frozen.NPC_LOAD_LOGGING_ENABLED then
		warn((`[NPCManager][Load] {p}`))
	end
end

function v2.warnNPCLoadStalled(instance, p: string)
	task.delay(frozen.NPC_LOAD_STALL_LOG_DELAY, function()
		if frozen.NPC_LOAD_LOGGING_ENABLED and instance.Parent and not instance:GetAttribute("NPCReady") then
			v2.warnNPCLoad((`Still loading {instance.Name} after {frozen.NPC_LOAD_STALL_LOG_DELAY}s ({p}); path={v2.getNPCDebugPath(instance)} Optimized={tostring(instance:GetAttribute("Optimized"))} WaitingForDialogue={tostring(instance:GetAttribute("WaitingForDialogue"))} NPCReady={tostring(instance:GetAttribute("NPCReady"))}`))
		end
	end)
end

function v2.getFlatDirection(vector2: Vector3, vector3: Vector3)
	local v6 = vector2 * createVector(1, 0, 1)

	if v6.Magnitude > 0.05 then
		return v6.Unit
	end

	local v7 = vector3 * createVector(1, 0, 1)

	if v7.Magnitude > 0.05 then
		return v7.Unit
	end

	return createVector(0, 0, 1)
end

function v2:faceRootPartFlat(vector2: Vector3)
	local v6 = vector2 * createVector(1, 0, 1)

	if v6.Magnitude <= 0.05 then
		return
	end

	local position = self.Position
	self.CFrame = CFrame.lookAt(position, position + v6.Unit, createVector(0, 1, 0))
end

function v2.hideLocalCharacter(folder, localTransparencyModifiers)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function hide(descendant)
		if descendant.LocalTransparencyModifier ~= 1 then
			localTransparencyModifiers[descendant] = descendant.LocalTransparencyModifier
		end

		descendant.LocalTransparencyModifier = 1
	end

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			hide(descendant) -- equivalent call inferred; original call site unknown
		elseif descendant:IsA("Decal") then
			hide(descendant) -- equivalent call inferred; original call site unknown
		end
	end
end

function v2.restoreLocalCharacter(list)
	for k, localTransparencyModifier in list do
		if k.Parent then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	table.clear(list)
end

function v2.npcInteractionLocked()
	return AttributeCounter.active(localPlayer, "NPC_INTERACTION_LOCK")
end

function v2.getYawFromFlatDirection(vector2: Vector3)
	return (math.atan2(vector2.X, vector2.Z))
end

function v2.getFlatDirectionFromYaw(p: number)
	return (Vector3.new(math.sin(p), 0, (math.cos(p))))
end

function v2.getShortestYawDelta(p: number, p2: number)
	local v6 = p2 - p
	return (math.atan2(math.sin(v6), (math.cos(v6))))
end

function v2.getTweenAlpha(p: number)
	return p * p * (3 - p * 2)
end

function v2.tweenRootPartFlatLook(instance, vector2: Vector3, p: number, p2)
	local v6 = vector2 * createVector(1, 0, 1)

	if v6.Magnitude <= 0.05 then
		return
	end

	local unit = v6.Unit
	local flatDirection = v2.getFlatDirection(instance.CFrame.LookVector, unit)
	local yawFromFlatDirection = v2.getYawFromFlatDirection(flatDirection)
	local shortestYawDelta = v2.getShortestYawDelta(yawFromFlatDirection, v2.getYawFromFlatDirection(unit))

	if p <= 0 then
		v2.faceRootPartFlat(instance, unit)
		return
	end

	local lastTime = os.clock()

	while not (p2 and p2.Cancelled) and instance.Parent do
		local v7 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local v8 = yawFromFlatDirection + shortestYawDelta * v2.getTweenAlpha(v7)
		v2.faceRootPartFlat(instance, v2.getFlatDirectionFromYaw(v8))

		if v7 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	if not (p2 and p2.Cancelled) and instance.Parent then
		v2.faceRootPartFlat(instance, unit)
	end
end

function v2.moveHumanoidWithFlatFacing(object, p, vector2: Vector3, vector3: Vector3?)
	local rootPart

	if p then
		rootPart = p.RootPart
	end

	if rootPart and rootPart.Parent then
		v2.faceRootPartFlat(rootPart, vector3 or vector2)
	end

	object:Move(vector2, false)
end

function v2.isCharacterMovementInput(p)
	if v5[p.KeyCode] == true then
		return true
	end

	return p.KeyCode == Enum.KeyCode.Thumbstick1 and p.Position.Magnitude > frozen.GAMEPAD_THUMBSTICK_DEADZONE
end

function v2.watchPlayerMovementForShiftlockDisabler(instance, p, instance2)
	local flag = false
	local connections = {}

	local function moveSettled()
		return p == nil or p.Completed
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroy()
		if flag then
			return
		end

		flag = true
		instance2:Destroy()
		disconnect() -- equivalent call inferred; original call site unknown
	end

	table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and v2.isCharacterMovementInput(input) then
			destroy() -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if not gameProcessed and v2.isCharacterMovementInput(input) then
			destroy() -- equivalent call inferred; original call site unknown
		end
	end))
	table.insert(connections, instance:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if (p == nil or p.Completed) and instance.MoveDirection.Magnitude > frozen.HUMANOID_MOVE_DIRECTION_DEADZONE then
			destroy() -- equivalent call inferred; original call site unknown
		end
	end))
	task.spawn(function()
		while not flag do
			if (p == nil or p.Completed) and instance.MoveDirection.Magnitude > frozen.HUMANOID_MOVE_DIRECTION_DEADZONE then
				if flag then
					break
				end

				flag = true
				instance2:Destroy()
				disconnect() -- equivalent call inferred; original call site unknown
				break
			else
				task.wait(0.05)
			end
		end
	end)
	return {
		destroy = destroy
	}
end

function v2.getDialogueMoveRaycastParams(p, p2)
	local filterDescendantsInstances = { p, p2 }
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")

	if _WorldOrigin then
		table.insert(filterDescendantsInstances, _WorldOrigin)
	end

	local characters = workspace:FindFirstChild("Characters")

	if characters then
		table.insert(filterDescendantsInstances, characters)
	end

	local enemies = workspace:FindFirstChild("Enemies")

	if enemies then
		table.insert(filterDescendantsInstances, enemies)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.IgnoreWater = false
	return raycastParams
end

function v2.findDialogueFloor(vector2: Vector3, p)
	local v6 = vector2 + createVector(0, 1, 0) * NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_RAY_HEIGHT
	local v7 = createVector(0, 1, 0) * -(NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_RAY_HEIGHT + NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_RAY_DEPTH)
	local raycastResult = workspace:Raycast(v6, v7, p)

	if not raycastResult or raycastResult.Material == Enum.Material.Water or raycastResult.Instance.Name == "WaterBase-Plane" or raycastResult.Normal.Y < NPCInteractionConfig.DIALOGUE_PLAYER_MIN_FLOOR_NORMAL_Y then
		return nil
	end

	return raycastResult
end

function v2.isReachableDialogueFloor(p: number, vector2: Vector3)
	local v6 = vector2.Y - p
	return v6 <= NPCInteractionConfig.DIALOGUE_PLAYER_MAX_STEP_UP and -NPCInteractionConfig.DIALOGUE_PLAYER_MAX_DROP <= v6
end

function v2.hasSafeDialogueFloorPath(vector2: Vector3, vector3: Vector3, p)
	local v6 = math.max(
		1,
		(math.ceil(((vector3 - vector2) * createVector(1, 0, 1)).Magnitude / NPCInteractionConfig.DIALOGUE_PLAYER_PATH_FLOOR_SAMPLE_DISTANCE))
	)
	local Y = vector2.Y

	for i = 1, v6 do
		local lerped = vector2:Lerp(vector3, i / v6)
		local dialogueFloor = v2.findDialogueFloor(lerped, p)

		if not (dialogueFloor and v2.isReachableDialogueFloor(Y, dialogueFloor.Position)) then
			return false
		end
	end

	return true
end

function v2.hasClearDialogueMovePath(vector2: Vector3, vector3: Vector3, p)
	for _, v6 in NPCInteractionConfig.DIALOGUE_PLAYER_PATH_RAY_HEIGHTS do
		local v7 = vector2 + createVector(0, 1, 0) * v6
		local v8 = vector3 + createVector(0, 1, 0) * v6 - v7

		if not (v8.Magnitude > 0.05) then
			continue
		end

		local raycastResult = workspace:Raycast(v7, v8, p)

		if raycastResult and (raycastResult.Material == Enum.Material.Water or raycastResult.Normal.Y < NPCInteractionConfig.DIALOGUE_PLAYER_MIN_FLOOR_NORMAL_Y) then
			return false
		end
	end

	return true
end

function v2.getDialogueRangeEdgeFloorPosition(vector2: Vector3, vector3: Vector3)
	local v6 = (vector2 - vector3) * createVector(1, 0, 1)
	local magnitude = v6.Magnitude
	local v7 = NPCInteractionConfig.DIALOGUE_PLAYER_POSITION_RADIUS + NPCInteractionConfig.getLocalCharacterReach()

	if magnitude <= v7 then
		return nil
	end

	return vector3 + v6.Unit * v7
end

function v2.getDialogueStartGap(p)
	local v6

	if p then
		v6 = p.PlayerGap
	end

	return (math.max(v6 or NPCInteractionConfig.DIALOGUE_PLAYER_GAP, NPCInteractionConfig.DIALOGUE_PLAYER_MIN_GAP))
end

function v2.getDialogueRootHeight(p, p2)
	return p.HipHeight + p2.Size.Y / 2 + NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_CLEARANCE
end

function v2.getStagedMarkCFrame(p)
	return Staging.getMarkCFrame(p)
end

function v2.getAuthoredStagingMark(p, p2, cframe: CFrame)
	local v6, v7, v8 = RayMap(
		cframe.Position,
		createVector(0, 1, 0) * -NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_RAY_DEPTH
	)

	if not v6 or v8.Y < NPCInteractionConfig.DIALOGUE_PLAYER_MIN_FLOOR_NORMAL_Y then
		return nil
	end

	local vector2 = Vector3.new(cframe.Position.X, v7.Y + v2.getDialogueRootHeight(p, p2), cframe.Position.Z)
	local flatDirection = v2.getFlatDirection(cframe.LookVector, createVector(0, 0, 1))
	return CFrame.lookAt(vector2, vector2 + flatDirection, createVector(0, 1, 0))
end

function v2.getDialogueStagingMark(p, p2, p3, instance, p4)
	local stagedMarkCFrame = v2.getStagedMarkCFrame(p4)

	if stagedMarkCFrame then
		return v2.getAuthoredStagingMark(p2, p3, stagedMarkCFrame)
	end

	local dialogueMoveRaycastParams = v2.getDialogueMoveRaycastParams(p, instance)
	local pivot = instance:GetPivot()
	local dialogueFloor = v2.findDialogueFloor(pivot.Position, dialogueMoveRaycastParams)

	if not dialogueFloor then
		return nil
	end

	local flatDirection = v2.getFlatDirection(pivot.LookVector, p3.Position - pivot.Position)
	local dialogueRootHeight = v2.getDialogueRootHeight(p2, p3)

	for i = v2.getDialogueStartGap(p4), NPCInteractionConfig.DIALOGUE_PLAYER_MIN_GAP, -NPCInteractionConfig.DIALOGUE_PLAYER_GAP_STEP do
		local dialogueFloor2 = v2.findDialogueFloor(pivot.Position + flatDirection * i, dialogueMoveRaycastParams)

		if not (dialogueFloor2 and v2.isReachableDialogueFloor(dialogueFloor.Position.Y, dialogueFloor2.Position) and v2.hasSafeDialogueFloorPath(
			dialogueFloor.Position,
			dialogueFloor2.Position,
			dialogueMoveRaycastParams
		)) then
			continue
		end

		if not v2.hasClearDialogueMovePath(dialogueFloor.Position, dialogueFloor2.Position, dialogueMoveRaycastParams) then
			continue
		end

		local v6 = dialogueFloor2.Position + createVector(0, 1, 0) * dialogueRootHeight
		local flatDirection2 = v2.getFlatDirection(pivot.Position - v6, -flatDirection)
		return CFrame.lookAt(v6, v6 + flatDirection2, createVector(0, 1, 0))
	end

	return nil
end

function v2.getDialogueMoveTarget(p, p2, instance, p3)
	local dialogueMoveRaycastParams = v2.getDialogueMoveRaycastParams(p, instance)
	local dialogueFloor = v2.findDialogueFloor(p2.Position, dialogueMoveRaycastParams)

	if not dialogueFloor then
		return nil
	end

	local pivot = instance:GetPivot()
	local flatDirection = v2.getFlatDirection(pivot.LookVector, p2.Position - pivot.Position)
	local flatDirection2 = v2.getFlatDirection(pivot.RightVector, createVector(1, 0, 0))

	for i = v2.getDialogueStartGap(p3), NPCInteractionConfig.DIALOGUE_PLAYER_MIN_GAP, -NPCInteractionConfig.DIALOGUE_PLAYER_GAP_STEP do
		for _, v6 in NPCInteractionConfig.DIALOGUE_PLAYER_SIDE_OFFSETS do
			local v7 = pivot.Position + flatDirection * i + flatDirection2 * v6
			local dialogueFloor2 = v2.findDialogueFloor(v7, dialogueMoveRaycastParams)

			if not dialogueFloor2 then
				continue
			end

			local dialogueRangeEdgeFloorPosition = v2.getDialogueRangeEdgeFloorPosition(
				p2.Position,
				dialogueFloor2.Position
			)

			if not dialogueRangeEdgeFloorPosition then
				return p2.Position
			end

			local dialogueFloor3 = v2.findDialogueFloor(dialogueRangeEdgeFloorPosition, dialogueMoveRaycastParams)

			if dialogueFloor3 and v2.isReachableDialogueFloor(dialogueFloor.Position.Y, dialogueFloor3.Position) and v2.hasSafeDialogueFloorPath(
				dialogueFloor.Position,
				dialogueFloor3.Position,
				dialogueMoveRaycastParams
			) and v2.hasClearDialogueMovePath(
				dialogueFloor.Position,
				dialogueFloor3.Position,
				dialogueMoveRaycastParams
			) then
				return dialogueFloor3.Position + createVector(0, 1, 0) * NPCInteractionConfig.DIALOGUE_PLAYER_FLOOR_CLEARANCE
			end
		end
	end

	return nil
end

function v2.dialogueMoveCancelled(p)
	return p ~= nil and p.Cancelled == true
end

function v2:clearDialogueMoveRenderStep()
	local renderStepName = self.RenderStepName

	if not renderStepName then
		return
	end

	RunService:UnbindFromRenderStep(renderStepName)
	self.RenderStepName = nil
end

function v2.createDialogueMoveState(humanoid, rootPart)
	count += 1
	local v6 = {
		Cancelled = false,
		Completed = false,
		Humanoid = humanoid,
		RootPart = rootPart,
		MoveDirection = createVector(0, 0, 0),
		FaceDirection = nil,
		RenderStepName = `NPCManagerDialogueMove_{count}`,
		Thread = nil
	}
	RunService:BindToRenderStep(v6.RenderStepName, Enum.RenderPriority.Input.Value + 1, function()
		if v6.Cancelled or v6.Completed or humanoid.Health <= 0 then
			return
		end

		local moveDirection = v6.MoveDirection

		if moveDirection.Magnitude > 0 then
			v2.moveHumanoidWithFlatFacing(humanoid, v6, moveDirection, v6.FaceDirection)
		end
	end)
	return v6
end

function v2:finishDialogueMoveState()
	self.MoveDirection = createVector(0, 0, 0)
	self.FaceDirection = nil
	v2.clearDialogueMoveRenderStep(self)
	local humanoid = self.Humanoid

	if humanoid and humanoid.Parent then
		humanoid:Move(createVector(0, 0, 0), false)
	end

	self.Completed = true
end

function v2.moveHumanoidToward(p, p2, p3, vector2: Vector3, p4: number, p5: number, p6, callback)
	local v6 = os.clock() + p5

	while not v2.dialogueMoveCancelled(p6) and p.Parent and p2.Health > 0 and os.clock() < v6 do
		local v7 = (vector2 - p3.Position) * createVector(1, 0, 1)

		if v7.Magnitude <= p4 then
			if p6 then
				p6.MoveDirection = createVector(0, 0, 0)
				p6.FaceDirection = nil
			end

			return true
		else
			local unit = v7.Unit
			local faceDirection

			if callback then
				faceDirection = callback()
			else
				faceDirection = unit
			end

			if p6 then
				p6.MoveDirection = unit
				p6.FaceDirection = faceDirection
			end

			v2.moveHumanoidWithFlatFacing(p2, p6, unit, faceDirection)
			RunService.RenderStepped:Wait()
		end
	end

	if p6 then
		p6.MoveDirection = createVector(0, 0, 0)
		p6.FaceDirection = nil
	end

	return false
end

function v2.getDialogueFaceDirection(p, instance)
	local pivot = instance:GetPivot()
	return v2.getFlatDirection(pivot.Position - p.Position, -pivot.LookVector)
end

function v2.isRootPartFacingDirection(p, vector2: Vector3)
	local v6 = p.CFrame.LookVector * createVector(1, 0, 1)
	return not (v6.Magnitude <= 0.05) and v6.Unit:Dot(vector2) >= NPCInteractionConfig.DIALOGUE_PLAYER_REFACE_DOT
end

function v2.refaceHumanoidTowardNPC(p, p2, p3, p4, p5)
	local v6 = os.clock() + NPCInteractionConfig.DIALOGUE_PLAYER_REFACE_TIMEOUT

	while not v2.dialogueMoveCancelled(p5) and p.Parent and p2.Health > 0 and os.clock() < v6 do
		local dialogueFaceDirection = v2.getDialogueFaceDirection(p3, p4)

		if v2.isRootPartFacingDirection(p3, dialogueFaceDirection) then
			break
		end

		local moveDirection = dialogueFaceDirection * NPCInteractionConfig.DIALOGUE_PLAYER_REFACE_MOVE_SCALE
		p5.MoveDirection = moveDirection
		p5.FaceDirection = dialogueFaceDirection
		v2.moveHumanoidWithFlatFacing(p2, p5, moveDirection, dialogueFaceDirection)
		RunService.RenderStepped:Wait()
	end

	p5.MoveDirection = createVector(0, 0, 0)
	p5.FaceDirection = nil
end

function v2.moveLocalCharacterInFrontOfNPC(instance, object, p, p2, p3)
	if v2.dialogueMoveCancelled(p2) then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	if p2 then
		p2.RootPart = humanoidRootPart
	end

	local cFrame = p3 and p3.TeleportPlayer and v2.getDialogueStagingMark(instance, object, humanoidRootPart, p, p3)

	if cFrame then
		humanoidRootPart.CFrame = cFrame
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		object:Move(createVector(0, 0, 0), false)
	else
		local dialogueMoveTarget = v2.getDialogueMoveTarget(instance, humanoidRootPart, p, p3)

		if not dialogueMoveTarget then
			return
		end

		if ((humanoidRootPart.Position - dialogueMoveTarget) * createVector(1, 0, 1)).Magnitude <= NPCInteractionConfig.DIALOGUE_PLAYER_REACHED_DISTANCE then
			v2.tweenRootPartFlatLook(
				humanoidRootPart,
				v2.getDialogueFaceDirection(humanoidRootPart, p),
				NPCInteractionConfig.DIALOGUE_PLAYER_LOOK_TWEEN_TIME,
				p2
			)
			return
		end

		local v7

		if not p2 then
			p2 = v2.createDialogueMoveState(object, humanoidRootPart)
			v7 = p2
		end

		if v2.dialogueMoveCancelled(p2) then
			if v7 then
				v2.finishDialogueMoveState(v7)
			end
		else
			v2.moveHumanoidToward(
				instance,
				object,
				humanoidRootPart,
				dialogueMoveTarget,
				NPCInteractionConfig.DIALOGUE_PLAYER_REACHED_DISTANCE,
				NPCInteractionConfig.DIALOGUE_PLAYER_MOVE_TIMEOUT,
				p2,
				function()
					return v2.getDialogueFaceDirection(humanoidRootPart, p)
				end
			)

			if p2 and not v2.dialogueMoveCancelled(p2) then
				v2.refaceHumanoidTowardNPC(instance, object, humanoidRootPart, p, p2)
			end

			if v7 then
				v2.finishDialogueMoveState(v7)
			elseif not v2.dialogueMoveCancelled(p2) then
				object:Move(createVector(0, 0, 0), false)
			end
		end
	end
end

function v2.startDialogueMoveThread(instance, p, p2, p3)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local dialogueMoveState = v2.createDialogueMoveState(p, humanoidRootPart)
	dialogueMoveState.Thread = task.spawn(function()
		local success, result = pcall(function()
			v2.moveLocalCharacterInFrontOfNPC(instance, p, p2, dialogueMoveState, p3)
			return nil
		end)

		if not success then
			warn((`[NPCManager] Dialogue movement failed: {tostring(result)}`))
		end

		v2.finishDialogueMoveState(dialogueMoveState)
	end)
	return dialogueMoveState
end

function v2:cancelDialogueMoveThread()
	if not self or self.Completed then
		return
	end

	self.Cancelled = true
	v2.finishDialogueMoveState(self)

	if self.Thread then
		pcall(task.cancel, self.Thread)
	end
end

function v.onInit()
	if v2._wasInitialized then
		return
	end

	v2._wasInitialized = true
	local NPCList = require(ReplicatedStorage.NPCManager.NPCList)
	local Global = require(ReplicatedStorage.Global)
	local v6 = {}
	Config.NPCInfoRegistered:Connect(function(p)
		for i = #v6, 1, -1 do
			local v7 = v6[i]

			if v7.Name ~= p._name then
				continue
			end

			local v8 = i
			local v9 = v7
			local success, result = pcall(function()
				table.remove(v6, v8)
				v9:SetAttribute("WaitingForDialogue", false)
				v9.Parent = workspace.NPCs
			end)

			if success then
				v2.logNPCLoad((`Restored waiting NPC {v7.Name} after NPCInfo registered; path={v2.getNPCDebugPath(v7)}`))
			else
				v2.warnNPCLoad((`Failed to restore waiting NPC {v7.Name}: {tostring(result)}`))
			end
		end
	end)

	local function onNPCAdded(model)
		task.defer(function()
			if not model:IsA("Model") then
				v2.logNPCLoad((`Ignoring non-Model child under workspace.NPCs: {v2.getNPCDebugPath(model)}`))
				return
			end

			local v7 = model

			if v3[v7] then
				return
			end

			v2.logNPCLoad((`Detected NPC model {v7.Name}; path={v2.getNPCDebugPath(v7)} Optimized={tostring(v7:GetAttribute("Optimized"))}`))

			if not v7:GetAttribute("Optimized") then
				v2.warnNPCLoad((`Waiting for Optimized on {v7.Name}; path={v2.getNPCDebugPath(v7)}`))
				v2.warnNPCLoadStalled(v7, "waiting for Optimized before NPC registration")
				v7:GetAttributeChangedSignal("Optimized"):Wait()
				v2.logNPCLoad((`Optimized received for {v7.Name}; path={v2.getNPCDebugPath(v7)}`))
			end

			local v8 = NPCList.List[v7.Name]

			if v8 then
				local v9 = Classes.new(v8, v7)
				v2.logNPCLoad((`Registered NPC {v8._name} from model {v7.Name}; starting initializer`))
				v3[v7] = v9
				v2.warnNPCLoadStalled(v7, "running initializeNPC")
				task.spawn(function()
					local success, result = pcall(function()
						v9:initializeNPC()
					end)

					if success then
						v2.logNPCLoad((`Initializer finished for {v7.Name}; parent={v2.getNPCDebugPath(v7.Parent)} NPCReady={tostring(v7:GetAttribute("NPCReady"))}`))
					else
						v2.warnNPCLoad((`Initializer failed for {v7.Name}: {tostring(result)}`))
					end
				end)
			else
				v2.warnNPCLoad((`Missing NPCInfo for {v7.Name}; moving model to ReplicatedStorage until NPCInfoRegistered fires`))
				v7.Parent = ReplicatedStorage
				v7:SetAttribute("WaitingForDialogue", true)
				table.insert(v6, v7)
			end
		end)
	end

	workspace.NPCs.ChildAdded:Connect(onNPCAdded)

	for _, child in pairs(workspace.NPCs:GetChildren()) do
		local model = child
		task.defer(function()
			if not model:IsA("Model") then
				v2.logNPCLoad((`Ignoring non-Model child under workspace.NPCs: {v2.getNPCDebugPath(model)}`))
				return
			end

			local v7 = model

			if v3[v7] then
				return
			end

			v2.logNPCLoad((`Detected NPC model {v7.Name}; path={v2.getNPCDebugPath(v7)} Optimized={tostring(v7:GetAttribute("Optimized"))}`))

			if not v7:GetAttribute("Optimized") then
				v2.warnNPCLoad((`Waiting for Optimized on {v7.Name}; path={v2.getNPCDebugPath(v7)}`))
				v2.warnNPCLoadStalled(v7, "waiting for Optimized before NPC registration")
				v7:GetAttributeChangedSignal("Optimized"):Wait()
				v2.logNPCLoad((`Optimized received for {v7.Name}; path={v2.getNPCDebugPath(v7)}`))
			end

			local v8 = NPCList.List[v7.Name]

			if v8 then
				local v9 = Classes.new(v8, v7)
				v2.logNPCLoad((`Registered NPC {v8._name} from model {v7.Name}; starting initializer`))
				v3[v7] = v9
				v2.warnNPCLoadStalled(v7, "running initializeNPC")
				task.spawn(function()
					local success, result = pcall(function()
						v9:initializeNPC()
					end)

					if success then
						v2.logNPCLoad((`Initializer finished for {v7.Name}; parent={v2.getNPCDebugPath(v7.Parent)} NPCReady={tostring(v7:GetAttribute("NPCReady"))}`))
					else
						v2.warnNPCLoad((`Initializer failed for {v7.Name}: {tostring(result)}`))
					end
				end)
			else
				v2.warnNPCLoad((`Missing NPCInfo for {v7.Name}; moving model to ReplicatedStorage until NPCInfoRegistered fires`))
				v7.Parent = ReplicatedStorage
				v7:SetAttribute("WaitingForDialogue", true)
				table.insert(v6, v7)
			end
		end)
	end

	task.defer(function()
		local GuideModule = require(ReplicatedStorage.GuideModule)
		GuideModule:SetDataReady(true)
	end)
	local v7 = 0
	local v8 = false
	local count2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dialogueStartLocked()
		return v8 or os.clock() < v7
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setClosestNPC(closestNPC)
		local closestNPC2 = State.ClosestNPC

		if closestNPC ~= closestNPC2 then
			if closestNPC2 then
				closestNPC2:onInteractableStateChanged(false)
			end

			if closestNPC then
				closestNPC:onInteractableStateChanged(true)
			end
		end

		State.ClosestNPC = closestNPC
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearClosestNPC()
		local closestNPC = State.ClosestNPC

		if closestNPC ~= nil and closestNPC then
			closestNPC:onInteractableStateChanged(false)
		end

		State.ClosestNPC = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function claimDialogueStartLock()
		v8 = true
		v7 = os.clock() + NPCInteractionConfig.DIALOGUE_START_LOCKOUT
		clearClosestNPC() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseDialogueStartLock()
		v7 = os.clock() + NPCInteractionConfig.DIALOGUE_START_LOCKOUT
		v8 = false
		clearClosestNPC() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function warnNPCTickError(object, result)
		local v9

		if object then
			v9 = object:getModel()
		end

		local v10 = not v9 and "unknown" or v9.Name
		warn((`[NPCManager] NPC tick failed for {v10}: {tostring(result)}`))
	end

	local function updateInteractionClosest()
		local npcInteractionLocked = v2.npcInteractionLocked()

		if npcInteractionLocked then
			clearClosestNPC() -- equivalent call inferred; original call site unknown
		end

		local character = localPlayer.Character
		local pivot = character and character:GetPivot() or workspace.CurrentCamera.CFrame
		table.clear(v4)
		local count3 = 0

		for _, v9 in v3 do
			count3 += 1
			v4[count3] = v9
		end

		local now = os.clock()
		local v9 = 1e999
		local v10 = nil

		for i = 1, count3 do
			local v11 = v4[i]
			local success, result = pcall(function()
				return v11:onTick(pivot)
			end)

			if success then
				if result and v11:getIfLoadedInWorld() and result <= v9 and v11:getIfInteractable() then
					v10 = v11
					v9 = result
				end
			else
				warnNPCTickError(v11, result) -- equivalent call inferred; original call site unknown
			end

			if v2.npcInteractionLocked() then
				npcInteractionLocked = true
				clearClosestNPC() -- equivalent call inferred; original call site unknown
			end

			if not (i < count3) then
				continue
			end

			local v13 = now + frozen.NPC_TICK_CYCLE_DURATION * i / count3 - os.clock()

			if frozen.NPC_TICK_MIN_SPREAD_WAIT < v13 then
				task.wait(v13)
			end
		end

		if npcInteractionLocked or dialogueStartLocked() then
			clearClosestNPC() -- equivalent call inferred; original call site unknown
		else
			setClosestNPC(v10) -- equivalent call inferred; original call site unknown
		end
	end

	AttributeCounter.connect(localPlayer, "NPC_INTERACTION_LOCK", function()
		if v2.npcInteractionLocked() then
			clearClosestNPC() -- equivalent call inferred; original call site unknown
		end
	end, true)
	task.spawn(function()
		while true do
			local lastTime = os.clock()
			local success, result = pcall(function()
				updateInteractionClosest()
				return nil
			end)

			if not success then
				warn((`[NPCManager] NPC update loop failed: {tostring(result)}`))
			end

			local v9 = os.clock() - lastTime

			if v9 < frozen.NPC_TICK_CYCLE_DURATION then
				task.wait(frozen.NPC_TICK_CYCLE_DURATION - v9)
			else
				task.wait()
			end
		end
	end)
	Global.NPCReady = true
	local DialogueController = require(ReplicatedStorage:WaitForChild("DialogueController"))

	local function setup()
		State.DialogueModel = nil

		local function validityCheck(flag: boolean, p, p2, p3)
			if flag or not p3 or not p or not p2 or p2.Health <= 0 or DialogueController.Active or v2.npcInteractionLocked() or dialogueStartLocked() then
				return false
			end

			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dashingCheck(instance, p)
			return p and p.Value and not instance:GetAttribute("NoDashing")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setDialogueModel(model)
			Global.dialogueModel = model
			State.DialogueModel = model
		end

		local function watchDialogueCamera(instance, p, p2, p3: number)
			local v9 = os.clock() + 5
			local v10 = nil

			while count2 == p3 and os.clock() < v9 do
				local activeDialogue = DialogueController.getActiveDialogue()

				if activeDialogue then
					local NPC = activeDialogue:getNPC()

					if not NPC or NPC:getModel() ~= instance then
						return
					end

					v10 = activeDialogue
					break
				else
					task.wait()
				end
			end

			if not v10 then
				return
			end

			local character = localPlayer.Character
			local currentCamera = workspace.CurrentCamera

			if not (character and currentCamera) then
				return
			end

			local head = instance:FindFirstChild("Head")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function npcLookPoint()
				if head and head:IsA("BasePart") then
					return head.Position
				end

				return instance:GetPivot().Position
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function npcToPlayer()
				local v11 = (character:GetPivot().Position - instance:GetPivot().Position) * createVector(1, 0, 1)
				local magnitude = v11.Magnitude

				if magnitude < 0.05 then
					return instance:GetPivot().LookVector * createVector(1, 0, 1), 0
				end

				return v11 / magnitude, magnitude
			end

			local v11 = (currentCamera.CFrame.Position - instance:GetPivot().Position) * createVector(1, 0, 1)
			local unit

			if v11.Magnitude > 0.05 then
				unit = v11.Unit
			else
				local v12 = (character:GetPivot().Position - instance:GetPivot().Position) * createVector(1, 0, 1)
				local magnitude = v12.Magnitude

				if magnitude < 0.05 then
					unit = instance:GetPivot().LookVector * createVector(1, 0, 1)
				else
					unit = v12 / magnitude
				end
			end

			local total = 0
			local v12 = 0

			local function dialogueGoal(p4: number)
				local v13 = npcLookPoint() -- equivalent call inferred; original call site unknown
				local v14 = character:GetPivot().Position + createVector(0, 1.5, 0)
				local vector2, v15 = npcToPlayer() -- equivalent call inferred; original call site unknown
				local v16 = math.deg((math.atan2(vector2:Cross(unit).Y, (math.clamp(vector2:Dot(unit), -1, 1)))))
				local v17 = 0

				if math.abs(v16) < NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE then
					if v12 == 0 then
						v12 = v16 >= 0 and 1 or -1
					end

					v17 = v12 * NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE - v16
				elseif math.abs(v16) > NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE + NPCInteractionConfig.DIALOGUE_CAMERA_SIDE_RESET then
					v12 = 0
				end

				local v18 = NPCInteractionConfig.DIALOGUE_CAMERA_SWING_SPEED * p4
				total += math.clamp(v17 - total, -v18, v18)
				local vector3 = CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(total))) * unit
				local v19 = NPCInteractionConfig.DIALOGUE_CAMERA_BASE_DISTANCE + v15 * NPCInteractionConfig.DIALOGUE_CAMERA_PULLBACK
				local v20 = v15 * vector3:Dot(vector2)
				local v21 = math.sqrt((math.max(v15 ^ 2 - v20 ^ 2, 0)))

				if v21 < NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP then
					v19 = math.max(v19, v20 + math.sqrt(NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP ^ 2 - v21 ^ 2))
				end

				local v22 = v13 + vector3 * v19 + Vector3.new(0, NPCInteractionConfig.DIALOGUE_CAMERA_HEIGHT, 0)
				return CFrame.lookAt(v22, v13:Lerp(v14, 0.5))
			end

			local function firstPersonGoal()
				local v13 = (character:GetPivot().Position - instance:GetPivot().Position) * createVector(1, 0, 1)
				local magnitude = v13.Magnitude
				local v14

				if magnitude < 0.05 then
					v14 = instance:GetPivot().LookVector * createVector(1, 0, 1)
				else
					v14 = v13 / magnitude
				end

				local v15 = -v14
				local v16 = character:GetPivot().Position + createVector(0, 1, 0) * NPCInteractionConfig.DIALOGUE_STAGED_CAMERA_HEIGHT
				local v17 = v16 + v15 * NPCInteractionConfig.DIALOGUE_STAGED_CAMERA_FORWARD
				local v18 = npcLookPoint() -- equivalent call inferred; original call site unknown
				return CFrame.lookAt(v17, v18)
			end

			local v13

			if p2 == nil then
				v13 = false
			else
				v13 = p2.FirstPersonCamera == true
			end

			local v14 = CameraController.new()
			local v15 = {}
			local DIALOGUE_WALKAWAY_DISTANCE

			if p and p.WalkawayDistance then
				DIALOGUE_WALKAWAY_DISTANCE = math.max(
					p.WalkawayDistance,
					NPCInteractionConfig.DIALOGUE_WALKAWAY_DISTANCE
				)
			else
				DIALOGUE_WALKAWAY_DISTANCE = NPCInteractionConfig.DIALOGUE_WALKAWAY_DISTANCE
			end

			if p2 then
				local stagedMarkCFrame = v2.getStagedMarkCFrame(p2)
				local magnitude

				if stagedMarkCFrame then
					magnitude = ((stagedMarkCFrame.Position - instance:GetPivot().Position) * createVector(1, 0, 1)).Magnitude
				else
					magnitude = p2.PlayerGap
				end

				if magnitude then
					DIALOGUE_WALKAWAY_DISTANCE = math.max(
						DIALOGUE_WALKAWAY_DISTANCE,
						magnitude + NPCInteractionConfig.DIALOGUE_STAGED_WALKAWAY_MARGIN
					)
				end
			end

			local function shouldReleaseImmediately()
				if character.Parent and instance.Parent then
					return DIALOGUE_WALKAWAY_DISTANCE + NPCInteractionConfig.getLocalCharacterReach() < (character:GetPivot().Position - instance:GetPivot().Position).Magnitude
				end

				return true
			end

			local success, result = pcall(function()
				local v16 = 0.016666666666666666

				while count2 == p3 and DialogueController.getActiveDialogue() == v10 and character.Parent and instance.Parent and not (DIALOGUE_WALKAWAY_DISTANCE + NPCInteractionConfig.getLocalCharacterReach() < (character:GetPivot().Position - instance:GetPivot().Position).Magnitude) do
					if v13 then
						v2.hideLocalCharacter(character, v15)
					end

					local cframe

					if v13 then
						local v17 = (character:GetPivot().Position - instance:GetPivot().Position) * createVector(
							1,
							0,
							1
						)
						local magnitude = v17.Magnitude
						local v18

						if magnitude < 0.05 then
							v18 = instance:GetPivot().LookVector * createVector(1, 0, 1)
						else
							v18 = v17 / magnitude
						end

						local v19 = -v18
						local v20 = character:GetPivot().Position + createVector(0, 1, 0) * NPCInteractionConfig.DIALOGUE_STAGED_CAMERA_HEIGHT
						local v21 = v20 + v19 * NPCInteractionConfig.DIALOGUE_STAGED_CAMERA_FORWARD
						local v22 = npcLookPoint() -- equivalent call inferred; original call site unknown
						cframe = CFrame.lookAt(v21, v22)
					else
						cframe = dialogueGoal(v16)
					end

					v14.Animations:AnimateTo(cframe, 1, NPCInteractionConfig.DIALOGUE_CAMERA_FREQUENCY)
					v16 = task.wait()
				end
			end)
			v2.restoreLocalCharacter(v15)

			if not success then
				warn((`[NPCManager] Dialogue camera failed: {tostring(result)}`))
			end

			if DialogueController.getActiveDialogue() == v10 and not DialogueController.Terminating then
				DialogueController.close()
			end

			v14:FadeOut(0.25)
		end

		local function startDialogueInteraction(character, p, busy, object, _interactionController, p2)
			if dashingCheck(character, busy) then
				return false
			end

			local model = object:getModel()
			local _entry = _interactionController._entry
			local dialogueStaging = object._npcInfo.DialogueStaging
			local ifStagesOwnDialogue = object:getIfStagesOwnDialogue()
			_entry.GUI.BusyLock:Lock("_General")
			Config.Highlight.Adornee = nil
			claimDialogueStartLock() -- equivalent call inferred; original call site unknown
			setDialogueModel(model) -- equivalent call inferred; original call site unknown
			AttributeCounter.add(localPlayer, "FORCED_WALKING_STATE")
			local destroyable = AttributeCounter.destroyable(localPlayer, "SHIFTLOCK_DISABLED")
			local v9

			if not ifStagesOwnDialogue then
				v9 = v2.startDialogueMoveThread(character, p, model, dialogueStaging)
			end

			local v10 = v2.watchPlayerMovementForShiftlockDisabler(p, v9, destroyable)
			task.wait()
			count2 += 1
			local v11 = count2

			if not ifStagesOwnDialogue then
				task.spawn(watchDialogueCamera, model, p2, dialogueStaging, v11)
			end

			local success, result = pcall(function()
				DialogueController.start(object:getDialogue(), object)
			end)

			if count2 == v11 then
				count2 += 1
			end

			v2.cancelDialogueMoveThread(v9)
			releaseDialogueStartLock() -- equivalent call inferred; original call site unknown
			setDialogueModel(nil) -- equivalent call inferred; original call site unknown

			if not success then
				task.spawn(error, result)
			end

			AttributeCounter.remove(localPlayer, "FORCED_WALKING_STATE")
			v10.destroy()
			return success and result ~= nil
		end

		local function tryStartDialogue(flag: boolean, object, p)
			local character = localPlayer.Character

			if not character then
				return false
			end

			local busy = character:FindFirstChild("Busy")

			if not (busy and busy:IsA("BoolValue")) then
				busy = nil
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local v9 = object or State.ClosestNPC

			if not v9 or object and not (object:getIfInitialized() and object:getIfLoadedInWorld() and object:getIfInteractable()) then
				return false
			end

			local _interactionController = v9._interactionController
			local v10

			if flag or not _interactionController or not character or not humanoid or humanoid.Health <= 0 or DialogueController.Active or v2.npcInteractionLocked() then
				v10 = false
			else
				v10 = not dialogueStartLocked()
			end

			if v10 then
				return (startDialogueInteraction(character, assert(humanoid), busy, v9, _interactionController, p))
			end

			return false
		end

		fn = function(p, p2)
			return (tryStartDialogue(false, p, p2))
		end

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Touch or not UserInputService.GamepadEnabled and (input.UserInputState ~= Enum.UserInputState.Begin or input.UserInputType ~= Enum.UserInputType.MouseButton1) then
				return
			end

			tryStartDialogue(gameProcessed, nil, nil)
		end)
		UserInputService.TouchTap:Connect(function(_, p)
			tryStartDialogue(p, nil, nil)
		end)
	end

	task.spawn(setup)
	task.spawn(function()
		local DialoguesList = require(ReplicatedStorage:WaitForChild("DialoguesList"))
		ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Prompt").OnClientEvent:Connect(function(p)
			DialogueController.start(DialoguesList[p])
		end)
	end)

	function Global.Dialogue(p)
		local DialoguesList = require(ReplicatedStorage:WaitForChild("DialoguesList"))
		DialogueController.start(DialoguesList[p])
	end

	Global.DialogueController = DialogueController

	function Global.GetQueue(p)
		local v9 = p and v3[p]

		if v9 then
			return v9._interactionController._entry
		end

		return v3
	end
end

function v.getNPCsByName(p: string)
	local result = {}

	for _, v6 in v3 do
		if v6:getModel().Name == p then
			table.insert(result, v6)
		end
	end

	return result
end

function v.startDialogue(p, p2)
	local v6 = os.clock() + frozen.PROGRAMMATIC_DIALOGUE_START_WAIT_TIMEOUT
	local v7

	while true do
		v7 = fn

		if v7 then
			break
		end

		task.wait()

		if v6 <= os.clock() then
			return false
		end
	end

	return v7(p, p2)
end

function v.getClosestNPC(vector2: Vector3, p: string?, value: number?)
	local v6 = value or 1e999
	local v7 = nil

	for _, v8 in v3 do
		local model = v8:getModel()

		if not (not p or model.Name == p) then
			continue
		end

		local magnitude = (vector2 - model:GetPivot().Position).Magnitude

		if not (magnitude < v6) then
			continue
		end

		v7 = v8
		v6 = magnitude
	end

	return v7
end

task.spawn(v.onInit)
return table.freeze(v)