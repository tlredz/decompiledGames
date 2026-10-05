local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.AssetBillboardController)
local AssetChatBubble = require(ReplicatedStorage.Client.UI.AssetChatBubble)
local Assets = require(ReplicatedStorage.Data.Assets)
local AssetModels = require(ReplicatedStorage.Shared.Modules.AssetModels)
require(script.Parent.AssetMovementBatch)
local AssetRuntime = require(ReplicatedStorage.Shared.Types.AssetRuntime)
local AssetWanderSimulator = require(script.Parent.AssetWanderSimulator)
local Audio = require(ReplicatedStorage.Shared.Audio)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local ItemDisplay = require(ReplicatedStorage.Shared.Modules.ItemDisplay)
local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
local Player = require(ReplicatedStorage.Shared.Player)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local rescale = VFX.Rescale
local SfxRework = require(ReplicatedStorage.Data.SfxRework)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Parent.Types)
local AssetComponent = {}
AssetComponent.__index = AssetComponent
local global = SfxRework.Global("GreetingRun")
local global2 = SfxRework.Global("GreetingLove")
local global3 = SfxRework.Global("Jump")
local smokeTrail = ReplicatedStorage.Assets.Particles.Pets.SmokeTrail
assert(smokeTrail:IsA("Attachment"), "SmokeTrail pet particle template must be an Attachment")
local love = ReplicatedStorage.Assets.Particles.Pets.Love
assert(love:IsA("Attachment"), "Love pet particle template must be an Attachment")

