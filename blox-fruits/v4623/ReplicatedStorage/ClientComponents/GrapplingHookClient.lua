local createVector = vector.create
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local BonusMomentsController = require(ReplicatedStorage.Controllers.BonusMomentsController)
local Component = require(ReplicatedStorage.Modules.Component)
local DialogueController = require(ReplicatedStorage.DialogueController)
local Global = require(ReplicatedStorage.Global)
local LastInput = require(ReplicatedStorage.Modules.LastInput)
local Maid = require(ReplicatedStorage.Util.Maid)
local Anims = require(ReplicatedStorage.Util.Anims)
local AttributeCounter = require(ReplicatedStorage.Util.AttributeCounter)
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local Sound = require(ReplicatedStorage.Util.Sound)
local ThrowController = require(ReplicatedStorage.Controllers.ThrowController)
local Effects = require(ReplicatedStorage.Controllers.ThrowController.Effects)
local Trajectory = require(ReplicatedStorage.Util.Trajectory)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local frozen = table.freeze({
	MOMENT_NAME = "Zipline Repair",
	EQUIPPED_RIG_NAME = "EquippedGrapplingHookRig",
	CHARGE_ANIMATION = "GrapplingHookCharge",
	THROW_ANIMATION = "GrapplingHookThrow",
	RIG_CHARGE_ANIMATION = "GrapplingHookRigSpin",
	RIG_THROW_ANIMATION = "GrapplingHookRigThrow",
	RIG_CHARGE_FULL_WEIGHT = 0.99,
	RIG_IDLE_IK_PRIORITY = 100,
	HOOK_IDLE_OFFSET = CFrame.Angles(-1.5707963267948966, 0, 0),
	ROPE_PART_NAME = "rope",
	ROPE_FADE_DURATION = 0.35,
	MOVEMENT_COUNTER_NAME = "DisableMovement",
	SOURCE_POSITION_ATTRIBUTE = "SourcePosition",
	TARGET_POSITION_ATTRIBUTE = "TargetPosition",
	AUTO_AIM_RADIUS_PX = 120,
	ANIMATION_RELEASE_DELAY = 0.1,
	FAILURE_DIALOGUE_START_TIMEOUT = 1,
	AIM_PREDICTION_INTERVAL = 0.05,
	AIM_SMOOTHING_SPEED = 24,
	PREVIEW_SIMULATION_FPS = 20,
	RELEASE_SIMULATION_FPS = 30,
	SOUND_GROUP = "JungleBonusMoments",
	SOUND_NAME_TOKENS = table.freeze({ "Grapple", "Zipline" }),
	SPIN_SOUND = "JungleBonusMoments.BF_Jungle_Spin_Grapple_01",
	SPIN_SOUND_FADE_DURATION = 0.1,
	THROW_SOUNDS = table.freeze({
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_01",
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_02",
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_03",
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_04",
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_05",
		"JungleBonusMoments.BF_Jungle_Throw_Grapple_06"
	})
})
local raycastParams = RaycastParams.new()
local v = {
	_soundsPreloadStarted = false
}
local v2 = Component.new({
	Tag = "GrapplingHook",
	Ancestors = { workspace, game:GetService("Players") },
	Extensions = {
		{
			ShouldConstruct = function(p)
				local character = localPlayer.Character
				local isDescendant = p.Instance:IsDescendantOf(localPlayer)

				if not isDescendant then
					if character == nil then
						isDescendant = false
					else
						isDescendant = p.Instance:IsDescendantOf(character)
					end
				end

				return isDescendant
			end
		}
	}
})

function v.preloadThrowAnimations()
	local raws = {}

	for _, v3 in { frozen.THROW_ANIMATION, frozen.RIG_THROW_ANIMATION } do
		local raw = Anims:GetRaw(v3)

		if raw and raw:IsA("Animation") then
			table.insert(raws, raw)
		end
	end

	if #raws == 0 then
		return
	end

	local ContentProvider = game:GetService("ContentProvider")
	local success, result = pcall(ContentProvider.PreloadAsync, ContentProvider, raws)

	if not success then
		warn((`[GrapplingHookClient] Failed to preload throw animations: {result}`))
	end
