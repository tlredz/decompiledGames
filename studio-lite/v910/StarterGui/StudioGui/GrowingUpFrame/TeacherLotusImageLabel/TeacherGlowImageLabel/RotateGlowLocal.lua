local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0)
local tween = TweenService:Create(script.Parent, tweenInfo, {
	Rotation = 180
})
tween:Play()
local parent = script.Parent.Parent.Parent
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible and tween.PlaybackState ~= Enum.PlaybackState.Playing then
		tween:Play()
	elseif parent.Visible == false and tween.PlaybackState == Enum.PlaybackState.Playing then
		tween:Pause()
	end
end)