local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Anims = require(ReplicatedStorage.Util.Anims)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local DialogueController = require(ReplicatedStorage.DialogueController)
local DialogueRegistry = require(ReplicatedStorage.Controllers.BonusMomentsController.DialogueRegistry)
local Maid = require(ReplicatedStorage.Util.Maid)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local frozen = table.freeze({
	ISLAND = "Jungle",
	FOOTSTEPS_TAG = "MonkeyThiefFootsteps",
	ADVENTURER_NAME = "Adventurer",
	ADVENTURER_SUBTITLE = "Quest Giver",
	RETURN_TEXT = "You found my hat! That thieving monkey took it right off my head!",
	RETURN_LABEL = "Return the hat",
	RETURN_THANKS_TEXT = "Thank you! I thought I'd never see it again.",
	RETURN_THANKS_LABEL = "You're welcome.",
	DIALOGUE_PROVIDER_ID = "ThievingMonkeyHatReturn",
	DIALOGUE_PRIORITY = 100,
	ADVENTURER_HAT_NAME = "Hat",
	HAT_TOOL_NAME = "Adventurer's Hat",
	HAT_MARKER = "ThievingMonkeyHat",
	NOTICE_DISTANCE = 24,
	NOTICE_TEXT = "These footsteps look suspicious... I wonder where they lead to?",
	NOTICE_DURATION = 2,
	SURRENDER_TITLE = "Thieving Monkey",
	SURRENDER_TEXT = "Ooh ooh ah ah!!\n(Translation: I give up!!)",
	SURRENDER_DURATION = 2,
	SURRENDER_FOCUS_HEIGHT = 1.5,
	FALL_FOCUS_HEIGHT = 1.5,
	FALL_CAMERA_FIELD_OF_VIEW = 70,
	FALL_CAMERA_TIMEOUT = 3.5,
	FALL_CAMERA_GROUND_CLEARANCE = 6,
	FALL_CAMERA_GROUND_CAST_UP = 12,
	FALL_CAMERA_GROUND_CAST_DOWN = 96,
	FALL_CAMERA_MIN_HORIZONTAL_DISTANCE = 35,
	SCAN_INTERVAL = 0.2,
	PRESENTATION_REFRESH_INTERVAL = 0.5,
	CAMERA_BLEND_TIME = 0.2,
	CAMERA_RETURN_TIME = 0.25,
	CAMERA_DAMPING = 1,
	CAMERA_FREQUENCY = 3,
	HAT_BOUNCE_DURATION = 0.65,
	HAT_BOUNCE_HEIGHT = 5,
	HAT_BOUNCE_ROTATIONS = 2,
	HAT_HIGHLIGHT_NAME = "ThievingMonkeyHatHighlight",
	HAT_HIGHLIGHT_COLOR = Color3.fromRGB(255, 211, 74),
	HAT_HIGHLIGHT_FILL_TRANSPARENCY = 0.7,
	HAT_PROMPT_RETRY_DELAY = 1
})
local localPlayer = Players.LocalPlayer
local v = nil
local flag = false
local v2 = {
	getJungle = function()
		local map = workspace:FindFirstChild("Map")
		local model

		if map then
			model = map:FindFirstChild(frozen.ISLAND)
		end

		if model and model:IsA("Model") then
			return model
		end

		return nil
	end
}

function v2.getState(maid)
	local _thievingMonkeyState = maid.MiscData._thievingMonkeyState

	if _thievingMonkeyState then
		return _thievingMonkeyState
	end

	local thievingMonkeyState = {
		maid = Maid.new(),
		completed = maid.Completed,
		noticed = false,
		ownsHat = false,
		noticeDialogue = nil,
		surrenderDialogue = nil,
		fallCamera = nil,
		fallCameraReturnCFrame = nil,
		footsteps = nil,
		footprints = nil,
		retreatMaid = nil,
		hatPickupMaid = nil,
		hatTransparency = {}
	}
	maid.MiscData._thievingMonkeyState = thievingMonkeyState
	maid:GiveTask(thievingMonkeyState.maid)
	thievingMonkeyState.maid:GiveTask(function()
		v2.closeTrackedDialogue(thievingMonkeyState, "noticeDialogue")
		v2.closeTrackedDialogue(thievingMonkeyState, "surrenderDialogue")
		v2.closeFallCamera(thievingMonkeyState)
		v2.closeMonkeyRetreat(thievingMonkeyState)
		v2.closeHatPickup(thievingMonkeyState)
		v2.restorePresentation(thievingMonkeyState)

		if v == maid then
			v = nil
		end
	end)
	return thievingMonkeyState
