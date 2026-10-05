local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	Linear = 1,
	Quadratic = 2,
	Cubic = 3
}
local v2 = {
	"Text",
	"Height",
	"MinX",
	"MaxX",
	"MinY",
	"MaxY",
	"TrendLine",
	"TrendThickness",
	"TrendResolution",
	"TrendExtend",
	"MovingAverageWindow",
	"PointSize",
	"NoPoints",
	"XTicks",
	"YTicks",
	"XFormat",
	"YFormat",
	"AxisWidth",
	"NoXAxis",
	"NoYAxis",
	"NoGrid",
	"NoLegend",
	"LegendOnBottom",
	"LegendIconSize",
	"TextOverlay"
}
local v3 = {
	"values",
	"trends",
	"colors",
	"labels",
	"icons"
}
local internal = Common.Internal
local utility = Common.Utility

local function solve(list, list2)
	local count = #list2

	for i = 1, count do
		local v4 = math.abs(list[i][i])
		local v5 = i

		for i2 = i + 1, count do
			local v6 = math.abs(list[i2][i])

			if not (v4 < v6) then
				continue
			end

			v5 = i2
			v4 = v6
		end

		if v4 < 1e-12 then
			return nil
		end

		if v5 ~= i then
			local v6 = list[v5]
			local v7 = list[i]
			list[i] = v6
			list[v5] = v7
			local v8 = list2[v5]
			local v9 = list2[i]
			list2[i] = v8
			list2[v5] = v9
		end

		local v6 = list[i][i]

		for i2 = i + 1, count do
			local v7 = list[i2][i] / v6

			if v7 == 0 then
				continue
			end

			for i3 = i, count do
				list[i2][i3] -= v7 * list[i][i3]
			end

			list2[i2] -= v7 * list2[i]
		end
	end

	local result = table.create(count, 0)

	for i = count, 1, -1 do
		local v4 = list2[i]

		for i2 = i + 1, count do
			v4 -= list[i][i2] * result[i2]
		end

		result[i] = v4 / list[i][i]
	end

	return result
end

local function fitPolynomial(list, Ys, p: number)
	local count = #list

	if count < p + 1 then
		return nil
	end

	local v4 = p + 1
	local v5 = table.create(p * 2 + 1, 0)

	for i = 1, p * 2 + 1 do
		v5[i] = 0
	end

	local v6 = table.create(v4, 0)

	for i = 1, v4 do
		v6[i] = 0
	end

	for i = 1, count do
		local v7 = list[i]
		local v8 = Ys[i]
		local v9 = 1

		for i2 = 1, p * 2 + 1 do
			v5[i2] += v9
			v9 *= v7
		end

		local v10 = 1

		for i2 = 1, v4 do
			v6[i2] += v8 * v10
			v10 *= v7
		end
	end

	local v7 = table.create(v4)

	for i = 1, v4 do
		local v8 = table.create(v4, 0)

		for i2 = 1, v4 do
			v8[i2] = v5[i + i2 - 1]
		end

		table.insert(v7, v8)
	end

	return (solve(v7, v6))
end

local function meanOf(list)
	if #list == 0 then
		return 0
	end

	local total = 0

	for _, v4 in list do
		total += v4
	end

	return total / #list
end

local function rSquared(Ys, list)
	local v4

	if #Ys == 0 then
		v4 = 0
	else
		local total = 0

		for _, v5 in Ys do
			total += v5
		end

		v4 = total / #Ys
	end

	local total = 0
	local total2 = 0

	for i = 1, #Ys do
		local v5 = Ys[i] - list[i]
		total += v5 * v5
		local v6 = Ys[i] - v4
		total2 += v6 * v6
	end

	if total2 < Common.EPSILON then
		if total < Common.EPSILON then
			return 1
		end

		return 0
	else
		return (math.clamp(1 - total / total2, 0, 1))
	end
end

local function evaluatePolynomial(items, p: number, p2: number)
	local v4 = p - p2
	local v5 = 1
	local total = 0

	for _, item in items do
		total += item * v5
		v5 *= v4
	end

	return total
end

