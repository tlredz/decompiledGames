game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local value = script.Parent.Remote.Value
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
TweenService:Create(script.Parent.TextBox, tweenInfo, {
	Position = UDim2.new(0.5, 0, 0.5, 0),
	BackgroundTransparency = 0.5,
	TextTransparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.UIStroke, tweenInfo, {
	Transparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.TextButton, tweenInfo, {
	BackgroundTransparency = 0.5,
	TextTransparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.TextButton.UIStroke, tweenInfo, {
	Transparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.ReportButton, tweenInfo, {
	BackgroundTransparency = 0.5,
	TextTransparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.ReportButton.UIStroke, tweenInfo, {
	Transparency = 0
}):Play()
TweenService:Create(script.Parent.TextBox.Warnng, tweenInfo, {
	TextTransparency = 0
}):Play()
script.Parent.TextBox.FocusLost:Connect(function(p)
	if not p then
		return
	end

	value:FireServer(script.Parent.Promptobj.Value, script.Parent.TextBox.Text)
	script.Parent:Destroy()
end)
script.Parent.TextBox.TextButton.MouseButton1Down:Connect(function()
	value:FireServer(script.Parent.Promptobj.Value, script.Parent.TextBox.Text)
	script.Parent:Destroy()
end)
script.Parent.TextBox.ReportButton.MouseButton1Down:Connect(function()
	value:FireServer(script.Parent.Promptobj.Value, "Report")
	script.Parent:Destroy()
end)