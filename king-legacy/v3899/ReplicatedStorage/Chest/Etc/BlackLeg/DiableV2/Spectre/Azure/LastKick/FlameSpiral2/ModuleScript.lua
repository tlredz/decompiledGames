local createVector = vector.create
return function()
	local mesh = script.Parent.n.Mesh
	local mesh2 = script.Parent.n2.Mesh
	mesh.Scale = createVector(0.35, 0.1, 0.1)
	mesh2.Scale = createVector(0.55, 0.2, 0.2)
	mesh2.Offset = createVector(0, 0, 0)
	task.wait()
	game.TweenService:Create(mesh, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(0.65, 0, 0)
	}):Play()
	game.TweenService:Create(mesh2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(0.85, 0, 0),
		Offset = createVector(7.5, 0, 0)
	}):Play()
end