local function fitTrend(list, kind: string, trendResolution: number, movingAverageWindow: number, p2: number, p3: number)
	if kind == "None" or #list < 2 then
		return nil, nil
	end

	local clone = table.clone(list)
	table.sort(clone, function(a, b)
		return a.X < b.X
	end)

	if kind == "MovingAverage" then
		local v4 = math.floor(math.max(1, (math.floor(movingAverageWindow))) / 2)
		local vectors = table.create(#clone)
		local v5 = table.create(#clone)
		local Ys = table.create(#clone)

		for i = 1, #clone do
			local v6 = math.max(1, i - v4)
			local v7 = math.min(#clone, i + v4)
			local total = 0

			for i2 = v6, v7 do
				total += clone[i2].Y
			end

			local v8 = total / (v7 - v6 + 1)
			table.insert(vectors, Vector2.new(clone[i].X, v8))
			table.insert(v5, v8)
			table.insert(Ys, clone[i].Y)
		end

		return {
			Kind = "MovingAverage",
			Coefficients = {},
			XOffset = 0,
			RSquared = rSquared(Ys, v5),
			Points = #clone
		}, vectors
	else
		local v4 = {}
		local Ys = {}
		local v5 = {}

		for _, v6 in clone do
			local X = v6.X
			local Y = v6.Y

			if kind == "Exponential" then
				if Y <= 0 then
					continue
				else
					Y = math.log(Y)
				end
			elseif kind == "Logarithmic" then
				if X <= 0 then
					continue
				else
					X = math.log(X)
				end
			elseif kind == "Power" then
				if X <= 0 or Y <= 0 then
					continue
				end

				X = math.log(X)
				Y = math.log(Y)
			end

			table.insert(v4, X)
			table.insert(Ys, Y)
			table.insert(v5, v6)
		end

		if #v4 < 2 then
			return nil, nil
		end

		local v6 = v[kind]
		local xOffset

		if v6 == nil or not (v6 > 1) or #v4 == 0 then
			xOffset = 0
		else
			local total = 0

			for _, v8 in v4 do
				total += v8
			end

			xOffset = total / #v4
		end

		if xOffset ~= 0 then
			for i = 1, #v4 do
				v4[i] -= xOffset
			end
		end

		local coefficients = fitPolynomial(v4, Ys, v6 == nil and 1 or v6)

		if coefficients == nil then
			return nil, nil
		end

		local fn

		if v6 == nil then
			if kind == "Exponential" then
				local v9 = math.exp(coefficients[1])
				local v10 = coefficients[2]

				fn = function(p4: number)
					return v9 * math.exp(v10 * p4)
				end

				coefficients = { v9, v10 }
			elseif kind == "Logarithmic" then
				local v9 = coefficients[1]
				local v10 = coefficients[2]

				fn = function(p4: number)
					if p4 > 0 then
						return v9 + v10 * math.log(p4)
					end

					return (0 / 0)
				end

				coefficients = { v9, v10 }
			else
				local v9 = math.exp(coefficients[1])
				local v10 = coefficients[2]

				fn = function(p4: number)
					if p4 > 0 then
						return v9 * p4 ^ v10
					end

					return (0 / 0)
				end

				coefficients = { v9, v10 }
			end
		else
			fn = function(p4: number)
				local v9 = coefficients
				local v10 = p4 - xOffset
				local v11 = 1
				local total = 0

				for _, v12 in v9 do
					total += v12 * v11
					v11 *= v10
				end

				return total
			end
		end

		local Ys2 = table.create(#v5)
		local v9 = table.create(#v5)

		for _, v10 in v5 do
			table.insert(Ys2, v10.Y)
			table.insert(v9, fn(v10.X))
		end

		local v10 = kind == "Linear" and 1 or math.clamp(math.floor(trendResolution), 2, 512)
		local vectors = table.create(v10 + 1)

		for i = 0, v10 do
			local v11 = p2 + (p3 - p2) * (i / v10)
			local v12 = fn(v11)

			if v12 == v12 and math.abs(v12) ~= 1e999 then
				table.insert(vectors, Vector2.new(v11, v12))
			end
		end

		if #vectors < 2 then
			return nil, nil
		end

		return {
			Kind = kind,
			Coefficients = coefficients,
			XOffset = xOffset,
			RSquared = rSquared(Ys2, v9),
			Points = #v5
		}, vectors
	end
end

local function createSeriesRender(content, name: string, seriesColor: Color3)
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = name
	canvasGroup.Size = UDim2.fromScale(1, 1)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0
	canvasGroup.Parent = content
	return {
		Container = canvasGroup,
		Points = {},
		Trend = {},
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
	local v4 = utility.getMouseLocation() - (chrome.Plot.AbsolutePosition - utility.GuiOffset)
	local v5 = 1e999
	local v6 = nil
	local v7 = nil

	for k, render in state.Renders do
		for _, sample in render.Samples do
			local magnitude = (Vector2.new(sample.PX, sample.PY) - v4).Magnitude

			if not (magnitude < v5) then
				continue
			end

			v7 = sample
			v6 = k
			v5 = magnitude
		end
	end

	if v6 == nil or v7 == nil or v5 > 24 then
		clearHover(state) -- equivalent call inferred; original call site unknown
	else
		local render = state.Renders[v6]
		local v8 = Common.stateValue(state, "labels") or {}
		local v9

		if typeof(v8[v6]) == "string" then
			v9 = v8[v6]
		else
			v9 = v6
		end

		chrome.Cursor.Visible = true
		chrome.Cursor.BackgroundColor3 = render.Color
		chrome.Cursor.Position = UDim2.fromOffset(v7.PX, v7.PY)
		chrome.Crosshair.Visible = false
		Common.showTooltip(
			chrome,
			(`{v9} #{v7.Index}\nX: {Common.formatNumber(v7.X, arguments.XFormat)}\nY: {Common.formatNumber(v7.Y, arguments.YFormat)}`)
		)
		local hovered = {
			Key = v6,
			Index = v7.Index,
			X = v7.X,
			Y = v7.Y
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
	local v4 = Common.stateValue(data, "values") or {}
	local v5 = Common.stateValue(data, "trends") or {}
	local v6 = Common.stateValue(data, "colors") or {}
	local labels = Common.stateValue(data, "labels") or {}
	local icons = Common.stateValue(data, "icons") or {}
	local sortedKeys = Common.sortedKeys(v4)
	local seriesColors = Common.seriesColors(sortedKeys, v6)
	local minX = 1e999
	local v9 = -1e999
	local minY = 1e999
	local maxY = -1e999
	local v10 = {}

	for _, sortedKey in sortedKeys do
		local v11 = {}

		for k, v12 in v4[sortedKey] do
			if typeof(v12) ~= "Vector2" then
				continue
			end

			local X = v12.X
			local Y = v12.Y

			if not (X == X and Y == Y) then
				continue
			end

			table.insert(v11, {
				X = X,
				Y = Y,
				Index = k,
				PX = 0,
				PY = 0
			})
			minX = math.min(minX, X)
			v9 = math.max(v9, X)
			minY = math.min(minY, Y)
			maxY = math.max(maxY, Y)
		end

		v10[sortedKey] = v11
	end

	if v9 < minX then
		minX = 0
		v9 = 1
	end

	if maxY < minY then
		maxY = 1
		minY = 0
	end

	local v11 = minX

	if typeof(arguments.MinX) == "number" then
		minX = arguments.MinX
	end

	local maxX

	if typeof(arguments.MaxX) == "number" then
		maxX = arguments.MaxX
	else
		maxX = v9
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

	local v12 = maxX - minX
	local v13 = maxY - minY
	local showXAxis = arguments.NoXAxis ~= true
	local showYAxis = arguments.NoYAxis ~= true
	local v16 = arguments.NoGrid ~= true
	local v17 = not (showYAxis or v16) and {} or Common.buildTicks(minY, maxY, arguments.YTicks or 5)
	local v18 = not (showXAxis or v16) and {} or Common.buildTicks(minX, maxX, arguments.XTicks or 5)
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
		return (p - minX) / v12 * plotWidth
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
		if v4[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		data.Renders[k] = nil
	end

	local trendLine = arguments.TrendLine or "None"
	local v23 = math.max(1, (math.floor(arguments.TrendThickness or 2)))
	local trendResolution = arguments.TrendResolution or 48
	local movingAverageWindow = arguments.MovingAverageWindow or 5

	if arguments.TrendExtend then
		v11 = minX
	end

	if arguments.TrendExtend then
		v9 = maxX
	end

	local v24 = math.max(2, (math.floor(arguments.PointSize or math.max(3, (math.round(textSize * 0.45))))))
	local v25 = {}

	for _, sortedKey in sortedKeys do
		local seriesColor = seriesColors[sortedKey]
		local render2 = data.Renders[sortedKey]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, sortedKey, seriesColor)
			data.Renders[sortedKey] = render2
		end

		render2.Color = seriesColor
		local samples = v10[sortedKey]

		for _, v27 in samples do
			v27.PX = (v27.X - minX) / v12 * plotWidth
			v27.PY = (maxY - v27.Y) / v13 * plotHeight
		end

		render2.Samples = samples
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
			for k, v28 in samples do
				local point = render2.Points[k]
				point.BackgroundColor3 = seriesColor
				point.Size = UDim2.fromOffset(v24, v24)
				point.Position = UDim2.fromOffset(v28.PX, v28.PY)
			end
		end

		local v28

		if typeof(v5[sortedKey]) == "string" then
			v28 = v5[sortedKey]
		else
			v28 = trendLine
		end

		local v29, v30 = fitTrend(samples, v28, trendResolution, movingAverageWindow, v11, v9)

		if v29 ~= nil then
			v25[sortedKey] = v29
		end

		local v31 = v30 == nil and 0 or #v30 - 1
		local v32 = render2
		Common.resizePool(render2.Trend, v31, function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Trend{p}`
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BorderSizePixel = 0
			frame.ZIndex = 4
			frame.Parent = v32.Container
			return frame
		end)

		if v30 == nil then
			continue
		end

		local backgroundColor = Common.highlight(seriesColor, 0.25)

		for i = 1, v31 do
			local vector = Vector2.new((v30[i].X - minX) / v12 * plotWidth, (maxY - v30[i].Y) / v13 * plotHeight)
			local vector2 = Vector2.new(
				(v30[i + 1].X - minX) / v12 * plotWidth,
				(maxY - v30[i + 1].Y) / v13 * plotHeight
			)
			local v34 = vector2 - vector
			local midpoint = (vector + vector2) / 2
			local v36 = render2.Trend[i]
			v36.BackgroundColor3 = backgroundColor
			v36.Size = UDim2.fromOffset(v34.Magnitude + 1, v23)
			v36.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
			v36.Rotation = math.deg((math.atan2(v34.Y, v34.X)))
		end
	end

	chrome.Cursor.Size = UDim2.fromOffset(v24 * 2, v24 * 2)
	Common.publishState(data, "fits", v25)
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("ScatterPlot", events, {
	"values",
	"trends",
	"colors",
	"labels",
	"icons",
	"fits",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.ScatterPlot == nil then
	local widgetConstructor = internal.WidgetConstructor
	local args = {}
	local v6 = {
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

	for k, v8 in v2 do
		args[v8] = k
	end

	v6.Args = args
	v6.Events = events

	function v6:Generate()
		local chrome = Common.createChrome("Iris_ScatterPlot", 240)
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

	function v6.GenerateState(p)
		if p.state.values == nil then
			p.state.values = internal._widgetState(p, "values", {})
		end

		if p.state.trends == nil then
			p.state.trends = internal._widgetState(p, "trends", {})
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

		if p.state.fits == nil then
			p.state.fits = internal._widgetState(p, "fits", {})
		end

		if p.state.hoveredMark == nil then
			p.state.hoveredMark = internal._widgetState(p, "hoveredMark", nil)
		end

		if p.state.clickedMark == nil then
			p.state.clickedMark = internal._widgetState(p, "clickedMark", nil)
		end
	end

	function v6.Update(data)
		local arguments = data.arguments
		Common.updateChrome(data.Chrome, arguments.Text, arguments.TextOverlay, arguments.Height or 240)

		if data.state ~= nil and data.state.values ~= nil then
			render(data)

			if data.Hovered ~= false then
				updateHover(data, true)
			end
		end
	end

	function v6.UpdateState(data)
		local _cycleTick = internal._cycleTick

		if data.state.hoveredMark.lastChangeTick == _cycleTick then
			local visible = data.state.hoveredMark.value ~= nil
			data.Chrome.Tooltip.Visible = visible
			data.Chrome.Cursor.Visible = visible
		end

		local v8 = false

		for _, v10 in v3 do
			local v11 = data.state[v10]

			if not (v11 ~= nil and v11.lastChangeTick == _cycleTick) then
				continue
			end

			v8 = true
			break
		end

		if not v8 then
			return
		end

		render(data)

		if data.Hovered ~= false then
			updateHover(data, true)
		end
	end

	function v6.Discard(p)
		Common.destroyChrome(p.Chrome)
		utility.discardState(p)
	end

	widgetConstructor("ScatterPlot", v6)
end

local function ScatterPlot(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("ScatterPlot", Common.toArguments(v2, data.Arguments), Common.toStates(data.States)))
end

return ScatterPlot