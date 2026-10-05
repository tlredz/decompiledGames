local UserInputService = game:GetService("UserInputService")
local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local State = require(parent.State)
local Enums = require(parent.Enums)
local hooks = parent.Hooks
local useKeybinds = require(hooks.useKeybinds)
local components = parent.Components
local EquipWheelOverlay = require(components.EquipWheelOverlay)

local function EquipWheelController(p)
	local v = React.useContext(State.Context)
	local equipWheelOpen = v.EquipWheelOpen
	local features = v.Features
	local setEquipWheelOpen = v.SetEquipWheelOpen
	local v2 = useKeybinds()
	local windowState = v.WindowState
	local setWindowState = v.SetWindowState
	local ref = React.useRef(Enums.WindowState.Full)

	local function toggleEquipWheel()
		if UserInputService:GetFocusedTextBox() then
			return
		end

		setEquipWheelOpen(not equipWheelOpen)
	end

	local function togglePlayer()
		if UserInputService:GetFocusedTextBox() or equipWheelOpen then
			return
		end

		if windowState == Enums.WindowState.Hidden then
			setWindowState(Enums.WindowState.Full)
		else
			setWindowState(Enums.WindowState.Hidden)
		end
	end

	local function toggleMinimize()
		if UserInputService:GetFocusedTextBox() or equipWheelOpen then
			return
		end

		if windowState == Enums.WindowState.Minimized then
			local current = ref.current

			if current == Enums.WindowState.Hidden or current == Enums.WindowState.Minimized then
				current = Enums.WindowState.Full
			end

			setWindowState(current)
		else
			if windowState ~= Enums.WindowState.Hidden then
				ref.current = windowState
			end

			setWindowState(Enums.WindowState.Minimized)
		end
	end

	return React.createElement(React.Fragment, nil, {
		Overlay = React.createElement(EquipWheelOverlay, {
			Root = p.Root,
			Visible = equipWheelOpen,
			OnClose = function()
				setEquipWheelOpen(false)
			end,
			OnEditSlot = function(p2: number)
				setEquipWheelOpen(false)
				v.SetEquipTargetSlot(p2)
				v.SetEquipReturnToWheel(true)
				v.SetWindowTab(Enums.WindowTab.Customize)
				v.SetCustomizeTab("EQUIP")
				v.SetWindowState(Enums.WindowState.Full)
			end
		}),
		InputContext = React.createElement("InputContext", {
			Enabled = features.EmoteWheel,
			Sink = false,
			Priority = 100
		}, {
			EquipWheel = React.createElement("InputAction", {
				Type = Enum.InputActionType.Bool,
				[React.Event.Pressed] = toggleEquipWheel
			}, {
				Keyboard = React.createElement("InputBinding", {
					KeyCode = v2.EquipWheel
				})
			}),
			TogglePlayer = React.createElement("InputAction", {
				Type = Enum.InputActionType.Bool,
				[React.Event.Pressed] = togglePlayer
			}, {
				Keyboard = React.createElement("InputBinding", {
					KeyCode = v2.TogglePlayer
				})
			}),
			Minimize = React.createElement("InputAction", {
				Type = Enum.InputActionType.Bool,
				[React.Event.Pressed] = toggleMinimize
			}, {
				Keyboard = React.createElement("InputBinding", {
					KeyCode = v2.Minimize
				})
			})
		})
	})
end

return EquipWheelController