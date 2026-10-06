local createVector = vector.create
return function()
	script.Parent.Mesh.Scale = createVector(2.2, 0.5, 0.5)
	script.Parent.Decal.Transparency = 0.25
	game.TweenService:Create(
		script.Parent.Mesh,
		TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Scale = createVector(3.25, 0.35, 0.35)
		}
	):Play()
	game.TweenService:Create(script.Parent, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = script.Parent.CFrame * CFrame.new(-60, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	task.spawn(function()
		wait()
		game.TweenService:Create(
			script.Parent.Decal,
			TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end