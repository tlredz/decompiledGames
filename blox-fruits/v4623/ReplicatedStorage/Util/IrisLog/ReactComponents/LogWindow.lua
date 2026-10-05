local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local Controls = require(script.Parent.Controls)
local FloatingCollapseButton = require(script.Parent.FloatingCollapseButton)
local HeaderBar = require(script.Parent.HeaderBar)
local InputUtils = require(script.Parent.InputUtils)
local KeyCodeSelector = require(script.Parent.KeyCodeSelector)
local LogNameColors = require(script.Parent.Parent.LogNameColors)
local Motion = require(script.Parent.Motion)
local Popout = require(script.Parent.Popout)
local ResizeGrip = require(script.Parent.ResizeGrip)
local Theme = require(script.Parent.Theme)
local WindowDragContext = require(script.Parent.WindowDragContext)
local createElement = React.createElement
local vector = Vector2.new(560, 260)
local vector2 = Vector2.new(Theme.TabBarHeight, Theme.TabBarHeight)
local vector3 = Vector2.new(500, 0)
local vector4 = Vector2.new(100, 100)
local gothamBlack = Enum.Font.GothamBlack
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 0, 0)
local v = math.ceil((#LogNameColors.Palette + 1) / 4)
local heightPx = v * 24 + 16 + (v - 1) * 6

-- equivalent calls inferred from this helper; original call sites unknown
local function viewportSize()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return currentCamera.ViewportSize
	end

	return (Vector2.new(1280, 720))
end

local function clampWindow(point: Vector2, point2: Vector2, point3: Vector2?)
	local v3 = viewportSize() -- equivalent call inferred; original call site unknown
	local v4 = point3 or vector
	local vector5 = Vector2.new(
		math.clamp(point2.X, v4.X, (math.max(v4.X, v3.X))),
		(math.clamp(point2.Y, v4.Y, (math.max(v4.Y, v3.Y))))
	)
	return
		Vector2.new(
			math.clamp(point.X, 0, (math.max(0, v3.X - vector5.X))),
			(math.clamp(point.Y, 0, (math.max(0, v3.Y - vector5.Y))))
		),
		vector5
end

local function isInPopout(position: Vector2)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	for _, parent in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		while parent do
			if CollectionService:HasTag(parent, "IrisLogPopoutGui") then
				return true
			else
				parent = parent.Parent
			end
		end
	end

	return false
end

local function taggedGuiObjectAncestor(parent, tag: string)
	while parent do
		if parent:IsA("GuiObject") and CollectionService:HasTag(parent, tag) then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function hasTaggedAncestor(parent, tag: string)
	while parent do
		if CollectionService:HasTag(parent, tag) then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function windowRootForObject(p)
	return (taggedGuiObjectAncestor(p, "IrisLogWindowRoot"))
end

local function isTopIrisLogWindowAt(position: Vector2, current)
	if not current then
		return false
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	for _, v3 in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		local v4 = windowRootForObject(v3) -- equivalent call inferred; original call site unknown

		if v4 then
			return v4 == current
		end
	end

	return false
end

local function isTabButtonObject(parent)
	while parent do
		if CollectionService:HasTag(parent, "IrisLogTabButton") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function isFloatingCollapseButtonObject(parent)
	while parent do
		if CollectionService:HasTag(parent, "IrisLogFloatingCollapseButton") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function isHorizontalTabDrag(point: Vector2)
	return math.abs(point.X) >= 6 and math.abs(point.X) > math.abs(point.Y)
end

local function scrollingFrameForObject(parent)
	while parent do
		if parent:IsA("ScrollingFrame") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function isPointInVerticalScrollbar(point: Vector2, parent)
	if not parent.ScrollingEnabled or parent.ScrollBarThickness <= 0 or parent.ScrollingDirection ~= Enum.ScrollingDirection.Y and parent.ScrollingDirection ~= Enum.ScrollingDirection.XY or parent.AbsoluteCanvasSize.Y <= parent.AbsoluteWindowSize.Y then
		return false
	end

	local absolutePosition = parent.AbsolutePosition
	local absoluteSize = parent.AbsoluteSize
	local scrollBarThickness = parent.ScrollBarThickness
	local X

	if parent.VerticalScrollBarPosition == Enum.VerticalScrollBarPosition.Left then
		X = absolutePosition.X
	else
		X = absolutePosition.X + absoluteSize.X - scrollBarThickness
	end

	return X <= point.X and point.X <= X + scrollBarThickness and point.Y >= absolutePosition.Y and point.Y <= absolutePosition.Y + absoluteSize.Y
end

local function dragTargetInfoAt(position: Vector2, flag: boolean)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false, false
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false, false
	end

	local v3 = false

	for _, instance in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		local parent = instance
		local flag2

		while true do
			if not parent then
				flag2 = false
				break
			end

			if CollectionService:HasTag(parent, "IrisLogFloatingCollapseButton") then
				flag2 = true
				break
			else
				parent = parent.Parent
			end
		end

		if flag2 then
			if not flag then
				return true, v3
			end
		else
			local parent2 = instance
			local flag3

			while true do
				if not parent2 then
					flag3 = false
					break
				end

				if CollectionService:HasTag(parent2, "IrisLogTabButton") then
					flag3 = true
					break
				else
					parent2 = parent2.Parent
				end
			end

			if flag3 then
				v3 = true
			else
				local parent3 = instance

				while true do
					if not parent3 then
						parent3 = nil
						break
					end

					if parent3:IsA("ScrollingFrame") then
						break
					else
						parent3 = parent3.Parent
					end
				end

				if parent3 and isPointInVerticalScrollbar(position, parent3) then
					return true, v3
				end

				if instance:IsA("TextBox") or instance:FindFirstAncestorWhichIsA("TextBox") or instance:IsA("GuiButton") or instance:FindFirstAncestorWhichIsA("GuiButton") then
					return true, v3
				end
			end
		end
	end

	return false, v3
end

return function(props)
	local state, setState = React.useState(props.PositionPx)
	local state2, setState2 = React.useState(props.SizePx)
	local state3, setState3 = React.useState(false)
	local state4, setState4 = React.useState(false)
	local state5, setState5 = React.useState(false)
	local state6, setState6 = React.useState(false)
	local state7, setState7 = React.useState(false)
	local state8, setState8 = React.useState(nil)
	local state9, setState9 = React.useState("")
	local state10, setState10 = React.useState(false)
	local state11, setState11 = React.useState(false)
	local state12, setState12 = React.useState(false)
	local v3, v4 = React.useBinding(props.PositionPx)
	local v5, v6 = React.useBinding(props.SizePx)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(0)
	local ref5 = React.useRef(nil)
	local ref6 = React.useRef(false)
	local ref7 = React.useRef(false)
	local ref8 = React.useRef(state)
	local ref9 = React.useRef(state2)
	local angle, v8 = Motion.useNumberMotion(0)
	local angle2, v10 = Motion.useNumberMotion(0)
	local vector5 = Vector2.new(Theme.CollapsedWindowWidth, Theme.CollapsedHeaderHeight)
	local selectedLog = props.SelectedLog
	local onFloatingMinimizedChanged = props.OnFloatingMinimizedChanged
	local headerless = props.Headerless == true
	local showSettings = props.ShowSettings ~= false
	local v11 = headerless and props.FloatingMinimized == true
	local v12 = v11 or state4 and not headerless
	local v13 = state3 and not headerless

	-- equivalent calls inferred from this helper; original call sites unknown
	local function displaySizeFor(sizePx: Vector2)
		if v13 then
			return vector5
		end

		if v12 then
			return vector2
		end

		return sizePx
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function minimizedPosition()
		local v14 = viewportSize() -- equivalent call inferred; original call site unknown
		return Vector2.new(math.max(0, v14.X - vector2.X), (math.max(0, v14.Y - vector2.Y)))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setMainMinimized(flag: boolean)
		if flag then
			local current = minimizedPosition() -- equivalent call inferred; original call site unknown
			ref8.current = current
			setState(current)
			v4(current)
			v6(vector2)

			if props.OnWindowChanged then
				props.OnWindowChanged(current, ref9.current)
			end
		end

		setState4(flag)
	end

	if not ref6.current then
		ref8.current = state
		ref9.current = state2
	end

	local useEffect = React.useEffect

	local function fn()
		local sizePx

		if v13 or v11 then
			sizePx = props.SizePx

			if v13 then
				sizePx = vector5
			elseif v12 then
				sizePx = vector2
			end
		end

		local current, sizePx2 = clampWindow(props.PositionPx, sizePx or props.SizePx, sizePx or props.MinSizePx)

		if sizePx then
			sizePx2 = props.SizePx
		end

		setState(current)
		setState2(sizePx2)
		ref8.current = current
		ref9.current = sizePx2
		v4(current)
		local v16 = displaySizeFor(sizePx2) -- equivalent call inferred; original call site unknown
		v6(v16)

		if props.OnWindowChanged and (current ~= props.PositionPx or sizePx2 ~= props.SizePx) then
			props.OnWindowChanged(current, sizePx2)
		end
	end

	local resetToken = props.ResetToken
	local X

	if props.MinSizePx then
		X = props.MinSizePx.X or false
	else
		X = false
	end

	local v15

	if props.MinSizePx then
		v15 = props.MinSizePx.Y or false
	else
		v15 = false
	end

	useEffect(fn, {
		resetToken,
		X,
		v15,
		headerless,
		v11
	})
	React.useEffect(function()
		if ref6.current then
			return
		end

		ref8.current = state
		ref9.current = state2
		local current = state

		if not (v13 or v12) then
			current = clampWindow(state, state2, props.MinSizePx)

			if current ~= state then
				setState(current)
				ref8.current = current

				if props.OnWindowChanged then
					props.OnWindowChanged(current, state2)
				end
			end
		end

		v4(current)
		local v18 = state2

		if v13 then
			v18 = vector5
		elseif v12 then
			v18 = vector2
		end

		v6(v18)
	end, {
		state,
		state2,
		state3,
		headerless,
		v12
	})
	React.useEffect(function()
		if (state3 or headerless or v12 or not showSettings) and state5 then
			setState5(false)
		end

		if (state3 or headerless or v12 or not showSettings) and state6 then
			setState6(false)
		end

		if (state3 or headerless or v12 or not showSettings) and state7 then
			setState7(false)
		end
	end, {
		state3,
		headerless,
		v12,
		showSettings,
		state5,
		state6,
		state7
	})
	React.useEffect(function()
		if not state5 and state8 ~= nil then
			setState8(nil)
			setState9("")
			setState10(false)
		end
	end, { state5, state8 })
	React.useEffect(function()
		v8(state5 and 90 or 0, Motion.Rotate)
	end, { state5 })
	React.useEffect(function()
		v10(state6 and 90 or 0, Motion.Rotate)
	end, { state6 })
	React.useEffect(function()
		if selectedLog == nil and state6 then
			setState6(false)
		end

		if selectedLog == nil and state7 then
			setState7(false)
		end
	end, { selectedLog or false, state6, state7 })
	React.useEffect(function()
		if not state6 and state7 then
			setState7(false)
		end
	end, { state6, state7 })

	local function applyWindow(point: Vector2, point2: Vector2, flag: boolean)
		local v16

		if v13 or v12 then
			if v13 then
				v16 = vector5
			elseif v12 then
				v16 = vector2
			else
				v16 = point2
			end
		end

		local current2, v18 = clampWindow(point, v16 or point2, v16 or props.MinSizePx)
		local current

		if v16 then
			current = ref9.current
		else
			current = v18
		end

		ref8.current = current2
		ref9.current = current
		v4(current2)
		v6(v16 or v18)

		if flag then
			setState(current2)
			setState2(current)
		end

		if props.OnWindowChanged then
			props.OnWindowChanged(current2, current)
		end

		return current2, current
	end

	local function beginDrag(input, flag: boolean?)
		if not InputUtils.isPrimaryPointer(input) or ref6.current then
			return
		end

		ref6.current = true
		ref7.current = false
		local position = InputUtils.position(input)
		local current = ref8.current
		local v16 = current
		local current2 = ref9.current
		local v17 = flag ~= true
		local inputChangedConnection = nil
		local inputEndedConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disconnect()
			if inputChangedConnection then
				inputChangedConnection:Disconnect()
				inputChangedConnection = nil
			end

			if inputEndedConnection then
				inputEndedConnection:Disconnect()
				inputEndedConnection = nil
			end
		end

		inputChangedConnection = UserInputService.InputChanged:Connect(function(input2)
			if not InputUtils.isPointerMove(input2) then
				return
			end

			local v18 = InputUtils.position(input2) - position

			if not v17 then
				if v18.Magnitude < 6 then
					return
				end

				local v19

				if math.abs(v18.X) >= 6 then
					v19 = math.abs(v18.X) > math.abs(v18.Y)
				else
					v19 = false
				end

				if v19 then
					ref6.current = false
					disconnect() -- equivalent call inferred; original call site unknown
					return
				else
					v17 = true
				end
			end

			if v18.Magnitude > 3 then
				ref7.current = true
			end

			v16, current2 = applyWindow(current + v18, ref9.current, false)
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input2)
			if input2.UserInputType ~= input.UserInputType then
				return
			end

			disconnect() -- equivalent call inferred; original call site unknown
			ref6.current = false

			if v17 then
				applyWindow(v16, current2, true)
			end
		end)
	end

	if v13 then
		state2 = vector5
	elseif v12 then
		state2 = vector2
	end

	React.useEffect(function()
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if not InputUtils.isPrimaryPointer(input) then
				return
			end

			local position = InputUtils.position(input)

			if isInPopout(position) then
				return
			end

			local v16

			if position.X >= state.X and position.X <= state.X + state2.X and position.Y >= state.Y then
				v16 = position.Y <= state.Y + state2.Y
			else
				v16 = false
			end

			if not (v16 and isTopIrisLogWindowAt(position, ref5.current)) then
				return
			end

			local v17, v18 = dragTargetInfoAt(position, v12)

			if v17 then
				return
			end

			local v19 = not (v13 or v12)

			if v19 then
				if position.X >= state.X + state2.X - 28 then
					v19 = position.Y >= state.Y + state2.Y - 28
				else
					v19 = false
				end
			end

			if v19 then
				return
			end

			beginDrag(input, v18 and not headerless)
		end)
		return function()
			inputBeganConnection:Disconnect()
		end
	end, {
		state,
		state2,
		state3,
		headerless,
		v12
	})

	local function beginResize(p)
		if not InputUtils.isPrimaryPointer(p) then
			return
		end

		local position = InputUtils.position(p)
		ref6.current = true
		local current = ref9.current
		local current2 = ref8.current
		local v16 = current
		local inputEndedConnection = nil
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if not InputUtils.isPointerMove(input) then
				return
			end

			current2, v16 = applyWindow(ref8.current, current + (InputUtils.position(input) - position), false)
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= p.UserInputType then
				return
			end

			if inputChangedConnection then
				inputChangedConnection:Disconnect()
			end

			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end

			ref6.current = false
			applyWindow(current2, v16, true)
		end)
	end

	local function settingsRow(label: string, selected: boolean, layoutOrder: number, fn2, flag2: boolean?)
		return createElement(Controls.CheckRow, {
			Label = label,
			Selected = selected,
			LayoutOrder = layoutOrder,
			Disabled = flag2,
			OnActivated = fn2
		})
	end

	local function settingsOption(p: string, p2: string, p3: number)
		local v16 = props.TextOverflowMode == p2
		return settingsRow(p, v16, p3, function()
			props.OnTextOverflowModeChanged(v16 and "clip" or p2)
		end)
	end

	local function settingsToggle(label: string, selected: boolean, layoutOrder: number, callback, flag2: boolean?)
		return settingsRow(label, selected, layoutOrder, function()
			callback(not selected)
		end, flag2)
	end

	local function beginSettingsExport()
		local onExportSettings = props.OnExportSettings

		if state10 or not onExportSettings then
			return
		end

		ref4.current += 1
		local current = ref4.current
		setState8("export")
		setState9("")
		setState10(true)
		task.spawn(function()
			local v17, v18 = onExportSettings()

			if ref4.current ~= current then
				return
			end

			setState10(false)

			if v17 and v18 then
				setState9(v18)
			end
		end)
	end

	local function beginSettingsImport()
		ref4.current += 1
		setState8("import")
		setState9("")
		setState10(false)
	end

	local function applySettingsImport()
		local onImportSettings = props.OnImportSettings

		if state10 or not onImportSettings then
			return
		end

		ref4.current += 1
		local current = ref4.current
		local v17 = state9
		setState10(true)
		task.spawn(function()
			local v18 = onImportSettings(v17)

			if ref4.current ~= current then
				return
			end

			setState10(false)

			if v18 then
				setState9("")
			end
		end)
	end

	local function settingsTransferButton(text: string, applySettingsImport2)
		return createElement(Controls.ActionButton, {
			Text = text,
			LayoutOrder = 2,
			Disabled = state10,
			Size = UDim2.new(1, 0, 0, 28),
			CornerRadius = Theme.CornerSmall,
			ZIndex = 183,
			OnActivated = applySettingsImport2
		})
	end

	local function settingsTransferPanel()
		if state8 == nil then
			return nil
		end

		local v16 = state8 == "import"
		local v19 = {
			BackgroundColor3 = Theme.PanelDarker,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			LayoutOrder = 8,
			Size = UDim2.new(1, 0, 0, v16 and 160 or 124),
			ZIndex = 181
		}
		local v20 = {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8)
			}),
			TextBox = createElement("TextBox", {
				AutoLocalize = false,
				BackgroundColor3 = Theme.PanelDark,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Theme.MonoFont,
				LayoutOrder = 1,
				MultiLine = true,
				PlaceholderColor3 = Theme.TextSubtle,
				PlaceholderText = v16 and "Paste settings export" or "Settings export",
				RichText = false,
				Selectable = true,
				Size = UDim2.new(1, 0, 0, 108),
				Text = state10 and not v16 and "" or state9,
				TextColor3 = Theme.Text,
				TextEditable = not state10,
				TextSize = 13,
				TextStrokeTransparency = 1,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 182,
				[React.Change.Text] = v16 and function(p)
					setState9(p.Text)
				end or nil
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = UDim.new(0, Theme.CornerSmall)
				}),
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingTop = UDim.new(0, 6)
				})
			}),
			Apply = 0
		}
		local apply

		if v16 then
			apply = settingsTransferButton(state10 and "Importing" or "Apply import", applySettingsImport)
		end

		v20.Apply = apply
		return createElement("Frame", v19, v20)
	end

	local function keyCodeSettingRow(layoutOrder: number)
		local disabled = selectedLog == nil or props.OnFloatingHotkeyChanged == nil
		return createElement(Controls.SettingsRow, {
			Label = "Floating key",
			LayoutOrder = layoutOrder,
			Disabled = disabled,
			RightWidthPx = Theme.KeyCodeSelectorWidth,
			ZIndex = 181
		}, {
			Selector = createElement(KeyCodeSelector, {
				LayoutOrder = 1,
				Value = props.FloatingHotkeyNames,
				ZIndex = 182,
				OnChanged = function(p2)
					if selectedLog and props.OnFloatingHotkeyChanged then
						props.OnFloatingHotkeyChanged(selectedLog, p2)
					end
				end
			})
		})
	end

	local function logColorSettingRow(layoutOrder: number)
		local disabled = selectedLog == nil
		local nameColorKey

		if selectedLog then
			nameColorKey = selectedLog.NameColorKey
		end

		local color3

		if selectedLog and selectedLog.NameColor then
			color3 = selectedLog.NameColor
		else
			color3 = Theme.TextMuted
		end

		return createElement(Controls.SettingsRow, {
			Label = "Name color",
			LayoutOrder = layoutOrder,
			Disabled = disabled,
			RightWidthPx = 22,
			ZIndex = 181
		}, {
			Swatch = createElement(Controls.ColorSwatchButton, {
				ButtonRef = ref3,
				Color = color3,
				Default = nameColorKey == nil,
				StrongStroke = nameColorKey ~= nil,
				Open = state7,
				Disabled = disabled,
				LayoutOrder = 1,
				SizePx = 22,
				ZIndex = 182,
				OnActivated = function()
					setState7(not state7)
				end
			})
		})
	end

	local function colorGridButton(p: string?, color3: Color3, layoutOrder: number)
		local selected

		if selectedLog == nil then
			selected = false
		else
			selected = selectedLog.NameColorKey == p
		end

		return createElement(Controls.ColorSwatchButton, {
			Color = color3,
			Selected = selected,
			Default = p == nil,
			LayoutOrder = layoutOrder,
			SizePx = 24,
			ZIndex = 202,
			OnActivated = function()
				if selectedLog then
					props.OnLogNameColorChanged(selectedLog, p)
				end

				setState7(false)
			end
		})
	end

	local function colorGridChildren()
		local result = {
			UIGridLayout = createElement("UIGridLayout", {
				CellPadding = UDim2.fromOffset(6, 6),
				CellSize = UDim2.fromOffset(24, 24),
				FillDirectionMaxCells = 4,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8)
			}),
			Default = colorGridButton(nil, Theme.TextMuted, 1)
		}

		for k, v16 in LogNameColors.Palette do
			result[`Color{k}`] = colorGridButton(v16.Key, v16.Color, k + 1)
		end

		return result
	end

	local v16 = Theme.HeaderHeight + math.floor((Theme.ToolbarHeight - Theme.SettingsButtonSize) / 2)
	local v17 = Theme.SettingsButtonSize * 2 + 6

	local function settingsTooltip(open: boolean, anchorRef, text: string, zIndex: number)
		return createElement(Controls.TooltipPopout, {
			Open = open,
			AnchorRef = anchorRef,
			Text = text,
			WidthPx = Theme.SettingsTooltipWidth,
			HeightPx = Theme.SettingsTooltipHeight,
			OffsetY = 4,
			HorizontalAlign = "right",
			ZIndex = zIndex
		})
	end

	local function settingsButton(props2)
		local disabled = props2.Disabled == true
		local v20 = {
			ref = props2.ButtonRef,
			AutoButtonColor = false
		}
		local backgroundColor

		if props2.Open then
			backgroundColor = Theme.ButtonSelected
		else
			backgroundColor = Theme.Button
		end

		v20.BackgroundColor3 = backgroundColor
		v20.BackgroundTransparency = disabled and 0.45 or Theme.ControlTransparency
		v20.BorderSizePixel = 0
		v20.LayoutOrder = props2.LayoutOrder
		v20.Selectable = false
		v20.Size = UDim2.fromOffset(Theme.SettingsButtonSize, Theme.SettingsButtonSize)
		v20.Text = ""
		v20.ZIndex = 45
		local activated = React.Event.Activated
		local v22

		if not disabled then
			v22 = props2.OnActivated
		end

		v20[activated] = v22

		v20[React.Event.MouseEnter] = function()
			props2.HoveredChanged(true)
			Motion.to(props2.ButtonRef.current, Motion.Hover, {
				BackgroundColor3 = Theme.ButtonHover
			})
		end

		v20[React.Event.MouseLeave] = function()
			props2.HoveredChanged(false)
			local to = Motion.to
			local current = props2.ButtonRef.current
			local hover = Motion.Hover
			local backgroundColor2

			if props2.Open then
				backgroundColor2 = Theme.ButtonSelected
			else
				backgroundColor2 = Theme.Button
			end

			to(current, hover, {
				BackgroundColor3 = backgroundColor2
			})
		end

		local v23 = {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1)
			}),
			Icon = createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://127503254560275",
				ImageColor3 = Theme.Text,
				ImageRectOffset = vector3,
				ImageRectSize = vector4,
				ImageTransparency = disabled and 0.35 or 0,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = props2.Angle,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1.05, 1.05),
				ZIndex = 46
			}),
			Scope = 0
		}
		local v26 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = gothamBlack,
			Position = UDim2.fromScale(0.5, 0.5),
			RichText = false,
			Size = UDim2.fromScale(1, 1),
			Text = props2.Label,
			TextColor3 = 0,
			TextSize = 16,
			TextStrokeTransparency = 1,
			TextXAlignment = 0,
			TextYAlignment = 0,
			ZIndex = 47
		}
		local textColor

		if disabled then
			textColor = Theme.TextMuted
		else
			textColor = color
		end

		v26.TextColor3 = textColor
		v26.TextXAlignment = Enum.TextXAlignment.Center
		v26.TextYAlignment = Enum.TextYAlignment.Center
		v23.Scope = createElement("TextLabel", v26, {
			UIStroke = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Color = color2,
				Thickness = 2,
				Transparency = disabled and 0.35 or 0
			})
		})
		return createElement("TextButton", v20, v23)
	end

	local v20 = {
		ref = ref5,
		Active = true,
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = Theme.WindowTransparency,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = v3:map(function(point: Vector2)
			return UDim2.fromOffset(point.X, point.Y)
		end),
		Size = v5:map(function(point: Vector2)
			return UDim2.fromOffset(point.X, point.Y)
		end),
		[React.Tag] = "IrisLogWindowRoot"
	}
	local children = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerWindow)
		}),
		TitleBar = 0,
		SettingsButtons = 0,
		GlobalSettingsTooltip = 0,
		LogSettingsTooltip = 0,
		SettingsPopout = 0,
		LogSettingsPopout = 0,
		LogColorPickerPopout = 0,
		FloatingCollapsedButton = 0,
		Content = 0,
		Resize = 0
	}
	local titleBar

	if not (headerless or v12) then
		local v24 = {
			Title = props.Title,
			Collapsed = state3,
			Height = 0,
			OnMinimize = 0,
			OnExit = 0,
			OnActivated = 0,
			OnInputBegan = 0
		}
		local height

		if state3 then
			height = Theme.CollapsedHeaderHeight
		else
			height = Theme.HeaderHeight
		end

		v24.Height = height

		function v24.OnMinimize()
			local current = minimizedPosition() -- equivalent call inferred; original call site unknown
			ref8.current = current
			setState(current)
			v4(current)
			v6(vector2)

			if props.OnWindowChanged then
				props.OnWindowChanged(current, ref9.current)
			end

			setState4(true)
		end

		v24.OnExit = props.OnClose

		function v24.OnActivated()
			if ref7.current then
				ref7.current = false
			else
				setState3(not state3)
			end
		end

		v24.OnInputBegan = beginDrag
		titleBar = createElement(HeaderBar, v24)
	end

	children.TitleBar = titleBar
	local settingsButtons

	if not (state3 or headerless or v12 or not showSettings) then
		settingsButtons = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -4, 0, v16),
			Size = UDim2.fromOffset(v17, Theme.SettingsButtonSize),
			ZIndex = 45
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			LogSettings = settingsButton({
				Label = "L",
				LayoutOrder = 1,
				ButtonRef = ref2,
				Open = state6,
				Disabled = selectedLog == nil,
				HoveredChanged = setState12,
				Angle = angle2,
				OnActivated = function()
					setState5(false)
					setState6(not state6)
				end
			}),
			GlobalSettings = settingsButton({
				Label = "G",
				LayoutOrder = 2,
				ButtonRef = ref,
				Open = state5,
				HoveredChanged = setState11,
				Angle = angle,
				OnActivated = function()
					setState6(false)
					setState5(not state5)
				end
			})
		})
	end

	children.SettingsButtons = settingsButtons
	children.GlobalSettingsTooltip = createElement(Controls.TooltipPopout, {
		Open = showSettings and state11 and not (state5 or state3 or headerless or v12),
		AnchorRef = ref,
		Text = "IrisLog Global settings. Personal settings persist for 7 days.",
		WidthPx = Theme.SettingsTooltipWidth,
		HeightPx = Theme.SettingsTooltipHeight,
		OffsetY = 4,
		HorizontalAlign = "right",
		ZIndex = 190
	})
	children.LogSettingsTooltip = createElement(Controls.TooltipPopout, {
		Open = showSettings and state12 and not (state6 or state3 or headerless or v12),
		AnchorRef = ref2,
		Text = "IrisLog Log settings. Applies to the specific chosen log and overrides any global settings, if applicable.",
		WidthPx = Theme.SettingsTooltipWidth,
		HeightPx = Theme.SettingsTooltipHeight,
		OffsetY = 4,
		HorizontalAlign = "right",
		ZIndex = 190
	})
	local v25 = {
		Open = showSettings and state5 and not state3 and not (headerless or v12),
		AnchorRef = ref,
		WidthPx = Theme.SettingsPopoutWidth,
		HeightPx = Theme.SettingsPopoutRowHeight * 7 + (state8 == "import" and 160 or state8 == "export" and 124 or 0),
		OffsetY = 5,
		HorizontalAlign = "right",
		OnOutsideInput = function()
			setState5(false)
		end,
		ZIndex = 180
	}
	local v28 = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 181
	}
	local children2 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Fit = 0,
		Wrap = 0,
		IgnoreToasts = 0,
		ShowHidden = 0,
		MinimalTables = 0,
		Import = 0,
		Export = 0,
		Transfer = 0
	}
	local selected2 = props.TextOverflowMode == "fit"
	local v30 = "fit"
	children2.Fit = createElement(Controls.CheckRow, {
		Label = "Resize to fit",
		Selected = selected2,
		LayoutOrder = 1,
		Disabled = nil,
		OnActivated = function()
			props.OnTextOverflowModeChanged(selected2 and "clip" or v30)
		end
	})
	local selected3 = props.TextOverflowMode == "wrap"
	local v32 = "wrap"
	children2.Wrap = createElement(Controls.CheckRow, {
		Label = "Word wrap",
		Selected = selected3,
		LayoutOrder = 2,
		Disabled = nil,
		OnActivated = function()
			props.OnTextOverflowModeChanged(selected3 and "clip" or v32)
		end
	})
	local ignoreToastAlerts = props.IgnoreToastAlerts
	local onIgnoreToastAlertsChanged = props.OnIgnoreToastAlertsChanged
	children2.IgnoreToasts = createElement(Controls.CheckRow, {
		Label = "Ignore toast alerts",
		Selected = ignoreToastAlerts,
		LayoutOrder = 3,
		Disabled = nil,
		OnActivated = function()
			onIgnoreToastAlertsChanged(not ignoreToastAlerts)
		end
	})
	local showHiddenLogs = props.ShowHiddenLogs
	local onShowHiddenLogsChanged = props.OnShowHiddenLogsChanged
	children2.ShowHidden = createElement(Controls.CheckRow, {
		Label = "Show hidden logs",
		Selected = showHiddenLogs,
		LayoutOrder = 4,
		Disabled = nil,
		OnActivated = function()
			onShowHiddenLogsChanged(not showHiddenLogs)
		end
	})
	local minimalTables = props.MinimalTables
	local onMinimalTablesChanged = props.OnMinimalTablesChanged
	children2.MinimalTables = createElement(Controls.CheckRow, {
		Label = "Minimal tables",
		Selected = minimalTables,
		LayoutOrder = 5,
		Disabled = nil,
		OnActivated = function()
			onMinimalTablesChanged(not minimalTables)
		end
	})
	local selected4 = state8 == "import"
	children2.Import = createElement(Controls.CheckRow, {
		Label = "Import settings",
		Selected = selected4,
		LayoutOrder = 6,
		Disabled = nil,
		OnActivated = beginSettingsImport
	})
	local selected5 = state8 == "export"
	children2.Export = createElement(Controls.CheckRow, {
		Label = "Export settings",
		Selected = selected5,
		LayoutOrder = 7,
		Disabled = nil,
		OnActivated = beginSettingsExport
	})
	children2.Transfer = settingsTransferPanel()
	children.SettingsPopout = createElement(Popout, v25, {
		Options = createElement("Frame", v28, children2)
	})
	local v37 = {
		Open = showSettings and state6 and not (state3 or headerless) and not v12 and selectedLog ~= nil,
		AnchorRef = ref2,
		WidthPx = Theme.LogSettingsPopoutWidth,
		HeightPx = Theme.SettingsPopoutRowHeight * 3,
		OffsetY = 5,
		HorizontalAlign = "right",
		OnOutsideInput = function()
			setState6(false)
		end,
		ZIndex = 180
	}
	local v41 = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 181
	}
	local v42 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Pinned = 0,
		NameColor = 0,
		FloatingKey = 0
	}
	local selected6

	if selectedLog == nil then
		selected6 = false
	else
		selected6 = selectedLog.Pinned == true
	end

	local function fn2(p)
		if selectedLog then
			props.OnTogglePin(selectedLog, p)
		end
	end

	local disabled2 = selectedLog == nil
	v42.Pinned = createElement(Controls.CheckRow, {
		Label = "Pinned",
		Selected = selected6,
		LayoutOrder = 1,
		Disabled = disabled2,
		OnActivated = function()
			fn2(not selected6)
		end
	})
	v42.NameColor = logColorSettingRow(2)
	v42.FloatingKey = keyCodeSettingRow(3)
	children.LogSettingsPopout = createElement(Popout, v37, {
		Options = createElement("Frame", v41, v42)
	})
	children.LogColorPickerPopout = createElement(Popout, {
		Open = showSettings and state7 and state6 and not (state3 or headerless) and not v12 and selectedLog ~= nil,
		AnchorRef = ref3,
		WidthPx = 130,
		HeightPx = heightPx,
		OffsetY = 5,
		HorizontalAlign = "right",
		OnOutsideInput = function()
			setState7(false)
		end,
		ZIndex = 200
	}, {
		Grid = createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 201
		}, (colorGridChildren()))
	})
	local floatingCollapsedButton

	if v12 then
		floatingCollapsedButton = createElement(FloatingCollapseButton, {
			Collapsed = true,
			OnActivated = function()
				if headerless then
					if onFloatingMinimizedChanged then
						onFloatingMinimizedChanged(false)
					end
				else
					setMainMinimized(false) -- equivalent call inferred; original call site unknown
				end
			end,
			ZIndex = 50
		})
	end

	children.FloatingCollapsedButton = floatingCollapsedButton
	local content

	if not (v13 or v12) then
		local position

		if headerless then
			position = UDim2.fromOffset(0, 0)
		else
			position = UDim2.fromOffset(0, Theme.HeaderHeight)
		end

		local size

		if headerless then
			size = UDim2.fromScale(1, 1)
		else
			size = UDim2.new(1, 0, 1, -Theme.HeaderHeight)
		end

		local v52

		if headerless then
			v52 = {
				WindowDragProvider = createElement(WindowDragContext.Provider, {
					value = beginDrag
				}, props.children)
			}
		else
			v52 = props.children
		end

		content = createElement("Frame", {
			BackgroundTransparency = 1,
			Position = position,
			Size = size
		}, v52)
	end

	children.Content = content
	local resize

	if not (v13 or v12) then
		resize = createElement(ResizeGrip, {
			SizePx = 28,
			ZIndex = 40,
			OnInputBegan = beginResize
		})
	end

	children.Resize = resize
	return createElement("Frame", v20, children)
end