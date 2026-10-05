local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"MinValue",
	"MaxValue",
	"BaseLine",
	"Stacked",
	"Horizontal",
	"BarPadding",
	"GroupPadding",
	"ValueTicks",
	"ValueFormat",
	"AxisWidth",
	"ShowValues",
	"BarRounding",
	"NoValueAxis",
	"NoCategoryAxis",
	"NoGrid",
	"NoBaseLine",
	"NoLegend",
	"LegendOnBottom",
	"LegendIconSize",
	"TextOverlay"
}
local v2 = {
	"values",
	"categories",
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
			local bar = render.Bars[v4.Index]

			if bar ~= nil then
				bar.Frame.BackgroundColor3 = Common.highlight(render.Color)
			end
		end

		Common.showTooltip(chrome, (`{key}\n{v4.Category}: {Common.formatNumber(v4.Value, arguments.ValueFormat)}`))
		local hovered = {
			Key = v4.Key,
			Category = v4.Category,
			Index = v4.Index,
			Value = v4.Value
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
	local stacked = arguments.Stacked == true
	local v3 = Common.stateValue(data, "values") or {}
	local v4 = Common.stateValue(data, "categories") or {}
	local v5 = Common.stateValue(data, "colors") or {}
	local labels = Common.stateValue(data, "labels") or {}
	local icons = Common.stateValue(data, "icons") or {}
	local sortedKeys = Common.sortedKeys(v3)
	local seriesColors = Common.seriesColors(sortedKeys, v5)
	local count = #v4

	for _, sortedKey in sortedKeys do
		count = math.max(count, #v3[sortedKey])
	end

	local v8 = table.create(count)

	for i = 1, count do
		local v9 = v4[i]

		if typeof(v9) ~= "string" then
			v9 = tostring(i)
		end

		table.insert(v8, v9)
	end

	local v9 = typeof(arguments.BaseLine) ~= "number" and 0 or arguments.BaseLine
	local minValue = v9
	local maxValue

	if stacked then
		maxValue = v9

		for i = 1, count do
			local v10 = v9
			local v11 = v10
			v10 = v11

			for _, sortedKey in sortedKeys do
				local v13 = v3[sortedKey][i]

				if typeof(v13) ~= "number" then
					continue
				end

				if v9 <= v13 then
					v11 += v13 - v9
				else
					v10 += v13 - v9
				end
			end

			minValue = math.min(minValue, v10)
			maxValue = math.max(maxValue, v11)
		end
	else
		maxValue = v9

		for _, sortedKey in sortedKeys do
			for i = 1, count do
				local v10 = v3[sortedKey][i]

				if typeof(v10) ~= "number" then
					continue
				end

				minValue = math.min(minValue, v10)
				maxValue = math.max(maxValue, v10)
			end
		end
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

	local v10 = maxValue - minValue
	local v11 = arguments.NoValueAxis ~= true
	local v12 = arguments.NoCategoryAxis ~= true
	local v13 = not v11 and arguments.NoGrid == true and {} or Common.buildTicks(
		minValue,
		maxValue,
		arguments.ValueTicks or 5
	)
	local v14 = textSize + 2
	local showYAxis

	if horizontal then
		showYAxis = v12
	else
		showYAxis = v11
	end

	local showXAxis

	if horizontal then
		showXAxis = v11
	else
		showXAxis = v12
	end

	local axisWidth

	if showYAxis then
		if typeof(arguments.AxisWidth) == "number" then
			axisWidth = math.max(0, arguments.AxisWidth)
		elseif horizontal then
			axisWidth = Common.measureAxisWidthFromText(v8)
		else
			axisWidth = Common.measureAxisWidth(v13, arguments.ValueFormat)
		end
	else
		axisWidth = 0
	end

	local axisHeight = not showXAxis and 0 or v14
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
	local function toValuePixel(p: number)
		local v22 = (p - minValue) / v10

		if horizontal then
			return v22 * v20
		end

		return (1 - v22) * v20
	end

	local v22 = v21 / math.max(1, count)
	local v23 = math.clamp(arguments.BarPadding or 0.2, 0, 0.9)
	local v24 = math.clamp(arguments.GroupPadding or 0.05, 0, 0.9)
	local v25 = v22 * (1 - v23)
	local count2 = #sortedKeys
	local v26 = not stacked and count2 > 1
	local v27

	if v26 then
		v27 = v25 / count2
	else
		v27 = v25
	end

	local v28 = math.max(1, v27 * (not v26 and 1 or 1 - v24))
	local numericTicks = Common.numericTicks(v13, arguments.ValueFormat, toValuePixel)
	local v29 = {}

	if v12 and count > 0 then
		local v30 = 0

		for _, v31 in v8 do
			v30 = math.max(v30, Common.estimateTextWidth(v31, textSize))
		end

		local v31

		if horizontal then
			v31 = v14 + 2
		else
			v31 = v30 + 6
		end

		for i = 1, count, not (v22 > 0) and 1 or math.max(1, (math.ceil(v31 / v22))) do
			table.insert(v29, {
				Text = v8[i],
				Position = (i - 0.5) * v22
			})
		end
	end

	local v30 = {}
	local v31 = {}

	for _, numericTick in numericTicks do
		local v32

		if horizontal then
			v32 = v30
		else
			v32 = v31
		end

		table.insert(v32, numericTick.Position)
	end

	Common.drawGrid(chrome, v31, v30, plotWidth, plotHeight, arguments.NoGrid)

	if horizontal then
		Common.drawYAxis(chrome, v29, not v12)
		Common.drawXAxis(chrome, numericTicks, axisHeight, plotWidth, not v11)
	else
		Common.drawYAxis(chrome, numericTicks, not v11)
		Common.drawXAxis(chrome, v29, axisHeight, plotWidth, not v12)
	end

	local valuePixel = toValuePixel(math.clamp(v9, minValue, maxValue)) -- equivalent call inferred; original call site unknown
	data.BaseLine.Visible = arguments.NoBaseLine ~= true

	if horizontal then
		data.BaseLine.Size = UDim2.fromOffset(1, plotHeight)
		data.BaseLine.Position = UDim2.fromOffset(math.round(valuePixel), 0)
	else
		data.BaseLine.Size = UDim2.fromOffset(plotWidth, 1)
		data.BaseLine.Position = UDim2.fromOffset(0, (math.round(valuePixel)))
	end

	for k, render2 in data.Renders do
		if v3[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		data.Renders[k] = nil
	end

	table.clear(data.Bars)
	local v33 = table.create(count, v9)
	local v34 = table.create(count, v9)

	for i = 1, count do
		v33[i] = v9
		v34[i] = v9
	end

	local v35 = math.max(0, arguments.BarRounding or 0)

	for k, sortedKey in sortedKeys do
		local seriesColor = seriesColors[sortedKey]
		local render2 = data.Renders[sortedKey]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, sortedKey, seriesColor)
			data.Renders[sortedKey] = render2
		end

		render2.Color = seriesColor
		Common.resizePool(render2.Bars, count, function(p: number)
			local frame = Instance.new("Frame")
			frame.Name = `Bar{p}`
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

		for i = 1, count do
			local bar = render2.Bars[i]
			local frame = bar.Frame
			local v37 = v3[sortedKey][i]

			if typeof(v37) == "number" then
				local v38, v39

				if stacked then
					local v40 = v9 <= v37
					local v41

					if v40 then
						v41 = v33[i]
					else
						v41 = v34[i]
					end

					local v42 = v41 + (v37 - v9)

					if v40 then
						v33[i] = v42
					else
						v34[i] = v42
					end

					local v43 = (math.clamp(v41, minValue, maxValue) - minValue) / v10

					if horizontal then
						v38 = v43 * v20
					else
						v38 = (1 - v43) * v20
					end

					local v44 = (math.clamp(v42, minValue, maxValue) - minValue) / v10

					if horizontal then
						v39 = v44 * v20
					else
						v39 = (1 - v44) * v20
					end
				else
					local v40 = (math.clamp(v9, minValue, maxValue) - minValue) / v10

					if horizontal then
						v38 = v40 * v20
					else
						v38 = (1 - v40) * v20
					end

					local v41 = (math.clamp(v37, minValue, maxValue) - minValue) / v10

					if horizontal then
						v39 = v41 * v20
					else
						v39 = (1 - v41) * v20
					end
				end

				local v40 = math.min(v38, v39)
				local v41 = math.abs(v39 - v38)
				local v42 = not v26 and 0 or (k - 1) * v27 + (v27 - v28) / 2
				local v43 = (i - 1) * v22 + (v22 - v25) / 2 + v42
				local v44

				if horizontal then
					v44 = {
						Key = sortedKey,
						Category = v8[i],
						Index = i,
						Value = v37,
						X = v40,
						Y = v43,
						Width = v41,
						Height = v28
					}
				else
					v44 = {
						Key = sortedKey,
						Category = v8[i],
						Index = i,
						Value = v37,
						X = v43,
						Y = v40,
						Width = v28,
						Height = v41
					}
				end

				frame.Visible = true
				frame.BackgroundColor3 = seriesColor
				frame.Position = UDim2.fromOffset(v44.X, v44.Y)
				frame.Size = UDim2.fromOffset(math.max(1, v44.Width), (math.max(1, v44.Height)))
				bar.Corner.CornerRadius = UDim.new(0, v35)
				table.insert(data.Bars, v44)
			else
				frame.Visible = false
			end
		end
	end

	local showValues = arguments.ShowValues == true
	Common.resizePool(data.ValueLabels, showValues and #data.Bars or 0, function(p: number)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = `Value{p}`
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.ZIndex = 3
		utility.applyTextStyle(textLabel)
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.Parent = chrome.Content
		return textLabel
	end)

	if showValues then
		for k, bar in data.Bars do
			local valueLabel = data.ValueLabels[k]
			valueLabel.Text = Common.formatNumber(bar.Value, arguments.ValueFormat)
			valueLabel.Size = UDim2.fromOffset(0, v14)

			if horizontal then
				local v36 = v9 <= bar.Value
				local v38

				if v36 then
					v38 = bar.X + bar.Width + 2
				else
					v38 = bar.X - 2
				end

				valueLabel.AnchorPoint = Vector2.new(v36 and 0 or 1, 0.5)
				valueLabel.Position = UDim2.fromOffset(math.round(v38), (math.round(bar.Y + bar.Height / 2)))
			else
				local v36 = v9 <= bar.Value
				local v38

				if v36 then
					v38 = bar.Y - 2
				else
					v38 = bar.Y + bar.Height + 2
				end

				valueLabel.AnchorPoint = Vector2.new(0.5, v36 and 1 or 0)
				valueLabel.Position = UDim2.fromOffset(math.round(bar.X + bar.Width / 2), (math.round(v38)))
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
Common.assertNoShadowedEvents("BarGraph", events, {
	"values",
	"categories",
	"colors",
	"labels",
	"icons",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.BarGraph == nil then
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
		local config = Common.config()
		local chrome = Common.createChrome("Iris_BarGraph", 220)
		chrome.Cursor.Visible = false
		chrome.Crosshair.Visible = false
		local frame = Instance.new("Frame")
		frame.Name = "BaseLine"
		frame.BackgroundColor3 = config.SeparatorColor
		frame.BackgroundTransparency = config.SeparatorTransparency
		frame.BorderSizePixel = 0
		frame.ZIndex = 1
		frame.Parent = chrome.Grid
		self.Chrome = chrome
		self.Renders = {}
		self.Bars = {}
		self.ValueLabels = {}
		self.BaseLine = frame
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

		if p.state.categories == nil then
			p.state.categories = internal._widgetState(p, "categories", {})
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

	widgetConstructor("BarGraph", v5)
end

local function BarGraph(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("BarGraph", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return BarGraph