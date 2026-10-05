local parent = script.Parent
local ScaleMeasure = require(parent.ScaleMeasure)
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local React = require(shared.React)
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local State = require(parent2.State)
local Util = require(parent2.Util)
local hooks = parent2.Hooks
local useSpring = require(hooks.useSpring)
local useStyleSheet = require(hooks.useStyleSheet)

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function clamp(p: number, p2: number, p3: number)
	if p < p2 then
		return p2
	end

	if p3 < p then
		return p3
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGuiInsetYFor(instance)
	local screenGui = instance and instance:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui and screenGui.IgnoreGuiInset then
		return 0
	end

	return GuiService:GetGuiInset().Y
end

local function FloatingRowOverlay(props)
	local v = React.useMemo(function()
		local innerProps = {
			DisplayIndex = props.Index,
			Dragging = true,
			Id = props.Id
		}

		if props.InnerProps then
			for k, innerProp in pairs(props.InnerProps) do
				innerProps[k] = innerProp
			end
		end

		return innerProps
	end, { props.Id, props.Index, props.InnerProps })
	return React.createElement("TextButton", {
		[React.Tag] = "FloatingRowOverlay",
		Size = UDim2.new(1, 0, 0, props.RowHeight),
		Position = UDim2.fromOffset(0, props.Y),
		BackgroundColor3 = props.Color
	}, props.InnerComponent and { React.createElement(props.InnerComponent, v) })
end

local function Row(props)
	local v = React.useMemo(function()
		local innerProps = {
			DisplayIndex = props.DisplayIndex,
			Dragging = false,
			Id = props.Id
		}

		if props.InnerProps then
			for k, innerProp in pairs(props.InnerProps) do
				innerProps[k] = innerProp
			end
		end

		return innerProps
	end, { props.Id, props.InnerProps, props.DisplayIndex })
	local v2, v3 = React.useBinding(props.YGoal)
	React.useEffect(function()
		v3(props.YGoal)
	end, { props.YGoal })
	local v4 = useSpring(v2)
	local v5, v6 = React.useBinding(props.TGoal)
	React.useEffect(function()
		v6(props.TGoal)
	end, { props.TGoal })
	local mapped = useSpring(v5):map(function(value: number)
		local v7 = math.clamp(value, 0, 1)
		return props.OddColor:Lerp(props.EvenColor, v7)
	end)
	local ref = React.useRef(nil)
	return React.createElement("TextButton", {
		[React.Tag] = "SongItem Row",
		Size = UDim2.new(1, 0, 0, props.Height),
		Position = v4:map(function(p: number)
			return UDim2.fromOffset(0, p)
		end),
		BackgroundColor3 = mapped,
		ref = ref,
		[React.Event.MouseButton1Down] = function()
			if props.Dragging then
				return
			end

			local current = ref.current

			if current then
				props.OnMouseDownAt(current.AbsolutePosition.Y)
			else
				props.OnMouseDownAt(0)
			end
		end,
		[React.Event.MouseButton1Click] = function()
			if props.Dragging then
				return
			end

			if props.OnActivated then
				props.OnActivated()
			end
		end
	}, props.InnerComponent and { React.createElement(props.InnerComponent, v) })
end

local function mouseViewY(instance, p: number)
	local guiInsetYFor = getGuiInsetYFor(instance) -- equivalent call inferred; original call site unknown
	return clamp(
		(UserInputService:GetMouseLocation().Y - guiInsetYFor - instance.AbsolutePosition.Y) / p,
		0,
		instance.AbsoluteSize.Y / p
	)
end

