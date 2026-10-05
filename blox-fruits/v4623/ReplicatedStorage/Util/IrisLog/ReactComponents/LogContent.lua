local React = require(game.ReplicatedStorage.Packages.React)
local FloatingCollapseButton = require(script.Parent.FloatingCollapseButton)
local Formatter = require(script.Parent.Formatter)
local LogLine = require(script.Parent.LogLine)
local LogList = require(script.Parent.LogList)
local LogText = require(script.Parent.LogText)
local TabBar = require(script.Parent.TabBar)
local Theme = require(script.Parent.Theme)
local ThreadPanel = require(script.Parent.ThreadPanel)
local Toolbar = require(script.Parent.Toolbar)
local TabDisplay = require(script.Parent.Parent.TabDisplay)
local createElement = React.createElement

local function noop() end

local function noopSelectLog(_) end

local function noopClear(_) end

local function useMeasuredHeight(flag: boolean, p)
	local ref = React.useRef(nil)
	local v, v2 = React.useBinding(0)
	local ref2 = React.useRef(0)
	React.useEffect(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function set(Y: number)
			if ref2.current == Y then
				return
			end

			ref2.current = Y
			v2(Y)
		end

		if flag then
			local current = ref.current

			if current then
				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateHeight()
					set(math.ceil(current.AbsoluteSize.Y)) -- equivalent call inferred; original call site unknown
				end

				updateHeight() -- equivalent call inferred; original call site unknown
				task.defer(updateHeight)
				local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateHeight)
				return function()
					absoluteSizeChangedConnection:Disconnect()
				end
			end
		end

		set(0) -- equivalent call inferred; original call site unknown
	end, p)
	return ref, v
end

local function LogContent(props)
	local log = props.Log
	local onFloatingMinimizedChanged = props.OnFloatingMinimizedChanged
	local showToolbar = props.ShowToolbar == true
	local v = not showToolbar and 0 or Theme.ToolbarHeight
	local showThreads = props.ShowThreads == true
	local v2 = log and #log.HeaderLines or 0
	local ref, v4 = useMeasuredHeight(v2 > 0, { log or false, v2, props.RenderVersion })
	local ref2, v6 = useMeasuredHeight(showThreads and log ~= nil, { showThreads, log or false, props.RenderVersion })

	if log then
		local visibleTabs, v7 = TabDisplay.visibleTabs(log.Tabs)
		local selectedTabIndex = TabDisplay.resolveSelectedTabIndex(log.Tabs, props.SelectedTabIndex)
		local visibleTabIndexForSourceIndex = TabDisplay.visibleTabIndexForSourceIndex(log.Tabs, selectedTabIndex)
		local tab = log.Tabs[selectedTabIndex]
		local v8 = #visibleTabs > 1
		local v9 = not v8 and 0 or Theme.TabBarHeight
		local onReorderTabs = props.OnReorderTabs
		local v10 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8)
			})
		}

		for k, headerLine in log.HeaderLines do
			local formatted = `Header{k}`
			local v13 = {
				Context = props.Context,
				LayoutOrder = k,
				Line = headerLine,
				LineNumber = k,
				Repeats = 0,
				DynamicVersion = 0,
				TextOverflowMode = 0,
				MinimalTables = 0
			}
			local dynamicVersion

			if Formatter.lineContainsDynamic(headerLine) then
				dynamicVersion = props.RenderVersion
			end

			v13.DynamicVersion = dynamicVersion
			v13.TextOverflowMode = props.TextOverflowMode
			v13.MinimalTables = props.MinimalTables
			v10[formatted] = createElement(LogLine, v13)
		end

		local v13 = {
			BackgroundTransparency = 1,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.fromScale(1, 1)
		}
		local v14 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Toolbar = 0,
			Threads = 0,
			Headers = 0,
			Tabs = 0,
			ListWrap = 0
		}
		local toolbar

		if showToolbar then
			toolbar = createElement(Toolbar, {
				LayoutOrder = 1,
				Logs = props.Logs or {},
				LogVersion = props.LogVersion,
				SelectedLog = log,
				OnSelectLog = props.OnSelectLog or noopSelectLog,
				OnClear = props.OnClear or noopClear,
				OnResetWindow = props.OnResetWindow or noop
			})
		end

		v14.Toolbar = toolbar
		local threads

		if showThreads then
			threads = createElement("Frame", {
				ref = ref2,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0)
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8)
				}),
				Panel = createElement(ThreadPanel, {
					LayoutOrder = 1,
					Threads = log.Threads
				})
			})
		end

		v14.Threads = threads
		local headers

		if #log.HeaderLines > 0 then
			headers = createElement("Frame", {
				ref = ref,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 0)
			}, v10)
		end

		v14.Headers = headers
		local tabs

		if v8 then
			local v21 = {
				LayoutOrder = 4,
				Tabs = visibleTabs,
				SelectedIndex = visibleTabIndexForSourceIndex,
				OnSelect = function(p: number)
					props.OnSelectTab(v7[p] or p)
				end,
				OnReorder = onReorderTabs and function(p: number, p2: number)
					onReorderTabs(v7[p] or p, v7[p2] or p2)
				end or nil,
				RightControl = 0,
				RightControlWidthPx = 0
			}
			local rightControl

			if onFloatingMinimizedChanged then
				rightControl = createElement(FloatingCollapseButton, {
					Collapsed = props.FloatingMinimized == true,
					OnActivated = function()
						onFloatingMinimizedChanged(true)
					end
				})
			end

			v21.RightControl = rightControl
			local rightControlWidthPx

			if onFloatingMinimizedChanged then
				rightControlWidthPx = Theme.TabBarHeight
			end

			v21.RightControlWidthPx = rightControlWidthPx
			tabs = createElement(TabBar, v21)
		end

		v14.Tabs = tabs
		v14.ListWrap = createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			Size = React.joinBindings({ v4, v6 }):map(function(list)
				return UDim2.new(1, 0, 1, -(v + v9 + list[1] + list[2]))
			end)
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8)
			}),
			List = createElement(LogList, {
				Context = props.Context,
				Lines = tab and tab.Lines or {},
				RenderLimit = props.LineRenderLimit,
				LockedDown = props.LockedDown,
				RenderVersion = props.RenderVersion,
				TextOverflowMode = props.TextOverflowMode,
				MinimalTables = props.MinimalTables,
				OnLockedDownChanged = props.OnLockedDownChanged
			})
		})
		return createElement("Frame", v13, v14)
	else
		local v9 = {
			BackgroundTransparency = 1,
			LayoutOrder = props.LayoutOrder,
			Size = UDim2.fromScale(1, 1)
		}
		local v10 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Toolbar = 0,
			Empty = 0
		}
		local toolbar

		if showToolbar then
			toolbar = createElement(Toolbar, {
				LayoutOrder = 1,
				Logs = props.Logs or {},
				LogVersion = props.LogVersion,
				SelectedLog = nil,
				OnSelectLog = props.OnSelectLog or noopSelectLog,
				OnClear = props.OnClear or noopClear,
				OnResetWindow = props.OnResetWindow or noop
			})
		end

		v10.Toolbar = toolbar
		v10.Empty = createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 1, -v)
		}, {
			Text = createElement(LogText, {
				Text = "No visible logs.",
				TextColor3 = Theme.TextMuted,
				TextSize = 18,
				Font = Theme.FontBold
			})
		})
		return createElement("Frame", v9, v10)
	end
end

return React.memo(LogContent)