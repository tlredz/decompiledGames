local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local monsterModules = ReplicatedStorage:WaitForChild("MonsterModules")
local TwistedSquirmConfig = require(monsterModules:WaitForChild("TwistedSquirmConfig"))
local SoundGroupManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Audio"):WaitForChild("SoundGroupManager"))
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
local TwistedSquirmGrabHandler = require(monsterModules:WaitForChild("TwistedSquirmGrabHandler"))
local module = nil
local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local character = sharedModules and sharedModules:FindFirstChild("Character")
local researchHandler = character and character:FindFirstChild("ResearchHandler")
local module2

if researchHandler then
	module2 = require(researchHandler)
else
	module2 = nil
end

local sharedUtils = ReplicatedStorage:FindFirstChild("SharedUtils")
local actionEvent = sharedUtils and sharedUtils:FindFirstChild("ActionEvent")

if actionEvent then
	module = require(actionEvent)
end

local v = {
	IDLE = Color3.fromRGB(200, 200, 200),
	ALERT = Color3.fromRGB(255, 150, 0),
	DESCENDING = Color3.fromRGB(255, 255, 100),
	STRIKE = Color3.fromRGB(255, 100, 100),
	HOLDING = Color3.fromRGB(255, 50, 50),
	RECOIL = Color3.fromRGB(100, 100, 255),
	RELOCATING = Color3.fromRGB(200, 100, 255)
}

local function getNibbleEvent()
	if not RunService:IsServer() then
		return nil
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return nil
	end

	local v2 = events:FindFirstChild("SquirmBookshelfNibble")

	if not v2 then
		v2 = Instance.new("RemoteEvent")
		v2.Name = "SquirmBookshelfNibble"
		v2.Parent = events
	end

	return v2
end

local function getChewDustEvent()
	if not RunService:IsServer() then
		return nil
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return nil
	end

	local v2 = events:FindFirstChild("SquirmChewDust")

	if not v2 then
		v2 = Instance.new("RemoteEvent")
		v2.Name = "SquirmChewDust"
		v2.Parent = events
	end

	return v2
end

local v2 = {
	"rbxassetid://82761841004688",
	"rbxassetid://132527910432050",
	"rbxassetid://127607908952032",
	"rbxassetid://115164005258143"
}

local function playChewSound(part)
	if not (part and part:IsA("BasePart")) then
		return
	end

	local v3 = Audio:Play("Sounds.Twisted.Squirm.Chew", {
		Volume = 0.75,
		RollOffMaxDistance = 60,
		RollOffMode = Enum.RollOffMode.LinearSquare,
		Parent = part
	})

	if v3 then
		SoundGroupManager.AssignSFXSound(v3)
	end
end

