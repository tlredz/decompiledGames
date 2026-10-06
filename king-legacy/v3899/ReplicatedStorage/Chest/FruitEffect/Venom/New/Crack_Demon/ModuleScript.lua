local createVector = vector.create
return function()
	local parent = script.Parent
	game:GetService("TweenService")
	local dark = script.Parent.dark
	script.Parent.Size = Vector3.new()
	dark.Transparency = 1
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(60, 1, 60)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0.5
	}):Play()
	local attachment = parent.Attachment
	attachment.Spark:Emit(2)
	attachment.sparkl1:Emit(5)
	attachment.sparkl2:Emit(5)
	attachment.big:Emit(3)
	parent.rock:Emit(20)
	task.spawn(function()
		wait(1)
		game.TweenService:Create(
			parent.dark,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end