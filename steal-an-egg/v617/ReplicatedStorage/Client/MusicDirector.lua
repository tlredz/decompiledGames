local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Player = require(ReplicatedStorage.Shared.Player)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local AreaEggResetCycle = require(ReplicatedStorage.Data.AreaEggResetCycle)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
local shuffle = Numeric.Shuffle
local TreadmillVideoGate = require(ReplicatedStorage.Client.TreadmillVideoGate)
local v = {}
local separationLine = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("SeparationLine")
local localPlayer = Players.LocalPlayer
local clone = table.clone({
	1836009208,
	1846088038,
	9045766074,
	1842150151
})
shuffle(clone, Random.new())
local v2 = 1
local musicTrack = Audio.MusicTrack({
	Name = "OutdoorMusic",
	Source = clone[v2],
	Looped = false
})
local musicTrack2 = Audio.MusicTrack({
	Name = "ArenaMusic",
	Source = 5026653246,
	Looped = true
})
local musicTrack3 = Audio.MusicTrack({
	Name = "ChaseMusic",
	Source = 77770487605071,
	Looped = true
})
local musicTrack4 = Audio.MusicTrack({
	Name = "SafeZoneMusic",
	Source = 77770487605071,
	Looped = true
})
local v3

if AreaEggResetCycle.NightMusic then
	v3 = Audio.MusicTrack({
		Name = "ResetNightMusic",
		Source = AreaEggResetCycle.NightMusic.Id,
		Looped = true
	})
else
	v3 = nil
end

local musicTrack5 = Audio.MusicTrack({
	Name = "DrScrambleMusic",
	Source = 116561685928578,
	Looped = true
})
local v4 = {
	musicTrack,
	musicTrack2,
	musicTrack3,
	musicTrack4,
	musicTrack5
}

if v3 then
	table.insert(v4, v3)
end

local v5 = {}
local v6 = false
local v7 = false
local v8 = false
local flag = false
local v9 = false
local v10 = false
local v11 = false
local v12 = false
local v13 = false
local isOn = Preferences.IsOn("Music")
local isHidden = HiddenUIHandler.IsHidden()
local v14 = ""
local v15 = 0

local function fade(object, volume: number, seconds: number, flag2: boolean?)
	local v16 = v5[object]

	if v16 then
		v16:Cancel()
	end

	if (volume > 0 or flag2) and not object.IsPlaying then
		object:Play()
	end

	local fadeTo = Audio.FadeTo(object, {
		Volume = volume,
		Seconds = seconds,
		Style = Enum.EasingStyle.Quad,
		Direction = Enum.EasingDirection.InOut
	})
	v5[object] = fadeTo
	fadeTo.Completed:Once(function(p3)
		if v5[object] ~= fadeTo then
			return
		end

		v5[object] = nil

		if p3 == Enum.PlaybackState.Completed and volume <= 0 and not flag2 then
			object:Pause()
		end
	end)
end

local function treadmillFeedActive()
	return v11 and not TreadmillVideoGate.IsVideoPlayerDisabled()
end

local function mode()
	if not isOn then
		return "Silent"
	end

	if v13 and not v12 and (not v11 or TreadmillVideoGate.IsVideoPlayerDisabled()) and not isHidden then
		return "Scramble"
	end

	if v9 then
		return "Night"
	end

	if v11 and not TreadmillVideoGate.IsVideoPlayerDisabled() then
		return "Treadmill"
	end

	if v12 or v7 then
		return "Silent"
	end

	if v8 then
		if v6 then
			return "Chase"
		end

		return "Arena"
	else
		if isHidden then
			return "Silent"
		end

		if flag then
			return "SafeZone"
		end

		return "Outdoor"
	end
end

