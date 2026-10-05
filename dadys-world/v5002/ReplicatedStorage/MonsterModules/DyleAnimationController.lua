local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local DyleAnimationController = {}
DyleAnimationController.__index = DyleAnimationController
local v = nil
local v2 = {
	{
		threshold = 0.15,
		name = "VerySlow",
		animSpeed = 1
	},
	{
		threshold = 0.35,
		name = "Slow",
		animSpeed = 1
	},
	{
		threshold = 0.55,
		name = "Normal",
		animSpeed = 1
	},
	{
		threshold = 0.75,
		name = "Fast",
		animSpeed = 1.5
	},
	{
		threshold = 1,
		name = "VeryFast",
		animSpeed = 2
	}
}
local v3 = {
	{
		threshold = 0.33,
		animation = "FC_SlowSpeed"
	},
	{
		threshold = 0.66,
		animation = "FC_NormalSpeed"
	},
	{
		threshold = 1,
		animation = "FC_FastSpeed"
	}
}

function DyleAnimationController.new(character, monsterData)
	local object = setmetatable({}, DyleAnimationController)
	object.character = character
	object.monsterData = monsterData
	object.humanoid = character:WaitForChild("Humanoid")
	local events = ReplicatedStorage:FindFirstChild("Events")
	object.animationSpeedEvent = events and events:FindFirstChild("AnimationSpeed")
	object.currentState = {
		speedBucket = "VerySlow",
		animSpeed = 1,
		clockAnimation = nil,
		faceTexture = "Normal",
		isAttacking = false,
		isChasing = false,
		speedPercent = 0
	}
	object.lastUpdate = {
		speed = 0,
		clock = 0,
		face = 0,
		music = 0
	}
	object.throttleIntervals = {
		speed = 0.15,
		clock = 0.2,
		face = 0.05,
		music = 0.2
	}

	if monsterData.ClockHandsEnabled then
		object:initializeClockAnimator()
	end

	object.animationInstances = {}

	if monsterData.SpecialAnimatorData then
		object.specialAnimatorConfig = monsterData.SpecialAnimatorData.Config
	end

	return object
end

