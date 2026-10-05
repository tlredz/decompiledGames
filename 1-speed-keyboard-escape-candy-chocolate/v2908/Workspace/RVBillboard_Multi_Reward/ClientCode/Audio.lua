local SoundService = game:GetService("SoundService")
local v = {
	AdComplete = {
		id = "rbxassetid://15675043410",
		volume = 0.4
	},
	Click = {
		id = "rbxassetid://15675059323",
		volume = 0.2
	},
	Enter = {
		id = "rbxassetid://96158989044754",
		volume = 0.2
	}
}
local v2 = {}

local function getSound(name: string)
	local v3 = v2[name]

	if v3 then
		return v3
	end

	local v4 = v[name]
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = v4.id
	sound.Volume = v4.volume
	sound.Parent = SoundService

	if name == "Enter" then
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = 0.4
		pitchShiftSoundEffect.Parent = sound
	end

	v2[name] = sound
	return sound
end

local Audio = {}

function Audio.playAdCompleteSound()
	local adComplete2 = v2.AdComplete

	if not adComplete2 then
		local adComplete = v.AdComplete
		adComplete2 = Instance.new("Sound")
		adComplete2.Name = "AdComplete"
		adComplete2.SoundId = adComplete.id
		adComplete2.Volume = adComplete.volume
		adComplete2.Parent = SoundService
		v2.AdComplete = adComplete2
	end

	adComplete2:Play()
end

function Audio.playClickSound()
	local click2 = v2.Click

	if not click2 then
		local click = v.Click
		click2 = Instance.new("Sound")
		click2.Name = "Click"
		click2.SoundId = click.id
		click2.Volume = click.volume
		click2.Parent = SoundService
		v2.Click = click2
	end

	click2:Play()
end

function Audio.playEnterSound()
	local v3 = v2.Enter

	if not v3 then
		local enter = v.Enter
		v3 = Instance.new("Sound")
		v3.Name = "Enter"
		v3.SoundId = enter.id
		v3.Volume = enter.volume
		v3.Parent = SoundService
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = 0.4
		pitchShiftSoundEffect.Parent = v3
		v2.Enter = v3
	end

	v3:Play()
end

return Audio