local createVector = vector.create
return function()
	local parent = script.Parent
	game:GetService("TweenService")
	local neon = script.Parent.neon
	local dark = script.Parent.dark
	script.Parent.Size = Vector3.new()
	dark.Transparency = 1
	neon.Transparency = 1
	game.TweenService:Create(
		parent.PointLight,
		TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Range = 50,
			Brightness = 1
		}
	):Play()
	game.TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(70, 1, 70)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = -0.1
	}):Play()
	game.TweenService:Create(parent.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	parent.Attachment.sm2:Emit(50)
	task.spawn(function()
		wait()
		parent.Specs:Emit(20)
		parent.rock:Emit(5)
		parent.sakura:Emit(20)
	end)
	task.spawn(function()
		wait(0.5)
		game.TweenService:Create(
			parent.PointLight,
			TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Range = 5
			}
		):Play()
		game.TweenService:Create(
			parent.dark,
			TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(
			parent.neon,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end