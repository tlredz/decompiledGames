return function()
	local AT1 = script.Parent.AT1
	local AT2 = script.Parent.AT2
	local v = math.random(28, 35)
	AT1.WorldCFrame = script.Parent.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	AT2.WorldCFrame = script.Parent.CFrame * CFrame.new(0, v, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	) * CFrame.new(0, 0, math.random(5, 8))
	script.Parent.beam.Width0 = 30
	script.Parent.beam.CurveSize1 = math.random(15, 20) * (math.random(1, 2) == 1 and 1 or -1)
	script.Parent.beam.CurveSize0 = math.random(15, 20) * (math.random(1, 2) == 1 and 1 or -1)
	game.TweenService:Create(
		script.Parent.beam,
		TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			CurveSize0 = -script.Parent.beam.CurveSize0,
			CurveSize1 = -script.Parent.beam.CurveSize1
		}
	):Play()
	task.spawn(function()
		wait(0.1)
		game.TweenService:Create(AT2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = AT2.CFrame * CFrame.new(0, -v, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		wait(0.1)
		game.TweenService:Create(
			script.Parent.beam,
			TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Width0 = 0
			}
		):Play()
	end)
end