local function refresh()
	local v16

	if isOn then
		if v13 and not v12 and (not v11 or TreadmillVideoGate.IsVideoPlayerDisabled()) and not isHidden then
			v16 = "Scramble"
		elseif v9 then
			v16 = "Night"
		elseif v11 and not TreadmillVideoGate.IsVideoPlayerDisabled() then
			v16 = "Treadmill"
		elseif v12 or v7 then
			v16 = "Silent"
		elseif v8 then
			v16 = v6 and "Chase" or "Arena"
		else
			v16 = isHidden and "Silent" or flag and "SafeZone" or "Outdoor"
		end
	else
		v16 = "Silent"
	end

	local v17 = v14
	v14 = v16
	local seconds = (v16 == "Chase" or v17 == "Chase") and 0.1 or (v16 == "Arena" or v17 == "Arena") and 0.4 or 0.8
	fade(musicTrack, v16 == "Outdoor" and 0.22 or 0, seconds, true)
	fade(musicTrack2, v16 == "Arena" and 1.5 or 0, seconds)
	fade(musicTrack3, v16 == "Chase" and 0.4 or 0, seconds)
	fade(musicTrack4, v16 == "SafeZone" and 0.5 or 0, seconds)
	fade(musicTrack5, v16 == "Scramble" and 0.5 or 0, seconds)

	if v3 then
		fade(
			v3,
			(v16 ~= "Night" or not v10) and 0 or AreaEggResetCycle.NightMusic.Volume,
			AreaEggResetCycle.MusicTransitionSeconds
		)
	end

	local adminAbuseMusic = SoundService.Music:FindFirstChild("AdminAbuseMusic")

	if adminAbuseMusic and adminAbuseMusic:IsA("SoundGroup") then
		adminAbuseMusic.Volume = v11 and not TreadmillVideoGate.IsVideoPlayerDisabled() and 0 or 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateArena()
	local rootPart = Player.FindRootPart(localPlayer)
	local v16

	if rootPart == nil then
		v16 = false
	else
		v16 = GuardAreaGeometry.IsPastLine(separationLine, rootPart.Position)
	end

	if v8 ~= v16 then
		v8 = v16
		refresh()
	end
end

function v.EnterSaveZone()
	if not flag then
		flag = true
		refresh()
	end
end

function v.ExitSaveZone()
	if flag then
		flag = false
		refresh()
	end
end

function v.HasCustomTreadmill()
	return v11
end

function v.SetCarryingAreaEgg(flag2: boolean)
	if v6 ~= flag2 then
		v6 = flag2
		refresh()
	end
end

function v.SetGuardedGameplay(flag2: boolean)
	if v7 ~= flag2 then
		v7 = flag2
		refresh()
	end
end

function v.SetScrambleActive(flag2: boolean)
	if v13 ~= flag2 then
		v13 = flag2
		refresh()
	end
end

function v.SetEventMusic(flag2: boolean)
	if v12 ~= flag2 then
		v12 = flag2
		refresh()
	end
end

function v.SetResetNight(flag2: boolean, flag3: boolean?)
	local v16 = flag2 and flag3 == true

	if v9 ~= flag2 or v10 ~= v16 then
		v9 = flag2
		v10 = v16
		refresh()
	end
end

musicTrack.Ended:Connect(function()
	v2 += 1

	if v2 > #clone then
		shuffle(clone, Random.new())
		v2 = 1
	end

	musicTrack.SoundId = `rbxassetid://{clone[v2]}`
	musicTrack:Play()
end)
Preferences.Observe("Music", function(flag2: boolean)
	if flag2 == isOn then
		return
	end

	isOn = flag2
	refresh()
end)
HiddenUIHandler.Changed:Connect(function(flag2: boolean)
	isHidden = flag2
	refresh()
end)
Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
	v11 = p ~= nil
	refresh()
end)
TreadmillVideoGate.Changed:Connect(function()
	if v11 then
		refresh()
	end
end)
RunService.Heartbeat:Connect(function(dt: number)
	v15 += dt

	if v15 >= 0.1 then
		v15 %= 0.1
		updateArena() -- equivalent call inferred; original call site unknown
	end
end)
musicTrack:Play()
updateArena() -- equivalent call inferred; original call site unknown
refresh()
return table.freeze(v)