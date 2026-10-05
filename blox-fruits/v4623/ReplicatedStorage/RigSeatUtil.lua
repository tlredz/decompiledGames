local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AllianceUtil = require(ReplicatedStorage.AllianceUtil)
local SharedSignals = require(game.ReplicatedStorage.SharedSignals)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("RigSeat"):traceback():build()
local transformationChanged = SharedSignals.TransformationChanged()
local v2 = {}

function getIfTransformed(instance)
	return instance:GetAttribute("TransparencyMode") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMountCFrame(bone)
	if bone:IsA("Bone") then
		return bone.TransformedWorldCFrame
	end

	return bone.WorldCFrame
end

local info = v.info

function getRegisteredUserIdsToSeats(instance)
	local passengers = instance:GetAttribute("Passengers") or "{}"
	assert(typeof(passengers) == "string")
	return (HttpService:JSONDecode(passengers))
end

function updateRiderRender(p: number, instance)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if not playerByUserId then
		return
	end

	assert(playerByUserId)
	local character = playerByUserId.Character

	if not character then
		return
	end

	assert(character)
	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	assert(primaryPart)
	local boneValue = instance:FindFirstChild("BoneValue")

	if not boneValue then
		return
	end

	assert(boneValue and boneValue:IsA("ObjectValue"))
	local value = boneValue.Value
	assert(
		value and (value:IsA("Bone") or value:IsA("Attachment")),
		(`bad to the bone, bbbb-bad, bad to the bone at "{boneValue:GetFullName()}"`)
	)
	local weld = instance:FindFirstChildOfClass("Weld")

	if not weld then
		return
	end

	assert(weld)
	local mountCFrame = getMountCFrame(value) -- equivalent call inferred; original call site unknown
	primaryPart.CFrame = mountCFrame * weld.C0 * CFrame.new(value:GetAttribute("RIG_SEAT_OFFSET") or createVector(
		0,
		1.5,
		-3
	))
	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
end

function getTriggerEnabled(instance)
	if RunService:IsClient() and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid") and (Players.LocalPlayer.Character.Humanoid.SeatPart or Players.LocalPlayer.Character.Humanoid.Health <= 0) then
		return false
	end

	local isTriggerEnabled = instance:GetAttribute("IsTriggerEnabled")
	assert(typeof(isTriggerEnabled) == "boolean", "trigger never initialized")
	return isTriggerEnabled
end

function bindTrigger(instance)
	local character = Players.LocalPlayer.Character

	if character and instance:IsDescendantOf(character) then
		info((`trigger event "{instance:GetFullName()}" is descendant of client character, skipping prompt set-up`))
		return function() end
	end

	local checkRigSeatAccess = instance:WaitForChild("CheckRigSeatAccess", 1)

	if not checkRigSeatAccess then
		info((`trigger event "{instance:GetFullName()}" does is missing valid-sitter check remoteFunction "CheckRigSeatAccess", skipping prompt set-up`))
		return function() end
	end

	assert(checkRigSeatAccess:IsA("RemoteFunction"))
	local triggerObjectText = instance:GetAttribute("TriggerObjectText")
	assert(typeof(triggerObjectText) == "string")
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.ActionText = "Mount"
	proximityPrompt.ObjectText = triggerObjectText
	proximityPrompt.MaxActivationDistance = 50
	local isTriggerEnabledChangedConnection = instance:GetAttributeChangedSignal("IsTriggerEnabled"):Connect(function()
		proximityPrompt.Enabled = getTriggerEnabled(instance) and checkRigSeatAccess:InvokeServer()
	end)

	local function onAllianceUpdate(p, p2)
		info((`detected alliance update for {p} and {p2}`))

		if p == Players.LocalPlayer or p2 == Players.LocalPlayer then
			info("resolving trigger", proximityPrompt.Enabled)
			proximityPrompt.Enabled = getTriggerEnabled(instance) and checkRigSeatAccess:InvokeServer()
			info("resolved trigger", proximityPrompt.Enabled)
		end
	end

	local connection = AllianceUtil.clientConnectOnAllianceStart(onAllianceUpdate)
	local connection2 = AllianceUtil.clientConnectOnAllianceEnd(onAllianceUpdate)
	local connection3 = transformationChanged:Connect(function(_, _: boolean?, _: boolean?)
		proximityPrompt.Enabled = getTriggerEnabled(instance) and checkRigSeatAccess:InvokeServer()
	end)
	proximityPrompt.Enabled = getTriggerEnabled(instance) and checkRigSeatAccess:InvokeServer()
	proximityPrompt:AddTag("RigRidePrompt")
	local triggeredConnection = proximityPrompt.Triggered:Connect(function(player)
		instance:FireServer(player)
	end)
	local destroyingConnection = nil
	destroyingConnection = proximityPrompt.Destroying:Connect(function()
		destroyingConnection:Disconnect()
		triggeredConnection:Disconnect()
	end)
	proximityPrompt.Parent = instance.Parent
	local destroyingConnection2 = nil
	local flag = true

	local function onDestroying()
		if not flag then
			return
		end

		flag = false
		connection3:Disconnect()
		isTriggerEnabledChangedConnection:Disconnect()
		proximityPrompt:Destroy()
		connection2:Disconnect()
		connection:Disconnect()

		if destroyingConnection2 then
			destroyingConnection2:Disconnect()
		end

		v2[instance] = nil
	end

	destroyingConnection2 = instance.Destroying:Connect(onDestroying)
	v2[instance] = onDestroying
	return onDestroying
