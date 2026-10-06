local createVector = vector.create
return function(p, p2, color, color2)
	local clone = script.SMD:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = p * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	clone.Mesh.Scale = Vector3.new()
	clone.Decal.Color3 = color
	game.TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(1.536, 1.536, 1.536)
	}):Play()

	if math.random(1, 2) == 1 then
		clone.Decal.Color3 = color2
	end

	_G.PU:Dust(clone, 1.5)
	task.spawn(function()
		local ModuleScript2 = require(clone.ModuleScript2)
		ModuleScript2()
	end)
	game.TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(p2.p) * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()
end