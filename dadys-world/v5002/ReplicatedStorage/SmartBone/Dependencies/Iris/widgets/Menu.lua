require(script.Parent.Parent.Types)
return function(data, data2)
	local v = false
	local v2 = nil
	local states = {}

	local function EmptyMenuStack(p: number?)
		for i = #states, p and p + 1 or 1, -1 do
			local v3 = states[i]
			v3.state.isOpened:set(false)
			v3.Instance.BackgroundColor3 = data._config.HeaderColor
			v3.Instance.BackgroundTransparency = 1
			table.remove(states, i)
		end

		if #states == 0 then
			v = false
			v2 = nil
		end
	end

	local function UpdateChildContainerTransform(data3)
		local v3 = data3.parentWidget.type == "Menu"
		local instance = data3.Instance
		local childContainer = data3.ChildContainer
		childContainer.Size = UDim2.fromOffset(
			math.max(childContainer.AbsoluteSize.X, instance.AbsoluteSize.X),
			(math.max(childContainer.AbsoluteSize.Y, instance.AbsoluteSize.Y))
		)

		if childContainer.Parent == nil then
			return
		end

		local absolutePosition = instance.AbsolutePosition
		local absoluteSize = instance.AbsoluteSize
		local absoluteSize2 = childContainer.AbsoluteSize
		local popupBorderSize = data._config.PopupBorderSize
		local absoluteSize3 = childContainer.Parent.AbsoluteSize
		local v4 = absolutePosition.X + popupBorderSize

		if data3.parentWidget.type == "Menu" then
			if absolutePosition.X + absoluteSize2.X > absoluteSize3.X then
				v4 = absolutePosition.X - popupBorderSize - (not v3 and 0 or absoluteSize2.X or 0)
			else
				v4 = absolutePosition.X + popupBorderSize + (not v3 and 0 or absoluteSize.X or 0)
			end
		end

		local v5

		if absolutePosition.Y + absoluteSize2.Y > absoluteSize3.Y then
			v5 = absolutePosition.Y - popupBorderSize - absoluteSize2.Y + (v3 and absoluteSize.Y or 0)
		else
			v5 = absolutePosition.Y + popupBorderSize + (v3 and 0 or absoluteSize.Y)
		end

		childContainer.Position = UDim2.fromOffset(v4, v5)
	end

	data2.UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 or v == false or v2 == nil then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local v3 = false

		for _, v4 in states do
			for _, v6 in { v4.ChildContainer, v4.Instance } do
				local absolutePosition = v6.AbsolutePosition
				local v7 = absolutePosition + v6.AbsoluteSize

				if not data2.isPosInsideRect(mouseLocation, absolutePosition, v7) then
					continue
				end

				v3 = true
				break
			end
		end

		if not v3 then
			EmptyMenuStack()
		end
	end)
	data.WidgetConstructor("MenuBar", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(p)
			local frame = Instance.new("Frame")
			frame.Name = "MenuBar"
			frame.Size = UDim2.fromScale(1, 0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundColor3 = data._config.MenubarBgColor
			frame.BackgroundTransparency = data._config.MenubarBgTransparency
			frame.BorderSizePixel = 0
			frame.ZIndex = p.ZIndex
			frame.LayoutOrder = p.ZIndex
			frame.ClipsDescendants = true
			data2.UIPadding(frame, Vector2.new(data._config.ItemSpacing.X, 2))
			local uIListLayout = data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new())
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			return frame
		end,
		Update = function(p)
			local parentWidget = p.parentWidget

			if parentWidget.type == "Window" then
				local windowButton = parentWidget.Instance and parentWidget.Instance:FindFirstChild("WindowButton")

				if windowButton then
					p.Instance.Parent = windowButton
					local v3 = #data._postCycleCallbacks + 1
					local v4 = data._cycleTick + 1

					data._postCycleCallbacks[v3] = function()
						if data._cycleTick == v4 then
							data._widgets.Window.Update(parentWidget)
							data._postCycleCallbacks[v3] = nil
						end
					end
				end
			else
				if parentWidget.type == "Root" then
					return
				end

				error("The MenuBar was not created directly under a window or root.")
			end
		end,
		ChildAdded = function(p)
			return p.Instance
		end,
		Discard = function(p)
			local parentWidget = p.parentWidget
			p.Instance:Destroy()
			data._widgets.Window.Update(parentWidget)
		end
	})
	data.WidgetConstructor("Menu", {
		hasState = true,
		hasChildren = true,
		Args = {
			Text = 1
		},
		Events = {
			clicked = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
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
			}
		},
		Generate = function(state)
			state.ButtonColors = {
				ButtonColor = data._config.HeaderColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = data._config.HeaderHoveredColor,
				ButtonHoveredTransparency = data._config.HeaderHoveredTransparency,
				ButtonActiveColor = data._config.HeaderHoveredColor,
				ButtonActiveTransparency = data._config.HeaderHoveredTransparency
			}
			local textButton

			if state.parentWidget.type == "Menu" then
				textButton = Instance.new("TextButton")
				textButton.Name = "Menu"
				textButton.BackgroundColor3 = data._config.HeaderColor
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.Size = UDim2.fromScale(1, 0)
				textButton.Text = ""
				textButton.AutomaticSize = Enum.AutomaticSize.Y
				textButton.ZIndex = state.ZIndex
				textButton.LayoutOrder = state.ZIndex
				textButton.AutoButtonColor = false
				local uIPadding = data2.UIPadding(textButton, data._config.FramePadding)
				uIPadding.PaddingTop -= UDim.new(0, 1)
				local uIListLayout = data2.UIListLayout(
					textButton,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.AnchorPoint = Vector2.new(0, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.ZIndex = state.ZIndex + 2
				textLabel.LayoutOrder = state.ZIndex + 2
				textLabel.AutomaticSize = Enum.AutomaticSize.XY
				data2.applyTextStyle(textLabel)
				textLabel.Parent = textButton
				local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
				local v4 = v3 - math.round(v3 * 0.2) * 2
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "Icon"
				imageLabel.Size = UDim2.fromOffset(v4, v4)
				imageLabel.BackgroundTransparency = 1
				imageLabel.BorderSizePixel = 0
				imageLabel.ImageColor3 = data._config.TextColor
				imageLabel.ImageTransparency = data._config.TextTransparency
				imageLabel.Image = data2.ICONS.RIGHT_POINTING_TRIANGLE
				imageLabel.ZIndex = state.ZIndex + 3
				imageLabel.LayoutOrder = state.ZIndex + 3
				imageLabel.Parent = textButton
			else
				textButton = Instance.new("TextButton")
				textButton.Name = "Menu"
				textButton.Size = UDim2.fromScale(0, 0)
				textButton.AutomaticSize = Enum.AutomaticSize.XY
				textButton.BackgroundColor3 = data._config.HeaderColor
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.Text = ""
				textButton.LayoutOrder = state.ZIndex
				textButton.ZIndex = state.ZIndex
				textButton.AutoButtonColor = false
				textButton.ClipsDescendants = true
				data2.applyTextStyle(textButton)
				data2.UIPadding(textButton, Vector2.new(data._config.ItemSpacing.X, data._config.FramePadding.Y))
			end

			data2.applyInteractionHighlights(textButton, textButton, state.ButtonColors)
			textButton.MouseButton1Click:Connect(function()
				local v3 = not (#states <= 1) or not state.state.isOpened.value
				state.state.isOpened:set(v3)
				v = v3
				v2 = v3 and state or nil

				if #states <= 1 then
					if v3 then
						table.insert(states, state)
					else
						table.remove(states)
					end
				end
			end)
			textButton.MouseEnter:Connect(function()
				if v and v2 and v2 ~= state then
					local parentWidget = state.parentWidget
					EmptyMenuStack(table.find(states, parentWidget))
					state.state.isOpened:set(true)
					v2 = state
					v = true
					table.insert(states, state)
				end
			end)
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "ChildContainer"
			scrollingFrame.BackgroundColor3 = data._config.WindowBgColor
			scrollingFrame.BackgroundTransparency = data._config.WindowBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.Size = UDim2.fromOffset(0, 0)
			scrollingFrame.AutomaticSize = Enum.AutomaticSize.XY
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			scrollingFrame.ScrollBarThickness = data._config.ScrollbarSize
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.ZIndex = state.ZIndex + 6
			scrollingFrame.LayoutOrder = state.ZIndex + 6
			scrollingFrame.ClipsDescendants = true
			local uIListLayout_2 = data2.UIListLayout(scrollingFrame, Enum.FillDirection.Vertical, UDim.new(0, 1))
			uIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Top
			scrollingFrame.Parent = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			state.ChildContainer = scrollingFrame
			data2.UIStroke(
				scrollingFrame,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(scrollingFrame, Vector2.new(2, data._config.WindowPadding.Y - data._config.ItemSpacing.Y))
			return textButton
		end,
		Update = function(data3)
			local instance = data3.Instance

			if data3.parentWidget.type == "Menu" then
				instance = instance.TextLabel
			end

			instance.Text = data3.arguments.Text or "Menu"
		end,
		ChildAdded = function(p, _)
			UpdateChildContainerTransform(p)
			return p.ChildContainer
		end,
		ChildDiscarded = function(p, _)
			UpdateChildContainerTransform(p)
		end,
		GenerateState = function(p)
			if p.state.isOpened == nil then
				p.state.isOpened = data._widgetState(p, "isOpened", false)
			end
		end,
		UpdateState = function(state)
			local childContainer = state.ChildContainer

			if state.state.isOpened.value then
				state.lastOpenedTick = data._cycleTick + 1
				state.ButtonColors.ButtonTransparency = data._config.HeaderTransparency
				childContainer.Visible = true
				UpdateChildContainerTransform(state)
			else
				state.lastClosedTick = data._cycleTick + 1
				state.ButtonColors.ButtonTransparency = 1
				childContainer.Visible = false
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
	data.WidgetConstructor("MenuItem", {
		hasState = false,
		hasChildren = false,
		Args = {
			Text = 1,
			KeyCode = 2,
			ModifierKey = 3
		},
		Events = {
			clicked = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(p)
			local textButton = Instance.new("TextButton")
			textButton.Name = "MenuItem"
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Size = UDim2.fromScale(1, 0)
			textButton.Text = ""
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.ZIndex = p.ZIndex
			textButton.LayoutOrder = p.ZIndex
			textButton.AutoButtonColor = false
			local uIPadding = data2.UIPadding(textButton, data._config.FramePadding)
			uIPadding.PaddingTop -= UDim.new(0, 1)
			data2.UIListLayout(textButton, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.X))
			data2.applyInteractionHighlights(textButton, textButton, {
				ButtonColor = data._config.HeaderColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = data._config.HeaderHoveredColor,
				ButtonHoveredTransparency = data._config.HeaderHoveredTransparency,
				ButtonActiveColor = data._config.HeaderHoveredColor,
				ButtonActiveTransparency = data._config.HeaderHoveredTransparency
			})
			textButton.MouseButton1Click:Connect(function()
				EmptyMenuStack()
			end)
			textButton.MouseEnter:Connect(function()
				local parentWidget = p.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AnchorPoint = Vector2.new(0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = p.ZIndex + 2
			textLabel.LayoutOrder = p.ZIndex + 2
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Shortcut"
			textLabel2.AnchorPoint = Vector2.new(0, 0)
			textLabel2.BackgroundTransparency = 1
			textLabel2.BorderSizePixel = 0
			textLabel2.ZIndex = p.ZIndex + 3
			textLabel2.LayoutOrder = p.ZIndex + 3
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			data2.applyTextStyle(textLabel2)
			textLabel2.Text = ""
			textLabel2.TextColor3 = data._config.TextDisabledColor
			textLabel2.TextTransparency = data._config.TextDisabledTransparency
			textLabel2.Parent = textButton
			return textButton
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local shortcut = instance.Shortcut
			textLabel.Text = p.arguments.Text

			if p.arguments.KeyCode then
				shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})
	data.WidgetConstructor("MenuToggle", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			KeyCode = 2,
			ModifierKey = 3
		},
		Events = {
			checked = {
				Init = function(_) end,
				Get = function(p)
					return p.lastCheckedTick == data._cycleTick
				end
			},
			unchecked = {
				Init = function(_) end,
				Get = function(p)
					return p.lastUncheckedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(data3)
			local textButton = Instance.new("TextButton")
			textButton.Name = "MenuItem"
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Size = UDim2.fromScale(1, 0)
			textButton.Text = ""
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.ZIndex = data3.ZIndex
			textButton.LayoutOrder = data3.ZIndex
			textButton.AutoButtonColor = false
			local uIPadding = data2.UIPadding(textButton, data._config.FramePadding)
			uIPadding.PaddingTop -= UDim.new(0, 1)
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyInteractionHighlights(textButton, textButton, {
				ButtonColor = data._config.HeaderColor,
				ButtonTransparency = 1,
				ButtonHoveredColor = data._config.HeaderHoveredColor,
				ButtonHoveredTransparency = data._config.HeaderHoveredTransparency,
				ButtonActiveColor = data._config.HeaderHoveredColor,
				ButtonActiveTransparency = data._config.HeaderHoveredTransparency
			})
			textButton.MouseButton1Click:Connect(function()
				local value = data3.state.isChecked.value
				data3.state.isChecked:set(not value)
				EmptyMenuStack()
			end)
			textButton.MouseEnter:Connect(function()
				local parentWidget = data3.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AnchorPoint = Vector2.new(0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = data3.ZIndex + 2
			textLabel.LayoutOrder = data3.ZIndex + 2
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Shortcut"
			textLabel2.AnchorPoint = Vector2.new(0, 0)
			textLabel2.BackgroundTransparency = 1
			textLabel2.BorderSizePixel = 0
			textLabel2.ZIndex = data3.ZIndex + 3
			textLabel2.LayoutOrder = data3.ZIndex + 3
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			data2.applyTextStyle(textLabel2)
			textLabel2.Text = ""
			textLabel2.TextColor3 = data._config.TextDisabledColor
			textLabel2.TextTransparency = data._config.TextDisabledTransparency
			textLabel2.Parent = textButton
			local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
			local v4 = v3 - math.round(v3 * 0.2) * 2
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Icon"
			imageLabel.Size = UDim2.fromOffset(v4, v4)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.Image = data2.ICONS.CHECK_MARK
			imageLabel.ZIndex = data3.ZIndex + 4
			imageLabel.LayoutOrder = data3.ZIndex + 4
			imageLabel.Parent = textButton
			return textButton
		end,
		GenerateState = function(p)
			if p.state.isChecked == nil then
				p.state.isChecked = data._widgetState(p, "isChecked", false)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local shortcut = instance.Shortcut
			textLabel.Text = p.arguments.Text

			if p.arguments.KeyCode then
				shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
			end
		end,
		UpdateState = function(state)
			local icon = state.Instance.Icon

			if state.state.isChecked.value then
				icon.Image = data2.ICONS.CHECK_MARK
				state.lastCheckedTick = data._cycleTick + 1
			else
				icon.Image = ""
				state.lastUncheckedTick = data._cycleTick + 1
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end