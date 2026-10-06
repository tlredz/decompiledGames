local createVector = vector.create
return function()
	script.Parent.Decal.Transparency = 0
	script.Parent.Mesh.Scale = Vector3.new()
	game.TweenService:Create(
		script.Parent.Mesh,
		TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Scale = createVector(0.557, 0.738, 0.738)
		}
	):Play()
	game.TweenService:Create(script.Parent, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = script.Parent.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	task.spawn(function()
		wait()

		if script.Parent:FindFirstChild("Decal") then
			game.TweenService:Create(
				script.Parent.Decal,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end
	end)
end