local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
require("./Types")
local module = require("../SettingsController")
local ReelFX = {}
ReelFX.__index = ReelFX

function ReelFX.Shake(p, instance, p2, p3, p4, p5, value)
	if not instance:GetAttribute("RootPosition") then
		instance:SetAttribute("RootPosition", instance.Position)
		local _ = instance.Position
	end

	for _ = 0, p3, p4 do
		if p.current.ready and not p.current.active then
			return
		end

		instance.Position = instance:GetAttribute("RootPosition"):Lerp(
			instance:GetAttribute("RootPosition") + UDim2.new(
				Random.new():NextNumber(-0.05, 0.05),
				0,
				Random.new():NextNumber(-0.08, 0.08),
				0
			),
			p2 * module:GetSettingValue("minigameShake")
		)

		if p5 then
			instance.Rotation = math.lerp(
				0,
				Random.new():NextNumber(-8, 8),
				p2 * module:GetSettingValue("minigameShake")
			)
		end

		p2 *= value or 0.9
		p.current:WaitRender(p4)
	end

	instance.Position = instance:GetAttribute("RootPosition")
	instance.Rotation = p5 and 0 or instance.Rotation
end

function ReelFX.SpawnShake(p, ...)
	return task.spawn(p.Shake, p, ...)
end

local function resizeSlash(udim: UDim2, p: number, p2: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset, udim.Y.Scale * p2, udim.Y.Offset)
end

function ReelFX.Slash(p, options)
	local v = options or {}
	local v2

	if typeof(v.Sound) == "table" then
		v2 = v.Sound
	else
		v2 = { v.Sound or ReplicatedStorage.resources.sounds.sfx.fishing.slashes.stabbystab }
	end

	for _, soundId in ipairs(v2) do
		local v4

		if typeof(soundId) == "string" then
			v4 = Instance.new("Sound")
			v4.SoundId = soundId
		else
			v4 = soundId:Clone()
		end

		if typeof(v.SoundPitch) == "number" then
			v4.PlaybackSpeed = v.SoundPitch
		else
			local soundPitch = v.SoundPitch or NumberRange.new(0.95, 1.1)
			v4.PlaybackSpeed = Random.new():NextNumber(soundPitch.Min, soundPitch.Max)
		end

		v4.Parent = p.current.reel
		v4:Play()
		p.current.trove:Add(v4)

		if v4.IsPlaying then
			v4.Ended:Once(function()
				p.current.trove:Remove(v4)
			end)
		else
			p.current.trove:Remove(v4)
		end
	end

	local clone

	if typeof(v.Icon) == "table" then
		clone = v.Icon[math.random(1, #v.Icon)]:Clone()
	else
		clone = (v.Icon or ReplicatedStorage.resources.replicated.fishing.slashes["Default Slash"]):Clone()
	end

	clone.LayoutOrder = 1000

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

	clone.Parent = p.current.reel_bar.fish
	local time = v.Time or 0.4
	local renderTweens = p.current.renderTweens
	local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local fullSize = v.FullSize or UDim2.fromScale(10.188, 4.5)
	local v5 = renderTweens:CreateAndPlay(clone, tweenInfo, {
		Size = UDim2.new(fullSize.X.Scale * 1, fullSize.X.Offset, fullSize.Y.Scale * 1, fullSize.Y.Offset)
	})
	task.defer(function()
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BorderSizePixel = 0
		frame.ZIndex = p.current.reel_progress.bar.ZIndex + 100
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 45
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

		frame.Parent = p.current.reel_progress.bar
		local v6 = p.current.renderTweens:Create(
			uIGradient,
			TweenInfo.new(2, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
			{
				Offset = Vector2.new(1, 0)
			}
		)
		v6:Play()
		v6.Completed:Wait()
		v6:Destroy()
		frame:Destroy()
	end)
	p.current:DelayRender(time, function()
		local renderTweens2 = p.current.renderTweens
		local tweenInfo2 = TweenInfo.new(time / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local endSize = v.EndSize or UDim2.fromScale(7, 4.75)
		local v8 = renderTweens2:Create(clone, tweenInfo2, {
			Size = UDim2.new(endSize.X.Scale * 1, endSize.X.Offset, endSize.Y.Scale * 1, endSize.Y.Offset),
			ImageTransparency = 1
		})
		v8:Play()
		v8.Completed:Once(function()
			clone:Destroy()
		end)
	end)
	return v5
end

return ReelFX