end

task.spawn(v.preloadThrowAnimations)

function v.preloadSounds()
	if v._soundsPreloadStarted then
		return
	end

	local folder = Sound:Get(frozen.SOUND_GROUP)

	if not folder then
		return
	end

	local sounds = {}

	for _, sound in folder:GetDescendants() do
		if not sound:IsA("Sound") then
			continue
		end

		for _, v4 in frozen.SOUND_NAME_TOKENS do
			if not sound.Name:find(v4, 1, true) then
				continue
			end

			table.insert(sounds, sound)
			break
		end
	end

	if #sounds == 0 then
		return
	end

	v._soundsPreloadStarted = true
	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		local success, result = pcall(ContentProvider.PreloadAsync, ContentProvider, sounds)

		if not success then
			warn((`[GrapplingHookClient] Failed to preload sounds: {result}`))
		end
	end)
end

function v.isThrowInput(p)
	return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch or p.KeyCode == Enum.KeyCode.ButtonR1 or p.KeyCode == Enum.KeyCode.ButtonR2
end

function v.getLocalSoundLocation()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return character
end

function v.isAimLockedToCenter()
	return Global.Shiftlock == true or (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter or LastInput.IsMobile())
end

function v.getAimViewportPosition(p, p2)
	if p and p.UserInputType == Enum.UserInputType.MouseButton1 and not v.isAimLockedToCenter() then
		return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end

	return p2.ViewportSize * 0.5
end

function v.getOppositeZiplinePosition(instance, vector2: Vector3)
	local attribute = instance:GetAttribute(frozen.SOURCE_POSITION_ATTRIBUTE)
	local attribute2 = instance:GetAttribute(frozen.TARGET_POSITION_ATTRIBUTE)

	if typeof(attribute) ~= "Vector3" or typeof(attribute2) ~= "Vector3" then
		return nil
	end

	if (vector2 - attribute).Magnitude <= (vector2 - attribute2).Magnitude then
		return attribute2
	end

	return attribute
end

function v.getAutoAimTarget(p, vector2: Vector3, object, point: Vector2)
	local oppositeZiplinePosition = v.getOppositeZiplinePosition(p, vector2)

	if not oppositeZiplinePosition then
		return nil
	end

	local worldToViewportPoint, v3 = object:WorldToViewportPoint(oppositeZiplinePosition)

	if not v3 or worldToViewportPoint.Z <= 0 or (point - Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)).Magnitude > frozen.AUTO_AIM_RADIUS_PX then
		return nil
	end

	return oppositeZiplinePosition
end

function v.applyIdleRigPose(data)
	local worldCFrame = data.controllerBone.WorldCFrame
	local v3 = CFrame.new(data.controllerTarget.WorldPosition) * worldCFrame.Rotation
	data.controllerBone.Transform = worldCFrame:Inverse() * v3
	local v4 = data.hookTarget.WorldCFrame * frozen.HOOK_IDLE_OFFSET
	data.hookBone.Transform = (v3 * data.hookBone.CFrame):Inverse() * v4
end

function v:getAim(p2, p3: number)
	local character = localPlayer.Character
	local currentCamera = workspace.CurrentCamera
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not character or self.Instance.Parent ~= character or not (currentCamera and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil, nil, false
	end

	local _currentInput = self._currentInput
	local aimViewportPosition = v.getAimViewportPosition(_currentInput, currentCamera)
	local autoAimTarget = v.getAutoAimTarget(
		self.Instance,
		humanoidRootPart.Position,
		currentCamera,
		aimViewportPosition
	)
	local viewportPointToRay = currentCamera:ViewportPointToRay(aimViewportPosition.X, aimViewportPosition.Y)
	local filterDescendantsInstances = { character }
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")

	if _WorldOrigin then
		table.insert(filterDescendantsInstances, _WorldOrigin)
	end

	for _, v4 in Effects.getIgnoreInstances(p2, humanoidRootPart.Position) do
		table.insert(filterDescendantsInstances, v4)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local position, normal

	if autoAimTarget then
		position = autoAimTarget
	else
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * (p2.MaxRange or ThrowController.MAX_RANGE_RBX),
			raycastParams
		)

		if not raycastResult then
			return nil, nil, false
		end

		position = raycastResult.Position
		normal = raycastResult.Normal
	end

	local v4 = assert(position)
	local arcAim = Trajectory.getArcAim(humanoidRootPart.Position, v4)
	local v5 = Effects.fire(character, nil, p2, arcAim, function() end, p3)

	if v5:isErr() then
		return nil, nil, false
	end

	local unwrapped = v5:unwrap()

	if autoAimTarget then
		local v6

		if unwrapped.Type == "Simulated" and unwrapped.Impact then
			v6 = unwrapped.Impact.Normal
		end

		return arcAim, v6, true
	elseif unwrapped.Type == "Simulated" and unwrapped.Impact then
		return
			Trajectory.getArcAim(humanoidRootPart.Position, unwrapped.Impact.Position),
			unwrapped.Impact.Normal,
			false
	else
		return arcAim, normal, false
	end
