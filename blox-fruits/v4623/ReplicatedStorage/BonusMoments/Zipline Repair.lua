local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Anims = require(ReplicatedStorage.Util.Anims)
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local CameraController = require(ReplicatedStorage.Controllers.CameraController)
local DialogueController = require(ReplicatedStorage.DialogueController)
local Util = require(ReplicatedStorage.DialoguesList.Util)
local Effect = require(ReplicatedStorage.Effect)
local FX = require(game.ReplicatedStorage.FX)
local Maid = require(ReplicatedStorage.Util.Maid)
require(ReplicatedStorage.Controllers.BonusMomentsController.Types)
local ZiplinePair = require(ReplicatedStorage.ClientComponents.ZiplinePair)
local frozen = table.freeze({
	ASSET_FOLDER_NAME = "ZiplineAssets",
	PICKUP_ASSET_NAME = "GroundPickupGrapplingHook",
	PICKUP_ACTION = "Pick Up",
	PICKUP_INTERACTION_PART_NAME = "hook.001",
	PICKUP_OBJECT = "Grappling Hook",
	PROMPT_RANGE = 12,
	PROMPT_HOLD_DURATION = 0.4,
	PROMPT_RETRY_DELAY = 1,
	NPC_ENABLED = false,
	NPC_NAME = "Stranded Explorer",
	INTERNAL_THOUGHT_TITLE = "",
	INTERNAL_BELOW_NPC_TEXT = "I should get higher before I throw this.",
	INTERNAL_WRONG_AREA_TEXT = "Seems like there's something for the grapple to hook onto over there...",
	NPC_DIALOGUE_DURATION = 2.5,
	NPC_EFFECT_RANGE = 300,
	NPC_RAY_UP = 1,
	NPC_RAY_DOWN = 48,
	NPC_ROOT_FLOOR_OFFSET = 2.385,
	FEEDBACK_BELOW_NPC = "BelowNpc",
	FEEDBACK_WRONG_AREA = "WrongArea",
	BELOW_NPC_TEXT = "Try throwing it from up here!",
	WRONG_AREA_TEXT = "What are you aiming for?  The zipline is over there!",
	PICKUP_DIALOGUE_TEXT = "HEY YOU!<AnimateYield=1> Over here!<AnimateYield=1> Could you bring that grapple over here?",
	NPC_INTERACTION_TEXT = "Wow, I'm really lucky you passed by!",
	NPC_WHATS_UP_OPTION = "What's up?",
	NPC_WHATS_UP_RESPONSE = "I got up here with the zipline earlier, but the rope broke and the grapple line fell all the way down! I'd never be able to get it from up here!",
	NPC_HELP_OPTION = "How can I help?",
	NPC_HELP_RESPONSE = "You see that zipline station over there?<AnimateYield=2> Could you toss that grappling hook in that direction and try to set it back up?",
	NPC_SUCCESS_TEXT = "Nice throw! I'm gonna head down now! Thanks again!",
	NPC_RIDE_TEXT = "This is fun! You should give it a try too!",
	NPC_WALK_ANIMATION = "NPC_Walk",
	NPC_WALK_DURATION = 1.35,
	NPC_STATION_APPROACH_DISTANCE = 3,
	NPC_RIDE_DIALOGUE_DELAY = 0.6,
	PICKUP_CAMERA_FOV_REDUCTION = 30,
	MIN_CAMERA_FIELD_OF_VIEW = 20,
	FLASH_NAME = "ZiplineRepairDestinationFlash",
	FLASH_COLOR = Color3.fromRGB(70, 255, 100),
	FLASH_FADE_DURATION = 0.25,
	FLASH_HOLD_DURATION = 1.5,
	CAMERA_BLEND_TIME = 0.15,
	CAMERA_RETURN_TIME = 0.2,
	CAMERA_FIELD_OF_VIEW = 50,
	STATION_CAMERA_FIELD_OF_VIEW = 25,
	STATION_CAMERA_DISTANCE = 32,
	STATION_CAMERA_HEIGHT = 8,
	STATION_CAMERA_CLEARANCE = 2,
	STATION_FOCUS_HEIGHT = 2.5,
	CAMERA_TRACKING_DAMPING = 1,
	CAMERA_TRACKING_FREQUENCY = 3,
	ZIPLINE_PAIR_NAME = "ZiplinePair",
	ZIPLINE_PAIR_TAG = "ZiplinePair",
	ZIPLINE_ENDPOINT_NAME = "zipline",
	ZIPLINE_PRIMARY_PART_NAME = "Cube.003",
	REPAIRED_VISUAL_NAME = "RepairedZipline",
	REPAIR_RETRY_DELAY = 1,
	REPAIR_RETRY_ATTEMPTS = 30,
	SETUP_RETRY_DELAY = 4,
	SETUP_RETRY_ATTEMPTS = 30,
	TROLLEY_NAME = "Cylinder",
	TROLLEY_TEMPLATE_ATTRIBUTE = "ZiplineTrolleyTemplate",
	RIDE_TROLLEY_ATTRIBUTE = "ZiplineRideTrolley",
	ROPE_POINT_NAME = "RopePoint",
	RIDE_WELD_NAME = "ZiplineRideWeld",
	RIDER_TAG = "ZiplineActiveRider",
	NPC_TROLLEY_ATTRIBUTE = "ZiplineRepairNpcTrolley",
	RIDE_START_CFRAME_ATTRIBUTE = "ZiplineRideStartCFrame",
	RIDE_TARGET_CFRAME_ATTRIBUTE = "ZiplineRideTargetCFrame",
	RIDE_START_TIME_ATTRIBUTE = "ZiplineRideStartTime",
	RIDE_DURATION_ATTRIBUTE = "ZiplineRideDuration",
	RIDER_OFFSET = createVector(0, -4.5, 0),
	ENDPOINT_PADDING = 2.2,
	RIDE_SPEED = 65,
	MINIMUM_RIDE_DURATION = 0.5
})
local v = {}
local v2 = false
local count = 0
local connection = nil

