local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(script.Types)
require(game.ReplicatedStorage.React.RobloxTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Spritesheets)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
local TemporaryDescription = require(game.ReplicatedStorage.React.Contexts.Inventory.TemporaryDescription)
local ItemCard = require(game.ReplicatedStorage.React.Components.Inventory.ItemCard)
local Main = require(script.Main)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function log(...)
	RunService:IsStudio()
end

function getPosition(p: number, udim: UDim2)
	return udim:Lerp(UDim2.fromScale(0.5, 1.25), 1 - p)
end

function getAnchorPoint(p: number, point: Vector2)
	return point:Lerp(Vector2.new(0.5, 0), 1 - p)
end

return function(props)
	log("redraw Inventory")
	local state, setState = React.useState(true)
	log((` - isMoving: {state}`))
	local ref = React.useRef(Spring.new(1, 4, 0))
	local v = use("InventoryTransitionBox")
	log((` - transitionBoxTag: {v}`))
	local v2 = use("InventoryMain")
	log((` - mainBracket: {v2}`))
	local ref2 = React.useRef(nil)
	local guiObject = useFirstTagged(v)

	if not (guiObject and guiObject:IsA("GuiObject")) then
		guiObject = nil
	end

	ref2.current = guiObject
	useSpringEffect(props.IsOpen and 1 or 0, ref.current, true, function(p: number, _: number)
		local current = ref2.current

		if current then
			local getPosition2 = getPosition
			local v3

			if props.Position then
				v3 = props.Position
			else
				v3 = UDim2.fromScale(0.5, 0.5)
			end

			current.Position = getPosition2(p, v3)
			local getAnchorPoint2 = getAnchorPoint
			local v4

			if props.AnchorPoint then
				v4 = props.AnchorPoint
			else
				v4 = Vector2.new(0.5, 0.5)
			end

			current.AnchorPoint = getAnchorPoint2(p, v4)
		end
	end, function()
		setState(true)
	end, function()
		setState(false)
	end)
	local v3 = useViewportSize()
	log((` - viewportSize: {v3}`))
	local v4 = useLastInput()
	local v5 = useConfig()
	local v6, _, _ = useSelection()
	local actionButtonTag = use("InventoryActionButton")
	local v8 = useDrawContext()
	local selectable = v8 == "Default"
	useGuiServiceSelect(v, props.IsOpen and not state and selectable)
	local v10 = ref.current:Get()

	if props.IsOpen == false and v10 < 0.01 then
		props.OnExitComplete()
	end

	local ref3 = React.useRef(tick())
	local tiles2 = React.useMemo(function()
		local tiles = {}

		for _, tile in props.Tiles do
			local unwrapped = ItemConfig.match(tile.ItemId):unwrap()

			if not (not (#unwrapped.Inventory.Tags > 0) or not table.find(
				unwrapped.Inventory.Tags,
				PseudoEnum.InventoryItemTag.HasInvisibleTile
			) or v5.ShowInvisibleTiles == true) then
				continue
			end

			table.insert(tiles, tile)
		end

		table.freeze(tiles)
		return tiles
	end, { props.Tiles, v5.ShowInvisibleTiles })
	local state2, setState2 = React.useState(PseudoEnum.InventoryItemGroup.Backpack)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(PseudoEnum.InventorySortType.Rarity)
	local state5, setState5 = React.useState(nil)
	React.useEffect(function()
		if not (state or props.IsOpen) then
			setState3(nil)
			setState4(PseudoEnum.InventoryItemGroup.Backpack)
		end
	end, { props.IsOpen, state })
	local v12 = math.max(350, v3.Y * 0.6)
	local uDim = UDim2.fromOffset(v12 / 2.1, v12)
	local state6, setState6 = React.useState(nil)
	local ref4 = React.useRef(false)

	if not props.IsOpen then
		ref4.current = false
	end

	if not ref4.current and props.OnTabChange then
		ref4.current = true
		task.spawn(function()
			props.OnTabChange(state2)
		end)
	end

	local provider = Navigation.Provider
	local provider2 = TemporaryDescription.Provider
	local v21 = {
		[React.Tag] = v,
		Active = false
	}
	local anchorPoint

	if not state then
		local getAnchorPoint2 = getAnchorPoint
		local v23

		if props.AnchorPoint then
			v23 = props.AnchorPoint
		else
			v23 = Vector2.new(0.5, 0.5)
		end

		anchorPoint = getAnchorPoint2(v10, v23)
	end

	v21.AnchorPoint = anchorPoint
	v21.AutomaticSize = Enum.AutomaticSize.Y
	v21.BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	v21.BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	v21.LayoutOrder = props.LayoutOrder
	local position

	if not state then
		local getPosition2 = getPosition
		local v24

		if props.Position then
			v24 = props.Position
		else
			v24 = UDim2.fromScale(0.5, 0.5)
		end

		position = getPosition2(v10, v24)
	end

	v21.Position = position
	v21.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	v21.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	v21.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	v21.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	v21.SelectionGroup = true
	v21.Size = UDim2.fromScale(1, 0)
	v21.SizeConstraint = props.SizeConstraint
	v21.Visible = props.Visible ~= false and (v10 > 0.01 or props.IsOpen)
	v21.ZIndex = props.ZIndex
	local v25 = {
		Layout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		DrawContextProvider = 0
	}
	local v28 = {
		Context = state == false and props.IsOpen == false and "Offscreen" or state and v8 == "Default" and "Moving" or v8
	}
	local leftCard

	if not state then
		leftCard = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 0,
			Size = uDim
		}, {
			AspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.7,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Width
			})
		})
	end

	local v29 = {
		LeftCard = leftCard,
		Main = createElement(Main, {
			[React.Tag] = v2,
			ActionButtonTag = actionButtonTag,
			AnchorPoint = Vector2.new(0.5, 0.5),
			IsMoving = state,
			OnTabChange = props.OnTabChange,
			LayoutOrder = 2,
			OnExit = props.OnExit,
			Position = UDim2.fromScale(0.5, 0.5),
			Selectable = selectable,
			Size = UDim2.fromOffset(0, 0),
			Tiles = tiles2,
			ZIndex = 2
		}),
		RightCard = 0
	}
	local rightCard

	if not state then
		local v37 = {
			Active = v4 == "Touch",
			AutomaticSize = Enum.AutomaticSize.None,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 2,
			Size = uDim,
			ZIndex = 3
		}
		local v38 = {
			AspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.7,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Width
			}),
			ItemCard = 0
		}
		local itemCard

		if props.OnAction then
			itemCard = createElement(ItemCard, {
				ActionButtonTag = actionButtonTag,
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				IsFavoritingEnabled = #props.Tiles > 50,
				OnAction = function(p)
					if ref3.current + 1 > tick() then
						log("Action debounce triggered, ignoring action:", p)
						return
					end

					ref3.current = tick()
					props.OnAction(p)
				end,
				OnPurchase = function(p)
					log("Purchase action for tile:", p)
				end,
				Position = UDim2.fromScale(0.5, 0.5),
				Selectable = selectable,
				Size = UDim2.fromScale(1, 1),
				Visible = v6 ~= nil
			})
		end

		v38.ItemCard = itemCard
		rightCard = createElement("Frame", v37, v38)
	end

	v29.RightCard = rightCard
	v25.DrawContextProvider = createElement(DrawContextProvider, v28, v29)
	return createElement(provider, {
		value = {
			Group = state2,
			Bracket = state3,
			SortType = state4,
			InitialSelection = state5,
			SetNavigation = function(p, p2, p3, p4)
				if p4 and state5 ~= p4 then
					setState5(p4)
				else
					setState5(nil)
				end

				if state2 ~= p then
					if props.OnTabChange then
						task.spawn(function()
							props.OnTabChange(p)
						end)
					end

					setState2(p)
				end

				if state3 ~= p2 then
					setState3(p2)
				end

				if p3 ~= state4 then
					setState4(p3)
				end
			end
		}
	}, {
		TemporaryDescription = createElement(provider2, {
			value = {
				Description = state6,
				SetDescription = function(message: string?, itemId: number?, networkedUID: string?)
					if message then
						assert(itemId, (`bad itemId for message: "{message}"`))
						local v18 = {
							Message = message,
							ItemId = itemId,
							NetworkedUID = networkedUID
						}
						table.freeze(v18)
						print("SetDescription:", v18)
						setState6(v18)
					else
						print("Clear Description")
						setState6(nil)
					end
				end
			}
		}, {
			Inventory = createElement("Frame", v21, v25)
		})
	})
end