function DyleAnimationController:initializeClockAnimator()
	if not self.humanoid then
		warn("DyleAnimationController: No humanoid found for clock animations")
		return
	end

	local animator = self.humanoid:FindFirstChild("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = self.humanoid
	end

	self.animator = animator
	self.clockAnimationTracks = {}
end

function DyleAnimationController:update(isChasing, isAttacking, speedPercent)
	if not (self.character and self.character.Parent) then
		return
	end

	local now = tick()
	self.currentState.isChasing = isChasing
	self.currentState.isAttacking = isAttacking
	self.currentState.speedPercent = speedPercent

	if self.monsterData.ClockHandsEnabled then
		self:updateClockAnimation(speedPercent, now)
	end

	if isAttacking and self.currentState.faceTexture ~= "Attack" then
		self:updateFaceTexture("Attack", now)
	elseif not isAttacking and self.currentState.faceTexture == "Attack" then
		self:updateFaceTexture("Normal", now)
	end
end

function DyleAnimationController.updateAnimationSpeed(data, p, speed)
	local v4 = v2[1]
	local animSpeed = v2[1].animSpeed

	for _, v6 in ipairs(v2) do
		if not (p <= v6.threshold) then
			continue
		end

		animSpeed = v6.animSpeed
		v4 = v6
		break
	end

	local v6 = v4.name ~= data.currentState.speedBucket
	local v7 = math.abs(animSpeed - data.currentState.animSpeed) > 0.1
	local v8 = speed - data.lastUpdate.speed >= data.throttleIntervals.speed

	if (v6 or v7 and v8) and data.animationSpeedEvent then
		local v9 = animSpeed * 1

		if v then
			v:queueUpdate(data.character, "animationSpeed", v9)
		else
			data.animationSpeedEvent:FireAllClients(data.character, v9)
		end

		data.currentState.speedBucket = v4.name
		data.currentState.animSpeed = animSpeed
		data.lastUpdate.speed = speed
	end
end

function DyleAnimationController:updateClockAnimation(p, clock)
	if clock - self.lastUpdate.clock < self.throttleIntervals.clock then
		return
	end

	local animation = nil

	for _, v5 in ipairs(v3) do
		if not (p <= v5.threshold) then
			continue
		end

		animation = v5.animation
		break
	end

	if animation ~= self.currentState.clockAnimation then
		self:playClockAnimation(animation)
		self.currentState.clockAnimation = animation
		self.lastUpdate.clock = clock
	end
end

function DyleAnimationController:playClockAnimation(name)
	if not (self.animator and self.monsterData.ClockAnimationData) then
		return
	end

	for _, clockAnimationTrack in pairs(self.clockAnimationTracks) do
		if clockAnimationTrack.IsPlaying then
			clockAnimationTrack:Stop(0.5)
		end
	end

	local animationId = self.monsterData.ClockAnimationData[name]

	if not animationId then
		return
	end

	local track = self.clockAnimationTracks[name]

	if not track then
		local v5 = self.animationInstances[name]

		if not v5 then
			v5 = Instance.new("Animation")
			v5.AnimationId = animationId
			v5.Name = name
			self.animationInstances[name] = v5
		end

		track = self.animator:LoadAnimation(v5)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		self.clockAnimationTracks[name] = track
	end

	track:Play(0.5)
end

function DyleAnimationController:updateFaceTexture(faceTexture, face)
	if face - self.lastUpdate.face < self.throttleIntervals.face then
		return
	end

	self.currentState.faceTexture = faceTexture
	self.lastUpdate.face = face

	if self.specialAnimatorConfig then
		self.character:SetAttribute("DyleFaceTexture", faceTexture)
	end
end

function DyleAnimationController:updateMusicTempo(p)
	if not self.monsterData.DynamicMusicEnabled then
		return
	end

	local music = self:findMusic()

	if not music then
		return
	end

	local v4 = 1 + ((self.monsterData.MaxMusicPitch or 1.75) - 1) * p
	local playbackSpeed = music.PlaybackSpeed or 1
	music.PlaybackSpeed = playbackSpeed + (v4 - playbackSpeed) * 0.1

	if self.monsterData.MusicVolumeScaling then
		local minMusicVolume = self.monsterData.MinMusicVolume or 0.8
		music.Volume = minMusicVolume + ((self.monsterData.MaxMusicVolume or 1) - minMusicVolume) * p
	end

	if p > 0.8 then
		local v5 = music:FindFirstChild("ReverbSoundEffect")

		if not v5 then
			v5 = Instance.new("ReverbSoundEffect")
			v5.Parent = music
		end

		v5.DryLevel = -6 * p
		v5.WetLevel = -12 * (1 - p)
	end
end

function DyleAnimationController:findMusic()
	local v4 = {
		self.character:FindFirstChild("Head"),
		self.character:FindFirstChild("HumanoidRootPart"),
		self.character:FindFirstChild("Sounds")
	}

	for _, v5 in ipairs(v4) do
		if not v5 then
			continue
		end

		for _, sound in ipairs(v5:GetChildren()) do
			if not (sound:IsA("Sound") and (sound.Name:match("Music") or sound.Name:match("Chase") or sound.IsPlaying)) then
				continue
			end

			if sound:GetAttribute("RolloffConfigured") then
				return sound
			end

			sound.RollOffMode = Enum.RollOffMode.Linear
			sound.RollOffMinDistance = 10
			sound.RollOffMaxDistance = 100
			sound.EmitterSize = 10
			sound:SetAttribute("RolloffConfigured", true)
			print("DyleAnimationController: Configured audio rolloff for", sound.Name)
			return sound
		end
	end

	return nil
end

function DyleAnimationController:cleanup()
	for _, clockAnimationTrack in pairs(self.clockAnimationTracks) do
		if clockAnimationTrack.IsPlaying then
			clockAnimationTrack:Stop()
		end

		clockAnimationTrack:Destroy()
	end

	self.clockAnimationTracks = {}

	for _, animationInstance in pairs(self.animationInstances) do
		animationInstance:Destroy()
	end

	self.animationInstances = {}

	if self.character and self.character.Parent then
		self.character:SetAttribute("DyleFaceTexture", nil)
	end

	local music = self:findMusic()

	if music then
		local reverbSoundEffect = music:FindFirstChild("ReverbSoundEffect")

		if reverbSoundEffect then
			reverbSoundEffect:Destroy()
		end

		music.PlaybackSpeed = 1
		music.Volume = 0.5
	end

	print("DyleAnimationController: Cleanup completed")
end

return DyleAnimationController