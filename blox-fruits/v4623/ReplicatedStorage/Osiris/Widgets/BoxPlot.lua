local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"MinValue",
	"MaxValue",
	"Horizontal",
	"WhiskerRange",
	"BoxPadding",
	"ShowOutliers",
	"ShowMean",
	"ValueTicks",
	"ValueFormat",
	"AxisWidth",
	"NoValueAxis",
	"NoCategoryAxis",
	"NoGrid",
	"NoLegend",
	"LegendOnBottom",
	"LegendIconSize",
	"TextOverlay"
}
local v2 = {
	"values",
	"colors",
	"labels",
	"icons"
}
local internal = Common.Internal
local utility = Common.Utility

-- equivalent calls inferred from this helper; original call sites unknown
local function quantile(list, p: number)
	local count = #list

	if count == 0 then
		return 0
	elseif count == 1 then
		return list[1]
	end

	local v3 = (count - 1) * p + 1
	local v4 = math.floor(v3)
	local v5 = math.min(v4 + 1, count)
	local v6 = v3 - v4
	return list[v4] * (1 - v6) + list[v5] * v6
end

local function summarise(sortedKey: string, items, p: number)
	local v3 = {}
	local total = 0

	for _, item in items do
		if not (typeof(item) == "number" and item == item) then
			continue
		end

		table.insert(v3, item)
		total += item
	end

	if #v3 == 0 then
		return nil
	end

	table.sort(v3)
	local Q1 = quantile(v3, 0.25) -- equivalent call inferred; original call site unknown
	local median = quantile(v3, 0.5) -- equivalent call inferred; original call site unknown
	local Q3 = quantile(v3, 0.75) -- equivalent call inferred; original call site unknown
	local v7 = (Q3 - Q1) * math.max(0, p)
	local v8 = Q1 - v7
	local v9 = Q3 + v7
	local outliers = {}
	local low = 1e999
	local high = -1e999

	for _, v13 in v3 do
		if v13 < v8 or v9 < v13 then
			table.insert(outliers, v13)
		else
			low = math.min(low, v13)
			high = math.max(high, v13)
		end
	end

	if high < low then
		high = Q3
		low = Q1
	end

	return {
		Key = sortedKey,
		Count = #v3,
		Min = v3[1],
		Max = v3[#v3],
		Q1 = Q1,
		Median = median,
		Q3 = Q3,
		Low = low,
		High = high,
		Mean = total / #v3,
		Outliers = outliers
	}
end

local function createSeriesRender(content, name: string, color: Color3)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = content

	local function part(name2: string, zIndex: number)
		local frame2 = Instance.new("Frame")
		frame2.Name = name2
		frame2.BorderSizePixel = 0
		frame2.ZIndex = zIndex
		frame2.Parent = frame
		return frame2
	end

	local v3 = {
		Container = frame,
		LowWhisker = 0,
		HighWhisker = 0,
		LowCap = 0,
		HighCap = 0,
		Box = 0,
		Median = 0,
		Mean = 0,
		Outliers = 0,
		Color = 0
	}
	local frame2 = Instance.new("Frame")
	frame2.Name = "LowWhisker"
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 2
	frame2.Parent = frame
	v3.LowWhisker = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "HighWhisker"
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 2
	frame3.Parent = frame
	v3.HighWhisker = frame3
	local frame4 = Instance.new("Frame")
	frame4.Name = "LowCap"
	frame4.BorderSizePixel = 0
	frame4.ZIndex = 2
	frame4.Parent = frame
	v3.LowCap = frame4
	local frame5 = Instance.new("Frame")
	frame5.Name = "HighCap"
	frame5.BorderSizePixel = 0
	frame5.ZIndex = 2
	frame5.Parent = frame
	v3.HighCap = frame5
	local frame6 = Instance.new("Frame")
	frame6.Name = "Box"
	frame6.BorderSizePixel = 0
	frame6.ZIndex = 3
	frame6.Parent = frame
	v3.Box = frame6
	local frame7 = Instance.new("Frame")
	frame7.Name = "Median"
	frame7.BorderSizePixel = 0
	frame7.ZIndex = 4
	frame7.Parent = frame
	v3.Median = frame7
	local frame8 = Instance.new("Frame")
	frame8.Name = "Mean"
	frame8.BorderSizePixel = 0
	frame8.ZIndex = 5
	frame8.Parent = frame
	v3.Mean = frame8
	v3.Outliers = {}
	v3.Color = color
	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHighlight(state)
	for _, render in state.Renders do
		render.Box.BackgroundColor3 = render.Color
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHover(state)
	if state.Hovered == false then
		return
	end

	state.Hovered = false
	clearHighlight(state) -- equivalent call inferred; original call site unknown
	Common.hideTooltip(state.Chrome)
	local hoveredMark = state.state.hoveredMark

	if hoveredMark ~= nil then
		hoveredMark:set(nil)
	end
end

local function updateHover(state, flag: boolean?)
	local chrome = state.Chrome
	local absoluteSize = chrome.Plot.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local arguments = state.arguments
	local v3 = utility.getMouseLocation() - (chrome.Plot.AbsolutePosition - utility.GuiOffset)
	local v4 = nil
	local outlier2 = nil

	for _, box in state.Boxes do
		for _, outlier in box.Outliers do
			if not ((Vector2.new(outlier.X, outlier.Y) - v3).Magnitude <= 8) then
				continue
			end

			outlier2 = outlier.Value
			v4 = box
			break
		end

		if v4 ~= nil then
			break
		end
	end

	if v4 == nil then
		for _, box in state.Boxes do
			if not (v3.X >= box.X and v3.X <= box.X + box.Width and v3.Y >= box.Y and v3.Y <= box.Y + box.Height) then
				continue
			end

			v4 = box
			break
		end
	end

	if v4 == nil then
		clearHover(state) -- equivalent call inferred; original call site unknown
	else
		local v6 = Common.stateValue(state, "labels") or {}
		local key

		if typeof(v6[v4.Key]) == "string" then
			key = v6[v4.Key]
		else
			key = v4.Key
		end

		clearHighlight(state) -- equivalent call inferred; original call site unknown
		local render = state.Renders[v4.Key]

		if render ~= nil then
			render.Box.BackgroundColor3 = Common.highlight(render.Color)
		end

		local stats = v4.Stats
		local valueFormat = arguments.ValueFormat
		local v7

		if outlier2 == nil then
			v7 = `{key} (n={stats.Count})` .. `\nmax {Common.formatNumber(stats.High, valueFormat)}` .. `\nq3  {Common.formatNumber(stats.Q3, valueFormat)}` .. `\nmed {Common.formatNumber(stats.Median, valueFormat)}` .. `\nq1  {Common.formatNumber(stats.Q1, valueFormat)}` .. `\nmin {Common.formatNumber(stats.Low, valueFormat)}`
		else
			v7 = `{key}\noutlier: {Common.formatNumber(outlier2, valueFormat)}`
		end

		Common.showTooltip(chrome, v7)
		local hovered = {
			Key = v4.Key,
			Index = v4.Index,
			Stats = stats,
			Outlier = outlier2
		}
		state.Hovered = hovered
		local hoveredMark = state.state.hoveredMark

		if hoveredMark ~= nil then
			if flag then
				hoveredMark.value = hovered
			else
				hoveredMark:set(hovered)
			end
		end
	end
end

local function render(data)
	local arguments = data.arguments
	local config = Common.config()
	local chrome = data.Chrome
	local textSize = config.TextSize
	local horizontal = arguments.Horizontal == true
	local v3 = Common.stateValue(data, "values") or {}
	local v4 = Common.stateValue(data, "colors") or {}
	local labels = Common.stateValue(data, "labels") or {}
	local icons = Common.stateValue(data, "icons") or {}
	local sortedKeys = Common.sortedKeys(v3)
	local seriesColors = Common.seriesColors(sortedKeys, v4)
	local v7 = typeof(arguments.WhiskerRange) ~= "number" and 1.5 or arguments.WhiskerRange
	local v8 = {}
	local sortedKeys2 = {}
	local minValue = 1e999
	local maxValue = -1e999

	for _, sortedKey in sortedKeys do
		local v9 = summarise(sortedKey, v3[sortedKey], v7)

		if v9 == nil then
			continue
		end

		v8[sortedKey] = v9
		table.insert(sortedKeys2, sortedKey)
		minValue = math.min(minValue, v9.Min)
		maxValue = math.max(maxValue, v9.Max)
	end

	if maxValue < minValue then
		maxValue = 1
		minValue = 0
	end

	if typeof(arguments.MinValue) == "number" then
		minValue = arguments.MinValue
	end

	if typeof(arguments.MaxValue) == "number" then
		maxValue = arguments.MaxValue
	end

	if maxValue - minValue < Common.EPSILON then
		local midpoint = (maxValue + minValue) / 2
		minValue = midpoint - 0.5
		maxValue = midpoint + 0.5
	end

	local v9 = maxValue - minValue
	local v10 = arguments.NoValueAxis ~= true
	local v11 = arguments.NoCategoryAxis ~= true
	local v12 = not v10 and arguments.NoGrid == true and {} or Common.buildTicks(
		minValue,
		maxValue,
		arguments.ValueTicks or 5
	)
	local v13 = textSize + 2
	local showYAxis

	if horizontal then
		showYAxis = v11
	else
		showYAxis = v10
	end

	local showXAxis

	if horizontal then
		showXAxis = v10
	else
		showXAxis = v11
	end

	local v16 = table.create(#sortedKeys2)

	for _, v17 in sortedKeys2 do
		if typeof(labels[v17]) == "string" then
			v17 = labels[v17]
		end

		table.insert(v16, v17)
	end

	local axisWidth

	if showYAxis then
		if typeof(arguments.AxisWidth) == "number" then
			axisWidth = math.max(0, arguments.AxisWidth)
		elseif horizontal then
			axisWidth = Common.measureAxisWidthFromText(v16)
		else
			axisWidth = Common.measureAxisWidth(v12, arguments.ValueFormat)
		end
	else
		axisWidth = 0
	end

	local axisHeight = not showXAxis and 0 or v13
	local v19 = {
		Keys = sortedKeys2,
		Colors = seriesColors,
		Labels = labels,
		Icons = icons,
		IconSize = arguments.LegendIconSize,
		AvailableWidth = Common.innerSize(chrome).X,
		Hidden = arguments.NoLegend
	}
	local legend = Common.measureLegend(chrome, v19)
	local layout = Common.layout(chrome, {
		AxisWidth = axisWidth,
		AxisHeight = axisHeight,
		LegendHeight = legend,
		LegendOnBottom = arguments.LegendOnBottom,
		ShowYAxis = showYAxis,
		ShowXAxis = showXAxis
	})
	local plotWidth = layout.PlotWidth
	local plotHeight = layout.PlotHeight

	if plotWidth <= 0 or plotHeight <= 0 then
		return
	end

	Common.drawLegend(chrome, v19)
	local v20

	if horizontal then
		v20 = plotWidth
	else
		v20 = plotHeight
	end

	local v21

	if horizontal then
		v21 = plotHeight
	else
		v21 = plotWidth
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toValuePixel(value: number)
		local v22 = (math.clamp(value, minValue, maxValue) - minValue) / v9

		if horizontal then
			return v22 * v20
		end

		return (1 - v22) * v20
	end

	local v22 = v21 / math.max(1, #sortedKeys2)
	local v23 = math.max(2, v22 * (1 - math.clamp(arguments.BoxPadding or 0.4, 0, 0.9)))
	local numericTicks = Common.numericTicks(v12, arguments.ValueFormat, toValuePixel)
	local v24 = {}

	if v11 then
		local v25 = 0

		for _, v26 in v16 do
			v25 = math.max(v25, Common.estimateTextWidth(v26, textSize))
		end

		local v26

		if horizontal then
			v26 = v13 + 2
		else
			v26 = v25 + 6
		end

		local v27 = not (v22 > 0) and 1 or math.max(1, (math.ceil(v26 / v22)))

		for i = 1, #sortedKeys2, v27 do
			table.insert(v24, {
				Text = v16[i],
				Position = (i - 0.5) * v22
			})
		end
	end

	local v25 = {}
	local v26 = {}

	for _, numericTick in numericTicks do
		local v27

		if horizontal then
			v27 = v25
		else
			v27 = v26
		end

		table.insert(v27, numericTick.Position)
	end

	Common.drawGrid(chrome, v26, v25, plotWidth, plotHeight, arguments.NoGrid)

	if horizontal then
		Common.drawYAxis(chrome, v24, not v11)
		Common.drawXAxis(chrome, numericTicks, axisHeight, plotWidth, not v10)
	else
		Common.drawYAxis(chrome, numericTicks, not v10)
		Common.drawXAxis(chrome, v24, axisHeight, plotWidth, not v11)
	end

	for k, render2 in data.Renders do
		if v8[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		data.Renders[k] = nil
	end

	table.clear(data.Boxes)
	local showOutliers = arguments.ShowOutliers ~= false
	local showMean = arguments.ShowMean == true
	local v27 = math.max(3, (math.round(textSize * 0.35)))
	local v28 = math.max(2, v23 * 0.5)

	for k, v29 in sortedKeys2 do
		local stats = v8[v29]
		local seriesColor = seriesColors[v29]
		local render2 = data.Renders[v29]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, v29, seriesColor)
			data.Renders[v29] = render2
		end

		render2.Color = seriesColor
		local v31 = (k - 0.5) * v22
		local v32 = v31 - v23 / 2
		local v33 = v31 - v28 / 2
		local valuePixel = toValuePixel(stats.Q1) -- equivalent call inferred; original call site unknown
		local valuePixel2 = toValuePixel(stats.Q3) -- equivalent call inferred; original call site unknown
		local valuePixel3 = toValuePixel(stats.Median) -- equivalent call inferred; original call site unknown
		local valuePixel4 = toValuePixel(stats.Low) -- equivalent call inferred; original call site unknown
		local valuePixel5 = toValuePixel(stats.High) -- equivalent call inferred; original call site unknown
		local valuePixel6 = toValuePixel(stats.Mean) -- equivalent call inferred; original call site unknown
		local v40 = math.min(valuePixel, valuePixel2)
		local v41 = math.max(1, (math.abs(valuePixel2 - valuePixel)))
		local v42 = v40 + v41
		local v43

		if horizontal then
			v43 = v40
		else
			v43 = v42
		end

		if not horizontal then
			v42 = v40
		end

		local v44 = math.min(valuePixel4, v43)
		local v45 = math.abs(valuePixel4 - v43)
		local v46 = math.min(valuePixel5, v42)
		local v47 = math.abs(valuePixel5 - v42)

		local function place(p, p2: number, p3: number, p4: number, p5: number)
			if horizontal then
				p.Position = UDim2.fromOffset(p2, p5)
				p.Size = UDim2.fromOffset(math.max(1, p3), (math.max(1, p4)))
			else
				p.Position = UDim2.fromOffset(p5, p2)
				p.Size = UDim2.fromOffset(math.max(1, p4), (math.max(1, p3)))
			end
		end

		render2.Box.BackgroundColor3 = seriesColor
		render2.Box.BackgroundTransparency = 0.35
		place(render2.Box, v40, v41, v23, v32)
		render2.Median.BackgroundColor3 = config.TextColor
		place(render2.Median, valuePixel3 - 1, 2, v23, v32)
		render2.LowWhisker.BackgroundColor3 = seriesColor
		place(render2.LowWhisker, v44, v45, 1, v31 - 0.5)
		render2.HighWhisker.BackgroundColor3 = seriesColor
		place(render2.HighWhisker, v46, v47, 1, v31 - 0.5)
		render2.LowCap.BackgroundColor3 = seriesColor
		place(render2.LowCap, valuePixel4 - 0.5, 1, v28, v33)
		render2.HighCap.BackgroundColor3 = seriesColor
		place(render2.HighCap, valuePixel5 - 0.5, 1, v28, v33)
		render2.Mean.Visible = showMean

		if showMean then
			render2.Mean.BackgroundColor3 = Common.highlight(seriesColor, 0.6)
			place(render2.Mean, valuePixel6 - 1, 2, v28, v33)
		end

		local v48 = not showOutliers and {} or stats.Outliers
		Common.resizePool(render2.Outliers, #v48, function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Outlier{p}`
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BorderSizePixel = 0
			frame.ZIndex = 6
			frame.Parent = render2.Container
			utility.UICorner(frame)
			return frame
		end)
		local outliers = {}

		for k2, v51 in v48 do
			local outlier = render2.Outliers[k2]
			local valuePixel7 = toValuePixel(v51) -- equivalent call inferred; original call site unknown
			local v53

			if horizontal then
				v53 = valuePixel7
			else
				v53 = v31
			end

			if horizontal then
				valuePixel7 = v31
			end

			outlier.BackgroundColor3 = seriesColor
			outlier.Size = UDim2.fromOffset(v27, v27)
			outlier.Position = UDim2.fromOffset(v53, valuePixel7)
			table.insert(outliers, {
				Value = v51,
				X = v53,
				Y = valuePixel7
			})
		end

		table.insert(data.Boxes, horizontal and {
			Key = v29,
			Index = k,
			Stats = stats,
			X = v40,
			Y = v32,
			Width = v41,
			Height = v23,
			Outliers = outliers
		} or {
			Key = v29,
			Index = k,
			Stats = stats,
			X = v32,
			Y = v40,
			Width = v23,
			Height = v41,
			Outliers = outliers
		})
	end

	Common.publishState(data, "stats", v8)
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("BoxPlot", events, {
	"values",
	"colors",
	"labels",
	"icons",
	"stats",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.BoxPlot == nil then
	local widgetConstructor = internal.WidgetConstructor
	local args = {}
	local v5 = {
		hasState = true,
		hasChildren = false,
		Args = 0,
		Events = 0,
		Generate = 0,
		GenerateState = 0,
		Update = 0,
		UpdateState = 0,
		Discard = 0
	}

	for k, v7 in v do
		args[v7] = k
	end

	v5.Args = args
	v5.Events = events

	function v5:Generate()
		local chrome = Common.createChrome("Iris_BoxPlot", 240)
		chrome.Cursor.Visible = false
		chrome.Crosshair.Visible = false
		self.Chrome = chrome
		self.Renders = {}
		self.Boxes = {}
		self.Hovered = false
		utility.applyMouseMoved(chrome.Interact, function()
			updateHover(self)
		end)
		utility.applyMouseLeave(chrome.Interact, function()
			clearHover(self) -- equivalent call inferred; original call site unknown
		end)
		Common.registerClick(self, chrome, function()
			updateHover(self)

			if self.Hovered == false then
				return nil
			end

			return self.Hovered
		end)
		chrome.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if self.state == nil or self.state.values == nil then
				return
			end

			render(self)

			if self.Hovered ~= false then
				updateHover(self, true)
			end
		end)
		return chrome.Root
	end

	function v5.GenerateState(p)
		if p.state.values == nil then
			p.state.values = internal._widgetState(p, "values", {})
		end

		if p.state.colors == nil then
			p.state.colors = internal._widgetState(p, "colors", {})
		end

		if p.state.labels == nil then
			p.state.labels = internal._widgetState(p, "labels", {})
		end

		if p.state.icons == nil then
			p.state.icons = internal._widgetState(p, "icons", {})
		end

		if p.state.stats == nil then
			p.state.stats = internal._widgetState(p, "stats", {})
		end

		if p.state.hoveredMark == nil then
			p.state.hoveredMark = internal._widgetState(p, "hoveredMark", nil)
		end

		if p.state.clickedMark == nil then
			p.state.clickedMark = internal._widgetState(p, "clickedMark", nil)
		end
	end

	function v5.Update(data)
		local arguments = data.arguments
		Common.updateChrome(data.Chrome, arguments.Text, arguments.TextOverlay, arguments.Height or 240)

		if data.state ~= nil and data.state.values ~= nil then
			render(data)

			if data.Hovered ~= false then
				updateHover(data, true)
			end
		end
	end

	function v5.UpdateState(data)
		local _cycleTick = internal._cycleTick

		if data.state.hoveredMark.lastChangeTick == _cycleTick then
			data.Chrome.Tooltip.Visible = data.state.hoveredMark.value ~= nil
		end

		local v7 = false

		for _, v9 in v2 do
			local v10 = data.state[v9]

			if not (v10 ~= nil and v10.lastChangeTick == _cycleTick) then
				continue
			end

			v7 = true
			break
		end

		if not v7 then
			return
		end

		render(data)

		if data.Hovered ~= false then
			updateHover(data, true)
		end
	end

	function v5.Discard(p)
		Common.destroyChrome(p.Chrome)
		utility.discardState(p)
	end

	widgetConstructor("BoxPlot", v5)
end

local function BoxPlot(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("BoxPlot", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return BoxPlot