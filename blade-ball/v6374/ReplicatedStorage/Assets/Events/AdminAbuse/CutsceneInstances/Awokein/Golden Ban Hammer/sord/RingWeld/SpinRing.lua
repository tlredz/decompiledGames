local C0 = script.Parent.C0
local TweenService = game:GetService("TweenService")
local tween = TweenService:Create(
	script.Parent,
	TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
	{
		C0 = C0 * CFrame.fromOrientation(0, 0, -3.141592653589793)
	}
)
tween.Parent = script.Parent
tween:Play()