function v.isRepairedVisualMissing()
	for _, model in CollectionService:GetTagged(frozen.ZIPLINE_PAIR_TAG) do
		if model:IsA("Model") and model:IsDescendantOf(workspace) and not model:FindFirstChild(frozen.REPAIRED_VISUAL_NAME) then
			return true
		end
	end

	return false
end

function v.retryRepaired(p: number)
	task.spawn(function()
		for _ = 1, frozen.REPAIR_RETRY_ATTEMPTS do
			task.wait(frozen.REPAIR_RETRY_DELAY)

			if not v2 or count ~= p or not v.isRepairedVisualMissing() then
				break
			end

			ZiplinePair:setDefaultRepaired(true)
		end
	end)
end

function v.watchZiplinePairs()
	if connection then
		return
	end

	connection = CollectionService:GetInstanceAddedSignal(frozen.ZIPLINE_PAIR_TAG):Connect(function()
		if not v2 then
			return
		end

		count += 1
		v.retryRepaired(count)
	end)
end

function v.setRepaired(flag: boolean)
	v2 = flag
	count += 1
	ZiplinePair:setDefaultRepaired(flag)
	v.watchZiplinePairs()

	if flag then
		v.retryRepaired(count)
	end
end

function v.getState(maid)
	local _ziplineRepairClientState = maid.MiscData._ziplineRepairClientState

	if _ziplineRepairClientState then
		return _ziplineRepairClientState
	end

	local maid2 = Maid.new()
	local ziplineRepairClientState = {
		_maid = maid2,
		_pickupCFrame = nil,
		_pickupLoading = false,
		_pickupModel = nil,
		_npc = nil,
		_sourceEndpoint = nil,
		_sourcePosition = nil,
		_targetEndpoint = nil,
		_targetPosition = nil,
		_feedbackDialogue = nil,
		_ownsTool = false,
		_completed = maid.Completed,
		_departing = false
	}
	maid.MiscData._ziplineRepairClientState = ziplineRepairClientState
	maid:GiveTask(maid2)
	maid2:GiveTask(function()
		v.closeFeedback(ziplineRepairClientState)
		v.removeNpc(ziplineRepairClientState)
		v.destroyPickup(ziplineRepairClientState)
	end)
	return ziplineRepairClientState
end

function v:destroyPickup()
	if self._pickupModel then
		self._pickupModel:Destroy()
		self._pickupModel = nil
	end
end

function v:closeFeedback(flag: boolean?)
	local _feedbackDialogue = self._feedbackDialogue
	self._feedbackDialogue = nil
	local activeDialogue = DialogueController.getActiveDialogue()

	if activeDialogue and (flag or activeDialogue == _feedbackDialogue) then
		DialogueController.close()
	end
