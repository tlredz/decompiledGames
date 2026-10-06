return function()
	local start = script.Parent.start
	local attachment = script.Parent["end"]
	local beam = script.Parent.Beam
	start.CFrame = CFrame.new() * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	attachment.CFrame = CFrame.new() * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	beam.Attachment0 = start
	beam.Attachment1 = attachment
	beam.Width0 = 0.1
	beam.Width1 = 0.1
	beam.CurveSize0 = -10 * math.random(-2, 2)
	beam.CurveSize1 = -10 * math.random(-2, 2)
	game.TweenService:Create(attachment, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(0, -150, 0)
	}):Play()
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CurveSize0 = math.random(-10, 10),
		CurveSize1 = math.random(-10, 10)
	}):Play()
	wait(0.15)
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CurveSize0 = -beam.CurveSize0,
		CurveSize1 = -beam.CurveSize1
	}):Play()
	wait(0.15)
	game.TweenService:Create(beam, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CurveSize0 = math.random(-10, 10) * 0.01,
		CurveSize1 = math.random(-10, 10) * 0.01
	}):Play()
	wait(0.25)
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Width0 = 0,
		Width1 = 0
	}):Play()
end