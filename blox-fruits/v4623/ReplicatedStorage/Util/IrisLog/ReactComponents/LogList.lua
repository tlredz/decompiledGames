local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local Formatter = require(script.Parent.Formatter)
local InputUtils = require(script.Parent.InputUtils)
local LayoutMetrics = require(script.Parent.LayoutMetrics)
local LogLine = require(script.Parent.LogLine)
local LogText = require(script.Parent.LogText)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local v = Theme.VirtualLineHeight + 4
local v2 = math.max(1, Theme.RawTextSize * 0.55)
local v3 = Theme.RawTextSize + 2
local memo = React.memo(function(p)
	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PanelDark,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		LayoutOrder = p.LayoutOrder,
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
		Text = createElement(LogText, {
			Text = p.Text,
			TextColor3 = Theme.TextSubtle,
			TextSize = Theme.SecondaryTextSize
		})
	})
end)

local function pointerY(p)
	return p.Position.Y
end

local function newLineHeightCache()
	return (setmetatable({}, {
		__mode = "k"
	}))
end

local function newLineEstimateCache()
	return (setmetatable({}, {
		__mode = "k"
	}))
end

local function lineTextForEstimate(items, p)
	local texts = {}

	for _, item in items do
		local text = Formatter.toText(item, p)

		if text and text ~= "" then
			table.insert(texts, text)
		end
	end

	return table.concat(texts)
end

