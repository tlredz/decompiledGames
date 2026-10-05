local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
require(script.Parent.Parent.Types)
local Button = require(script.Parent.Parent.Button)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v, _, _ = useSelection()
	local v2

	if v then
		v2 = Skin.Definition.Recipe.match(v):asNullable()
	else
		v2 = nil
	end

	local v3

	if v then
		v3 = ItemConfig.match(v):asNullable()
	else
		v3 = nil
	end

	local v5

	if v3 then
		v5 = v3.Economy and v3.Economy.PurchaseWith or v3.Index.ItemId or nil
	end

	local v6 = useRobuxPrice(v5)
	local v7 = React.useMemo(function()
		if v3 then
			return (ItemConfig.Query.selectOne({
				Index = {
					IdType = "Redeemable",
					StorageKey = v3.Index.StorageKey
				}
			}):asNullable())
		end

		return nil
	end, { v3 })
	local v8 = React.useMemo(function()
		if v2 == nil then
			return nil
		end

		for k, ingredient in v2.Ingredients do
			if not props.CraftingInventory[k] or props.CraftingInventory[k] < ingredient then
				return false
			end
		end

		return true
	end, { v2, props.CraftingInventory })
	local robux

	if not (v7 == nil or v3 == nil or not v7.Economy or not v7.Economy.ProductId or v6 == nil or table.find(
		props.Owned,
		v3.Index.ItemId
	) ~= nil) then
		robux = createElement(Button, {
			AnchorPoint = Vector2.new(1, 0.5),
			LayoutOrder = 3,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.new(0.5, -2, 1, 0),
			Text = `R${v6}`,
			Variant = "Green",
			ZIndex = 4,
			[React.Event.Activated] = function()
				props.OnAction({
					Type = "Purchase",
					ItemId = v7.Index.ItemId
				})
			end
		})
	end

	local craft

	if not (v3 == nil or v8 == nil or table.find(props.Owned, v3.Index.ItemId) ~= nil) then
		craft = createElement(Button, {
			AnchorPoint = Vector2.new(0, 0.5),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(0.5, -2, 1, 0),
			Text = "Craft",
			IsDisabled = not v8,
			Variant = "Yellow",
			ZIndex = 4,
			[React.Event.Activated] = function()
				props.OnAction({
					Type = "Craft",
					ItemId = v3.Index.ItemId
				})
			end
		})
	end

	local gift

	if v3 and v7 and v7.Economy and v7.Economy.ProductId and table.find(props.Owned, v3.Index.ItemId) ~= nil then
		gift = createElement(Button, {
			AnchorPoint = Vector2.new(1, 1),
			LayoutOrder = 3,
			Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromScale(0.333, 1),
			Text = "Gift",
			Icon = "rbxassetid://11332562153",
			Variant = "Yellow",
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = function()
				props.OnAction({
					Type = "Gift",
					ItemId = v7.Index.ItemId
				})
			end
		})
	end

	local v9 = {
		Robux = robux,
		Craft = craft,
		Gift = gift
	}
	local count = 0

	for _, _ in v9 do
		count += 1
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Color3.fromRGB(29, 29, 29),
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 2,
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromScale(1, 0.18),
		BackgroundTransparency = count > 0 and 0 or 1
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.SM
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Buttons = createElement(React.Fragment, {}, v9)
	})
end