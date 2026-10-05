local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local HighlightEmit = {}

function HighlightEmit.tweenHighlight(p, color: Color3?, color2: Color3?, value: number?, p2, p3: string?, value2: number?)
	local v = value or 1
	local highlight = Instance.new("Highlight")
	task.delay(v, function()
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end)
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
	return highlight
end

function HighlightEmit.pulseHighlight(p, color: Color3?, color2: Color3?, value: number?, p2, value2: number?, value3: number?, value4: number?)
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
	task.delay(15, function()
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end)
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = v3,
		OutlineTransparency = v3
	})
	local tween2 = TweenService:Create(highlight, tweenInfo2, {
		FillTransparency = v2,
		OutlineTransparency = v2
	})
	local count = 0
	local v4 = value2 or 0
	local doPulse

	doPulse = function()
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

		if v4 == 0 or count < v4 then
			task.spawn(doPulse)
		else
			Debris:AddItem(highlight, 0.1)
		end
	end

	task.spawn(doPulse)
	return highlight
end

function HighlightEmit.flashHighlight(p, color: Color3?, color2: Color3?, value: number?, value2: number?, p2, p3: number?)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	highlight.FillTransparency = p3
	highlight.OutlineTransparency = p3
	highlight.Parent = p
	local v = value2 or 0.1
	local v2 = value or 1
	task.delay(v2 + 0.5, function()
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
	end)
	local tweenInfo = TweenInfo.new(v / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(v / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(highlight, tweenInfo, {
		FillTransparency = p3,
		OutlineTransparency = p3
	})
	local tween2 = TweenService:Create(highlight, tweenInfo2, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	local lastTime = os.clock()
	local doFlash

	doFlash = function()
		if not (highlight and highlight.Parent) then
			return
		end

		if v2 <= os.clock() - lastTime then
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
		task.spawn(doFlash)
	end

	task.spawn(doFlash)
	return highlight
end

return HighlightEmit