local function chewNextSection(folder, rootPart)
	if not RunService:IsServer() then
		return false
	end

	local descendants = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("Texture") or descendant:IsA("Decal")) or descendant:GetAttribute("SquirmChewed") then
			continue
		end

		table.insert(descendants, descendant)
	end

	if #descendants == 0 then
		return false
	end

	local v3 = descendants[math.random(1, #descendants)]
	local texture = v2[math.random(1, #v2)]
	local parent = v3.Parent
	v3.Parent = nil
	v3.Texture = texture
	v3.Parent = parent
	v3:SetAttribute("SquirmChewed", true)
	local parent2 = v3.Parent

	if parent2 and parent2:IsA("BasePart") then
		local chewDustEvent = getChewDustEvent()

		if chewDustEvent then
			chewDustEvent:FireAllClients(parent2)
		end

		playChewSound(rootPart or parent2)
	end

	return true
end

local function springTo(p, p2, p3, p4, p5, p6)
	local v3 = (p3 + (p2 - p) * p4 * p6) * (1 - p5 * p6)
	return p + v3 * p6, v3
end

local v3 = nil

local function getSimpleZone()
	if v3 then
		return v3
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local simpleZone = modules and modules:FindFirstChild("SimpleZone")

	if simpleZone then
		local module3 = require(simpleZone)
		v3 = module3
	end

	return v3
end

local function interruptMachineExtraction(player)
	if not player then
		return
	end

	local character2 = player.Character

	if not character2 then
		return
	end

	local decoding = character2:FindFirstChild("Decoding")

	if not (decoding and decoding.Value) then
		return
	end

	local value = decoding.Value

	if value and value.Parent and value:FindFirstChild("Stats") then
		local forceStop = value.Stats:FindFirstChild("ForceStop")

		if forceStop then
			local v4

			if typeof(player) == "Instance" then
				v4 = player:IsA("Player")
			else
				v4 = false
			end

			forceStop:Fire(v4 and player or {
				Name = player.Name,
				Character = character2
			})
			local events = ReplicatedStorage:FindFirstChild("Events")
			local stopInteracting = events and events:FindFirstChild("StopInteracting")

			if stopInteracting and v4 then
				stopInteracting:FireClient(player)
			end
		end

		if not character2:FindFirstChild("NoDecode") then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "NoDecode"
			boolValue.Value = true
			boolValue.Parent = character2
			Debris:AddItem(boolValue, 1)
		end
	else
		decoding.Value = nil
	end
end

local TwistedSquirmController = {}
local v4 = {}
local v5 = 0
local count = 0
local v6 = {}
local raycastParams = nil
RunService.Heartbeat:Connect(function()
	count += 1
end)

local function getObstaclePartsAndParams()
	if v5 == count then
		return v6, raycastParams
	end

	local result = {}

	for _, tag in ipairs(TwistedSquirmConfig.LOS_BLOCKING_TAGS) do
		for _, v7 in ipairs(CollectionService:GetTagged(tag)) do
			table.insert(result, v7)
		end
	end

	if not raycastParams then
		raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.IgnoreWater = true
	end

	raycastParams.FilterDescendantsInstances = result
	v6 = result
	v5 = count
	return result, raycastParams
end

local v7 = {}

function v7.new(instance)
	local v8 = {
		monster = instance,
		animator = nil,
		loadedTracks = {},
		currentTrack = nil
	}
	local animationController = instance:FindFirstChildOfClass("AnimationController")

	if animationController then
		v8.animator = animationController:FindFirstChild("Animator")

		if not v8.animator then
			v8.animator = Instance.new("Animator")
			v8.animator.Parent = animationController
		end
	else
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid then
			v8.animator = humanoid:FindFirstChildOfClass("Animator")

			if not v8.animator then
				v8.animator = Instance.new("Animator")
				v8.animator.Parent = humanoid
			end
		else
			warn("[TwistedSquirm] No AnimationController or Humanoid found in monster!")
		end
	end

	setmetatable(v8, {
		__index = v7
	})
	return v8
end

function v7:LoadAnimation(p2, animationId)
	if not self.animator or (not animationId or animationId == "rbxassetid://0") then
		return nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result = pcall(function()
		return self.animator:LoadAnimation(animation)
	end)

	if success and result then
		self.loadedTracks[p2] = result
		return result
	end

	warn("[TwistedSquirm] Failed to load animation:", p2, animationId)
	return nil
end

function v7:Play(currentTrackName, p, p2, p3)
	local loadedTrack = self.loadedTracks[currentTrackName]

	if not loadedTrack then
		warn("[TwistedSquirm ANIM] Animation not found:", currentTrackName)
		return nil
	end

	local v8 = p or TwistedSquirmConfig.ANIMATION.BLEND_TIME
	local _ = self.currentTrackName or "none"
	local _ = self.currentTrack and self.currentTrack.IsPlaying

	if self.currentTrack and self.currentTrack ~= loadedTrack then
		self.currentTrack:Stop(v8)
	end

	loadedTrack.Priority = p2 or Enum.AnimationPriority.Action
	loadedTrack.Looped = p3 or false
	loadedTrack:Play(v8)
	self.currentTrack = loadedTrack
	self.currentTrackName = currentTrackName
	return loadedTrack
end

function v7:Stop(p, p2)
	local loadedTrack = self.loadedTracks[p]

	if loadedTrack then
		local v8 = p2 or TwistedSquirmConfig.ANIMATION.BLEND_TIME
		local _ = loadedTrack.IsPlaying
		loadedTrack:Stop(v8)

		if self.currentTrack == loadedTrack then
			self.currentTrack = nil
			self.currentTrackName = nil
		end
	end
end

function v7:StopAll(p2)
	local v8 = p2 or TwistedSquirmConfig.ANIMATION.BLEND_TIME
	local v9 = {}

	for k, loadedTrack in pairs(self.loadedTracks) do
		if not loadedTrack.IsPlaying then
			continue
		end

		loadedTrack:Stop(v8)
		table.insert(v9, k)
	end

	local _ = #v9 > 0
	self.currentTrack = nil
	self.currentTrackName = nil
end

function v7:Cleanup()
	self:StopAll(0)
	self.loadedTracks = {}
	self.animator = nil
end

local class = {}
class.__index = class

local function computeMaxRopeLength(p, p2, groundZone)
	local Y = p2.Position.Y
	local Y2

	if groundZone then
		Y2 = groundZone.Position.Y
	else
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.FilterDescendantsInstances = { p }
		local raycastResult = workspace:Raycast(p2.Position, createVector(0, -200, 0), raycastParams2)
		Y2 = raycastResult and raycastResult.Position.Y or Y - TwistedSquirmConfig.ROPE.LENGTH_MAX
	end

	return math.max(math.abs(Y - Y2) + 5, TwistedSquirmConfig.ROPE.LENGTH_MAX), Y, Y2
end

function class.new(instance, anchorZone, rope, groundZone)
	local object = setmetatable({}, class)
	object.monster = instance
	object.anchorZone = anchorZone
	object.groundZone = groundZone
	object.rope = rope
	object.id = instance.Name
	object.rootPart = instance:FindFirstChild(TwistedSquirmConfig.PARTS.ROOT)
	object.headPart = instance:FindFirstChild(TwistedSquirmConfig.PARTS.HEAD)
	object.headLookTarget = nil
	object.lastLookSwitchTime = 0
	object.lookSwitchInterval = 3
	object.lastIdleRotationUpdate = 0
	object.idleRotationInterval = 0.05
	object.lastIdleTrackingTarget = nil
	object.lastIdlePositionUpdate = 0
	object.currentTilt = 0
	object.targetTilt = 0
	object.tiltVel = 0
	object.hasLOS = false
	object.currentYaw = 0
	object.targetYaw = 0
	object.yawVel = 0
	object.currentState = TwistedSquirmConfig.STATES.IDLE
	object.previousState = nil
	object.stateStartTime = tick()
	object.targetPlayer = nil
	object.playersInZone = {}
	object.noTargetListeners = {}
	object.lastAttackTime = 0
	object.lastGrabTime = 0
	object.attackRetries = 0
	object.lastStrikeTarget = nil
	object.lastRelocateTime = 0
	object.relocateFailCount = 0
	object.lastTransitionTime = 0
	object.currentBookshelf = nil
	object.headPos = not object.rootPart and createVector(0, 0, 0) or object.rootPart.Position or createVector(0, 0, 0)
	object.headVel = createVector(0, 0, 0)
	object.headLookDir = createVector(0, -1, 0)
	object.lookVel = createVector(0, 0, 0)
	object.currentStiffness = 6
	object.currentDamping = 5
	object.skipSpringThisFrame = false
	local maxRopeLength, _, _ = computeMaxRopeLength(instance, anchorZone, groundZone)
	object.maxRopeLength = maxRopeLength
	object.descentStartTime = nil
	object.currentDescentSpeed = TwistedSquirmConfig.MOVEMENT.DESCEND_SPEED_INITIAL
	object.attackLoopStarted = false
	object.shouldRelocateAfterRecoil = false
	object.lastAlertExitTime = 0
	object.researchGrantedPlayers = {}
	object.researchMonsterId = tostring(os.time() .. "_" .. instance:GetFullName() .. "_" .. math.random(1000, 9999))
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "ChasingValue"
	objectValue.Value = nil
	objectValue.Parent = instance
	object.chasingValue = objectValue
	object.animManager = v7.new(instance)
	object.connections = {}
	object.zonePart = nil
	object.zone = nil
	object.grabHandler = nil
	object.ikControl = nil
	object.ikTargetPart = nil
	object.ikTargetAttachment = nil
	object.ikTargetPos = not object.rootPart and createVector(0, 0, 0) or object.rootPart.Position - createVector(
		0,
		10,
		0
	) or createVector(0, 0, 0)
	object.ikTargetVel = createVector(0, 0, 0)
	object.leftHandIK = nil
	object.rightHandIK = nil
	object.leftHandTarget = nil
	object.rightHandTarget = nil
	object.handIKWeight = 0
	object.handIKTargetWeight = 0
	object.faceNormalSA = nil
	object.faceBlinkSA = nil
	object.faceAttackSA = nil
	object.faceActiveSA = nil
	object.faceBlinkThread = nil
	object.faceIsBlinking = false
	object.faceCurrentState = "normal"
	return object
end

function class:Initialize()
	if self.rootPart then
		self.rootPart.Anchored = true
		self.headPos = self.rootPart.Position
	end

	local part = self.monster:FindFirstChild(TwistedSquirmConfig.PARTS.BASE)

	if part and part:IsA("BasePart") then
		part.Transparency = 1
	end

	local part2 = self.monster:FindFirstChild(TwistedSquirmConfig.PARTS.DRIP)

	if part2 and part2:IsA("BasePart") then
		part2.Transparency = 1
	end

	self:LoadAnimations()

	if TwistedSquirmConfig.IK.ENABLED then
		self:SetupHeadIK()
	end

	if TwistedSquirmConfig.HAND_IK.ENABLED then
		self:SetupHandIK()
	end

	self:CreateDetectionZone()
	self:SpawnIchorDrip()
	self:SetupFace()
	self:SetupGlowingEyes()
	local info = RunService:IsServer() and TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.ENABLED and TwistedSquirmConfig.GLOWING_EYES.BLACKOUT_ONLY and workspace:FindFirstChild("Info")

	if info then
		local blackOut = info:FindFirstChild("BlackOut")

		if blackOut and blackOut:IsA("BoolValue") then
			self:SetGlowingEyesEnabled(blackOut.Value)
			local valueChangedConnection = blackOut:GetPropertyChangedSignal("Value"):Connect(function()
				self:SetGlowingEyesEnabled(blackOut.Value)
			end)
			table.insert(self.connections, valueChangedConnection)
		end
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end)
	table.insert(self.connections, heartbeatConnection)
	local ancestryChangedConnection = self.monster.AncestryChanged:Connect(function(_, parent)
		if not parent then
			self:Cleanup()
		end
	end)
	table.insert(self.connections, ancestryChangedConnection)

	if self.anchorZone then
		self.anchorZone:SetAttribute("OccupiedBySquirm", self.id)
		self.monster:SetAttribute("ClaimedAnchor", self.anchorZone.Name)
	end

	v4[self.id] = self
	self:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
	task.delay(0.5, function()
		if self.currentState == TwistedSquirmConfig.STATES.IDLE then
			self.animManager:Play("IDLE", nil, Enum.AnimationPriority.Idle, true)
		end
	end)
	self:CreateDebugDisplay()
end

function class:LoadAnimations()
	local ANIMATIONS = TwistedSquirmConfig.ANIMATIONS
	self.animManager:LoadAnimation("IDLE", ANIMATIONS.IDLE_HANGING)
	self.animManager:LoadAnimation("ALERT", ANIMATIONS.ALERT)
	self.animManager:LoadAnimation("ALERT_B", ANIMATIONS.ALERT_B)
	self.animManager:LoadAnimation("ALERT_C", ANIMATIONS.ALERT_C)
	self.animManager:LoadAnimation("IDLE_TO_READY", ANIMATIONS.IDLE_TO_READY)
	self.animManager:LoadAnimation("DESCEND", ANIMATIONS.DESCEND)
	self.animManager:LoadAnimation("STRIKE", ANIMATIONS.STRIKE)
	self.animManager:LoadAnimation("ATTACK_START", ANIMATIONS.ATTACK_START)
	self.animManager:LoadAnimation("ATTACK_LOOP", ANIMATIONS.ATTACK_LOOP)
	self.animManager:LoadAnimation("HOLDING", ANIMATIONS.HOLDING)
	self.animManager:LoadAnimation("RETRACT", ANIMATIONS.RETRACT)
	self.animManager:LoadAnimation("LEAVE", ANIMATIONS.LEAVE)
	self.animManager:LoadAnimation("EMERGE", ANIMATIONS.EMERGE)
	self.animManager:LoadAnimation("LOST_INTEREST", ANIMATIONS.LOST_INTEREST)
	self.animManager:LoadAnimation("ALERT_TO_IDLE_A", ANIMATIONS.ALERT_TO_IDLE_A)
	self.animManager:LoadAnimation("ALERT_TO_IDLE_B", ANIMATIONS.ALERT_TO_IDLE_B)
	self.animManager:LoadAnimation("QUIRK", ANIMATIONS.QUIRK)
	self.animManager:LoadAnimation("EATING_BOOKS", ANIMATIONS.EATING_BOOKS)
	self.animManager:LoadAnimation("MUNCH_LEAVE_A", ANIMATIONS.MUNCH_LEAVE_A)
	self.animManager:LoadAnimation("MUNCH_LEAVE_B", ANIMATIONS.MUNCH_LEAVE_B)
end

function class:SetupHeadIK()
	if not TwistedSquirmConfig.IK.ENABLED then
		return
	end

	local animationController = self.monster:FindFirstChildOfClass("AnimationController")

	if not animationController then
		warn("[TwistedSquirm] No AnimationController found for IK setup!")
		return
	end

	if not animationController:FindFirstChildOfClass("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = animationController
	end

	local chest_jnt = self.monster:FindFirstChild("chest_jnt", true)

	if not chest_jnt then
		warn("[TwistedSquirm] No chest_jnt bone found for IK!")
		return
	end

	local root_jnt = self.monster:FindFirstChild("root_jnt", true)

	if not root_jnt then
		warn("[TwistedSquirm] No root_jnt bone found for IK!")
		return
	end

	local part = Instance.new("Part")
	part.Name = "SquirmIKTarget"
	part.Size = createVector(0.5, 0.5, 0.5)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = workspace
	self.ikTargetPart = part
	local attachment = Instance.new("Attachment")
	attachment.Name = "IKTargetAttachment"
	attachment.Parent = part
	self.ikTargetAttachment = attachment
	local v8 = self.headPos - createVector(0, 10, 0)
	part.Position = v8
	self.ikTargetPos = v8
	self.ikTargetVel = createVector(0, 0, 0)
	local iKControl = Instance.new("IKControl")
	iKControl.Name = "HeadLookIK"
	local lookAt = TwistedSquirmConfig.IK.LOOK_AT_TYPE == 1 and Enum.IKControlType.LookAt or Enum.IKControlType.Position
	iKControl.Type = lookAt
	iKControl.EndEffector = chest_jnt
	iKControl.Target = attachment
	iKControl.ChainRoot = root_jnt
	iKControl.Weight = TwistedSquirmConfig.IK.WEIGHT
	iKControl.SmoothTime = TwistedSquirmConfig.IK.SMOOTH_TIME
	iKControl.Parent = animationController
	self.ikControl = iKControl

	if lookAt == Enum.IKControlType.Position then
	end
end

function class:SetupHandIK()
	local animationController = self.monster:FindFirstChildOfClass("AnimationController")

	if not animationController then
		warn("[TwistedSquirm] No AnimationController found for hand IK setup!")
		return
	end

	if not animationController:FindFirstChildOfClass("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = animationController
	end

	local endEffector = nil
	local endEffector2 = nil
	local chainRoot = nil
	local chainRoot2 = nil

	for _, bone in ipairs(self.monster:GetDescendants()) do
		if not bone:IsA("Bone") then
			continue
		end

		if bone.Name == "L_hand_jnt" then
			endEffector = bone
		elseif bone.Name == "R_hand_jnt" then
			endEffector2 = bone
		elseif bone.Name == "L_arm_jnt" then
			chainRoot = bone
		elseif bone.Name == "R_arm_jnt" then
			chainRoot2 = bone
		end
	end

	if not (endEffector and endEffector2) then
		warn("[TwistedSquirm] Could not find hand bones for IK! L:", endEffector, "R:", endEffector2)
		return
	end

	if not (chainRoot and chainRoot2) then
		warn("[TwistedSquirm] Could not find arm bones for IK chain! L:", chainRoot, "R:", chainRoot2)
		return
	end

	local iKControl = Instance.new("IKControl")
	iKControl.Name = "LeftHandGrabIK"
	iKControl.Type = Enum.IKControlType.Position
	iKControl.EndEffector = endEffector
	iKControl.ChainRoot = chainRoot
	iKControl.Weight = 0
	iKControl.SmoothTime = 0.15
	iKControl.Parent = animationController
	self.leftHandIK = iKControl
	local iKControl2 = Instance.new("IKControl")
	iKControl2.Name = "RightHandGrabIK"
	iKControl2.Type = Enum.IKControlType.Position
	iKControl2.EndEffector = endEffector2
	iKControl2.ChainRoot = chainRoot2
	iKControl2.Weight = 0
	iKControl2.SmoothTime = 0.15
	iKControl2.Parent = animationController
	self.rightHandIK = iKControl2
end

function class:AttachHandTargets(parent)
	self:DetachHandTargets()
	local HAND_IK = TwistedSquirmConfig.HAND_IK
	local v8

	if HAND_IK.CHARACTER_OVERRIDES and parent.Parent then
		local config = parent.Parent:FindFirstChild("Config")
		local moduleName = config and config:FindFirstChild("ModuleName")
		local value = moduleName and moduleName.Value or parent.Parent.Name
		v8 = HAND_IK.CHARACTER_OVERRIDES[value]
	end

	if v8 and v8.disabled then
		return
	end

	local leftHand = v8 and v8.leftHand or HAND_IK.LEFT_HAND_OFFSET or createVector(1, 1.2, 0)
	local rightHand = v8 and v8.rightHand or HAND_IK.RIGHT_HAND_OFFSET or createVector(-1, 1.2, 0)
	local leftPole = v8 and v8.leftPole or HAND_IK.LEFT_POLE_OFFSET or createVector(2, 0, 3.5)
	local rightPole = v8 and v8.rightPole or HAND_IK.RIGHT_POLE_OFFSET or createVector(-2, 0, 3.5)
	local attachment = Instance.new("Attachment")
	attachment.Name = "SquirmGrabLeft"
	attachment.Position = leftHand
	attachment.Parent = parent
	self.leftHandTarget = attachment
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "SquirmGrabRight"
	attachment2.Position = rightHand
	attachment2.Parent = parent
	self.rightHandTarget = attachment2
	local attachment3 = Instance.new("Attachment")
	attachment3.Name = "SquirmPoleLeft"
	attachment3.Position = leftPole
	attachment3.Parent = parent
	self.leftPole = attachment3
	local attachment4 = Instance.new("Attachment")
	attachment4.Name = "SquirmPoleRight"
	attachment4.Position = rightPole
	attachment4.Parent = parent
	self.rightPole = attachment4

	if self.leftHandIK then
		self.leftHandIK.Target = attachment
		self.leftHandIK.Pole = attachment3
	end

	if self.rightHandIK then
		self.rightHandIK.Target = attachment2
		self.rightHandIK.Pole = attachment4
	end
end

function class:DetachHandTargets()
	if self.leftHandTarget then
		if self.leftHandIK then
			self.leftHandIK.Target = nil
			self.leftHandIK.Pole = nil
		end

		self.leftHandTarget:Destroy()
		self.leftHandTarget = nil
	end

	if self.rightHandTarget then
		if self.rightHandIK then
			self.rightHandIK.Target = nil
			self.rightHandIK.Pole = nil
		end

		self.rightHandTarget:Destroy()
		self.rightHandTarget = nil
	end

	if self.leftPole then
		self.leftPole:Destroy()
		self.leftPole = nil
	end

	if self.rightPole then
		self.rightPole:Destroy()
		self.rightPole = nil
	end

	if self.debugVisualizers then
		for _, debugVisualizer in ipairs(self.debugVisualizers) do
			if debugVisualizer and debugVisualizer.Parent then
				debugVisualizer:Destroy()
			end
		end

		self.debugVisualizers = nil
	end
end

function class:VisualizeIKTargets()
	if self.debugVisualizers then
		for _, debugVisualizer in ipairs(self.debugVisualizers) do
			if debugVisualizer and debugVisualizer.Parent then
				debugVisualizer:Destroy()
			end
		end
	end

	self.debugVisualizers = {}

	local function createMarker(p, color, p2)
		if not (p2 and p2.Parent) then
			return
		end

		local part = Instance.new("Part")
		part.Name = p .. "_IKDebug"
		part.Size = createVector(0.4, 0.4, 0.4)
		part.Shape = Enum.PartType.Ball
		part.Color = color
		part.Material = Enum.Material.Neon
		part.Transparency = 0.3
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = false
		part.Massless = true
		part.Parent = workspace
		table.insert(self.debugVisualizers, part)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = p2.Parent
		weldConstraint.Part1 = part
		part.CFrame = CFrame.new(p2.WorldPosition)
		weldConstraint.Parent = part
		return part
	end

	if self.leftPole then
		createMarker("LeftPole", Color3.fromRGB(255, 0, 0), self.leftPole)
	end

	if self.rightPole then
		createMarker("RightPole", Color3.fromRGB(0, 0, 255), self.rightPole)
	end

	if self.leftHandTarget then
		createMarker("LeftTarget", Color3.fromRGB(255, 255, 0), self.leftHandTarget)
	end

	if self.rightHandTarget then
		createMarker("RightTarget", Color3.fromRGB(0, 255, 255), self.rightHandTarget)
	end
end

function class:CreateDebugDisplay()
	if not TwistedSquirmConfig.DEBUG.SHOW_STATE or self.debugBillboard then
		return
	end

	local headPart = self.headPart or self.rootPart

	if not headPart then
		warn("[TwistedSquirm]", self.id, "No head/root part for debug billboard")
		return
	end

	local squirmDebugDisplay = headPart:FindFirstChild("SquirmDebugDisplay")

	if squirmDebugDisplay then
		warn("[TwistedSquirm]", self.id, "Found orphaned SquirmDebugDisplay, removing it")
		squirmDebugDisplay:Destroy()
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "SquirmDebugDisplay"
	billboardGui.Size = UDim2.new(4, 0, 2.5, 0)
	billboardGui.StudsOffset = createVector(0, 2, 0)
	billboardGui.AlwaysOnTop = false
	billboardGui.MaxDistance = 100
	billboardGui.Parent = headPart
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 2
	frame.Parent = billboardGui
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "State"
	textLabel.Size = UDim2.new(1, 0, 0.18, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.Text = "State: IDLE"
	textLabel.TextSize = 28
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Target"
	textLabel2.Size = UDim2.new(1, 0, 0.18, 0)
	textLabel2.Position = UDim2.new(0, 0, 0.2, 0)
	textLabel2.Text = "Target: None"
	textLabel2.TextSize = 22
	textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.SourceSans
	textLabel2.TextStrokeTransparency = 0.5
	textLabel2.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Distance"
	textLabel3.Size = UDim2.new(1, 0, 0.18, 0)
	textLabel3.Position = UDim2.new(0, 0, 0.4, 0)
	textLabel3.Text = "Distance: --"
	textLabel3.TextSize = 20
	textLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel3.BackgroundTransparency = 1
	textLabel3.Font = Enum.Font.SourceSans
	textLabel3.TextStrokeTransparency = 0.5
	textLabel3.Parent = frame
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.Name = "Animation"
	textLabel4.Size = UDim2.new(1, 0, 0.18, 0)
	textLabel4.Position = UDim2.new(0, 0, 0.6, 0)
	textLabel4.Text = "Anim: None"
	textLabel4.TextSize = 20
	textLabel4.TextColor3 = Color3.fromRGB(150, 255, 150)
	textLabel4.BackgroundTransparency = 1
	textLabel4.Font = Enum.Font.SourceSans
	textLabel4.TextStrokeTransparency = 0.5
	textLabel4.Parent = frame
	local textLabel5 = Instance.new("TextLabel")
	textLabel5.Name = "IKWeight"
	textLabel5.Size = UDim2.new(1, 0, 0.18, 0)
	textLabel5.Position = UDim2.new(0, 0, 0.8, 0)
	textLabel5.Text = "Hand IK: 0.0"
	textLabel5.TextSize = 18
	textLabel5.TextColor3 = Color3.fromRGB(200, 200, 255)
	textLabel5.BackgroundTransparency = 1
	textLabel5.Font = Enum.Font.SourceSans
	textLabel5.TextStrokeTransparency = 0.5
	textLabel5.Parent = frame
	self.debugBillboard = {
		gui = billboardGui,
		labels = {
			state = textLabel,
			target = textLabel2,
			distance = textLabel3,
			animation = textLabel4,
			ikWeight = textLabel5
		}
	}
end

function class:UpdateDebugDisplay()
	if TwistedSquirmConfig.DEBUG.SHOW_STATE then
		if not self.debugBillboard then
			self:CreateDebugDisplay()

			if not self.debugBillboard then
				return
			end
		end

		local labels = self.debugBillboard.labels
		local text = "State: " .. tostring(self.currentState)
		labels.state.Text = text
		labels.state.TextColor3 = v[self.currentState] or Color3.fromRGB(255, 255, 255)
		local v9

		if self.animManager and self.animManager.currentTrackName then
			local currentTrackName = self.animManager.currentTrackName
			local v10

			if self.animManager.currentTrack and self.animManager.currentTrack.Animation then
				local animationId = self.animManager.currentTrack.Animation.AnimationId
				v10 = animationId:match("rbxassetid://(%d+)") or animationId
			else
				v10 = "?"
			end

			v9 = string.format("%s (%s)", currentTrackName, v10)
		else
			v9 = "None"
		end

		labels.animation.Text = "Anim: " .. v9

		if self.targetPlayer then
			labels.target.Text = "Target: " .. tostring(self.targetPlayer.Name)

			if self.targetPlayer.Character and self.targetPlayer.Character:FindFirstChild("HumanoidRootPart") and self.rootPart then
				local magnitude = (self.targetPlayer.Character.HumanoidRootPart.Position - self.rootPart.Position).Magnitude
				labels.distance.Text = string.format("Distance: %.1f studs", magnitude)
			else
				labels.distance.Text = "Distance: --"
			end
		else
			labels.target.Text = "Target: None"
			labels.distance.Text = "Distance: --"
		end

		labels.ikWeight.Text = string.format("Hand IK: %.2f", self.handIKWeight or 0)
	elseif self.debugBillboard and self.debugBillboard.gui then
		self.debugBillboard.gui:Destroy()
		self.debugBillboard = nil
	end
end

function class:UpdateHandIK(p)
	local v8 = TwistedSquirmConfig

	if not (v8.HAND_IK.ENABLED and (self.leftHandIK and self.rightHandIK)) then
		return
	end

	local v9

	if self.handIKTargetWeight > self.handIKWeight then
		v9 = 1 / (v8.HAND_IK.FADE_IN_TIME or 0.2)
	else
		v9 = 1 / (v8.HAND_IK.FADE_OUT_TIME or 0.15)
	end

	self.handIKWeight += (self.handIKTargetWeight - self.handIKWeight) * math.min(1, v9 * p)
	local weight = v8.HAND_IK.WEIGHT * self.handIKWeight
	self.leftHandIK.Weight = weight
	self.rightHandIK.Weight = weight
end

function class:CreateDetectionZone()
	if not v3 then
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local simpleZone = modules and modules:FindFirstChild("SimpleZone")

		if simpleZone then
			local module3 = require(simpleZone)
			v3 = module3
		end
	end

	local v8 = v3

	if not v8 then
		warn("[TwistedSquirm] SimpleZone not found! Detection disabled.")
		return
	end

	local position = self.anchorZone.Position
	local Y

	if self.groundZone then
		Y = self.groundZone.Position.Y
	else
		local raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.FilterDescendantsInstances = { self.monster }
		local raycastResult = workspace:Raycast(position, createVector(0, -200, 0), raycastParams2)

		if raycastResult then
			Y = raycastResult.Position.Y
		else
			Y = position.Y + TwistedSquirmConfig.ZONE.OFFSET_Y - TwistedSquirmConfig.ZONE.SIZE.Y / 2
		end

		warn("[TwistedSquirm] No ground TriggerZone, used raycast for floor detection")
	end

	local v9 = math.abs(position.Y - Y)
	local v10 = v9 + 10
	local v11 = position.Y - v9 / 2
	local SIZE = TwistedSquirmConfig.ZONE.SIZE
	local vector2 = Vector3.new(SIZE.X, math.max(v10, SIZE.Y), SIZE.Z)
	local vector3 = Vector3.new(position.X, v11, position.Z)
	local part = Instance.new("Part")
	part.Name = "SquirmDetectionZone"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = TwistedSquirmConfig.DEBUG.SHOW_ZONE and 0.5 or 1
	part.Color = Color3.fromRGB(255, 100, 100)
	part.Size = vector2
	part.Position = vector3
	part.Parent = workspace
	self.zonePart = part
	local queryOptions = v8.QueryOptions.new()
	queryOptions.FireMode = "Both"
	local zone = v8.fromPart(part, queryOptions)
	zone:BindToHeartbeat()

	local function resolvePlayer(instance)
		if instance:IsA("Player") then
			return instance
		end

		local v13 = instance:IsA("Model") and instance or instance.Parent
		return TwistedSquirmGrabHandler.ResolveGrabKey(v13)
	end

	local itemEnteredConnection = zone.ItemEntered:Connect(function(instance)
		if not instance:IsA("Player") then
			local v13 = instance:IsA("Model") and instance or instance.Parent
			instance = TwistedSquirmGrabHandler.ResolveGrabKey(v13)
		end

		if instance then
			self:OnPlayerEntered(instance)
		end
	end)
	table.insert(self.connections, itemEnteredConnection)
	local itemExitedConnection = zone.ItemExited:Connect(function(instance)
		if not instance:IsA("Player") then
			local v13 = instance:IsA("Model") and instance or instance.Parent
			instance = TwistedSquirmGrabHandler.ResolveGrabKey(v13)
		end

		if instance then
			self:OnPlayerExited(instance)
		end
	end)
	table.insert(self.connections, itemExitedConnection)
	self.zone = zone
end

function class:SpawnIchorDrip()
	local ICHOR_DRIP = TwistedSquirmConfig.ICHOR_DRIP

	if not ICHOR_DRIP.ENABLED then
		return
	end

	if not self.anchorZone then
		warn("[TwistedSquirm] No anchor zone for ichor drip")
		return
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")

	if not parts then
		return
	end

	local child = parts:FindFirstChild(ICHOR_DRIP.FOLDER_NAME)

	if not child then
		warn("[TwistedSquirm] Ichor puddle ceiling folder not found:", ICHOR_DRIP.FOLDER_NAME)
		return
	end

	local children = {}

	for _, child2 in ipairs(child:GetChildren()) do
		if child2.Name:match(ICHOR_DRIP.MODEL_PATTERN) then
			table.insert(children, child2)
		end
	end

	if #children == 0 then
		warn("[TwistedSquirm] No puddle models found matching pattern:", ICHOR_DRIP.MODEL_PATTERN)
		return
	end

	local clone = children[math.random(1, #children)]:Clone()
	local v8 = self.anchorZone.Position - createVector(0, 0.1, 0)
	local cFrame = self.anchorZone.CFrame

	if clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(cFrame + (v8 - cFrame.Position))
	else
		clone:PivotTo(cFrame + (v8 - cFrame.Position))
	end

	local CollectionService2 = game:GetService("CollectionService")
	CollectionService2:AddTag(clone, "Ceiling")
	local model = workspace.CurrentRoom and workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local parent = model:FindFirstChild("SquirmVisuals")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "SquirmVisuals"
			parent.Parent = model
		end

		clone.Parent = parent
		local animationController = clone:FindFirstChildOfClass("AnimationController", true)

		if animationController then
			local idleAnimation = clone:FindFirstChild("IdleAnimation", true) or clone:FindFirstChild("Idle", true)

			if idleAnimation and idleAnimation:IsA("Animation") then
				local animator = animationController:FindFirstChild("Animator")

				if not animator then
					task.wait(0.1)
					animator = animationController:FindFirstChild("Animator")
				end

				if animator then
					local track = animator:LoadAnimation(idleAnimation)
					track.Looped = true
					track:Play()
				end
			end
		end

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			elseif descendant:IsA("BasePart") then
				descendant.CanCollide = false
				descendant.CanTouch = false

				if descendant:IsA("MeshPart") and (descendant.Name == "IchorPuddleTop" or descendant.Name:match("^Ichor")) then
					descendant.Transparency = 0
				else
					descendant.Transparency = 1
				end
			end
		end

		self.ichorDrip = clone
	else
		clone:Destroy()
		warn("[TwistedSquirm] No current room to parent ichor drip")
	end
end

function class:SetupGlowingEyes()
	local GLOWING_EYES = TwistedSquirmConfig.GLOWING_EYES

	if not GLOWING_EYES then
		warn("[TwistedSquirm] GLOWING_EYES config not found - skipping glowing eyes setup")
		return
	end

	if not GLOWING_EYES.ENABLED then
		return
	end

	if not self.headPart then
		warn("[TwistedSquirm] Head part not found - cannot setup glowing eyes")
		return
	end

	self.headSurface = self.headPart:FindFirstChildOfClass("SurfaceAppearance")

	if not self.headSurface then
		warn("[TwistedSquirm] No SurfaceAppearance found on Head mesh - cannot setup glowing eyes")
		return
	end

	self.headSurface.EmissiveStrength = 0
	local child = self.monster:FindFirstChild(TwistedSquirmConfig.PARTS.GLOWING_EYES)

	if child then
		self.glowingEyesLight = child:FindFirstChildOfClass("PointLight", true)

		if self.glowingEyesLight then
			self.glowingEyesLight.Enabled = false
			self.glowingEyesLight.Brightness = GLOWING_EYES.BRIGHTNESS
			self.glowingEyesLight.Range = GLOWING_EYES.RANGE
			self.glowingEyesLight.Color = GLOWING_EYES.COLOR
		end
	end
end

function class:SetGlowingEyesEnabled(flag)
	local GLOWING_EYES = TwistedSquirmConfig.GLOWING_EYES

	if not self.headSurface then
		return
	end

	if not (GLOWING_EYES and GLOWING_EYES.ENABLED) then
		flag = false
	end

	local _ = self.glowingEyesEnabled ~= flag
	self.glowingEyesEnabled = flag

	if flag then
		if not (GLOWING_EYES and GLOWING_EYES.DISTANCE_TWEEN_ENABLED) then
			self.headSurface.EmissiveStrength = 30
		end
	else
		self.headSurface.EmissiveStrength = 0
	end

	if self.glowingEyesLight then
		self.glowingEyesLight.Enabled = flag
	end
end

function class:RefreshGlowingEyes()
	local GLOWING_EYES = TwistedSquirmConfig.GLOWING_EYES

	if not (GLOWING_EYES and self.headSurface) then
		return
	end

	local v8

	if GLOWING_EYES.ENABLED then
		if GLOWING_EYES.BLACKOUT_ONLY then
			local info = workspace:FindFirstChild("Info")
			local blackOut = info and info:FindFirstChild("BlackOut")
			v8 = blackOut and blackOut.Value == true
		else
			v8 = true
		end
	else
		v8 = false
	end

	if self.glowingEyesEnabled ~= v8 then
		self:SetGlowingEyesEnabled(v8)
	end
end

function class:UpdateGlowingEyesDistance()
	local GLOWING_EYES = TwistedSquirmConfig.GLOWING_EYES

	if not (GLOWING_EYES.ENABLED and GLOWING_EYES.DISTANCE_TWEEN_ENABLED and (self.glowingEyesEnabled and self.headSurface)) then
		return
	end

	local v8

	if GLOWING_EYES.BLACKOUT_ONLY then
		local info = workspace:FindFirstChild("Info")
		local blackOut = info and info:FindFirstChild("BlackOut")
		v8 = blackOut and blackOut.Value == true
	else
		v8 = false
	end

	if v8 then
		self.headSurface.EmissiveStrength = GLOWING_EYES.MAX_EMISSIVE

		if self.glowingEyesLight then
			self.glowingEyesLight.Brightness = GLOWING_EYES.BRIGHTNESS
		end
	else
		local v9 = 1e999

		for k, _ in pairs(self.playersInZone) do
			if not k.Character then
				continue
			end

			local humanoidRootPart = k.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and self.rootPart then
				v9 = math.min(v9, (humanoidRootPart.Position - self.rootPart.Position).Magnitude)
			end
		end

		local v10 = 0

		if GLOWING_EYES.DISTANCE_MAX <= v9 then
			v10 = 1
		elseif GLOWING_EYES.DISTANCE_MIN < v9 then
			v10 = (v9 - GLOWING_EYES.DISTANCE_MIN) / (GLOWING_EYES.DISTANCE_MAX - GLOWING_EYES.DISTANCE_MIN)
		end

		local v11 = GLOWING_EYES.MAX_EMISSIVE * v10
		local v12 = GLOWING_EYES.BRIGHTNESS * v10
		local v13 = math.min(1, 5 / (60 * (GLOWING_EYES.TWEEN_TIME or 0.5)))

		if self.glowingEyesLight then
			local brightness = self.glowingEyesLight.Brightness
			self.glowingEyesLight.Brightness = brightness + (v12 - brightness) * v13
		end

		local emissiveStrength = self.headSurface.EmissiveStrength
		self.headSurface.EmissiveStrength = emissiveStrength + (v11 - emissiveStrength) * v13
	end
end

function class:SetupFace()
	if not self.headPart then
		return
	end

	local config = self.monster:FindFirstChild("Config")
	local v8 = nil
	local faceBlinkSA = nil
	local faceAttackSA = nil

	local function scan(instance)
		if not instance then
			return
		end

		for _, surfaceAppearance in ipairs(instance:GetChildren()) do
			if not surfaceAppearance:IsA("SurfaceAppearance") then
				continue
			end

			local name = surfaceAppearance.Name:lower()

			if name:find("normal") and not v8 then
				v8 = surfaceAppearance
			elseif name:find("blink") and not faceBlinkSA then
				faceBlinkSA = surfaceAppearance
			elseif name:find("attack") and not faceAttackSA then
				faceAttackSA = surfaceAppearance
			end
		end
	end

	scan(self.headPart)
	scan(config)

	if v8 and faceBlinkSA and faceAttackSA then
		self.faceNormalSA = v8
		self.faceBlinkSA = faceBlinkSA
		self.faceAttackSA = faceAttackSA
		self.faceStash = config or self.monster
		v8.EmissiveStrength = 0
		faceBlinkSA.EmissiveStrength = 0
		faceAttackSA.EmissiveStrength = 0
		v8.Parent = self.headPart
		faceBlinkSA.Parent = self.faceStash
		faceAttackSA.Parent = self.faceStash
		self.faceActiveSA = v8
		self.faceCurrentState = "normal"
		self:StartBlinking()
	else
		local names = {}

		local function collect(instance)
			if not instance then
				return
			end

			for _, surfaceAppearance in ipairs(instance:GetChildren()) do
				if surfaceAppearance:IsA("SurfaceAppearance") then
					table.insert(names, surfaceAppearance.Name)
				end
			end
		end

		collect(self.headPart)
		collect(config)
		warn(
			"[TwistedSquirm]",
			self.id,
			"Need 3 SAs (Normal/Blink/Attack) on Head or Config. Found:",
			table.concat(names, ", ")
		)
	end
end

function class:SwapFaceSA(p)
	if not (self.headPart and p and self.faceActiveSA ~= p) then
		return
	end

	local emissiveStrength = not self.faceActiveSA and 0 or self.faceActiveSA.EmissiveStrength or 0

	if not pcall(function()
		p.EmissiveStrength = emissiveStrength
		p.Parent = self.headPart
	end) then
		return
	end

	if self.faceActiveSA then
		pcall(function()
			self.faceActiveSA.Parent = self.faceStash or self.monster
		end)
	end

	self.faceActiveSA = p
	self.headSurface = p
end

function class:SetNormalFace()
	if not self.faceNormalSA then
		return
	end

	if not self.faceIsBlinking and self.faceCurrentState == "normal" then
		self:SwapFaceSA(self.faceNormalSA)
	end
end

function class:SetAttackFace()
	if not self.faceAttackSA then
		return
	end

	if self.faceCurrentState ~= "attack" then
		self:SwapFaceSA(self.faceAttackSA)
		self.faceCurrentState = "attack"
	end
end

function class:StopBlinking()
	if self.faceBlinkThread then
		task.cancel(self.faceBlinkThread)
		self.faceBlinkThread = nil
	end

	if self.faceIsBlinking then
		self.faceIsBlinking = false

		if self.faceCurrentState == "normal" then
			self:SwapFaceSA(self.faceNormalSA)
		end
	end
end

function class:StartBlinking()
	if self.isCleanedUp then
		return
	end

	if self.faceBlinkSA and self.headPart then
		self:StopBlinking()
		self.faceBlinkThread = task.spawn(function()
			while not self.isCleanedUp do
				task.wait(math.random(3, 6))

				if self.faceCurrentState == "attack" then
					continue
				end

				self.faceIsBlinking = true
				self:SwapFaceSA(self.faceBlinkSA)
				task.wait(0.35)
				self.faceIsBlinking = false

				if self.faceCurrentState ~= "attack" then
					self:SwapFaceSA(self.faceNormalSA)
				end
			end
		end)
	end
end

function class:UpdateFaceForState(p)
	if not self.faceNormalSA then
		return
	end

	local STATES = TwistedSquirmConfig.STATES

	if p == STATES.DESCENDING or p == STATES.STRIKE or p == STATES.HOLDING then
		self:StopBlinking()
		self:SetAttackFace()
	else
		if self.faceCurrentState == "attack" then
			task.delay(0.5, function()
				if self.isCleanedUp then
					return
				end

				if self.faceCurrentState == "attack" then
					local currentState = self.currentState

					if currentState ~= STATES.DESCENDING and currentState ~= STATES.STRIKE and currentState ~= STATES.HOLDING then
						self.faceCurrentState = "normal"
						self:SetNormalFace()
						self:StartBlinking()
					end
				end
			end)
			return
		end

		self.faceCurrentState = "normal"
		self:SetNormalFace()

		if not self.faceBlinkThread then
			self:StartBlinking()
		end
	end
end

function class:OnPlayerEntered(targetPlayer)
	if not (targetPlayer and targetPlayer.Character) then
		return
	end

	local character2 = targetPlayer.Character
	local noTarget = character2:FindFirstChild("NoTarget")
	local invincible = character2:FindFirstChild("Invincible")

	if noTarget or invincible then
		if noTarget and not self.noTargetListeners[targetPlayer] then
			local destroyingConnection = noTarget.Destroying:Connect(function()
				local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
				task.defer(function()
					self:OnPlayerEntered(targetPlayer)
				end)
			end)
			self.noTargetListeners[targetPlayer] = destroyingConnection
		end
	else
		if self.noTargetListeners[targetPlayer] then
			self.noTargetListeners[targetPlayer]:Disconnect()
			self.noTargetListeners[targetPlayer] = nil
		end

		self.playersInZone[targetPlayer] = true
		local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
		local STATES = TwistedSquirmConfig.STATES

		if self.currentState == STATES.IDLE then
			if not self:HasLineOfSight(targetPlayer) then
				local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
				return
			end

			self.targetPlayer = targetPlayer
			self:TransitionTo(STATES.ALERT)
		elseif self.currentState ~= STATES.HOLDING then
			local distanceToPlayer = self:GetDistanceToPlayer(targetPlayer)
			local distanceToTarget = self:GetDistanceToTarget()

			if distanceToPlayer < distanceToTarget * 0.5 or distanceToPlayer < distanceToTarget - 5 then
				local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES and not (self.targetPlayer and self.targetPlayer.Name)
				self.targetPlayer = targetPlayer
			end
		end
	end
end

function class:GetDistanceToPlayer(player)
	if not (player and player.Character) then
		return 1e999
	end

	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (humanoidRootPart.Position - self.headPos).Magnitude
	end

	return 1e999
end

function class:OnPlayerExited(p)
	self.playersInZone[p] = nil

	if self.noTargetListeners[p] then
		self.noTargetListeners[p]:Disconnect()
		self.noTargetListeners[p] = nil
	end

	local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
	local v8 = TwistedSquirmConfig

	if self.currentState == v8.STATES.HOLDING or self.currentState == v8.STATES.RELOCATING or self.currentState == v8.STATES.DESCENDING or self.currentState == v8.STATES.STRIKE then
		return
	end

	if self.targetPlayer == p then
		self.targetPlayer = self:FindClosestPlayer()

		if not self.targetPlayer then
			self:TransitionTo(v8.STATES.RECOIL)
		end
	end
end

function class:FindClosestPlayer()
	local headPos = self.headPos
	local v8 = 1e999
	local v9 = nil

	for k, _ in pairs(self.playersInZone) do
		if not (k.Character and k.Character:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local character2 = k.Character

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			continue
		end

		local magnitude = (character2.HumanoidRootPart.Position - headPos).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v9 = k
		v8 = magnitude
	end

	return v9
end

function class:FindClosestPlayerWithLOS()
	local headPos = self.headPos
	local v8 = 1e999
	local v9 = nil

	for k, _ in pairs(self.playersInZone) do
		if not (k.Character and k.Character:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local character2 = k.Character

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			continue
		end

		local magnitude = (character2.HumanoidRootPart.Position - headPos).Magnitude

		if not (magnitude < v8 and self:HasLineOfSight(k)) then
			continue
		end

		v9 = k
		v8 = magnitude
	end

	return v9
end

function class:GetDistanceToTarget()
	if not (self.targetPlayer and self.targetPlayer.Character) then
		return 1e999
	end

	local humanoidRootPart = self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (humanoidRootPart.Position - self.headPos).Magnitude
	end

	return 1e999
end

function class:GetHorizontalDistanceToTarget()
	if not (self.targetPlayer and self.targetPlayer.Character) then
		return 1e999
	end

	local humanoidRootPart = self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return 1e999
	end

	local v8 = humanoidRootPart.Position - self.headPos
	return Vector3.new(v8.X, 0, v8.Z).Magnitude
end

function class:HasLineOfSight(player)
	if not (player and player.Character) then
		return false
	end

	local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and self.headPos) then
		return false
	end

	local headPos = self.headPos
	local v8 = humanoidRootPart.Position - headPos
	local magnitude = v8.Magnitude

	if magnitude < 0.5 then
		return true
	end

	local obstaclePartsAndParams, v9 = getObstaclePartsAndParams()
	return #obstaclePartsAndParams == 0 or not workspace:Raycast(headPos, v8.Unit * magnitude, v9)
end

function class:CheckWallCollision(data)
	local v8 = TwistedSquirmConfig

	if not (v8.WALL_COLLISION and v8.WALL_COLLISION.ENABLED and (self.headPos and data)) then
		return false, nil
	end

	local v9 = data - self.headPos

	if v9.Magnitude < 0.1 then
		return false, nil
	end

	local obstaclePartsAndParams, v10 = getObstaclePartsAndParams()

	if #obstaclePartsAndParams == 0 then
		return false, nil
	end

	local raycastResult = workspace:Raycast(self.headPos, v9, v10)

	if not raycastResult then
		return false, nil
	end

	if v8.DEBUG and v8.DEBUG.LOG_WALL_DETECTION then
		warn(string.format(
			"[TwistedSquirm] %s WALL DETECTED! Current: (%.1f, %.1f, %.1f) → Target: (%.1f, %.1f, %.1f) | Hit: %s at (%.1f, %.1f, %.1f) dist: %.1f",
			self.id,
			self.headPos.X,
			self.headPos.Y,
			self.headPos.Z,
			data.X,
			data.Y,
			data.Z,
			raycastResult.Instance:GetFullName(),
			raycastResult.Position.X,
			raycastResult.Position.Y,
			raycastResult.Position.Z,
			(raycastResult.Position - self.headPos).Magnitude
		))
	end

	return true, raycastResult
end

function class:SetTargetPosition(headTargetPos)
	local v8 = TwistedSquirmConfig

	if self.currentState == v8.STATES.DESCENDING or self.currentState == v8.STATES.STRIKE or self.currentState == v8.STATES.HOLDING then
		local v9, v10 = self:CheckWallCollision(headTargetPos)

		if v9 and v10 then
			local unit = (headTargetPos - self.headPos).Unit
			local v11 = math.max((v10.Position - self.headPos).Magnitude - v8.WALL_COLLISION.SAFE_DISTANCE, 0)
			local headTargetPos2 = self.headPos + unit * v11

			if v8.DEBUG then
				local _ = v8.DEBUG.LOG_WALL_DETECTION
			end

			self.headTargetPos = headTargetPos2
			return
		end
	end

	self.headTargetPos = headTargetPos
end

function class:SetTargetLookDir(data)
	if data.Magnitude > 0.1 then
		self.headTargetLookDir = data.Unit
		local vector2 = Vector3.new(data.X, 0, data.Z)

		if vector2.Magnitude > 0.01 then
			self.targetYaw = math.atan2(vector2.X, vector2.Z)
		end
	end
end

function class:ApplySpringPhysics(p)
	if not self.rootPart then
		return
	end

	if self.headPos ~= self.headPos or self.headVel ~= self.headVel then
		warn("[TwistedSquirm]", self.id, "NaN detected in spring physics - recovering to anchor")

		if self.anchorZone then
			self.headPos = self.anchorZone.Position - Vector3.new(0, TwistedSquirmConfig.ROPE.LENGTH_DEFAULT, 0)
		end

		self.headVel = createVector(0, 0, 0)
	end

	if self.skipSpringThisFrame then
		self.skipSpringThisFrame = false

		if self.anchorZone and self.rope then
			local magnitude = (self.headPos - self.anchorZone.Position).Magnitude

			if self.rope.Attachment0 and self.rope.Attachment1 then
				magnitude = (self.rope.Attachment0.WorldPosition - self.rope.Attachment1.WorldPosition).Magnitude
			end

			local v8 = (TwistedSquirmConfig.ROPE.SLACK_BUFFER or 0.5) * (math.log(1 + magnitude / 10) + 1)
			self.rope.Length = math.max(magnitude + v8, TwistedSquirmConfig.ROPE.LENGTH_MIN)
		end
	else
		if self.headTargetPos then
			local headPos = self.headPos
			local headTargetPos = self.headTargetPos
			local headVel = self.headVel
			local currentStiffness = self.currentStiffness
			local currentDamping = self.currentDamping
			local headVel2 = (headVel + (headTargetPos - headPos) * currentStiffness * p) * (1 - currentDamping * p)
			self.headPos = headPos + headVel2 * p
			self.headVel = headVel2
		end

		if self.anchorZone then
			local position = self.anchorZone.Position
			local v8 = self.headPos - position
			local magnitude = v8.Magnitude
			local maxRopeLength = self.maxRopeLength
			local LENGTH_DEFAULT = TwistedSquirmConfig.ROPE.LENGTH_DEFAULT

			if maxRopeLength < magnitude then
				self.headPos = position + v8.Unit * maxRopeLength
				local unit = v8.Unit
				local dot = self.headVel:Dot(unit)

				if dot > 0 then
					self.headVel -= unit * dot * 0.8
				end
			end

			if self.currentState == TwistedSquirmConfig.STATES.RECOIL and magnitude < LENGTH_DEFAULT then
				self.headPos = position + Vector3.new(0, -LENGTH_DEFAULT, 0)

				if self.headVel.Y > 0 then
					self.headVel = Vector3.new(self.headVel.X, 0, self.headVel.Z)
				end
			end

			if self.rope then
				if self.rope.Attachment0 and self.rope.Attachment1 then
					magnitude = (self.rope.Attachment0.WorldPosition - self.rope.Attachment1.WorldPosition).Magnitude
				end

				local v9 = (TwistedSquirmConfig.ROPE.SLACK_BUFFER or 0.5) * (math.log(1 + magnitude / 10) + 1)
				self.rope.Length = math.max(magnitude + v9, TwistedSquirmConfig.ROPE.LENGTH_MIN)
			end
		end
	end

	local LERP_SPEED = TwistedSquirmConfig.TILT.LERP_SPEED or 4
	self.currentTilt += (self.targetTilt - self.currentTilt) * math.min(p * LERP_SPEED, 1)
	local YAW_LERP_SPEED = TwistedSquirmConfig.SPRING.YAW_LERP_SPEED or 6
	local v8 = (self.targetYaw or 0) + (self.yawOffset or 0) - (self.currentYaw or 0)

	while v8 > 3.141592653589793 do
		v8 -= 6.283185307179586
	end

	while v8 < -3.141592653589793 do
		v8 += 6.283185307179586
	end

	self.currentYaw += v8 * math.min(p * YAW_LERP_SPEED, 1)
	local cframe = CFrame.new(self.headPos)
	local cframe2 = CFrame.Angles(0, self.currentYaw, 0)
	local currentTilt = self.currentTilt
	local cframe3 = CFrame.Angles(3.141592653589793 - currentTilt, 0, 0)
	local cframe4 = CFrame.new()

	if self.currentState == "HOLDING" and TwistedSquirmConfig.GRAB.ATTACHMENT_ROTATION then
		local ATTACHMENT_ROTATION = TwistedSquirmConfig.GRAB.ATTACHMENT_ROTATION
		cframe4 = CFrame.Angles(ATTACHMENT_ROTATION.X, ATTACHMENT_ROTATION.Y, ATTACHMENT_ROTATION.Z)
	end

	self.rootPart.CFrame = cframe * cframe2 * cframe3 * cframe4
end

function class:GetIdleSway(p)
	local MOVEMENT = TwistedSquirmConfig.MOVEMENT
	return (Vector3.new(
		math.sin(p * MOVEMENT.SWAY_FREQUENCY.X) * MOVEMENT.SWAY_AMPLITUDE.X,
		math.sin(p * MOVEMENT.SWAY_FREQUENCY.Y) * MOVEMENT.SWAY_AMPLITUDE.Y,
		math.cos(p * MOVEMENT.SWAY_FREQUENCY.Z) * MOVEMENT.SWAY_AMPLITUDE.Z
	))
end

function class:GetAllPlayersInZone()
	local result = {}

	for k, _ in pairs(self.playersInZone) do
		if not (k and k.Character) then
			continue
		end

		local character2 = k.Character
		local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
		local humanoid = character2:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoid and humanoid.Health > 0) then
			continue
		end

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			continue
		end

		table.insert(result, k)
	end

	return result
end

function class:PickRandomLookTarget()
	local allPlayersInZone = self:GetAllPlayersInZone()

	if #allPlayersInZone == 0 then
		self.headLookTarget = nil
		return nil
	end

	if self.headLookTarget and table.find(allPlayersInZone, self.headLookTarget) and math.random() < 0.6 then
		return self.headLookTarget
	end

	local headLookTarget = allPlayersInZone[math.random(#allPlayersInZone)]

	if #allPlayersInZone > 1 and headLookTarget == self.headLookTarget then
		for _, v10 in ipairs(allPlayersInZone) do
			if v10 == self.headLookTarget then
				continue
			end

			headLookTarget = v10
			break
		end
	end

	self.headLookTarget = headLookTarget
	self.lastLookSwitchTime = tick()
	return headLookTarget
end

function class:FindNearestPlayerGlobal()
	local headPos = self.headPos
	local v8 = 1e999
	local v9 = nil

	for _, v10 in ipairs(Players:GetPlayers()) do
		if not v10.Character then
			continue
		end

		local character2 = v10.Character
		local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
		local humanoid = character2:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoid and humanoid.Health > 0) then
			continue
		end

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			continue
		end

		local magnitude = (humanoidRootPart.Position - headPos).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v9 = v10
		v8 = magnitude
	end

	return v9, v8
end

function class:UpdateHeadTracking(p)
	local STATES = TwistedSquirmConfig.STATES
	local currentState = self.currentState
	local _cachedNearestPlayer = nil

	if currentState == STATES.IDLE or currentState == STATES.ALERT then
		_cachedNearestPlayer = self._cachedNearestPlayer
	elseif currentState == STATES.DESCENDING or currentState == STATES.STRIKE or currentState == STATES.HOLDING then
		_cachedNearestPlayer = self.targetPlayer
	elseif currentState == STATES.RECOIL then
		_cachedNearestPlayer = self._cachedNearestPlayer
	end

	local v8 = nil

	if _cachedNearestPlayer and _cachedNearestPlayer.Character then
		local humanoidRootPart = _cachedNearestPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			v8 = humanoidRootPart.Position + createVector(0, 1.5, 0)
		end
	end

	local v9 = v8 or self.headPos - createVector(0, 15, 0)

	if self.ikTargetPart then
		if currentState == STATES.STRIKE or currentState == STATES.HOLDING or currentState == STATES.DESCENDING then
			self.ikTargetPart.Position = v9
			self.ikTargetPos = v9
			self.ikTargetVel = createVector(0, 0, 0)
		else
			local ikTargetPos = self.ikTargetPos
			local ikTargetVel = (self.ikTargetVel + (v9 - ikTargetPos) * 18 * p) * (1 - 4 * p)
			self.ikTargetPos = ikTargetPos + ikTargetVel * p
			self.ikTargetVel = ikTargetVel
			self.ikTargetPart.Position = self.ikTargetPos
		end
	end

	if self.ikControl then
		local v10

		if currentState == STATES.HOLDING or currentState == STATES.STRIKE then
			self.hasLOS = false
			v10 = 0
		elseif _cachedNearestPlayer and _cachedNearestPlayer.Character then
			if _cachedNearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
				self.hasLOS = true
				local _ = "looking at " .. _cachedNearestPlayer.Name
				v10 = 1
			else
				self.hasLOS = false
				v10 = 0
			end
		else
			self.hasLOS = false
			v10 = 0
		end

		local weight = self.ikControl.Weight
		local weight2 = weight + (v10 - weight) * math.min(1, 5 * p)
		self.ikControl.Weight = weight2

		if TwistedSquirmConfig.DEBUG.LOG_IK then
			self.lastIKLog = self.lastIKLog or 0

			if tick() - self.lastIKLog > 0.5 then
				self.lastIKLog = tick()
			end
		end
	end

	local humanoidRootPart = _cachedNearestPlayer and _cachedNearestPlayer.Character and currentState == STATES.IDLE and _cachedNearestPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local headPos = self.headPos
		local position = humanoidRootPart.Position
		local vector2 = Vector3.new(position.X - headPos.X, -1, position.Z - headPos.Z)

		if vector2.Magnitude > 0.5 then
			self:SetTargetLookDir(vector2)
		end
	end
end

function class.UpdateRopeLength(p, value)
	if not p.rope then
		return
	end

	local length = math.clamp(value, TwistedSquirmConfig.ROPE.LENGTH_MIN, p.maxRopeLength)
	p.rope.Length = length
end

function class.CalculateNeededRopeLength(p)
	if p.anchorZone then
		return (p.anchorZone.Position - p.headPos).Magnitude + 5
	end

	return TwistedSquirmConfig.ROPE.LENGTH_DEFAULT
end

function class:TransitionTo(currentState)
	if self.currentState == currentState then
		return
	end

	local now = tick()

	if currentState ~= TwistedSquirmConfig.STATES.HOLDING and self.currentState ~= TwistedSquirmConfig.STATES.RELOCATING and now - self.lastTransitionTime < 0.5 then
		return
	end

	self.previousState = self.currentState
	local _ = now - (self.stateStartTime or now)
	self.currentState = currentState
	self.stateStartTime = now
	self.lastTransitionTime = now
	self:OnStateExit(self.previousState)
	self:OnStateEnter(currentState)
	self:UpdateFaceForState(currentState)
end

function class:FireSpottedIndicator()
	if not (self.targetPlayer and self.targetPlayer.Character) then
		return
	end

	if self.chasingValue then
		self.chasingValue.Value = self.targetPlayer.Character
	end

	self.targetPlayer:SetAttribute("Spotted", workspace.DistributedGameTime or tick())
	self.targetPlayer:SetAttribute("Alerted", true)
	local storyEvents = ReplicatedStorage:FindFirstChild("StoryEvents")
	local spotted = storyEvents and storyEvents:FindFirstChild("Spotted")

	if spotted and typeof(self.targetPlayer) == "Instance" then
		spotted:FireClient(self.targetPlayer, self.monster)
	end

	interruptMachineExtraction(self.targetPlayer)
end

function class:OnStateEnter(p)
	local STATES = TwistedSquirmConfig.STATES
	local v8 = TwistedSquirmConfig

	if p == STATES.IDLE then
		self.animManager:Play("IDLE", 0.5, Enum.AnimationPriority.Idle, true)

		if self.chasingValue then
			self.chasingValue.Value = nil
		end

		if self.targetPlayer then
			self.targetPlayer:SetAttribute("Spotted", nil)
			self.targetPlayer:SetAttribute("Alerted", false)
		end

		self.targetPlayer = nil
		self.idleEnteredTime = tick()
		self.lastPlayerNearbyTime = tick()
		local v9 = not v8.BOOKSHELF and 15 or v8.BOOKSHELF.IDLE_DELAY or 15
		self.bookshelfTargetDelay = math.random(v9, v9 + 30)
		self.currentBookshelf = nil
		self.bookshelfLookPos = nil
		self.lastChewTime = nil
		self.munchLeaveUntil = nil
		self.lastQuirkTime = tick()
		self.nextQuirkDelay = math.random(8, 15)
		self.lastIdleRelocateCheck = tick()
		local IDLE_RELOCATE_MIN = v8.TIMING.IDLE_RELOCATE_MIN or 45
		local IDLE_RELOCATE_MAX = v8.TIMING.IDLE_RELOCATE_MAX or 90
		self.idleRelocateDelay = math.random(IDLE_RELOCATE_MIN, IDLE_RELOCATE_MAX)
		self.currentStiffness = v8.SPRING.IDLE_STIFFNESS
		self.currentDamping = v8.SPRING.IDLE_DAMPING
		self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_DEFAULT, 0))
		self:SetTargetLookDir(createVector(0, -1, 0))
	elseif p == STATES.ALERT then
		self:FireSpottedIndicator()
		local QUIRK = self.animManager.loadedTracks.QUIRK

		if QUIRK and QUIRK.IsPlaying then
			QUIRK:Stop(0.2)
		end

		local IDLE = self.animManager.loadedTracks.IDLE

		if IDLE then
			IDLE.Priority = Enum.AnimationPriority.Idle
			IDLE.Looped = true

			if not IDLE.IsPlaying then
				IDLE:Play(0.1)
			end
		end

		self.animManager:Play("ALERT_C", 0.4, Enum.AnimationPriority.Action, true)
		self.currentStiffness = v8.SPRING.ALERT_STIFFNESS
		self.currentDamping = v8.SPRING.ALERT_DAMPING
		self.targetTilt = v8.TILT.ALERT

		if self.targetPlayer ~= self.lastStrikeTarget then
			self.attackRetries = 0
		end
	elseif p == STATES.DESCENDING then
		self:FireSpottedIndicator()
		self.descentStartTime = tick()
		self.descendAnimPlayed = false
		self.currentStiffness = v8.SPRING.DESCEND_STIFFNESS_BASE
		self.currentDamping = v8.SPRING.DESCEND_DAMPING
		self.targetTilt = v8.TILT.DESCENDING
		local v9 = self.rootPart and Audio:Play("Sounds.Twisted.Squirm.Alert", {
			Volume = 0.8,
			RollOffMaxDistance = 90,
			Parent = self.rootPart
		})

		if v9 then
			SoundGroupManager.AssignMonsterCombatSound(v9)
		end

		local v10 = self.rootPart and Audio:Play("Sounds.Twisted.Squirm.Descend", {
			Volume = 0.8,
			RollOffMaxDistance = 100,
			Parent = self.rootPart
		})

		if v10 then
			SoundGroupManager.AssignMonsterCombatSound(v10)
		end

		self:SendAlertEffects()
	elseif p == STATES.STRIKE then
		self.animManager:Play("ATTACK_START", 0, Enum.AnimationPriority.Action4, false)
		self.attackLoopStarted = false
		local ATTACK_START = self.animManager.loadedTracks.ATTACK_START

		if ATTACK_START then
			ATTACK_START.Stopped:Once(function()
				if self.currentState == v8.STATES.STRIKE then
					self.animManager:Play("ATTACK_LOOP", 0.1, Enum.AnimationPriority.Action4, true)
					self.attackLoopStarted = true
				end
			end)
		else
			self.animManager:Play("STRIKE", 0, Enum.AnimationPriority.Action4, false)
		end

		self.lastAttackTime = tick()
		self.lastStrikeTarget = self.targetPlayer
		self.strikeRetryCounted = false
		self.currentStiffness = v8.SPRING.STRIKE_STIFFNESS
		self.currentDamping = v8.SPRING.STRIKE_DAMPING
		local distanceToTarget = self:GetDistanceToTarget()
		local v9 = (not (distanceToTarget > 0) or distanceToTarget == 1e999) and 0 or distanceToTarget / v8.MOVEMENT.STRIKE_SPEED or 0
		self.strikeTimeout = math.clamp(
			v8.TIMING.STRIKE_DURATION + v9,
			v8.TIMING.STRIKE_DURATION,
			v8.TIMING.STRIKE_DURATION_MAX
		)
		self.targetTilt = v8.TILT.STRIKE
	elseif p == STATES.HOLDING then
		self.animManager:Play("HOLDING", nil, Enum.AnimationPriority.Action, true)
		self.currentStiffness = v8.SPRING.HOLDING_STIFFNESS
		self.currentDamping = v8.SPRING.HOLDING_DAMPING
		self.holdingYaw = nil
		self.attackRetries = 0

		if self.targetPlayer and not self.researchGrantedPlayers[self.targetPlayer] then
			self.researchGrantedPlayers[self.targetPlayer] = true

			if module2 then
				local success, result = pcall(function()
					module2.grantResearch(self.targetPlayer, self.monster.Name, {
						points = 5
					}, self.researchMonsterId)
				end)

				if not success then
					warn("[TwistedSquirm] Failed to grant research:", result)
				end
			end

			if module then
				pcall(function()
					module:Record(self.targetPlayer, "EncounterTwisted", self.monster.Name)
				end)
			end

			local child = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("PlayerStats") and workspace.Info.PlayerStats:FindFirstChild(self.targetPlayer.Name)
			local monsters = child and child:FindFirstChild("Monsters")

			if monsters then
				monsters.Value += 1
			end
		end

		if v8.GRAB.ALERT_TWISTEDS_ON_GRAB then
			self:AlertTwisteds()
		end

		local humanoidRootPart = self.targetPlayer and self.targetPlayer.Character and self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			self:AttachHandTargets(humanoidRootPart)

			if v8.DEBUG.VISUALIZE_IK_TARGETS then
				self:VisualizeIKTargets()
			end
		end

		self.targetTilt = v8.TILT.HOLDING
	elseif p == STATES.RECOIL then
		if self.chasingValue then
			self.chasingValue.Value = nil
		end

		if self.targetPlayer then
			self.targetPlayer:SetAttribute("Spotted", nil)
			self.targetPlayer:SetAttribute("Alerted", false)
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local storyEvents = ReplicatedStorage2:FindFirstChild("StoryEvents")

			if storyEvents then
				local lostInterest = storyEvents:FindFirstChild("LostInterest")

				if lostInterest and typeof(self.targetPlayer) == "Instance" then
					lostInterest:FireClient(self.targetPlayer)
				end
			end
		end

		local IDLE = self.animManager.loadedTracks.IDLE

		if IDLE then
			IDLE.Priority = Enum.AnimationPriority.Idle
			IDLE.Looped = true

			if not IDLE.IsPlaying then
				IDLE:Play(0.1)
			end
		end

		local v9

		if tick() - (self.lastAlertExitTime or 0) < 5 and self.previousState == STATES.ALERT then
			local _ = v8.DEBUG.LOG_STATE_CHANGES
			v9 = nil
		else
			v9 = self.previousState ~= STATES.ALERT and "LOST_INTEREST" or math.random(2) == 1 and "ALERT_TO_IDLE_A" or "ALERT_TO_IDLE_B"
		end

		if v9 then
			local loadedTrack = self.animManager.loadedTracks[v9]

			if loadedTrack then
				loadedTrack.Priority = Enum.AnimationPriority.Action
				loadedTrack.Looped = false
				loadedTrack:Play(self.previousState == STATES.ALERT and 1 or 0.6)
				loadedTrack.Stopped:Once(function()
					if self.currentState == STATES.RECOIL then
						local v10 = (v9 == "ALERT_TO_IDLE_A" or v9 == "ALERT_TO_IDLE_B") and 1 or 0.5
						self.animManager:Play("IDLE", v10, Enum.AnimationPriority.Idle, true)
					end
				end)
			else
				self.animManager:Play("IDLE", 0.5, Enum.AnimationPriority.Idle, true)
			end
		elseif IDLE then
			IDLE.Priority = Enum.AnimationPriority.Idle
		end

		self.headVel = createVector(0, 0, 0)
		self.currentStiffness = v8.SPRING.RECOIL_STIFFNESS
		self.currentDamping = v8.SPRING.RECOIL_DAMPING
		self.targetTilt = v8.TILT.RECOIL
		self.recoilStartTilt = self.currentTilt
		self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_RECOIL, 0))
		self:SetTargetLookDir(createVector(0, -1, 0))
	elseif p == STATES.RELOCATING then
		if self.chasingValue then
			self.chasingValue.Value = nil
		end

		if self.targetPlayer then
			self.targetPlayer:SetAttribute("Spotted", nil)
			self.targetPlayer:SetAttribute("Alerted", false)
		end

		self.currentStiffness = v8.SPRING.RECOIL_STIFFNESS
		self.currentDamping = v8.SPRING.RECOIL_DAMPING
		self.targetTilt = v8.TILT.RECOIL
		self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_RECOIL, 0))
		self:StartRelocate()
	end
end

function class:OnStateExit(p)
	local STATES = TwistedSquirmConfig.STATES

	if p == STATES.IDLE then
		if self.currentBookshelf then
			local nibbleEvent = getNibbleEvent()

			if nibbleEvent then
				nibbleEvent:FireAllClients(self.monster, nil, "stop")
			end

			self.currentBookshelf = nil
			self.bookshelfLookPos = nil
			self.lastChewTime = nil
		end

		if self.munchSound then
			self.munchSound:Stop()
			self.munchSound:Destroy()
			self.munchSound = nil
		end

		local currentTrackName = self.animManager.currentTrackName

		if currentTrackName == "MUNCH_LEAVE_A" or currentTrackName == "MUNCH_LEAVE_B" then
			self.animManager:Stop(currentTrackName, 0.2)
		end
	elseif p == STATES.ALERT then
		self.lastAlertExitTime = tick()
		local IDLE = self.animManager.loadedTracks.IDLE

		if IDLE then
			IDLE:Stop(0.3)
		end
	elseif p == STATES.RECOIL then
		self.recoilStartTilt = nil
	end
end

function class:Update(p)
	if not (self.monster and self.monster.Parent) or self.frozen then
		return
	end

	local STATES = TwistedSquirmConfig.STATES
	local currentState = self.currentState
	local nearestPlayerGlobal, cachedNearestPlayerDist = self:FindNearestPlayerGlobal()
	self._cachedNearestPlayer = nearestPlayerGlobal
	self._cachedNearestPlayerDist = cachedNearestPlayerDist

	if currentState ~= STATES.HOLDING then
		self.handIKTargetWeight = 0

		if self.handIKWeight < 0.01 and self.leftHandTarget then
			self:DetachHandTargets()
		end
	end

	if currentState == STATES.IDLE then
		self:UpdateIdle(p)
	elseif currentState == STATES.ALERT then
		self:UpdateAlert(p)
	elseif currentState == STATES.DESCENDING then
		self:UpdateDescending(p)
	elseif currentState == STATES.STRIKE then
		self:UpdateStrike(p)
	elseif currentState == STATES.HOLDING then
		self:UpdateHolding()
	elseif currentState == STATES.RECOIL then
		self:UpdateRecoil(p)
	elseif currentState == STATES.RELOCATING then
		self:UpdateRelocating(p)
	end

	self:ApplySpringPhysics(p)
	local v9 = tick() - self.stateStartTime

	if (currentState == STATES.DESCENDING or currentState == STATES.STRIKE) and (currentState ~= STATES.DESCENDING or v9 > 2) then
		if self.headVel.Magnitude < 0.5 and self.headTargetPos and (self.headTargetPos - self.headPos).Magnitude > 3 then
			self.stuckTimer = (self.stuckTimer or 0) + p

			if self.stuckTimer > 2 then
				warn("[TwistedSquirm]", self.id, "Stuck detected in", currentState, "- forcing recovery")
				self.stuckTimer = 0
				self.attackRetries += 1

				if self.attackRetries >= TwistedSquirmConfig.WHIFF.MAX_RETRIES then
					self:TransitionTo(STATES.RELOCATING)
				else
					self:TransitionTo(STATES.RECOIL)
				end
			end
		else
			self.stuckTimer = 0
		end
	else
		self.stuckTimer = 0
	end

	self:UpdateHeadTracking(p)
	self:UpdateHandIK(p)
	self:UpdateGlowingEyesDistance()
	self.lastEyesRefresh = self.lastEyesRefresh or 0

	if tick() - self.lastEyesRefresh > 1 then
		self.lastEyesRefresh = tick()
		self:RefreshGlowingEyes()
	end

	if TwistedSquirmConfig.DEBUG.ENABLED then
		self.lastDebugLog = self.lastDebugLog or 0

		if tick() - self.lastDebugLog > 0.5 then
			self.lastDebugLog = tick()
			self:LogDebugState()
		end
	end

	self:UpdateDebugDisplay()
end

function class:LogDebugState()
	if not self.rootPart then
		return
	end

	math.deg(self.currentTilt or 0)
	math.deg(self.targetTilt or 0)
	self:GetDistanceToTarget()
	self:GetHorizontalDistanceToTarget()
	local _ = tick() - self.stateStartTime
	local _ = self.targetPlayer
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawToShowFace(headPos, p)
	local vector2 = Vector3.new(p.X - headPos.X, 0, p.Z - headPos.Z)

	if vector2.Magnitude > 0.1 then
		return (math.atan2(vector2.X, vector2.Z))
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawToTrack(headPos, position)
	local vector2 = Vector3.new(position.X - headPos.X, 0, position.Z - headPos.Z)

	if vector2.Magnitude > 0.1 then
		return (math.atan2(-vector2.X, -vector2.Z))
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawFromPlayerLook(humanoidRootPart)
	local lookVector = humanoidRootPart.CFrame.LookVector
	return (math.atan2(-lookVector.X, -lookVector.Z))
end

function class:UpdateIdle(_)
	local v8 = TwistedSquirmConfig

	if v8.DEBUG.CONSTANT_GRAB then
		local v9 = nil

		if v8.DEBUG.CONSTANT_GRAB_TARGET then
			for _, v11 in pairs(game.Players:GetPlayers()) do
				if not (v11.Name == v8.DEBUG.CONSTANT_GRAB_TARGET and v11.Character) then
					continue
				end

				v9 = v11
				break
			end
		end

		local targetPlayer = v9 or self:FindNearestPlayerGlobal()

		if targetPlayer then
			self.targetPlayer = targetPlayer
			self:TransitionTo(v8.STATES.HOLDING)
			return
		end
	end

	self.currentStiffness = v8.SPRING.IDLE_STIFFNESS
	self.currentDamping = v8.SPRING.IDLE_DAMPING
	self.targetTilt = v8.TILT.IDLE
	local now = tick()
	local idleSway = self:GetIdleSway(now)
	self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_DEFAULT, 0) + idleSway)

	if not self.lastIdleSoundTime then
		self.lastIdleSoundTime = now
		self.nextIdleSoundDelay = math.random(10, 25)
	end

	if not self.currentBookshelf and now - self.lastIdleSoundTime > self.nextIdleSoundDelay then
		self.lastIdleSoundTime = now
		self.nextIdleSoundDelay = math.random(10, 25)
		local v9 = self.rootPart and Audio:Play("Sounds.Twisted.Squirm.Idle", {
			Volume = 1.2,
			RollOffMaxDistance = 160,
			Parent = self.rootPart
		})

		if v9 then
			SoundGroupManager.AssignMonsterAmbientSound(v9)
		end
	end

	local v9 = now - (self.idleEnteredTime or now)
	local _cachedNearestPlayer = self._cachedNearestPlayer
	local _cachedNearestPlayerDist = self._cachedNearestPlayerDist
	local v10 = _cachedNearestPlayer and _cachedNearestPlayerDist <= (v8.DISTANCES.PLAYER_WATCH or 40)

	if not self.lastQuirkTime then
		self.lastQuirkTime = now
		self.nextQuirkDelay = math.random(8, 15)
	end

	if v10 then
		self.lastQuirkTime = now
	end

	if v9 >= 5 and not v10 and not self.currentBookshelf and now - self.lastQuirkTime > self.nextQuirkDelay then
		self.lastQuirkTime = now
		self.nextQuirkDelay = math.random(8, 15)
		self.animManager:Play("QUIRK", 0.3, Enum.AnimationPriority.Action, false)
		local QUIRK = self.animManager.loadedTracks.QUIRK

		if QUIRK then
			QUIRK.Stopped:Once(function()
				if self.currentState == v8.STATES.IDLE and not self.currentBookshelf then
					self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
				end
			end)
		end
	end

	if v10 and not self.currentBookshelf then
		if not self.lastWatchPoseTime then
			self.lastWatchPoseTime = now
			self.nextWatchPoseDelay = math.random(6, 14)
		end

		if now - self.lastWatchPoseTime > self.nextWatchPoseDelay then
			self.lastWatchPoseTime = now
			self.nextWatchPoseDelay = math.random(6, 14)
			local v11 = { "ALERT_C" }
			local v12 = v11[math.random(#v11)]
			self.animManager:Play(v12, 0.4, Enum.AnimationPriority.Action, false)
			local loadedTrack = self.animManager.loadedTracks[v12]

			if loadedTrack then
				loadedTrack.Stopped:Once(function()
					if self.currentState == v8.STATES.IDLE and not self.currentBookshelf then
						self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
					end
				end)
			end
		end
	else
		self.lastWatchPoseTime = nil
	end

	local IDLE_RELOCATE_MIN = v8.TIMING.IDLE_RELOCATE_MIN or 45
	local IDLE_RELOCATE_MAX = v8.TIMING.IDLE_RELOCATE_MAX or 90

	if not self.lastIdleRelocateCheck then
		self.lastIdleRelocateCheck = now
		self.idleRelocateDelay = math.random(IDLE_RELOCATE_MIN, IDLE_RELOCATE_MAX)
	end

	if not v10 and not self.currentBookshelf and now - self.lastIdleRelocateCheck > self.idleRelocateDelay then
		self.lastIdleRelocateCheck = now
		self.idleRelocateDelay = math.random(IDLE_RELOCATE_MIN, IDLE_RELOCATE_MAX)

		if now - (self.lastRelocateTime or 0) > (v8.TIMING.RELOCATE_COOLDOWN or 3) and self.relocateFailCount < 2 then
			self:TransitionTo(v8.STATES.RELOCATING)
			return
		end
	end

	local v11 = 1e999
	local targetPlayer2 = nil

	for _, v13 in ipairs(Players:GetPlayers()) do
		if not v13.Character then
			continue
		end

		local character2 = v13.Character
		local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")
		local humanoid = character2:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoid and humanoid.Health > 0) then
			continue
		end

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			continue
		end

		local v14 = humanoidRootPart.Position - self.headPos
		local magnitude = Vector3.new(v14.X, 0, v14.Z).Magnitude

		if not (magnitude < v11) then
			continue
		end

		targetPlayer2 = v13
		v11 = magnitude
	end

	if targetPlayer2 and targetPlayer2.Character and v11 < v8.DISTANCES.PLAYER_WATCH then
		self.lastPlayerNearbyTime = now

		if self.currentBookshelf then
			local nibbleEvent = getNibbleEvent()

			if nibbleEvent then
				nibbleEvent:FireAllClients(self.monster, nil, "stop")
			end

			self.currentBookshelf = nil
			self.bookshelfLookPos = nil
			self.lastChewTime = nil

			if self.munchSound then
				self.munchSound:Stop()
				self.munchSound:Destroy()
				self.munchSound = nil
			end

			if self.animManager.currentTrackName == "EATING_BOOKS" then
				if v8.BOOKSHELF and v8.BOOKSHELF.USE_MUNCH_LEAVE_ANIM then
					local v13 = math.random() < 0.5 and "MUNCH_LEAVE_A" or "MUNCH_LEAVE_B"
					self.animManager:Play(v13, 0, Enum.AnimationPriority.Action, true)
					local MUNCH_LEAVE_DURATION = v8.BOOKSHELF.MUNCH_LEAVE_DURATION or 1.5
					self.munchLeaveUntil = tick() + MUNCH_LEAVE_DURATION
					task.delay(MUNCH_LEAVE_DURATION, function()
						if self.currentState == v8.STATES.IDLE and not self.currentBookshelf then
							local currentTrackName = self.animManager.currentTrackName

							if currentTrackName == "MUNCH_LEAVE_A" or currentTrackName == "MUNCH_LEAVE_B" then
								self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
							end
						end
					end)
				else
					self.animManager:Play("ALERT_C", 0, Enum.AnimationPriority.Action, false)
					task.delay(0.5, function()
						if self.currentState == v8.STATES.IDLE and not self.currentBookshelf then
							self.animManager:Play("IDLE", 0.2, Enum.AnimationPriority.Idle, true)
						end
					end)
				end
			end

			self.headVel = createVector(0, 0, 0)
			self.currentStiffness = v8.SPRING.STRIKE_STIFFNESS
			self.currentDamping = v8.SPRING.STRIKE_DAMPING
		end

		self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_DEFAULT, 0))
		self.targetTilt = v8.TILT.IDLE
		local humanoidRootPart = targetPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if v11 < v8.DISTANCES.PLAYER_FACE then
				self.targetYaw = yawToShowFace(self.headPos, humanoidRootPart.Position)
			else
				self.targetYaw = math.sin(now * 0.3) * 0.5
			end

			local v13 = tick() - (self.idleEnteredTime or 0)
			local v14 = self.munchLeaveUntil and tick() < self.munchLeaveUntil

			if v11 < v8.DISTANCES.ALERT and v8.TIMING.MIN_IDLE <= v13 and not v14 and self:HasLineOfSight(targetPlayer2) then
				local _ = self.currentBookshelf
				self.targetPlayer = targetPlayer2
				self:TransitionTo(v8.STATES.ALERT)
			end
		end
	else
		local v13 = now - (self.lastPlayerNearbyTime or 0)
		local bookshelfTargetDelay = self.bookshelfTargetDelay or not v8.BOOKSHELF and 15 or v8.BOOKSHELF.IDLE_DELAY or 15

		if not self.lastDelayDebug or now - self.lastDelayDebug > 5 then
			self.lastDelayDebug = now
		end

		if v13 < bookshelfTargetDelay then
			self.targetYaw = math.sin(now * 0.3) * 0.5

			if self.currentBookshelf then
				local nibbleEvent = getNibbleEvent()

				if nibbleEvent then
					nibbleEvent:FireAllClients(self.monster, nil, "stop")
				end

				self.currentBookshelf = nil
				self.bookshelfLookPos = nil
				self.lastChewTime = nil

				if self.animManager.currentTrackName == "EATING_BOOKS" then
					self.headVel = createVector(0, 0, 0)
					self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
				end
			end
		else
			local CollectionService2 = game:GetService("CollectionService")
			local tagged = CollectionService2:GetTagged("BookShelfModel")

			if not self.lastBookshelfDebug or now - self.lastBookshelfDebug > 5 then
				self.lastBookshelfDebug = now
				local count2 = 0
				local count3 = 0

				for _, instance in ipairs(tagged) do
					if not instance:IsDescendantOf(workspace) then
						continue
					end

					count2 += 1
					local primaryPart = instance:IsA("Model") and instance.PrimaryPart or instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA(
						"BasePart",
						true
					)

					if not (primaryPart and Vector3.new(
						primaryPart.Position.X - self.headPos.X,
						0,
						primaryPart.Position.Z - self.headPos.Z
					).Magnitude < v8.DISTANCES.BOOKSHELF_SEARCH) then
						continue
					end

					count3 += 1
				end
			end

			if #tagged > 0 then
				local currentBookshelf = nil
				local v14 = 1e999
				local position = nil

				if self.currentBookshelf and self.currentBookshelf:IsDescendantOf(workspace) then
					local primaryPart

					if self.currentBookshelf:IsA("Model") and self.currentBookshelf.PrimaryPart then
						primaryPart = self.currentBookshelf.PrimaryPart
					elseif self.currentBookshelf:IsA("BasePart") then
						primaryPart = self.currentBookshelf
					else
						primaryPart = self.currentBookshelf:FindFirstChildWhichIsA("BasePart", true)
					end

					if primaryPart then
						local magnitude = Vector3.new(
							primaryPart.Position.X - self.headPos.X,
							0,
							primaryPart.Position.Z - self.headPos.Z
						).Magnitude

						if magnitude < v8.DISTANCES.BOOKSHELF_SEARCH then
							currentBookshelf = self.currentBookshelf
							position = primaryPart.Position
							v14 = magnitude
						end
					end
				end

				if not currentBookshelf then
					for _, instance in ipairs(tagged) do
						if not instance:IsDescendantOf(workspace) then
							continue
						end

						local primaryPart

						if instance:IsA("Model") and instance.PrimaryPart then
							primaryPart = instance.PrimaryPart
						elseif instance:IsA("BasePart") then
							primaryPart = instance
						else
							primaryPart = instance:FindFirstChildWhichIsA("BasePart", true)
						end

						if not primaryPart then
							continue
						end

						local position2 = primaryPart.Position
						local magnitude = Vector3.new(position2.X - self.headPos.X, 0, position2.Z - self.headPos.Z).Magnitude

						if not (magnitude < v14 and magnitude < v8.DISTANCES.BOOKSHELF_SEARCH) then
							continue
						end

						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
						raycastParams2.FilterDescendantsInstances = { self.monster }
						local v15 = false
						local v16 = position2.Y + 3
						local vector2 = Vector3.new(self.headPos.X, v16, self.headPos.Z)
						local v17 = Vector3.new(position2.X, v16, position2.Z) - vector2
						local magnitude2 = v17.Magnitude

						if magnitude2 > 0 then
							local raycastResult = workspace:Raycast(vector2, v17.Unit * magnitude2, raycastParams2)

							if raycastResult then
								local instance2 = raycastResult.Instance

								if not instance2:IsDescendantOf(instance) and instance2 ~= instance then
									if not self.lastLOSDebug or tick() - self.lastLOSDebug > 3 then
										self.lastLOSDebug = tick()
									end

									v15 = true
								end
							end
						end

						if v15 then
							continue
						end

						position = position2
						currentBookshelf = instance
						v14 = magnitude
					end
				end

				if currentBookshelf and position then
					local primaryPart

					if currentBookshelf:IsA("Model") then
						primaryPart = currentBookshelf.PrimaryPart or currentBookshelf
					else
						primaryPart = currentBookshelf
					end

					local squirmFrontAttachment = primaryPart and primaryPart:FindFirstChild("SquirmFrontAttachment")
					local lookVector = nil
					local position2

					if squirmFrontAttachment then
						local v15 = primaryPart.CFrame * squirmFrontAttachment.CFrame
						position2 = v15.Position
						lookVector = v15.LookVector
					else
						local position3 = self.anchorZone.Position
						local v15 = position.Y + 5
						local vector2 = Vector3.new(position3.X - position.X, 0, position3.Z - position.Z)

						if vector2.Magnitude > 4 then
							local unit = vector2.Unit
							position2 = Vector3.new(position.X + unit.X * 4, v15, position.Z + unit.Z * 4)
						else
							position2 = Vector3.new(position.X, v15, position.Z)
						end
					end

					self:SetTargetPosition(position2)
					self.targetTilt = v8.TILT.EATING_BOOKS or 0

					if self.animManager.currentTrackName ~= "EATING_BOOKS" then
						self.animManager:Play("EATING_BOOKS", 0.5, Enum.AnimationPriority.Action, true)
					end

					if self.currentBookshelf ~= currentBookshelf then
						local nibbleEvent = getNibbleEvent()

						if nibbleEvent then
							if self.currentBookshelf then
								nibbleEvent:FireAllClients(self.monster, nil, "stop")
							end

							nibbleEvent:FireAllClients(self.monster, currentBookshelf, "start")
						else
							warn(string.format("[TwistedSquirm] %s getNibbleEvent returned nil!", self.id))
						end

						self.currentBookshelf = currentBookshelf
						self.lastChewTime = now

						if lookVector then
							self.bookshelfLookPos = position2 + lookVector * 5
						else
							self.bookshelfLookPos = position
						end

						local munchSound = self.rootPart and not self.munchSound and Audio:Play(
							"Sounds.Twisted.Squirm.BookMunch",
							{
								Name = "BookMunchSound",
								Volume = 1.1,
								Looped = true,
								RollOffMaxDistance = 50,
								Parent = self.rootPart
							}
						)

						if munchSound then
							SoundGroupManager.AssignMonsterAmbientSound(munchSound)
							self.munchSound = munchSound
						end
					end

					if self.lastChewTime and now - self.lastChewTime >= 3 and chewNextSection(
						currentBookshelf,
						self.rootPart
					) then
						self.lastChewTime = now
					end

					local headPos = self.headPos
					local bookshelfLookPos = self.bookshelfLookPos or position
					self.targetYaw = yawToShowFace(headPos, bookshelfLookPos) + math.sin(now * 0.8) * 0.008726646259971648
				else
					if self.currentBookshelf then
						local nibbleEvent = getNibbleEvent()

						if nibbleEvent then
							nibbleEvent:FireAllClients(self.monster, nil, "stop")
						end

						self.currentBookshelf = nil
						self.bookshelfLookPos = nil
						self.lastChewTime = nil

						if self.munchSound then
							self.munchSound:Stop()
							self.munchSound:Destroy()
							self.munchSound = nil
						end

						if self.animManager.currentTrackName == "EATING_BOOKS" then
							self.headVel = createVector(0, 0, 0)
							self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
						end
					end

					self.targetYaw = math.sin(now * 0.3) * 0.5
				end
			else
				if self.currentBookshelf then
					local nibbleEvent = getNibbleEvent()

					if nibbleEvent then
						nibbleEvent:FireAllClients(self.monster, nil, "stop")
					end

					self.currentBookshelf = nil
					self.bookshelfLookPos = nil
					self.lastChewTime = nil

					if self.munchSound then
						self.munchSound:Stop()
						self.munchSound:Destroy()
						self.munchSound = nil
					end

					if self.animManager.currentTrackName == "EATING_BOOKS" then
						self.headVel = createVector(0, 0, 0)
						self.animManager:Play("IDLE", 0.3, Enum.AnimationPriority.Idle, true)
					end
				end

				self.targetYaw = math.sin(now * 0.3) * 0.5
			end
		end
	end