end

function v:removeNpc(flag: boolean?)
	local _npc = self._npc
	self._npc = nil

	if not _npc then
		return
	end

	if _npc:IsDescendantOf(workspace) then
		local pivot = _npc:GetPivot()
		local currentCamera = workspace.CurrentCamera

		if currentCamera and (flag or (currentCamera.CFrame.Position - pivot.Position).Magnitude <= frozen.NPC_EFFECT_RANGE) then
			pcall(function()
				Effect.new("Chests.Despawn"):play({
					CFrame = pivot
				})
			end)
		end
	end

	_npc:Destroy()
end

function v.getGroundedNpcCFrame(cframe: CFrame)
	local map = workspace:FindFirstChild("Map")
	local jungle

	if map then
		jungle = map:FindFirstChild("Jungle")
	end

	if not jungle then
		return cframe
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { jungle }
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	local v3 = cframe.Position + createVector(0, 1, 0) * frozen.NPC_RAY_UP
	local raycastResult = workspace:Raycast(
		v3,
		createVector(-0, -1, -0) * (frozen.NPC_RAY_UP + frozen.NPC_RAY_DOWN),
		raycastParams
	)

	if not raycastResult then
		return cframe
	end

	local v4 = raycastResult.Position + createVector(0, 1, 0) * frozen.NPC_ROOT_FLOOR_OFFSET
	return CFrame.new(v4) * cframe.Rotation
end

function v:updateNpcInteraction()
	local _npc = self._npc

	if _npc then
		_npc:SetAttribute("LockedInteraction", self._completed or self._departing or not self._ownsTool)
	end
end

function v.destroyNpcQuestVisual(instance)
	if instance.Name ~= "QuestBBG" and instance.Name ~= "QUEST" then
		return
	end

	task.defer(function()
		if instance.Parent then
			instance:Destroy()
		end
	end)
end

function v:suppressNpcQuestVisuals(folder)
	folder:SetAttribute("NoAura", true)
	folder:SetAttribute("NoRing", true)

	for _, descendant in folder:GetDescendants() do
		v.destroyNpcQuestVisual(descendant)
	end

	self._maid:GiveTask(folder.DescendantAdded:Connect(v.destroyNpcQuestVisual))
end

function v.createNpc(object, state, cframe: CFrame)
	if not frozen.NPC_ENABLED or state._completed or state._npc then
		return
	end

	local model = script:FindFirstChild(frozen.NPC_NAME)

	if not (model and model:IsA("Model")) then
		return
	end

	local clone = model:Clone()
	clone.Name = frozen.NPC_NAME
	clone:SetAttribute("DisplayName", frozen.NPC_NAME)
	clone:SetAttribute("LockedInteraction", true)
	clone:SetAttribute("NoAura", true)
	clone:SetAttribute("NoRing", true)
	clone:PivotTo(v.getGroundedNpcCFrame(cframe))
	local npc = object:AddNpc(clone, function()
		return v.buildNpcDialogue(state)
	end, true)
	clone:Destroy()
	state._npc = npc
	v.suppressNpcQuestVisuals(state, npc)
	v.updateNpcInteraction(state)
end

function v.getClearStationCameraCFrame(p, vector2: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local v3 = (currentCamera.CFrame.Position - vector2) * createVector(1, 0, 1)
	local v4 = not (v3.Magnitude > 0.01) and createVector(0, 0, 1) or v3.Unit
	local raycastParams = RaycastParams.new()
	local characters = { p.Parent or p }
	local character = Players.LocalPlayer.Character

	if character then
		table.insert(characters, character)
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	local v5 = 0
	local v6 = nil

	for _, v7 in {
		0,
		45,
		-45,
		90,
		-90,
		180
	} do
		local v8 = vector2 + CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(v7))):VectorToWorldSpace(v4) * frozen.STATION_CAMERA_DISTANCE + createVector(
			0,
			1,
			0
		) * frozen.STATION_CAMERA_HEIGHT
		local v9 = v8 - vector2
		local raycastResult = workspace:Raycast(vector2, v9, raycastParams)

		if not raycastResult then
			return CFrame.lookAt(v8, vector2)
		end

		local v10 = math.max(raycastResult.Distance - frozen.STATION_CAMERA_CLEARANCE, 0)

		if not (v5 < v10) then
			continue
		end

		v6 = vector2 + v9.Unit * v10
		v5 = v10
	end

	if v6 and not (v5 < frozen.STATION_CAMERA_CLEARANCE * 2) then
		return CFrame.lookAt(v6, vector2)
	end

	return nil