end

function v2:Construct()
	v.preloadSounds()
	self._maid = Maid.new()
	self._equipMaid = nil
	self._equippedRig = nil
	self._equippedRigVisible = true
	self._equippedRopeTransparency = 1
	self._idleRigPose = nil
	self._idleRigPoseScheduledFor = nil
	self._inputMaid = nil
	self._throwMaid = nil
	self._aimController = nil
	self._aimData = nil
	self._currentInput = nil
	self._equipped = false
	self._throwing = false
	self._requestPending = false
end

function v2:getEquippedRig()
	local character = localPlayer.Character
	local model = character and character:FindFirstChild(frozen.EQUIPPED_RIG_NAME)

	if model and model:IsA("Model") then
		return model
	end

	local _equippedRig = self._equippedRig

	if _equippedRig and _equippedRig.Parent then
		return _equippedRig
	end

	return nil
end

function v2:findEquippedRig(maid)
	local character = localPlayer.Character

	if not character or self.Instance.Parent ~= character then
		return nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyPartTransparency(part)
		if part:IsA("BasePart") then
			local firstAncestor = part:FindFirstAncestor(frozen.EQUIPPED_RIG_NAME)

			if firstAncestor and firstAncestor.Parent == character then
				self:applyEquippedRigPartTransparency(part)
			end
		end

		self:scheduleIdleRigPose(maid)
	end

	maid:GiveTask(character.DescendantAdded:Connect(applyPartTransparency))

	for _, descendant in character:GetDescendants() do
		applyPartTransparency(descendant) -- equivalent call inferred; original call site unknown
	end

	local model = character:FindFirstChild(frozen.EQUIPPED_RIG_NAME) or character:WaitForChild(
		frozen.EQUIPPED_RIG_NAME,
		5
	)

	if self._equipMaid ~= maid or not (model and model:IsA("Model")) then
		return nil
	end

	self._equippedRig = model
	maid:GiveTask(function()
		if self._equippedRig == model then
			self._equippedRig = nil
		end
	end)
	return model
end

function v2:applyEquippedRigPartTransparency(instance)
	local firstAncestor = instance:FindFirstAncestor(frozen.EQUIPPED_RIG_NAME)
	local _idleRigPose = self._idleRigPose
	local localTransparencyModifier = (not self._equippedRigVisible or not firstAncestor or not _idleRigPose or _idleRigPose.rig ~= firstAncestor) and 1 or instance.Name ~= frozen.ROPE_PART_NAME and 0 or self._equippedRopeTransparency

	if instance.Name ~= frozen.ROPE_PART_NAME then
		instance.LocalTransparencyModifier = localTransparencyModifier
		return
	end

	instance.LocalTransparencyModifier = localTransparencyModifier
	instance.Transparency = localTransparencyModifier < 1 and 0 or 1
end

function v2:scheduleIdleRigPose(idleRigPoseScheduledFor)
	if self._idleRigPoseScheduledFor == idleRigPoseScheduledFor then
		return
	end

	self._idleRigPoseScheduledFor = idleRigPoseScheduledFor
	task.defer(function()
		if self._idleRigPoseScheduledFor == idleRigPoseScheduledFor then
			self._idleRigPoseScheduledFor = nil
		end

		if self._equipMaid == idleRigPoseScheduledFor and self.Instance.Parent == localPlayer.Character then
			self:createIdleRigPose(idleRigPoseScheduledFor)
		end
	end)
