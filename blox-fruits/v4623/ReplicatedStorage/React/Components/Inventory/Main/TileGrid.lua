local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local useMultiSelection = require(ReplicatedStorage.React.Hooks.Item.useMultiSelection)
local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Console"):tag("UI"):tag("React"):traceback():display():build()
local useVirtualList = require(game.ReplicatedStorage.React.Hooks.useVirtualList)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useListLoadingQueue = require(game.ReplicatedStorage.React.Hooks.useListLoadingQueue)
local useInputEffect = require(game.ReplicatedStorage.React.Hooks.useInputEffect)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useInitialSelection = require(game.ReplicatedStorage.React.Hooks.Inventory.useInitialSelection)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local FastTile = require(script.FastTile)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(data)
	local state, setState = React.useState(nil)
	local ref = React.useRef(Spring.new(0.8, 2, 0))
	local ref2 = React.useRef(Vector2.new(0, 0))
	local v2, v3 = useInitialSelection()
	local v4 = useLastInput()
	local v5 = useConfig()
	local v6 = data.Variant == "Fade" and 5 or 3
	local state2, setState2 = React.useState(Vector2.new(0, 0))
	local state3, setState3 = React.useState(Vector2.new(0, 0))
	local state4, setState4 = React.useState(Vector2.new(0, 0))
	local rowCellCount = data.RowCellCount or 4
	local v7, v8 = useMultiSelection()
	local v9, v10, v11 = useSelection()
	React.useEffect(function()
		local vector = nil

		if v2 then
			local count = 0

			for _, tile in pairs(data.Tiles) do
				count += 1

				if not (tile.ItemId == v2 and tile.NetworkedUID == v3) then
					continue
				end

				local v13 = math.ceil(count / rowCellCount)
				local v14 = count - (v13 - 1) * rowCellCount
				vector = Vector2.new(v14, v13)
				break
			end

			if vector then
				local renderSteppedConnection = nil
				renderSteppedConnection = RunService.RenderStepped:Connect(function(_: number)
					setState(nil)
					renderSteppedConnection:Disconnect()
				end)
				setState(vector)
				return function()
					renderSteppedConnection:Disconnect()
				end
			end
		end

		return function() end
	end, { v2, v3 })
	local current3 = math.max(3, (math.ceil(#data.Tiles / rowCellCount)))
	local v13 = math.ceil(state4.Y / current3)
	math.min(v13, (math.round(v13 / 1.8181818181818181)))
	local rect = Rect.new(state2.X, state2.Y, state2.X + state4.X - 0, state2.Y + state4.Y)
	local v14 = math.round((rect.Width - 8) / rowCellCount - (rowCellCount - 1) / rowCellCount * 0 * (v4 ~= "Touch" and 1 or (rowCellCount + 1) / rowCellCount))
	local ref3 = React.useRef(nil)
	React.useEffect(function()
		if data.ScrollToTop then
			ref.current.Position = 0
			ref.current.Velocity = 0
			ref.current:Set(1)
			ref2.current = state3
		end
	end, { data.ScrollToTop })
	React.useEffect(function()
		local current = ref3.current

		if not (data.ScrollToTop and current) then
			return function() end
		end

		local current2 = ref.current
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			current2:Step(dt)
			current.CanvasPosition = ref2.current:Lerp(Vector2.zero, (math.clamp(current2.Position, 0, 1)))

			if math.abs(current2.Goal - current2.Position) <= 0.001 and math.abs(current2.Velocity) <= 0.001 then
				heartbeatConnection:Disconnect()
				setState3(Vector2.zero)
				data.OnScrollToTop()
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { data.ScrollToTop, ref3.current, data.OnScrollToTop })
	local drawContext = useDrawContext()
	local v16 = useVirtualList(
		drawContext == "Default",
		Vector2.new(rowCellCount, current3),
		v4 == "Gamepad" and 1 or 0,
		Enum.SizeConstraint.RelativeYY,
		UDim2.fromOffset(v14, v14),
		UDim2.fromOffset(0, 0),
		UDim2.fromOffset(4, 4),
		rect,
		state3,
		ref3,
		Enum.ScrollingDirection.Y,
		state,
		Spring.new(1.5, 4, 0),
		nil,
		function() end,
		nil
	)
	local ref4 = React.useRef(rowCellCount)
	ref4.current = rowCellCount
	local ref5 = React.useRef(current3)
	ref5.current = current3
	local ref6 = React.useRef(nil)

	local function fn(p)
		local keyCode = p.KeyCode
		v.trace(function()
			return (`console input? key={keyCode}, focusIndexRef={state}, tileCount={#data.Tiles}`)
		end)

		if state and (ref6.current == nil or ref6.current and ref6.current < tick() - 0.75) then
			ref6.current = tick()

			if keyCode == Enum.KeyCode.DPadUp and (state.Y <= 1 or #data.Tiles == 0) then
				v.trace("GamepadBorderExit(Up)")
				data.OnGamepadBorderExit("Up")
			elseif keyCode == Enum.KeyCode.DPadDown and (state.Y >= ref5.current or #data.Tiles == 0) then
				v.trace("GamepadBorderExit(Down)")
				data.OnGamepadBorderExit("Down")
			elseif keyCode == Enum.KeyCode.DPadLeft and (state.X <= 1 or #data.Tiles == 0) then
				v.trace("GamepadBorderExit(Left)")
				data.OnGamepadBorderExit("Left")
			elseif keyCode == Enum.KeyCode.DPadRight and (state.X >= ref4.current or math.round(state.X + ref4.current * (state.Y - 1)) >= #data.Tiles) then
				v.trace("GamepadBorderExit(Right)")
				data.OnGamepadBorderExit("Right")
			end
		end
	end

	useInputEffect(fn, Enum.UserInputState.End, nil, nil, v4 == "Gamepad" and drawContext == "Default", state)
	local v22 = 1e999
	local count = 0
	local v23 = {}

	for _, card in pairs(v16.Cards) do
		local v24 = math.round(card.Index.X + rowCellCount * (card.Index.Y - 1))
		v22 = math.min(v22, v24)

		if data.Tiles[v24] then
			count += 1
		end
	end

	local v24 = useListLoadingQueue(count, 0.02, nil)

	for k, card in pairs(v16.Cards) do
		local v25 = math.round(card.Index.X + rowCellCount * (card.Index.Y - 1))
		local tile = data.Tiles[v25]

		if not tile then
			continue
		end

		local v26 = v25 - v22 + 1

		if not (v24 and v26 <= v24) then
			continue
		end

		local formatted = `{tile.ItemId}{not tile.NetworkedUID and "" or `-{tile.NetworkedUID}`}`
		local isSelected

		if data.IsMultiSelect == true then
			isSelected = v7[formatted] == true
		elseif tile.ItemId == v9 then
			isSelected = tile.NetworkedUID == v10
		else
			isSelected = false
		end

		local v28

		if v4 == "Gamepad" then
			v28 = `ConsoleTile-{k}`
		else
			v28 = `Tile-{v26}`
		end

		local v31 = {
			Size = UDim2.fromOffset(card.SizePx.X - v6, card.SizePx.Y - v6),
			Position = UDim2.fromOffset(card.PositionPx.X, card.PositionPx.Y),
			LoadingPriority = #data.Tiles - v25,
			IsSelected = isSelected,
			DrawContext = drawContext,
			Variant = data.Variant,
			Selectable = data.Selectable ~= false and drawContext == "Default",
			Info = tile,
			SelectionBorderColor = data.SelectionBorderColor
		}
		local info = tile

		v31[React.Event.Activated] = function()
			if data.IsMultiSelect == true then
				v8(formatted, not isSelected)
			elseif isSelected then
				v11(nil, nil)
			else
				v11(info.ItemId, info.NetworkedUID)
			end
		end

		local v35 = card
		v31[React.Event.SelectionLost] = v4 == "Gamepad" and function(p)
			if state and math.round(state.X) == math.round(v35.Index.X) and math.round(state.Y) == math.round(v35.Index.Y) then
				setState(nil)
			end
		end or nil
		local v36 = card
		v31[React.Event.SelectionGained] = v4 == "Gamepad" and function(p)
			setState(v36.Index)
		end or nil
		v23[v28] = createElement(FastTile, v31)
	end

	if #data.Tiles == 0 and v5.HideEmptyScreen ~= true then
		return createElement("Frame", RobloxTypes.mergeGuiObject({
			BackgroundTransparency = 1,
			SelectionGroup = true,
			SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
			SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
			SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
			SelectionBehaviorRight = Enum.SelectionBehavior.Stop
		}, data), {
			Graphic = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Image = "rbxassetid://106651835895529",
				Position = UDim2.fromScale(0.5, 0.42),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.18, 0.18)
			}, {
				AspectRatio = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1
				})
			}),
			NoItemsFound = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.58),
				Size = UDim2.fromScale(0.6, 0.07),
				Text = "No Items Found",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = CONSTANTS.ALPHA.LIGHT
			})
		})
	end

	local mergeScrollingFrame = RobloxTypes.mergeScrollingFrame
	local v27 = {
		[React.Tag] = data[React.Tag],
		ref = ref3,
		[React.Change.AbsoluteWindowSize] = function(p)
			setState4(Vector2.new(p.AbsoluteWindowSize.X, p.AbsoluteWindowSize.Y))
		end,
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollBarImageColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ScrollBarThickness = 10,
		ScrollBarImageTransparency = CONSTANTS.ALPHA.OPAQUE,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		SelectionGroup = true,
		SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
		SelectionBehaviorUp = Enum.SelectionBehavior.Escape,
		SelectionBehaviorLeft = Enum.SelectionBehavior.Escape,
		SelectionBehaviorRight = Enum.SelectionBehavior.Escape,
		Selectable = false,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		LayoutOrder = data.LayoutOrder,
		ZIndex = data.ZIndex,
		SizeConstraint = data.SizeConstraint
	}

	if data.ScrollToTop then
		state3 = nil
	end

	v27.CanvasPosition = state3
	v27.CanvasSize = UDim2.fromOffset(0, v16.CanvasAreaPx.Height)

	v27[React.Change.AbsolutePosition] = function(p)
		setState2(p.AbsolutePosition)
	end

	v27[React.Change.CanvasPosition] = function(p)
		setState3(p.CanvasPosition)
	end

	return createElement("ScrollingFrame", mergeScrollingFrame(v27, data), {
		Content = createElement(React.Fragment, {}, v23)
	})
end