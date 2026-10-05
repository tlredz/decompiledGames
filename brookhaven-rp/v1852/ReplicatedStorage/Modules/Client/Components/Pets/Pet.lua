local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PetConstants = require(ReplicatedStorage.Modules.Shared.Pets.PetConstants)
local PetUtil = require(ReplicatedStorage.Modules.Shared.Pets.PetUtil)
local RadialMenu = require(ReplicatedStorage.Modules.Client.UI.RadialMenu)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local PetController = require(ReplicatedStorage.Modules.Client.Pets.PetController)
local v = Component.new({
	Tag = PetConstants.PET_TAG
})

local function getRootPart(instance)
	if instance.PrimaryPart ~= nil then
		return instance.PrimaryPart
	end

	local rootPart = instance:WaitForChild("RootPart", 10)

	if rootPart == nil or not rootPart:IsA("BasePart") then
		return instance:FindFirstChildWhichIsA("BasePart")
	end

	return rootPart
end

local function computeFollowFacingCFrame(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v2 = vector3 - vector2
	local vector5 = Vector3.new(v2.X, 0, v2.Z)

	if vector5.Magnitude < 2 then
		vector5 = Vector3.new(vector4.X, 0, vector4.Z)
	end

	if vector5.Magnitude < 0.001 then
		return CFrame.new()
	end

	return CFrame.lookAt(createVector(0, 0, 0), vector5.Unit)
end

local function getOwnerCarryAttachPart(instance)
	local upperTorso = instance:FindFirstChild("UpperTorso")

	if upperTorso ~= nil and upperTorso:IsA("BasePart") then
		return upperTorso
	end

	local torso = instance:FindFirstChild("Torso")

	if torso == nil or not torso:IsA("BasePart") then
		return nil
	end

	return torso
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._carryJanitor = Janitor.new()
	self._Janitor:Add(self._carryJanitor)
	self._isCarrying = false
	self._carryTrack = nil
	self._cancelHandler = nil
	self._interactionJumpEnabled = nil
end

function v:_SetInteractionJumpLocked(flag: boolean)
	local character = Players.LocalPlayer.Character
	local humanoid

	if character == nil then
		humanoid = false
	else
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if humanoid == nil then
		return
	end

	if flag then
		if self._interactionJumpEnabled == nil then
			self._interactionJumpEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	elseif self._interactionJumpEnabled ~= nil then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, self._interactionJumpEnabled)
		self._interactionJumpEnabled = nil
	end
end

function v:_SetCancelHandler(cancelHandler)
	if self._cancelHandler == cancelHandler then
		return
	end

	local _cancelHandler = self._cancelHandler
	self._cancelHandler = cancelHandler

	if _cancelHandler ~= nil then
		EmotesController.ClearExternalCancelHandler(_cancelHandler)
	end

	if cancelHandler ~= nil then
		EmotesController.SetExternalCancelHandler(cancelHandler)
	end
end

function v:_IsInteracting()
	local instance = self.Instance

	if instance:GetAttribute(PetConstants.ATTR_INTERACTING) == true then
		return true
	end

	local attribute = instance:GetAttribute(PetConstants.ATTR_STATE)
	return attribute == PetConstants.State.Carry or attribute == PetConstants.State.Pet
end

function v:_OpenRadialMenu(flag: boolean)
	local instance = self.Instance
	local attribute = instance:GetAttribute(PetConstants.ATTR_PET_TYPE)

	if attribute == nil then
		return
	end

	local attribute2 = instance:GetAttribute(PetConstants.ATTR_STATE) or PetConstants.State.Follow
	local v2 = {}

	for _, v3 in {
		{
			text = "Carry",
			icon = "rbxassetid://76663233330031",
			ownerOnly = true,
			onActivated = function()
				if self:_IsInteracting() then
					return
				end

				self:_BeginCarry()
			end
		},
		{
			text = "Feed",
			icon = "rbxassetid://89480357368980",
			onActivated = function()
				if self:_IsInteracting() then
					return
				end

				Remotes.fireServerComponent(instance, "Feed")
			end
		},
		{
			text = "Unequip",
			icon = "rbxassetid://6893025659",
			iconColor = Color3.fromRGB(200, 0, 0),
			ownerOnly = true,
			onActivated = function()
				Remotes.fireServer("Pet_Unequip", attribute)
			end
		},
		{
			text = attribute2 == PetConstants.State.Stay and "Follow" or "Stay",
			icon = "rbxassetid://139724042980836",
			ownerOnly = true,
			onActivated = function()
				if self:_IsInteracting() then
					return
				end

				local v3

				if instance:GetAttribute(PetConstants.ATTR_STATE) == PetConstants.State.Stay then
					v3 = PetConstants.State.Follow
				else
					v3 = PetConstants.State.Stay
				end

				Remotes.fireServerComponent(instance, "SetState", v3)
			end
		},
		{
			text = "Pet",
			icon = "rbxassetid://105612022576794",
			onActivated = function()
				if self:_IsInteracting() then
					return
				end

				Remotes.fireServerComponent(instance, "PetAnimal")
			end
		}
	} do
		if v3.ownerOnly ~= true or flag then
			table.insert(v2, v3)
		end
	end

	local hitbox = instance:FindFirstChild("Hitbox") or instance
	RadialMenu.Open(hitbox, v2)
