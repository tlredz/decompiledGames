local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"Donut",
	"StartAngle",
	"Clockwise",
	"SemiCircleImage",
	"Radius",
	"SliceGap",
	"ShowPercentages",
	"LabelMinShare",
	"ValueFormat",
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

local function createSeriesRender(content, key: string, seriesColor: Color3)
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = key
	canvasGroup.Size = UDim2.fromScale(1, 1)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.BorderSizePixel = 0
	canvasGroup.Parent = content
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Share"
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Size = UDim2.fromOffset(0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.ZIndex = 8
	textLabel.Visible = false
	utility.applyTextStyle(textLabel)
	textLabel.Parent = canvasGroup
	return {
		Container = canvasGroup,
		Wedges = {},
		Label = textLabel,
		Color = seriesColor
	}
end

local function clearHighlight(state)
	for _, render in state.Renders do
		for _, wedge in render.Wedges do
			wedge.Image.ImageColor3 = render.Color
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

local function sliceAt(data, point: Vector2)
	local v3 = point - data.Centre
	local magnitude = v3.Magnitude

	if magnitude < data.InnerRadius or data.OuterRadius < magnitude then
		return nil
	end

	local v4 = math.deg((math.atan2(v3.Y, v3.X)))

	for _, slice in data.Slices do
		if (v4 - slice.StartAngle) * data.Direction % 360 <= slice.Sweep then
			return slice
		end
	end

	return nil
end

local function updateHover(state, flag: boolean?)
	local chrome = state.Chrome
	local absoluteSize = chrome.Plot.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local arguments = state.arguments
	local v4 = sliceAt(state, utility.getMouseLocation() - (chrome.Plot.AbsolutePosition - utility.GuiOffset))

	if v4 == nil then
		clearHover(state) -- equivalent call inferred; original call site unknown
	else
		local v5 = Common.stateValue(state, "labels") or {}
		local key

		if typeof(v5[v4.Key]) == "string" then
			key = v5[v4.Key]
		else
			key = v4.Key
		end

		clearHighlight(state)
		local render = state.Renders[v4.Key]

		if render ~= nil then
			local imageColor = Common.highlight(render.Color)

			for _, wedge in render.Wedges do
				wedge.Image.ImageColor3 = imageColor
			end
		end

		Common.showTooltip(
			chrome,
			(`{key}\n{Common.formatNumber(v4.Value, arguments.ValueFormat)} ({string.format("%.1f", v4.Share * 100)}%)`)
		)
		local hovered = {
			Key = v4.Key,
			Value = v4.Value,
			Share = v4.Share,
			StartAngle = v4.StartAngle,
			EndAngle = v4.StartAngle + v4.Sweep * state.Direction
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

local function render(state)
	local arguments = state.arguments
	local config = Common.config()
	local chrome = state.Chrome
	local v3 = Common.stateValue(state, "values") or {}
	local v4 = Common.stateValue(state, "colors") or {}
	local labels = Common.stateValue(state, "labels") or {}
	local icons = Common.stateValue(state, "icons") or {}
	local sortedKeys = Common.sortedKeys(v3)
	local sortedKeys2 = {}
	local total = 0

	for _, sortedKey in sortedKeys do
		local v7 = v3[sortedKey]

		if not (typeof(v7) == "number" and v7 == v7 and v7 > 0) then
			continue
		end

		table.insert(sortedKeys2, sortedKey)
		total += v7
	end

	local seriesColors = Common.seriesColors(sortedKeys2, v4)
	local v7 = {
		Keys = sortedKeys2,
		Colors = seriesColors,
		Labels = labels,
		Icons = icons,
		IconSize = arguments.LegendIconSize,
		AvailableWidth = Common.innerSize(chrome).X,
		Hidden = arguments.NoLegend
	}
	local legend = Common.measureLegend(chrome, v7)
	local layout = Common.layout(chrome, {
		AxisWidth = 0,
		AxisHeight = 0,
		LegendHeight = legend,
		LegendOnBottom = arguments.LegendOnBottom,
		ShowYAxis = false,
		ShowXAxis = false
	})
	local plotWidth = layout.PlotWidth
	local plotHeight = layout.PlotHeight

	if plotWidth <= 0 or plotHeight <= 0 then
		return
	end

	Common.drawLegend(chrome, v7)
	local vector = Vector2.new(plotWidth / 2, plotHeight / 2)
	local radius = math.min(plotWidth, plotHeight) / 2 - 2

	if typeof(arguments.Radius) == "number" then
		radius = arguments.Radius
	end

	local outerRadius = math.max(1, radius)
	local innerRadius = outerRadius * math.clamp(arguments.Donut or 0, 0, 0.95)
	state.Centre = vector
	state.InnerRadius = innerRadius
	state.OuterRadius = outerRadius
	local direction = arguments.Clockwise == false and -1 or 1
	local startAngle = typeof(arguments.StartAngle) ~= "number" and -90 or arguments.StartAngle
	local v13 = math.clamp(arguments.SliceGap or 0, 0, 45)
	state.Direction = direction
	table.clear(state.Slices)
	local v14 = {}

	for _, v15 in sortedKeys2 do
		local share = not (total > 0) and 0 or v3[v15] / total
		v14[v15] = share
		local sweep = math.max(0, share * 360 - v13)
		table.insert(state.Slices, {
			Key = v15,
			Value = v3[v15],
			Share = share,
			StartAngle = startAngle,
			Sweep = sweep
		})
		startAngle += share * 360 * direction
	end

	for k, render2 in state.Renders do
		if v14[k] ~= nil then
			continue
		end

		render2.Container:Destroy()
		state.Renders[k] = nil
	end

	local image = typeof(arguments.SemiCircleImage) ~= "string" and "rbxassetid://7135409944" or arguments.SemiCircleImage
	local v16 = outerRadius * 2
	local showPercentages = arguments.ShowPercentages == true
	local labelMinShare = arguments.LabelMinShare or 0.05

	for _, slice in state.Slices do
		local seriesColor = seriesColors[slice.Key]
		local render2 = state.Renders[slice.Key]

		if render2 == nil then
			render2 = createSeriesRender(chrome.Content, slice.Key, seriesColor)
			state.Renders[slice.Key] = render2
		end

		render2.Color = seriesColor
		local v17

		if direction >= 0 then
			v17 = slice.StartAngle
		else
			v17 = slice.StartAngle - slice.Sweep
		end

		local rotation = v17 + 180
		local v19 = slice.Sweep <= 0 and 0 or slice.Sweep < 180 and 1 or 2
		Common.resizePool(render2.Wedges, v19, function(p: number)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = `Wedge{p}`
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.ZIndex = 2
			imageLabel.Parent = render2.Container
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Name = "Cut"
			uIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.5, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
			uIGradient.Enabled = false
			uIGradient.Parent = imageLabel
			return {
				Image = imageLabel,
				Gradient = uIGradient
			}
		end, function(p)
			p.Image:Destroy()
		end)

		for i = 1, v19 do
			local wedge = render2.Wedges[i]
			wedge.Image.Image = image
			wedge.Image.ImageColor3 = seriesColor
			wedge.Image.Size = UDim2.fromOffset(v16, v16)
			wedge.Image.Position = UDim2.fromOffset(vector.X, vector.Y)
		end

		if v19 == 1 then
			local wedge = render2.Wedges[1]
			wedge.Image.Rotation = rotation
			wedge.Gradient.Enabled = true
			wedge.Gradient.Rotation = (slice.Sweep + 270) % 360
		elseif v19 == 2 then
			local wedge = render2.Wedges[1]
			wedge.Image.Rotation = rotation
			wedge.Gradient.Enabled = false
			local wedge2 = render2.Wedges[2]
			wedge2.Image.Rotation = rotation + slice.Sweep + 180
			wedge2.Gradient.Enabled = false
		end

		local visible

		if showPercentages then
			if labelMinShare <= slice.Share then
				visible = slice.Sweep > 0
			else
				visible = false
			end
		else
			visible = showPercentages
		end

		render2.Label.Visible = visible

		if not visible then
			continue
		end

		local v22 = math.rad(slice.StartAngle + direction * slice.Sweep / 2)
		local v23

		if innerRadius > 0 then
			v23 = (innerRadius + outerRadius) / 2
		else
			v23 = outerRadius * 0.62
		end

		local v24 = vector + Vector2.new(math.cos(v22), (math.sin(v22))) * v23
		render2.Label.Text = string.format("%.0f%%", slice.Share * 100)
		render2.Label.Position = UDim2.fromOffset(v24.X, v24.Y)
		render2.Label.TextColor3 = config.TextColor
	end

	state.Hole.Visible = innerRadius > 0
	state.Hole.BackgroundColor3 = config.FrameBgColor:Lerp(Color3.new(0, 0, 0), 0.3)
	state.Hole.BackgroundTransparency = 0
	state.Hole.Size = UDim2.fromOffset(innerRadius * 2, innerRadius * 2)
	state.Hole.Position = UDim2.fromOffset(vector.X, vector.Y)
	Common.publishState(state, "shares", v14)
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("PieChart", events, {
	"values",
	"colors",
	"labels",
	"icons",
	"shares",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.PieChart == nil then
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
		local chrome = Common.createChrome("Iris_PieChart", 240)
		chrome.Cursor.Visible = false
		chrome.Crosshair.Visible = false
		local frame = Instance.new("Frame")
		frame.Name = "Hole"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.ZIndex = 6
		frame.Parent = chrome.Content
		utility.UICorner(frame)
		self.Chrome = chrome
		self.Hole = frame
		self.Renders = {}
		self.Slices = {}
		self.Centre = Vector2.zero
		self.InnerRadius = 0
		self.OuterRadius = 0
		self.Direction = 1
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

		if p.state.shares == nil then
			p.state.shares = internal._widgetState(p, "shares", {})
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

	widgetConstructor("PieChart", v5)
end

local function PieChart(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("PieChart", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return PieChart