function AssetComponent.new(record, owner, p, p2, billboards, movementBatch, cframe: CFrame?)
	assert(AssetRuntime.SchemaValidation.RuntimeAssetRecord(record), "Invalid runtime asset record")
	t.strict(t.instanceIsA("Player"))(owner)
	t.strict(t.instanceIsA("BasePart"))(p)
	t.strict(t.Instance)(p2)
	local object = setmetatable({}, AssetComponent)
	object._trove = Trove.new()
	object._record = record
	object._owner = owner
	object._billboards = billboards
	object._movementBatch = movementBatch
	object._hiddenTransparencySnapshot = nil
	object._hiddenDecalSnapshot = nil
	object._hiddenEffectSnapshot = nil
	object._model = ItemDisplay.CreateWanderingAssetModel(record.OwnerUserId, record.UID, record.ItemData, p2)
	object._trove:Connect(object._model.DescendantAdded, function(instance)
		local _hiddenTransparencySnapshot = object._hiddenTransparencySnapshot

		if _hiddenTransparencySnapshot ~= nil and instance:IsA("BasePart") and _hiddenTransparencySnapshot[instance] == nil then
			_hiddenTransparencySnapshot[instance] = instance.Transparency
			instance.Transparency = 1
		end

		local _hiddenDecalSnapshot = object._hiddenDecalSnapshot

		if _hiddenDecalSnapshot ~= nil and instance:IsA("Decal") and _hiddenDecalSnapshot[instance] == nil then
			_hiddenDecalSnapshot[instance] = instance.Transparency
			instance.Transparency = 1
		end

		local _hiddenEffectSnapshot = object._hiddenEffectSnapshot

		if _hiddenEffectSnapshot == nil or not (instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail")) then
			return
		end

		if _hiddenEffectSnapshot[instance] == nil then
			_hiddenEffectSnapshot[instance] = instance.Enabled
			instance.Enabled = false
		end
	end)
	object._rootPart = assert(object._model.PrimaryPart, (`Asset model {object._model.Name} must have a PrimaryPart`))
	local part = assert(
		object._model:FindFirstChild("CENTER"),
		(`Asset model {object._model.Name} must contain CENTER`)
	)
	assert(part:IsA("BasePart"), (`Asset model {object._model.Name}.CENTER must be a BasePart`))
	object._centerPart = part
	local v, v2 = ModelBounds(object._model)
	local v3 = object._model:GetPivot():PointToObjectSpace(v.Position).Y - v2.Y * 0.5
	local visibleBoundsData = AssetModels.GetVisibleBoundsData(record.ItemData.Category)
	local v4 = visibleBoundsData.Size / visibleBoundsData.TemplateScale
	local v5 = 2.5 + v2.Z * 0.5 * 0.8
	local v6 = (math.max(v2.Y, 4.5) / 4.5) ^ 0.7 + math.max((math.max(v2.X, v2.Z) - 5.625) / 4.5, 0) ^ 0.65 * 1.15
	object._wanderSimulator = AssetWanderSimulator.new(
		record.Seed,
		owner,
		p,
		record.ItemData,
		record.IsFirstPlacement == true,
		v5,
		v6
	)
	local parent = assert(
		assert(object._model:FindFirstChild("Model"), (`Asset model {object._model.Name} must contain Model`)):FindFirstChildWhichIsA("AnimationController"),
		(`Asset model {object._model.Name}.Model must contain AnimationController`)
	)
	local animator = parent:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
	animator.Parent = parent
	local v8 = Assets.Directory[record.ItemData.Category]
	local idle = v8.Animations.Idle
	local walk = v8.Animations.Walk
	object._idleTrack = nil
	object._walkTrack = nil

	if object._model:GetAttribute("AnimationsDisabled") ~= true then
		assert(idle ~= nil, (`Missing Idle animation for {record.ItemData.Category}`))
		assert(walk ~= nil, (`Missing Walk animation for {record.ItemData.Category}`))
		local track = animator:LoadAnimation(idle)
		local track2 = animator:LoadAnimation(walk)
		track.Looped = true
		track2.Looped = true
		object._idleTrack = track
		object._walkTrack = track2
	end

	object._walkAnimationReferenceSpeed = v8.WalkAnimationReferenceSpeed or 8
	object._animationTransitionFadeDuration = v8.Animations.TransitionFadeDuration
	object._walkAnimationAlwaysOn = object._animationTransitionFadeDuration == 0
	object._currentTrack = nil
	object._idleTransitionRemaining = 0
	object._wasJumping = false
	object._greetingEffectsActive = false
	object._greetingEffectScale = math.clamp((math.max(v2.X, v2.Y, v2.Z) / 6) ^ 0.5, 0.7, 6)
	object._greetingSmokeAttachment = nil
	object._greetingLoveAttachment = nil
	object._greetingRunLoopSound = nil
	object._greetingLoveLoopSound = nil
	local v9 = math.max(math.max(v2.X, v2.Y, v2.Z) / 6 - 1, 0) ^ 0.5
	local v10 = math.clamp(v9 + 1, 1, 3)
	local v11 = math.clamp(v9 + 1, 1, 2)
	object._jumpSoundVolume = v10 * 0.75
	object._jumpSoundMaxDistance = v11 * 50
	object._jumpSounds = {}
	object._walkSound = nil
	object._walkSoundBasePlaybackSpeed = 1
	object._walkSoundTargetVolume = 0
	object._walkSoundFadeTween = nil
	object._walkSoundWasMoving = false
	object._simulationWasMoving = false
	object._randomIdleSound = nil
	object._randomIdleRandom = Random.new(record.Seed)
	object._soundsSuppressed = false
	local resolved = SfxRework.Resolve(record.ItemData.Category, "Walk", v8.WalkSound)
	local resolved2 = SfxRework.Resolve(record.ItemData.Category, "Idle", v8.RandomIdleSound)

	if resolved ~= nil or resolved2 ~= nil then
		local part2 = Instance.new("Part")
		part2.Name = "AssetWalkSoundEmitter"
		part2.Anchored = false
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Massless = true
		part2.Transparency = 1
		part2.Size = createVector(0.05, 0.05, 0.05)
		part2.CFrame = object._rootPart.CFrame * CFrame.new(0, -v2.Y * 0.5, 0)
		part2.Parent = object._model
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Name = "AssetWalkSoundEmitterWeld"
		weldConstraint.Part0 = part2
		weldConstraint.Part1 = object._rootPart
		weldConstraint.Parent = part2
		local v12 = math.max(math.max(v2.X, v2.Y, v2.Z) / 6 - 1, 0) ^ 0.5
		local v13 = math.clamp(v12 + 1, 1, 5)
		local v14 = math.clamp(v12 + 1, 1, 3)

		if resolved ~= nil then
			local sound = Instance.new("Sound")
			sound.Name = "AssetWalkSound"
			Audio.Configure(sound, resolved)
			sound.Looped = true
			object._walkSoundBasePlaybackSpeed = sound.PlaybackSpeed
			object._walkSoundTargetVolume = sound.Volume * v13
			sound.RollOffMaxDistance = math.min(sound.RollOffMaxDistance * v14, 120)
			sound.Volume = 0
			sound.Parent = part2
			object._walkSound = sound
		end

		if resolved2 ~= nil then
			local sound = Instance.new("Sound")
			sound.Name = "AssetRandomIdleSound"
			Audio.Configure(sound, resolved2)
			sound.Volume *= v13
			sound.RollOffMaxDistance *= v14
			sound.Parent = part2
			object._randomIdleSound = sound
		end

		object._trove:Add(part2)
	end

	local v12 = v4.X > 6.0229997634887695 or v4.Y > 4.925000190734863 or v4.Z > 3.3399999141693115
	object._chatBubble = AssetChatBubble.new(object._model, object._centerPart, v12)
	object._bubbleSuppressionActive = false
	local v13 = cframe or AssetComponent._initialCFrame(record, p)
	object._model:PivotTo(v13)
	object._movementBatch:Add(
		object._model,
		{ object._rootPart },
		v13,
		v3,
		p,
		owner == Players.LocalPlayer,
		function(p3: number, flag: boolean)
			object:_step(p3, flag)
		end
	)
	local _walkTrack

	if object._walkAnimationAlwaysOn then
		_walkTrack = object._walkTrack
	else
		_walkTrack = object._idleTrack
	end

	if _walkTrack ~= nil then
		object:_play(_walkTrack)
	end

	return object
end

function AssetComponent:_tryPlayRandomIdleSound()
	local _randomIdleSound = self._randomIdleSound

	if self._soundsSuppressed or _randomIdleSound == nil or self._randomIdleRandom:NextInteger(1, 13) ~= 1 then
		return
	end

	_randomIdleSound.TimePosition = 0
	_randomIdleSound:Play()
end

function AssetComponent._initialCFrame(p, instance)
	local random = Random.new(p.Seed)
	local v = instance.Size * 0.5
	local position = (instance.CFrame * CFrame.new(random:NextNumber(-v.X, v.X), 0, random:NextNumber(-v.Z, v.Z))).Position
	return CFrame.new(position) * CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0)