end

function v2:createIdleRigPose(p)
	local character = localPlayer.Character
	local folder = self:getEquippedRig()
	local _idleRigPose = self._idleRigPose

	if folder and _idleRigPose and _idleRigPose.rig == folder then
		return true
	end

	local rightHand = character and character:FindFirstChild("RightHand")
	local rightUpperArm = character and character:FindFirstChild("RightUpperArm")
	local leftHand = character and character:FindFirstChild("LeftHand")
	local animationController = folder and folder:FindFirstChildWhichIsA("AnimationController", true)
	local controller = folder and folder:FindFirstChild("Controller", true)
	local hook = folder and folder:FindFirstChild("Hook", true)
	local rope9 = folder and folder:FindFirstChild("Rope9", true)

	if not (folder and rightHand and rightHand:IsA("BasePart") and rightUpperArm and rightUpperArm:IsA("BasePart") and leftHand and leftHand:IsA("BasePart") and animationController and controller and controller:IsA("Bone") and hook and hook:IsA("Bone") and rope9 and rope9:IsA("Bone")) then
		return false
	end

	local maid = Maid.new()
	local attachment = Instance.new("Attachment")
	attachment.Name = "GrapplingHookRightHandTarget"
	attachment.Parent = rightHand
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "GrapplingHookRightUpperArmTarget"
	attachment2.Position = Vector3.new(0, rightUpperArm.Size.Y / 2, 0)
	attachment2.Parent = rightUpperArm
	local attachment3 = Instance.new("Attachment")
	attachment3.Name = "GrapplingHookLeftHandTarget"
	attachment3.Parent = leftHand
	local iKControl = Instance.new("IKControl")
	iKControl.Name = "GrapplingHookRopeIK"
	iKControl.Type = Enum.IKControlType.Position
	iKControl.ChainRoot = controller
	iKControl.EndEffector = rope9
	iKControl.Target = attachment3
	iKControl.Priority = frozen.RIG_IDLE_IK_PRIORITY
	iKControl.SmoothTime = 0
	iKControl.Weight = 1
	iKControl.Parent = animationController
	local transformsByBone = {}

	for _, bone in folder:GetDescendants() do
		if bone:IsA("Bone") then
			transformsByBone[bone] = bone.Transform
		end
	end

	local idleRigPose = {
		boneTransforms = transformsByBone,
		controllerBone = controller,
		controllerTarget = attachment2,
		enabled = false,
		hookBone = hook,
		hookTarget = attachment,
		ikControl = iKControl,
		rig = folder
	}
	p._idleRigMaid = maid
	self._idleRigPose = idleRigPose
	maid:GiveTask(attachment)
	maid:GiveTask(attachment2)
	maid:GiveTask(attachment3)
	maid:GiveTask(iKControl)
	maid:GiveTask(RunService.PreSimulation:Connect(function()
		if idleRigPose.enabled and controller.Parent and attachment2.Parent and hook.Parent and attachment.Parent then
			v.applyIdleRigPose(idleRigPose)
		end
	end))
	maid:GiveTask(function()
		if self._idleRigPose == idleRigPose then
			self._idleRigPose = nil
		end
	end)

	if self._equipped and not (self._throwing or self._currentInput or self._requestPending) then
		self:setIdleRigPoseEnabled(true)
	end

	self:setEquippedRigVisible(self._equippedRigVisible)
	return true
end

function v2:setIdleRigPoseEnabled(flag: boolean)
	local _idleRigPose = self._idleRigPose

	if not _idleRigPose then
		return
	end

	_idleRigPose.enabled = false
	_idleRigPose.ikControl.Enabled = false

	for k, boneTransform in _idleRigPose.boneTransforms do
		if k.Parent then
			k.Transform = boneTransform
		end
	end

	if not flag then
		return
	end

	self:setEquippedRopeTransparency(1)
	_idleRigPose.enabled = true
	_idleRigPose.ikControl.Enabled = true
	v.applyIdleRigPose(_idleRigPose)
