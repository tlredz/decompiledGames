local React = require(game.ReplicatedStorage.Packages.React)
local Controls = require(script.Parent.Controls)
local Formatter = require(script.Parent.Formatter)
local LayoutMetrics = require(script.Parent.LayoutMetrics)
local RichText = require(script.Parent.RichText)
local TabBar = require(script.Parent.TabBar)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local TabDisplay = require(script.Parent.Parent.TabDisplay)
local createElement = React.createElement
local uDim = UDim.new(0, LayoutMetrics.RowGapPx)
local uDim2 = UDim.new(0, LayoutMetrics.RowVerticalGapPx)
local uDim3 = UDim.new(0, LayoutMetrics.LinePadXPx)
local uDim4 = UDim.new(0, LayoutMetrics.LinePadYPx)
local buttonPadXPx = LayoutMetrics.ButtonPadXPx
local checkboxExtraWidthPx = LayoutMetrics.CheckboxExtraWidthPx
local comboExtraWidthPx = LayoutMetrics.ComboExtraWidthPx
local tableExtraWidthPx = LayoutMetrics.TableExtraWidthPx
local tooltipWidthPx = LayoutMetrics.TooltipWidthPx
local prefixBadgePadXPx = LayoutMetrics.PrefixBadgePadXPx
local v = 12 + uDim3.Offset * 2

