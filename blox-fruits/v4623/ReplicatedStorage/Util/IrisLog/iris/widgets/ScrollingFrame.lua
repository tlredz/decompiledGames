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
			childContainer.Visible = true
			return childContainer
		end,
		UpdateState = function(state)
			local value = state.state.isUncollapsed.value
			local _ = state.Instance
			local childContainer = state.ChildContainer

			if value then
				state.lastUncollapsedTick = data._cycleTick + 1
			else
				state.lastCollapsedTick = data._cycleTick + 1
			end

			childContainer.Visible = true
		end,
		GenerateState = function(p)
			if p.state.isUncollapsed == nil then
				p.state.isUncollapsed = data._widgetState(p, "isUncollapsed", false)
			end
		end
	}
	data.WidgetConstructor("ScrollingFrame", data2.extend(v, {
		Args = {
			Text = 1,
			SpanAvailWidth = 2,
			NoIndent = 3
		},
		Generate = function(p)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_ScrollingFrame"
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.LayoutOrder = p.ZIndex
			local uIListLayout = data2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, 5))
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			local scrollingFrame = Instance.new("ScrollingFrame")
			scrollingFrame.Name = "Iris_ScrollingFrameContainer"
			scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
			scrollingFrame.CanvasSize = UDim2.new(1, 0, 1, 0)
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.AutomaticSize = Enum.AutomaticSize.None
			scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			scrollingFrame.BackgroundTransparency = 1
			scrollingFrame.BorderSizePixel = 0
			scrollingFrame.LayoutOrder = 2
			scrollingFrame.Visible = true
			scrollingFrame.ClipsDescendants = true
			local uIListLayout2 = data2.UIListLayout(scrollingFrame, Enum.FillDirection.Vertical, UDim.new(0, 0))
			uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Top
			scrollingFrame.Parent = frame
			p.ChildContainer = scrollingFrame
			return frame
		end,
		Update = function(p)
			local _ = p.Instance
			local _ = p.ChildContainer
		end
	}))
end