local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Lighting_2 = {}

function Lighting_2.CCFlash(data)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Brightness = data.Brightness or 0
	colorCorrectionEffect.Saturation = data.Saturation or 0
	colorCorrectionEffect.Contrast = data.Contrast or 0
	colorCorrectionEffect.TintColor = data.Color or Color3.fromRGB(255, 255, 255)
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(
		colorCorrectionEffect,
		TweenInfo.new(data.Duration or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Brightness = 0,
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	):Play()
	Debris:AddItem(colorCorrectionEffect, data.Duration or 0.2)
	return colorCorrectionEffect
end

function Lighting_2.PointLight(instance)
	assert(instance.Parent, "Parent Is Required")
	local pointLight = Instance.new("PointLight")
	pointLight.Enabled = true
	pointLight.Color = instance.Color or Color3.fromRGB(105, 195, 255)
	pointLight.Range = instance.InitalRange or 10
	pointLight.Brightness = instance.InitalBrightness or 2
	pointLight.Parent = instance.Parent
	TweenService:Create(
		pointLight,
		TweenInfo.new(instance.Duration or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Brightness = 0,
			Range = instance.EndRange or (instance.InitalRange or 10) * 1.5
		}
	):Play()
	Debris:AddItem(pointLight, instance.Duration or 1)
	return pointLight
end

function Lighting_2.Highlight(data)
	assert(data.Model, "BasePart Or Model Is Required")
	local highlight = Instance.new("Highlight")
	highlight.Adornee = data.Model
	highlight.DepthMode = data.DepthMode or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = data.FillColor or Color3.new(1, 1, 1)
	highlight.OutlineColor = data.OutlineColor or Color3.new(1, 1, 1)
	local v = data.FadeDirection == "In" and "In" or "Out"
	local initalFillTransparency, initalFillTransparency2

	if v == "In" then
		initalFillTransparency = data.InitalFillTransparency or 0
		initalFillTransparency2 = 1
	else
		initalFillTransparency2 = data.InitalFillTransparency or 0
		initalFillTransparency = 1
	end

	highlight.FillTransparency = initalFillTransparency2
	highlight.OutlineTransparency = initalFillTransparency2
	highlight.Parent = data.Model
	TweenService:Create(
		highlight,
		TweenInfo.new(
			data.Duration or 0.5,
			Enum.EasingStyle.Sine,
			v == "In" and Enum.EasingDirection.In or Enum.EasingDirection.Out
		),
		{
			FillTransparency = initalFillTransparency,
			OutlineTransparency = initalFillTransparency
		}
	):Play()
	Debris:AddItem(highlight, data.Duration or 0.5)
	return highlight
end

function Lighting_2.PulseHighlight(data)
	assert(data.Model, "Model Is Required")
	local highlight = Instance.new("Highlight")
	highlight.Adornee = data.Model
	highlight.DepthMode = data.DepthMode or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = data.FillColor or Color3.new(1, 1, 1)
	highlight.OutlineColor = data.OutlineColor or Color3.new(1, 1, 1)
	local pulseDuration = data.PulseDuration or 0.5
	local startTransparency = data.StartTransparency or 0
	local endTransparency = data.EndTransparency or 0
	highlight.FillTransparency = startTransparency
	highlight.OutlineTransparency = startTransparency
	highlight.Parent = data.Model
	local tweenInfo = TweenInfo.new(pulseDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(pulseDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = endTransparency,
		OutlineTransparency = endTransparency
	})
	local tween2 = TweenService:Create(highlight, tweenInfo2, {
		FillTransparency = startTransparency,
		OutlineTransparency = startTransparency
	})
	local count = 0
	local repeatCount = data.RepeatCount or 0
	local DoPulse

	DoPulse = function()
		if not (highlight and highlight.Parent) then
			return
		end

		tween:Play()
		tween.Completed:Wait()

		if not (highlight and highlight.Parent) then
			return
		end

		tween2:Play()
		tween2.Completed:Wait()
		count += 1

		if repeatCount == 0 or count < repeatCount then
			task.spawn(DoPulse)
		else
			Debris:AddItem(highlight, 0.1)
		end
	end

	task.spawn(DoPulse)
	return highlight
end

function Lighting_2.FlashHighlight(data)
	assert(data.Model, "Model Is Required")
	local highlight = Instance.new("Highlight")
	highlight.Adornee = data.Model
	highlight.DepthMode = data.DepthMode or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = data.FillColor or Color3.new(1, 1, 1)
	highlight.OutlineColor = data.OutlineColor or Color3.new(1, 1, 1)
	local startTransparency = data.StartTransparency or 0
	highlight.FillTransparency = startTransparency
	highlight.OutlineTransparency = startTransparency
	highlight.Parent = data.Model
	local flashSpeed = data.FlashSpeed or 0.1
	local flashDuration = data.FlashDuration or 1
	local tweenInfo = TweenInfo.new(flashSpeed / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(flashSpeed / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = startTransparency,
		OutlineTransparency = startTransparency
	})
	local tween2 = TweenService:Create(highlight, tweenInfo2, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	local lastTime = os.clock()
	local DoFlash

	DoFlash = function()
		if not (highlight and highlight.Parent) then
			return
		end

		if flashDuration <= os.clock() - lastTime then
			Debris:AddItem(highlight, 0.1)
			return
		end

		tween:Play()
		tween.Completed:Wait()

		if not (highlight and highlight.Parent) then
			return
		end

		tween2:Play()
		tween2.Completed:Wait()
		task.spawn(DoFlash)
	end

	task.spawn(DoFlash)
	Debris:AddItem(highlight, flashDuration + 0.5)
	return highlight
end

return Lighting_2