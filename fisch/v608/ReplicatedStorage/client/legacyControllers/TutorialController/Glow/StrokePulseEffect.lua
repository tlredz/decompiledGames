local TweenService = game:GetService("TweenService")
local parent = script.Parent
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
local tween = TweenService:Create(parent, tweenInfo, {
	Transparency = 0.5
})
local tween2 = TweenService:Create(parent, tweenInfo, {
	Transparency = 0
})

while parent.Parent do
	task.wait()
	tween:Play()
	tween.Completed:Wait()
	tween2:Play()
	tween2.Completed:Wait()
end