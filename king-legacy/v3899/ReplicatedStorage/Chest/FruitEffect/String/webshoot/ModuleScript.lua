return function(attachment, attachment2)
	local beam = script.Parent.Beam
	local attachment3 = script.Parent["end"]
	attachment.CFrame = CFrame.new() * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	attachment3.CFrame = CFrame.new() * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment3
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	beam.CurveSize0 = -10 * math.random(-2, 2)
	beam.CurveSize1 = -10 * math.random(-2, 2)
	game.TweenService:Create(attachment3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		WorldCFrame = attachment2.WorldCFrame
	}):Play()
	task.spawn(function()
		wait(0.2)
		beam.Attachment1 = attachment2
	end)
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
end