local parent = script.Parent
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true, 0)
TweenService:Create(parent.Frame, tweenInfo, {
	Position = UDim2.new(0, 0, 0, 0)
})

while true do
	parent.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, true)
	task.wait(1)
	parent.Frame:TweenPosition(UDim2.new(0, 0, 0.25, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 1, true)
	task.wait(1)
end