end

function AssetComponent:_play(currentTrack)
	if self._currentTrack == currentTrack then
		return
	end

	if self._currentTrack ~= nil then
		self._currentTrack:Stop(self._animationTransitionFadeDuration or 0.35)
	end

	self._currentTrack = currentTrack
	currentTrack:Play(self._animationTransitionFadeDuration or 0.5)
end

function AssetComponent:_walkAnimationSpeed(p2: number)
	return (math.clamp(p2 / self._walkAnimationReferenceSpeed, 0.3, 5))
end

function AssetComponent:_playJumpSound(vector2: Vector3)
	t.strict(t.Vector3)(vector2)

	if self._soundsSuppressed then
		return
	end

	local primaryPart = Player.FindPrimaryPart(Players.LocalPlayer)

	if primaryPart == nil or (primaryPart.Position - vector2).Magnitude > self._jumpSoundMaxDistance then
		return
	end

	local v = Audio.Play(global3, vector2, {
		Volume = self._jumpSoundVolume,
		MaxDistance = self._jumpSoundMaxDistance
	})

	if v ~= nil then
		self._jumpSounds[v] = true
		v.Destroying:Once(function()
			self._jumpSounds[v] = nil
		end)
	end
end

function AssetComponent._setAttachmentEmittersEnabled(folder, enabled: boolean)
	t.strict(t.Instance)(folder)
	t.strict(t.boolean)(enabled)

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

function AssetComponent._prepareGreetingAttachment(instance, name: string, p: number)
	t.strict(t.Instance)(instance)
	t.strict(t.string)(name)
	t.strict(t.number)(p)
	local clone = instance:Clone()
	clone.Name = name

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		rescale(emitter, p)
		emitter.Enabled = false
	end

	return clone
end

function AssetComponent:_isLocalPlayerNear(p2: number)
	t.strict(t.number)(p2)
	local primaryPart = Player.FindPrimaryPart(Players.LocalPlayer)
	return primaryPart ~= nil and (primaryPart.Position - self._rootPart.Position).Magnitude <= p2
end

