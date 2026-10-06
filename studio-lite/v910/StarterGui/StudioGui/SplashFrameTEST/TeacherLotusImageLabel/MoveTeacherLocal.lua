local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)
local tween = TweenService:Create(script.Parent, tweenInfo, {
	Position = UDim2.new(
		script.Parent.Position.X.Scale,
		script.Parent.Position.X.Offset + 6,
		script.Parent.Position.Y.Scale,
		script.Parent.Position.Y.Offset
	)
})
tween:Play()
local parent = script.Parent.Parent
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible and tween.PlaybackState ~= Enum.PlaybackState.Playing then
		tween:Play()
	elseif parent.Visible == false and tween.PlaybackState == Enum.PlaybackState.Playing then
		tween:Pause()
	end
end)