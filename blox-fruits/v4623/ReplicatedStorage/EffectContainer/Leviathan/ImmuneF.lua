return function(p)
	local model = p.Model
	local highlight = Instance.new("Highlight", model)
	highlight.Adornee = model
	highlight.OutlineTransparency = 1
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(
		highlight,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true),
		{
			OutlineTransparency = 0,
			FillTransparency = 0.3
		}
	)
	tween:Play()
	tween.Completed:Wait()
	highlight:Destroy()
end