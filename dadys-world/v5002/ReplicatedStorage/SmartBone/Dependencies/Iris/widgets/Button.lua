require(script.Parent.Parent.Types)
return function(p, state)
	local abstractButton = {
		hasState = false,
		hasChildren = false,
		Args = {
			Text = 1
		},
		Events = {
			clicked = state.EVENTS.click(function(p2)
				return p2.Instance
			end),
			rightClicked = state.EVENTS.rightClick(function(p2)
				return p2.Instance
			end),
			doubleClicked = state.EVENTS.doubleClick(function(p2)
				return p2.Instance
			end),
			ctrlClicked = state.EVENTS.ctrlClick(function(p2)
				return p2.Instance
			end),
			hovered = state.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local textButton = Instance.new("TextButton")
			textButton.Size = UDim2.fromOffset(0, 0)
			textButton.BackgroundColor3 = p._config.ButtonColor
			textButton.BackgroundTransparency = p._config.ButtonTransparency
			textButton.AutoButtonColor = false
			state.applyTextStyle(textButton)
			textButton.AutomaticSize = Enum.AutomaticSize.XY
			state.applyFrameStyle(textButton)
			state.applyInteractionHighlights(textButton, textButton, {
				ButtonColor = p._config.ButtonColor,
				ButtonTransparency = p._config.ButtonTransparency,
				ButtonHoveredColor = p._config.ButtonHoveredColor,
				ButtonHoveredTransparency = p._config.ButtonHoveredTransparency,
				ButtonActiveColor = p._config.ButtonActiveColor,
				ButtonActiveTransparency = p._config.ButtonActiveTransparency
			})
			textButton.ZIndex = p2.ZIndex
			textButton.LayoutOrder = p2.ZIndex
			return textButton
		end,
		Update = function(p2)
			p2.Instance.Text = p2.arguments.Text or "Button"
		end,
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	}
	state.abstractButton = abstractButton
	p.WidgetConstructor("Button", state.extend(abstractButton, {
		Generate = function(p2)
			local generate = abstractButton.Generate(p2)
			generate.Name = "Iris_Button"
			return generate
		end
	}))
	p.WidgetConstructor("SmallButton", state.extend(abstractButton, {
		Generate = function(p2)
			local generate = abstractButton.Generate(p2)
			generate.Name = "Iris_SmallButton"
			local uIPadding = generate.UIPadding
			uIPadding.PaddingLeft = UDim.new(0, 2)
			uIPadding.PaddingRight = UDim.new(0, 2)
			uIPadding.PaddingTop = UDim.new(0, 0)
			uIPadding.PaddingBottom = UDim.new(0, 0)
			return generate
		end
	}))
end