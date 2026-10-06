local createVector = vector.create
return function()
	local mesh = script.Parent.n.Mesh
	local mesh2 = script.Parent.n2.Mesh
	mesh.Scale = createVector(1, 0.2, 0.2)
	mesh2.Scale = createVector(1.25, 0.3, 0.3)
	mesh2.Offset = createVector(5, 0, 0)
	wait()
	game.TweenService:Create(mesh, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(1.1, 0, 0)
	}):Play()
	game.TweenService:Create(mesh2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(1.35, 0, 0),
		Offset = createVector(10, 0, 0)
	}):Play()
end