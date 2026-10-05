local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Utils.AnimationAssets)
local Audio = require(ReplicatedStorage.Shared.Audio)
require(ReplicatedStorage.Data.Guards)
local t = require(ReplicatedStorage.Packages.t)
local GuardPresentationComponent = {}
GuardPresentationComponent.__index = GuardPresentationComponent
GuardPresentationComponent.__class = "GuardPresentationComponent"

function GuardPresentationComponent.new(p, p2, data)
	t.strict(t.instanceIsA("BasePart"))(p)
	t.strict(t.Instance)(p2)
	t.strict(t.table)(data)
	local self = setmetatable({}, GuardPresentationComponent)
	self._afterWakeSoundConfigs = GuardPresentationComponent.NormalizeAfterWakeSoundConfigs(data.AfterWakeSound)
	local afterWakeSound

	if #self._afterWakeSoundConfigs > 0 then
		afterWakeSound = Audio.CreateConfigured(
			p,
			GuardPresentationComponent.CreateSoundFile(self._afterWakeSoundConfigs[1]),
			"AfterWakeSound"
		)
	end

	self._afterWakeSound = afterWakeSound
	self._afterWakeSoundAt = nil
	self._animationBaseWalkSpeed = data.AnimationBaseWalkSpeed or 7
	assert(self._animationBaseWalkSpeed > 0, (`Guard {data._id} animation base WalkSpeed must be greater than zero`))
	local footstepSound

	if data.FootstepSound ~= nil then
		footstepSound = Audio.CreateConfigured(
			p,
			GuardPresentationComponent.CreateSoundFile(data.FootstepSound),
			"FootstepSound"
		)
	end

	self._footstepSound = footstepSound
	local footstepPlaybackSpeed

	if data.FootstepSound ~= nil then
		footstepPlaybackSpeed = data.FootstepSound.PlaybackSpeed or 1
	end

	self._footstepPlaybackSpeed = footstepPlaybackSpeed
	self._hitSound = Audio.CreateConfigured(p, GuardPresentationComponent.CreateSoundFile(data.AttackSound), "Hit")
	self._hitTrack = GuardPresentationComponent.LoadTrack(p2, data.AttackAnimation, false)
	self._hitTrack.Priority = Enum.AnimationPriority.Action4
	self._idleTrack = GuardPresentationComponent.LoadTrack(p2, data.IdleAnimation, true)
	self._sleepSound = Audio.CreateConfigured(
		p,
		GuardPresentationComponent.CreateSoundFile(data.SleepSound),
		"SleepSound"
	)
	self._sleepTrack = GuardPresentationComponent.LoadTrack(p2, data.SleepAnimation, true)
	self._random = Random.new()
	self._wakeSound = Audio.CreateConfigured(p, GuardPresentationComponent.CreateSoundFile(data.WakeSound), "Detected")
	self._walkTrack = GuardPresentationComponent.LoadTrack(p2, data.WalkAnimation, true)
	return self
end

function GuardPresentationComponent.CreateSoundFile(data)
	return {
		SoundId = data.SoundIds or data.SoundId,
		Data = {
			Speed = data.PlaybackSpeed,
			Volume = data.Volume,
			MaxDistance = data.MaxDistance,
			Looped = data.Looped
		}
	}
end

