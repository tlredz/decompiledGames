return function()
	local frame = Instance.new("Frame")
	frame.Name = "Separator"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, 8)
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "Line"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.Size = UDim2.new(1, 0, 0, 1)
	frame2.ZIndex = 10
	frame2.Parent = frame
	return frame
end