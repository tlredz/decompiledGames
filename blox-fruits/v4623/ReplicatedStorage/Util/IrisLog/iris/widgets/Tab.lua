require(script.Parent.Parent.Types)
return function(data, data2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function openTab(parentWidget, index: number)
		if parentWidget.state.index.value > 0 then
			return
		end

		parentWidget.state.index:set(index)
	end

	local function closeTab(p, index: number)
		if p.state.index.value ~= index then
			return
		end

		for i = index - 1, 1, -1 do
			if p.Tabs[i].state.isOpened.value ~= true then
				continue
			end

			p.state.index:set(i)
			return
		end

		for i = index, #p.Tabs do
			if p.Tabs[i].state.isOpened.value ~= true then
				continue
			end

			p.state.index:set(i)
			return
		end

		p.state.index:set(0)
	end

	data.WidgetConstructor("TabBar", {
		hasState = true,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(p)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_TabBar"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = p.ZIndex
			local uIListLayout = data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new())
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
			local frame2 = Instance.new("Frame")
			frame2.Name = "Bar"
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			data2.UIListLayout(frame2, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.X))
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Underline"
			frame3.Size = UDim2.new(1, 0, 0, 1)
			frame3.BackgroundColor3 = data._config.TabActiveColor
			frame3.BackgroundTransparency = data._config.TabActiveTransparency
			frame3.BorderSizePixel = 0
			frame3.LayoutOrder = 1
			frame3.Parent = frame
			local frame4 = Instance.new("Frame")
			frame4.Name = "TabContainer"
			frame4.AutomaticSize = Enum.AutomaticSize.Y
			frame4.Size = UDim2.fromScale(1, 0)
			frame4.BackgroundTransparency = 1
			frame4.BorderSizePixel = 0
			frame4.LayoutOrder = 2
			frame4.ClipsDescendants = true
			frame4.Parent = frame
			p.ChildContainer = frame4
			p.Tabs = {}
			return frame
		end,
		Update = function(_) end,
		ChildAdded = function(data3, state)
			assert(state.type == "Tab", "Only Iris.Tab can be parented to Iris.TabBar.")
			local instance = data3.Instance
			state.ChildContainer.Parent = data3.ChildContainer
			state.Index = #data3.Tabs + 1
			data3.state.index.ConnectedWidgets[state.ID] = state
			table.insert(data3.Tabs, state)
			return instance.Bar
		end,
		ChildDiscarded = function(p, p2)
			local index = p2.Index
			table.remove(p.Tabs, index)

			for i = index, #p.Tabs do
				p.Tabs[i].Index = i
			end

			closeTab(p, index)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", 1)
			end
		end,
		UpdateState = function(_) end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})
	data.WidgetConstructor("Tab", {
		hasState = true,
		hasChildren = true,
		Args = {
			Text = 1,
			Hideable = 2
		},
		Events = {
			clicked = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
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
					return p.state.index.value == p.Index
				end
			},
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
			local textButton = Instance.new("TextButton")
			textButton.Name = "Iris_Tab"
			textButton.AutomaticSize = Enum.AutomaticSize.XY
			textButton.BackgroundColor3 = data._config.TabColor
			textButton.BackgroundTransparency = data._config.TabTransparency
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			state.ButtonColors = {
				Color = data._config.TabColor,
				Transparency = data._config.TabTransparency,
				HoveredColor = data._config.TabHoveredColor,
				HoveredTransparency = data._config.TabHoveredTransparency,
				ActiveColor = data._config.TabActiveColor,
				ActiveTransparency = data._config.TabActiveTransparency
			}
			data2.UIPadding(textButton, Vector2.new(data._config.FramePadding.X, 0))
			data2.applyFrameStyle(textButton, true, true)
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyInteractionHighlights("Background", textButton, textButton, state.ButtonColors)
			data2.applyButtonClick(textButton, function()
				state.state.index:set(state.Index)
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			data2.applyTextStyle(textLabel)
			data2.UIPadding(textLabel, Vector2.new(0, data._config.FramePadding.Y))
			textLabel.Parent = textButton
			local v = data._config.TextSize + (data._config.FramePadding.Y - 1) * 2
			local textButton2 = Instance.new("TextButton")
			textButton2.Name = "CloseButton"
			textButton2.BackgroundTransparency = 1
			textButton2.BorderSizePixel = 0
			textButton2.LayoutOrder = 1
			textButton2.Size = UDim2.fromOffset(v, v)
			textButton2.Text = ""
			textButton2.AutoButtonColor = false
			data2.UICorner(textButton2)
			data2.applyButtonClick(textButton2, function()
				state.state.isOpened:set(false)
				closeTab(state.parentWidget, state.Index)
			end)
			data2.applyInteractionHighlights("Background", textButton2, textButton2, {
				Color = data._config.TabColor,
				Transparency = 1,
				HoveredColor = data._config.ButtonHoveredColor,
				HoveredTransparency = data._config.ButtonHoveredTransparency,
				ActiveColor = data._config.ButtonActiveColor,
				ActiveTransparency = data._config.ButtonActiveTransparency
			})
			textButton2.Parent = textButton
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Icon"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Image = data2.ICONS.MULTIPLICATION_SIGN
			imageLabel.ImageTransparency = 1
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = UDim2.fromOffset(math.floor(v * 0.7), (math.floor(v * 0.7)))
			data2.applyInteractionHighlights("Image", textButton, imageLabel, {
				Color = data._config.TextColor,
				Transparency = 1,
				HoveredColor = data._config.TextColor,
				HoveredTransparency = data._config.TextTransparency,
				ActiveColor = data._config.TextColor,
				ActiveTransparency = data._config.TextTransparency
			})
			imageLabel.Parent = textButton2
			local frame = Instance.new("Frame")
			frame.Name = "TabContainer"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = true
			data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))
			local uIPadding = data2.UIPadding(frame, Vector2.new(0, data._config.ItemSpacing.Y))
			uIPadding.PaddingBottom = UDim.new()
			state.ChildContainer = frame
			return textButton
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local closeButton = instance.CloseButton
			textLabel.Text = tostring(p.arguments.Text)
			closeButton.Visible = p.arguments.Hideable == true
		end,
		ChildAdded = function(p, _)
			return p.ChildContainer
		end,
		GenerateState = function(data3)
			data3.state.index = data3.parentWidget.state.index
			data3.state.index.ConnectedWidgets[data3.ID] = data3

			if data3.state.isOpened == nil then
				data3.state.isOpened = data._widgetState(data3, "isOpened", true)
			end
		end,
		UpdateState = function(state)
			local instance = state.Instance
			local childContainer = state.ChildContainer

			if state.state.isOpened.lastChangeTick == data._cycleTick then
				if state.state.isOpened.value == true then
					state.lastOpenedTick = data._cycleTick + 1
					openTab(state.parentWidget, state.Index) -- equivalent call inferred; original call site unknown
					instance.Visible = true
				else
					state.lastClosedTick = data._cycleTick + 1
					closeTab(state.parentWidget, state.Index)
					instance.Visible = false
				end
			end

			if state.state.index.lastChangeTick == data._cycleTick then
				if state.state.index.value == state.Index then
					state.ButtonColors.Color = data._config.TabActiveColor
					state.ButtonColors.Transparency = data._config.TabActiveTransparency
					instance.BackgroundColor3 = data._config.TabActiveColor
					instance.BackgroundTransparency = data._config.TabActiveTransparency
					childContainer.Visible = true
					state.lastSelectedTick = data._cycleTick + 1
				else
					state.ButtonColors.Color = data._config.TabColor
					state.ButtonColors.Transparency = data._config.TabTransparency
					instance.BackgroundColor3 = data._config.TabColor
					instance.BackgroundTransparency = data._config.TabTransparency
					childContainer.Visible = false
					state.lastUnselectedTick = data._cycleTick + 1
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})
end