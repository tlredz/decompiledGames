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
			Brightness = 1.15
		}
	):Play()
	game.TweenService:Create(parent, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(100, 1, 100)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = -0.1
	}):Play()
	game.TweenService:Create(parent.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	parent.Attachment.Spark:Emit(3)
	parent.Attachment.sm2:Emit(50)
	parent.Attachment.sakura:Emit(25)
	parent.Attachment.sparkl1:Emit(15)
	parent.Attachment.ring:Emit(10)
	parent.Attachment.sparkl2:Emit(15)
	task.spawn(function()
		wait()
		parent.Specs:Emit(25)
		parent.rock:Emit(10)
		parent.sakura:Emit(25)
	end)
	task.spawn(function()
		wait(1)
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