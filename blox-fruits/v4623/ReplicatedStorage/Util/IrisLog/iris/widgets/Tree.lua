require(script.Parent.Parent.Types)
return function(data, data2)
	local v = {
		hasState = true,
		hasChildren = true,
		Events = {
			collapsed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastCollapsedTick == data._cycleTick
				end
			},
			uncollapsed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastUncollapsedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		ChildAdded = function(p, _)
			local childContainer = p.ChildContainer
			childContainer.Visible = p.state.isUncollapsed.value
			return childContainer
		end,
		UpdateState = function(state)
			local visible = state.state.isUncollapsed.value
			local instance = state.Instance
			local childContainer = state.ChildContainer
			instance.Header.Button.Arrow.Image = visible and data2.ICONS.DOWN_POINTING_TRIANGLE or data2.ICONS.RIGHT_POINTING_TRIANGLE

			if visible then
				state.lastUncollapsedTick = data._cycleTick + 1
			else
				state.lastCollapsedTick = data._cycleTick + 1
			end

			childContainer.Visible = visible
		end,
		GenerateState = function(p)
			if p.state.isUncollapsed == nil then
				p.state.isUncollapsed = data._widgetState(p, "isUncollapsed", false)
			end
		end
	}
	data.WidgetConstructor("Tree", data2.extend(v, {
		Args = {
			Text = 1,
			SpanAvailWidth = 2,
			NoIndent = 3
		},
		Generate = function(state)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Tree"
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, 0))
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = state.ZIndex
			data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 0))
			local frame2 = Instance.new("Frame")
			frame2.Name = "TreeContainer"
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.LayoutOrder = 1
			frame2.Visible = false
			data2.UIListLayout(frame2, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))
			local uIPadding = data2.UIPadding(frame2, Vector2.zero)
			uIPadding.PaddingTop = UDim.new(0, data._config.ItemSpacing.Y)
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Header"
			frame3.Size = UDim2.fromScale(1, 0)
			frame3.AutomaticSize = Enum.AutomaticSize.Y
			frame3.BackgroundTransparency = 1
			frame3.BorderSizePixel = 0
			frame3.Parent = frame
			local textButton = Instance.new("TextButton")
			textButton.Name = "Button"
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			data2.applyInteractionHighlights("Background", textButton, frame3, {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})
			local uIPadding_2 = data2.UIPadding(textButton, Vector2.zero)
			uIPadding_2.PaddingLeft = UDim.new(0, data._config.FramePadding.X)
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.FramePadding.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			textButton.Parent = frame3
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.Size = UDim2.fromOffset(data._config.TextSize, (math.floor(data._config.TextSize * 0.7)))
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = textButton
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			local uIPadding_3 = data2.UIPadding(textLabel, Vector2.zero)
			uIPadding_3.PaddingRight = UDim.new(0, 21)
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			data2.applyButtonClick(textButton, function()
				state.state.isUncollapsed:set(not state.state.isUncollapsed.value)
			end)
			state.ChildContainer = frame2
			return frame
		end,
		Update = function(data3)
			local instance = data3.Instance
			local childContainer = data3.ChildContainer
			local button = instance.Header.Button
			local textLabel = button.TextLabel
			local uIPadding = childContainer.UIPadding
			textLabel.Text = data3.arguments.Text or "Tree"

			if data3.arguments.SpanAvailWidth then
				button.AutomaticSize = Enum.AutomaticSize.Y
				button.Size = UDim2.fromScale(1, 0)
			else
				button.AutomaticSize = Enum.AutomaticSize.XY
				button.Size = UDim2.fromScale(0, 0)
			end

			if data3.arguments.NoIndent then
				uIPadding.PaddingLeft = UDim.new(0, 0)
			else
				uIPadding.PaddingLeft = UDim.new(0, data._config.IndentSpacing)
			end
		end
	}))
	data.WidgetConstructor("CollapsingHeader", data2.extend(v, {
		Args = {
			Text = 1
		},
		Generate = function(state)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_CollapsingHeader"
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, 0))
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = state.ZIndex
			data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 0))
			local frame2 = Instance.new("Frame")
			frame2.Name = "CollapsingHeaderContainer"
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.LayoutOrder = 1
			frame2.Visible = false
			data2.UIListLayout(frame2, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))
			local uIPadding = data2.UIPadding(frame2, Vector2.zero)
			uIPadding.PaddingTop = UDim.new(0, data._config.ItemSpacing.Y)
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Header"
			frame3.Size = UDim2.fromScale(1, 0)
			frame3.AutomaticSize = Enum.AutomaticSize.Y
			frame3.BackgroundTransparency = 1
			frame3.BorderSizePixel = 0
			frame3.Parent = frame
			local textButton = Instance.new("TextButton")
			textButton.Name = "Button"
			textButton.Size = UDim2.new(1, 0, 0, 0)
			textButton.AutomaticSize = Enum.AutomaticSize.Y
			textButton.BackgroundColor3 = data._config.HeaderColor
			textButton.BackgroundTransparency = data._config.HeaderTransparency
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.ClipsDescendants = true
			data2.UIPadding(textButton, data._config.FramePadding)
			data2.applyFrameStyle(textButton, true)
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, 2 * data._config.FramePadding.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyInteractionHighlights("Background", textButton, textButton, {
				Color = data._config.HeaderColor,
				Transparency = data._config.HeaderTransparency,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})
			textButton.Parent = frame3
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.Size = UDim2.fromOffset(data._config.TextSize, (math.ceil(data._config.TextSize * 0.8)))
			imageLabel.AutomaticSize = Enum.AutomaticSize.Y
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = data._config.TextColor
			imageLabel.ImageTransparency = data._config.TextTransparency
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = textButton
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			local uIPadding_2 = data2.UIPadding(textLabel, Vector2.zero)
			uIPadding_2.PaddingRight = UDim.new(0, 21)
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			data2.applyButtonClick(textButton, function()
				state.state.isUncollapsed:set(not state.state.isUncollapsed.value)
			end)
			state.ChildContainer = frame2
			return frame
		end,
		Update = function(p)
			p.Instance.Header.Button.TextLabel.Text = p.arguments.Text or "Collapsing Header"
		end
	}))
end