end

function v.focusTarget(object, vector2: Vector3, p: number?, cframe: CFrame?)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local v3 = CameraController.new(currentCamera, 1, frozen.CAMERA_BLEND_TIME)

	if cframe then
		v3:SetCFrame(cframe)
	end

	local v4 = v3:SetCameraTarget(vector2)
	v4:SetPositionLocked(true)
	v4:SetTrackingSpring(frozen.CAMERA_TRACKING_DAMPING, frozen.CAMERA_TRACKING_FREQUENCY)
	v3.Animations:AnimateFieldOfView(
		p or frozen.CAMERA_FIELD_OF_VIEW,
		frozen.CAMERA_TRACKING_DAMPING,
		frozen.CAMERA_TRACKING_FREQUENCY
	)
	object:getMaid():GiveTask(function()
		v3:FadeOut(frozen.CAMERA_RETURN_TIME)
	end)
end

function v.focusStation(p, p2, instance)
	local parent = instance.Parent

	if not (parent and parent:IsA("Model")) then
		return
	end

	local v3 = instance.Position + createVector(0, 1, 0) * frozen.STATION_FOCUS_HEIGHT
	local clearStationCameraCFrame = v.getClearStationCameraCFrame(parent, v3)
	v.flashDestination(p, instance)
	v.focusTarget(p2, v3, frozen.STATION_CAMERA_FIELD_OF_VIEW, clearStationCameraCFrame)
end

function v:addHelpOption(object)
	object:addOption(function(object2)
		object2:setText(frozen.NPC_HELP_OPTION):jumpToPage(function(object3)
			object3:noCancel()
			object3:noSkip()
			object3:addText(frozen.NPC_HELP_RESPONSE)
			object3:advanceAfterDelay(frozen.NPC_DIALOGUE_DURATION)
			local _targetEndpoint = self._targetEndpoint

			if _targetEndpoint and _targetEndpoint.Parent then
				v.focusStation(self, object3, _targetEndpoint)
			end
		end)
	end)
end

function v:buildNpcDialogue()
	local v3 = DialogueController.new()
	v3:setTitle(frozen.NPC_NAME)
	v3:addPage(function(object)
		object:setTitle(frozen.NPC_NAME)
		object:noCancel()

		if self._completed or self._departing or not self._ownsTool then
			object:noSkip()
			object:addText("...")
			object:advanceAfterDelay(1)
		else
			object:addText(frozen.NPC_INTERACTION_TEXT)
			object:addOption(function(object2)
				object2:setText(frozen.NPC_WHATS_UP_OPTION):jumpToPage(function(object3)
					object3:noCancel()
					object3:noSkip()
					object3:addText(frozen.NPC_WHATS_UP_RESPONSE)
					v.addHelpOption(self, object3)
				end)
			end)
			v.addHelpOption(self, object)
		end
	end)
	return v3:build()
end

function v:prepareFeedbackDialogue()
	local activeDialogue = DialogueController.getActiveDialogue()

	if not activeDialogue then
		return true
	end

	if activeDialogue ~= self._feedbackDialogue then
		return false
	end

	DialogueController.close()
	self._feedbackDialogue = nil
	return true
end

function v:showNpcDialogue(p: string, vector2: Vector3?, p2: number?, flag: boolean?)
	if not v.prepareFeedbackDialogue(self) then
		return nil
	end

	local NPC_NAME

	if frozen.NPC_ENABLED then
		NPC_NAME = frozen.NPC_NAME
	else
		NPC_NAME = frozen.INTERNAL_THOUGHT_TITLE
	end

	local v3 = DialogueController.new()
	v3:setTitle(NPC_NAME)
	v3:addPage(function(object)
		object:setTitle(NPC_NAME)
		object:noCancel()
		object:noSkip()
		object:addText(p)
		object:advanceAfterDelay(frozen.NPC_DIALOGUE_DURATION)
	end)
	local v4 = v3:build()
	local feedbackDialogue = DialogueController.start(v4)
	self._feedbackDialogue = feedbackDialogue

	if not feedbackDialogue then
		return nil
	end

	if vector2 then
		v.focusTarget(v4, vector2, p2)
	end

	local _npc = self._npc
	local NPC_ENABLED = frozen.NPC_ENABLED

	if NPC_ENABLED then
		if flag == true and _npc ~= nil then
			NPC_ENABLED = _npc.Parent ~= nil
		else
			NPC_ENABLED = false
		end
	end

	if NPC_ENABLED then
		Util.playAction("Welcome", _npc)
	end

	v4:getMaid():GiveTask(function()
		if NPC_ENABLED then
			Util.stopAction("Welcome", _npc)
		end

		if self._feedbackDialogue == feedbackDialogue then
			self._feedbackDialogue = nil
		end
	end)
	return feedbackDialogue
