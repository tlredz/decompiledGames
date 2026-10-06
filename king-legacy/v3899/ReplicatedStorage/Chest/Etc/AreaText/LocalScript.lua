local parent = script.Parent
local info = parent.Info
local place = parent.Place
local line = parent.Line
local TweenService = game:GetService("TweenService")
local uDim = UDim2.new(0.5, 0, 1, 0)
local uDim2 = UDim2.new(0.5, 0, -1, 0)
local uDim3 = UDim2.new(0, 0, 0.015, 0)
local sine = Enum.EasingStyle.Sine
place.TextLabel.Position = uDim
info.TextLabel.Position = uDim2
line.Size = uDim3
task.spawn(function()
	TweenService:Create(line, TweenInfo.new(0.5, sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.8, 0, 0.015, 0)
	}):Play()
	task.wait(0.5)
	TweenService:Create(info.TextLabel, TweenInfo.new(0.5, sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 0)
	}):Play()
	TweenService:Create(place.TextLabel, TweenInfo.new(0.5, sine, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 0)
	}):Play()
	task.wait(1.25)
	TweenService:Create(info.TextLabel, TweenInfo.new(0.5, sine, Enum.EasingDirection.In), {
		Position = uDim2
	}):Play()
	TweenService:Create(place.TextLabel, TweenInfo.new(0.5, sine, Enum.EasingDirection.In), {
		Position = uDim
	}):Play()
	task.wait(0.5)
	TweenService:Create(line, TweenInfo.new(0.5, sine, Enum.EasingDirection.In), {
		Size = uDim3
	}):Play()
end)