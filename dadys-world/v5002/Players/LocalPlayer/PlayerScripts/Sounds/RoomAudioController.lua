local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local modules = ReplicatedStorage:WaitForChild("Modules")
local RoomAudioConfig = require(modules:WaitForChild("Zones"):WaitForChild("RoomAudioConfig"))
local MyDataController = require(modules:WaitForChild("ClientUI"):WaitForChild("MyDataController"))
local v = nil
pcall(function()
	local SoundGroupManager = require(modules:WaitForChild("Audio"):WaitForChild("SoundGroupManager"))
	v = SoundGroupManager
end)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v2 = nil
local v3 = {}
local v4 = {}
local indexes = {}
local flag = false
local thread = nil
local folder = Instance.new("Folder")
folder.Name = "RoomAudioSounds"
folder.Parent = SoundService

local function Shuffle(list)
	for i = 1, #list - 1 do
		local v5 = math.random(i, #list)
		local v6 = list[v5]
		local v7 = list[i]
		list[i] = v6
		list[v5] = v7
	end
end

local function SeedMusicMuteState()
	if not (v and v.GetGroup) then
		return
	end

	local group = v.GetGroup("Music")

	if not group then
		return
	end

	group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
end

local function CreateSound(data, p)
	local sound = Instance.new("Sound")
	sound.Name = data.name
	sound.SoundId = "rbxassetid://" .. tostring(data.id)
	sound.Volume = data.volume or 0.5
	sound.Looped = data.looped or false
	sound.PlaybackSpeed = data.playbackSpeed or 1
	sound.RollOffMode = Enum.RollOffMode.Inverse
	sound.RollOffMaxDistance = 10000
	sound.Parent = p or folder

	if data.music then
		if v and v.AssignMusicSound then
			v.AssignMusicSound(sound)
			local v5 = v and v.GetGroup and v.GetGroup("Music")

			if v5 then
				v5.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
			end
		end
	elseif v and v.AssignAmbienceSound then
		v.AssignAmbienceSound(sound)
	end

	if not data.effects then
		return sound
	end

	for _, effect in ipairs(data.effects) do
		local v5 = effect
		local success, result = pcall(function()
			local instance = Instance.new(v5.Type)

			for k, v6 in pairs(v5.Properties or {}) do
				instance[k] = v6
			end

			instance.Parent = sound

			for k, tag in pairs(v5.Tags or {}) do
				if tag and typeof(tag) == "string" then
					instance:AddTag(tag)
				end
			end
		end)

		if not success then
			warn("[RoomAudioController] Failed to apply effect", tostring(effect.Type), "-", result)
		end
	end

	return sound
end

local function CleanupSounds()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, v5 in ipairs(v3) do
		if not (v5 and v5.Parent) then
			continue
		end

		local tween = TweenService:Create(v5, tweenInfo2, {
			Volume = 0
		})
		tween:Play()
		local v6 = v5
		tween.Completed:Connect(function()
			v6:Stop()
			v6:Destroy()
		end)
	end

	for _, v5 in ipairs(v4) do
		if not (v5 and v5.Parent) then
			continue
		end

		v5:Stop()
		v5:Destroy()
	end

	v3 = {}
	v4 = {}
	indexes = {}
	flag = false
end

local function StartRoomAudio(p)
	local roomConfig = RoomAudioConfig.GetRoomConfig(p)

	if not roomConfig then
		warn("[RoomAudioController] No audio config found for room:", p)
		return
	end

	CleanupSounds()
	v2 = p
	flag = true

	if roomConfig.ambience then
		for _, v5 in ipairs(roomConfig.ambience) do
			local sound = CreateSound({
				name = v5.name,
				id = v5.id,
				volume = v5.volume,
				looped = true,
				playbackSpeed = v5.playbackSpeed,
				music = v5.music,
				effects = v5.effects
			})
			local volume = sound.Volume
			sound.Volume = 0
			sound:Play()
			TweenService:Create(sound, tweenInfo, {
				Volume = volume
			}):Play()
			table.insert(v3, sound)
		end
	end

	if roomConfig.randomSounds then
		for _, randomSound in ipairs(roomConfig.randomSounds) do
			local sound = CreateSound({
				name = randomSound.name,
				id = randomSound.id,
				volume = randomSound.volume,
				looped = false,
				playbackSpeed = randomSound.playbackSpeed,
				music = randomSound.music,
				effects = randomSound.effects
			})
			table.insert(v4, sound)
		end
	end

	local randomInterval = roomConfig.randomInterval or {
		min = 20,
		max = 25
	}
	thread = task.spawn(function()
		while flag do
			task.wait(math.random(randomInterval.min, randomInterval.max))

			if not flag then
				break
			end

			if #indexes >= #v4 then
				indexes = {}
			end

			local v5 = {}

			for i, sound2 in ipairs(v4) do
				table.insert(v5, {
					index = i,
					sound = sound2
				})
			end

			Shuffle(v5)
			local sound = nil

			for _, v7 in ipairs(v5) do
				if table.find(indexes, v7.index) then
					continue
				end

				table.insert(indexes, v7.index)
				sound = v7.sound
				break
			end

			if not (sound and sound.Parent) then
				continue
			end

			sound:Stop()
			sound:Play()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopRoomAudio()
	if v2 then
		CleanupSounds()
		v2 = nil
	end
end

local function SetupRoomListener()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	local function OnRoomChanged()
		local currentRoom2 = workspace:FindFirstChild("CurrentRoom")

		if currentRoom2 then
			local v5 = nil

			for _, child in ipairs(currentRoom2:GetChildren()) do
				if not (child:IsA("Model") or child:IsA("Folder")) then
					continue
				end

				v5 = child
				break
			end

			if v5 then
				local name = v5.Name
				local v7 = name:match("[^/]+$") or name

				if v7 ~= v2 then
					StartRoomAudio(v7)
				end
			else
				StopRoomAudio() -- equivalent call inferred; original call site unknown
			end
		else
			StopRoomAudio() -- equivalent call inferred; original call site unknown
		end
	end

	OnRoomChanged()
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "CurrentRoom" then
			task.wait(0.5)
			OnRoomChanged()
			child.ChildAdded:Connect(OnRoomChanged)
			child.ChildRemoved:Connect(OnRoomChanged)
		end
	end)
	workspace.ChildRemoved:Connect(function(child)
		if child.Name == "CurrentRoom" and v2 then
			CleanupSounds()
			v2 = nil
		end
	end)

	if currentRoom then
		currentRoom.ChildAdded:Connect(OnRoomChanged)
		currentRoom.ChildRemoved:Connect(OnRoomChanged)
	end
end

local function SetupSpecialLevelListener()
	local specialLevelEventRemote = ReplicatedStorage:WaitForChild("SpecialLevelEventRemote", 10)

	if specialLevelEventRemote then
		specialLevelEventRemote.OnClientEvent:Connect(function(p, p2, p3, _)
			if p == "ExecuteLocalEvent" and p3 then
				local v5 = p2 or p3 and p3.Name

				if v5 then
					StartRoomAudio(v5:gsub("Event$", ""))
				end
			elseif p == "CleanupLocalEvent" and v2 then
				CleanupSounds()
				v2 = nil
			end
		end)
		return true
	end

	warn("[RoomAudioController] SpecialLevelEventRemote not found - using fallback detection")
	return false
end

local function SetupRemoteListener()
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local roomAudioEvent = events:FindFirstChild("RoomAudioEvent")

	if roomAudioEvent then
		roomAudioEvent.OnClientEvent:Connect(function(p, p2)
			if p == "Start" then
				StartRoomAudio(p2)
			elseif p == "Stop" and v2 then
				CleanupSounds()
				v2 = nil
			end
		end)
	end
end

local function SetupMusicBedListener()
	local function RouteMusicBed(sound)
		if not (sound:IsA("Sound") and v and v.AssignMusicSound) then
			return
		end

		if not v.AssignMusicSound(sound) then
			warn("[RoomAudioController] Could not route music bed onto the Music bus:", sound:GetFullName())
		elseif v then
			if not v.GetGroup then
				return
			end

			local group = v.GetGroup("Music")

			if not group then
				return
			end

			group.Volume = MyDataController:getDataFromPath("Settings.MusicToggle") == true and 0 or 1
		end
	end

	CollectionService:GetInstanceAddedSignal("MusicBed"):Connect(RouteMusicBed)

	for _, v5 in ipairs(CollectionService:GetTagged("MusicBed")) do
		RouteMusicBed(v5)
	end
end

local RoomAudioController = {
	StartRoom = function(p)
		StartRoomAudio(p)
	end,
	StopRoom = function()
		StopRoomAudio() -- equivalent call inferred; original call site unknown
	end,
	GetCurrentRoom = function()
		return v2
	end,
	IsPlaying = function()
		return flag
	end
}
SetupMusicBedListener()
SetupSpecialLevelListener()
SetupRemoteListener()
SetupRoomListener()
return RoomAudioController