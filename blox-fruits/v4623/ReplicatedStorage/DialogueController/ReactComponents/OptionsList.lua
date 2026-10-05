local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ArrowIndicator = require(script.Parent.ArrowIndicator)
local OptionRowHeight = require(script.Parent.OptionRowHeight)
local OptionBubbleSync = require(script.Parent.OptionBubbleSync)
local uDim = UDim2.fromScale(0.2885, 0.1)

-- equivalent calls inferred from this helper; original call sites unknown
local function inputPosition(p)
	local position = p.Position
	return Vector2.new(position.X, position.Y)
end

local function maxScroll(p)
	return (math.max(p.AbsoluteCanvasSize.Y - p.AbsoluteWindowSize.Y, 0))
end

local function isPointNearObject(point: Vector2, current, p: number)
	local v = current.AbsolutePosition - Vector2.new(p, p)
	local v2 = current.AbsolutePosition + current.AbsoluteSize + Vector2.new(p, p)
	return point.X >= v.X and point.X <= v2.X and point.Y >= v.Y and point.Y <= v2.Y
end

local function shouldAttachSpecialToOptions(p)
	local props = p and p.props
	return typeof(props) == "table" and props.optionsListLayout == "aboveOptions"
end

local function ArrowTapButton(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(props.visible)
	local ref3 = React.useRef(props.onActivated)
	ref2.current = props.visible
	ref3.current = props.onActivated
	React.useEffect(function()
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			local current = ref.current

			if not current or input.UserInputType ~= current.inputType then
				return
			end

			if (inputPosition(input) - current.startPosition).Magnitude > 6 then
				current.moved = true
			end
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local current = ref.current

			if not current or input.UserInputType ~= current.inputType then
				return
			end

			ref.current = nil
			local v = time() - current.startedAt
			local moved = current.moved

			if not moved then
				moved = (inputPosition(input) - current.startPosition).Magnitude > 6
			end

			if ref2.current and v <= 0.25 and not moved then
				ref3.current()
			end
		end)
		return function()
			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, {})
	return React.createElement("TextButton", {
		Active = props.visible,
		AnchorPoint = props.anchorPoint,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = props.position,
		Selectable = false,
		Size = props.size,
		Text = "",
		Visible = props.visible,
		ZIndex = 9,
		[React.Event.InputBegan] = function(_, p)
			if p.UserInputType ~= Enum.UserInputType.Touch and p.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			ref.current = {
				startPosition = inputPosition(p),
				startedAt = time(),
				inputType = p.UserInputType,
				moved = false
			}
		end
	})
end

