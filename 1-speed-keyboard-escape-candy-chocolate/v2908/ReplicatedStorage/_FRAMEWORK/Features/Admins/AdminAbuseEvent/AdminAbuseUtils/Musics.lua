local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local v = {}
local v2 = {}
local v3 = nil

local function resolveAssetId(p)
	local v4 = tostring(p)
	assert(v4 ~= "", "AdminAbuseUtils.Musics requires a non-empty asset ID")

	if string.find(v4, "://", 1, true) then
		return v4
	end

	return (`rbxassetid://{v4}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSettingVolume(localPlayer)
	local aAMusicVolume = localPlayer:GetAttribute("AAMusicVolume")

	if type(aAMusicVolume) == "number" then
		return (math.clamp(aAMusicVolume, 0, 1))
	end

	return 1
end

local function resolveFadeDuration(value: number?)
	local v4 = value or 1.5
	local v5

	if v4 >= 0 then
		v5 = v4 < 1e999
	else
		v5 = false
	end

	assert(v5, "AdminAbuseUtils.Musics requires a finite, non-negative fadeDuration")
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelVolumeTween(state)
	local fadeConnection = state.fadeConnection
	state.fadeConnection = nil

	if fadeConnection then
		fadeConnection:Disconnect()
	end

	local volumeTween = state.volumeTween
	state.volumeTween = nil

	if volumeTween then
		volumeTween:Cancel()
	end
end

local function destroyHandle(data)
	if not v[data] then
		return
	end

	v[data] = nil
	cancelVolumeTween(data) -- equivalent call inferred; original call site unknown

	if v2[data.assetId] == data then
		v2[data.assetId] = nil
	end

	if v3 == data then
		v3 = nil
	end

	data.settingConnection:Disconnect()
	data.cameraConnection:Disconnect()
	pcall(function()
		data.audioPlayer:Stop()
	end)
	data.container:Destroy()
end

local function createHandle(assetId: string, data)
	local localPlayer = Players.LocalPlayer
	local currentCamera = Workspace.CurrentCamera

	if not (localPlayer and currentCamera) then
		return nil
	end

	local folder = Instance.new("Folder")
	folder.Name = data.name or "AdminAbuseMusic"
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.Name = "AudioPlayer"
	audioPlayer.AssetId = assetId
	audioPlayer.Looping = data.looping ~= false
	local v4 = math.max(0, data.volume or 1)
	audioPlayer.Volume = v4
	audioPlayer.Parent = folder
	local audioFader = Instance.new("AudioFader")
	audioFader.Name = "SettingsFader"
	audioFader.Bypass = false
	audioFader.Volume = getSettingVolume(localPlayer)
	audioFader.Parent = folder
	local audioDeviceOutput = Instance.new("AudioDeviceOutput")
	audioDeviceOutput.Name = "AudioDeviceOutput"
	audioDeviceOutput.Player = localPlayer
	audioDeviceOutput.Parent = folder
	local wire = Instance.new("Wire")
	wire.Name = "PlayerToFader"
	wire.SourceInstance = audioPlayer
	wire.TargetInstance = audioFader
	wire.Parent = folder
	local wire2 = Instance.new("Wire")
	wire2.Name = "FaderToOutput"
	wire2.SourceInstance = audioFader
	wire2.TargetInstance = audioDeviceOutput
	wire2.Parent = folder
	folder.Parent = currentCamera
	local v5 = {
		assetId = assetId,
		audioPlayer = audioPlayer,
		container = folder,
		settingConnection = localPlayer:GetAttributeChangedSignal("AAMusicVolume"):Connect(function()
			if audioFader.Parent then
				audioFader.Volume = getSettingVolume(localPlayer)
			end
		end),
		cameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			local currentCamera2 = Workspace.CurrentCamera

			if currentCamera2 and folder.Parent then
				folder.Parent = currentCamera2
			end
		end),
		startTimePosition = data.timePosition,
		targetVolume = v4,
		fadeDuration = 0,
		hasPlayed = false,
		volumeTween = nil,
		fadeConnection = nil
	}
	local fadeDuration = data.fadeDuration or 1.5
	local v6

	if fadeDuration >= 0 then
		v6 = fadeDuration < 1e999
	else
		v6 = false
	end

	assert(v6, "AdminAbuseUtils.Musics requires a finite, non-negative fadeDuration")
	v5.fadeDuration = fadeDuration
	v[v5] = true
	return v5
end

local function applyPlaybackOverrides(state, options)
	if not options then
		return
	end

	if options.name then
		state.container.Name = options.name
	end

	if options.looping ~= nil then
		state.audioPlayer.Looping = options.looping
	end

	if options.volume ~= nil then
		state.targetVolume = math.max(0, options.volume)
		state.audioPlayer.Volume = state.targetVolume
	end

	if options.timePosition ~= nil then
		state.startTimePosition = options.timePosition
	end

	if options.fadeDuration ~= nil then
		local fadeDuration = options.fadeDuration or 1.5
		local v4

		if fadeDuration >= 0 then
			v4 = fadeDuration < 1e999
		else
			v4 = false
		end

		assert(v4, "AdminAbuseUtils.Musics requires a finite, non-negative fadeDuration")
		state.fadeDuration = fadeDuration
	end
end

local function tweenVolume(state, volume: number, fadeDuration: number, callback)
	cancelVolumeTween(state) -- equivalent call inferred; original call site unknown

	if fadeDuration <= 0 then
		state.audioPlayer.Volume = volume

		if callback then
			callback()
		end
	else
		local tween = TweenService:Create(
			state.audioPlayer,
			TweenInfo.new(fadeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Volume = volume
			}
		)
		state.volumeTween = tween
		state.fadeConnection = tween.Completed:Connect(function(p)
			if state.volumeTween ~= tween then
				return
			end

			local fadeConnection = state.fadeConnection
			state.fadeConnection = nil
			state.volumeTween = nil

			if fadeConnection then
				fadeConnection:Disconnect()
			end

			if p == Enum.PlaybackState.Completed and callback then
				callback()
			end
		end)
		tween:Play()
	end
end

local Musics = {}

function Musics.preload(p, options)
	if RunService:IsServer() then
		return nil
	end

	local v4 = tostring(p)
	assert(v4 ~= "", "AdminAbuseUtils.Musics requires a non-empty asset ID")

	if not string.find(v4, "://", 1, true) then
		v4 = `rbxassetid://{v4}`
	end

	local v5 = v2[v4]

	if v5 and v[v5] then
		applyPlaybackOverrides(v5, options)
		return v5
	end

	local handle = createHandle(v4, options or {})

	if handle then
		v2[v4] = handle
	end

	return handle
end

function Musics.play(p, options)
	if RunService:IsServer() then
		return nil
	end

	local v4 = options or {}
	local v5 = tostring(p)
	assert(v5 ~= "", "AdminAbuseUtils.Musics requires a non-empty asset ID")

	if not string.find(v5, "://", 1, true) then
		v5 = `rbxassetid://{v5}`
	end

	local v6 = v2[v5]

	if v6 and v[v6] then
		v2[v5] = nil
		applyPlaybackOverrides(v6, options)
	else
		v6 = createHandle(v5, v4)
	end

	if not v6 then
		return nil
	end

	local v7 = {}

	for k in v do
		if k ~= v6 and k.hasPlayed then
			table.insert(v7, k)
		end
	end

	v3 = v6
	local v8 = #v7 > 0

	if v8 then
		v6.audioPlayer.Volume = 0
	end

	v6.hasPlayed = true
	v6.audioPlayer:Play()

	if v6.startTimePosition then
		v6.audioPlayer.TimePosition = math.max(0, v6.startTimePosition)
	end

	if v8 then
		local fadeDuration = v6.fadeDuration
		tweenVolume(v6, v6.targetVolume, fadeDuration, nil)

		for _, v9 in v7 do
			local v10 = v9
			tweenVolume(v9, 0, fadeDuration, function()
				destroyHandle(v10)
			end)
		end

		return v6
	else
		cancelVolumeTween(v6) -- equivalent call inferred; original call site unknown
		v6.audioPlayer.Volume = v6.targetVolume
		return v6
	end
end

function Musics.stop(p)
	destroyHandle(p)
end

function Musics.getCurrentlyPlaying()
	return v3
end

function Musics.cleanup()
	local v4 = {}

	for k in v do
		table.insert(v4, k)
	end

	for _, v5 in v4 do
		destroyHandle(v5)
	end
end

return Musics