local createVector = vector.create
return function()
	script.Parent.Decal.Transparency = 0.25
	script.Parent.Mesh.Scale = Vector3.new()
	game.TweenService:Create(
		script.Parent.Mesh,
		TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Scale = createVector(0.75, 0.45000002, 0.45000002)
		}
	):Play()
	game.TweenService:Create(script.Parent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = script.Parent.CFrame * CFrame.new(25, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	task.spawn(function()
		wait()

		if script.Parent:FindFirstChild("Decal") then
			game.TweenService:Create(
				script.Parent.Decal,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end
	end)
end