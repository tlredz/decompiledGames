local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local HandcuffsConstants = require(ReplicatedStorage.Modules.Shared.Tools.HandcuffsConstants)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local PetController = require(ReplicatedStorage.Modules.Client.Pets.PetController)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local DanglingTool = require(ReplicatedStorage.Modules.Client.Components.Physics.DanglingTool)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "Handcuffs",
	Extensions = { OnlyRunOnPlayerHotbar }
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getRootPart(instance)
	if instance == nil then
		return nil
	end

	return (instance:FindFirstChild("HumanoidRootPart"))
end

local function isBusy(instance)
	return instance == nil or instance:FindFirstChild(HandcuffsConstants.BUSY_TAG_NAME) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLocalEmote()
	if not EmotesController.IsPlayingEmote() then
		return
	end

	task.spawn(EmotesController.StopEmote)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._promptJanitor = self._Janitor:Add(Janitor.new())
	self._arrestJanitor = self._Janitor:Add(Janitor.new())
	self._isEquipped = false
	self._isLocalOwner = false
	self._promptsByPlayer = {}
	self._cancelHandler = nil
	self._dragTrack = nil
	self._walkTrack = nil
	self._danglingTool = DanglingTool:FromInstance(self.Instance)
end

function v:_getOwningPlayer()
	local parent = self.Instance.Parent

	if parent == nil then
		return nil
	end

	if parent:IsA("Backpack") then
		return parent.Parent
	end

	return Players:GetPlayerFromCharacter(parent)
end

function v:_clearCancelHandler()
	local _cancelHandler = self._cancelHandler

	if _cancelHandler == nil then
		return
	end

	self._cancelHandler = nil
	EmotesController.ClearExternalCancelHandler(_cancelHandler)
end

function v:_setCancelHandler(cancelHandler)
	self:_clearCancelHandler()

	if cancelHandler == nil then
		return
	end

	self._cancelHandler = cancelHandler
	EmotesController.SetExternalCancelHandler(cancelHandler)
end

function v:_stopEscortAnimation()
	local ANIM_FADE_TIME = HandcuffsConstants.ANIM_FADE_TIME

	if self._dragTrack ~= nil then
		self._dragTrack:Stop(ANIM_FADE_TIME)
		self._dragTrack = nil
	end

	if self._walkTrack ~= nil then
		self._walkTrack:Stop(ANIM_FADE_TIME)
		self._walkTrack = nil
	end
end

function v:_getCharacterWalkAnimation(instance)
	local animate = instance:FindFirstChild("Animate")

	if animate == nil then
		return nil
	end

	local walk = animate:FindFirstChild("walk")

	if walk == nil then
		return nil
	end

	return walk:FindFirstChild("WalkAnim") or walk:FindFirstChildOfClass("Animation")
end

function v:_setWalkPlaying(flag: boolean, p2: number)
	local _walkTrack = self._walkTrack

	if _walkTrack == nil then
		return
	end

	if flag then
		if not _walkTrack.IsPlaying then
			_walkTrack:Play(HandcuffsConstants.ANIM_FADE_TIME)
		end

		_walkTrack:AdjustSpeed((math.clamp(p2 / 16, 0.5, 1.5)))
	elseif _walkTrack.IsPlaying then
		_walkTrack:Stop(HandcuffsConstants.ANIM_FADE_TIME)
	end
end

function v:_startEscortAnimation()
	self:_stopEscortAnimation()
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local animator = character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	local _getCharacterWalkAnimation = self:_getCharacterWalkAnimation(character)

	if _getCharacterWalkAnimation ~= nil then
		local track = animator:LoadAnimation(_getCharacterWalkAnimation)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
		self._walkTrack = track
	end

	local track = animator:LoadAnimation((self.Instance:FindFirstChild("DragAnim")))
	track.Looped = true
	track.Priority = Enum.AnimationPriority.Action
	track:Play(HandcuffsConstants.ANIM_FADE_TIME)
	self._dragTrack = track
	self._arrestJanitor:Add(RunService.Heartbeat:Connect(function()
		local rootPart = getRootPart(character) -- equivalent call inferred; original call site unknown

		if rootPart == nil then
			return
		end

		local magnitude = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z).Magnitude
		self:_setWalkPlaying(HandcuffsConstants.ESCORT_WALK_SPEED_THRESHOLD < magnitude, magnitude)
	end))
end

function v:_destroyPrompt(p2)
	if self._promptsByPlayer[p2] == nil then
		return
	end

	self._promptsByPlayer[p2] = nil
	self._promptJanitor:Remove(p2)
end

function v:_clearAllPrompts()
	table.clear(self._promptsByPlayer)
	self._promptJanitor:Cleanup()
end

