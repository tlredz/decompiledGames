local createVector = vector.create
return function()
	local clone = script.Parent:Clone()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 2)
	game:GetService("TweenService")
	local neon = clone.neon
	local dark = clone.dark
	clone.Size = Vector3.new()
	dark.Transparency = 1
	neon.Transparency = 1
	game.TweenService:Create(
		clone.PointLight,
		TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Range = 60,
			Brightness = 0.25
		}
	):Play()
	game.TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(125, 1, 125)
	}):Play()
	game.TweenService:Create(clone.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0.25
	}):Play()
	game.TweenService:Create(clone.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	script.Parent.diable2:Emit(45)
	script.Parent.diable:Emit(45)
	script.Parent.rock:Emit(35)
	script.Parent.diable.Enabled = true
	script.Parent.diable2.Enabled = true
	task.spawn(function()
		wait(1)
		script.Parent.diable.Enabled = false
		script.Parent.diable2.Enabled = false
		game.TweenService:Create(
			clone.PointLight,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Range = 5
			}
		):Play()
		game.TweenService:Create(clone.dark, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		game.TweenService:Create(clone.neon, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
end