end

function class:UpdateAlert(_)
	local v8 = TwistedSquirmConfig
	local v9 = tick() - self.stateStartTime
	self.currentStiffness = v8.SPRING.IDLE_STIFFNESS
	self.currentDamping = v8.SPRING.IDLE_DAMPING
	self.targetTilt = v8.TILT.ALERT
	self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_DEFAULT, 0))

	if not (self.targetPlayer and self.targetPlayer.Character) then
		self.targetPlayer = self:FindClosestPlayer()

		if not self.targetPlayer then
			self:TransitionTo(v8.STATES.RECOIL)
			return
		end
	end

	local humanoidRootPart = self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		self.targetYaw = yawToTrack(self.headPos, humanoidRootPart.Position)
	end

	if v9 < v8.TIMING.ALERT_DELAY then
		return
	end

	local horizontalDistanceToTarget = self:GetHorizontalDistanceToTarget()

	if horizontalDistanceToTarget <= v8.DISTANCES.ALERT then
		if tick() - self.lastGrabTime < v8.GRAB.GRAB_COOLDOWN then
			self.lastCooldownLog = self.lastCooldownLog or 0

			if v8.DEBUG.LOG_STATE_CHANGES and tick() - self.lastCooldownLog > 1 then
				self.lastCooldownLog = tick()
			end
		else
			if self:HasLineOfSight(self.targetPlayer) then
				self:TransitionTo(v8.STATES.DESCENDING)
				return
			end

			local closestPlayer = self:FindClosestPlayerWithLOS()

			if closestPlayer then
				self.targetPlayer = closestPlayer
			else
				self:TransitionTo(v8.STATES.RECOIL)
			end
		end
	elseif v8.DISTANCES.ALERT_EXIT < horizontalDistanceToTarget then
		local closestPlayer = self:FindClosestPlayer()

		if closestPlayer and closestPlayer ~= self.targetPlayer then
			self.targetPlayer = closestPlayer
		else
			self:TransitionTo(v8.STATES.RECOIL)
		end
	end