end

function v2:loadAnimationTrack(animator, p: string, looped: boolean)
	local raw = Anims:GetRaw(p)

	if not (raw and raw:IsA("Animation")) then
		return nil
	end

	local track = animator:LoadAnimation(raw)
	track.Looped = looped
	track:Play()
	return track
end

function v2:manageAnimationTracks(maid, list)
	if #list == 0 then
		return
	end

	maid:GiveTask(function()
		for _, v3 in list do
			if v3.IsPlaying then
				v3:Stop()
			end
		end
	end)
end

function v2:playPlayerAnimation(p: string, flag: boolean)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if self.Instance.Parent == character and animator then
		return self:loadAnimationTrack(animator, p, flag)
	end

	return nil
end

function v2:playEquippedRigAnimation(p: string, flag: boolean)
	local equippedRig = self:getEquippedRig()
	local animationController = equippedRig and equippedRig:FindFirstChildWhichIsA("AnimationController", true)
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if equippedRig and equippedRig.Parent and animator then
		return self:loadAnimationTrack(animator, p, flag)
	end

	return nil
end

function v2:setEquippedRopeTransparency(equippedRopeTransparency: number, duration: number?, maid)
	self._equippedRopeTransparency = equippedRopeTransparency
	local equippedRig = self:getEquippedRig()
	local part = equippedRig and equippedRig:FindFirstChild(frozen.ROPE_PART_NAME, true)

	if not (part and part:IsA("BasePart")) then
		return
	end

	local _idleRigPose = self._idleRigPose
	local localTransparencyModifier = (not self._equippedRigVisible or not _idleRigPose or _idleRigPose.rig ~= equippedRig) and 1 or equippedRopeTransparency

	if localTransparencyModifier >= 1 then
		part.LocalTransparencyModifier = 1
		part.Transparency = 1
	else
		part.LocalTransparencyModifier = duration and duration > 0 and 1 or localTransparencyModifier
		part.Transparency = 0

		if not duration or duration <= 0 then
			return
		end

		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(
			part,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				LocalTransparencyModifier = localTransparencyModifier
			}
		)

		if maid then
			maid:GiveTask(tween)
		end

		tween:Play()
	end
end

function v2:setEquippedRigVisible(equippedRigVisible: boolean)
	self._equippedRigVisible = equippedRigVisible
	local folder = self:getEquippedRig()

	if not folder then
		return
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			self:applyEquippedRigPartTransparency(part)
		end
	end
end

function v2:addChargeMovementLock(maid)
	local character = localPlayer.Character

	if not character or self.Instance.Parent ~= character then
		return false
	end

	maid:GiveTask(AttributeCounter.destroyable(character, frozen.MOVEMENT_COUNTER_NAME))
	return true
end

function v2:faceAimTarget()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local _aimData = self._aimData

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local position = humanoidRootPart.Position
	local vector2

	if _aimData then
		local target = _aimData.Target
		vector2 = Vector3.new(target.X - position.X, 0, target.Z - position.Z)
	else
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local aimViewportPosition = v.getAimViewportPosition(self._currentInput, currentCamera)
		local viewportPointToRay = currentCamera:ViewportPointToRay(aimViewportPosition.X, aimViewportPosition.Y)
		local v3 = viewportPointToRay.Origin + viewportPointToRay.Direction * ThrowController.MAX_RANGE_RBX
		vector2 = Vector3.new(v3.X - position.X, 0, v3.Z - position.Z)
	end

	if vector2.Magnitude <= 0.001 then
		return
	end

	humanoidRootPart.CFrame = CFrame.lookAt(position, position + vector2.Unit, createVector(0, 1, 0))
end

function v2:revealEquippedRopeWhenChargeReady(maid, data)
	self:setEquippedRopeTransparency(1)

	if not data then
		return
	end

	local preSimulationConnection = nil
	preSimulationConnection = RunService.PreSimulation:Connect(function()
		if self._inputMaid ~= maid or not data.IsPlaying or data.WeightTarget < frozen.RIG_CHARGE_FULL_WEIGHT or data.WeightCurrent < frozen.RIG_CHARGE_FULL_WEIGHT then
			return
		end

		if preSimulationConnection then
			preSimulationConnection:Disconnect()
			preSimulationConnection = nil
		end

		self:setEquippedRopeTransparency(0, frozen.ROPE_FADE_DURATION, maid)
	end)
	maid:GiveTask(preSimulationConnection)
