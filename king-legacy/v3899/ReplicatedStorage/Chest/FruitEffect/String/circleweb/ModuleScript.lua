local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(p, value)
	task.spawn(function()
		local start = script.Parent.start
		local v = script.Parent["end"]
		local beam = script.Parent.Beam
		local beam2 = script.Parent.Beam2
		start.WorldCFrame = script.Parent.CFrame
		v.WorldCFrame = script.Parent.CFrame
		local curveSize = 55
		beam.Width0 = value or 0.1
		beam.Width1 = value or 0.1
		beam2.Width0 = value or 0.1
		beam2.Width1 = value or 0.1
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
		TweenService:Create(script.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = script.Parent.CFrame * CFrame.Angles(0, 0, 0.6283185307179586)
		}):Play()
		TweenService:Create(start, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = start.CFrame * CFrame.new(0, 0, 40)
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = v.CFrame * CFrame.new(0, 0, -40)
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
		wait(0.45)
		TweenService:Create(color3Value, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = Color3.fromRGB(255, 89, 48)
		}):Play()
		TweenService:Create(beam, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 2
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 2
		}):Play()
		local curveSize2 = 60
		TweenService:Create(beam, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CurveSize0 = curveSize2,
			CurveSize1 = -curveSize2
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CurveSize0 = -curveSize2,
			CurveSize1 = curveSize2
		}):Play()
		TweenService:Create(start, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = start.CFrame * CFrame.new(0, 0, 5)
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = v.CFrame * CFrame.new(0, 0, -5)
		}):Play()
		wait(0.45)
		local step = 12 - p or 12
		PeodizService.ForLoop({
			Step = step
		}, function(_) end)
		TweenService:Create(start, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CFrame = start.CFrame * CFrame.new(0, 0, -45)
		}):Play()
		TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			CFrame = v.CFrame * CFrame.new(0, 0, 45)
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