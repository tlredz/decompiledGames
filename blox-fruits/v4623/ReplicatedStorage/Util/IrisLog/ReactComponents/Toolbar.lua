local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local CategorizedDropdownGrid = require(script.Parent.CategorizedDropdownGrid)
local Controls = require(script.Parent.Controls)
local LogNameColors = require(script.Parent.Parent.LogNameColors)
local Popout = require(script.Parent.Popout)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local v = {
	error = "rgb(248,113,113)",
	warn = "rgb(250,204,21)",
	info = "rgb(86,196,240)"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitizeSearchText(value: string)
	return (value:gsub("'", ""))
end

local memo = React.memo(function(props)
	local state, setState = React.useState(false)
	local v4 = {
		ref = props.TextBoxRef,
		AutoLocalize = false
	}
	local backgroundColor

	if state then
		backgroundColor = Theme.ButtonHover
	else
		backgroundColor = Theme.Button
	end

	v4.BackgroundColor3 = backgroundColor
	v4.BorderSizePixel = 0
	v4.ClearTextOnFocus = false
	v4.Font = Theme.FontBold
	v4.LayoutOrder = props.LayoutOrder
	v4.PlaceholderColor3 = Theme.TextSubtle
	v4.PlaceholderText = "Search (')"
	v4.RichText = false
	v4.Selectable = false
	v4.Size = UDim2.fromOffset(Theme.LogSearchWidth, Theme.ControlHeight)
	v4.Text = props.Text
	v4.TextColor3 = Theme.Text
	v4.TextSize = Theme.ControlTextSize
	v4.TextStrokeTransparency = 1
	v4.TextTruncate = Enum.TextTruncate.AtEnd
	v4.TextXAlignment = Enum.TextXAlignment.Left
	v4.TextYAlignment = Enum.TextYAlignment.Center

	v4[React.Change.Text] = function(p)
		props.OnChanged(p)
	end

	v4[React.Event.Focused] = function()
		setState(true)
		props.OnFocused()
	end

	v4[React.Event.FocusLost] = function(_, flag: boolean)
		setState(false)

		if flag then
			props.OnSubmit()
		end
	end

	return createElement("TextBox", v4, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 1)
		})
	})
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function escapeRichText(name: string)
	return (name:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function logSearchText(p)
	if p then
		return string.lower((tostring(p.Name)))
	end

	return ""
end

local function bestLogMatch(logs, list: string)
	if list == "" then
		return nil
	end

	local v2 = 1e999
	local v3 = nil

	for _, item in logs do
		local v5 = not item and "" or string.lower((tostring(item.Name)))
		local v6

		if v5 == list then
			v6 = 1
		elseif string.sub(v5, 1, #list) == list then
			v6 = 2
		elseif string.find(v5, list, 1, true) then
			v6 = 3
		else
			v6 = nil
		end

		if not (v6 and v6 < v2) then
			continue
		end

		if v6 == 1 then
			v3 = item
			break
		else
			v3 = item
			v2 = v6
		end
	end

	return v3
end

local function logNameColor(p)
	if p == nil then
		return nil
	end

	return p.NameColor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isHiddenLog(p)
	return p ~= nil and p.IrisLogSettings ~= nil and p.IrisLogSettings.Hidden == true
end

local function explicitLogCategory(p)
	if not p then
		return nil
	end

	local category = p.Category

	if typeof(category) ~= "string" and p.IrisLogSettings ~= nil then
		category = p.IrisLogSettings.Category
	end

	if typeof(category) == "string" and category ~= "" then
		return category
	end

	return nil
end

local function logCategory(data)
	if not data then
		return nil
	end

	if data.Pinned then
		return "Pinned"
	end

	local category

	if data then
		category = data.Category

		if typeof(category) ~= "string" and data.IrisLogSettings ~= nil then
			category = data.IrisLogSettings.Category
		end

		if typeof(category) ~= "string" or category == "" then
			category = nil
		end
	end

	if category then
		return category
	end

	local v2

	if data == nil or data.IrisLogSettings == nil then
		v2 = false
	else
		v2 = data.IrisLogSettings.Hidden == true
	end

	if v2 then
		return "Hidden"
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function logDropdownRank(data)
	if data.Pinned then
		return 1
	end

	local v2

	if data ~= nil then
		v2 = data.NameColor
	end

	if v2 ~= nil then
		return 2
	end

	local v3

	if data == nil or data.IrisLogSettings == nil then
		v3 = false
	else
		v3 = data.IrisLogSettings.Hidden == true
	end

	if v3 then
		return 4
	end

	return 3
end

local function compareLogs(data, data2)
	local v2 = logDropdownRank(data) -- equivalent call inferred; original call site unknown
	local v3 = logDropdownRank(data2) -- equivalent call inferred; original call site unknown

	if v2 == v3 then
		return tostring(data.Name) < tostring(data2.Name)
	end

	return v2 < v3
end

local function compareCategories(value: string, value2: string)
	if value == "Pinned" and value2 ~= "Pinned" then
		return true
	end

	if value2 == "Pinned" and value ~= "Pinned" or value == "Hidden" and value2 ~= "Hidden" then
		return false
	end

	if value2 == "Hidden" and value ~= "Hidden" then
		return true
	end

	if value == "Uncategorized" and value2 ~= "Uncategorized" then
		return false
	end

	if value2 == "Uncategorized" and value ~= "Uncategorized" then
		return true
	end

	local v2 = string.lower(value)
	local v3 = string.lower(value2)

	if v2 == v3 then
		return value < value2
	end

	return v2 < v3
end

local function groupedRowCount(items)
	local v2 = {}
	local count = 0

	for _, item in items do
		local category

		if item then
			if item.Pinned then
				category = "Pinned"
			else
				if item then
					category = item.Category

					if typeof(category) ~= "string" and item.IrisLogSettings ~= nil then
						category = item.IrisLogSettings.Category
					end

					if typeof(category) ~= "string" or category == "" then
						category = nil
					end
				end

				if not category then
					category = isHiddenLog(item) and "Hidden" or nil
				end
			end
		end

		local v3 = category or "Uncategorized"

		if not v2[v3] then
			v2[v3] = true
			count += 1
		end

		count += 1
	end

	return count
end

local function categoryColorOverride(p: string)
	if p == "Pinned" then
		return Theme.LogDropdownPinnedCategory
	elseif p == "Hidden" then
		return Theme.LogDropdownHiddenCategory
	end

	return nil
end

local function colorRichText(color: Color3, p: string)
	return (`<font color="{LogNameColors.richTextColor(color)}">{p}</font>`)
end

local function logLabel(data)
	if not data then
		return "No logs"
	end

	local v2 = escapeRichText(tostring(data.Name)) -- equivalent call inferred; original call site unknown
	local nameColor

	if data ~= nil then
		nameColor = data.NameColor
	end

	if nameColor then
		v2 = `<font color="{LogNameColors.richTextColor(nameColor)}">{v2}</font>`
	end

	if data.Pinned then
		v2 = `📌 {v2}`
	end

	if data.New and data.New > 0 then
		return (`{v2} (<font color="{v[data.NewSeverity or "info"] or "rgb(86,196,240)"}">{data.New}</font>)`)
	end

	return v2
end

local function Toolbar(props)
	local state, setState = React.useState("")
	local state2, setState2 = React.useState(false)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(false)
	local selectedLog = props.SelectedLog
	local count = #props.Logs
	local v2 = string.lower(state)
	local logVersion = props.LogVersion or 0
	local v3 = React.useMemo(function()
		return (bestLogMatch(props.Logs, v2))
	end, { props.Logs, v2, logVersion })
	local items = React.useMemo(function()
		local logs = {}

		for _, log in props.Logs do
			if not (v2 == "" or string.find(not log and "" or string.lower((tostring(log.Name))), v2, 1, true)) then
				continue
			end

			table.insert(logs, log)
		end

		return logs
	end, { props.Logs, v2, logVersion })
	local v5

	if v2 == "" or not v3 then
		v5 = selectedLog
	else
		v5 = v3
	end

	local v6 = Controls.useInlinePopoutState(function()
		return #props.Logs > 0
	end)
	local opened = v6.Opened

	local function handleSearchChanged(p)
		local text = p.Text
		local text2 = sanitizeSearchText(text) -- equivalent call inferred; original call site unknown

		if text2 ~= text then
			p.Text = text2
		end

		if ref3.current then
			local text3 = sanitizeSearchText(state) -- equivalent call inferred; original call site unknown

			if text2 == text3 then
				ref3.current = false
			else
				p.Text = text3
			end

			setState(text3)
		else
			ref2.current = nil
			setState(text2)

			if text2 ~= "" and #props.Logs > 0 then
				v6.SetOpened(true)
			end
		end
	end

	local function handleSearchFocused()
		ref2.current = nil
		ref3.current = false
		setState("")
	end

	React.useEffect(function()
		if v2 == "" or not v3 then
			return
		end

		if ref2.current ~= v2 then
			v6.SetOpened(true)
		end

		if v3 ~= selectedLog then
			props.OnSelectLog(v3)
		end
	end, { v2, v3 or false, selectedLog or false })
	local v7 = math.max(1, (groupedRowCount(items)))
	local v8 = math.min(Theme.LogDropdownGridRows, v7)
	local heightPx = math.max(
		Theme.DropdownRowHeight + Theme.LogDropdownScrollBarThickness,
		v8 * Theme.DropdownRowHeight + math.max(0, v8 - 1) * 2 + 8 + Theme.LogDropdownScrollBarThickness
	)

	local function renderDropdownItem(p, layoutOrder: number, zIndex: number?)
		local selected = p == v5
		return createElement(Controls.DropdownOption, {
			Label = logLabel(p),
			Selected = selected,
			Hidden = isHiddenLog(p),
			RichText = true,
			Font = Theme.FontBold,
			LayoutOrder = layoutOrder,
			ZIndex = zIndex,
			OnActivated = function()
				v6.SetOpened(false)
				setState("")
				props.OnSelectLog(p)
			end
		})
	end

	local element = createElement("TextLabel", {
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 1,
		RichText = false,
		Size = UDim2.fromOffset(Theme.LogDropdownGridColumnWidth, Theme.DropdownRowHeight),
		Text = "No matching logs",
		TextColor3 = Theme.TextSubtle,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 132
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		})
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closePopup(p: string?)
		local current = p or v2

		if current ~= "" then
			ref2.current = current
		end

		v6.SetOpened(false)
	end

	local function shortcutSubmitSearch(text: string)
		local text2 = sanitizeSearchText(text) -- equivalent call inferred; original call site unknown
		ref3.current = true
		setState(text2)
		closePopup(string.lower(text2)) -- equivalent call inferred; original call site unknown
		task.defer(function()
			local current = ref.current

			if current and current.Text ~= text2 then
				current.Text = text2
			end
		end)
		task.delay(0.1, function()
			ref3.current = false
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function focusSearch()
		ref2.current = nil
		v6.SetOpened(count > 0)
		task.defer(function()
			local current = ref.current

			if current then
				current:CaptureFocus()
			end
		end)
	end

	React.useEffect(function()
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode ~= Enum.KeyCode.Quote then
				return
			end

			local focusedTextBox = UserInputService:GetFocusedTextBox()

			if focusedTextBox and focusedTextBox == ref.current then
				shortcutSubmitSearch(focusedTextBox.Text)
				focusedTextBox:ReleaseFocus(true)
			else
				if gameProcessed or focusedTextBox then
					return
				end

				focusSearch() -- equivalent call inferred; original call site unknown
			end
		end)
		return function()
			inputBeganConnection:Disconnect()
		end
	end, { count })

	local function renderSelector(ref4, flag: boolean)
		local zIndex = flag and 132 or nil
		local buttonHover

		if state2 or opened then
			buttonHover = Theme.ButtonHover
		elseif flag then
			buttonHover = Theme.Button
		else
			buttonHover = Theme.PanelDark
		end

		local v13 = {
			ref = ref4,
			AutoButtonColor = false,
			BackgroundColor3 = buttonHover,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			LayoutOrder = 1,
			RichText = false,
			Selectable = false
		}
		local size

		if flag then
			size = UDim2.new(1, 0, 0, Theme.ControlHeight)
		else
			size = UDim2.new(1, -Theme.ToolbarSelectorReservedWidth, 1, 0)
		end

		v13.Size = size
		v13.Text = ""
		v13.TextColor3 = Theme.TextMuted
		v13.TextSize = Theme.ControlTextSize
		v13.TextStrokeTransparency = 1
		v13.TextTruncate = Enum.TextTruncate.AtEnd
		v13.TextXAlignment = Enum.TextXAlignment.Left
		v13.ZIndex = zIndex
		v13[React.Event.Activated] = v6.Activate
		v13[React.Event.InputBegan] = v6.HeaderInputBegan

		v13[React.Event.MouseEnter] = function()
			setState2(true)
		end

		v13[React.Event.MouseLeave] = function()
			setState2(false)
		end

		local uICorner

		if not flag then
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			})
		end

		local v19 = {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			Position = UDim2.fromOffset(11, 0),
			RichText = true,
			Size = UDim2.new(1, -34, 1, 0),
			Text = logLabel(selectedLog),
			TextColor3 = 0,
			TextSize = 0,
			TextStrokeTransparency = 1,
			TextTruncate = 0,
			TextWrapped = false,
			TextXAlignment = 0,
			TextYAlignment = 0,
			ZIndex = 0
		}
		local selectedLog2 = selectedLog
		local v21

		if selectedLog2 == nil or selectedLog2.IrisLogSettings == nil then
			v21 = false
		else
			v21 = selectedLog2.IrisLogSettings.Hidden == true
		end

		local textColor

		if v21 then
			textColor = Theme.TextHidden
		else
			textColor = Theme.TextMuted
		end

		v19.TextColor3 = textColor
		v19.TextSize = Theme.ControlTextSize
		v19.TextTruncate = Enum.TextTruncate.AtEnd
		v19.TextXAlignment = Enum.TextXAlignment.Left
		v19.TextYAlignment = Enum.TextYAlignment.Center
		v19.ZIndex = zIndex
		local v15 = {
			UICorner = uICorner,
			Label = createElement("TextLabel", v19),
			Chevron = 0
		}
		local chevron

		if not (opened and not flag) then
			chevron = createElement(Controls.Chevron, {
				Color = Theme.TextSubtle,
				Rotation = flag and 0 or -90,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -11, 0.5, 0),
				ZIndex = zIndex
			})
		end

		v15.Chevron = chevron
		return createElement("TextButton", v13, v15)
	end

	return createElement("Frame", {
		BackgroundColor3 = Theme.Panel,
		BackgroundTransparency = Theme.PanelTransparency,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, Theme.ToolbarHeight),
		ZIndex = 100
	}, {
		Divider = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Theme.StrokeSubtle,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 101
		}),
		Row = createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, (math.floor((Theme.ToolbarHeight - Theme.ControlHeight) / 2))),
			Size = UDim2.new(1, -Theme.ToolbarSettingsReservedWidth, 0, Theme.ControlHeight),
			ZIndex = 101
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Selector = renderSelector(v6.AnchorRef, false),
			Clear = createElement(Controls.ActionButton, {
				LayoutOrder = 2,
				Text = "Clear",
				Disabled = selectedLog == nil,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, Theme.ControlHeight),
				OnActivated = function()
					if selectedLog then
						props.OnClear(selectedLog)
					end
				end
			}),
			Reset = createElement(Controls.ActionButton, {
				LayoutOrder = 3,
				Text = "Reset",
				Danger = true,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, Theme.ControlHeight),
				OnActivated = props.OnResetWindow
			}),
			Search = createElement(memo, {
				LayoutOrder = 4,
				Text = state,
				TextBoxRef = ref,
				OnChanged = handleSearchChanged,
				OnFocused = handleSearchFocused,
				OnSubmit = function()
					closePopup() -- equivalent call inferred; original call site unknown
				end
			})
		}),
		Dropdown = createElement(Popout, {
			Open = opened,
			AnchorRef = v6.AnchorRef,
			WidthPx = Theme.LogDropdownWidth,
			HeightPx = Theme.ControlHeight + heightPx,
			InitialVisibleHeightPx = Theme.ControlHeight,
			OffsetY = -Theme.ControlHeight + 1,
			OnOutsideInput = function()
				closePopup() -- equivalent call inferred; original call site unknown
			end,
			ZIndex = 130
		}, {
			Surface = createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 131
			}, {
				Header = renderSelector(nil, true),
				Grid = createElement("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, Theme.ControlHeight),
					Size = UDim2.new(1, 0, 1, -Theme.ControlHeight),
					ZIndex = 132
				}, {
					Rows = createElement(CategorizedDropdownGrid, {
						Items = items,
						GetCategory = logCategory,
						RenderItem = renderDropdownItem,
						CompareCategories = compareCategories,
						CompareItems = compareLogs,
						GetCategoryColor = categoryColorOverride,
						DefaultCategory = "Uncategorized",
						RowHeightPx = Theme.DropdownRowHeight,
						ColumnWidthPx = Theme.LogDropdownGridColumnWidth,
						HeightPx = heightPx,
						GapPx = 2,
						PaddingPx = 4,
						ScrollBarThicknessPx = Theme.LogDropdownScrollBarThickness,
						ZIndex = 132,
						Empty = element
					})
				})
			})
		})
	})
end

return React.memo(Toolbar)