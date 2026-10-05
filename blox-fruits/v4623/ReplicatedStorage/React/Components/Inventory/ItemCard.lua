local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useMoveList = require(game.ReplicatedStorage.React.Hooks.Item.useMoveList)
local useStats = require(game.ReplicatedStorage.React.Hooks.Item.useStats)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
local useTemporaryDescription = require(game.ReplicatedStorage.React.Hooks.Inventory.useTemporaryDescription)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useIsEquipped = require(game.ReplicatedStorage.React.Hooks.Item.useIsEquipped)
local useBloxFruit = require(game.ReplicatedStorage.React.Hooks.Player.useBloxFruit)
local useInitialSelection = require(game.ReplicatedStorage.React.Hooks.Inventory.useInitialSelection)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local Carousel = require(script.Carousel)
local ActionButton = require(script.ActionButton)
local MoveList = require(script.MoveList)
local StatsList = require(script.StatsList)
local Overview = require(script.Overview)
local Display = require(script.Display)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	[PseudoEnum.InventoryAction.FindFromBuildMenu] = "View",
	[PseudoEnum.InventoryAction.OpenFruitShopFromBuildMenu] = "Shop",
	[PseudoEnum.InventoryAction.Favorite] = "★"
}
local v2 = {}

for _, v3 in PseudoEnum.getEnumItems("InventoryAction") do
	v2[v3] = v[v3] or FormatUtil.pascalCaseToTitle(v3):split(" ")[1]
end

local createElement = React.createElement
return function(props)
	local state, setState = React.useState(1)
	local selectable

	if useDrawContext() == "Default" then
		selectable = props.Selectable ~= false
	else
		selectable = false
	end

	local v4, v5, _ = useSelection()
	local v6 = useMatch(v4)
	local text = not v6 and "" or v6.Display.Name or v6.Index.StorageKey
	local _, _, v8 = useInitialSelection()
	local v9 = useConfig()
	local v10 = useCurrentGroup()
	local v11 = {}
	local v12 = useIsEquipped(v4, v5)
	local v13 = useBloxFruit()
	local v14 = v13 and v6 and v6.Index.ItemId == v13.ItemId and v10 == "Build" and true or false
	local count = 0
	local purchaseWith = v6 and v6.Economy and v6.Economy.PurchaseWith
	local v15 = useRobuxPrice(purchaseWith)

	if v6 and v4 then
		local clone = table.clone(v9.Actions or v6.Inventory.Actions)

		if v9.FavoritingEnabled and v10 ~= PseudoEnum.InventoryItemGroup.Build and props.IsFavoritingEnabled == true then
			table.insert(clone, PseudoEnum.InventoryAction.Favorite)
		end

		if v9.PurchaseTiles then
			local flag = false

			for _, purchaseTile in v9.PurchaseTiles do
				if not (purchaseTile.ItemId == v4 and purchaseTile.NetworkedUID == v5) then
					continue
				end

				flag = true
				break
			end

			if flag then
				table.insert(clone, PseudoEnum.InventoryAction.Purchase)
			end
		end

		if not table.find(clone, PseudoEnum.InventoryAction.Purchase) then
			v15 = nil
		end

		for k, v16 in clone do
			if v10 == PseudoEnum.InventoryItemGroup.Build then
				if table.find(v6.Inventory.Tags, "HideActionsOnBuildMenu") and v16 ~= PseudoEnum.InventoryAction.OpenFruitShopFromBuildMenu and v16 ~= PseudoEnum.InventoryAction.FindFromBuildMenu then
					continue
				end
			elseif v16 == PseudoEnum.InventoryAction.OpenFruitShopFromBuildMenu or v16 == PseudoEnum.InventoryAction.FindFromBuildMenu then
				continue
			end

			if not ((not v14 or v16 ~= PseudoEnum.InventoryAction.EquipFruit) and (v16 ~= "Purchase" or v15 ~= nil)) then
				continue
			end

			count += 1
			local formatted = `Action-{v16}`
			local tag = React.Tag
			local v20

			if count == 1 then
				v20 = props.ActionButtonTag
			end

			local v19 = {
				[tag] = v20,
				LayoutOrder = k,
				Selectable = selectable,
				Size = v16 == PseudoEnum.InventoryAction.Favorite and UDim2.fromScale(1, 1) or UDim2.fromScale(2.5, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY
			}
			local text2

			if v15 and v16 == "Purchase" then
				text2 = `{FormatUtil.ROBUX_ICON}{v15}`
			else
				text2 = (v2[v16] or "???"):gsub(
					"Equip",
					v16 == PseudoEnum.InventoryAction.EquipItem and v12 and "Unequip" or "Equip"
				)
			end

			v19.Text = text2
			local v22 = v16

			v19[React.Event.Activated] = function()
				if v22 == PseudoEnum.InventoryAction.FindFromBuildMenu then
					v8(v4, v5)
				end

				props.OnAction(v22)
			end

			v11[formatted] = createElement(ActionButton, v19)
		end
	end

	local v17

	if v6 then
		v17 = v6.Index.ItemId
	end

	local v18 = useMoveList(v17)
	local v19 = useStats(v4, v5)
	local v20 = v19 and #v19 > 0

	if v20 and v6 and v6.Index.IdType == "Moveset" then
		v20 = false
	end

	local v21, _ = useTemporaryDescription()
	local v22 = v6 and (v6.Display.Description ~= nil or v21 ~= nil or v6.Index.IdType == "Fish")
	local v23 = v4 and v18 and #v18 > 0
	local v24 = React.useMemo(function()
		local v25 = {}

		if v23 then
			table.insert(v25, MoveList)
		end

		if v20 then
			table.insert(v25, StatsList)
		end

		if v22 then
			table.insert(v25, Overview)
		end

		return v25
	end, { v22, v23, v20 })

	if math.max(1, #v24) < state then
		setState((math.max(1, #v24)))
		state = math.max(1, #v24)
	end

	React.useEffect(function()
		setState(1)
	end, { v4 })
	local contentComponent = v24[state] or Overview
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, props)
	local v28 = {
		UIStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 1)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top
		}),
		Display = createElement(Display, {
			AutomaticSize = Enum.AutomaticSize.None,
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.34)
		}),
		Title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ClipsDescendants = true,
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0.12)
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
				PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.SM
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PANEL.BACKGROUND),
					ColorSequenceKeypoint.new(
						0.5,
						CONSTANTS.COLOR.PANEL.BACKGROUND:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.25)
					),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PANEL.BACKGROUND)
				})
			}),
			Text = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
				LineHeight = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		Carousel = v4 and contentComponent and createElement(Carousel, {
			ContentComponent = contentComponent,
			CurrentPage = state,
			LayoutOrder = 3,
			MaxPage = #v24,
			OnPageChanged = function(p: number)
				setState(p)
			end,
			Selectable = selectable,
			Size = UDim2.new(1, 0, 0.4, 0)
		}),
		Buttons = 0
	}
	local buttons

	if count ~= 0 then
		buttons = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 4,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.14)
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XS,
				PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.LG
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.OFFSET.MD,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Actions = createElement(React.Fragment, {}, v11)
		})
	end

	v28.Buttons = buttons
	return createElement("Frame", mergeFrame, v28)
end