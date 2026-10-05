require(script.Parent.Types)
return function(state)
	local state2 = state.State(true)
	local state3 = state.State(false)
	local state4 = state.State(false)
	local state5 = state.State(false)
	local state6 = state.State(false)
	local state7 = state.State(false)

	local function helpMarker(p)
		state.PushConfig({
			TextColor = state._config.TextDisabledColor
		})
		local text = state.Text({ "(?)" })
		state.PopConfig()
		state.PushConfig({
			ContentWidth = UDim.new(0, 350)
		})

		if text.hovered() then
			state.Tooltip({ p })
		end

		state.PopConfig()
	end

	local v = {
		Basic = function()
			state.Tree({ "Basic" })
			state.SeparatorText({ "Basic" })
			local state8 = state.State(1)
			state.Button({ "Button" })
			state.SmallButton({ "SmallButton" })
			state.Text({ "Text" })
			state.TextWrapped({ string.rep("Text Wrapped ", 5) })
			state.TextColored({ "Colored Text", Color3.fromRGB(255, 128, 0) })
			state.Text({
				"Rich Text: <b>bold text</b> <i>italic text</i> <u>underline text</u> <s>strikethrough text</s> <font color= \"rgb(240, 40, 10)\">red text</font> <font size=\"32\">bigger text</font>",
				true,
				nil,
				true
			})
			state.SameLine()
			state.RadioButton({ "Index '1'", 1 }, {
				index = state8
			})
			state.RadioButton({ "Index 'two'", "two" }, {
				index = state8
			})

			if state.RadioButton({ "Index 'false'", false }, {
				index = state8
			}).active() == false and state.SmallButton({ "Select last" }).clicked() then
				state8:set(false)
			end

			state.End()
			state.Text({ "The Index is: " .. tostring(state8.value) })
			state.SeparatorText({ "Inputs" })
			state.InputNum({})
			state.DragNum({})
			state.SliderNum({})
			state.End()
		end,
		Tree = function()
			state.Tree({ "Trees" })
			state.Tree({
				"Tree using SpanAvailWidth",
				[state.Args.Tree.SpanAvailWidth] = true
			})
			helpMarker("SpanAvailWidth determines if the Tree is selectable from its entire with, or only the text area")
			state.End()
			local tree2 = state.Tree({ "Tree with Children" })
			state.Text({ "Im inside the first tree!" })
			state.Button({ "Im a button inside the first tree!" })
			state.Tree({ "Im a tree inside the first tree!" })
			state.Text({ "I am the innermost text!" })
			state.End()
			state.End()
			state.Checkbox({ "Toggle above tree" }, {
				isChecked = tree2.state.isUncollapsed
			})
			state.End()
		end,
		CollapsingHeader = function()
			state.Tree({ "Collapsing Headers" })
			state.CollapsingHeader({ "A header" })
			state.Text({ "This is under the first header!" })
			state.End()
			local state8 = state.State(true)
			state.CollapsingHeader({ "Another header" }, {
				isUncollapsed = state8
			})

			if state.Button({ "Shhh... secret button!" }).clicked() then
				state8:set(true)
			end

			state.End()
			state.End()
		end,
		Group = function()
			state.Tree({ "Groups" })
			state.SameLine()
			state.Group()
			state.Text({ "I am in group A" })
			state.Button({ "Im also in A" })
			state.End()
			state.Separator()
			state.Group()
			state.Text({ "I am in group B" })
			state.Button({ "Im also in B" })
			state.Button({ "Also group B" })
			state.End()
			state.End()
			state.End()
		end,
		Indent = function()
			state.Tree({ "Indents" })
			state.Text({ "Not Indented" })
			state.Indent()
			state.Text({ "Indented" })
			state.Indent({ 7 })
			state.Text({ "Indented by 7 more pixels" })
			state.End()
			state.Indent({ -7 })
			state.Text({ "Indented by 7 less pixels" })
			state.End()
			state.End()
			state.End()
		end,
		Input = function()
			state.Tree({ "Input" })
			local state8 = state.State(false)
			local state9 = state.State(false)
			local state10 = state.State(0)
			local state11 = state.State(100)
			local state12 = state.State(1)
			local state13 = state.State("%d")
			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			local v3 = state.InputNum({
				"Input Number",
				[state.Args.InputNum.NoButtons] = state9.value,
				[state.Args.InputNum.Min] = state10.value,
				[state.Args.InputNum.Max] = state11.value,
				[state.Args.InputNum.Increment] = state12.value,
				[state.Args.InputNum.Format] = { state13.value }
			})
			state.PopConfig()
			state.Text({ "The Value is: " .. v3.number.value })

			if state.Button({ "Randomize Number" }).clicked() then
				v3.number:set(math.random(1, 99))
			end

			local checkbox = state.Checkbox({ "NoField" }, {
				isChecked = state8
			})
			local checkbox2 = state.Checkbox({ "NoButtons" }, {
				isChecked = state9
			})

			if checkbox.checked() and checkbox2.isChecked.value == true then
				checkbox2.isChecked:set(false)
			end

			if checkbox2.checked() and checkbox.isChecked.value == true then
				checkbox.isChecked:set(false)
			end

			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			state.InputVector2({ "InputVector2" })
			state.InputVector3({ "InputVector3" })
			state.InputUDim({ "InputUDim" })
			state.InputUDim2({ "InputUDim2" })
			local state14 = state.State(false)
			local state15 = state.State(false)
			local state16 = state.State(Color3.new())
			local state17 = state.State(0)
			state.SliderNum({
				"Transparency",
				0.01,
				0,
				1
			}, {
				number = state17
			})
			state.InputColor3({ "InputColor3", state14:get(), state15:get() }, {
				color = state16
			})
			state.InputColor4({ "InputColor4", state14:get(), state15:get() }, {
				color = state16,
				transparency = state17
			})
			state.SameLine()
			state.Text({ state16:get():ToHex() })
			state.Checkbox({ "Use Floats" }, {
				isChecked = state14
			})
			state.Checkbox({ "Use HSV" }, {
				isChecked = state15
			})
			state.End()
			state.PopConfig()
			state.Separator()
			state.SameLine()
			state.Text({ "Slider Numbers" })
			helpMarker("ctrl + click slider number widgets to input a number")
			state.End()
			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			state.SliderNum({
				"Slide Int",
				1,
				1,
				8
			})
			state.SliderNum({
				"Slide Float",
				0.01,
				0,
				100
			})
			state.SliderNum({
				"Small Numbers",
				0.001,
				-2,
				1,
				"%f radians"
			})
			state.SliderNum({
				"Odd Ranges",
				0.001,
				-3.141592653589793,
				3.141592653589793,
				"%f radians"
			})
			state.SliderNum({
				"Big Numbers",
				10000,
				100000,
				10000000
			})
			state.SliderNum({
				"Few Numbers",
				1,
				0,
				3
			})
			state.PopConfig()
			state.Separator()
			state.SameLine()
			state.Text({ "Drag Numbers" })
			helpMarker("ctrl + click or double click drag number widgets to input a number, hold shift/alt while dragging to increase/decrease speed")
			state.End()
			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			state.DragNum({ "Drag Int" })
			state.DragNum({
				"Slide Float",
				0.001,
				-10,
				10
			})
			state.DragNum({
				"Percentage",
				1,
				0,
				100,
				"%d %%"
			})
			state.PopConfig()
			state.End()
		end,
		InputText = function()
			state.Tree({ "Input Text" })
			state.PushConfig({
				ContentWidth = UDim.new(0, 250)
			})
			local v3 = state.InputText({
				"Input Text Test",
				[state.Args.InputText.TextHint] = "Input Text here"
			})
			state.PopConfig()
			state.Text({ "The text is: " .. v3.text.value })
			state.End()
		end,
		MultiInput = function()
			state.Tree({ "Multi-Component Input" })
			local state8 = state.State(Vector2.new())
			local state9 = state.State((Vector3.new()))
			local state10 = state.State(UDim.new())
			local state11 = state.State(UDim2.new())
			local state12 = state.State(Color3.new())
			local state13 = state.State(Rect.new(0, 0))
			state.SeparatorText({ "Input" })
			state.InputVector2({}, {
				number = state8
			})
			state.InputVector3({}, {
				number = state9
			})
			state.InputUDim({}, {
				number = state10
			})
			state.InputUDim2({}, {
				number = state11
			})
			state.InputRect({}, {
				number = state13
			})
			state.SeparatorText({ "Drag" })
			state.DragVector2({}, {
				number = state8
			})
			state.DragVector3({}, {
				number = state9
			})
			state.DragUDim({}, {
				number = state10
			})
			state.DragUDim2({}, {
				number = state11
			})
			state.DragRect({}, {
				number = state13
			})
			state.SeparatorText({ "Slider" })
			state.SliderVector2({}, {
				number = state8
			})
			state.SliderVector3({}, {
				number = state9
			})
			state.SliderUDim({}, {
				number = state10
			})
			state.SliderUDim2({}, {
				number = state11
			})
			state.SliderRect({}, {
				number = state13
			})
			state.SeparatorText({ "Color" })
			state.InputColor3({}, {
				color = state12
			})
			state.InputColor4({}, {
				color = state12
			})
			state.End()
		end,
		Tooltip = function()
			state.PushConfig({
				ContentWidth = UDim.new(0, 250)
			})
			state.Tree({ "Tooltip" })

			if state.Text({ "Hover over me to reveal a tooltip" }).hovered() then
				state.Tooltip({ "I am some helpful tooltip text" })
			end

			local state8 = state.State("Hello ")
			local state9 = state.State(1)

			if state.InputNum({
				"# of repeat",
				1,
				1,
				50
			}, {
				number = state9
			}).numberChanged() then
				state8:set(string.rep("Hello ", state9:get()))
			end

			if state.Checkbox({ "Show dynamic text tooltip" }).isChecked.value then
				state.Tooltip({ state8:get() })
			end

			state.End()
			state.PopConfig()
		end,
		Selectable = function()
			state.Tree({ "Selectable" })
			local state8 = state.State(2)
			state.Selectable({ "Selectable #1", 1 }, {
				index = state8
			})
			state.Selectable({ "Selectable #2", 2 }, {
				index = state8
			})

			if state.Selectable({ "Double click Selectable", 3, true }, {
				index = state8
			}).doubleClicked() then
				state8:set(3)
			end

			state.Selectable({ "Impossible to select", 4, true }, {
				index = state8
			})

			if state.Button({ "Select last" }).clicked() then
				state8:set(4)
			end

			state.Selectable({ "Independent Selectable" })
			state.End()
		end,
		Combo = function()
			state.Tree({ "Combo" })
			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			local state8 = state.State("No Selection")
			state.SameLine()
			local checkbox = state.Checkbox({ "No Preview" })
			local checkbox2 = state.Checkbox({ "No Button" })

			if checkbox.checked() and checkbox2.isChecked.value == true then
				checkbox2.isChecked:set(false)
			end

			if checkbox2.checked() and checkbox.isChecked.value == true then
				checkbox.isChecked:set(false)
			end

			state.End()
			state.Combo({ "Basic Usage", checkbox2.isChecked:get(), checkbox.isChecked:get() }, {
				index = state8
			})
			state.Selectable({ "Select 1", "One" }, {
				index = state8
			})
			state.Selectable({ "Select 2", "Two" }, {
				index = state8
			})
			state.Selectable({ "Select 3", "Three" }, {
				index = state8
			})
			state.End()
			state.ComboArray({ "Using ComboArray" }, {
				index = "No Selection"
			}, { "Red", "Green", "Blue" })
			local state9 = state.State("7 AM")
			state.Combo({ "Combo with Inner widgets" }, {
				index = state9
			})
			state.Tree({ "Morning Shifts" })
			state.Selectable({ "Shift at 7 AM", "7 AM" }, {
				index = state9
			})
			state.Selectable({ "Shift at 11 AM", "11 AM" }, {
				index = state9
			})
			state.Selectable({ "Shist at 3 PM", "3 PM" }, {
				index = state9
			})
			state.End()
			state.Tree({ "Night Shifts" })
			state.Selectable({ "Shift at 6 PM", "6 PM" }, {
				index = state9
			})
			state.Selectable({ "Shift at 9 PM", "9 PM" }, {
				index = state9
			})
			state.End()
			state.End()
			local comboEnum = state.ComboEnum({ "Using ComboEnum" }, {
				index = Enum.UserInputState.Begin
			}, Enum.UserInputState)
			state.Text({ "Selected: " .. comboEnum.index:get().Name })
			state.PopConfig()
			state.End()
		end
	}
	local v2 = {
		"Basic",
		"Tree",
		"CollapsingHeader",
		"Group",
		"Indent",
		"Input",
		"MultiInput",
		"InputText",
		"Tooltip",
		"Selectable",
		"Combo"
	}
	local recursiveTree

	recursiveTree = function()
		if state.Tree({ "Recursive Tree" }).state.isUncollapsed.value then
			recursiveTree()
		end

		state.End()
	end

	local recursiveWindow

	recursiveWindow = function(isOpened)
		state.Window({ "Recursive Window" }, {
			size = state.State(Vector2.new(175, 100)),
			isOpened = isOpened
		})
		local checkbox = state.Checkbox({ "Recurse Again" })
		state.End()

		if checkbox.isChecked.value then
			recursiveWindow(checkbox.isChecked)
		end
	end

	local function runtimeInfo()
		local window = state.Window({ "Runtime Info" }, {
			isOpened = state4
		})
		local _lastVDOM = state.Internal._lastVDOM
		local _states = state.Internal._states
		local state8 = state.State(3)
		local state9 = state.State(0)
		local state10 = state.State(os.clock())
		state.SameLine()
		state.InputNum({
			"",
			[state.Args.InputNum.Format] = "%d Seconds",
			[state.Args.InputNum.Max] = 10
		}, {
			number = state8
		})

		if state.Button({ "Disable" }).clicked() then
			state.Disabled = true
			task.delay(state8:get(), function()
				state.Disabled = false
			end)
		end

		state.End()
		local now = os.clock()
		local v4 = now - state10.value
		state9.value += (v4 - state9.value) * 0.2
		state10.value = now
		state.Text({ string.format("Average %.3f ms/frame (%.1f FPS)", state9.value * 1000, 1 / state9.value) })
		state.Text({ string.format(
				"Window Position: (%d, %d), Window Size: (%d, %d)",
				window.position.value.X,
				window.position.value.Y,
				window.size.value.X,
				window.size.value.Y
			) })
		state.SameLine()
		state.Text({ "Enter an ID to learn more about it." })
		helpMarker("every widget and state has an ID which Iris tracks to remember which widget is which. below lists all widgets and states, with their respective IDs")
		state.End()
		state.PushConfig({
			ItemWidth = UDim.new(1, -150)
		})
		local value = state.InputText({ "ID field" }, {
			text = state.State(window.ID)
		}).text.value
		state.PopConfig()
		state.Indent()
		local v5 = _lastVDOM[value]
		local _state = _states[value]

		if v5 then
			state.Table({
				1,
				[state.Args.Table.RowBg] = false
			})
			state.Text({ string.format("The ID, \"%s\", is a widget", value) })
			state.NextRow()
			state.Text({ string.format("Widget is type: %s", v5.type) })
			state.NextRow()
			state.Tree({ "Widget has Args:" }, {
				isUncollapsed = state.State(true)
			})

			for k, argument in v5.arguments do
				state.Text({ k .. " - " .. tostring(argument) })
			end

			state.End()
			state.NextRow()

			if v5.state then
				state.Tree({ "Widget has State:" }, {
					isUncollapsed = state.State(true)
				})

				for k, v7 in v5.state do
					state.Text({ k .. " - " .. tostring(v7.value) })
				end

				state.End()
			end

			state.End()
		elseif _state then
			state.Table({
				1,
				[state.Args.Table.RowBg] = false
			})
			state.Text({ string.format("The ID, \"%s\", is a state", value) })
			state.NextRow()
			state.Text({ string.format(
					"Value is type: %s, Value = %s",
					typeof(_state.value),
					(tostring(_state.value))
				) })
			state.NextRow()
			state.Tree({ "state has connected widgets:" }, {
				isUncollapsed = state.State(true)
			})

			for k, connectedWidget in _state.ConnectedWidgets do
				state.Text({ k .. " - " .. connectedWidget.type })
			end

			state.End()
			state.NextRow()
			state.Text({ string.format("state has: %d connected functions", #_state.ConnectedFunctions) })
			state.End()
		else
			state.Text({ string.format("The ID, \"%s\", is not a state or widget", value) })
		end

		state.End()

		if state.Tree({ "Widgets" }).isUncollapsed.value then
			local count = 0
			local v6 = ""

			for _, v7 in _lastVDOM do
				count += 1
				v6 ..= "\n" .. v7.ID .. " - " .. v7.type
			end

			state.Text({ "Number of Widgets: " .. count })
			state.Text({ v6 })
		end

		state.End()

		if state.Tree({ "States" }).isUncollapsed.value then
			local count = 0
			local v6 = ""

			for k, _state2 in _states do
				count += 1
				v6 ..= "\n" .. k .. " - " .. tostring(_state2.value)
			end

			state.Text({ "Number of States: " .. count })
			state.Text({ v6 })
		end

		state.End()
		state.End()
	end

	local recursiveMenu

	recursiveMenu = function()
		if state.Menu({ "Recursive" }).state.isOpened.value then
			state.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl })
			state.MenuItem({ "Open", Enum.KeyCode.O, Enum.ModifierKey.Ctrl })
			state.MenuItem({ "Save", Enum.KeyCode.S, Enum.ModifierKey.Ctrl })
			state.Separator()
			state.MenuToggle({ "Autosave" })
			state.MenuToggle({ "Checked" })
			state.Separator()
			state.Menu({ "Options" })
			state.MenuItem({ "Red" })
			state.MenuItem({ "Yellow" })
			state.MenuItem({ "Green" })
			state.MenuItem({ "Blue" })
			state.Separator()
			recursiveMenu()
			state.End()
		end

		state.End()
	end

	local function mainMenuBar()
		state.MenuBar()
		state.Menu({ "File" })
		state.MenuItem({ "New", Enum.KeyCode.N, Enum.ModifierKey.Ctrl })
		state.MenuItem({ "Open", Enum.KeyCode.O, Enum.ModifierKey.Ctrl })
		state.MenuItem({ "Save", Enum.KeyCode.S, Enum.ModifierKey.Ctrl })
		recursiveMenu()
		state.MenuItem({ "Quit", Enum.KeyCode.Q, Enum.ModifierKey.Alt })
		state.End()
		state.Menu({ "Examples" })
		state.MenuToggle({ "Recursive Window" }, {
			isChecked = state3
		})
		state.MenuToggle({ "Windowless" }, {
			isChecked = state6
		})
		state.MenuToggle({ "Main Menu Bar" }, {
			isChecked = state7
		})
		state.End()
		state.Menu({ "Tools" })
		state.MenuToggle({ "Runtime Info" }, {
			isChecked = state4
		})
		state.MenuToggle({ "Style Editor" }, {
			isChecked = state5
		})
		state.End()
		state.End()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mainMenuBarExample()
		local _ = state.Internal._rootWidget.Instance.PseudoWindowScreenGui.AbsoluteSize
		mainMenuBar()
	end

	local function fn()
		local state8 = state.State(1)
		local v3 = {
			{ "Sizing", function()
					local state9 = state.State({})

					if state.Button({ "Update Config" }).clicked() then
						state.UpdateGlobalConfig(state9:get())
						state9:set({})
					end

					for _, list in {
						{
							"ItemWidth",
							nil,
							UDim.new(),
							UDim.new(1, 200)
						},
						{
							"ContentWidth",
							nil,
							UDim.new(),
							UDim.new(1, 200)
						}
					} do
						local sliderUDim = state.SliderUDim({ table.unpack(list) }, {
							number = state.WeakState(state._config[list[1]])
						})

						if not sliderUDim.numberChanged() then
							continue
						end

						local get = state9:get()
						get[list[1]] = sliderUDim.number:get()
					end

					for _, list in {
						{
							"WindowPadding",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"WindowResizePadding",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"FramePadding",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"ItemSpacing",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"ItemInnerSpacing",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"CellPadding",
							nil,
							Vector2.zero,
							Vector2.one * 20
						},
						{
							"DisplaySafeAreaPadding",
							nil,
							Vector2.zero,
							Vector2.one * 20
						}
					} do
						local sliderVector2 = state.SliderVector2({ table.unpack(list) }, {
							number = state.WeakState(state._config[list[1]])
						})

						if not sliderVector2.numberChanged() then
							continue
						end

						local get_2 = state9:get()
						get_2[list[1]] = sliderVector2.number:get()
					end

					for _, list in {
						{
							"TextSize",
							1,
							4,
							20
						},
						{
							"FrameBorderSize",
							0.1,
							0,
							1
						},
						{
							"FrameRounding",
							1,
							0,
							12
						},
						{
							"GrabRounding",
							1,
							0,
							12
						},
						{
							"WindowBorderSize",
							0.1,
							0,
							1
						},
						{
							"PopupBorderSize",
							0.1,
							0,
							1
						},
						{
							"PopupRounding",
							1,
							0,
							12
						},
						{
							"ScrollbarSize",
							1,
							0,
							20
						},
						{
							"GrabMinSize",
							1,
							0,
							20
						}
					} do
						local sliderNum = state.SliderNum({ table.unpack(list) }, {
							number = state.WeakState(state._config[list[1]])
						})

						if not sliderNum.numberChanged() then
							continue
						end

						local get_3 = state9:get()
						get_3[list[1]] = sliderNum.number:get()
					end

					for _, v4 in { "WindowTitleAlign" } do
						local comboEnum = state.ComboEnum({ v4 }, {
							index = state.WeakState(state._config[v4])
						}, state._config[v4].EnumType)

						if comboEnum.closed() then
							state.UpdateGlobalConfig({
								[v4] = comboEnum.index:get()
							})
						end
					end
				end },
			{ "Colors", function()
					local state9 = state.State({})

					if state.Button({ "Update Config" }).clicked() then
						state.UpdateGlobalConfig(state9:get())
						state9:set({})
					end

					for _, v4 in { "BorderColor", "BorderActiveColor" } do
						local inputColor3 = state.InputColor3({ v4 }, {
							color = state.WeakState(state._config[v4])
						})

						if inputColor3.numberChanged() then
							state.UpdateGlobalConfig({
								[v4] = inputColor3.color:get()
							})
						end
					end

					for _, v4 in {
						"Text",
						"TextDisabled",
						"WindowBg",
						"ScrollbarGrab",
						"TitleBg",
						"TitleBgActive",
						"TitleBgCollapsed",
						"MenubarBg",
						"FrameBg",
						"FrameBgHovered",
						"FrameBgActive",
						"Button",
						"ButtonHovered",
						"ButtonActive",
						"SliderGrab",
						"SliderGrabActive",
						"Header",
						"HeaderHovered",
						"HeaderActive",
						"SelectionImageObject",
						"SelectionImageObjectBorder",
						"TableBorderStrong",
						"TableBorderLight",
						"TableRowBg",
						"TableRowBgAlt",
						"NavWindowingHighlight",
						"NavWindowingDimBg",
						"Separator",
						"CheckMark"
					} do
						local inputColor4 = state.InputColor4({ v4 }, {
							color = state.WeakState(state._config[v4 .. "Color"]),
							transparency = state.WeakState(state._config[v4 .. "Transparency"])
						})

						if not inputColor4.numberChanged() then
							continue
						end

						local get = state9:get()
						get[v4 .. "Color"] = inputColor4.color:get()
						local get_2 = state9:get()
						get_2[v4 .. "Transparency"] = inputColor4.transparency:get()
					end
				end }
		}
		state.Window({ "Style Editor" }, {
			isOpened = state5
		})
		state.Text({ "Customize the look of Iris in realtime." })
		state.SameLine()

		if state.SmallButton({ "Light Theme" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.colorLight)
		end

		if state.SmallButton({ "Dark Theme" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.colorDark)
		end

		state.End()
		state.SameLine()

		if state.SmallButton({ "Classic Size" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.sizeDefault)
		end

		if state.SmallButton({ "Larger Size" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.sizeClear)
		end

		state.End()

		if state.SmallButton({ "Reset Everything" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.colorDark)
			state.UpdateGlobalConfig(state.TemplateConfig.sizeDefault)
		end

		state.Separator()
		state.SameLine()

		for i, v4 in ipairs(v3) do
			state.RadioButton({ v4[1], i }, {
				index = state8
			})
		end

		state.End()
		v3[state8:get()][2]()
		state.End()
	end

	local function widgetEventInteractivity()
		state.CollapsingHeader({ "Widget Event Interactivity" })
		local state8 = state.State(0)

		if state.Button({ "Click to increase Number" }).clicked() then
			state8:set(state8:get() + 1)
		end

		state.Text({ "The Number is: " .. state8:get() })
		state.Separator()
		local state9 = state.State(false)
		local state10 = state.State("clicked")
		state.SameLine()
		state.RadioButton({ "clicked", "clicked" }, {
			index = state10
		})
		state.RadioButton({ "rightClicked", "rightClicked" }, {
			index = state10
		})
		state.RadioButton({ "doubleClicked", "doubleClicked" }, {
			index = state10
		})
		state.RadioButton({ "ctrlClicked", "ctrlClicked" }, {
			index = state10
		})
		state.End()
		state.SameLine()

		if state.Button({ state10:get() .. " to reveal text" })[state10:get()]() then
			state9:set(not state9:get())
		end

		if state9:get() then
			state.Text({ "Here i am!" })
		end

		state.End()
		state.Separator()
		local state11 = state.State(0)
		state.SameLine()

		if state.Button({ "Click to show text for 20 frames" }).clicked() then
			state11:set(20)
		end

		if state11:get() > 0 then
			state.Text({ "Here i am!" })
		end

		state.End()
		state11:set((math.max(0, state11:get() - 1)))
		state.Text({ "Text Timer: " .. state11:get() })
		local checkbox = state.Checkbox({ "Event-tracked checkbox" })
		state.Indent()
		state.Text({ "unchecked: " .. tostring(checkbox.unchecked()) })
		state.Text({ "checked: " .. tostring(checkbox.checked()) })
		state.End()
		state.SameLine()

		if state.Button({ "Hover over me" }).hovered() then
			state.Text({ "The button is hovered" })
		end

		state.End()
		state.End()
	end

	local function widgetStateInteractivity()
		state.CollapsingHeader({ "Widget State Interactivity" })
		local checkbox = state.Checkbox({ "Widget-Generated State" })
		state.Text({ (`isChecked: {checkbox.state.isChecked.value}\n`) })
		local state8 = state.State(false)
		local checkbox2 = state.Checkbox({ "User-Generated State" }, {
			isChecked = state8
		})
		state.Text({ (`isChecked: {checkbox2.state.isChecked.value}\n`) })
		local checkbox3 = state.Checkbox({ "Widget Coupled State" })
		local checkbox4 = state.Checkbox({ "Coupled to above Checkbox" }, {
			isChecked = checkbox3.state.isChecked
		})
		state.Text({ (`isChecked: {checkbox4.state.isChecked.value}\n`) })
		local state9 = state.State(false)
		state.Checkbox({ "Widget and Code Coupled State" }, {
			isChecked = state9
		})

		if state.Button({ "Click to toggle above checkbox" }).clicked() then
			state9:set(not state9:get())
		end

		state.Text({ (`isChecked: {state9.value}\n`) })
		local state10 = state.State(true)
		local computedState = state.ComputedState(state10, function(p)
			return not p
		end)
		state.Checkbox({ "ComputedState (dynamic coupling)" }, {
			isChecked = state10
		})
		state.Checkbox({ "Inverted of above checkbox" }, {
			isChecked = computedState
		})
		state.Text({ (`isChecked: {computedState.value}\n`) })
		state.End()
	end

	local function dynamicStyle()
		state.CollapsingHeader({ "Dynamic Styles" })
		local state8 = state.State(0)
		state.SameLine()

		if state.Button({ "Change Color" }).clicked() then
			state8:set(math.random())
		end

		state.Text({ "Hue: " .. math.floor(state8:get() * 255) })
		helpMarker("Using PushConfig with a changing value, this can be done with any config field")
		state.End()
		state.PushConfig({
			TextColor = Color3.fromHSV(state8:get(), 1, 1)
		})
		state.Text({ "Text with a unique and changable color" })
		state.PopConfig()
		state.End()
	end

	local function tablesDemo()
		local state8 = state.State(false)
		state.CollapsingHeader({ "Tables & Columns" }, {
			isUncollapsed = state8
		})

		if state8.value == false then
			state.End()
			return
		end

		state.SameLine()
		state.Text({ "Table using NextRow and NextColumn syntax:" })
		helpMarker("calling Iris.NextRow() in the outer loop, and Iris.NextColumn()in the inner loop")
		state.End()
		state.Table({ 3 })

		for i = 1, 4 do
			state.NextRow()

			for i2 = 1, 3 do
				state.NextColumn()
				state.Text({ (`Row: {i}, Column: {i2}`) })
			end
		end

		state.End()
		state.Text({ "" })
		state.SameLine()
		state.Text({ "Table using NextColumn only syntax:" })
		helpMarker("only calling Iris.NextColumn() in the inner loop, the result is identical")
		state.End()
		state.Table({ 2 })

		for i = 1, 4 do
			for i2 = 1, 2 do
				state.NextColumn()
				state.Text({ (`Row: {i}, Column: {i2}`) })
			end
		end

		state.End()
		state.Separator()
		local state9 = state.State(false)
		local state10 = state.State(false)
		local state11 = state.State(true)
		local state12 = state.State(true)
		local state13 = state.State(3)
		state.Text({ "Table with Customizable Arguments" })
		state.Table({
			4,
			[state.Args.Table.RowBg] = state9.value,
			[state.Args.Table.BordersOuter] = state10.value,
			[state.Args.Table.BordersInner] = state11.value
		})

		for i = 1, state13:get() do
			for i2 = 1, 4 do
				state.NextColumn()

				if state12.value then
					state.Button({ (`Month: {i}, Week: {i2}`) })
				else
					state.Text({ (`Month: {i}, Week: {i2}`) })
				end
			end
		end

		state.End()
		state.Checkbox({ "RowBg" }, {
			isChecked = state9
		})
		state.Checkbox({ "BordersOuter" }, {
			isChecked = state10
		})
		state.Checkbox({ "BordersInner" }, {
			isChecked = state11
		})
		state.SameLine()
		state.RadioButton({ "Buttons", true }, {
			index = state12
		})
		state.RadioButton({ "Text", false }, {
			index = state12
		})
		state.End()
		state.InputNum({
			"Number of rows",
			[state.Args.InputNum.Min] = 0,
			[state.Args.InputNum.Max] = 100,
			[state.Args.InputNum.Format] = "%d"
		}, {
			number = state13
		})
		state.End()
	end

	local function layoutDemo()
		state.CollapsingHeader({ "Widget Layout" })
		state.Tree({ "Content Width" })
		local state8 = state.State(50)
		local state9 = state.State(Enum.Axis.X)
		state.Text({ "The Content Width is a size property which determines the width of input fields." })
		state.SameLine()
		state.Text({ "By default the value is UDim.new(0.65, 0)" })
		helpMarker("This is the default value from Dear ImGui.\nIt is 65% of the window width.")
		state.End()
		state.Text({ "This works well, but sometimes we know how wide elements are going to be and want to maximise the space." })
		state.Text({ "Therefore, we can use Iris.PushConfig() to change the width" })
		state.Separator()
		state.SameLine()
		state.Text({ "Content Width = 150 pixels" })
		helpMarker("UDim.new(0, 150)")
		state.End()
		state.PushConfig({
			ContentWidth = UDim.new(0, 150)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state8
		})
		state.ComboEnum({ "axis" }, {
			index = state9
		}, Enum.Axis)
		state.PopConfig()
		state.SameLine()
		state.Text({ "Content Width = 50% window width" })
		helpMarker("UDim.new(0.5, 0)")
		state.End()
		state.PushConfig({
			ContentWidth = UDim.new(0.5, 0)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state8
		})
		state.ComboEnum({ "axis" }, {
			index = state9
		}, Enum.Axis)
		state.PopConfig()
		state.SameLine()
		state.Text({ "Content Width = -150 pixels from the right side" })
		helpMarker("UDim.new(1, -150)")
		state.End()
		state.PushConfig({
			ContentWidth = UDim.new(1, -150)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state8
		})
		state.InputEnum({ "axis" }, {
			index = state9
		}, Enum.Axis)
		state.PopConfig()
		state.End()
		state.End()
	end

	local function windowlessDemo()
		state.PushConfig({
			ItemWidth = UDim.new(0, 150)
		})
		state.SameLine()
		state.TextWrapped({ "Windowless widgets" })
		helpMarker("Widgets which are placed outside of a window will appear on the top left side of the screen.")
		state.End()
		state.Button({})
		state.Tree({})
		state.InputText({})
		state.End()
		state.PopConfig()
	end

	return function()
		local state8 = state.State(false)
		local state9 = state.State(false)
		local state10 = state.State(false)
		local state11 = state.State(true)
		local state12 = state.State(false)
		local state13 = state.State(false)
		local state14 = state.State(false)
		local state15 = state.State(false)
		local state16 = state.State(false)

		if state2.value == false then
			state.Checkbox({ "Open main window" }, {
				isChecked = state2
			})
			return
		end

		state.Window({
			"Iris Demo Window",
			[state.Args.Window.NoTitleBar] = state8.value,
			[state.Args.Window.NoBackground] = state9.value,
			[state.Args.Window.NoCollapse] = state10.value,
			[state.Args.Window.NoClose] = state11.value,
			[state.Args.Window.NoMove] = state12.value,
			[state.Args.Window.NoScrollbar] = state13.value,
			[state.Args.Window.NoResize] = state14.value,
			[state.Args.Window.NoNav] = state15.value,
			[state.Args.Window.NoMenu] = state16.value
		}, {
			size = state.State(Vector2.new(600, 550)),
			position = state.State(Vector2.new(100, 25)),
			isOpened = state2
		})
		mainMenuBar()
		state.Text({ "Iris says hello. (2.1.1)" })
		state.CollapsingHeader({ "Window Options" })
		state.Table({
			3,
			false,
			false,
			false
		})
		state.NextColumn()
		state.Checkbox({ "NoTitleBar" }, {
			isChecked = state8
		})
		state.NextColumn()
		state.Checkbox({ "NoBackground" }, {
			isChecked = state9
		})
		state.NextColumn()
		state.Checkbox({ "NoCollapse" }, {
			isChecked = state10
		})
		state.NextColumn()
		state.Checkbox({ "NoClose" }, {
			isChecked = state11
		})
		state.NextColumn()
		state.Checkbox({ "NoMove" }, {
			isChecked = state12
		})
		state.NextColumn()
		state.Checkbox({ "NoScrollbar" }, {
			isChecked = state13
		})
		state.NextColumn()
		state.Checkbox({ "NoResize" }, {
			isChecked = state14
		})
		state.NextColumn()
		state.Checkbox({ "NoNav" }, {
			isChecked = state15
		})
		state.NextColumn()
		state.Checkbox({ "NoMenu" }, {
			isChecked = state16
		})
		state.End()
		state.End()
		widgetEventInteractivity()
		widgetStateInteractivity()
		state.CollapsingHeader({ "Recursive Tree" })

		if state.Tree({ "Recursive Tree" }).state.isUncollapsed.value then
			recursiveTree()
		end

		state.End()
		state.End()
		dynamicStyle()
		state.Separator()
		state.CollapsingHeader({ "Widgets" })

		for _, v4 in v2 do
			v[v4]()
		end

		state.End()
		tablesDemo()
		layoutDemo()
		state.End()

		if state3.value then
			recursiveWindow(state3)
		end

		if state4.value then
			runtimeInfo()
		end

		if state5.value then
			fn()
		end

		if state6.value then
			windowlessDemo()
		end

		if state7.value then
			mainMenuBarExample() -- equivalent call inferred; original call site unknown
		end
	end
end