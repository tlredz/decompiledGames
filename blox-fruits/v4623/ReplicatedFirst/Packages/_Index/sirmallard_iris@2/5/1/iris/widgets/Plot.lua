require(script.Parent.Parent.Types)
return function(data, data2)
	data.WidgetConstructor("ProgressBar", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Format = 2
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
			changed = {
				Init = function(_) end,
				Get = function(p)
					return p.lastChangedTick == data._cycleTick
				end
			}
		},
		Generate = function(_)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_ProgressBar"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			frame.BackgroundTransparency = 1
			local uIListLayout = data2.UIListLayout(
				frame,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local frame2 = Instance.new("Frame")
			frame2.Name = "Bar"
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
			frame2.BackgroundColor3 = data._config.FrameBgColor
			frame2.BackgroundTransparency = data._config.FrameBgTransparency
			frame2.BorderSizePixel = 0
			frame2.ClipsDescendants = true
			data2.applyFrameStyle(frame2, true)
			frame2.Parent = frame
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Progress"
			textLabel.AutomaticSize = Enum.AutomaticSize.Y
			textLabel.Size = UDim2.new(UDim.new(0, 0), data._config.ContentHeight)
			textLabel.BackgroundColor3 = data._config.PlotHistogramColor
			textLabel.BackgroundTransparency = data._config.PlotHistogramTransparency
			textLabel.BorderSizePixel = 0
			data2.applyTextStyle(textLabel)
			data2.UIPadding(textLabel, data._config.FramePadding)
			data2.UICorner(textLabel, data._config.FrameRounding)
			textLabel.Text = ""
			textLabel.Parent = frame2
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Value"
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.Size = UDim2.new(UDim.new(0, 0), data._config.ContentHeight)
			textLabel2.BackgroundTransparency = 1
			textLabel2.BorderSizePixel = 0
			textLabel2.ZIndex = 1
			data2.applyTextStyle(textLabel2)
			data2.UIPadding(textLabel2, data._config.FramePadding)
			textLabel2.Parent = frame2
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "TextLabel"
			textLabel3.AutomaticSize = Enum.AutomaticSize.XY
			textLabel3.AnchorPoint = Vector2.new(0, 0.5)
			textLabel3.BackgroundTransparency = 1
			textLabel3.BorderSizePixel = 0
			textLabel3.LayoutOrder = 1
			data2.applyTextStyle(textLabel3)
			data2.UIPadding(textLabel2, data._config.FramePadding)
			textLabel3.Parent = frame
			return frame
		end,
		GenerateState = function(p)
			if p.state.progress == nil then
				p.state.progress = data._widgetState(p, "Progress", 0)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local value = instance.Bar.Value

			if p.arguments.Format ~= nil and typeof(p.arguments.Format) == "string" then
				value.Text = p.arguments.Format
			end

			textLabel.Text = p.arguments.Text or "Progress Bar"
		end,
		UpdateState = function(state)
			local bar = state.Instance.Bar
			local progress = bar.Progress
			local value = bar.Value
			local v = math.clamp(state.state.progress.value, 0, 1)
			local X = bar.AbsoluteSize.X
			local X2 = value.AbsoluteSize.X

			if X * (1 - v) < X2 then
				value.AnchorPoint = Vector2.xAxis
				value.Position = UDim2.fromScale(1, 0)
			else
				value.AnchorPoint = Vector2.zero
				value.Position = UDim2.fromScale(v, 0)
			end

			progress.Size = UDim2.new(UDim.new(v, 0), progress.Size.Height)

			if state.arguments.Format == nil or typeof(state.arguments.Format) ~= "string" then
				value.Text = string.format("%d%%", v * 100)
			else
				value.Text = state.arguments.Format
			end

			state.lastChangedTick = data._cycleTick + 1
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})

	local function createLine(parent, p: number)
		local frame = Instance.new("Frame")
		frame.Name = tostring(p)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = data._config.PlotLinesColor
		frame.BackgroundTransparency = data._config.PlotLinesTransparency
		frame.BorderSizePixel = 0
		frame.Parent = parent
		return frame
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearLine(state)
		if state.HoveredLine then
			state.HoveredLine.BackgroundColor3 = data._config.PlotLinesColor
			state.HoveredLine.BackgroundTransparency = data._config.PlotLinesTransparency
			state.HoveredLine = false
			state.state.hovered:set(nil)
		end
	end

	local function updateLine(state, flag: boolean?)
		local plot = state.Instance.Background.Plot
		local mouseLocation = data2.getMouseLocation()
		local v = plot.AbsolutePosition - data2.GuiOffset
		local v2 = math.ceil((mouseLocation.X - v.X) / plot.AbsoluteSize.X * #state.Lines)
		local line = state.Lines[v2]

		if line then
			if line ~= state.HoveredLine and not flag and state.HoveredLine then
				state.HoveredLine.BackgroundColor3 = data._config.PlotLinesColor
				state.HoveredLine.BackgroundTransparency = data._config.PlotLinesTransparency
				state.HoveredLine = false
				state.state.hovered:set(nil)
			end

			local v3 = state.state.values.value[v2]
			local v4 = state.state.values.value[v2 + 1]

			if v3 and v4 then
				if math.floor(v3) == v3 and math.floor(v4) == v4 then
					state.Tooltip.Text = ("%d: %d\n%d: %d"):format(v2, v3, v2 + 1, v4)
				else
					state.Tooltip.Text = ("%d: %.3f\n%d: %.3f"):format(v2, v3, v2 + 1, v4)
				end
			end

			state.HoveredLine = line
			line.BackgroundColor3 = data._config.PlotLinesHoveredColor
			line.BackgroundTransparency = data._config.PlotLinesHoveredTransparency

			if flag then
				state.state.hovered.value = { v3, v4 }
			else
				state.state.hovered:set({ v3, v4 })
			end
		end
	end

	data.WidgetConstructor("PlotLines", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Height = 2,
			Min = 3,
			Max = 4,
			TextOverlay = 5
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(p)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_PlotLines"
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			local uIListLayout = data2.UIListLayout(
				frame,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local frame2 = Instance.new("Frame")
			frame2.Name = "Background"
			frame2.Size = UDim2.new(data._config.ContentWidth, UDim.new(1, 0))
			frame2.BackgroundColor3 = data._config.FrameBgColor
			frame2.BackgroundTransparency = data._config.FrameBgTransparency
			data2.applyFrameStyle(frame2)
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Plot"
			frame3.Size = UDim2.fromScale(1, 1)
			frame3.BackgroundTransparency = 1
			frame3.BorderSizePixel = 0
			frame3.ClipsDescendants = true
			frame3:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				p.state.values.lastChangeTick = data._cycleTick
				data._widgets.PlotLines.UpdateState(p)
			end)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "OverlayText"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.AnchorPoint = Vector2.new(0.5, 0)
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.Position = UDim2.fromScale(0.5, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = 2
			data2.applyTextStyle(textLabel)
			textLabel.Parent = frame3
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Iris_Tooltip"
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.Size = UDim2.fromOffset(0, 0)
			textLabel2.BackgroundColor3 = data._config.PopupBgColor
			textLabel2.BackgroundTransparency = data._config.PopupBgTransparency
			textLabel2.BorderSizePixel = 0
			textLabel2.Visible = false
			data2.applyTextStyle(textLabel2)
			data2.UIStroke(
				textLabel2,
				data._config.PopupBorderSize,
				data._config.BorderActiveColor,
				data._config.BorderActiveTransparency
			)
			data2.UIPadding(textLabel2, data._config.WindowPadding)

			if data._config.PopupRounding > 0 then
				data2.UICorner(textLabel2, data._config.PopupRounding)
			end

			local popupScreenGui = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			textLabel2.Parent = popupScreenGui and popupScreenGui:FindFirstChild("TooltipContainer")
			p.Tooltip = textLabel2
			data2.applyMouseMoved(frame3, function()
				updateLine(p)
			end)
			data2.applyMouseLeave(frame3, function()
				clearLine(p) -- equivalent call inferred; original call site unknown
			end)
			frame3.Parent = frame2
			p.Lines = {}
			p.HoveredLine = false
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "TextLabel"
			textLabel3.AutomaticSize = Enum.AutomaticSize.XY
			textLabel3.Size = UDim2.fromOffset(0, 0)
			textLabel3.BackgroundTransparency = 1
			textLabel3.BorderSizePixel = 0
			textLabel3.ZIndex = 3
			textLabel3.LayoutOrder = 3
			data2.applyTextStyle(textLabel3)
			textLabel3.Parent = frame
			return frame
		end,
		GenerateState = function(p)
			if p.state.values == nil then
				p.state.values = data._widgetState(p, "values", { 0, 1 })
			end

			if p.state.hovered == nil then
				p.state.hovered = data._widgetState(p, "hovered", nil)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local overlayText = instance.Background.Plot.OverlayText
			textLabel.Text = p.arguments.Text or "Plot Lines"
			overlayText.Text = p.arguments.TextOverlay or ""
			instance.Size = UDim2.new(1, 0, 0, p.arguments.Height or 0)
		end,
		UpdateState = function(data3)
			if data3.state.hovered.lastChangeTick == data._cycleTick then
				if data3.state.hovered.value then
					data3.Tooltip.Visible = true
				else
					data3.Tooltip.Visible = false
				end
			end

			if data3.state.values.lastChangeTick == data._cycleTick then
				local plot = data3.Instance.Background.Plot
				local value = data3.state.values.value
				local v = #value - 1
				local count = #data3.Lines
				local min = data3.arguments.Min or 1e999
				local max = data3.arguments.Max or -1e999

				if min == nil or max == nil then
					for _, v2 in value do
						min = math.min(min, v2)
						max = math.max(max, v2)
					end
				end

				if count < v then
					for i = count + 1, v do
						local lines = data3.Lines
						local frame = Instance.new("Frame")
						frame.Name = tostring(i)
						frame.AnchorPoint = Vector2.new(0.5, 0.5)
						frame.BackgroundColor3 = data._config.PlotLinesColor
						frame.BackgroundTransparency = data._config.PlotLinesTransparency
						frame.BorderSizePixel = 0
						frame.Parent = plot
						table.insert(lines, frame)
					end
				elseif v < count then
					for _ = v + 1, count do
						local v2 = table.remove(data3.Lines)

						if v2 then
							v2:Destroy()
						end
					end
				end

				local v2 = max - min
				local absoluteSize = plot.AbsoluteSize

				for i = 1, v do
					local v3 = value[i]
					local v4 = value[i + 1]
					local v5 = absoluteSize * Vector2.new((i - 1) / v, (max - v3) / v2)
					local v6 = absoluteSize * Vector2.new(i / v, (max - v4) / v2)
					local midpoint = (v5 + v6) / 2
					data3.Lines[i].Size = UDim2.fromOffset((v6 - v5).Magnitude + 1, 1)
					data3.Lines[i].Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
					data3.Lines[i].Rotation = math.atan2(v6.Y - v5.Y, v6.X - v5.X) * 57.29577951308232
				end

				if data3.HoveredLine then
					updateLine(data3, true)
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			p.Tooltip:Destroy()
			data2.discardState(p)
		end
	})

	local function createBlock(parent, p: number)
		local frame = Instance.new("Frame")
		frame.Name = tostring(p)
		frame.BackgroundColor3 = data._config.PlotHistogramColor
		frame.BackgroundTransparency = data._config.PlotHistogramTransparency
		frame.BorderSizePixel = 0
		frame.Parent = parent
		return frame
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearBlock(state)
		if state.HoveredBlock then
			state.HoveredBlock.BackgroundColor3 = data._config.PlotHistogramColor
			state.HoveredBlock.BackgroundTransparency = data._config.PlotHistogramTransparency
			state.HoveredBlock = false
			state.state.hovered:set(nil)
		end
	end

	local function updateBlock(state, flag: boolean?)
		local plot = state.Instance.Background.Plot
		local mouseLocation = data2.getMouseLocation()
		local v = plot.AbsolutePosition - data2.GuiOffset
		local v2 = math.ceil((mouseLocation.X - v.X) / plot.AbsoluteSize.X * #state.Blocks)
		local block = state.Blocks[v2]

		if block then
			if block ~= state.HoveredBlock and not flag and state.HoveredBlock then
				state.HoveredBlock.BackgroundColor3 = data._config.PlotHistogramColor
				state.HoveredBlock.BackgroundTransparency = data._config.PlotHistogramTransparency
				state.HoveredBlock = false
				state.state.hovered:set(nil)
			end

			local v3 = state.state.values.value[v2]

			if v3 then
				local tooltip = state.Tooltip
				local text

				if math.floor(v3) == v3 then
					text = ("%d: %d"):format(v2, v3)
				else
					text = ("%d: %.3f"):format(v2, v3)
				end

				tooltip.Text = text
			end

			state.HoveredBlock = block
			block.BackgroundColor3 = data._config.PlotHistogramHoveredColor
			block.BackgroundTransparency = data._config.PlotHistogramHoveredTransparency

			if flag then
				state.state.hovered.value = v3
			else
				state.state.hovered:set(v3)
			end
		end
	end

	data.WidgetConstructor("PlotHistogram", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Height = 2,
			Min = 3,
			Max = 4,
			TextOverlay = 5,
			BaseLine = 6
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(p)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_PlotHistogram"
			frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			local uIListLayout = data2.UIListLayout(
				frame,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local frame2 = Instance.new("Frame")
			frame2.Name = "Background"
			frame2.Size = UDim2.new(data._config.ContentWidth, UDim.new(1, 0))
			frame2.BackgroundColor3 = data._config.FrameBgColor
			frame2.BackgroundTransparency = data._config.FrameBgTransparency
			data2.applyFrameStyle(frame2)
			frame2.UIPadding.PaddingRight = UDim.new(0, data._config.FramePadding.X - 1)
			frame2.Parent = frame
			local frame3 = Instance.new("Frame")
			frame3.Name = "Plot"
			frame3.Size = UDim2.fromScale(1, 1)
			frame3.BackgroundTransparency = 1
			frame3.BorderSizePixel = 0
			frame3.ClipsDescendants = true
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "OverlayText"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.AnchorPoint = Vector2.new(0.5, 0)
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.Position = UDim2.fromScale(0.5, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = 2
			data2.applyTextStyle(textLabel)
			textLabel.Parent = frame3
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Iris_Tooltip"
			textLabel2.AutomaticSize = Enum.AutomaticSize.XY
			textLabel2.Size = UDim2.fromOffset(0, 0)
			textLabel2.BackgroundColor3 = data._config.PopupBgColor
			textLabel2.BackgroundTransparency = data._config.PopupBgTransparency
			textLabel2.BorderSizePixel = 0
			textLabel2.Visible = false
			data2.applyTextStyle(textLabel2)
			data2.UIStroke(
				textLabel2,
				data._config.PopupBorderSize,
				data._config.BorderActiveColor,
				data._config.BorderActiveTransparency
			)
			data2.UIPadding(textLabel2, data._config.WindowPadding)

			if data._config.PopupRounding > 0 then
				data2.UICorner(textLabel2, data._config.PopupRounding)
			end

			local popupScreenGui = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			textLabel2.Parent = popupScreenGui and popupScreenGui:FindFirstChild("TooltipContainer")
			p.Tooltip = textLabel2
			data2.applyMouseMoved(frame3, function()
				updateBlock(p)
			end)
			data2.applyMouseLeave(frame3, function()
				clearBlock(p) -- equivalent call inferred; original call site unknown
			end)
			frame3.Parent = frame2
			p.Blocks = {}
			p.HoveredBlock = false
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "TextLabel"
			textLabel3.AutomaticSize = Enum.AutomaticSize.XY
			textLabel3.Size = UDim2.fromOffset(0, 0)
			textLabel3.BackgroundTransparency = 1
			textLabel3.BorderSizePixel = 0
			textLabel3.ZIndex = 3
			textLabel3.LayoutOrder = 3
			data2.applyTextStyle(textLabel3)
			textLabel3.Parent = frame
			return frame
		end,
		GenerateState = function(p)
			if p.state.values == nil then
				p.state.values = data._widgetState(p, "values", { 1 })
			end

			if p.state.hovered == nil then
				p.state.hovered = data._widgetState(p, "hovered", nil)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local overlayText = instance.Background.Plot.OverlayText
			textLabel.Text = p.arguments.Text or "Plot Histogram"
			overlayText.Text = p.arguments.TextOverlay or ""
			instance.Size = UDim2.new(1, 0, 0, p.arguments.Height or 0)
		end,
		UpdateState = function(data3)
			if data3.state.hovered.lastChangeTick == data._cycleTick then
				if data3.state.hovered.value then
					data3.Tooltip.Visible = true
				else
					data3.Tooltip.Visible = false
				end
			end

			if data3.state.values.lastChangeTick == data._cycleTick then
				local plot = data3.Instance.Background.Plot
				local value = data3.state.values.value
				local count = #value
				local count2 = #data3.Blocks
				local min = data3.arguments.Min or 1e999
				local max = data3.arguments.Max or -1e999
				local baseLine = data3.arguments.BaseLine or 0

				if min == nil or max == nil then
					for _, v in value do
						min = math.min(min or v, v)
						max = math.max(max or v, v)
					end
				end

				if count2 < count then
					for i = count2 + 1, count do
						local blocks = data3.Blocks
						local frame = Instance.new("Frame")
						frame.Name = tostring(i)
						frame.BackgroundColor3 = data._config.PlotHistogramColor
						frame.BackgroundTransparency = data._config.PlotHistogramTransparency
						frame.BorderSizePixel = 0
						frame.Parent = plot
						table.insert(blocks, frame)
					end
				elseif count < count2 then
					for _ = count + 1, count2 do
						local v = table.remove(data3.Blocks)

						if v then
							v:Destroy()
						end
					end
				end

				local v = max - min
				local uDim = UDim.new(1 / count, -1)

				for i = 1, count do
					local v2 = value[i]

					if v2 >= 0 then
						data3.Blocks[i].Size = UDim2.new(uDim, UDim.new((v2 - baseLine) / v))
						data3.Blocks[i].Position = UDim2.fromScale((i - 1) / count, (max - v2) / v)
					else
						data3.Blocks[i].Size = UDim2.new(uDim, UDim.new((baseLine - v2) / v))
						data3.Blocks[i].Position = UDim2.fromScale((i - 1) / count, (max - baseLine) / v)
					end
				end

				if data3.HoveredBlock then
					updateBlock(data3, true)
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			p.Tooltip:Destroy()
			data2.discardState(p)
		end
	})
end