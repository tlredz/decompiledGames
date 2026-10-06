return function()
	local start = script.Parent.start
	local attachment = script.Parent["end"]
	local beam = script.Parent.Beam
	start.WorldCFrame = script.Parent.CFrame
	attachment.CFrame = start.CFrame
	beam.Attachment0 = start
	beam.Attachment1 = attachment
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	beam.CurveSize0 = -50
	beam.CurveSize1 = -32.5
	game.TweenService:Create(attachment, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		WorldCFrame = script.Parent.CFrame * CFrame.new(0, 0, -150)
	}):Play()
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true), {
		CurveSize0 = 25,
		CurveSize1 = 16.25
	}):Play()
	wait(0.2)
	game.TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		CurveSize0 = 0,
		CurveSize1 = 0
	}):Play()
	game.TweenService:Create(beam, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Width0 = 0,
		Width1 = 0
	}):Play()
end