end

local RigSeatUtil = {
	IS_PASSENGER_ATTR_KEY = "IsPassenger",
	RIDE_ATTR_REP_KEY = "Passengers",
	RIDE_RIG_TAG = "RideRig",
	PROX_PROMPT_TAG = "RigRidePrompt",
	MAX_ACTIVATION_DISTANCE = 50,
	BONE_REF_VALUE_NAME = "BoneValue",
	EXT_TRANSFORM_DETECTION_ATTR = "TransparencyMode",
	CLIENT_SEAT_POSITION_TAG = "RigSeatClientSeatPosition",
	SIT_TRIGGER_TAG = "RigSeatTrigger",
	OBJ_TEXT_ATTR_KEY = "TriggerObjectText",
	IS_TRIGGER_ENABLED_ATTR_KEY = "IsTriggerEnabled",
	CHECK_ACCESS_REMOTE_FUNC_NAME = "CheckRigSeatAccess",
	getRegisteredUserIdsToSeats = getRegisteredUserIdsToSeats,
	getIfTransformed = getIfTransformed,
	getTriggerEnabled = getTriggerEnabled,
	getIfPassenger = function(instance)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return false
		end

		if humanoid.SeatPart then
			return true
		end

		local isPassenger = humanoid:GetAttribute("IsPassenger")

		if typeof(isPassenger) == "boolean" then
			info((`getIsPassenger: {isPassenger}`))
			return isPassenger
		end

		return false
	end
}

