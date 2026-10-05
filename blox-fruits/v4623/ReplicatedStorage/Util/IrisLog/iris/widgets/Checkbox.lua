require(script.Parent.Parent.Types)
return function(data, data2)
	data.WidgetConstructor("Checkbox", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1
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
			textButton.Name = "Iris_Checkbox"
			textButton.AutomaticSize = Enum.AutomaticSize.XY
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.BackgroundTransparency = 0.85
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.ZIndex = p.ZIndex
			textButton.LayoutOrder = p.ZIndex
			local uIListLayout = data2.UIListLayout(
				textButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local v = data._config.TextSize + 2 * data._config.FramePadding.Y
			local frame = Instance.new("Frame")
			frame.Name = "Box"
			frame.Size = UDim2.fromOffset(v, v)
			frame.BackgroundColor3 = data._config.FrameBgColor
			frame.BackgroundTransparency = data._config.FrameBgTransparency
			data2.applyFrameStyle(frame, true)
			data2.UIPadding(frame, Vector2.new(math.floor(v / 10), (math.floor(v / 10))))
			data2.applyInteractionHighlights("Background", textButton, frame, {
				Color = data._config.FrameBgColor,
				Transparency = data._config.FrameBgTransparency,
				HoveredColor = data._config.FrameBgHoveredColor,
				HoveredTransparency = data._config.FrameBgHoveredTransparency,
				ActiveColor = data._config.FrameBgActiveColor,
				ActiveTransparency = data._config.FrameBgActiveTransparency
			})
			frame.Parent = textButton
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Checkmark"
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.BackgroundTransparency = 1
			imageLabel.ImageColor3 = data._config.CheckMarkColor
			imageLabel.ImageTransparency = data._config.CheckMarkTransparency
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = frame
			data2.applyButtonClick(textButton, function()
				local value = p.state.isChecked.value
				p.state.isChecked:set(not value)
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
		Update = function(p)
			p.Instance.TextLabel.Text = p.arguments.Text or "Checkbox"
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.isChecked == nil then
				p.state.isChecked = data._widgetState(p, "checked", false)
			end
		end,
		UpdateState = function(state)
			local checkmark = state.Instance.Box.Checkmark

			if state.state.isChecked.value then
				checkmark.Image = data2.ICONS.CHECK_MARK
				state.lastCheckedTick = data._cycleTick + 1
			else
				checkmark.Image = ""
				state.lastUncheckedTick = data._cycleTick + 1
			end
		end
	})
end