function AssetComponent:_getGreetingSmokeAttachment()
	local _greetingSmokeAttachment = self._greetingSmokeAttachment

	if _greetingSmokeAttachment ~= nil then
		return _greetingSmokeAttachment
	end

	local _prepareGreetingAttachment = AssetComponent._prepareGreetingAttachment(
		smokeTrail,
		"AssetGreetingSmokeTrail",
		self._greetingEffectScale
	)
	_prepareGreetingAttachment.Parent = self._rootPart
	self._greetingSmokeAttachment = _prepareGreetingAttachment
	return _prepareGreetingAttachment
end

function AssetComponent:_getGreetingLoveAttachment()
	local _greetingLoveAttachment = self._greetingLoveAttachment

	if _greetingLoveAttachment ~= nil then
		return _greetingLoveAttachment
	end

	local _prepareGreetingAttachment = AssetComponent._prepareGreetingAttachment(
		love,
		"AssetGreetingLove",
		self._greetingEffectScale
	)
	_prepareGreetingAttachment.Parent = self._rootPart
	self._greetingLoveAttachment = _prepareGreetingAttachment
	return _prepareGreetingAttachment
end

function AssetComponent:_stopGreetingLoopSounds()
	local _greetingRunLoopSound = self._greetingRunLoopSound

	if _greetingRunLoopSound ~= nil then
		self._greetingRunLoopSound = nil
		_greetingRunLoopSound:Stop()
		_greetingRunLoopSound:Destroy()
	end

	local _greetingLoveLoopSound = self._greetingLoveLoopSound

	if _greetingLoveLoopSound ~= nil then
		self._greetingLoveLoopSound = nil
		_greetingLoveLoopSound:Stop()
		_greetingLoveLoopSound:Destroy()
	end
end

function AssetComponent:_startGreetingLoopSounds()
	if self._soundsSuppressed or not self:_isLocalPlayerNear(80) then
		return
	end

	if self._greetingRunLoopSound == nil then
		self._greetingRunLoopSound = Audio.Play(global, self._rootPart, {
			Volume = 0.75,
			MaxDistance = 80,
			Looped = true
		})
	end

	if self._greetingLoveLoopSound == nil then
		self._greetingLoveLoopSound = Audio.Play(global2, self._rootPart, {
			Volume = 0.75,
			MaxDistance = 80,
			Looped = true
		})
	end
end

function AssetComponent:_setGreetingEffectsActive(greetingEffectsActive: boolean)
	t.strict(t.boolean)(greetingEffectsActive)

	if greetingEffectsActive then
		if not self._greetingEffectsActive then
			AssetComponent._setAttachmentEmittersEnabled(self:_getGreetingSmokeAttachment(), true)
			AssetComponent._setAttachmentEmittersEnabled(self:_getGreetingLoveAttachment(), true)
		end

		if self:_isLocalPlayerNear(80) then
			self:_startGreetingLoopSounds()
		else
			self:_stopGreetingLoopSounds()
		end
	elseif self._greetingEffectsActive then
		local _greetingSmokeAttachment = self._greetingSmokeAttachment

		if _greetingSmokeAttachment ~= nil then
			AssetComponent._setAttachmentEmittersEnabled(_greetingSmokeAttachment, false)
		end

		local _greetingLoveAttachment = self._greetingLoveAttachment

		if _greetingLoveAttachment ~= nil then
			AssetComponent._setAttachmentEmittersEnabled(_greetingLoveAttachment, false)
		end

		self:_stopGreetingLoopSounds()
	end

	self._greetingEffectsActive = greetingEffectsActive
end

function AssetComponent:_destroyGreetingEffects()
	self:_setGreetingEffectsActive(false)
	local _greetingSmokeAttachment = self._greetingSmokeAttachment

	if _greetingSmokeAttachment ~= nil then
		self._greetingSmokeAttachment = nil
		_greetingSmokeAttachment:Destroy()
	end

	local _greetingLoveAttachment = self._greetingLoveAttachment

	if _greetingLoveAttachment ~= nil then
		self._greetingLoveAttachment = nil
		_greetingLoveAttachment:Destroy()
	end
end

function AssetComponent:_releaseBubbleSuppression()
	if not self._bubbleSuppressionActive then
		return
	end

	self._bubbleSuppressionActive = false
	self._billboards:SetSuppressed(self._model, false)
end

function AssetComponent:_displayChatBubble(p: string)
	if not self._bubbleSuppressionActive then
		self._bubbleSuppressionActive = true
		self._billboards:SetSuppressed(self._model, true)
	end

	self._chatBubble:Say(p, function()
		self:_releaseBubbleSuppression()
	end)
