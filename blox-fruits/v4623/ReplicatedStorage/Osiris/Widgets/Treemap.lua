local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local Common = require(game.ReplicatedStorage.Osiris.Common)
local v = {
	"Text",
	"Height",
	"MaxDepth",
	"Padding",
	"HeaderHeight",
	"ShowLabels",
	"ShowValues",
	"MinLabelSize",
	"ValueFormat",
	"NoLegend",
	"LegendOnBottom",
	"LegendIconSize",
	"TextOverlay"
}
local v2 = { "root", "path" }
local internal = Common.Internal
local utility = Common.Utility
local weigh

weigh = function(p, p2: number)
	if p2 > 32 then
		return 0
	end

	local children = p.Children

	if children == nil then
		local value = p.Value

		if typeof(value) == "number" and value == value and value > 0 then
			return value
		end

		return 0
	else
		local total = 0

		for _, v3 in children do
			if typeof(v3) == "table" then
				total += weigh(v3, p2 + 1)
			end
		end

		return total
	end
end

local function childItems(p)
	local result = {}
	local children = p.Children

	if children == nil then
		return result
	end

	for k, node in children do
		if not (typeof(k) == "string" and typeof(node) == "table") then
			continue
		end

		local v4 = weigh(node, 1)

		if v4 > 0 then
			table.insert(result, {
				Key = k,
				Value = v4,
				Node = node
			})
		end
	end

	table.sort(result, function(a, b)
		if a.Value == b.Value then
			return a.Key < b.Key
		end

		return a.Value > b.Value
	end)
	return result
end

local function squarify(list, data)
	local X = data.X
	local Y = data.Y
	local W = data.W
	local H = data.H
	local v3 = 0
	local result = {}

	for _, v4 in list do
		v3 += v4.Value
	end

	if v3 <= 0 or W <= 0 or H <= 0 then
		return result
	end

	local v4 = 1

	while v4 <= #list and not (W <= 0 or H <= 0 or v3 <= 0) do
		local v5 = math.min(W, H)
		local v6 = W * H / v3
		local v7 = v4 - 1
		local v8 = 0
		local v9 = 1e999

		for i = v4, #list do
			local v10 = v8 + list[i].Value
			local v11 = v10 * v6 / v5
			local v12 = 0

			if v11 > 0 then
				for i2 = v4, i do
					local v13 = list[i2].Value * v6 / v11

					if v13 > 0 then
						v12 = math.max(v12, (math.max(v11 / v13, v13 / v11)))
					else
						v12 = 1e999
					end
				end
			else
				v12 = 1e999
			end

			if v9 < v12 then
				break
			end

			v9 = v12
			v7 = i
			v8 = v10
		end

		if v7 < v4 then
			break
		end

		local v10 = v8 * v6 / v5
		local total = 0

		for i = v4, v7 do
			local v11 = v5 * (list[i].Value / v8)

			if H <= W then
				table.insert(result, {
					Item = list[i],
					Rect = {
						X = X,
						Y = Y + total,
						W = v10,
						H = v11
					}
				})
			else
				table.insert(result, {
					Item = list[i],
					Rect = {
						X = X + total,
						Y = Y,
						W = v11,
						H = v10
					}
				})
			end

			total += v11
		end

		if H <= W then
			X += v10
			W -= v10
		else
			Y += v10
			H -= v10
		end

		v3 -= v8
		v4 = v7 + 1
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deflate(rect, p: number)
	local v3 = p / 2
	return {
		X = rect.X + v3,
		Y = rect.Y + v3,
		W = math.max(0, rect.W - p),
		H = math.max(0, rect.H - p)
	}
end

local place

