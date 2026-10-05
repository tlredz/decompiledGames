local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
require("./Types")
local module = require("../SettingsController")
local ReelFX = {}
ReelFX.__index = ReelFX

function ReelFX.Shake(_, instance, p, p2, duration, p3, value)
	if not instance:GetAttribute("RootPosition") then
		instance:SetAttribute("RootPosition", instance.Position)
		local _ = instance.Position
	end

	for _ = 0, p2, duration do
		instance.Position = instance:GetAttribute("RootPosition"):Lerp(
			instance:GetAttribute("RootPosition") + UDim2.new(
				Random.new():NextNumber(-0.05, 0.05),
				0,
				Random.new():NextNumber(-0.08, 0.08),
				0
			),
			p * module:GetSettingValue("minigameShake")
		)

		if p3 then
			instance.Rotation = math.lerp(
				0,
				Random.new():NextNumber(-8, 8),
				p * module:GetSettingValue("minigameShake")
			)
		end

		p *= value or 0.9
		task.wait(duration)
	end

	instance.Position = instance:GetAttribute("RootPosition")
	instance.Rotation = p3 and 0 or instance.Rotation
end

function ReelFX.SpawnShake(_, ...)
	return task.spawn(ReelFX.Shake, ReelFX, ...)
end

local function resizeSlash(udim: UDim2, p: number, p2: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset, udim.Y.Scale * p2, udim.Y.Offset)
end

function ReelFX.Slash(p, data)
	local clone = script.slashcontainer:Clone()
	clone.Size = data.TargetButton.Size
	clone.Position = data.TargetButton.Position
	local sound = typeof(data.Sound) == "table" and data.Sound or { data.Sound or ReplicatedStorage.resources.sounds.sfx.fishing.slashes.stabbystab }

	for _, soundId in ipairs(sound) do
		local v2

		if typeof(soundId) == "string" then
			v2 = Instance.new("Sound")
			v2.SoundId = soundId
		else
			v2 = soundId:Clone()
		end

		if typeof(data.SoundPitch) == "number" then
			v2.PlaybackSpeed = data.SoundPitch
		else
			local soundPitch = data.SoundPitch or NumberRange.new(0.95, 1.1)
			v2.PlaybackSpeed = Random.new():NextNumber(soundPitch.Min, soundPitch.Max)
		end

		v2.Parent = p.current.ui
		v2:Play()
		p.current.trove:Add(v2)

		if v2.IsPlaying then
			v2.Ended:Once(function()
				p.current.trove:Remove(v2)
			end)
		else
			p.current.trove:Remove(v2)
		end
	end

	local clone2

	if typeof(data.Icon) == "table" then
		clone2 = data.Icon[math.random(1, #data.Icon)]:Clone()
	else
		clone2 = (data.Icon or ReplicatedStorage.resources.replicated.fishing.slashes["Default Slash"]):Clone()
	end

	if typeof(data.IconRotation) == "number" then
		clone2.Rotation = data.IconRotation
	else
		local iconRotation = data.IconRotation or NumberRange.new(0, 360)
		clone2.Rotation = Random.new():NextNumber(iconRotation.Min, iconRotation.Max)
	end

	if clone2:IsA("ImageLabel") then
		clone2.ImageTransparency = 0

		if data.IconColor then
			clone2.ImageColor3 = data.IconColor
		end
	end

	clone2.Parent = clone
	clone.Parent = p.current.ui_safezone
	local time = data.Time or 0.4
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local fullSize = data.FullSize or UDim2.fromScale(10.188, 4.5)
	local v4 = TweenService:Create(clone2, tweenInfo, {
		Size = UDim2.new(fullSize.X.Scale * 0.1, fullSize.X.Offset, fullSize.Y.Scale * 0.5, fullSize.Y.Offset)
	})
	v4:Play()
	v4.Completed:Once(function()
		v4:Destroy()
	end)
	task.defer(function()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BorderSizePixel = 0
		frame.ZIndex = p.current.ui_progress.bar.ZIndex + 100
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 45
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Offset = Vector2.new(-1, 0)
		uIGradient.Parent = frame

		if data.Color then
			if typeof(data.Color) == "Color3" then
				frame.BackgroundColor3 = data.Color
			elseif typeof(data.Color) == "ColorSequence" then
				uIGradient.Color = data.Color
			else
				error("Invalid color type passed to slash function")
			end
		end

		frame.Parent = p.current.ui_progress.bar
		local tween = TweenService:Create(
			uIGradient,
			TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			{
				Offset = Vector2.new(1, 0)
			}
		)
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
		frame:Destroy()
	end)
	task.delay(time, function()
		local tweenInfo2 = TweenInfo.new(time / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local endSize = data.EndSize or UDim2.fromScale(7, 4.75)
		local v8 = TweenService:Create(clone2, tweenInfo2, {
			Size = UDim2.new(endSize.X.Scale * 0.1, endSize.X.Offset, endSize.Y.Scale * 0.5, endSize.Y.Offset),
			ImageTransparency = 1
		})
		v8:Play()
		v8.Completed:Once(function()
			v8:Destroy()
			clone:Destroy()
		end)
	end)
	return v4
end

return ReelFX