end

function v.showFeedbackDialogue(p, p2: string, vector2: Vector3?)
	v.showNpcDialogue(p, p2, vector2, nil, false)
end

function v:showPickupDialogue()
	if not frozen.NPC_ENABLED or self._completed then
		return
	end

	local _npc = self._npc
	local currentCamera = workspace.CurrentCamera

	if _npc and _npc.Parent and currentCamera then
		local v3 = math.max(
			currentCamera.FieldOfView - frozen.PICKUP_CAMERA_FOV_REDUCTION,
			frozen.MIN_CAMERA_FIELD_OF_VIEW
		)
		v.showNpcDialogue(self, frozen.PICKUP_DIALOGUE_TEXT, _npc:GetPivot().Position, v3, true)
	end
end

function v:getNpcRideParts()
	local _targetEndpoint = self._targetEndpoint
	local parent = _targetEndpoint and _targetEndpoint.Parent
	local parent2 = parent and parent.Parent

	if not _targetEndpoint or _targetEndpoint.Name ~= frozen.ZIPLINE_PRIMARY_PART_NAME or not parent or not parent:IsA("Model") or parent.Name ~= frozen.ZIPLINE_ENDPOINT_NAME or not parent2 or not parent2:IsA("Model") or parent2.Name ~= frozen.ZIPLINE_PAIR_NAME then
		return nil, nil, nil
	end

	for _, model in parent2:GetChildren() do
		if not (model:IsA("Model") and model.Name == frozen.ZIPLINE_ENDPOINT_NAME and model ~= parent) then
			continue
		end

		local primaryPart = model.PrimaryPart

		if primaryPart and primaryPart.Name == frozen.ZIPLINE_PRIMARY_PART_NAME then
			return parent2, primaryPart, _targetEndpoint
		end
	end

	return nil, nil, nil
end

function v.playNpcAnimation(p, p2: string)
	if not Anims:GetRaw(p2) then
		return nil
	end

	local success, result = pcall(function()
		return Anims:Get(p, p2)
	end)

	if not success then
		return nil
	end

	result.Looped = true
	result.Priority = Enum.AnimationPriority.Movement
	result:Play(0.1)
	return result
end

function v.walkNpcToSource(instance, p, p2)
	local pivot = instance:GetPivot()
	local v3 = p2.Position - p.Position
	local v4 = v3 * createVector(1, 0, 1)

	if v3.Magnitude < 1 or v4.Magnitude < 0.01 then
		return false
	end

	local unit = v3.Unit
	local v5 = p.Position - unit * frozen.NPC_STATION_APPROACH_DISTANCE
	local vector2 = Vector3.new(v5.X, pivot.Position.Y, v5.Z)
	local unit2 = v4.Unit
	local cframe = CFrame.lookAt(vector2, vector2 + unit2)
	local v6 = v.playNpcAnimation(instance, frozen.NPC_WALK_ANIMATION)
	local total = 0

	while instance.Parent and total < frozen.NPC_WALK_DURATION do
		total += RunService.RenderStepped:Wait()
		local lerped = pivot:Lerp(
			cframe,
			(TweenService:GetValue(
				math.clamp(total / frozen.NPC_WALK_DURATION, 0, 1),
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut
			))
		)
		instance:PivotTo(lerped)
		instance:SetAttribute("FloorPos", lerped.Position - createVector(0, 1, 0) * frozen.NPC_ROOT_FLOOR_OFFSET)
	end

	if v6 then
		v6:Stop(0.1)
		v6:Destroy()
	end

	return instance.Parent ~= nil
end