end

function v:_DisableFollowForces()
	if self._bodyGyro ~= nil then
		self._bodyGyro.MaxTorque = createVector(0, 0, 0)
	end

	if self._bodyPosition ~= nil then
		self._bodyPosition.MaxForce = createVector(0, 0, 0)
	end
end

function v:_RestoreFollowForces()
	if self._bodyGyro ~= nil and self._followBodyGyroMaxTorque ~= nil then
		self._bodyGyro.MaxTorque = self._followBodyGyroMaxTorque
	end

	if self._bodyPosition ~= nil and self._followBodyPositionMaxForce ~= nil then
		self._bodyPosition.MaxForce = self._followBodyPositionMaxForce
	end
end

function v:_EndCarry()
	self:_RestoreFollowForces()

	if not self._isCarrying then
		return
	end

	if self._carryTrack ~= nil then
		self._carryTrack:Stop(0)
		self._carryTrack = nil
	end

	self._isCarrying = false
	self._carryJanitor:Cleanup()
	self:_SnapFollowTargetToCurrentPosition()
end

function v:_SnapFollowTargetToCurrentPosition()
	local instance = self.Instance
	local _rootPart = self._rootPart
	local _bodyPosition = self._bodyPosition
	local _bodyGyro = self._bodyGyro

	if _rootPart == nil or _bodyPosition == nil or _bodyGyro == nil then
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character == nil then
		humanoidRootPart = false
	else
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character == nil or humanoidRootPart == nil then
		return
	end

	local attribute = instance:GetAttribute(PetConstants.ATTR_SLOT_NUMBER) or 1
	local parent = instance.Parent
	local v2 = parent == nil and 1 or #parent:GetChildren() or 1
	local followTargetPosition = PetUtil.ComputeFollowTargetPosition(
		humanoidRootPart,
		attribute,
		v2,
		self._rootPartAboveBottom,
		{ character, instance }
	)
	local position = _rootPart.Position
	local lookVector = humanoidRootPart.CFrame.LookVector
	local v3 = followTargetPosition - position
	local vector2 = Vector3.new(v3.X, 0, v3.Z)

	if vector2.Magnitude < 2 then
		vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	end

	local cFrame

	if vector2.Magnitude < 0.001 then
		cFrame = CFrame.new()
	else
		cFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
	end

	_bodyGyro.CFrame = cFrame
	_bodyPosition.Position = followTargetPosition
	self._lastRootPosition = _rootPart.Position
	self._lastSentCategory = nil
end

function v:_BeginCarry()
	if self._isCarrying or self:_IsInteracting() then
		return
	end

	local instance = self.Instance

	if self._rootPart == nil then
		return
	end

	local character = Players.LocalPlayer.Character
	local upperTorso

	if character == nil then
		upperTorso = false
	else
		upperTorso = character:FindFirstChild("UpperTorso")

		if upperTorso == nil or not upperTorso:IsA("BasePart") then
			upperTorso = character:FindFirstChild("Torso")

			if upperTorso == nil or not upperTorso:IsA("BasePart") then
				upperTorso = nil
			end
		end
	end

	if upperTorso == nil then
		return
	end

	Remotes.fireServerComponent(instance, "SetState", PetConstants.State.Carry)
end

