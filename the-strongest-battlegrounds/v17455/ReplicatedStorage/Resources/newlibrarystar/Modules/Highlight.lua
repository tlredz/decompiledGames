local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Highlight = {}

function Highlight.tween(p, color: Color3?, color2: Color3?, value: number?, p2, p3: string?, value2: number?)
	local v = value or 1
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 0
	local v2, v3

	if p3 == "Out" then
		v2 = 1
		v3 = 0
	else
		v2 = value2 or 0
		v3 = 1
	end

	highlight.FillTransparency = v2
	highlight.OutlineTransparency = v2
	highlight.Parent = p
	TweenService:Create(highlight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FillTransparency = v3,
		OutlineTransparency = v3
	}):Play()
	Debris:AddItem(highlight, v)
	return highlight
end

function Highlight.pulse(p, color: Color3?, color2: Color3?, value: number?, p2, value2: number?, value3: number?, value4: number?)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	local v = value or 0.5
	local v2 = value3 or 0
	local v3 = value4 or 1
	highlight.FillTransparency = v2
	highlight.OutlineTransparency = v2
	highlight.Parent = p
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local count = 0
	local v4 = value2 or 0
	local pulseOnce

	pulseOnce = function()
		TweenService:Create(highlight, tweenInfo, {
			FillTransparency = v3,
			OutlineTransparency = v3
		}):Play()
		task.wait(v)
		TweenService:Create(highlight, tweenInfo2, {
			FillTransparency = v2,
			OutlineTransparency = v2
		}):Play()
		task.wait(v)
		count += 1

		if v4 == 0 or count < v4 then
			task.spawn(pulseOnce)
		else
			Debris:AddItem(highlight, 0.1)
		end
	end

	task.spawn(pulseOnce)
	return highlight
end

function Highlight.flash(p, color: Color3?, color2: Color3?, value: number?, value2: number?, p2, value3: number?)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	highlight.FillTransparency = value3 or 0
	highlight.OutlineTransparency = value3 or 0
	highlight.Parent = p
	local v = (value2 or 0.1) / 2
	local v2 = value or 1
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local lastTime = os.clock()
	local loop

	loop = function()
		if v2 <= os.clock() - lastTime then
			Debris:AddItem(highlight, 0.1)
			return
		end

		TweenService:Create(highlight, tweenInfo, {
			FillTransparency = highlight.FillTransparency,
			OutlineTransparency = highlight.OutlineTransparency
		}):Play()
		task.wait(v)
		TweenService:Create(highlight, tweenInfo2, {
			FillTransparency = 1,
			OutlineTransparency = 1
		}):Play()
		task.wait(v)
		task.spawn(loop)
	end

	task.spawn(loop)
	Debris:AddItem(highlight, v2 + 0.5)
	return highlight
end

return Highlight