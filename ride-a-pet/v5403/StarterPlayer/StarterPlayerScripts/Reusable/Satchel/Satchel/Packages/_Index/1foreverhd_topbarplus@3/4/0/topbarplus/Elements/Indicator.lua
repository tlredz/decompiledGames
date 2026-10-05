return function(object, _)
	local widget = object.widget
	local instance = object:getInstance("Contents")
	local frame = Instance.new("Frame")
	frame.Name = "Indicator"
	frame.LayoutOrder = 9999999
	frame.ZIndex = 6
	frame.Size = UDim2.new(0, 42, 0, 42)
	frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.new(1, 0, 0.5, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.Parent = instance
	local frame2 = Instance.new("Frame")
	frame2.Name = "IndicatorButton"
	frame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BorderSizePixel = 0
	frame2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame2.Parent = frame
	local GuiService = game:GetService("GuiService")
	local GamepadService = game:GetService("GamepadService")
	local instance2 = object:getInstance("ClickRegion")

	local function selectionChanged()
		if GuiService.SelectedObject == instance2 then
			frame2.BackgroundTransparency = 1
			frame2.Position = UDim2.new(0.5, -2, 0.5, 0)
			frame2.Size = UDim2.fromScale(1.2, 1.2)
		else
			frame2.BackgroundTransparency = 0.75
			frame2.Position = UDim2.new(0.5, 2, 0.5, 0)
			frame2.Size = UDim2.fromScale(1, 1)
		end
	end

	object.janitor:add(GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(selectionChanged))
	selectionChanged()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.LayoutOrder = 2
	imageLabel.ZIndex = 15
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Image = "rbxasset://textures/ui/Controls/XboxController/DPadUp@2x.png"
	imageLabel.Parent = frame2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame2
	local UserInputService = game:GetService("UserInputService")

	local function setIndicatorVisible(visible)
		if visible == nil then
			visible = frame.Visible
		end

		if GamepadService.GamepadCursorEnabled then
			visible = false
		end

		if visible then
			object:modifyTheme({ "PaddingRight", "Size", UDim2.new(0, 0, 1, 0) }, "IndicatorPadding")
		elseif frame.Visible then
			object:removeModification("IndicatorPadding")
		end

		object:modifyTheme({ "Indicator", "Visible", visible })
		object.updateSize:Fire()
	end

	object.janitor:add(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(setIndicatorVisible))
	object.indicatorSet:Connect(function(p)
		local v

		if p then
			imageLabel.Image = UserInputService:GetImageForKeyCode(p)
			v = true
		else
			v = false
		end

		setIndicatorVisible(v)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSize()
		local v = widget.AbsoluteSize.Y * 0.96
		frame.Size = UDim2.new(0, v, 0, v)
	end

	widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
	updateSize() -- equivalent call inferred; original call site unknown
	return frame
end