place = function(p, p2, depth: number, p4: number, p5: number, p6: number, p7, color: Color3?, p8: number, p9: number, list)
	if p4 < depth or p2.W <= 0 or p2.H <= 0 or #list >= 2000 then
		return
	end

	local v3 = childItems(p)

	if #v3 == 0 then
		return
	end

	for k, v4 in squarify(v3, p2) do
		if #list >= 2000 then
			break
		end

		local item = v4.Item
		local v5 = deflate(v4.Rect, p5) -- equivalent call inferred; original call site unknown

		if v5.W <= 0 or v5.H <= 0 then
			continue
		end

		local clone = table.clone(p7)
		table.insert(clone, item.Key)
		local color2

		if typeof(item.Node.Color) == "Color3" then
			color2 = item.Node.Color
		elseif color == nil then
			color2 = Common.seriesColor(k, p9)
		else
			color2 = Common.highlight(color, 0.12)
		end

		local isLeaf = item.Node.Children == nil or #childItems(item.Node) == 0
		table.insert(list, {
			Key = item.Key,
			Path = clone,
			Node = item.Node,
			Value = item.Value,
			Share = not (p8 > 0) and 0 or item.Value / p8,
			Depth = depth,
			IsLeaf = isLeaf,
			X = v5.X,
			Y = v5.Y,
			W = v5.W,
			H = v5.H,
			Color = color2
		})

		if isLeaf or not (depth < p4) then
			continue
		end

		local v7 = {
			X = v5.X + p5,
			Y = v5.Y + p6,
			W = v5.W - p5 * 2,
			H = v5.H - p6 - p5
		}

		if v7.W > 0 and v7.H > 0 then
			place(item.Node, v7, depth + 1, p4, p5, p6, clone, color2, p8, p9, list)
		end
	end
end