end

function v2.getContainers()
	local v3 = {}
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")

	if backpack then
		table.insert(v3, backpack)
	end

	if localPlayer.Character then
		table.insert(v3, localPlayer.Character)
	end

	return v3
end

function v2.hasHat()
	for _, v3 in v2.getContainers() do
		for _, tool in v3:GetChildren() do
			if tool:IsA("Tool") and tool.Name == frozen.HAT_TOOL_NAME and tool:GetAttribute(frozen.HAT_MARKER) == true and tool:HasTag(frozen.HAT_MARKER) then
				return true
			end
		end
	end

	return false
end

function v2.canReturnHat(p)
	local _thievingMonkeyState = p.MiscData._thievingMonkeyState
	return _thievingMonkeyState ~= nil and _thievingMonkeyState.ownsHat and v2.hasHat()
end

function v2:closeMonkeyRetreat(p2)
	if p2 and self.retreatMaid ~= p2 then
		return
	end

	local retreatMaid = self.retreatMaid
	self.retreatMaid = nil

	if retreatMaid then
		retreatMaid:DoCleaning()
	end
end

function v2:closeHatPickup(p2)
	if p2 and self.hatPickupMaid ~= p2 then
		return
	end

	local hatPickupMaid = self.hatPickupMaid
	self.hatPickupMaid = nil

	if hatPickupMaid then
		hatPickupMaid:DoCleaning()
	end
end

function v2.easeSineInOut(p: number)
	return (1 - math.cos(3.141592653589793 * p)) * 0.5
end

function v2.quadraticBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v3 = 1 - p
	return v3 * v3 * vector2 + v3 * 2 * p * vector3 + p * p * vector4
end