function RigSeatUtil.initClient()
	assert(RunService:IsClient(), "initClient can only be run on client")
	info("initClient")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getIsPassenger()
		local localPlayer = Players.LocalPlayer
		assert(localPlayer)
		local character = localPlayer.Character

		if character then
			return RigSeatUtil.getIfPassenger(character)
		end

		info((`getIsPassenger: {false}`))
		return false
	end

	local function processPrompt(proximityPrompt)
		assert(proximityPrompt:IsA("ProximityPrompt"))
		local localPlayer = Players.LocalPlayer
		assert(localPlayer)
		local character = localPlayer.Character

		if character then
			if proximityPrompt:IsDescendantOf(character) then
				if proximityPrompt.MaxActivationDistance == 0 then
					return
				end

				info((`hiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
				proximityPrompt.MaxActivationDistance = 0
			else
				local isPassenger = getIsPassenger() -- equivalent call inferred; original call site unknown

				if isPassenger == true or getIfTransformed(character) then
					if proximityPrompt.MaxActivationDistance == 0 then
						return
					end

					info((`hiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
					proximityPrompt.MaxActivationDistance = 0
				elseif character then
					if proximityPrompt.MaxActivationDistance ~= 50 then
						info((`unhiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
						proximityPrompt.MaxActivationDistance = 50
					end
				else
					if proximityPrompt.MaxActivationDistance == 0 then
						return
					end

					info((`hiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
					proximityPrompt.MaxActivationDistance = 0
				end
			end
		elseif character then
			if proximityPrompt.MaxActivationDistance ~= 50 then
				info((`unhiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
				proximityPrompt.MaxActivationDistance = 50
			end
		else
			if proximityPrompt.MaxActivationDistance == 0 then
				return
			end

			info((`hiding prompt "{proximityPrompt:GetFullName()}" for {localPlayer.Name}`))
			proximityPrompt.MaxActivationDistance = 0
		end
	end

	local function processAllPrompts()
		info("called processAllPrompts()\"")

		for _, v3 in ipairs(CollectionService:GetTagged("RigRidePrompt")) do
			processPrompt(v3)
		end
	end

	local isPassengerChangedConnection = nil
	local seatPartChangedConnection = nil
	local transparencyModeChangedConnection = nil

	local function initCharacter(character)
		if not character then
			return
		end

		assert(character)
		local humanoid = character:WaitForChild("Humanoid", 10)

		if humanoid then
			assert(humanoid:IsA("Humanoid"))

			if isPassengerChangedConnection then
				isPassengerChangedConnection:Disconnect()
			end

			isPassengerChangedConnection = humanoid:GetAttributeChangedSignal("IsPassenger"):Connect(processAllPrompts)

			if seatPartChangedConnection then
				seatPartChangedConnection:Disconnect()
			end

			seatPartChangedConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(processAllPrompts)
		end

		if transparencyModeChangedConnection then
			transparencyModeChangedConnection:Disconnect()
		end

		transparencyModeChangedConnection = character:GetAttributeChangedSignal("TransparencyMode"):Connect(processAllPrompts)
		processAllPrompts()
	end

	local connection = CollectionService:GetInstanceAddedSignal("RigRidePrompt"):Connect(processPrompt)
	local connection2 = CollectionService:GetInstanceAddedSignal("RigSeatTrigger"):Connect(function(remoteEvent)
		if remoteEvent:IsA("RemoteEvent") then
			bindTrigger(remoteEvent)
		end
	end)
	local connection3 = CollectionService:GetInstanceRemovedSignal("RigSeatTrigger"):Connect(function(remoteEvent)
		local callback = remoteEvent:IsA("RemoteEvent") and v2[remoteEvent]

		if callback then
			callback()
		end
	end)
	local characterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(character)
		initCharacter(character)
	end)
	task.spawn(function()
		initCharacter(Players.LocalPlayer.Character)
	end)
	local flag = false
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v3 = false

		for _, objectValue in ipairs(CollectionService:GetTagged("RigSeatClientSeatPosition")) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local parent = objectValue.Parent

			if not (parent and parent:IsA("BasePart")) then
				continue
			end

			assert(parent:IsA("BasePart"))
			local value = objectValue.Value

			if not (value and value:IsA("Bone")) then
				continue
			end

			assert(value:IsA("Bone"))
			local mountCFrame = getMountCFrame(value) -- equivalent call inferred; original call site unknown
			parent:PivotTo(mountCFrame)
		end

		for _, model in ipairs(CollectionService:GetTagged("RideRig")) do
			if not model:IsA("Model") then
				continue
			end

			for k, childName in pairs(getRegisteredUserIdsToSeats(model)) do
				local part = model:FindFirstChild(childName, true)

				if not (part and part:IsA("BasePart")) then
					continue
				end

				local v4 = tonumber(k)
				assert(v4 ~= nil, (`bad userId "{k}"`))
				updateRiderRender(v4, part)
				v3 = true
			end
		end

		if v3 ~= flag then
			info("isRenderingAnything: ", v3)
			flag = v3
		end
	end)

	for _, remoteEvent in ipairs(CollectionService:GetTagged("RigSeatTrigger")) do
		if remoteEvent:IsA("RemoteEvent") then
			bindTrigger(remoteEvent)
		end
	end

	local flag2 = true
	return function()
		if not flag2 then
			return
		end

		flag2 = true

		if isPassengerChangedConnection then
			isPassengerChangedConnection:Disconnect()
		end

		connection2:Disconnect()
		connection3:Disconnect()
		connection:Disconnect()
		characterAddedConnection:Disconnect()
		heartbeatConnection:Disconnect()

		if transparencyModeChangedConnection then
			transparencyModeChangedConnection:Disconnect()
		end
	end
end

return RigSeatUtil