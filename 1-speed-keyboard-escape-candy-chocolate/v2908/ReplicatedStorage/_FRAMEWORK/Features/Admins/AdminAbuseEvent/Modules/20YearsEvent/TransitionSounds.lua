local SoundService = game:GetService("SoundService")
require(script.Parent.Types)
local random = Random.new()
local v = {}
local TransitionSounds = {}

function TransitionSounds.play(data)
	if data.soundId == "" then
		return
	end

	local pitch = data.pitch
	local sound = Instance.new("Sound")
	sound.Name = "AnniversaryTransitionSound"
	sound.SoundId = data.soundId
	sound.Volume = data.volume

	if typeof(pitch) == "NumberRange" then
		pitch = random:NextNumber(pitch.Min, pitch.Max)
	end

	sound.PlaybackSpeed = pitch
	sound:SetAttribute("IsEventSound", true)
	local aAMusicVolumeGroup = SoundService:FindFirstChild("AAMusicVolumeGroup")

	if aAMusicVolumeGroup and aAMusicVolumeGroup:IsA("SoundGroup") then
		sound.SoundGroup = aAMusicVolumeGroup
	end

	v[sound] = true
	sound.Ended:Once(function()
		v[sound] = nil
		sound:Destroy()
	end)
	sound.Parent = SoundService
	sound:Play()
end

function TransitionSounds.cleanup()
	for k in v do
		k:Destroy()
	end

	table.clear(v)
end

return TransitionSounds