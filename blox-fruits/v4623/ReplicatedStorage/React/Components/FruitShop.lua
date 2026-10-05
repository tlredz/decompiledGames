local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Types)
require(script.Types)
local DrawContext = require(game.ReplicatedStorage.React.Contexts.DrawContext)
local FruitCard = require(script.FruitCard)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local VirtualList = require(script.VirtualList)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useControllerMap = require(game.ReplicatedStorage.React.Hooks.useControllerMap)
local useLegacyThumbstick = require(script.useLegacyThumbstick)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useSelectionAnimation = require(script.useSelectionAnimation)
local useFruitPrices = require(script.useFruitPrices)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(43, 43, 43)
local color2 = Color3.fromRGB(255, 240, 69)
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut

function log(...) end

-- equivalent calls inferred from this helper; original call sites unknown
local function solveCardTargetY(p: number, p2: number, rect: Rect, p3: number)
	return (math.round((p3 - 1) * (p + 8) + (p + p2) / 2 - rect.Height / 2))
end

function getAllCardTargets(list, rect: Rect, p: number, p2: number)
	local result = {}

	for i, v in ipairs(list) do
		local v2 = solveCardTargetY(p, p2, rect, i) -- equivalent call inferred; original call site unknown

		if v2 then
			result[v.Name] = v2
		end
	end

	return result
end

local createElement = React.createElement

