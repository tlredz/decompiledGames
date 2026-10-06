local createVector = vector.create
return function()
	local parent = script.Parent
	parent.Size = Vector3.new()
	parent.CFrame = CFrame.new(parent.CFrame.p)
	parent.Flames:Emit(50)
	parent.Attachment.Ring:Emit(1)
	parent.Attachment.Spark:Emit(2)
	parent.Attachment.Ball:Emit(1)
	parent.Transparency = -2
	game.TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(4.988, 4.419, 44.075)
	}):Play()
	task.wait()
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = parent.CFrame * CFrame.new(0, 8, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	wait(0.35)
	game.TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		CFrame = CFrame.new(parent.CFrame.p - createVector(0, 22.5, 0)) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	wait(0.3)
	task.spawn(function()
		parent.Flames:Emit(50)
		game.TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
end