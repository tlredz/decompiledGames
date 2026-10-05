local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"MinX",
	"MaxX",
	"MinY",
	"MaxY",
	"BaselineZero",
	"Resolution",
	"XTicks",
	"YTicks",
	"XFormat",
	"YFormat",
	"AxisWidth",
	"NoXAxis",
	"NoYAxis",
	"NoGrid",
	"NoPoints",
	"NoLines",
	"NoLegend",
	"LegendOnBottom",
	"TextOverlay",
	"LegendIconSize"
}
local v2 = {
	"values",
	"xValues",
	"seriesXValues",
	"colors",
	"labels",
	"icons"
}
local internal = Common.Internal
local utility = Common.Utility

local function sampleSeries(list, p, p2: number)
	local result = {}
	local count = #list

	if count == 0 then
		return result
	end

	local v3 = math.max(1, (math.ceil(count / p2)))
	local v4 = {}

	for i = 1, count, v3 do
		local v5 = math.min(i + v3 - 1, count)
		local v6

		if v5 == i then
			v6 = list[i]
		else
			table.clear(v4)

			for i2 = i, v5 do
				table.insert(v4, list[i2])
			end

			table.sort(v4)
			v6 = v4[math.clamp(math.round(#v4 * 0.55), 1, #v4)]
		end

		if typeof(v6) ~= "number" then
			continue
		end

		local v7 = math.floor((i + v5) / 2)
		local v8

		if p == nil or typeof(p[v7]) ~= "number" then
			v8 = v7
		else
			v8 = p[v7]
		end

		table.insert(result, {
			X = v8,
			Y = v6,
			Index = v7,
			PX = 0,
			PY = 0
		})
	end

	table.sort(result, function(a, b)
		return a.X < b.X
	end)
	return result
end

local function createSeriesRender(content, name: string, seriesColor: Color3)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = content
	return {
		Container = frame,
		Points = {},
		Lines = {},
		Samples = {},
		Color = seriesColor
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHover(state)
	if state.Hovered == false then
		return
	end

	state.Hovered = false
	state.Chrome.Cursor.Visible = false
	state.Chrome.Crosshair.Visible = false
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
	local v4 = 1e999
	local v5 = nil
	local v6 = nil

	for k, render in state.Renders do
		for _, sample in render.Samples do
			local magnitude = (Vector2.new(sample.PX, sample.PY) - v3).Magnitude

			if not (magnitude < v4) then
				continue
			end

			v6 = sample
			v5 = k
			v4 = magnitude
		end
	end

	if v5 == nil or v6 == nil or v4 > 32 then
		clearHover(state) -- equivalent call inferred; original call site unknown
	else
		local render = state.Renders[v5]
		local v7 = Common.stateValue(state, "labels") or {}
		local v8

		if typeof(v7[v5]) == "string" then
			v8 = v7[v5]
		else
			v8 = v5
		end

		chrome.Cursor.Visible = true
		chrome.Cursor.BackgroundColor3 = render.Color
		chrome.Cursor.Position = UDim2.fromOffset(v6.PX, v6.PY)
		chrome.Crosshair.Visible = true
		chrome.Crosshair.Position = UDim2.fromOffset(v6.PX, 0)
		chrome.Crosshair.Size = UDim2.fromOffset(1, absoluteSize.Y)
		Common.showTooltip(
			chrome,
			(`{v8}\nX: {Common.formatNumber(v6.X, arguments.XFormat)}\nY: {Common.formatNumber(v6.Y, arguments.YFormat)}`)
		)
		local hovered = {
			Key = v5,
			Index = v6.Index,
			X = v6.X,
			Y = v6.Y
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
	local v3 = Common.stateValue(data, "values") or {}
	local stateValue = Common.stateValue(data, "xValues")

	if stateValue ~= nil and #stateValue == 0 then
		stateValue = nil
	end

	local v4 = Common.stateValue(data, "seriesXValues") or {}
	local v5 = Common.stateValue(data, "colors") or {}
	local labels = Common.stateValue(data, "labels") or {}
	local icons = Common.stateValue(data, "icons") or {}
	local sortedKeys = Common.sortedKeys(v3)
	local seriesColors = Common.seriesColors(sortedKeys, v5)
	local v8 = math.clamp(math.floor(arguments.Resolution or 100), 2, 1000)
	local v9 = {}
	local minX = 1e999
	local maxX = -1e999
	local minY = 1e999
	local maxY = -1e999

	for _, sortedKey in sortedKeys do
		local v10 = sampleSeries(v3[sortedKey], v4[sortedKey] or stateValue, v8)
		v9[sortedKey] = v10

		for _, v11 in v10 do
			minX = math.min(minX, v11.X)
			maxX = math.max(maxX, v11.X)
			minY = math.min(minY, v11.Y)
			maxY = math.max(maxY, v11.Y)
		end
	end

	if maxX < minX then
		maxX = 1
		minX = 0
	end

	if maxY < minY then
		minY = 0
		maxY = 1
	end

	if arguments.BaselineZero then
		minY = math.min(0, minY)
		maxY = math.max(0, maxY)
	end

	if typeof(arguments.MinX) == "number" then
		minX = arguments.MinX
	end

	if typeof(arguments.MaxX) == "number" then
		maxX = arguments.MaxX
	end

	if typeof(arguments.MinY) == "number" then
		minY = arguments.MinY
	end

	if typeof(arguments.MaxY) == "number" then
		maxY = arguments.MaxY
	end

	if maxX - minX < Common.EPSILON then
		local midpoint = (maxX + minX) / 2
		minX = midpoint - 0.5
		maxX = midpoint + 0.5
	end

	if maxY - minY < Common.EPSILON then
		local midpoint = (maxY + minY) / 2
		minY = midpoint - 0.5
		maxY = midpoint + 0.5
	end

	local v10 = maxX - minX
	local v11 = maxY - minY
	local v12 = not (arguments.NoYAxis and arguments.NoGrid)
	local v13 = not (arguments.NoXAxis and arguments.NoGrid)
	local v14 = not v12 and {} or Common.buildTicks(minY, maxY, arguments.YTicks or 5)
	local v15 = not v13 and {} or Common.buildTicks(minX, maxX, arguments.XTicks or 5)
	local v16 = textSize + 2
	local axisHeight = arguments.NoXAxis and 0 or v16
	local axisWidth

	if arguments.NoYAxis then
		axisWidth = 0
	elseif typeof(arguments.AxisWidth) == "number" then
		axisWidth = math.max(0, arguments.AxisWidth)
	else
		axisWidth = Common.measureAxisWidth(v14, arguments.YFormat)
	end

	local v19 = {
		Keys = sortedKeys,
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
		ShowYAxis = not arguments.NoYAxis,
		ShowXAxis = not arguments.NoXAxis
	})
	local plotWidth = layout.PlotWidth
	local plotHeight = layout.PlotHeight

	if plotWidth <= 0 or plotHeight <= 0 then
		return
	end

	Common.drawLegend(chrome, v19)

	local function toPixelX(p: number)
		return (p - minX) / v10 * plotWidth
	end

	local function toPixelY(p: number)
		return (maxY - p) / v11 * plotHeight
	end

	local numericTicks = Common.numericTicks(v14, arguments.YFormat, toPixelY)
	local numericTicks2 = Common.numericTicks(v15, arguments.XFormat, toPixelX)
	local positions = table.create(#numericTicks)

	for _, numericTick in numericTicks do
		table.insert(positions, numericTick.Position)
	end

	local positions2 = table.create(#numericTicks2)

	for _, numericTick in numericTicks2 do
		table.insert(positions2, numericTick.Position)
	end

	Common.drawGrid(chrome, positions, positions2, plotWidth, plotHeight, arguments.NoGrid)
	Common.drawYAxis(chrome, numericTicks, arguments.NoYAxis)
	Common.drawXAxis(chrome, numericTicks2, axisHeight, plotWidth, arguments.NoXAxis)

	for k, render2 in data.Renders do
		if v3[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		data.Renders[k] = nil
	end

	local v20 = math.max(2, (math.round(textSize * 0.2)))

	for _, sortedKey in sortedKeys do
		local seriesColor = seriesColors[sortedKey]
		local render2 = data.Renders[sortedKey]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, sortedKey, seriesColor)
			data.Renders[sortedKey] = render2
		end

		render2.Color = seriesColor
		local samples = v9[sortedKey]

		for _, v22 in samples do
			v22.PX = (v22.X - minX) / v10 * plotWidth
			v22.PY = (maxY - v22.Y) / v11 * plotHeight
		end

		render2.Samples = samples
		local v22

		if #samples > 1 then
			v22 = plotWidth / (#samples - 1)
		else
			v22 = plotWidth
		end

		local v23 = math.clamp(math.round(v22 * 0.45), 2, v20 * 2)
		Common.resizePool(render2.Points, arguments.NoPoints and 0 or #samples, function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Point{p}`
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BorderSizePixel = 0
			frame.ZIndex = 3
			frame.Parent = render2.Container
			utility.UICorner(frame)
			return frame
		end)

		if not arguments.NoPoints then
			for k, v25 in samples do
				local point = render2.Points[k]
				point.BackgroundColor3 = seriesColor
				point.Size = UDim2.fromOffset(v23, v23)
				point.Position = UDim2.fromOffset(v25.PX, v25.PY)
			end
		end

		local v25 = render2
		Common.resizePool(render2.Lines, arguments.NoLines and 0 or math.max(0, #samples - 1), function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Line{p}`
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BorderSizePixel = 0
			frame.ZIndex = 2
			frame.Parent = v25.Container
			return frame
		end)

		if arguments.NoLines then
			continue
		end

		for i = 1, #samples - 1 do
			local vector = Vector2.new(samples[i].PX, samples[i].PY)
			local vector2 = Vector2.new(samples[i + 1].PX, samples[i + 1].PY)
			local v26 = vector2 - vector
			local midpoint = (vector + vector2) / 2
			local line = render2.Lines[i]
			line.BackgroundColor3 = seriesColor
			line.Size = UDim2.fromOffset(v26.Magnitude + 1, 1)
			line.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
			line.Rotation = math.deg((math.atan2(v26.Y, v26.X)))
		end
	end

	chrome.Cursor.Size = UDim2.fromOffset(v20 * 3, v20 * 3)
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("Graph", events, {
	"values",
	"xValues",
	"seriesXValues",
	"colors",
	"labels",
	"icons",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.Graph == nil then
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
		local chrome = Common.createChrome("Iris_Graph", 200)
		self.Chrome = chrome
		self.Renders = {}
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

		if p.state.xValues == nil then
			p.state.xValues = internal._widgetState(p, "xValues", {})
		end

		if p.state.seriesXValues == nil then
			p.state.seriesXValues = internal._widgetState(p, "seriesXValues", {})
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
		Common.updateChrome(data.Chrome, arguments.Text, arguments.TextOverlay, arguments.Height or 200)

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
			local visible = data.state.hoveredMark.value ~= nil
			data.Chrome.Tooltip.Visible = visible
			data.Chrome.Cursor.Visible = visible
			data.Chrome.Crosshair.Visible = visible
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

	widgetConstructor("Graph", v5)
end

local function Graph(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("Graph", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return Graph