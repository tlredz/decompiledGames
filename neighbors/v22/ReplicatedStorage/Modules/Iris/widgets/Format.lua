require(script.Parent.Parent.Types)
return function(p, p2)
	p.WidgetConstructor("Separator", {
		hasState = false,
		hasChildren = false,
		Args = {},
		Events = {},
		Generate = function(p3)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Separator"

			if p3.parentWidget.type == "SameLine" then
				frame.Size = UDim2.new(0, 1, p._config.ItemWidth.Scale, p._config.ItemWidth.Offset)
			else
				frame.Size = UDim2.new(p._config.ItemWidth.Scale, p._config.ItemWidth.Offset, 0, 1)
			end

			frame.BackgroundColor3 = p._config.SeparatorColor
			frame.BackgroundTransparency = p._config.SeparatorTransparency
			frame.BorderSizePixel = 0
			p2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 0))
			return frame
		end,
		Update = function(_) end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end
	})
	p.WidgetConstructor("Indent", {
		hasState = false,
		hasChildren = true,
		Args = {
			Width = 1
		},
		Events = {},
		Generate = function(_)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Indent"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.new(p._config.ItemWidth, UDim.new())
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			p2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))
			p2.UIPadding(frame, Vector2.zero)
			return frame
		end,
		Update = function(p3)
			local uIPadding = p3.Instance.UIPadding
			local v2

			if p3.arguments.Width then
				v2 = p3.arguments.Width
			else
				v2 = p._config.IndentSpacing
			end

			uIPadding.PaddingLeft = UDim.new(0, v2)
		end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end
	})
	p.WidgetConstructor("SameLine", {
		hasState = false,
		hasChildren = true,
		Args = {
			Width = 1,
			VerticalAlignment = 2,
			HorizontalAlignment = 3
		},
		Events = {},
		Generate = function(_)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_SameLine"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.new(p._config.ItemWidth, UDim.new())
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			p2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new(0, 0))
			return frame
		end,
		Update = function(p3)
			local uIListLayout = p3.Instance.UIListLayout
			local v2

			if p3.arguments.Width then
				v2 = p3.arguments.Width
			else
				v2 = p._config.ItemSpacing.X
			end

			uIListLayout.Padding = UDim.new(0, v2)

			if p3.arguments.VerticalAlignment then
				uIListLayout.VerticalAlignment = p3.arguments.VerticalAlignment
			else
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			end

			if p3.arguments.HorizontalAlignment then
				uIListLayout.HorizontalAlignment = p3.arguments.HorizontalAlignment
			else
				uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			end
		end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end
	})
	p.WidgetConstructor("Group", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(_)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_Group"
			frame.AutomaticSize = Enum.AutomaticSize.XY
			frame.Size = UDim2.fromOffset(0, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ClipsDescendants = false
			p2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))
			return frame
		end,
		Update = function(_) end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end
	})
end