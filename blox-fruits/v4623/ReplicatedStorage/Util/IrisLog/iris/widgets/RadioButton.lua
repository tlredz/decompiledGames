require(script.Parent.Parent.Types)
return function(data, data2)
	data.WidgetConstructor("RadioButton", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Index = 2
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
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(data3)
			local textButton = Instance.new("TextButton")
			textButton.Name = "Iris_RadioButton"
			textButton.AutomaticSize = Enum.AutomaticSize.XY
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.LayoutOrder = data3.ZIndex
			textButton.AutoButtonColor = false
			textButton.ZIndex = data3.ZIndex
			textButton.LayoutOrder = data3.ZIndex
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local v = data._config.TextSize + 2 * (data._config.FramePadding.Y - 1)
			local frame = Instance.new("Frame")
			frame.Name = "Button"
			frame.Size = UDim2.fromOffset(v, v)
			frame.Parent = textButton
			frame.BackgroundColor3 = data._config.FrameBgColor
			frame.BackgroundTransparency = data._config.FrameBgTransparency
			data2.UICorner(frame)
			data2.UIPadding(frame, Vector2.new(math.max(1, (math.floor(v / 5))), (math.max(1, (math.floor(v / 5))))))
			local frame2 = Instance.new("Frame")
			frame2.Name = "Circle"
			frame2.Size = UDim2.fromScale(1, 1)
			frame2.Parent = frame
			frame2.BackgroundColor3 = data._config.CheckMarkColor
			frame2.BackgroundTransparency = data._config.CheckMarkTransparency
			data2.UICorner(frame2)
			data2.applyInteractionHighlights("Background", textButton, frame, {
				Color = data._config.FrameBgColor,
				Transparency = data._config.FrameBgTransparency,
				HoveredColor = data._config.FrameBgHoveredColor,
				HoveredTransparency = data._config.FrameBgHoveredTransparency,
				ActiveColor = data._config.FrameBgActiveColor,
				ActiveTransparency = data._config.FrameBgActiveTransparency
			})
			data2.applyButtonClick(textButton, function()
				data3.state.index:set(data3.arguments.Index)
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1
			data2.applyTextStyle(textLabel)
			textLabel.Parent = textButton
			return textButton
		end,
		Update = function(data3)
			data3.Instance.TextLabel.Text = data3.arguments.Text or "Radio Button"

			if data3.state then
				data3.state.index.lastChangeTick = data._cycleTick
				data._widgets[data3.type].UpdateState(data3)
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", p.arguments.Index)
			end
		end,
		UpdateState = function(state)
			local circle = state.Instance.Button.Circle

			if state.state.index.value == state.arguments.Index then
				circle.BackgroundTransparency = data._config.CheckMarkTransparency
				state.lastSelectedTick = data._cycleTick + 1
			else
				circle.BackgroundTransparency = 1
				state.lastUnselectedTick = data._cycleTick + 1
			end
		end
	})
end