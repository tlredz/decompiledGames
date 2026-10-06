local module = require("@game/ReplicatedStorage/Omni")
local v = {
	[0] = 1,
	[180] = 1
}
local v2 = {}
local v3 = {}
local heartbeatConnection = nil
local thread = nil
local currentCameraChangedConnection = nil
local audioListener = nil
local audioDeviceOutput = nil
local flag = false
local Sound = {}

local function GetSettingVolume(p: string)
	local settings = module.Data and module.Data.Settings
	local v4 = settings and settings[p]
	return math.clamp((typeof(v4) ~= "number" or v4 ~= v4) and 50 or v4, 0, 100) / 100
end

local function GetVolume()
	local settings = module.Data and module.Data.Settings
	local effectsVolume = settings and settings["Effects Volume"]
	return math.clamp(
		(typeof(effectsVolume) ~= "number" or effectsVolume ~= effectsVolume) and 50 or effectsVolume,
		0,
		100
	) / 100
end

local function GetLength(range: NumberRange?, p: number)
	if range then
		return (math.max(0, math.min(range.Max, p) - range.Min))
	end

	return p
end

local function GetDistanceCurve(data)
	local v4 = math.max(data.RollOffMinDistance, 0.1)
	local v5 = math.max(data.RollOffMaxDistance, v4 + 1)
	local rollOffMode = data.RollOffMode
	local result = {
		[0] = 1,
		[v4] = 1
	}

	for i = 1, 10 do
		local v6 = v4 * math.pow(v5 / v4, i / 10)
		local v7 = (v6 - v4) / (v5 - v4)
		local v8 = v4 / v6

		if rollOffMode == Enum.RollOffMode.Linear then
			v8 = 1 - v7
		elseif rollOffMode == Enum.RollOffMode.LinearSquare then
			v8 = (1 - v7) ^ 2
		elseif rollOffMode == Enum.RollOffMode.InverseTapered then
			v8 = math.min(v8, (1 - v7) ^ 2)
		end

		result[math.floor(v6 * 100 + 0.5) / 100] = math.clamp(v8, 0, 1)
	end

	return result
end

local function EnsureListener()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or flag then
		return
	end

	if not audioListener then
		audioListener = Instance.new("AudioListener")
		audioListener.Name = "OmniListener"
		audioListener.AudioInteractionGroup = "Omni"
		audioListener:SetAngleAttenuation(v)
		audioDeviceOutput = Instance.new("AudioDeviceOutput")
		audioDeviceOutput.Name = "OmniOutput"
		audioDeviceOutput.Parent = module.Services.SoundService
		local wire = Instance.new("Wire")
		wire.SourceInstance = audioListener
		wire.TargetInstance = audioDeviceOutput
		wire.Parent = audioListener
	end

	if audioListener.Parent ~= currentCamera then
		audioListener.Parent = currentCamera
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsSpatial(instance)
	return instance:IsA("BasePart") or instance:IsA("Attachment") or instance:IsA("Model")
end

local function CreateEmitter(sound)
	EnsureListener()
	local audioEmitter = Instance.new("AudioEmitter")
	audioEmitter.Name = sound.Name
	audioEmitter.AudioInteractionGroup = "Omni"
	audioEmitter:SetDistanceAttenuation((GetDistanceCurve(sound)))
	audioEmitter:SetAngleAttenuation(v)
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.Asset = sound.SoundId
	audioPlayer.PlaybackSpeed = sound.PlaybackSpeed
	audioPlayer.Looping = false

	if sound.PlaybackRegionsEnabled then
		audioPlayer.PlaybackRegion = sound.PlaybackRegion
		audioPlayer.TimePosition = sound.PlaybackRegion.Min
	end

	audioPlayer.Parent = audioEmitter
	local wire = Instance.new("Wire")
	wire.SourceInstance = audioPlayer
	wire.TargetInstance = audioEmitter
	wire.Parent = audioEmitter
	return audioEmitter, audioPlayer
end

