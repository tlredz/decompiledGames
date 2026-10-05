local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BonusMomentInteraction = require(ReplicatedStorage.Util.BonusMomentInteraction)
local LineOfSight = require(ReplicatedStorage.NPCManager.NPC.LineOfSight)
local Maid = require(ReplicatedStorage.Util.Maid)
local NPC = require(ReplicatedStorage.NPCManager.NPC)
local Sound = require(ReplicatedStorage.Util.Sound)
local NPCDrop = require(ReplicatedStorage.Modules.NPCDrop)
local Net = require(ReplicatedStorage.Modules.Net)
local TextGrammar = require(ReplicatedStorage.NPCManager.NPC.TextGrammar)
require(ReplicatedStorage.NPCManager.Types)
local localPlayer = Players.LocalPlayer
local v = {
	{
		Yaw = 0,
		Hand = "Right",
		Actions = { "Explain", "Observe" }
	},
	{
		Yaw = 180,
		Hand = "Left",
		Actions = { "Positive", "Negative" },
		transform = TextGrammar.formal
	}
}
local frozen = table.freeze({
	"MiddleTownSFX.BF_MidTown_Swap_Personality_01",
	"MiddleTownSFX.BF_MidTown_Swap_Personality_02",
	"MiddleTownSFX.BF_MidTown_Swap_Personality_03"
})
local frozen2 = table.freeze({
	DELAY = 0,
	DURATION = 0.2
})
local frozen3 = table.freeze({
	DELAY = 1,
	DURATION = 0.5
})
local frozen4 = table.freeze({
	HEAD = frozen2,
	BODY = frozen3,
	TOTAL = frozen3.DELAY + frozen3.DURATION,
	OVERSHOOT = 0.6632251157578453,
	ROLL = 0.24434609527920614,
	BOB = 0.35,
	HAND_SWAP_LEAD = 0.12,
	HAND_SWAP_DURATION = 0.35
})
local v2 = frozen3.DELAY - frozen4.HAND_SWAP_LEAD
local frozen5 = table.freeze({
	ASSET = "DevBrosMoneybag",
	SCALE = 0.55,
	YAW = 0.4363323129985824,
	FOLDER_NAME = "NPCProps",
	GRIP_OFFSET = createVector(0.45, -0.35, 0.95),
	BAG_DROP = 0.6,
	POLE_OFFSETS = table.freeze({
		Right = createVector(3.2, -2.4, 0.1),
		Left = createVector(-3.2, -2.4, 0.1)
	}),
	IK_PRIORITY = 1,
	IK_SMOOTH_TIME = 0.18
})
local extended = NPC.extend("DevBros")

-- equivalent calls inferred from this helper; original call sites unknown
local function spinYaw(p: number, p2: number)
	if p2 == 0 then
		return 0
	end

	return p * p * (3 - p * 2) * p2 + math.sin(p ^ 1.5 * 3.141592653589793) * frozen4.OVERSHOOT
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawOf(lookVector: Vector3)
	return (math.atan2(-lookVector.X, -lookVector.Z))
end

local function getPlayerFocus()
	local character = localPlayer.Character
	local head

	if character then
		head = character:FindFirstChild("Head")
	end

	if head and head:IsA("BasePart") then
		return head.Position
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function segmentAlpha(p: number, p2)
	return (math.clamp((p - p2.DELAY) / p2.DURATION, 0, 1))
end

