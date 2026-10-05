local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local MusicDirector = require(ReplicatedStorage.Client.MusicDirector)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
require(ReplicatedStorage.Packages.Trove)
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut
local v = nil
local v2 = {}
local v3 = false

local function resolveTrack(childName: string)
	local sound = script:FindFirstChild(childName)
	assert(sound and sound:IsA("Sound"), (`LightVsDarkness.{childName} must be a Sound`))
	local adminAbuseMusic = SoundService.Music:FindFirstChild("AdminAbuseMusic")
	assert(
		adminAbuseMusic and adminAbuseMusic:IsA("SoundGroup"),
		"SoundService.Music.AdminAbuseMusic must be a SoundGroup"
	)
	sound.SoundGroup = adminAbuseMusic
	sound.Looped = true
	return {
		Sound = sound,
		Volume = sound.Volume
	}
end

local track = resolveTrack("MusicNormal")
local track2 = resolveTrack("MusicIntense")

local function fade(track3, volume: number)
	local sound = track3.Sound
	local v4 = v2[sound]

	if v4 then
		v4:Cancel()
	end

	if volume > 0 and not sound.IsPlaying then
		sound.Volume = 0
		sound:Play()
	end

	local fadeTo = Audio.FadeTo(sound, {
		Volume = volume,
		Seconds = 1.5,
		Style = quad,
		Direction = inOut
	})
	v2[sound] = fadeTo
	fadeTo.Completed:Once(function(p2)
		if v2[sound] ~= fadeTo then
			return
		end

		v2[sound] = nil

		if p2 == Enum.PlaybackState.Completed and volume <= 0 then
			sound:Stop()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFinalClash()
	return Workspace:GetAttribute("LvdFinalClash") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	local v4 = v3 and Preferences.IsOn("Music")
	local finalClash = isFinalClash() -- equivalent call inferred; original call site unknown
	fade(track, (not v4 or finalClash) and 0 or track.Volume)
	fade(track2, not (v4 and finalClash) and 0 or track2.Volume)
end

local function stop()
	if not v3 then
		return
	end

	v3 = false
	refresh() -- equivalent call inferred; original call site unknown
end

local function start()
	local assetTrove = v.AssetTrove
	v3 = true
	MusicDirector.SetEventMusic(true)
	assetTrove:Add(function()
		MusicDirector.SetEventMusic(false)
	end)
	assetTrove:Connect(Workspace:GetAttributeChangedSignal("LvdFinalClash"), refresh)
	assetTrove:Add(Preferences.Observe("Music", function()
		refresh() -- equivalent call inferred; original call site unknown
	end))
	assetTrove:Add(stop)
end

return function(p)
	v = p
	return {
		Start = start,
		Stop = stop
	}
end