end

function AssetComponent:_setWalkSoundMoving(flag: boolean, p: number)
	if self._soundsSuppressed then
		flag = false
	end

	local _walkSound = self._walkSound

	if _walkSound == nil then
		return
	end

	if flag then
		local v = math.clamp(p / 8, 0.3, 5)
		_walkSound.PlaybackSpeed = self._walkSoundBasePlaybackSpeed * v

		if not self._walkSoundWasMoving then
			local _walkSoundFadeTween = self._walkSoundFadeTween

			if _walkSoundFadeTween ~= nil then
				_walkSoundFadeTween:Cancel()
			end

			_walkSound.Volume = 0

			if _walkSound.IsLoaded and _walkSound.TimeLength > 2 then
				_walkSound.TimePosition = math.random() * (_walkSound.TimeLength - 1)
			end

			_walkSound:Play()
		end

		if not self._walkSoundWasMoving then
			local fadeTo = Audio.FadeTo(_walkSound, {
				Volume = self._walkSoundTargetVolume,
				Seconds = 0.1
			})
			self._walkSoundFadeTween = fadeTo
			fadeTo:Play()
		end

		self._walkSoundWasMoving = true
	else
		if not self._walkSoundWasMoving then
			return
		end

		self._walkSoundWasMoving = false
		local _walkSoundFadeTween = self._walkSoundFadeTween

		if _walkSoundFadeTween ~= nil then
			_walkSoundFadeTween:Cancel()
		end

		local fadeTo = Audio.FadeTo(_walkSound, {
			Volume = 0,
			Seconds = 0.1
		})
		self._walkSoundFadeTween = fadeTo
		fadeTo:Play()
		fadeTo.Completed:Once(function()
			if self._walkSoundFadeTween == fadeTo then
				self._walkSoundFadeTween = nil
				_walkSound:Stop()
			end
		end)
	end
end

function AssetComponent:_setSoundsSuppressed(soundsSuppressed: boolean)
	t.strict(t.boolean)(soundsSuppressed)

	if self._soundsSuppressed == soundsSuppressed then
		return
	end

	self._soundsSuppressed = soundsSuppressed

	if not soundsSuppressed then
		return
	end

	self:_stopGreetingLoopSounds()

	for k in self._jumpSounds do
		k:Stop()
	end

	table.clear(self._jumpSounds)
	local _randomIdleSound = self._randomIdleSound

	if _randomIdleSound ~= nil then
		_randomIdleSound:Stop()
	end

	self:_setWalkSoundMoving(false, 0)
end

function AssetComponent:_step(p: number, flag: boolean)
	local isHidden = self:IsHidden()
	self:_setSoundsSuppressed(isHidden or MusicDirector.HasCustomTreadmill() or flag)
	local simulationCFrame = self._movementBatch:GetSimulationCFrame(self._model)
	local v, simulationWasMoving, v3, v4, v5, v6 = self._wanderSimulator:Step(p, simulationCFrame)

	if isHidden then
		self._simulationWasMoving = simulationWasMoving
		self._wasJumping = not v3
		self._movementBatch:SetGroundingEnabled(self._model, v3)
		self._movementBatch:SetTarget(self._model, v)
	else
		local v7 = self._simulationWasMoving and not simulationWasMoving
		self._simulationWasMoving = simulationWasMoving

		if v6 ~= nil then
			self:_displayChatBubble(v6)
		end

		self:_setGreetingEffectsActive(v5 and not flag)
		local wasJumping = not v3

		if wasJumping and not self._wasJumping then
			self:_playJumpSound(simulationCFrame.Position)
		end

		self._wasJumping = wasJumping
		self._movementBatch:SetGroundingEnabled(self._model, v3)
		self._movementBatch:SetTarget(self._model, v)

		if v7 then
			self:_tryPlayRandomIdleSound()
		end

		self:_setWalkSoundMoving(simulationWasMoving and not flag, v4)
		local _idleTrack = self._idleTrack
		local _walkTrack = self._walkTrack

		if _idleTrack == nil or _walkTrack == nil then
			return
		end

		if self._walkAnimationAlwaysOn then
			self._idleTransitionRemaining = 0
			self:_play(_walkTrack)
			_walkTrack:AdjustSpeed(flag and 0 or self:_walkAnimationSpeed(v4))
		elseif flag then
			self._idleTransitionRemaining = 0
			self:_play(_idleTrack)
			_idleTrack:AdjustSpeed(1)
		else
			if simulationWasMoving then
				self._idleTransitionRemaining = 0.28
				self:_play(_walkTrack)
			else
				if self._currentTrack ~= _walkTrack or not (self._idleTransitionRemaining > 0) then
					self:_play(_idleTrack)
					return
				end

				self._idleTransitionRemaining = math.max(self._idleTransitionRemaining - p, 0)
			end

			_walkTrack:AdjustSpeed(self:_walkAnimationSpeed(v4))
		end
	end
