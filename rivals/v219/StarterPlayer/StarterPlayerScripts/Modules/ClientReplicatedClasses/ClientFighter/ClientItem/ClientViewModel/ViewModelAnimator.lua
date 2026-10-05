local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local SoundLibrary = require(ReplicatedStorage.Modules.SoundLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ViewModelAnimator = {}
ViewModelAnimator.__index = ViewModelAnimator

function ViewModelAnimator.new(clientViewModel)
	local self = setmetatable({}, ViewModelAnimator)
	self.AnimationPlayed = Signal.new()
	self.AnimationStopped = Signal.new()
	self.ClientViewModel = clientViewModel
	self.SprintTrackSpeed = 1
	self._viewmodel_animations = self.ClientViewModel.Info.Animations
	self._play_animations_instantly = self.ClientViewModel.Info.PlayAnimationsInstantly
	self._render_cooldown = 0
	self._inspect_cooldown = 0
	self._animations_loaded = false
	self._animation_cleanup = {}
	self._animation_tracks = {}
	self._animation_hashes = {}
	self._animation_threads = {}
	self._animation_keys_lookup = {}
	self._equip_animation = nil
	self._idle_animation = nil
	self._inspect_animation = nil
	self._rare_inspect_animation = nil
	self._sprint_animation = nil
	self._should_override_previous_animations_on_play = false
	self._last_animation_key_played = nil
	self._blocked_animations = {}
	self:_Init()
	return self
end

function ViewModelAnimator:HasEmptyReloadAnimations()
	return self._viewmodel_animations.EmptyReload ~= nil or self._viewmodel_animations.EmptyReloadStart ~= nil
end

function ViewModelAnimator:IsRenderingDisabled()
	return tick() < self._render_cooldown
end

function ViewModelAnimator:IsAnimationPlaying(p)
	local animationTrack = self:GetAnimationTrack(p)
	return animationTrack and animationTrack.IsPlaying
end

function ViewModelAnimator:AreAnimationsPlaying(items)
	for _, item in pairs(items) do
		if self:IsAnimationPlaying(item) then
			return true
		end
	end
end

function ViewModelAnimator:GetEquipAnimationKey()
	return self._equip_animation
end

function ViewModelAnimator:GetIdleAnimationKey()
	return self._idle_animation
end

function ViewModelAnimator:GetInspectAnimationKey()
	return self._inspect_animation
end

function ViewModelAnimator:GetRareInspectAnimationKey()
	return self._rare_inspect_animation
end

function ViewModelAnimator:GetAnimationTrack(p2)
	return self._animation_tracks[p2]
end

function ViewModelAnimator:GetAnimationKeys(p)
	if self._animation_keys_lookup[p] then
		return self._animation_keys_lookup[p]
	end

	local result = {}

	for i = 1, 1e999 do
		local v = p .. i

		if not self:GetAnimationTrack(v) then
			break
		end

		table.insert(result, v)
	end

	self._animation_keys_lookup[p] = result
	return result
end

function ViewModelAnimator:IsInspectAnimationPlaying()
	return self:IsAnimationPlaying(self._inspect_animation) or self:IsAnimationPlaying(self._rare_inspect_animation)
end

function ViewModelAnimator:GetSprintTrack()
	return self:GetAnimationTrack(self._sprint_animation)
end

function ViewModelAnimator:IsAnimationHashValid(p2, p3)
	return self._animation_hashes[p2] == p3
end

function ViewModelAnimator:AnimationWait(p, p2, p3)
	return wait(p3) and self:IsAnimationHashValid(p, p2)
end

function ViewModelAnimator:SetInspectCooldown(p2)
	self._inspect_cooldown = tick() + p2
end

function ViewModelAnimator:CreateSound(...)
	return self.ClientViewModel:CreateSound(...)
end

function ViewModelAnimator:OverridePreviousAnimationsOnPlay(should_override_previous_animations_on_play)
	self._should_override_previous_animations_on_play = should_override_previous_animations_on_play
end

function ViewModelAnimator:BlockAnimation(value, value2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	assert(typeof(value2) == "number", "Argument 2 invalid, expected a number")
	self._blocked_animations[value] = tick() + value2
end

function ViewModelAnimator:PlayAnimation(last_animation_key_played, value, p, p2, value2)
	assert(typeof(last_animation_key_played) == "string", "Argument 1 invalid, expected a string")
	assert(not value or typeof(value) == "number", "Argument 2 invalid, expected a number")

	if tick() < (self._blocked_animations[last_animation_key_played] or 0) then
		return
	end

	local v = self._play_animations_instantly and 0 or p

	if value then
		self:SetInspectCooldown(value)
		self:StopInspecting()
	end

	local _AnimationKeyToName = self:_AnimationKeyToName(last_animation_key_played)

	if _AnimationKeyToName then
		self:_CancelAnimationSoundCallback(_AnimationKeyToName)
	end

	local _should_override_previous_animations_on_play = self._should_override_previous_animations_on_play or last_animation_key_played == self:GetInspectAnimationKey() or last_animation_key_played == self:GetRareInspectAnimationKey()

	if last_animation_key_played ~= self:GetIdleAnimationKey() and last_animation_key_played ~= self._sprint_animation and self._last_animation_key_played ~= self:GetIdleAnimationKey() and self._last_animation_key_played ~= self._sprint_animation then
		if _should_override_previous_animations_on_play and self._last_animation_key_played then
			self:StopAnimation(self._last_animation_key_played, 0)
		end

		self._last_animation_key_played = last_animation_key_played
	end

	local animationTrack = self:GetAnimationTrack(last_animation_key_played)

	if not animationTrack then
		warn("Animation key failed to play (not found): " .. tostring(last_animation_key_played))
		return
	end

	local _animation_hash = self._animation_hashes[_AnimationKeyToName]
	local v2 = AnimationLibrary.Info[_AnimationKeyToName]
	local v3 = v2.Speed * (value2 or 1)
	animationTrack:Play(v, p2, v3)

	if v2.SoundCallback then
		table.insert(
			self._animation_threads[_AnimationKeyToName],
			task.defer(v2.SoundCallback, self.ClientViewModel, v3, _animation_hash)
		)
	end

	if v2.EffectCallback then
		table.insert(
			self._animation_threads[_AnimationKeyToName],
			task.defer(v2.EffectCallback, self.ClientViewModel, v3, _animation_hash)
		)
	end

	self.AnimationPlayed:Fire(last_animation_key_played, _AnimationKeyToName, _animation_hash)
end

function ViewModelAnimator:PlayIdleAnimation()
	if self.ClientViewModel:IsEquipped() then
		self:PlayAnimation(self._idle_animation, nil, 0)
	end
end

function ViewModelAnimator:PlayEquipAnimation()
	if not self:GetAnimationTrack(self._equip_animation) then
		return
	end

	self:PlayAnimation(self._equip_animation)
	return true
end

function ViewModelAnimator:PlaySprintAnimation()
	self:PlayAnimation(self._sprint_animation)
end

function ViewModelAnimator:Inspect(p)
	assert(not p or typeof(p) == "boolean", "Argument 1 invalid, expected a boolean or nil")

	if tick() < self._inspect_cooldown or self.ClientViewModel.ClientItem:IsEquipping() then
		return false
	end

	self:StopAnimation(self._equip_animation, 0)
	local v = self:StopInspecting()

	if not p then
		if p == nil then
			p = self:GetAnimationTrack(self._rare_inspect_animation) and math.random() < 0.1
		else
			p = false
		end
	end

	if p then
		self:CreateSound(
			SoundLibrary.EquipSounds[math.random(#SoundLibrary.EquipSounds)],
			0.375,
			1.4 + 0.2 * math.random(),
			true,
			5
		)
		self:CreateSound("rbxassetid://13159969353", 0.25, 1 + 0.25 * math.random(), true, 5)
		self:PlayAnimation(self._rare_inspect_animation, nil, v and 0 or 0.2)
	else
		if not self:GetAnimationTrack(self._inspect_animation) then
			return false
		end

		self:CreateSound(
			SoundLibrary.EquipSounds[math.random(#SoundLibrary.EquipSounds)],
			0.375,
			1.4 + 0.2 * math.random(),
			true,
			5
		)
		self:PlayAnimation(self._inspect_animation, nil, v and 0 or 0.2)
	end

	return true, p
end

function ViewModelAnimator:StopAnimation(value, p, value2)
	assert(typeof(value) == "string", "Argument 1 invalid, expected a string")
	assert(not value2 or typeof(value2) == "number", "Argument 3 invalid, expected a number")
	local v = self._play_animations_instantly and 0 or p

	if value2 then
		self:SetInspectCooldown(value2)
		self:StopInspecting()
	end

	local _AnimationKeyToName = self:_AnimationKeyToName(value)

	if _AnimationKeyToName then
		self:_CancelAnimationSoundCallback(_AnimationKeyToName)
	end

	local animationTrack = self:GetAnimationTrack(value)

	if not animationTrack then
		return
	end

	animationTrack:Stop(v)
	self.AnimationStopped:Fire(value, _AnimationKeyToName)
end

function ViewModelAnimator:StopInspecting()
	if self:GetAnimationTrack(self._inspect_animation) and self:GetAnimationTrack(self._inspect_animation).IsPlaying then
		self:StopAnimation(self._inspect_animation, 0.1)
		return 0.1
	end

	if self:GetAnimationTrack(self._rare_inspect_animation) and self:GetAnimationTrack(self._rare_inspect_animation).IsPlaying then
		self:StopAnimation(self._rare_inspect_animation, 0.1)
		return 0.1
	end
end

function ViewModelAnimator:StopSprintAnimation()
	self:StopAnimation(self._sprint_animation)
end

function ViewModelAnimator:StopAllAnimations()
	for k in pairs(self._animation_tracks) do
		self:StopAnimation(k)
	end
end

function ViewModelAnimator:ChangeEquipAnimation(value)
	local equip_animation = value or "Equip"

	if equip_animation == self._equip_animation then
		return
	end

	self._equip_animation = equip_animation
end

function ViewModelAnimator:ChangeIdleAnimation(value)
	local idle_animation = value or "Idle"

	if idle_animation == self._idle_animation then
		return
	end

	if self._idle_animation then
		self:StopAnimation(self._idle_animation)
	end

	self._idle_animation = idle_animation
	self:PlayIdleAnimation()
end

function ViewModelAnimator:ChangeSprintAnimation(value)
	local sprint_animation = value or "Sprint"

	if sprint_animation == self._sprint_animation then
		return
	end

	if self._sprint_animation then
		self:StopAnimation(self._sprint_animation)
	end

	self._sprint_animation = sprint_animation
	self.SprintTrackSpeed = not self:_AnimationKeyToName(self._sprint_animation) and 1 or AnimationLibrary.Info[self:_AnimationKeyToName(self._sprint_animation)].Speed or 1
end

function ViewModelAnimator:ChangeInspectAnimation(value)
	local inspect_animation = value or "Inspect"

	if inspect_animation == self._inspect_animation then
		return
	end

	if self._inspect_animation then
		self:StopAnimation(self._inspect_animation)
	end

	self._inspect_animation = inspect_animation
end

function ViewModelAnimator:ChangeRareInspectAnimation(value)
	local rare_inspect_animation = value ~= "nil" and (value or "RareInspect") or nil

	if rare_inspect_animation == self._rare_inspect_animation then
		return
	end

	if self._rare_inspect_animation then
		self:StopAnimation(self._rare_inspect_animation)
	end

	self._rare_inspect_animation = rare_inspect_animation
end

function ViewModelAnimator:LoadAnimations()
	if self._animations_loaded or not self.ClientViewModel.Model:IsDescendantOf(game) then
		return
	end

	self._animations_loaded = true
	local v = {}

	local function preload_animation(p, p2)
		local animationID = AnimationLibrary.Info[p2].AnimationID
		local animation = Instance.new("Animation")
		animation.AnimationId = animationID
		table.insert(v, animation)
		table.insert(self._animation_cleanup, animation)
		local success, result = pcall(
			self.ClientViewModel.Model.AnimationController.Animator.LoadAnimation,
			self.ClientViewModel.Model.AnimationController.Animator,
			animation
		)

		if not success then
			warn("FAILED TO LOAD ANIMATION FOR " .. self.ClientViewModel.Name .. ": " .. p .. ", " .. p2 .. ", " .. animationID)
			return
		end

		table.insert(self._animation_cleanup, result)
		result.Stopped:Connect(function()
			self:_CancelAnimationSoundCallback(p2)
			self.AnimationStopped:Fire(p, p2)

			if self._play_animations_instantly then
				result:Stop(0)
			end
		end)
		self._animation_tracks[p] = result
	end

	for k, _viewmodel_animation in pairs(self._viewmodel_animations) do
		task.spawn(preload_animation, k, _viewmodel_animation)
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(v)
		self._render_cooldown = tick() + 0.1
	end)
	self._render_cooldown = tick() + 5
	self:ChangeEquipAnimation("Equip")
	self:ChangeIdleAnimation("Idle")
	self:ChangeSprintAnimation("Sprint")
	self:ChangeInspectAnimation("Inspect")
	self:ChangeRareInspectAnimation("RareInspect")
	self:PlayIdleAnimation()
end

function ViewModelAnimator:Destroy()
	self.AnimationPlayed:Destroy()
	self.AnimationStopped:Destroy()

	for _, v in pairs(self._animation_cleanup) do
		v:Destroy()
	end

	for _, _ in pairs(self._animation_threads) do
		for _, _animation_thread in pairs(self._animation_threads) do
			pcall(task.cancel, _animation_thread)
		end
	end

	self._animation_cleanup = {}
	self._animation_threads = {}
	self._animation_hashes = {}
end

function ViewModelAnimator:_ResetIdleAfterEquipping(p, p2, p3)
	local v = AnimationLibrary.Info[p2]
	local resetIdleTimestamp = v and v.ExtraInformation.ResetIdleTimestamp

	if p ~= "Equip" or not resetIdleTimestamp then
		return
	end

	wait(resetIdleTimestamp)

	if not self:IsAnimationHashValid(p2, p3) then
		return
	end

	local animationTrack = self:GetAnimationTrack(self:GetIdleAnimationKey())

	if not animationTrack then
		return
	end

	animationTrack.TimePosition = 0
end

function ViewModelAnimator:_CancelAnimationSoundCallback(p2)
	for _, v in pairs(self._animation_threads[p2] or {}) do
		pcall(task.cancel, v)
	end

	self._animation_threads[p2] = {}
	self._animation_hashes[p2] = (self._animation_hashes[p2] or 0) + 1
end

function ViewModelAnimator:_AnimationKeyToName(p2)
	return self._viewmodel_animations[p2]
end

function ViewModelAnimator:_Init()
	self.AnimationPlayed:Connect(function(p, p2, p3)
		self:_ResetIdleAfterEquipping(p, p2, p3)
	end)
end

return ViewModelAnimator