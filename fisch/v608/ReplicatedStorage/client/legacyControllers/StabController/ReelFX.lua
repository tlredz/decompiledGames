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

function ReelFX.Slash(p, options)
	local v = options or {}

	for _, soundId in typeof(v.Sound) == "table" and v.Sound or { v.Sound or ReplicatedStorage.resources.sounds.sfx.fishing.slashes.stabbystab } do
		local v3

		if typeof(soundId) == "string" then
			v3 = Instance.new("Sound")
			v3.SoundId = soundId
		else
			v3 = soundId:Clone()
		end

		if typeof(v.SoundPitch) == "number" then
			v3.PlaybackSpeed = v.SoundPitch
		else
			local soundPitch = v.SoundPitch or NumberRange.new(0.95, 1.1)
			v3.PlaybackSpeed = Random.new():NextNumber(soundPitch.Min, soundPitch.Max)
		end

		v3.Parent = p.current.reel
		v3:Play()
		p.current.trove:Add(v3)

		if v3.IsPlaying then
			v3.Ended:Once(function()
				p.current.trove:Remove(v3)
			end)
		else
			p.current.trove:Remove(v3)
		end
	end

	local clone

	if typeof(v.Icon) == "table" then
		clone = v.Icon[math.random(1, #v.Icon)]:Clone()
	else
		clone = (v.Icon or ReplicatedStorage.resources.replicated.fishing.slashes["Default Slash"]):Clone()
	end

	if typeof(v.IconRotation) == "number" then
		clone.Rotation = v.IconRotation
	else
		local iconRotation = v.IconRotation or NumberRange.new(0, 360)
		clone.Rotation = Random.new():NextNumber(iconRotation.Min, iconRotation.Max)
	end

	if clone:IsA("ImageLabel") then
		clone.ImageTransparency = 0

		if v.IconColor then
			clone.ImageColor3 = v.IconColor
		end
	end

	local v2 = 1
	local v3 = 1

	if p.current.isSimplified then
		local position = clone.Position
		clone.Position = UDim2.new(math.random(), position.X.Offset, position.Y.Scale, position.Y.Offset)
		local _ = clone.Size
		v2 = 0.01 / p.current.reel_playerbar.Size.X.Scale
		v3 = 1.5384615384615383
		local size = clone.Size
		clone.Size = UDim2.new(size.X.Scale * v2, size.X.Offset, size.Y.Scale * v3, size.Y.Offset)
		clone.Parent = p.current.reel_playerbar
	else
		clone.Parent = p.current.reel_bar.fish
	end

	local time = v.Time or 0.4
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local fullSize = v.FullSize or UDim2.fromScale(10.188, 4.5)
	local v9 = TweenService:Create(clone, tweenInfo, {
		Size = UDim2.new(fullSize.X.Scale * v2, fullSize.X.Offset, fullSize.Y.Scale * v3, fullSize.Y.Offset)
	})
	v9:Play()
	v9.Completed:Once(function()
		v9:Destroy()
	end)
	task.defer(function()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BorderSizePixel = 0
		frame.ZIndex = p.current.reel_progress.bar.ZIndex + 100
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = p.current.isSimplified and 65 or 45
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Offset = Vector2.new(-1, 0)
		uIGradient.Parent = frame

		if v.Color then
			if typeof(v.Color) == "Color3" then
				frame.BackgroundColor3 = v.Color
			elseif typeof(v.Color) == "ColorSequence" then
				uIGradient.Color = v.Color
			else
				error("Invalid color type passed to slash function")
			end
		end

		if p.current.isSimplified then
			frame.Parent = p.current.reel_playerbar
		else
			frame.Parent = p.current.reel_progress.bar
		end

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
		local endSize = v.EndSize or UDim2.fromScale(7, 4.75)
		local v15 = TweenService:Create(clone, tweenInfo2, {
			Size = UDim2.new(endSize.X.Scale * v2, endSize.X.Offset, endSize.Y.Scale * v3, endSize.Y.Offset),
			ImageTransparency = 1
		})
		v15:Play()
		v15.Completed:Once(function()
			v15:Destroy()
			clone:Destroy()
		end)
	end)
	return v9
end

return ReelFX