function windowItems(props)
	local windowRegionPx = props.WindowRegionPx
	local sortedFruitList = props.SortedFruitList
	local cardBounds = props.CardBounds
	local currentCanvasPosition = props.CurrentCanvasPosition
	local closedCardAbsoluteHeight = props.ClosedCardAbsoluteHeight
	local openPanelAbsoluteHeight = props.OpenPanelAbsoluteHeight
	local selectionTargets = props.SelectionTargets
	local canvasPosition = props.CanvasPosition
	local currentDragonSwapType = props.CurrentDragonSwapType
	local setLastWindowArea = props.SetLastWindowArea
	local setCanvasLockInitialPosition = props.SetCanvasLockInitialPosition
	local setCanvasLockTargetPosition = props.SetCanvasLockTargetPosition
	local equipped = props.Equipped
	local owned = props.Owned
	local locked = props.Locked
	local isControllerActive = props.IsControllerActive
	local onGiftClick = props.OnGiftClick
	local onPermPurchaseClick = props.OnPermPurchaseClick
	local onTempPurchaseClick = props.OnTempPurchaseClick
	local onDragonSwapClick = props.OnDragonSwapClick
	local selectionCurrentAlphas = props.SelectionCurrentAlphas
	local selectionCurrentStarts = props.SelectionCurrentStarts
	local setSelectionTargets = props.SetSelectionTargets
	local setSelectionCurrentStarts = props.SetSelectionCurrentStarts
	local onCardClick = props.OnCardClick
	local lastInput = props.LastInput
	local openCardIndex = props.OpenCardIndex
	local midCardIndex = props.MidCardIndex
	local consoleMidTarget = props.ConsoleMidTarget
	local consoleCurrentIndex = props.ConsoleCurrentIndex
	local tagConversions = props.TagConversions
	local setConsoleCurrentIndex = props.SetConsoleCurrentIndex
	local setConsoleMidTarget = props.SetConsoleMidTarget
	local buildQuality = props.BuildQuality
	React.useEffect(function()
		setLastWindowArea(windowRegionPx)
	end, { windowRegionPx, setLastWindowArea })
	local v = React.useMemo(function()
		if #sortedFruitList == 0 then
			return 0
		end

		local v2 = math.random(1, #sortedFruitList)
		local v3 = sortedFruitList[v2]

		if v3 then
			print((`found: {v3.Name}`))
		end

		return v2
	end, { #sortedFruitList })
	local ref = React.useRef(false)
	local flag = false
	local v2 = {}

	for i, v3 in ipairs(sortedFruitList) do
		local cardBound = cardBounds[i]

		if not cardBound then
			continue
		end

		local min = cardBound.Min
		local max = cardBound.Max

		if not (windowRegionPx.Min.Y <= max and min <= windowRegionPx.Max.Y) then
			continue
		end

		local v4 = i

		local function lockToCenter()
			if flag then
				return
			end

			local X = math.round(currentCanvasPosition.X)
			local v5 = solveCardTargetY(closedCardAbsoluteHeight, openPanelAbsoluteHeight, windowRegionPx, v4) -- equivalent call inferred; original call site unknown
			local X2 = math.round(canvasPosition.X)
			local Y = math.round(canvasPosition.Y)

			if X == X2 and Y == v5 then
				return
			end

			local v9 = solveCardTargetY(closedCardAbsoluteHeight, openPanelAbsoluteHeight, windowRegionPx, v4) -- equivalent call inferred; original call site unknown

			if not v9 then
				return
			end

			flag = true
			setCanvasLockInitialPosition(currentCanvasPosition)
			setCanvasLockTargetPosition(Vector2.new(currentCanvasPosition.X, v9))
		end

		local name = v3.Name
		local v7 = v3
		local v8 = {
			PanelHeightRatio = 0.125,
			CardHeightRatio = 0.22435897435897437,
			BuildQuality = buildQuality,
			Data = v3,
			CardAnimationDuration = 0.1,
			CardAnimationEasingStyle = quad,
			CardAnimationEasingDirection = inOut,
			LayoutOrder = i,
			OnEggSelect = v == i and ref.current == false and props.OnEggClick and function()
				ref.current = true
				props.OnEggClick()
			end or nil,
			Item = v3.Item,
			OnMutationClick = v3.HasMutations and function()
				props.OnMutationClick(v7)
			end or nil,
			CurrentDragonSwapType = currentDragonSwapType,
			HoverWiggleEnabled = windowRegionPx.Min.Y < min and max < windowRegionPx.Max.Y,
			PanelPadding = UDim.new(0, 4),
			IsSelected = selectionTargets[v3.Name],
			IsEquipped = 0,
			IsLocked = 0,
			AnchorPoint = 0,
			Position = 0,
			Size = 0,
			SizeConstraint = 0,
			IsControllerActive = 0,
			OnGiftClick = 0,
			IsOwned = 0,
			OnPermPurchaseClick = 0,
			OnTempPurchaseClick = 0,
			OnDragonSwap = 0,
			OnCardClick = 0,
			OnCardSelectionGained = 0,
			ConsoleTag = 0
		}
		local isEquipped

		if equipped then
			isEquipped = v3.Name == equipped.Name
		else
			isEquipped = false
		end

		v8.IsEquipped = isEquipped
		v8.IsLocked = table.find(locked, v3) ~= nil
		v8.AnchorPoint = Vector2.new(0.5, 0)
		v8.Position = UDim2.new(0.5, 0, 0, min)
		v8.Size = UDim2.fromScale(1, 0)
		v8.SizeConstraint = Enum.SizeConstraint.RelativeXX
		v8.IsControllerActive = isControllerActive
		local v11 = v3

		function v8.OnGiftClick()
			onGiftClick(v11)
		end

		v8.IsOwned = table.find(owned, v3) ~= nil
		local v12 = v3

		function v8.OnPermPurchaseClick()
			onPermPurchaseClick(v12)
		end

		local v13 = v3
		v8.OnTempPurchaseClick = onTempPurchaseClick and function()
			onTempPurchaseClick(v13)
		end or nil
		local onDragonSwap

		if v3.Name == "Dragon-Dragon" and equipped == v3 then
			onDragonSwap = onDragonSwapClick
		end

		v8.OnDragonSwap = onDragonSwap
		local v15 = v3
		local v16 = i

		function v8.OnCardClick(flag2: boolean)
			for k, selectionCurrentAlpha in pairs(selectionCurrentAlphas) do
				if selectionCurrentAlpha < 1 and selectionTargets[k] or selectionCurrentAlpha > 0 and not selectionTargets[k] then
					return
				end
			end

			local clone = table.clone(selectionCurrentStarts)
			local now = tick()
			clone[v15.Name] = now

			if selectionTargets[v15.Name] then
				local clone2 = table.clone(selectionTargets)
				clone2[v15.Name] = false
				table.freeze(clone2)
				setSelectionTargets(clone2)
			else
				local clone2 = table.clone(selectionTargets)

				for k, v17 in pairs(clone2) do
					clone2[k] = false
					clone[k] = now
				end

				clone2[v15.Name] = true
				table.freeze(clone2)
				setSelectionTargets(clone2)
			end

			table.freeze(clone)
			setSelectionCurrentStarts(clone)

			if flag2 then
				setCanvasLockInitialPosition(Vector2.new(currentCanvasPosition.X, currentCanvasPosition.Y))
				setCanvasLockTargetPosition(Vector2.new(
					currentCanvasPosition.X,
					(v16 - 1) * (closedCardAbsoluteHeight + 8) + (closedCardAbsoluteHeight + openPanelAbsoluteHeight) / 2 - windowRegionPx.Height / 2
				))
			else
				setConsoleMidTarget(nil)
			end

			onCardClick(v15, flag2)
		end

		v8.OnCardSelectionGained = lastInput == "Gamepad" and function()
			if lastInput == "Gamepad" and openCardIndex ~= nil then
			end
		end or nil
		v8.ConsoleTag = i ~= midCardIndex and "" or tagConversions.Card
		v2[name] = createElement(FruitCard, v8)

		if not (consoleMidTarget == i and openCardIndex == nil) then
			continue
		end

		lockToCenter()

		if not consoleMidTarget then
			continue
		end

		if consoleMidTarget ~= consoleCurrentIndex then
			setConsoleCurrentIndex(consoleMidTarget)
		end

		setConsoleMidTarget(nil)
	end

	return createElement(React.Fragment, {}, v2)
end

function getInitialCanvasPosition()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	local fruitShopInitialScroll = localPlayer:GetAttribute("FruitShopInitialScroll")
	assert(
		typeof(fruitShopInitialScroll) == "nil" or typeof(fruitShopInitialScroll) == "number",
		(`Invalid initial scroll value: {fruitShopInitialScroll} ({typeof(fruitShopInitialScroll)})`)
	)
	return fruitShopInitialScroll
end

function setInitialCanvasPosition(fruitShopInitialScroll: number)
	local localPlayer = Players.LocalPlayer

	if localPlayer then
		localPlayer:SetAttribute("FruitShopInitialScroll", fruitShopInitialScroll)
	end
end

function header(props)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local renderSteppedConnection = nil

		if props.ReleaseDate then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now = DateTime.now()

				if now.UnixTimestamp > props.ReleaseDate.UnixTimestamp then
					setState(nil)
				else
					setState(props.ReleaseDate.UnixTimestamp - now.UnixTimestamp)
				end
			end)
		else
			setState(nil)
		end

		return function()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end
		end
	end, { props.ReleaseDate })
	local text

	if state then
		text = `New fruits in {string.format(
			"%02d:%02d:%02d",
			math.floor(state % 86400 / 3600),
			math.floor(state % 3600 / 60),
			(math.round(state % 60))
		)}`
	else
		text = `{props.OnTempPurchaseClick and "" or "Permanent "}Fruit Shop`
	end

	return createElement("TextLabel", {
		Text = text,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0,
		Size = UDim2.fromScale(1, 0.0953),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		TextTransparency = CONSTANTS.ALPHA.OPAQUE,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderMode = Enum.BorderMode.Outline,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		TextScaled = true,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.SM
		}),
		ExitButton = createElement(Button, {
			ElevatedBackgroundColor3 = color2,
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			OnClick = props.OnExitClick,
			Text = "Back",
			LayoutOrder = 1,
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromScale(0.138, 0.95),
			[React.Tag] = props.TagConversions.ExitButton
		})
	})