function v:_OnEnterCarry()
	if self._isCarrying then
		return
	end

	local instance = self.Instance

	if instance:GetAttribute(PetConstants.ATTR_STATE) ~= PetConstants.State.Carry then
		return
	end

	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	self._isCarrying = true
	self:_DisableFollowForces()
	self._carryJanitor:Add(function()
		self:_RestoreFollowForces()
	end)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator

	if humanoid == nil then
		animator = false
	else
		animator = humanoid:FindFirstChildOfClass("Animator")
	end

	if animator ~= nil then
		local animation = Instance.new("Animation")
		animation.AnimationId = PetUtil.GetPlayerCarryAnimationId(instance)
		local track = animator:LoadAnimation(animation)
		animation:Destroy()
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Action
		track:Play(0.2)
		self._carryTrack = track
		self._carryJanitor:Add(track, "Stop")
	end
end

function v:_StartFollowSimulation(p)
	local instance = self.Instance
	local localPlayer = Players.LocalPlayer
	self._rootPart = p
	self._followAccumulator = 0
	self._lastSentCategory = nil
	self._lastSentPlaybackSpeed = nil
	self._lastRootPosition = p.Position
	self._rootPartAboveBottom = PetUtil.ComputeRootPartAboveBottom(instance, p)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = createVector(400000, 400000, 400000)
	bodyGyro.P = 4000
	bodyGyro.D = 500
	bodyGyro.Parent = p
	self._Janitor:Add(bodyGyro)
	self._bodyGyro = bodyGyro
	self._followBodyGyroMaxTorque = createVector(400000, 400000, 400000)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = createVector(12500, 10000, 12500)
	bodyPosition.Parent = p
	self._Janitor:Add(bodyPosition)
	self._bodyPosition = bodyPosition
	self._followBodyPositionMaxForce = createVector(12500, 10000, 12500)
	local character = localPlayer.Character
	local humanoidRootPart

	if character == nil then
		humanoidRootPart = false
	else
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart ~= nil then
		local attribute = instance:GetAttribute(PetConstants.ATTR_SLOT_NUMBER) or 1
		local parent = instance.Parent
		local v2 = parent == nil and 1 or #parent:GetChildren() or 1
		local followTargetPosition = PetUtil.ComputeFollowTargetPosition(
			humanoidRootPart,
			attribute,
			v2,
			self._rootPartAboveBottom,
			{ character, instance }
		)
		local position = p.Position
		local lookVector = humanoidRootPart.CFrame.LookVector
		local v3 = followTargetPosition - position
		local vector2 = Vector3.new(v3.X, 0, v3.Z)

		if vector2.Magnitude < 2 then
			vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
		end

		local cFrame

		if vector2.Magnitude < 0.001 then
			cFrame = CFrame.new()
		else
			cFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
		end

		bodyGyro.CFrame = cFrame
		bodyPosition.Position = followTargetPosition
	end
end

function v:_SendLocomotion(lastSentCategory, lastSentPlaybackSpeed: number?)
	local instance = self.Instance
	local v2

	if lastSentCategory == PetConstants.Locomotion.Walk and lastSentPlaybackSpeed ~= nil then
		v2 = self._lastSentPlaybackSpeed == nil or math.abs(lastSentPlaybackSpeed - self._lastSentPlaybackSpeed) > 0.05
	else
		v2 = false
	end

	if lastSentCategory == self._lastSentCategory and not v2 then
		return
	end

	self._lastSentCategory = lastSentCategory
	self._lastSentPlaybackSpeed = lastSentPlaybackSpeed
	Remotes.fireServerComponent(instance, "SetLocomotion", lastSentCategory, lastSentPlaybackSpeed)
end

function v:_GetPetSpeed(p: number)
	local _rootPart = self._rootPart

	if _rootPart == nil or p <= 0 then
		return 0
	end

	local v2 = (_rootPart.Position - self._lastRootPosition).Magnitude / p
	self._lastRootPosition = _rootPart.Position
	return v2
end

function v:_UpdateLocomotion(p: number)
	if p < PetConstants.WALK_SPEED_THRESHOLD then
		self:_SendLocomotion(PetConstants.Locomotion.Idle)
	elseif p < PetConstants.RUN_SPEED_THRESHOLD then
		local v2 = math.clamp(
			p / PetConstants.WALK_ANIM_REFERENCE_SPEED,
			PetConstants.WALK_ANIM_MIN_PLAYBACK,
			PetConstants.WALK_ANIM_MAX_PLAYBACK
		)
		self:_SendLocomotion(PetConstants.Locomotion.Walk, v2)
	else
		self:_SendLocomotion(PetConstants.Locomotion.Run)
	end
