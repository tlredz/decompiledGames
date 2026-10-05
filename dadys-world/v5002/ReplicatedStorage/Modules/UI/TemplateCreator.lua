local TemplateCreator = {}

function TemplateCreator.createToonTemplate(parent)
	local template = parent:FindFirstChild("Template") or parent:FindFirstChild("ToonTemplate")

	if template then
		template.Visible = false
		return template
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "Template"
	textButton.Size = UDim2.new(0.173512578, 0, 0.15558739, 0)
	textButton.BackgroundColor3 = Color3.new(1, 1, 1)
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.Visible = false
	textButton.Text = ""
	textButton.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "CharacterName"
	textLabel.Size = UDim2.new(1, 0, 0.3, 0)
	textLabel.Position = UDim2.new(0, 0, 0.7, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSans
	textLabel.Parent = textButton
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "CharacterImage"
	imageLabel.Size = UDim2.new(0.8, 0, 0.6, 0)
	imageLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = textButton
	return textButton
end

function TemplateCreator.createTeamTemplate(parent)
	local template = parent:FindFirstChild("Template") or parent:FindFirstChild("TeamTemplate")

	if template then
		template.Visible = false
		return template
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "Template"
	textButton.Size = UDim2.new(1, 0, 0.125, 0)
	textButton.Text = " "
	textButton.Font = Enum.Font.SourceSans
	textButton.BackgroundTransparency = 1
	textButton.Visible = false
	textButton.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "PlayerName"
	textLabel.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = textButton
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "CharacterName"
	textLabel2.Size = UDim2.new(0.5, 0, 1, 0)
	textLabel2.Position = UDim2.new(0.5, 0, 0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextScaled = true
	textLabel2.Font = Enum.Font.SourceSans
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = textButton
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "CharacterImage"
	imageLabel.Size = UDim2.new(0.2, 0, 0.8, 0)
	imageLabel.Position = UDim2.new(0.8, 0, 0.1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = textButton
	return textButton
end

function TemplateCreator.createTrinketTemplate(parent)
	local template = parent:FindFirstChild("Template") or parent:FindFirstChild("TrinketTemplate")

	if template then
		template.Visible = false
		return template
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "Template"
	textButton.Size = UDim2.new(0.22, 0, 0.15, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 2
	textButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
	textButton.Visible = false
	textButton.Text = ""
	textButton.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "CharacterName"
	textLabel.Size = UDim2.new(1, 0, 0.3, 0)
	textLabel.Position = UDim2.new(0, 0, 0.7, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSans
	textLabel.Parent = textButton
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "CharacterImage"
	imageLabel.Size = UDim2.new(0.8, 0, 0.6, 0)
	imageLabel.Position = UDim2.new(0.1, 0, 0.1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = textButton
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Checkmark"
	imageLabel2.Size = UDim2.new(0.3, 0, 0.3, 0)
	imageLabel2.Position = UDim2.new(0.7, 0, 0, 0)
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Visible = false
	imageLabel2.Parent = textButton
	return textButton
end

return TemplateCreator