local function resolveRoot(p, items)
	local result = {}

	for _, item in items do
		local children = p.Children

		if children == nil then
			break
		end

		local v3 = children[item]

		if typeof(v3) ~= "table" then
			break
		end

		table.insert(result, item)
		p = v3
	end

	return p, result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearHighlight(state)
	for k, placement in state.Placements do
		local cell = state.Cells[k]

		if cell ~= nil then
			cell.Frame.BackgroundColor3 = placement.Color
		end
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

	for i = #state.Placements, 1, -1 do
		local placement = state.Placements[i]

		if not (v3.X >= placement.X and v3.X <= placement.X + placement.W and v3.Y >= placement.Y and v3.Y <= placement.Y + placement.H) then
			continue
		end

		v4 = i
		break
	end

	if v4 == nil then
		clearHover(state) -- equivalent call inferred; original call site unknown
	else
		local placement = state.Placements[v4]
		clearHighlight(state) -- equivalent call inferred; original call site unknown
		local cell = state.Cells[v4]

		if cell ~= nil then
			cell.Frame.BackgroundColor3 = Common.highlight(placement.Color)
		end

		local v5

		if typeof(placement.Node.Label) == "string" then
			v5 = placement.Node.Label
		else
			v5 = placement.Key
		end

		Common.showTooltip(
			chrome,
			(`{table.concat(placement.Path, " / ")}\n{v5}: {Common.formatNumber(placement.Value, arguments.ValueFormat)} ({string.format("%.1f", placement.Share * 100)}%)`)
		)
		local hovered = {
			Key = placement.Key,
			Path = placement.Path,
			Value = placement.Value,
			Share = placement.Share,
			Depth = placement.Depth,
			IsLeaf = placement.IsLeaf
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
	local textSize = config.TextSize
	local v3 = Common.stateValue(state, "root") or {}
	local root, v6 = resolveRoot(typeof(v3) ~= "table" and {} or v3, Common.stateValue(state, "path") or {})
	local v7 = childItems(root)
	local total = 0

	for _, v8 in v7 do
		total += v8.Value
	end

	local keys = table.create(#v7)
	local colors = {}
	local icons = {}
	local labels = {}

	for k, v10 in v7 do
		table.insert(keys, v10.Key)
		local key = v10.Key
		local v11

		if typeof(v10.Node.Color) == "Color3" then
			v11 = v10.Node.Color
		else
			v11 = Common.seriesColor(k, #v7)
		end

		colors[key] = v11

		if typeof(v10.Node.Label) == "string" then
			labels[v10.Key] = v10.Node.Label
		end

		if typeof(v10.Node.Icon) == "table" then
			icons[v10.Key] = v10.Node.Icon
		end
	end

	local v10 = {
		Keys = keys,
		Colors = colors,
		Labels = labels,
		Icons = icons,
		IconSize = arguments.LegendIconSize,
		AvailableWidth = Common.innerSize(chrome).X,
		Hidden = arguments.NoLegend
	}
	local legend = Common.measureLegend(chrome, v10)
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

	Common.drawLegend(chrome, v10)
	local v11 = math.clamp(math.floor(arguments.MaxDepth or 2), 1, 8)
	local v12 = math.max(0, arguments.Padding or 2)
	local v13

	if typeof(arguments.HeaderHeight) == "number" then
		v13 = math.max(0, arguments.HeaderHeight)
	else
		v13 = textSize + 2
	end

	local placements = {}
	place(root, {
		X = 0,
		Y = 0,
		W = plotWidth,
		H = plotHeight
	}, 1, v11, v12, v13, v6, nil, total, #v7, placements)
	state.Placements = placements
	Common.resizePool(state.Cells, #placements, function(p: number)
		local frame = Instance.new("Frame")
		frame.Name = `Cell{p}`
		frame.BorderSizePixel = 0
		frame.Parent = chrome.Content
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Icon"
		imageLabel.AnchorPoint = Vector2.new(0, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderSizePixel = 0
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.Visible = false
		imageLabel.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Label"
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.ClipsDescendants = true
		utility.applyTextStyle(textLabel)
		textLabel.Parent = frame
		return {
			Frame = frame,
			Label = textLabel,
			Icon = imageLabel
		}
	end, function(p)
		p.Frame:Destroy()
	end)
	local showLabels = arguments.ShowLabels ~= false
	local showValues = arguments.ShowValues == true
	local minLabelSize = arguments.MinLabelSize or 28
	local v15 = textSize + 2

	for k, v16 in placements do
		local cell = state.Cells[k]
		cell.Frame.ZIndex = v16.Depth * 2 + 2
		cell.Frame.BackgroundColor3 = v16.Color
		cell.Frame.Position = UDim2.fromOffset(v16.X, v16.Y)
		cell.Frame.Size = UDim2.fromOffset(math.max(1, v16.W), (math.max(1, v16.H)))
		local visible

		if showLabels then
			if minLabelSize <= v16.W then
				visible = v15 <= v16.H
			else
				visible = false
			end
		else
			visible = showLabels
		end

		cell.Label.Visible = visible
		cell.Label.ZIndex = cell.Frame.ZIndex + 1

		if visible then
			local label

			if typeof(v16.Node.Label) == "string" then
				label = v16.Node.Label
			else
				label = v16.Key
			end

			if showValues then
				label = `{label}  {Common.formatNumber(v16.Value, arguments.ValueFormat)}`
			end

			cell.Label.Text = label
			cell.Label.TextXAlignment = Enum.TextXAlignment.Left
			cell.Label.TextYAlignment = Enum.TextYAlignment.Top
			cell.Label.Position = UDim2.fromOffset(3, 1)
			cell.Label.Size = UDim2.fromOffset(math.max(1, v16.W - 6), v15)
		end

		local icon = v16.Node.Icon

		if visible then
			if typeof(icon) == "table" then
				local H = v16.H
				visible = v15 * 2 + 4 <= H
			else
				visible = false
			end
		end

		cell.Icon.Visible = visible
		cell.Icon.ZIndex = cell.Frame.ZIndex + 1

		if not (visible and icon ~= nil) then
			continue
		end

		local v18 = math.min(v16.W - 6, v16.H - v15 - 4)
		cell.Icon.Image = icon.Image
		cell.Icon.ImageRectOffset = icon.ImageRectOffset or Vector2.zero
		cell.Icon.ImageRectSize = icon.ImageRectSize or Vector2.zero
		cell.Icon.Position = UDim2.fromOffset(3, v15 + 2)
		cell.Icon.Size = UDim2.fromOffset(v18, v18)
	end
end

local events = {
	hovered = utility.EVENTS.hover(function(p)
		return p.Instance
	end),
	clicked = Common.CLICKED_EVENT
}
Common.assertNoShadowedEvents("Treemap", events, {
	"root",
	"path",
	"hoveredMark",
	"clickedMark"
})

if internal._widgets.Treemap == nil then
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
		local chrome = Common.createChrome("Iris_Treemap", 300)
		chrome.Cursor.Visible = false
		chrome.Crosshair.Visible = false
		self.Chrome = chrome
		self.Cells = {}
		self.Placements = {}
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
			if self.state == nil or self.state.root == nil then
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
		if p.state.root == nil then
			p.state.root = internal._widgetState(p, "root", {})
		end

		if p.state.path == nil then
			p.state.path = internal._widgetState(p, "path", {})
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
		Common.updateChrome(data.Chrome, arguments.Text, arguments.TextOverlay, arguments.Height or 300)

		if data.state ~= nil and data.state.root ~= nil then
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

	widgetConstructor("Treemap", v5)
end

local function Treemap(data)
	if data.Id ~= nil then
		Osiris.SetNextWidgetID(data.Id)
	end

	return (internal._Insert("Treemap", Common.toArguments(v, data.Arguments), Common.toStates(data.States)))
end

return Treemap