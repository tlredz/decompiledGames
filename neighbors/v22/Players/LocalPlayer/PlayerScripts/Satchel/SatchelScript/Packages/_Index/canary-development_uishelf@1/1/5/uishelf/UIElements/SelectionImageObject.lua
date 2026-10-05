local frame = Instance.new("Frame")
frame.Name = "SelectionImageObject"
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 1
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Size = UDim2.new(1, 0, 0, 44)
local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "UIStroke"
uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uIStroke.Color = Color3.fromRGB(255, 255, 255)
uIStroke.Thickness = 3
local uIGradient = Instance.new("UIGradient")
uIGradient.Name = "GradientChild"
uIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(86, 86, 86))
})
uIGradient.Parent = uIStroke
uIStroke.Parent = frame
local uICorner = Instance.new("UICorner")
uICorner.Name = "UICorner"
uICorner.CornerRadius = UDim.new(1, 0)
uICorner.Parent = frame
return frame