end

function AssetComponent:GetOwnerUserId()
	return self._record.OwnerUserId
end

function AssetComponent:GetUid()
	return self._record.UID
end

function AssetComponent:GetModel()
	return self._model
end

function AssetComponent:GetRuntimeRecord()
	return self._record
end

function AssetComponent:IsHidden()
	return self._hiddenTransparencySnapshot ~= nil
end

function AssetComponent:SetHidden(flag: boolean)
	t.strict(t.boolean)(flag)

	if self:IsHidden() == flag then
		return
	end

	self._movementBatch:SetHidden(self._model, flag)

	if flag then
		self:_setSoundsSuppressed(true)
		self:_setWalkSoundMoving(false, 0)

		if self._idleTrack ~= nil then
			self._idleTrack:Stop(0)
		end

		if self._walkTrack ~= nil then
			self._walkTrack:Stop(0)
		end

		self._currentTrack = nil
		self._idleTransitionRemaining = 0
		self:_setGreetingEffectsActive(false)
		self._chatBubble:Mute(true)
		self:_releaseBubbleSuppression()
		local transparenciesByDescendant = {}
		local transparenciesByDescendant2 = {}
		local enabledsByDescendant = {}
		self._hiddenTransparencySnapshot = transparenciesByDescendant
		self._hiddenDecalSnapshot = transparenciesByDescendant2
		self._hiddenEffectSnapshot = enabledsByDescendant

		for _, descendant in ipairs(self._model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			elseif descendant:IsA("Decal") then
				transparenciesByDescendant2[descendant] = descendant.Transparency
				descendant.Transparency = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
				enabledsByDescendant[descendant] = descendant.Enabled
				descendant.Enabled = false
			end
		end
	else
		local v = assert(self._hiddenTransparencySnapshot, "Hidden asset must own a transparency snapshot")
		self._hiddenTransparencySnapshot = nil

		for k, transparency in pairs(v) do
			if k.Parent ~= nil then
				k.Transparency = transparency
			end
		end

		table.clear(v)
		local _hiddenDecalSnapshot = self._hiddenDecalSnapshot
		self._hiddenDecalSnapshot = nil

		if _hiddenDecalSnapshot ~= nil then
			for k, transparency in pairs(_hiddenDecalSnapshot) do
				if k.Parent ~= nil then
					k.Transparency = transparency
				end
			end

			table.clear(_hiddenDecalSnapshot)
		end

		local _hiddenEffectSnapshot = self._hiddenEffectSnapshot
		self._hiddenEffectSnapshot = nil

		if _hiddenEffectSnapshot ~= nil then
			for k, enabled in pairs(_hiddenEffectSnapshot) do
				if k.Parent ~= nil then
					k.Enabled = enabled
				end
			end

			table.clear(_hiddenEffectSnapshot)
		end

		self._chatBubble:Mute(false)
	end
end

function AssetComponent:SetRuntimeRecord(record)
	assert(AssetRuntime.SchemaValidation.RuntimeAssetRecord(record), "Invalid runtime asset record")
	self._record = record
	self._wanderSimulator:SetItemData(record.ItemData, record.IsFirstPlacement == true)
end

function AssetComponent:SetAssetArea(p)
	t.strict(t.instanceIsA("BasePart"))(p)
	self._wanderSimulator:SetAssetArea(p)
	self._movementBatch:SetAssetArea(self._model, p)
end

function AssetComponent:Destroy()
	self:_destroyGreetingEffects()
	self._chatBubble:Destroy()
	self._movementBatch:Remove(self._model)
	self._trove:Destroy()
	self._model:Destroy()
end

return AssetComponent