function v2.getBezierTangent(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	return (1 - p) * 2 * (vector3 - vector2) + p * 2 * (vector4 - vector3)
end

function v2.prepareMonkeyRetreatAnimation(instance)
	local model = instance:FindFirstAncestorOfClass("Model")

	if model then
		pcall(function()
			Anims:Get(model, "NPC_Jump")
		end)
	end
end

function v2:startMonkeyRetreat(instance, cframe: CFrame, vector2: Vector3, cframe2: CFrame, p: number, max: number)
	v2.closeMonkeyRetreat(self)

	if self.completed or not instance.Parent then
		return
	end

	local maid = Maid.new()
	self.retreatMaid = maid
	local nPCJump = nil
	local v3 = false
	local model = instance:FindFirstAncestorOfClass("Model")

	if model then
		pcall(function()
			nPCJump = Anims:Get(model, "NPC_Jump")
			nPCJump.Priority = Enum.AnimationPriority.Action4
			local length = nPCJump.Length
			local v4

			if typeof(length) == "number" then
				v4 = length > 0
			else
				v4 = false
			end

			nPCJump.Looped = not v4
			nPCJump:Play(0.05, 1, not v4 and 1 or length / max)

			if not v4 then
				v3 = true
				return
			end

			local v5 = math.clamp(workspace:GetServerTimeNow() - p, 0, max)
			nPCJump.TimePosition = length * (v5 / max)
		end)
	end

	if nPCJump then
		maid:GiveTask(function()
			pcall(function()
				nPCJump:Stop(0.1)
			end)
		end)
	end

	if nPCJump and v3 then
		maid:GiveTask(task.spawn(function()
			while self.retreatMaid == maid and instance.Parent do
				local v4 = math.clamp(workspace:GetServerTimeNow() - p, 0, max)

				if max <= v4 then
					break
				end

				local length = nPCJump.Length

				if typeof(length) == "number" and length > 0 then
					nPCJump.Looped = false
					nPCJump:AdjustSpeed(length / max)
					nPCJump.TimePosition = length * (v4 / max)
					break
				else
					RunService.PreRender:Wait()
				end
			end
		end))
	end

	maid:GiveTask(instance.Destroying:Once(function()
		v2.closeMonkeyRetreat(self, maid)
	end))
	local v4 = false
	maid:GiveTask(RunService.PreRender:Connect(function()
		if self.retreatMaid ~= maid or not instance.Parent then
			return
		end

		local v5 = math.clamp((workspace:GetServerTimeNow() - p) / max, 0, 1)
		local easeSineInOut = v2.easeSineInOut(v5)
		local quadraticBezier2 = v2.quadraticBezier(cframe.Position, vector2, cframe2.Position, easeSineInOut)
		local v6 = v2.getBezierTangent(cframe.Position, vector2, cframe2.Position, easeSineInOut) * createVector(
			1,
			0,
			1
		)
		local v7 = instance
		local cFrame

		if v6.Magnitude > 0.001 then
			cFrame = CFrame.lookAt(quadraticBezier2, quadraticBezier2 + v6.Unit)
		else
			cFrame = CFrame.new(quadraticBezier2) * cframe2.Rotation
		end

		v7.CFrame = cFrame
		instance.AssemblyLinearVelocity = createVector(0, 0, 0)
		instance.AssemblyAngularVelocity = createVector(0, 0, 0)

		if v5 >= 1 and not v4 then
			v4 = true
			task.defer(v2.closeMonkeyRetreat, self, maid)
		end
	end))
end

function v2:destroyFootsteps()
	local footsteps = self.footsteps
	self.footsteps = nil

	if footsteps then
		footsteps:Destroy()
	end
end

function v2.applyFootprints(folder, p)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local cFrame = p[part.Name]

		if cFrame then
			part.CFrame = cFrame
		else
			part:Destroy()
		end
	end
end

function v2:createFootsteps()
	local footprints = self.footprints

	if not footprints then
		return nil
	end

	local footsteps = self.footsteps

	if footsteps and footsteps.Parent then
		return footsteps
	end

	local jungle = v2.getJungle()

	if not jungle then
		return nil
	end

	local model = script:FindFirstChild(frozen.FOOTSTEPS_TAG)

	if not (model and model:IsA("Model")) then
		return nil
	end

	local clone = model:Clone()
	v2.applyFootprints(clone, footprints)
	clone:AddTag(frozen.FOOTSTEPS_TAG)
	clone.Parent = jungle
	self.footsteps = clone
	return clone
end

function v2.findNpcContainers()
	local nPCs = {}
	local nPCs2 = workspace:FindFirstChild("NPCs")

	if nPCs2 then
		table.insert(nPCs, nPCs2)
	end

	local nPCs3 = ReplicatedStorage:FindFirstChild("NPCs")

	if nPCs3 then
		table.insert(nPCs, nPCs3)
	end

	return nPCs
end

function v2.getAdventurerHatVisual()
	for _, v3 in v2.findNpcContainers() do
		local child = v3:FindFirstChild(frozen.ADVENTURER_NAME)
		local accessory

		if child then
			accessory = child:FindFirstChild(frozen.ADVENTURER_HAT_NAME)
		end

		if accessory and accessory:IsA("Accessory") then
			return accessory
		end
	end

	return nil
end

function v2.prepareHatClone(instance)
	local clone = instance:Clone()
	clone.Name = frozen.HAT_TOOL_NAME

	for _, jointInstance in clone:GetDescendants() do
		if jointInstance:IsA("JointInstance") then
			jointInstance:Destroy()
		end
	end

	local handle = clone:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		clone:Destroy()
		return nil, nil, nil
	end

	local result = {}

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		result[part] = handle.CFrame:ToObjectSpace(part.CFrame)
		part.Anchored = true
		part.AudioCanCollide = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.LocalTransparencyModifier = 0
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
	end

	return clone, handle, result
end

function v2.pivotHat(items, cframe: CFrame)
	for k, item in items do
		if k.Parent then
			k.CFrame = cframe * item
		end
	end
end

function v2.addHatPrompt(object, data, maid, parent)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Pick up"
	proximityPrompt.ObjectText = frozen.HAT_TOOL_NAME
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
	proximityPrompt.HoldDuration = 0
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = parent
	maid:GiveTask(proximityPrompt.Triggered:Connect(function()
		if not proximityPrompt.Enabled then
			return
		end

		proximityPrompt.Enabled = false
		object:FireServer("ClaimHat")
		maid:GiveTask(task.delay(frozen.HAT_PROMPT_RETRY_DELAY, function()
			if data.hatPickupMaid == maid and not data.completed and not data.ownsHat and not v2.hasHat() and proximityPrompt.Parent then
				proximityPrompt.Enabled = true
			end
		end))
	end))
end

function v2.showDroppedHat(p, state, cframe: CFrame, cframe2: CFrame)
	v2.closeHatPickup(state)

	if state.completed or state.ownsHat or v2.hasHat() then
		return
	end

	local adventurerHatVisual = v2.getAdventurerHatVisual()

	if not adventurerHatVisual then
		return
	end

	local parent, adornee, v5 = v2.prepareHatClone(adventurerHatVisual)

	if not (parent and adornee and v5) then
		return
	end

	local maid = Maid.new()
	state.hatPickupMaid = maid
	parent.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	v2.pivotHat(v5, cframe)
	local highlight = Instance.new("Highlight")
	highlight.Name = frozen.HAT_HIGHLIGHT_NAME
	highlight.Adornee = adornee
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = frozen.HAT_HIGHLIGHT_COLOR
	highlight.OutlineColor = frozen.HAT_HIGHLIGHT_COLOR
	highlight.FillTransparency = frozen.HAT_HIGHLIGHT_FILL_TRANSPARENCY
	highlight.OutlineTransparency = 0
	highlight.Parent = parent
	maid:GiveTask(parent)
	maid:GiveTask(parent.Destroying:Once(function()
		v2.closeHatPickup(state, maid)
	end))
	maid:GiveTask(task.spawn(function()
		local lastTime = os.clock()
		local v6 = cframe.Position:Lerp(cframe2.Position, 0.5) + createVector(0, 1, 0) * frozen.HAT_BOUNCE_HEIGHT

		while state.hatPickupMaid == maid and parent.Parent do
			local v7 = math.clamp((os.clock() - lastTime) / frozen.HAT_BOUNCE_DURATION, 0, 1)
			local easeSineInOut = v2.easeSineInOut(v7)
			local quadraticBezier2 = v2.quadraticBezier(cframe.Position, v6, cframe2.Position, easeSineInOut)
			local lerped = cframe.Rotation:Lerp(cframe2.Rotation, easeSineInOut)
			local cframe3 = CFrame.fromAxisAngle(
				(createVector(1, 0.35, 0.2)).Unit,
				v7 * 3.141592653589793 * 2 * frozen.HAT_BOUNCE_ROTATIONS
			)
			v2.pivotHat(v5, CFrame.new(quadraticBezier2) * lerped * cframe3)

			if v7 >= 1 then
				break
			else
				RunService.PreRender:Wait()
			end
		end

		if state.hatPickupMaid == maid and parent.Parent and adornee.Parent then
			v2.pivotHat(v5, cframe2)
			v2.addHatPrompt(p, state, maid, adornee)
		end
	end))
end

function v2.hideAdventurerHat(p)
	for _, v3 in v2.findNpcContainers() do
		local model = v3:FindFirstChild(frozen.ADVENTURER_NAME)
		local folder

		if model and model:IsA("Model") then
			folder = model:FindFirstChild(frozen.ADVENTURER_HAT_NAME)
		end

		if not folder then
			continue
		end

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if p.hatTransparency[part] == nil then
				p.hatTransparency[part] = part.LocalTransparencyModifier
			end

			part.LocalTransparencyModifier = 1
		end
	end
end

function v2.restorePresentation(p)
	v2.destroyFootsteps(p)

	for k, localTransparencyModifier in p.hatTransparency do
		if k.Parent then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	table.clear(p.hatTransparency)
end

function v2.getDiscoveryTarget(p, vector2: Vector3)
	local footsteps = p.footsteps

	if not (footsteps and footsteps.Parent) then
		return nil, nil
	end

	local v3 = 1e999
	local position = nil

	for _, part in footsteps:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local magnitude = (vector2 - part.Position).Magnitude

		if not (magnitude < v3) then
			continue
		end

		position = part.Position
		v3 = magnitude
	end

	if position then
		return position, v3
	end

	return nil, nil
end

function v2.focusTarget(object, p)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v3 = CameraController.new(currentCamera, 1, frozen.CAMERA_BLEND_TIME)
	local v4 = v3:SetCameraTarget(p)
	v4:SetPositionLocked(true)
	v4:SetTrackingSpring(frozen.CAMERA_DAMPING, frozen.CAMERA_FREQUENCY)
	object:getMaid():GiveTask(function()
		v3:FadeOut(frozen.CAMERA_RETURN_TIME)
	end)
end

function v2:closeTrackedDialogue(p2: string)
	local v3 = self[p2]
	self[p2] = nil

	if v3 and DialogueController.getActiveDialogue() == v3 then
		DialogueController.close()
	end
end

function v2:closeFallCamera(p)
	if p and self.fallCamera ~= p then
		return
	end

	local fallCamera = self.fallCamera
	local fallCameraReturnCFrame = self.fallCameraReturnCFrame
	self.fallCamera = nil
	self.fallCameraReturnCFrame = nil

	if fallCamera then
		if fallCameraReturnCFrame then
			local success, result = pcall(fallCamera.TeleportBack, fallCamera, fallCameraReturnCFrame)

			if not success then
				warn((`[Thieving Monkey] Fall camera restoration failed: {tostring(result)}`))
				pcall(fallCamera.Destroy, fallCamera)
				local currentCamera = workspace.CurrentCamera

				if currentCamera then
					currentCamera.CFrame = fallCameraReturnCFrame
				end
			end
		else
			fallCamera:FadeOut(frozen.CAMERA_RETURN_TIME)
		end
	end
end

function v2.getSafeFallCameraCFrame(cframe: CFrame, vector2: Vector3, instance)
	local DISTANCE_EPSILON = 0.01
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true
	local filterDescendantsInstances = {}
	local character = localPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local model = instance:FindFirstAncestorOfClass("Model")

	if model then
		table.insert(filterDescendantsInstances, model)
	end

	for _, childName in {
		"Characters",
		"Enemies",
		"NPCs",
		"_WorldOrigin"
	} do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local position = cframe.Position
	local v4 = (position - vector2) * createVector(1, 0, 1)

	if v4.Magnitude < frozen.FALL_CAMERA_MIN_HORIZONTAL_DISTANCE then
		local v5 = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 0) or -humanoidRootPart.CFrame.LookVector * createVector(
			1,
			0,
			1
		)

		if v5.Magnitude <= DISTANCE_EPSILON and v4.Magnitude > DISTANCE_EPSILON then
			v5 = v4
		end

		if v5.Magnitude <= DISTANCE_EPSILON then
			v5 = -cframe.LookVector * createVector(1, 0, 1)
		end

		local unit = (v5.Magnitude <= DISTANCE_EPSILON and createVector(0, 0, 1) or v5).Unit
		local v6

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			v6 = (humanoidRootPart.Position - vector2) * createVector(1, 0, 1) + unit * (frozen.FALL_CAMERA_MIN_HORIZONTAL_DISTANCE + 5)
		else
			v6 = unit * (frozen.FALL_CAMERA_MIN_HORIZONTAL_DISTANCE + 5)
		end

		if v6.Magnitude > DISTANCE_EPSILON then
			unit = v6.Unit
		end

		local v7 = unit * math.max(v6.Magnitude, frozen.FALL_CAMERA_MIN_HORIZONTAL_DISTANCE + 5)
		position = Vector3.new(vector2.X + v7.X, position.Y, vector2.Z + v7.Z)
	end

	local v5 = math.max(
		position.Y,
		vector2.Y,
		not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and -1e999 or humanoidRootPart.Position.Y
	) + frozen.FALL_CAMERA_GROUND_CAST_UP
	local v6 = math.min(position.Y, vector2.Y) - frozen.FALL_CAMERA_GROUND_CAST_DOWN
	local vector3 = Vector3.new(position.X, v5, position.Z)
	local raycastResult = workspace:Raycast(vector3, createVector(-0, -1, -0) * (v5 - v6), raycastParams)

	if raycastResult then
		position = Vector3.new(
			position.X,
			math.max(position.Y, raycastResult.Position.Y + frozen.FALL_CAMERA_GROUND_CLEARANCE),
			position.Z
		)
	end

	if (vector2 - position).Magnitude > DISTANCE_EPSILON then
		return (CFrame.lookAt(position, vector2))
	end

	return CFrame.new(position) * cframe.Rotation