end

function class:UpdateDescending(_)
	local v8 = TwistedSquirmConfig

	if not self.targetPlayer then
		self:TransitionTo(v8.STATES.RECOIL)
		return
	end

	local character2 = self.targetPlayer.Character

	if not (character2 and character2:FindFirstChild("HumanoidRootPart")) then
		self:TransitionTo(v8.STATES.RECOIL)
	elseif character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
		if v8.DEBUG.LOG_STATE_CHANGES then
			character2:FindFirstChild("NoTarget")
		end

		self.targetPlayer = self:FindClosestPlayer()

		if not self.targetPlayer then
			self:TransitionTo(v8.STATES.RECOIL)
		end
	elseif self:HasLineOfSight(self.targetPlayer) then
		local humanoidRootPart = character2.HumanoidRootPart
		local v9 = tick() - self.descentStartTime
		self.currentStiffness = v8.SPRING.DESCEND_STIFFNESS_BASE + v9 * v8.SPRING.DESCEND_STIFFNESS_ACCEL
		self.currentDamping = v8.SPRING.DESCEND_DAMPING
		self.currentStiffness *= v8.WHIFF.FRUSTRATION_SPEEDUP ^ self.attackRetries

		if self.headVel.Magnitude > v8.SPRING.MAX_VELOCITY then
			self.headVel = self.headVel.Unit * v8.SPRING.MAX_VELOCITY
		end

		local v10 = humanoidRootPart.Position + createVector(0, 2, 0)
		self:SetTargetPosition(v10)
		self.targetTilt = v8.TILT.DESCENDING
		self.targetYaw = yawToTrack(self.headPos, humanoidRootPart.Position)
		local _ = (v10 - self.headPos).Magnitude
		local magnitude = (humanoidRootPart.Position - self.headPos).Magnitude

		if not self.descendAnimPlayed then
			self.descendAnimPlayed = true
			local v11 = math.random(2) == 1 and "ALERT" or "ALERT_B"
			self.animManager:Play(v11, 0.3, Enum.AnimationPriority.Action, true)
		end

		if magnitude <= v8.DISTANCES.STRIKE then
			if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
				local _ = v8.DEBUG.LOG_STATE_CHANGES
				self:TransitionTo(v8.STATES.RELOCATING)
				return
			else
				local _ = v8.DEBUG.LOG_STATE_CHANGES
				self:TransitionTo(v8.STATES.STRIKE)
			end
		elseif math.max(v8.DISTANCES.DESCEND_EXIT, self.maxRopeLength) < magnitude then
			self.attackRetries += 1

			if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
				self:TransitionTo(v8.STATES.RELOCATING)
			else
				self:TransitionTo(v8.STATES.RECOIL)
			end

			return
		end

		if self.anchorZone and v8.DISTANCES.STRIKE < magnitude and (self.headPos - self.anchorZone.Position).Magnitude >= self.maxRopeLength - 1 then
			local _ = v8.DEBUG.LOG_STATE_CHANGES
			self.attackRetries += 1

			if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
				self:TransitionTo(v8.STATES.RELOCATING)
			else
				self:TransitionTo(v8.STATES.RECOIL)
			end
		end
	else
		local _ = v8.DEBUG.LOG_STATE_CHANGES
		self.attackRetries += 1
		self:TransitionTo(v8.STATES.RECOIL)

		if self.currentState == v8.STATES.DESCENDING then
			self.headVel = createVector(0, 0, 0)
			self.headTargetPos = self.headPos
		end
	end
