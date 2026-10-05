local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.UserGenerated.Concurrency.Render)

local function GetOriginal(instance, p: string)
	local formatted = `Original{p}`
	local attribute = instance:GetAttribute(formatted)

	if attribute == nil then
		attribute = instance[p]
		instance:SetAttribute(formatted, attribute)
	end

	return attribute
end

local function Set(instance, p: string, p2)
	local formatted = `Original{p}`
	local attribute = instance:GetAttribute(formatted)

	if attribute == nil then
		attribute = instance[p]
		instance:SetAttribute(formatted, attribute)
	end

	if p2 == nil then
		p2 = attribute
	end

	instance[p] = p2
end

local function SetGiantSteps(instance, flag: boolean)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	local running = primaryPart:WaitForChild("Running", 30)
	assert(running:IsA("Sound"))
	local soundId = flag and "rbxassetid://72918943937811" or nil
	local originalSoundId = running:GetAttribute("OriginalSoundId")

	if originalSoundId == nil then
		originalSoundId = running.SoundId
		running:SetAttribute("OriginalSoundId", originalSoundId)
	end

	if soundId == nil then
		soundId = originalSoundId
	end

	running.SoundId = soundId
	local playbackSpeed = flag and 1.9040000000000001 or nil
	local originalPlaybackSpeed = running:GetAttribute("OriginalPlaybackSpeed")

	if originalPlaybackSpeed == nil then
		originalPlaybackSpeed = running.PlaybackSpeed
		running:SetAttribute("OriginalPlaybackSpeed", originalPlaybackSpeed)
	end

	if playbackSpeed == nil then
		playbackSpeed = originalPlaybackSpeed
	end

	running.PlaybackSpeed = playbackSpeed
	local volume = flag and 3 or nil
	local originalVolume = running:GetAttribute("OriginalVolume")

	if originalVolume == nil then
		originalVolume = running.Volume
		running:SetAttribute("OriginalVolume", originalVolume)
	end

	if volume == nil then
		volume = originalVolume
	end

	running.Volume = volume
end

local function WatchCharacter(_, character)
	character:WaitForChild("HumanoidRootPart", 30)
	character:GetAttributeChangedSignal("GiantSteps"):Connect(function()
		SetGiantSteps(character, character:GetAttribute("GiantSteps") == true)
	end)
	SetGiantSteps(character, character:GetAttribute("GiantSteps") == true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchPlayer(player)
	player.CharacterAdded:Connect(function(character)
		WatchCharacter(player, character)
	end)
	local character = player.Character

	if character then
		task.spawn(WatchCharacter, player, character)
	end
end

Players.PlayerAdded:Connect(function(player)
	WatchPlayer(player) -- equivalent call inferred; original call site unknown
end)

for _, v in ipairs(Players:GetPlayers()) do
	task.spawn(WatchPlayer, v)
end