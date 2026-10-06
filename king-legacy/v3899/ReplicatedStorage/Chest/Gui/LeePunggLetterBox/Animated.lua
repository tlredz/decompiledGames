local upper = script.Parent:WaitForChild("Upper")
local lower = script.Parent:WaitForChild("Lower")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local position = upper.Position
local position2 = lower.Position
local tween = TweenService:Create(upper, tweenInfo, {
	Position = UDim2.new(0, 0, -0.8, 0)
})
local tween2 = TweenService:Create(lower, tweenInfo, {
	Position = UDim2.new(0, 0, 0.8, 0)
})
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
return function()
	tween2:Play()
	tween:Play()
	task.wait(3)
	TweenService:Create(upper, tweenInfo, {
		Position = position
	}):Play()
	TweenService:Create(lower, tweenInfo, {
		Position = position2
	}):Play()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
end