end

function class:UpdateStrike(_)
	local v8 = TwistedSquirmConfig

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if not self.strikeRetryCounted then
			self.strikeRetryCounted = true
			self.attackRetries += 1
		end

		if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
			self:TransitionTo(v8.STATES.RELOCATING)
		else
			self:TransitionTo(v8.STATES.RECOIL)
		end
	end

	local v9 = tick() - self.stateStartTime

	if self.targetPlayer and self.targetPlayer.Character then
		local character2 = self.targetPlayer.Character

		if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
			if v8.DEBUG.LOG_STATE_CHANGES then
				character2:FindFirstChild("NoTarget")
			end

			self.targetPlayer = self:FindClosestPlayer()

			if not self.targetPlayer then
				self:TransitionTo(v8.STATES.RECOIL)
			end

			return
		end
	end

	if self.targetPlayer and not self:HasLineOfSight(self.targetPlayer) then
		local _ = v8.DEBUG.LOG_STATE_CHANGES

		if not self.strikeRetryCounted then
			self.strikeRetryCounted = true
			self.attackRetries += 1
		end

		if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
			self:TransitionTo(v8.STATES.RELOCATING)
		else
			self:TransitionTo(v8.STATES.RECOIL)
		end

		if self.currentState == v8.STATES.STRIKE then
			self.headVel = createVector(0, 0, 0)
			self.headTargetPos = self.headPos
		end
	else
		self.currentStiffness = v8.SPRING.STRIKE_STIFFNESS
		self.currentDamping = v8.SPRING.STRIKE_DAMPING
		self.targetTilt = v8.TILT.STRIKE
		local distanceToTarget = self:GetDistanceToTarget()

		if distanceToTarget <= v8.DISTANCES.GRAB and self.targetPlayer then
			local _ = v8.DEBUG.LOG_STATE_CHANGES

			if self:AttemptGrab() then
				self:TransitionTo(v8.STATES.HOLDING)
				return
			end
		end

		if v8.DISTANCES.STRIKE + 3 < distanceToTarget then
			local _ = v8.DEBUG.LOG_STATE_CHANGES
			self.animManager:Play("LOST_INTEREST", 0.2, Enum.AnimationPriority.Action, false)
			return deduplicatedTail()
		elseif self.anchorZone and v8.DISTANCES.GRAB < distanceToTarget and (self.headPos - self.anchorZone.Position).Magnitude >= self.maxRopeLength - 1 then
			local _ = v8.DEBUG.LOG_STATE_CHANGES
			self.animManager:Play("LOST_INTEREST", 0.2, Enum.AnimationPriority.Action, false)
			return deduplicatedTail()
		else
			local humanoidRootPart = self.targetPlayer and self.targetPlayer.Character and self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				self:SetTargetPosition(humanoidRootPart.Position + v8.GRAB.ATTACHMENT_OFFSET + v8.GRAB.SQUIRM_OFFSET)
				self.targetYaw = yawFromPlayerLook(humanoidRootPart)
			end

			if (self.strikeTimeout or v8.TIMING.STRIKE_DURATION) < v9 then
				if not self.strikeRetryCounted then
					self.strikeRetryCounted = true
					self.attackRetries += 1
				end

				if self.attackRetries >= v8.WHIFF.MAX_RETRIES then
					self:TransitionTo(v8.STATES.RELOCATING)
				else
					self:TransitionTo(v8.STATES.RECOIL)
				end
			end
		end
	end
