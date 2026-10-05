return function()
	local frame = Instance.new("Frame")
	frame.Name = "Window"
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(400, 200)
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "UIScale"
	uIScale.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Topbar"
	frame2.AnchorPoint = Vector2.new(0, 1)
	frame2.BackgroundColor3 = Color3.fromRGB(41, 45, 54)
	frame2.BorderColor3 = Color3.new()
	frame2.BorderSizePixel = 0
	frame2.Size = UDim2.new(1, 0, 0, 24)
	frame2.ZIndex = 100
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(221, 221, 221)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(253, 253, 253)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(252, 252, 252)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 218, 218))
	})
	uIGradient.Rotation = 90
	uIGradient.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.AnchorPoint = Vector2.new(1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel.Position = UDim2.fromScale(1, 0)
	textLabel.Size = UDim2.new(1, -12, 1, 0)
	textLabel.RichText = true
	textLabel.Text = "<font color=\"#FFFFFF\">◙</font> Staff panel"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextSize = 20
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 150
	textLabel.Parent = frame2
	local textButton = Instance.new("TextButton")
	textButton.Name = "Interactibility"
	textButton.BackgroundTransparency = 1
	textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.Text = ""
	textButton.TextColor3 = Color3.new()
	textButton.TextSize = 14
	textButton.ZIndex = 500
	textButton.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "WhiteOff"
	frame3.BackgroundTransparency = 1
	frame3.Size = UDim2.fromScale(1, 1)
	frame3.ZIndex = 5000
	frame3.Parent = frame2
	local folder = Instance.new("Folder")
	folder.Name = "Buttons"
	local frame4 = Instance.new("Frame")
	frame4.Name = "Minimize"
	frame4.AnchorPoint = Vector2.new(1, 0)
	frame4.BackgroundTransparency = 1
	frame4.Position = UDim2.fromScale(1, 0)
	frame4.Size = UDim2.fromScale(1, 1)
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = frame4
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.AnchorPoint = Vector2.new(1, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.FontFace = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel2.Position = UDim2.fromScale(1, 0)
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.Text = "-"
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextSize = 20
	textLabel2.TextWrapped = true
	textLabel2.ZIndex = 120
	textLabel2.Parent = frame4
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "Interactibility"
	textButton2.BackgroundTransparency = 1
	textButton2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton2.Size = UDim2.fromScale(1, 1)
	textButton2.Text = ""
	textButton2.TextColor3 = Color3.new()
	textButton2.TextSize = 14
	textButton2.ZIndex = 1000
	textButton2.Parent = frame4
	frame4.Parent = folder
	local frame5 = Instance.new("Frame")
	frame5.Name = "Close"
	frame5.AnchorPoint = Vector2.new(1, 0)
	frame5.BackgroundTransparency = 1
	frame5.LayoutOrder = 10
	frame5.Position = UDim2.fromScale(1, 0)
	frame5.Size = UDim2.fromScale(1, 1)
	local uIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint_2.Parent = frame5
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.AnchorPoint = Vector2.new(1, 0)
	textLabel3.BackgroundTransparency = 1
	textLabel3.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	textLabel3.Position = UDim2.fromScale(1, 0)
	textLabel3.Size = UDim2.fromScale(1, 1)
	textLabel3.Text = "X"
	textLabel3.TextColor3 = Color3.new(1, 1, 1)
	textLabel3.TextSize = 20
	textLabel3.TextWrapped = true
	textLabel3.ZIndex = 120
	textLabel3.Parent = frame5
	local textButton3 = Instance.new("TextButton")
	textButton3.Name = "Interactibility"
	textButton3.BackgroundTransparency = 1
	textButton3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton3.Size = UDim2.fromScale(1, 1)
	textButton3.Text = ""
	textButton3.TextColor3 = Color3.new()
	textButton3.TextSize = 14
	textButton3.ZIndex = 1000
	textButton3.Parent = frame5
	frame5.Parent = folder
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = folder
	folder.Parent = frame2
	frame2.Parent = frame
	local frame6 = Instance.new("Frame")
	frame6.Name = "Content"
	frame6.AnchorPoint = Vector2.new(0.5, 0.5)
	frame6.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
	frame6.BorderColor3 = Color3.new()
	frame6.BorderSizePixel = 0
	frame6.Position = UDim2.fromScale(0.5, 0.5)
	frame6.Size = UDim2.fromScale(1, 1)
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.50692, Color3.fromRGB(253, 253, 253)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 206, 206))
	})
	uIGradient2.Rotation = 90
	uIGradient2.Parent = frame6
	frame6.Parent = frame
	local textButton4 = Instance.new("TextButton")
	textButton4.Name = "Interactibility"
	textButton4.BackgroundTransparency = 1
	textButton4.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton4.Size = UDim2.fromScale(1, 1)
	textButton4.Text = ""
	textButton4.TextColor3 = Color3.new()
	textButton4.TextSize = 14
	textButton4.ZIndex = -1
	textButton4.Parent = frame
	return frame
end