end

function v2:isDialogueActive()
	return DialogueController.getActiveDialogue() ~= nil
end

function v2:finishThrow(p)
	if self._throwMaid ~= p then
		return
	end

	self._throwMaid = nil
	self._throwing = false
	self._requestPending = false

	if self._equipped and self.Instance.Parent == localPlayer.Character then
		self:setEquippedRopeTransparency(1)
		self:setEquippedRigVisible(true)
		self:setIdleRigPoseEnabled(true)
	end

	local _maid = self._maid
	task.defer(function()
		if _maid and _maid._throwMaid == p then
			_maid._throwMaid = nil
		end

		if _maid and self._maid == _maid and not self._equipped and not self._requestPending and self.Instance.Parent == localPlayer.Character then
			self:startEquipped()
		end
	end)
end

function v2:finishFailedThrowAfterDialogue(p)
	local lastTime = os.clock()

	while self._throwMaid == p and not self:isDialogueActive() and os.clock() - lastTime < frozen.FAILURE_DIALOGUE_START_TIMEOUT do
		RunService.Heartbeat:Wait()
	end

	while self._throwMaid == p and self:isDialogueActive() do
		RunService.Heartbeat:Wait()
	end

	if self._throwMaid == p then
		self:finishThrow(p)
	end
end

function v2:cancelThrow()
	local _throwMaid = self._throwMaid
	self._throwMaid = nil
	self._throwing = false
	self._requestPending = false

	if not _throwMaid then
		return
	end

	local _maid = self._maid

	if _maid and _maid._throwMaid == _throwMaid then
		_maid._throwMaid = nil
	else
		_throwMaid:Destroy()
	end
end

function v2:clearAim()
	self._aimData = nil
	local _aimController = self._aimController

	if _aimController then
		_aimController:Update(nil, nil)
	end
end

function v2:startEquipped()
	self:stopEquipped()

	if self._requestPending then
		return
	end

	local config = ThrowController.readConfig(self.Instance)

	if config:isErr() then
		local unwrapErr = config:unwrapErr()
		warn((`[GrapplingHookClient] {unwrapErr.Type}: {unwrapErr.Message}`))
	else
		local maid = Maid.new()
		local unwrapped = config:unwrap()
		local aim = Effects.aim(unwrapped, nil)
		local v3 = nil
		local v4 = nil
		local v5 = false
		local target = nil
		local v6 = nil
		local v7 = 0
		self._equipMaid = maid
		self._aimController = aim
		self._equipped = true
		maid:GiveTask(aim)
		self:setEquippedRopeTransparency(1)
		self:setEquippedRigVisible(true)
		self:findEquippedRig(maid)

		if self._equipMaid ~= maid or self.Instance.Parent ~= localPlayer.Character then
			maid:Destroy()
			return
		end

		self:createIdleRigPose(maid)
		maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
			local dialogueActive = self:isDialogueActive()

			if dialogueActive and self._currentInput then
				self:cancelChargeInput()
			end

			if dialogueActive or not self._currentInput then
				v3 = nil
				v4 = nil
				v5 = false
				target = nil
				v6 = nil
				self:clearAim()
			else
				local now = os.clock()

				if v7 <= now then
					v7 = now + frozen.AIM_PREDICTION_INTERVAL
					v3, v4, v5 = v.getAim(self, unwrapped, frozen.PREVIEW_SIMULATION_FPS)

					if v3 and (v5 or not target) then
						target = v3.Target
					end

					if v4 and (v5 or not v6) then
						v6 = v4
					end
				end

				if v3 and target then
					if v5 then
						target = v3.Target
						v6 = v4
					else
						local v8 = 1 - math.exp(-frozen.AIM_SMOOTHING_SPEED * dt)
						target = target:Lerp(v3.Target, v8)

						if v4 then
							local v9

							if v6 then
								v9 = v6:Lerp(v4, v8)
							else
								v9 = v4
							end

							local v10

							if v9.Magnitude > 0.001 then
								v10 = v9.Unit
							else
								v10 = v4
							end

							v6 = v10
						end
					end

					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
					local aimData

					if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						aimData = Trajectory.getArcAim(humanoidRootPart.Position, target)
					else
						aimData = v3
					end

					self._aimData = aimData
					aim:Update(aimData, v6)
				else
					target = nil
					v6 = nil
					self:clearAim()
				end
			end
		end))
		local _maid = self._maid

		if _maid then
			_maid._equipMaid = maid
		end
	end
