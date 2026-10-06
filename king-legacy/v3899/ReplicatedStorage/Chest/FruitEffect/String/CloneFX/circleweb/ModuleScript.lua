local TweenService = game:GetService("TweenService")
return function(p, value)
	task.spawn(function()
		local start = script.Parent.start
		local v = script.Parent["end"]
		local beam = script.Parent.Beam
		local beam2 = script.Parent.Beam2
		start.WorldCFrame = script.Parent.CFrame
		v.WorldCFrame = script.Parent.CFrame
		local curveSize = 3 + math.sin((math.rad(p / 15 * 179)))
		beam.Width0 = value or 0.05
		beam.Width1 = value or 0.05
		beam2.Width0 = value or 0.05
		beam2.Width1 = value or 0.05
		beam.CurveSize0 = curveSize * 1.5
		beam.CurveSize1 = curveSize * -1.5
		beam2.CurveSize0 = curveSize * -1.5
		beam2.CurveSize1 = curveSize * 1.5
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		beam2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		local color3Value = Instance.new("Color3Value")
		color3Value.Value = Color3.fromRGB(255, 255, 255)
		color3Value.Changed:Connect(function()
			beam.Color = ColorSequence.new(color3Value.Value)
			beam2.Color = ColorSequence.new(color3Value.Value)
		end)
		local v3 = math.random(1, 2) == 1 and -0.6283185307179586 or 0.6283185307179586
		script.Parent.CFrame = script.Parent.CFrame * CFrame.Angles(0, 0, -v3)
		TweenService:Create(script.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = script.Parent.CFrame * CFrame.Angles(0, 0, v3)
		}):Play()
		TweenService:Create(start, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = start.CFrame * CFrame.new(0, 0, 2)
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = v.CFrame * CFrame.new(0, 0, -2)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CurveSize0 = curveSize * 0.5,
			CurveSize1 = -curveSize * 0.5
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CurveSize0 = -curveSize * 0.5,
			CurveSize1 = curveSize * 0.5
		}):Play()
		wait(0.15)
		TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CurveSize0 = curveSize,
			CurveSize1 = -curveSize
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CurveSize0 = -curveSize,
			CurveSize1 = curveSize
		}):Play()
		curveSize += 0.5

		for _ = 1, 12 - p do
			task.wait()
		end

		wait(0.15)
		TweenService:Create(start, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CFrame = start.CFrame * CFrame.new(0, 0, -2)
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CFrame = v.CFrame * CFrame.new(0, 0, 2)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CurveSize0 = 0,
			CurveSize1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CurveSize0 = 0,
			CurveSize1 = 0
		}):Play()
	end)
end