end

local function fruitShop(props)
	local visible = props.IsVisible and not props.IsHidden
	local fruitReleaseDate = props.FruitReleaseDate
	local onExitClick = props.OnExitClick
	local onTempPurchaseClick = props.OnTempPurchaseClick
	local onPermPurchaseClick = props.OnPermPurchaseClick
	local onGiftClick = props.OnGiftClick
	local fruits = props.Fruits
	local equipped = props.Equipped
	local owned = props.Owned
	local locked = props.Locked
	local onCardClick = props.OnCardClick
	local onDragonSwapClick = props.OnDragonSwapClick
	local currentDragonSwapType = props.CurrentDragonSwapType
	local isControllerActive = props.IsControllerActive and visible
	local openAtFruit = props.OpenAtFruit
	local lastInput = useLastInput()
	local state, setState = React.useState(Vector2.zero)
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState((lastInput == "Touch" and 2 or 1) * 14)
	local state5, setState5 = React.useState(Vector2.zero)
	local state6, setState6 = React.useState(table.freeze({}))
	local state7, setState7 = React.useState(table.freeze({}))
	local selectionCurrentAlphas = useSelectionAnimation(state6, state7, setState6, setState7, 0.1, visible)
	local state8, setState8 = React.useState(nil)
	local state9, setState9 = React.useState(nil)
	local state10, setState10 = React.useState(nil)
	local state11, setState11 = React.useState(Rect.new())
	local state12, setState12 = React.useState(nil)
	local state13, setState13 = React.useState(false)
	local state14, setState14 = React.useState(0)
	local v5 = useFruitPrices(fruits)
	React.useEffect(function()
		if state12 == nil then
			return
		end

		if visible then
			local thread = nil
			thread = task.delay(math.max(0, state12 + 0.3 - tick()), function()
				thread = nil
				setState12(nil)
				setState14(0)
			end)
			return function()
				if thread then
					task.cancel(thread)
				end
			end
		else
			setState12(nil)
			setState14(0)
		end
	end, { state12, visible })
	local v6 = useLegacyThumbstick(visible)
	local point = useViewportSize()
	local consoleCurrentIndex

	if state9 then
		consoleCurrentIndex = math.max(state9, 1)
	else
		consoleCurrentIndex = nil
	end

	local v8 = useSpring(
		state3 and state2 and 1 or 0,
		state3 and state2 and 1 or 0,
		lastInput == "Gamepad" and 3 or 0.7,
		lastInput == "Gamepad" and 3 or 1.5
	)
	local v9 = React.useMemo(function()
		for k, v10 in pairs(state6) do
			if v10 then
				return k
			end
		end

		return nil
	end, { state6 })
	local v10 = React.useMemo(function()
		return table.freeze({
			ExitButton = {
				[Enum.KeyCode.DPadLeft] = "ScrollFrame",
				[Enum.KeyCode.DPadDown] = "Card"
			},
			ScrollFrame = {
				[Enum.KeyCode.DPadUp] = "ExitButton",
				[Enum.KeyCode.DPadRight] = "ExitButton",
				[Enum.KeyCode.DPadLeft] = "Card",
				[Enum.KeyCode.DPadDown] = "Card"
			},
			Card = {
				[Enum.KeyCode.DPadLeft] = "ScrollFrame",
				[Enum.KeyCode.DPadRight] = "ScrollFrame"
			}
		})
	end)
	local v11 = use("LegacyFruitShopControllerMap")
	local isVisible

	if lastInput == "Gamepad" and v9 == nil then
		isVisible = isControllerActive and props.IsVisible
	else
		isVisible = false
	end

	local v14

	if lastInput == "Gamepad" and v9 == nil then
		v14 = isControllerActive and props.IsVisible
	else
		v14 = false
	end

	local v15, tagConversions, _ = useControllerMap("ScrollFrame", isVisible, v14, v11, v10)
	React.useEffect(function()
		setState10(v6)
	end, { v6 })
	React.useEffect(function()
		local inputBeganConnection

		if lastInput == "Gamepad" and visible and isControllerActive and v9 == nil then
			inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.ButtonB then
					setState9(nil)
					onExitClick()
				end
			end)
		else
			inputBeganConnection = nil
		end

		return function()
			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end
		end
	end, {
		lastInput,
		visible,
		isControllerActive,
		v9
	})
	local v17 = React.useMemo(function()
		local result = {}

		for k, value in pairs(selectionCurrentAlphas) do
			result[k] = TweenService:GetValue(math.clamp(value, 0, 1), quad, inOut)
		end

		table.freeze(result)
		return result
	end, {
		selectionCurrentAlphas,
		0.1,
		quad,
		inOut
	})
	local sortedFruitList = React.useMemo(function()
		local v19 = {}
		local fruits2 = {}

		for _, fruit in ipairs(fruits) do
			if not (fruit.PermanentOnly == false or not onTempPurchaseClick) then
				continue
			end

			assert(v19[fruit.Name] == nil, (`duplicate fruit name: {fruit.Name}`))
			table.insert(fruits2, fruit)
			v19[fruit.Name] = (fruit.SortOrderOffset or 0) * 10000000000 + (fruit.Price or 0) + 10000000 * (v5[fruit.Name] or 0) + 10000000000 * fruit.Rarity.Value
		end

		table.sort(fruits2, function(a, b)
			return v19[a.Name] < v19[b.Name]
		end)
		table.freeze(fruits2)
		return fruits2
	end, { fruits, onTempPurchaseClick, v5 })
	local openCardIndex = React.useMemo(function()
		if v9 then
			for i, v20 in ipairs(sortedFruitList) do
				if v20.Name == v9 then
					return i
				end
			end
		end

		return nil
	end, { v9, sortedFruitList })
	local closedCardAbsoluteHeight = React.useMemo(function()
		return (math.round(state11.Width * 0.22435897435897437))
	end, { state11.Width, 0.22435897435897437 })
	local openPanelAbsoluteHeight = React.useMemo(function()
		return math.round(state11.Width * 0.125) + 4
	end, { state11.Width, 0.125, 4 })
	local v22 = React.useMemo(function()
		local v23 = (#sortedFruitList - 1) * 8 + 8
		local total = 0

		for _, v24 in ipairs(sortedFruitList) do
			local v25 = v17[v24.Name]

			if v25 then
				total += closedCardAbsoluteHeight + openPanelAbsoluteHeight * v25
			else
				total += closedCardAbsoluteHeight
			end
		end

		return total + v23 + 8
	end, {
		sortedFruitList,
		closedCardAbsoluteHeight,
		openPanelAbsoluteHeight,
		v17,
		8,
		4
	})
	local v23 = React.useMemo(function()
		return getAllCardTargets(sortedFruitList, state11, closedCardAbsoluteHeight, openPanelAbsoluteHeight)
	end, {
		sortedFruitList,
		state11.Height,
		closedCardAbsoluteHeight,
		openPanelAbsoluteHeight
	})
	local v24 = React.useMemo(function()
		local v25 = v23 and openAtFruit and v23[openAtFruit]

		if v25 then
			return v25
		end

		return getInitialCanvasPosition()
	end, { v15, openAtFruit, v23 })
	local v26

	if state3 then
		v26 = state3.Y / v22
	else
		v26 = state.Y / v22
	end

	local v27

	if state3 then
		v27 = state3.Y / v22
	else
		v27 = state.Y / v22
	end

	local v28 = useSpring(v26, v27, lastInput == "Gamepad" and 0.3 or 0.7, lastInput == "Gamepad" and 0.3 or 1.5) * v22

	if v22 > 0 and closedCardAbsoluteHeight > 0 and closedCardAbsoluteHeight < v22 then
		if v24 and state13 == false then
			setState2(state)
			setState3(Vector2.new(0, (math.clamp(v24, 0, v22 - closedCardAbsoluteHeight))))
			setState13(true)
		else
			setInitialCanvasPosition(state.Y)
		end
	end

	React.useEffect(function()
		if not visible then
			return function() end
		end

		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			local vector

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				vector = Vector2.new(input.Position.X, input.Position.Y)
			end

			if vector then
				local v29 = vector - state5

				if v29.X >= state11.Width and v29.X <= state11.Width + state4 and v29.Y >= 0 and v29.Y <= state11.Height then
					local v30 = math.clamp(v29.Y / state11.Height, 0, 1)
					local vector2 = Vector2.new(state.X, (math.round(v30 * v22)))

					if vector2.Y ~= math.round(state.Y) then
						setState2(state)
						setState3(vector2)
					end
				end
			end
		end)
		return function()
			inputEndedConnection:Disconnect()
		end
	end, {
		state11,
		state5,
		state4,
		v22,
		state,
		visible
	})
	local canvasPosition = React.useMemo(function()
		if state3 and state2 and v8 then
			return Vector2.new(state.X, (math.clamp(v28, 0, (math.max(1, v22 - state11.Height)))))
		end

		return state
	end, {
		state11,
		state,
		state3,
		state2,
		v8,
		v22,
		v28
	})

	if v8 >= 1 then
		if state2 then
			setState2(nil)
		end

		if state3 and lastInput ~= "Gamepad" then
			setState3(nil)
		end
	end

	local cardBounds = React.useMemo(function()
		local v31 = 12
		local numberRanges = {}

		for i, v32 in ipairs(sortedFruitList) do
			local v33 = v17[v32.Name] or 0
			local v34 = v31 + (closedCardAbsoluteHeight + math.round(openPanelAbsoluteHeight * v33))
			numberRanges[i] = NumberRange.new(v31, v34)
			v31 = v34 + 8
		end

		return numberRanges
	end, {
		sortedFruitList,
		v17,
		closedCardAbsoluteHeight,
		openPanelAbsoluteHeight
	})
	local midCardIndex = React.useMemo(function()
		if openCardIndex then
			return openCardIndex
		end

		if lastInput == "Gamepad" and consoleCurrentIndex then
			return consoleCurrentIndex
		end

		for i, v32 in ipairs(cardBounds) do
			if v32.Min >= state11.Min.Y and v32.Max <= state11.Max.Y or openCardIndex == i then
				return i
			end
		end

		return #cardBounds
	end, {
		cardBounds,
		state11,
		lastInput,
		consoleCurrentIndex
	})
	log("target", v15, "Mid", "mid-index", midCardIndex, "target-index", state8)
	React.useEffect(function()
		local inputEndedConnection

		if lastInput == "Gamepad" and midCardIndex and not state8 and not openCardIndex and v15 == "Card" then
			if state10 then
				setState10(nil)

				if state10 == Enum.KeyCode.DPadUp then
					setState8((math.max(1, midCardIndex - 1)))
				elseif state10 == Enum.KeyCode.DPadDown then
					setState8((math.min(#sortedFruitList, midCardIndex + 1)))
				end
			end

			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.DPadUp then
					setState8((math.max(1, midCardIndex - 1)))
				elseif input.KeyCode == Enum.KeyCode.DPadDown then
					setState8((math.min(math.max(1, #sortedFruitList), midCardIndex + 1)))
				end
			end)
		else
			inputEndedConnection = nil
		end

		return function()
			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end
	end, {
		lastInput,
		midCardIndex,
		openCardIndex,
		sortedFruitList,
		state8,
		consoleCurrentIndex,
		v15,
		state10
	})
	local v32

	if point.X < 1000 then
		v32 = lastInput == "Touch"
	else
		v32 = false
	end

	local buildQuality

	if lastInput == "Gamepad" or not state12 then
		buildQuality = "Full"
	else
		local v34 = state14 * point.Y
		buildQuality = closedCardAbsoluteHeight * 0.15 < v34 and "VisualOnly" or state14 * point.Y > 1 and "VisualOnly" or "Full"
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		Visible = visible,
		Active = false,
		BackgroundTransparency = 1
	}, props)
	local scrim

	if props.IsVisible then
		scrim = createElement("Frame", {
			ZIndex = CONSTANTS.LAYER.CONTENT,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = v32 and 0 or 1,
			Size = UDim2.fromScale(1, 1)
		})
	end

	local menu

	if props.IsVisible then
		local v41 = {
			ZIndex = CONSTANTS.LAYER.RAISED,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Size = 0
		}
		local size

		if v32 then
			size = UDim2.new(1, -8, 1, -8)
		else
			size = UDim2.fromScale(0.52, 0.72)
		end

		v41.Size = size
		local uIAspectRatioConstraint

		if not v32 then
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.35,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height
			})
		end

		menu = createElement("Frame", v41, {
			UIAspectRatioConstraint = uIAspectRatioConstraint,
			UISizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(1e999, 1e999),
				MinSize = Vector2.new(350, (math.min(400, point.Y * 0.9)))
			}),
			Content = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(1, 1)
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Wraps = false,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					HorizontalFlex = Enum.UIFlexAlignment.None,
					ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					VerticalFlex = Enum.UIFlexAlignment.None
				}),
				Header = createElement(header, {
					ReleaseDate = fruitReleaseDate,
					TagConversions = tagConversions,
					OnTempPurchaseClick = onTempPurchaseClick,
					OnExitClick = onExitClick
				}),
				Body = createElement("Frame", {
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0.845)
				}, {
					ScrollingFrame = createElement(VirtualList, {
						Active = true,
						Selectable = true,
						BackgroundColor3 = color,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						CanvasSize = UDim2.fromOffset(0, v22),
						SelectionGroup = false,
						ScrollBarThickness = lastInput == "Touch" and 28 or 14,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						VerticalScrollBarInset = Enum.ScrollBarInset.Always,
						CanvasPosition = canvasPosition,
						Size = UDim2.fromScale(1, 1),
						ItemProperties = {
							SortedFruitList = sortedFruitList,
							CardBounds = cardBounds,
							CurrentCanvasPosition = state,
							ClosedCardAbsoluteHeight = closedCardAbsoluteHeight,
							OpenPanelAbsoluteHeight = openPanelAbsoluteHeight,
							SelectionTargets = state6,
							CanvasPosition = canvasPosition,
							Equipped = equipped,
							Owned = owned,
							Locked = locked,
							BuildQuality = buildQuality,
							IsControllerActive = isControllerActive,
							SelectionCurrentAlphas = selectionCurrentAlphas,
							SelectionCurrentStarts = state7,
							LastInput = lastInput,
							OpenCardIndex = openCardIndex,
							MidCardIndex = midCardIndex,
							ConsoleMidTarget = state8,
							ConsoleCurrentIndex = consoleCurrentIndex,
							TagConversions = tagConversions,
							CurrentDragonSwapType = currentDragonSwapType,
							OnEggClick = props.OnEggClick,
							SetCanvasLockInitialPosition = setState2,
							SetCanvasLockTargetPosition = setState3,
							OnGiftClick = onGiftClick,
							OnMutationClick = props.OnMutationClick,
							OnPermPurchaseClick = onPermPurchaseClick,
							OnTempPurchaseClick = onTempPurchaseClick,
							OnDragonSwapClick = onDragonSwapClick,
							SetSelectionTargets = setState6,
							SetSelectionCurrentStarts = setState7,
							OnCardClick = onCardClick,
							SetConsoleCurrentIndex = setState9,
							SetConsoleMidTarget = setState8,
							SetLastWindowArea = function(rect: Rect)
								if state11.Min.X ~= rect.Min.X or state11.Min.Y ~= rect.Min.Y or state11.Max.X ~= rect.Max.X or state11.Max.Y ~= rect.Max.Y then
									local v54 = rect.Min.Y - state11.Min.Y

									if math.abs(v54) > 1 then
										setState14((math.abs(v54 / point.Y)))
										setState12(tick())
									end

									setState11(rect)
								end
							end
						},
						ItemConstructor = windowItems,
						[React.Change.AbsolutePosition] = function(p)
							setState5(p.AbsolutePosition)
						end,
						[React.Change.ScrollBarThickness] = function(p)
							setState4(p.ScrollBarThickness)
						end,
						[React.Change.CanvasPosition] = function(p)
							setState(p.CanvasPosition)
						end,
						[React.Tag] = tagConversions.ScrollFrame
					}),
					VerticalDivider = createElement("Frame", {
						BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.new(1, -state4 - 2, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						ZIndex = CONSTANTS.LAYER.RAISED
					})
				}),
				Footer = createElement("Frame", {
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.06)
				}, {
					FooterTitle = createElement("TextLabel", {
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						TextScaled = true,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.fromScale(0.812, 0.8),
						Text = "Purchased fruits will directly replace your current fruit.",
						TextXAlignment = Enum.TextXAlignment.Left
					}),
					UIPadding = createElement("UIPadding", {
						PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.MD,
						PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XS,
						PaddingRight = UDim.new(0.006, 0),
						PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.MD
					})
				})
			})
		})
	end

	return createElement("Frame", mergeFrame, {
		Scrim = scrim,
		Menu = menu
	})
end

return function(p)
	local v = React.useContext(DrawContext)
	return createElement(DrawContext.Provider, {
		value = (not p.IsVisible or p.IsHidden) and "Offscreen" or v
	}, {
		Shop = createElement(fruitShop, p)
	})
end