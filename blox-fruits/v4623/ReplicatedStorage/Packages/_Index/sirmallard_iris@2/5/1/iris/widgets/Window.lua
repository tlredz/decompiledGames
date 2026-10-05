require(script.Parent.Parent.Types)
return function(state, data)
	local function relocateTooltips()
		if state._rootInstance == nil then
			return
		end

		local popupScreenGui = state._rootInstance:FindFirstChild("PopupScreenGui")
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

	data.registerEvent("InputChanged", function()
		if not state._started then
			return
		end

		relocateTooltips()
	end)
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
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.new(state._config.ContentWidth, UDim.new(0, 0))
			frame.BorderSizePixel = 0
			frame.BackgroundTransparency = 1
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TooltipText"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.BackgroundColor3 = state._config.PopupBgColor
			textLabel.BackgroundTransparency = state._config.PopupBgTransparency
			data.applyTextStyle(textLabel)
			data.UIStroke(
				textLabel,
				state._config.PopupBorderSize,
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
				error("Text argument is required for Iris.Tooltip().", 5)
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

		if not v13 then
			return
		end

		if v13.state.isUncollapsed.value == false then
			v13.state.isUncollapsed:set(true)
		end

		state.SetFocusedWindow(v13)
	end

	local function fitSizeToWindowBounds(p, point: Vector2)
		local vector = Vector2.new(p.state.position.value.X, p.state.position.value.Y)
		local v12 = (state._config.TextSize + 2 * state._config.FramePadding.Y) * 2
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
				local titleBar = windowButton.Content.TitleBar

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
			local titleBar = windowButton.Content.TitleBar
			titleBar.BackgroundColor3 = state._config.TitleBgActiveColor
			titleBar.BackgroundTransparency = state._config.TitleBgActiveTransparency
			windowButton.UIStroke.Color = state._config.BorderActiveColor
			count += 1

			if data2.usesScreenGuis then
				instance.DisplayOrder = count + state._config.DisplayOrderOffset
			else
				instance.ZIndex = count + state._config.DisplayOrderOffset
			end

			if data2.state.isUncollapsed.value == false then
				data2.state.isUncollapsed:set(true)
			end

			if data.GuiService.SelectedObject then
				if titleBar.Visible then
					data.GuiService:Select(titleBar)
				else
					data.GuiService:Select(data2.ChildContainer)
				end
			end
		end
	end

	data.registerEvent("InputBegan", function(p)
		if not state._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouseLocation = data.getMouseLocation()
			local v12 = false

			for _, v14 in v11 do
				local instance = v14.Instance

				if not instance then
					continue
				end

				local resizeBorder = instance.WindowButton.ResizeBorder

				if not (resizeBorder and data.isPosInsideRect(
					mouseLocation,
					resizeBorder.AbsolutePosition - data.GuiOffset,
					resizeBorder.AbsolutePosition - data.GuiOffset + resizeBorder.AbsoluteSize
				)) then
					continue
				end

				v12 = true
				break
			end

			if not v12 then
				state.SetFocusedWindow(nil)
			end
		end

		if p.KeyCode == Enum.KeyCode.Tab and (data.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			quickSwapWindows()
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v6 and not v7 and v10 and v9 then
			local v12 = v9.state.position.value + v9.state.size.value / 2
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
	data.registerEvent("TouchTapInWorld", function(_, flag: boolean)
		if not state._started then
			return
		end

		if not flag then
			state.SetFocusedWindow(nil)
		end
	end)
	data.registerEvent("InputChanged", function(data2)
		if not state._started then
			return
		end

		if v2 and v then
			local vector

			if data2.UserInputType == Enum.UserInputType.Touch then
				local position = data2.Position
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

			if data2.UserInputType == Enum.UserInputType.Touch then
				delta = data2.Delta
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
	data.registerEvent("InputEnded", function(p, _)
		if not state._started then
			return
		end

		if (p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch) and v2 and v then
			local windowButton = v.Instance.WindowButton
			v2 = false
			v.state.position:set(Vector2.new(windowButton.Position.X.Offset, windowButton.Position.Y.Offset))
		end

		if (p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch) and v5 and v4 then
			local instance = v4.Instance
			v5 = false
			v4.state.size:set(instance.WindowButton.AbsoluteSize)
		end

		if p.KeyCode == Enum.KeyCode.ButtonX then
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
			state2.usesScreenGuis = state._config.UseScreenGUIs
			v11[state2.ID] = state2
			local parent

			if state2.usesScreenGuis then
				parent = Instance.new("ScreenGui")
				parent.ResetOnSpawn = false
				parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				parent.DisplayOrder = state._config.DisplayOrderOffset
				parent.ScreenInsets = state._config.ScreenInsets
				parent.IgnoreGuiInset = state._config.IgnoreGuiInset
			else
				parent = Instance.new("Frame")
				parent.AnchorPoint = Vector2.new(0.5, 0.5)
				parent.Position = UDim2.fromScale(0.5, 0.5)
				parent.Size = UDim2.fromScale(1, 1)
				parent.BackgroundTransparency = 1
				parent.ZIndex = state._config.DisplayOrderOffset
			end

			parent.Name = "Iris_Window"
			local textButton = Instance.new("TextButton")
			textButton.Name = "WindowButton"
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.ClipsDescendants = false
			textButton.Selectable = false
			textButton.SelectionImageObject = state.SelectionImageObject
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
			data.applyInputBegan(textButton, function(p)
				if p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Keyboard then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end

				if not state2.arguments.NoMove and p.UserInputType == Enum.UserInputType.MouseButton1 then
					v = state2
					v2 = true
					v3 = data.getMouseLocation() - state2.state.position.value
				end
			end)
			local frame = Instance.new("Frame")
			frame.Name = "Content"
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.Position = UDim2.fromScale(0.5, 0.5)
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 1
			frame.ClipsDescendants = true
			frame.Parent = textButton
			local uIListLayout = data.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 0))
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "WindowContainer"
			scrollingFrame.Size = UDim2.fromScale(1, 1)
			scrollingFrame.BackgroundColor3 = state._config.WindowBgColor
			scrollingFrame.BackgroundTransparency = state._config.WindowBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = state._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = state._config.ScrollbarGrabColor
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.TopImage = data.ICONS.BLANK_SQUARE
			scrollingFrame.MidImage = data.ICONS.BLANK_SQUARE
			scrollingFrame.BottomImage = data.ICONS.BLANK_SQUARE
			scrollingFrame.LayoutOrder = state2.ZIndex + 65535
			scrollingFrame.ClipsDescendants = true
			data.UIPadding(scrollingFrame, state._config.WindowPadding)
			scrollingFrame.Parent = frame
			local uIFlexItem = Instance.new("UIFlexItem")
			uIFlexItem.FlexMode = Enum.UIFlexMode.Fill
			uIFlexItem.ItemLineAlignment = Enum.ItemLineAlignment.End
			uIFlexItem.Parent = scrollingFrame
			scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				state2.state.scrollDistance.value = scrollingFrame.CanvasPosition.Y
			end)
			data.applyInputBegan(scrollingFrame, function(p)
				if p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Keyboard then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end
			end)
			local frame2 = Instance.new("Frame")
			frame2.Name = "TerminatingFrame"
			frame2.Size = UDim2.fromOffset(0, state._config.WindowPadding.Y + state._config.FramePadding.Y)
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.LayoutOrder = 2147483632
			local uIListLayout_2 = data.UIListLayout(
				scrollingFrame,
				Enum.FillDirection.Vertical,
				UDim.new(0, state._config.ItemSpacing.Y)
			)
			uIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Top
			frame2.Parent = scrollingFrame
			local frame3 = Instance.new("Frame")
			frame3.Name = "TitleBar"
			frame3.AutomaticSize = Enum.AutomaticSize.Y
			frame3.Size = UDim2.fromScale(1, 0)
			frame3.BorderSizePixel = 0
			frame3.ClipsDescendants = true
			frame3.Parent = frame
			data.UIPadding(frame3, Vector2.new(state._config.FramePadding.X))
			local uIListLayout_3 = data.UIListLayout(
				frame3,
				Enum.FillDirection.Horizontal,
				UDim.new(0, state._config.ItemInnerSpacing.X)
			)
			uIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center
			data.applyInputBegan(frame3, function(p)
				if p.UserInputType == Enum.UserInputType.Touch and not state2.arguments.NoMove then
					v = state2
					v2 = true
					local position = p.Position
					v3 = Vector2.new(position.X, position.Y) - state2.state.position.value
				end
			end)
			local v13 = state._config.TextSize + (state._config.FramePadding.Y - 1) * 2
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "CollapseButton"
			textButton2.AutomaticSize = Enum.AutomaticSize.None
			textButton2.AnchorPoint = Vector2.new(0, 0.5)
			textButton2.Size = UDim2.fromOffset(v13, v13)
			textButton2.Position = UDim2.fromScale(0, 0.5)
			textButton2.BackgroundTransparency = 1
			textButton2.BorderSizePixel = 0
			textButton2.AutoButtonColor = false
			textButton2.Text = ""
			data.UICorner(textButton2)
			textButton2.Parent = frame3
			data.applyButtonClick(textButton2, function()
				state2.state.isUncollapsed:set(not state2.state.isUncollapsed.value)
			end)
			data.applyInteractionHighlights("Background", textButton2, textButton2, {
				Color = state._config.ButtonColor,
				Transparency = 1,
				HoveredColor = state._config.ButtonHoveredColor,
				HoveredTransparency = state._config.ButtonHoveredTransparency,
				ActiveColor = state._config.ButtonActiveColor,
				ActiveTransparency = state._config.ButtonActiveTransparency
			})
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(math.floor(0.7 * v13), (math.floor(0.7 * v13)))
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Image = data.ICONS.MULTIPLICATION_SIGN
			imageLabel.ImageColor3 = state._config.TextColor
			imageLabel.ImageTransparency = state._config.TextTransparency
			imageLabel.Parent = textButton2
			local textButton3 = Instance.new("TextButton")
			textButton3.Name = "CloseButton"
			textButton3.AutomaticSize = Enum.AutomaticSize.None
			textButton3.AnchorPoint = Vector2.new(1, 0.5)
			textButton3.Size = UDim2.fromOffset(v13, v13)
			textButton3.Position = UDim2.fromScale(1, 0.5)
			textButton3.BackgroundTransparency = 1
			textButton3.BorderSizePixel = 0
			textButton3.Text = ""
			textButton3.AutoButtonColor = false
			textButton3.LayoutOrder = 2
			data.UICorner(textButton3)
			data.applyButtonClick(textButton3, function()
				state2.state.isOpened:set(false)
			end)
			data.applyInteractionHighlights("Background", textButton3, textButton3, {
				Color = state._config.ButtonColor,
				Transparency = 1,
				HoveredColor = state._config.ButtonHoveredColor,
				HoveredTransparency = state._config.ButtonHoveredTransparency,
				ActiveColor = state._config.ButtonActiveColor,
				ActiveTransparency = state._config.ButtonActiveTransparency
			})
			textButton3.Parent = frame3
			local imageLabel2 = Instance.new("ImageLabel")
			imageLabel2.Name = "Icon"
			imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel2.Size = UDim2.fromOffset(math.floor(0.7 * v13), (math.floor(0.7 * v13)))
			imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel2.BackgroundTransparency = 1
			imageLabel2.BorderSizePixel = 0
			imageLabel2.Image = data.ICONS.MULTIPLICATION_SIGN
			imageLabel2.ImageColor3 = state._config.TextColor
			imageLabel2.ImageTransparency = state._config.TextTransparency
			imageLabel2.Parent = textButton3
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Title"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BorderSizePixel = 0
			textLabel.BackgroundTransparency = 1
			textLabel.LayoutOrder = 1
			textLabel.ClipsDescendants = true
			data.UIPadding(textLabel, Vector2.new(0, state._config.FramePadding.Y))
			data.applyTextStyle(textLabel)
			textLabel.TextXAlignment = Enum.TextXAlignment[state._config.WindowTitleAlign.Name]
			local uIFlexItem2 = Instance.new("UIFlexItem")
			uIFlexItem2.FlexMode = Enum.UIFlexMode.Fill
			uIFlexItem2.ItemLineAlignment = Enum.ItemLineAlignment.Center
			uIFlexItem2.Parent = textLabel
			textLabel.Parent = frame3
			local v14 = state._config.TextSize + state._config.FramePadding.X
			local imageButton = Instance.new("ImageButton")
			imageButton.Name = "LeftResizeGrip"
			imageButton.AnchorPoint = Vector2.yAxis
			imageButton.Rotation = 180
			imageButton.Position = UDim2.fromScale(0, 1)
			imageButton.Size = UDim2.fromOffset(v14, v14)
			imageButton.BackgroundTransparency = 1
			imageButton.BorderSizePixel = 0
			imageButton.Image = data.ICONS.BOTTOM_RIGHT_CORNER
			imageButton.ImageColor3 = state._config.ResizeGripColor
			imageButton.ImageTransparency = 1
			imageButton.AutoButtonColor = false
			imageButton.ZIndex = 3
			imageButton.Parent = textButton
			data.applyInteractionHighlights("Image", imageButton, imageButton, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			data.applyButtonDown(imageButton, function()
				if not v10 or v9 ~= state2 then
					state.SetFocusedWindow(state2)
				end

				v5 = true
				top = Enum.TopBottom.Bottom
				left = Enum.LeftRight.Left
				v4 = state2
			end)
			local imageButton2 = Instance.new("ImageButton")
			imageButton2.Name = "RightResizeGrip"
			imageButton2.AnchorPoint = Vector2.one
			imageButton2.Rotation = 90
			imageButton2.Position = UDim2.fromScale(1, 1)
			imageButton2.Size = UDim2.fromOffset(v14, v14)
			imageButton2.BackgroundTransparency = 1
			imageButton2.BorderSizePixel = 0
			imageButton2.Image = data.ICONS.BOTTOM_RIGHT_CORNER
			imageButton2.ImageColor3 = state._config.ResizeGripColor
			imageButton2.ImageTransparency = state._config.ResizeGripTransparency
			imageButton2.AutoButtonColor = false
			imageButton2.ZIndex = 3
			imageButton2.Parent = textButton
			data.applyInteractionHighlights("Image", imageButton2, imageButton2, {
				Color = state._config.ResizeGripColor,
				Transparency = state._config.ResizeGripTransparency,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			data.applyButtonDown(imageButton2, function()
				if not v10 or v9 ~= state2 then
					state.SetFocusedWindow(state2)
				end

				v5 = true
				top = Enum.TopBottom.Bottom
				left = Enum.LeftRight.Right
				v4 = state2
			end)
			local imageButton3 = Instance.new("ImageButton")
			imageButton3.Name = "LeftResizeBorder"
			imageButton3.AnchorPoint = Vector2.new(1, 0.5)
			imageButton3.Position = UDim2.fromScale(0, 0.5)
			imageButton3.Size = UDim2.new(0, state._config.WindowResizePadding.X, 1, 2 * state._config.WindowBorderSize)
			imageButton3.Transparency = 1
			imageButton3.Image = data.ICONS.BORDER
			imageButton3.ResampleMode = Enum.ResamplerMode.Pixelated
			imageButton3.ScaleType = Enum.ScaleType.Slice
			imageButton3.SliceCenter = Rect.new(0, 0, 1, 1)
			imageButton3.ImageRectOffset = Vector2.new(2, 2)
			imageButton3.ImageRectSize = Vector2.new(2, 1)
			imageButton3.ImageTransparency = 1
			imageButton3.AutoButtonColor = false
			imageButton3.ZIndex = 4
			imageButton3.Parent = textButton
			local imageButton4 = Instance.new("ImageButton")
			imageButton4.Name = "RightResizeBorder"
			imageButton4.AnchorPoint = Vector2.new(0, 0.5)
			imageButton4.Position = UDim2.fromScale(1, 0.5)
			imageButton4.Size = UDim2.new(0, state._config.WindowResizePadding.X, 1, 2 * state._config.WindowBorderSize)
			imageButton4.Transparency = 1
			imageButton4.Image = data.ICONS.BORDER
			imageButton4.ResampleMode = Enum.ResamplerMode.Pixelated
			imageButton4.ScaleType = Enum.ScaleType.Slice
			imageButton4.SliceCenter = Rect.new(1, 0, 2, 1)
			imageButton4.ImageRectOffset = Vector2.new(1, 2)
			imageButton4.ImageRectSize = Vector2.new(2, 1)
			imageButton4.ImageTransparency = 1
			imageButton4.AutoButtonColor = false
			imageButton4.ZIndex = 4
			imageButton4.Parent = textButton
			local imageButton5 = Instance.new("ImageButton")
			imageButton5.Name = "TopResizeBorder"
			imageButton5.AnchorPoint = Vector2.new(0.5, 1)
			imageButton5.Position = UDim2.fromScale(0.5, 0)
			imageButton5.Size = UDim2.new(1, 2 * state._config.WindowBorderSize, 0, state._config.WindowResizePadding.Y)
			imageButton5.Transparency = 1
			imageButton5.Image = data.ICONS.BORDER
			imageButton5.ResampleMode = Enum.ResamplerMode.Pixelated
			imageButton5.ScaleType = Enum.ScaleType.Slice
			imageButton5.SliceCenter = Rect.new(0, 0, 1, 1)
			imageButton5.ImageRectOffset = Vector2.new(2, 2)
			imageButton5.ImageRectSize = Vector2.new(1, 2)
			imageButton5.ImageTransparency = 1
			imageButton5.AutoButtonColor = false
			imageButton5.ZIndex = 4
			imageButton5.Parent = textButton
			local imageButton6 = Instance.new("ImageButton")
			imageButton6.Name = "BottomResizeBorder"
			imageButton6.AnchorPoint = Vector2.new(0.5, 0)
			imageButton6.Position = UDim2.fromScale(0.5, 1)
			imageButton6.Size = UDim2.new(1, 2 * state._config.WindowBorderSize, 0, state._config.WindowResizePadding.Y)
			imageButton6.Transparency = 1
			imageButton6.Image = data.ICONS.BORDER
			imageButton6.ResampleMode = Enum.ResamplerMode.Pixelated
			imageButton6.ScaleType = Enum.ScaleType.Slice
			imageButton6.SliceCenter = Rect.new(0, 1, 1, 2)
			imageButton6.ImageRectOffset = Vector2.new(2, 1)
			imageButton6.ImageRectSize = Vector2.new(1, 2)
			imageButton6.ImageTransparency = 1
			imageButton6.AutoButtonColor = false
			imageButton6.ZIndex = 4
			imageButton6.Parent = textButton
			data.applyInteractionHighlights("Image", imageButton3, imageButton3, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			data.applyInteractionHighlights("Image", imageButton4, imageButton4, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			data.applyInteractionHighlights("Image", imageButton5, imageButton5, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			data.applyInteractionHighlights("Image", imageButton6, imageButton6, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})
			local frame4 = Instance.new("Frame")
			frame4.Name = "ResizeBorder"
			frame4.Position = UDim2.fromOffset(
				-state._config.WindowResizePadding.X,
				-state._config.WindowResizePadding.Y
			)
			frame4.Size = UDim2.new(
				1,
				state._config.WindowResizePadding.X * 2,
				1,
				state._config.WindowResizePadding.Y * 2
			)
			frame4.BackgroundTransparency = 1
			frame4.BorderSizePixel = 0
			frame4.Active = false
			frame4.Selectable = false
			frame4.ClipsDescendants = false
			frame4.Parent = textButton
			data.applyMouseEnter(frame4, function()
				if v9 == state2 then
					v6 = true
				end
			end)
			data.applyMouseLeave(frame4, function()
				if v9 == state2 then
					v6 = false
				end
			end)
			data.applyInputBegan(frame4, function(p)
				if p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Keyboard then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end
			end)
			data.applyMouseEnter(textButton, function()
				if v9 == state2 then
					v7 = true
				end
			end)
			data.applyMouseLeave(textButton, function()
				if v9 == state2 then
					v7 = false
				end
			end)
			state2.ChildContainer = scrollingFrame
			return parent
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
		end,
		Update = function(data2)
			local instance = data2.Instance
			local childContainer = data2.ChildContainer
			local windowButton = instance.WindowButton
			local content = windowButton.Content
			local titleBar = content.TitleBar
			local title = titleBar.Title
			local iris_MenuBar = content:FindFirstChild("Iris_MenuBar")
			local leftResizeGrip = windowButton.LeftResizeGrip
			local rightResizeGrip = windowButton.RightResizeGrip
			local leftResizeBorder = windowButton.LeftResizeBorder
			local rightResizeBorder = windowButton.RightResizeBorder
			local topResizeBorder = windowButton.TopResizeBorder
			local bottomResizeBorder = windowButton.BottomResizeBorder

			if data2.arguments.NoResize == true then
				leftResizeGrip.Visible = false
				rightResizeGrip.Visible = false
				leftResizeBorder.Visible = false
				rightResizeBorder.Visible = false
				topResizeBorder.Visible = false
				bottomResizeBorder.Visible = false
			else
				leftResizeGrip.Visible = true
				rightResizeGrip.Visible = true
				leftResizeBorder.Visible = true
				rightResizeBorder.Visible = true
				topResizeBorder.Visible = true
				bottomResizeBorder.Visible = true
			end

			if data2.arguments.NoScrollbar then
				childContainer.ScrollBarThickness = 0
			else
				childContainer.ScrollBarThickness = state._config.ScrollbarSize
			end

			if data2.arguments.NoTitleBar then
				titleBar.Visible = false
			else
				titleBar.Visible = true
			end

			if iris_MenuBar then
				if data2.arguments.NoMenu then
					iris_MenuBar.Visible = false
				else
					iris_MenuBar.Visible = true
				end
			end

			if data2.arguments.NoBackground then
				childContainer.BackgroundTransparency = 1
			else
				childContainer.BackgroundTransparency = state._config.WindowBgTransparency
			end

			if data2.arguments.NoCollapse then
				titleBar.CollapseButton.Visible = false
			else
				titleBar.CollapseButton.Visible = true
			end

			if data2.arguments.NoClose then
				titleBar.CloseButton.Visible = false
			else
				titleBar.CloseButton.Visible = true
			end

			title.Text = data2.arguments.Title or ""
		end,
		UpdateState = function(state2)
			local value = state2.state.size.value
			local value2 = state2.state.position.value
			local value3 = state2.state.isUncollapsed.value
			local value4 = state2.state.isOpened.value
			local value5 = state2.state.scrollDistance.value
			local instance = state2.Instance
			local childContainer = state2.ChildContainer
			local windowButton = instance.WindowButton
			local content = windowButton.Content
			local titleBar = content.TitleBar
			local iris_MenuBar = content:FindFirstChild("Iris_MenuBar")
			local leftResizeGrip = windowButton.LeftResizeGrip
			local rightResizeGrip = windowButton.RightResizeGrip
			local leftResizeBorder = windowButton.LeftResizeBorder
			local rightResizeBorder = windowButton.RightResizeBorder
			local topResizeBorder = windowButton.TopResizeBorder
			local bottomResizeBorder = windowButton.BottomResizeBorder
			windowButton.Size = UDim2.fromOffset(value.X, value.Y)
			windowButton.Position = UDim2.fromOffset(value2.X, value2.Y)

			if value4 then
				if state2.usesScreenGuis then
					instance.Enabled = true
				else
					instance.Visible = true
				end

				windowButton.Visible = true
				state2.lastOpenedTick = state._cycleTick + 1
			else
				if state2.usesScreenGuis then
					instance.Enabled = false
				else
					instance.Visible = false
				end

				windowButton.Visible = false
				state2.lastClosedTick = state._cycleTick + 1
			end

			if value3 then
				titleBar.CollapseButton.Arrow.Image = data.ICONS.DOWN_POINTING_TRIANGLE

				if iris_MenuBar then
					iris_MenuBar.Visible = not state2.arguments.NoMenu
				end

				childContainer.Visible = true

				if state2.arguments.NoResize ~= true then
					leftResizeGrip.Visible = true
					rightResizeGrip.Visible = true
					leftResizeBorder.Visible = true
					rightResizeBorder.Visible = true
					topResizeBorder.Visible = true
					bottomResizeBorder.Visible = true
				end

				windowButton.AutomaticSize = Enum.AutomaticSize.None
				state2.lastUncollapsedTick = state._cycleTick + 1
			else
				local Y = titleBar.AbsoluteSize.Y
				titleBar.CollapseButton.Arrow.Image = data.ICONS.RIGHT_POINTING_TRIANGLE

				if iris_MenuBar then
					iris_MenuBar.Visible = false
				end

				childContainer.Visible = false
				leftResizeGrip.Visible = false
				rightResizeGrip.Visible = false
				leftResizeBorder.Visible = false
				rightResizeBorder.Visible = false
				topResizeBorder.Visible = false
				bottomResizeBorder.Visible = false
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
					if v13 <= state._cycleTick then
						if state2.lastCycleTick ~= -1 then
							childContainer.CanvasPosition = Vector2.new(0, value5)
						end

						state._postCycleCallbacks[v12] = nil
					end
				end
			end
		end,
		ChildAdded = function(p, p2)
			local content = p.Instance.WindowButton.Content

			if p2.type ~= "MenuBar" then
				return p.ChildContainer
			end

			local childContainer = p.ChildContainer
			p2.Instance.ZIndex = childContainer.ZIndex + 1
			p2.Instance.LayoutOrder = childContainer.LayoutOrder - 1
			return content
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
		end
	})
end