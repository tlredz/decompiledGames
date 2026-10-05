local TweenService = game:GetService("TweenService")
return function(data)
	local root = data.Root
	local cFrame = data.CFrame
	local duration = data.Duration
	local tweenInfo = TweenInfo.new(duration)

	if data.Linear then
		tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	end

	TweenService:Create(root, tweenInfo, {
		CFrame = cFrame
	}):Play()
end