end

function v2:startFallCamera(instance)
	v2.closeTrackedDialogue(self, "noticeDialogue")
	v2.closeFallCamera(self)
	local currentCamera = workspace.CurrentCamera

	if self.completed or not currentCamera then
		return
	end

	local cFrame = currentCamera.CFrame
	local v3 = instance.Position + createVector(0, 1, 0) * frozen.FALL_FOCUS_HEIGHT
	local fallCamera = CameraController.new(currentCamera, 1, frozen.CAMERA_BLEND_TIME)
	fallCamera:SetCFrame(v2.getSafeFallCameraCFrame(currentCamera.CFrame, v3, instance))
	self.fallCamera = fallCamera
	self.fallCameraReturnCFrame = cFrame
	local v5 = nil
	v5 = fallCamera:SetCameraTarget(function()
		if not instance.Parent then
			return v3
		end

		v3 = instance.Position + createVector(0, 1, 0) * frozen.FALL_FOCUS_HEIGHT
		local _lockedPosition = v5 and v5._lockedPosition

		if _lockedPosition and ((_lockedPosition - v3) * createVector(1, 0, 1)).Magnitude < frozen.FALL_CAMERA_MIN_HORIZONTAL_DISTANCE then
			local v6 = CFrame.new(_lockedPosition) * fallCamera:GetCFrame().Rotation
			v5._lockedPosition = v2.getSafeFallCameraCFrame(v6, v3, instance).Position
		end

		return v3
	end)
	v5:SetPositionLocked(true)
	local CAMERA_DAMPING = frozen.CAMERA_DAMPING
	local CAMERA_FREQUENCY = frozen.CAMERA_FREQUENCY
	v5:SetTrackingSpring(CAMERA_DAMPING, CAMERA_FREQUENCY)
	fallCamera.Animations:AnimateFieldOfView(
		frozen.FALL_CAMERA_FIELD_OF_VIEW,
		frozen.CAMERA_DAMPING,
		frozen.CAMERA_FREQUENCY
	)
	self.maid:GiveTask(instance.Destroying:Once(function()
		v2.closeFallCamera(self, fallCamera)
	end))
	task.delay(frozen.FALL_CAMERA_TIMEOUT, function()
		v2.closeFallCamera(self, fallCamera)
	end)
