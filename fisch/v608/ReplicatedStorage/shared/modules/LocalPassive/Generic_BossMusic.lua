local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local module = require("./PassiveHandler")
local flag = false
local GenericBossMusic = {
	MorphSpear = true,
	Morph = function(data, _, p)
		local sound = script.Music:FindFirstChild(data.config.MusicName)

		if not (sound and sound:IsA("Sound")) then
			warn((`No music found named "{data.config.MusicName}"`))
			return
		end

		if p.rodName == "Lullaby" then
			return
		end

		local volume = sound:GetAttribute("Volume") or sound.Volume
		local soundId = sound:GetAttribute("SoundId") or sound.SoundId
		local volume2 = volume == 0 and 0.5 or volume

		if flag then
			return
		end

		flag = true
		data.reelTrove:Add(function()
			flag = false
		end)
		ContentProvider:PreloadAsync({ soundId })
		local music = SoundService:WaitForChild("music")
		TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			Volume = 0
		}):Play()
		data.reelTrove:Add(function()
			TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
			}):Play()
			local tween = TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Volume = 0
			})
			tween.Completed:Once(function()
				sound:Stop()
				tween:Destroy()
			end)
			tween:Play()
		end)
		data.reelTrove:Add(data.current.OnReady:Once(function()
			sound.Volume = volume2
			sound:Play()
		end))
	end
}
setmetatable(GenericBossMusic, module)
return GenericBossMusic