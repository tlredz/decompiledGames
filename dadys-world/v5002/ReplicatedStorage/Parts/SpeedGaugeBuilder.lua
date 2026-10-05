local createVector = vector.create
return {
	createSpeedGauge = function(parent)
		local intValue = Instance.new("IntValue")
		intValue.Name = "Speed"
		intValue.Value = 0
		intValue.Parent = parent
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "SpeedGauge"
		billboardGui.Size = UDim2.new(4, 0, 4, 0)
		billboardGui.StudsOffset = createVector(0, 5, 0)
		billboardGui.AlwaysOnTop = false
		billboardGui.Parent = parent
		local frame = Instance.new("Frame")
		frame.Name = "OuterFrame"
		frame.Size = UDim2.new(0.8, 0, 0.8, 0)
		frame.Position = UDim2.new(0.1, 0, 0.1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		frame.BackgroundTransparency = 0.3
		frame.BorderSizePixel = 0
		frame.Parent = billboardGui
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.5, 0)
		uICorner.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "GaugeBackground"
		frame2.Size = UDim2.new(0.9, 0, 0.9, 0)
		frame2.Position = UDim2.new(0.05, 0, 0.05, 0)
		frame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		frame2.BackgroundTransparency = 0.4
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0.5, 0)
		uICorner2.Parent = frame2
		local frame3 = Instance.new("Frame")
		frame3.Name = "GaugeFace"
		frame3.Size = UDim2.new(0.95, 0, 0.95, 0)
		frame3.Position = UDim2.new(0.025, 0, 0.025, 0)
		frame3.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		frame3.BackgroundTransparency = 0.2
		frame3.BorderSizePixel = 0
		frame3.Rotation = -95
		frame3.Parent = frame2
		local uICorner3 = Instance.new("UICorner")
		uICorner3.CornerRadius = UDim.new(0.5, 0)
		uICorner3.Parent = frame3
		local v = {
			{
				value = 0,
				rotation = -45,
				color = Color3.fromRGB(20, 140, 60)
			},
			{
				value = 5,
				rotation = -31.5,
				color = Color3.fromRGB(30, 135, 55)
			},
			{
				value = 10,
				rotation = -18,
				color = Color3.fromRGB(40, 130, 50)
			},
			{
				value = 15,
				rotation = -4.5,
				color = Color3.fromRGB(50, 125, 45)
			},
			{
				value = 20,
				rotation = 9,
				color = Color3.fromRGB(60, 120, 40)
			},
			{
				value = 25,
				rotation = 22.5,
				color = Color3.fromRGB(70, 115, 35)
			},
			{
				value = 30,
				rotation = 36,
				color = Color3.fromRGB(80, 110, 30)
			},
			{
				value = 35,
				rotation = 49.5,
				color = Color3.fromRGB(90, 105, 25)
			},
			{
				value = 40,
				rotation = 63,
				color = Color3.fromRGB(100, 100, 20)
			},
			{
				value = 45,
				rotation = 76.5,
				color = Color3.fromRGB(110, 90, 20)
			},
			{
				value = 50,
				rotation = 90,
				color = Color3.fromRGB(120, 80, 20)
			},
			{
				value = 55,
				rotation = 103.5,
				color = Color3.fromRGB(130, 70, 20)
			},
			{
				value = 60,
				rotation = 117,
				color = Color3.fromRGB(140, 60, 20)
			},
			{
				value = 65,
				rotation = 130.5,
				color = Color3.fromRGB(150, 50, 20)
			},
			{
				value = 70,
				rotation = 144,
				color = Color3.fromRGB(160, 40, 20)
			},
			{
				value = 75,
				rotation = 157.5,
				color = Color3.fromRGB(170, 30, 20)
			},
			{
				value = 80,
				rotation = 171,
				color = Color3.fromRGB(180, 20, 20)
			},
			{
				value = 85,
				rotation = 184.5,
				color = Color3.fromRGB(170, 20, 30)
			},
			{
				value = 90,
				rotation = 198,
				color = Color3.fromRGB(160, 20, 40)
			},
			{
				value = 95,
				rotation = 211.5,
				color = Color3.fromRGB(150, 20, 50)
			},
			{
				value = 100,
				rotation = 225,
				color = Color3.fromRGB(180, 20, 20)
			}
		}

		for _, v2 in ipairs(v) do
			local frame4 = Instance.new("Frame")
			frame4.Name = "Tick" .. tostring(v2.value)
			frame4.Size = UDim2.new(0.02, 0, 0.08, 0)
			frame4.Position = UDim2.new(0.49, 0, 0.05, 0)
			frame4.AnchorPoint = Vector2.new(0.5, 0)
			frame4.BackgroundColor3 = v2.color
			frame4.BackgroundTransparency = 0.3
			frame4.BorderSizePixel = 0
			frame4.Rotation = v2.rotation
			frame4.Parent = frame3
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v2.color),
				ColorSequenceKeypoint.new(
					0.5,
					Color3.new(
						math.min(v2.color.R * 1.3, 1),
						math.min(v2.color.G * 1.3, 1),
						(math.min(v2.color.B * 1.3, 1))
					)
				),
				ColorSequenceKeypoint.new(1, v2.color)
			})
			uIGradient.Rotation = 90
			uIGradient.Parent = frame4
		end

		local v2 = {
			{
				text = "0",
				position = UDim2.new(0.2, 0, 0.7, 0)
			},
			{
				text = "25",
				position = UDim2.new(0.15, 0, 0.35, 0)
			},
			{
				text = "50",
				position = UDim2.new(0.5, 0, 0.15, 0)
			},
			{
				text = "75",
				position = UDim2.new(0.85, 0, 0.35, 0)
			},
			{
				text = "100",
				position = UDim2.new(0.8, 0, 0.7, 0)
			}
		}

		for _, v3 in ipairs(v2) do
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(0.15, 0, 0.1, 0)
			textLabel.Position = v3.position
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = v3.text
			textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			textLabel.TextTransparency = 0.1
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.Bodoni
			textLabel.TextStrokeTransparency = 0.3
			textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			textLabel.Parent = frame3
		end

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "SpeedText"
		textLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
		textLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "SPEED"
		textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel.TextTransparency = 0.1
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.Bodoni
		textLabel.TextStrokeTransparency = 0.3
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.Parent = frame3
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "SpeedValue"
		textLabel2.Size = UDim2.new(0.2, 0, 0.15, 0)
		textLabel2.Position = UDim2.new(0.5, 0, 0.75, 0)
		textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = "0"
		textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
		textLabel2.TextTransparency = 0.1
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.Bodoni
		textLabel2.TextStrokeTransparency = 0.3
		textLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel2.Parent = frame3
		local frame4 = Instance.new("Frame")
		frame4.Name = "NeedleContainer"
		frame4.Size = UDim2.new(1, 0, 1, 0)
		frame4.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame4.AnchorPoint = Vector2.new(0.5, 0.5)
		frame4.BackgroundTransparency = 1
		frame4.Rotation = -138
		frame4.Parent = frame3
		local frame5 = Instance.new("Frame")
		frame5.Name = "Needle"
		frame5.Size = UDim2.new(0.03, 0, 0.4, 0)
		frame5.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame5.AnchorPoint = Vector2.new(0.5, 1)
		frame5.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
		frame5.BackgroundTransparency = 0.1
		frame5.BorderSizePixel = 0
		frame5.Rotation = -2
		frame5.Parent = frame4
		local frame6 = Instance.new("Frame")
		frame6.Name = "Frame"
		frame6.Size = UDim2.new(1.5, 0, 0.1, 0)
		frame6.Position = UDim2.new(0.5, 0, 0, 0)
		frame6.AnchorPoint = Vector2.new(0.5, 1)
		frame6.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
		frame6.BackgroundTransparency = 0.2
		frame6.BorderSizePixel = 0
		frame6.Rotation = 45
		frame6.Parent = frame5
		local frame7 = Instance.new("Frame")
		frame7.Name = "CenterPivot"
		frame7.Size = UDim2.new(0.08, 0, 0.08, 0)
		frame7.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame7.AnchorPoint = Vector2.new(0.5, 0.5)
		frame7.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
		frame7.BackgroundTransparency = 0.2
		frame7.BorderSizePixel = 0
		frame7.Rotation = 0
		frame7.Parent = frame3
		local uICorner4 = Instance.new("UICorner")
		uICorner4.CornerRadius = UDim.new(0.5, 0)
		uICorner4.Parent = frame7
		print("Speed gauge created successfully for", parent.Name)
		return billboardGui, intValue, frame4
	end
}