end

function v2:showNotice(vector2: Vector3)
	if self.noticed or self.completed or DialogueController.getActiveDialogue() then
		return false
	end

	local v3 = DialogueController.new()
	v3:setTitle("")
	v3:addPage(function(object)
		object:setTitle("")
		object:noCancel()
		object:noSkip()
		object:addText(frozen.NOTICE_TEXT)
		object:advanceAfterDelay(frozen.NOTICE_DURATION)
	end)
	local v4 = v3:build()
	local noticeDialogue = DialogueController.start(v4)

	if not noticeDialogue then
		return false
	end

	self.noticed = true
	self.noticeDialogue = noticeDialogue
	v2.focusTarget(v4, vector2)
	v4:getMaid():GiveTask(function()
		if self.noticeDialogue == noticeDialogue then
			self.noticeDialogue = nil
		end
	end)
	return true
end

function v2:showSurrender(instance)
	v2.closeTrackedDialogue(self, "noticeDialogue")

	if self.completed or DialogueController.getActiveDialogue() then
		return
	end

	local v3 = DialogueController.new()
	v3:setTitle(frozen.SURRENDER_TITLE)
	v3:addPage(function(object)
		object:setTitle(frozen.SURRENDER_TITLE)
		object:noCancel()
		object:noSkip()
		object:addText(frozen.SURRENDER_TEXT)
		object:advanceAfterDelay(frozen.SURRENDER_DURATION)
	end)
	local v4 = v3:build()
	local surrenderDialogue = DialogueController.start(v4)

	if not surrenderDialogue then
		return
	end

	self.surrenderDialogue = surrenderDialogue
	local v6 = instance.Position + createVector(0, 1, 0) * frozen.SURRENDER_FOCUS_HEIGHT
	v2.focusTarget(v4, function()
		if instance.Parent then
			v6 = instance.Position + createVector(0, 1, 0) * frozen.SURRENDER_FOCUS_HEIGHT
		end

		return v6
	end)
	v4:getMaid():GiveTask(function()
		if self.surrenderDialogue == surrenderDialogue then
			self.surrenderDialogue = nil
		end
	end)
	task.delay(frozen.SURRENDER_DURATION, function()
		if self.surrenderDialogue == surrenderDialogue and DialogueController.getActiveDialogue() == surrenderDialogue then
			DialogueController.close()
		end
	end)
