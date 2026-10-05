require(script.Parent.Types)
return function(state)
	local state2 = state.State(true)
	local state3 = state.State(false)
	local state4 = state.State(false)
	local state5 = state.State(false)
	local state6 = state.State(false)
	local state7 = state.State(false)
	local state8 = state.State(false)

	local function helpMarker(p: string)
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function textAndHelpMarker(p: string, p2: string)
		state.SameLine()
		state.Text({ p })
		helpMarker(p2)
		state.End()
	end

	local v = {
		Basic = function()
			state.Tree({ "Basic" })
			state.SeparatorText({ "Basic" })
			local state9 = state.State(1)
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
				index = state9
			})
			state.RadioButton({ "Index 'two'", "two" }, {
				index = state9
			})

			if state.RadioButton({ "Index 'false'", false }, {
				index = state9
			}).active() == false and state.SmallButton({ "Select last" }).clicked() then
				state9:set(false)
			end

			state.End()
			state.Text({ "The Index is: " .. tostring(state9.value) })
			state.SeparatorText({ "Inputs" })
			state.InputNum({})
			state.DragNum({})
			state.SliderNum({})
			state.End()
		end,
		Image = function()
			state.Tree({ "Image" })
			state.SeparatorText({ "Image Controls" })
			local state9 = state.State("rbxasset://textures/ui/common/robux.png")
			local state10 = state.State(UDim2.fromOffset(100, 100))
			local state11 = state.State(Rect.new(0, 0, 0, 0))
			local state12 = state.State(Enum.ScaleType.Stretch)
			local state13 = state.State(false)
			local computedState = state.ComputedState(state13, function(flag: boolean)
				return flag and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default
			end)
			local state14 = state.State(state._config.ImageColor)
			local state15 = state.State(state._config.ImageTransparency)
			state.InputColor4({ "Image Tint" }, {
				color = state14,
				transparency = state15
			})
			state.Combo({ "Asset" }, {
				index = state9
			})
			state.Selectable({ "Robux Small", "rbxasset://textures/ui/common/robux.png" }, {
				index = state9
			})
			state.Selectable({ "Robux Large", "rbxasset://textures//ui/common/robux@3x.png" }, {
				index = state9
			})
			state.Selectable({ "Loading Texture", "rbxasset://textures//loading/darkLoadingTexture.png" }, {
				index = state9
			})
			state.Selectable({ "Hue-Saturation Gradient", "rbxasset://textures//TagEditor/huesatgradient.png" }, {
				index = state9
			})
			state.Selectable({ "famfamfam.png (WHY?)", "rbxasset://textures//TagEditor/famfamfam.png" }, {
				index = state9
			})
			state.End()
			state.SliderUDim2({
				"Image Size",
				nil,
				nil,
				UDim2.new(1, 240, 1, 240)
			}, {
				number = state10
			})
			state.SliderRect({
				"Image Rect",
				nil,
				nil,
				Rect.new(256, 256, 256, 256)
			}, {
				number = state11
			})
			state.Combo({ "Scale Type" }, {
				index = state12
			})
			state.Selectable({ "Stretch", Enum.ScaleType.Stretch }, {
				index = state12
			})
			state.Selectable({ "Fit", Enum.ScaleType.Fit }, {
				index = state12
			})
			state.Selectable({ "Crop", Enum.ScaleType.Crop }, {
				index = state12
			})
			state.End()
			state.Checkbox({ "Pixelated" }, {
				isChecked = state13
			})
			state.PushConfig({
				ImageColor = state14:get(),
				ImageTransparency = state15:get()
			})
			state.Image({
				state9:get(),
				state10:get(),
				state11:get(),
				state12:get(),
				computedState:get()
			})
			state.PopConfig()
			state.SeparatorText({ "Tile" })
			local state16 = state.State(UDim2.fromScale(0.5, 0.5))
			state.SliderUDim2({
				"Tile Size",
				nil,
				nil,
				UDim2.new(1, 240, 1, 240)
			}, {
				number = state16
			})
			state.PushConfig({
				ImageColor = state14:get(),
				ImageTransparency = state15:get()
			})
			state.Image({
				"rbxasset://textures/grid2.png",
				state10:get(),
				nil,
				Enum.ScaleType.Tile,
				computedState:get(),
				state16:get()
			})
			state.PopConfig()
			state.SeparatorText({ "Slice" })
			local state17 = state.State(1)
			state.SliderNum({
				"Image Slice Scale",
				0.1,
				0.1,
				5
			}, {
				number = state17
			})
			state.PushConfig({
				ImageColor = state14:get(),
				ImageTransparency = state15:get()
			})
			state.Image({
				"rbxasset://textures/ui/chatBubble_blue_notify_bkg.png",
				state10:get(),
				nil,
				Enum.ScaleType.Slice,
				computedState:get(),
				nil,
				Rect.new(12, 12, 56, 56),
				1
			}, state17:get())
			state.PopConfig()
			state.SeparatorText({ "Image Button" })
			local state18 = state.State(0)
			state.SameLine()
			state.PushConfig({
				ImageColor = state14:get(),
				ImageTransparency = state15:get()
			})

			if state.ImageButton({
				"rbxasset://textures/AvatarCompatibilityPreviewer/add.png",
				UDim2.fromOffset(20, 20)
			}).clicked() then
				state18:set(state18.value + 1)
			end

			state.PopConfig()
			state.Text({ (`Click count: {state18.value}`) })
			state.End()
			state.End()
		end,
		Selectable = function()
			state.Tree({ "Selectable" })
			local state9 = state.State(2)
			state.Selectable({ "Selectable #1", 1 }, {
				index = state9
			})
			state.Selectable({ "Selectable #2", 2 }, {
				index = state9
			})

			if state.Selectable({ "Double click Selectable", 3, true }, {
				index = state9
			}).doubleClicked() then
				state9:set(3)
			end

			state.Selectable({ "Impossible to select", 4, true }, {
				index = state9
			})

			if state.Button({ "Select last" }).clicked() then
				state9:set(4)
			end

			state.Selectable({ "Independent Selectable" })
			state.End()
		end,
		Combo = function()
			state.Tree({ "Combo" })
			state.PushConfig({
				ContentWidth = UDim.new(1, -200)
			})
			local state9 = state.State("No Selection")
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
				index = state9
			})
			state.Selectable({ "Select 1", "One" }, {
				index = state9
			})
			state.Selectable({ "Select 2", "Two" }, {
				index = state9
			})
			state.Selectable({ "Select 3", "Three" }, {
				index = state9
			})
			state.End()
			state.ComboArray({ "Using ComboArray" }, {
				index = "No Selection"
			}, { "Red", "Green", "Blue" })
			local state10 = state.State("7 AM")
			state.Combo({ "Combo with Inner widgets" }, {
				index = state10
			})
			state.Tree({ "Morning Shifts" })
			state.Selectable({ "Shift at 7 AM", "7 AM" }, {
				index = state10
			})
			state.Selectable({ "Shift at 11 AM", "11 AM" }, {
				index = state10
			})
			state.Selectable({ "Shift at 3 PM", "3 PM" }, {
				index = state10
			})
			state.End()
			state.Tree({ "Night Shifts" })
			state.Selectable({ "Shift at 6 PM", "6 PM" }, {
				index = state10
			})
			state.Selectable({ "Shift at 9 PM", "9 PM" }, {
				index = state10
			})
			state.End()
			state.End()
			local comboEnum = state.ComboEnum({ "Using ComboEnum" }, {
				index = Enum.UserInputState.Begin
			}, Enum.UserInputState)
			state.Text({ "Selected: " .. comboEnum.index:get().Name })
			state.PopConfig()
			state.End()
		end,
		Tree = function()
			state.Tree({ "Trees" })
			state.Tree({ "Tree using SpanAvailWidth", true })
			helpMarker("SpanAvailWidth determines if the Tree is selectable from its entire with, or only the text area")
			state.End()
			local tree = state.Tree({ "Tree with Children" })
			state.Text({ "Im inside the first tree!" })
			state.Button({ "Im a button inside the first tree!" })
			state.Tree({ "Im a tree inside the first tree!" })
			state.Text({ "I am the innermost text!" })
			state.End()
			state.End()
			state.Checkbox({ "Toggle above tree" }, {
				isChecked = tree.state.isUncollapsed
			})
			state.End()
		end,
		CollapsingHeader = function()
			state.Tree({ "Collapsing Headers" })
			state.CollapsingHeader({ "A header" })
			state.Text({ "This is under the first header!" })
			state.End()
			local state9 = state.State(false)
			state.CollapsingHeader({ "Another header" }, {
				isUncollapsed = state9
			})

			if state.Button({ "Shhh... secret button!" }).clicked() then
				state9:set(true)
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
		Tab = function()
			state.Tree({ "Tabs" })
			state.Tree({ "Simple" })
			state.TabBar()
			state.Tab({ "Apples" })
			state.Text({ "Who loves apples?" })
			state.End()
			state.Tab({ "Broccoli" })
			state.Text({ "And what about broccoli?" })
			state.End()
			state.Tab({ "Carrots" })
			state.Text({ "But carrots are the best." })
			state.End()
			state.End()
			state.Separator()
			state.Text({ "Very important questions." })
			state.End()
			state.Tree({ "Closable" })
			local state9 = state.State(true)
			local state10 = state.State(true)
			local state11 = state.State(true)
			state.TabBar()
			state.Tab({ "🍎", true }, {
				isOpened = state9
			})
			state.Text({ "Who loves apples?" })

			if state.Button({ "I don't like apples." }).clicked() then
				state9:set(false)
			end

			state.End()
			state.Tab({ "🥦", true }, {
				isOpened = state10
			})
			state.Text({ "And what about broccoli?" })

			if state.Button({ "Not for me." }).clicked() then
				state10:set(false)
			end

			state.End()
			state.Tab({ "🥕", true }, {
				isOpened = state11
			})
			state.Text({ "But carrots are the best." })

			if state.Button({ "I disagree with you." }).clicked() then
				state11:set(false)
			end

			state.End()
			state.End()
			state.Separator()

			if state.Button({ "Actually, let me reconsider it." }).clicked() then
				state9:set(true)
				state10:set(true)
				state11:set(true)
			end

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
			local state9 = state.State(false)
			local state10 = state.State(false)
			local state11 = state.State(0)
			local state12 = state.State(100)
			local state13 = state.State(1)
			local state14 = state.State("%d")
			state.PushConfig({
				ContentWidth = UDim.new(1, -120)
			})
			local v3 = state.InputNum({
				[state.Args.InputNum.Text] = "Input Number",
				[state.Args.InputNum.NoButtons] = state10.value,
				[state.Args.InputNum.Min] = state11.value,
				[state.Args.InputNum.Max] = state12.value,
				[state.Args.InputNum.Increment] = state13.value,
				[state.Args.InputNum.Format] = { state14.value }
			})
			state.PopConfig()
			state.Text({ "The Value is: " .. v3.number.value })

			if state.Button({ "Randomize Number" }).clicked() then
				v3.number:set(math.random(1, 99))
			end

			local checkbox = state.Checkbox({ "NoField" }, {
				isChecked = state9
			})
			local checkbox2 = state.Checkbox({ "NoButtons" }, {
				isChecked = state10
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
			local state15 = state.State(false)
			local state16 = state.State(false)
			local state17 = state.State(Color3.new())
			local state18 = state.State(0)
			state.SliderNum({
				"Transparency",
				0.01,
				0,
				1
			}, {
				number = state18
			})
			state.InputColor3({ "InputColor3", state15:get(), state16:get() }, {
				color = state17
			})
			state.InputColor4({ "InputColor4", state15:get(), state16:get() }, {
				color = state17,
				transparency = state18
			})
			state.SameLine()
			state.Text({ state17:get():ToHex() })
			state.Checkbox({ "Use Floats" }, {
				isChecked = state15
			})
			state.Checkbox({ "Use HSV" }, {
				isChecked = state16
			})
			state.End()
			state.PopConfig()
			state.Separator()
			textAndHelpMarker("Slider Numbers", "ctrl + click slider number widgets to input a number") -- equivalent call inferred; original call site unknown
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
			textAndHelpMarker(
				"Drag Numbers",
				"ctrl + click or double click drag number widgets to input a number, hold shift/alt while dragging to increase/decrease speed"
			) -- equivalent call inferred; original call site unknown
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
			local inputText = state.InputText({ "Input Text Test", "Input Text here" })
			state.Text({ "The text is: " .. inputText.text.value })
			state.End()
		end,
		MultiInput = function()
			state.Tree({ "Multi-Component Input" })
			local state9 = state.State(Vector2.new())
			local state10 = state.State((Vector3.new()))
			local state11 = state.State(UDim.new())
			local state12 = state.State(UDim2.new())
			local state13 = state.State(Color3.new())
			local state14 = state.State(Rect.new(0, 0, 0, 0))
			state.SeparatorText({ "Input" })
			state.InputVector2({}, {
				number = state9
			})
			state.InputVector3({}, {
				number = state10
			})
			state.InputUDim({}, {
				number = state11
			})
			state.InputUDim2({}, {
				number = state12
			})
			state.InputRect({}, {
				number = state14
			})
			state.SeparatorText({ "Drag" })
			state.DragVector2({}, {
				number = state9
			})
			state.DragVector3({}, {
				number = state10
			})
			state.DragUDim({}, {
				number = state11
			})
			state.DragUDim2({}, {
				number = state12
			})
			state.DragRect({}, {
				number = state14
			})
			state.SeparatorText({ "Slider" })
			state.SliderVector2({}, {
				number = state9
			})
			state.SliderVector3({}, {
				number = state10
			})
			state.SliderUDim({}, {
				number = state11
			})
			state.SliderUDim2({}, {
				number = state12
			})
			state.SliderRect({}, {
				number = state14
			})
			state.SeparatorText({ "Color" })
			state.InputColor3({}, {
				color = state13
			})
			state.InputColor4({}, {
				color = state13
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

			local state9 = state.State("Hello ")
			local state10 = state.State(1)

			if state.InputNum({
				"# of repeat",
				1,
				1,
				50
			}, {
				number = state10
			}).numberChanged() then
				state9:set(string.rep("Hello ", state10:get()))
			end

			if state.Checkbox({ "Show dynamic text tooltip" }).state.isChecked.value then
				state.Tooltip({ state9:get() })
			end

			state.End()
			state.PopConfig()
		end,
		Plotting = function()
			state.Tree({ "Plotting" })
			state.SeparatorText({ "Progress" })
			local v2 = os.clock() * 15
			local state9 = state.State(0)
			state9:set(math.clamp(math.abs(v2 % 100 - 50) - 7.5, 0, 35) / 35)
			state.ProgressBar({ "Progress Bar" }, {
				progress = state9
			})
			state.ProgressBar({ "Progress Bar", (`{math.floor(state9:get() * 1753)}/1753`) }, {
				progress = state9
			})
			state.SeparatorText({ "Graphs" })
			local state10 = state.State({
				0.5,
				0.8,
				0.2,
				0.9,
				0.1,
				0.6,
				0.4,
				0.7,
				0.3,
				0
			})
			state.PlotHistogram({
				"Histogram",
				100,
				0,
				1,
				"random"
			}, {
				values = state10
			})
			state.PlotLines({
				"Lines",
				100,
				0,
				1,
				"random"
			}, {
				values = state10
			})
			local state11 = state.State("Cos")
			local state12 = state.State(37)
			local state13 = state.State(0)
			local state14 = state.State({})
			local state15 = state.State(0)
			local checkbox = state.Checkbox({ "Animate" })
			local comboArray = state.ComboArray({ "Plotting Function" }, {
				index = state11
			}, {
				"Sin",
				"Cos",
				"Tan",
				"Saw"
			})
			local sliderNum = state.SliderNum({
				"Samples",
				1,
				1,
				145,
				"%d samples"
			}, {
				number = state12
			})

			if state.SliderNum({
				"Baseline",
				0.1,
				-1,
				1
			}, {
				number = state13
			}).numberChanged() then
				state14:set(state14.value, true)
			end

			if checkbox.state.isChecked.value or comboArray.closed() or sliderNum.numberChanged() or #state14.value == 0 then
				if checkbox.state.isChecked.value then
					state15:set(state15.value + state.Internal._deltaTime)
				end

				local v3 = math.floor(state15.value * 30) - 1
				local value = state11.value
				table.clear(state14.value)

				for i = 1, state12.value do
					if value == "Sin" then
						state14.value[i] = math.sin((math.rad((i + v3) * 5)))
					elseif value == "Cos" then
						state14.value[i] = math.cos((math.rad((i + v3) * 5)))
					elseif value == "Tan" then
						state14.value[i] = math.tan((math.rad((i + v3) * 5)))
					elseif value == "Saw" then
						state14.value[i] = i % 2 == v3 % 2 and 1 or -1
					end
				end

				state14:set(state14.value, true)
			end

			state.PlotHistogram({
				"Histogram",
				100,
				-1,
				1,
				"",
				state13:get()
			}, {
				values = state14
			})
			state.PlotLines({
				"Lines",
				100,
				-1,
				1
			}, {
				values = state14
			})
			state.End()
		end
	}
	local v2 = {
		"Basic",
		"Image",
		"Selectable",
		"Combo",
		"Tree",
		"CollapsingHeader",
		"Group",
		"Tab",
		"Indent",
		"Input",
		"MultiInput",
		"InputText",
		"Tooltip",
		"Plotting"
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
		local state9 = state.State(3)
		local state10 = state.State(0)
		local state11 = state.State(os.clock())
		state.SameLine()
		state.InputNum({
			[state.Args.InputNum.Text] = "",
			[state.Args.InputNum.Format] = "%d Seconds",
			[state.Args.InputNum.Max] = 10
		}, {
			number = state9
		})

		if state.Button({ "Disable" }).clicked() then
			state.Disabled = true
			task.delay(state9:get(), function()
				state.Disabled = false
			end)
		end

		state.End()
		local now = os.clock()
		local v4 = now - state11.value
		state10.value += (v4 - state10.value) * 0.2
		state11.value = now
		state.Text({ string.format("Average %.3f ms/frame (%.1f FPS)", state10.value * 1000, 1 / state10.value) })
		state.Text({ string.format(
				"Window Position: (%d, %d), Window Size: (%d, %d)",
				window.position.value.X,
				window.position.value.Y,
				window.size.value.X,
				window.size.value.Y
			) })
		textAndHelpMarker(
			"Enter an ID to learn more about it.",
			"every widget and state has an ID which Iris tracks to remember which widget is which. below lists all widgets and states, with their respective IDs"
		) -- equivalent call inferred; original call site unknown
		state.PushConfig({
			ItemWidth = UDim.new(1, -150)
		})
		local value = state.InputText({ "ID field" }, {
			text = state.State(window.ID)
		}).state.text.value
		state.PopConfig()
		state.Indent()
		local v5 = _lastVDOM[value]
		local _state = _states[value]

		if v5 then
			state.Table({ 1 })
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

				for k, v6 in v5.state do
					state.Text({ k .. " - " .. tostring(v6.value) })
				end

				state.End()
			end

			state.End()
		elseif _state then
			state.Table({ 1 })
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

		if state.Tree({ "Widgets" }).state.isUncollapsed.value then
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

		if state.Tree({ "States" }).state.isUncollapsed.value then
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

	local function debugPanel()
		state.Window({ "Debug Panel" }, {
			isOpened = state8
		})
		state.CollapsingHeader({ "Widgets" })
		state.SeparatorText({ "GuiService" })
		state.Text({ (`GuiOffset: {state.Internal._utility.GuiOffset}`) })
		state.Text({ (`MouseOffset: {state.Internal._utility.MouseOffset}`) })
		state.SeparatorText({ "UserInputService" })
		state.Text({ (`MousePosition: {state.Internal._utility.UserInputService:GetMouseLocation()}`) })
		state.Text({ (`MouseLocation: {state.Internal._utility.getMouseLocation()}`) })
		state.Text({ (`Left Control: {state.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)}`) })
		state.Text({ (`Right Control: {state.Internal._utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)}`) })
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

		if state.MenuItem({ "Quit", Enum.KeyCode.Q, Enum.ModifierKey.Alt }).clicked() then
			state2:set(false)
		end

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
		state.MenuToggle({ "Debug Panel" }, {
			isChecked = state8
		})
		state.End()
		state.End()
	end

	local function mainMenuBarExample()
		mainMenuBar()
	end

	local function fn()
		local v3 = {
			{ "Sizing", function()
					local state9 = state.State({})
					state.SameLine()

					if state.Button({ "Update" }).clicked() then
						state.UpdateGlobalConfig(state9.value)
						state9:set({})
					end

					helpMarker("Update the global config with these changes.")
					state.End()

					local function SliderInput(p: string, list)
						local v4 = state[p](list, {
							number = state.WeakState(state._config[list[1]])
						})

						if v4.numberChanged() then
							state9.value[list[1]] = v4.number:get()
						end
					end

					local function BooleanInput(list)
						local checkbox = state.Checkbox(list, {
							isChecked = state.WeakState(state._config[list[1]])
						})

						if checkbox.checked() or checkbox.unchecked() then
							state9.value[list[1]] = checkbox.isChecked:get()
						end
					end

					state.SeparatorText({ "Main" })
					SliderInput("SliderVector2", {
						"WindowPadding",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"WindowResizePadding",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"FramePadding",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"ItemSpacing",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"ItemInnerSpacing",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"CellPadding",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderNum", {
						"IndentSpacing",
						1,
						0,
						36
					})
					SliderInput("SliderNum", {
						"ScrollbarSize",
						1,
						0,
						20
					})
					SliderInput("SliderNum", {
						"GrabMinSize",
						1,
						0,
						20
					})
					state.SeparatorText({ "Borders & Rounding" })
					SliderInput("SliderNum", {
						"FrameBorderSize",
						0.1,
						0,
						1
					})
					SliderInput("SliderNum", {
						"WindowBorderSize",
						0.1,
						0,
						1
					})
					SliderInput("SliderNum", {
						"PopupBorderSize",
						0.1,
						0,
						1
					})
					SliderInput("SliderNum", {
						"SeparatorTextBorderSize",
						1,
						0,
						20
					})
					SliderInput("SliderNum", {
						"FrameRounding",
						1,
						0,
						12
					})
					SliderInput("SliderNum", {
						"GrabRounding",
						1,
						0,
						12
					})
					SliderInput("SliderNum", {
						"PopupRounding",
						1,
						0,
						12
					})
					state.SeparatorText({ "Widgets" })
					SliderInput("SliderVector2", {
						"DisplaySafeAreaPadding",
						nil,
						Vector2.zero,
						Vector2.new(20, 20)
					})
					SliderInput("SliderVector2", {
						"SeparatorTextPadding",
						nil,
						Vector2.zero,
						Vector2.new(36, 36)
					})
					SliderInput("SliderUDim", {
						"ItemWidth",
						nil,
						UDim.new(),
						UDim.new(1, 200)
					})
					SliderInput("SliderUDim", {
						"ContentWidth",
						nil,
						UDim.new(),
						UDim.new(1, 200)
					})
					SliderInput("SliderNum", {
						"ImageBorderSize",
						1,
						0,
						12
					})
					local comboEnum = state.ComboEnum({ "WindowTitleAlign" }, {
						index = state.WeakState(state._config.WindowTitleAlign)
					}, Enum.LeftRight)

					if comboEnum.closed() then
						state9.value.WindowTitleAlign = comboEnum.index:get()
					end

					BooleanInput({ "RichText" })
					BooleanInput({ "TextWrapped" })
					state.SeparatorText({ "Config" })
					BooleanInput({ "UseScreenGUIs" })
					SliderInput("DragNum", { "DisplayOrderOffset", 1, 0 })
					SliderInput("DragNum", { "ZIndexOffset", 1, 0 })
					SliderInput("SliderNum", {
						"MouseDoubleClickTime",
						0.1,
						0,
						5
					})
					SliderInput("SliderNum", {
						"MouseDoubleClickMaxDist",
						0.1,
						0,
						20
					})
				end },
			{ "Colors", function()
					local state9 = state.State({})
					state.SameLine()

					if state.Button({ "Update" }).clicked() then
						state.UpdateGlobalConfig(state9.value)
						state9:set({})
					end

					helpMarker("Update the global config with these changes.")
					state.End()

					for _, v4 in {
						"Text",
						"TextDisabled",
						"WindowBg",
						"PopupBg",
						"Border",
						"BorderActive",
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
						"Image",
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

						state9.value[v4 .. "Color"] = inputColor4.color:get()
						state9.value[v4 .. "Transparency"] = inputColor4.transparency:get()
					end
				end },
			{ "Fonts", function()
					local state9 = state.State({})
					state.SameLine()

					if state.Button({ "Update" }).clicked() then
						state.UpdateGlobalConfig(state9.value)
						state9:set({})
					end

					helpMarker("Update the global config with these changes.")
					state.End()
					local v4 = {
						["Code (default)"] = Font.fromEnum(Enum.Font.Code),
						["Ubuntu (template)"] = Font.fromEnum(Enum.Font.Ubuntu),
						Arial = Font.fromEnum(Enum.Font.Arial),
						Highway = Font.fromEnum(Enum.Font.Highway),
						Roboto = Font.fromEnum(Enum.Font.Roboto),
						["Roboto Mono"] = Font.fromEnum(Enum.Font.RobotoMono),
						["Noto Sans"] = Font.new("rbxassetid://12187370747"),
						["Builder Sans"] = Font.fromEnum(Enum.Font.BuilderSans),
						["Builder Mono"] = Font.new("rbxassetid://16658246179"),
						Sono = Font.new("rbxassetid://12187374537")
					}
					state.Text({ (`Current Font: {state._config.TextFont.Family} Weight: {state._config.TextFont.Weight} Style: {state._config.TextFont.Style}`) })
					state.SeparatorText({ "Size" })
					local sliderNum = state.SliderNum({
						"Font Size",
						1,
						4,
						20
					}, {
						number = state.WeakState(state._config.TextSize)
					})

					if sliderNum.numberChanged() then
						state9.value.TextSize = sliderNum.state.number:get()
					end

					state.SeparatorText({ "Properties" })
					local weakState = state.WeakState(state._config.TextFont.Family)
					local comboEnum = state.ComboEnum({ "Font Weight" }, {
						index = state.WeakState(state._config.TextFont.Weight)
					}, Enum.FontWeight)
					local comboEnum2 = state.ComboEnum({ "Font Style" }, {
						index = state.WeakState(state._config.TextFont.Style)
					}, Enum.FontStyle)
					state.SeparatorText({ "Fonts" })

					for k, v5 in v4 do
						local font = Font.new(v5.Family, comboEnum.state.index.value, comboEnum2.state.index.value)
						state.SameLine()
						state.PushConfig({
							TextFont = font
						})

						if state.Selectable({ `{k} | "The quick brown fox jumps over the lazy dog."`, font.Family }, {
							index = weakState
						}).selected() then
							state9.value.TextFont = font
						end

						state.PopConfig()
						state.End()
					end
				end }
		}
		state.Window({ "Style Editor" }, {
			isOpened = state5
		})
		state.Text({ "Customize the look of Iris in realtime." })
		local state9 = state.State("Dark Theme")

		if state.ComboArray({ "Theme" }, {
			index = state9
		}, { "Dark Theme", "Light Theme" }).closed() then
			if state9.value == "Dark Theme" then
				state.UpdateGlobalConfig(state.TemplateConfig.colorDark)
			elseif state9.value == "Light Theme" then
				state.UpdateGlobalConfig(state.TemplateConfig.colorLight)
			end
		end

		local state10 = state.State("Classic Size")

		if state.ComboArray({ "Size" }, {
			index = state10
		}, { "Classic Size", "Larger Size" }).closed() then
			if state10.value == "Classic Size" then
				state.UpdateGlobalConfig(state.TemplateConfig.sizeDefault)
			elseif state10.value == "Larger Size" then
				state.UpdateGlobalConfig(state.TemplateConfig.sizeClear)
			end
		end

		state.SameLine()

		if state.Button({ "Revert" }).clicked() then
			state.UpdateGlobalConfig(state.TemplateConfig.colorDark)
			state.UpdateGlobalConfig(state.TemplateConfig.sizeDefault)
			state9:set("Dark Theme")
			state10:set("Classic Size")
		end

		helpMarker("Reset Iris to the default theme and size.")
		state.End()
		state.TabBar()

		for i, v4 in ipairs(v3) do
			state.Tab({ v4[1] })
			v3[i][2]()
			state.End()
		end

		state.End()
		state.Separator()
		state.End()
	end

	local function widgetEventInteractivity()
		state.CollapsingHeader({ "Widget Event Interactivity" })
		local state9 = state.State(0)

		if state.Button({ "Click to increase Number" }).clicked() then
			state9:set(state9:get() + 1)
		end

		state.Text({ "The Number is: " .. state9:get() })
		state.Separator()
		local state10 = state.State(false)
		local state11 = state.State("clicked")
		state.SameLine()
		state.RadioButton({ "clicked", "clicked" }, {
			index = state11
		})
		state.RadioButton({ "rightClicked", "rightClicked" }, {
			index = state11
		})
		state.RadioButton({ "doubleClicked", "doubleClicked" }, {
			index = state11
		})
		state.RadioButton({ "ctrlClicked", "ctrlClicked" }, {
			index = state11
		})
		state.End()
		state.SameLine()

		if state.Button({ state11:get() .. " to reveal text" })[state11:get()]() then
			state10:set(not state10:get())
		end

		if state10:get() then
			state.Text({ "Here i am!" })
		end

		state.End()
		state.Separator()
		local state12 = state.State(0)
		state.SameLine()

		if state.Button({ "Click to show text for 20 frames" }).clicked() then
			state12:set(20)
		end

		if state12:get() > 0 then
			state.Text({ "Here i am!" })
		end

		state.End()
		state12:set((math.max(0, state12:get() - 1)))
		state.Text({ "Text Timer: " .. state12:get() })
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
		local state9 = state.State(false)
		local checkbox2 = state.Checkbox({ "User-Generated State" }, {
			isChecked = state9
		})
		state.Text({ (`isChecked: {checkbox2.state.isChecked.value}\n`) })
		local checkbox3 = state.Checkbox({ "Widget Coupled State" })
		local checkbox4 = state.Checkbox({ "Coupled to above Checkbox" }, {
			isChecked = checkbox3.state.isChecked
		})
		state.Text({ (`isChecked: {checkbox4.state.isChecked.value}\n`) })
		local state10 = state.State(false)
		state.Checkbox({ "Widget and Code Coupled State" }, {
			isChecked = state10
		})

		if state.Button({ "Click to toggle above checkbox" }).clicked() then
			state10:set(not state10:get())
		end

		state.Text({ (`isChecked: {state10.value}\n`) })
		local state11 = state.State(true)
		local computedState = state.ComputedState(state11, function(p)
			return not p
		end)
		state.Checkbox({ "ComputedState (dynamic coupling)" }, {
			isChecked = state11
		})
		state.Checkbox({ "Inverted of above checkbox" }, {
			isChecked = computedState
		})
		state.Text({ (`isChecked: {computedState.value}\n`) })
		state.End()
	end

	local function dynamicStyle()
		state.CollapsingHeader({ "Dynamic Styles" })
		local state9 = state.State(0)
		state.SameLine()

		if state.Button({ "Change Color" }).clicked() then
			state9:set(math.random())
		end

		state.Text({ "Hue: " .. math.floor(state9:get() * 255) })
		helpMarker("Using PushConfig with a changing value, this can be done with any config field")
		state.End()
		state.PushConfig({
			TextColor = Color3.fromHSV(state9:get(), 1, 1)
		})
		state.Text({ "Text with a unique and changable color" })
		state.PopConfig()
		state.End()
	end

	local function tablesDemo()
		local state9 = state.State(false)
		state.CollapsingHeader({ "Tables & Columns" }, {
			isUncollapsed = state9
		})

		if state9.value == false then
			state.End()
			return
		end

		textAndHelpMarker(
			"Table using NextRow and NextColumn syntax:",
			"calling Iris.NextRow() in the outer loop, and Iris.NextColumn()in the inner loop"
		) -- equivalent call inferred; original call site unknown
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
		textAndHelpMarker(
			"Table using NextColumn only syntax:",
			"only calling Iris.NextColumn() in the inner loop, the result is identical"
		) -- equivalent call inferred; original call site unknown
		state.Table({ 2 })

		for i = 1, 4 do
			for i2 = 1, 2 do
				state.NextColumn()
				state.Text({ (`Row: {i}, Column: {i2}`) })
			end
		end

		state.End()
		state.Separator()
		local state10 = state.State(false)
		local state11 = state.State(false)
		local state12 = state.State(true)
		local state13 = state.State(true)
		local state14 = state.State(3)
		state.Text({ "Table with Customizable Arguments" })
		state.Table({
			[state.Args.Table.NumColumns] = 4,
			[state.Args.Table.RowBg] = state10.value,
			[state.Args.Table.BordersOuter] = state11.value,
			[state.Args.Table.BordersInner] = state12.value
		})

		for i = 1, state14:get() do
			for i2 = 1, 4 do
				state.NextColumn()

				if state13.value then
					state.Button({ (`Month: {i}, Week: {i2}`) })
				else
					state.Text({ (`Month: {i}, Week: {i2}`) })
				end
			end
		end

		state.End()
		state.Checkbox({ "RowBg" }, {
			isChecked = state10
		})
		state.Checkbox({ "BordersOuter" }, {
			isChecked = state11
		})
		state.Checkbox({ "BordersInner" }, {
			isChecked = state12
		})
		state.SameLine()
		state.RadioButton({ "Buttons", true }, {
			index = state13
		})
		state.RadioButton({ "Text", false }, {
			index = state13
		})
		state.End()
		state.InputNum({
			[state.Args.InputNum.Text] = "Number of rows",
			[state.Args.InputNum.Min] = 0,
			[state.Args.InputNum.Max] = 100,
			[state.Args.InputNum.Format] = "%d"
		}, {
			number = state14
		})
		state.End()
	end

	local function layoutDemo()
		state.CollapsingHeader({ "Widget Layout" })
		state.Tree({ "Widget Alignment" })
		state.Text({ "Iris.SameLine has optional argument supporting horizontal and vertical alignments." })
		state.Text({ "This allows widgets to be place anywhere on the line." })
		state.Separator()
		textAndHelpMarker("By default child widgets will be aligned to the left.", [[
Iris.SameLine()
	Iris.Button({ "Button A" })
	Iris.Button({ "Button B" })
Iris.End()]]) -- equivalent call inferred; original call site unknown
		state.SameLine()
		state.Button({ "Button A" })
		state.Button({ "Button B" })
		state.End()
		textAndHelpMarker("But can be aligned to the center.", [[
Iris.SameLine({ nil, nil, Enum.HorizontalAlignment.Center })
	Iris.Button({ "Button A" })
	Iris.Button({ "Button B" })
Iris.End()]]) -- equivalent call inferred; original call site unknown
		state.SameLine({ nil, nil, Enum.HorizontalAlignment.Center })
		state.Button({ "Button A" })
		state.Button({ "Button B" })
		state.End()
		textAndHelpMarker("Or right.", [[
Iris.SameLine({ nil, nil, Enum.HorizontalAlignment.Right })
	Iris.Button({ "Button A" })
	Iris.Button({ "Button B" })
Iris.End()]]) -- equivalent call inferred; original call site unknown
		state.SameLine({ nil, nil, Enum.HorizontalAlignment.Right })
		state.Button({ "Button A" })
		state.Button({ "Button B" })
		state.End()
		state.Separator()
		textAndHelpMarker("You can also specify the padding.", [[
Iris.SameLine({ 0, nil, Enum.HorizontalAlignment.Center })
	Iris.Button({ "Button A" })
	Iris.Button({ "Button B" })
Iris.End()]]) -- equivalent call inferred; original call site unknown
		state.SameLine({ 0, nil, Enum.HorizontalAlignment.Center })
		state.Button({ "Button A" })
		state.Button({ "Button B" })
		state.End()
		state.End()
		state.Tree({ "Widget Sizing" })
		state.Text({ "Nearly all widgets are the minimum size of the content." })
		state.Text({ "For example, text and button widgets will be the size of the text labels." })
		state.Text({ "Some widgets, such as the Image and Button have Size arguments will will set the size of them." })
		state.Separator()
		textAndHelpMarker(
			"The button takes up the full screen-width.",
			"Iris.Button({ \"Button\", UDim2.fromScale(1, 0) })"
		) -- equivalent call inferred; original call site unknown
		state.Button({ "Button", UDim2.fromScale(1, 0) })
		textAndHelpMarker(
			"The button takes up half the screen-width.",
			"Iris.Button({ \"Button\", UDim2.fromScale(0.5, 0) })"
		) -- equivalent call inferred; original call site unknown
		state.Button({ "Button", UDim2.fromScale(0.5, 0) })
		textAndHelpMarker(
			"Combining with SameLine, the buttons can fill the screen width.",
			"The button will still be larger that the text size."
		) -- equivalent call inferred; original call site unknown
		local state9 = state.State(2)
		state.SliderNum({
			"Number of Buttons",
			1,
			1,
			8
		}, {
			number = state9
		})
		state.SameLine({ 0, nil, Enum.HorizontalAlignment.Center })

		for i = 1, state9.value do
			state.Button({ `Button {i}`, UDim2.fromScale(1 / state9.value, 0) })
		end

		state.End()
		state.End()
		state.Tree({ "Content Width" })
		local state10 = state.State(50)
		local state11 = state.State(Enum.Axis.X)
		state.Text({ "The Content Width is a size property which determines the width of input fields." })
		textAndHelpMarker(
			"By default the value is UDim.new(0.65, 0)",
			"This is the default value from Dear ImGui.\nIt is 65% of the window width."
		) -- equivalent call inferred; original call site unknown
		state.Text({ "This works well, but sometimes we know how wide elements are going to be and want to maximise the space." })
		state.Text({ "Therefore, we can use Iris.PushConfig() to change the width" })
		state.Separator()
		textAndHelpMarker("Content Width = 150 pixels", "UDim.new(0, 150)") -- equivalent call inferred; original call site unknown
		state.PushConfig({
			ContentWidth = UDim.new(0, 150)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state10
		})
		state.InputEnum({ "axis" }, {
			index = state11
		}, Enum.Axis)
		state.PopConfig()
		textAndHelpMarker("Content Width = 50% window width", "UDim.new(0.5, 0)") -- equivalent call inferred; original call site unknown
		state.PushConfig({
			ContentWidth = UDim.new(0.5, 0)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state10
		})
		state.InputEnum({ "axis" }, {
			index = state11
		}, Enum.Axis)
		state.PopConfig()
		textAndHelpMarker("Content Width = -150 pixels from the right side", "UDim.new(1, -150)") -- equivalent call inferred; original call site unknown
		state.PushConfig({
			ContentWidth = UDim.new(1, -150)
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state10
		})
		state.InputEnum({ "axis" }, {
			index = state11
		}, Enum.Axis)
		state.PopConfig()
		state.End()
		state.Tree({ "Content Height" })
		local state12 = state.State("a single line")
		local state13 = state.State(50)
		local state14 = state.State(Enum.Axis.X)
		local state15 = state.State(0)
		state15:set(math.clamp(math.abs(os.clock() * 15 % 100 - 50) - 7.5, 0, 35) / 35)
		state.Text({ "The Content Height is a size property that determines the minimum size of certain widgets." })
		state.Text({ "By default the value is UDim.new(0, 0), so there is no minimum height." })
		state.Text({ "We use Iris.PushConfig() to change this value." })
		state.Separator()
		textAndHelpMarker("Content Height = 0 pixels", "UDim.new(0, 0)") -- equivalent call inferred; original call site unknown
		state.InputText({ "text" }, {
			text = state12
		})
		state.ProgressBar({ "progress" }, {
			progress = state15
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state13
		})
		state.ComboEnum({ "axis" }, {
			index = state14
		}, Enum.Axis)
		textAndHelpMarker("Content Height = 60 pixels", "UDim.new(0, 60)") -- equivalent call inferred; original call site unknown
		state.PushConfig({
			ContentHeight = UDim.new(0, 60)
		})
		state.InputText({
			"text",
			nil,
			nil,
			true
		}, {
			text = state12
		})
		state.ProgressBar({ "progress" }, {
			progress = state15
		})
		state.DragNum({
			"number",
			1,
			0,
			100
		}, {
			number = state13
		})
		state.ComboEnum({ "axis" }, {
			index = state14
		}, Enum.Axis)
		state.PopConfig()
		state.Text({ "This property can be used to force the height of a text box." })
		state.Text({ "Just make sure you enable the MultiLine argument." })
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
		local state9 = state.State(false)
		local state10 = state.State(false)
		local state11 = state.State(false)
		local state12 = state.State(true)
		local state13 = state.State(false)
		local state14 = state.State(false)
		local state15 = state.State(false)
		local state16 = state.State(false)
		local state17 = state.State(false)

		if state2.value == false then
			state.Checkbox({ "Open main window" }, {
				isChecked = state2
			})
			return
		end

		debug.profilebegin("Iris/Demo/Window")
		local v4 = state.Window({
			[state.Args.Window.Title] = "Iris Demo Window",
			[state.Args.Window.NoTitleBar] = state9.value,
			[state.Args.Window.NoBackground] = state10.value,
			[state.Args.Window.NoCollapse] = state11.value,
			[state.Args.Window.NoClose] = state12.value,
			[state.Args.Window.NoMove] = state13.value,
			[state.Args.Window.NoScrollbar] = state14.value,
			[state.Args.Window.NoResize] = state15.value,
			[state.Args.Window.NoNav] = state16.value,
			[state.Args.Window.NoMenu] = state17.value
		}, {
			size = state.State(Vector2.new(600, 550)),
			position = state.State(Vector2.new(100, 25)),
			isOpened = state2
		})

		if v4.state.isUncollapsed.value and v4.state.isOpened.value then
			debug.profilebegin("Iris/Demo/MenuBar")
			mainMenuBar()
			debug.profileend()
			state.Text({ "Iris says hello. (" .. state.Internal._version .. ")" })
			debug.profilebegin("Iris/Demo/Options")
			state.CollapsingHeader({ "Window Options" })
			state.Table({
				3,
				false,
				false,
				false
			})
			state.NextColumn()
			state.Checkbox({ "NoTitleBar" }, {
				isChecked = state9
			})
			state.NextColumn()
			state.Checkbox({ "NoBackground" }, {
				isChecked = state10
			})
			state.NextColumn()
			state.Checkbox({ "NoCollapse" }, {
				isChecked = state11
			})
			state.NextColumn()
			state.Checkbox({ "NoClose" }, {
				isChecked = state12
			})
			state.NextColumn()
			state.Checkbox({ "NoMove" }, {
				isChecked = state13
			})
			state.NextColumn()
			state.Checkbox({ "NoScrollbar" }, {
				isChecked = state14
			})
			state.NextColumn()
			state.Checkbox({ "NoResize" }, {
				isChecked = state15
			})
			state.NextColumn()
			state.Checkbox({ "NoNav" }, {
				isChecked = state16
			})
			state.NextColumn()
			state.Checkbox({ "NoMenu" }, {
				isChecked = state17
			})
			state.End()
			state.End()
			debug.profileend()
			debug.profilebegin("Iris/Demo/Events")
			widgetEventInteractivity()
			debug.profileend()
			debug.profilebegin("Iris/Demo/States")
			widgetStateInteractivity()
			debug.profileend()
			debug.profilebegin("Iris/Demo/Recursive")
			state.CollapsingHeader({ "Recursive Tree" })

			if state.Tree({ "Recursive Tree" }).state.isUncollapsed.value then
				recursiveTree()
			end

			state.End()
			state.End()
			debug.profileend()
			debug.profilebegin("Iris/Demo/Style")
			dynamicStyle()
			debug.profileend()
			state.Separator()
			debug.profilebegin("Iris/Demo/Widgets")
			state.CollapsingHeader({ "Widgets" })

			for _, v5 in v2 do
				debug.profilebegin((`Iris/Demo/Widgets/{v5}`))
				v[v5]()
				debug.profileend()
			end

			state.End()
			debug.profileend()
			debug.profilebegin("Iris/Demo/Tables")
			tablesDemo()
			debug.profileend()
			debug.profilebegin("Iris/Demo/Layout")
			layoutDemo()
			debug.profileend()
		end

		state.End()
		debug.profileend()

		if state3.value then
			recursiveWindow(state3)
		end

		if state4.value then
			runtimeInfo()
		end

		if state8.value then
			debugPanel()
		end

		if state5.value then
			fn()
		end

		if state6.value then
			windowlessDemo()
		end

		if state7.value then
			mainMenuBar()
		end

		return v4
	end
end