end

function class:UpdateHolding()
	local v8 = TwistedSquirmConfig

	if not (self.targetPlayer and self.targetPlayer.Character) then
		self:TransitionTo(v8.STATES.RECOIL)
		return
	end

	local character2 = self.targetPlayer.Character

	if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") then
		self:TransitionTo(v8.STATES.RECOIL)
		return
	end

	self.currentStiffness = v8.SPRING.HOLDING_STIFFNESS
	self.currentDamping = v8.SPRING.HOLDING_DAMPING
	self.targetTilt = v8.TILT.HOLDING
	self.handIKTargetWeight = 1

	if self.targetPlayer and self.targetPlayer.Character then
		local humanoidRootPart = self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and self.rootPart then
			local config = self.targetPlayer.Character:FindFirstChild("Config")
			local moduleName = config and config:FindFirstChild("ModuleName")
			local value = moduleName and moduleName.Value or self.targetPlayer.Character.Name
			local v9 = (v8.GRAB.CHARACTER_OFFSETS and v8.GRAB.CHARACTER_OFFSETS[value] or v8.GRAB.ATTACHMENT_OFFSET) + v8.GRAB.SQUIRM_OFFSET
			local vectorToWorldSpace = humanoidRootPart.CFrame:VectorToWorldSpace(v9)
			self.headPos = humanoidRootPart.Position + vectorToWorldSpace
			self.headVel = createVector(0, 0, 0)
			self.skipSpringThisFrame = true
			local v10 = yawFromPlayerLook(humanoidRootPart) -- equivalent call inferred; original call site unknown
			self.currentYaw = v10
			self.targetYaw = v10
		end
	end