local function estimateWrappedLineHeight(p, p2, p3: number)
	local v4 = lineTextForEstimate(p, p2)

	if v4 == "" then
		return Theme.VirtualLineHeight
	end

	local stripRichText = TextMetrics.stripRichText(v4)
	local v5 = math.max(1, (math.floor(p3 / v2)))
	local total = 0

	for k in string.gmatch(stripRichText .. "\n", [[
([^
]*)
]]) do
		total += math.max(1, (math.ceil(#k / v5)))
	end

	local v6 = math.ceil(total * v3 * 1.15)
	return (math.max(Theme.VirtualLineHeight, v6 + LayoutMetrics.LinePadYPx * 2))
end

local function estimateLineHeightForMode(p, p2, p3: string?, width: number, current)
	if p3 ~= "wrap" or width <= 0 then
		return Theme.VirtualLineHeight
	end

	local lineContainsDynamic = Formatter.lineContainsDynamic(p)
	local v4 = not lineContainsDynamic and current[p]

	if v4 then
		return v4
	end

	local v6 = estimateWrappedLineHeight(p, p2, math.max(1, width - LayoutMetrics.LinePadXPx * 2))

	if not lineContainsDynamic then
		current[p] = v6
	end

	return v6
end

local function buildLayoutSnapshot(lines, current, estimateLineHeight)
	local count = #lines
	local prefixOffsets = {}
	local total = 0
	local indexByLine = {}

	for k, v6 in lines do
		prefixOffsets[k] = total
		indexByLine[v6] = k
		local v7 = current[v6] or estimateLineHeight(v6)
		total += math.max(Theme.VirtualLineHeight, (math.ceil(v7)))

		if k < count then
			total += 4
		end
	end

	prefixOffsets[count + 1] = total
	return {
		PrefixOffsets = prefixOffsets,
		IndexByLine = indexByLine,
		TotalContentHeight = not (count > 0) and 0 or total + 8
	}
end

local function lineOffsetAt(p, p2: number)
	return p.PrefixOffsets[p2] or 0
end

local function lineIndexAtOffset(p, p2: number, count: number)
	if count <= 0 then
		return 1
	end

	local v4 = math.max(0, p2)
	local v5 = 1
	local v6 = 1

	while v5 <= count do
		local v7 = math.floor((v5 + count) / 2)

		if (p.PrefixOffsets[v7] or 0) <= v4 then
			v5 = v7 + 1
			v6 = v7
		else
			count = v7 - 1
		end
	end

	return v6
end

local function LogList(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef((setmetatable({}, {
		__mode = "k"
	})))
	local ref4 = React.useRef((setmetatable({}, {
		__mode = "k"
	})))
	local ref5 = React.useRef(nil)
	local ref6 = React.useRef(props.Context)
	local ref7 = React.useRef(props.TextOverflowMode)
	local ref8 = React.useRef(false)
	local ref9 = React.useRef(0)
	local ref10 = React.useRef(false)
	local state, setState = React.useState({
		ScrollY = 0,
		DisplayScrollY = 0,
		Height = 0,
		Width = 0,
		LayoutVersion = 0
	})
	local ref11 = React.useRef(state)
	local state2, setState2 = React.useState(props.LockedDown)
	local ref12 = React.useRef(state2)
	local ref13 = React.useRef(0)
	local ref14 = React.useRef(nil)
	local ref15 = React.useRef(nil)
	local ref16 = React.useRef(props.OnLockedDownChanged)
	ref6.current = props.Context
	ref7.current = props.TextOverflowMode
	ref12.current = state2
	ref16.current = props.OnLockedDownChanged
	local count = #props.Lines
	local ref17 = React.useRef(count)
	ref17.current = count
	local formatted = `{props.TextOverflowMode or "clip"}:{props.MinimalTables == true and "minimal" or "full"}:{state.Width}`
	local ref18 = React.useRef(formatted)

	if ref18.current ~= formatted then
		ref18.current = formatted
		ref3.current = setmetatable({}, {
			__mode = "k"
		})
		ref4.current = setmetatable({}, {
			__mode = "k"
		})
	end

	React.useEffect(function()
		ref12.current = props.LockedDown
		setState2(props.LockedDown)
	end, { props.LockedDown, props.Lines })
	local v4 = React.useCallback(function()
		if ref8.current then
			return
		end

		ref8.current = true
		task.defer(function()
			ref8.current = false
			local current = ref11.current
			local current2 = ref9.current
			ref9.current = 0
			local scrollY

			if ref12.current then
				scrollY = current.ScrollY
			else
				scrollY = math.max(0, current.ScrollY + current2)
			end

			local displayScrollY

			if ref12.current then
				displayScrollY = current.DisplayScrollY
			else
				displayScrollY = math.max(0, current.DisplayScrollY + current2)
			end

			local current3 = {
				ScrollY = scrollY,
				DisplayScrollY = displayScrollY,
				Height = current.Height,
				Width = current.Width,
				LayoutVersion = current.LayoutVersion + 1
			}
			ref11.current = current3
			setState(current3)
		end)
	end, {})

	local function estimateLineHeight(p)
		return (estimateLineHeightForMode(p, props.Context, props.TextOverflowMode, state.Width, ref4.current))
	end

	local current4 = React.useMemo(function()
		return (buildLayoutSnapshot(props.Lines, ref3.current, estimateLineHeight))
	end, {
		props.Lines,
		count,
		state.LayoutVersion,
		formatted,
		props.Context
	})
	ref5.current = current4
	local height

	if state.Height > 0 then
		height = state.Height
	else
		height = Theme.VirtualLineHeight * Theme.VirtualInitialRows
	end

	local totalContentHeight = current4.TotalContentHeight
	local current5 = math.max(0, totalContentHeight - height)
	local scrollY2

	if state2 then
		scrollY2 = current5
	else
		scrollY2 = math.clamp(state.ScrollY, 0, current5)
	end

	local displayScrollY2

	if state2 then
		displayScrollY2 = current5
	else
		displayScrollY2 = math.clamp(state.DisplayScrollY, 0, current5)
	end

	ref13.current = current5
	ref11.current = {
		ScrollY = scrollY2,
		DisplayScrollY = displayScrollY2,
		Height = state.Height,
		Width = state.Width,
		LayoutVersion = state.LayoutVersion
	}

	local function setVirtualScroll(value: number, flag: boolean, flag2: boolean?)
		local scrollY = math.clamp(value, 0, ref13.current)
		local current = ref11.current
		local displayScrollY

		if flag2 == true then
			displayScrollY = scrollY
		else
			displayScrollY = current.DisplayScrollY
		end

		if current.ScrollY ~= scrollY or current.DisplayScrollY ~= displayScrollY then
			local current2 = {
				ScrollY = scrollY,
				DisplayScrollY = displayScrollY,
				Height = current.Height,
				Width = current.Width,
				LayoutVersion = current.LayoutVersion
			}
			ref11.current = current2
			setState(current2)
		end

		if flag then
			local current3 = ref13.current - 2 <= scrollY
			local v11 = flag2 == true or not current3
			ref10.current = current3 and not v11

			if v11 and ref12.current ~= current3 then
				ref12.current = current3
				setState2(current3)
				local current2 = ref16.current

				if current2 then
					current2(current3)
				end
			end
		end
	end

	ref14.current = setVirtualScroll

	local function updateViewportBounds(p)
		if not p then
			return
		end

		local height2 = math.max(0, (math.floor(p.AbsoluteSize.Y)))
		local width = math.max(0, (math.floor(p.AbsoluteSize.X)))
		local current = ref11.current

		if current.Height == height2 and current.Width == width then
			return
		end

		local current2 = {
			ScrollY = current.ScrollY,
			DisplayScrollY = current.DisplayScrollY,
			Height = height2,
			Width = width,
			LayoutVersion = current.LayoutVersion
		}
		ref11.current = current2
		setState(current2)
	end

	local function beginContentDrag(inputObject)
		if inputObject.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		ref15.current = {
			Mode = "content",
			InputObject = inputObject,
			UserInputType = inputObject.UserInputType,
			StartPointerY = inputObject.Position.Y,
			StartScrollY = ref11.current.DisplayScrollY
		}
	end

	local function beginThumbDrag(inputObject, trackHeight: number, thumbHeight: number)
		if not InputUtils.isPrimaryPointer(inputObject) or ref13.current <= 0 then
			return
		end

		ref15.current = {
			Mode = "thumb",
			InputObject = inputObject,
			UserInputType = inputObject.UserInputType,
			StartPointerY = inputObject.Position.Y,
			StartScrollY = ref11.current.DisplayScrollY,
			TrackHeight = trackHeight,
			ThumbHeight = thumbHeight
		}
	end

	local v9 = math.min(28, height)
	local v10

	if totalContentHeight > 0 and height > 0 then
		v10 = math.clamp(math.floor(height / totalContentHeight * height + 0.5), v9, height)
	else
		v10 = height
	end

	local v11 = math.max(0, height - v10)
	local v12 = not (current5 > 0 and v11 > 0) and 0 or math.clamp(
		math.floor(displayScrollY2 / current5 * v11 + 0.5),
		0,
		v11
	)
	local active

	if current5 > 0 then
		active = height > 0
	else
		active = false
	end

	local v14, v15, v16

	if count > 0 then
		local v17 = Theme.VirtualLineHeight * Theme.VirtualOverscanRows
		local v18 = math.max(0, displayScrollY2 - v17)
		local v19 = math.min(totalContentHeight, displayScrollY2 + height + v17)
		v14 = lineIndexAtOffset(current4, v18, count)
		local v20 = math.max(1, lineIndexAtOffset(current4, v19, count) - v14 + 1)
		local v21 = math.max(math.max(1, props.RenderLimit), v20 + 2)
		v15 = current4.PrefixOffsets[v14] or 0
		v16 = math.min(count, v14 + v21 - 1)
	else
		v15 = 0
		v14 = 1
		v16 = 0
	end

	local v17 = math.floor(v15 - displayScrollY2)
	local onHeightChanged = React.useCallback(function(p, p2: number)
		local v19 = math.max(Theme.VirtualLineHeight, (math.ceil(p2)))
		local current = ref3.current
		local v20 = current[p] or estimateLineHeightForMode(
			p,
			ref6.current,
			ref7.current,
			ref11.current.Width,
			ref4.current
		)

		if v19 == v20 then
			return
		end

		current[p] = v19
		local current2 = ref5.current
		local v21

		if current2 then
			v21 = current2.IndexByLine[p]
		end

		if current2 and v21 and not ref12.current and (current2.PrefixOffsets[v21] or 0) + (v20 + (v21 < ref17.current and 4 or 0)) <= ref11.current.DisplayScrollY then
			ref9.current += v19 - v20
		end

		v4()
	end, {})
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}
	local count2 = 0

	if count == 0 then
		children.Empty = createElement(memo, {
			LayoutOrder = count2,
			Text = "No log entries."
		})
	end

	for i = v14, v16 do
		count2 += 1
		local line = props.Lines[i]
		local formatted2 = `Line{i}`
		local v21 = {
			Context = props.Context,
			LayoutOrder = count2,
			Line = line,
			LineNumber = i,
			Repeats = Formatter.getRepeatCount(line),
			DynamicVersion = 0,
			TextOverflowMode = 0,
			MinimalTables = 0,
			OnHeightChanged = 0
		}
		local dynamicVersion

		if Formatter.lineContainsDynamic(line) then
			dynamicVersion = props.RenderVersion
		end

		v21.DynamicVersion = dynamicVersion
		v21.TextOverflowMode = props.TextOverflowMode
		v21.MinimalTables = props.MinimalTables
		v21.OnHeightChanged = onHeightChanged
		children[formatted2] = createElement(LogLine, v21)
	end

	if count == 0 or count <= v16 then
		children.BottomPad = createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = count2 + 1,
			Size = UDim2.new(1, 0, 0, 8)
		})
	end

	React.useEffect(function()
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			local current = ref15.current

			if not current then
				return
			end

			if current.UserInputType == Enum.UserInputType.Touch then
				if input ~= current.InputObject then
					return
				end
			elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			local current2 = ref14.current

			if not current2 then
				return
			end

			if current.Mode == "content" then
				current2(current.StartScrollY + (current.StartPointerY - input.Position.Y), true, true)
				return
			end

			local v19 = math.max(1, (current.TrackHeight or 0) - (current.ThumbHeight or 0))
			local v20 = (input.Position.Y - current.StartPointerY) / v19 * ref13.current
			current2(current.StartScrollY + v20, true, true)
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local current = ref15.current

			if not current or current.UserInputType == Enum.UserInputType.Touch and input ~= current.InputObject or current.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			ref15.current = nil
		end)
		return function()
			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, {})
	React.useEffect(function()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if ref12.current then
				return
			end

			local current = ref11.current
			local v19 = math.clamp(current.ScrollY, 0, ref13.current)

			-- [DEDUP] synthesized from 2 duplicated terminal regions
			local function deduplicatedTail()
				if ref10.current and ref13.current - 2 <= v19 and not ref12.current then
					ref10.current = false
					ref12.current = true
					setState2(true)
					local current2 = ref16.current

					if current2 then
						current2(true)
					end
				end
			end

			local v20 = math.clamp(current.DisplayScrollY, 0, ref13.current)
			local v21 = v19 - v20

			if v19 < ref13.current - 2 then
				ref10.current = false
			end

			if math.abs(v21) <= 0.5 then
				if current.ScrollY == v19 and current.DisplayScrollY == v19 then
					return deduplicatedTail()
				else
					local current2 = {
						ScrollY = v19,
						DisplayScrollY = v19,
						Height = current.Height,
						Width = current.Width,
						LayoutVersion = current.LayoutVersion
					}
					ref11.current = current2
					setState(current2)
					return deduplicatedTail()
				end
			else
				local current2 = {
					ScrollY = v19,
					DisplayScrollY = v20 + v21 * math.clamp(1 - math.exp(dt * -18), 0, 1),
					Height = current.Height,
					Width = current.Width,
					LayoutVersion = current.LayoutVersion
				}
				ref11.current = current2
				setState(current2)
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, {})
	React.useEffect(function()
		local scrollY

		if state2 then
			scrollY = current5
		else
			scrollY = math.clamp(state.ScrollY, 0, current5)
		end

		local displayScrollY

		if state2 then
			displayScrollY = current5
		else
			displayScrollY = math.clamp(state.DisplayScrollY, 0, current5)
		end

		if scrollY ~= state.ScrollY or displayScrollY ~= state.DisplayScrollY then
			local current = {
				ScrollY = scrollY,
				DisplayScrollY = displayScrollY,
				Height = state.Height,
				Width = state.Width,
				LayoutVersion = state.LayoutVersion
			}
			ref11.current = current
			setState(current)
		end
	end, {
		state2,
		current5,
		state.ScrollY,
		state.DisplayScrollY,
		state.Height,
		state.Width,
		state.LayoutVersion
	})
	React.useEffect(function()
		task.defer(function()
			updateViewportBounds(ref.current)
		end)
	end, {
		count,
		props.RenderLimit,
		v14,
		v16
	})

	local function handleFrameInputBegan(_, inputObject)
		beginContentDrag(inputObject)
	end

	local function handleFrameInputChanged(_, p)
		if p.UserInputType == Enum.UserInputType.MouseWheel then
			setVirtualScroll(ref11.current.ScrollY - p.Position.Z * v * 1.25, true)
		end
	end

	return createElement("Frame", {
		Active = true,
		BackgroundColor3 = Theme.PanelDarker,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		[React.Event.InputBegan] = handleFrameInputBegan,
		[React.Event.InputChanged] = handleFrameInputChanged
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		Viewport = createElement("Frame", {
			ref = ref,
			Active = true,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.new(1, -26, 1, -12),
			[React.Change.AbsoluteSize] = function(p)
				updateViewportBounds(p)
			end,
			[React.Event.InputBegan] = handleFrameInputBegan,
			[React.Event.InputChanged] = handleFrameInputChanged
		}, {
			Content = createElement("Frame", {
				Active = true,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, v17),
				Size = UDim2.new(1, 0, 0, 0),
				[React.Event.InputBegan] = handleFrameInputBegan,
				[React.Event.InputChanged] = handleFrameInputChanged
			}, children)
		}),
		Scrollbar = createElement("TextButton", {
			ref = ref2,
			Active = active,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Panel,
			BackgroundTransparency = active and 0.25 or 0.75,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -14, 0, 6),
			Selectable = false,
			Size = UDim2.new(0, 8, 1, -12),
			Text = "",
			[React.Event.InputBegan] = function(_, inputObject)
				if not (InputUtils.isPrimaryPointer(inputObject) and active) then
					return
				end

				local current = ref2.current

				if not current then
					return
				end

				local v29 = inputObject.Position.Y - current.AbsolutePosition.Y

				if v12 <= v29 and v29 <= v12 + v10 then
					return
				end

				local v30 = math.clamp(v29 - v10 / 2, 0, v11)
				setVirtualScroll(not (v11 > 0) and 0 or v30 / v11 * current5, true, true)
				beginThumbDrag(inputObject, current.AbsoluteSize.Y, v10)
			end
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, 99)
			}),
			Thumb = createElement("TextButton", {
				Active = active,
				AutoButtonColor = false,
				BackgroundColor3 = Theme.TextSubtle,
				BackgroundTransparency = active and 0.05 or 0.65,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, v12),
				Selectable = false,
				Size = UDim2.new(1, 0, 0, v10),
				Text = "",
				[React.Event.InputBegan] = function(_, inputObject)
					beginThumbDrag(inputObject, height, v10)
				end
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = UDim.new(0, 99)
				})
			})
		})
	})
end

return React.memo(LogList)