end

function v2:cancelChargeInput()
	local _inputMaid = self._inputMaid
	local _maid = self._maid
	self._inputMaid = nil
	self._currentInput = nil
	self:clearAim()

	if _inputMaid and _maid and _maid._inputMaid == _inputMaid then
		_maid._inputMaid = nil
	elseif _inputMaid then
		_inputMaid:Destroy()
	end

	if self._equipped and not (self._throwing or self._requestPending) then
		self:setIdleRigPoseEnabled(true)
	end
end

function v2:stopEquipped()
	self:cancelChargeInput()

	if not self._requestPending then
		self:cancelThrow()
	end

	local _equipMaid = self._equipMaid
	local _maid = self._maid

	if _maid and _maid._equipMaid == _equipMaid then
		_maid._equipMaid = nil
	elseif _equipMaid then
		_equipMaid:Destroy()
	end

	self._equipMaid = nil
	self._aimController = nil
	self._aimData = nil
	self._equipped = false
end

function v2:startInput(currentInput)
	if self._currentInput or self._throwing or not self._equipped or self:isDialogueActive() then
		return
	end

	if BonusMomentInteraction.isTransformed(localPlayer.Character) then
		BonusMomentInteraction.notifyTransformed()
		return
	end

	local _maid = self._maid

	if not _maid then
		return
	end

	local maid = Maid.new()
	local character = localPlayer.Character
	local v3, v4

	if character then
		v3, v4 = BonusMomentInteraction.acquireBusy(character)
	else
		v4 = "Busy"
	end

	if v3 then
		maid:GiveTask(v3)

		if not self:addChargeMovementLock(maid) then
			maid:Destroy()
			return
		end

		self:faceAimTarget()
		local v5 = self:playPlayerAnimation(frozen.CHARGE_ANIMATION, true)

		if not v5 then
			maid:Destroy()
			return
		end

		self:setIdleRigPoseEnabled(false)
		local v6 = self:playEquippedRigAnimation(frozen.RIG_CHARGE_ANIMATION, true)
		local v7 = { v5 }

		if v6 then
			table.insert(v7, v6)
		end

		self._inputMaid = maid
		self._currentInput = currentInput
		local v8 = Sound:Play(frozen.SPIN_SOUND, v.getLocalSoundLocation())
		maid:GiveTask(function()
			Sound:FadeOut(v8, frozen.SPIN_SOUND_FADE_DURATION)
		end)
		maid:GiveTask(RunService.RenderStepped:Connect(function()
			if self._inputMaid == maid and self._currentInput == currentInput then
				self:faceAimTarget()
			end
		end))
		self:revealEquippedRopeWhenChargeReady(maid, v6)
		self:manageAnimationTracks(maid, v7)
		maid:GiveTask(currentInput.Changed:Connect(function()
			if currentInput.UserInputState == Enum.UserInputState.End then
				self:release()
			end
		end))
		_maid._inputMaid = maid
	else
		if BonusMomentInteraction.isTransformedReason(v4) then
			BonusMomentInteraction.notifyTransformed()
		end

		maid:Destroy()
	end
end

