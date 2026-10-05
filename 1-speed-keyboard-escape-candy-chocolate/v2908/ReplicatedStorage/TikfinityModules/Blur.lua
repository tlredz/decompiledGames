local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local _ = {
	DURATION = 3,
	BLUR_SIZE = 40,
	FADE_IN = 0.3,
	FADE_OUT = 0.5,
	SOUND_ID = "rbxassetid://135541330012995",
	SOUND_VOL = 0.4
}
return {
	Run = function(_)
		task.spawn(function()
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://135541330012995"
			sound.Volume = 0.4
			sound.Parent = SoundService
			sound:Play()
			Debris:AddItem(sound, 4)
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Name = "TikfinityBlur"
			blurEffect.Size = 0
			blurEffect.Parent = Lighting
			TweenService:Create(blurEffect, TweenInfo.new(0.3), {
				Size = 40
			}):Play()
			task.wait(3)
			local tween = TweenService:Create(blurEffect, TweenInfo.new(0.5), {
				Size = 0
			})
			tween:Play()
			tween.Completed:Wait()
			blurEffect:Destroy()
		end)
	end
}