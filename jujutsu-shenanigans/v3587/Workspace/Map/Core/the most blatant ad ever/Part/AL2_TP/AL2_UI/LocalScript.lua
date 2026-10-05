local WAIT_INTERVAL = 0.4
local TweenService = game:GetService("TweenService")
TweenService:Create(script.Parent:WaitForChild("Frame"), TweenInfo.new(1, Enum.EasingStyle.Linear), {
	BackgroundTransparency = 0
}):Play()
task.wait(1)
script.Parent:WaitForChild("Sound"):Play()
TweenService:Create(script.Parent.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
	ImageTransparency = 0
}):Play()
TweenService:Create(script.Parent.Area, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {
	TextTransparency = 0
}):Play()
task.wait(WAIT_INTERVAL)
script.Parent.Star.Visible = true
script.Parent.Area2.Visible = true
script.Parent.Stars.Visible = true

while true do
	TweenService:Create(script.Parent.Star, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0, 0, 0.1, 0)
	}):Play()
	task.wait(WAIT_INTERVAL)
	TweenService:Create(script.Parent.Star, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		Size = UDim2.new(0.1, 0, 0.1, 0)
	}):Play()
	task.wait(WAIT_INTERVAL)
end