end

function v2.bindDeath(p, instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function bind(humanoid)
		p.maid:GiveTask(humanoid.Died:Once(function()
			v2.closeTrackedDialogue(p, "noticeDialogue")
			v2.closeFallCamera(p)
			v2.closeMonkeyRetreat(p)
			v2.closeHatPickup(p)
		end))
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		p.maid:GiveTask(humanoid.Died:Once(function()
			v2.closeTrackedDialogue(p, "noticeDialogue")
			v2.closeFallCamera(p)
			v2.closeMonkeyRetreat(p)
			v2.closeHatPickup(p)
		end))
	else
		p.maid:GiveTask(task.spawn(function()
			local humanoid2 = instance:WaitForChild("Humanoid", 5)

			if humanoid2 and humanoid2:IsA("Humanoid") and localPlayer.Character == instance then
				bind(humanoid2) -- equivalent call inferred; original call site unknown
			end
		end))
	end
end

function v2.startPresentation(p, data)
	data.maid:GiveTask(task.spawn(function()
		while not data.completed do
			v2.hideAdventurerHat(data)

			if p.Active and data.footprints then
				v2.createFootsteps(data)
			else
				v2.destroyFootsteps(data)
			end

			task.wait(frozen.PRESENTATION_REFRESH_INTERVAL)
		end
	end))
end

function v2.startDiscovery(p, data)
	data.maid:GiveTask(task.spawn(function()
		while not (data.completed or data.noticed) do
			if p.Active and data.footprints then
				local character = localPlayer.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					local discoveryTarget, v3 = v2.getDiscoveryTarget(data, humanoidRootPart.Position)

					if discoveryTarget and v3 and v3 <= frozen.NOTICE_DISTANCE then
						v2.showNotice(data, discoveryTarget)
					end
				end
			end

			task.wait(frozen.SCAN_INTERVAL)
		end
	end))
end

function v2.buildReturnDialogue(object, internalQuestName: string?)
	local v3 = DialogueController.new()
	v3:setTitle(frozen.ADVENTURER_NAME)
	v3:setSubtitle(frozen.ADVENTURER_SUBTITLE)
	v3:addPage("Return", function(object2)
		object2:addText(frozen.RETURN_TEXT)
		object2:addOption(function(object3)
			object3:setText(frozen.RETURN_LABEL)
			object3:jumpToPage(function(object4)
				if object:InvokeServer("ReturnHat") ~= true then
					object4:addText("I couldn't take the hat. Please move closer and try again.")
					return
				end

				object4:addText(frozen.RETURN_THANKS_TEXT)
				object4:addOption(function(object5)
					object5:setText(frozen.RETURN_THANKS_LABEL)
				end)
			end)
		end)
	end)
	local v4 = v3:build()
	v4.InternalQuestName = internalQuestName
	return v4
end

function v2.installAdventurerDialogue()
	if flag then
		return
	end

	flag = true
	DialogueRegistry.register(frozen.ADVENTURER_NAME, frozen.DIALOGUE_PROVIDER_ID, frozen.DIALOGUE_PRIORITY, function(p)
		if typeof(p) ~= "table" then
			return nil
		end

		local v3 = v

		if v3 and v3.Active and not v3.Completed and v2.canReturnHat(v3) then
			return v2.buildReturnDialogue(v3, p.InternalQuestName)
		end

		return nil
	end)
end

local TheThievingMonkey = {}
TheThievingMonkey.DataName = script.Name
TheThievingMonkey.Repeatable = false

function TheThievingMonkey.OnLoad(object)
	local state = v2.getState(object)
	v = object
	v2.installAdventurerDialogue()

	if state.completed then
		return
	end

	v2.startPresentation(object, state)
	v2.startDiscovery(object, state)

	if localPlayer.Character then
		v2.bindDeath(state, localPlayer.Character)
	end

	state.maid:GiveTask(localPlayer.CharacterAdded:Connect(function(character)
		v2.bindDeath(state, character)
	end))
	object:FireServer("Initialize")
end

TheThievingMonkey.RemoteEvents = {
	Footprints = function(p, items)
		local state = v2.getState(p)
		local footprints = {}
		local v4 = false

		if typeof(items) == "table" then
			for k, item in items do
				if not (typeof(k) == "string" and typeof(item) == "CFrame") then
					continue
				end

				footprints[k] = item
				v4 = true
			end
		end

		if not v4 then
			footprints = nil
		end

		state.footprints = footprints
		v2.destroyFootsteps(state)
		v2.createFootsteps(state)
	end,
	HatState = function(p, p2)
		local state = v2.getState(p)
		state.ownsHat = p2 == true

		if state.ownsHat then
			v2.closeHatPickup(state)
		end
	end,
	ClearHatPickup = function(p)
		v2.closeHatPickup(v2.getState(p))
	end,
	HatDropped = function(p, p2, p3)
		if typeof(p2) ~= "CFrame" or typeof(p3) ~= "CFrame" then
			return
		end

		v2.showDroppedHat(p, v2.getState(p), p2, p3)
	end,
	MonkeyRetreat = function(p, part, p2, p3, p4, value, value2)
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") or typeof(p2) ~= "CFrame" or typeof(p3) ~= "Vector3" or typeof(p4) ~= "CFrame" or typeof(value) ~= "number" or typeof(value2) ~= "number" or value2 <= 0 then
			return
		end

		v2.startMonkeyRetreat(v2.getState(p), part, p2, p3, p4, value, value2)
	end,
	MonkeyDefeated = function(p, part)
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
			return
		end

		local state = v2.getState(p)
		v2.closeFallCamera(state)
		v2.showSurrender(state, part)
	end,
	MonkeyFalling = function(p, part)
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
			return
		end

		v2.prepareMonkeyRetreatAnimation(part)
		v2.startFallCamera(v2.getState(p), part)
	end,
	MonkeyLanded = function(p)
		v2.closeFallCamera(v2.getState(p))
	end
}

function TheThievingMonkey.OnComplete(p, flag2: boolean)
	local state = v2.getState(p)
	state.completed = p.Completed or flag2
	state.ownsHat = false
	v2.closeTrackedDialogue(state, "noticeDialogue")
	v2.closeTrackedDialogue(state, "surrenderDialogue")
	v2.closeFallCamera(state)
	v2.closeMonkeyRetreat(state)
	v2.closeHatPickup(state)
	v2.restorePresentation(state)

	if v == p then
		v = nil
	end
end

return TheThievingMonkey