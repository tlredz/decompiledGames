local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local Mushrooms = require(script.Parent.Mushrooms)
local v = { 1, 1.0594630943592953, 1.4142135623730951 }
local v2 = nil
local count = 0

local function play(p: number, p2: number, volume: number)
	local mushroom = BanjoCricket.Mushrooms[p]
	local anchor = Mushrooms.Anchor(p)

	if mushroom == nil or anchor == nil then
		return nil
	end

	return Audio.Play(mushroom.Sound, anchor, {
		MaxDistance = 90,
		PlaybackSpeed = mushroom.Speed * p2,
		Volume = volume
	})
end

local v3 = {
	Note = function(p: number)
		play(p, 1, BanjoCricket.Volume.Note)
	end,
	Muted = function(p: number)
		local v4 = play(p, 1, BanjoCricket.Volume.Muted)

		if v4 == nil then
			return
		end

		task.delay(0.1, function()
			local tween = TweenService:Create(v4, TweenInfo.new(0.06), {
				Volume = 0
			})
			tween.Completed:Once(function()
				v4:Stop()
			end)
			tween:Play()
		end)
	end,
	Soft = function(p: number, value: number?)
		play(p, 2 ^ (value or 0), BanjoCricket.Volume.Soft)
	end,
	Sour = function(p: number)
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v4 in v do
			local v5 = play(p, v4, BanjoCricket.Volume.Sour)

			if v5 then
				TweenService:Create(v5, tweenInfo, {
					PlaybackSpeed = v5.PlaybackSpeed * 0.9
				}):Play()
			end
		end
	end,
	Run = function()
		for k in BanjoCricket.Mushrooms do
			task.delay((k - 1) * 0.07, play, k, 1, BanjoCricket.Volume.Soft)
		end
	end,
	Strum = function()
		local v4 = {
			MaxDistance = 90,
			Volume = BanjoCricket.Volume.Strum
		}

		for k, mushroom in BanjoCricket.Mushrooms do
			local anchor = Mushrooms.Anchor(k)

			if anchor == nil then
				continue
			end

			local v5 = (k - 1) * 0.045
			task.delay(v5, Audio.Play, mushroom.Sound, anchor, v4)
		end
	end,
	Creak = function(cframe: CFrame, p: number)
		Audio.Play(BanjoCricket.Sounds.Creak, cframe, {
			MaxDistance = 90,
			PlaybackSpeed = 1.1 - p * 0.3,
			Volume = BanjoCricket.Volume.Creak * (p * 0.5 + 0.5)
		})
	end,
	Duck = function(duration: number)
		local music = SoundService:FindFirstChild("Music")

		if music == nil or not music:IsA("SoundGroup") then
			return
		end

		local v4 = v2

		if v4 == nil or v4.Parent == nil then
			v4 = Instance.new("EqualizerSoundEffect")
			v4.Name = "BanjoCricketDuck"
			v4.HighGain = 0
			v4.MidGain = 0
			v4.LowGain = 0
			v4.Parent = music
			v2 = v4
		end

		count += 1
		local v5 = count
		TweenService:Create(v4, TweenInfo.new(0.25), {
			HighGain = -10,
			MidGain = -10,
			LowGain = -10
		}):Play()
		task.delay(duration, function()
			if count ~= v5 or v4.Parent == nil then
				return
			end

			TweenService:Create(v4, TweenInfo.new(0.6), {
				HighGain = 0,
				MidGain = 0,
				LowGain = 0
			}):Play()
		end)
	end
}
return table.freeze(v3)