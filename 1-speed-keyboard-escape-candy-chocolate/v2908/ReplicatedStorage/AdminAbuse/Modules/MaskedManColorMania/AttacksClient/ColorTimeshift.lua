local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local count = 0

local function _destroyFx()
	if v then
		v:Destroy()
		v = nil
	end

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	if v4 then
		v4:Destroy()
		v4 = nil
	end

	if v5 then
		v5:Destroy()
		v5 = nil
	end
end

local function _findActiveSoundtrack()
	for _, sound in CollectionService:GetTagged("Music") do
		if sound:IsA("Sound") and sound.IsPlaying then
			return sound
		end
	end

	return nil
end

local ColorTimeshift = {}

function ColorTimeshift.begin(value: number?)
	local v6 = value or 0.6
	count += 1
	_destroyFx()
	local Lighting = game:GetService("Lighting")
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "MaskedManTimeshiftCC"
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = Lighting
	v = colorCorrectionEffect
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Saturation = -1,
		Contrast = 0.4,
		Brightness = -0.12
	}):Play()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

	if playerGui then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MaskedManTimeshiftFlash"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 1000000
		screenGui.Parent = playerGui
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 0
		frame.BorderSizePixel = 0
		frame.Parent = screenGui
		v5 = screenGui
		TweenService:Create(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		task.delay(0.5, function()
			if not screenGui.Parent then
				return
			end

			frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			frame.BackgroundTransparency = 0.85
		end)
	end

	local parent = _findActiveSoundtrack()

	if parent and parent.Parent then
		local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
		equalizerSoundEffect.LowGain = 0
		equalizerSoundEffect.MidGain = 0
		equalizerSoundEffect.HighGain = 0
		equalizerSoundEffect.Parent = parent
		v2 = equalizerSoundEffect
		TweenService:Create(equalizerSoundEffect, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			HighGain = -20,
			MidGain = -8,
			LowGain = 2
		}):Play()
		local reverbSoundEffect = Instance.new("ReverbSoundEffect")
		reverbSoundEffect.DecayTime = 1.5
		reverbSoundEffect.Density = 1
		reverbSoundEffect.WetLevel = 0
		reverbSoundEffect.DryLevel = 0
		reverbSoundEffect.Parent = parent
		v3 = reverbSoundEffect
		TweenService:Create(reverbSoundEffect, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			DecayTime = 3,
			WetLevel = 6,
			DryLevel = -3
		}):Play()
		local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
		pitchShiftSoundEffect.Octave = 1
		pitchShiftSoundEffect.Parent = parent
		v4 = pitchShiftSoundEffect
		TweenService:Create(pitchShiftSoundEffect, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Octave = 0.7
		}):Play()
	end
end

function ColorTimeshift.finish(value: number?)
	local v6 = value or 0.5
	count += 1
	local v7 = count
	local v8 = v
	local v9 = v2
	local v10 = v3
	local v11 = v4
	local v12 = v5

	if v8 then
		TweenService:Create(v8, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Saturation = 0,
			Contrast = 0,
			Brightness = 0
		}):Play()
	end

	if v9 then
		TweenService:Create(v9, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			HighGain = 0,
			MidGain = 0,
			LowGain = 0
		}):Play()
	end

	if v10 then
		TweenService:Create(v10, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			WetLevel = 0,
			DryLevel = 0
		}):Play()
	end

	if v11 then
		TweenService:Create(v11, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Octave = 1
		}):Play()
	end

	if v12 and v12:FindFirstChildOfClass("Frame") then
		TweenService:Create(
			v12:FindFirstChildOfClass("Frame"),
			TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				BackgroundTransparency = 1
			}
		):Play()
	end

	task.delay(v6 + 0.05, function()
		if v7 ~= count then
			return
		end

		_destroyFx()
	end)
end

function ColorTimeshift.cleanup()
	count += 1
	_destroyFx()
end

return ColorTimeshift