end

function v:HeartbeatUpdate(p: number)
	local DISTANCE_EPSILON = 0.001
	local DISTANCE_THRESHOLD = 2
	local _rootPart = self._rootPart

	if _rootPart == nil then
		return
	end

	self._followAccumulator += p

	if self._followAccumulator < PetConstants.FOLLOW_UPDATE_INTERVAL then
		return
	end

	local _followAccumulator = self._followAccumulator
	self._followAccumulator = 0
	local instance = self.Instance
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character == nil then
		humanoidRootPart = false
	else
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character == nil or humanoidRootPart == nil or _rootPart.Parent == nil then
		return
	end

	local _bodyGyro = self._bodyGyro
	local _bodyPosition = self._bodyPosition

	if _bodyGyro == nil or _bodyPosition == nil then
		return
	end

	local attribute = instance:GetAttribute(PetConstants.ATTR_STATE) or PetConstants.State.Follow

	if attribute == PetConstants.State.Pet then
		local attribute2 = instance:GetAttribute(PetConstants.ATTR_INTERACTION_TARGET_POSITION)
		local attribute3 = instance:GetAttribute(PetConstants.ATTR_INTERACTION_TARGET_LOOK)
		local v2 = instance:GetAttribute(PetConstants.ATTR_INTERACTION_PET_APPROACH) == true

		if typeof(attribute2) == "Vector3" then
			_bodyPosition.Position = attribute2
		end

		if v2 then
			if typeof(attribute3) == "Vector3" then
				local lookVector = humanoidRootPart.CFrame.LookVector
				local v3 = attribute3 - createVector(0, 0, 0)
				local vector2 = Vector3.new(v3.X, 0, v3.Z)

				if vector2.Magnitude < DISTANCE_THRESHOLD then
					vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
				end

				local cFrame

				if vector2.Magnitude < DISTANCE_EPSILON then
					cFrame = CFrame.new()
				else
					cFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
				end

				_bodyGyro.CFrame = cFrame
			end

			if (typeof(attribute2) ~= "Vector3" and 0 or (_rootPart.Position - attribute2).Magnitude) > PetConstants.PET_INTERACT_ARRIVAL_DISTANCE then
				self:_UpdateLocomotion(self:_GetPetSpeed(_followAccumulator))
			else
				self:_SendLocomotion(PetConstants.Locomotion.Idle)
			end
		elseif typeof(attribute3) == "Vector3" then
			local lookVector = humanoidRootPart.CFrame.LookVector
			local v3 = attribute3 - createVector(0, 0, 0)
			local vector2 = Vector3.new(v3.X, 0, v3.Z)

			if vector2.Magnitude < DISTANCE_THRESHOLD then
				vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			end

			local cFrame

			if vector2.Magnitude < DISTANCE_EPSILON then
				cFrame = CFrame.new()
			else
				cFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
			end

			_bodyGyro.CFrame = cFrame
		end

		self._lastRootPosition = _rootPart.Position
		self._lastSentCategory = nil
	elseif self._isCarrying and attribute == PetConstants.State.Carry then
		self:_DisableFollowForces()
		self._lastRootPosition = _rootPart.Position
		self._lastSentCategory = nil
	else
		self:_RestoreFollowForces()

		if instance:GetAttribute(PetConstants.ATTR_INTERACTING) == true then
			_bodyPosition.Position = _rootPart.Position
			local vector2 = Vector3.new(_rootPart.CFrame.LookVector.X, 0, _rootPart.CFrame.LookVector.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				_bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
			end

			self._lastRootPosition = _rootPart.Position
			self._lastSentCategory = nil
			self:_SendLocomotion(PetConstants.Locomotion.Idle)
		elseif attribute == PetConstants.State.Stay then
			_bodyPosition.Position = _rootPart.Position
			local vector2 = Vector3.new(_rootPart.CFrame.LookVector.X, 0, _rootPart.CFrame.LookVector.Z)

			if vector2.Magnitude > DISTANCE_EPSILON then
				_bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
			end

			self._lastRootPosition = _rootPart.Position
			self._lastSentCategory = nil
		else
			local attribute2 = instance:GetAttribute(PetConstants.ATTR_SLOT_NUMBER) or 1
			local parent = instance.Parent
			local v2 = parent == nil and 1 or #parent:GetChildren() or 1
			local followTargetPosition = PetUtil.ComputeFollowTargetPosition(
				humanoidRootPart,
				attribute2,
				v2,
				self._rootPartAboveBottom,
				{ character, instance }
			)

			if (_rootPart.Position - followTargetPosition).Magnitude > PetConstants.TELEPORT_DISTANCE then
				instance:PivotTo(CFrame.new(followTargetPosition) * PetUtil.GetOwnerFlatRotation(humanoidRootPart))
			end

			local position = _rootPart.Position
			local lookVector = humanoidRootPart.CFrame.LookVector
			local v3 = followTargetPosition - position
			local vector2 = Vector3.new(v3.X, 0, v3.Z)

			if vector2.Magnitude < DISTANCE_THRESHOLD then
				vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			end

			local cFrame

			if vector2.Magnitude < DISTANCE_EPSILON then
				cFrame = CFrame.new()
			else
				cFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
			end

			_bodyGyro.CFrame = cFrame
			_bodyPosition.Position = followTargetPosition
			self:_UpdateLocomotion(self:_GetPetSpeed(_followAccumulator))
		end
	end
end

function v:Start()
	local instance = self.Instance
	local parent = instance.Parent

	if parent == nil then
		return
	end

	local v2 = PetUtil.GetPlayerFromPetsFolder(parent) == Players.LocalPlayer
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "OpenInteractionMenu", function()
		if self:_IsInteracting() then
			return
		end

		self:_OpenRadialMenu(v2)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(
		instance,
		"SetInteractionCancellable",
		function(flag: boolean, flag2: boolean?)
			if flag then
				if EmotesController.IsPlayingEmote() then
					EmotesController.StopEmote()
				end

				if flag2 == true then
					self:_SetInteractionJumpLocked(true)
				end

				self:_SetCancelHandler(function()
					Remotes.fireServerComponent(instance, "CancelInteraction")
				end)
			else
				self:_SetCancelHandler(nil)
				self:_SetInteractionJumpLocked(false)
			end
		end
	))
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "InteractionRequestSent", function()
		PetController.ShowMessageSent()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "IncomingInteractionRequest", function(p: string, p2)
		PetController.ShowIncomingRequest(p, p2, function(flag: boolean)
			Remotes.fireServerComponent(instance, "RespondToInteractionRequest", flag)
		end)
	end))

	if not v2 then
		return
	end

	self._Janitor:Add(instance:GetAttributeChangedSignal(PetConstants.ATTR_STATE):Connect(function()
		local attribute = instance:GetAttribute(PetConstants.ATTR_STATE)

		if attribute == PetConstants.State.Carry then
			self:_OnEnterCarry()
		else
			self:_EndCarry()
		end

		if attribute == PetConstants.State.Stay then
			local _rootPart = self._rootPart
			local _bodyPosition = self._bodyPosition
			local _bodyGyro = self._bodyGyro

			if _rootPart ~= nil and _bodyPosition ~= nil and _bodyGyro ~= nil then
				_bodyPosition.Position = _rootPart.Position
				local vector2 = Vector3.new(_rootPart.CFrame.LookVector.X, 0, _rootPart.CFrame.LookVector.Z)

				if vector2.Magnitude > 0.001 then
					_bodyGyro.CFrame = CFrame.lookAt(createVector(0, 0, 0), vector2.Unit)
				end

				self._lastRootPosition = _rootPart.Position
				self._lastSentCategory = nil
			end
		end
	end))
	self._Janitor:Add(instance:GetAttributeChangedSignal(PetConstants.ATTR_INTERACTING):Connect(function()
		if instance:GetAttribute(PetConstants.ATTR_INTERACTING) ~= true then
			self:_RestoreFollowForces()
		end
	end))
	local rootPart

	if instance.PrimaryPart == nil then
		rootPart = instance:WaitForChild("RootPart", 10)

		if rootPart == nil or not rootPart:IsA("BasePart") then
			rootPart = instance:FindFirstChildWhichIsA("BasePart")
		end
	else
		rootPart = instance.PrimaryPart
	end

	if rootPart == nil then
		warn((`Pet:Start: no root part found for pet "{instance.Name}"`))
	else
		self:_StartFollowSimulation(rootPart)
	end
end

function v:Stop()
	self:_SetCancelHandler(nil)
	self:_SetInteractionJumpLocked(false)
	self._Janitor:Destroy()
end

return v