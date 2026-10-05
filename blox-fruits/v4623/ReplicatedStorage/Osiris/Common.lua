local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local internal = Osiris.Internal
local _utility = internal._utility

local function niceNumber(p: number, flag: boolean)
	if p <= 0 then
		return 1
	end

	local v = math.floor((math.log(p, 10)))
	local v2 = p / 10 ^ v
	local v3

	if flag then
		if v2 < 1.5 then
			v3 = 1
		elseif v2 < 3 then
			v3 = 2
		elseif v2 < 7 then
			v3 = 5
		else
			v3 = 10
		end
	elseif v2 <= 1 then
		v3 = 1
	elseif v2 <= 2 then
		v3 = 2
	elseif v2 <= 5 then
		v3 = 5
	else
		v3 = 10
	end

	return v3 * 10 ^ v
end

local Common = {
	Internal = internal,
	Utility = _utility,
	EPSILON = 1e-9,
	LEGEND_GAP = 4,
	config = function()
		return internal._config
	end,
	formatNumber = function(p: number, p2: string?)
		if p2 ~= nil then
			local success, result = pcall(string.format, p2, p)

			if success and typeof(result) == "string" then
				return result
			end
		end

		local v = math.abs(p)

		if v < 1e-9 then
			return "0"
		end

		if p == math.floor(p) and v < 1000000 then
			return string.format("%.0f", p)
		end

		if v >= 100000 or v < 0.001 then
			return string.format("%.3g", p)
		end

		return string.format("%.2f", p)
	end,
	estimateTextWidth = function(list: string, p: number)
		return #list * p * 0.55
	end,
	buildTicks = function(p: number, p2: number, p3: number)
		local result = {}
		local v = p2 - p

		if v <= 0 then
			return { p }
		end

		local v2 = v / math.clamp(math.floor(p3), 1, 64)
		local v3

		if v2 <= 0 then
			v3 = 1
		else
			local v4 = math.floor((math.log(v2, 10)))
			local v5 = v2 / 10 ^ v4
			v3 = (v5 < 1.5 and 1 or v5 < 3 and 2 or v5 < 7 and 5 or 10) * 10 ^ v4
		end

		if v3 <= 0 then
			return { p }
		end

		local v4 = math.ceil(p / v3 - 1e-9) * v3

		while v4 <= p2 + v3 * 1e-9 and #result < 64 do
			table.insert(result, math.abs(v4) < v3 * 1e-6 and 0 or v4)
			v4 += v3
		end

		if #result == 0 then
			table.insert(result, p)
		end

		return result
	end
}