end

function class:UpdateRecoil(_)
	local v8 = TwistedSquirmConfig
	local v9 = tick() - self.stateStartTime
	self.currentStiffness = v8.SPRING.RECOIL_STIFFNESS
	self.currentDamping = v8.SPRING.RECOIL_DAMPING
	local v10 = math.min(v9 / 1.5, 1)

	if not self.recoilStartTilt then
		self.recoilStartTilt = self.currentTilt
	end

	self.targetTilt = self.recoilStartTilt + (v8.TILT.RECOIL - self.recoilStartTilt) * v10
	local position = self.anchorZone.Position
	local v11 = position - Vector3.new(0, v8.ROPE.LENGTH_RECOIL, 0)
	local magnitude = (self.headPos - v11).Magnitude
	local magnitude2 = (self.headPos - position).Magnitude

	if v8.DEBUG.LOG_STATE_CHANGES then
		self.lastRecoilLog = self.lastRecoilLog or 0

		if tick() - self.lastRecoilLog > 0.3 then
			self.lastRecoilLog = tick()
			local _ = v8.ROPE.LENGTH_RECOIL - magnitude2
		end
	end

	local nearestPlayerGlobal = self:FindNearestPlayerGlobal()
	local humanoidRootPart = nearestPlayerGlobal and nearestPlayerGlobal.Character and nearestPlayerGlobal.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		self.targetYaw = yawToTrack(self.headPos, humanoidRootPart.Position)
	end

	if magnitude < 2 and v8.TIMING.RECOIL_DURATION < v9 then
		if self.shouldRelocateAfterRecoil then
			self.shouldRelocateAfterRecoil = false
			self:TransitionTo(v8.STATES.RELOCATING)
		else
			self:TransitionTo(v8.STATES.IDLE)
		end
	end
end

function class:UpdateRelocating(_)
	local v8 = TwistedSquirmConfig

	if self.isEmerging then
		return
	end

	self.currentStiffness = v8.SPRING.RECOIL_STIFFNESS
	self.currentDamping = v8.SPRING.RECOIL_DAMPING
	self.targetTilt = v8.TILT.RECOIL
	self:SetTargetPosition(self.anchorZone.Position - Vector3.new(0, v8.ROPE.LENGTH_RECOIL, 0))
end

function class:AttemptGrab()
	if not (self.targetPlayer and self.targetPlayer.Character) then
		return false
	end

	local character2 = self.targetPlayer.Character

	if character2:FindFirstChild("NoTarget") or character2:FindFirstChild("Invincible") or not self:HasLineOfSight(self.targetPlayer) then
		return false
	end

	local grabbedBySquirm = character2:GetAttribute("GrabbedBySquirm")

	if grabbedBySquirm then
		if TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES then
			warn(
				"[TwistedSquirm]",
				self.id,
				"Cannot grab",
				self.targetPlayer.Name,
				"- already grabbed by",
				grabbedBySquirm
			)
		end

		return false
	else
		interruptMachineExtraction(self.targetPlayer)

		if not self.grabHandler then
			self.grabHandler = TwistedSquirmGrabHandler
		end

		local v8 = self.grabHandler.StartGrab(self, self.targetPlayer)

		if not TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES or v8 then
			return v8
		end

		warn("[TwistedSquirm]", self.id, "Failed to grab", self.targetPlayer.Name, "- grab handler returned false")
		return v8
	end
end

function class:OnGrabEnded(_)
	if TwistedSquirmConfig.DEBUG.CONSTANT_GRAB then
		return
	end

	self.handIKTargetWeight = 0

	if self.leftHandTarget or self.rightHandTarget then
		self:DetachHandTargets()
	end

	self.lastGrabTime = tick()
	self.shouldRelocateAfterRecoil = true
	self:TransitionTo(TwistedSquirmConfig.STATES.RECOIL)
end

function class:AlertTwisteds()
	if not (self.targetPlayer and self.targetPlayer.Character) then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local machineEvent = events:FindFirstChild("MachineEvent")

	if not machineEvent then
		return
	end

	machineEvent:Fire(self.targetPlayer.Character, nil)
	local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
end

function class:SendAlertEffects()
	local SQUIRM_ALERT_EFFECTS = TwistedSquirmConfig.SQUIRM_ALERT_EFFECTS

	if not SQUIRM_ALERT_EFFECTS.SHAKE_ENABLED then
		return
	end

	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local twistedSquirmGrab = events:FindFirstChild("TwistedSquirmGrab")

	if not twistedSquirmGrab then
		return
	end

	local count2 = 0

	for player, _ in pairs(self.playersInZone) do
		if not (player and player:IsA("Player")) then
			continue
		end

		twistedSquirmGrab:FireClient(player, "AlertEffect", {
			shake = SQUIRM_ALERT_EFFECTS.SHAKE_ENABLED,
			shakeDuration = SQUIRM_ALERT_EFFECTS.SHAKE_DURATION,
			shakeIntensity = SQUIRM_ALERT_EFFECTS.SHAKE_INTENSITY
		})
		count2 += 1
	end

	if TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES then
		local _ = count2 > 0
	end
end

function class:StartRelocate()
	task.spawn(function()
		if not (self.monster and self.monster.Parent) then
			return
		end

		if self:FindBestAnchor() then
			self.animManager:Play("LEAVE", nil, Enum.AnimationPriority.Action, false)
			local v8 = self.rootPart and Audio:Play("Sounds.Twisted.Squirm.Retreat", {
				Volume = 0.8,
				RollOffMaxDistance = 90,
				Parent = self.rootPart
			})

			if v8 then
				SoundGroupManager.AssignMonsterStateSound(v8)
			end

			local ichorDrip = self.ichorDrip
			self.ichorDrip = nil
			local particleEmitter = nil
			local RELOCATION = TwistedSquirmConfig.RELOCATION
			local CEILING_DUST = TwistedSquirmConfig.CEILING_DUST
			local position = self.anchorZone.Position
			local part = Instance.new("Part")
			part.Name = "SquirmScurryTravel"
			part.Size = createVector(2, 2, 2)

			if TwistedSquirmConfig.DEBUG.ENABLED then
				part.Transparency = 0
				part.Material = Enum.Material.Neon
				part.BrickColor = BrickColor.new("Really red")
			else
				part.Transparency = 1
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = true
			part.CFrame = CFrame.new(position)
			part.Parent = workspace
			self.scurryPart = part

			if CEILING_DUST and CEILING_DUST.ENABLED then
				local attachment = Instance.new("Attachment")
				attachment.Name = "DustAttachment"
				attachment.Parent = part
				particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Name = "CeilingDust"
				particleEmitter.Texture = CEILING_DUST.TEXTURE
				particleEmitter.Color = CEILING_DUST.COLOR
				particleEmitter.Size = CEILING_DUST.SIZE
				particleEmitter.Transparency = CEILING_DUST.TRANSPARENCY
				particleEmitter.Lifetime = CEILING_DUST.LIFETIME
				particleEmitter.Rate = CEILING_DUST.RATE
				particleEmitter.Speed = CEILING_DUST.SPEED
				particleEmitter.SpreadAngle = CEILING_DUST.SPREAD_ANGLE
				particleEmitter.EmissionDirection = Enum.NormalId.Bottom
				particleEmitter.Rotation = CEILING_DUST.ROTATION
				particleEmitter.RotSpeed = CEILING_DUST.ROT_SPEED
				particleEmitter.Acceleration = CEILING_DUST.ACCELERATION
				particleEmitter.LightInfluence = CEILING_DUST.LIGHT_INFLUENCE
				particleEmitter.Enabled = false
				particleEmitter.Parent = attachment
			end

			local _ = TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES
			task.wait(TwistedSquirmConfig.TIMING.LEAVE_ANIM_DURATION)

			if self.monster and self.monster.Parent then
				if self.rope then
					self.rope.Visible = false
				end

				if ichorDrip and ichorDrip.Parent then
					local CEILING_PUDDLE_FADE = TwistedSquirmConfig.TIMING.CEILING_PUDDLE_FADE or 1.5
					local tweenInfo = TweenInfo.new(
						CEILING_PUDDLE_FADE,
						Enum.EasingStyle.Sine,
						Enum.EasingDirection.Out
					)

					for _, descendant in ipairs(ichorDrip:GetDescendants()) do
						if descendant:IsA("MeshPart") then
							TweenService:Create(descendant, tweenInfo, {
								Transparency = 1
							}):Play()
						elseif descendant:IsA("ParticleEmitter") then
							descendant.Enabled = false
						end
					end

					task.delay(CEILING_PUDDLE_FADE, function()
						if ichorDrip and ichorDrip.Parent then
							ichorDrip:Destroy()
						end
					end)
				end

				for _, part2 in ipairs(self.monster:GetDescendants()) do
					if part2:IsA("BasePart") then
						part2.Transparency = 1
					end
				end

				if self.rootPart then
					self.rootPart.CFrame = CFrame.new(0, -500, 0)
				end

				local _ = self.anchorZone.Name
				local bestAnchor = self:FindBestAnchor()

				if bestAnchor and bestAnchor ~= self.anchorZone then
					local v9 = math.max(
						1,
						(bestAnchor.Position - position).Magnitude / (RELOCATION.SCURRY_TRAVEL_SPEED or 40)
					)

					if part then
						if particleEmitter then
							particleEmitter.Enabled = true
						end

						local v10 = Audio:Play("Sounds.Twisted.Squirm.ScurryTravel", {
							Volume = math.max(RELOCATION.SCURRY_VOLUME or 0.8, 0.8),
							RollOffMode = Enum.RollOffMode.Linear,
							RollOffMaxDistance = RELOCATION.SCURRY_ROLLOFF or 150,
							RollOffMinDistance = 0,
							Looped = true,
							Parent = part
						})

						if v10 then
							SoundGroupManager.AssignMonsterAmbientSound(v10)
						end

						local position2 = bestAnchor.Position
						part.CFrame = CFrame.new(position)
						TweenService:Create(part, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
							CFrame = CFrame.new(position2)
						}):Play()
						task.wait(v9)

						if v10 then
							v10:Stop()
						end

						if particleEmitter then
							particleEmitter.Enabled = false
						end
					else
						task.wait(v9)
					end

					if self.monster and self.monster.Parent then
						self.anchorZone:SetAttribute("OccupiedBySquirm", nil)
						bestAnchor:SetAttribute("OccupiedBySquirm", self.id)
						self.anchorZone = bestAnchor
						self.monster:SetAttribute("ClaimedAnchor", bestAnchor.Name)
						local parent = bestAnchor.Parent

						if parent and parent.Name == "CeilingTriggerZone" then
							parent = parent.Parent
						end

						if parent and parent.Name == "TriggerZone" then
							self.groundZone = parent
						else
							warn(
								"[TwistedSquirm]",
								self.id,
								"Relocation: could not find parent TriggerZone! Anchor:",
								bestAnchor:GetFullName(),
								"Parent:",
								parent and parent.Name or "nil"
							)
						end

						local v10 = self
						local maxRopeLength, _, _ = computeMaxRopeLength(self.monster, bestAnchor, self.groundZone)
						v10.maxRopeLength = maxRopeLength

						if self.rope then
							self.rope:Destroy()
						end

						for _, descendant in ipairs(self.monster:GetDescendants()) do
							if not (descendant:IsA("Attachment") and descendant.Name == "RopeAttachment" or descendant:IsA("BasePart") and descendant.Name == "RopeBlendSphere") then
								continue
							end

							descendant:Destroy()
						end

						local headTargetPos = bestAnchor.Position - Vector3.new(
							0,
							TwistedSquirmConfig.ROPE.LENGTH_DEFAULT,
							0
						)
						self.headPos = bestAnchor.Position
						self.headVel = createVector(0, 0, 0)
						self.headLookDir = createVector(0, -1, 0)
						self.lookVel = createVector(0, 0, 0)
						self.headTargetPos = headTargetPos
						self.headTargetLookDir = createVector(0, -1, 0)

						if self.rootPart then
							self.rootPart.CFrame = CFrame.new(bestAnchor.Position) * CFrame.Angles(
								3.141592653589793,
								0,
								0
							)
						end

						local v13 = nil

						for _, bone in ipairs(self.monster:GetDescendants()) do
							if not (bone:IsA("Bone") and bone.Name == "cocoon1_jnt") then
								continue
							end

							v13 = bone
							break
						end

						local parent2 = v13 or self.rootPart
						local attachment = parent2:FindFirstChild("RopeAttachment")

						if not attachment then
							attachment = self.rootPart:FindFirstChild("RopeAttachment")

							if attachment then
								attachment.Parent = parent2
							end
						end

						if not attachment then
							attachment = Instance.new("Attachment")
							attachment.Name = "RopeAttachment"
							attachment.Parent = parent2
						end

						attachment.Position = TwistedSquirmConfig.ROPE.ATTACHMENT_OFFSET or createVector(0, 0, 0)

						if not parent2:FindFirstChild("RopeBlendSphere") then
							local part2 = Instance.new("Part")
							part2.Name = "RopeBlendSphere"
							part2.Shape = Enum.PartType.Ball
							part2.Size = Vector3.new(
								TwistedSquirmConfig.ROPE.THICKNESS,
								TwistedSquirmConfig.ROPE.THICKNESS,
								TwistedSquirmConfig.ROPE.THICKNESS
							)
							part2.Color = TwistedSquirmConfig.ROPE.COLOR
							part2.Material = Enum.Material.SmoothPlastic
							part2.Transparency = 1
							part2.CanCollide = false
							part2.CanQuery = false
							part2.CanTouch = false
							part2.Massless = true
							part2.Anchored = false
							part2.CastShadow = false
							local weldConstraint = Instance.new("WeldConstraint")
							weldConstraint.Part0 = self.rootPart
							weldConstraint.Part1 = part2
							weldConstraint.Parent = part2
							part2.CFrame = attachment.WorldCFrame
							part2.Parent = parent2
						end

						local attachment2 = bestAnchor:FindFirstChild("TetherPoint")

						if not attachment2 then
							attachment2 = Instance.new("Attachment")
							attachment2.Name = "TetherPoint"
							attachment2.Parent = bestAnchor
						end

						local ropeConstraint = Instance.new("RopeConstraint")
						ropeConstraint.Name = "CeilingTether"
						ropeConstraint.Attachment0 = attachment
						ropeConstraint.Attachment1 = attachment2
						ropeConstraint.Length = TwistedSquirmConfig.ROPE.LENGTH_DEFAULT
						ropeConstraint.Restitution = TwistedSquirmConfig.ROPE.RESTITUTION
						ropeConstraint.Thickness = TwistedSquirmConfig.ROPE.THICKNESS
						ropeConstraint.Visible = TwistedSquirmConfig.ROPE.VISIBLE
						ropeConstraint.Color = BrickColor.new(TwistedSquirmConfig.ROPE.COLOR)
						ropeConstraint.Parent = self.monster
						self.rope = ropeConstraint

						if self.zonePart then
							local Y = bestAnchor.Position.Y
							local v18 = math.abs(Y - (self.groundZone and self.groundZone.Position.Y or Y - TwistedSquirmConfig.ROPE.LENGTH_MAX))
							local v19 = math.max(v18 + 10, TwistedSquirmConfig.ZONE.SIZE.Y)
							local SIZE = TwistedSquirmConfig.ZONE.SIZE
							self.zonePart.Size = Vector3.new(SIZE.X, v19, SIZE.Z)
							self.zonePart.Position = Vector3.new(
								bestAnchor.Position.X,
								Y - v18 / 2,
								bestAnchor.Position.Z
							)
						end

						self:SpawnIchorDrip()
					else
						if part then
							part:Destroy()
						end

						return
					end
				end

				if bestAnchor then
					if part then
						part:Destroy()
						self.scurryPart = nil
					end

					task.wait(TwistedSquirmConfig.TIMING.EMERGE_DELAY)

					if not (self.monster and self.monster.Parent) then
						return
					end

					self.isEmerging = true
					local success, result = pcall(function()
						self.headPos = bestAnchor.Position - Vector3.new(0, TwistedSquirmConfig.ROPE.LENGTH_DEFAULT, 0)
						self.headVel = createVector(0, 0, 0)
						self.targetTilt = 0

						for _, part2 in ipairs(self.monster:GetDescendants()) do
							if not part2:IsA("BasePart") then
								continue
							end

							local name = part2.Name

							if not (name ~= TwistedSquirmConfig.PARTS.ROOT and name ~= TwistedSquirmConfig.PARTS.BASE and name ~= TwistedSquirmConfig.PARTS.DRIP and name ~= "DarkGlow") then
								continue
							end

							if not (name ~= "LightGlow" and name ~= "RopeBlendSphere") then
								continue
							end

							part2.Transparency = 0
						end

						local IDLE = self.animManager.loadedTracks.IDLE

						if IDLE then
							IDLE.Priority = Enum.AnimationPriority.Idle
							IDLE.Looped = true

							if not IDLE.IsPlaying then
								IDLE:Play(0.1)
							end
						end

						task.wait()

						if not (self.monster and self.monster.Parent) then
							return
						end

						self.animManager:Play("EMERGE", 0.3, Enum.AnimationPriority.Action, false)
						local EMERGE = TwistedSquirmConfig.SOUNDS.EMERGE
						local v10 = EMERGE ~= "rbxassetid://0" and self.rootPart and Audio:Play(EMERGE, {
							Volume = 0.8,
							RollOffMaxDistance = 90,
							Parent = self.rootPart
						})

						if v10 then
							SoundGroupManager.AssignMonsterStateSound(v10)
						end

						self.lastRelocateTime = tick()
						self.relocateFailCount = 0
						self.attackRetries = 0
						self.lastStrikeTarget = nil
						local EMERGE2 = self.animManager.loadedTracks.EMERGE

						if EMERGE2 and EMERGE2.IsPlaying then
							EMERGE2.Stopped:Wait()
						end

						if not (self.monster and self.monster.Parent) then
							return
						end

						local closestPlayer = self:FindClosestPlayer()

						if not closestPlayer then
							self:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
							return
						end

						self.targetPlayer = closestPlayer
						self:TransitionTo(TwistedSquirmConfig.STATES.ALERT)
					end)
					self.isEmerging = false

					if not success then
						warn("[TwistedSquirm]", self.id, "Emerge phase error:", result)

						if self.monster and self.monster.Parent then
							self:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
						end
					end
				else
					warn(
						"[TwistedSquirm]",
						self.id,
						"Anchor became unavailable during travel - restoring at current position"
					)

					for _, part2 in ipairs(self.monster:GetDescendants()) do
						if not part2:IsA("BasePart") then
							continue
						end

						local name = part2.Name

						if not (name ~= TwistedSquirmConfig.PARTS.ROOT and name ~= TwistedSquirmConfig.PARTS.BASE and name ~= TwistedSquirmConfig.PARTS.DRIP and name ~= "DarkGlow") then
							continue
						end

						if not (name ~= "LightGlow" and name ~= "RopeBlendSphere") then
							continue
						end

						part2.Transparency = 0
					end

					if self.rootPart and self.anchorZone then
						local headPos = self.anchorZone.Position - Vector3.new(
							0,
							TwistedSquirmConfig.ROPE.LENGTH_DEFAULT,
							0
						)
						self.rootPart.CFrame = CFrame.new(headPos) * CFrame.Angles(3.141592653589793, 0, 0)
						self.headPos = headPos
						self.headVel = createVector(0, 0, 0)
					end

					if self.rope then
						self.rope.Visible = true
					end

					if part then
						part:Destroy()
					end

					self.scurryPart = nil
					self:SpawnIchorDrip()
					self:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
				end
			else
				if part then
					part:Destroy()
				end

				self.scurryPart = nil
			end
		else
			self.relocateFailCount = (self.relocateFailCount or 0) + 1
			self.lastRelocateTime = tick()
			warn(
				"[TwistedSquirm]",
				self.id,
				"No alternate anchor available - skipping relocation (fail",
				self.relocateFailCount .. ")"
			)
			self:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
		end
	end)
