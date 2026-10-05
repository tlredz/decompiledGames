local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local parent = script.Parent
local parent2 = parent.Parent
local Widgets = require(parent2.Widgets)
local State = require(parent2.State)
local Enums = require(parent2.Enums)
local Util = require(parent2.Util)
local shared = parent2.Parent.Shared
local React = require(shared.React)
local Backend = require(shared.Backend)
local HeaderBar = require(parent.HeaderBar)
local MiniPlayer = require(parent.MiniPlayer)
local Spectrogram = require(parent.Spectrogram)
local CustomNodes = require(parent.CustomNodes)
local NavigationBar = require(parent.NavigationBar)
local CalibrateTreeGraph = require(parent.Dev.CalibrateTreeGraph)
local hooks = parent2.Hooks
local useChild = require(hooks.useChild)
local useScaler = require(hooks.useScaler)
local useSpring = require(hooks.useSpring)
local useTagged = require(hooks.useTagged)
local useAttribute = require(hooks.useAttribute)
local useFormFactor = require(hooks.useFormFactor)
local useStyleSheet = require(hooks.useStyleSheet)
local v = {
	[Enums.WindowState.Full] = 400,
	[Enums.WindowState.Compact] = 400,
	[Enums.WindowState.Minimized] = 60
}

local function MainWindow(props)
	local v2 = useStyleSheet("Window")
	local v3 = useStyleSheet("Tweaks")
	local v4 = React.useContext(State.Context)
	local v5 = useFormFactor()
	local v6 = useTagged("RelicsDesign")[1]
	local v7 = useChild(v6, "StyleSheetOverride")
	local v8 = useChild(v6, "MainWindow")
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local state, setState = React.useState(nil)
	local windowState = v4.WindowState
	local state2, setState2 = React.useState(nil)

	if state ~= v4.WindowTab then
		local name = Enums.GetName(Enums.WindowTab, v4.WindowTab)
		local widget2 = name and Widgets[name]

		if widget2 then
			v4.SetWidget({
				Widget = widget2
			})
		end

		setState(v4.WindowTab)
	end

	local v9 = useAttribute(ReplicatedStorage, "__RELICSxyz_Dev_Design_Snap", function(value)
		if type(value) == "string" then
			return value
		end

		return nil
	end)
	local v10 = useTagged("StyleSheetOption")
	React.useEffect(function()
		if v9 then
			for _, v11 in v10 do
				if v11.Name == v9 then
					v11:AddTag("RelicsDesign")
				else
					v11:RemoveTag("RelicsDesign")
				end
			end
		end
	end, { v9, v10 })
	React.useEffect(function()
		setState2(ref2.current)
	end)
	local v11 = 100
	local v12 = v[windowState] or 0
	local v13 = windowState == Enums.WindowState.Full and v3("Tweak-UseTallWindow", false) and 470 or v12

	if v3("Window-UseCoreHeight", false) and v3("Window-CoreHeight", nil) then
		v13 = v3("Window-CoreHeight", 0)
	end

	if not v3("Tweak-ShowCollapseButton", true) then
		v11 = v13
	end

	local v14, v15 = useSpring(v11 or 0)
	local v16 = useScaler(state2, v3("Window-CoreWidth", nil))

	if v13 then
		v15:spring(v13 or 0)
	end

	if windowState == Enums.WindowState.Hidden then
		return nil
	end

	local v17 = windowState == Enums.WindowState.Minimized
	local features = v4.Features
	local widget = v4.Widget
	local extraComponents = widget and widget.ExtraComponents
	local v18, widget3

	if widget and widget.Widget then
		v18 = widget.HideBackground and true or false
		widget3 = React.createElement(widget.Widget, {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.one / 2
		})
	else
		v18 = false
	end

	local createElement = React.createElement
	local v21 = {
		[React.Tag] = "RelicsWindowContainer",
		ref = ref2
	}
	local uDim

	if v3("Window-UseCustomSize", false) then
		uDim = v3("Window-CustomSize", UDim2.new(1, 0, 1, 0))
	elseif v3("Tweak-AnimateOpen", true) then
		uDim = v14:map(function(p: number)
			return UDim2.fromOffset(v3("Window-CoreWidth", 0), p)
		end)
	else
		uDim = UDim2.fromOffset(v3("Window-CoreWidth", 0), v13)
	end

	v21.Size = uDim
	v21.Position = props.Position
	v21.AnchorPoint = props.AnchorPoint
	local children = {
		StyleLink = React.createElement("StyleLink", {
			StyleSheet = v7 or v8,
			ref = ref
		}),
		Calibrator = 0,
		DragDetector = 0,
		Scale = 0,
		CustomNodes = 0,
		App = 0,
		InputContext = 0
	}
	local calibrator

	if props.IsCalibrating then
		calibrator = React.createElement(CalibrateTreeGraph, {
			Root = ref2
		})
	end

	children.Calibrator = calibrator
	local dragDetector

	if v3("Tweak-Draggable", false) then
		dragDetector = React.createElement("UIDragDetector", {})
	end

	children.DragDetector = dragDetector
	local createElement2 = React.createElement
	local scale

	if v3("Window-IsEmbedded", false) then
		scale = v16 * (props.Scale or 1)
	else
		scale = (props.Scale or v2("Window-Scale", 1) or 1) * (v5 ~= "Phone" and 1 or v2("Window-MobileScale", 1) or 1) or 1
	end

	children.Scale = createElement2("UIScale", {
		Scale = scale
	})
	children.CustomNodes = React.createElement(CustomNodes, {
		StyleLink = ref
	})
	local createElement3 = React.createElement
	local v28 = {
		[React.Tag] = "WindowContentContainer"
	}
	local createElement4 = React.createElement
	local v31 = {
		[React.Tag] = "WindowCoreContainer"
	}
	local children2 = {
		List = React.createElement("UIListLayout", {
			[React.Tag] = "UIListLayout"
		}),
		Header = React.createElement(HeaderBar, {
			[React.Tag] = Util.ClassNames("ofWindow", v17 and "isMin" or nil)
		}),
		NoList = 0,
		Body = 0,
		MiniPlayer = 0,
		NavBar = 0
	}
	local createElement7 = React.createElement
	local v37 = {
		AlwaysHeader = React.createElement("Frame", {
			[React.Tag] = Util.ClassNames("Design", "AlwaysHeaderBarBackground", v17 and "isMin" or nil)
		}),
		Background = 0,
		Spectrogram = 0
	}
	local background = not v18

	if background then
		background = React.createElement("Frame", {
			[React.Tag] = "Design MainWindowBackground"
		})
	end

	v37.Background = background
	local spectrogram = features.Spectrogram

	if spectrogram then
		if v17 then
			spectrogram = React.createElement(Spectrogram, {
				[React.Tag] = "Design Spectrogram ofMinimizedWindow"
			}, {})
		else
			spectrogram = v17
		end
	end

	v37.Spectrogram = spectrogram
	children2.NoList = createElement7("Folder", {}, v37, extraComponents)
	local body = not v17

	if body then
		body = React.createElement("Frame", {
			[React.Tag] = "WindowBodyContainer"
		}, {
			Widget = widget3
		})
	end

	children2.Body = body
	children2.MiniPlayer = not v17 and React.createElement(MiniPlayer)
	children2.NavBar = not v17 and React.createElement(NavigationBar, {
		OnActivated = function(_, p)
			if v4.WindowTab == p then
				v4.ReturnEvent:Fire()
			else
				v4.SetWindowTab(p)
			end
		end
	})
	children.App = createElement3("Frame", v28, {
		Core = createElement4("Frame", v31, children2)
	})
	children.InputContext = React.createElement("InputContext", {
		Sink = false,
		Enabled = true,
		Priority = 2147483647
	}, {
		DevTools = React.createElement("InputAction", {
			Type = Enum.InputActionType.Bool,
			[React.Event.Pressed] = function()
				if Backend.IsRelicsDev(Players.LocalPlayer) then
					local widget2 = v4.Widget
					v4.SetWidget({
						Widget = Widgets.DevTools,
						ReturnText = "Developer Tools",
						ReturnFunc = function()
							v4.SetWidget(widget2)
						end
					})
				end
			end
		}, {
			F1 = React.createElement("InputBinding", {
				KeyCode = Enum.KeyCode.F1
			}),
			F2 = React.createElement("InputBinding", {
				KeyCode = Enum.KeyCode.F2
			})
		})
	})
	return createElement("Frame", v21, children)
end

return MainWindow