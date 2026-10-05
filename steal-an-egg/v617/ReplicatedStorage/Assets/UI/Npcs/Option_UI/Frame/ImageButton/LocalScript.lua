local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local parent = script.Parent.Parent
local uIPadding = parent.Frame.Text_Element.UIPadding
local imageLabel = parent.ImageLabel
local imageColor3 = imageLabel.ImageColor3
local tween = TweenService:Create(uIPadding, tweenInfo, {
	PaddingLeft = UDim.new(0.04, 0)
})
local tween2 = TweenService:Create(uIPadding, tweenInfo, {
	PaddingLeft = UDim.new(0, 0)
})
local tween3 = TweenService:Create(imageLabel, tweenInfo, {
	ImageColor3 = Color3.fromRGB(255, 255, 255)
})
local tween4 = TweenService:Create(imageLabel, tweenInfo, {
	ImageColor3 = imageColor3
})
local hover = SoundService.Hover
script.Parent.MouseEnter:Connect(function()
	hover.PlaybackSpeed = 1 + math.random(-5, 5) / 100
	hover.Playing = true
	hover.TimePosition = 0
	tween:Play()
	tween3:Play()
end)
script.Parent.MouseLeave:Connect(function()
	tween2:Play()
	tween4:Play()
end)