-- equivalent calls inferred from this helper; original call sites unknown
local function nextKey(p, p2: string)
	p.value += 1
	return (`{p2}{p.value}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function replicatedHandleValue(list, p, p2: string)
	local replicatedHandles = p.ReplicatedHandles
	local v2 = replicatedHandles and replicatedHandles[list[1]]

	if v2 and v2.Kind == p2 then
		return v2.Value
	end

	return list[4]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newRow()
	return {
		Children = {},
		WidthPx = 0,
		Count = 0
	}
end

local function trimRight(value: string)
	return (string.gsub(value, "%s+$", ""))
end

local function isTimestampPrefix(value)
	return typeof(value) == "string" and string.match(value, "^%d%d:%d%d:%d%d$") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSidePrefix(value)
	if typeof(value) == "string" then
		return string.match(value, "^/<font.->.-</font>:%s*$") ~= nil or string.match(value, "^/%a+:%s*$") ~= nil
	end

	return false
end

local function getContextPrefix(list)
	local v2 = list[1]
	local v3

	if typeof(v2) == "string" then
		v3 = string.match(v2, "^%d%d:%d%d:%d%d$") ~= nil
	else
		v3 = false
	end

	if not v3 then
		return nil, 1
	end

	-- equivalent call inferred; original call site unknown
	if isSidePrefix(list[2]) then
		local v5 = tostring(list[1])
		local v6 = list[2]
		return v5 .. string.gsub(v6, "%s+$", ""), 3
	end

	return nil, 1
end

local function measureTextWidth(p: string, p2: number, p3)
	return LayoutMetrics.textWidth(p, p2, p3)
end

local function copyOptions(data)
	local horizontalAlignment

	if data then
		horizontalAlignment = data.HorizontalAlignment
	end

	local centerAligned

	if data then
		centerAligned = data.CenterAligned
	end

	local controlWidthPx

	if data then
		controlWidthPx = data.ControlWidthPx
	end

	local availableWidthPx

	if data then
		availableWidthPx = data.AvailableWidthPx
	end

	local structuredWrap

	if data then
		structuredWrap = data.StructuredWrap
	end

	return {
		HorizontalAlignment = horizontalAlignment,
		CenterAligned = centerAligned,
		ControlWidthPx = controlWidthPx,
		AvailableWidthPx = availableWidthPx,
		StructuredWrap = structuredWrap
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function centeredOptions(data)
	local v2 = copyOptions(data)
	v2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	v2.CenterAligned = true
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sizeGroupOptions(data, controlWidthPx: number?)
	local v2 = copyOptions(data)
	v2.ControlWidthPx = controlWidthPx
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function widthWithGap(p, p2: number)
	if p.Count <= 0 then
		return p2
	end

	return p.WidthPx + uDim.Offset + p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addToRow(state, p: string, p2, p3: number, p4)
	state.Children[p] = p2

	if p4 and p4.HorizontalAlignment then
		state.HorizontalAlignment = p4.HorizontalAlignment
	end

	if state.Count > 0 then
		state.WidthPx += uDim.Offset
	end

	state.WidthPx += math.max(0, (math.ceil(p3)))
	state.Count += 1
end

local function addPacked(list, p: string, p2, p3: number, p4, p5)
	local v2 = list[#list]
	local availableWidthPx

	if p4 and p4.AvailableWidthPx then
		availableWidthPx = p4.AvailableWidthPx
	else
		availableWidthPx = p5 and p5.AvailableWidthPx
	end

	local structuredWrap = p5 and p5.StructuredWrap or p4 and p4.StructuredWrap == true
	local v3 = math.max(0, (math.ceil(p3)))

	if structuredWrap and availableWidthPx and availableWidthPx > 0 and v3 > 0 and v2.Count > 0 then
		local v4 = widthWithGap(v2, v3) -- equivalent call inferred; original call site unknown

		if availableWidthPx < v4 then
			table.insert(list, newRow())
			v2 = list[#list]
		end
	end

	addToRow(v2, p, p2, v3, p4) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addBlock(list, formatted: string, p, fullWidth: number, p2, p3)
	if list[#list].Count > 0 then
		table.insert(list, newRow())
	end

	addPacked(list, formatted, p, fullWidth, p2, p3)
	table.insert(list, newRow())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tableSummary(list)
	return LayoutMetrics.tableSummary(list)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function measureControlPartWidth(item, p)
	return LayoutMetrics.controlPartWidth(item, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function measureSizeGroupWidth(p, p2)
	local v2 = 0
	local scan

	scan = function(items)
		for _, item in items do
			if typeof(item) ~= "table" then
				continue
			end

			local v3 = item[3]

			if v3 == "</robj>" then
				local v5 = replicatedHandleValue(item, p2, "object") -- equivalent call inferred; original call site unknown
				scan(v5 or {})
			elseif v3 ~= "</ilog>" then
				local controlPartWidth = measureControlPartWidth(item, p2) -- equivalent call inferred; original call site unknown

				if controlPartWidth then
					v2 = math.max(v2, controlPartWidth)
				end

				if v3 == "</font>" or v3 == "</text>" or v3 == "</tree>" or v3 == "</div>" or v3 == "</cdiv>" or v3 == "</center>" or v3 == "</sizegroup>" then
					scan(item[2] or {})
				elseif v3 == "</agrid>" or v3 == "</alist>" or v3 == "</bubble>" then
					scan(item[4] or {})
				end
			end
		end
	end

	scan(p)

	if v2 <= 0 then
		return nil
	end

	local v3 = math.ceil(v2)
	return (math.clamp(v3, Theme.SizeGroupMinControlWidth, Theme.SizeGroupMaxControlWidth))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function childMeasureState(p)
	return {
		Depth = p.Depth + 1,
		Visiting = p.Visiting
	}
end

local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function constrainedPreferredWidth(p: number, p2: number?)
	return LayoutMetrics.constrainWidth(math.max(Theme.ControlHeight, (math.ceil(p))), p2)
end

local function measureInlineLogPreferredWidth(data, p, p2: number?, p3)
	if typeof(data) ~= "table" then
		return Theme.ControlHeight
	end

	local v2

	if p2 then
		v2 = math.max(1, p2 - v)
	end

	local noTabs = data.NoTabs == true
	local v3 = 0

	for _, v4 in typeof(data.HeaderLines) ~= "table" and {} or data.HeaderLines do
		if typeof(v4) == "table" then
			v3 = math.max(v3, fn(v4, p, v2, childMeasureState(p3)))
		end
	end

	local v4 = (noTabs or typeof(data.Tabs) ~= "table") and {} or data.Tabs
	local visibleTabs = TabDisplay.visibleTabs(v4)
	local total = 0

	for _, visibleTab in visibleTabs do
		if typeof(visibleTab) ~= "table" then
			continue
		end

		local v5 = typeof(visibleTab.Name) ~= "string" and "Log" or visibleTab.Name
		local controlTextSize = Theme.ControlTextSize
		local fontBold = Theme.FontBold
		total += LayoutMetrics.textWidth(v5, controlTextSize, fontBold) + 22

		if typeof(visibleTab.Lines) ~= "table" then
			continue
		end

		for _, line in visibleTab.Lines do
			if typeof(line) == "table" then
				v3 = math.max(v3, fn(line, p, v2, childMeasureState(p3)))
			end
		end
	end

	if total > 0 then
		v3 = math.max(v3, total)
	end

	for _, v5 in typeof(data.Lines) ~= "table" and {} or data.Lines do
		if typeof(v5) == "table" then
			v3 = math.max(v3, fn(v5, p, v2, childMeasureState(p3)))
		end
	end

	return constrainedPreferredWidth(v3 + v, p2)
end

fn = function(p, p2, p3: number?, p4, value: string?, value2: string?)
	if typeof(p) ~= "table" then
		return 0
	end

	local v2 = p4 or {
		Depth = 0,
		Visiting = {}
	}

	if v2.Depth > 8 or v2.Visiting[p] then
		return Theme.ControlHeight
	end

	v2.Visiting[p] = true
	local v3 = 0
	local total = 0
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finishRow()
		v3 = math.max(v3, total)
		total = 0
		count = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addWidth(p5: number)
		local v4 = math.max(0, (math.ceil(p5)))

		if v4 <= 0 then
			return
		end

		if count > 0 then
			total += uDim.Offset
		end

		total += v4
		count += 1
		v3 = math.max(v3, total)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addBlock2(p5: number)
		if count > 0 then
			finishRow() -- equivalent call inferred; original call site unknown
		end

		v3 = math.max(v3, (math.max(0, (math.ceil(p5)))))
	end

	local function measureTextPieces(p5: string)
		local splitLines = RichText.splitLines(p5)

		for k, splitLine in splitLines do
			if splitLine ~= "" and TextMetrics.stripRichText(splitLine) ~= "" then
				local rawTextSize = Theme.RawTextSize
				local monoFont = Theme.MonoFont
				addWidth(LayoutMetrics.textWidth(splitLine, rawTextSize, monoFont)) -- equivalent call inferred; original call site unknown
			end

			if not (k < #splitLines) then
				continue
			end

			finishRow() -- equivalent call inferred; original call site unknown
		end
	end

	local scan

	scan = function(items, p5: string, p6: string)
		local flag

		if items == p then
			flag = false
		elseif v2.Visiting[items] then
			local v4 = math.max(0, (math.ceil(Theme.ControlHeight)))

			if v4 <= 0 then
				return
			end

			if count > 0 then
				total += uDim.Offset
			end

			total += v4
			count += 1
			v3 = math.max(v3, total)
			return
		else
			v2.Visiting[items] = true
			flag = true
		end

		for _, item in items do
			if typeof(item) == "table" then
				local v4 = item[3]

				if v4 == "</font>" then
					scan(item[2] or {}, p5 .. (item[1] or ""), (item[3] or "") .. p6)
				elseif v4 == "</text>" then
					scan(item[2] or {}, p5, p6)
				elseif v4 == "</br>" then
					finishRow() -- equivalent call inferred; original call site unknown
				elseif v4 == "</btn>" or v4 == "</chk>" or v4 == "</cmbo>" or v4 == "</combochild>" or v4 == "</tree>" then
					addWidth(LayoutMetrics.controlPartWidth(item, p2) or Theme.ControlHeight) -- equivalent call inferred; original call site unknown
				elseif v4 == "</div>" or v4 == "</cdiv>" then
					local v5 = fn
					local v6 = item[2] or {}
					local v8

					if p3 then
						v8 = math.max(1, p3 - 16)
					end

					local v12 = constrainedPreferredWidth(v5(v6, p2, v8, childMeasureState(v2)) + 16, p3) -- equivalent call inferred; original call site unknown
					addBlock2(v12) -- equivalent call inferred; original call site unknown
				elseif v4 == "</center>" then
					if count > 0 then
						finishRow() -- equivalent call inferred; original call site unknown
					end

					scan(item[2] or {}, p5, p6)

					if count > 0 then
						finishRow() -- equivalent call inferred; original call site unknown
					end
				elseif v4 == "</sizegroup>" then
					scan(item[2] or {}, p5, p6)
				elseif v4 == "</agrid>" or v4 == "</alist>" then
					local v5 = item[4] or {}
					local v6 = tonumber(item[1]) or 1
					local v7 = math.clamp(v6, 0.05, 1)
					local v8 = v4 ~= "</agrid>" and 1 or math.max(1, (math.floor(1 / v7 + 0.5)))
					local v9 = 0

					for _, v10 in v5 do
						v9 = math.max(v9, fn({ v10 }, p2, p3, childMeasureState(v2)) + Theme.AlignedCellPadding * 2)
					end

					local v10

					if v4 == "</agrid>" then
						v10 = v9 * v8 + Theme.AlignedGroupInset
					else
						v10 = v9 + Theme.AlignedGroupInset
					end

					addWidth(LayoutMetrics.expandedScaledWidth(v6, p3, v10)) -- equivalent call inferred; original call site unknown
				elseif v4 == "</bubble>" then
					local v5 = tonumber(item[1]) or 1
					local v6 = fn
					local v7 = item[4] or {}
					local v9

					if p3 then
						v9 = math.max(1, p3 - Theme.BubbleFramePadding * 2)
					end

					local v11 = v6(v7, p2, v9, childMeasureState(v2))
					addWidth(LayoutMetrics.expandedScaledWidth(v5, p3, v11 + Theme.BubbleFramePadding * 2)) -- equivalent call inferred; original call site unknown
				elseif v4 == "</srvst>" then
					local text = Formatter.toText(item, p2)

					if text then
						measureTextPieces(p5 .. text .. p6)
					end
				elseif v4 == "</robj>" then
					local v6 = replicatedHandleValue(item, p2, "object") -- equivalent call inferred; original call site unknown
					scan(v6 or {}, p5, p6)
				elseif v4 == "</ilog>" then
					local v6 = replicatedHandleValue(item, p2, "inline-log") -- equivalent call inferred; original call site unknown
					addBlock2(measureInlineLogPreferredWidth(v6, p2, p3, childMeasureState(v2))) -- equivalent call inferred; original call site unknown
				elseif v4 == "</tip>" then
					addWidth(tooltipWidthPx) -- equivalent call inferred; original call site unknown
				elseif v4 ~= "</stay>" then
					addWidth(LayoutMetrics.controlPartWidth(item, p2) or Theme.ControlHeight) -- equivalent call inferred; original call site unknown
				end
			else
				local text = Formatter.toText(item, p2)

				if text then
					measureTextPieces(p5 .. text .. p6)
				end
			end
		end

		if flag then
			v2.Visiting[items] = nil
		end
	end

	scan(p, value or "", value2 or "")
	finishRow() -- equivalent call inferred; original call site unknown
	v2.Visiting[p] = nil
	return constrainedPreferredWidth(v3, p3)
end

local function LogRow(props)
	local ref = React.useRef(nil)
	local state, setState = React.useState(1)
	local ref2 = React.useRef(state)
	ref2.current = state

	local function updateScale()
		if props.TextOverflowMode == "fit" then
			local current = ref.current

			if not current then
				return
			end

			local X = math.floor(current.AbsoluteSize.X)
			local contentWidthPx = props.ContentWidthPx or 0
			local current2 = not (X > 0 and X < contentWidthPx) and 1 or math.max(0.35, X / contentWidthPx)

			if math.abs(ref2.current - current2) < 0.001 then
				return
			end

			ref2.current = current2
			setState(current2)
		elseif ref2.current ~= 1 then
			ref2.current = 1
			setState(1)
		end
	end

	React.useEffect(function()
		updateScale()
		task.defer(updateScale)
		local current = ref.current
		local absoluteSizeChangedConnection

		if current then
			absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
		else
			absoluteSizeChangedConnection = nil
		end

		return function()
			if absoluteSizeChangedConnection then
				absoluteSizeChangedConnection:Disconnect()
			end
		end
	end, { props.TextOverflowMode or "clip", props.ContentWidthPx or 0 })
	local v4 = {
		ref = ref,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0)
	}
	local v8 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0)
	}
	local uIScale

	if props.TextOverflowMode == "fit" and state < 1 then
		uIScale = createElement("UIScale", {
			Scale = state
		})
	end

	return createElement("Frame", v4, {
		ScaledContent = createElement("Frame", v8, {
			UIScale = uIScale,
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left,
				Padding = uDim,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Wraps = props.TextOverflowMode == "wrap"
			}),
			Content = createElement(React.Fragment, {}, props.children)
		})
	})
end

local memo = React.memo(function(props)
	local state, setState = React.useState(1)
	local log = props.Log
	local v2 = log and log.NoTabs == true
	local v3 = (v2 or not log or typeof(log.Tabs) ~= "table") and {} or log.Tabs
	local visibleTabs, v4 = TabDisplay.visibleTabs(v3)
	local count = #visibleTabs
	local selectedTabIndex = TabDisplay.resolveSelectedTabIndex(v3, state)
	local visibleTabIndexForSourceIndex = TabDisplay.visibleTabIndexForSourceIndex(v3, selectedTabIndex)
	local v5 = v3[selectedTabIndex]
	local v6 = (not log or typeof(log.HeaderLines) ~= "table") and {} or log.HeaderLines
	local lines

	if v2 and log and typeof(log.Lines) == "table" then
		lines = log.Lines
	elseif v5 and typeof(v5.Lines) == "table" then
		lines = v5.Lines
	else
		lines = (not log or typeof(log.Lines) ~= "table") and {} or log.Lines
	end

	local function renderLine(p, k: number)
		local v9 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = k % 2 == 0 and 0.55 or 1,
			BorderSizePixel = 0,
			LayoutOrder = k,
			Size = UDim2.new(1, 0, 0, 0)
		}
		local v10 = {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			Content = 0
		}
		local v13 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}
		local v14 = {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = uDim4,
				PaddingLeft = uDim3,
				PaddingRight = uDim3,
				PaddingTop = uDim4
			}),
			Body = 0
		}
		local renderNestedContent = props.RenderNestedContent
		local v17

		if props.ContentWidthPx then
			v17 = math.max(1, props.ContentWidthPx - 12 - uDim3.Offset * 2)
		end

		v14.Body = renderNestedContent(p, nil, nil, v17)
		v10.Content = createElement("Frame", v13, v14)
		return createElement("Frame", v9, v10)
	end

	local v7 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = uDim2,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}

	for k, v8 in v6 do
		v7[`Header{k}`] = renderLine(v8, k)
	end

	local v8 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6)
		})
	}

	for k, line in lines do
		v8[`Line{k}`] = renderLine(line, k)
	end

	if #lines == 0 then
		v8.Empty = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.PanelDark,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 4),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 4)
			}),
			Text = createElement(Controls.Text, {
				Text = "No log entries.",
				TextColor3 = Theme.TextSubtle,
				LayoutOrder = 1
			})
		})
	end

	if not v2 and count <= 0 then
		visibleTabs = {
			{
				Name = "Log",
				Lines = lines
			}
		}
		count = #visibleTabs
		visibleTabIndexForSourceIndex = 1
		v4 = { 1 }
	end

	local v9 = not v2 and count > 1
	local v12 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PanelDark,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0)
	}
	local v13 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerPanel)
		}),
		UIStroke = createElement("UIStroke", {
			Color = Theme.StrokeSubtle,
			Transparency = 0.15
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Headers = 0,
		Tabs = 0,
		Lines = 0
	}
	local headers

	if #v6 > 0 then
		headers = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, v7)
	end

	v13.Headers = headers
	local tabs

	if v9 then
		tabs = createElement(TabBar, {
			LayoutOrder = 2,
			Tabs = visibleTabs,
			SelectedIndex = visibleTabIndexForSourceIndex,
			OnSelect = function(p: number)
				setState(v4[p] or p)
			end
		})
	end

	v13.Tabs = tabs
	v13.Lines = createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PanelDarker,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 0)
	}, v8)
	return createElement("Frame", v12, v13)
end)

local function appendText(list, p, p2: string, color: Color3?, textOverflowMode: string?, p4, p5)
	if p2 == "" then
		return
	end

	local splitLines = RichText.splitLines(p2)

	for k, splitLine in splitLines do
		if splitLine ~= "" and TextMetrics.stripRichText(splitLine) ~= "" then
			p.value += 1
			local formatted = `Text{p.value}`
			local element = createElement(Controls.Text, {
				Text = splitLine,
				TextColor3 = color,
				LayoutOrder = p.value,
				TextOverflowMode = textOverflowMode
			})
			local rawTextSize = Theme.RawTextSize
			local monoFont = Theme.MonoFont
			addPacked(list, formatted, element, LayoutMetrics.textWidth(splitLine, rawTextSize, monoFont), p4, p5)
		end

		if k < #splitLines then
			table.insert(list, newRow())
		end
	end
end

local renderParts

renderParts = function(list, context, list2, p2, p3: string, p4: string, textOverflowMode: string?, data, p6, value: number?)
	local function renderNestedContent(p7, center, data2, availableWidthPx: number?)
		local v2 = { newRow() }
		local v4 = copyOptions(data2 or data)

		if availableWidthPx then
			v4.AvailableWidthPx = availableWidthPx
			v4.StructuredWrap = true
		end

		if center then
			v4.HorizontalAlignment = center

			if center == Enum.HorizontalAlignment.Center then
				v4.CenterAligned = true
			end
		end

		local v5 = {
			AvailableWidthPx = v4.AvailableWidthPx or p6 and p6.AvailableWidthPx,
			StructuredWrap = true,
			MinimalTables = p6 and p6.MinimalTables
		}
		local textOverflowMode2 = v5.StructuredWrap and "wrap" or textOverflowMode
		renderParts(p7, context, v2, {
			value = 0
		}, "", "", textOverflowMode2, v4, v5)
		local children = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = uDim2,
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		}

		for k, v7 in v2 do
			if v7.Count ~= 0 then
				children[`Row{k}`] = createElement(LogRow, {
					LayoutOrder = k,
					TextOverflowMode = textOverflowMode2,
					ContentWidthPx = v7.WidthPx,
					HorizontalAlignment = v7.HorizontalAlignment or center
				}, v7.Children)
			end
		end

		return createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, children)
	end

	local function renderPart(list3)
		if typeof(list3) == "table" then
			local v2 = list3[3]

			if v2 == "</font>" then
				renderParts(
					list3[2] or {},
					context,
					list2,
					p2,
					p3 .. (list3[1] or ""),
					(list3[3] or "") .. p4,
					textOverflowMode,
					data,
					p6
				)
			elseif v2 == "</text>" then
				renderParts(list3[2] or {}, context, list2, p2, p3, p4, textOverflowMode, data, p6)
			elseif v2 == "</br>" then
				table.insert(list2, newRow())
			elseif v2 == "</btn>" then
				local v3 = p2
				v3.value += 1
				local formatted = `Button{v3.value}`
				local v4 = Formatter.toText(list3[4], context) or "Button"
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(v4, controlTextSize, fontBold) + buttonPadXPx
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.Button, {
					Part = list3,
					Context = context,
					LayoutOrder = p2.value,
					TextOverflowMode = textOverflowMode,
					SizePx = constrainWidth
				}), constrainWidth, data, p6)
			elseif v2 == "</chk>" then
				local v3 = p2
				v3.value += 1
				local formatted = `Checkbox{v3.value}`
				local v4 = Formatter.toText(list3[4], context) or "Checkbox"
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(v4, controlTextSize, fontBold) + checkboxExtraWidthPx
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.Checkbox, {
					Part = list3,
					Context = context,
					LayoutOrder = p2.value,
					TextOverflowMode = textOverflowMode,
					SizePx = constrainWidth
				}), constrainWidth, data, p6)
			elseif v2 == "</cmbo>" then
				local v3 = p2
				v3.value += 1
				local formatted = `Combo{v3.value}`
				local v4 = Formatter.toText(list3[4], context) or "Select"
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(v4, controlTextSize, fontBold) + comboExtraWidthPx
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.Combo, {
					Part = list3,
					Context = context,
					LayoutOrder = p2.value,
					TextOverflowMode = textOverflowMode,
					SizePx = constrainWidth
				}), constrainWidth, data, p6)
			elseif v2 == "</combochild>" then
				local v3 = p2
				v3.value += 1
				local formatted = `ComboChild{v3.value}`
				local v4 = Formatter.toText(list3[4], context) or "Select"
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(v4, controlTextSize, fontBold) + comboExtraWidthPx
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.Combo, {
					Part = list3,
					Context = context,
					LayoutOrder = p2.value,
					FromChildren = true,
					TextOverflowMode = textOverflowMode,
					SizePx = constrainWidth
				}), constrainWidth, data, p6)
			elseif v2 == "</tree>" then
				local label = Formatter.toText(list3[1], context) or "Tree"
				local v4 = list3[2] or {}
				local v5 = p2
				v5.value += 1
				local formatted = `Tree{v5.value}`
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(label, controlTextSize, fontBold) + 42
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.Tree, {
					Label = label,
					LayoutOrder = p2.value,
					RenderBody = function()
						local v8

						if data then
							v8 = data.HorizontalAlignment
						end

						return renderNestedContent(v4, v8, data, Theme.TreePopoutWidth - 16)
					end,
					SizePx = constrainWidth
				}), constrainWidth, data, p6)
			elseif v2 == "</div>" or v2 == "</cdiv>" then
				local label = Formatter.toText(list3[1], context) or "Divider"
				local v4 = list3[2] or {}
				local collapsableDivider

				if v2 == "</cdiv>" then
					collapsableDivider = Controls.CollapsableDivider
				else
					collapsableDivider = Controls.Divider
				end

				local fullWidth = LayoutMetrics.fullWidth(p6 and p6.AvailableWidthPx)
				local v6 = p2
				v6.value += 1
				addBlock(list2, `Divider{v6.value}`, createElement(collapsableDivider, {
					Label = label,
					LayoutOrder = p2.value,
					LabelCentered = data and data.CenterAligned == true,
					RenderBody = function()
						local v9

						if data then
							v9 = data.HorizontalAlignment
						end

						return renderNestedContent(v4, v9, data, math.max(1, fullWidth - 16))
					end
				}), fullWidth, data, p6) -- equivalent call inferred; original call site unknown
			elseif v2 == "</center>" then
				if list2[#list2].Count > 0 then
					table.insert(list2, newRow())
				end

				renderParts(list3[2] or {}, context, list2, p2, p3, p4, textOverflowMode, centeredOptions(data), p6)

				if list2[#list2].Count > 0 then
					table.insert(list2, newRow())
				end
			elseif v2 == "</sizegroup>" then
				local controlWidthPx = measureSizeGroupWidth(list3[2] or {}, context) -- equivalent call inferred; original call site unknown
				renderParts(
					list3[2] or {},
					context,
					list2,
					p2,
					p3,
					p4,
					textOverflowMode,
					sizeGroupOptions(data, controlWidthPx),
					p6
				)
			elseif v2 == "</agrid>" or v2 == "</alist>" then
				local v3 = list3[4] or {}
				local v4 = tonumber(list3[1]) or 1
				local v5 = math.clamp(v4, 0.05, 1)
				local v6 = v2 ~= "</agrid>" and 1 or math.max(1, (math.floor(1 / v5 + 0.5)))
				local v7 = 0
				local items = {}

				for _, v9 in v3 do
					v7 = math.max(v7, fn({ v9 }, context, p6 and p6.AvailableWidthPx) + Theme.AlignedCellPadding * 2)
				end

				local v9

				if v2 == "</agrid>" then
					v9 = v7 * v6 + Theme.AlignedGroupInset
				else
					v9 = v7 + Theme.AlignedGroupInset
				end

				local expandedScaledWidth = LayoutMetrics.expandedScaledWidth(v4, p6 and p6.AvailableWidthPx, v9)
				local availableWidthPx = math.max(
					1,
					math.floor(expandedScaledWidth / v6) - Theme.AlignedCellPadding * 2
				)

				for k, v11 in v3 do
					items[k] = renderNestedContent({ v11 }, Enum.HorizontalAlignment.Center, data, availableWidthPx)
				end

				local key = nextKey(p2, v2 == "</agrid>" and "AlignedGrid" or "AlignedList") -- equivalent call inferred; original call site unknown
				local v14

				if v2 == "</agrid>" then
					v14 = Controls.AlignedGrid
				else
					v14 = Controls.AlignedList
				end

				addPacked(list2, key, createElement(v14, {
					LayoutOrder = p2.value,
					ScaleX = tonumber(list3[1]) or 1,
					ScaleY = tonumber(list3[2]) or 0.1,
					SizePx = expandedScaledWidth,
					Items = items
				}), expandedScaledWidth, data, p6)
			elseif v2 == "</bubble>" then
				local v3 = list3[4] or {}
				local v4 = p2
				v4.value += 1
				local formatted = `BubbleFrame{v4.value}`
				local v5 = fn
				local v7

				if p6 and p6.AvailableWidthPx then
					v7 = math.max(1, p6.AvailableWidthPx - Theme.BubbleFramePadding * 2)
				end

				local v8 = v5(v3, context, v7)
				local expandedScaledWidth = LayoutMetrics.expandedScaledWidth(
					tonumber(list3[1]) or 1,
					p6 and p6.AvailableWidthPx,
					v8 + Theme.BubbleFramePadding * 2
				)
				addPacked(list2, formatted, createElement(Controls.BubbleFrame, {
					LayoutOrder = p2.value,
					ScaleX = tonumber(list3[1]) or 1,
					ScaleY = tonumber(list3[2]) or 0.12,
					SizePx = expandedScaledWidth,
					RenderBody = function()
						local v11

						if data then
							v11 = data.HorizontalAlignment
						end

						return renderNestedContent(
							v3,
							v11,
							data,
							math.max(1, expandedScaledWidth - Theme.BubbleFramePadding * 2)
						)
					end
				}), expandedScaledWidth, data, p6)
			elseif v2 == "</srvst>" then
				local text = Formatter.toText(list3, context)

				if text then
					appendText(list2, p2, p3 .. text .. p4, nil, textOverflowMode, data, p6)
				end
			elseif v2 == "</robj>" then
				local v4 = replicatedHandleValue(list3, context, "object") -- equivalent call inferred; original call site unknown
				renderParts(v4 or {}, context, list2, p2, p3, p4, textOverflowMode, data, p6)
			elseif v2 == "</ilog>" then
				local v3 = p2
				v3.value += 1
				local formatted = `InlineLog{v3.value}`
				local fullWidth = LayoutMetrics.fullWidth(p6 and p6.AvailableWidthPx)
				local log = replicatedHandleValue(list3, context, "inline-log") -- equivalent call inferred; original call site unknown
				addBlock(list2, formatted, createElement(memo, {
					Log = log,
					LayoutOrder = p2.value,
					ContentWidthPx = fullWidth,
					RenderNestedContent = renderNestedContent
				}), fullWidth, data, p6) -- equivalent call inferred; original call site unknown
			elseif v2 == "</tip>" then
				local v5 = p2
				v5.value += 1
				addPacked(list2, `Tooltip{v5.value}`, createElement(Controls.Tooltip, {
					Text = Formatter.toText(list3[1], context) or "",
					LayoutOrder = p2.value
				}), tooltipWidthPx, data, p6)
			else
				if v2 == "</stay>" then
					return
				end

				local v3 = p2
				v3.value += 1
				local formatted = `Table{v3.value}`
				local v4 = tableSummary(list3) -- equivalent call inferred; original call site unknown
				local controlWidthPx = data and data.ControlWidthPx

				if not controlWidthPx then
					local controlTextSize = Theme.ControlTextSize
					local fontBold = Theme.FontBold
					controlWidthPx = LayoutMetrics.textWidth(v4, controlTextSize, fontBold) + tableExtraWidthPx
				end

				local constrainWidth = LayoutMetrics.constrainWidth(controlWidthPx, p6 and p6.AvailableWidthPx)
				addPacked(list2, formatted, createElement(Controls.TableExplorer, {
					Value = list3,
					Context = context,
					LayoutOrder = p2.value,
					SizePx = constrainWidth,
					Minimal = p6 and p6.MinimalTables == true
				}), constrainWidth, data, p6)
			end
		else
			local text = Formatter.toText(list3, context)

			if text then
				appendText(list2, p2, p3 .. text .. p4, nil, textOverflowMode, data, p6)
			end
		end
	end

	for i = value or 1, #list do
		renderPart(list[i])
	end
end

local function LogLine(props)
	local ref = React.useRef(nil)
	local state, setState = React.useState(0)
	local ref2 = React.useRef(state)
	local ref3 = React.useRef(0)
	ref2.current = state

	local function updateMeasurements()
		local current = ref.current

		if not current then
			return
		end

		local current2 = math.max(0, (math.floor(current.AbsoluteSize.X - uDim3.Offset * 2)))

		if current2 ~= ref2.current then
			ref2.current = current2
			setState(current2)
		end

		local current3 = math.max(Theme.VirtualLineHeight, (math.ceil(current.AbsoluteSize.Y)))

		if current3 ~= ref3.current then
			ref3.current = current3

			if props.OnHeightChanged then
				props.OnHeightChanged(props.Line, current3)
			end
		end
	end

	React.useEffect(function()
		updateMeasurements()
		task.defer(updateMeasurements)
		local current = ref.current

		if not current then
			return
		end

		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMeasurements)
		return function()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, {
		props.Line,
		props.DynamicVersion or false,
		props.TextOverflowMode or "clip",
		props.MinimalTables == true
	})
	local v2 = { newRow() }
	local v3 = {
		value = 0
	}
	local textOverflowMode = props.TextOverflowMode or "clip"
	local line = props.Line
	local v4 = line[1]
	local v5

	if typeof(v4) == "string" then
		v5 = string.match(v4, "^%d%d:%d%d:%d%d$") ~= nil
	else
		v5 = false
	end

	local text, v7

	if v5 then
		-- equivalent call inferred; original call site unknown
		if isSidePrefix(line[2]) then
			local v9 = tostring(line[1])
			local v10 = line[2]
			text = v9 .. string.gsub(v10, "%s+$", "")
			v7 = 3
		else
			v7 = 1
		end
	else
		v7 = 1
	end

	if not (state > 0) then
		state = nil
	end

	local v8 = {
		AvailableWidthPx = state,
		StructuredWrap = true,
		MinimalTables = props.MinimalTables == true
	}

	if text then
		local element = createElement(Controls.PrefixBadge, {
			LayoutOrder = 0,
			Text = text
		})
		local rawTextSize = Theme.RawTextSize
		local monoFont = Theme.MonoFont
		addPacked(
			v2,
			"ContextPrefix",
			element,
			LayoutMetrics.textWidth(text, rawTextSize, monoFont) + prefixBadgePadXPx,
			nil,
			v8
		)
	end

	renderParts(props.Line, props.Context, v2, v3, "", "", textOverflowMode, nil, v8, v7)

	if props.Repeats and props.Repeats > 1 then
		appendText(v2, v3, ` <font color="rgb(255,107,35)">(x{props.Repeats})</font>`, nil, textOverflowMode, nil, v8)
	end

	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = uDim2,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = uDim4,
			PaddingLeft = uDim3,
			PaddingRight = uDim3,
			PaddingTop = uDim4
		})
	}

	for k, v9 in v2 do
		if v9.Count ~= 0 then
			children[`Row{k}`] = createElement(LogRow, {
				LayoutOrder = k,
				TextOverflowMode = textOverflowMode,
				ContentWidthPx = v9.WidthPx,
				HorizontalAlignment = v9.HorizontalAlignment
			}, v9.Children)
		end
	end

	local lineNumber = props.LineNumber or 0
	return createElement("Frame", {
		ref = ref,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = lineNumber % 2 == 0 and 0.55 or 1,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0)
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		Content = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, children)
	})
end

return React.memo(LogLine)