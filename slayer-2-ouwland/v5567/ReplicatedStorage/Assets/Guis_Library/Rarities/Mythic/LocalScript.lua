game.TweenService:Create(
	script.Parent,
	TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0),
	{
		Rotation = script.Parent.Rotation + 360
	}
):Play()