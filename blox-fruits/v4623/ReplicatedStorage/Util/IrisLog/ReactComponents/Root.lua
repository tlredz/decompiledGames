local React = require(game.ReplicatedStorage.Packages.React)
local UserInputService = game:GetService("UserInputService")
require(script.Parent.Formatter)
local LogContent = require(script.Parent.LogContent)
local LogWindow = require(script.Parent.LogWindow)
local ToastStack = require(script.Parent.ToastStack)
local createElement = React.createElement
local vector = Vector2.new(360, 220)

local function Root(props)
	local state, setState = React.useState(UserInputService:IsKeyDown(Enum.KeyCode.P))
	local toasts = props.Toasts or {}
	local floatingWindows = props.FloatingWindows or {}
	local popupWindows = props.PopupWindows or {}
	local v = #toasts > 0
	local v2 = #floatingWindows > 0
	local v3 = #popupWindows > 0
	local selectedLog = props.SelectedLog
	React.useEffect(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePState()
			setState(UserInputService:IsKeyDown(Enum.KeyCode.P))
		end

		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.P then
				updatePState() -- equivalent call inferred; original call site unknown
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.P then
				updatePState() -- equivalent call inferred; original call site unknown
			end
		end)
		return function()
			inputBeganConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, {})

	if not (props.Visible or v or v2 or v3) then
		return nil
	end

	local children = {}

	if props.Visible then
		children.Window = createElement(LogWindow, {
			Title = "Debug Panel",
			PositionPx = props.WindowPositionPx,
			SizePx = props.WindowSizePx,
			ResetToken = props.WindowResetToken,
			OnClose = props.OnClose,
			OnWindowChanged = props.OnWindowChanged,
			SelectedLog = selectedLog,
			OnTogglePin = props.OnTogglePin,
			FloatingHotkeyNames = props.FloatingHotkeyNames,
			OnFloatingHotkeyChanged = props.OnFloatingHotkeyChanged,
			TextOverflowMode = props.TextOverflowMode,
			OnTextOverflowModeChanged = props.OnTextOverflowModeChanged,
			MinimalTables = props.MinimalTables,
			OnMinimalTablesChanged = props.OnMinimalTablesChanged,
			IgnoreToastAlerts = props.IgnoreToastAlerts,
			OnIgnoreToastAlertsChanged = props.OnIgnoreToastAlertsChanged,
			ShowHiddenLogs = props.ShowHiddenLogs,
			OnShowHiddenLogsChanged = props.OnShowHiddenLogsChanged,
			OnExportSettings = props.OnExportSettings,
			OnImportSettings = props.OnImportSettings,
			OnLogNameColorChanged = props.OnLogNameColorChanged
		}, {
			Content = createElement(LogContent, {
				Log = selectedLog,
				Logs = props.Logs,
				LogVersion = props.LogVersion,
				SelectedTabIndex = props.SelectedTabIndex,
				LineRenderLimit = props.LineRenderLimit,
				LockedDown = props.LockedDown,
				RenderVersion = props.RenderVersion,
				Context = props.Context,
				TextOverflowMode = props.TextOverflowMode,
				MinimalTables = props.MinimalTables,
				ShowToolbar = true,
				ShowThreads = state,
				OnSelectLog = props.OnSelectLog,
				OnClear = props.OnClear,
				OnResetWindow = props.OnResetWindow,
				OnSelectTab = props.OnSelectTab,
				OnReorderTabs = selectedLog and function(p: number, p2: number)
					props.OnReorderTabs(selectedLog, p, p2)
				end or nil,
				OnLockedDownChanged = props.OnLockedDownChanged
			})
		})
	end

	for k, floatingWindow in floatingWindows do
		local log = floatingWindow.Log
		local v5 = log
		local v6 = log
		local v7 = log
		local v8 = log
		local v9 = log
		children[`Floating{k}`] = createElement(LogWindow, {
			Title = tostring(log.Name),
			Headerless = true,
			FloatingMinimized = floatingWindow.Minimized == true,
			MinSizePx = vector,
			PositionPx = floatingWindow.PositionPx,
			SizePx = floatingWindow.SizePx,
			ResetToken = floatingWindow.ResetToken or 0,
			OnWindowChanged = function(point: Vector2, point2: Vector2)
				props.OnFloatingWindowChanged(log, point, point2)
			end,
			OnFloatingMinimizedChanged = function(flag: boolean)
				props.OnFloatingMinimizedChanged(v5, flag)
			end,
			SelectedLog = log,
			OnTogglePin = props.OnTogglePin,
			FloatingHotkeyNames = nil,
			OnFloatingHotkeyChanged = nil,
			TextOverflowMode = props.TextOverflowMode,
			OnTextOverflowModeChanged = props.OnTextOverflowModeChanged,
			MinimalTables = props.MinimalTables,
			OnMinimalTablesChanged = props.OnMinimalTablesChanged,
			IgnoreToastAlerts = props.IgnoreToastAlerts,
			OnIgnoreToastAlertsChanged = props.OnIgnoreToastAlertsChanged,
			ShowHiddenLogs = props.ShowHiddenLogs,
			OnShowHiddenLogsChanged = props.OnShowHiddenLogsChanged,
			OnExportSettings = nil,
			OnImportSettings = nil,
			OnLogNameColorChanged = props.OnLogNameColorChanged
		}, {
			Content = createElement(LogContent, {
				Log = log,
				SelectedTabIndex = floatingWindow.SelectedTabIndex,
				LineRenderLimit = props.LineRenderLimit,
				LockedDown = floatingWindow.LockedDown,
				RenderVersion = props.RenderVersion,
				Context = props.Context,
				TextOverflowMode = props.TextOverflowMode,
				MinimalTables = props.MinimalTables,
				ShowToolbar = false,
				ShowThreads = state,
				FloatingMinimized = floatingWindow.Minimized == true,
				OnSelectTab = function(p: number)
					props.OnFloatingSelectTab(v6, p)
				end,
				OnReorderTabs = function(p: number, p2: number)
					props.OnReorderTabs(v7, p, p2)
				end,
				OnFloatingMinimizedChanged = function(flag: boolean)
					props.OnFloatingMinimizedChanged(v8, flag)
				end,
				OnLockedDownChanged = function(flag: boolean)
					props.OnFloatingLockedDownChanged(v9, flag)
				end
			})
		})
	end

	for k, popupWindow in popupWindows do
		local log = popupWindow.Log
		local v5 = log
		local v6 = log
		local v7 = log
		local v8 = log
		children[`Popup{k}`] = createElement(LogWindow, {
			Title = popupWindow.Title,
			Headerless = false,
			ShowSettings = false,
			MinSizePx = vector,
			PositionPx = popupWindow.PositionPx,
			SizePx = popupWindow.SizePx,
			ResetToken = popupWindow.ResetToken or 0,
			OnClose = function()
				props.OnPopupClose(log)
			end,
			OnWindowChanged = function(point: Vector2, point2: Vector2)
				props.OnPopupWindowChanged(v5, point, point2)
			end,
			SelectedLog = log,
			OnTogglePin = props.OnTogglePin,
			FloatingHotkeyNames = nil,
			OnFloatingHotkeyChanged = nil,
			TextOverflowMode = props.TextOverflowMode,
			OnTextOverflowModeChanged = props.OnTextOverflowModeChanged,
			MinimalTables = props.MinimalTables,
			OnMinimalTablesChanged = props.OnMinimalTablesChanged,
			IgnoreToastAlerts = props.IgnoreToastAlerts,
			OnIgnoreToastAlertsChanged = props.OnIgnoreToastAlertsChanged,
			ShowHiddenLogs = props.ShowHiddenLogs,
			OnShowHiddenLogsChanged = props.OnShowHiddenLogsChanged,
			OnExportSettings = nil,
			OnImportSettings = nil,
			OnLogNameColorChanged = props.OnLogNameColorChanged
		}, {
			Content = createElement(LogContent, {
				Log = log,
				SelectedTabIndex = popupWindow.SelectedTabIndex,
				LineRenderLimit = props.LineRenderLimit,
				LockedDown = popupWindow.LockedDown,
				RenderVersion = props.RenderVersion,
				Context = props.Context,
				TextOverflowMode = props.TextOverflowMode,
				MinimalTables = props.MinimalTables,
				ShowToolbar = false,
				ShowThreads = state,
				OnSelectTab = function(p: number)
					props.OnPopupSelectTab(v6, p)
				end,
				OnReorderTabs = function(p: number, p2: number)
					props.OnReorderTabs(v7, p, p2)
				end,
				OnLockedDownChanged = function(flag: boolean)
					props.OnPopupLockedDownChanged(v8, flag)
				end
			})
		})
	end

	if v then
		children.Toasts = createElement(ToastStack, {
			Context = props.Context,
			Toasts = toasts,
			ToastVersion = props.ToastVersion,
			OnActivated = props.OnToastActivated,
			OnDismissed = props.OnToastDismissed
		})
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, children)
end

return React.memo(Root)