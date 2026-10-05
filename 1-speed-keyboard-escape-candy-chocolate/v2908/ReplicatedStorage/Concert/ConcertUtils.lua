game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local parent = script.Parent
local TableUtils = require(ReplicatedStorage.Utilities.TableUtils)
local ConcertState = require(parent.ConcertState)
local ConcertUtils = {}
local currentCameraChangedConnection = nil
local v = nil
local v2 = nil
local v3 = false
local v4 = nil

local function GetStageMusic(p)
	local music = p.AssetFolder:FindFirstChild("Music")

	if music and music:IsA("AudioPlayer") then
		return music
	end

	return p.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
end

local function EnsureEmitter(sourceInstance)
	if not RunService:IsClient() then
		return false
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	local targetInstance = currentCamera:FindFirstChild("ConcertAudioDeviceOutput")

	if targetInstance and not targetInstance:IsA("AudioDeviceOutput") then
		targetInstance:Destroy()
		targetInstance = nil
	end

	if not targetInstance then
		targetInstance = Instance.new("AudioDeviceOutput")
		targetInstance.Name = "ConcertAudioDeviceOutput"
		targetInstance.Parent = currentCamera
	end

	targetInstance.Player = Players.LocalPlayer
	local v6 = ConcertState.AudioFader

	if not pcall(function()
		v6.Name = "ConcertAudioFader"
		v6.Bypass = false
		v6.Volume = ConcertState.ConcertVolume
		v6.Parent = currentCamera
	end) then
		v6 = Instance.new("AudioFader")
		v6.Name = "ConcertAudioFader"
		v6.Bypass = false
		v6.Volume = ConcertState.ConcertVolume
		v6.Parent = currentCamera
		ConcertState.AudioFader = v6
	end

	local audioWire = ConcertState.AudioWire

	if not pcall(function()
		audioWire.Name = "ConcertAudioWire"
		audioWire.Parent = currentCamera
		audioWire.TargetInstance = v6
	end) then
		audioWire = Instance.new("Wire")
		audioWire.Name = "ConcertAudioWire"
		audioWire.Parent = currentCamera
		audioWire.TargetInstance = v6
		ConcertState.AudioWire = audioWire
	end

	if sourceInstance and audioWire.SourceInstance ~= sourceInstance then
		audioWire.SourceInstance = sourceInstance
	end

	local audioOutputWire = ConcertState.AudioOutputWire

	if not pcall(function()
		audioOutputWire.Name = "ConcertAudioOutputWire"
		audioOutputWire.Parent = currentCamera
		audioOutputWire.SourceInstance = v6
		audioOutputWire.TargetInstance = targetInstance
	end) then
		audioOutputWire = Instance.new("Wire")
		audioOutputWire.Name = "ConcertAudioOutputWire"
		audioOutputWire.Parent = currentCamera
		audioOutputWire.SourceInstance = v6
		audioOutputWire.TargetInstance = targetInstance
		ConcertState.AudioOutputWire = audioOutputWire
	end

	return audioWire.TargetInstance == v6 and audioOutputWire.SourceInstance == v6 and audioOutputWire.TargetInstance == targetInstance
end

local v5 = {
	Name = "Unknown",
	Order = 0,
	AssetFolder = nil,
	Init = function(_) end,
	Update = function(_) end,
	Cleanup = function(_) end,
	TransitionIn = function(_) end,
	TransitionOut = function(_) end,
	PlayMusic = function(p, _: number?)
		print((`Playing music for stage {p.Name}`))
		local music = p.AssetFolder:FindFirstChild("Music")

		if not (music and music:IsA("AudioPlayer")) then
			music = p.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
		end

		assert(music, (`Stage {p.Name} has no Music instance in its AssetFolder!`))

		if RunService:IsClient() then
			EnsureEmitter(music)
			v4 = p
			music:Play()
		end
	end,
	StopMusic = function(p)
		local music = p.AssetFolder:FindFirstChild("Music")

		if not (music and music:IsA("AudioPlayer")) then
			music = p.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
		end

		assert(music, (`Stage {p.Name} has no Music instance in its AssetFolder!`))

		if RunService:IsClient() then
			if v4 == p then
				v4 = nil
			end

			ConcertState.AudioWire.SourceInstance = nil
			music:Stop()
		end
	end,
	GetLyricAtElapsedTime = function(p, p2: number)
		if not p.Lyrics then
			return
		end

		for i = #p.Lyrics, 1, -1 do
			local lyric = p.Lyrics[i]

			if lyric.seconds <= p2 and p2 <= lyric.seconds + lyric.duration then
				return lyric, i
			end
		end
	end
}

function ConcertUtils.DefineStage(options)
	assert(options.AssetFolder, (`Stage {options.Name} has no AssetFolder defined!`))
	return (TableUtils.Reconcile(options or {}, v5))