function Common.numericTicks(list, p: string?, callback)
	local result = table.create(#list)

	for _, v in list do
		table.insert(result, {
			Text = Common.formatNumber(v, p),
			Position = callback(v)
		})
	end

	return result
end

function Common.resizePool(list, p: number, callback, callback2)
	while #list < p do
		table.insert(list, callback(#list + 1))
	end

	while p < #list do
		local v = table.remove(list)

		if v == nil then
			continue
		end

		if callback2 == nil then
			v:Destroy()
		else
			callback2(v)
		end
	end
end

function Common.seriesColor(p: number, p2: number)
	local v = (p - 1) / math.max(1, p2) % 1
	return Color3.fromHSV(v, 0.55, 0.95)
end

function Common.seriesColors(list, p)
	local result = {}

	for k, v in list do
		local v2

		if p ~= nil then
			v2 = p[v]
		end

		if typeof(v2) ~= "Color3" then
			v2 = Common.seriesColor(k, #list)
		end

		result[v] = v2
	end

	return result
end

function Common.sortedKeys(items)
	local result = {}

	for k, item in items do
		if typeof(k) == "string" and item ~= nil then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

function Common.stateValue(p, p2: string)
	local v = p.state[p2]

	if v == nil or typeof(v) ~= "table" then
		return nil
	end

	return v.value
end

function Common.toArguments(items, p)
	if p == nil then
		return nil
	end

	local result = {}

	for k, item in items do
		result[k] = p[item]
	end

	return result
end

function Common.toStates(items)
	if items == nil then
		return nil
	end

	local result = {}
	local count = 0

	for k, item in items do
		if item == nil then
			continue
		end

		result[k] = item
		count += 1
	end

	if count > 0 then
		return result
	end

	return nil
end

function Common.createChrome(name: string, p: number)
	local _config = internal._config
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, p)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	local uIListLayout = _utility.UIListLayout(
		frame,
		Enum.FillDirection.Horizontal,
		UDim.new(0, _config.ItemInnerSpacing.X)
	)
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
	local frame2 = Instance.new("Frame")
	frame2.Name = "Background"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.BackgroundColor3 = _config.FrameBgColor
	frame2.BackgroundTransparency = _config.FrameBgTransparency
	frame2.ClipsDescendants = true
	_utility.applyFrameStyle(frame2)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Legend"
	frame3.BackgroundTransparency = 1
	frame3.BorderSizePixel = 0
	frame3.ClipsDescendants = true
	frame3.Parent = frame2
	local frame4 = Instance.new("Frame")
	frame4.Name = "YAxis"
	frame4.BackgroundTransparency = 1
	frame4.BorderSizePixel = 0
	frame4.Parent = frame2
	local frame5 = Instance.new("Frame")
	frame5.Name = "XAxis"
	frame5.BackgroundTransparency = 1
	frame5.BorderSizePixel = 0
	frame5.Parent = frame2
	local frame6 = Instance.new("Frame")
	frame6.Name = "Plot"
	frame6.BackgroundTransparency = 1
	frame6.BorderSizePixel = 0
	frame6.ClipsDescendants = true
	frame6.Parent = frame2
	local frame7 = Instance.new("Frame")
	frame7.Name = "Grid"
	frame7.Size = UDim2.fromScale(1, 1)
	frame7.BackgroundTransparency = 1
	frame7.BorderSizePixel = 0
	frame7.ZIndex = 1
	frame7.Parent = frame6
	local frame8 = Instance.new("Frame")
	frame8.Name = "Content"
	frame8.Size = UDim2.fromScale(1, 1)
	frame8.BackgroundTransparency = 1
	frame8.BorderSizePixel = 0
	frame8.ZIndex = 2
	frame8.Parent = frame6
	local frame9 = Instance.new("Frame")
	frame9.Name = "Crosshair"
	frame9.BackgroundColor3 = _config.PlotLinesHoveredColor
	frame9.BackgroundTransparency = 0.5
	frame9.BorderSizePixel = 0
	frame9.Visible = false
	frame9.ZIndex = 4
	frame9.Parent = frame6
	local frame10 = Instance.new("Frame")
	frame10.Name = "Cursor"
	frame10.AnchorPoint = Vector2.new(0.5, 0.5)
	frame10.BackgroundColor3 = _config.PlotLinesHoveredColor
	frame10.BorderSizePixel = 0
	frame10.Visible = false
	frame10.ZIndex = 5
	frame10.Parent = frame6
	_utility.UICorner(frame10)
	_utility.UIStroke(frame10, 1, _config.BorderActiveColor, _config.BorderActiveTransparency)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "OverlayText"
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.Size = UDim2.fromOffset(0, 0)
	textLabel.Position = UDim2.fromScale(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.ZIndex = 6
	_utility.applyTextStyle(textLabel)
	textLabel.Parent = frame6
	local textButton = Instance.new("TextButton")
	textButton.Name = "Interact"
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.ZIndex = 7
	textButton.Parent = frame6
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "TextLabel"
	textLabel2.AutomaticSize = Enum.AutomaticSize.XY
	textLabel2.Size = UDim2.fromOffset(0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.BorderSizePixel = 0
	textLabel2.LayoutOrder = 1
	_utility.applyTextStyle(textLabel2)
	textLabel2.Parent = frame
	local uIFlexItem = Instance.new("UIFlexItem")
	uIFlexItem.FlexMode = Enum.UIFlexMode.Shrink
	uIFlexItem.Parent = textLabel2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Iris_Tooltip"
	textLabel3.AutomaticSize = Enum.AutomaticSize.XY
	textLabel3.Size = UDim2.fromOffset(0, 0)
	textLabel3.BackgroundColor3 = _config.PopupBgColor
	textLabel3.BackgroundTransparency = _config.PopupBgTransparency
	textLabel3.BorderSizePixel = 0
	textLabel3.Visible = false
	_utility.applyTextStyle(textLabel3)
	_utility.UIStroke(textLabel3, _config.PopupBorderSize, _config.BorderActiveColor, _config.BorderActiveTransparency)
	_utility.UIPadding(textLabel3, _config.WindowPadding)

	if _config.PopupRounding > 0 then
		_utility.UICorner(textLabel3, _config.PopupRounding)
	end

	local popupScreenGui

	if internal._rootInstance ~= nil then
		popupScreenGui = internal._rootInstance:FindFirstChild("PopupScreenGui")
	end

	local parent

	if popupScreenGui ~= nil then
		parent = popupScreenGui:FindFirstChild("TooltipContainer")
	end

	textLabel3.Parent = parent
	return {
		Root = frame,
		Background = frame2,
		Legend = frame3,
		YAxis = frame4,
		XAxis = frame5,
		Plot = frame6,
		Grid = frame7,
		Content = frame8,
		Cursor = frame10,
		Crosshair = frame9,
		Interact = textButton,
		OverlayText = textLabel,
		TextLabel = textLabel2,
		Tooltip = textLabel3,
		LegendEntries = {},
		LegendRows = {},
		LegendRowHeight = 0,
		LegendWidths = {},
		LegendIconWidths = {},
		LegendSwatchSize = 0,
		LegendIconSize = 0,
		GridLines = {},
		XLabels = {},
		YLabels = {}
	}
end

function Common.updateChrome(data, value: string?, value2: string?, p: number)
	local _config = internal._config
	local visible

	if typeof(value) == "string" then
		visible = #value > 0
	else
		visible = false
	end

	data.TextLabel.Text = not visible and "" or value
	data.TextLabel.Visible = visible
	local background = data.Background
	local v2

	if visible then
		v2 = _config.ContentWidth
	else
		v2 = UDim.new(1, 0)
	end

	background.Size = UDim2.new(v2, UDim.new(1, 0))
	data.OverlayText.Text = value2 or ""
	data.Root.Size = UDim2.new(1, 0, 0, (math.max(0, (math.floor(p)))))
end

function Common.destroyChrome(p)
	p.Root:Destroy()
	p.Tooltip:Destroy()
end

function Common.assertNoShadowedEvents(p: string, p2, items)
	for _, item in items do
		assert(p2[item] == nil, (`{p}: the "{item}" state would shadow the event of the same name, rename one of them`))
	end
end

function Common.publishState(p, p2: string, p3)
	if p.state == nil then
		return false
	end

	local v = p.state[p2]

	if v == nil or typeof(v) ~= "table" then
		return false
	end

	local value = v.value

	if typeof(value) == "table" and internal._deepCompare(value, p3) and internal._deepCompare(p3, value) then
		return false
	end

	v.value = p3
	v.lastChangeTick = internal._cycleTick

	for _, connectedFunction in v.ConnectedFunctions do
		connectedFunction(p3)
	end

	return true
end

Common.CLICKED_EVENT = {
	Init = function(_) end,
	Get = function(p)
		return p.lastClickedTick == internal._cycleTick
	end
}

function Common:registerClick(p2, callback)
	self.lastClickedTick = -1
	_utility.applyButtonClick(p2.Interact, function()
		if self.state == nil then
			return
		end

		local v = callback()
		self.lastClickedTick = internal._cycleTick + 1
		local clickedMark = self.state.clickedMark

		if clickedMark ~= nil and typeof(clickedMark) == "table" then
			clickedMark:set(v)
		end
	end)
end

function Common.showTooltip(p, text: string)
	p.Tooltip.Text = text
	p.Tooltip.Visible = true
end

function Common.hideTooltip(p)
	p.Tooltip.Visible = false
end

local function legendLabel(p, p2: string)
	local labels = p.Labels
	local selected

	if labels ~= nil then
		selected = labels[p2]
	end

	if typeof(selected) == "string" then
		return selected
	end

	return p2
end

function Common:measureLegend(data)
	local _config = internal._config
	local textSize = _config.TextSize
	local legendRowHeight = textSize + 2
	table.clear(self.LegendRows)
	table.clear(self.LegendWidths)
	table.clear(self.LegendIconWidths)
	self.LegendSwatchSize = math.max(4, (math.round(textSize * 0.7)))
	self.LegendIconSize = math.max(0, (math.round(data.IconSize or legendRowHeight)))
	self.LegendRowHeight = legendRowHeight

	if data.Hidden == true or #data.Keys == 0 then
		return 0
	end

	local icons = data.Icons
	local flag = false

	for _, key in data.Keys do
		local v2

		if icons ~= nil then
			v2 = icons[key]
		end

		local legendIconSize

		if v2 == nil or not (self.LegendIconSize > 0) then
			legendIconSize = 0
		else
			local imageRectSize = v2.ImageRectSize

			if imageRectSize == nil or not (imageRectSize.X > 0 and imageRectSize.Y > 0) then
				legendIconSize = self.LegendIconSize
			else
				local v3 = math.min(imageRectSize.X / imageRectSize.Y, 4)
				legendIconSize = math.max(1, (math.round(self.LegendIconSize * v3)))
			end

			flag = true
		end

		self.LegendIconWidths[key] = legendIconSize
		local v3 = self.LegendSwatchSize + 4
		local estimateTextWidth = Common.estimateTextWidth
		local labels = data.Labels
		local v4

		if labels ~= nil then
			v4 = labels[key]
		end

		if typeof(v4) ~= "string" then
			v4 = key
		end

		local v5 = v3 + estimateTextWidth(v4, textSize)

		if legendIconSize > 0 then
			v5 += legendIconSize + 4
		end

		self.LegendWidths[key] = v5
	end

	if flag then
		self.LegendRowHeight = math.max(legendRowHeight, self.LegendIconSize)
	end

	local X = _config.ItemSpacing.X
	local v2 = {}
	local total = 0

	for _, key in data.Keys do
		local legendWidth = self.LegendWidths[key]

		if #v2 > 0 and total + X + legendWidth > data.AvailableWidth then
			table.insert(self.LegendRows, v2)
			v2 = {}
			total = 0
		end

		total += (not (#v2 > 0) and 0 or X) + legendWidth
		table.insert(v2, key)
	end

	if #v2 > 0 then
		table.insert(self.LegendRows, v2)
	end

	return #self.LegendRows * self.LegendRowHeight + _config.ItemSpacing.Y
end

function Common.drawLegend(data, data2)
	local _config = internal._config
	local total = 0

	for _, legendRow in data.LegendRows do
		total += #legendRow
	end

	Common.resizePool(data.LegendEntries, total, function(p: number)
		local frame = Instance.new("Frame")
		frame.Name = `Legend{p}`
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Parent = data.Legend
		local frame2 = Instance.new("Frame")
		frame2.Name = "Swatch"
		frame2.AnchorPoint = Vector2.new(0, 0.5)
		frame2.Position = UDim2.fromScale(0, 0.5)
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		_utility.UICorner(frame2, 2)
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Icon"
		imageLabel.AnchorPoint = Vector2.new(0, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Visible = false
		imageLabel.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Label"
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		_utility.applyTextStyle(textLabel)
		textLabel.Parent = frame
		return {
			Frame = frame,
			Swatch = frame2,
			Icon = imageLabel,
			Label = textLabel
		}
	end, function(p)
		p.Frame:Destroy()
	end)

	if total == 0 then
		return
	end

	local icons = data2.Icons
	local X = _config.ItemSpacing.X
	local legendRowHeight = data.LegendRowHeight
	local legendSwatchSize = data.LegendSwatchSize
	local count = 0

	for k, legendRow in data.LegendRows do
		local total2 = 0

		for _, text in legendRow do
			count += 1
			local legendEntry = data.LegendEntries[count]
			local v2 = data.LegendWidths[text] or 0
			legendEntry.Frame.Position = UDim2.fromOffset(math.round(total2), (k - 1) * legendRowHeight)
			legendEntry.Frame.Size = UDim2.fromOffset(math.ceil(v2), legendRowHeight)
			legendEntry.Swatch.Size = UDim2.fromOffset(legendSwatchSize, legendSwatchSize)
			legendEntry.Swatch.BackgroundColor3 = data2.Colors[text] or _config.TextColor
			local v3 = legendSwatchSize + 4
			local v4

			if icons ~= nil then
				v4 = icons[text]
			end

			local v5 = data.LegendIconWidths[text] or 0

			if v4 == nil or not (v5 > 0) then
				legendEntry.Icon.Visible = false
			else
				legendEntry.Icon.Visible = true
				legendEntry.Icon.Image = v4.Image
				legendEntry.Icon.ImageRectOffset = v4.ImageRectOffset or Vector2.zero
				legendEntry.Icon.ImageRectSize = v4.ImageRectSize or Vector2.zero
				legendEntry.Icon.Size = UDim2.fromOffset(v5, data.LegendIconSize)
				legendEntry.Icon.Position = UDim2.new(0, v3, 0.5, 0)
				v3 += v5 + 4
			end

			local label = legendEntry.Label
			local labels = data2.Labels
			local v6

			if labels ~= nil then
				v6 = labels[text]
			end

			if typeof(v6) == "string" then
				text = v6
			end

			label.Text = text
			legendEntry.Label.Size = UDim2.fromOffset(0, legendRowHeight)
			legendEntry.Label.Position = UDim2.fromOffset(v3, 0)
			total2 += v2 + X
		end
	end
end

function Common.measureAxisWidthFromText(items)
	local _config = internal._config
	local v = 0

	for _, item in items do
		v = math.max(v, Common.estimateTextWidth(item, _config.TextSize))
	end

	return math.ceil(v) + _config.ItemInnerSpacing.X
end

function Common.measureAxisWidth(list, p: string?)
	local v = table.create(#list)

	for _, v2 in list do
		table.insert(v, Common.formatNumber(v2, p))
	end

	return Common.measureAxisWidthFromText(v)
end

function Common.highlight(color: Color3, value: number?)
	return color:Lerp(Color3.new(1, 1, 1), (math.clamp(value or 0.35, 0, 1)))
end

function Common.innerSize(p)
	return p.Background.AbsoluteSize - internal._config.FramePadding * 2
end

function Common.layout(data, data2)
	local innerSize = Common.innerSize(data)
	local legendHeight = data2.LegendHeight
	local topInset = data2.LegendOnBottom and 0 or legendHeight
	local bottomInset = data2.AxisHeight + (not data2.LegendOnBottom and 0 or legendHeight)
	local plotWidth = math.max(0, innerSize.X - data2.AxisWidth)
	local plotHeight = math.max(0, innerSize.Y - topInset - bottomInset)
	data.Legend.Visible = legendHeight > 0
	data.Legend.Size = UDim2.new(1, 0, 0, legendHeight)
	local legend = data.Legend
	local position

	if data2.LegendOnBottom then
		position = UDim2.new(0, 0, 1, -legendHeight)
	else
		position = UDim2.fromOffset(0, 0)
	end

	legend.Position = position
	data.YAxis.Visible = data2.ShowYAxis ~= false
	data.YAxis.Position = UDim2.fromOffset(0, topInset)
	data.YAxis.Size = UDim2.fromOffset(data2.AxisWidth, plotHeight)
	data.XAxis.Visible = data2.ShowXAxis ~= false
	data.XAxis.Position = UDim2.fromOffset(data2.AxisWidth, topInset + plotHeight)
	data.XAxis.Size = UDim2.fromOffset(plotWidth, data2.AxisHeight)
	data.Plot.Position = UDim2.fromOffset(data2.AxisWidth, topInset)
	data.Plot.Size = UDim2.fromOffset(plotWidth, plotHeight)
	return {
		Inner = innerSize,
		PlotWidth = plotWidth,
		PlotHeight = plotHeight,
		TopInset = topInset,
		BottomInset = bottomInset
	}
end

function Common.drawYAxis(p, list, flag: boolean?)
	local _config = internal._config
	local v = _config.TextSize + 2
	Common.resizePool(p.YLabels, flag and 0 or #list, function(p2: number)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = `Y{p2}`
		textLabel.AnchorPoint = Vector2.new(0, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		_utility.applyTextStyle(textLabel)
		textLabel.TextXAlignment = Enum.TextXAlignment.Right
		textLabel.TextColor3 = _config.TextDisabledColor
		textLabel.TextTransparency = _config.TextDisabledTransparency
		textLabel.Parent = p.YAxis
		return textLabel
	end)

	if flag then
		return
	end

	for k, v2 in list do
		local yLabel = p.YLabels[k]
		yLabel.Text = v2.Text
		yLabel.Size = UDim2.new(1, -_config.ItemInnerSpacing.X / 2, 0, v)
		yLabel.Position = UDim2.fromOffset(0, (math.round(v2.Position)))
	end
end

function Common.drawXAxis(p, list, p2: number, p3: number, flag: boolean?)
	local _config = internal._config
	local textSize = _config.TextSize
	Common.resizePool(p.XLabels, flag and 0 or #list, function(p4: number)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = `X{p4}`
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		_utility.applyTextStyle(textLabel)
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextColor3 = _config.TextDisabledColor
		textLabel.TextTransparency = _config.TextDisabledTransparency
		textLabel.Parent = p.XAxis
		return textLabel
	end)

	if flag then
		return
	end

	for k, v in list do
		local xLabel = p.XLabels[k]
		local v2 = Common.estimateTextWidth(v.Text, textSize) / 2
		local v3 = v.Position - v2 < 0 and 0 or p3 < v.Position + v2 and 1 or 0.5
		xLabel.Text = v.Text
		xLabel.Size = UDim2.fromOffset(0, p2)
		xLabel.AnchorPoint = Vector2.new(v3, 0)
		xLabel.Position = UDim2.fromOffset(math.round(v.Position), 0)
	end
end

function Common.drawGrid(p, list, list2, p2: number, p3: number, flag: boolean?)
	local _config = internal._config
	local v = flag and 0 or #list + #list2
	Common.resizePool(p.GridLines, v, function(p4: number)
		local frame = Instance.new("Frame")
		frame.Name = `Grid{p4}`
		frame.BackgroundColor3 = _config.TableBorderLightColor
		frame.BackgroundTransparency = _config.TableBorderLightTransparency
		frame.BorderSizePixel = 0
		frame.ZIndex = 1
		frame.Parent = p.Grid
		return frame
	end)

	if flag then
		return
	end

	local count = 0

	for _, v2 in list do
		count += 1
		local gridLine = p.GridLines[count]
		gridLine.Size = UDim2.fromOffset(p2, 1)
		gridLine.Position = UDim2.fromOffset(0, (math.round(v2)))
	end

	for _, v2 in list2 do
		count += 1
		local gridLine = p.GridLines[count]
		gridLine.Size = UDim2.fromOffset(1, p3)
		gridLine.Position = UDim2.fromOffset(math.round(v2), 0)
	end
end

return Common