local function Finish(data, flag2: boolean)
	if v2[data.Sound] ~= data then
		return
	end

	v2[data.Sound] = nil

	if data.Owned then
		data.Sound:Destroy()
	elseif data.Sound.Parent then
		data.Sound:Stop()
		data.Sound.Volume = data.Volume
		data.Sound.PlaybackSpeed = data.Speed
		data.Sound.Looped = data.Looped
		data.Sound.PlayOnRemove = data.PlayOnRemove
		data.Sound.Parent = data.Parent
	end

	data.Resolve(flag2)
end

local function Update(state, now: number, p: number)
	local sound = state.Sound

	if not sound:IsDescendantOf(game) then
		Finish(state, false)
		return
	end

	local player = state.Player or sound
	player.Volume = state.Volume * p * state.VolumeMultiplier

	if state.ExpiresAt <= now then
		Finish(state, state.Started == true)
	elseif state.Started then
		if not player.IsPlaying then
			Finish(state, state.Player ~= nil or sound.TimePosition == 0)
		end
	else
		local v4

		if state.Player then
			v4 = state.Player.IsReady and state.Player.TimeLength > 0
		else
			v4 = sound.IsLoaded and sound.TimeLength > 0
		end

		if v4 then
			local region = state.Region
			local timeLength = player.TimeLength

			if region then
				timeLength = math.max(0, math.min(region.Max, timeLength) - region.Min)
			end

			if state.Duration then
				player.PlaybackSpeed = timeLength / (state.ExpiresAt - now)
			else
				state.ExpiresAt = now + math.min(timeLength / math.max(player.PlaybackSpeed, 0.01) + 1, 60)
			end

			state.Started = true
			player:Play()
		elseif now - state.CreatedAt >= 1 then
			Finish(state, false)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Connect()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(function()
		local now = os.clock()
		local settings = module.Data and module.Data.Settings
		local effectsVolume = settings and settings["Effects Volume"]
		local v4 = math.clamp(
			(typeof(effectsVolume) ~= "number" or effectsVolume ~= effectsVolume) and 50 or effectsVolume,
			0,
			100
		) / 100

		for _, v5 in v2 do
			Update(v5, now, v4)
		end

		for k, v5 in v3 do
			if v5 <= now then
				v3[k] = nil
			end
		end

		if not (next(v2) or next(v3)) then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

function Sound:Play(sound, p, flag2: boolean?, options)
	if flag or typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		return module.Libs.Promise.resolve(false)
	end

	local v4 = options or {}
	local parent = p or module.Services.SoundService
	local settings = module.Data and module.Data.Settings
	local effectsVolume = settings and settings["Effects Volume"]
	local v6 = math.clamp(
		(typeof(effectsVolume) ~= "number" or effectsVolume ~= effectsVolume) and 50 or effectsVolume,
		0,
		100
	) / 100
	local now = os.clock()
	local group = v4.Group or sound
	local duration = v4.Duration
	local volumeMultiplier = v4.VolumeMultiplier or 1

	if v6 <= 0 or sound.SoundId == "" or not parent:IsDescendantOf(game) then
		return module.Libs.Promise.resolve(false)
	end

	if typeof(volumeMultiplier) ~= "number" or volumeMultiplier ~= volumeMultiplier or volumeMultiplier <= 0 or volumeMultiplier == 1e999 then
		return module.Libs.Promise.resolve(false)
	end

	if duration ~= nil and (typeof(duration) ~= "number" or duration ~= duration or duration <= 0 or duration == 1e999) or v3[group] and now < v3[group] then
		return module.Libs.Promise.resolve(false)
	end

	local v7 = 0
	local count = 0
	local v8 = nil

	for _, v9 in v2 do
		v7 += 1

		if v9.Group ~= group then
			continue
		end

		count += 1

		if not v8 or v9.CreatedAt < v8.CreatedAt then
			v8 = v9
		end
	end

	if v8 and (v4.MaxVoices or 3) <= count then
		Finish(v8, false)
		v7 -= 1
	end

	if v7 >= 24 then
		return module.Libs.Promise.resolve(false)
	end

	local spatial = IsSpatial(parent) -- equivalent call inferred; original call site unknown

	if not spatial and flag2 and v2[sound] then
		Finish(v2[sound], false)
	end

	local player = nil
	local sound2

	if spatial then
		sound2, player = CreateEmitter(sound)
	else
		sound2 = flag2 and sound or sound:Clone()
	end

	local v12 = {
		Sound = sound2,
		Player = player,
		Owned = spatial or not flag2,
		Parent = sound.Parent,
		Volume = sound.Volume,
		VolumeMultiplier = volumeMultiplier,
		Speed = sound.PlaybackSpeed,
		Looped = sound.Looped,
		PlayOnRemove = sound.PlayOnRemove,
		Region = 0,
		Group = 0,
		Duration = 0,
		CreatedAt = 0,
		ExpiresAt = 0
	}
	local region

	if sound.PlaybackRegionsEnabled then
		region = sound.PlaybackRegion
	end

	v12.Region = region
	v12.Group = group
	v12.Duration = duration
	v12.CreatedAt = now
	v12.ExpiresAt = now + (duration or 60)

	if not spatial then
		sound2.Looped = false
		sound2.PlayOnRemove = false
		sound2.Volume = v12.Volume * v6 * v12.VolumeMultiplier
	end

	sound2.Parent = parent
	v3[group] = now + (v4.Cooldown or 0.04)
	return module.Libs.Promise.new(function(resolve, _, callback)
		v12.Resolve = resolve
		v2[sound2] = v12
		callback(function()
			Finish(v12, false)
		end)
		local now2 = os.clock()
		local settings2 = module.Data and module.Data.Settings
		local effectsVolume2 = settings2 and settings2["Effects Volume"]
		Update(
			v12,
			now2,
			math.clamp(
				(typeof(effectsVolume2) ~= "number" or effectsVolume2 ~= effectsVolume2) and 50 or effectsVolume2,
				0,
				100
			) / 100
		)
		Connect() -- equivalent call inferred; original call site unknown
	end)
end

function Sound.CanPlay(_, p)
	if flag then
		return false
	end

	local v4 = v3[p]
	return not v4 or v4 <= os.clock()
end

function Sound.GetSettingVolume(_, p: string)
	local settings = module.Data and module.Data.Settings
	local v4 = settings and settings[p]
	return math.clamp((typeof(v4) ~= "number" or v4 ~= v4) and 50 or v4, 0, 100) / 100
end

function Sound:PlayEffect(value: string, p)
	local sounds = module.Assets:FindFirstChild("Sounds")

	for _, childName in string.split(value, ".") do
		sounds = sounds and sounds:FindFirstChild(childName)
	end

	return self:Play(sounds, nil, false, p)
end

function Sound:Destroy()
	flag = true

	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, v4 in v2 do
		Finish(v4, false)
	end

	table.clear(v3)

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if currentCameraChangedConnection then
		currentCameraChangedConnection:Disconnect()
		currentCameraChangedConnection = nil
	end

	if audioListener then
		audioListener:Destroy()
		audioListener = nil
	end

	if audioDeviceOutput then
		audioDeviceOutput:Destroy()
		audioDeviceOutput = nil
	end
end

thread = task.defer(function()
	local sounds = module.Assets:FindFirstChild("Sounds")
	local sounds2 = {}

	if sounds then
		local musics = sounds:FindFirstChild("Musics")

		for _, sound in sounds:GetDescendants() do
			if not sound:IsA("Sound") or musics and sound:IsDescendantOf(musics) then
				continue
			end

			table.insert(sounds2, sound)
		end
	end

	pcall(function()
		local ContentProvider = game:GetService("ContentProvider")
		ContentProvider:PreloadAsync(sounds2)
	end)
	thread = nil
end)
currentCameraChangedConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(EnsureListener)
script.Destroying:Connect(function()
	Sound:Destroy()
end)
return Sound