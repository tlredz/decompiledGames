require(script.Parent.Parent.Types)
return function(state, data)
	local function relocateTooltips()
		if state._rootInstance == nil then
			return
		end

		local popupScreenGui = state._rootInstance:FindFirstChild("PopupScreenGui")

		if not popupScreenGui then
			return
		end

		local tooltipContainer = popupScreenGui.TooltipContainer
		local mouseLocation = data.getMouseLocation()
		local bestWindowPosForPopup = data.findBestWindowPosForPopup(
			mouseLocation,
			tooltipContainer.AbsoluteSize,
			state._config.DisplaySafeAreaPadding,
			popupScreenGui.AbsoluteSize
		)
		tooltipContainer.Position = UDim2.fromOffset(bestWindowPosForPopup.X, bestWindowPosForPopup.Y)
	end

	data.UserInputService.InputChanged:Connect(relocateTooltips)
	state.WidgetConstructor("Tooltip", {
		hasState = false,
		hasChildren = false,
		Args = {
			Text = 1
		},
		Events = {},
		Generate = function(p)
			p.parentWidget = state._rootWidget
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Tooltip"
			frame.Size = UDim2.new(state._config.ContentWidth, UDim.new(0, 0))
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BorderSizePixel = 0
			frame.BackgroundTransparency = 1
			frame.ZIndex = p.ZIndex + 1
			frame.LayoutOrder = p.ZIndex + 1
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TooltipText"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundColor3 = state._config.WindowBgColor
			textLabel.BackgroundTransparency = state._config.WindowBgTransparency
			textLabel.BorderSizePixel = state._config.PopupBorderSize
			textLabel.TextWrapped = true
			textLabel.ZIndex = p.ZIndex + 1
			textLabel.LayoutOrder = p.ZIndex + 1
			data.applyTextStyle(textLabel)
			data.UIStroke(
				textLabel,
				state._config.WindowBorderSize,
				state._config.BorderActiveColor,
				state._config.BorderActiveTransparency
			)
			data.UIPadding(textLabel, state._config.WindowPadding)

			if state._config.PopupRounding > 0 then
				data.UICorner(textLabel, state._config.PopupRounding)
			end

			textLabel.Parent = frame
			return frame
		end,
		Update = function(p)
			local tooltipText = p.Instance.TooltipText

			if p.arguments.Text == nil then
				error("Iris.Text Text Argument is required", 5)
			end

			tooltipText.Text = p.arguments.Text
			relocateTooltips()
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})
	local count = 0
	local v = nil
	local v2 = false
	local v3 = nil
	local v4 = nil
	local v5 = false
	local v6 = false
	local v7 = false
	local top = Enum.TopBottom.Top
	local left = Enum.LeftRight.Left
	local v8 = nil
	local v9 = nil
	local v10 = false
	local v11 = {}

	local function quickSwapWindows()
		if state._config.UseScreenGUIs == false then
			return
		end

		local v12 = 65535
		local v13 = nil

		for _, v14 in v11 do
			if not v14.state.isOpened.value or v14.arguments.NoNav or not v14.Instance:IsA("ScreenGui") then
				continue
			end

			local displayOrder = v14.Instance.DisplayOrder

			if not (displayOrder < v12) then
				continue
			end

			v13 = v14
			v12 = displayOrder
		end

		if v13.state.isUncollapsed.value == false then
			v13.state.isUncollapsed:set(true)
		end

		state.SetFocusedWindow(v13)
	end

	local function fitSizeToWindowBounds(p, point: Vector2)
		local vector = Vector2.new(p.state.position.value.X, p.state.position.value.Y)
		local v12 = (state._config.TextSize + state._config.FramePadding.Y * 2) * 2
		local screenSizeForWindow = data.getScreenSizeForWindow(p)
		local vector2 = Vector2.new(
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.X,
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.Y
		)
		local v13 = screenSizeForWindow - vector - vector2
		return Vector2.new(
			math.clamp(point.X, v12, (math.max(v13.X, v12))),
			(math.clamp(point.Y, v12, (math.max(v13.Y, v12))))
		)
	end

	local function fitPositionToWindowBounds(p, point: Vector2)
		local instance = p.Instance
		local screenSizeForWindow = data.getScreenSizeForWindow(p)
		local vector = Vector2.new(
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.X,
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.Y
		)
		return Vector2.new(
			math.clamp(
				point.X,
				vector.X,
				(math.max(vector.X, screenSizeForWindow.X - instance.WindowButton.AbsoluteSize.X - vector.X))
			),
			(math.clamp(
				point.Y,
				vector.Y,
				(math.max(vector.Y, screenSizeForWindow.Y - instance.WindowButton.AbsoluteSize.Y - vector.Y))
			))
		)
	end

	function state.SetFocusedWindow(data2)
		if v9 == data2 then
			return
		end

		if v10 and v9 ~= nil then
			if v11[v9.ID] then
				local windowButton = v9.Instance.WindowButton
				local titleBar = windowButton.TitleBar

				if v9.state.isUncollapsed.value then
					titleBar.BackgroundColor3 = state._config.TitleBgColor
					titleBar.BackgroundTransparency = state._config.TitleBgTransparency
				else
					titleBar.BackgroundColor3 = state._config.TitleBgCollapsedColor
					titleBar.BackgroundTransparency = state._config.TitleBgCollapsedTransparency
				end

				windowButton.UIStroke.Color = state._config.BorderColor
			end

			v10 = false
			v9 = nil
		end

		if data2 ~= nil then
			v10 = true
			v9 = data2
			local instance = data2.Instance
			local windowButton = instance.WindowButton
			local titleBar = windowButton.TitleBar
			titleBar.BackgroundColor3 = state._config.TitleBgActiveColor
			titleBar.BackgroundTransparency = state._config.TitleBgActiveTransparency
			windowButton.UIStroke.Color = state._config.BorderActiveColor
			count += 1

			if data2.usesScreenGUI then
				instance.DisplayOrder = count + state._config.DisplayOrderOffset
			end

			if data2.state.isUncollapsed.value == false then
				data2.state.isUncollapsed:set(true)
			end

			if data.GuiService.SelectedObject then
				if titleBar.Visible then
					data.GuiService:Select(titleBar)
				else
					data.GuiService:Select(instance.ChildContainer)
				end
			end
		end
	end

	data.UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
			state.SetFocusedWindow(nil)
		end

		if input.KeyCode == Enum.KeyCode.Tab and (data.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			quickSwapWindows()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 and v6 and not v7 and v10 and v9 then
			local v12 = v9.state.position.value + v9.state.size.value * 0.5
			local v13 = data.getMouseLocation() - v12

			if math.abs(v13.X) * v9.state.size.value.Y >= math.abs(v13.Y) * v9.state.size.value.X then
				top = Enum.TopBottom.Center
				local v14

				if math.sign(v13.X) == -1 then
					v14 = Enum.LeftRight.Left
				else
					v14 = Enum.LeftRight.Right
				end

				left = v14
			else
				left = Enum.LeftRight.Center
				local v14

				if math.sign(v13.Y) == -1 then
					v14 = Enum.TopBottom.Top
				else
					v14 = Enum.TopBottom.Bottom
				end

				top = v14
			end

			v5 = true
			v4 = v9
		end
	end)
	data.UserInputService.TouchTapInWorld:Connect(function(_, flag: boolean)
		if not flag then
			state.SetFocusedWindow(nil)
		end
	end)
	data.UserInputService.InputChanged:Connect(function(input)
		if v2 and v then
			local vector

			if input.UserInputType == Enum.UserInputType.Touch then
				local position = input.Position
				vector = Vector2.new(position.X, position.Y)
			else
				vector = data.getMouseLocation()
			end

			local windowButton = v.Instance.WindowButton
			local v12 = vector - v3
			local v13 = fitPositionToWindowBounds(v, v12)
			windowButton.Position = UDim2.fromOffset(v13.X, v13.Y)
			v.state.position.value = v13
		end

		if v5 and v4 and v4.arguments.NoResize ~= true then
			local windowButton = v4.Instance.WindowButton
			local vector = Vector2.new(windowButton.Position.X.Offset, windowButton.Position.Y.Offset)
			local vector2 = Vector2.new(windowButton.Size.X.Offset, windowButton.Size.Y.Offset)
			local delta

			if input.UserInputType == Enum.UserInputType.Touch then
				delta = input.Delta
			else
				delta = data.getMouseLocation() - v8
			end

			local v12 = vector + Vector2.new(
				left ~= Enum.LeftRight.Left and 0 or delta.X,
				top ~= Enum.TopBottom.Top and 0 or delta.Y
			)
			local v13

			if left == Enum.LeftRight.Left then
				v13 = -delta.X
			else
				v13 = left ~= Enum.LeftRight.Right and 0 or delta.X
			end

			local v14

			if top == Enum.TopBottom.Top then
				v14 = -delta.Y
			else
				v14 = top ~= Enum.TopBottom.Bottom and 0 or delta.Y
			end

			local v15 = vector2 + Vector2.new(v13, v14)
			local v16 = fitSizeToWindowBounds(v4, v15)
			local v17 = fitPositionToWindowBounds(v4, v12)
			windowButton.Size = UDim2.fromOffset(v16.X, v16.Y)
			v4.state.size.value = v16
			windowButton.Position = UDim2.fromOffset(v17.X, v17.Y)
			v4.state.position.value = v17
		end

		v8 = data.getMouseLocation()
	end)
	data.UserInputService.InputEnded:Connect(function(input, _)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and v2 and v then
			local windowButton = v.Instance.WindowButton
			v2 = false
			v.state.position:set(Vector2.new(windowButton.Position.X.Offset, windowButton.Position.Y.Offset))
		end

		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and v5 and v4 then
			local instance = v4.Instance
			v5 = false
			v4.state.size:set(instance.WindowButton.AbsoluteSize)
		end

		if input.KeyCode == Enum.KeyCode.ButtonX then
			quickSwapWindows()
		end
	end)
	state.WidgetConstructor("Window", {
		hasState = true,
		hasChildren = true,
		Args = {
			Title = 1,
			NoTitleBar = 2,
			NoBackground = 3,
			NoCollapse = 4,
			NoClose = 5,
			NoMove = 6,
			NoScrollbar = 7,
			NoResize = 8,
			NoNav = 9,
			NoMenu = 10
		},
		Events = {
			closed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastClosedTick == state._cycleTick
				end
			},
			opened = {
				Init = function(_) end,
				Get = function(p)
					return p.lastOpenedTick == state._cycleTick
				end
			},
			collapsed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastCollapsedTick == state._cycleTick
				end
			},
			uncollapsed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastUncollapsedTick == state._cycleTick
				end
			},
			hovered = data.EVENTS.hover(function(p)
				return p.Instance.WindowButton
			end)
		},
		Generate = function(state2)
			state2.parentWidget = state._rootWidget
			state2.usesScreenGUI = state._config.UseScreenGUIs
			v11[state2.ID] = state2
			local parent

			if state2.usesScreenGUI then
				parent = Instance.new("ScreenGui")
				parent.ResetOnSpawn = false
				parent.DisplayOrder = state._config.DisplayOrderOffset
				parent.IgnoreGuiInset = state._config.IgnoreGuiInset
			else
				parent = Instance.new("Folder")
			end

			parent.Name = "Iris_Window"
			local textButton = Instance.new("TextButton")
			textButton.Name = "WindowButton"
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.ClipsDescendants = false
			textButton.AutoButtonColor = false
			textButton.Selectable = false
			textButton.SelectionImageObject = state.SelectionImageObject
			textButton.ZIndex = state2.ZIndex + 1
			textButton.LayoutOrder = state2.ZIndex + 1
			textButton.SelectionGroup = true
			textButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			textButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			textButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			textButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			data.UIStroke(
				textButton,
				state._config.WindowBorderSize,
				state._config.BorderColor,
				state._config.BorderTransparency
			)
			textButton.Parent = parent
			textButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end

				if not state2.arguments.NoMove and input.UserInputType == Enum.UserInputType.MouseButton1 then
					v = state2
					v2 = true
					v3 = data.getMouseLocation() - state2.state.position.value
				end
			end)
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "ChildContainer"
			scrollingFrame.Size = UDim2.fromScale(1, 1)
			scrollingFrame.Position = UDim2.fromOffset(0, 0)
			scrollingFrame.BackgroundColor3 = state._config.WindowBgColor
			scrollingFrame.BackgroundTransparency = state._config.WindowBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = state._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = state._config.ScrollbarGrabColor
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 1)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.ZIndex = state2.ZIndex + 3
			scrollingFrame.LayoutOrder = state2.ZIndex + 3
			scrollingFrame.ClipsDescendants = true
			data.UIPadding(scrollingFrame, state._config.WindowPadding)
			scrollingFrame.Parent = textButton
			scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				state2.state.scrollDistance.value = scrollingFrame.CanvasPosition.Y
			end)
			scrollingFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Keyboard then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end
			end)
			local frame = Instance.new("Frame")
			frame.Name = "TerminatingFrame"
			frame.Size = UDim2.fromOffset(0, state._config.WindowPadding.Y + state._config.FramePadding.Y)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = 2147483632
			local uIListLayout = data.UIListLayout(
				scrollingFrame,
				Enum.FillDirection.Vertical,
				UDim.new(0, state._config.ItemSpacing.Y)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			frame.Parent = scrollingFrame
			local frame2 = Instance.new("Frame")
			frame2.Name = "TitleBar"
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.BorderSizePixel = 0
			frame2.ZIndex = state2.ZIndex + 1
			frame2.LayoutOrder = state2.ZIndex + 1
			frame2.ClipsDescendants = true
			frame2.Parent = textButton
			frame2.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch and not state2.arguments.NoMove then
					v = state2
					v2 = true
					local position = input.Position
					v3 = Vector2.new(position.X, position.Y) - state2.state.position.value
				end
			end)
			local v13 = state._config.TextSize + (state._config.FramePadding.Y - 1) * 2
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "CollapseButton"
			textButton2.AnchorPoint = Vector2.new(0, 0.5)
			textButton2.Size = UDim2.fromOffset(v13, v13)
			textButton2.Position = UDim2.new(0, state._config.FramePadding.X + 1, 0.5, 0)
			textButton2.AutomaticSize = Enum.AutomaticSize.None
			textButton2.BackgroundTransparency = 1
			textButton2.BorderSizePixel = 0
			textButton2.AutoButtonColor = false
			textButton2.Text = ""
			textButton2.ZIndex = state2.ZIndex + 4
			data.UICorner(textButton2)
			textButton2.Parent = frame2
			textButton2.MouseButton1Click:Connect(function()
				state2.state.isUncollapsed:set(not state2.state.isUncollapsed.value)
			end)
			data.applyInteractionHighlights(textButton2, textButton2, {
				ButtonColor = state._config.ButtonColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = state._config.ButtonHoveredColor,
				ButtonHoveredTransparency = state._config.ButtonHoveredTransparency,
				ButtonActiveColor = state._config.ButtonActiveColor,
				ButtonActiveTransparency = state._config.ButtonActiveTransparency
			})
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(math.floor(v13 * 0.7), (math.floor(v13 * 0.7)))
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Image = data.ICONS.MULTIPLICATION_SIGN
			imageLabel.ImageColor3 = state._config.TextColor
			imageLabel.ImageTransparency = state._config.TextTransparency
			imageLabel.ZIndex = state2.ZIndex + 5
			imageLabel.Parent = textButton2
			local textButton3 = Instance.new("TextButton")
			textButton3.Name = "CloseButton"
			textButton3.AnchorPoint = Vector2.new(1, 0.5)
			textButton3.Size = UDim2.fromOffset(v13, v13)
			textButton3.Position = UDim2.new(1, -(state._config.FramePadding.X + 1), 0.5, 0)
			textButton3.AutomaticSize = Enum.AutomaticSize.None
			textButton3.BackgroundTransparency = 1
			textButton3.BorderSizePixel = 0
			textButton3.Text = ""
			textButton3.ZIndex = state2.ZIndex + 4
			textButton3.AutoButtonColor = false
			data.UICorner(textButton3)
			textButton3.MouseButton1Click:Connect(function()
				state2.state.isOpened:set(false)
			end)
			data.applyInteractionHighlights(textButton3, textButton3, {
				ButtonColor = state._config.ButtonColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = state._config.ButtonHoveredColor,
				ButtonHoveredTransparency = state._config.ButtonHoveredTransparency,
				ButtonActiveColor = state._config.ButtonActiveColor,
				ButtonActiveTransparency = state._config.ButtonActiveTransparency
			})
			textButton3.Parent = frame2
			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Name = "Icon"
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel2.Size = UDim2.fromOffset(math.floor(v13 * 0.7), (math.floor(v13 * 0.7)))
			imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.BorderSizePixel = 0
			imageLabel2.Image = data.ICONS.MULTIPLICATION_SIGN
			imageLabel2.ImageColor3 = state._config.TextColor
			imageLabel2.ImageTransparency = state._config.TextTransparency
			imageLabel2.ZIndex = state2.ZIndex + 5
			imageLabel2.Parent = textButton3
			local v14 = state._config.WindowTitleAlign == Enum.LeftRight.Left and 0 or state._config.WindowTitleAlign == Enum.LeftRight.Center and 0.5 or 1
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Title"
			textLabel.AnchorPoint = Vector2.new(v14, 0)
			textLabel.Position = UDim2.fromScale(v14, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BorderSizePixel = 0
			textLabel.BackgroundTransparency = 1
			textLabel.ZIndex = state2.ZIndex + 3
			data.applyTextStyle(textLabel)
			data.UIPadding(textLabel, state._config.FramePadding)
			textLabel.Parent = frame2
			local textSize = state._config.TextSize + state._config.FramePadding.X
			local textButton4 = Instance.new("TextButton")
			textButton4.Name = "ResizeGrip"
			textButton4.AnchorPoint = Vector2.new(1, 1)
			textButton4.Size = UDim2.fromOffset(textSize, textSize)
			textButton4.Position = UDim2.fromScale(1, 1)
			textButton4.AutoButtonColor = false
			textButton4.BorderSizePixel = 0
			textButton4.BackgroundTransparency = 1
			textButton4.Text = data.ICONS.BOTTOM_RIGHT_CORNER
			textButton4.TextSize = textSize
			textButton4.TextColor3 = state._config.ButtonColor
			textButton4.TextTransparency = state._config.ButtonTransparency
			textButton4.LineHeight = 1.1
			textButton4.Selectable = false
			textButton4.ZIndex = state2.ZIndex + 3
			textButton4.Parent = textButton
			data.applyTextInteractionHighlights(textButton4, textButton4, {
				ButtonColor = state._config.ButtonColor,
				ButtonTransparency = state._config.ButtonTransparency,
				ButtonHoveredColor = state._config.ButtonHoveredColor,
				ButtonHoveredTransparency = state._config.ButtonHoveredTransparency,
				ButtonActiveColor = state._config.ButtonActiveColor,
				ButtonActiveTransparency = state._config.ButtonActiveTransparency
			})
			textButton4.MouseButton1Down:Connect(function()
				if not v10 or v9 ~= state2 then
					state.SetFocusedWindow(state2)
				end

				v5 = true
				top = Enum.TopBottom.Bottom
				left = Enum.LeftRight.Right
				v4 = state2
			end)
			local textButton5 = Instance.new("TextButton")
			textButton5.Name = "ResizeBorder"
			textButton5.Size = UDim2.new(
				1,
				state._config.WindowResizePadding.X * 2,
				1,
				state._config.WindowResizePadding.Y * 2
			)
			textButton5.Position = UDim2.fromOffset(
				-state._config.WindowResizePadding.X,
				-state._config.WindowResizePadding.Y
			)
			textButton5.BackgroundTransparency = 1
			textButton5.BorderSizePixel = 0
			textButton5.Text = ""
			textButton5.AutoButtonColor = false
			textButton5.Active = true
			textButton5.Selectable = false
			textButton5.ZIndex = state2.ZIndex
			textButton5.LayoutOrder = state2.ZIndex
			textButton5.ClipsDescendants = false
			textButton5.Parent = textButton
			textButton5.MouseEnter:Connect(function()
				if v9 == state2 then
					v6 = true
				end
			end)
			textButton5.MouseLeave:Connect(function()
				if v9 == state2 then
					v6 = false
				end
			end)
			textButton.MouseEnter:Connect(function()
				if v9 == state2 then
					v7 = true
				end
			end)
			textButton.MouseLeave:Connect(function()
				if v9 == state2 then
					v7 = false
				end
			end)
			return parent
		end,
		Update = function(p)
			local windowButton = p.Instance.WindowButton
			local titleBar = windowButton.TitleBar
			local title = titleBar.Title
			local menuBar = windowButton:FindFirstChild("MenuBar")
			local childContainer = windowButton.ChildContainer
			local resizeGrip = windowButton.ResizeGrip
			local total = 0
			local total2 = 0

			if p.arguments.NoResize == true then
				resizeGrip.Visible = false
			else
				resizeGrip.Visible = true
			end

			if p.arguments.NoScrollbar then
				childContainer.ScrollBarThickness = 0
			else
				childContainer.ScrollBarThickness = state._config.ScrollbarSize
			end

			if p.arguments.NoTitleBar then
				titleBar.Visible = false
			else
				titleBar.Visible = true
				local Y = titleBar.AbsoluteSize.Y
				total += Y
				total2 += Y
			end

			if menuBar then
				if p.arguments.NoMenu then
					menuBar.Visible = false
				else
					menuBar.Visible = true
					total += menuBar.AbsoluteSize.Y
				end

				menuBar.Position = UDim2.fromOffset(0, total2)
			end

			if p.arguments.NoBackground then
				childContainer.BackgroundTransparency = 1
			else
				childContainer.BackgroundTransparency = state._config.WindowBgTransparency
			end

			local v12 = state._config.FramePadding.X + state._config.TextSize + state._config.FramePadding.X * 2

			if p.arguments.NoCollapse then
				titleBar.CollapseButton.Visible = false
				titleBar.Title.UIPadding.PaddingLeft = UDim.new(0, state._config.FramePadding.X)
			else
				titleBar.CollapseButton.Visible = true
				titleBar.Title.UIPadding.PaddingLeft = UDim.new(0, v12)
			end

			if p.arguments.NoClose then
				titleBar.CloseButton.Visible = false
				titleBar.Title.UIPadding.PaddingRight = UDim.new(0, state._config.FramePadding.X)
			else
				titleBar.CloseButton.Visible = true
				titleBar.Title.UIPadding.PaddingRight = UDim.new(0, v12)
			end

			childContainer.Size = UDim2.new(1, 0, 1, -total)
			childContainer.CanvasSize = UDim2.new(0, 0, 1, -total)
			childContainer.Position = UDim2.fromOffset(0, total)
			title.Text = p.arguments.Title or ""
		end,
		Discard = function(p)
			if v9 == p then
				v9 = nil
				v10 = false
			end

			if v == p then
				v = nil
				v2 = false
			end

			if v4 == p then
				v4 = nil
				v5 = false
			end

			v11[p.ID] = nil
			p.Instance:Destroy()
			data.discardState(p)
		end,
		ChildAdded = function(p)
			return p.Instance.WindowButton.ChildContainer
		end,
		UpdateState = function(state2)
			local value = state2.state.size.value
			local value2 = state2.state.position.value
			local value3 = state2.state.isUncollapsed.value
			local value4 = state2.state.isOpened.value
			local value5 = state2.state.scrollDistance.value
			local instance = state2.Instance
			local windowButton = instance.WindowButton
			local titleBar = windowButton.TitleBar
			local childContainer = windowButton.ChildContainer
			local resizeGrip = windowButton.ResizeGrip
			windowButton.Size = UDim2.fromOffset(value.X, value.Y)
			windowButton.Position = UDim2.fromOffset(value2.X, value2.Y)

			if value4 then
				if state2.usesScreenGUI then
					instance.Enabled = true
				end

				windowButton.Visible = true
				state2.lastOpenedTick = state._cycleTick + 1
			else
				if state2.usesScreenGUI then
					instance.Enabled = false
				end

				windowButton.Visible = false
				state2.lastClosedTick = state._cycleTick + 1
			end

			if value3 then
				titleBar.CollapseButton.Arrow.Image = data.ICONS.DOWN_POINTING_TRIANGLE
				childContainer.Visible = true

				if state2.arguments.NoResize ~= true then
					resizeGrip.Visible = true
				end

				windowButton.AutomaticSize = Enum.AutomaticSize.None
				state2.lastUncollapsedTick = state._cycleTick + 1
			else
				local Y = titleBar.AbsoluteSize.Y
				titleBar.CollapseButton.Arrow.Image = data.ICONS.RIGHT_POINTING_TRIANGLE
				childContainer.Visible = false
				resizeGrip.Visible = false
				windowButton.Size = UDim2.fromOffset(value.X, Y)
				state2.lastCollapsedTick = state._cycleTick + 1
			end

			if value4 and value3 then
				state.SetFocusedWindow(state2)
			else
				titleBar.BackgroundColor3 = state._config.TitleBgCollapsedColor
				titleBar.BackgroundTransparency = state._config.TitleBgCollapsedTransparency
				windowButton.UIStroke.Color = state._config.BorderColor
				state.SetFocusedWindow(nil)
			end

			if value5 and value5 ~= 0 then
				local v12 = #state._postCycleCallbacks + 1
				local v13 = state._cycleTick + 1

				state._postCycleCallbacks[v12] = function()
					if state._cycleTick == v13 then
						childContainer.CanvasPosition = Vector2.new(0, value5)
						state._postCycleCallbacks[v12] = nil
					end
				end
			end
		end,
		GenerateState = function(p)
			if p.state.size == nil then
				p.state.size = state._widgetState(p, "size", Vector2.new(400, 300))
			end

			if p.state.position == nil then
				local state2 = p.state
				local _widgetState = state._widgetState
				local v13

				if v10 and v9 then
					v13 = v9.state.position.value + Vector2.new(15, 45)
				else
					v13 = Vector2.new(150, 250)
				end

				state2.position = _widgetState(p, "position", v13)
			end

			p.state.position.value = fitPositionToWindowBounds(p, p.state.position.value)
			p.state.size.value = fitSizeToWindowBounds(p, p.state.size.value)

			if p.state.isUncollapsed == nil then
				p.state.isUncollapsed = state._widgetState(p, "isUncollapsed", true)
			end

			if p.state.isOpened == nil then
				p.state.isOpened = state._widgetState(p, "isOpened", true)
			end

			if p.state.scrollDistance == nil then
				p.state.scrollDistance = state._widgetState(p, "scrollDistance", 0)
			end
		end
	})
end