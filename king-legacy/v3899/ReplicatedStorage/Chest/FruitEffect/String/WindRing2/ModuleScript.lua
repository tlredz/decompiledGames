local createVector = vector.create
return function()
	script.Parent.Decal.Transparency = 0.25
	script.Parent.Mesh.Scale = createVector(0.2, 0.2952, 0.2952)
	game.TweenService:Create(
		script.Parent.Mesh,
		TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Scale = createVector(0.5, 0.738, 0.738)
		}
	):Play()
	game.TweenService:Create(script.Parent, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = script.Parent.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	task.spawn(function()
		wait()
		game.TweenService:Create(
			script.Parent.Decal,
			TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end