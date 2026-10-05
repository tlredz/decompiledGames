require(script.Parent.Parent.Types)
return function(data, data2)
	data.WidgetConstructor("Selectable", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Index = 2,
			NoClick = 3
		},
		Events = {
			selected = {
				Init = function(_) end,
				Get = function(p)
					return p.lastSelectedTick == data._cycleTick
				end
			},
			unselected = {
				Init = function(_) end,
				Get = function(p)
					return p.lastUnselectedTick == data._cycleTick
				end
			},
			active = {
				Init = function(_) end,
				Get = function(p)
					return p.state.index.value == p.arguments.Index
				end
			},
			clicked = data2.EVENTS.click(function(p)
				return p.Instance.SelectableButton
			end),
			rightClicked = data2.EVENTS.rightClick(function(p)
				return p.Instance.SelectableButton
			end),
			doubleClicked = data2.EVENTS.doubleClick(function(p)
				return p.Instance.SelectableButton
			end),
			ctrlClicked = data2.EVENTS.ctrlClick(function(p)
				return p.Instance.SelectableButton
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance.SelectableButton
			end)
		},
		Generate = function(state)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Selectable"
			frame.Size = UDim2.new(
				data._config.ItemWidth,
				UDim.new(0, data._config.TextSize + 2 * data._config.FramePadding.Y - data._config.ItemSpacing.Y)
			)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = 0
			frame.LayoutOrder = state.ZIndex
			local textButton = Instance.new("TextButton")
			textButton.Name = "SelectableButton"
			textButton.Size = UDim2.new(1, 0, 0, data._config.TextSize + 2 * data._config.FramePadding.Y)
			textButton.Position = UDim2.fromOffset(0, -bit32.rshift(data._config.ItemSpacing.Y, 1))
			textButton.BackgroundColor3 = data._config.HeaderColor
			textButton.ClipsDescendants = true
			data2.applyFrameStyle(textButton)
			data2.applyTextStyle(textButton)
			data2.UISizeConstraint(textButton, Vector2.xAxis)
			state.ButtonColors = {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			}
			data2.applyInteractionHighlights("Background", textButton, textButton, state.ButtonColors)
			data2.applyButtonClick(textButton, function()
				warn("whats ur problem bud", state.arguments.NoClick, state.arguments.Index, state.state.index.Value)

				if state.arguments.NoClick ~= true then
					if type(state.state.index.value) == "boolean" then
						state.state.index:set(not state.state.index.value)
					else
						state.state.index:set(state.arguments.Index)
					end
				end
			end)
			textButton.Parent = frame
			return frame
		end,
		Update = function(p)
			p.Instance.SelectableButton.Text = tostring(p.providedArguments.Text) or "Selectable"
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				if p.arguments.Index ~= nil then
					error("A shared state index is required for Iris.Selectables() with an Index argument.", 5)
				end

				p.state.index = data._widgetState(p, "index", false)
			end
		end,
		UpdateState = function(state)
			local selectableButton = state.Instance.SelectableButton

			if state.state.index.value == (state.arguments.Index or true) then
				state.ButtonColors.Transparency = data._config.HeaderTransparency
				selectableButton.BackgroundTransparency = data._config.HeaderTransparency
				state.lastSelectedTick = data._cycleTick + 1
			else
				state.ButtonColors.Transparency = 1
				selectableButton.BackgroundTransparency = 1
				state.lastUnselectedTick = data._cycleTick + 1
			end
		end
	})
	local flag = false
	local _cycleTick = -1
	local v = nil

	local function UpdateChildContainerTransform(p)
		local previewContainer = p.Instance.PreviewContainer
		local childContainer = p.ChildContainer
		childContainer.Size = UDim2.fromOffset(previewContainer.AbsoluteSize.X * 2, 300)
		local v2 = previewContainer.AbsolutePosition - data2.GuiOffset
		local absoluteSize = previewContainer.AbsoluteSize
		local absoluteSize2 = childContainer.AbsoluteSize
		local popupBorderSize = data._config.PopupBorderSize
		local absoluteSize3 = childContainer.Parent.AbsoluteSize
		local X = v2.X
		local zero = Vector2.zero
		local v3

		if v2.Y + absoluteSize2.Y > absoluteSize3.Y then
			v3 = v2.Y - popupBorderSize
			zero = Vector2.yAxis
		else
			v3 = v2.Y + absoluteSize.Y + popupBorderSize
		end

		childContainer.AnchorPoint = zero
		childContainer.Position = UDim2.fromOffset(X, v3)
	end

	data2.registerEvent("InputBegan", function(p)
		if not data._started or p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.MouseButton2 and p.UserInputType ~= Enum.UserInputType.Touch or (flag == false or not v) then
			return
		end

		if _cycleTick == data._cycleTick then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local instance = v.Instance

		if instance:FindFirstChild("PreviewContainer") then
			local previewContainer = instance.PreviewContainer
			local childContainer = v.ChildContainer
			local v2 = previewContainer.AbsolutePosition - data2.GuiOffset
			local v3 = previewContainer.AbsolutePosition - data2.GuiOffset + previewContainer.AbsoluteSize + Vector2.new(
				300,
				300
			)

			if data2.isPosInsideRect(mouseLocation, v2, v3) then
				return
			end

			local v4 = childContainer.AbsolutePosition - data2.GuiOffset
			local v5 = childContainer.AbsolutePosition - data2.GuiOffset + childContainer.AbsoluteSize + Vector2.new(
				300,
				300
			)

			if data2.isPosInsideRect(mouseLocation, v4, v5) then
				return
			end

			v.state.isOpened:set(false)
		else
			v.Instance:Destroy()
			data2.discardState(v)
		end
	end)
	data.WidgetConstructor("Combo", {
		hasState = true,
		hasChildren = true,
		Args = {
			Text = 1,
			NoButton = 2,
			NoPreview = 3
		},
		Events = {
			opened = {
				Init = function(_) end,
				Get = function(p)
					return p.lastOpenedTick == data._cycleTick
				end
			},
			closed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastClosedTick == data._cycleTick
				end
			},
			clicked = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local v2 = data._config.TextSize + 2 * data._config.FramePadding.Y
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Combo"
			frame.Size = UDim2.fromOffset(100, 0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = state.ZIndex
			local uIListLayout = data2.UIListLayout(
				frame,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local textButton = Instance.new("TextButton")
			textButton.Name = "PreviewContainer"
			textButton.Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 0))
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.BackgroundTransparency = 1
			textButton.Text = ""
			textButton.ZIndex = state.ZIndex + 2
			textButton.AutoButtonColor = false
			data2.applyFrameStyle(textButton, true)
			data2.UIListLayout(textButton, Enum.FillDirection.Horizontal, UDim.new(0, 0))
			data2.UISizeConstraint(textButton, Vector2.new(v2 + 1))
			textButton.Parent = frame
			state.PreviewContainer = textButton
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "PreviewLabel"
			textLabel.Size = UDim2.new(UDim.new(1, 0), data._config.ContentHeight)
			textLabel.AutomaticSize = Enum.AutomaticSize.Y
			textLabel.BackgroundColor3 = data._config.FrameBgColor
			textLabel.BackgroundTransparency = data._config.FrameBgTransparency
			textLabel.BorderSizePixel = 0
			textLabel.ClipsDescendants = true
			data2.applyTextStyle(textLabel)
			data2.UIPadding(textLabel, data._config.FramePadding)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "DropdownButton"
			textLabel2.Size = UDim2.new(
				0,
				v2,
				data._config.ContentHeight.Scale,
				(math.max(data._config.ContentHeight.Offset, v2))
			)
			textLabel2.BorderSizePixel = 0
			textLabel2.BackgroundColor3 = data._config.ButtonColor
			textLabel2.BackgroundTransparency = data._config.ButtonTransparency
			textLabel2.Text = ""
			local v3 = v2 - math.round(v2 * 0.2) * 2
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Dropdown"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(v3, v3)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.Parent = textLabel2
			textLabel2.Parent = textButton
			data2.applyInteractionHighlightsWithMultiHighlightee("Background", textButton, {
				{
					textLabel,
					{
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					}
				},
				{
					textLabel2,
					{
						Color = data._config.ButtonColor,
						Transparency = data._config.ButtonTransparency,
						HoveredColor = data._config.ButtonHoveredColor,
						HoveredTransparency = data._config.ButtonHoveredTransparency,
						ActiveColor = data._config.ButtonHoveredColor,
						ActiveTransparency = data._config.ButtonHoveredTransparency
					}
				}
			})
			data2.applyButtonClick(textButton, function()
				if flag and v ~= state then
					return
				end

				state.state.isOpened:set(not state.state.isOpened.value)
			end)
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "TextLabel"
			textLabel3.Size = UDim2.fromOffset(0, v2)
			textLabel3.AutomaticSize = Enum.AutomaticSize.X
			textLabel3.BackgroundTransparency = 1
			textLabel3.BorderSizePixel = 0
			data2.applyTextStyle(textLabel3)
			textLabel3.Parent = frame
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "ComboContainer"
			scrollingFrame.AutomaticSize = Enum.AutomaticSize.None
			scrollingFrame.BackgroundColor3 = data._config.PopupBgColor
			scrollingFrame.BackgroundTransparency = data._config.PopupBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.Size = UDim2.new(0, 0, 0.3, 0)
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			scrollingFrame.ScrollBarThickness = data._config.ScrollbarSize
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.ClipsDescendants = true
			data2.UIStroke(
				scrollingFrame,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(scrollingFrame, Vector2.new(2, data._config.WindowPadding.Y))
			data2.UISizeConstraint(scrollingFrame, Vector2.new(100))
			local uIListLayout_2 = data2.UIListLayout(
				scrollingFrame,
				Enum.FillDirection.Vertical,
				UDim.new(0, data._config.ItemSpacing.Y)
			)
			uIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Top
			scrollingFrame.Parent = data._rootInstance and data._rootInstance:WaitForChild("PopupScreenGui")
			state.ChildContainer = scrollingFrame
			return frame
		end,
		Update = function(p)
			local instance = p.Instance
			local previewContainer = instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdownButton = previewContainer.DropdownButton
			instance.TextLabel.Text = tostring(p.arguments.Text) or "Combo"

			if p.arguments.NoButton then
				dropdownButton.Visible = false
				previewLabel.Size = UDim2.new(UDim.new(1, 0), previewLabel.Size.Height)
			else
				dropdownButton.Visible = true
				local v2 = data._config.TextSize + 2 * data._config.FramePadding.Y
				previewLabel.Size = UDim2.new(UDim.new(1, -v2), previewLabel.Size.Height)
			end

			if p.arguments.NoPreview then
				previewLabel.Visible = false
				previewContainer.Size = UDim2.new(0, 0, 0, 0)
				previewContainer.AutomaticSize = Enum.AutomaticSize.XY
			else
				previewLabel.Visible = true
				previewContainer.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
				previewContainer.AutomaticSize = Enum.AutomaticSize.Y
			end
		end,
		ChildAdded = function(p, _)
			UpdateChildContainerTransform(p)
			return p.ChildContainer
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", "No Selection")
			end

			p.state.index:onChange(function()
				if p.state.isOpened.value then
					p.state.isOpened:set(false)
				end
			end)

			if p.state.isOpened == nil then
				p.state.isOpened = data._widgetState(p, "isOpened", false)
			end
		end,
		UpdateState = function(state)
			local instance = state.Instance
			local childContainer = state.ChildContainer
			childContainer.Size = UDim2.new(0, 0, 0.3, 0)
			local previewContainer = instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdown = previewContainer.DropdownButton.Dropdown

			if state.state.isOpened.value then
				flag = true
				v = state
				_cycleTick = data._cycleTick
				state.lastOpenedTick = data._cycleTick + 1
				dropdown.Image = data2.ICONS.RIGHT_POINTING_TRIANGLE
				childContainer.Visible = true
				UpdateChildContainerTransform(state)
			else
				if flag then
					flag = false
					v = nil
					state.lastClosedTick = data._cycleTick + 1
				end

				dropdown.Image = data2.ICONS.DOWN_POINTING_TRIANGLE
				childContainer.Visible = false
			end

			local value = state.state.index.value
			local text

			if typeof(value) == "EnumItem" then
				text = value.Name
			else
				text = tostring(value)
			end

			previewLabel.Text = text
		end,
		Discard = function(data3)
			data3.Instance:Destroy()

			if data3.PreviewContainer then
				data3.PreviewContainer:Destroy()
			end

			if data3.ChildContainer then
				data3.ChildContainer:Destroy()
			end

			data2.discardState(data3)
		end
	})
end