end

function class:FindBestAnchor()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return nil
	end

	local model = currentRoom:FindFirstChildOfClass("Model")

	if not model then
		return nil
	end

	local triggerZones = model:FindFirstChild("TriggerZones")
	local ZONE_PRIORITY = TwistedSquirmConfig.ZONE_PRIORITY
	local CEILING_ZONE_TAGS = TwistedSquirmConfig.CEILING_ZONE_TAGS
	local STANDARD = 0

	if self.anchorZone then
		if CEILING_ZONE_TAGS then
			for k, tag in pairs(CEILING_ZONE_TAGS) do
				if not CollectionService:HasTag(self.anchorZone, tag) then
					continue
				end

				local v8 = ZONE_PRIORITY[k] or 0

				if STANDARD < v8 then
					STANDARD = v8
				end
			end
		end

		if STANDARD == 0 then
			STANDARD = ZONE_PRIORITY.STANDARD
		end
	end

	local v8 = {}
	local v9 = {}

	local function addCandidate(instance, priority)
		if not instance or instance == self.anchorZone then
			return
		end

		if v9[instance] then
			for _, v10 in ipairs(v8) do
				if v10.part == instance and v10.priority < priority then
					v10.priority = priority
				end
			end
		else
			local occupiedBySquirm = instance:GetAttribute("OccupiedBySquirm")

			if occupiedBySquirm and workspace:FindFirstChild(occupiedBySquirm, true) then
				return
			end

			v9[instance] = true
			table.insert(v8, {
				part = instance,
				priority = priority
			})
		end
	end

	if triggerZones then
		for _, child in ipairs(triggerZones:GetChildren()) do
			if child.Name ~= "TriggerZone" then
				continue
			end

			local ceilingTriggerZone = child:FindFirstChild("CeilingTriggerZone")

			if not ceilingTriggerZone then
				continue
			end

			if not ceilingTriggerZone:IsA("BasePart") then
				if ceilingTriggerZone:IsA("Model") and ceilingTriggerZone.PrimaryPart then
					ceilingTriggerZone = ceilingTriggerZone.PrimaryPart
				else
					ceilingTriggerZone = ceilingTriggerZone:FindFirstChildWhichIsA("BasePart", true)
				end
			end

			addCandidate(ceilingTriggerZone, ZONE_PRIORITY.STANDARD)
		end
	end

	if CEILING_ZONE_TAGS then
		for k, tag in pairs(CEILING_ZONE_TAGS) do
			local priority2 = ZONE_PRIORITY[k] or 0

			for _, part in ipairs(CollectionService:GetTagged(tag)) do
				if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
					addCandidate(part, priority2)
				end
			end
		end
	end

	if #v8 == 0 and TwistedSquirmConfig.CEILING_ZONE_TAG then
		for _, part in ipairs(CollectionService:GetTagged(TwistedSquirmConfig.CEILING_ZONE_TAG)) do
			if part:IsA("BasePart") and part:IsDescendantOf(workspace) then
				addCandidate(part, ZONE_PRIORITY.STANDARD)
			end
		end
	end

	if #v8 == 0 then
		return nil
	end

	local priority = 0

	for _, v10 in ipairs(v8) do
		if priority < v10.priority then
			priority = v10.priority
		end
	end

	if priority < STANDARD then
		return nil
	end

	local parts = {}

	for _, v10 in ipairs(v8) do
		if v10.priority == priority then
			table.insert(parts, v10.part)
		end
	end

	if #parts == 1 then
		return parts[1]
	end

	local position = nil

	if self.targetPlayer and self.targetPlayer.Character then
		local humanoidRootPart = self.targetPlayer.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			position = humanoidRootPart.Position
		end
	end

	if not (position and TwistedSquirmConfig.RELOCATION.PREFER_CLOSER_ANCHOR) then
		return parts[math.random(1, #parts)]
	end

	local v10 = parts[1]
	local magnitude = (v10.Position - position).Magnitude

	for i = 2, #parts do
		local magnitude2 = (parts[i].Position - position).Magnitude

		if not (magnitude2 < magnitude) then
			continue
		end

		v10 = parts[i]
		magnitude = magnitude2
	end

	return v10
end

function class:Cleanup()
	self.isCleanedUp = true
	self:StopBlinking()

	if self.faceNormalSA and self.headPart then
		self:SwapFaceSA(self.faceNormalSA)
	end

	for _, noTargetListener in pairs(self.noTargetListeners) do
		if noTargetListener and noTargetListener.Connected then
			noTargetListener:Disconnect()
		end
	end

	self.noTargetListeners = {}

	for _, connection in ipairs(self.connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	self.connections = {}

	if self.animManager then
		self.animManager:Cleanup()
	end

	if self.zonePart then
		self.zonePart:Destroy()
		self.zonePart = nil
	end

	if self.ichorDrip then
		self.ichorDrip:Destroy()
		self.ichorDrip = nil
	end

	if self.scurryPart then
		self.scurryPart:Destroy()
		self.scurryPart = nil
	end

	if self.debugBillboard and self.debugBillboard.gui then
		self.debugBillboard.gui:Destroy()
		self.debugBillboard = nil
	end

	if self.munchSound then
		self.munchSound:Stop()
		self.munchSound:Destroy()
		self.munchSound = nil
	end

	if self.ikTargetPart then
		self.ikTargetPart:Destroy()
		self.ikTargetPart = nil
	end

	if self.ikControl then
		self.ikControl:Destroy()
		self.ikControl = nil
	end

	self:DetachHandTargets()

	if self.leftHandIK then
		self.leftHandIK:Destroy()
		self.leftHandIK = nil
	end

	if self.rightHandIK then
		self.rightHandIK:Destroy()
		self.rightHandIK = nil
	end

	if self.grabHandler and self.currentState == TwistedSquirmConfig.STATES.HOLDING then
		self.grabHandler.ForceRelease(self.targetPlayer and self.targetPlayer.Character, "monster_removed")
	end

	if self.anchorZone then
		self.anchorZone:SetAttribute("OccupiedBySquirm", nil)
	end

	v4[self.id] = nil
end

function TwistedSquirmController:Initialize(p2, p3, p4)
	local v8 = class.new(self, p2, p3, p4)
	v8:Initialize()
	return v8
end

function TwistedSquirmController.GetInstance(p)
	return v4[p]
end

function TwistedSquirmController.GetAllInstances()
	return v4
end

function TwistedSquirmController.ForceGrab(targetPlayer)
	if not (targetPlayer and targetPlayer.Character) then
		return false
	end

	local humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local v8 = 1e999
	local v9 = nil

	for _, v10 in pairs(v4) do
		if not v10.rootPart then
			continue
		end

		local magnitude = (v10.rootPart.Position - humanoidRootPart.Position).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v9 = v10
		v8 = magnitude
	end

	if not v9 then
		return false
	end

	v9.targetPlayer = targetPlayer
	local attemptGrab = v9:AttemptGrab()

	if attemptGrab then
		v9:TransitionTo(TwistedSquirmConfig.STATES.HOLDING)
	end

	return attemptGrab
end

function TwistedSquirmController.ForceState(p, p2)
	local v8 = v4[p]
	local v9 = v8 and TwistedSquirmConfig.STATES[p2]

	if not v9 then
		return false
	end

	v8:TransitionTo(v9)
	return true
end

function TwistedSquirmController.ToggleDebug()
	TwistedSquirmConfig.DEBUG.ENABLED = not TwistedSquirmConfig.DEBUG.ENABLED
	TwistedSquirmConfig.DEBUG.LOG_STATE_CHANGES = TwistedSquirmConfig.DEBUG.ENABLED
	TwistedSquirmConfig.DEBUG.LOG_GRAB_PROGRESS = TwistedSquirmConfig.DEBUG.ENABLED

	for _, v8 in pairs(v4) do
		if v8.zonePart then
			v8.zonePart.Transparency = TwistedSquirmConfig.DEBUG.SHOW_ZONE and 0.5 or 1
		end
	end

	return TwistedSquirmConfig.DEBUG.ENABLED
end

function TwistedSquirmController.GetFirst()
	for k, v8 in pairs(v4) do
		return v8, k
	end

	return nil
end

function TwistedSquirmController.GetStatus()
	local result = {}

	for k, v8 in pairs(v4) do
		result[k] = {
			state = v8.currentState,
			position = v8.headPos,
			targetPlayer = not v8.targetPlayer and "none" or v8.targetPlayer.Name or "none",
			ikWeight = not v8.ikControl and 0 or v8.ikControl.Weight or 0,
			hasAnimation = v8.animManager.currentTrack ~= nil
		}
	end

	return result
end

function TwistedSquirmController.SetState(value)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	local v8 = TwistedSquirmConfig.STATES[value:upper()]

	if not v8 then
		return "Invalid state: " .. value
	end

	if v8 == TwistedSquirmConfig.STATES.HOLDING and not first.targetPlayer then
		first.targetPlayer = first:FindNearestPlayerGlobal()
	end

	first:TransitionTo(v8)
	return "Set state to: " .. value
end

function TwistedSquirmController.PlayAnim(value, p)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	local v8 = p ~= false
	first.animManager:Play(value:upper(), 0.2, Enum.AnimationPriority.Action, v8)
	return "Playing: " .. value .. (v8 and " (looped)" or "")
end

function TwistedSquirmController.SetIKWeight(value)
	local first = TwistedSquirmController.GetFirst()

	if first and first.ikControl then
		first.ikControl.Weight = math.clamp(value, 0, 1)
		return "IK weight: " .. first.ikControl.Weight
	else
		return "No Squirm/IK found"
	end
end

function TwistedSquirmController.SetRotationSpring(value, value2)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	first.rotationStiffness = value or 2
	first.rotationDamping = value2 or 4
	return string.format("Rotation spring: stiff=%s damp=%s", first.rotationStiffness, first.rotationDamping)
end

function TwistedSquirmController.SetYawOffset(value)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	first.yawOffset = math.rad(value or 0)
	return "Yaw offset: " .. value .. " degrees"
end

function TwistedSquirmController.LookAtPlayer(childName)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	local child = Players:FindFirstChild(childName)

	if not (child and child.Character) then
		return "Player not found: " .. childName
	end

	local humanoidRootPart = child.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return "Player has no HumanoidRootPart"
	end

	first.targetPlayer = child

	if first.ikTargetPart then
		first.ikTargetPart.Position = humanoidRootPart.Position + createVector(0, 1.5, 0)
	end

	return "Looking at: " .. childName
end

function TwistedSquirmController.SetDistances(value, value2)
	TwistedSquirmConfig.DISTANCES.STRIKE_RANGE = value or 12
	TwistedSquirmConfig.DISTANCES.GRAB_RANGE = value2 or 8
	return string.format(
		"Strike: %s, Grab: %s",
		TwistedSquirmConfig.DISTANCES.STRIKE_RANGE,
		TwistedSquirmConfig.DISTANCES.GRAB_RANGE
	)
end

function TwistedSquirmController.SetMovementSpring(value, value2)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	first.currentStiffness = value or 8
	first.currentDamping = value2 or 4
	return string.format("Movement spring: stiff=%s damp=%s", first.currentStiffness, first.currentDamping)
end

function TwistedSquirmController.SetPosition(p, p2, p3)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	local vector2 = Vector3.new(p, p2, p3)
	first.headPos = vector2
	first.headTargetPos = vector2
	first.headVel = createVector(0, 0, 0)

	if first.rootPart then
		first.rootPart.CFrame = CFrame.new(vector2) * CFrame.Angles(3.141592653589793, 0, 0)
	end

	return string.format("Position: %s, %s, %s", p, p2, p3)
end

function TwistedSquirmController.Reset()
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	if first.anchorZone then
		local v8 = first.anchorZone.Position - Vector3.new(0, TwistedSquirmConfig.ROPE.LENGTH_DEFAULT, 0)
		first.headPos = v8
		first.headTargetPos = v8
		first.headVel = createVector(0, 0, 0)
		first.headLookDir = createVector(0, -1, 0)
		first.lookVel = createVector(0, 0, 0)
	end

	first.targetPlayer = nil
	first:TransitionTo(TwistedSquirmConfig.STATES.IDLE)
	return "Reset to IDLE at anchor"
end

function TwistedSquirmController.Freeze(p)
	local first = TwistedSquirmController.GetFirst()

	if not first then
		return "No Squirm found"
	end

	first.frozen = p ~= false

	if first.frozen then
		return "Frozen"
	end

	return "Unfrozen"
end

function TwistedSquirmController.ListAnims()
	local ANIMATIONS = TwistedSquirmConfig.ANIMATIONS
	local v8 = {}

	for k, v9 in pairs(ANIMATIONS) do
		table.insert(v8, k .. ": " .. v9)
	end

	return table.concat(v8, "\n")
end

if RunService:IsServer() then
	_G.SquirmDebug = TwistedSquirmController
end

return TwistedSquirmController