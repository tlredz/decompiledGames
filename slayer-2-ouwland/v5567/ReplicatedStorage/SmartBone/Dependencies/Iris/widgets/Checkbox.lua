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
			textButton.BackgroundTransparency = 1
			textButton.BorderSizePixel = 0
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.Text = ""
			textButton.AutomaticSize = Enum.AutomaticSize.XY
			textButton.ZIndex = p.ZIndex
			textButton.AutoButtonColor = false
			textButton.LayoutOrder = p.ZIndex
			local v = data._config.TextSize + 2 * data._config.FramePadding.Y
			local frame = Instance.new("Frame")
			frame.Name = "CheckboxBox"
			frame.Size = UDim2.fromOffset(v, v)
			frame.BackgroundColor3 = data._config.FrameBgColor
			frame.BackgroundTransparency = data._config.FrameBgTransparency
			frame.ZIndex = p.ZIndex + 1
			frame.LayoutOrder = p.ZIndex + 1
			data2.applyFrameStyle(frame, true)
			data2.applyInteractionHighlights(textButton, frame, {
				ButtonColor = data._config.FrameBgColor,
				ButtonTransparency = data._config.FrameBgTransparency,
				ButtonHoveredColor = data._config.FrameBgHoveredColor,
				ButtonHoveredTransparency = data._config.FrameBgHoveredTransparency,
				ButtonActiveColor = data._config.FrameBgActiveColor,
				ButtonActiveTransparency = data._config.FrameBgActiveTransparency
			})
			frame.Parent = textButton
			local v2 = math.ceil(v * 0.1)
			local v3 = v - v2 * 2
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Checkmark"
			imageLabel.Size = UDim2.fromOffset(v3, v3)
			imageLabel.Position = UDim2.fromOffset(v2, v2)
			imageLabel.BackgroundTransparency = 1
			imageLabel.ImageColor3 = data._config.CheckMarkColor
			imageLabel.ImageTransparency = data._config.CheckMarkTransparency
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.ZIndex = p.ZIndex + 2
			imageLabel.LayoutOrder = p.ZIndex + 2
			imageLabel.Parent = textButton
			textButton.MouseButton1Click:Connect(function()
				local value = p.state.isChecked.value
				p.state.isChecked:set(not value)
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			data2.applyTextStyle(textLabel)
			textLabel.AnchorPoint = Vector2.new(0, 0.5)
			textLabel.Position = UDim2.new(0, v + data._config.ItemInnerSpacing.X, 0.5, 0)
			textLabel.ZIndex = p.ZIndex + 1
			textLabel.LayoutOrder = p.ZIndex + 1
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
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
			local checkmark = state.Instance.Checkmark

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