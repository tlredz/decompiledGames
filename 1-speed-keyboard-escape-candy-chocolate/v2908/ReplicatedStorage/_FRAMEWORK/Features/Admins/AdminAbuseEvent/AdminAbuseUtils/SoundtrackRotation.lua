local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function pickNextTrackIndex(p: number, p2: number?)
	if p == 1 or p2 == nil then
		return math.random(1, p)
	end

	local v = math.random(1, p - 1)

	if p2 <= v then
		return v + 1
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelThread(thread: thread?)
	if thread and thread ~= coroutine.running() and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end
end

local function destroyAudioRig(state)
	cancelThread(state.advanceThread) -- equivalent call inferred; original call site unknown
	state.advanceThread = nil
	cancelThread(state.durationThread) -- equivalent call inferred; original call site unknown
	state.durationThread = nil

	if state.fadeTween then
		local fadeTween = state.fadeTween
		state.fadeTween = nil
		fadeTween:Cancel()
		fadeTween:Destroy()
	end

	state.wire:Destroy()
	pcall(state.audioPlayer.Stop, state.audioPlayer)
	state.audioPlayer:Destroy()
end

local function createAudioRig(state, track)
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.Name = "AudioPlayer"
	audioPlayer.Looping = false
	audioPlayer.AssetId = track.AssetId
	audioPlayer.Volume = 0
	audioPlayer.Parent = state.audioFolder
	local wire = Instance.new("Wire")
	wire.Name = "WireToOutput"
	wire.SourceInstance = audioPlayer
	wire.TargetInstance = state.audioDeviceOutput
	wire.Parent = state.audioFolder
	return {
		audioPlayer = audioPlayer,
		wire = wire,
		advanceThread = nil,
		durationThread = nil,
		fadeTween = nil
	}
end

local function getAudioDuration(audioPlayer, p: number)
	local lastTime = os.clock()

	while not (audioPlayer.IsReady and audioPlayer.TimeLength > 0) and os.clock() - lastTime < p do
		task.wait(0.1)
	end

	return audioPlayer.TimeLength
end

local function fadeRig(state, volume: number, crossfadeDuration: number, p2)
	if state.fadeTween then
		state.fadeTween:Cancel()
		state.fadeTween:Destroy()
	end

	local tween = TweenService:Create(state.audioPlayer, TweenInfo.new(crossfadeDuration, Enum.EasingStyle.Quad, p2), {
		Volume = volume
	})
	state.fadeTween = tween
	tween:Play()
	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeOutAndDestroy(state, p)
	fadeRig(p, 0, state.crossfadeDuration, Enum.EasingDirection.In).Completed:Once(function()
		local index = table.find(state.rigs, p)

		if index then
			table.remove(state.rigs, index)
		end

		destroyAudioRig(p)
	end)
end

local fn

fn = function(state)
	if not state.active then
		return
	end

	local count = #state.tracks
	local currentIndex = state.currentIndex
	local currentIndex2

	if count == 1 or currentIndex == nil then
		currentIndex2 = math.random(1, count)
	else
		currentIndex2 = math.random(1, count - 1)

		if currentIndex <= currentIndex2 then
			currentIndex2 += 1
		end
	end

	local track = state.tracks[currentIndex2]
	local clone = table.clone(state.rigs)
	local audioRig = createAudioRig(state, track)
	table.insert(state.rigs, audioRig)
	state.currentIndex = currentIndex2
	ReplicatedStorage.AdminAbuse:SetAttribute("CurrentSoundtrackName", track.Name)
	audioRig.audioPlayer:Play()
	fadeRig(audioRig, 1, state.crossfadeDuration, Enum.EasingDirection.Out)

	for _, v2 in clone do
		fadeOutAndDestroy(state, v2) -- equivalent call inferred; original call site unknown
	end

	audioRig.durationThread = task.spawn(function()
		local audioDuration = getAudioDuration(audioRig.audioPlayer, 5)
		local v2 = audioDuration <= 0 and 180 or audioDuration

		if state.active then
			audioRig.advanceThread = task.delay(v2, fn, state)
		end
	end)
end

local function stopRotation(state)
	if not state.active then
		return
	end

	state.active = false

	for _, rig in state.rigs do
		destroyAudioRig(rig)
	end

	table.clear(state.rigs)
	state.audioFolder:Destroy()
	ReplicatedStorage.AdminAbuse:SetAttribute("CurrentSoundtrackName", nil)
end

local function checkStartReady(p)
	if not RunService:IsServer() then
		return false, "AdminAbuseUtils.SoundtrackRotation.start can only be called on the server"
	end

	if #p.tracks == 0 then
		return false, "AdminAbuseUtils.SoundtrackRotation.start requires at least one track"
	end

	return true, nil
end

local function applyStart(data)
	local folder = Instance.new("Folder")
	folder.Name = data.folderName or "SoundtrackRotation"
	local audioDeviceOutput = Instance.new("AudioDeviceOutput")
	audioDeviceOutput.Name = "AudioDeviceOutput"
	audioDeviceOutput.Parent = folder
	folder.Parent = data.parent
	local v = {
		tracks = data.tracks,
		crossfadeDuration = data.crossfadeDuration or 0.5,
		audioFolder = folder,
		audioDeviceOutput = audioDeviceOutput,
		rigs = {},
		currentIndex = nil,
		active = true
	}
	fn(v)
	return {
		audioFolder = folder,
		stop = function()
			stopRotation(v)
		end
	}
end

return {
	DEFAULT_FOLDER_NAME = "SoundtrackRotation",
	start = function(p)
		local flag, v

		if RunService:IsServer() then
			if #p.tracks == 0 then
				flag = false
				v = "AdminAbuseUtils.SoundtrackRotation.start requires at least one track"
			else
				flag = true
			end
		else
			flag = false
			v = "AdminAbuseUtils.SoundtrackRotation.start can only be called on the server"
		end

		if flag then
			return (applyStart(p))
		end

		error(v)
	end
}