function v:startNpcRide(instance, parent, p2, p3)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local v3 = nil

	for _, part in parent:GetChildren() do
		if not (part:IsA("BasePart") and part.Name == frozen.TROLLEY_NAME and part:GetAttribute(frozen.TROLLEY_TEMPLATE_ATTRIBUTE) == true) then
			continue
		end

		if not (part:GetAttribute(frozen.RIDE_TROLLEY_ATTRIBUTE) ~= true and part:GetAttribute(frozen.NPC_TROLLEY_ATTRIBUTE) ~= true) then
			continue
		end

		v3 = part
		break
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and v3) then
		return nil
	end

	local clone = v3:Clone()
	clone.Name = frozen.TROLLEY_NAME
	clone:SetAttribute(frozen.NPC_TROLLEY_ATTRIBUTE, true)
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Parent = parent
	local attachment = clone:FindFirstChild(frozen.ROPE_POINT_NAME)

	if not (attachment and attachment:IsA("Attachment")) then
		clone:Destroy()
		return nil
	end

	local v5 = p3.Position - p2.Position

	if v5.Magnitude < 1 then
		clone:Destroy()
		return nil
	end

	local unit = v5.Unit
	local v6 = p2.Position + unit * frozen.ENDPOINT_PADDING
	local v7 = p3.Position - unit * frozen.ENDPOINT_PADDING
	local v8 = v7 - v6
	local rotation = clone.CFrame.Rotation
	local vectorToWorldSpace = rotation:VectorToWorldSpace(attachment.Position)
	local cFrame = CFrame.new(v6 - vectorToWorldSpace) * rotation
	local v10 = CFrame.new(v7 - vectorToWorldSpace) * rotation
	local v11 = math.max(v8.Magnitude / frozen.RIDE_SPEED, frozen.MINIMUM_RIDE_DURATION)
	local weldConstraint = Instance.new("WeldConstraint")
	local anchored = humanoidRootPart.Anchored
	local maid = Maid.new()
	clone.CFrame = cFrame
	humanoidRootPart.Anchored = false
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local v12 = attachment.WorldPosition + frozen.RIDER_OFFSET
	humanoidRootPart.CFrame = CFrame.lookAt(v12, v12 + unit, clone.CFrame.UpVector)
	weldConstraint.Name = frozen.RIDE_WELD_NAME
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = humanoidRootPart
	weldConstraint:SetAttribute(frozen.RIDE_START_CFRAME_ATTRIBUTE, cFrame)
	weldConstraint:SetAttribute(frozen.RIDE_TARGET_CFRAME_ATTRIBUTE, v10)
	weldConstraint:SetAttribute(frozen.RIDE_START_TIME_ATTRIBUTE, workspace:GetServerTimeNow())
	weldConstraint:SetAttribute(frozen.RIDE_DURATION_ATTRIBUTE, v11)
	weldConstraint.Parent = humanoidRootPart
	instance:AddTag(frozen.RIDER_TAG)
	maid:GiveTask(function()
		instance:RemoveTag(frozen.RIDER_TAG)

		if weldConstraint.Parent then
			weldConstraint:Destroy()
		end

		if humanoidRootPart.Parent then
			humanoidRootPart.Anchored = anchored
		end

		clone:Destroy()
	end)
	self._maid._npcRide = maid
	return v11
end

function v.waitForDialogue(p, p2)
	while p.Parent and p2 and DialogueController.getActiveDialogue() == p2 do
		RunService.Heartbeat:Wait()
	end

	return p.Parent ~= nil
end

function v:runNpcDeparture()
	local _npc = self._npc
	local npcRideParts, v3, v4 = v.getNpcRideParts(self)

	if not (_npc and _npc.Parent and npcRideParts and v3 and v4) then
		v.removeNpc(self)
		return
	end

	self._departing = true
	v.updateNpcInteraction(self)
	local v5 = v.showNpcDialogue(self, frozen.NPC_SUCCESS_TEXT, nil, nil, false)

	if not v.waitForDialogue(_npc, v5) then
		return
	end

	if not v.walkNpcToSource(_npc, v3, v4) then
		v.removeNpc(self)
		return
	end

	local lastTime = os.clock()
	local v6 = v.startNpcRide(self, _npc, npcRideParts, v3, v4)

	if not v6 then
		v.removeNpc(self)
		return
	end

	task.wait(frozen.NPC_RIDE_DIALOGUE_DELAY)
	v.showNpcDialogue(self, frozen.NPC_RIDE_TEXT, nil, nil, false)

	while _npc.Parent and os.clock() - lastTime < v6 do
		RunService.Heartbeat:Wait()
	end

	self._maid._npcRide = nil
	v.removeNpc(self, true)