function v:_createPrompt(player)
	if self._promptsByPlayer[player] ~= nil then
		return
	end

	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local part = Instance.new("Part")
	part.Name = HandcuffsConstants.PROMPT_NAME
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.Anchored = false
	part.CFrame = humanoidRootPart.CFrame
	part:SetAttribute("PromptText", HandcuffsConstants.PROMPT_TEXT)
	part:SetAttribute("InteractDistance", HandcuffsConstants.ARREST_RANGE)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = humanoidRootPart
	weldConstraint.Part1 = part
	weldConstraint.Parent = part
	part.Parent = character
	CollectionService:AddTag(part, "InteractionPrompt")
	self._promptsByPlayer[player] = part
	local maid = Janitor.new()
	self._promptJanitor:Add(maid, "Destroy", player)
	maid:Add(part)
	maid:AddPromise(InteractionPrompt:WaitForInstance(part):andThen(function(p)
		if self._promptsByPlayer[player] ~= part then
			return
		end

		maid:Add(p.Interacted:Connect(function()
			local character2 = localPlayer.Character

			if character2 ~= nil and character2:FindFirstChild(HandcuffsConstants.BUSY_TAG_NAME) == nil then
				local character3 = player.Character

				if character3 ~= nil and character3:FindFirstChild(HandcuffsConstants.BUSY_TAG_NAME) == nil then
					Remotes.fireServerComponent(self.Instance, "RequestArrest", player)
				end
			end
		end))
	end))
end

function v:_updateNearbyPrompts()
	if not (self._isEquipped and self._isLocalOwner) then
		return
	end

	local rootPart = getRootPart(localPlayer.Character) -- equivalent call inferred; original call site unknown

	if rootPart ~= nil then
		local character2 = localPlayer.Character

		if character2 ~= nil and character2:FindFirstChild(HandcuffsConstants.BUSY_TAG_NAME) == nil then
			local v2 = {}

			for _, v3 in Players:GetPlayers() do
				if v3 == localPlayer then
					continue
				end

				local character3 = v3.Character

				if not (character3 ~= nil and character3:FindFirstChild(HandcuffsConstants.BUSY_TAG_NAME) == nil) then
					continue
				end

				local rootPart2 = getRootPart(v3.Character) -- equivalent call inferred; original call site unknown

				if rootPart2 == nil or (rootPart.Position - rootPart2.Position).Magnitude > HandcuffsConstants.ARREST_RANGE then
					continue
				end

				v2[v3] = true
				self:_createPrompt(v3)
			end

			local v3 = {}

			for k in self._promptsByPlayer do
				if v2[k] ~= true then
					table.insert(v3, k)
				end
			end

			for _, v4 in v3 do
				self:_destroyPrompt(v4)
			end

			return
		end
	end

	self:_clearAllPrompts()
end

function v:_onEquipped()
	if self._isEquipped then
		return
	end

	self._isLocalOwner = self:_getOwningPlayer() == localPlayer

	if not self._isLocalOwner then
		return
	end

	self._isEquipped = true
	local v2 = 0
	self._equipJanitor:Add(RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - v2 < HandcuffsConstants.SCAN_INTERVAL then
			return
		end

		v2 = now
		self:_updateNearbyPrompts()
	end))
end

function v:_onUnequipped()
	if not self._isLocalOwner then
		self._isEquipped = false
		return
	end

	self._isEquipped = false
	self:_clearAllPrompts()
	self._equipJanitor:Cleanup()
end

function v:_setDanglingDisabledForArrest(flag: boolean)
	local _danglingTool = self._danglingTool

	if _danglingTool == nil then
		return
	end

	if flag then
		_danglingTool:Disable(true)
	else
		_danglingTool:Enable()
	end
end

function v:_onArrestStarted(_, p: string)
	self:_clearAllPrompts()
	self:_setCancelHandler(function()
		Remotes.fireServerComponent(self.Instance, "CancelArrest")
	end)

	if p == "Officer" then
		stopLocalEmote() -- equivalent call inferred; original call site unknown
		self:_setDanglingDisabledForArrest(true)
	elseif p == "Cuffed" then
		self:_startEscortAnimation()
	end
end

function v:_onArrestEnded()
	self:_clearCancelHandler()
	self:_stopEscortAnimation()
	self:_setDanglingDisabledForArrest(false)
	self._arrestJanitor:Cleanup()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "IncomingArrestRequest", function(p: string, p2)
		PetController.ShowIncomingRequest(p, p2, function(flag: boolean)
			if flag and EmotesController.IsPlayingEmote() then
				task.spawn(EmotesController.StopEmote)
			end

			Remotes.fireServerComponent(instance, "RespondToArrestRequest", flag)
		end)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "ArrestStarted", function(p, p2: string)
		self:_onArrestStarted(p, p2)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(instance, "ArrestEnded", function()
		self:_onArrestEnded()
	end))
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if self:_getOwningPlayer() == localPlayer and self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self:_clearCancelHandler()
	self:_stopEscortAnimation()
	self:_setDanglingDisabledForArrest(false)
	self:_clearAllPrompts()
	self._Janitor:Destroy()
end

return v