local function OptionsList(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local ref4 = React.useRef(nil)
	local ref5 = React.useRef(false)
	local ref6 = React.useRef(false)
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(0)
	local ref7 = React.useRef(nil)

	if not ref7.current then
		local v = {}
		local v2 = {}

		local function current()
			local width = nil
			local textSize = nil

			for _, v3 in v do
				if not width or width < v3.width then
					width = v3.width
				end

				if not textSize or v3.textSize < textSize then
					textSize = v3.textSize
				end
			end

			return width, textSize
		end

		ref7.current = {
			current = current,
			report = function(p, width: number?, textSize: number?)
				if width and textSize then
					local v3 = v[p]

					if v3 and v3.width == width and v3.textSize == textSize then
						return
					else
						v[p] = {
							width = width,
							textSize = textSize
						}
					end
				elseif v[p] == nil then
					return
				else
					v[p] = nil
				end

				local v3, v4 = current()

				for _, v5 in v2 do
					v5(v3, v4)
				end
			end,
			subscribe = function(p, callback)
				v2[p] = callback
				return function()
					v2[p] = nil
				end
			end
		}
	end

	local count = 0

	if props.children then
		for _ in props.children do
			count += 1
		end
	end

	local v = math.floor(state3 / 4)
	local v2 = math.floor(v * 0.15 + 0.5)
	local v3 = math.floor(v2 / 2)
	local v4 = v2 - v3
	local v5 = v - v2
	local v6 = count * v
	local v7 = math.clamp(count, 1, 4)
	local v8 = not (v > 0) and 0 or math.max(state3 - v7 * v, 0) + v3
	local uDim2 = UDim2.new(0.1154, 0, 0, v8 - 6)
	local uDim3

	if v * 4 < v6 then
		uDim3 = UDim2.fromOffset(0, v6)
	else
		uDim3 = UDim2.new()
	end

	local uDim4 = UDim2.new(0.1154, -6, 0, v8 + v5 / 2)
	local uDim5 = UDim2.new(0.1154, -6, 0, state3 - v4 - v5 / 2)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelSnapThread()
		local current = ref3.current

		if current then
			ref3.current = nil
			pcall(task.cancel, current)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelScrollTween()
		local current = ref4.current

		if current then
			ref4.current = nil
			current:Cancel()
		end

		ref5.current = false
	end

	local function tweenToCanvasY(value: number)
		local current = ref2.current

		if not current then
			return
		end

		local v9 = math.clamp(value, 0, (math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0)))

		if math.abs(v9 - current.CanvasPosition.Y) < 1 then
			cancelSnapThread() -- equivalent call inferred; original call site unknown
			cancelScrollTween() -- equivalent call inferred; original call site unknown
		else
			cancelSnapThread() -- equivalent call inferred; original call site unknown
			cancelScrollTween() -- equivalent call inferred; original call site unknown
			ref5.current = true
			local tween = TweenService:Create(
				current,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CanvasPosition = Vector2.new(0, v9)
				}
			)
			ref4.current = tween
			tween.Completed:Connect(function()
				if ref4.current == tween then
					ref4.current = nil
					ref5.current = false
				end
			end)
			tween:Play()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function snapToNearestRow()
		local current = ref2.current

		if not current then
			return
		end

		local v9 = math.floor(current.AbsoluteWindowSize.Y / 4)

		if v9 < 1 then
			return
		end

		tweenToCanvasY(math.clamp(
			math.floor(current.CanvasPosition.Y / v9 + 0.5) * v9,
			0,
			(math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0))
		))
	end

	local function scheduleSnap()
		if ref5.current or ref6.current then
			return
		end

		cancelSnapThread() -- equivalent call inferred; original call site unknown
		ref3.current = task.delay(0.15, function()
			ref3.current = nil

			if not ref6.current then
				snapToNearestRow() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local function scrollToEdge(p: string)
		local current = ref2.current

		if not current then
			return
		end

		tweenToCanvasY(p == "up" and 0 or math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0))
	end

	React.useEffect(function()
		local current = ref2.current

		if not current then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			setState(current.CanvasPosition.Y > 1)
			local current2 = current
			setState2(current.CanvasPosition.Y < math.max(
				current2.AbsoluteCanvasSize.Y - current2.AbsoluteWindowSize.Y,
				0
			) - 1)
		end

		local function updateWindow()
			setState3(current.AbsoluteWindowSize.Y)
			update() -- equivalent call inferred; original call site unknown
		end

		setState3(current.AbsoluteWindowSize.Y)
		setState(current.CanvasPosition.Y > 1)
		setState2(current.CanvasPosition.Y < math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0) - 1)
		local v9 = { current:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				update() -- equivalent call inferred; original call site unknown

				if not ref5.current then
					if ref6.current then
						return
					end

					cancelSnapThread() -- equivalent call inferred; original call site unknown
					ref3.current = task.delay(0.15, function()
						ref3.current = nil

						if not ref6.current then
							snapToNearestRow() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			end), current:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(update), current:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateWindow) }
		return function()
			for _, connection in v9 do
				connection:Disconnect()
			end

			cancelSnapThread() -- equivalent call inferred; original call site unknown
			cancelScrollTween() -- equivalent call inferred; original call site unknown
		end
	end, {})
	React.useEffect(function()
		local v9 = nil
		local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local current = ref2.current
			local current2 = ref.current

			if not current or not current2 or math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0) <= 1 then
				return
			end

			local startPosition = inputPosition(input) -- equivalent call inferred; original call site unknown

			if not isPointNearObject(startPosition, current2, 24) then
				return
			end

			cancelSnapThread() -- equivalent call inferred; original call site unknown
			cancelScrollTween() -- equivalent call inferred; original call site unknown
			ref6.current = true
			v9 = {
				startPosition = startPosition,
				startCanvasPosition = current.CanvasPosition,
				dragging = false
			}
		end)
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch or not v9 then
				return
			end

			local current = ref2.current

			if not current then
				return
			end

			local v10 = inputPosition(input) - v9.startPosition

			if not v9.dragging and v10.Magnitude <= 8 then
				return
			end

			v9.dragging = true
			current.CanvasPosition = Vector2.new(
				0,
				(math.clamp(
					v9.startCanvasPosition.Y - v10.Y,
					0,
					(math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0))
				))
			)
		end)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch or not v9 then
				return
			end

			local dragging = v9.dragging
			v9 = nil
			ref6.current = false

			if dragging then
				snapToNearestRow() -- equivalent call inferred; original call site unknown
			end
		end)
		return function()
			inputBeganConnection:Disconnect()
			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
			ref6.current = false
		end
	end, {})
	local v9 = {
		uIListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0, v2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),
		uIPadding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0.1154, 0),
			PaddingRight = UDim.new(0.1154, 0),
			PaddingTop = UDim.new(0, v3),
			PaddingBottom = UDim.new(0, v4)
		}),
		options = 0
	}
	local options

	if v5 > 0 and props.children then
		options = React.createElement(OptionRowHeight.Provider, {
			value = v5
		}, React.createElement(OptionBubbleSync.Provider, {
			value = ref7.current
		}, props.children))
	end

	v9.options = options
	local v11 = {
		scroller = React.createElement("ScrollingFrame", {
			ref = ref2,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = uDim3,
			ScrollBarImageTransparency = 0.4,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Selectable = false,
			Size = UDim2.fromScale(1, 1)
		}, v9),
		upArrow = React.createElement(ArrowIndicator, {
			direction = "up",
			variant = "options",
			anchorPoint = Vector2.new(1, 0.5),
			position = uDim4,
			size = uDim,
			bounce = true,
			visible = state
		}),
		upArrowButton = React.createElement(ArrowTapButton, {
			anchorPoint = Vector2.new(1, 0.5),
			position = uDim4,
			size = uDim,
			visible = state,
			onActivated = function()
				if not ref2.current then
					return
				end

				tweenToCanvasY(0)
			end
		}),
		downArrow = React.createElement(ArrowIndicator, {
			direction = "down",
			variant = "options",
			anchorPoint = Vector2.new(1, 0.5),
			position = uDim5,
			size = uDim,
			bounce = true,
			visible = state2
		}),
		downArrowButton = React.createElement(ArrowTapButton, {
			anchorPoint = Vector2.new(1, 0.5),
			position = uDim5,
			size = uDim,
			visible = state2,
			onActivated = function()
				local current = ref2.current

				if not current then
					return
				end

				tweenToCanvasY(math.max(current.AbsoluteCanvasSize.Y - current.AbsoluteWindowSize.Y, 0))
			end
		})
	}

	if props.specialChildren then
		for k, v12 in props.specialChildren do
			local props2 = v12 and v12.props
			local v13

			if typeof(props2) == "table" then
				v13 = props2.optionsListLayout == "aboveOptions"
			else
				v13 = false
			end

			if v13 then
				v12 = React.cloneElement(v12, {
					anchorPoint = Vector2.new(0, 1),
					position = uDim2
				})
			end

			v11[k] = v12
		end
	end

	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = Vector2.new(0, 1),
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Position = props.position or UDim2.fromScale(0.714474, 0.00562883),
		Size = props.size or UDim2.fromScale(0.394558, 1.76641)
	}, v11)
end

return React.memo(OptionsList)