end

function ConcertUtils.Print(...)
	print("[CONCERT]", ...)
end

function ConcertUtils.GetStage(childName: string)
	local moduleScript = parent.Stages:FindFirstChild(childName)
	assert(
		moduleScript,
		(`Stage {childName} not found! Did you create a stage module in "src/ReplicatedStorage/Concert/Stages"?`)
	)
	assert(
		moduleScript:IsA("ModuleScript"),
		(`Stage {childName} is not a ModuleScript! Did you create a stage module in "src/ReplicatedStorage/Concert/Stages"?`)
	)
	local module = require(moduleScript)
	return module
end

function ConcertUtils.SetupEmitter()
	if not RunService:IsClient() then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	while not currentCamera do
		Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
		currentCamera = Workspace.CurrentCamera
	end

	EnsureEmitter(ConcertUtils.GetAudioPlayer())

	if currentCameraChangedConnection then
		currentCameraChangedConnection:Disconnect()
	end

	currentCameraChangedConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(function()
			local playingStage = ConcertState.PlayingStage
			local music

			if playingStage then
				music = playingStage.AssetFolder:FindFirstChild("Music")

				if not (music and music:IsA("AudioPlayer")) then
					music = playingStage.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
				end
			end

			EnsureEmitter(music)
		end)
	end)
end

function ConcertUtils.SetConcertVolume(value: number)
	if not RunService:IsClient() then
		return
	end

	if type(value) ~= "number" or value ~= value or math.abs(value) == 1e999 then
		warn("[CONCERT] SetConcertVolume expects a finite number.")
		return
	end

	local v6 = math.clamp(value, 0, 1)
	ConcertState.ConcertVolume = v6
	pcall(function()
		ConcertState.AudioFader.Volume = v6
	end)
end

function ConcertUtils.GetCurrentStageElapsedTime()
	if ConcertState.MusicStartTime then
		return Workspace:GetServerTimeNow() - ConcertState.MusicStartTime
	end

	return 0
end

function ConcertUtils.GetAudioPlayer()
	local sourceInstance = ConcertState.AudioWire.SourceInstance

	if sourceInstance and sourceInstance:IsA("AudioPlayer") then
		return sourceInstance
	end

	return nil
end

function ConcertUtils.SetMusicEndedHandler(callback)
	v = callback
end

local function HasCurrentStageMusicEnded()
	local playingStage = ConcertState.PlayingStage

	if playingStage ~= v2 then
		v2 = playingStage
		v3 = false
	end

	if not playingStage or v3 then
		return v3
	end

	local music = playingStage.AssetFolder:FindFirstChild("Music")

	if not (music and music:IsA("AudioPlayer")) then
		music = playingStage.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
	end

	if not music or music.TimeLength <= 0 or ConcertUtils.GetCurrentStageElapsedTime() < music.TimeLength then
		return false
	end

	v3 = true

	if v then
		task.defer(v, playingStage)
	end

	return true
end

function ConcertUtils.MakeSureIsPlayingMusic()
	if HasCurrentStageMusicEnded() or RunService:IsServer() then
		return
	end

	local playingStage = ConcertState.PlayingStage

	if not playingStage then
		return
	end

	local music = playingStage.AssetFolder:FindFirstChild("Music")

	if not (music and music:IsA("AudioPlayer")) then
		music = playingStage.AssetFolder:FindFirstChildWhichIsA("AudioPlayer")
	end

	if not (music and EnsureEmitter(music)) then
		return
	end

	local audioPlayer = ConcertUtils.GetAudioPlayer()

	if not (audioPlayer and audioPlayer.IsReady) then
		return
	end

	if v4 == playingStage then
		audioPlayer.TimePosition = math.min(
			ConcertUtils.GetCurrentStageElapsedTime(),
			(math.max(audioPlayer.TimeLength - 0.001, 0))
		)
		v4 = nil
	end

	if audioPlayer.IsPlaying then
		return
	end

	audioPlayer.TimePosition = ConcertUtils.GetCurrentStageElapsedTime()
	audioPlayer:Play()
end

function ConcertUtils.GetConcertStageMapFolder()
	return Workspace:FindFirstChild("ConcertStages") or ReplicatedStorage:FindFirstChild("ConcertStages")
end

function ConcertUtils.GetLyricDataFromFolder(instance)
	if not instance then
		return nil
	end

	local data = instance:GetAttribute("Data")

	if not data then
		return nil
	end

	debug.profilebegin("Concert.DecodeLyrics")
	local success, result = pcall(TableUtils.DecodeJSON, data)
	debug.profileend()

	if success then
		return result
	end

	return nil
end

return ConcertUtils