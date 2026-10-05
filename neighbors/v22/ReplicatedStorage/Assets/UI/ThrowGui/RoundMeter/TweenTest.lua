local v = game.TweenService:Create(
	script.Parent.Progress,
	TweenInfo.new(3.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 1e999),
	{
		Value = 1
	}
)
v.Parent = script.Parent.Progress
v:Play()