local createVector = vector.create
return function()
	local mesh = script.Parent.n.Mesh
	local mesh2 = script.Parent.n2.Mesh
	mesh.Scale = createVector(2.5, 0.25, 0.25)
	mesh2.Scale = createVector(2.8125, 0.375, 0.375)
	mesh2.Offset = createVector(12.5, 0, 0)
	wait()
	game.TweenService:Create(mesh, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(2.625, 0, 0)
	}):Play()
	game.TweenService:Create(mesh2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(2.9375, 0, 0),
		Offset = createVector(18.75, 0, 0)
	}):Play()
end