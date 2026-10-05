local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"BinCount",
	"BinWidth",
	"MinX",
	"MaxX",
	"MinY",
	"MaxY",
	"Cumulative",
	"Normalize",
	"Stacked",
	"BarPadding",
	"XTicks",
	"YTicks",
	"XFormat",
	"YFormat",
	"AxisWidth",
	"BarRounding",
	"NoXAxis",
	"NoYAxis",
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

local function createSeriesRender(content, name: string, seriesColor: Color3)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = content
	return {
		Container = frame,
		Bars = {},
		Color = seriesColor
	}
end

local function clearHighlight(state)
	for _, render in state.Renders do
		for _, bar in render.Bars do
			bar.Frame.BackgroundColor3 = render.Color
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHover(state)
	if state.Hovered == false then
		return
	end

	state.Hovered = false
	clearHighlight(state)
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

	for _, bar in state.Bars do
		if not (v3.X >= bar.X and v3.X <= bar.X + bar.Width and v3.Y >= bar.Y and v3.Y <= bar.Y + bar.Height) then
			continue
		end

		v4 = bar
		break
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

		clearHighlight(state)
		local render = state.Renders[v4.Key]

		if render ~= nil then
			local bar = render.Bars[v4.Bin]

			if bar ~= nil then
				bar.Frame.BackgroundColor3 = Common.highlight(render.Color)
			end
		end

		local formatNumber = Common.formatNumber(v4.Min, arguments.XFormat)
		local formatNumber2 = Common.formatNumber(v4.Max, arguments.XFormat)
		Common.showTooltip(
			chrome,
			(`{key}\n[{formatNumber}, {formatNumber2})\n{Common.formatNumber(v4.Value, arguments.YFormat)} ({v4.Samples} samples)`)
		)
		local hovered = {
			Key = v4.Key,
			Bin = v4.Bin,
			Min = v4.Min,
			Max = v4.Max,
			Value = v4.Value,
			Samples = v4.Samples
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
	local stacked = arguments.Stacked == true
	local v3 = Common.stateValue(data, "values") or {}
	local v4 = Common.stateValue(data, "colors") or {}
	local labels = Common.stateValue(data, "labels") or {}
	local icons = Common.stateValue(data, "icons") or {}
	local sortedKeys = Common.sortedKeys(v3)
	local seriesColors = Common.seriesColors(sortedKeys, v4)
	local minX = 1e999
	local maxX = -1e999
	local count = 0

	for _, sortedKey in sortedKeys do
		for _, v7 in v3[sortedKey] do
			if not (typeof(v7) == "number" and v7 == v7) then
				continue
			end

			minX = math.min(minX, v7)
			maxX = math.max(maxX, v7)
			count += 1
		end
	end

	if maxX < minX then
		maxX = 1
		minX = 0
	end

	if typeof(arguments.MinX) == "number" then
		minX = arguments.MinX
	end

	if typeof(arguments.MaxX) == "number" then
		maxX = arguments.MaxX
	end

	if maxX - minX < Common.EPSILON then
		local midpoint = (maxX + minX) / 2
		minX = midpoint - 0.5
		maxX = midpoint + 0.5
	end

	local v7 = maxX - minX
	local binCount

	if typeof(arguments.BinWidth) == "number" and arguments.BinWidth > 0 then
		binCount = math.ceil(v7 / arguments.BinWidth)
	elseif typeof(arguments.BinCount) == "number" then
		binCount = math.floor(arguments.BinCount)
	else
		binCount = math.ceil((math.sqrt((math.max(1, count)))))
	end

	local v8 = math.clamp(binCount, 1, 400)
	local v9 = v7 / v8
	local clonesBySortedKey = {}
	local v10 = {}
	local v11 = {}

	for _, sortedKey in sortedKeys do
		local v12 = table.create(v8, 0)

		for i = 1, v8 do
			v12[i] = 0
		end

		local count2 = 0

		for _, v13 in v3[sortedKey] do
			if typeof(v13) ~= "number" or v13 ~= v13 or (v13 < minX or maxX < v13) then
				continue
			end

			local v14 = math.clamp(math.floor((v13 - minX) / v9) + 1, 1, v8)
			v12[v14] += 1
			count2 += 1
		end

		clonesBySortedKey[sortedKey] = table.clone(v12)
		v10[sortedKey] = count2
		v11[sortedKey] = v12
	end

	if arguments.Cumulative == true then
		for _, sortedKey in sortedKeys do
			local v12 = v11[sortedKey]
			local total = 0

			for i = 1, v8 do
				total += v12[i]
				v12[i] = total
			end
		end
	end

	local normalize = arguments.Normalize

	if normalize == "Percent" or normalize == "Density" then
		for _, sortedKey in sortedKeys do
			local v12 = v10[sortedKey]

			if not (v12 > 0) then
				continue
			end

			local v13 = v11[sortedKey]
			local v14

			if normalize == "Percent" then
				v14 = v12 / 100
			else
				v14 = v12 * v9
			end

			if not (v14 > 0) then
				continue
			end

			for i = 1, v8 do
				v13[i] /= v14
			end
		end
	end

	local maxY = 0

	if stacked then
		for i = 1, v8 do
			local total = 0

			for _, sortedKey in sortedKeys do
				total += v11[sortedKey][i]
			end

			maxY = math.max(maxY, total)
		end
	else
		for _, sortedKey in sortedKeys do
			for i = 1, v8 do
				maxY = math.max(maxY, v11[sortedKey][i])
			end
		end
	end

	local v12 = typeof(arguments.MinY) ~= "number" and 0 or arguments.MinY

	if typeof(arguments.MaxY) == "number" then
		maxY = arguments.MaxY
	end

	if maxY - v12 < Common.EPSILON then
		maxY = v12 + 1
	end

	local v13 = maxY - v12
	local showXAxis = arguments.NoXAxis ~= true
	local showYAxis = arguments.NoYAxis ~= true
	local v16 = arguments.NoGrid ~= true
	local v17 = not (showYAxis or v16) and {} or Common.buildTicks(v12, maxY, arguments.YTicks or 5)
	local v18 = not (showXAxis or v16) and {} or Common.buildTicks(minX, maxX, arguments.XTicks or 6)
	local v19 = textSize + 2
	local axisHeight = not showXAxis and 0 or v19
	local axisWidth

	if showYAxis then
		if typeof(arguments.AxisWidth) == "number" then
			axisWidth = math.max(0, arguments.AxisWidth)
		else
			axisWidth = Common.measureAxisWidth(v17, arguments.YFormat)
		end
	else
		axisWidth = 0
	end

	local v22 = {
		Keys = sortedKeys,
		Colors = seriesColors,
		Labels = labels,
		Icons = icons,
		IconSize = arguments.LegendIconSize,
		AvailableWidth = Common.innerSize(chrome).X,
		Hidden = arguments.NoLegend
	}
	local legend = Common.measureLegend(chrome, v22)
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

	Common.drawLegend(chrome, v22)

	local function toPixelX(p: number)
		return (p - minX) / v7 * plotWidth
	end

	local function toPixelY(p: number)
		return (maxY - p) / v13 * plotHeight
	end

	local numericTicks = Common.numericTicks(v17, arguments.YFormat, toPixelY)
	local numericTicks2 = Common.numericTicks(v18, arguments.XFormat, toPixelX)
	local positions = table.create(#numericTicks)

	for _, numericTick in numericTicks do
		table.insert(positions, numericTick.Position)
	end

	local positions2 = table.create(#numericTicks2)

	for _, numericTick in numericTicks2 do
		table.insert(positions2, numericTick.Position)
	end

	Common.drawGrid(chrome, positions, positions2, plotWidth, plotHeight, arguments.NoGrid)
	Common.drawYAxis(chrome, numericTicks, not showYAxis)
	Common.drawXAxis(chrome, numericTicks2, axisHeight, plotWidth, not showXAxis)

	for k, render2 in data.Renders do
		if v3[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		data.Renders[k] = nil
	end

	table.clear(data.Bars)
	local v23 = plotWidth / v8
	local v24 = v23 * (1 - math.clamp(arguments.BarPadding or 0.02, 0, 0.9))
	local count2 = #sortedKeys
	local v25 = not stacked and count2 > 1
	local v27

	if v25 then
		v27 = v24 / count2
	else
		v27 = v24
	end

	local width = math.max(1, v27)
	local v29 = math.clamp(0, v12, maxY)
	local v30 = table.create(v8, 0)

	for i = 1, v8 do
		v30[i] = v29
	end

	local v31 = math.max(0, arguments.BarRounding or 0)

	for k, sortedKey in sortedKeys do
		local seriesColor = seriesColors[sortedKey]
		local render2 = data.Renders[sortedKey]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, sortedKey, seriesColor)
			data.Renders[sortedKey] = render2
		end

		render2.Color = seriesColor
		Common.resizePool(render2.Bars, v8, function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Bin{p}`
			frame.BorderSizePixel = 0
			frame.ZIndex = 2
			frame.Parent = render2.Container
			return {
				Frame = frame,
				Corner = utility.UICorner(frame, 0)
			}
		end, function(p)
			p.Frame:Destroy()
		end)

		for i = 1, v8 do
			local bar = render2.Bars[i]
			local frame = bar.Frame
			local v33 = v11[sortedKey][i]
			local v34, v35

			if stacked then
				local v36 = v30[i]
				local v37 = v36 + v33
				v30[i] = v37
				v34 = (maxY - math.clamp(v36, v12, maxY)) / v13 * plotHeight
				v35 = (maxY - math.clamp(v37, v12, maxY)) / v13 * plotHeight
			else
				v34 = (maxY - v29) / v13 * plotHeight
				v35 = (maxY - math.clamp(v33, v12, maxY)) / v13 * plotHeight
			end

			local v36 = math.min(v34, v35)
			local height = math.abs(v35 - v34)
			local v38 = not v25 and 0 or (k - 1) * width
			local v39 = (i - 1) * v23 + (v23 - v24) / 2 + v38

			if v33 <= 0 then
				frame.Visible = false
			else
				frame.Visible = true
				frame.BackgroundColor3 = seriesColor
				frame.Position = UDim2.fromOffset(v39, v36)
				frame.Size = UDim2.fromOffset(math.max(1, width), (math.max(1, height)))
				bar.Corner.CornerRadius = UDim.new(0, v31)
				table.insert(data.Bars, {
					Key = sortedKey,
					Bin = i,
					Min = minX + (i - 1) * v9,
					Max = minX + i * v9,
					Value = v33,
					Samples = clonesBySortedKey[sortedKey][i],
					X = v39,
					Y = v36,
					Width = width,
					Height = height
				})
			end
		end
	end
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("Histogram", events, {
	"values",
	"colors",
	"labels",
	"icons",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.Histogram == nil then
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
		local chrome = Common.createChrome("Iris_Histogram", 220)
		chrome.Cursor.Visible = false
		chrome.Crosshair.Visible = false
		self.Chrome = chrome
		self.Renders = {}
		self.Bars = {}
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

		if p.state.hoveredMark == nil then
			p.state.hoveredMark = internal._widgetState(p, "hoveredMark", nil)
		end

		if p.state.clickedMark == nil then
			p.state.clickedMark = internal._widgetState(p, "clickedMark", nil)
		end
	end

	function v5.Update(data)
		local arguments = data.arguments
		Common.updateChrome(data.Chrome, arguments.Text, arguments.TextOverlay, arguments.Height or 220)

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

	widgetConstructor("Histogram", v5)
end

local function Histogram(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("Histogram", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return Histogram