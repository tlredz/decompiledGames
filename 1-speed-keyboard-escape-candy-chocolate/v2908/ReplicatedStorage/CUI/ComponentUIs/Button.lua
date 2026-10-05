return function()
	local frame = Instance.new("Frame")
	frame.Name = "Button"
	frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
	frame.BorderColor3 = Color3.fromRGB(34, 34, 34)
	frame.BorderMode = Enum.BorderMode.Inset
	frame.LayoutOrder = 2
	frame.Size = UDim2.new(1, 0, 0, 28)
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "BG"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	frame2.BorderColor3 = Color3.new()
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.Size = UDim2.fromScale(1, 1)
	frame2.ZIndex = 10
	frame2.Parent = frame
	local textButton = Instance.new("TextButton")
	textButton.Name = "Btn"
	textButton.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	textButton.BorderColor3 = Color3.fromRGB(34, 34, 34)
	textButton.BorderMode = Enum.BorderMode.Inset
	textButton.BorderSizePixel = 0
	textButton.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textButton.Position = UDim2.fromScale(0.5, 0.5)
	textButton.Size = UDim2.new(1, -2, 1, -2)
	textButton.Text = "Export to Attributes"
	textButton.TextColor3 = Color3.fromRGB(229, 229, 229)
	textButton.TextSize = 14
	textButton.ZIndex = 30
	textButton.Parent = frame
	return frame
end