return function()
	local frame = Instance.new("Frame")
	frame.Name = "Image"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 100)
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "Ctn"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundTransparency = 1
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.Size = UDim2.fromScale(1, 1)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = frame2
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Parent = frame2
	frame2.Parent = frame
	return frame
end