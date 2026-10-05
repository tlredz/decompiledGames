return function()
	local frame = Instance.new("Frame")
	frame.Name = "Viewport"
	frame.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
	frame.BorderColor3 = Color3.fromRGB(34, 34, 34)
	frame.BorderMode = Enum.BorderMode.Inset
	frame.Size = UDim2.new(1, 0, 0, 100)
	frame.Visible = false
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.BackgroundColor3 = Color3.new()
	viewportFrame.BackgroundTransparency = 0.75
	viewportFrame.BorderColor3 = Color3.new()
	viewportFrame.BorderSizePixel = 0
	viewportFrame.Size = UDim2.fromScale(1, 1)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = viewportFrame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Warning"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://11745872910"
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(0.8, 0.8)
	imageLabel.Visible = false
	imageLabel.Parent = viewportFrame
	viewportFrame.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = frame
	return frame
end