local function findMotor(instance, childName: string, childName2: string)
	local child = instance:FindFirstChild(childName)
	local motor6D

	if child then
		motor6D = child:FindFirstChild(childName2)
	end

	if motor6D and motor6D:IsA("Motor6D") then
		return {
			motor = motor6D,
			base = motor6D.C0
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setNeck(p, cframe: CFrame)
	if not p then
		return
	end

	p.motor.C0 = p.base * cframe * p.motor.Transform.Rotation:Inverse()
end

local function getPropFolder()
	local folder = workspace:FindFirstChild(frozen5.FOLDER_NAME)

	if folder and folder:IsA("Folder") then
		return folder
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = frozen5.FOLDER_NAME
	folder2.Parent = workspace
	return folder2
end

local function prepareRig(folder)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = part == humanoidRootPart
		end
	end

	return humanoidRootPart
end

function extended.new(p, p2)
	local v3 = NPC.new(p, p2)
	setmetatable(v3, extended)
	v3._sideIndex = 1
	v3._lineIndex = 0
	v3._spinToken = 0
	v3._watchSuspended = false
	v3._dialogueActive = false
	v3._propWanted = false
	v3._neck = nil
	v3._prop = nil
	local v4 = prepareRig(p2)
	local authoredCFrame

	if v4 then
		authoredCFrame = v4.CFrame
	end

	v3._authoredCFrame = authoredCFrame
	return v3
end

function extended.getIfInteractable(p)
	return NPC.getIfInteractable(p) and LineOfSight.isClear(p)
end

function extended.getDialogue(p)
	local dialogue = NPC.getDialogue(p)

	if typeof(dialogue) == "table" and typeof(dialogue.noSkipReveal) == "function" then
		dialogue:noSkipReveal()
	end

	return dialogue
end

function extended:setWatching(flag: boolean)
	if self._watchSuspended then
		return
	end

	NPC.setWatching(self, flag)
end

function extended:getAuthoredCFrame()
	local _rootPart = self._modelState._rootPart

	if not _rootPart then
		return nil
	end

	local _authoredCFrame = self._authoredCFrame

	if _authoredCFrame then
		return CFrame.new(_rootPart.Position) * (_authoredCFrame - _authoredCFrame.Position)
	end

	local __OriginalCFrame = _rootPart:GetAttribute("__OriginalCFrame")

	if typeof(__OriginalCFrame) ~= "CFrame" then
		__OriginalCFrame = _rootPart.CFrame
	end

	self._authoredCFrame = __OriginalCFrame
	return CFrame.new(_rootPart.Position) * (__OriginalCFrame - __OriginalCFrame.Position)
end

function extended:getNeck()
	local _neck = self._neck

	if not _neck then
		_neck = findMotor(self:getModel(), "Head", "Neck")
		self._neck = _neck
	end

	return _neck
end

function extended:resetNeck()
	local _neck = self._neck

	if _neck then
		_neck.motor.C0 = _neck.base
	end
end

function extended:setHandBlend(p2: number, p3: number, p4: number)
	local _prop = self._prop

	if not _prop then
		return
	end

	local hand = v[p2].Hand
	local hand2 = v[p3].Hand

	for k, control in _prop.controls do
		local weight

		if k == hand2 then
			weight = hand == hand2 and 1 or p4
		else
			weight = k ~= hand and 0 or 1 - p4
		end

		control.Weight = weight
	end
end

local function createArmIK(humanoid, model, hand: string, attachment, attachment2, weight: number)
	local part = model:FindFirstChild((`{hand}UpperArm`))
	local part2 = model:FindFirstChild((`{hand}Hand`))

	if not (part and part:IsA("BasePart") and part2 and part2:IsA("BasePart")) then
		return nil
	end

	local iKControl = Instance.new("IKControl")
	iKControl.Name = `DevBros{hand}Hold`
	iKControl.Type = Enum.IKControlType.Position
	iKControl.ChainRoot = part
	iKControl.EndEffector = part2
	iKControl.Target = attachment
	iKControl.Pole = attachment2
	iKControl.Priority = frozen5.IK_PRIORITY
	iKControl.SmoothTime = frozen5.IK_SMOOTH_TIME
	iKControl.Weight = weight
	iKControl.Parent = humanoid
	return iKControl
end

function extended:ensureProp()
	local _prop = self._prop

	if _prop and _prop.grip.Parent then
		return
	end

	self._maid.DevBrosProp = nil
	local model = self:getModel()
	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	local authoredCFrame = self:getAuthoredCFrame()
	local model2 = ReplicatedStorage.Assets.Models:FindFirstChild(frozen5.ASSET)

	if not (humanoid and authoredCFrame and model2 and model2:IsA("Model")) then
		return
	end

	local clone = model2:Clone()
	clone:ScaleTo(frozen5.SCALE)
	local worldCFrame = authoredCFrame * CFrame.new(frozen5.GRIP_OFFSET)
	clone:PivotTo(worldCFrame * CFrame.new(0, -frozen5.BAG_DROP, 0) * CFrame.Angles(0, frozen5.YAW, 0))
	clone.Name = `{model.Name} Moneybag`
	local parent = workspace:FindFirstChild(frozen5.FOLDER_NAME)

	if not (parent and parent:IsA("Folder")) then
		parent = Instance.new("Folder")
		parent.Name = frozen5.FOLDER_NAME
		parent.Parent = workspace
	end

	clone.Parent = parent
	local basePart = clone:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		clone:Destroy()
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "Grip"
	attachment.Parent = basePart
	attachment.WorldCFrame = worldCFrame
	local maid = Maid.new()
	maid:GiveTask(clone)
	local armIKsByHand = {}

	for _, v5 in v do
		local hand = v5.Hand
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = `{hand}Pole`
		attachment2.Parent = basePart
		attachment2.WorldPosition = (authoredCFrame * CFrame.Angles(0, math.rad(v5.Yaw), 0) * CFrame.new(frozen5.POLE_OFFSETS[hand])).Position
		local armIK = createArmIK(humanoid, model, hand, attachment, attachment2, 0)

		if not armIK then
			continue
		end

		armIKsByHand[hand] = armIK
		maid:GiveTask(armIK)
	end

	maid:GiveTask(function()
		if self._prop and self._prop.maid == maid then
			self._prop = nil
		end
	end)
	self._prop = {
		maid = maid,
		grip = attachment,
		controls = armIKsByHand
	}
	self:setHandBlend(self._sideIndex, self._sideIndex, 1)
	self._maid.DevBrosProp = maid
end

function extended:onStateUpdate(flag: boolean, p: number)
	NPC.onStateUpdate(self, flag, p)

	if self._propWanted and self._isInitialized and self:getIfLoadedInWorld() then
		self:ensureProp()
	elseif self._prop then
		self._maid.DevBrosProp = nil
	end
end

function extended:suspendWatching()
	if self._watchSuspended then
		return
	end

	self._watchSuspended = true
	self._modelState._watching = false
	local _loadedMaid = self._loadedMaid

	if _loadedMaid then
		_loadedMaid.WatchTask = nil
		_loadedMaid.WatchLock = nil
	end

	local _rootPart = self._modelState._rootPart

	if _rootPart then
		_rootPart:SetAttribute("__OriginalCFrame", nil)
	end
end

function extended:resumeWatching()
	self._spinToken += 1
	local _rootPart = self._modelState._rootPart
	local authoredCFrame = self:getAuthoredCFrame()

	if _rootPart and authoredCFrame then
		_rootPart.CFrame = authoredCFrame
	end

	self:resetNeck()
	self._watchSuspended = false
end

function extended:spinToSide(sideIndex: number)
	local _rootPart = self._modelState._rootPart
	local authoredCFrame = self:getAuthoredCFrame()
	self._spinToken += 1
	local _spinToken = self._spinToken
	local _sideIndex = self._sideIndex
	self._sideIndex = sideIndex

	if not (_rootPart and authoredCFrame) then
		return _spinToken
	end

	local model = self:getModel()
	local yaw = math.rad(v[_sideIndex].Yaw)
	local v3 = _sideIndex == sideIndex and 0 or 3.141592653589793

	if v3 ~= 0 then
		task.delay(0.15, function()
			if self._spinToken == _spinToken and _rootPart.Parent then
				Sound:Play(frozen[math.random(#frozen)], _rootPart.Position)
			end
		end)
	end

	local v4 = yawOf(authoredCFrame.LookVector) -- equivalent call inferred; original call site unknown
	local neck = self:getNeck()
	local head = model:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		head = nil
	end

	task.spawn(function()
		local lastTime = os.clock()

		while self._spinToken == _spinToken and _rootPart.Parent do
			local v5 = os.clock() - lastTime
			local v6 = segmentAlpha(v5, frozen4.BODY) -- equivalent call inferred; original call site unknown
			local v7 = segmentAlpha(v5, frozen4.HEAD) -- equivalent call inferred; original call site unknown
			local v9 = spinYaw(v6, v3) -- equivalent call inferred; original call site unknown
			local v10 = math.sin(v6 * 3.141592653589793)
			local v11 = v10 * frozen4.ROLL
			_rootPart.CFrame = authoredCFrame * CFrame.new(0, v10 * frozen4.BOB, 0) * CFrame.Angles(0, yaw + v9, 0) * CFrame.Angles(
				0,
				0,
				v11
			)
			local playerFocus = getPlayerFocus()
			local v12

			if playerFocus and head then
				local v13 = playerFocus - head.Position
				v12 = math.atan2(-v13.X, -v13.Z)
			else
				v12 = v4
			end

			local v15 = v12 - v4 + spinYaw(v7, v3) - v9
			setNeck(neck, CFrame.Angles(0, 0, -v11) * CFrame.Angles(0, v15, 0)) -- equivalent call inferred; original call site unknown
			local v18 = (v5 - v2) / frozen4.HAND_SWAP_DURATION
			self:setHandBlend(_sideIndex, sideIndex, (math.clamp(v18, 0, 1)))
			RunService.RenderStepped:Wait()
		end
	end)
	return _spinToken
end

function extended:holdPlayer()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	else
		humanoidRootPart = nil
	end

	if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local busy = BonusMomentInteraction.acquireBusy(character)
	local anchored = humanoidRootPart.Anchored
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.Anchored = true

	function self._maid.DevBrosPlayerHold()
		humanoidRootPart.Anchored = anchored

		if busy then
			busy:Destroy()
		end
	end
end

function extended:releasePlayer()
	self._maid.DevBrosPlayerHold = nil
end

function extended:onDialogueStarted()
	self._lineIndex = 0
	self._dialogueActive = true
	self:suspendWatching()
	self:holdPlayer()
	self._propWanted = true
	self:ensureProp()
	self:spinToSide(self._sideIndex)
	local name = self:getModel().Name
	task.spawn(function()
		Net:RemoteEvent(NPCDrop.REMOTE_EVENT):FireServer(name)
	end)
end

function extended:onDialogueLine(_, object2)
	self._lineIndex += 1

	if typeof(object2.noSkipReveal) == "function" then
		object2:noSkipReveal()
	end

	local v3 = (self._lineIndex - 1) % #v + 1
	local v4 = v[v3]

	if v3 ~= self._sideIndex then
		self:spinToSide(v3)
	end

	if v4.transform and typeof(object2.transformCurrentText) == "function" then
		object2:transformCurrentText(v4.transform)
	end

	self:playAction(v4.Actions[(self._lineIndex - 1) // #v % #v4.Actions + 1])
end

function extended:onDialogueEnded()
	self._dialogueActive = false
	self:releasePlayer()
	local v3 = self._sideIndex ~= 1
	local _spinToken

	if v3 then
		_spinToken = self:spinToSide(1)
	else
		_spinToken = self._spinToken
	end

	task.delay(not v3 and 0 or frozen4.TOTAL, function()
		if self._spinToken == _spinToken and not self._dialogueActive then
			self:resumeWatching()
			self._propWanted = false
			self._maid.DevBrosProp = nil
		end
	end)
end

return extended