function GuardPresentationComponent.NormalizeAfterWakeSoundConfigs(p)
	if p == nil then
		return {}
	end

	if typeof(p) == "table" and typeof(p.SoundId) == "string" and typeof(p.Volume) == "number" and typeof(p.MaxDistance) == "number" then
		return { p }
	end

	assert(#p > 0, "AfterWakeSound config array must not be empty")
	return p
end

function GuardPresentationComponent.LoadTrack(animator, animation, looped: boolean)
	t.strict(t.instanceIsA("Animation"))(animation)
	t.strict(t.boolean)(looped)
	local track = animator:LoadAnimation(animation)
	track.Looped = looped
	return track
end

function GuardPresentationComponent:Destroy()
	self._afterWakeSoundAt = nil
	self:StopWalkAnimation()
	self:StopIdleAnimation()
	self:StopFootstepSound()
	self._sleepTrack:Stop(0.1)
	self._hitTrack:Stop(0.1)

	if self._footstepSound ~= nil then
		self._footstepSound:Destroy()
	end

	if self._afterWakeSound ~= nil then
		self._afterWakeSound:Destroy()
	end

	self._hitSound:Destroy()
	self._sleepSound:Destroy()
	self._wakeSound:Destroy()
end

function GuardPresentationComponent:PlaySleep(p2: number)
	t.strict(t.number)(p2)

	if not self._sleepTrack.IsPlaying then
		self._sleepTrack:Play(p2)
	end

	if not self._sleepSound.IsPlaying then
		self._sleepSound.Looped = true
		self._sleepSound.TimePosition = 0
		self._sleepSound:Play()
	end
end

function GuardPresentationComponent:StopSleep(p2: number)
	t.strict(t.number)(p2)
	self._sleepTrack:Stop(p2)
	self._sleepSound:Stop()
end

function GuardPresentationComponent:PlayWake()
	self._wakeSound.TimePosition = 0
	self._wakeSound:Play()
end

function GuardPresentationComponent:PlayAfterWake()
	local _afterWakeSound = self._afterWakeSound

	if _afterWakeSound == nil then
		return
	end

	local _afterWakeSoundConfig = self._afterWakeSoundConfigs[self._random:NextInteger(1, #self._afterWakeSoundConfigs)]
	assert(_afterWakeSoundConfig ~= nil, "AfterWakeSound playback requires a configured sound")
	_afterWakeSound:Stop()
	Audio.Configure(_afterWakeSound, GuardPresentationComponent.CreateSoundFile(_afterWakeSoundConfig))
	_afterWakeSound.TimePosition = 0
	_afterWakeSound:Play()
end

function GuardPresentationComponent:ScheduleAfterWake(p2: number)
	t.strict(t.number)(p2)

	if self._afterWakeSound ~= nil then
		self._afterWakeSoundAt = p2 + 1
	end
end

function GuardPresentationComponent:CancelAfterWake()
	self._afterWakeSoundAt = nil
end

function GuardPresentationComponent:UpdateAfterWake(p: number, flag: boolean)
	t.strict(t.number)(p)
	t.strict(t.boolean)(flag)
	local _afterWakeSoundAt = self._afterWakeSoundAt

	if _afterWakeSoundAt == nil or p < _afterWakeSoundAt then
		return
	end

	self._afterWakeSoundAt = nil

	if flag then
		self:PlayAfterWake()
	end
end

function GuardPresentationComponent:PlayHit()
	self:StopWalkAnimation()
	self:StopFootstepSound()
	self:EnsureIdleAnimation()
	self._hitTrack.TimePosition = 0
	self._hitTrack:Play(0.05)
	local length = self._hitTrack.Length
	local v = math.max(length / 1.5, 1)
	self._hitTrack:AdjustSpeed(v)
	self._hitSound.TimePosition = 0
	self._hitSound:Play()
	return length / v
end

function GuardPresentationComponent:EnsureFootstepSound(p: number)
	t.strict(t.number)(p)
	local _footstepSound = self._footstepSound
	local _footstepPlaybackSpeed = self._footstepPlaybackSpeed

	if _footstepSound == nil or _footstepPlaybackSpeed == nil then
		return
	end

	_footstepSound.PlaybackSpeed = _footstepPlaybackSpeed * math.max(p / self._animationBaseWalkSpeed, 0.01)

	if not _footstepSound.IsPlaying then
		_footstepSound.Looped = true
		_footstepSound.TimePosition = 0
		_footstepSound:Play()
	end
end

function GuardPresentationComponent:StopFootstepSound()
	local _footstepSound = self._footstepSound

	if _footstepSound ~= nil and _footstepSound.IsPlaying then
		_footstepSound:Stop()
	end
end

function GuardPresentationComponent:EnsureIdleAnimation()
	if not self._idleTrack.IsPlaying then
		self._idleTrack:Play(0.2)
	end
end

function GuardPresentationComponent:StopIdleAnimation()
	if self._idleTrack.IsPlaying then
		self._idleTrack:Stop(0.2)
	end
end

function GuardPresentationComponent:EnsureWalkAnimation(p: number)
	t.strict(t.number)(p)
	self:StopIdleAnimation()
	self:EnsureFootstepSound(p)
	self._walkTrack:AdjustSpeed((math.max(p / self._animationBaseWalkSpeed, 0.01)))

	if not self._walkTrack.IsPlaying then
		self._walkTrack:Play(0.4)
	end
end

function GuardPresentationComponent:StopWalkAnimation()
	if self._walkTrack.IsPlaying then
		self._walkTrack:Stop(0.2)
	end
end

return GuardPresentationComponent