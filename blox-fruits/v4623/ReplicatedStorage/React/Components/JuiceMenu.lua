local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
require(script.Types)
local ItemSelection = require(game.ReplicatedStorage.React.Contexts.ItemSelection)
local AdorneeGrid = require(script.AdorneeGrid)
local Grid = require(script.Grid)
local Menu = require(script.Menu)
local Footer = require(script.Footer)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	local v = state2 == nil
	local v2 = use("JuiceMenu")
	useGuiServiceSelect(v2, useDrawContext() == "Default")
	local adornees = React.useMemo(function()
		local v5 = {}
		local result = {}

		for _, item in props.Items do
			local nullable = Modification.matchAdornee(item):asNullable()

			if not nullable or v5[nullable] or Modification.matchDefaultSkin(nullable):asNullable() == item then
				continue
			end

			v5[nullable] = true
			table.insert(result, nullable)
		end

		table.sort(result)
		return result
	end, { props.Items })
	local items = React.useMemo(function()
		if state2 == nil then
			return props.Items
		end

		local result = {}

		for _, item in props.Items do
			if Modification.matchAdornee(item):asNullable() == state2 then
				table.insert(result, item)
			end
		end

		return result
	end, { props.Items, state2 })

	local function handleAction(p)
		if p.Type ~= "Back" or state2 == nil then
			props.OnAction(p)
			return
		end

		setState(nil)
		setState2(nil)
	end

	local v8 = {
		[React.Tag] = v2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.new(0.5, 0, 0.5, -30),
		SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
		SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
		SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
		SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
		SelectionGroup = true,
		Size = UDim2.fromScale(0.5, 0.5)
	}
	local v11 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}
	local v14 = {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 2,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(1, 0.57)
	}
	local v15 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Menu = 0
	}
	local v18 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}
	local provider = ItemSelection.Provider
	local v25 = {
		BackgroundColor3 = Color3.fromRGB(74, 74, 74),
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 1,
		Size = UDim2.fromScale(0.55, 1),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local grid

	if v then
		grid = createElement(AdorneeGrid, {
			Adornees = adornees,
			OnSelect = function(p: number)
				setState(nil)
				setState2(p)
			end
		})
	else
		grid = createElement(Grid, {
			Items = items,
			Unlocked = props.Unlocked,
			Owned = props.Owned
		})
	end

	local v22 = {
		GridContainer = createElement("Frame", v25, {
			Grid = grid,
			UIPadding = createElement("UIPadding", {
				PaddingRight = UDim.new(0, 6)
			})
		}),
		Menu = 0
	}
	local menu

	if not v then
		menu = createElement(Menu, {
			Unlocked = props.Unlocked,
			Owned = props.Owned,
			CraftingInventory = props.CraftingInventory,
			OnAction = handleAction
		})
	end

	v22.Menu = menu
	v15.Menu = createElement("Frame", v18, {
		ItemSelectionContext = createElement(provider, {
			value = {
				Selection = state,
				SetSelection = function(itemId, networkedUID)
					setState(itemId and {
						ItemId = itemId,
						NetworkedUID = networkedUID
					} or nil)
				end
			}
		}, v22),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	local children2 = {
		Content = createElement("Frame", v14, v15),
		Title = 0,
		UIListLayout = 0,
		Bottom = 0
	}
	local v31 = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 1,
		Position = UDim2.fromScale(0, 0.2285),
		Size = UDim2.new(1, 0, 0.1, -2)
	}
	local v35 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.7, 0.8),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true
	}
	local text

	if v then
		text = props.AdorneeHeaderText or "Select an item"
	else
		text = props.HeaderText
	end

	v35.Text = text
	v35.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
	children2.Title = createElement("Frame", v31, {
		TextLabel = createElement("TextLabel", v35)
	})
	children2.UIListLayout = createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	children2.Bottom = createElement(Footer, {
		Text = props.FooterText,
		OnAction = handleAction
	})
	return createElement("Frame", v8, {
		Main = createElement("Frame", v11, children2),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(800, 800),
			MinSize = Vector2.new(350, 400)
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.5
		})
	})
end