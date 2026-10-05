require(script.Parent.Parent.Types)
return function(p, data)
	p.WidgetConstructor("Text", {
		hasState = false,
		hasChildren = false,
		Args = {
			Text = 1,
			Wrapped = 2,
			Color = 3,
			RichText = 4
		},
		Events = {
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Iris_Text"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = p2.ZIndex
			textLabel.LayoutOrder = p2.ZIndex
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			data.applyTextStyle(textLabel)
			data.UIPadding(textLabel, Vector2.new(0, 2))
			return textLabel
		end,
		Update = function(p2)
			local instance = p2.Instance

			if p2.arguments.Text == nil then
				error("Iris.Text Text Argument is required", 5)
			end

			if p2.arguments.Wrapped then
				instance.TextWrapped = true
			else
				instance.TextWrapped = false
			end

			if p2.arguments.Color then
				instance.TextColor3 = p2.arguments.Color
			else
				instance.TextColor3 = p._config.TextColor
			end

			if p2.arguments.RichText then
				instance.RichText = true
			else
				instance.RichText = false
			end

			instance.Text = p2.arguments.Text
		end,
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	})
	p.WidgetConstructor("SeparatorText", {
		hasState = false,
		hasChildren = false,
		Args = {
			Text = 1
		},
		Events = {
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_SeparatorText"
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.ZIndex = p2.ZIndex
			frame.LayoutOrder = p2.ZIndex
			frame.ClipsDescendants = true
			data.UIPadding(frame, Vector2.new(0, p._config.SeparatorTextPadding.Y))
			data.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new(0, p._config.ItemSpacing.X))
			frame.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.ZIndex = p2.ZIndex + 1
			textLabel.LayoutOrder = p2.ZIndex + 1
			data.applyTextStyle(textLabel)
			textLabel.Parent = frame
			local frame2 = Instance.new("Frame")
			frame2.Name = "Left"
			frame2.AnchorPoint = Vector2.new(1, 0.5)
			frame2.BackgroundColor3 = p._config.SeparatorColor
			frame2.BackgroundTransparency = p._config.SeparatorTransparency
			frame2.BorderSizePixel = 0
			frame2.Size = UDim2.fromOffset(
				p._config.SeparatorTextPadding.X - p._config.ItemSpacing.X,
				p._config.SeparatorTextBorderSize
			)
			frame2.ZIndex = p2.ZIndex
			frame2.LayoutOrder = p2.ZIndex
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Right"
			frame3.AnchorPoint = Vector2.new(1, 0.5)
			frame3.BackgroundColor3 = p._config.SeparatorColor
			frame3.BackgroundTransparency = p._config.SeparatorTransparency
			frame3.BorderSizePixel = 0
			frame3.Size = UDim2.new(1, 0, 0, p._config.SeparatorTextBorderSize)
			frame3.ZIndex = p2.ZIndex + 2
			frame3.LayoutOrder = p2.ZIndex + 2
			frame3.Parent = frame
			return frame
		end,
		Update = function(p2)
			local textLabel = p2.Instance.TextLabel

			if p2.arguments.Text == nil then
				error("Iris.Text Text Argument is required", 5)
			end

			textLabel.Text = p2.arguments.Text
		end,
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	})
end