function v2:release()
	if self:isDialogueActive() then
		self:cancelChargeInput()
	elseif BonusMomentInteraction.isTransformed(localPlayer.Character) then
		self:cancelChargeInput()
		BonusMomentInteraction.notifyTransformed()
	else
		local _inputMaid = self._inputMaid
		local config = ThrowController.readConfig(self.Instance)
		local aim

		if config:isOk() then
			aim = select(1, v.getAim(self, config:unwrap(), frozen.RELEASE_SIMULATION_FPS))
		else
			aim = nil
		end

		self._currentInput = nil
		self._inputMaid = nil
		self:clearAim()
		local _maid = self._maid

		if _inputMaid and _maid and _maid._inputMaid == _inputMaid then
			_maid._inputMaid = nil
		elseif _inputMaid then
			_inputMaid:Destroy()
		end

		if not aim or self._throwing or config:isErr() or not _maid then
			self:setIdleRigPoseEnabled(true)
			return
		end

		local maid = Maid.new()
		local character = localPlayer.Character
		local v4, v5

		if character then
			v4, v5 = BonusMomentInteraction.acquireBusy(character)
		else
			v5 = "Busy"
		end

		if v4 then
			maid:GiveTask(v4)
			self._throwMaid = maid
			_maid._throwMaid = maid
			self._throwing = true
			self:setIdleRigPoseEnabled(false)
			self:setEquippedRigVisible(false)
			self:playPlayerAnimation(frozen.THROW_ANIMATION, false)
			local v6 = self:playEquippedRigAnimation(frozen.RIG_THROW_ANIMATION, false)

			if v6 then
				self:manageAnimationTracks(maid, { v6 })
			end

			maid:GiveTask(function()
				if self._throwMaid == maid then
					self:finishThrow(maid)
				end
			end)
			maid:GiveTask(task.delay(frozen.ANIMATION_RELEASE_DELAY, function()
				local character2 = localPlayer.Character

				if self._throwMaid ~= maid or not character2 or self.Instance.Parent ~= character2 or self:isDialogueActive() then
					self:finishThrow(maid)
					return
				end

				local v7 = {
					Aim = aim,
					Throwable = config:unwrap(),
					Thrower = localPlayer,
					Type = "ThrowData",
					UID = 0,
					Tags = 0
				}
				local HttpService = game:GetService("HttpService")
				v7.UID = HttpService:GenerateGUID(false)
				v7.Tags = {}
				self:setEquippedRigVisible(false)
				Sound:Play(frozen.THROW_SOUNDS[math.random(1, #frozen.THROW_SOUNDS)], v.getLocalSoundLocation())
				local v8 = ThrowController:Throw(v7, function(p, p2)
					if self._throwMaid ~= maid or self.Instance.Parent ~= localPlayer.Character or self:isDialogueActive() then
						return {
							Type = "Unauthorized",
							Message = "Grappling Hook is unavailable during dialogue"
						}
					end

					local v9 = BonusMomentsController:GetLoadedMoments()[frozen.MOMENT_NAME]

					if not v9 then
						return {
							Type = "Unauthorized",
							Message = "Zipline Repair is not active"
						}
					end

					self._requestPending = true
					return v9:InvokeServer("Throw", p, p2)
				end):await()

				if self._throwMaid == maid and v8:isErr() then
					local unwrapErr = v8:unwrapErr()
					warn((`[GrapplingHookClient] {unwrapErr.Type}: {unwrapErr.Message}`))

					if BonusMomentInteraction.isTransformedReason(unwrapErr.Message) then
						BonusMomentInteraction.notifyTransformed()
					end

					self:finishFailedThrowAfterDialogue(maid)
				end
			end))
		else
			if BonusMomentInteraction.isTransformedReason(v5) then
				BonusMomentInteraction.notifyTransformed()
			end

			self:setIdleRigPoseEnabled(true)
		end
	end
end

function v2:Start()
	local instance = self.Instance
	local _maid = self._maid

	if not (_maid and instance:IsA("Tool")) then
		return
	end

	_maid:GiveTask(instance.Equipped:Connect(function()
		self:startEquipped()
	end))
	_maid:GiveTask(instance.Unequipped:Connect(function()
		self:stopEquipped()
	end))
	_maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and v.isThrowInput(input) and instance.Parent == localPlayer.Character then
			self:startInput(input)
		end
	end))

	if instance.Parent == localPlayer.Character then
		self:startEquipped()
	end
end

function v2:Stop()
	self:stopEquipped()
	self:cancelThrow()
	local _maid = self._maid

	if _maid then
		_maid:Destroy()
	end

	self._maid = nil
	self._throwing = false
end

return v2