end

function v:flashDestination(p2)
	local parent = p2.Parent

	if not (parent and parent:IsA("Model")) then
		return
	end

	self._maid._destinationFlash = nil
	local maid = Maid.new()
	self._maid._destinationFlash = maid
	local highlight = Instance.new("Highlight")
	highlight.Name = frozen.FLASH_NAME
	highlight.Adornee = parent
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = frozen.FLASH_COLOR
	highlight.OutlineColor = frozen.FLASH_COLOR
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = parent
	maid:GiveTask(highlight)
	local tweenInfo = TweenInfo.new(frozen.FLASH_FADE_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 0.25,
		OutlineTransparency = 0
	})
	local tween2 = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	maid:GiveTask(tween)
	maid:GiveTask(tween2)
	maid:GiveTask(task.spawn(function()
		tween:Play()
		tween.Completed:Wait()
		task.wait(frozen.FLASH_HOLD_DURATION)
		tween2:Play()
		tween2.Completed:Wait()
		task.defer(function()
			if self._maid._destinationFlash == maid then
				self._maid._destinationFlash = nil
			end
		end)
	end))
end

function v:getOppositeEndpoint(part)
	local _sourceEndpoint = self._sourceEndpoint
	local _targetEndpoint = self._targetEndpoint
	local position

	if _sourceEndpoint and _sourceEndpoint.Parent then
		position = _sourceEndpoint.Position
	else
		position = self._sourcePosition
	end

	local position2

	if _targetEndpoint and _targetEndpoint.Parent then
		position2 = _targetEndpoint.Position
	else
		position2 = self._targetPosition
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if position and position2 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		if (humanoidRootPart.Position - position).Magnitude <= (humanoidRootPart.Position - position2).Magnitude then
			if not (_targetEndpoint and _targetEndpoint.Parent) then
				_targetEndpoint = nil
			end

			return _targetEndpoint, position2
		else
			if not (_sourceEndpoint and _sourceEndpoint.Parent) then
				_sourceEndpoint = nil
			end

			return _sourceEndpoint, position
		end
	elseif typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent then
		return part, part.Position
	else
		return nil, nil
	end
end

function v:showThrowFeedback(p2, p3)
	if self._completed then
		return
	end

	if p2 == frozen.FEEDBACK_BELOW_NPC then
		local _npc = self._npc
		local showFeedbackDialogue = v.showFeedbackDialogue
		local BELOW_NPC_TEXT

		if frozen.NPC_ENABLED then
			BELOW_NPC_TEXT = frozen.BELOW_NPC_TEXT
		else
			BELOW_NPC_TEXT = frozen.INTERNAL_BELOW_NPC_TEXT
		end

		local v3

		if frozen.NPC_ENABLED and _npc and _npc.Parent then
			v3 = _npc:GetPivot().Position
		end

		showFeedbackDialogue(self, BELOW_NPC_TEXT, v3)
	else
		if p2 ~= frozen.FEEDBACK_WRONG_AREA then
			return
		end

		local oppositeEndpoint, v3 = v.getOppositeEndpoint(self, p3)

		if oppositeEndpoint then
			v.flashDestination(self, oppositeEndpoint)
		end

		local showFeedbackDialogue = v.showFeedbackDialogue
		local v4

		if frozen.NPC_ENABLED then
			v4 = frozen.WRONG_AREA_TEXT
		else
			v4 = frozen.INTERNAL_WRONG_AREA_TEXT
		end

		showFeedbackDialogue(self, v4, v3)
	end
end

function v.createPrompt(parent)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = frozen.PICKUP_ACTION
	proximityPrompt.ObjectText = frozen.PICKUP_OBJECT
	proximityPrompt.MaxActivationDistance = frozen.PROMPT_RANGE
	proximityPrompt.HoldDuration = frozen.PROMPT_HOLD_DURATION
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = parent
	return proximityPrompt
end

