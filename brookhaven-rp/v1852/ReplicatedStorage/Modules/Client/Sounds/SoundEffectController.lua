local SoundEffectController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function SoundEffectController:Play(volume: number)
	local sound = Instance.new("Sound")
	sound.Name = "SoundEffect"
	sound.SoundId = self
	sound.Volume = volume
	sound.Looped = false
	sound.Parent = SoundService
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
end

function SoundEffectController.FrameworkInit() end

function SoundEffectController.FrameworkStart()
	Remotes.connect("PlaySoundEffect", SoundEffectController.Play)
end

return SoundEffectController