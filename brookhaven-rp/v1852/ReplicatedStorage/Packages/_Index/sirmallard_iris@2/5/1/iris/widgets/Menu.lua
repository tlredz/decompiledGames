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
		childContainer.Size = UDim2.fromOffset(instance.AbsoluteSize.X, 0)

		if childContainer.Parent == nil then
			return
		end

		local v4 = instance.AbsolutePosition - data2.GuiOffset
		local absoluteSize = instance.AbsoluteSize
		local absoluteSize2 = childContainer.AbsoluteSize
		local popupBorderSize = data._config.PopupBorderSize
		local absoluteSize3 = childContainer.Parent.AbsoluteSize
		local X = v4.X
		local zero = Vector2.zero

		if v3 then
			if v4.X + absoluteSize2.X > absoluteSize3.X then
				zero = Vector2.xAxis
			else
				X = v4.X + absoluteSize.X
			end
		end

		local v5

		if v4.Y + absoluteSize2.Y > absoluteSize3.Y then
			v5 = v4.Y - popupBorderSize + (v3 and absoluteSize.Y or 0)
			zero += Vector2.yAxis
		else
			v5 = v4.Y + popupBorderSize + (v3 and 0 or absoluteSize.Y)
		end

		childContainer.Position = UDim2.fromOffset(X, v5)
		childContainer.AnchorPoint = zero
	end

	data2.registerEvent("InputBegan", function(p)
		if not data._started or p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.MouseButton2 or v == false or v2 == nil then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local flag = false

		for _, v4 in states do
			for _, v6 in { v4.ChildContainer, v4.Instance } do
				local v7 = v6.AbsolutePosition - data2.GuiOffset
				local v8 = v7 + v6.AbsoluteSize

				if not data2.isPosInsideRect(mouseLocation, v7, v8) then
					continue
				end

				flag = true
				break
			end

			if flag then
				break
			end
		end

		if not flag then
			EmptyMenuStack()
		end
	end)
	data.WidgetConstructor("MenuBar", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(_)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_MenuBar"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundColor3 = data._config.MenubarBgColor
			frame.BackgroundTransparency = data._config.MenubarBgTransparency
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			data2.UIPadding(frame, Vector2.new(data._config.WindowPadding.X, 1))
			local uIListLayout = data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new())
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyFrameStyle(frame, true, true)
			return frame
		end,
		Update = function(_) end,
		ChildAdded = function(p, _)
			return p.Instance
		end,
		Discard = function(p)
			p.Instance:Destroy()
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
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			}
			local textButton

			if state.parentWidget.type == "Menu" then
				textButton = Instance.new("TextButton")
				textButton.Name = "Menu"
				textButton.AutomaticSize = Enum.AutomaticSize.Y
				textButton.Size = UDim2.fromScale(1, 0)
				textButton.BackgroundColor3 = data._config.HeaderColor
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.Text = ""
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
				textLabel.AutomaticSize = Enum.AutomaticSize.XY
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				data2.applyTextStyle(textLabel)
				textLabel.Parent = textButton
				local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
				local v4 = v3 - math.round(0.2 * v3) * 2
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "Icon"
				imageLabel.Size = UDim2.fromOffset(v4, v4)
				imageLabel.BackgroundTransparency = 1
				imageLabel.BorderSizePixel = 0
				imageLabel.ImageColor3 = data._config.TextColor
				imageLabel.ImageTransparency = data._config.TextTransparency
				imageLabel.Image = data2.ICONS.RIGHT_POINTING_TRIANGLE
				imageLabel.LayoutOrder = 1
				imageLabel.Parent = textButton
			else
				textButton = Instance.new("TextButton")
				textButton.Name = "Menu"
				textButton.AutomaticSize = Enum.AutomaticSize.XY
				textButton.Size = UDim2.fromScale(0, 0)
				textButton.BackgroundColor3 = data._config.HeaderColor
				textButton.BackgroundTransparency = 1
				textButton.BorderSizePixel = 0
				textButton.Text = ""
				textButton.AutoButtonColor = false
				textButton.ClipsDescendants = true
				data2.applyTextStyle(textButton)
				data2.UIPadding(textButton, Vector2.new(data._config.ItemSpacing.X, data._config.FramePadding.Y))
			end

			data2.applyInteractionHighlights("Background", textButton, textButton, state.ButtonColors)
			data2.applyButtonClick(textButton, function()
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
			data2.applyMouseEnter(textButton, function()
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
			scrollingFrame.Name = "MenuContainer"
			scrollingFrame.AutomaticSize = Enum.AutomaticSize.XY
			scrollingFrame.Size = UDim2.fromOffset(0, 0)
			scrollingFrame.BackgroundColor3 = data._config.PopupBgColor
			scrollingFrame.BackgroundTransparency = data._config.PopupBgTransparency
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			scrollingFrame.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			scrollingFrame.ScrollBarThickness = data._config.ScrollbarSize
			scrollingFrame.CanvasSize = UDim2.fromScale(0, 0)
			scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			scrollingFrame.TopImage = data2.ICONS.BLANK_SQUARE
			scrollingFrame.MidImage = data2.ICONS.BLANK_SQUARE
			scrollingFrame.BottomImage = data2.ICONS.BLANK_SQUARE
			scrollingFrame.ZIndex = 6
			scrollingFrame.LayoutOrder = 6
			scrollingFrame.ClipsDescendants = true
			data2.UIStroke(
				scrollingFrame,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(scrollingFrame, Vector2.new(2, data._config.WindowPadding.Y - data._config.ItemSpacing.Y))
			local uIListLayout_2 = data2.UIListLayout(scrollingFrame, Enum.FillDirection.Vertical, UDim.new(0, 1))
			uIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Top
			scrollingFrame.Parent = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			state.ChildContainer = scrollingFrame
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
				state.ButtonColors.Transparency = data._config.HeaderTransparency
				childContainer.Visible = true
				UpdateChildContainerTransform(state)
			else
				state.lastClosedTick = data._cycleTick + 1
				state.ButtonColors.Transparency = 1
				childContainer.Visible = false
			end
		end,
		Discard = function(data3)
			if v then
				local parentWidget = data3.parentWidget
				local index = table.find(states, parentWidget)

				if index then
					EmptyMenuStack(index)

					if #states ~= 0 then
						v2 = parentWidget
						v = true
					end
				end
			end

			data3.Instance:Destroy()
			data3.ChildContainer:Destroy()
			data2.discardState(data3)
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
			textButton.Name = "Iris_MenuItem"
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.Size = UDim2.fromScale(1, 0)
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			local uIPadding = data2.UIPadding(textButton, data._config.FramePadding)
			uIPadding.PaddingTop -= UDim.new(0, 1)
			data2.UIListLayout(textButton, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.X))
			data2.applyInteractionHighlights("Background", textButton, textButton, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			})
			data2.applyButtonClick(textButton, function()
				EmptyMenuStack()
			end)
			data2.applyMouseEnter(textButton, function()
				local parentWidget = p.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Shortcut"
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.BackgroundTransparency = 1
			textLabel2.BorderSizePixel = 0
			textLabel2.LayoutOrder = 1
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
				if p.arguments.ModifierKey then
					shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
				else
					shortcut.Text = p.arguments.KeyCode.Name
				end
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
		Generate = function(p)
			local textButton = Instance.new("TextButton")
			textButton.Name = "Iris_MenuToggle"
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.Size = UDim2.fromScale(1, 0)
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			local uIPadding = data2.UIPadding(textButton, data._config.FramePadding)
			uIPadding.PaddingTop -= UDim.new(0, 1)
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyInteractionHighlights("Background", textButton, textButton, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			})
			data2.applyButtonClick(textButton, function()
				p.state.isChecked:set(not p.state.isChecked.value)
				EmptyMenuStack()
			end)
			data2.applyMouseEnter(textButton, function()
				local parentWidget = p.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Shortcut"
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.BackgroundTransparency = 1
			textLabel2.BorderSizePixel = 0
			textLabel2.LayoutOrder = 1
			data2.applyTextStyle(textLabel2)
			textLabel2.Text = ""
			textLabel2.TextColor3 = data._config.TextDisabledColor
			textLabel2.TextTransparency = data._config.TextDisabledTransparency
			textLabel2.Parent = textButton
			local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
			local v4 = v3 - math.round(0.2 * v3) * 2
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Icon"
			imageLabel.Size = UDim2.fromOffset(v4, v4)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.Image = data2.ICONS.CHECKMARK
			imageLabel.LayoutOrder = 2
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
				if p.arguments.ModifierKey then
					shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
				else
					shortcut.Text = p.arguments.KeyCode.Name
				end
			end
		end,
		UpdateState = function(state)
			local icon = state.Instance.Icon

			if state.state.isChecked.value then
				icon.ImageTransparency = data._config.TextTransparency
				state.lastCheckedTick = data._cycleTick + 1
			else
				icon.ImageTransparency = 1
				state.lastUncheckedTick = data._cycleTick + 1
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end