local function DraggableList(data)
	local v = useStyleSheet("Palette")
	local v2, v3 = useStyleSheet("Sizes")
	local v4 = React.useMemo(function()
		return data.RowHeight or v2("Size-RowHeight", 0)
	end, { v3 })
	local v5 = React.useContext(State.Context)
	local oddColor = data.OddColor or v("Color-BackgroundForePanel") or Color3.fromRGB(42, 44, 56)
	local evenColor = data.EvenColor or v("Color-BackgroundMidPanel") or Color3.fromRGB(28, 30, 40)
	local v6 = React.useMemo(function()
		return table.clone(data.Items or {})
	end, { data.Items })
	local state, setState = React.useState(1)
	local state2, setState2 = React.useState(v6)
	local state3, setState3 = React.useState(false)
	local state4, setState4 = React.useState()
	local state5, setState5 = React.useState()
	local state6, setState6 = React.useState()
	local state7, setState7 = React.useState(0)
	local state8, setState8 = React.useState(0)
	local ref = React.useRef()
	local ref2 = React.useRef()
	local state9, setState9 = React.useState(0)
	local state10, setState10 = React.useState(0)
	local ref3 = React.useRef(0)
	local ref4 = React.useRef()
	React.useEffect(function()
		if state3 then
			return
		end

		local items = data.Items

		if not items then
			return
		end

		setState2(function(list)
			local v7 = {}
			local v8 = {}
			local v9 = {}
			local v10 = {}

			for i, v11 in ipairs(list) do
				v7[v11] = i
			end

			for i, item in ipairs(items) do
				if v7[item] ~= i then
					table.insert(v9, {
						Id = item,
						Order = i
					})
				end

				v8[item] = true
			end

			for _, v11 in ipairs(list) do
				if not v8[v11] then
					table.insert(v10, v11)
				end
			end

			if #v9 == 0 and #v10 == 0 then
				return list
			end

			local clone = table.clone(list)

			for _, v11 in ipairs(v9) do
				clone[v11.Order] = v11.Id
			end

			for _, v11 in ipairs(v10) do
				local index = table.find(clone, v11)

				if index then
					table.remove(clone, index)
				end
			end

			return clone
		end)
	end, { data.Items, state3 })
	local v7 = React.useCallback(function(p: number)
		return p * v4
	end, { v4 })
	local v8 = React.useCallback(function(p: number, p2: number)
		return clamp(math.floor(p / v4) + 1, 1, math.max(p2, 1))
	end, { v4 })
	local v9 = React.useCallback(function(p: number)
		local v10 = math.max(p, 1)
		local dragMinCell = data.DragMinCell or 1

		if dragMinCell < 1 then
			dragMinCell = 1
		elseif v10 < dragMinCell then
			dragMinCell = v10
		end

		local dragMaxCell = data.DragMaxCell or v10

		if dragMaxCell < 1 then
			dragMaxCell = 1
		elseif v10 < dragMaxCell then
			dragMaxCell = v10
		end

		if dragMaxCell < dragMinCell then
			dragMaxCell = dragMinCell
		end

		return dragMinCell, dragMaxCell
	end, { data.DragMinCell, data.DragMaxCell })
	local v10 = React.useCallback(function()
		ref4.current = nil
		ref3.current = 0
		setState8(0)
		setState3(false)
		setState7(0)
	end, {})
	local v11 = React.useCallback(function(current: number, p: number)
		if state3 then
			return
		end

		local v12, v13 = v9(#state2)

		if current < v12 or v13 < current then
			return
		end

		ref4.current = current
		ref3.current = os.clock()
		local current2 = ref2.current
		local current3 = ref.current

		if current2 and current3 then
			local guiInsetYFor = getGuiInsetYFor(current2) -- equivalent call inferred; original call site unknown
			local v14 = (UserInputService:GetMouseLocation().Y - guiInsetYFor) / state - p / state
			local v15 = v4

			if v14 < 0 then
				v14 = 0
			elseif v15 < v14 then
				v14 = v15
			end

			setState8(v14)
		end
	end, {
		state2,
		state,
		v4,
		v9
	})
	React.useEffect(function()
		if ref4.current == nil then
			return
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local current = ref3.current

			if current <= 0 or (os.clock() - current) * 1000 < 300 then
				return
			end

			local current2 = ref4.current
			ref4.current = nil
			ref3.current = 0

			if not current2 then
				return
			end

			local count = #state2

			if current2 < 1 or count < current2 then
				return
			end

			local v12, v13 = v9(count)

			if current2 < v12 or v13 < current2 then
				return
			end

			local current3 = ref2.current
			local current4 = ref.current

			if not (current3 and current4) then
				return
			end

			local v14 = state
			local guiInsetYFor = getGuiInsetYFor(current3) -- equivalent call inferred; original call site unknown
			local v15 = (UserInputService:GetMouseLocation().Y - guiInsetYFor - current3.AbsolutePosition.Y) / v14
			local v16 = current3.AbsoluteSize.Y / v14

			if v15 < 0 then
				v15 = 0
			elseif v16 < v15 then
				v15 = v16
			end

			local v17 = (current3.AbsolutePosition.Y - current4.AbsolutePosition.Y) / state + v15 - state8
			setState3(true)
			setState7(v17)
			setState4(state2[current2])
			setState6(current2)
			local v20 = v8(current3.CanvasPosition.Y / state + (v15 - state8 + v4 * 0.5), count)

			if v20 < v12 then
				v20 = v12
			elseif v13 < v20 then
				v20 = v13
			end

			setState5(v20)
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { state2, state8, state })
	React.useEffect(function()
		if not state3 then
			return
		end

		local current = ref2.current
		local current2 = ref.current

		if not (current and current2) then
			return
		end

		local v12 = true
		local now = os.clock()

		local function tick()
			if not v12 then
				return
			end

			local count = #state2
			local now2 = os.clock()
			local v13 = now2 - now
			now = now2

			if count == 0 then
				return
			end

			local guiInsetYFor = getGuiInsetYFor(current) -- equivalent call inferred; original call site unknown
			local v15 = (UserInputService:GetMouseLocation().Y - guiInsetYFor) / state
			local v16 = current.AbsolutePosition.Y / state
			local v17 = current.AbsoluteSize.Y / state
			local v18 = v16 + 24
			local v19 = v16 + v17 - 24
			local v20 = math.max(0, v7(count) * state - current.AbsoluteSize.Y)
			local v21 = 320 * state

			if v15 < v18 then
				local current3 = current
				local v24 = current.CanvasPosition.Y - v21 * v13

				if v24 < 0 then
					v24 = 0
				elseif v20 < v24 then
					v24 = v20
				end

				current3.CanvasPosition = Vector2.new(0, v24)
			elseif v19 < v15 then
				local current3 = current
				local v24 = current.CanvasPosition.Y + v21 * v13

				if v24 < 0 then
					v24 = 0
				elseif v20 < v24 then
					v24 = v20
				end

				current3.CanvasPosition = Vector2.new(0, v24)
			end

			local current4 = current
			local v23 = state
			local guiInsetYFor2 = getGuiInsetYFor(current4) -- equivalent call inferred; original call site unknown
			local v24 = (UserInputService:GetMouseLocation().Y - guiInsetYFor2 - current4.AbsolutePosition.Y) / v23
			local v25 = current4.AbsoluteSize.Y / v23

			if v24 < 0 then
				v24 = 0
			elseif v25 < v24 then
				v24 = v25
			end

			setState7((current.AbsolutePosition.Y - current2.AbsolutePosition.Y) / state + v24 - state8)
			local v27 = current.CanvasPosition.Y / state + (v24 - state8 + v4 * 0.5)
			local v28, v29 = v9(count)
			local v31 = v8(v27, count)

			if v31 < v28 then
				v31 = v28
			elseif v29 < v31 then
				v31 = v29
			end

			setState5(v31)
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(tick)
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseMovement or userInputType == Enum.UserInputType.Touch then
				tick()
			end
		end)
		return function()
			v12 = false
			heartbeatConnection:Disconnect()
			inputChangedConnection:Disconnect()
		end
	end, {
		state3,
		state2,
		state8,
		v4,
		state
	})
	React.useEffect(function()
		if not state3 then
			return
		end

		local function endDrag()
			if not state3 then
				return
			end

			setState3(false)
			local current = ref2.current

			if current then
				current.ScrollingEnabled = true
			end

			local v12 = state6
			local v13 = state5
			local count = #state2
			setState4(nil)
			setState6(nil)
			setState5(nil)

			if not (v12 and v13 and count ~= 0) then
				return
			end

			local v14, v15 = v9(count)

			if v12 < v14 or v15 < v12 then
				return
			end

			if v13 < v14 then
				v13 = v14
			elseif v15 < v13 then
				v13 = v15
			end

			if v12 == v13 then
				return
			end

			local clone = table.clone(state2)
			local v16 = clone[v12]
			table.remove(clone, v12)
			local v17 = #clone + 1

			if v15 < v14 then
				v15 = v14
			elseif v17 < v15 then
				v15 = v17
			end

			if v13 < v14 then
				v13 = v14
			elseif v15 < v13 then
				v13 = v15
			end

			table.insert(clone, v13, v16)
			setState2(clone)

			if data.OnReorder then
				data.OnReorder(clone)
			end
		end

		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				endDrag()
			end
		end)
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape then
				endDrag()
			end
		end)
		return function()
			inputEndedConnection:Disconnect()
			inputBeganConnection:Disconnect()
		end
	end, {
		state2,
		state3,
		state5,
		state6
	})
	React.useEffect(function()
		local current = ref2.current

		if current then
			current.ScrollingEnabled = not state3
		end
	end, { state3 })
	React.useEffect(function()
		local current = ref2.current

		if not current then
			return
		end

		setState9(current.CanvasPosition.Y / state)
		setState10(current.AbsoluteSize.Y / state)
		local canvasPositionChangedConnection = current:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			setState9(current.CanvasPosition.Y / state)
		end)
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			setState10(current.AbsoluteSize.Y / state)
		end)
		return function()
			canvasPositionChangedConnection:Disconnect()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, { state })
	React.useEffect(function()
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch then
				v10()
			end
		end)
		return function()
			inputEndedConnection:Disconnect()
		end
	end, {})
	local count = #state2
	local v12 = state3 and state5 or nil

	if v12 then
		local v13, v14 = v9(count)

		if v12 < v13 then
			v12 = v13
		elseif v14 < v12 then
			v12 = v14
		end
	end

	local v13 = 1
	local v14 = {}
	local v15 = {}
	local v16 = {}

	for i = 1, count do
		if not (not v12 or v12 ~= i) then
			continue
		end

		while v13 <= count and v13 == (state6 or -1) do
			v13 += 1
		end

		if v13 <= count then
			v14[v13] = (i - 1) * v4
			v15[v13] = i % 2 == 0 and 1 or 0
			v16[v13] = i
		end

		v13 += 1
	end

	local v17, v18

	if v4 <= 0 or count == 0 then
		v17 = count
		v18 = 1
	elseif state10 <= 0 then
		v17 = math.min(count, 40)
		v18 = 1
	else
		v18 = math.clamp(math.floor(state9 / v4) + 1 - 5, 1, count)
		v17 = math.clamp(math.ceil((state9 + state10) / v4) + 5, 1, count)
	end

	local children = {}

	if v12 then
		children._spacer = React.createElement("Frame", {
			[React.Tag] = "Spacer",
			Size = UDim2.new(1, 0, 0, v4),
			Position = UDim2.fromOffset(0, (v12 - 1) * v4)
		})
	end

	for i, id in ipairs(state2) do
		if not (not state3 or state6 ~= i) then
			continue
		end

		local yGoal = v14[i]
		local tGoal = v15[i]
		local displayIndex = v16[i]

		if not (yGoal ~= nil and tGoal ~= nil and displayIndex ~= nil) then
			continue
		end

		if displayIndex < v18 or v17 < displayIndex then
			continue
		end

		local v23 = i
		local v24 = id
		local displayIndex2 = displayIndex
		children[`row_{yGoal}_{tGoal}_{id}`] = React.createElement(Row, {
			Id = id,
			YGoal = yGoal,
			TGoal = tGoal,
			DisplayIndex = displayIndex,
			Height = v4,
			Dragging = state3 == true,
			OddColor = oddColor,
			EvenColor = evenColor,
			OnMouseDownAt = function(p: number)
				if state3 or not ref2.current or (v23 < 1 or count < v23) then
					return
				end

				v11(v23, p)
			end,
			OnActivated = function()
				if data.OnActivated then
					data.OnActivated(v24, displayIndex2)
				elseif v5 then
					v5.SetSong(v24)
					v5.SetPlaying(true)
				end
			end,
			InnerComponent = data.InnerComponent,
			InnerProps = data.InnerProps
		})
	end

	local floating

	if state3 and state4 then
		local v20 = v12 or state6 or 1
		local v21 = v20 % 2 == 0
		local createElement = React.createElement
		local v23 = {
			Id = state4,
			Y = state7,
			Index = v20,
			RowHeight = v4,
			Color = 0,
			InnerComponent = 0,
			InnerProps = 0
		}

		if v21 then
			oddColor = evenColor or oddColor
		end

		v23.Color = oddColor
		v23.InnerComponent = data.InnerComponent
		v23.InnerProps = data.InnerProps
		floating = createElement(FloatingRowOverlay, v23)
	end

	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames("DraggableList", data[React.Tag]),
		AnchorPoint = data.AnchorPoint,
		Size = data.Size,
		Position = data.Position,
		ref = ref
	}, {
		ScaleMeasure = React.createElement(ScaleMeasure, {
			SetScale = setState
		}),
		Scroller = React.createElement("ScrollingFrame", {
			CanvasSize = UDim2.new(0, 0, 0, v7(count + 1)),
			ref = ref2
		}, children),
		Floating = floating
	})
end

return DraggableList