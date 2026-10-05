return function()
	local frame = Instance.new("Frame")
	frame.Name = "Title"
	frame.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
	frame.BorderColor3 = Color3.fromRGB(34, 34, 34)
	frame.BorderMode = Enum.BorderMode.Inset
	frame.Size = UDim2.new(1, 0, 0, 24)
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(1, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel.Position = UDim2.fromScale(1, 0.5)
	textLabel.Size = UDim2.new(1, -6, 1, -2)
	textLabel.Text = "•   Exporting"
	textLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
	textLabel.TextSize = 14
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 10
	textLabel.Parent = frame
	return frame
end