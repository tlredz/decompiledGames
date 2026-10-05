local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false)
TweenService:Create(script.Parent, tweenInfo, {
	Position = UDim2.fromScale(1.843, 1.859)
}):Play()