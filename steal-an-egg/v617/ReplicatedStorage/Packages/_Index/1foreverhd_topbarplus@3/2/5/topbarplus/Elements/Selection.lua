return function(_)
	local frame = Instance.new("Frame")
	frame.Name = "SelectionContainer"
	frame.Visible = false
	local frame2 = Instance.new("Frame")
	frame2.Name = "Selection"
	frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame2.BackgroundTransparency = 1
	frame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "UIStroke"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	uIStroke.Thickness = 3
	uIStroke.Parent = frame2
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "SelectionGradient"
	uIGradient.Parent = uIStroke
	local uICorner = Instance.new("UICorner")
	uICorner:SetAttribute("Collective", "IconCorners")
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame2
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local rotationSpeed = 1
	frame2:GetAttributeChangedSignal("RotationSpeed"):Connect(function()
		rotationSpeed = frame2:GetAttribute("RotationSpeed")
	end)
	RunService.Heartbeat:Connect(function()
		if not GuiService.SelectedObject then
			return
		end

		uIGradient.Rotation = os.clock() * rotationSpeed * 100 % 360
	end)
	return frame
end