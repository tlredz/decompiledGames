local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local SoundService = game:GetService("SoundService")
local AudioSystem = {}
AudioSystem.__index = AudioSystem

function AudioSystem.new(ctx)
	local object = setmetatable({}, AudioSystem)
	object._ctx = ctx
	object.config = ctx.config
	object.arenaCFrame = ctx.arenaCFrame
	object.arenaScale = ctx.arenaScale
	object.instanceId = ctx.instanceId
	object.rootFolder = ctx.rootFolder
	object.audioMode = ctx.audioMode or "spatial"
	object.audioGlobalFolder = nil
	object.audioGlobalSounds = {}
	object.audioSpatialSounds = {}
	object.audioSpatialAnchors = {}
	object.audioLastPlayedAt = {}
	object.audioRandom = Random.new()
	object:_buildAudio()
	return object
end

function AudioSystem:_worldFromArena(point: Vector2, value: number?)
	return self.arenaCFrame:PointToWorldSpace((Vector3.new(
		point.X * self.arenaScale,
		point.Y * self.arenaScale,
		-(value or 0) * self.arenaScale
	)))
end

function AudioSystem:_createCueSound(name: string, data, parent)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = data.soundId
	sound.Volume = data.volume or 0.5
	sound.PlaybackSpeed = data.playbackSpeed or 1
	sound.SoundGroup = self._ctx.soundGroup
	sound.Parent = parent
	return sound
end

function AudioSystem:_buildAudio()
	self.audioGlobalFolder = Instance.new("Folder")
	self.audioGlobalFolder.Name = string.format("BattleAudio_%s", self.instanceId)
	self.audioGlobalFolder.Parent = SoundService
	local spectatorAudio = self.config.lobby.spectatorAudio

	for k, v in self.config.audio do
		self.audioGlobalSounds[k] = self:_createCueSound(k, v, self.audioGlobalFolder)
		local part = Instance.new("Part")
		part.Name = string.format("%s_AudioAnchor", k)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(0.2, 0.2, 0.2)
		part.Position = self:_worldFromArena(Vector2.zero, spectatorAudio.emitterHeight)
		part.Parent = self.rootFolder
		self.audioSpatialAnchors[k] = part
		local _createCueSound = self:_createCueSound(k, v, part)
		_createCueSound.RollOffMode = Enum.RollOffMode.InverseTapered
		_createCueSound.RollOffMinDistance = spectatorAudio.minDistance
		_createCueSound.RollOffMaxDistance = spectatorAudio.maxDistance
		self.audioSpatialSounds[k] = _createCueSound
	end
end

function AudioSystem:setAudioMode(p2: string)
	self.audioMode = p2 == "global" and "global" or "spatial"
end

function AudioSystem:playCue(p: string, vector2: Vector3?)
	local v = self.config.audio[p]
	local v2 = self.audioMode == "global" and self.audioGlobalSounds[p] or self.audioSpatialSounds[p]

	if not (v and v2) then
		return
	end

	local now = os.clock()

	if (v.minInterval or 0) > now - (self.audioLastPlayedAt[p] or -1e999) then
		return
	end

	self.audioLastPlayedAt[p] = now
	local v3 = self.audioMode == "spatial" and self.audioSpatialAnchors[p]

	if v3 then
		v3.Position = vector2 or self:_worldFromArena(Vector2.zero, self.config.lobby.spectatorAudio.emitterHeight)
	end

	local playbackSpeed = v.playbackSpeed or 1
	local playbackSpeedJitter = v.playbackSpeedJitter or 0

	if playbackSpeedJitter > 0 then
		playbackSpeed += self.audioRandom:NextNumber(-playbackSpeedJitter, playbackSpeedJitter)
	end

	v2.Volume = v.volume or v2.Volume
	v2.PlaybackSpeed = math.max(0.05, playbackSpeed)
	v2.TimePosition = 0
	v2:Play()
end

function AudioSystem:destroy()
	if self.audioGlobalFolder then
		self.audioGlobalFolder:Destroy()
		self.audioGlobalFolder = nil
	end
end

return AudioSystem