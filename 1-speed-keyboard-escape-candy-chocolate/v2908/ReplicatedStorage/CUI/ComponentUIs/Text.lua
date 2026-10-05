return function()
	local frame = Instance.new("Frame")
	frame.Name = "Text"
	frame.BackgroundTransparency = 1
	frame.BorderMode = Enum.BorderMode.Inset
	frame.Size = UDim2.new(1, 0, 0, 18)
	frame.Visible = false
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(1, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textLabel.Position = UDim2.fromScale(1, 0.5)
	textLabel.Size = UDim2.new(1, -6, 1, -2)
	textLabel.Text = "Exporting"
	textLabel.TextColor3 = Color3.fromRGB(218, 218, 218)
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 10
	textLabel.Parent = frame
	return frame
end