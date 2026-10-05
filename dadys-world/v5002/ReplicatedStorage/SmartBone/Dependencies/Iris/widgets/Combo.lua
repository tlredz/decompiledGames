require(script.Parent.Parent.Types)
return function(data, data2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onSelectionChange(p)
		if type(p.state.index.value) == "boolean" then
			p.state.index:set(not p.state.index.value)
		else
			p.state.index:set(p.arguments.Index)
		end
	end

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
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, data._config.TextSize))
			frame.AutomaticSize = Enum.AutomaticSize.None
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = state.ZIndex
			frame.LayoutOrder = state.ZIndex
			local textButton = Instance.new("TextButton")
			textButton.Name = "SelectableButton"
			textButton.Size = UDim2.new(1, 0, 1, data._config.ItemSpacing.Y - 1)
			textButton.Position = UDim2.fromOffset(0, -bit32.rshift(data._config.ItemSpacing.Y, 1))
			textButton.BackgroundColor3 = data._config.HeaderColor
			textButton.ZIndex = state.ZIndex + 1
			textButton.LayoutOrder = state.ZIndex + 1
			data2.applyFrameStyle(textButton)
			data2.applyTextStyle(textButton)
			state.ButtonColors = {
				ButtonColor = data._config.HeaderColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = data._config.HeaderHoveredColor,
				ButtonHoveredTransparency = data._config.HeaderHoveredTransparency,
				ButtonActiveColor = data._config.HeaderActiveColor,
				ButtonActiveTransparency = data._config.HeaderActiveTransparency
			}
			data2.applyInteractionHighlights(textButton, textButton, state.ButtonColors)
			textButton.MouseButton1Click:Connect(function()
				if state.arguments.NoClick ~= true then
					onSelectionChange(state) -- equivalent call inferred; original call site unknown
				end
			end)
			textButton.Parent = frame
			return frame
		end,
		Update = function(p)
			p.Instance.SelectableButton.Text = p.arguments.Text or "Selectable"
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				if p.arguments.Index ~= nil then
					error("a shared state index is required for Selectables with an Index argument", 5)
				end

				p.state.index = data._widgetState(p, "index", false)
			end
		end,
		UpdateState = function(state)
			local selectableButton = state.Instance.SelectableButton

			if state.state.index.value == (state.arguments.Index or true) then
				state.ButtonColors.ButtonTransparency = data._config.HeaderTransparency
				selectableButton.BackgroundTransparency = data._config.HeaderTransparency
				state.lastSelectedTick = data._cycleTick + 1
			else
				state.ButtonColors.ButtonTransparency = 1
				selectableButton.BackgroundTransparency = 1
				state.lastUnselectedTick = data._cycleTick + 1
			end
		end
	})
	local flag = false
	local _cycleTick = -1
	local v = nil

	local function UpdateChildContainerTransform(data3)
		local previewContainer = data3.Instance.PreviewContainer
		local previewLabel = previewContainer.PreviewLabel
		local childContainer = data3.ChildContainer
		local v2 = data._config.TextSize + 2 * data._config.FramePadding.Y
		local popupBorderSize = data._config.PopupBorderSize
		local v3 = v2 * math.min(data3.ComboChildrenHeight, 8) - popupBorderSize * 2 + 3 * data._config.FramePadding.Y
		local uDim = UDim.new(0, previewContainer.AbsoluteSize.X - popupBorderSize * 2)
		childContainer.Size = UDim2.new(uDim, UDim.new(0, v3))
		local absoluteSize = childContainer.Parent.AbsoluteSize

		if previewLabel.AbsolutePosition.Y + v2 + v3 > absoluteSize.Y then
			childContainer.Position = UDim2.new(
				0,
				previewLabel.AbsolutePosition.X + popupBorderSize,
				0,
				previewLabel.AbsolutePosition.Y - popupBorderSize - v3
			)
		else
			childContainer.Position = UDim2.new(
				0,
				previewLabel.AbsolutePosition.X + popupBorderSize,
				0,
				previewLabel.AbsolutePosition.Y + v2 + popupBorderSize
			)
		end
	end

	data2.UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.Touch or flag == false or _cycleTick == data._cycleTick then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local childContainer = v.ChildContainer
		local v2 = childContainer.AbsolutePosition - Vector2.new(0, v.LabelHeight)
		local v3 = childContainer.AbsolutePosition + childContainer.AbsoluteSize

		if not data2.isPosInsideRect(mouseLocation, v2, v3) then
			v.state.isOpened:set(false)
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
			state.ComboChildrenHeight = 0
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Combo"
			frame.Size = UDim2.fromScale(1, 0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = state.ZIndex
			frame.LayoutOrder = state.ZIndex
			data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.Y + 1))
			local textButton = Instance.new("TextButton")
			textButton.Name = "PreviewContainer"
			textButton.Size = UDim2.new(data._config.ContentWidth, UDim.new(0, 0))
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.BackgroundTransparency = 1
			textButton.Text = ""
			textButton.ZIndex = state.ZIndex + 2
			textButton.LayoutOrder = state.ZIndex + 2
			textButton.AutoButtonColor = false
			data2.applyFrameStyle(textButton, true, true)
			data2.UIListLayout(textButton, Enum.FillDirection.Horizontal, UDim.new(0, 0))
			textButton.Parent = frame
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "PreviewLabel"
			textLabel.Size = UDim2.new(1, 0, 0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.Y
			textLabel.BackgroundColor3 = data._config.FrameBgColor
			textLabel.BackgroundTransparency = data._config.FrameBgTransparency
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = state.ZIndex + 3
			textLabel.LayoutOrder = state.ZIndex + 3
			data2.applyTextStyle(textLabel)
			data2.UIPadding(textLabel, data._config.FramePadding)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "DropdownButton"
			textLabel2.Size = UDim2.new(0, v2, 0, v2)
			textLabel2.BorderSizePixel = 0
			textLabel2.BackgroundColor3 = data._config.ButtonColor
			textLabel2.BackgroundTransparency = data._config.ButtonTransparency
			textLabel2.Text = ""
			textLabel2.ZIndex = state.ZIndex + 4
			textLabel2.LayoutOrder = state.ZIndex + 4
			local v3 = math.round(v2 * 0.2)
			local v4 = v2 - v3 * 2
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Dropdown"
			imageLabel.Size = UDim2.fromOffset(v4, v4)
			imageLabel.Position = UDim2.fromOffset(v3, v3)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.ZIndex = state.ZIndex + 5
			imageLabel.LayoutOrder = state.ZIndex + 5
			imageLabel.Parent = textLabel2
			textLabel2.Parent = textButton
			data2.applyInteractionHighlightsWithMultiHighlightee(textButton, {
				{
					textLabel,
					{
						ButtonColor = data._config.FrameBgColor,
						ButtonTransparency = data._config.FrameBgTransparency,
						ButtonHoveredColor = data._config.FrameBgHoveredColor,
						ButtonHoveredTransparency = data._config.FrameBgHoveredTransparency,
						ButtonActiveColor = data._config.FrameBgActiveColor,
						ButtonActiveTransparency = data._config.FrameBgActiveTransparency
					}
				},
				{
					textLabel2,
					{
						ButtonColor = data._config.ButtonColor,
						ButtonTransparency = data._config.ButtonTransparency,
						ButtonHoveredColor = data._config.ButtonHoveredColor,
						ButtonHoveredTransparency = data._config.ButtonHoveredTransparency,
						ButtonActiveColor = data._config.ButtonHoveredColor,
						ButtonActiveTransparency = data._config.ButtonHoveredColor
					}
				}
			})
			textButton.InputBegan:Connect(function(input)
				if flag and v ~= state then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					state.state.isOpened:set(not state.state.isOpened.value)
				end
			end)
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "TextLabel"
			textLabel3.Size = UDim2.fromOffset(0, v2)
			textLabel3.AutomaticSize = Enum.AutomaticSize.X
			textLabel3.BackgroundTransparency = 1
			textLabel3.BorderSizePixel = 0
			textLabel3.ZIndex = state.ZIndex + 5
			textLabel3.LayoutOrder = state.ZIndex + 5
			data2.applyTextStyle(textLabel3)
			textLabel3.Parent = frame
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "ChildContainer"
			scrollingFrame.BackgroundColor3 = data._config.WindowBgColor
			scrollingFrame.BackgroundTransparency = data._config.WindowBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			scrollingFrame.ScrollBarThickness = data._config.ScrollbarSize
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.ZIndex = state.ZIndex + 6
			scrollingFrame.LayoutOrder = state.ZIndex + 6
			scrollingFrame.ClipsDescendants = true
			data2.UIStroke(
				scrollingFrame,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(scrollingFrame, Vector2.new(2, 2 * data._config.FramePadding.Y))
			local uIListLayout = data2.UIListLayout(
				scrollingFrame,
				Enum.FillDirection.Vertical,
				UDim.new(0, data._config.ItemSpacing.Y)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			scrollingFrame.Parent = data._rootInstance and data._rootInstance:WaitForChild("PopupScreenGui")
			state.ChildContainer = scrollingFrame
			return frame
		end,
		Update = function(p)
			local instance = p.Instance
			local previewContainer = instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdownButton = previewContainer.DropdownButton
			instance.TextLabel.Text = p.arguments.Text or "Combo"

			if p.arguments.NoButton then
				dropdownButton.Visible = false
				previewLabel.Size = UDim2.new(1, 0, 0, 0)
			else
				dropdownButton.Visible = true
				local v2 = data._config.TextSize + 2 * data._config.FramePadding.Y
				previewLabel.Size = UDim2.new(1, -v2, 0, 0)
			end

			if p.arguments.NoPreview then
				previewLabel.Visible = false
				previewContainer.Size = UDim2.new(0, 0, 0, 0)
				previewContainer.AutomaticSize = Enum.AutomaticSize.X
			else
				previewLabel.Visible = true
				previewContainer.Size = UDim2.new(data._config.ContentWidth, UDim.new(0, 0))
				previewContainer.AutomaticSize = Enum.AutomaticSize.Y
			end
		end,
		ChildAdded = function(state, p)
			if p.type == "Selectable" then
				state.ComboChildrenHeight += 1
			else
				state.ComboChildrenHeight += 10
			end

			UpdateChildContainerTransform(state)
			return state.ChildContainer
		end,
		ChildDiscarded = function(p, p2)
			if p2.type == "Selectable" then
				p.ComboChildrenHeight -= 1
			else
				p.ComboChildrenHeight -= 10
			end
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
			local previewContainer = state.Instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdown = previewContainer.DropdownButton.Dropdown
			local childContainer = state.ChildContainer

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
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end