function v.preparePickup(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end
end

function v.createPickup(object, state)
	if state._completed or state._ownsTool or not state._pickupCFrame or state._pickupLoading or state._pickupModel then
		return
	end

	state._pickupLoading = true
	local v3 = FX:Get(frozen.ASSET_FOLDER_NAME)
	local model

	if v3 then
		model = v3:FindFirstChild(frozen.PICKUP_ASSET_NAME)
	end

	state._pickupLoading = false

	if state._completed or state._ownsTool or state._pickupModel or not (model and model:IsA("Model")) then
		return
	end

	local clone = model:Clone()
	local part = clone:FindFirstChild(frozen.PICKUP_INTERACTION_PART_NAME, true)

	if not (part and part:IsA("BasePart")) then
		clone:Destroy()
		return
	end

	v.preparePickup(clone)
	local prompt = v.createPrompt(part)
	prompt.Triggered:Connect(function()
		if state._completed or state._ownsTool then
			return
		end

		if BonusMomentInteraction.isTransformed(object.Player.Character) then
			BonusMomentInteraction.notifyTransformed()
			return
		end

		prompt.Enabled = false
		object:FireServer("PickupTool")
		task.delay(frozen.PROMPT_RETRY_DELAY, function()
			if prompt.Parent and not (state._completed or state._ownsTool) then
				prompt.Enabled = true
			end
		end)
	end)
	clone.Parent = workspace
	state._pickupModel = clone
end

function v.refresh(p, p2)
	if p2._completed or p2._ownsTool then
		v.destroyPickup(p2)
	else
		v.createPickup(p, p2)
	end
end

local ZiplineRepair = {}
ZiplineRepair.DataName = script.Name
ZiplineRepair.Repeatable = false
ZiplineRepair.LoadWhenCompleted = true

function ZiplineRepair.OnLoad(maid)
	local state = v.getState(maid)
	v.setRepaired(maid.Completed)

	if maid.Completed then
		return
	end

	maid:FireServer("Initialize")
	maid:GiveTask(task.spawn(function()
		for _ = 1, frozen.SETUP_RETRY_ATTEMPTS do
			task.wait(frozen.SETUP_RETRY_DELAY)

			if state._completed or state._pickupCFrame and state._sourceEndpoint and state._targetEndpoint then
				break
			else
				maid:FireServer("Initialize")
			end
		end
	end))
end

ZiplineRepair.RemoteEvents = {
	Setup = function(p, pickupCFrame, p2, part, part2, targetPosition, sourcePosition)
		local state = v.getState(p)

		if typeof(pickupCFrame) ~= "CFrame" then
			pickupCFrame = nil
		end

		state._pickupCFrame = pickupCFrame

		if typeof(part2) == "Instance" and part2:IsA("BasePart") then
			state._sourceEndpoint = part2
		elseif not (state._sourceEndpoint and state._sourceEndpoint.Parent) then
			state._sourceEndpoint = nil
		end

		if typeof(part) == "Instance" and part:IsA("BasePart") then
			state._targetEndpoint = part
		elseif not (state._targetEndpoint and state._targetEndpoint.Parent) then
			state._targetEndpoint = nil
		end

		if typeof(sourcePosition) == "Vector3" then
			state._sourcePosition = sourcePosition
		end

		if typeof(targetPosition) == "Vector3" then
			state._targetPosition = targetPosition
		end

		if typeof(p2) == "CFrame" then
			v.createNpc(p, state, p2)
		end

		v.refresh(p, state)
	end,
	ToolState = function(p, p2)
		local state = v.getState(p)
		state._ownsTool = p2 == true
		v.updateNpcInteraction(state)
		v.refresh(p, state)
	end,
	ThrowFeedback = function(p, p2, p3)
		v.showThrowFeedback(v.getState(p), p2, p3)
	end,
	InteractionBlocked = function(_, p)
		if BonusMomentInteraction.isTransformedReason(p) then
			BonusMomentInteraction.notifyTransformed()
		end
	end
}

function ZiplineRepair.OnComplete(p, flag: boolean, flag2: boolean?)
	local state = v.getState(p)
	state._completed = p.Completed or flag
	v.setRepaired(state._completed)
	v.destroyPickup(state)

	if state._completed then
		state._maid._destinationFlash = nil
		v.closeFeedback(state, flag)
		v.updateNpcInteraction(state)

		if frozen.NPC_ENABLED and flag and not flag2 and state._npc then
			v.runNpcDeparture(state)
		else
			v.removeNpc(state)
		end
	end
end

return ZiplineRepair