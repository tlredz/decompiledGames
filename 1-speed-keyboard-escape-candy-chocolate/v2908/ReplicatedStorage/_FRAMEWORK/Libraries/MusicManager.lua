local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local targetInstance = nil
local aAMusicVolumeChangedConnection = nil
local v6 = nil

local function checkPlayArguments(p, p2: string, p3: number)
	if tostring(p) == "" then
		error("MusicManager.play requires a non-empty assetId")
	elseif p2 == "" then
		error("MusicManager.play requires a non-empty name")
	elseif p3 ~= p3 or math.abs(p3) == 1e999 then
		error("MusicManager.play requires a finite priority")
	end
end

local function resolveAssetId(p)
	local v7 = tostring(p)

	if string.find(v7, "://", 1, true) then
		return v7
	end

	return (`rbxassetid://{v7}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSettingsVolume(instance)
	if instance == nil then
		return 1
	end

	local aAMusicVolume = instance:GetAttribute("AAMusicVolume")

	if type(aAMusicVolume) == "number" then
		return (math.clamp(aAMusicVolume, 0, 1))
	end

	return 1
end

local function ensureOutput()
	if v4 then
		return v4
	end

	local localPlayer = Players.LocalPlayer
	local folder = Instance.new("Folder")
	folder.Name = "MusicManager"
	local audioFader = Instance.new("AudioFader")
	audioFader.Name = "AdminAbuseMusicVolume"
	audioFader.Bypass = false
	local settingsVolume = getSettingsVolume(localPlayer) -- equivalent call inferred; original call site unknown
	audioFader.Volume = settingsVolume
	audioFader.Parent = folder
	local audioDeviceOutput = Instance.new("AudioDeviceOutput")
	audioDeviceOutput.Name = "AudioDeviceOutput"

	if localPlayer then
		audioDeviceOutput.Player = localPlayer
	end

	audioDeviceOutput.Parent = folder
	local wire = Instance.new("Wire")
	wire.Name = "FaderToOutput"
	wire.SourceInstance = audioFader
	wire.TargetInstance = audioDeviceOutput
	wire.Parent = folder
	v4 = folder
	targetInstance = audioFader
	folder.Parent = SoundService

	if localPlayer then
		aAMusicVolumeChangedConnection = localPlayer:GetAttributeChangedSignal("AAMusicVolume"):Connect(function()
			if targetInstance then
				local v7 = targetInstance
				local settingsVolume2 = getSettingsVolume(localPlayer) -- equivalent call inferred; original call site unknown
				v7.Volume = settingsVolume2
			end
		end)
	end

	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyOutputIfUnused()
	if next(v3) ~= nil then
		return
	end

	if aAMusicVolumeChangedConnection then
		aAMusicVolumeChangedConnection:Disconnect()
		aAMusicVolumeChangedConnection = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
		targetInstance = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelFade(state)
	if state.fadeConnection then
		state.fadeConnection:Disconnect()
		state.fadeConnection = nil
	end

	if state.fadeTween then
		state.fadeTween:Cancel()
		state.fadeTween = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pauseTrack(p)
	local timePosition = p.audioPlayer.TimePosition
	p.audioPlayer:Stop()
	p.audioPlayer.TimePosition = timePosition
end

local function fadeTrack(state, volume: number, callback)
	cancelFade(state) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(
		state.audioPlayer,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			Volume = volume
		}
	)
	state.fadeTween = tween
	state.fadeConnection = tween.Completed:Connect(function(p2)
		if state.fadeTween ~= tween then
			return
		end

		local fadeConnection = state.fadeConnection
		state.fadeConnection = nil
		state.fadeTween = nil

		if fadeConnection then
			fadeConnection:Disconnect()
		end

		if p2 == Enum.PlaybackState.Completed and callback then
			callback()
		end
	end)
	tween:Play()
end

local function createTrack(assetId, name: string, priority: number)
	local output = ensureOutput()
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.Name = name
	local assetId2 = tostring(assetId)

	if not string.find(assetId2, "://", 1, true) then
		assetId2 = `rbxassetid://{assetId2}`
	end

	audioPlayer.AssetId = assetId2
	audioPlayer.Looping = true
	audioPlayer.Parent = output
	local wire = Instance.new("Wire")
	wire.Name = `{name}ToFader`
	wire.SourceInstance = audioPlayer
	wire.TargetInstance = targetInstance
	wire.Parent = output
	local v8 = {
		assetId = assetId,
		name = name,
		priority = priority,
		audioPlayer = audioPlayer,
		wire = wire,
		fadeTween = nil,
		fadeConnection = nil
	}
	v3[v8] = true
	return v8
end

local function findHighestPriorityTrack()
	local v7 = nil

	for _, v8 in v do
		if v7 == nil or v8.priority > v7.priority then
			v7 = v8
		end
	end

	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyTrack(state)
	cancelFade(state) -- equivalent call inferred; original call site unknown
	v2[state] = nil
	v3[state] = nil
	state.audioPlayer:Stop()
	state.wire:Destroy()
	state.audioPlayer:Destroy()
	destroyOutputIfUnused() -- equivalent call inferred; original call site unknown
end

local function activateHighestPriorityTrack()
	local v7 = nil

	for _, v8 in v do
		if v7 == nil or v8.priority > v7.priority then
			v7 = v8
		end
	end

	if v6 == v7 then
		return
	end

	local v8 = v6
	v6 = v7

	if v8 then
		v2[v8] = true
		fadeTrack(v8, 0, function()
			v2[v8] = nil

			if v[v8.name] == v8 then
				pauseTrack(v8) -- equivalent call inferred; original call site unknown
			else
				destroyTrack(v8) -- equivalent call inferred; original call site unknown
			end

			destroyOutputIfUnused() -- equivalent call inferred; original call site unknown
		end)
	end

	if v7 then
		v2[v7] = nil
		cancelFade(v7) -- equivalent call inferred; original call site unknown

		if not v7.audioPlayer.IsPlaying then
			v7.audioPlayer.Volume = 0
		end

		v7.audioPlayer:Play()
		fadeTrack(v7, 1, nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTrack(p)
	v[p.name] = nil

	if v6 ~= p then
		destroyTrack(p) -- equivalent call inferred; original call site unknown
	end
end

local function removeMatchingTracks(p: string, p2: number)
	local v7 = {}

	for _, v8 in v do
		if v8.name == p or v8.priority == p2 then
			table.insert(v7, v8)
		end
	end

	for _, v8 in v7 do
		removeTrack(v8) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toPublicTrack(data)
	return {
		assetId = data.assetId,
		name = data.name,
		priority = data.priority,
		isAudible = data == v6,
		audioPlayer = data.audioPlayer
	}
end

local MusicManager = {}

function MusicManager.play(assetId, name: string, priority: number)
	if tostring(assetId) == "" then
		error("MusicManager.play requires a non-empty assetId")
	elseif name == "" then
		error("MusicManager.play requires a non-empty name")
	elseif priority ~= priority or math.abs(priority) == 1e999 then
		error("MusicManager.play requires a finite priority")
	end

	removeMatchingTracks(name, priority)
	local track = createTrack(assetId, name, priority)
	v[name] = track
	activateHighestPriorityTrack()
	return toPublicTrack(track)
end

function MusicManager.stop(p: string)
	local v7 = v[p]

	if v7 then
		removeTrack(v7) -- equivalent call inferred; original call site unknown
		activateHighestPriorityTrack()
	end
end

function MusicManager.getAllPlaying()
	local result = {}

	for _, v7 in v do
		table.insert(result, toPublicTrack(v7))
	end

	table.sort(result, function(a, b)
		return a.priority > b.priority
	end)
	return result
end

function MusicManager.stopAll()
	local v7 = {}

	for _, v8 in v do
		table.insert(v7, v8)
	end

	for _, v8 in v7 do
		removeTrack(v8) -- equivalent call inferred; original call site unknown
	end

	activateHighestPriorityTrack()
end

return MusicManager